# Matriz de testes e evidências

## 1. Objetivo

Esta matriz relaciona as perguntas da pesquisa experimental com:

- hipóteses;
- métodos;
- testes executados;
- evidências coletadas;
- resultados;
- incidentes;
- limitações;
- documentos correspondentes.

O objetivo é permitir que cada conclusão do repositório seja rastreada até uma evidência observada.

Este arquivo não contém:

- logs brutos;
- dados de produção;
- identificadores reais;
- credenciais;
- nomes de clientes;
- nomes de pessoas;
- IDs de planilhas;
- IDs de projetos;
- IDs de implantação;
- IDs de gatilhos;
- hashes operacionais.

---

## 2. Escopo da matriz

A matriz cobre dois experimentos.

### Experimento A — Pipeline automatizado

Características:

- duração aproximada de 48 horas;
- processamento recorrente;
- BigQuery Sandbox;
- Apps Script;
- origem somente leitura;
- publicação em shadow;
- máquina de estados;
- auditoria;
- recuperação;
- encerramento automático.

### Experimento B — Baseline da planilha

Características:

- duração aproximada de 24 horas;
- intervalo de 15 minutos;
- 96 amostras;
- inventário integral;
- monitoramento somente leitura;
- ausência de BigQuery;
- ausência de escrita na produção;
- encerramento automático.

---

## 3. Classificação das evidências

| Nível | Classificação | Definição |
|---|---|---|
| E1 | Evidência direta | Resultado observado em execução controlada |
| E2 | Evidência consolidada | Resultado derivado de múltiplos registros ou etapas |
| E3 | Inferência técnica | Conclusão compatível com os resultados, mas não testada diretamente |
| E4 | Fora do escopo | Condição não avaliada pelo experimento |

As conclusões principais deste repositório utilizam evidências dos níveis E1 e E2.

Inferências classificadas como E3 são apresentadas como aplicabilidade ou possibilidade, e não como implementação comprovada.

---

## 4. Classificação dos resultados

| Status | Significado |
|---|---|
| Aprovado | Critérios obrigatórios atendidos |
| Aprovado com ressalva | Resultado válido, com limitação ou observação relevante |
| Recuperado | Bloqueio ou incidente tratado e posteriormente validado |
| Bloqueado | Critério obrigatório não atendido naquela execução |
| Não avaliado | Não testado pelo experimento |
| Não aplicável | Não fazia parte do objetivo do teste |

---

## 5. Perguntas da pesquisa

| ID | Pergunta |
|---|---|
| P-01 | É possível processar externamente regras originalmente distribuídas em fórmulas? |
| P-02 | É possível operar o pipeline no BigQuery Sandbox sem faturamento? |
| P-03 | É possível proteger a produção contra escrita durante o experimento? |
| P-04 | É possível detectar mudanças sem ler integralmente as células a cada chamada? |
| P-05 | É possível validar uma geração antes e depois da promoção? |
| P-06 | É possível publicar resultados sem fórmulas nas abas técnicas? |
| P-07 | É possível interromper o fluxo diante de uma inconsistência? |
| P-08 | É possível recuperar o mesmo ciclo sem reiniciar todo o processo? |
| P-09 | É possível executar auditorias automáticas? |
| P-10 | É possível encerrar a janela e remover o gatilho automaticamente? |
| P-11 | Qual componente apresentou o principal gargalo? |
| P-12 | Qual foi o consumo aproximado do BigQuery? |
| P-13 | Qual é o tamanho da dependência de fórmulas da estrutura original? |
| P-14 | Habilitar faturamento resolveria o problema estrutural observado? |
| P-15 | Os resultados permitem afirmar um ganho percentual de velocidade? |

---

## 6. Hipóteses

