-- ============================================================================
-- sheets-bigquery-sandbox-pipeline
-- Arquivo: src/sql/04_indicators_example.sql
-- Finalidade: criar indicadores sintéticos sobre a camada de regras.
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
--   5. confirme 24 registros em rules_records_example.
--
-- ESCOPO DOS INDICADORES
--
-- A view utiliza somente registros com:
--
--   eligible_for_business_analysis = TRUE
--
-- Isso inclui:
--
--   VALID
--   DIVERGENCE
--
-- E exclui:
--
--   EXCEPTION
--   DUPLICATE
--   OUT_OF_WINDOW
--
-- Os registros com divergência permanecem nos indicadores porque possuem
-- estrutura técnica válida e representam situações reais de negócio que
-- precisam ser visíveis.
--
-- NÍVEIS DE AGREGAÇÃO
--
--   OVERALL
--   DATE
--   TEAM
--   GROUP
--   CHANNEL
--   CAMPAIGN
--   DATE_TEAM
--   DATE_TEAM_CHANNEL_CAMPAIGN
--
-- SEGURANÇA
--
-- Este script:
--
--   1. lê somente a camada de regras sintética;
--   2. não acessa produção;
--   3. não publica em planilhas;
--   4. não cria gatilhos;
--   5. não contém credenciais;
--   6. não executa DML;
--   7. não altera os dados de origem.
-- ============================================================================

CREATE OR REPLACE VIEW
  `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.vw_indicators_example`
OPTIONS (
  expiration_timestamp = TIMESTAMP_ADD(
    CURRENT_TIMESTAMP(),
    INTERVAL 59 DAY
  ),
  description = 'Indicadores sintéticos por nível de agregação, calculados sobre registros elegíveis da camada de regras.',
  labels = [
    ('environment', 'sandbox'),
    ('layer', 'indicators'),
    ('category', 'synthetic_analytics'),
    ('retention', '59_days')
  ]
)
AS

WITH eligible_records AS (
  SELECT
    source_row_id,
    record_id,
    event_date,
    team_code,
    team_name,
    group_code,
    channel,
    campaign,
    status,
    attempts,
    converted,
    estimated_value,
    daily_capacity_reference,
    primary_classification
  FROM
    `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.rules_records_example`
  WHERE
    eligible_for_business_analysis
),

