/**
 * sheets-bigquery-sandbox-pipeline
 * Arquivo: orchestrator.example.gs
 *
 * Máquina de estados simplificada e manual.
 *
 * Este exemplo:
 * - não cria gatilhos;
 * - não executa automaticamente;
 * - exige autorização manual;
 * - utiliza somente dados sintéticos;
 * - não modifica objetos do BigQuery;
 * - consulta objetos previamente criados pelos exemplos SQL.
 */

/**
 * Executa o preflight do orquestrador.
 *
 * @return {Object}
 */
function SBSP_orchestratorPreflight() {
  const startedAtMs = Date.now();

  return sbspWithScriptLock_(function() {
    const blockers = [];
    const information = [];
    const checks = {};

    try {
      const config = sbspGetConfig_();
      const state = sbspGetOrchestratorState_();
      const pending = sbspGetPendingDetection_();

      checks.configValid = true;
      checks.syntheticDataOnly =
        config.syntheticDataOnly === true;
      checks.productionSourceBlocked =
        config.productionSourceAllowed === false;
      checks.productionWritesBlocked =
        config.productionWritesAllowed === false;
      checks.automaticExecutionDisabled =
        config.execution.automaticExecutionEnabled === false;
      checks.triggerCreationDisabled =
        config.execution.triggerCreationAllowed === false;
      checks.manualExecutionOnly =
        config.execution.manualExecutionOnly === true;
      checks.manualAuthorizationClosed =
        !sbspManualAuthorizationIsOpen_();
      checks.stateAvailable = Boolean(state);

      checks.pendingDetectionAvailable =
        Boolean(pending);

      checks.pendingDetectionConfirmed =
        sbspPendingDetectionIsConfirmed_(pending);

      if (!checks.pendingDetectionAvailable) {
        blockers.push(
          'Não existe mudança sintética pendente.'
        );
      }

      if (
        checks.pendingDetectionAvailable &&
        !checks.pendingDetectionConfirmed
      ) {
        blockers.push(
          'A mudança pendente ainda não atingiu o limiar.'
        );
      }

      information.push(
        'O preflight não alterou o estado.'
      );

      information.push(
        'O preflight não executou publicação.'
      );

      information.push(
        'O preflight não criou gatilhos.'
      );

      information.push(
        'O preflight não modificou objetos do BigQuery.'
      );

      const result = sbspCreateResult_({
        startedAtMs: startedAtMs,
        success: blockers.length === 0,
        status: blockers.length === 0
          ? 'OK'
          : 'BLOCKED',
        stage: 'ORCHESTRATOR_PREFLIGHT',
        mode: 'PREFLIGHT',
        blockers: blockers,
        information: information,
        measures: {
          state: state,
          pending: pending
            ? {
                intervalsConfirmed:
                  pending.intervalsConfirmed,
                requiredIntervals:
                  config.detection.confirmationIntervals,
                pendingMinutes:
                  sbspPendingMinutes_(pending),
                requiredMinutes:
                  config.detection.confirmationMinutes
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
        stage: 'ORCHESTRATOR_PREFLIGHT',
        mode: 'PREFLIGHT',
        blockers: [String(error.message || error)]
      });

      sbspLog_(result);
      return result;
    }
  });
}

/**
 * Executa uma única transição manual da máquina de estados.
 *
 * Antes de cada chamada, a propriedade abaixo precisa estar como true:
 *
 * SBSP_MANUAL_AUTHORIZATION
 *
 * A autorização é fechada automaticamente no final da execução.
 *
 * @return {Object}
 */
function SBSP_runNextManualStep() {
  const startedAtMs = Date.now();

  return sbspWithScriptLock_(function() {
    const information = [];
    const checks = {};

    try {
      const config = sbspGetConfig_();

      if (!sbspManualAuthorizationIsOpen_()) {
        throw new Error(
          'A autorização manual está fechada.'
        );
      }

      const stateBefore = sbspGetOrchestratorState_();
      const pending = sbspGetPendingDetection_();

      checks.manualAuthorizationOpen = true;
      checks.syntheticDataOnly =
        config.syntheticDataOnly === true;
      checks.productionWritesBlocked =
        config.productionWritesAllowed === false;
      checks.triggerCreationDisabled =
        config.execution.triggerCreationAllowed === false;

      let stateAfter = stateBefore;
      let action = 'NO_ACTION';
      let measures = {};

      switch (stateBefore.currentState) {
        case config.states.waiting:
          if (!sbspPendingDetectionIsConfirmed_(pending)) {
            throw new Error(
              'Não existe mudança confirmada para iniciar o ciclo.'
            );
          }

          stateAfter = sbspTransitionState_(
            stateBefore,
            config.states.changeConfirmed,
            'CONFIRM_PENDING_CHANGE'
          );

          action = 'CHANGE_CONFIRMED';
          break;

        case config.states.changeConfirmed:
          stateAfter = sbspTransitionState_(
            stateBefore,
            config.states.processing,
            'START_PROCESSING_VALIDATION'
          );

          action = 'PROCESSING_STARTED';
          break;

        case config.states.processing:
          measures.objects =
            sbspValidatePipelineObjects_();

          if (!measures.objects.valid) {
            throw new Error(
              'Os objetos obrigatórios do pipeline não estão disponíveis.'
            );
          }

          stateAfter = sbspTransitionState_(
            stateBefore,
            config.states.publicationPending,
            'PIPELINE_OBJECTS_VALIDATED'
          );

          action = 'PIPELINE_VALIDATED';
          break;

        case config.states.publicationPending:
          measures.publication =
            sbspBuildPublicationPreview_();

          if (config.publication.enabled === true) {
            measures.publicationResult =
              sbspPublishSyntheticOutputs_();

            information.push(
              'A publicação sintética foi executada.'
            );
          } else {
            information.push(
              'A publicação permanece desabilitada. Somente o preview foi gerado.'
            );
          }

          stateAfter = sbspTransitionState_(
            stateBefore,
            config.states.auditPending,
            config.publication.enabled === true
              ? 'SYNTHETIC_PUBLICATION_COMPLETED'
              : 'SYNTHETIC_PUBLICATION_SKIPPED'
          );

          action = config.publication.enabled === true
            ? 'PUBLICATION_COMPLETED'
            : 'PUBLICATION_SKIPPED';
          break;

        case config.states.auditPending:
          measures.audit = sbspRunAudit_();

          if (!measures.audit.approved) {
            throw new Error(
              'A auditoria sintética não foi aprovada.'
            );
          }

          stateAfter = sbspTransitionState_(
            stateBefore,
            config.states.completed,
            'AUDIT_APPROVED'
          );

          action = 'CYCLE_COMPLETED';
          break;

        case config.states.completed:
          sbspPromotePendingDetectionToBaseline_();

          stateAfter = sbspCreateInitialState_();

          stateAfter.previousState =
            config.states.completed;

          stateAfter.lastAction =
            'BASELINE_RENEWED';

          stateAfter.updatedAt =
            sbspNowIso_();

          sbspWriteJsonProperty_(
            config.properties.orchestratorState,
            stateAfter
          );

          action = 'RETURNED_TO_WAITING';
          break;

        case config.states.preservedFailure:
          throw new Error(
            'O estado PRESERVED_FAILURE exige diagnóstico antes de qualquer retomada.'
          );

        default:
          throw new Error(
            'Estado do orquestrador não reconhecido.'
          );
      }

      const result = sbspCreateResult_({
        startedAtMs: startedAtMs,
        success: true,
        status: 'OK',
        stage: 'MANUAL_ORCHESTRATOR',
        mode: 'MANUAL',
        information: information,
        measures: Object.assign(
          {
            action: action,
            stateBefore: stateBefore,
            stateAfter: stateAfter
          },
          measures
        ),
        checks: checks
      });

      sbspWriteJsonProperty_(
        config.properties.orchestratorLastResult,
        result
      );

      sbspLog_(result);
      return result;

    } catch (error) {
      const config = sbspGetConfig_();
      const stateBefore = sbspGetOrchestratorState_();

      const failedState = sbspTransitionState_(
        stateBefore,
        config.states.preservedFailure,
        'ERROR_PRESERVED'
      );

      failedState.lastError =
        String(error.message || error);

      sbspWriteJsonProperty_(
        config.properties.orchestratorState,
        failedState
      );

      const result = sbspCreateResult_({
        startedAtMs: startedAtMs,
        success: false,
        status: 'BLOCKED',
        stage: 'MANUAL_ORCHESTRATOR',
        mode: 'MANUAL',
        blockers: [String(error.message || error)],
        measures: {
          stateBefore: stateBefore,
          stateAfter: failedState
        },
        checks: {
          productionWriteExecuted: false,
          triggerCreated: false
        }
      });

      sbspWriteJsonProperty_(
        config.properties.orchestratorLastResult,
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
 * Retorna o estado atual.
 *
 * @return {Object}
 */
function SBSP_getOperationalState() {
  const state = sbspGetOrchestratorState_();

  const result = {
    version: SBSP_VERSION,
    state: state,
    occurredAt: sbspNowIso_()
  };

  sbspLog_(result);
  return result;
}

/**
 * Retorna o estado persistido ou cria o estado inicial.
 *
 * @return {Object}
 */
function sbspGetOrchestratorState_() {
  const config = sbspGetConfig_();

  const persisted = sbspReadJsonProperty_(
    config.properties.orchestratorState
  );

  if (persisted) {
    return persisted;
  }

  const initial = sbspCreateInitialState_();

  sbspWriteJsonProperty_(
    config.properties.orchestratorState,
    initial
  );

  return initial;
}

/**
 * Cria o estado inicial.
 *
 * @return {Object}
 */
function sbspCreateInitialState_() {
  const config = sbspGetConfig_();

  return {
    cycleId: null,
    currentState: config.states.waiting,
    previousState: null,
    lastAction: 'INITIALIZED',
    lastError: null,
    startedAt: null,
    updatedAt: sbspNowIso_()
  };
}

/**
 * Executa uma transição e persiste o estado.
 *
 * @param {Object} previous
 * @param {string} nextState
 * @param {string} action
 * @return {Object}
 */
function sbspTransitionState_(
  previous,
  nextState,
  action
) {
  const config = sbspGetConfig_();

  const next = {
    cycleId: previous.cycleId ||
      sbspCreateId_('cycle'),
    currentState: nextState,
    previousState: previous.currentState,
    lastAction: action,
    lastError: null,
    startedAt: previous.startedAt ||
      sbspNowIso_(),
    updatedAt: sbspNowIso_()
  };

  sbspWriteJsonProperty_(
    config.properties.orchestratorState,
    next
  );

  return next;
}

/**
 * Calcula os minutos da mudança pendente.
 *
 * @param {Object|null} pending
 * @return {number}
 */
function sbspPendingMinutes_(pending) {
  if (
    !pending ||
    !pending.firstDetectedAtMs ||
    !pending.lastConfirmedAtMs
  ) {
    return 0;
  }

  return Number(
    (
      (
        pending.lastConfirmedAtMs -
        pending.firstDetectedAtMs
      ) / 60000
    ).toFixed(3)
  );
}

/**
 * Confirma se a pendência atingiu o limiar.
 *
 * @param {Object|null} pending
 * @return {boolean}
 */
function sbspPendingDetectionIsConfirmed_(pending) {
  if (!pending) {
    return false;
  }

  const config = sbspGetConfig_();

  return (
    Number(pending.intervalsConfirmed || 0) >=
      config.detection.confirmationIntervals &&
    sbspPendingMinutes_(pending) >=
      config.detection.confirmationMinutes
  );
}

/**
 * Verifica os oito objetos esperados.
 *
 * @return {Object}
 */
function sbspValidatePipelineObjects_() {
  const config = sbspGetConfig_();

  const requiredObjects = [
    config.objects.rawInput,
    config.objects.rawTeams,
    config.objects.cleanRecords,
    config.objects.rulesRecords,
    config.objects.indicatorsView,
    config.objects.divergencesView,
    config.objects.exceptionsView,
    config.objects.auditView
  ];

  const quotedObjects = requiredObjects
    .map(function(objectName) {
      return "'" +
        objectName.replace(/'/g, "''") +
        "'";
    })
    .join(', ');

  const sql = [
    'SELECT',
    '  COUNT(*) AS objects_found,',
    '  COUNTIF(expiration_time IS NOT NULL) AS objects_with_expiration',
    'FROM',
    '  `' + config.projectId + '.' +
      config.datasetId +
      '.INFORMATION_SCHEMA.TABLES`',
    'WHERE',
    '  table_name IN (' + quotedObjects + ')'
  ].join('\n');

  const query = sbspRunQuery_(sql);
  const row = query.rows[0] || {};

  const objectsFound = Number(
    row.objects_found || 0
  );

  const objectsWithExpiration = Number(
    row.objects_with_expiration || 0
  );

  return {
    expectedObjects: requiredObjects.length,
    objectsFound: objectsFound,
    objectsWithExpiration:
      objectsWithExpiration,
    valid:
      objectsFound === requiredObjects.length &&
      objectsWithExpiration ===
        requiredObjects.length,
    jobIdHash: query.jobIdHash,
    totalBytesProcessed:
      query.totalBytesProcessed,
    totalBytesBilled:
      query.totalBytesBilled
  };
}
