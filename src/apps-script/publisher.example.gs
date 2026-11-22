/**
 * sheets-bigquery-sandbox-pipeline
 * Arquivo: publisher.example.gs
 *
 * Publicador opcional para uma planilha exclusivamente sintética.
 *
 * A publicação permanece desabilitada por padrão.
 *
 * Para habilitá-la conscientemente:
 *
 * 1. use somente uma planilha sintética;
 * 2. inclua [SYNTHETIC] no nome da planilha;
 * 3. configure SBSP_SYNTHETIC_OUTPUT_SPREADSHEET_ID;
 * 4. altere publication.enabled para true;
 * 5. mantenha writeFormulas como false;
 * 6. abra SBSP_MANUAL_AUTHORIZATION;
 * 7. execute somente SBSP_publishSyntheticOutputs.
 */

/**
 * Executa o preflight da publicação.
 *
 * @return {Object}
 */
function SBSP_publicationPreflight() {
  const startedAtMs = Date.now();

  return sbspWithScriptLock_(function() {
    const blockers = [];
    const information = [];
    const checks = {};

    try {
      const config = sbspGetConfig_();

      checks.syntheticDataOnly =
        config.syntheticDataOnly === true;
      checks.productionWritesBlocked =
        config.productionWritesAllowed === false;
      checks.writeFormulasDisabled =
        config.publication.writeFormulas === false;
      checks.manualExecutionOnly =
        config.execution.manualExecutionOnly === true;

      checks.publicationEnabled =
        config.publication.enabled === true;

      if (!checks.publicationEnabled) {
        information.push(
          'A publicação está desabilitada. O modo atual permite somente preview.'
        );
      }

      const preview = sbspBuildPublicationPreview_();

      let output = null;

      if (checks.publicationEnabled) {
        output = sbspValidateSyntheticOutput_();

        checks.outputConfigured =
          output.configured;
        checks.outputIsSpreadsheet =
          output.isSpreadsheet;
        checks.syntheticMarkerPresent =
          output.syntheticMarkerPresent;

        if (!output.configured) {
          blockers.push(
            'A propriedade da planilha sintética de saída não foi configurada.'
          );
        }

        if (
          output.configured &&
          !output.isSpreadsheet
        ) {
          blockers.push(
            'O destino configurado não é uma planilha Google.'
          );
        }

        if (
          output.configured &&
          !output.syntheticMarkerPresent
        ) {
          blockers.push(
            'O nome da planilha de saída precisa conter [SYNTHETIC].'
          );
        }
      }

      information.push(
        'O preflight não escreveu na planilha.'
      );

      information.push(
        'O preflight não criou gatilhos.'
      );

      const result = sbspCreateResult_({
        startedAtMs: startedAtMs,
        success: blockers.length === 0,
        status: blockers.length === 0
          ? 'OK'
          : 'BLOCKED',
        stage: 'PUBLICATION_PREFLIGHT',
        mode: 'PREFLIGHT',
        blockers: blockers,
        information: information,
        measures: {
          preview: preview,
          output: output
            ? {
                configured: output.configured,
                idHash: output.idHash,
                nameHash: output.nameHash,
                isSpreadsheet:
                  output.isSpreadsheet,
                syntheticMarkerPresent:
                  output.syntheticMarkerPresent
              }
            : null
        },
        checks: checks
      });

      sbspLog_(result);
      return result;

    } catch (error) {
      const result = sbspCreateResult_({
        startedAtMs: startedAtMs,
        success: false,
        status: 'BLOCKED',
        stage: 'PUBLICATION_PREFLIGHT',
        mode: 'PREFLIGHT',
        blockers: [String(error.message || error)]
      });

      sbspLog_(result);
      return result;
    }
  });
}

/**
 * Publica os resultados em uma planilha sintética.
 *
 * @return {Object}
 */