expanded_dimensions AS (
  -- ========================================================================
  -- NÍVEL GERAL
  -- ========================================================================

  SELECT
    'OVERALL' AS indicator_level,
    CAST(NULL AS DATE) AS event_date,
    CAST(NULL AS STRING) AS team_code,
    CAST(NULL AS STRING) AS team_name,
    CAST(NULL AS STRING) AS group_code,
    CAST(NULL AS STRING) AS channel,
    CAST(NULL AS STRING) AS campaign,
    CAST(NULL AS INT64) AS daily_capacity_reference,
    source_row_id,
    record_id,
    status,
    attempts,
    converted,
    estimated_value,
    primary_classification
  FROM
    eligible_records

  UNION ALL

  -- ========================================================================
  -- NÍVEL POR DATA
  -- ========================================================================

  SELECT
    'DATE' AS indicator_level,
    event_date,
    CAST(NULL AS STRING) AS team_code,
    CAST(NULL AS STRING) AS team_name,
    CAST(NULL AS STRING) AS group_code,
    CAST(NULL AS STRING) AS channel,
    CAST(NULL AS STRING) AS campaign,
    CAST(NULL AS INT64) AS daily_capacity_reference,
    source_row_id,
    record_id,
    status,
    attempts,
    converted,
    estimated_value,
    primary_classification
  FROM
    eligible_records

  UNION ALL

  -- ========================================================================
  -- NÍVEL POR EQUIPE
  -- ========================================================================

  SELECT
    'TEAM' AS indicator_level,
    CAST(NULL AS DATE) AS event_date,
    team_code,
    team_name,
    group_code,
    CAST(NULL AS STRING) AS channel,
    CAST(NULL AS STRING) AS campaign,
    CAST(NULL AS INT64) AS daily_capacity_reference,
    source_row_id,
    record_id,
    status,
    attempts,
    converted,
    estimated_value,
    primary_classification
  FROM
    eligible_records

  UNION ALL

  -- ========================================================================
  -- NÍVEL POR GRUPO
  -- ========================================================================

  SELECT
    'GROUP' AS indicator_level,
    CAST(NULL AS DATE) AS event_date,
    CAST(NULL AS STRING) AS team_code,
    CAST(NULL AS STRING) AS team_name,
    group_code,
    CAST(NULL AS STRING) AS channel,
    CAST(NULL AS STRING) AS campaign,
    CAST(NULL AS INT64) AS daily_capacity_reference,
    source_row_id,
    record_id,
    status,
    attempts,
    converted,
    estimated_value,
    primary_classification
  FROM
    eligible_records

  UNION ALL

  -- ========================================================================
  -- NÍVEL POR CANAL
  -- ========================================================================

  SELECT
    'CHANNEL' AS indicator_level,
    CAST(NULL AS DATE) AS event_date,
    CAST(NULL AS STRING) AS team_code,
    CAST(NULL AS STRING) AS team_name,
    CAST(NULL AS STRING) AS group_code,
    channel,
    CAST(NULL AS STRING) AS campaign,
    CAST(NULL AS INT64) AS daily_capacity_reference,
    source_row_id,
    record_id,
    status,
    attempts,
    converted,
    estimated_value,
    primary_classification
  FROM
    eligible_records

  UNION ALL

  -- ========================================================================
  -- NÍVEL POR CAMPANHA
  -- ========================================================================

  SELECT
    'CAMPAIGN' AS indicator_level,
    CAST(NULL AS DATE) AS event_date,
    CAST(NULL AS STRING) AS team_code,
    CAST(NULL AS STRING) AS team_name,
    CAST(NULL AS STRING) AS group_code,
    CAST(NULL AS STRING) AS channel,
    campaign,
    CAST(NULL AS INT64) AS daily_capacity_reference,
    source_row_id,
    record_id,
    status,
    attempts,
    converted,
    estimated_value,
    primary_classification
  FROM
    eligible_records

  UNION ALL

  -- ========================================================================
  -- NÍVEL POR DATA E EQUIPE
  -- ========================================================================
  --
  -- Este é o nível utilizado para comparar o volume do dia com a capacidade
  -- diária de referência da equipe.
  -- ========================================================================

  SELECT
    'DATE_TEAM' AS indicator_level,
    event_date,
    team_code,
    team_name,
    group_code,
    CAST(NULL AS STRING) AS channel,
    CAST(NULL AS STRING) AS campaign,
    daily_capacity_reference,
    source_row_id,
    record_id,
    status,
    attempts,
    converted,
    estimated_value,
    primary_classification
  FROM
    eligible_records

  UNION ALL

  -- ========================================================================
  -- NÍVEL DETALHADO
  -- ========================================================================

  SELECT
    'DATE_TEAM_CHANNEL_CAMPAIGN' AS indicator_level,
    event_date,
    team_code,
    team_name,
    group_code,
    channel,
    campaign,
    CAST(NULL AS INT64) AS daily_capacity_reference,
    source_row_id,
    record_id,
    status,
    attempts,
    converted,
    estimated_value,
    primary_classification
  FROM
    eligible_records
),

