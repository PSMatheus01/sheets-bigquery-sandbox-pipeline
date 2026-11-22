-- ============================================================================
-- sheets-bigquery-sandbox-pipeline
-- Arquivo: src/sql/05_exceptions_example.sql
-- Finalidade: criar views detalhadas de divergências e exceções sintéticas.
-- Dialeto: GoogleSQL
-- Ambiente: BigQuery Sandbox
-- Projeto: sheets-bq-sandbox-pipeline
-- Dataset: sandbox_pipeline_example
-- ============================================================================
--
-- PRÉ-REQUISITOS
--
-- Antes de executar este script:
--
--   1. execute src/sql/01_raw_example.sql;
--   2. carregue os arquivos CSV sintéticos;
--   3. execute src/sql/02_clean_example.sql;
--   4. execute src/sql/03_rules_example.sql;
--   5. execute src/sql/04_indicators_example.sql.
--
-- OBJETOS CRIADOS
--
--   vw_divergences_example
--   vw_exceptions_example
--
-- DIVERGÊNCIAS
--
-- São registros tecnicamente utilizáveis, mas que possuem combinações de
-- negócio inconsistentes.
--
-- EXCEÇÕES
--
-- A view de exceções consolida:
--
--   1. problemas de qualidade;
--   2. campos obrigatórios ausentes;
--   3. tipos inválidos;
--   4. referências inválidas;
--   5. valores fora dos limites;
--   6. duplicidades excedentes;
--   7. registros fora da janela.
--
-- GRANULARIDADE
--
-- As views possuem uma linha por ocorrência.
--
-- Um mesmo registro pode gerar mais de uma linha quando possui mais de uma
-- causa. Isso permite contar e auditar cada problema separadamente.
--
-- SEGURANÇA
--
-- Este script:
--
--   1. lê somente a camada de regras sintética;
--   2. não altera os registros de origem;
--   3. não acessa produção;
--   4. não publica em planilhas;
--   5. não cria gatilhos;
--   6. não contém credenciais;
--   7. não executa DML;
--   8. configura expiração de 59 dias nas views.
-- ============================================================================

-- ============================================================================
-- VIEW DE DIVERGÊNCIAS
-- ============================================================================

CREATE OR REPLACE VIEW
  `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.vw_divergences_example`
OPTIONS (
  expiration_timestamp = TIMESTAMP_ADD(
    CURRENT_TIMESTAMP(),
    INTERVAL 59 DAY
  ),
  description = 'Divergências sintéticas de negócio, com uma linha por código de divergência.',
  labels = [
    ('environment', 'sandbox'),
    ('layer', 'exceptions'),
    ('category', 'synthetic_divergences'),
    ('retention', '59_days')
  ]
)
AS

WITH divergence_occurrences AS (
  SELECT
    CONCAT(
      records.source_row_id,
      ':',
      issue_code
    ) AS occurrence_id,

    records.source_row_id,
    records.record_id,
    records.event_date,

    records.team_code,
    records.team_name,
    records.group_code,

    records.agent_code,
    records.channel,
    records.campaign,

    records.status,
    records.converted,
    records.attempts,
    records.estimated_value,

    records.source_updated_at,
    records.row_fingerprint,

    records.primary_classification,

    'BUSINESS_RULE' AS issue_category,
    issue_code,

    CASE issue_code
      WHEN 'COMPLETED_WITHOUT_CONVERSION'
        THEN 'Registro concluído sem conversão confirmada.'

      WHEN 'CONVERTED_WITHOUT_COMPLETED_STATUS'
        THEN 'Registro convertido sem status de conclusão.'

      WHEN 'CANCELLED_WITH_CONVERSION'
        THEN 'Registro cancelado marcado como convertido.'

      ELSE 'Divergência de negócio não mapeada.'
    END AS issue_description,

    'WARNING' AS severity

  FROM
    `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.rules_records_example`
    AS records

  CROSS JOIN
    UNNEST(records.divergence_issue_codes) AS issue_code

  WHERE
    records.primary_classification = 'DIVERGENCE'
)

