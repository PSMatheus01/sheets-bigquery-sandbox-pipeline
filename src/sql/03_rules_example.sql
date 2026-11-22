-- ============================================================================
-- sheets-bigquery-sandbox-pipeline
-- Arquivo: src/sql/03_rules_example.sql
-- Finalidade: aplicar regras de qualidade e negócio sobre a camada clean.
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
--   4. confirme 24 registros em clean_records_example.
--
-- CLASSIFICAÇÕES PRINCIPAIS
--
-- Cada linha recebe exatamente uma classificação principal:
--
--   VALID
--   DIVERGENCE
--   EXCEPTION
--   DUPLICATE
--   OUT_OF_WINDOW
--
-- PRECEDÊNCIA
--
-- Quando uma linha atende a mais de uma condição, a classificação principal
-- segue esta ordem:
--
--   1. DUPLICATE
--   2. OUT_OF_WINDOW
--   3. EXCEPTION
--   4. DIVERGENCE
--   5. VALID
--
-- A classificação principal não elimina as causas específicas.
--
-- Cada linha mantém:
--
--   exception_issue_codes
--   divergence_issue_codes
--   clean_issue_codes
--
-- SEGURANÇA
--
-- Este script:
--
--   1. lê somente a camada clean sintética;
--   2. não altera as tabelas raw;
--   3. não acessa produção;
--   4. não publica em planilhas;
--   5. não cria gatilhos;
--   6. não executa DML;
--   7. configura expiração de 59 dias;
--   8. preserva todas as 24 linhas.
-- ============================================================================

CREATE OR REPLACE TABLE
  `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.rules_records_example`
OPTIONS (
  expiration_timestamp = TIMESTAMP_ADD(
    CURRENT_TIMESTAMP(),
    INTERVAL 59 DAY
  ),
  description = 'Camada sintética de regras com classificações, divergências, exceções, duplicidades e registros fora da janela.',
  labels = [
    ('environment', 'sandbox'),
    ('layer', 'rules'),
    ('category', 'synthetic_classification'),
    ('retention', '59_days')
  ]
)
AS

WITH rule_evaluation AS (
  SELECT
    clean_records.*,

    ARRAY_CONCAT(
      ARRAY(
        SELECT issue_code
        FROM UNNEST(clean_issue_codes) AS issue_code
        WHERE issue_code NOT IN (
          'EXCESS_DUPLICATE',
          'OUT_OF_REFERENCE_WINDOW'
        )
      ),

      ARRAY(
        SELECT issue_code
        FROM UNNEST(
          [
            IF(
              status IS NOT NULL
              AND status NOT IN (
                'NEW',
                'IN_PROGRESS',
                'COMPLETED',
                'CANCELLED'
              ),
              'UNKNOWN_STATUS',
              NULL
            ),

            IF(
              channel IS NOT NULL
              AND channel NOT IN (
                'WHATSAPP',
                'WEB',
                'PHONE',
                'PARTNER'
              ),
              'UNKNOWN_CHANNEL',
              NULL
            ),

            IF(
              campaign IS NOT NULL
              AND campaign NOT IN (
                'CAMP_ALPHA',
                'CAMP_BETA',
                'CAMP_GAMMA'
              ),
              'UNKNOWN_CAMPAIGN',
              NULL
            ),

            IF(
              attempts IS NOT NULL
              AND attempts < 0,
              'NEGATIVE_ATTEMPTS',
              NULL
            ),

            IF(
              estimated_value IS NOT NULL
              AND estimated_value < 0,
              'NEGATIVE_ESTIMATED_VALUE',
              NULL
            )
          ]
        ) AS issue_code
        WHERE issue_code IS NOT NULL
      )
    ) AS exception_issue_codes,

    ARRAY(
      SELECT issue_code
      FROM UNNEST(
        [
          IF(
            status = 'COMPLETED'
            AND converted IS FALSE,
            'COMPLETED_WITHOUT_CONVERSION',
            NULL
          ),

          IF(
            status IS NOT NULL
            AND status != 'COMPLETED'
            AND converted IS TRUE,
            'CONVERTED_WITHOUT_COMPLETED_STATUS',
            NULL
          ),

          IF(
            status = 'CANCELLED'
            AND converted IS TRUE,
            'CANCELLED_WITH_CONVERSION',
            NULL
          )
        ]
      ) AS issue_code
      WHERE issue_code IS NOT NULL
    ) AS divergence_issue_codes

  FROM
    `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.clean_records_example`
),

