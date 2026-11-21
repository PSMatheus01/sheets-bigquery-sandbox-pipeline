# Resultados experimentais

## 1. Visão geral

Este documento apresenta os resultados consolidados dos experimentos realizados para avaliar uma alternativa ao processamento intensivo por fórmulas em Google Sheets.

A avaliação foi dividida em dois experimentos complementares:

1. **Pipeline automatizado em BigQuery Sandbox e Apps Script**, executado durante uma janela controlada de aproximadamente 48 horas;
2. **Baseline da planilha baseada em fórmulas**, monitorada durante 24 horas em modo estritamente somente leitura.

Os experimentos tiveram finalidades diferentes:

- o teste de 48 horas avaliou automação, recorrência, integridade, segurança, desempenho e recuperação;
- o teste de 24 horas mediu o tamanho e o comportamento da estrutura existente baseada em fórmulas.

Os resultados demonstram que o processamento centralizado fora das fórmulas da planilha é tecnicamente viável. Também mostram que o principal gargalo observado não estava no processamento analítico do BigQuery, mas na interação e publicação de grandes volumes de dados no Google Sheets.

---

## 2. Resumo dos resultados

| Indicador | Resultado |
|---|---:|
| Duração da janela do pipeline | Aproximadamente 48 horas |
| Ciclos concluídos e aprovados | 10 |
| Resultados operacionais acumulados | 32 |
| Resultados aprovados | 31 |
| Bloqueios ativos ao final | 0 |
| Gatilhos residuais ao final | 0 |
| Falhas não tratadas ao final | 0 |
| Auditoria de integridade registrada no consolidado | 1 |
| Amostras de performance do pipeline | 30 |
| Média de duração das etapas | 12,72 s |
| Mediana | 2,27 s |
| P95 | 62,32 s |
| Maior duração observada | 92,08 s |
| Execuções abaixo de 25 segundos | 86,67% |
| Publicação do ciclo analisado | 9.009 linhas |
| Células publicadas no ciclo | 114.575 |
| Fórmulas publicadas nas abas técnicas | 0 |
| Valores tratados para publicação segura | 2.340 |
| Duração do monitoramento da planilha | 24 horas |
| Amostras da baseline | 96 de 96 |
| Falhas no monitoramento | 0 |
| Linhas inventariadas | 75.595 |
| Colunas inventariadas | 35 |
| Células existentes | 2.645.825 |
| Fórmulas encontradas | 146.701 |
| Células com erro de fórmula | 18 |

---

# Parte I — Pipeline automatizado de 48 horas

## 3. Janela de avaliação

A janela controlada foi iniciada em:

- **08/11/2026 às 19:25:47**

O encerramento automático ocorreu em:

- **10/11/2026 às 19:29:03**

A pequena diferença entre o horário programado e o encerramento efetivo decorreu do intervalo do gatilho periódico. O executor identificou a expiração na chamada seguinte disponível.

O encerramento apresentou as seguintes características:

- encerramento automático por prazo;
- remoção do único gatilho responsável pelo executor;
- nenhuma alteração indevida no estado operacional;
- nenhuma concessão residual;
- nenhuma lease residual;
- nenhum gatilho residual;
- nenhuma intervenção manual necessária para concluir a janela.

O gatilho foi removido automaticamente após a identificação do término do período de avaliação.

---

## 4. Resultado funcional do pipeline

Durante a janela, o pipeline percorreu o fluxo operacional completo:

1. detecção de alteração;
2. confirmação da persistência da mudança;
3. captura dos dados;
4. validação da captura;
5. criação da geração candidata;
6. criação e validação das views candidatas;
7. preservação da geração oficial anterior;
8. promoção da geração candidata;
9. validação pós-promoção;
10. decisão de publicação;
11. publicação na shadow;
12. validação da publicação;
13. finalização do ciclo;
14. retorno ao estado de espera por uma nova alteração.

Foram registrados:

- **10 ciclos concluídos e aprovados**;
- **32 resultados operacionais acumulados**;
- **31 resultados aprovados diretamente**;
- **1 bloqueio histórico recuperado**;
- **0 bloqueios ativos no estado final**.

O estado final foi:

- `CICLO_CONCLUIDO`;
- ciclo aprovado;
- geração validada;
- publicação concluída;
- produção preservada em modo somente leitura;
- ausência de gatilhos ou mecanismos temporários residuais.

