-- ============================================================================
-- sheets-bigquery-sandbox-pipeline
-- Arquivo: src/sql/02_clean_example.sql
-- Finalidade: normalizar, converter e enriquecer os dados sintéticos raw.
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
--   2. carregue input-example.csv em raw_input_example;
--   3. carregue team-example.csv em raw_team_example;
--   4. confirme 24 registros na tabela principal;
--   5. confirme 4 registros na referência de equipes.
--
-- SEGURANÇA
--
-- Este script:
--
--   1. lê somente as tabelas raw sintéticas;
--   2. não acessa dados de produção;
--   3. não altera os arquivos CSV;
--   4. não executa publicação em planilhas;
--   5. não cria gatilhos;
--   6. não contém credenciais;
--   7. configura expiração de 59 dias;
--   8. preserva valores inválidos para diagnóstico.
--
-- ESTRATÉGIA
--
-- A camada clean:
--
--   1. normaliza espaços e capitalização;
--   2. converte textos com SAFE_CAST;
--   3. preserva os valores raw relevantes;
--   4. relaciona cada registro com a referência de equipes;
--   5. calcula a ordem de deduplicação;
--   6. mantém todas as linhas de origem;
--   7. identifica qual linha seria selecionada por record_id;
--   8. registra problemas técnicos de limpeza.
--
-- A remoção física de duplicidades não ocorre nesta etapa.
--
-- Todas as linhas permanecem disponíveis para auditoria.
-- ============================================================================

CREATE OR REPLACE TABLE
  `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.clean_records_example`
OPTIONS (
  expiration_timestamp = TIMESTAMP_ADD(
    CURRENT_TIMESTAMP(),
    INTERVAL 59 DAY
  ),
  description = 'Camada clean sintética com normalização, conversões seguras, referência de equipes e evidências de duplicidade.',
  labels = [
    ('environment', 'sandbox'),
    ('layer', 'clean'),
    ('category', 'synthetic_records'),
    ('retention', '59_days')
  ]
)
AS

WITH input_normalized AS (
  SELECT
    NULLIF(TRIM(source_row_id), '') AS source_row_id,
    NULLIF(TRIM(record_id), '') AS record_id,

    event_date AS event_date_raw,
    NULLIF(TRIM(event_date), '') AS event_date_normalized,

    team_code AS team_code_raw,
    NULLIF(UPPER(TRIM(team_code)), '') AS team_code,

    agent_code AS agent_code_raw,
    NULLIF(UPPER(TRIM(agent_code)), '') AS agent_code,

    channel AS channel_raw,
    NULLIF(UPPER(TRIM(channel)), '') AS channel,

    campaign AS campaign_raw,
    NULLIF(UPPER(TRIM(campaign)), '') AS campaign,

    status AS status_raw,
    NULLIF(UPPER(TRIM(status)), '') AS status,

    attempts AS attempts_raw,
    NULLIF(TRIM(attempts), '') AS attempts_normalized,

    converted AS converted_raw,
    NULLIF(UPPER(TRIM(converted)), '') AS converted_normalized,

    estimated_value AS estimated_value_raw,
    NULLIF(TRIM(estimated_value), '') AS estimated_value_normalized,

    source_updated_at AS source_updated_at_raw,
    NULLIF(TRIM(source_updated_at), '') AS source_updated_at_normalized
  FROM
    `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.raw_input_example`
),

