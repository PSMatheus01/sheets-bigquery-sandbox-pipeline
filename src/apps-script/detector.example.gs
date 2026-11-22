/**
 * sheets-bigquery-sandbox-pipeline
 * Arquivo: detector.example.gs
 *
 * Detector somente leitura para uma planilha sintética.
 *
 * O detector:
 * - não lê células;
 * - não altera a planilha;
 * - não cria gatilhos;
 * - não inicia o pipeline automaticamente;
 * - não aceita planilha sem o marcador [SYNTHETIC];
 * - armazena somente hashes e metadados agregados.
 */

/**
 * Executa o preflight do detector.
 *
 * @return {Object}
 */
function SBSP_detectorPreflight() {
  const startedAtMs = Date.now();

  return sbspWithScriptLock_(function() {
    const blockers = [];
    const information = [];
    const checks = {};

    try {
      const config = sbspGetConfig_();
      checks.configValid = true;

      const sourceId = sbspProperties_().getProperty(
        config.detection.spreadsheetIdProperty
      );

      checks.sourcePropertyPresent = Boolean(sourceId);

      if (!sourceId) {
        blockers.push(
          'A propriedade da planilha sintética não foi configurada.'
        );
      }

      let sourceMetadata = null;

      if (sourceId) {
        sourceMetadata = sbspReadSyntheticFileMetadata_(
          sourceId
        );

        checks.mimeTypeValid =
          sourceMetadata.mimeType ===
          config.detection.requiredMimeType;

        checks.syntheticMarkerPresent =
          sourceMetadata.name.indexOf(
            config.detection.requiredNameMarker
          ) !== -1;

        if (!checks.mimeTypeValid) {
          blockers.push(
            'O arquivo configurado não é uma planilha Google.'
          );
        }

        if (!checks.syntheticMarkerPresent) {
          blockers.push(
            'O nome da planilha precisa conter [SYNTHETIC].'
          );
        }
      }

      checks.productionSourceAllowed =
        config.productionSourceAllowed;

      checks.productionWritesAllowed =
        config.productionWritesAllowed;

      checks.readSpreadsheetCells =
        config.detection.readSpreadsheetCells;

      checks.triggerCreationAllowed =
        config.execution.triggerCreationAllowed;

      checks.publicationEnabled =
        config.publication.enabled;

      checks.readOnlyDetector =
        config.detection.readSpreadsheetCells === false &&
        config.productionWritesAllowed === false;

      checks.noAutomaticTrigger =
        config.execution.triggerCreationAllowed === false;

      checks.noPublication =
        config.publication.enabled === false;

      information.push(
        'O preflight não leu células da planilha.'
      );

      information.push(
        'O preflight não criou gatilhos.'
      );

      information.push(
        'O preflight não executou consultas no BigQuery.'
      );

      information.push(
        'O preflight não alterou a fonte.'
      );

      const result = sbspCreateResult_({
        startedAtMs: startedAtMs,
        success: blockers.length === 0,
        status: blockers.length === 0
          ? 'OK'
          : 'BLOCKED',
        stage: 'DETECTOR_PREFLIGHT',
        mode: 'PREFLIGHT',
        blockers: blockers,
        information: information,
        measures: sourceMetadata
          ? {
              source: {
                idHash: sbspSha256_(sourceId)
                  .substring(0, 16),
                nameHash: sbspSha256_(
                  sourceMetadata.name
                ).substring(0, 16),
                modifiedTime: sourceMetadata.modifiedTime,
                size: sourceMetadata.size,
                mimeType: sourceMetadata.mimeType
              }
            }
          : {},
        checks: checks
      });

      sbspLog_(result);
      return result;

    } catch (error) {
      const result = sbspCreateResult_({
        startedAtMs: startedAtMs,
        success: false,
        status: 'BLOCKED',
        stage: 'DETECTOR_PREFLIGHT',
        mode: 'PREFLIGHT',
        blockers: [String(error.message || error)]
      });

      sbspLog_(result);
      return result;
    }
  });
}

