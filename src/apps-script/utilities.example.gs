/**
 * sheets-bigquery-sandbox-pipeline
 * Arquivo: utilities.example.gs
 *
 * Utilitários sanitizados para:
 * - locks;
 * - propriedades;
 * - hashes;
 * - logs estruturados;
 * - resultados padronizados;
 * - consultas somente leitura no BigQuery.
 */

/**
 * Executa uma função sob Script Lock.
 *
 * @param {Function} callback
 * @return {*}
 */
function sbspWithScriptLock_(callback) {
  const lock = LockService.getScriptLock();

  if (!lock.tryLock(5000)) {
    throw new Error('Existe outra execução do exemplo em andamento.');
  }

  try {
    return callback();
  } finally {
    lock.releaseLock();
  }
}

/**
 * Retorna as Script Properties.
 *
 * @return {GoogleAppsScript.Properties.Properties}
 */
function sbspProperties_() {
  return PropertiesService.getScriptProperties();
}

/**
 * Lê uma propriedade JSON.
 *
 * @param {string} key
 * @return {*|null}
 */
function sbspReadJsonProperty_(key) {
  const rawValue = sbspProperties_().getProperty(key);

  if (!rawValue) {
    return null;
  }

  try {
    return JSON.parse(rawValue);
  } catch (error) {
    throw new Error(
      'A propriedade "' + key + '" não contém JSON válido.'
    );
  }
}

/**
 * Grava uma propriedade JSON.
 *
 * @param {string} key
 * @param {*} value
 */
function sbspWriteJsonProperty_(key, value) {
  sbspProperties_().setProperty(
    key,
    JSON.stringify(value)
  );
}

/**
 * Exclui uma propriedade.
 *
 * @param {string} key
 */
function sbspDeleteProperty_(key) {
  sbspProperties_().deleteProperty(key);
}

/**
 * Retorna o horário atual em ISO 8601.
 *
 * @return {string}
 */
function sbspNowIso_() {
  return new Date().toISOString();
}

/**
 * Cria um identificador aleatório sem usar dados do ambiente.
 *
 * @param {string} prefix
 * @return {string}
 */
function sbspCreateId_(prefix) {
  const normalizedPrefix = String(prefix || 'id')
    .replace(/[^a-zA-Z0-9_-]/g, '_');

  return normalizedPrefix + '_' +
    Utilities.getUuid().replace(/-/g, '');
}

/**
 * Calcula SHA-256 e retorna hexadecimal.
 *
 * @param {*} value
 * @return {string}
 */
function sbspSha256_(value) {
  const bytes = Utilities.computeDigest(
    Utilities.DigestAlgorithm.SHA_256,
    String(value),
    Utilities.Charset.UTF_8
  );

  return bytes
    .map(function(byteValue) {
      const normalized = byteValue < 0
        ? byteValue + 256
        : byteValue;

      return ('0' + normalized.toString(16)).slice(-2);
    })
    .join('');
}

/**
 * Remove chaves sensíveis de objetos destinados ao log.
 *
 * @param {*} value
 * @return {*}
 */
function sbspSanitizeForLog_(value) {
  const sensitiveKeys = {
    spreadsheetid: true,
    userid: true,
    userkey: true,
    projectkey: true,
    deploymentid: true,
    triggeruid: true,
    accesstoken: true,
    refreshtoken: true,
    password: true,
    credential: true,
    secret: true
  };

  if (Array.isArray(value)) {
    return value.map(sbspSanitizeForLog_);
  }

  if (
    value !== null &&
    typeof value === 'object' &&
    !(value instanceof Date)
  ) {
    return Object.keys(value).reduce(function(result, key) {
      const normalizedKey = key
        .replace(/[^a-zA-Z0-9]/g, '')
        .toLowerCase();

      if (sensitiveKeys[normalizedKey]) {
        result[key] = '[REMOVED]';
      } else {
        result[key] = sbspSanitizeForLog_(value[key]);
      }

      return result;
    }, {});
  }

  return value;
}

/**
 * Escreve um log estruturado e sanitizado.
 *
 * @param {Object} payload
 */
function sbspLog_(payload) {
  const sanitized = sbspSanitizeForLog_(payload);
  console.log(JSON.stringify(sanitized));
}

/**
 * Cria um resultado padronizado.
 *
 * @param {Object} options
 * @return {Object}
 */
