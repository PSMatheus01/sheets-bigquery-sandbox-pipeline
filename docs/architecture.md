# Arquitetura experimental

## Visão geral

Este documento descreve a arquitetura efetivamente implementada e avaliada no estudo.

A solução utilizou:

- Google Sheets como origem somente para leitura;
- Google Apps Script como camada de orquestração;
- BigQuery Sandbox como mecanismo de processamento;
- uma planilha shadow como destino isolado;
- Script Properties como armazenamento de estado;
- Cloud Logging como camada de observabilidade;
- gatilhos temporais como mecanismo de recorrência.

O objetivo não foi transformar o Google Sheets em banco de dados nem construir uma aplicação transacional.

A arquitetura foi criada para avaliar:

- externalização de fórmulas;
- processamento em lote;
- validação de dados;
- publicação controlada;
- auditoria;
- recuperação de incidentes;
- operação dentro dos limites do sandbox.

---

# 1. Componentes

## 1.1 Planilha de origem

A planilha de origem representou o ambiente operacional existente.

Durante o experimento, ela permaneceu:

- somente para leitura;
- sem alteração de células;
- sem alteração de fórmulas;
- sem criação ou remoção de abas;
- sem formatação;
- sem gatilhos instalados;
- sem publicação de resultados.

A identidade da planilha foi validada por identificador e metadados antes das operações de captura.

```text
┌────────────────────────────────────────────┐
│ Planilha de origem                         │
│                                            │
│ Responsabilidade: fornecer dados           │
│ Permissão utilizada: leitura               │
│ Escrita pelo pipeline: não                 │
└────────────────────────────────────────────┘
```

---

## 1.2 Google Apps Script

O Google Apps Script atuou como plano de controle.

Suas responsabilidades incluíram:

- detecção de mudanças;
- leitura de metadados;
- captura controlada;
- criação de jobs no BigQuery;
- persistência do estado;
- validação das etapas;
- controle de gatilhos;
- controle de locks;
- publicação na shadow;
- auditoria;
- encerramento automático;
- recuperação controlada.

O Apps Script não executou o tratamento analítico principal. Essa responsabilidade permaneceu no BigQuery.

```text
┌────────────────────────────────────────────┐
│ Google Apps Script                         │
│                                            │
│ • detecta                                  │
│ • orquestra                                │
│ • valida                                   │
│ • publica                                  │
│ • audita                                   │
│ • preserva estados                         │
└────────────────────────────────────────────┘
```

---

## 1.3 BigQuery Sandbox

O BigQuery executou:

- armazenamento temporário;
- tipagem;
- normalização;
- limpeza;
- filtros temporais;
- cruzamentos;
- regras;
- agregações;
- geração de indicadores;
- detecção de divergências;
- geração de exceções;
- métricas de controle;
- assinaturas de conteúdo.

As estruturas foram criadas com expiração compatível com o sandbox.

```text
┌────────────────────────────────────────────┐
│ BigQuery Sandbox                           │
│                                            │
│ • tabelas candidatas                       │
│ • tabelas oficiais                         │
│ • views de limpeza                         │
│ • views de regras                          │
│ • indicadores                              │
│ • divergências                             │
│ • exceções                                 │
│ • controle                                 │
└────────────────────────────────────────────┘
```

---

## 1.4 Planilha shadow

A planilha shadow foi utilizada como destino isolado.

Ela recebeu:

- valores estáticos;
- cabeçalhos;
- filtros;
- congelamento da primeira linha;
- formatação necessária;
- abas técnicas;
- zero fórmulas nas saídas publicadas.

A shadow também preservou abas de negócio independentes das saídas técnicas.

```text
┌────────────────────────────────────────────┐
│ Planilha shadow                            │
│                                            │
│ • destino isolado                          │
│ • valores estáticos                        │
│ • zero fórmulas técnicas                   │
│ • publicação validada                      │
│ • produção preservada                      │
└────────────────────────────────────────────┘
```

---

## 1.5 Script Properties

As Script Properties armazenaram o estado operacional.

Entre os dados persistidos estavam:

- etapa atual;
- etapa anterior;
- ciclo operacional;
- resultados das etapas;
- assinaturas;
- janela avaliativa;
- concessão;
- lease;
- orçamento de execução;
- auditorias;
- incidentes;
- resultados de recuperação.

Não foram utilizadas para armazenar os dados operacionais completos da origem.

---

## 1.6 Cloud Logging

O Cloud Logging registrou:

- início e término;
- ação executada;
- origem da execução;
- estado anterior;
- estado posterior;
- duração;
- bloqueios;
- ressalvas;
- métricas;
- consumo;
- encerramento automático;
- incidentes.

Os logs utilizados no repositório público são descritos apenas por métricas agregadas e anonimizadas.

---

# 2. Visão arquitetural

```text
┌──────────────────────┐
│ Google Sheets        │
│ Origem somente       │
│ para leitura         │
└──────────┬───────────┘
           │
           │ Dados e metadados
           ▼
┌──────────────────────┐
│ Apps Script          │
│ Plano de controle    │
└──────────┬───────────┘
           │
           │ Jobs e validações
           ▼
┌──────────────────────┐
│ BigQuery Sandbox     │
│ Plano de dados       │
└──────────┬───────────┘
           │
           │ Resultados aprovados
           ▼
┌──────────────────────┐
│ Apps Script          │
│ Publicação           │
└──────────┬───────────┘
           │
           │ Valores estáticos
           ▼
┌──────────────────────┐
│ Planilha shadow      │
│ Destino isolado      │
└──────────┬───────────┘
           │
           │ Conferência
           ▼
┌──────────────────────┐
│ Auditoria            │
│ Assinaturas e        │
│ integridade          │
└──────────────────────┘
```

---

# 3. Plano de controle e plano de dados

A arquitetura separou duas responsabilidades.

## Plano de controle

Executado pelo Apps Script:

- qual etapa deve rodar;
- quando deve rodar;
- se pode avançar;
- qual estado deve ser persistido;
- quando bloquear;
- quando encerrar;
- quando recuperar;
- quando publicar.

## Plano de dados

Executado pelo BigQuery:

- leitura das tabelas;
- limpeza;
- transformação;
- tipagem;
- regras;
- cruzamentos;
- agregações;
- assinaturas;
- resultados analíticos.

Essa separação evitou que o Apps Script executasse grandes transformações linha a linha.

---

# 4. Camadas de dados

A organização lógica utilizou camadas distintas.

## 4.1 Origem

Representação dos dados capturados da planilha.

```text
ORIGEM
  ├── dados principais
  └── dados auxiliares
```

## 4.2 Candidata

Estruturas criadas antes da promoção.

```text
CANDIDATA
  ├── tabela principal candidata
  ├── tabela auxiliar candidata
  └── views candidatas
```

As candidatas permitiram validar a nova geração sem substituir imediatamente as estruturas oficiais.

## 4.3 Oficial

Estruturas aprovadas para consumo.

```text
OFICIAL
  ├── tabela principal
  ├── tabela auxiliar
  ├── view de limpeza
  ├── view de regras
  ├── view de indicadores
  ├── view de divergências
  ├── view de exceções
  └── view de controle
```

## 4.4 Backup

Versões anteriores preservadas antes da promoção.

```text
BACKUP
  ├── tabela principal anterior
  └── tabela auxiliar anterior
```

## 4.5 Publicação

Resultados materializados na planilha shadow.

```text
PUBLICAÇÃO
  ├── indicadores
  ├── divergências
  ├── exceções
  └── controle
```

---

# 5. Pipeline operacional

O pipeline utilizou 12 etapas principais.

| Ordem | Responsabilidade |
|---:|---|
| 1 | Detectar mudança |
| 2 | Capturar snapshot |
| 3 | Validar candidata |
| 4 | Criar views candidatas |
| 5 | Validar views candidatas |
| 6 | Criar backup |
| 7 | Promover estruturas |
| 8 | Validar pós-promoção |
| 9 | Decidir publicação |
| 10 | Publicar na shadow |
| 11 | Validar publicação |
| 12 | Finalizar ciclo |