O resultado final com status de ressalva não representou reprovação do experimento. A ressalva preservou o histórico dos eventos intermediários e das recuperações realizadas durante o desenvolvimento.

---

## 5. Detecção e confirmação de mudanças

A detecção foi baseada em metadados da fonte, sem necessidade de ler todas as células da planilha a cada execução.

Foram utilizados dois indicadores principais:

- horário de modificação da fonte;
- hash de referência dos metadados observados.

Uma alteração não iniciava imediatamente um novo ciclo. Antes disso, precisava permanecer detectável durante:

- **8 intervalos de confirmação**;
- aproximadamente **120 minutos**.

Esse mecanismo reduziu o risco de iniciar processamento durante alterações transitórias ou enquanto a fonte ainda estava sendo modificada.

A espera de aproximadamente 120 minutos foi uma decisão de controle e estabilidade, e não uma limitação de desempenho do processamento.

---

## 6. Auditoria de integridade

O consolidado final registrou uma auditoria operacional de integridade durante o período avaliado.

Resultado:

- parecer: **INTEGRIDADE APROVADA**;
- duração: aproximadamente **13,56 segundos**;
- nenhuma alteração na produção;
- nenhuma alteração em objetos do BigQuery durante a auditoria;
- nenhuma fórmula residual nas abas técnicas avaliadas;
- nenhuma aba inesperada;
- nenhuma evidência de corrupção da publicação;
- nenhuma intervenção manual necessária.

A auditoria verificou a consistência entre:

- estado operacional;
- publicação realizada;
- abas técnicas;
- assinaturas dos resultados;
- controles de segurança;
- identidade do experimento;
- ciclo operacional correspondente.

---

## 7. Performance do pipeline

Foram consolidadas 30 amostras de duração.

| Métrica | Resultado |
|---|---:|
| Média | 12.715,33 ms |
| Mediana | 2.269 ms |
| P95 | 62.315,15 ms |
| Mínimo | 304 ms |
| Máximo | 92.083 ms |
| Abaixo de 25 segundos | 26 de 30 |
| Percentual abaixo de 25 segundos | 86,67% |

### 7.1 Interpretação do P95

P95 significa **percentil 95**.

Neste experimento, um P95 de aproximadamente 62,32 segundos significa que:

- 95% das execuções observadas ficaram em até aproximadamente 62,32 segundos;
- somente os 5% mais lentos ultrapassaram esse valor.

O P95 é mais útil do que apenas a média porque evidencia o comportamento das execuções mais lentas sem utilizar somente o pior caso isolado.

### 7.2 Etapas mais lentas

| Etapa | Duração observada |
|---|---:|
| Resultado original da recuperação da publicação | 92.083 ms |
| Publicação na shadow | 87.404 ms |
| Captura otimizada | 31.651 ms |
| Promoção nativa | 31.001 ms |
| Validação pós-promoção | 22.082 ms |

As etapas mais lentas estavam relacionadas principalmente a:

- leitura e organização de grandes volumes;
- promoção de estruturas;
- publicação de dados no Google Sheets;
- validações posteriores à publicação.

O maior gargalo observado foi a publicação na planilha shadow, e não a execução das consultas analíticas no BigQuery.

---

## 8. Publicação na planilha shadow

No ciclo analisado, a publicação processou:

- **9.009 linhas**;
- **114.575 células**;
- **0 fórmulas nas abas técnicas**;
- **2.340 valores sanitizados** para impedir interpretação indevida como fórmula;
- duração aproximada de **87,4 segundos**.

No acumulado registrado pelo experimento, foram publicados:

- **30.904 registros**;
- **440.653 células**.

A publicação utilizou valores já processados, evitando que as abas técnicas precisassem reproduzir a lógica com milhares de fórmulas locais.

Isso transferiu o processamento analítico para uma camada centralizada, mantendo o Apps Script como orquestrador e publicador dos resultados.

---

## 9. Consumo de BigQuery

Um ciclo aprovado registrou:

| Indicador | Resultado |
|---|---:|
| Jobs totais | 13 |
| Jobs com processamento | 9 |
| Bytes processados | 88.789.912 |
| Bytes processados aproximados | 84,7 MiB |
| Bytes faturáveis registrados | 181.403.648 |
| Bytes faturáveis aproximados | 173 MiB |

