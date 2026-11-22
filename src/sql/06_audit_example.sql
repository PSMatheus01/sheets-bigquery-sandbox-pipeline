-- ============================================================================
-- sheets-bigquery-sandbox-pipeline
-- Arquivo: src/sql/06_audit_example.sql
-- Finalidade: auditar a integridade do pipeline SQL sintético.
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
--   2. carregue os dois arquivos CSV sintéticos;
--   3. execute src/sql/02_clean_example.sql;
--   4. execute src/sql/03_rules_example.sql;
--   5. execute src/sql/04_indicators_example.sql;
--   6. execute src/sql/05_exceptions_example.sql.
--
-- OBJETO CRIADO
--
--   vw_audit_example
--
-- OBJETIVO
--
-- A view consolida verificações de:
--
--   1. contagem raw;
--   2. contagem clean;
--   3. contagem rules;
--   4. preservação das linhas;
--   5. deduplicação;
--   6. decomposição das classificações;
--   7. indicador geral;
--   8. divergências;
--   9. exceções;
--  10. existência dos objetos;
--  11. expiração;
--  12. labels.
--
-- RESULTADO ESPERADO
--
-- Todas as verificações devem apresentar:
--
--   check_passed = TRUE
--   check_status = OK
--
-- SEGURANÇA
--
-- Este script:
--
--   1. executa somente consultas sobre dados sintéticos;
--   2. não acessa produção;
--   3. não publica em planilhas;
--   4. não cria gatilhos;
--   5. não contém credenciais;
--   6. não executa DML;
--   7. não remove objetos;
--   8. configura expiração de 59 dias.
-- ============================================================================

CREATE OR REPLACE VIEW
  `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.vw_audit_example`
OPTIONS (
  expiration_timestamp = TIMESTAMP_ADD(
    CURRENT_TIMESTAMP(),
    INTERVAL 59 DAY
  ),
  description = 'Auditoria consolidada da integridade do pipeline SQL sintético.',
  labels = [
    ('environment', 'sandbox'),
    ('layer', 'audit'),
    ('category', 'synthetic_integrity'),
    ('retention', '59_days')
  ]
)
AS

WITH raw_metrics AS (
  SELECT
    (
      SELECT COUNT(*)
      FROM
        `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.raw_input_example`
    ) AS raw_input_rows,

    (
      SELECT COUNT(*)
      FROM
        `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.raw_team_example`
    ) AS raw_team_rows
),

clean_metrics AS (
  SELECT
    COUNT(*) AS clean_rows,

    COUNTIF(
      is_selected_business_record
    ) AS selected_business_rows,

    COUNTIF(
      is_in_duplicate_group
    ) AS rows_in_duplicate_groups,

    COUNTIF(
      is_excess_duplicate
    ) AS excess_duplicate_rows

  FROM
    `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.clean_records_example`
),

rules_metrics AS (
  SELECT
    COUNT(*) AS rules_rows,

    COUNTIF(
      primary_classification = 'VALID'
    ) AS valid_records,

    COUNTIF(
      primary_classification = 'DIVERGENCE'
    ) AS divergence_records,

    COUNTIF(
      primary_classification = 'EXCEPTION'
    ) AS exception_records,

    COUNTIF(
      primary_classification = 'DUPLICATE'
    ) AS duplicate_records,

    COUNTIF(
      primary_classification = 'OUT_OF_WINDOW'
    ) AS out_of_window_records

  FROM
    `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.rules_records_example`
),

indicator_metrics AS (
  SELECT
    COUNT(*) AS overall_indicator_rows,
    COALESCE(MAX(total_records), 0) AS total_records,
    COALESCE(MAX(valid_records), 0) AS valid_records,
    COALESCE(MAX(divergence_records), 0) AS divergence_records,
    COALESCE(MAX(converted_records), 0) AS converted_records,
    COALESCE(MAX(total_attempts), 0) AS total_attempts,
    COALESCE(MAX(total_estimated_value), 0) AS total_estimated_value

  FROM
    `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.vw_indicators_example`

  WHERE
    indicator_level = 'OVERALL'
),

divergence_metrics AS (
  SELECT
    COUNT(DISTINCT source_row_id) AS distinct_divergence_records,
    COUNT(*) AS divergence_occurrences

  FROM
    `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.vw_divergences_example`
),

