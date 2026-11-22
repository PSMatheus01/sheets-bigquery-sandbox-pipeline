# Histórico de alterações

Este documento registra as alterações relevantes do repositório `sheets-bigquery-sandbox-pipeline`.

O formato segue uma estrutura baseada em categorias de alteração. As versões registradas representam o conteúdo disponibilizado no repositório e não a versão do ambiente operacional que originou o estudo.

---

## 0.1.0 — 2026-11-22

### Adicionado

#### Documentação principal

- `README.md`
- `SECURITY.md`
- `CONTRIBUTING.md`
- documentação da arquitetura;
- metodologia experimental;
- resultados consolidados;
- análise do BigQuery Sandbox e faturamento;
- incidentes e recuperação;
- casos de uso;
- guia de adaptação.

#### Arquitetura

- representação do estado observado;
- fluxo de dados experimental;
- pipeline validado;
- máquina de estados;
- separação entre origem, processamento, validação, publicação e auditoria.

#### Evidências

- resumo experimental sanitizado;
- resumo da baseline de fórmulas;
- resumo de performance e consumo;
- matriz de rastreabilidade dos testes.

#### Dados sintéticos

- conjunto principal com registros válidos e inconsistências intencionais;
- referência sintética de equipes;
- documentação dos dados;
- configuração de Sandbox;
- resultados esperados de indicadores;
- resultados esperados de divergências;
- resultados esperados de exceções.

#### Pipeline SQL

- criação da camada de entrada;
- limpeza e conversões seguras;
- deduplicação;
- aplicação de regras;
- classificação de registros;
- geração de indicadores;
- geração de divergências;
- geração de exceções;
- auditoria consolidada.

#### Apps Script

- configuração sanitizada;
- utilitários;
- detector de alteração;
- orquestrador manual;
- publicador opcional para destino sintético;
- auditor somente leitura.

#### Templates

- checklist de implementação;
- relatório de incidente;
- revisão de privacidade;
- avaliação de riscos;
- plano de testes.

### Validado

- pipeline experimental em ambiente isolado;
- processamento no BigQuery Sandbox;
- orquestração com Apps Script;
- produção mantida em somente leitura;
- validação por gerações candidatas;
- backup antes da promoção;
- falha preservada;
- recuperação controlada;
- auditoria de integridade;
- encerramento automático;
- monitoramento de fórmulas em somente leitura;
- publicação sem fórmulas nas abas técnicas;
- uso exclusivo de dados sintéticos nos exemplos públicos.

### Documentado

- teste automatizado com janela aproximada de 48 horas;
- baseline de fórmulas com janela aproximada de 24 horas;
- resultados de performance;
- consumo observado;
- incidentes identificados;
- correções aplicadas;
- limitações do experimento;
- diferenças entre medição e projeção;
- limites de aplicabilidade;
- critérios de adaptação para outros contextos.

### Segurança

- remoção de identificadores do ambiente original;
- exclusão de credenciais e tokens;
- sanitização das evidências;
- substituição de dados reais por dados sintéticos;
- publicação desabilitada por padrão;
- autorização manual fechada por padrão nos exemplos;
- ausência de acesso de escrita à origem nos exemplos documentados.