| ID | Hipótese | Resultado |
|---|---|---|
| H-01 | Regras de planilha podem ser processadas externamente e publicadas como valores | Confirmada |
| H-02 | O Sandbox suporta uma prova técnica recorrente e auditável | Confirmada |
| H-03 | A produção pode permanecer somente leitura durante todo o teste | Confirmada |
| H-04 | Mudanças podem ser detectadas inicialmente por metadados | Confirmada |
| H-05 | Gerações candidatas podem ser validadas antes da promoção | Confirmada |
| H-06 | Uma falha pode interromper o fluxo sem destruir evidências | Confirmada |
| H-07 | Um ciclo interrompido pode ser retomado de forma controlada | Confirmada |
| H-08 | A janela pode ser encerrada sem intervenção manual | Confirmada |
| H-09 | O BigQuery seria o principal gargalo de performance | Rejeitada |
| H-10 | Habilitar faturamento resolveria a dependência estrutural da planilha | Rejeitada |
| H-11 | Seria possível calcular ganho percentual exato sobre as fórmulas | Não confirmada |
| H-12 | A planilha original possui dependência relevante de fórmulas | Confirmada |

---

# Parte I — Matriz do pipeline automatizado

## 7. Proteção da produção

| Campo | Resultado |
|---|---|
| Teste | T-01 |
| Pergunta relacionada | P-03 |
| Hipótese relacionada | H-03 |
| Método | Execução do pipeline com origem configurada como somente leitura |
| Evidência | Checks de segurança, logs estruturados e ausência de operação de escrita |
| Resultado observado | Nenhuma escrita na produção |
| Classificação | Aprovado |
| Nível de evidência | E1 |

### Critérios verificados

- produção e shadow diferentes;
- produção somente leitura;
- nenhuma célula alterada;
- nenhuma aba criada na produção;
- nenhum gatilho instalado na produção;
- nenhuma etapa de publicação direcionada à produção.

### Limitação

O experimento não avaliou uma eventual escrita controlada de retorno à produção.

---

## 8. Detecção de mudança

| Campo | Resultado |
|---|---|
| Teste | T-02 |
| Pergunta relacionada | P-04 |
| Hipótese relacionada | H-04 |
| Método | Comparação de horário de modificação e hash de referência |
| Evidência | Execuções automáticas do detector |
| Resultado observado | Mudanças identificadas sem leitura integral de células |
| Classificação | Aprovado |
| Nível de evidência | E1 |

### Critérios verificados

- mudança de `modifiedTime`;
- mudança de hash de referência;
- ausência de leitura integral das células na etapa de detecção;
- ausência de abertura da shadow durante o detector;
- registro da fonte anterior e da fonte atual.

### Limitação

Metadados indicam que uma alteração ocorreu, mas não identificam isoladamente quais células foram alteradas.

---

## 9. Confirmação de persistência

| Campo | Resultado |
|---|---|
| Teste | T-03 |
| Pergunta relacionada | P-04 |
| Hipótese relacionada | H-04 |
| Método | Confirmação em 8 intervalos e aproximadamente 120 minutos |
| Evidência | Contador de intervalos e minutos pendentes |
| Resultado observado | Ciclo iniciado somente após o limiar |
| Classificação | Aprovado |
| Nível de evidência | E1 |

### Critérios verificados

- 8 intervalos exigidos;
- aproximadamente 120 minutos exigidos;
- nenhuma etapa pesada executada antes do limiar;
- estado preservado durante a espera;
- ciclo criado após a confirmação.

### Limitação

O limiar utilizado pertence ao experimento e não representa recomendação universal.

---

## 10. Captura

| Campo | Resultado |
|---|---|
| Teste | T-04 |
| Pergunta relacionada | P-01 |
| Hipótese relacionada | H-01 |
| Método | Captura controlada após confirmação da mudança |
| Evidência | Resultado da etapa de captura e métricas operacionais |
| Resultado observado | Dados capturados e disponibilizados para validação |
| Classificação | Aprovado com ressalva de performance |
| Nível de evidência | E1 |

### Performance observada

A etapa de captura apresentou duração aproximada de:

- 31,65 segundos em uma das amostras consolidadas.

### Limitação

A performance depende do volume, da origem e das APIs utilizadas.

---

## 11. Geração candidata

| Campo | Resultado |
|---|---|
| Teste | T-05 |
| Pergunta relacionada | P-05 |
| Hipótese relacionada | H-05 |
| Método | Criação de tabelas separadas da geração oficial |
| Evidência | Existência das tabelas candidatas e validações |
| Resultado observado | Candidata criada sem substituir a oficial |
| Classificação | Aprovado |
| Nível de evidência | E1 |

### Critérios verificados

- identidade da candidata;
- schema;
- quantidade de campos;
- quantidade de registros;
- labels;
- retenção;
- vínculo com o ciclo.

---

## 12. Views candidatas

| Campo | Resultado |
|---|---|
| Teste | T-06 |
| Pergunta relacionada | P-05 |
| Hipótese relacionada | H-05 |
| Método | Criação e validação de views sobre as tabelas candidatas |
| Evidência | Diagnósticos e assinaturas das views |
| Resultado observado | Views candidatas criadas e aprovadas |
| Classificação | Aprovado |
| Nível de evidência | E1 |

### Critérios verificados

- existência;
- estrutura;
- contagens;
- assinaturas;
- regras;
- controle;
- compatibilidade com as views oficiais.

---

## 13. Backup

| Campo | Resultado |
|---|---|
| Teste | T-07 |
| Pergunta relacionada | P-05 e P-07 |
| Hipótese relacionada | H-05 e H-06 |
| Método | Preservação da geração oficial antes da promoção |
| Evidência | Backups registrados e validados |
| Resultado observado | Geração anterior preservada |
| Classificação | Aprovado |
| Nível de evidência | E1 |

### Critérios verificados

- backup da tabela principal;
- backup da tabela de apoio;
- schema;
- contagens;
- retenção;
- vínculo com a geração anterior.

---

## 14. Promoção

| Campo | Resultado |
|---|---|
| Teste | T-08 |
| Pergunta relacionada | P-05 |
| Hipótese relacionada | H-05 |
| Método | Substituição controlada da geração oficial pela candidata aprovada |
| Evidência | Resultado da promoção e validação das tabelas oficiais |
| Resultado observado | Candidata promovida |
| Classificação | Aprovado com ressalva de performance |
| Nível de evidência | E1 |

### Performance observada

A promoção apresentou duração aproximada de:

- 31,00 segundos em uma das amostras consolidadas.

### Segurança

As views oficiais permaneceram controladas durante a promoção.

---

## 15. Validação pós-promoção

| Campo | Resultado |
|---|---|
| Teste | T-09 |
| Pergunta relacionada | P-05 e P-07 |
| Hipótese relacionada | H-05 e H-06 |
| Método | Comparação entre candidata, oficial, backups, views e decomposição |
| Evidência | Bloqueio inicial, diagnóstico, correção e nova aprovação |
| Resultado observado | Validação aprovada após correção de falso bloqueio |
| Classificação | Recuperado |
| Nível de evidência | E1 e E2 |

### Incidente

A regra inicial exigia igualdade entre:

- linhas com conteúdo da tabela raw;
- registros da view clean.

A regra era incompatível com filtros de elegibilidade e janela temporal.

### Correção

A condição passou a validar:

`totalClean <= linhasComConteudo`

### Resultado após correção

- 22.344 linhas não incorporadas pela view clean;
- exclusão explicada por regras ou janela temporal;
- tabela oficial igual à candidata;
- views oficiais equivalentes às candidatas;
- backups preservados.

---

## 16. Publicação na shadow

| Campo | Resultado |
|---|---|
| Teste | T-10 |
| Pergunta relacionada | P-01, P-06 e P-11 |
| Hipótese relacionada | H-01 e H-09 |
| Método | Publicação de valores processados em planilha separada |
| Evidência | Métricas de linhas, células, fórmulas e duração |
| Resultado observado | Publicação concluída |
| Classificação | Aprovado com ressalva de performance |
| Nível de evidência | E1 |