function SBSP_publishSyntheticOutputs() {
  const startedAtMs = Date.now();

  return sbspWithScriptLock_(function() {
    try {
      const config = sbspGetConfig_();

      if (!sbspManualAuthorizationIsOpen_()) {
        throw new Error(
          'A autorização manual está fechada.'
        );
      }

      const measures = sbspPublishSyntheticOutputs_();

      const result = sbspCreateResult_({
        startedAtMs: startedAtMs,
        success: true,
        status: 'OK',
        stage: 'SYNTHETIC_PUBLICATION',
        mode: 'MANUAL',
        information: [
          'A publicação utilizou somente uma planilha marcada como sintética.',
          'Nenhuma fórmula foi gravada.',
          'Nenhum gatilho foi criado.'
        ],
        measures: measures,
        checks: {
          syntheticOutput: true,
          productionWriteExecuted: false,
          formulasWritten: false,
          triggerCreated: false
        }
      });

      sbspWriteJsonProperty_(
        config.properties.publisherLastResult,
        result
      );

      sbspLog_(result);
      return result;

    } catch (error) {
      const config = sbspGetConfig_();

      const result = sbspCreateResult_({
        startedAtMs: startedAtMs,
        success: false,
        status: 'BLOCKED',
        stage: 'SYNTHETIC_PUBLICATION',
        mode: 'MANUAL',
        blockers: [String(error.message || error)],
        checks: {
          productionWriteExecuted: false,
          triggerCreated: false
        }
      });

      sbspWriteJsonProperty_(
        config.properties.publisherLastResult,
        result
      );

      sbspLog_(result);
      return result;

    } finally {
      sbspCloseManualAuthorization_();
    }
  });
}

/**
 * Executa a publicação interna.
 *
 * @return {Object}
 */
function sbspPublishSyntheticOutputs_() {
  const config = sbspGetConfig_();

  if (config.publication.enabled !== true) {
    throw new Error(
      'A publicação está desabilitada na configuração.'
    );
  }

  if (config.publication.writeFormulas !== false) {
    throw new Error(
      'A publicação de fórmulas não é permitida.'
    );
  }

  const output = sbspValidateSyntheticOutput_();

  if (
    !output.configured ||
    !output.isSpreadsheet ||
    !output.syntheticMarkerPresent
  ) {
    throw new Error(
      'O destino sintético não foi validado.'
    );
  }

  const data = sbspReadPublicationData_();

  const spreadsheet = SpreadsheetApp.openById(
    output.spreadsheetId
  );

  const indicatorsResult =
    sbspWriteSyntheticSheet_(
      spreadsheet,
      config.publication.indicatorsSheetName,
      data.indicators.headers,
      data.indicators.rows
    );

  const divergencesResult =
    sbspWriteSyntheticSheet_(
      spreadsheet,
      config.publication.divergencesSheetName,
      data.divergences.headers,
      data.divergences.rows
    );

  const exceptionsResult =
    sbspWriteSyntheticSheet_(
      spreadsheet,
      config.publication.exceptionsSheetName,
      data.exceptions.headers,
      data.exceptions.rows
    );

  return {
    outputIdHash: output.idHash,
    indicators: indicatorsResult,
    divergences: divergencesResult,
    exceptions: exceptionsResult
  };
}

/**
 * Gera um preview sem abrir planilha de saída.
 *
 * @return {Object}
 */
function sbspBuildPublicationPreview_() {
  const data = sbspReadPublicationData_();

  return {
    indicators: {
      columns: data.indicators.headers.length,
      rows: data.indicators.rows.length
    },
    divergences: {
      columns: data.divergences.headers.length,
      rows: data.divergences.rows.length
    },
    exceptions: {
      columns: data.exceptions.headers.length,
      rows: data.exceptions.rows.length
    }
  };
}

/**
 * Lê os três resultados no BigQuery.
 *
 * @return {Object}
 */