exception_metrics AS (
  SELECT
    COUNT(DISTINCT source_row_id) AS distinct_exception_records,
    COUNT(*) AS exception_occurrences

  FROM
    `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.vw_exceptions_example`
),

required_objects AS (
  SELECT
    object_name
  FROM
    UNNEST(
      [
        'raw_input_example',
        'raw_team_example',
        'clean_records_example',
        'rules_records_example',
        'vw_indicators_example',
        'vw_divergences_example',
        'vw_exceptions_example'
      ]
    ) AS object_name
),

object_inventory AS (
  SELECT
    COUNTIF(
      table_information.table_name IS NOT NULL
    ) AS required_objects_found,

    COUNTIF(
      table_information.expiration_time IS NOT NULL
    ) AS required_objects_with_expiration,

    COUNTIF(
      table_information.expiration_time IS NOT NULL
      AND table_information.expiration_time <= TIMESTAMP_ADD(
        CURRENT_TIMESTAMP(),
        INTERVAL 59 DAY
      )
    ) AS required_objects_within_retention

  FROM
    required_objects

  LEFT JOIN
    `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.INFORMATION_SCHEMA.TABLES`
    AS table_information

  ON
    required_objects.object_name = table_information.table_name
),

label_inventory AS (
  SELECT
    COUNT(DISTINCT required_objects.object_name)
      AS required_objects_with_labels

  FROM
    required_objects

  INNER JOIN
    `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.INFORMATION_SCHEMA.TABLE_OPTIONS`
    AS table_options

  ON
    required_objects.object_name = table_options.table_name
    AND table_options.option_name = 'labels'
),