aggregated_indicators AS (
  SELECT
    indicator_level,
    event_date,
    team_code,
    team_name,
    group_code,
    channel,
    campaign,

    MAX(daily_capacity_reference) AS daily_capacity_reference,

    COUNT(*) AS total_records,

    COUNTIF(
      primary_classification = 'VALID'
    ) AS valid_records,

    COUNTIF(
      primary_classification = 'DIVERGENCE'
    ) AS divergence_records,

    COUNTIF(
      converted IS TRUE
    ) AS converted_records,

    COUNTIF(
      primary_classification = 'VALID'
      AND converted IS TRUE
    ) AS valid_converted_records,

    COUNTIF(
      primary_classification = 'DIVERGENCE'
      AND converted IS TRUE
    ) AS divergence_converted_records,

    COUNTIF(
      status = 'NEW'
    ) AS new_records,

    COUNTIF(
      status = 'IN_PROGRESS'
    ) AS in_progress_records,

    COUNTIF(
      status = 'COMPLETED'
    ) AS completed_records,

    COUNTIF(
      status = 'CANCELLED'
    ) AS cancelled_records,

    SUM(attempts) AS total_attempts,

    ROUND(
      AVG(CAST(attempts AS NUMERIC)),
      2
    ) AS average_attempts,

    SUM(estimated_value) AS total_estimated_value,

    COUNTIF(
      estimated_value IS NULL
    ) AS missing_estimated_value_records

  FROM
    expanded_dimensions
  GROUP BY
    indicator_level,
    event_date,
    team_code,
    team_name,
    group_code,
    channel,
    campaign
)

SELECT
  indicator_level,
  event_date,
  team_code,
  team_name,
  group_code,
  channel,
  campaign,

  total_records,
  valid_records,
  divergence_records,

  converted_records,
  valid_converted_records,
  divergence_converted_records,

  ROUND(
    SAFE_MULTIPLY(
      SAFE_DIVIDE(
        converted_records,
        total_records
      ),
      100
    ),
    2
  ) AS conversion_rate_percentage,

  ROUND(
    SAFE_MULTIPLY(
      SAFE_DIVIDE(
        valid_converted_records,
        valid_records
      ),
      100
    ),
    2
  ) AS valid_conversion_rate_percentage,

  new_records,
  in_progress_records,
  completed_records,
  cancelled_records,

  total_attempts,
  average_attempts,
  total_estimated_value,
  missing_estimated_value_records,

  daily_capacity_reference,

  CASE
    WHEN daily_capacity_reference IS NULL THEN NULL
    ELSE GREATEST(
      daily_capacity_reference - total_records,
      0
    )
  END AS remaining_capacity_reference,

  CASE
    WHEN daily_capacity_reference IS NULL THEN NULL
    ELSE total_records > daily_capacity_reference
  END AS capacity_exceeded,

  CASE
    WHEN daily_capacity_reference IS NULL THEN NULL
    ELSE ROUND(
      SAFE_MULTIPLY(
        SAFE_DIVIDE(
          total_records,
          daily_capacity_reference
        ),
        100
      ),
      2
    )
  END AS capacity_utilization_percentage

FROM
  aggregated_indicators;

-- ============================================================================
-- VERIFICAÇÃO 1 — INDICADOR GERAL
-- ============================================================================
--
-- Resultado esperado:
--
--   total_records                  = 11
--   valid_records                  = 8
--   divergence_records             = 3
--   converted_records              = 6
--   valid_converted_records        = 4
--   divergence_converted_records   = 2
--   conversion_rate_percentage     = 54.55
--   valid_conversion_rate          = 50.00
--   total_attempts                 = 27
--   average_attempts               = 2.45
--   total_estimated_value          = 1535.00
--   missing_estimated_value        = 1
-- ============================================================================

SELECT
  *
FROM
  `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.vw_indicators_example`
WHERE
  indicator_level = 'OVERALL';

-- ============================================================================
-- VERIFICAÇÃO 2 — INDICADORES POR DATA
-- ============================================================================
--
-- Resultado esperado:
--
--   2026-11-03 = 4 registros
--   2026-11-05 = 3 registros
--   2026-11-06 = 1 registro
--   2026-11-07 = 1 registro
--   2026-11-08 = 2 registros
--
-- O dia 2026-11-04 não aparece porque todos os registros desse dia possuem
-- exceções impeditivas.
-- ============================================================================

SELECT
  event_date,
  total_records,
  valid_records,
  divergence_records,
  converted_records,
  conversion_rate_percentage,
  total_attempts,
  total_estimated_value
FROM
  `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.vw_indicators_example`
WHERE
  indicator_level = 'DATE'
ORDER BY
  event_date;