### Métricas do ciclo consolidado

- 9.009 linhas;
- 114.575 células;
- zero fórmulas nas abas técnicas;
- 2.340 valores sanitizados;
- aproximadamente 87,4 segundos de duração.

### Conclusão

A publicação no Google Sheets foi o principal gargalo observado.

---

## 17. Validação da publicação

| Campo | Resultado |
|---|---|
| Teste | T-11 |
| Pergunta relacionada | P-06 e P-07 |
| Hipótese relacionada | H-01 e H-06 |
| Método | Verificação posterior das abas publicadas |
| Evidência | Contagens, cabeçalhos, fórmulas, resíduos e estrutura |
| Resultado observado | Publicação aprovada após recuperação |
| Classificação | Recuperado |
| Nível de evidência | E1 e E2 |

### Critérios verificados

- abas técnicas;
- abas de negócio;
- cabeçalhos;
- quantidade de linhas;
- quantidade de células;
- ausência de fórmulas técnicas;
- ausência de abas inesperadas;
- sanitização;
- ausência de staging após recuperação.

---

## 18. Finalização do ciclo

| Campo | Resultado |
|---|---|
| Teste | T-12 |
| Pergunta relacionada | P-08 |
| Hipótese relacionada | H-07 |
| Método | Transição final após aprovação das etapas obrigatórias |
| Evidência | Estado final dos ciclos |
| Resultado observado | Ciclos concluídos e aprovados |
| Classificação | Aprovado |
| Nível de evidência | E2 |

### Consolidado

- 10 ciclos concluídos e aprovados;
- 32 resultados acumulados;
- 31 resultados diretamente aprovados;
- 1 bloqueio histórico recuperado;
- estado final `CICLO_CONCLUIDO`.

---

## 19. Auditoria automática

| Campo | Resultado |
|---|---|
| Teste | T-13 |
| Pergunta relacionada | P-09 |
| Hipótese relacionada | H-02 |
| Método | Execução periódica por gatilho |
| Evidência | Resultado consolidado da auditoria |
| Resultado observado | Integridade aprovada |
| Classificação | Aprovado |
| Nível de evidência | E1 |

### Métricas registradas no consolidado

- parecer de integridade aprovado;
- duração aproximada de 13,56 segundos;
- nenhuma alteração na produção;
- nenhuma alteração de objetos durante a auditoria;
- ausência de resíduos impeditivos.

### Incidente relacionado

Uma comparação histórica de assinaturas precisou ser ajustada para considerar views com janela temporal móvel.

---

## 20. Falha preservada

| Campo | Resultado |
|---|---|
| Teste | T-14 |
| Pergunta relacionada | P-07 |
| Hipótese relacionada | H-06 |
| Método | Indução real de bloqueio durante validação pós-promoção |
| Evidência | Estado de falha, encerramento e preservação |
| Resultado observado | Fluxo interrompido de forma segura |
| Classificação | Aprovado |
| Nível de evidência | E1 |

### Critérios verificados

- nenhuma etapa posterior executada;
- geração promovida preservada;
- backups preservados;
- publicação não iniciada;
- janela encerrada;
- gatilho removido;
- retomada automática impedida.

---

## 21. Retomada controlada

| Campo | Resultado |
|---|---|
| Teste | T-15 |
| Pergunta relacionada | P-08 |
| Hipótese relacionada | H-07 |
| Método | Preflight, autorização temporária e nova janela vinculada ao ciclo |
| Evidência | Resultado da retomada e conclusão do ciclo |
| Resultado observado | Mesmo ciclo retomado na etapa pendente |
| Classificação | Recuperado |
| Nível de evidência | E1 |

### Critérios verificados