A métrica de bytes faturáveis representa a unidade de contabilização da consulta. No ambiente Sandbox, ela não significa que houve cobrança financeira.

Um ciclo com aproximadamente 173 MiB faturáveis representa cerca de:

- **0,0165% de 1 TiB**.

A projeção depende diretamente da frequência de ciclos completos.

| Frequência hipotética | Projeção mensal aproximada |
|---|---:|
| 1 ciclo por dia | 5,1 GiB por mês |
| 96 ciclos por dia | 486,6 GiB por mês |

Esses números são projeções baseadas no consumo de referência de um ciclo. Não representam consumo mensal medido.

Mesmo na hipótese elevada de 96 ciclos completos por dia, a projeção permaneceria abaixo de 1 TiB mensal. Entretanto, essa frequência não corresponde ao comportamento real observado, pois o pipeline somente iniciava um ciclo completo após confirmar uma mudança persistente.

---

## 10. Orçamento de execução do Apps Script

O maior consumo diário observado durante a avaliação permaneceu abaixo do orçamento operacional configurado.

No encerramento final, foi registrado:

- runtime consumido: aproximadamente **10,19 minutos**;
- orçamento diário configurado: **70 minutos**;
- utilização aproximada: **14,55%**.

Em outro ponto do experimento, o maior acumulado diário observado foi de aproximadamente:

- **13,36 minutos**;
- equivalente a cerca de **19,1%** do orçamento diário de 70 minutos.

O orçamento preventivo evitava que o executor iniciasse novas operações quando a margem disponível pudesse comprometer auditorias ou finalizações obrigatórias.

---

## 11. Incidentes e recuperações

### 11.1 Bloqueio histórico na validação pós-promoção

A validação pós-promoção inicialmente exigia que a quantidade de registros da view limpa fosse igual à quantidade total de linhas com conteúdo na tabela bruta.

Essa premissa era incorreta porque a view limpa aplicava regras de elegibilidade e uma janela temporal.

A relação correta era:

- a view limpa deve possuir quantidade menor ou igual ao total de linhas com conteúdo;
- linhas fora da janela ou inelegíveis podem ser excluídas legitimamente.

Após a correção:

- a validação foi aprovada;
- foram identificadas **22.344 linhas não incorporadas pela view limpa** por regras de elegibilidade ou janela temporal;
- a promoção foi confirmada como válida;
- nenhuma perda estrutural indevida foi identificada.

### 11.2 Falha preservada

Quando a validação bloqueou o fluxo, o sistema:

- registrou o estado de falha;
- não continuou automaticamente;
- preservou a geração promovida;
- preservou os backups;
- encerrou a janela;
- removeu o gatilho correspondente;
- não executou publicação incompleta;
- não realizou rollback automático sem validação.

Esse comportamento confirmou a capacidade de interrupção segura diante de uma inconsistência.

### 11.3 Recuperação controlada

Após a correção da validação, a retomada:

- exigiu preflight;
- exigiu autorização manual temporária;
- vinculou a nova janela ao ciclo específico;
- criou exatamente um novo gatilho;
- manteve o estado operacional;
- permitiu a continuação a partir da etapa pendente;
- não repetiu desnecessariamente as etapas já aprovadas.

A recuperação permitiu que o mesmo ciclo prosseguisse até a conclusão.

### 11.4 Staging órfão

Foi identificado um staging temporário remanescente durante uma das validações.

A rotina de recuperação:

- identificou o objeto;
- removeu somente o staging correspondente;
- preservou as abas oficiais;
- validou novamente a publicação;
- permitiu a finalização segura do ciclo.

O incidente foi tratado e não permaneceu ativo no encerramento do experimento.

---

## 12. Segurança operacional

Durante o experimento, foram confirmados os seguintes controles:

- produção utilizada somente para leitura;
- nenhuma escrita na planilha de produção;
- ausência de gatilhos instalados na produção;
- execução automática somente no projeto controlado;
- verificação da identidade do experimento;
- verificação do ciclo operacional;
- locks contra concorrência;
- concessões temporárias;
- leases de execução;
- validação da configuração;
- validação da janela ativa;
- encerramento automático;
- remoção automática do gatilho;
- preservação de backups;
- auditoria periódica;
- sanitização de valores antes da publicação;
- separação entre produção e shadow;
- ausência de fórmulas nas abas técnicas publicadas.