function sbspReadPublicationData_() {
  const config = sbspGetConfig_();
  const prefix = '`' +
    config.projectId + '.' +
    config.datasetId + '.';

  const indicators = sbspRunQuery_([
    'SELECT',
    '  indicator_level,',
    '  event_date,',
    '  team_code,',
    '  group_code,',
    '  channel,',
    '  campaign,',
    '  total_records,',
    '  valid_records,',
    '  divergence_records,',
    '  converted_records,',
    '  conversion_rate_percentage,',
    '  total_attempts,',
    '  total_estimated_value',
    'FROM',
    '  ' + prefix +
      config.objects.indicatorsView + '`',
    'ORDER BY',
    '  indicator_level,',
    '  event_date,',
    '  team_code,',
    '  channel,',
    '  campaign'
  ].join('\n'));

  const divergences = sbspRunQuery_([
    'SELECT',
    '  occurrence_id,',
    '  source_row_id,',
    '  record_id,',
    '  event_date,',
    '  team_code,',
    '  status,',
    '  converted,',
    '  issue_code,',
    '  issue_description,',
    '  severity',
    'FROM',
    '  ' + prefix +
      config.objects.divergencesView + '`',
    'ORDER BY',
    '  source_row_id,',
    '  issue_code'
  ].join('\n'));

  const exceptions = sbspRunQuery_([
    'SELECT',
    '  occurrence_id,',
    '  source_row_id,',
    '  record_id,',
    '  primary_classification,',
    '  issue_category,',
    '  issue_code,',
    '  issue_description,',
    '  severity',
    'FROM',
    '  ' + prefix +
      config.objects.exceptionsView + '`',
    'ORDER BY',
    '  source_row_id,',
    '  issue_code'
  ].join('\n'));

  return {
    indicators: sbspQueryToMatrix_(indicators),
    divergences: sbspQueryToMatrix_(divergences),
    exceptions: sbspQueryToMatrix_(exceptions)
  };
}

/**
 * Converte o resultado de consulta em cabeçalhos e linhas.
 *
 * @param {Object} query
 * @return {Object}
 */
function sbspQueryToMatrix_(query) {
  const rows = query.rows || [];

  const headers = rows.length > 0
    ? Object.keys(rows[0])
    : [];

  return {
    headers: headers,
    rows: rows.map(function(row) {
      return headers.map(function(header) {
        return row[header];
      });
    })
  };
}

/**
 * Valida a planilha sintética de saída.
 *
 * @return {Object}
 */
function sbspValidateSyntheticOutput_() {
  const config = sbspGetConfig_();

  const spreadsheetId =
    sbspProperties_().getProperty(
      config.publication.spreadsheetIdProperty
    );

  if (!spreadsheetId) {
    return {
      configured: false,
      spreadsheetId: null,
      idHash: null,
      nameHash: null,
      isSpreadsheet: false,
      syntheticMarkerPresent: false
    };
  }

  const file = DriveApp.getFileById(
    spreadsheetId
  );

  const name = file.getName();
  const mimeType = file.getMimeType();

  return {
    configured: true,
    spreadsheetId: spreadsheetId,
    idHash: sbspSha256_(spreadsheetId)
      .substring(0, 16),
    nameHash: sbspSha256_(name)
      .substring(0, 16),
    isSpreadsheet:
      mimeType ===
      'application/vnd.google-apps.spreadsheet',
    syntheticMarkerPresent:
      name.indexOf(
        config.detection.requiredNameMarker
      ) !== -1
  };
}

/**
 * Grava valores em uma aba exclusivamente sintética.
 *
 * @param {GoogleAppsScript.Spreadsheet.Spreadsheet} spreadsheet
 * @param {string} sheetName
 * @param {Array<string>} headers
 * @param {Array<Array<*>>} rows
 * @return {Object}
 */
function sbspWriteSyntheticSheet_(
  spreadsheet,
  sheetName,
  headers,
  rows
) {
  let sheet = spreadsheet.getSheetByName(
    sheetName
  );

  if (!sheet) {
    sheet = spreadsheet.insertSheet(
      sheetName
    );
  }

  sheet.clearContents();

  if (headers.length === 0) {
    return {
      sheetName: sheetName,
      rowsWritten: 0,
      columnsWritten: 0
    };
  }

  const sanitizedRows = rows.map(function(row) {
    return row.map(sbspSanitizeCellValue_);
  });

  const matrix = [headers].concat(
    sanitizedRows
  );

  sheet.getRange(
    1,
    1,
    matrix.length,
    headers.length
  ).setValues(matrix);

  return {
    sheetName: sheetName,
    rowsWritten: sanitizedRows.length,
    columnsWritten: headers.length
  };
}

/**
 * Impede que um texto seja interpretado como fórmula.
 *
 * @param {*} value
 * @return {*}
 */
function sbspSanitizeCellValue_(value) {
  if (value === null || value === undefined) {
    return '';
  }

  if (typeof value !== 'string') {
    return value;
  }

  if (/^[=+\-@]/.test(value)) {
    return "'" + value;
  }

  return value;
}