```text
DETECÇÃO
   │
   ▼
CAPTURA
   │
   ▼
VALIDAÇÃO CANDIDATA
   │
   ▼
VIEWS CANDIDATAS
   │
   ▼
VALIDAÇÃO DAS VIEWS
   │
   ▼
BACKUP
   │
   ▼
PROMOÇÃO
   │
   ▼
VALIDAÇÃO PÓS-PROMOÇÃO
   │
   ▼
DECISÃO DE PUBLICAÇÃO
   │
   ▼
PUBLICAÇÃO
   │
   ▼
VALIDAÇÃO DA PUBLICAÇÃO
   │
   ▼
FINALIZAÇÃO
```

Uma etapa reprovada impedia o avanço automático.

---

# 6. Máquina de estados

O estado operacional foi persistido entre as execuções.

```text
AGUARDANDO DETECÇÃO
         │
         ▼
CAPTURA PENDENTE
         │
         ▼
VALIDAÇÃO CANDIDATA PENDENTE
         │
         ▼
VIEWS CANDIDATAS PENDENTES
         │
         ▼
VALIDAÇÃO DAS VIEWS PENDENTE
         │
         ▼
BACKUP PENDENTE
         │
         ▼
PROMOÇÃO PENDENTE
         │
         ▼
VALIDAÇÃO PÓS-PROMOÇÃO PENDENTE
         │
         ▼
PUBLICAÇÃO PENDENTE
         │
         ▼
VALIDAÇÃO DA PUBLICAÇÃO PENDENTE
         │
         ▼
FINALIZAÇÃO PENDENTE
         │
         ▼
CICLO CONCLUÍDO
```

Em caso de falha:

```text
ETAPA EM EXECUÇÃO
        │
        ▼
FALHA DETECTADA
        │
        ▼
FALHA PRESERVADA
        │
        ├── diagnóstico
        ├── correção
        ├── recuperação
        └── rollback, quando aplicável
```

O estado `FALHA PRESERVADA` impediu que o executor retomasse automaticamente uma operação incompleta.

---

# 7. Detecção de mudanças

A detecção utilizou metadados da origem.

Foram comparados:

- horário da última modificação;
- referência resumida da origem;
- estado anteriormente aprovado.

A detecção inicial não precisou abrir todas as células da planilha.

Uma mudança precisava permanecer observável por múltiplos intervalos antes de iniciar um novo ciclo.

Esse mecanismo reduziu o risco de processar uma alteração transitória ou ainda incompleta.

```text
Mudança observada
       │
       ▼
Pendência registrada
       │
       ▼
Confirmações periódicas
       │
       ▼
Limiar atendido
       │
       ▼
Novo ciclo autorizado
```

---

# 8. Captura consistente

Antes da captura, o pipeline registrou uma referência da origem.

Após a criação das estruturas candidatas, a origem foi verificada novamente.

Se a planilha tivesse mudado durante a captura:

- a geração não seria promovida;
- a execução seria bloqueada;
- uma nova tentativa seria necessária.

Esse controle evitou misturar dados de dois estados diferentes da origem na mesma geração.

---

# 9. Validação das estruturas candidatas

As estruturas candidatas foram verificadas antes da promoção.

As validações incluíram:

- existência;
- tipo do objeto;
- esquema;
- quantidade de campos;
- contagem;
- expiração;
- labels;
- assinaturas;
- dependências;
- compatibilidade com as regras.

A promoção somente ocorria depois da aprovação dessas verificações.

---

# 10. Promoção e backup

Antes da promoção:

1. as estruturas oficiais eram identificadas;
2. backups eram criados;
3. candidatas eram validadas;
4. o estado era persistido.

Depois:

1. candidatas eram promovidas;
2. estruturas oficiais eram verificadas;
3. backups permaneciam disponíveis;
4. a etapa seguinte validava o resultado.

```text
OFICIAL ANTERIOR ───────► BACKUP
                              
CANDIDATA APROVADA ─────► OFICIAL NOVA
```

A promoção não significava aprovação final. Uma validação pós-promoção ainda era obrigatória.

---

# 11. Assinaturas

As assinaturas foram utilizadas para comparar gerações e publicações.

Cada saída possuía:

- total de registros;
- assinatura XOR;
- assinatura de soma;
- nome lógico;
- view de origem;
- aba de destino.