SELECT
  occurrence_id,
  source_row_id,
  record_id,
  event_date,

  team_code,
  team_name,
  group_code,

  agent_code,
  channel,
  campaign,

  status,
  converted,
  attempts,
  estimated_value,

  source_updated_at,
  row_fingerprint,

  primary_classification,
  issue_category,
  issue_code,
  issue_description,
  severity

FROM
  divergence_occurrences;

-- ============================================================================
-- VIEW CONSOLIDADA DE EXCEÇÕES
-- ============================================================================

CREATE OR REPLACE VIEW
  `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.vw_exceptions_example`
OPTIONS (
  expiration_timestamp = TIMESTAMP_ADD(
    CURRENT_TIMESTAMP(),
    INTERVAL 59 DAY
  ),
  description = 'Exceções sintéticas consolidadas, incluindo qualidade, duplicidade e registros fora da janela.',
  labels = [
    ('environment', 'sandbox'),
    ('layer', 'exceptions'),
    ('category', 'synthetic_exceptions'),
    ('retention', '59_days')
  ]
)
AS

WITH quality_occurrences AS (
  SELECT
    CONCAT(
      records.source_row_id,
      ':',
      issue_code
    ) AS occurrence_id,

    records.source_row_id,
    records.record_id,
    records.event_date_raw,
    records.event_date,

    records.team_code_raw,
    records.team_code,
    records.team_name,
    records.group_code,

    records.agent_code_raw,
    records.agent_code,

    records.channel_raw,
    records.channel,

    records.campaign_raw,
    records.campaign,

    records.status_raw,
    records.status,

    records.attempts_raw,
    records.attempts,

    records.converted_raw,
    records.converted,

    records.estimated_value_raw,
    records.estimated_value,

    records.source_updated_at_raw,
    records.source_updated_at,

    records.row_fingerprint,
    records.duplicate_count,
    records.duplicate_rank,
    records.primary_classification,

    CASE issue_code
      WHEN 'MISSING_SOURCE_ROW_ID' THEN 'REQUIRED_FIELD'
      WHEN 'MISSING_RECORD_ID' THEN 'REQUIRED_FIELD'
      WHEN 'MISSING_EVENT_DATE' THEN 'REQUIRED_FIELD'
      WHEN 'MISSING_TEAM_CODE' THEN 'REQUIRED_FIELD'
      WHEN 'MISSING_AGENT_CODE' THEN 'REQUIRED_FIELD'
      WHEN 'MISSING_CHANNEL' THEN 'REQUIRED_FIELD'
      WHEN 'MISSING_CAMPAIGN' THEN 'REQUIRED_FIELD'
      WHEN 'MISSING_STATUS' THEN 'REQUIRED_FIELD'
      WHEN 'MISSING_ATTEMPTS' THEN 'REQUIRED_FIELD'
      WHEN 'MISSING_CONVERTED' THEN 'REQUIRED_FIELD'
      WHEN 'MISSING_SOURCE_UPDATED_AT' THEN 'REQUIRED_FIELD'

      WHEN 'INVALID_EVENT_DATE' THEN 'TYPE_CONVERSION'
      WHEN 'INVALID_ATTEMPTS_TYPE' THEN 'TYPE_CONVERSION'
      WHEN 'INVALID_CONVERTED_TYPE' THEN 'TYPE_CONVERSION'
      WHEN 'INVALID_ESTIMATED_VALUE_TYPE' THEN 'TYPE_CONVERSION'
      WHEN 'INVALID_SOURCE_UPDATED_AT' THEN 'TYPE_CONVERSION'

      WHEN 'UNKNOWN_TEAM_CODE' THEN 'REFERENCE'
      WHEN 'INACTIVE_TEAM' THEN 'REFERENCE'
      WHEN 'TEAM_OUTSIDE_VALIDITY' THEN 'REFERENCE'

      WHEN 'UNKNOWN_STATUS' THEN 'DOMAIN'
      WHEN 'UNKNOWN_CHANNEL' THEN 'DOMAIN'
      WHEN 'UNKNOWN_CAMPAIGN' THEN 'DOMAIN'

      WHEN 'NEGATIVE_ATTEMPTS' THEN 'RANGE'
      WHEN 'NEGATIVE_ESTIMATED_VALUE' THEN 'RANGE'

      ELSE 'DATA_QUALITY'
    END AS issue_category,

    issue_code,

    CASE issue_code
      WHEN 'MISSING_SOURCE_ROW_ID'
        THEN 'Identificador da linha de origem ausente.'

      WHEN 'MISSING_RECORD_ID'
        THEN 'Identificador de negócio ausente.'

      WHEN 'MISSING_EVENT_DATE'
        THEN 'Data do evento ausente.'

      WHEN 'INVALID_EVENT_DATE'
        THEN 'Data do evento não pôde ser convertida.'

      WHEN 'MISSING_TEAM_CODE'
        THEN 'Código da equipe ausente.'

      WHEN 'UNKNOWN_TEAM_CODE'
        THEN 'Código da equipe não encontrado na referência.'

      WHEN 'INACTIVE_TEAM'
        THEN 'Equipe encontrada, mas marcada como inativa.'

      WHEN 'TEAM_OUTSIDE_VALIDITY'
        THEN 'Equipe fora do período de validade na data do evento.'

      WHEN 'MISSING_AGENT_CODE'
        THEN 'Código do agente ausente.'

      WHEN 'MISSING_CHANNEL'
        THEN 'Canal ausente.'

      WHEN 'UNKNOWN_CHANNEL'
        THEN 'Canal não pertence ao domínio permitido.'

      WHEN 'MISSING_CAMPAIGN'
        THEN 'Campanha ausente.'

      WHEN 'UNKNOWN_CAMPAIGN'
        THEN 'Campanha não pertence ao domínio permitido.'

      WHEN 'MISSING_STATUS'
        THEN 'Status ausente.'

      WHEN 'UNKNOWN_STATUS'
        THEN 'Status não pertence ao domínio permitido.'

      WHEN 'MISSING_ATTEMPTS'
        THEN 'Quantidade de tentativas ausente.'

      WHEN 'INVALID_ATTEMPTS_TYPE'
        THEN 'Quantidade de tentativas não pôde ser convertida para inteiro.'

      WHEN 'NEGATIVE_ATTEMPTS'
        THEN 'Quantidade de tentativas possui valor negativo.'

      WHEN 'MISSING_CONVERTED'
        THEN 'Indicador de conversão ausente.'

      WHEN 'INVALID_CONVERTED_TYPE'
        THEN 'Indicador de conversão não pôde ser convertido para booleano.'

      WHEN 'INVALID_ESTIMATED_VALUE_TYPE'
        THEN 'Valor estimado não pôde ser convertido para número.'

      WHEN 'NEGATIVE_ESTIMATED_VALUE'
        THEN 'Valor estimado possui valor negativo.'

      WHEN 'MISSING_SOURCE_UPDATED_AT'
        THEN 'Horário de atualização da origem ausente.'

      WHEN 'INVALID_SOURCE_UPDATED_AT'
        THEN 'Horário de atualização não pôde ser convertido.'

      ELSE 'Exceção de qualidade não mapeada.'
    END AS issue_description,

    'ERROR' AS severity

  FROM
    `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.rules_records_example`
    AS records

  CROSS JOIN
    UNNEST(records.exception_issue_codes) AS issue_code

  WHERE
    records.primary_classification = 'EXCEPTION'
),