/**
 * Detecta mudanças na fonte sintética.
 *
 * A função confirma a mesma mudança durante:
 * - 8 intervalos;
 * - no mínimo 120 minutos.
 *
 * @return {Object}
 */
function SBSP_detectSyntheticSourceChange() {
  const startedAtMs = Date.now();

  return sbspWithScriptLock_(function() {
    const config = sbspGetConfig_();
    const blockers = [];
    const information = [];
    const checks = {};

    try {
      const sourceId = sbspProperties_().getProperty(
        config.detection.spreadsheetIdProperty
      );

      if (!sourceId) {
        throw new Error(
          'A propriedade da planilha sintética não foi configurada.'
        );
      }

      const metadata = sbspReadSyntheticFileMetadata_(
        sourceId
      );

      if (
        metadata.mimeType !==
        config.detection.requiredMimeType
      ) {
        throw new Error(
          'O arquivo configurado não é uma planilha Google.'
        );
      }

      if (
        metadata.name.indexOf(
          config.detection.requiredNameMarker
        ) === -1
      ) {
        throw new Error(
          'A fonte não possui o marcador [SYNTHETIC].'
        );
      }

      const snapshot = sbspCreateSourceSnapshot_(
        sourceId,
        metadata
      );

      const baseline = sbspReadJsonProperty_(
        config.properties.detectorBaseline
      );

      let pending = sbspReadJsonProperty_(
        config.properties.detectorPending
      );

      let action = 'NO_CHANGE';
      let changeDetected = false;
      let thresholdReached = false;

      if (!baseline) {
        sbspWriteJsonProperty_(
          config.properties.detectorBaseline,
          snapshot
        );

        sbspDeleteProperty_(
          config.properties.detectorPending
        );

        pending = null;
        action = 'BASELINE_INITIALIZED';

        information.push(
          'A primeira observação foi registrada como baseline.'
        );

      } else if (
        baseline.fingerprint === snapshot.fingerprint
      ) {
        sbspDeleteProperty_(
          config.properties.detectorPending
        );

        pending = null;
        action = 'NO_CHANGE';

        information.push(
          'Nenhuma mudança foi detectada.'
        );

      } else {
        changeDetected = true;

        const nowMs = Date.now();

        if (
          !pending ||
          pending.fingerprint !== snapshot.fingerprint
        ) {
          pending = {
            fingerprint: snapshot.fingerprint,
            firstDetectedAtMs: nowMs,
            lastConfirmedAtMs: nowMs,
            intervalsConfirmed: 0,
            snapshot: snapshot
          };
        } else {
          pending.intervalsConfirmed += 1;
          pending.lastConfirmedAtMs = nowMs;
          pending.snapshot = snapshot;
        }

        const pendingMinutes =
          (
            pending.lastConfirmedAtMs -
            pending.firstDetectedAtMs
          ) / 60000;

        thresholdReached =
          pending.intervalsConfirmed >=
            config.detection.confirmationIntervals &&
          pendingMinutes >=
            config.detection.confirmationMinutes;

        action = thresholdReached
          ? 'CHANGE_CONFIRMED'
          : 'CHANGE_PENDING';

        sbspWriteJsonProperty_(
          config.properties.detectorPending,
          pending
        );

        information.push(
          thresholdReached
            ? 'A mudança atingiu o limiar de confirmação.'
            : 'A mudança permanece pendente.'
        );
      }

      const pendingMinutes = pending
        ? (
            pending.lastConfirmedAtMs -
            pending.firstDetectedAtMs
          ) / 60000
        : 0;

      checks.configValid = true;
      checks.syntheticSource = true;
      checks.readSpreadsheetCells = false;
      checks.productionWriteExecuted = false;
      checks.bigQueryExecuted = false;
      checks.triggerCreated = false;
      checks.publicationExecuted = false;

      const result = sbspCreateResult_({
        startedAtMs: startedAtMs,
        success: blockers.length === 0,
        status: blockers.length === 0
          ? 'OK'
          : 'BLOCKED',
        stage: 'SYNTHETIC_SOURCE_DETECTOR',
        mode: 'MANUAL',
        blockers: blockers,
        information: information,
        measures: {
          action: action,
          changeDetected: changeDetected,
          thresholdReached: thresholdReached,
          source: {
            idHash: snapshot.idHash,
            nameHash: snapshot.nameHash,
            modifiedTime: snapshot.modifiedTime,
            size: snapshot.size,
            fingerprint: snapshot.fingerprint
          },
          pending: pending
            ? {
                intervalsConfirmed:
                  pending.intervalsConfirmed,
                requiredIntervals:
                  config.detection.confirmationIntervals,
                pendingMinutes: Number(
                  pendingMinutes.toFixed(3)
                ),
                requiredMinutes:
                  config.detection.confirmationMinutes
              }
            : null
        },
        checks: checks
      });

      sbspWriteJsonProperty_(
        config.properties.detectorLastResult,
        result
      );

      sbspLog_(result);
      return result;

    } catch (error) {
      const result = sbspCreateResult_({
        startedAtMs: startedAtMs,
        success: false,
        status: 'BLOCKED',
        stage: 'SYNTHETIC_SOURCE_DETECTOR',
        mode: 'MANUAL',
        blockers: [String(error.message || error)],
        checks: {
          productionWriteExecuted: false,
          bigQueryExecuted: false,
          triggerCreated: false,
          publicationExecuted: false
        }
      });

      sbspWriteJsonProperty_(
        config.properties.detectorLastResult,
        result
      );

      sbspLog_(result);
      return result;
    }
  });
}