O resultado final não apresentou:

- gatilho residual;
- concessão residual;
- lease residual;
- janela ativa;
- ciclo incompleto;
- bloqueio ativo;
- falha não tratada.

---

# Parte II — Baseline da planilha com fórmulas

## 13. Objetivo da baseline

A baseline teve como objetivo quantificar a estrutura existente baseada em fórmulas.

O monitoramento não tentou medir diretamente o tempo interno de recálculo do Google Sheets, pois esse indicador não é exposto de forma precisa pelo Apps Script.

Em vez disso, foram coletados indicadores empíricos relacionados a:

- tamanho da planilha;
- volume de fórmulas;
- distribuição por coluna;
- funções utilizadas;
- erros existentes;
- latência de abertura;
- latência de leitura;
- tempo das amostras;
- alterações de metadados;
- estabilidade do monitoramento.

---

## 14. Controles de segurança da baseline

A baseline foi executada a partir de um projeto separado e controlado.

Durante todo o monitoramento:

- nenhuma célula foi alterada;
- nenhuma fórmula foi alterada;
- nenhuma aba foi criada;
- nenhuma aba foi excluída;
- nenhuma linha foi inserida;
- nenhum valor foi gravado;
- nenhuma formatação foi alterada;
- nenhum `flush()` foi executado;
- nenhum job do BigQuery foi executado;
- nenhum estado do experimento E2O foi alterado;
- nenhum gatilho foi criado na produção.

Somente métricas agregadas foram armazenadas.

Não foram persistidos:

- nomes de clientes;
- documentos;
- e-mails;
- conteúdo integral de células;
- fórmulas completas;
- dados operacionais individuais.

---

## 15. Cobertura do monitoramento

O monitoramento foi executado durante aproximadamente 24 horas.

| Indicador | Resultado |
|---|---:|
| Intervalo configurado | 15 minutos |
| Amostras previstas | 96 |
| Amostras concluídas | 96 |
| Cobertura | 100% |
| Falhas de execução | 0 |
| Encerramento | Automático por prazo |
| Gatilhos residuais | 0 |

O gatilho temporário foi removido automaticamente ao final da janela.

A coleta incluiu parte de um período operacional e parte de um período sem expediente. Por isso, a baseline deve ser interpretada como uma amostra técnica da estrutura e do comportamento observado, e não como uma medição exclusiva de carga máxima de usuários.

---

## 16. Dimensão da planilha

O inventário encontrou:

| Indicador | Resultado |
|---|---:|
| Linhas utilizadas | 75.595 |
| Colunas utilizadas | 35 |
| Células existentes na área inventariada | 2.645.825 |
| Fórmulas encontradas | 146.701 |
| Densidade de fórmulas | 5,54% |
| Colunas com fórmulas | 5 |
| Células com erros | 18 |

Embora a densidade total de fórmulas seja de 5,54%, a concentração em colunas específicas faz com que determinadas regras sejam repetidas milhares de vezes.

---

## 17. Distribuição das fórmulas

| Coluna | Fórmulas encontradas |
|---|---:|
| A | 1 |
| R | 1.454 |
| S | 5.129 |
| AB | 75.594 |
| AG | 64.523 |
| **Total** | **146.701** |

A coluna AB continha praticamente uma fórmula por linha e apresentou padrões misturados.

Padrões misturados em uma mesma coluna aumentam o risco de:

- fórmulas sobrescritas;
- regras diferentes na mesma área;
- manutenção parcial;
- comportamento inconsistente entre registros;
- dificuldade de auditoria;
- propagação de erros.

---

## 18. Funções identificadas

| Função | Ocorrências identificadas |
|---|---:|
| `IF` | 173.158 |
| `SUBSTITUTE` | 151.188 |
| `VALUE` | 75.594 |
| `XLOOKUP` | 64.523 |
| `COUNTIFS` | 5.129 |
| `IMPORTRANGE` | 1 |

A quantidade de funções pode ser maior do que a quantidade de células com fórmula porque uma mesma fórmula pode conter várias funções combinadas ou utilizar a mesma função mais de uma vez.

Os números indicam uma lógica significativa sendo executada diretamente dentro da planilha, especialmente para:

- decisões condicionais;
- substituição e normalização de textos;
- conversão de valores;
- buscas entre conjuntos de dados;
- contagens condicionais;
- importação de dados externos.

---

## 19. Erros encontrados

Foram identificadas 18 células com erro:

| Tipo de erro | Quantidade |
|---|---:|
| `#REF!` | 8 |
| `#VALUE!` | 4 |
| `#ERROR!` | 6 |
| **Total** | **18** |

Distribuição conhecida:

| Coluna | Erros |
|---|---:|
| E | 3 |
| S | 13 |
| AB | 2 |

As amostras periódicas de 800 linhas não encontraram erros nas regiões selecionadas. Entretanto, o inventário integral encontrou 18 erros no conjunto completo.

Isso demonstra a diferença entre:

- monitoramento amostral;
- inventário completo.

Os **0 erros nas amostras** não anulam os **18 erros encontrados no inventário integral**.

Da mesma forma, as **0 falhas do monitoramento** significam que o script de coleta funcionou corretamente; não significam que a planilha não possuía erros de fórmula.

---

## 20. Estrutura das amostras

Cada amostra avaliou três regiões da planilha:

- 100 linhas no início;
- 200 linhas na região intermediária;
- 500 linhas na região final.

Por execução, foram observados:

| Indicador | Resultado |
|---|---:|
| Linhas amostradas | 800 |
| Colunas | 35 |
| Células amostradas | 28.000 |
| Fórmulas amostradas | 2.499 |
| Erros nas regiões amostradas | 0 |

As regiões foram mantidas constantes para permitir comparação entre as execuções.

---

## 21. Alterações observadas

Durante o período, foram identificadas:

- **31 alterações de `modifiedTime`**.

Essa métrica indica mudanças registradas nos metadados do arquivo.

Ela não permite afirmar, isoladamente:

- quantas células foram alteradas;
- quais usuários fizeram as alterações;
- quais regras foram recalculadas;
- quanto tempo o Google Sheets levou para concluir cada recálculo interno.

Ainda assim, demonstra que a fonte permaneceu ativa durante parte da janela monitorada.

---

## 22. Performance da baseline

### 22.1 Abertura da planilha

| Métrica | Resultado |
|---|---:|
| Média | 6,10 s |
| Mediana | 10,67 s |
| P95 | 10,98 s |
| Máximo | 13,89 s |

### 22.2 Leitura das regiões amostradas

| Métrica | Resultado |
|---|---:|
| Média | 3,12 s |
| P95 | 5,59 s |
| Máximo | 9,43 s |

### 22.3 Processamento da amostra

| Métrica | Resultado |
|---|---:|
| Média | 4,03 s |
| P95 | 7,53 s |
| Máximo | 11,11 s |

Esses tempos representam a interação do Apps Script com a planilha e o processamento das métricas coletadas.

Eles não representam diretamente:

- o tempo total de recálculo interno do Google Sheets;
- o tempo percebido por cada usuário;
- o tempo de resposta da interface em todos os dispositivos;
- o impacto de 100 usuários simultâneos.

---

# Parte III — Comparação dos resultados

## 23. Fórmulas distribuídas versus processamento centralizado

### Estrutura baseada em fórmulas

A lógica está distribuída entre milhares de células.

Características observadas:

- 146.701 fórmulas;
- 64.523 buscas `XLOOKUP`;
- 5.129 contagens `COUNTIFS`;
- 173.158 ocorrências de `IF`;
- 151.188 ocorrências de `SUBSTITUTE`;
- padrões diferentes na mesma coluna;
- 18 células com erro;
- manutenção dependente da estrutura da planilha;
- risco de alteração manual;
- dificuldade de auditoria por versão.

### Pipeline centralizado

A lógica é executada em consultas e etapas controladas.

Características observadas:

- regras centralizadas;
- validações antes e depois da promoção;
- publicação de valores prontos;
- zero fórmulas nas abas técnicas publicadas;
- controle de estado;
- backups;
- auditoria;
- recuperação;
- rastreabilidade por ciclo;
- encerramento automático;
- proteção da produção em modo somente leitura.

---

## 24. Principais diferenças