duplicate_occurrences AS (
  SELECT
    CONCAT(
      source_row_id,
      ':EXCESS_DUPLICATE'
    ) AS occurrence_id,

    source_row_id,
    record_id,
    event_date_raw,
    event_date,

    team_code_raw,
    team_code,
    team_name,
    group_code,

    agent_code_raw,
    agent_code,

    channel_raw,
    channel,

    campaign_raw,
    campaign,

    status_raw,
    status,

    attempts_raw,
    attempts,

    converted_raw,
    converted,

    estimated_value_raw,
    estimated_value,

    source_updated_at_raw,
    source_updated_at,

    row_fingerprint,
    duplicate_count,
    duplicate_rank,
    primary_classification,

    'DUPLICATE' AS issue_category,
    'EXCESS_DUPLICATE' AS issue_code,
    'Registro excedente em um grupo com o mesmo identificador de negócio.'
      AS issue_description,
    'WARNING' AS severity

  FROM
    `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.rules_records_example`

  WHERE
    primary_classification = 'DUPLICATE'
),

window_occurrences AS (
  SELECT
    CONCAT(
      source_row_id,
      ':OUT_OF_REFERENCE_WINDOW'
    ) AS occurrence_id,

    source_row_id,
    record_id,
    event_date_raw,
    event_date,

    team_code_raw,
    team_code,
    team_name,
    group_code,

    agent_code_raw,
    agent_code,

    channel_raw,
    channel,

    campaign_raw,
    campaign,

    status_raw,
    status,

    attempts_raw,
    attempts,

    converted_raw,
    converted,

    estimated_value_raw,
    estimated_value,

    source_updated_at_raw,
    source_updated_at,

    row_fingerprint,
    duplicate_count,
    duplicate_rank,
    primary_classification,

    'REFERENCE_WINDOW' AS issue_category,
    'OUT_OF_REFERENCE_WINDOW' AS issue_code,
    'Data do evento está fora da janela de referência configurada.'
      AS issue_description,
    'INFO' AS severity

  FROM
    `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.rules_records_example`

  WHERE
    primary_classification = 'OUT_OF_WINDOW'
),