```text
ASSINATURA
  ├── total de registros
  ├── XOR
  └── soma
```

A combinação não foi tratada como mecanismo criptográfico. Seu objetivo foi detectar diferenças operacionais entre conjuntos de registros.

---

# 12. Decisão de publicação

A publicação não ocorria apenas porque um ciclo havia sido processado.

A etapa de decisão comparava:

- geração atual;
- publicação anteriormente aprovada;
- contagem;
- assinaturas;
- saídas alteradas.

Somente saídas identificadas como alteradas eram selecionadas para publicação.

Esse comportamento reduziu escritas desnecessárias.

---

# 13. Publicação isolada

A publicação utilizou abas temporárias.

```text
RESULTADO APROVADO
        │
        ▼
ABA TEMPORÁRIA
        │
        ▼
VALIDAÇÃO DA ABA
        │
        ▼
PROMOÇÃO DO NOME
        │
        ▼
VALIDAÇÃO DA PUBLICAÇÃO
        │
        ▼
REMOÇÃO DA VERSÃO ANTERIOR
```

A versão anterior somente era removida depois da validação completa da nova publicação.

As abas técnicas receberam:

- valores;
- cabeçalhos;
- filtros;
- congelamento;
- formatação necessária;
- zero fórmulas.

---

# 14. Sanitização

Textos iniciados por caracteres interpretáveis como fórmulas foram tratados antes da publicação.

Caracteres avaliados incluíram:

```text
=
+
-
@
```

A sanitização reduziu o risco de que dados externos fossem interpretados como fórmulas pelo Google Sheets.

---

# 15. Auditoria

A auditoria verificou a integridade da camada publicada.

Entre as verificações estavam:

- planilha correta;
- abas esperadas;
- ausência de abas inesperadas;
- ausência de resíduos;
- cabeçalhos;
- quantidade de linhas;
- quantidade de colunas;
- filtros;
- congelamento;
- visibilidade;
- ausência de fórmulas;
- assinaturas;
- preservação das abas de negócio.

A auditoria abriu apenas a shadow e consultou as estruturas analíticas necessárias.

---

# 16. Recorrência

A recorrência foi controlada por um único gatilho temporal.

O executor:

- obtinha lock;
- validava a janela;
- verificava a configuração;
- conferia lease;
- verificava orçamento;
- selecionava uma etapa;
- executava uma etapa por chamada;
- persistia o resultado;
- liberava o lock.

```text
GATILHO
  │
  ▼
LOCK
  │
  ▼
VALIDAR JANELA
  │
  ▼
VALIDAR LEASE
  │
  ▼
VALIDAR ORÇAMENTO
  │
  ▼
SELECIONAR ETAPA
  │
  ▼
EXECUTAR UMA ETAPA
  │
  ▼
PERSISTIR RESULTADO
```

A execução de apenas uma etapa por chamada reduziu o risco de ultrapassar o limite de duração do Apps Script.

---

# 17. Concorrência

A arquitetura utilizou três mecanismos complementares.

## Lock

Impediu duas execuções simultâneas do mesmo projeto.

## Lease

Registrou temporariamente a propriedade de uma execução operacional.

## Estado

Impediu que uma etapa fosse executada fora da sequência prevista.

Esses mecanismos reduziram:

- duplicidade;
- publicação concorrente;
- promoção simultânea;
- conflito de estado;
- retomada indevida.

---

# 18. Orçamento operacional

O executor registrou o runtime acumulado por dia.

Antes de executar etapas mais pesadas, verificava:

- runtime consumido;
- orçamento diário;
- reserva preventiva;
- necessidade de auditoria;
- margem restante.

O objetivo foi impedir que o ciclo consumisse toda a cota diária e inviabilizasse auditorias ou encerramentos.

---

# 19. Encerramento automático

A janela avaliativa possuía:

- início;
- término previsto;
- gatilho associado;
- identificador de ativação;
- motivo de encerramento.

Após o prazo:

1. o executor detectava a expiração;
2. localizava o gatilho exato;
3. removia apenas o gatilho da janela;
4. marcava a janela como encerrada;
5. preservava o estado operacional;
6. registrava o resultado.