- ciclo específico;
- estado esperado;
- etapa anterior aprovada;
- ausência de concessão;
- ausência de lease;
- ausência de gatilho;
- exatamente um novo gatilho;
- executor não chamado durante a ativação;
- continuidade pela etapa pendente.

---

## 22. Encerramento automático

| Campo | Resultado |
|---|---|
| Teste | T-16 |
| Pergunta relacionada | P-10 |
| Hipótese relacionada | H-08 |
| Método | Expiração da janela e chamada automática posterior |
| Evidência | Log de encerramento |
| Resultado observado | Janela encerrada e gatilho removido |
| Classificação | Aprovado |
| Nível de evidência | E1 |

### Resultado

- encerramento automático por prazo;
- um gatilho encontrado;
- um gatilho removido;
- nenhuma intervenção manual;
- nenhum gatilho residual;
- estado operacional preservado.

---

# Parte II — Matriz de consumo e performance

## 23. Consumo do BigQuery

| Campo | Resultado |
|---|---|
| Teste | T-17 |
| Pergunta relacionada | P-02 e P-12 |
| Hipótese relacionada | H-02 |
| Método | Consolidação das métricas de jobs do ciclo aprovado |
| Evidência | Jobs, bytes processados e bytes faturáveis |
| Resultado observado | Consumo abaixo da cota mensal |
| Classificação | Aprovado |
| Nível de evidência | E2 |

### Métricas do ciclo de referência

| Indicador | Resultado |
|---|---:|
| Jobs totais | 13 |
| Jobs com processamento | 9 |
| Bytes processados | 88.789.912 |
| Bytes processados aproximados | 84,7 MiB |
| Bytes faturáveis | 181.403.648 |
| Bytes faturáveis aproximados | 173 MiB |
| Percentual aproximado de 1 TiB | 0,0165% |

### Limitação

As projeções mensais foram calculadas a partir de um ciclo de referência e não representam consumo mensal medido.

---

## 24. Performance do pipeline

| Campo | Resultado |
|---|---|
| Teste | T-18 |
| Pergunta relacionada | P-11 |
| Hipótese relacionada | H-09 |
| Método | Consolidação de 30 amostras |
| Evidência | Durações por etapa |
| Resultado observado | Performance aprovada com ressalvas |
| Classificação | Aprovado com ressalva |
| Nível de evidência | E2 |

### Métricas

| Indicador | Resultado |
|---|---:|
| Amostras | 30 |
| Média | 12.715,33 ms |
| Mediana | 2.269 ms |
| P95 | 62.315,15 ms |
| Mínimo | 304 ms |
| Máximo | 92.083 ms |
| Abaixo de 25 segundos | 86,67% |

### Conclusão

O BigQuery não foi o principal gargalo.

A publicação no Google Sheets apresentou a maior duração entre as etapas operacionais recorrentes.

---

## 25. Orçamento do Apps Script

| Campo | Resultado |
|---|---|
| Teste | T-19 |
| Pergunta relacionada | P-11 |
| Método | Controle de runtime diário |
| Evidência | Orçamento consumido e margem |
| Resultado observado | Consumo abaixo do orçamento |
| Classificação | Aprovado |
| Nível de evidência | E2 |

### Resultados observados

- orçamento diário configurado: 70 minutos;
- consumo final de referência: aproximadamente 10,19 minutos;
- maior acumulado diário observado: aproximadamente 13,36 minutos;
- margem suficiente para auditoria e encerramento.

---

# Parte III — Matriz da baseline de fórmulas

## 26. Monitoramento somente leitura

| Campo | Resultado |
|---|---|
| Teste | T-20 |
| Pergunta relacionada | P-13 |
| Hipótese relacionada | H-12 |
| Método | Monitoramento por 24 horas |
| Evidência | 96 amostras e inventário integral |
| Resultado observado | Baseline concluída sem escrita |
| Classificação | Aprovado |
| Nível de evidência | E1 e E2 |

### Cobertura