input_typed AS (
  SELECT
    source_row_id,
    record_id,

    event_date_raw,
    event_date_normalized,
    SAFE_CAST(event_date_normalized AS DATE) AS event_date,

    team_code_raw,
    team_code,

    agent_code_raw,
    agent_code,

    channel_raw,
    channel,

    campaign_raw,
    campaign,

    status_raw,
    status,

    attempts_raw,
    attempts_normalized,
    SAFE_CAST(attempts_normalized AS INT64) AS attempts,

    converted_raw,
    converted_normalized,
    CASE converted_normalized
      WHEN 'TRUE' THEN TRUE
      WHEN 'FALSE' THEN FALSE
      ELSE NULL
    END AS converted,

    estimated_value_raw,
    estimated_value_normalized,
    SAFE_CAST(estimated_value_normalized AS NUMERIC) AS estimated_value,

    source_updated_at_raw,
    source_updated_at_normalized,
    SAFE_CAST(source_updated_at_normalized AS TIMESTAMP) AS source_updated_at,

    TO_HEX(
      SHA256(
        CONCAT(
          COALESCE(source_row_id, ''),
          '|',
          COALESCE(record_id, ''),
          '|',
          COALESCE(event_date_normalized, ''),
          '|',
          COALESCE(team_code, ''),
          '|',
          COALESCE(agent_code, ''),
          '|',
          COALESCE(channel, ''),
          '|',
          COALESCE(campaign, ''),
          '|',
          COALESCE(status, ''),
          '|',
          COALESCE(attempts_normalized, ''),
          '|',
          COALESCE(converted_normalized, ''),
          '|',
          COALESCE(estimated_value_normalized, ''),
          '|',
          COALESCE(source_updated_at_normalized, '')
        )
      )
    ) AS row_fingerprint
  FROM
    input_normalized
),

input_with_duplicates AS (
  SELECT
    input_typed.*,

    COUNT(*) OVER (
      PARTITION BY
        COALESCE(
          record_id,
          CONCAT('__MISSING_RECORD__', COALESCE(source_row_id, GENERATE_UUID()))
        )
    ) AS duplicate_count,

    ROW_NUMBER() OVER (
      PARTITION BY
        COALESCE(
          record_id,
          CONCAT('__MISSING_RECORD__', COALESCE(source_row_id, GENERATE_UUID()))
        )
      ORDER BY
        source_updated_at DESC,
        source_row_id DESC
    ) AS duplicate_rank
  FROM
    input_typed
),

team_normalized AS (
  SELECT
    NULLIF(UPPER(TRIM(team_code)), '') AS reference_team_code,
    NULLIF(TRIM(team_name), '') AS team_name,
    NULLIF(UPPER(TRIM(group_code)), '') AS group_code,

    active AS active_raw,
    NULLIF(UPPER(TRIM(active)), '') AS active_normalized,

    daily_capacity_reference AS daily_capacity_reference_raw,
    NULLIF(
      TRIM(daily_capacity_reference),
      ''
    ) AS daily_capacity_reference_normalized,

    valid_from AS valid_from_raw,
    NULLIF(TRIM(valid_from), '') AS valid_from_normalized,

    valid_to AS valid_to_raw,
    NULLIF(TRIM(valid_to), '') AS valid_to_normalized
  FROM
    `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.raw_team_example`
),

team_typed AS (
  SELECT
    reference_team_code,
    team_name,
    group_code,

    active_raw,
    active_normalized,
    CASE active_normalized
      WHEN 'TRUE' THEN TRUE
      WHEN 'FALSE' THEN FALSE
      ELSE NULL
    END AS team_active,

    daily_capacity_reference_raw,
    daily_capacity_reference_normalized,
    SAFE_CAST(
      daily_capacity_reference_normalized AS INT64
    ) AS daily_capacity_reference,

    valid_from_raw,
    valid_from_normalized,
    SAFE_CAST(valid_from_normalized AS DATE) AS team_valid_from,

    valid_to_raw,
    valid_to_normalized,
    SAFE_CAST(valid_to_normalized AS DATE) AS team_valid_to
  FROM
    team_normalized
),