| Critério | Fórmulas na planilha | Pipeline centralizado |
|---|---|---|
| Local da lógica | Células distribuídas | Consultas e scripts versionáveis |
| Risco de alteração manual | Elevado | Reduzido |
| Auditoria | Limitada | Estruturada por ciclo |
| Recuperação | Predominantemente manual | Controlada e registrada |
| Validação antes da publicação | Parcial | Explícita |
| Histórico de execução | Limitado | Logs e estados persistidos |
| Fórmulas nas abas técnicas | 146.701 na estrutura avaliada | 0 nas abas técnicas publicadas |
| Controle de concorrência | Não centralizado | Locks, concessões e leases |
| Encerramento automático | Não aplicável | Validado |
| Rastreamento de incidentes | Disperso | Associado ao ciclo e à etapa |
| Processamento analítico | Distribuído no Sheets | Centralizado no BigQuery |
| Publicação | Resultado do recálculo local | Valores prontos e sanitizados |

---

## 25. Limites da comparação

Os experimentos não permitem afirmar um percentual exato de ganho de velocidade entre os dois modelos.

Isso ocorre porque o Google Sheets não expõe, pelo Apps Script, uma métrica completa e confiável do tempo interno de recálculo de todas as fórmulas.

Portanto, não seria tecnicamente correto declarar, por exemplo, que o pipeline foi uma determinada porcentagem mais rápido.

O que foi comprovado objetivamente foi:

- o tamanho da dependência de fórmulas;
- a existência de erros;
- a concentração de regras em colunas críticas;
- a viabilidade de processar os dados externamente;
- a capacidade de publicar valores sem fórmulas;
- a recorrência automática;
- a integridade do fluxo;
- a recuperação após incidentes;
- o baixo consumo relativo do BigQuery no experimento;
- a permanência do Google Sheets como principal gargalo de publicação.

---

# Parte IV — Conclusões

## 26. Resultado da hipótese

A hipótese técnica foi confirmada.

Foi possível construir e operar um pipeline que:

- detectou mudanças;
- aguardou estabilidade;
- capturou os dados;
- executou validações;
- processou regras;
- promoveu gerações;
- publicou resultados;
- auditou integridade;
- recuperou incidentes;
- concluiu ciclos;
- encerrou automaticamente a janela;
- removeu seus próprios gatilhos;
- preservou a produção em modo somente leitura.

O experimento também demonstrou que o BigQuery Sandbox foi suficiente para a prova técnica executada, sem necessidade de habilitar faturamento durante o período avaliado.

Essa conclusão não significa que o Sandbox seja automaticamente adequado para qualquer cenário de produção. Significa apenas que ele foi suficiente para os volumes, consultas e objetivos deste experimento.

---

## 27. Principal gargalo identificado

O principal gargalo observado foi a publicação de grandes volumes no Google Sheets.

A etapa de publicação apresentou durações superiores às etapas analíticas e chegou a aproximadamente:

- **87,4 segundos** no ciclo consolidado;
- **92,08 segundos** no maior registro histórico relacionado à publicação e sua recuperação.

Portanto, habilitar faturamento no BigQuery não eliminaria o principal gargalo observado, pois a publicação continuaria dependendo da API e da estrutura do Google Sheets.

O faturamento poderia ampliar recursos do BigQuery, mas não resolveria:

- alterações manuais na planilha;
- fórmulas distribuídas;
- inconsistências de preenchimento;
- dependência da interface da planilha;
- concorrência entre usuários;
- dificuldade de manutenção;
- publicação lenta no Sheets;
- ausência de controle transacional na interface operacional.

---

## 28. Resultado de segurança

O comportamento de segurança foi aprovado.

Foram comprovados:

- produção somente leitura;
- isolamento da shadow;
- proteção contra concorrência;
- interrupção em caso de inconsistência;
- preservação de backups;
- retomada controlada;
- auditoria;
- sanitização de valores;
- encerramento automático;
- remoção de gatilhos;
- ausência de resíduos operacionais ao final.

O pipeline não ignorou a falha encontrada. Ele interrompeu o ciclo, preservou evidências e exigiu uma recuperação controlada.

Esse comportamento foi mais relevante para a avaliação de segurança do que uma execução sem qualquer incidente, pois permitiu verificar a resposta real do sistema diante de uma condição inesperada.

---

## 29. Resultado de performance

A performance geral foi aprovada com ressalvas.

Pontos positivos:

- mediana de 2,27 segundos;
- média de 12,72 segundos;
- 86,67% das amostras abaixo de 25 segundos;
- consumo de runtime diário abaixo do orçamento;
- consultas com volume reduzido em relação à cota disponível;
- auditoria concluída em aproximadamente 13,56 segundos.

Ressalvas:

- publicação no Sheets próxima ou superior a um minuto;
- captura e promoção acima da meta genérica de 25 segundos;
- necessidade de metas específicas por tipo de etapa;
- limitação do Apps Script para operações extensas;
- dependência da latência da API do Google Sheets.

Uma meta única de 25 segundos não representa adequadamente todas as etapas. Operações simples e operações de grande volume devem possuir metas separadas.

---

## 30. Resultado de consumo

O consumo do BigQuery foi baixo no contexto da cota avaliada.

O ciclo de referência utilizou aproximadamente:

- 84,7 MiB processados;
- 173 MiB na métrica de bytes faturáveis.

Esse resultado demonstrou que o volume analítico do caso estudado não foi o principal fator limitante.

O limite mais relevante permaneceu associado a:

- publicação na planilha;
- runtime do Apps Script;
- manutenção da estrutura baseada em Sheets;
- governança das alterações operacionais.

---

## 31. Conclusão consolidada

Os experimentos demonstraram que:

1. a estrutura existente possui dependência relevante de fórmulas;
2. a lógica está concentrada em poucas colunas críticas;
3. existem erros de fórmula no conjunto integral;
4. o processamento pode ser centralizado fora das células;
5. o BigQuery Sandbox suportou a prova técnica sem faturamento;
6. o Apps Script conseguiu orquestrar o fluxo completo;
7. a publicação de valores prontos eliminou fórmulas das abas técnicas;
8. a produção permaneceu somente leitura;
9. o pipeline reagiu corretamente a uma falha;
10. a recuperação controlada foi concluída;
11. os ciclos posteriores foram aprovados;
12. a janela terminou automaticamente;
13. nenhum gatilho, lease ou concessão permaneceu ativo;
14. o principal gargalo foi o Google Sheets;
15. habilitar faturamento no BigQuery não resolveria, isoladamente, o problema estrutural.

O estudo não demonstrou apenas que o processamento externo funciona. Ele mostrou que a maior oportunidade está na separação entre:

- entrada operacional;
- regras de negócio;
- processamento;
- armazenamento;
- publicação;
- auditoria;
- interface de consulta.

O resultado sustenta tecnicamente a evolução para uma estrutura em que a planilha não concentre simultaneamente entrada de dados, lógica de negócio, processamento, armazenamento, controle operacional e apresentação.

---

## 32. Classificação final

| Dimensão | Classificação |
|---|---|
| Viabilidade funcional | Aprovada |
| Recorrência automática | Aprovada |
| Integridade | Aprovada |
| Segurança | Aprovada |
| Recuperação de incidentes | Aprovada |
| Encerramento automático | Aprovado |
| Consumo de BigQuery | Aprovado |
| Runtime do Apps Script | Aprovado |
| Performance geral | Aprovada com ressalvas |
| Publicação no Google Sheets | Gargalo identificado |
| Baseline de fórmulas | Concluída |
| Proteção da produção | Aprovada |
| Estado final | Saudável |
| Uso direto como arquitetura final | Não avaliado por este experimento |

---

## 33. Evidências utilizadas

Os resultados apresentados foram consolidados a partir de:

- registros estruturados do Cloud Logging;
- resultados persistidos das etapas operacionais;
- consolidado de performance e consumo;
- resultados das auditorias;
- logs de encerramento automático;
- registros de publicação e validação;
- inventário integral da planilha baseada em fórmulas;
- monitoramento de 24 horas;
- amostras periódicas de leitura;
- registros de incidentes e recuperações.

Os logs e identificadores originais não fazem parte deste repositório.

Todas as informações apresentadas foram agregadas e sanitizadas para impedir a exposição de:

- identificadores reais de planilhas;
- identificadores de projetos;
- identificadores de implantação;
- identificadores de gatilhos;
- chaves de usuário;
- nomes de pessoas;
- documentos;
- e-mails;
- dados de clientes;
- URLs internas;
- hashes operacionais;
- credenciais;
- conteúdo de produção.
