-- ============================================================================
-- sheets-bigquery-sandbox-pipeline
-- Arquivo: src/sql/01_raw_example.sql
-- Finalidade: criar o dataset e as tabelas raw do exemplo sintético.
-- Dialeto: GoogleSQL
-- Ambiente: BigQuery Sandbox
-- Projeto: sheets-bq-sandbox-pipeline
-- Dataset: sandbox_pipeline_example
-- Região: US
-- ============================================================================
--
-- SEGURANÇA
--
-- Este script:
--   1. cria somente objetos do projeto sintético;
--   2. não acessa o ambiente original;
--   3. não utiliza dados de produção;
--   4. não habilita faturamento;
--   5. não cria gatilhos;
--   6. não executa publicação em planilhas;
--   7. não utiliza DML;
--   8. configura expiração de 59 dias.
--
-- IMPORTANTE
--
-- O projeto sheets-bq-sandbox-pipeline precisa existir no Google Cloud antes
-- da execução deste script.
--
-- Os arquivos CSV devem ser carregados posteriormente por jobs de carga:
--
--   examples/synthetic-data/input-example.csv
--   examples/synthetic-data/team-example.csv
--
-- Todos os campos raw são STRING para preservar valores inválidos e permitir
-- que a camada clean faça conversões seguras.
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS
  `sheets-bq-sandbox-pipeline.sandbox_pipeline_example`
OPTIONS (
  location = 'US',
  default_table_expiration_days = 59,
  description = 'Dataset sintético do estudo sheets-bigquery-sandbox-pipeline.',
  labels = [
    ('environment', 'sandbox'),
    ('purpose', 'synthetic_example'),
    ('repository', 'sheets_bq_sandbox_pipeline')
  ]
);

-- ============================================================================
-- TABELA RAW PRINCIPAL
-- ============================================================================
--
-- Origem esperada:
--   examples/synthetic-data/input-example.csv
--
-- Quantidade esperada após a carga:
--   24 registros
--
-- A tabela é criada vazia. O CSV deve ser carregado posteriormente usando um
-- job de carga do BigQuery com a opção de anexar dados à tabela existente.
-- ============================================================================

CREATE TABLE IF NOT EXISTS
  `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.raw_input_example`
(
  source_row_id STRING OPTIONS (
    description = 'Identificador sintético da linha de origem.'
  ),
  record_id STRING OPTIONS (
    description = 'Identificador sintético de negócio.'
  ),
  event_date STRING OPTIONS (
    description = 'Data do evento preservada como texto na camada raw.'
  ),
  team_code STRING OPTIONS (
    description = 'Código sintético da equipe.'
  ),
  agent_code STRING OPTIONS (
    description = 'Código sintético do agente.'
  ),
  channel STRING OPTIONS (
    description = 'Canal de entrada preservado como texto.'
  ),
  campaign STRING OPTIONS (
    description = 'Campanha sintética.'
  ),
  status STRING OPTIONS (
    description = 'Status operacional preservado como texto.'
  ),
  attempts STRING OPTIONS (
    description = 'Quantidade de tentativas preservada como texto.'
  ),
  converted STRING OPTIONS (
    description = 'Indicador de conversão preservado como texto.'
  ),
  estimated_value STRING OPTIONS (
    description = 'Valor estimado preservado como texto.'
  ),
  source_updated_at STRING OPTIONS (
    description = 'Horário de atualização preservado como texto.'
  )
)
OPTIONS (
  expiration_timestamp = TIMESTAMP_ADD(
    CURRENT_TIMESTAMP(),
    INTERVAL 59 DAY
  ),
  description = 'Dados sintéticos raw carregados a partir de input-example.csv.',
  labels = [
    ('environment', 'sandbox'),
    ('layer', 'raw'),
    ('category', 'synthetic_input'),
    ('retention', '59_days')
  ]
);

-- ============================================================================
-- TABELA RAW DE EQUIPES
-- ============================================================================
--
-- Origem esperada:
--   examples/synthetic-data/team-example.csv
--
-- Quantidade esperada após a carga:
--   4 registros
--
-- A tabela é criada vazia. O CSV deve ser carregado posteriormente usando um
-- job de carga do BigQuery com a opção de anexar dados à tabela existente.
-- ============================================================================