joined_records AS (
  SELECT
    input_with_duplicates.source_row_id,
    input_with_duplicates.record_id,

    input_with_duplicates.event_date_raw,
    input_with_duplicates.event_date_normalized,
    input_with_duplicates.event_date,

    input_with_duplicates.team_code_raw,
    input_with_duplicates.team_code,

    input_with_duplicates.agent_code_raw,
    input_with_duplicates.agent_code,

    input_with_duplicates.channel_raw,
    input_with_duplicates.channel,

    input_with_duplicates.campaign_raw,
    input_with_duplicates.campaign,

    input_with_duplicates.status_raw,
    input_with_duplicates.status,

    input_with_duplicates.attempts_raw,
    input_with_duplicates.attempts_normalized,
    input_with_duplicates.attempts,

    input_with_duplicates.converted_raw,
    input_with_duplicates.converted_normalized,
    input_with_duplicates.converted,

    input_with_duplicates.estimated_value_raw,
    input_with_duplicates.estimated_value_normalized,
    input_with_duplicates.estimated_value,

    input_with_duplicates.source_updated_at_raw,
    input_with_duplicates.source_updated_at_normalized,
    input_with_duplicates.source_updated_at,

    input_with_duplicates.row_fingerprint,
    input_with_duplicates.duplicate_count,
    input_with_duplicates.duplicate_rank,

    team_typed.reference_team_code,
    team_typed.team_name,
    team_typed.group_code,
    team_typed.active_raw AS team_active_raw,
    team_typed.team_active,
    team_typed.daily_capacity_reference_raw,
    team_typed.daily_capacity_reference,
    team_typed.valid_from_raw AS team_valid_from_raw,
    team_typed.team_valid_from,
    team_typed.valid_to_raw AS team_valid_to_raw,
    team_typed.team_valid_to
  FROM
    input_with_duplicates
  LEFT JOIN
    team_typed
  ON
    input_with_duplicates.team_code = team_typed.reference_team_code
),

evaluated_records AS (
  SELECT
    joined_records.*,

    duplicate_count > 1 AS is_in_duplicate_group,
    duplicate_rank = 1 AS is_selected_business_record,
    duplicate_rank > 1 AS is_excess_duplicate,

    source_row_id IS NOT NULL AS has_source_row_id,
    record_id IS NOT NULL AS has_record_id,
    event_date_normalized IS NOT NULL AS has_event_date,
    team_code IS NOT NULL AS has_team_code,
    agent_code IS NOT NULL AS has_agent_code,
    channel IS NOT NULL AS has_channel,
    campaign IS NOT NULL AS has_campaign,
    status IS NOT NULL AS has_status,
    attempts_normalized IS NOT NULL AS has_attempts,
    converted_normalized IS NOT NULL AS has_converted,
    source_updated_at_normalized IS NOT NULL AS has_source_updated_at,

    event_date_normalized IS NOT NULL
      AND event_date IS NOT NULL AS is_event_date_valid,

    attempts_normalized IS NOT NULL
      AND attempts IS NOT NULL AS is_attempts_type_valid,

    converted_normalized IS NOT NULL
      AND converted IS NOT NULL AS is_converted_type_valid,

    estimated_value_normalized IS NULL
      OR estimated_value IS NOT NULL AS is_estimated_value_type_valid,

    source_updated_at_normalized IS NOT NULL
      AND source_updated_at IS NOT NULL AS is_source_updated_at_valid,

    reference_team_code IS NOT NULL AS team_exists,

    reference_team_code IS NOT NULL
      AND team_active IS TRUE AS team_is_active,

    reference_team_code IS NOT NULL
      AND event_date IS NOT NULL
      AND team_valid_from IS NOT NULL
      AND event_date >= team_valid_from
      AND (
        team_valid_to IS NULL
        OR event_date <= team_valid_to
      ) AS team_is_valid_on_event_date,

    event_date IS NOT NULL
      AND event_date BETWEEN DATE '2026-11-01' AND DATE '2026-11-30'
      AS is_within_reference_window,

    source_row_id IS NOT NULL
      AND record_id IS NOT NULL
      AND event_date_normalized IS NOT NULL
      AND team_code IS NOT NULL
      AND agent_code IS NOT NULL
      AND channel IS NOT NULL
      AND campaign IS NOT NULL
      AND status IS NOT NULL
      AND attempts_normalized IS NOT NULL
      AND converted_normalized IS NOT NULL
      AND source_updated_at_normalized IS NOT NULL
      AS required_fields_present
  FROM
    joined_records
)