checks AS (
  -- ========================================================================
  -- RAW
  -- ========================================================================

  SELECT
    1 AS check_order,
    'RAW_INPUT_COUNT' AS check_id,
    'RAW' AS check_group,
    'A tabela raw principal deve possuir 24 registros.' AS check_description,
    CAST(raw_input_rows AS STRING) AS actual_value,
    '24' AS expected_value,
    raw_input_rows = 24 AS check_passed,
    'BLOCKING' AS failure_severity
  FROM
    raw_metrics

  UNION ALL

  SELECT
    2,
    'RAW_TEAM_COUNT',
    'RAW',
    'A referência raw de equipes deve possuir 4 registros.',
    CAST(raw_team_rows AS STRING),
    '4',
    raw_team_rows = 4,
    'BLOCKING'
  FROM
    raw_metrics

  -- ========================================================================
  -- CLEAN
  -- ========================================================================

  UNION ALL

  SELECT
    3,
    'CLEAN_COUNT',
    'CLEAN',
    'A camada clean deve preservar os 24 registros raw.',
    CAST(clean_rows AS STRING),
    '24',
    clean_rows = 24,
    'BLOCKING'
  FROM
    clean_metrics

  UNION ALL

  SELECT
    4,
    'RULES_COUNT',
    'RULES',
    'A camada rules deve preservar os 24 registros clean.',
    CAST(rules_rows AS STRING),
    '24',
    rules_rows = 24,
    'BLOCKING'
  FROM
    rules_metrics

  UNION ALL

  SELECT
    5,
    'RAW_CLEAN_PARITY',
    'PARITY',
    'A contagem raw deve ser igual à contagem clean.',
    CONCAT(
      CAST(raw_input_rows AS STRING),
      ':',
      CAST(clean_rows AS STRING)
    ),
    '24:24',
    raw_input_rows = clean_rows,
    'BLOCKING'
  FROM
    raw_metrics
  CROSS JOIN
    clean_metrics

  UNION ALL

  SELECT
    6,
    'CLEAN_RULES_PARITY',
    'PARITY',
    'A contagem clean deve ser igual à contagem rules.',
    CONCAT(
      CAST(clean_rows AS STRING),
      ':',
      CAST(rules_rows AS STRING)
    ),
    '24:24',
    clean_rows = rules_rows,
    'BLOCKING'
  FROM
    clean_metrics
  CROSS JOIN
    rules_metrics

  -- ========================================================================
  -- DEDUPLICAÇÃO
  -- ========================================================================

  UNION ALL

  SELECT
    7,
    'SELECTED_BUSINESS_COUNT',
    'DEDUPLICATION',
    'A deduplicação deve selecionar 23 registros de negócio.',
    CAST(selected_business_rows AS STRING),
    '23',
    selected_business_rows = 23,
    'BLOCKING'
  FROM
    clean_metrics

  UNION ALL

  SELECT
    8,
    'DUPLICATE_GROUP_ROWS',
    'DEDUPLICATION',
    'Duas linhas devem fazer parte do grupo duplicado.',
    CAST(rows_in_duplicate_groups AS STRING),
    '2',
    rows_in_duplicate_groups = 2,
    'BLOCKING'
  FROM
    clean_metrics

  UNION ALL

  SELECT
    9,
    'EXCESS_DUPLICATE_COUNT',
    'DEDUPLICATION',
    'Uma linha deve ser classificada como duplicidade excedente.',
    CAST(excess_duplicate_rows AS STRING),
    '1',
    excess_duplicate_rows = 1,
    'BLOCKING'
  FROM
    clean_metrics

  -- ========================================================================
  -- CLASSIFICAÇÕES
  -- ========================================================================

  UNION ALL

  SELECT
    10,
    'VALID_COUNT',
    'CLASSIFICATION',
    'A camada rules deve possuir 8 registros válidos.',
    CAST(valid_records AS STRING),
    '8',
    valid_records = 8,
    'BLOCKING'
  FROM
    rules_metrics

  UNION ALL

  SELECT
    11,
    'DIVERGENCE_COUNT',
    'CLASSIFICATION',
    'A camada rules deve possuir 3 registros com divergência.',
    CAST(divergence_records AS STRING),
    '3',
    divergence_records = 3,
    'BLOCKING'
  FROM
    rules_metrics

  UNION ALL

  SELECT
    12,
    'EXCEPTION_COUNT',
    'CLASSIFICATION',
    'A camada rules deve possuir 11 registros com exceção.',
    CAST(exception_records AS STRING),
    '11',
    exception_records = 11,
    'BLOCKING'
  FROM
    rules_metrics

  UNION ALL

  SELECT
    13,
    'DUPLICATE_COUNT',
    'CLASSIFICATION',
    'A camada rules deve possuir 1 registro duplicado excedente.',
    CAST(duplicate_records AS STRING),
    '1',
    duplicate_records = 1,
    'BLOCKING'
  FROM
    rules_metrics

  UNION ALL

  SELECT
    14,
    'OUT_OF_WINDOW_COUNT',
    'CLASSIFICATION',
    'A camada rules deve possuir 1 registro fora da janela.',
    CAST(out_of_window_records AS STRING),
    '1',
    out_of_window_records = 1,
    'BLOCKING'
  FROM
    rules_metrics

  UNION ALL

  SELECT
    15,
    'CLASSIFICATION_DECOMPOSITION',
    'CLASSIFICATION',
    'A soma das classificações deve ser igual ao total da camada rules.',
    CAST(
      valid_records
      + divergence_records
      + exception_records
      + duplicate_records
      + out_of_window_records
      AS STRING
    ),
    CAST(rules_rows AS STRING),
    rules_rows = (
      valid_records
      + divergence_records
      + exception_records
      + duplicate_records
      + out_of_window_records
    ),
    'BLOCKING'
  FROM
    rules_metrics

  -- ========================================================================
  -- INDICADORES
  -- ========================================================================

  UNION ALL

  SELECT
    16,
    'OVERALL_INDICATOR_ROW',
    'INDICATORS',
    'A view de indicadores deve possuir uma linha geral.',
    CAST(overall_indicator_rows AS STRING),
    '1',
    overall_indicator_rows = 1,
    'BLOCKING'
  FROM
    indicator_metrics

  UNION ALL

  SELECT
    17,
    'OVERALL_TOTAL_RECORDS',
    'INDICATORS',
    'O indicador geral deve possuir 11 registros analisáveis.',
    CAST(total_records AS STRING),
    '11',
    total_records = 11,
    'BLOCKING'
  FROM
    indicator_metrics

  UNION ALL

  SELECT
    18,
    'OVERALL_VALID_RECORDS',
    'INDICATORS',
    'O indicador geral deve possuir 8 registros válidos.',
    CAST(valid_records AS STRING),
    '8',
    valid_records = 8,
    'BLOCKING'
  FROM
    indicator_metrics

  UNION ALL

  SELECT
    19,
    'OVERALL_DIVERGENCE_RECORDS',
    'INDICATORS',
    'O indicador geral deve possuir 3 registros com divergência.',
    CAST(divergence_records AS STRING),
    '3',
    divergence_records = 3,
    'BLOCKING'
  FROM
    indicator_metrics

  UNION ALL

  SELECT
    20,
    'OVERALL_CONVERTED_RECORDS',
    'INDICATORS',
    'O indicador geral deve possuir 6 registros convertidos.',
    CAST(converted_records AS STRING),
    '6',
    converted_records = 6,
    'BLOCKING'
  FROM
    indicator_metrics

  UNION ALL

  SELECT
    21,
    'OVERALL_TOTAL_ATTEMPTS',
    'INDICATORS',
    'O indicador geral deve possuir 27 tentativas.',
    CAST(total_attempts AS STRING),
    '27',
    total_attempts = 27,
    'BLOCKING'
  FROM
    indicator_metrics

  UNION ALL

  SELECT
    22,
    'OVERALL_ESTIMATED_VALUE',
    'INDICATORS',
    'O valor estimado total deve ser 1535.00.',
    FORMAT(
      '%.2f',
      CAST(total_estimated_value AS FLOAT64)
    ),
    '1535.00',
    total_estimated_value = NUMERIC '1535.00',
    'BLOCKING'
  FROM
    indicator_metrics

  -- ========================================================================
  -- DIVERGÊNCIAS E EXCEÇÕES
  -- ========================================================================

  UNION ALL

  SELECT
    23,
    'DIVERGENCE_DISTINCT_RECORDS',
    'DIVERGENCES',
    'A view de divergências deve possuir 3 registros distintos.',
    CAST(distinct_divergence_records AS STRING),
    '3',
    distinct_divergence_records = 3,
    'BLOCKING'
  FROM
    divergence_metrics

  UNION ALL

  SELECT
    24,
    'DIVERGENCE_OCCURRENCES',
    'DIVERGENCES',
    'A view de divergências deve possuir 4 ocorrências.',
    CAST(divergence_occurrences AS STRING),
    '4',
    divergence_occurrences = 4,
    'BLOCKING'
  FROM
    divergence_metrics

  UNION ALL

  SELECT
    25,
    'EXCEPTION_DISTINCT_RECORDS',
    'EXCEPTIONS',
    'A view de exceções deve possuir 13 registros distintos.',
    CAST(distinct_exception_records AS STRING),
    '13',
    distinct_exception_records = 13,
    'BLOCKING'
  FROM
    exception_metrics

  UNION ALL

  SELECT
    26,
    'EXCEPTION_OCCURRENCES',
    'EXCEPTIONS',
    'A view de exceções deve possuir 14 ocorrências.',
    CAST(exception_occurrences AS STRING),
    '14',
    exception_occurrences = 14,
    'BLOCKING'
  FROM
    exception_metrics

  -- ========================================================================
  -- OBJETOS
  -- ========================================================================

  UNION ALL

  SELECT
    27,
    'REQUIRED_OBJECTS_FOUND',
    'OBJECTS',
    'Os 7 objetos obrigatórios anteriores à auditoria devem existir.',
    CAST(required_objects_found AS STRING),
    '7',
    required_objects_found = 7,
    'BLOCKING'
  FROM
    object_inventory

  UNION ALL

  SELECT
    28,
    'REQUIRED_OBJECTS_WITH_EXPIRATION',
    'OBJECTS',
    'Os 7 objetos obrigatórios devem possuir expiração.',
    CAST(required_objects_with_expiration AS STRING),
    '7',
    required_objects_with_expiration = 7,
    'BLOCKING'
  FROM
    object_inventory

  UNION ALL

  SELECT
    29,
    'REQUIRED_OBJECTS_WITHIN_RETENTION',
    'OBJECTS',
    'Os 7 objetos obrigatórios devem respeitar a retenção de 59 dias.',
    CAST(required_objects_within_retention AS STRING),
    '7',
    required_objects_within_retention = 7,
    'BLOCKING'
  FROM
    object_inventory

  UNION ALL

  SELECT
    30,
    'REQUIRED_OBJECTS_WITH_LABELS',
    'OBJECTS',
    'Os 7 objetos obrigatórios devem possuir labels.',
    CAST(required_objects_with_labels AS STRING),
    '7',
    required_objects_with_labels = 7,
    'BLOCKING'
  FROM
    label_inventory
)