all_exception_occurrences AS (
  SELECT
    *
  FROM
    quality_occurrences

  UNION ALL

  SELECT
    *
  FROM
    duplicate_occurrences

  UNION ALL

  SELECT
    *
  FROM
    window_occurrences
)

SELECT
  occurrence_id,

  source_row_id,
  record_id,

  event_date_raw,
  event_date,

  team_code_raw,
  team_code,
  team_name,
  group_code,

  agent_code_raw,
  agent_code,

  channel_raw,
  channel,

  campaign_raw,
  campaign,

  status_raw,
  status,

  attempts_raw,
  attempts,

  converted_raw,
  converted,

  estimated_value_raw,
  estimated_value,

  source_updated_at_raw,
  source_updated_at,

  row_fingerprint,

  duplicate_count,
  duplicate_rank,

  primary_classification,
  issue_category,
  issue_code,
  issue_description,
  severity

FROM
  all_exception_occurrences;

-- ============================================================================
-- VERIFICAÇÃO 1 — DIVERGÊNCIAS
-- ============================================================================
--
-- Resultado esperado:
--
--   registros distintos = 3
--   ocorrências          = 4
--
-- SRC020 possui duas ocorrências:
--
--   CONVERTED_WITHOUT_COMPLETED_STATUS
--   CANCELLED_WITH_CONVERSION
-- ============================================================================

SELECT
  COUNT(DISTINCT source_row_id) AS distinct_divergence_records,
  COUNT(*) AS divergence_occurrences
FROM
  `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.vw_divergences_example`;

-- ============================================================================
-- VERIFICAÇÃO 2 — DIVERGÊNCIAS POR CÓDIGO
-- ============================================================================
--
-- Resultado esperado:
--
--   COMPLETED_WITHOUT_CONVERSION          = 1
--   CONVERTED_WITHOUT_COMPLETED_STATUS    = 2
--   CANCELLED_WITH_CONVERSION             = 1
-- ============================================================================

SELECT
  issue_code,
  COUNT(*) AS occurrences
FROM
  `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.vw_divergences_example`
GROUP BY
  issue_code
ORDER BY
  issue_code;

-- ============================================================================
-- VERIFICAÇÃO 3 — DETALHAMENTO DAS DIVERGÊNCIAS
-- ============================================================================

SELECT
  occurrence_id,
  source_row_id,
  record_id,
  status,
  converted,
  issue_code,
  issue_description,
  severity
FROM
  `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.vw_divergences_example`
