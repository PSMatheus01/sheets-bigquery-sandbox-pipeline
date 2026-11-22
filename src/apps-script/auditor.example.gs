/**
 * sheets-bigquery-sandbox-pipeline
 * Arquivo: auditor.example.gs
 *
 * Auditor somente leitura do exemplo sintético.
 *
 * O auditor consulta vw_audit_example e valida:
 * - quantidade de checks;
 * - checks aprovados;
 * - checks reprovados;
 * - parecer final.
 */

/**
 * Executa o preflight da auditoria.
 *
 * @return {Object}
 */
function SBSP_auditorPreflight() {
  const startedAtMs = Date.now();

  return sbspWithScriptLock_(function() {
    try {
      const config = sbspGetConfig_();
      const objects =
        sbspValidatePipelineObjects_();

      const blockers = [];

      if (!objects.valid) {
        blockers.push(
          'Os objetos obrigatórios não estão disponíveis.'
        );
      }

      const result = sbspCreateResult_({
        startedAtMs: startedAtMs,
        success: blockers.length === 0,
        status: blockers.length === 0
          ? 'OK'
          : 'BLOCKED',
        stage: 'AUDITOR_PREFLIGHT',
        mode: 'PREFLIGHT',
        blockers: blockers,
        information: [
          'O preflight executou somente consulta de metadados.',
          'O preflight não modificou objetos do BigQuery.',
          'O preflight não escreveu em planilhas.',
          'O preflight não criou gatilhos.'
        ],
        measures: {
          objects: objects
        },
        checks: {
          requiredObjectsAvailable:
            objects.valid,
          productionWriteExecuted: false,
          spreadsheetWriteExecuted: false,
          triggerCreated: false
        }
      });

      sbspLog_(result);
      return result;

    } catch (error) {
      const result = sbspCreateResult_({
        startedAtMs: startedAtMs,
        success: false,
        status: 'BLOCKED',
        stage: 'AUDITOR_PREFLIGHT',
        mode: 'PREFLIGHT',
        blockers: [String(error.message || error)]
      });

      sbspLog_(result);
      return result;
    }
  });
}

/**
 * Executa a auditoria manual.
 *
 * @return {Object}
 */
function SBSP_runSyntheticAudit() {
  const startedAtMs = Date.now();

  return sbspWithScriptLock_(function() {
    try {
      const config = sbspGetConfig_();

      if (!sbspManualAuthorizationIsOpen_()) {
        throw new Error(
          'A autorização manual está fechada.'
        );
      }

      const audit = sbspRunAudit_();

      const result = sbspCreateResult_({
        startedAtMs: startedAtMs,
        success: audit.approved,
        status: audit.approved
          ? 'OK'
          : 'BLOCKED',
        stage: 'SYNTHETIC_AUDIT',
        mode: 'MANUAL',
        blockers: audit.approved
          ? []
          : [
              'Uma ou mais verificações da auditoria foram reprovadas.'
            ],
        information: [
          'A auditoria executou somente consultas.',
          'Nenhum objeto do BigQuery foi alterado.',
          'Nenhuma planilha foi modificada.',
          'Nenhum gatilho foi criado.'
        ],
        measures: {
          audit: audit
        },
        checks: {
          totalChecksValid:
            audit.totalChecks ===
            config.audit.expectedChecks,
          passedChecksValid:
            audit.passedChecks ===
            config.audit.expectedPassedChecks,
          failedChecksValid:
            audit.failedChecks ===
            config.audit.expectedFailedChecks,
          verdictValid:
            audit.verdict ===
            config.audit.expectedVerdict,
          productionWriteExecuted: false,
          spreadsheetWriteExecuted: false,
          triggerCreated: false
        }
      });

      sbspWriteJsonProperty_(
        config.properties.auditorLastResult,
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
        stage: 'SYNTHETIC_AUDIT',
        mode: 'MANUAL',
        blockers: [String(error.message || error)],
        checks: {
          productionWriteExecuted: false,
          spreadsheetWriteExecuted: false,
          triggerCreated: false
        }
      });

      sbspWriteJsonProperty_(
        config.properties.auditorLastResult,
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
 * Executa a auditoria interna.
 *
 * @return {Object}
 */
function sbspRunAudit_() {
  const config = sbspGetConfig_();

  const sql = [
    'SELECT',
    '  check_order,',
    '  check_id,',
    '  check_group,',
    '  actual_value,',
    '  expected_value,',
    '  check_passed,',
    '  check_status',
    'FROM',
    '  `' + config.projectId + '.' +
      config.datasetId + '.' +
      config.objects.auditView + '`',
    'ORDER BY',
    '  check_order'
  ].join('\n');

  const query = sbspRunQuery_(sql);

  const checks = query.rows.map(function(row) {
    return {
      checkOrder: Number(
        row.check_order || 0
      ),
      checkId: row.check_id,
      checkGroup: row.check_group,
      actualValue: row.actual_value,
      expectedValue: row.expected_value,
      checkPassed:
        sbspBooleanValue_(row.check_passed),
      checkStatus: row.check_status
    };
  });

  const failedChecks = checks.filter(
    function(check) {
      return !check.checkPassed;
    }
  );

  const passedChecks =
    checks.length - failedChecks.length;

  const verdict = failedChecks.length === 0
    ? 'INTEGRITY_APPROVED'
    : 'INTEGRITY_BLOCKED';

  const approved =
    checks.length ===
      config.audit.expectedChecks &&
    passedChecks ===
      config.audit.expectedPassedChecks &&
    failedChecks.length ===
      config.audit.expectedFailedChecks &&
    verdict ===
      config.audit.expectedVerdict;

  return {
    approved: approved,
    verdict: verdict,
    totalChecks: checks.length,
    passedChecks: passedChecks,
    failedChecks: failedChecks.length,
    failedCheckDetails: failedChecks,
    jobIdHash: query.jobIdHash,
    totalBytesProcessed:
      query.totalBytesProcessed,
    totalBytesBilled:
      query.totalBytesBilled,
    cacheHit: query.cacheHit
  };
}

/**
 * Converte valores do BigQuery para booleano.
 *
 * @param {*} value
 * @return {boolean}
 */
function sbspBooleanValue_(value) {
  if (value === true) {
    return true;
  }

  if (value === false) {
    return false;
  }

  return String(value).toLowerCase() === 'true';
}
