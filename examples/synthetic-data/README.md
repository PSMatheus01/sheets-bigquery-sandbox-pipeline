		# Dados sintéticos

## 1. Objetivo

Esta pasta contém dados criados exclusivamente para demonstrar os mecanismos técnicos apresentados neste repositório.

Os arquivos não contêm:

- dados de produção;
- nomes de clientes;
- nomes de colaboradores;
- documentos;
- telefones;
- e-mails;
- endereços;
- identificadores reais;
- URLs internas;
- chaves;
- credenciais;
- hashes do ambiente original;
- conteúdo extraído das planilhas avaliadas.

Os dados foram construídos manualmente para permitir testes de:

- carregamento;
- conversão de tipos;
- limpeza;
- validação;
- deduplicação;
- detecção de divergências;
- identificação de exceções;
- geração de indicadores;
- auditoria.

---

## 2. Arquivos da pasta

| Arquivo | Formato | Finalidade |
|---|---|---|
| `input-example.csv` | CSV | Fonte sintética principal utilizada nos exemplos do pipeline |
| `team-example.csv` | CSV | Referência sintética de equipes, grupos, validade e capacidade |

O arquivo principal contém registros válidos e registros intencionalmente inconsistentes.

O arquivo de equipes permite validar:

- existência da equipe;
- situação ativa ou inativa;
- período de validade;
- agrupamento;
- capacidade diária de referência.

As inconsistências fazem parte do conjunto de teste e não devem ser corrigidas diretamente nos arquivos CSV.

---

## 3. Características do conjunto

| Característica | Resultado |
|---|---:|
| Registros | 24 |
| Colunas | 12 |
| Cabeçalho | Sim |
| Delimitador | Vírgula |
| Codificação recomendada | UTF-8 |
| Dados pessoais | Nenhum |
| Dados de produção | Nenhum |
| Inconsistências intencionais | Sim |
| Identificador sintético da linha | `source_row_id` |
| Identificador sintético de negócio | `record_id` |

---

## 4. Finalidade dos dados

O conjunto não foi criado para representar integralmente uma operação real.

Ele foi criado para exercer situações que um pipeline de dados precisa tratar, como:

1. registros corretos;
2. campos obrigatórios ausentes;
3. valores numéricos inválidos;
4. valores negativos;
5. datas ausentes;
6. datas fora da janela;
7. valores booleanos inválidos;
8. referências inexistentes;
9. referências inativas;
10. identificadores duplicados;
11. combinações de status inconsistentes;
12. categorias fora do domínio permitido.

---

## 5. Schema da fonte

Todos os campos devem ser carregados inicialmente como texto na camada raw.

A conversão para tipos específicos deve ocorrer somente na camada de limpeza.

| Coluna | Tipo na camada raw | Tipo esperado após limpeza | Obrigatória | Descrição |
|---|---|---|---|---|
| `source_row_id` | `STRING` | `STRING` | Sim | Identificador único da linha sintética |
| `record_id` | `STRING` | `STRING` | Sim | Identificador de negócio utilizado na deduplicação |
| `event_date` | `STRING` | `DATE` | Sim | Data sintética do evento |
| `team_code` | `STRING` | `STRING` | Sim | Código sintético da equipe |
| `agent_code` | `STRING` | `STRING` | Sim | Código sintético do agente |
| `channel` | `STRING` | `STRING` | Sim | Canal de entrada |
| `campaign` | `STRING` | `STRING` | Sim | Campanha sintética |
| `status` | `STRING` | `STRING` | Sim | Estado operacional |
| `attempts` | `STRING` | `INT64` | Sim | Quantidade de tentativas |
| `converted` | `STRING` | `BOOL` | Sim | Indicador de conversão |
| `estimated_value` | `STRING` | `NUMERIC` | Não | Valor estimado sintético |
| `source_updated_at` | `STRING` | `TIMESTAMP` | Sim | Horário de atualização da linha |

---

## 6. Motivo para carregar os campos como texto

O arquivo contém propositalmente valores que não podem ser convertidos diretamente para o tipo esperado.

Exemplos:

- `UNKNOWN` em um campo booleano;
- `two` em um campo numérico;
- data ausente;
- valor monetário ausente;
- valor negativo;
- categoria não cadastrada.

Se o carregamento raw exigir os tipos finais imediatamente, o job poderá falhar antes que o pipeline consiga classificar as inconsistências.

A camada raw deve preservar o conteúdo recebido.

A camada de limpeza deve realizar conversões seguras.

---

## 7. Domínios de referência

### Status reconhecidos

| Status | Interpretação |
|---|---|
| `NEW` | Registro criado e ainda não trabalhado |
| `IN_PROGRESS` | Registro em andamento |
| `COMPLETED` | Registro concluído |
| `CANCELLED` | Registro cancelado |

O valor `REVIEW` foi inserido propositalmente como status não reconhecido.