O encerramento não alterava a planilha de produção nem repetia etapas do pipeline.

---

# 20. Recuperação

A arquitetura suportou recuperação controlada.

Foram utilizados padrões como:

- preservação da falha original;
- preflight somente para leitura;
- autorização manual temporária;
- recuperação baseada em metadados;
- avanço restrito de estado;
- ausência de republicação desnecessária;
- nova validação posterior.

A recuperação não apagou o incidente original. O histórico permaneceu disponível para auditoria.

---

# 21. Limites de confiança

```text
┌─────────────────────────────────────────┐
│ Ambiente de origem                      │
│ Dados operacionais                      │
└───────────────────┬─────────────────────┘
                    │ Limite 1
                    ▼
┌─────────────────────────────────────────┐
│ Apps Script                             │
│ Controle e credenciais do projeto       │
└───────────────────┬─────────────────────┘
                    │ Limite 2
                    ▼
┌─────────────────────────────────────────┐
│ BigQuery                                │
│ Processamento e armazenamento           │
└───────────────────┬─────────────────────┘
                    │ Limite 3
                    ▼
┌─────────────────────────────────────────┐
│ Planilha shadow                         │
│ Resultado para validação                │
└─────────────────────────────────────────┘
```

Cada transição exigiu validação de:

- identidade do recurso;
- esquema;
- configuração;
- contagem;
- estado;
- autorização.

---

# 22. Propriedades de segurança

A arquitetura validou:

- produção somente para leitura;
- destino isolado;
- publicação sem fórmulas;
- sanitização de textos;
- locks;
- leases;
- estados persistidos;
- backups;
- auditoria;
- recuperação;
- encerramento automático;
- inventário de resíduos;
- autorização manual para operações excepcionais.

---

# 23. Limitações arquiteturais

A arquitetura não foi projetada para:

- banco transacional;
- processamento em tempo real;
- alta concorrência de escrita;
- edição simultânea de registros;
- baixa latência;
- retenção permanente no sandbox;
- disponibilidade crítica;
- grandes volumes sem revisão;
- operação sem monitoramento.

Os principais limites observados foram:

- cotas do Apps Script;
- tempo máximo por execução;
- expiração do sandbox;
- armazenamento limitado;
- ausência de DML no sandbox;
- ausência de streaming;
- latência de escrita no Sheets;
- dependência da estrutura da origem.

---

# 24. Padrões reutilizáveis

A arquitetura produziu padrões aplicáveis a outros contextos.

## Estruturas candidatas

Criar, validar e somente depois promover.

## Backup anterior à promoção

Preservar uma versão recuperável antes da substituição.

## Máquina de estados

Impedir avanço fora de sequência.

## Assinaturas operacionais

Comparar registros sem reler manualmente todo o resultado.

## Shadow isolada

Validar a publicação fora da origem.

## Recuperação baseada em metadados

Retomar operações sem repetir efeitos já concluídos.

## Auditoria independente

Verificar a integridade depois da publicação.

## Encerramento automático

Remover recursos temporários após o prazo.

---

# 25. Síntese

A arquitetura demonstrou que um processo dependente de fórmulas pode ser reorganizado em um pipeline com:

- origem protegida;
- processamento externo;
- validação por etapas;
- promoção controlada;
- publicação isolada;
- auditoria;
- recuperação;
- observabilidade.

O principal resultado arquitetural foi a separação entre:

```text
DADOS
PROCESSAMENTO
CONTROLE
PUBLICAÇÃO
AUDITORIA
```

Essa separação tornou o fluxo mais previsível, verificável e recuperável do que uma sequência de alterações diretas na planilha.

---

# Referências

- [BigQuery Sandbox](https://docs.cloud.google.com/bigquery/docs/sandbox)
- [BigQuery Quotas and Limits](https://docs.cloud.google.com/bigquery/quotas)
- [Google Apps Script — Triggers](https://developers.google.com/apps-script/guides/triggers)
- [Google Apps Script — Quotas](https://developers.google.com/apps-script/guides/services/quotas)
- [Google Apps Script — Logging](https://developers.google.com/apps-script/guides/logging)