function sbspCreateResult_(options) {
  const startedAtMs = options.startedAtMs || Date.now();
  const success = options.success === true;
  const status = options.status ||
    (success ? 'OK' : 'BLOCKED');

  return {
    success: success,
    status: status,
    stage: options.stage || 'UNDEFINED',
    mode: options.mode || 'MANUAL',
    version: SBSP_VERSION,
    environment: SBSP_CONFIG.environment,
    projectIdHash: sbspSha256_(SBSP_CONFIG.projectId)
      .substring(0, 16),
    datasetId: SBSP_CONFIG.datasetId,
    blockers: options.blockers || [],
    reservations: options.reservations || [],
    information: options.information || [],
    measures: options.measures || {},
    checks: options.checks || {},
    durationMs: Date.now() - startedAtMs,
    occurredAt: sbspNowIso_()
  };
}

/**
 * Converte uma linha simples do BigQuery em objeto.
 *
 * @param {Object} schema
 * @param {Object} row
 * @return {Object}
 */
function sbspBigQueryRowToObject_(schema, row) {
  const fields = schema && schema.fields
    ? schema.fields
    : [];

  const values = row && row.f
    ? row.f
    : [];

  return fields.reduce(function(result, field, index) {
    const cell = values[index];
    result[field.name] = cell ? cell.v : null;
    return result;
  }, {});
}

/**
 * Executa uma consulta GoogleSQL.
 *
 * Requer o serviço avançado BigQuery habilitado no projeto Apps Script.
 *
 * @param {string} sql
 * @return {Object}
 */
function sbspRunQuery_(sql) {
  const config = sbspGetConfig_();

  if (!sql || typeof sql !== 'string') {
    throw new Error('A consulta SQL é obrigatória.');
  }

  const request = {
    query: sql,
    useLegacySql: false,
    location: config.location,
    maximumBytesBilled: String(
      config.query.maximumBytesBilled
    ),
    timeoutMs: config.query.timeoutMilliseconds
  };

  let response = BigQuery.Jobs.query(
    request,
    config.projectId
  );

  const jobReference = response.jobReference;

  if (!jobReference || !jobReference.jobId) {
    throw new Error(
      'O BigQuery não retornou uma referência de job.'
    );
  }

  let pollAttempts = 0;

  while (!response.jobComplete) {
    pollAttempts += 1;

    if (
      pollAttempts >
      config.query.maximumPollAttempts
    ) {
      throw new Error(
        'A consulta ultrapassou o limite de espera.'
      );
    }

    Utilities.sleep(
      config.query.pollIntervalMilliseconds
    );

    response = BigQuery.Jobs.getQueryResults(
      config.projectId,
      jobReference.jobId,
      {
        location: config.location,
        timeoutMs: config.query.timeoutMilliseconds
      }
    );
  }

  let rows = response.rows || [];
  let pageToken = response.pageToken || null;

  while (pageToken) {
    const nextPage = BigQuery.Jobs.getQueryResults(
      config.projectId,
      jobReference.jobId,
      {
        location: config.location,
        pageToken: pageToken,
        timeoutMs: config.query.timeoutMilliseconds
      }
    );

    rows = rows.concat(nextPage.rows || []);
    pageToken = nextPage.pageToken || null;
  }

  const schema = response.schema || { fields: [] };

  return {
    jobIdHash: sbspSha256_(jobReference.jobId)
      .substring(0, 16),
    jobComplete: response.jobComplete === true,
    totalRows: Number(response.totalRows || rows.length),
    totalBytesProcessed: Number(
      response.totalBytesProcessed || 0
    ),
    totalBytesBilled: Number(
      response.totalBytesBilled || 0
    ),
    cacheHit: response.cacheHit === true,
    rows: rows.map(function(row) {
      return sbspBigQueryRowToObject_(
        schema,
        row
      );
    })
  };
}

/**
 * Lê o valor da autorização manual.
 *
 * @return {boolean}
 */
function sbspManualAuthorizationIsOpen_() {
  const config = sbspGetConfig_();

  return sbspProperties_().getProperty(
    config.properties.manualAuthorization
  ) === 'true';
}

/**
 * Fecha a autorização manual.
 */
function sbspCloseManualAuthorization_() {
  const config = sbspGetConfig_();

  sbspProperties_().setProperty(
    config.properties.manualAuthorization,
    'false'
  );
}