### Canais reconhecidos

| Canal | Interpretação |
|---|---|
| `WHATSAPP` | Entrada por mensagem |
| `WEB` | Entrada por formulário ou página |
| `PHONE` | Entrada por contato telefônico |
| `PARTNER` | Entrada por parceiro |

O valor `SOCIAL` foi inserido propositalmente como canal não cadastrado na regra inicial.

### Campanhas utilizadas

| Campanha | Finalidade |
|---|---|
| `CAMP_ALPHA` | Campanha sintética A |
| `CAMP_BETA` | Campanha sintética B |
| `CAMP_GAMMA` | Campanha sintética C |

Os nomes não representam campanhas reais.

---

## 8. Regras de validação pretendidas

Os exemplos técnicos podem utilizar as seguintes regras.

### Identificação

- `source_row_id` deve ser preenchido;
- `source_row_id` deve identificar uma única linha;
- `record_id` deve ser preenchido;
- registros com o mesmo `record_id` devem ser avaliados como possíveis duplicidades.

### Data

- `event_date` deve ser convertível para `DATE`;
- data ausente deve gerar exceção;
- data fora da janela definida deve ser classificada separadamente.

### Equipe

- `team_code` deve ser preenchido;
- a equipe deve existir na referência;
- a equipe deve estar ativa.

### Agente

- `agent_code` deve ser preenchido;
- a ausência do agente deve gerar exceção.

### Canal

- o canal deve pertencer ao domínio permitido;
- canais desconhecidos devem ser classificados como exceção.

### Status

- o status deve pertencer ao domínio permitido;
- valores não reconhecidos devem gerar exceção.

### Tentativas

- `attempts` deve ser convertível para número inteiro;
- o valor não pode ser negativo.

### Conversão

- `converted` deve ser convertível para booleano;
- `COMPLETED` com `converted` igual a `FALSE` deve gerar divergência;
- status diferente de `COMPLETED` com `converted` igual a `TRUE` deve gerar divergência;
- `CANCELLED` com `converted` igual a `TRUE` deve gerar divergência.

### Valor estimado

- `estimated_value` deve ser convertível para `NUMERIC` quando preenchido;
- valor negativo deve gerar exceção;
- valor ausente pode ser mantido como `NULL`, conforme a regra do exemplo.

### Atualização

- `source_updated_at` deve ser convertível para `TIMESTAMP`;
- em registros duplicados, a atualização mais recente pode ser utilizada como critério de precedência.

---

## 9. Inconsistências intencionais

| Linha | Campo ou regra | Condição |
|---|---|---|
| `SRC005` | `team_code` | Equipe inexistente |
| `SRC006` | `agent_code` | Agente ausente |
| `SRC007` | `status` | Status não reconhecido |
| `SRC008` | `attempts` | Quantidade negativa |
| `SRC010` | `status` e `converted` | Registro concluído sem conversão |
| `SRC011` | `status` e `converted` | Conversão verdadeira sem conclusão |
| `SRC012` | `team_code` | Equipe ausente |
| `SRC013` | `event_date` | Data fora da janela de referência |
| `SRC014` | `estimated_value` | Valor negativo |
| `SRC015` e `SRC016` | `record_id` | Identificador duplicado |
| `SRC017` | `channel` | Canal não cadastrado |
| `SRC018` | `converted` | Valor booleano inválido |
| `SRC019` | `event_date` | Data ausente |
| `SRC020` | `status` e `converted` | Registro cancelado marcado como convertido |
| `SRC022` | `team_code` | Equipe de referência inativa |
| `SRC023` | `estimated_value` | Valor ausente |
| `SRC024` | `attempts` | Valor não numérico |

---

## 10. Duplicidade intencional

Os registros `SRC015` e `SRC016` compartilham o mesmo `record_id`.

| Campo | `SRC015` | `SRC016` |
|---|---|---|
| `record_id` | `REC015` | `REC015` |
| `source_updated_at` | `2026-11-06T08:10:00Z` | `2026-11-06T08:11:00Z` |

A duplicidade permite testar:

- detecção de duplicidades;
- ordenação por atualização;
- escolha determinística;
- preservação da evidência de duplicidade;
- contagem antes e depois da deduplicação.

A regra de precedência deve ser aplicada na camada de limpeza ou de regras, e não pela exclusão manual de uma linha do arquivo.

---

## 11. Valores ausentes

O CSV utiliza campos vazios entre vírgulas.

Exemplos:

| Linha | Campo vazio |
|---|---|
| `SRC006` | `agent_code` |
| `SRC012` | `team_code` |
| `SRC019` | `event_date` |
| `SRC023` | `estimated_value` |

Durante o carregamento raw, esses campos podem ser tratados como texto vazio ou `NULL`, conforme a configuração utilizada.

A camada de limpeza deve normalizar esse comportamento.

---