| Indicador | Resultado |
|---|---:|
| Amostras previstas | 96 |
| Amostras concluídas | 96 |
| Cobertura | 100% |
| Falhas de coleta | 0 |
| Intervalo | 15 minutos |
| Encerramento | Automático |

---

## 27. Inventário estrutural

| Campo | Resultado |
|---|---|
| Teste | T-21 |
| Pergunta relacionada | P-13 |
| Hipótese relacionada | H-12 |
| Método | Leitura integral em blocos |
| Evidência | Consolidado do inventário |
| Resultado observado | Dependência relevante de fórmulas |
| Classificação | Aprovado |
| Nível de evidência | E1 |

### Métricas

| Indicador | Resultado |
|---|---:|
| Linhas | 75.595 |
| Colunas | 35 |
| Células | 2.645.825 |
| Fórmulas | 146.701 |
| Densidade de fórmulas | 5,54% |
| Colunas com fórmulas | 5 |
| Células com erro | 18 |

---

## 28. Funções encontradas

| Campo | Resultado |
|---|---|
| Teste | T-22 |
| Pergunta relacionada | P-13 |
| Hipótese relacionada | H-12 |
| Método | Classificação das fórmulas do inventário |
| Evidência | Contagem agregada por função |
| Resultado observado | Regras extensas concentradas em poucas colunas |
| Classificação | Aprovado |
| Nível de evidência | E1 |

### Ocorrências

| Função | Ocorrências |
|---|---:|
| `IF` | 173.158 |
| `SUBSTITUTE` | 151.188 |
| `VALUE` | 75.594 |
| `XLOOKUP` | 64.523 |
| `COUNTIFS` | 5.129 |
| `IMPORTRANGE` | 1 |

A quantidade de funções é superior à quantidade de fórmulas porque uma fórmula pode conter várias funções.

---

## 29. Erros de fórmula

| Campo | Resultado |
|---|---|
| Teste | T-23 |
| Pergunta relacionada | P-13 |
| Método | Inventário integral |
| Evidência | Contagem agregada de erros |
| Resultado observado | 18 células com erro |
| Classificação | Aprovado |
| Nível de evidência | E1 |

### Distribuição

| Tipo | Quantidade |
|---|---:|
| `#REF!` | 8 |
| `#VALUE!` | 4 |
| `#ERROR!` | 6 |

A aprovação indica que o inventário foi executado corretamente.

Ela não significa aprovação da qualidade das 18 células identificadas.

---

## 30. Performance da baseline

| Campo | Resultado |
|---|---|
| Teste | T-24 |
| Pergunta relacionada | P-15 |
| Hipótese relacionada | H-11 |
| Método | Coleta de latências durante 96 amostras |
| Evidência | Tempos de abertura, leitura e processamento |
| Resultado observado | Baseline empírica coletada |
| Classificação | Aprovado com limitação |
| Nível de evidência | E2 |

### Abertura

| Métrica | Resultado |
|---|---:|
| Média | 6,10 s |
| Mediana | 10,67 s |
| P95 | 10,98 s |
| Máximo | 13,89 s |

### Leitura

| Métrica | Resultado |
|---|---:|
| Média | 3,12 s |
| P95 | 5,59 s |
| Máximo | 9,43 s |

### Processamento da amostra

| Métrica | Resultado |
|---|---:|
| Média | 4,03 s |
| P95 | 7,53 s |
| Máximo | 11,11 s |

### Limitação

O Apps Script não forneceu o tempo interno completo de recálculo das fórmulas do Google Sheets.

Por isso, o experimento não sustenta uma afirmação de ganho percentual exato.

---

# Parte IV — Hipóteses rejeitadas ou não confirmadas

## 31. BigQuery como principal gargalo

| Campo | Resultado |
|---|---|
| Hipótese | H-09 |
| Resultado | Rejeitada |
| Evidência | Consumo do BigQuery e duração das etapas |
| Conclusão | A publicação no Google Sheets foi mais lenta do que o processamento analítico |

