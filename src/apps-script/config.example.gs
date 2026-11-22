/**
 * sheets-bigquery-sandbox-pipeline
 * Arquivo: config.example.gs
 *
 * Configuração pública e sanitizada do exemplo.
 *
 * Este arquivo:
 * - não contém credenciais;
 * - não contém IDs de planilhas;
 * - não habilita publicação;
 * - não cria gatilhos;
 * - não permite origem de produção;
 * - utiliza somente o projeto sintético do repositório.
 */

const SBSP_VERSION = '1.0.0';

const SBSP_CONFIG = Object.freeze({
  projectId: 'sheets-bq-sandbox-pipeline',
  datasetId: 'sandbox_pipeline_example',
  location: 'US',

  environment: 'SANDBOX',
  billingEnabled: false,
  syntheticDataOnly: true,
  productionSourceAllowed: false,
  productionWritesAllowed: false,

  retentionDays: 59,
  expirationAlertDays: 7,

  query: Object.freeze({
    maximumBytesBilled: 104857600,
    timeoutMilliseconds: 25000,
    pollIntervalMilliseconds: 500,
    maximumPollAttempts: 40
  }),

  detection: Object.freeze({
    spreadsheetIdProperty: 'SBSP_SYNTHETIC_SPREADSHEET_ID',
    requiredNameMarker: '[SYNTHETIC]',
    requiredMimeType: 'application/vnd.google-apps.spreadsheet',
    confirmationIntervals: 8,
    confirmationMinutes: 120,
    expectedIntervalMinutes: 15,
    readSpreadsheetCells: false
  }),

  execution: Object.freeze({
    automaticExecutionEnabled: false,
    triggerCreationAllowed: false,
    manualExecutionOnly: true,
    manualAuthorizationRequired: true,
    manualAuthorizationDefault: false
  }),

  publication: Object.freeze({
    enabled: false,
    spreadsheetIdProperty: 'SBSP_SYNTHETIC_OUTPUT_SPREADSHEET_ID',
    indicatorsSheetName: 'INDICATORS_EXAMPLE',
    divergencesSheetName: 'DIVERGENCES_EXAMPLE',
    exceptionsSheetName: 'EXCEPTIONS_EXAMPLE',
    sanitizeFormulaLikeText: true,
    writeFormulas: false
  }),

  audit: Object.freeze({
    expectedChecks: 30,
    expectedPassedChecks: 30,
    expectedFailedChecks: 0,
    expectedVerdict: 'INTEGRITY_APPROVED'
  }),

  objects: Object.freeze({
    rawInput: 'raw_input_example',
    rawTeams: 'raw_team_example',
    cleanRecords: 'clean_records_example',
    rulesRecords: 'rules_records_example',
    indicatorsView: 'vw_indicators_example',
    divergencesView: 'vw_divergences_example',
    exceptionsView: 'vw_exceptions_example',
    auditView: 'vw_audit_example'
  }),

  properties: Object.freeze({
    detectorBaseline: 'SBSP_DETECTOR_BASELINE',
    detectorPending: 'SBSP_DETECTOR_PENDING',
    detectorLastResult: 'SBSP_DETECTOR_LAST_RESULT',
    orchestratorState: 'SBSP_ORCHESTRATOR_STATE',
    orchestratorLastResult: 'SBSP_ORCHESTRATOR_LAST_RESULT',
    publisherLastResult: 'SBSP_PUBLISHER_LAST_RESULT',
    auditorLastResult: 'SBSP_AUDITOR_LAST_RESULT',
    manualAuthorization: 'SBSP_MANUAL_AUTHORIZATION'
  }),

  states: Object.freeze({
    waiting: 'WAITING_FOR_CHANGE',
    changePending: 'CHANGE_PENDING',
    changeConfirmed: 'CHANGE_CONFIRMED',
    processing: 'PROCESSING',
    publicationPending: 'PUBLICATION_PENDING',
    auditPending: 'AUDIT_PENDING',
    completed: 'COMPLETED',
    preservedFailure: 'PRESERVED_FAILURE'
  }),

  security: Object.freeze({
    allowRealData: false,
    allowProductionIdentifiers: false,
    allowEmbeddedCredentials: false,
    allowRawLogExport: false,
    allowPersonalData: false,
    requireSyntheticSpreadsheetMarker: true,
    requireReadOnlyDetection: true,
    sanitizeLogs: true
  })
});

/**
 * Retorna a configuração após validar os controles essenciais.
 *
 * @return {Object}
 */
function sbspGetConfig_() {
  sbspValidateConfig_();
  return SBSP_CONFIG;
}

/**
 * Impede alterações acidentais que tornariam o exemplo inseguro.
 */
function sbspValidateConfig_() {
  const errors = [];

  if (SBSP_CONFIG.projectId !== 'sheets-bq-sandbox-pipeline') {
    errors.push('O projectId deve permanecer no projeto sintético.');
  }

  if (SBSP_CONFIG.datasetId !== 'sandbox_pipeline_example') {
    errors.push('O datasetId deve permanecer no dataset sintético.');
  }

  if (SBSP_CONFIG.environment !== 'SANDBOX') {
    errors.push('O exemplo deve permanecer em modo SANDBOX.');
  }

  if (SBSP_CONFIG.billingEnabled !== false) {
    errors.push('O exemplo não deve declarar faturamento habilitado.');
  }

  if (SBSP_CONFIG.syntheticDataOnly !== true) {
    errors.push('O exemplo aceita somente dados sintéticos.');
  }

  if (SBSP_CONFIG.productionSourceAllowed !== false) {
    errors.push('Uma origem de produção não é permitida.');
  }

  if (SBSP_CONFIG.productionWritesAllowed !== false) {
    errors.push('Escritas em produção não são permitidas.');
  }

  if (SBSP_CONFIG.retentionDays > 59) {
    errors.push('A retenção não pode ultrapassar 59 dias.');
  }

  if (SBSP_CONFIG.execution.triggerCreationAllowed !== false) {
    errors.push('A criação de gatilhos deve permanecer desabilitada.');
  }

  if (SBSP_CONFIG.publication.enabled !== false) {
    errors.push('A publicação deve permanecer desabilitada por padrão.');
  }

  if (SBSP_CONFIG.publication.writeFormulas !== false) {
    errors.push('O exemplo não deve publicar fórmulas.');
  }

  if (errors.length > 0) {
    throw new Error(errors.join(' '));
  }
}