classification_flags AS (
  SELECT
    rule_evaluation.*,

    ARRAY_LENGTH(exception_issue_codes) > 0 AS has_exception,
    ARRAY_LENGTH(divergence_issue_codes) > 0 AS has_divergence,

    is_excess_duplicate AS has_duplicate,

    is_event_date_valid
      AND NOT is_within_reference_window AS is_out_of_window,

    is_selected_business_record
      AND is_within_reference_window
      AND ARRAY_LENGTH(exception_issue_codes) = 0
      AS eligible_for_business_analysis,

    is_selected_business_record
      AND is_within_reference_window
      AND ARRAY_LENGTH(exception_issue_codes) = 0
      AND ARRAY_LENGTH(divergence_issue_codes) = 0
      AS eligible_for_valid_indicators

  FROM
    rule_evaluation
),

classified_records AS (
  SELECT
    classification_flags.*,

    CASE
      WHEN has_duplicate THEN 'DUPLICATE'
      WHEN is_out_of_window THEN 'OUT_OF_WINDOW'
      WHEN has_exception THEN 'EXCEPTION'
      WHEN has_divergence THEN 'DIVERGENCE'
      ELSE 'VALID'
    END AS primary_classification

  FROM
    classification_flags
)

SELECT
  classified_records.*,

  primary_classification = 'VALID' AS is_valid,
  primary_classification = 'DIVERGENCE' AS is_divergence,
  primary_classification = 'EXCEPTION' AS is_exception,
  primary_classification = 'DUPLICATE' AS is_duplicate,
  primary_classification = 'OUT_OF_WINDOW' AS is_outside_window,

  ARRAY_CONCAT(
    clean_issue_codes,
    exception_issue_codes,
    divergence_issue_codes
  ) AS all_issue_codes

FROM
  classified_records;

-- ============================================================================
-- VERIFICAÇÃO 1 — CONTAGEM CLEAN E RULES
-- ============================================================================
--
-- Resultado esperado:
--
--   clean_rows = 24
--   rules_rows = 24
--
-- Nenhuma linha deve ser removida nesta etapa.
-- ============================================================================

SELECT
  (
    SELECT COUNT(*)
    FROM
      `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.clean_records_example`
  ) AS clean_rows,

  (
    SELECT COUNT(*)
    FROM
      `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.rules_records_example`
  ) AS rules_rows,

  (
    SELECT COUNT(*)
    FROM
      `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.clean_records_example`
  )
  =
  (
    SELECT COUNT(*)
    FROM
      `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.rules_records_example`
  ) AS clean_equals_rules;

-- ============================================================================
-- VERIFICAÇÃO 2 — DISTRIBUIÇÃO DAS CLASSIFICAÇÕES
-- ============================================================================
--
-- Resultado esperado para os dados sintéticos:
--
--   VALID          = 8
--   DIVERGENCE     = 3
--   EXCEPTION      = 11
--   DUPLICATE      = 1
--   OUT_OF_WINDOW  = 1
--
-- Total = 24
-- ============================================================================

SELECT
  primary_classification,
  COUNT(*) AS total_records
FROM
  `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.rules_records_example`
GROUP BY
  primary_classification
ORDER BY
  CASE primary_classification
    WHEN 'VALID' THEN 1
    WHEN 'DIVERGENCE' THEN 2
    WHEN 'EXCEPTION' THEN 3
    WHEN 'DUPLICATE' THEN 4
    WHEN 'OUT_OF_WINDOW' THEN 5
    ELSE 6
  END;

-- ============================================================================
-- VERIFICAÇÃO 3 — DECOMPOSIÇÃO INTEGRAL
-- ============================================================================
--
-- O total da tabela rules deve ser igual à soma das cinco classificações.
-- ============================================================================

SELECT
  COUNT(*) AS total_records,
  COUNTIF(is_valid) AS valid_records,
  COUNTIF(is_divergence) AS divergence_records,
  COUNTIF(is_exception) AS exception_records,
  COUNTIF(is_duplicate) AS duplicate_records,
  COUNTIF(is_outside_window) AS out_of_window_records,

  COUNT(*) = (
    COUNTIF(is_valid)
    + COUNTIF(is_divergence)
    + COUNTIF(is_exception)
    + COUNTIF(is_duplicate)
    + COUNTIF(is_outside_window)
  ) AS classification_decomposition_valid

FROM
  `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.rules_records_example`;

-- ============================================================================
-- VERIFICAÇÃO 4 — REGISTROS VÁLIDOS
-- ============================================================================
--
-- Resultado esperado:
--
--   SRC001
--   SRC002
--   SRC003
--   SRC004
--   SRC009
--   SRC016
--   SRC021
--   SRC023
-- ============================================================================

SELECT
  source_row_id,
  record_id,
  event_date,
  team_code,
  status,
  converted,
  primary_classification