/**
 * Lê somente metadados do arquivo.
 *
 * Não abre a planilha e não lê células.
 *
 * @param {string} sourceId
 * @return {Object}
 */
function sbspReadSyntheticFileMetadata_(sourceId) {
  const file = DriveApp.getFileById(sourceId);

  return {
    name: file.getName(),
    mimeType: file.getMimeType(),
    modifiedTime: file.getLastUpdated().toISOString(),
    size: Number(file.getSize() || 0)
  };
}

/**
 * Cria um snapshot sanitizado da fonte.
 *
 * @param {string} sourceId
 * @param {Object} metadata
 * @return {Object}
 */
function sbspCreateSourceSnapshot_(sourceId, metadata) {
  const idHash = sbspSha256_(sourceId)
    .substring(0, 16);

  const nameHash = sbspSha256_(metadata.name)
    .substring(0, 16);

  const fingerprint = sbspSha256_(
    [
      idHash,
      nameHash,
      metadata.modifiedTime,
      metadata.size,
      metadata.mimeType
    ].join('|')
  );

  return {
    idHash: idHash,
    nameHash: nameHash,
    modifiedTime: metadata.modifiedTime,
    size: metadata.size,
    mimeType: metadata.mimeType,
    fingerprint: fingerprint,
    capturedAt: sbspNowIso_()
  };
}

/**
 * Retorna o último resultado do detector.
 *
 * @return {Object|null}
 */
function sbspGetLastDetection_() {
  const config = sbspGetConfig_();

  return sbspReadJsonProperty_(
    config.properties.detectorLastResult
  );
}

/**
 * Retorna a mudança pendente.
 *
 * @return {Object|null}
 */
function sbspGetPendingDetection_() {
  const config = sbspGetConfig_();

  return sbspReadJsonProperty_(
    config.properties.detectorPending
  );
}

/**
 * Promove o snapshot pendente para baseline.
 *
 * Esta função é interna e será utilizada pelo orquestrador somente depois da
 * conclusão e aprovação do ciclo sintético.
 */
function sbspPromotePendingDetectionToBaseline_() {
  const config = sbspGetConfig_();

  const pending = sbspReadJsonProperty_(
    config.properties.detectorPending
  );

  if (!pending || !pending.snapshot) {
    throw new Error(
      'Não existe snapshot pendente para promover.'
    );
  }

  sbspWriteJsonProperty_(
    config.properties.detectorBaseline,
    pending.snapshot
  );

  sbspDeleteProperty_(
    config.properties.detectorPending
  );
}