CREATE TABLE IF NOT EXISTS
  `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.raw_team_example`
(
  team_code STRING OPTIONS (
    description = 'Código sintético da equipe.'
  ),
  team_name STRING OPTIONS (
    description = 'Nome fictício da equipe.'
  ),
  group_code STRING OPTIONS (
    description = 'Código sintético do agrupamento.'
  ),
  active STRING OPTIONS (
    description = 'Indicador de atividade preservado como texto.'
  ),
  daily_capacity_reference STRING OPTIONS (
    description = 'Capacidade diária preservada como texto.'
  ),
  valid_from STRING OPTIONS (
    description = 'Início da validade preservado como texto.'
  ),
  valid_to STRING OPTIONS (
    description = 'Fim da validade preservado como texto.'
  )
)
OPTIONS (
  expiration_timestamp = TIMESTAMP_ADD(
    CURRENT_TIMESTAMP(),
    INTERVAL 59 DAY
  ),
  description = 'Referência sintética raw carregada a partir de team-example.csv.',
  labels = [
    ('environment', 'sandbox'),
    ('layer', 'raw'),
    ('category', 'synthetic_reference'),
    ('retention', '59_days')
  ]
);

-- ============================================================================
-- VERIFICAÇÃO DO SCHEMA
-- ============================================================================
--
-- Esta consulta é somente leitura.
--
-- Resultado esperado:
--   raw_input_example com 12 colunas STRING;
--   raw_team_example com 7 colunas STRING.
-- ============================================================================

SELECT
  table_name,
  column_name,
  data_type,
  is_nullable,
  ordinal_position
FROM
  `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.INFORMATION_SCHEMA.COLUMNS`
WHERE
  table_name IN (
    'raw_input_example',
    'raw_team_example'
  )
ORDER BY
  table_name,
  ordinal_position;

-- ============================================================================
-- VERIFICAÇÃO DAS CONTAGENS
-- ============================================================================
--
-- Antes da carga dos CSVs:
--   raw_input_example = 0
--   raw_team_example = 0
--
-- Depois da carga dos CSVs:
--   raw_input_example = 24
--   raw_team_example = 4
--
-- A consulta não bloqueia a execução. Ela apenas apresenta as contagens.
-- ============================================================================

SELECT
  'raw_input_example' AS table_name,
  COUNT(*) AS actual_rows,
  24 AS expected_rows,
  COUNT(*) = 24 AS expected_count_reached
FROM
  `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.raw_input_example`

UNION ALL

SELECT
  'raw_team_example' AS table_name,
  COUNT(*) AS actual_rows,
  4 AS expected_rows,
  COUNT(*) = 4 AS expected_count_reached
FROM
  `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.raw_team_example`;

-- ============================================================================
-- VERIFICAÇÃO DA EXPIRAÇÃO
-- ============================================================================
--
-- Esta consulta confirma que as tabelas possuem expiração e que o prazo não
-- ultrapassa a retenção configurada para o exemplo.
-- ============================================================================

SELECT
  table_name,
  creation_time,
  expiration_time,
  TIMESTAMP_DIFF(
    expiration_time,
    CURRENT_TIMESTAMP(),
    DAY
  ) AS remaining_retention_days,
  expiration_time IS NOT NULL AS expiration_configured,
  expiration_time <= TIMESTAMP_ADD(
    CURRENT_TIMESTAMP(),
    INTERVAL 59 DAY
  ) AS within_sandbox_retention
FROM
  `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.INFORMATION_SCHEMA.TABLES`
WHERE
  table_name IN (
    'raw_input_example',
    'raw_team_example'
  )
ORDER BY
  table_name;

-- ============================================================================
-- VERIFICAÇÃO DOS LABELS
-- ============================================================================
--
-- Esta consulta apresenta os labels configurados nas tabelas raw.
-- ============================================================================

SELECT
  table_name,
  option_name,
  option_value
FROM
  `sheets-bq-sandbox-pipeline.sandbox_pipeline_example.INFORMATION_SCHEMA.TABLE_OPTIONS`
WHERE
  table_name IN (
    'raw_input_example',
    'raw_team_example'
  )
  AND option_name IN (
    'labels',
    'expiration_timestamp',
    'description'
  )
ORDER BY
  table_name,
  option_name;