-- ============================================================================
-- VERIFICAÇÃO 3 — INDICADORES POR EQUIPE
-- ============================================================================
--
-- Resultado esperado:
--
--   TEAM_A = 4 registros
--   TEAM_B = 4 registros
--   TEAM_C = 3 registros
--
-- TEAM_D não aparece porque seu registro possui exceção.
-- TEAM_X não aparece porque não existe na referência.
-- ============================================================================

SELECT
  team_code,
  team_name,
  group_code,
  total_records,
  valid_records,
  divergence_records,
  converted_records,
  conversion_rate_percentage,
  total_attempts,
  total_estimated_value
FROM
  `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.vw_indicators_example`
WHERE
  indicator_level = 'TEAM'
ORDER BY
  team_code;

-- ============================================================================
-- VERIFICAÇÃO 4 — INDICADORES POR GRUPO
-- ============================================================================

SELECT
  group_code,
  total_records,
  valid_records,
  divergence_records,
  converted_records,
  conversion_rate_percentage,
  total_attempts,
  total_estimated_value
FROM
  `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.vw_indicators_example`
WHERE
  indicator_level = 'GROUP'
ORDER BY
  group_code;

-- ============================================================================
-- VERIFICAÇÃO 5 — INDICADORES POR CANAL
-- ============================================================================

SELECT
  channel,
  total_records,
  valid_records,
  divergence_records,
  converted_records,
  conversion_rate_percentage
FROM
  `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.vw_indicators_example`
WHERE
  indicator_level = 'CHANNEL'
ORDER BY
  channel;

-- ============================================================================
-- VERIFICAÇÃO 6 — INDICADORES POR CAMPANHA
-- ============================================================================

SELECT
  campaign,
  total_records,
  valid_records,
  divergence_records,
  converted_records,
  conversion_rate_percentage
FROM
  `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.vw_indicators_example`
WHERE
  indicator_level = 'CAMPAIGN'
ORDER BY
  campaign;

-- ============================================================================
-- VERIFICAÇÃO 7 — CAPACIDADE POR DATA E EQUIPE
-- ============================================================================

SELECT
  event_date,
  team_code,
  team_name,
  total_records,
  daily_capacity_reference,
  remaining_capacity_reference,
  capacity_exceeded,
  capacity_utilization_percentage
FROM
  `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.vw_indicators_example`
WHERE
  indicator_level = 'DATE_TEAM'
ORDER BY
  event_date,
  team_code;

-- ============================================================================
-- VERIFICAÇÃO 8 — DECOMPOSIÇÃO DO INDICADOR GERAL
-- ============================================================================
--
-- O total geral deve ser igual à soma de válidos e divergências.
-- ============================================================================

SELECT
  total_records,
  valid_records,
  divergence_records,

  total_records
    =
    valid_records + divergence_records
    AS valid_plus_divergence_equals_total,

  converted_records,
  valid_converted_records,
  divergence_converted_records,

  converted_records
    =
    valid_converted_records + divergence_converted_records
    AS converted_decomposition_valid

FROM
  `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.vw_indicators_example`
WHERE
  indicator_level = 'OVERALL';

-- ============================================================================
-- VERIFICAÇÃO 9 — QUANTIDADE DE LINHAS POR NÍVEL
-- ============================================================================

SELECT
  indicator_level,
  COUNT(*) AS indicator_rows
FROM
  `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.vw_indicators_example`
GROUP BY
  indicator_level
ORDER BY
  CASE indicator_level
    WHEN 'OVERALL' THEN 1
    WHEN 'DATE' THEN 2
    WHEN 'TEAM' THEN 3
    WHEN 'GROUP' THEN 4
    WHEN 'CHANNEL' THEN 5
    WHEN 'CAMPAIGN' THEN 6
    WHEN 'DATE_TEAM' THEN 7
    WHEN 'DATE_TEAM_CHANNEL_CAMPAIGN' THEN 8
    ELSE 9
  END;

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
  table_name = 'vw_indicators_example'
  AND option_name IN (
    'description',
    'expiration_timestamp',
    'labels'
  )
ORDER BY
  option_name;