O resultado não significa que o BigQuery nunca possa se tornar um gargalo.

Ele significa que isso não ocorreu no volume e no período avaliados.

---

## 32. Faturamento como solução estrutural

| Campo | Resultado |
|---|---|
| Hipótese | H-10 |
| Resultado | Rejeitada |
| Evidência | Limitações observadas na planilha e no processo de publicação |
| Conclusão | Faturamento amplia capacidades do BigQuery, mas não elimina a dependência estrutural do Sheets |

Os problemas observados incluíam:

- fórmulas distribuídas;
- alterações manuais;
- padrões misturados;
- publicação lenta;
- manutenção;
- concentração de responsabilidades.

---

## 33. Ganho percentual de velocidade

| Campo | Resultado |
|---|---|
| Hipótese | H-11 |
| Resultado | Não confirmada |
| Evidência | Baseline parcial de latência e ausência de tempo interno de recálculo |
| Conclusão | Não existe base suficiente para calcular ganho percentual exato |

O experimento permite comparar:

- arquitetura;
- volume;
- fórmulas;
- erros;
- controle;
- segurança;
- consumo;
- tempos observáveis.

Ele não permite afirmar que o novo modelo é uma porcentagem específica mais rápido que o recálculo interno do Sheets.

---

# Parte V — Incidentes e evidências de recuperação

## 34. Matriz de incidentes

| ID | Incidente | Evidência | Recuperação | Estado final |
|---|---|---|---|---|
| I-01 | Divergência por janela móvel | Auditoria com ressalva | Comparação histórica tornada informativa | Resolvido |
| I-02 | Janela anterior persistida | Bloqueio de ativação | Arquivamento e validação de atividade | Resolvido |
| I-03 | Igualdade incorreta na view clean | Bloqueio pós-promoção | Validação de subconjunto | Resolvido |
| I-04 | Falha preservada | Estado e encerramento | Retomada controlada | Resolvido |
| I-05 | Recuperação da publicação | Resultado histórico bloqueado | Nova validação | Resolvido |
| I-06 | Staging órfão | Aba temporária detectada | Remoção seletiva | Resolvido |
| I-07 | Etapas acima de 25 segundos | Métricas de performance | Reclassificação como ressalva | Registrado |
| I-08 | Divergência de configuração de estados | Validação estrutural | Alerta documentado | Registrado |

---

## 35. Valor experimental dos incidentes

Os incidentes permitiram comprovar:

- interrupção segura;
- preservação de evidências;
- encerramento automático;
- remoção de gatilho;
- bloqueio da retomada automática;
- diagnóstico;
- correção;
- recuperação;
- nova validação;
- conclusão do mesmo ciclo.

Uma execução sem incidentes não teria exercitado todos esses mecanismos.

---

# Parte VI — Segurança e privacidade

## 36. Controles avaliados

| Controle | Evidência | Resultado |
|---|---|---|
| Produção somente leitura | Checks e ausência de escrita | Aprovado |
| Shadow separada | Identidade distinta | Aprovado |
| Locks | Registros de obtenção | Aprovado |
| Concessões | Ausência ou validade controlada | Aprovado |
| Leases | Ausência de concorrência | Aprovado |
| Gatilho único | Contagem e identidade | Aprovado |
| Encerramento | Remoção automática | Aprovado |
| Sanitização | 2.340 valores tratados | Aprovado |
| Logs estruturados | Registros consolidados | Aprovado |
| Ausência de resíduos finais | Estado final | Aprovado |

---

## 37. Privacidade da documentação

A documentação pública utiliza apenas:

- números agregados;
- nomes genéricos;
- descrições técnicas;
- estados abstratos;
- métricas consolidadas;
- dados sintéticos quando aplicável.

Não são incluídos:

- registros individuais;
- conteúdo de produção;
- identificadores do ambiente;
- logs brutos;
- credenciais;
- informações pessoais.

---

# Parte VII — Limitações

## 38. Limitações experimentais