SELECT
  check_order,
  check_id,
  check_group,
  check_description,
  actual_value,
  expected_value,
  check_passed,

  CASE
    WHEN check_passed THEN 'OK'
    ELSE failure_severity
  END AS check_status

FROM
  checks;

-- ============================================================================
-- VERIFICAÇÃO 1 — RESULTADO COMPLETO DA AUDITORIA
-- ============================================================================

SELECT
  check_order,
  check_id,
  check_group,
  check_description,
  actual_value,
  expected_value,
  check_passed,
  check_status
FROM
  `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.vw_audit_example`
ORDER BY
  check_order;

-- ============================================================================
-- VERIFICAÇÃO 2 — PARECER GERAL
-- ============================================================================
--
-- Resultado esperado:
--
--   total_checks   = 30
--   passed_checks  = 30
--   failed_checks  = 0
--   audit_verdict  = INTEGRITY_APPROVED
-- ============================================================================

SELECT
  COUNT(*) AS total_checks,

  COUNTIF(
    check_passed
  ) AS passed_checks,

  COUNTIF(
    NOT check_passed
  ) AS failed_checks,

  CASE
    WHEN COUNTIF(NOT check_passed) = 0
      THEN 'INTEGRITY_APPROVED'
    ELSE 'INTEGRITY_BLOCKED'
  END AS audit_verdict