SELECT
  source_row_id,
  record_id,

  event_date_raw,
  event_date,

  team_code_raw,
  team_code,

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
  is_in_duplicate_group,
  is_selected_business_record,
  is_excess_duplicate,

  reference_team_code,
  team_name,
  group_code,
  team_active_raw,
  team_active,
  daily_capacity_reference_raw,
  daily_capacity_reference,
  team_valid_from_raw,
  team_valid_from,
  team_valid_to_raw,
  team_valid_to,

  has_source_row_id,
  has_record_id,
  has_event_date,
  has_team_code,
  has_agent_code,
  has_channel,
  has_campaign,
  has_status,
  has_attempts,
  has_converted,
  has_source_updated_at,

  is_event_date_valid,
  is_attempts_type_valid,
  is_converted_type_valid,
  is_estimated_value_type_valid,
  is_source_updated_at_valid,

  team_exists,
  team_is_active,
  team_is_valid_on_event_date,
  is_within_reference_window,
  required_fields_present,

  ARRAY(
    SELECT issue_code
    FROM UNNEST(
      [
        IF(
          NOT has_source_row_id,
          'MISSING_SOURCE_ROW_ID',
          NULL
        ),
        IF(
          NOT has_record_id,
          'MISSING_RECORD_ID',
          NULL
        ),
        IF(
          NOT has_event_date,
          'MISSING_EVENT_DATE',
          NULL
        ),
        IF(
          has_event_date AND NOT is_event_date_valid,
          'INVALID_EVENT_DATE',
          NULL
        ),
        IF(
          NOT has_team_code,
          'MISSING_TEAM_CODE',
          NULL
        ),
        IF(
          has_team_code AND NOT team_exists,
          'UNKNOWN_TEAM_CODE',
          NULL
        ),
        IF(
          team_exists AND NOT team_is_active,
          'INACTIVE_TEAM',
          NULL
        ),
        IF(
          team_exists
          AND is_event_date_valid
          AND NOT team_is_valid_on_event_date,
          'TEAM_OUTSIDE_VALIDITY',
          NULL
        ),
        IF(
          NOT has_agent_code,
          'MISSING_AGENT_CODE',
          NULL
        ),
        IF(
          NOT has_channel,
          'MISSING_CHANNEL',
          NULL
        ),
        IF(
          NOT has_campaign,
          'MISSING_CAMPAIGN',
          NULL
        ),
        IF(
          NOT has_status,
          'MISSING_STATUS',
          NULL
        ),
        IF(
          NOT has_attempts,
          'MISSING_ATTEMPTS',
          NULL
        ),
        IF(
          has_attempts AND NOT is_attempts_type_valid,
          'INVALID_ATTEMPTS_TYPE',
          NULL
        ),
        IF(
          NOT has_converted,
          'MISSING_CONVERTED',
          NULL
        ),
        IF(
          has_converted AND NOT is_converted_type_valid,
          'INVALID_CONVERTED_TYPE',
          NULL
        ),
        IF(
          NOT is_estimated_value_type_valid,
          'INVALID_ESTIMATED_VALUE_TYPE',
          NULL
        ),
        IF(
          NOT has_source_updated_at,
          'MISSING_SOURCE_UPDATED_AT',
          NULL
        ),
        IF(
          has_source_updated_at AND NOT is_source_updated_at_valid,
          'INVALID_SOURCE_UPDATED_AT',
          NULL
        ),
        IF(
          is_event_date_valid
          AND NOT is_within_reference_window,
          'OUT_OF_REFERENCE_WINDOW',
          NULL
        ),
        IF(
          is_excess_duplicate,
          'EXCESS_DUPLICATE',
          NULL
        )
      ]
    ) AS issue_code
    WHERE issue_code IS NOT NULL
  ) AS clean_issue_codes

FROM
  evaluated_records;

-- ============================================================================
-- VERIFICAÇÃO 1 — CONTAGEM RAW E CLEAN
-- ============================================================================
--
-- Resultado esperado após a carga correta:
--
--   raw_rows   = 24
--   clean_rows = 24
--
-- A camada clean preserva todas as linhas da origem.
-- ============================================================================