FROM
  `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.rules_records_example`
WHERE
  primary_classification = 'VALID'
ORDER BY
  source_row_id;

-- ============================================================================
-- VERIFICAÇÃO 5 — DIVERGÊNCIAS
-- ============================================================================
--
-- Resultado esperado:
--
--   SRC010 = COMPLETED_WITHOUT_CONVERSION
--   SRC011 = CONVERTED_WITHOUT_COMPLETED_STATUS
--   SRC020 = CONVERTED_WITHOUT_COMPLETED_STATUS
--            CANCELLED_WITH_CONVERSION
-- ============================================================================

SELECT
  source_row_id,
  record_id,
  status,
  converted,
  divergence_issue_codes,
  primary_classification
FROM
  `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.rules_records_example`
WHERE
  primary_classification = 'DIVERGENCE'
ORDER BY
  source_row_id;

-- ============================================================================
-- VERIFICAÇÃO 6 — EXCEÇÕES
-- ============================================================================
--
-- Resultado esperado:
--
--   SRC005
--   SRC006
--   SRC007
--   SRC008
--   SRC012
--   SRC014
--   SRC017
--   SRC018
--   SRC019
--   SRC022
--   SRC024
-- ============================================================================

SELECT
  source_row_id,
  record_id,
  exception_issue_codes,
  primary_classification
FROM
  `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.rules_records_example`
WHERE
  primary_classification = 'EXCEPTION'
ORDER BY
  source_row_id;

-- ============================================================================
-- VERIFICAÇÃO 7 — DUPLICIDADE
-- ============================================================================
--
-- Resultado esperado:
--
--   SRC015 = DUPLICATE
--   SRC016 = VALID
--
-- SRC016 possui o source_updated_at mais recente.
-- ============================================================================

SELECT
  source_row_id,
  record_id,
  source_updated_at,
  duplicate_count,
  duplicate_rank,
  is_selected_business_record,
  is_duplicate,
  primary_classification
FROM
  `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.rules_records_example`
WHERE
  is_in_duplicate_group
ORDER BY
  record_id,
  duplicate_rank;

-- ============================================================================
-- VERIFICAÇÃO 8 — FORA DA JANELA
-- ============================================================================
--
-- Resultado esperado:
--
--   SRC013 = OUT_OF_WINDOW
-- ============================================================================

SELECT
  source_row_id,
  record_id,
  event_date,
  is_within_reference_window,
  primary_classification
FROM
  `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.rules_records_example`
WHERE
  primary_classification = 'OUT_OF_WINDOW'
ORDER BY
  source_row_id;

-- ============================================================================
-- VERIFICAÇÃO 9 — CONTAGEM POR CÓDIGO DE EXCEÇÃO
-- ============================================================================

SELECT
  issue_code,
  COUNT(*) AS affected_records
FROM
  `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.rules_records_example`,
  UNNEST(exception_issue_codes) AS issue_code
GROUP BY
  issue_code
ORDER BY
  affected_records DESC,
  issue_code;

-- ============================================================================
-- VERIFICAÇÃO 10 — CONTAGEM POR CÓDIGO DE DIVERGÊNCIA
-- ============================================================================

SELECT
  issue_code,
  COUNT(*) AS affected_records
FROM
  `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.rules_records_example`,
  UNNEST(divergence_issue_codes) AS issue_code
GROUP BY
  issue_code
ORDER BY
  affected_records DESC,
  issue_code;

-- ============================================================================
-- VERIFICAÇÃO 11 — ELEGIBILIDADE
-- ============================================================================
--
-- eligible_for_business_analysis:
--
--   selecionado pela deduplicação;
--   dentro da janela;
--   sem exceção técnica ou de qualidade.
--
-- eligible_for_valid_indicators:
--
--   atende aos critérios anteriores;
--   não possui divergência de negócio.
-- ============================================================================

SELECT
  COUNTIF(eligible_for_business_analysis) AS business_analysis_records,
  COUNTIF(eligible_for_valid_indicators) AS valid_indicator_records,
  COUNTIF(
    eligible_for_business_analysis
    AND has_divergence
  ) AS business_divergence_records
FROM
  `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.rules_records_example`;

-- ============================================================================
-- VERIFICAÇÃO 12 — EXPIRAÇÃO E LABELS
-- ============================================================================

SELECT
  table_name,
  option_name,
  option_value
FROM
  `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.INFORMATION_SCHEMA.TABLE_OPTIONS`
WHERE
  table_name = 'rules_records_example'
  AND option_name IN (
    'description',
    'expiration_timestamp',
    'labels'
  )
ORDER BY
  option_name;