FROM
  `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.vw_audit_example`;

-- ============================================================================
-- VERIFICAÇÃO 3 — SOMENTE CHECKS REPROVADOS
-- ============================================================================
--
-- Resultado esperado:
--
--   zero linhas
-- ============================================================================

SELECT
  check_order,
  check_id,
  check_group,
  check_description,
  actual_value,
  expected_value,
  check_status
FROM
  `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.vw_audit_example`
WHERE
  NOT check_passed
ORDER BY
  check_order;

-- ============================================================================
-- VERIFICAÇÃO 4 — RESUMO POR GRUPO
-- ============================================================================

SELECT
  check_group,
  COUNT(*) AS total_checks,
  COUNTIF(check_passed) AS passed_checks,
  COUNTIF(NOT check_passed) AS failed_checks,

  CASE
    WHEN COUNTIF(NOT check_passed) = 0
      THEN 'APPROVED'
    ELSE 'BLOCKED'
  END AS group_verdict

FROM
  `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.vw_audit_example`

GROUP BY
  check_group

ORDER BY
  check_group;

-- ============================================================================
-- VERIFICAÇÃO 5 — EXISTÊNCIA DOS OITO OBJETOS FINAIS
-- ============================================================================
--
-- Após a criação da auditoria, o exemplo deve possuir:
--
--   1. raw_input_example
--   2. raw_team_example
--   3. clean_records_example
--   4. rules_records_example
--   5. vw_indicators_example
--   6. vw_divergences_example
--   7. vw_exceptions_example
--   8. vw_audit_example
-- ============================================================================

SELECT
  table_name,
  table_type,
  creation_time,
  expiration_time
FROM
  `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.INFORMATION_SCHEMA.TABLES`
WHERE
  table_name IN (
    'raw_input_example',
    'raw_team_example',
    'clean_records_example',
    'rules_records_example',
    'vw_indicators_example',
    'vw_divergences_example',
    'vw_exceptions_example',
    'vw_audit_example'
  )
ORDER BY
  table_name;

-- ============================================================================
-- VERIFICAÇÃO 6 — EXPIRAÇÃO E LABELS DA AUDITORIA
-- ============================================================================

SELECT
  table_name,
  option_name,
  option_value
FROM
  `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.INFORMATION_SCHEMA.TABLE_OPTIONS`
WHERE
  table_name = 'vw_audit_example'
  AND option_name IN (
    'description',
    'expiration_timestamp',
    'labels'
  )
ORDER BY
  option_name;