SELECT
  (
    SELECT COUNT(*)
    FROM
      `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.raw_input_example`
  ) AS raw_rows,

  (
    SELECT COUNT(*)
    FROM
      `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.clean_records_example`
  ) AS clean_rows,

  (
    SELECT COUNT(*)
    FROM
      `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.raw_input_example`
  )
  =
  (
    SELECT COUNT(*)
    FROM
      `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.clean_records_example`
  ) AS raw_equals_clean;

-- ============================================================================
-- VERIFICAÇÃO 2 — DEDUPLICAÇÃO
-- ============================================================================
--
-- Resultado esperado:
--
--   total_rows                  = 24
--   selected_business_rows      = 23
--   rows_in_duplicate_groups    = 2
--   excess_duplicate_rows       = 1
--
-- REC015 aparece duas vezes.
--
-- A linha mais recente deve possuir duplicate_rank = 1.
-- ============================================================================

SELECT
  COUNT(*) AS total_rows,
  COUNTIF(is_selected_business_record) AS selected_business_rows,
  COUNTIF(is_in_duplicate_group) AS rows_in_duplicate_groups,
  COUNTIF(is_excess_duplicate) AS excess_duplicate_rows
FROM
  `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.clean_records_example`;

-- ============================================================================
-- VERIFICAÇÃO 3 — CONVERSÕES E REFERÊNCIAS
-- ============================================================================

SELECT
  COUNTIF(NOT required_fields_present) AS rows_with_missing_required_fields,
  COUNTIF(NOT is_event_date_valid) AS rows_with_invalid_or_missing_event_date,
  COUNTIF(NOT is_attempts_type_valid) AS rows_with_invalid_or_missing_attempts,
  COUNTIF(NOT is_converted_type_valid) AS rows_with_invalid_or_missing_boolean,
  COUNTIF(NOT is_estimated_value_type_valid) AS rows_with_invalid_value_type,
  COUNTIF(NOT is_source_updated_at_valid) AS rows_with_invalid_update_timestamp,
  COUNTIF(has_team_code AND NOT team_exists) AS rows_with_unknown_team,
  COUNTIF(team_exists AND NOT team_is_active) AS rows_with_inactive_team,
  COUNTIF(
    team_exists
    AND is_event_date_valid
    AND NOT team_is_valid_on_event_date
  ) AS rows_with_team_outside_validity,
  COUNTIF(
    is_event_date_valid
    AND NOT is_within_reference_window
  ) AS rows_outside_reference_window
FROM
  `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.clean_records_example`;

-- ============================================================================
-- VERIFICAÇÃO 4 — PROBLEMAS DE LIMPEZA
-- ============================================================================
--
-- Exibe somente registros com pelo menos um código técnico de limpeza.
-- Não altera nenhum dado.
-- ============================================================================

SELECT
  source_row_id,
  record_id,
  clean_issue_codes
FROM
  `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.clean_records_example`
WHERE
  ARRAY_LENGTH(clean_issue_codes) > 0
ORDER BY
  source_row_id;

-- ============================================================================
-- VERIFICAÇÃO 5 — REGISTRO DUPLICADO
-- ============================================================================

SELECT
  source_row_id,
  record_id,
  source_updated_at,
  duplicate_count,
  duplicate_rank,
  is_selected_business_record,
  is_excess_duplicate
FROM
  `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.clean_records_example`
WHERE
  is_in_duplicate_group
ORDER BY
  record_id,
  duplicate_rank;

-- ============================================================================
-- VERIFICAÇÃO 6 — EXPIRAÇÃO E LABELS
-- ============================================================================

SELECT
  table_name,
  option_name,
  option_value
FROM
  `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.INFORMATION_SCHEMA.TABLE_OPTIONS`
WHERE
  table_name = 'clean_records_example'
  AND option_name IN (
    'description',
    'expiration_timestamp',
    'labels'
  )
ORDER BY
  option_name;