ORDER BY
  source_row_id,
  issue_code;

-- ============================================================================
-- VERIFICAÇÃO 4 — EXCEÇÕES CONSOLIDADAS
-- ============================================================================
--
-- Resultado esperado:
--
--   registros distintos = 13
--   ocorrências          = 14
--
-- Composição:
--
--   11 registros classificados como EXCEPTION;
--    1 registro classificado como DUPLICATE;
--    1 registro classificado como OUT_OF_WINDOW.
--
-- SRC022 possui duas ocorrências de referência:
--
--   INACTIVE_TEAM
--   TEAM_OUTSIDE_VALIDITY
-- ============================================================================

SELECT
  COUNT(DISTINCT source_row_id) AS distinct_exception_records,
  COUNT(*) AS exception_occurrences
FROM
  `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.vw_exceptions_example`;

-- ============================================================================
-- VERIFICAÇÃO 5 — EXCEÇÕES POR CLASSIFICAÇÃO PRINCIPAL
-- ============================================================================

SELECT
  primary_classification,
  COUNT(DISTINCT source_row_id) AS distinct_records,
  COUNT(*) AS occurrences
FROM
  `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.vw_exceptions_example`
GROUP BY
  primary_classification
ORDER BY
  CASE primary_classification
    WHEN 'EXCEPTION' THEN 1
    WHEN 'DUPLICATE' THEN 2
    WHEN 'OUT_OF_WINDOW' THEN 3
    ELSE 4
  END;

-- ============================================================================
-- VERIFICAÇÃO 6 — EXCEÇÕES POR CATEGORIA
-- ============================================================================

SELECT
  issue_category,
  COUNT(DISTINCT source_row_id) AS distinct_records,
  COUNT(*) AS occurrences
FROM
  `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.vw_exceptions_example`
GROUP BY
  issue_category
ORDER BY
  issue_category;

-- ============================================================================
-- VERIFICAÇÃO 7 — EXCEÇÕES POR CÓDIGO
-- ============================================================================

SELECT
  issue_code,
  COUNT(DISTINCT source_row_id) AS distinct_records,
  COUNT(*) AS occurrences
FROM
  `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.vw_exceptions_example`
GROUP BY
  issue_code
ORDER BY
  issue_code;

-- ============================================================================
-- VERIFICAÇÃO 8 — DETALHAMENTO DAS EXCEÇÕES
-- ============================================================================

SELECT
  occurrence_id,
  source_row_id,
  record_id,
  primary_classification,
  issue_category,
  issue_code,
  issue_description,
  severity
FROM
  `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.vw_exceptions_example`
ORDER BY
  source_row_id,
  issue_code;

-- ============================================================================
-- VERIFICAÇÃO 9 — CONSISTÊNCIA COM A CAMADA DE REGRAS
-- ============================================================================

SELECT
  (
    SELECT COUNT(DISTINCT source_row_id)
    FROM
      `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.vw_divergences_example`
  ) AS divergence_view_records,

  (
    SELECT COUNTIF(primary_classification = 'DIVERGENCE')
    FROM
      `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.rules_records_example`
  ) AS divergence_rules_records,

  (
    SELECT COUNT(DISTINCT source_row_id)
    FROM
      `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.vw_exceptions_example`
  ) AS exception_view_records,

  (
    SELECT COUNTIF(
      primary_classification IN (
        'EXCEPTION',
        'DUPLICATE',
        'OUT_OF_WINDOW'
      )
    )
    FROM
      `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.rules_records_example`
  ) AS exception_rules_records;

-- ============================================================================
-- VERIFICAÇÃO 10 — EXPIRAÇÃO E LABELS
-- ============================================================================

SELECT
  table_name,
  option_name,
  option_value
FROM
  `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.INFORMATION_SCHEMA.TABLE_OPTIONS`
WHERE
  table_name IN (
    'vw_divergences_example',
    'vw_exceptions_example'
  )
  AND option_name IN (
    'description',
    'expiration_timestamp',
    'labels'
  )
ORDER BY
  table_name,
  option_name;