| ID | Limitação | Impacto |
|---|---|---|
| L-01 | Janela de aproximadamente 48 horas | Não representa operação anual |
| L-02 | Baseline de aproximadamente 24 horas | Incluiu período sem expediente |
| L-03 | Uma origem principal | Não comprova consolidação de múltiplas origens |
| L-04 | Ausência de teste com 100 usuários simultâneos | Não comprova capacidade concorrente |
| L-05 | Sandbox sem faturamento | Não testou recursos pagos |
| L-06 | Ausência de streaming | Não comprova operação em tempo real |
| L-07 | Shadow como destino | Não comprova aplicação transacional |
| L-08 | Tempo interno de recálculo indisponível | Impede ganho percentual exato |
| L-09 | Logs públicos sanitizados e agregados | Não permitem reproduzir o ambiente original |
| L-10 | Volume específico | Performance não deve ser generalizada automaticamente |

---

## 39. Condições não avaliadas

Foram classificadas como E4:

- disaster recovery;
- operação entre regiões;
- tolerância a falha regional;
- milhares de usuários;
- latência em milissegundos;
- transações financeiras;
- retenção regulatória;
- aderência integral à LGPD;
- streaming;
- sincronização bidirecional;
- operação offline;
- uso do BigQuery como banco operacional;
- integração com o Celebra Connect.

---

# Parte VIII — Rastreabilidade documental

## 40. Relação entre evidência e documento

| Evidência | Documento principal |
|---|---|
| Arquitetura do experimento | `docs/architecture.md` |
| Método experimental | `docs/methodology.md` |
| Resultados consolidados | `docs/results.md` |
| Sandbox e faturamento | `docs/sandbox-and-billing.md` |
| Incidentes e recuperação | `docs/incidents-and-recovery.md` |
| Aplicabilidade | `docs/use-cases.md` |
| Método de adaptação | `docs/adaptation-guide.md` |
| Segurança pública | `SECURITY.md` |
| Visão geral | `README.md` |

---

## 41. Evidências estruturadas relacionadas

Esta matriz é acompanhada pelos seguintes consolidados sanitizados:

| Arquivo | Finalidade |
|---|---|
| `experimental-summary.json` | Resultado do pipeline automatizado |
| `formula-baseline-summary.json` | Resultado do inventário de fórmulas |
| `performance-summary.json` | Performance e consumo |

Os arquivos JSON contêm somente métricas agregadas.

---

# Parte IX — Conclusão da matriz

## 42. Resultado geral

As evidências sustentam as seguintes conclusões:

1. o pipeline automatizado funcionou durante a janela avaliada;
2. a produção permaneceu somente leitura;
3. o BigQuery Sandbox foi suficiente para a prova técnica;
4. o pipeline concluiu ciclos recorrentes;
5. a geração candidata foi validada;
6. a promoção foi controlada;
7. a publicação utilizou valores sem fórmulas nas abas técnicas;
8. falhas interromperam o fluxo;
9. recuperações foram executadas;
10. a janela foi encerrada automaticamente;
11. o gatilho foi removido;
12. o principal gargalo foi a publicação no Google Sheets;
13. a estrutura original possuía dependência relevante de fórmulas;
14. habilitar faturamento não resolveria o problema estrutural da planilha;
15. não existe evidência suficiente para declarar ganho percentual exato de velocidade.

---

## 43. Classificação final

| Dimensão | Resultado |
|---|---|
| Funcionalidade | Aprovada |
| Recorrência | Aprovada |
| Integridade | Aprovada |
| Segurança | Aprovada |
| Recuperação | Aprovada |
| Encerramento | Aprovado |
| Consumo | Aprovado |
| Performance | Aprovada com ressalvas |
| Baseline | Concluída |
| Generalização automática | Não autorizada |
| Uso como produto pronto | Não comprovado |

A matriz demonstra que as conclusões do repositório estão vinculadas a testes identificáveis e a limitações declaradas.