## 12. Conversões seguras

As conversões devem evitar que um único valor inválido interrompa toda a consulta.

No BigQuery, os exemplos SQL podem utilizar funções de conversão segura, como:

- `SAFE_CAST`;
- `PARSE_DATE` com tratamento;
- `PARSE_TIMESTAMP` com tratamento;
- normalização com `TRIM`;
- normalização com `UPPER`;
- conversão de texto vazio para `NULL`.

Valores que não puderem ser convertidos devem permanecer identificáveis para a camada de exceções.

---

## 13. Camadas esperadas

O exemplo será organizado conceitualmente em seis camadas.

| Ordem | Camada | Finalidade |
|---:|---|---|
| 1 | Raw | Preservar o conteúdo original do CSV |
| 2 | Clean | Normalizar e converter os campos |
| 3 | Rules | Aplicar regras e classificar divergências |
| 4 | Indicators | Consolidar indicadores |
| 5 | Exceptions | Listar registros que exigem análise |
| 6 | Audit | Validar contagens e consistência |

Essas camadas representam uma simplificação do experimento.

Elas não reproduzem integralmente o projeto original.

---

## 14. Resultado conceitual esperado

Ao final do processamento, os registros poderão ser classificados como:

| Classificação | Significado |
|---|---|
| Válido | Registro atende às regras obrigatórias |
| Divergência | Registro possui combinação de negócio inconsistente |
| Exceção | Registro possui dado ausente, inválido ou fora do domínio |
| Duplicado | Registro compartilha identificador de negócio com outra linha |
| Fora da janela | Registro não pertence ao período de referência |

Um mesmo registro pode participar de mais de uma classificação técnica, dependendo da regra aplicada.

---

## 15. Cuidados durante o uso

Não corrija manualmente as inconsistências antes de executar os exemplos.

Não altere:

- `UNKNOWN`;
- `two`;
- valores negativos;
- campos vazios;
- `REVIEW`;
- `SOCIAL`;
- identificadores duplicados;
- combinações inconsistentes entre status e conversão.

Esses valores são necessários para comprovar o funcionamento das validações.

---

## 16. Validação do arquivo

Antes de utilizar o CSV, confirme:

- [ ] o arquivo possui 24 registros;
- [ ] o arquivo possui 12 colunas;
- [ ] o cabeçalho está presente;
- [ ] o delimitador é vírgula;
- [ ] não existem linhas explicativas dentro do CSV;
- [ ] os campos vazios foram preservados;
- [ ] `REC015` aparece duas vezes;
- [ ] `SRC018` contém `UNKNOWN`;
- [ ] `SRC024` contém `two`;
- [ ] não existem dados reais;
- [ ] a codificação é UTF-8.

---

## 17. Segurança e privacidade

Os dados foram construídos para publicação pública.

Ainda assim, qualquer contribuição deve ser revisada antes do commit.

Não inclua:

- exemplos copiados da produção;
- valores parcialmente mascarados;
- nomes reais;
- documentos alterados apenas em parte;
- endereços reais;
- URLs privadas;
- IDs do ambiente original;
- trechos de logs;
- conteúdo de planilhas;
- credenciais;
- tokens.

Mascarar parcialmente um dado real não o transforma automaticamente em dado sintético.

---

## 18. Relação com o estudo

O arquivo sintético permite representar, em escala reduzida, princípios observados no experimento:

- fonte raw;
- conversão segura;
- aplicação de regras;
- identificação de divergências;
- identificação de exceções;
- deduplicação;
- geração de indicadores;
- auditoria.

Os números produzidos por esse conjunto não representam resultados do ambiente original.

Os resultados experimentais reais e sanitizados permanecem documentados em:

- `../../docs/results.md`;
- `../../evidence/experimental-summary.json`;
- `../../evidence/formula-baseline-summary.json`;
- `../../evidence/performance-summary.json`;
- `../../evidence/test-matrix.md`.

---

## 19. Limitações

O conjunto sintético:

- possui somente 24 registros;
- não representa carga de produção;
- não representa concorrência;
- não representa dados pessoais;
- não representa todas as regras possíveis;
- não comprova performance;
- não comprova escalabilidade;
- não substitui uma baseline;
- não representa um sistema transacional;
- não reproduz a arquitetura do Celebra Connect.

Sua finalidade é demonstrar os mecanismos de transformação e validação de forma segura e reproduzível.

---

## 20. Conclusão

O arquivo `input-example.csv` foi criado para permitir que os exemplos do repositório sejam compreendidos e executados sem qualquer dependência dos dados originais.

As inconsistências são intencionais.

Elas permitem demonstrar que um pipeline não deve apenas transformar dados válidos.

Ele também precisa:

- preservar a entrada;
- identificar valores inválidos;
- separar divergências;
- registrar exceções;
- tratar duplicidades;
- validar o resultado;
- manter rastreabilidade.
