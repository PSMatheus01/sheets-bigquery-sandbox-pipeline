# BigQuery Sandbox e faturamento

## 1. Objetivo

Este documento registra a avaliação realizada sobre o uso do BigQuery sem faturamento, as limitações do ambiente Sandbox e as diferenças técnicas identificadas quando comparado a um projeto com faturamento habilitado.

O estudo não teve como motivação uma restrição financeira.

A utilização do Sandbox foi uma decisão experimental para responder às seguintes perguntas:

1. até onde seria possível construir um pipeline automatizado sem habilitar faturamento;
2. quais recursos estariam disponíveis nesse ambiente;
3. quais limitações afetariam o desenho técnico;
4. qual seria o consumo aproximado do caso analisado;
5. se habilitar faturamento resolveria os problemas estruturais observados;
6. se o principal gargalo estava no BigQuery, no Apps Script ou no Google Sheets.

O resultado demonstrou que o Sandbox foi suficiente para a prova técnica realizada, mas que a habilitação de faturamento, isoladamente, não resolveria os problemas estruturais associados ao uso intensivo do Google Sheets.

---

## 2. Escopo da avaliação

A avaliação considerou:

- BigQuery Sandbox;
- consultas SQL;
- tabelas nativas temporárias;
- views;
- tabelas candidatas;
- tabelas oficiais;
- backups temporários;
- expiração automática;
- processamento em lote;
- métricas de bytes processados;
- métricas de bytes faturáveis;
- jobs executados;
- integração com Apps Script;
- publicação de resultados no Google Sheets;
- execução recorrente por gatilho;
- auditoria;
- recuperação de incidentes;
- encerramento automático.

A avaliação não incluiu:

- cobrança financeira real;
- streaming de dados;
- Data Transfer Service;
- contratos de capacidade;
- reservas de slots;
- BigQuery Editions;
- BigQuery ML;
- ingestão contínua pela Storage Write API;
- uso do BigQuery como banco transacional;
- uso do BigQuery na arquitetura do Celebra Connect.

---

## 3. O que é o BigQuery Sandbox

O BigQuery Sandbox permite utilizar um conjunto limitado de funcionalidades do BigQuery sem fornecer cartão de crédito e sem vincular uma conta de faturamento ao projeto.

O ambiente foi criado para aprendizado, experimentação e validação inicial de compatibilidade técnica.

As cotas e limitações atuais documentadas pelo Google incluem:

- até 1 TiB de dados processados em consultas por mês;
- limite vitalício de 10 GiB de armazenamento no Sandbox;
- expiração automática dos recursos após 60 dias;
- indisponibilidade de streaming;
- indisponibilidade de instruções DML;
- indisponibilidade do BigQuery Data Transfer Service.

O limite vitalício de armazenamento do Sandbox não é restaurado pela exclusão dos dados já utilizados. Portanto, ele não deve ser confundido com a franquia mensal de armazenamento disponível em projetos com faturamento habilitado.

A documentação oficial pode ser consultada em:

- [BigQuery Sandbox](https://docs.cloud.google.com/bigquery/docs/sandbox)
- [BigQuery Pricing](https://cloud.google.com/bigquery/pricing)

---

## 4. Limites do Sandbox considerados no experimento

| Recurso | Limite ou comportamento |
|---|---|
| Processamento de consultas | 1 TiB por mês |
| Armazenamento | Limite vitalício de 10 GiB |
| Expiração | Recursos expiram automaticamente após 60 dias |
| Streaming | Não disponível |
| DML | Não disponível |
| Data Transfer Service | Não disponível |
| Conta de faturamento | Não obrigatória |
| Consultas SQL | Disponíveis |
| Jobs de carga em lote | Disponíveis |
| Tabelas nativas | Disponíveis com expiração |
| Views | Disponíveis com expiração |
| Integração por API | Disponível dentro das cotas aplicáveis |

Todos os limites gerais e cotas do BigQuery continuam válidos no Sandbox.

---

## 5. Adaptação do experimento ao Sandbox

O pipeline foi adaptado para respeitar as limitações do ambiente sem faturamento.

As principais adaptações foram:

- criação de tabelas com expiração configurada;
- retenção operacional de até 59 dias;
- ausência de tentativa de transformar as tabelas em recursos sem expiração;
- substituição de operações DML por criação ou substituição controlada de tabelas;
- processamento em lote;
- uso de tabelas candidatas antes da promoção;
- preservação temporária de backups;
- renovação controlada da retenção;
- monitoramento de consumo;
- uso de views para regras analíticas;
- separação entre objetos candidatos e objetos oficiais.

A retenção de 59 dias foi utilizada como margem de segurança em relação ao limite de 60 dias do Sandbox.

---

## 6. Estrutura utilizada sem faturamento

A estrutura experimental conseguiu operar com:

1. leitura da fonte;
2. carregamento em lote;
3. criação de tabelas candidatas;
4. criação de views candidatas;
5. validação de schemas;
6. validação de contagens;
7. comparação de assinaturas;
8. criação de backups temporários;
9. promoção de tabelas;
10. validação pós-promoção;
11. publicação dos resultados;
12. auditoria de integridade;
13. recuperação controlada;
14. encerramento automático.

Isso comprovou que o Sandbox não está limitado apenas a consultas manuais simples.

Dentro das restrições documentadas, foi possível montar um pipeline automatizado, recorrente, auditável e controlado.

---

## 7. Resultado empírico do teste

Um ciclo aprovado registrou:

| Indicador | Resultado |
|---|---:|
| Jobs totais | 13 |
| Jobs com processamento | 9 |
| Bytes processados | 88.789.912 |
| Bytes processados aproximados | 84,7 MiB |
| Bytes faturáveis registrados | 181.403.648 |
| Bytes faturáveis aproximados | 173 MiB |

O experimento foi executado sem faturamento habilitado.

Portanto:

- não houve cobrança financeira;
- os bytes faturáveis foram utilizados como métrica técnica;
- o consumo permaneceu dentro da cota de processamento do Sandbox;
- os recursos criados permaneceram sujeitos à expiração obrigatória.

---

## 8. Bytes processados e bytes faturáveis

Bytes processados e bytes faturáveis não são necessariamente iguais.

Os bytes processados representam o volume que o BigQuery efetivamente analisou durante uma consulta.

Os bytes faturáveis representam o volume considerado pelo modelo de contabilização.

No modelo sob demanda, o BigQuery aplica valores mínimos de processamento por consulta e por tabela referenciada. Isso pode fazer com que a métrica de bytes faturáveis seja superior à quantidade efetivamente processada em consultas pequenas.

A documentação de preços informa, entre outras regras:

- cobrança baseada nas colunas processadas;
- mínimo de 10 MB por consulta;
- mínimo de 10 MB por tabela referenciada;
- consultas atendidas integralmente pelo cache não são cobradas;
- consultas com erro não são cobradas;
- o uso de `LIMIT` não reduz automaticamente o volume processado.

Mais informações estão disponíveis em:

- [BigQuery Pricing](https://cloud.google.com/bigquery/pricing)
- [BigQuery Cost Best Practices](https://docs.cloud.google.com/bigquery/docs/best-practices-costs)

---

## 9. Comparação com a cota mensal

Um ciclo com aproximadamente 173 MiB na métrica de bytes faturáveis corresponde a aproximadamente:

- 0,0165% de 1 TiB;
- cerca de 6.000 ciclos equivalentes para atingir matematicamente 1 TiB.

Essa estimativa não deve ser interpretada como capacidade operacional garantida para 6.000 ciclos.

Antes de alcançar o limite de processamento do BigQuery, outros limites poderiam se tornar relevantes, incluindo:

- runtime diário do Apps Script;
- duração máxima por execução;
- quantidade de gatilhos;
- latência da API do Google Sheets;
- volume de publicação;
- concorrência;
- armazenamento disponível;
- expiração;
- manutenção dos objetos temporários.

A comparação serve apenas para demonstrar que o BigQuery não foi o componente mais próximo do seu limite durante o experimento.

---

## 10. Projeções mensais

Com base no ciclo de referência, foram produzidas projeções teóricas.

| Frequência hipotética | Projeção aproximada |
|---|---:|
| 1 ciclo completo por dia | 5,1 GiB por mês |
| 96 ciclos completos por dia | 486,6 GiB por mês |

Esses valores são projeções, não medições mensais reais.

A frequência de 96 ciclos por dia representa uma hipótese extrema de um ciclo completo a cada 15 minutos.

O comportamento efetivamente testado não executava um ciclo completo a cada chamada do gatilho.

O executor:

1. verificava a existência de mudança;
2. confirmava a persistência da mudança;
3. aguardava o limiar de segurança;
4. iniciava o ciclo somente quando necessário;
5. avançava uma etapa de cada vez;
6. retornava ao estado de espera após a conclusão.

Portanto, a quantidade de chamadas do executor era superior à quantidade de ciclos completos.

---

## 11. Consumo observado e custo financeiro

Como o projeto permaneceu sem faturamento:

- o custo financeiro observado foi zero;
- não existia conta de faturamento vinculada ao projeto;
- não havia possibilidade de cobrança automática pelo BigQuery;
- o uso ficou sujeito às limitações do Sandbox;
- o experimento precisava respeitar a expiração dos recursos.

O custo zero não significa ausência de consumo técnico.

Foram consumidos:

- processamento do BigQuery;
- armazenamento temporário;
- jobs;
- runtime do Apps Script;
- chamadas de API;
- tempo de leitura;
- tempo de publicação;
- capacidade operacional para manutenção do pipeline.

A diferença é que esses consumos permaneceram dentro das cotas disponíveis no ambiente utilizado.

---

## 12. O que funcionou sem faturamento

O experimento comprovou o funcionamento de:

- processamento SQL;
- carregamentos em lote;
- criação de tabelas nativas;
- criação de views;
- tabelas candidatas;
- tabelas oficiais;
- backups temporários;
- promoção controlada;
- validação de schema;
- comparação de contagens;
- comparação de assinaturas;
- consultas consolidadas;
- auditoria;
- automação por Apps Script;
- detecção de mudanças;
- máquina de estados;
- publicação de resultados;
- recuperação de incidentes;
- encerramento automático.

O resultado mostra que um projeto sem faturamento pode ser utilizado para uma prova de conceito tecnicamente relevante, desde que a arquitetura seja adaptada às limitações do Sandbox.

---

## 13. O que não estava disponível

O Sandbox não disponibilizou:

- streaming de dados;
- instruções DML;
- BigQuery Data Transfer Service;
- armazenamento permanente sem expiração;
- retenção histórica ilimitada;
- recursos que dependem de faturamento;
- expansão de capacidade além das cotas gratuitas.

Essas limitações influenciaram diretamente o desenho do pipeline.

O experimento utilizou processamento em lote e substituição controlada de gerações, em vez de depender de atualizações transacionais contínuas.

---

## 14. Expiração de recursos

No Sandbox, datasets, tabelas, views e partições ficam sujeitos à expiração automática após 60 dias.

No experimento, as tabelas nativas foram configuradas com retenção de até 59 dias.

Isso permitiu:

- respeitar o limite do ambiente;
- manter margem de segurança;
- identificar recursos próximos da expiração;
- renovar objetos quando necessário;
- impedir a expectativa de retenção permanente.

A expiração não foi tratada como erro.

Ela foi incorporada ao modelo operacional do experimento.

---

## 15. Consequências da expiração

A expiração obrigatória exige atenção para:

- renovação de tabelas;
- reconstrução de objetos;
- preservação de dados históricos;
- continuidade de views;
- dependências entre tabelas;
- backups temporários;
- auditorias com períodos maiores;
- reprodução de resultados antigos.

Por esse motivo, o Sandbox não deve ser tratado como armazenamento histórico permanente.

No experimento, ele foi utilizado como ambiente analítico temporário e controlado.

---

## 16. Limite de armazenamento

O Sandbox disponibiliza um limite vitalício de 10 GiB de armazenamento.

Segundo a documentação oficial, essa cota não é restaurada quando os dados são excluídos.

Essa característica é diferente da franquia de armazenamento gratuito disponível em um projeto com faturamento habilitado.

No experimento, o volume armazenado foi compatível com o limite disponível, mas o comportamento vitalício impede considerar o Sandbox como repositório permanente de crescimento contínuo.

---

## 17. Habilitação de faturamento

Habilitar faturamento remove as limitações específicas do Sandbox e permite o uso mais amplo dos recursos do BigQuery.

Entre as mudanças possíveis estão:

- remoção da expiração obrigatória de 60 dias;
- configuração própria de retenção;
- armazenamento acima do limite vitalício do Sandbox;
- uso de DML;
- uso de streaming;
- uso do BigQuery Data Transfer Service;
- acesso a modelos de capacidade;
- uso de recursos adicionais da plataforma;
- possibilidade de ultrapassar a franquia gratuita.

Entretanto, habilitar faturamento também cria a possibilidade de cobrança por:

- processamento de consultas;
- armazenamento;
- streaming;
- transferência de dados;
- serviços adicionais;
- capacidade reservada;
- recursos integrados.

---

## 18. Franquia gratuita com faturamento habilitado

Um projeto com faturamento habilitado ainda pode utilizar franquias gratuitas do BigQuery.

A documentação de preços informa:

- primeiro 1 TiB de consultas sob demanda por mês sem cobrança;
- primeiros 10 GiB mensais de armazenamento sem cobrança, conforme o modelo aplicável;
- operações gratuitas específicas;
- cache de consultas sem cobrança;
- carregamentos em lote gratuitos no pool compartilhado padrão.

Isso significa que habilitar faturamento não gera necessariamente custo imediato.

Contudo, deixa de existir a barreira que impedia cobranças.

Se o consumo ultrapassar as franquias ou utilizar serviços cobrados, os valores serão direcionados para a conta de faturamento vinculada.

---

## 19. Comparação entre os ambientes

| Critério | Sandbox | Faturamento habilitado |
|---|---|---|
| Conta de faturamento | Não obrigatória | Obrigatória |
| Possibilidade de cobrança | Não | Sim |
| Consultas gratuitas | Até 1 TiB por mês | Primeiro 1 TiB por mês |
| Armazenamento gratuito | 10 GiB vitalícios | Franquia mensal aplicável |
| Expiração obrigatória | 60 dias | Não imposta pelo Sandbox |
| DML | Não disponível | Disponível |
| Streaming | Não disponível | Disponível |
| Data Transfer Service | Não disponível | Disponível |
| Retenção permanente | Não | Configurável |
| Crescimento contínuo | Limitado | Possível mediante controle |
| Controle de custos | Cotas do Sandbox | Orçamentos, alertas e limites |
| Capacidade reservada | Não utilizada | Disponível |
| Adequação a experimentos | Alta | Alta |
| Adequação a retenção prolongada | Baixa | Maior |

---

## 20. Faturamento não significa arquitetura pronta

A habilitação de faturamento não transforma automaticamente uma prova de conceito em solução de produção.

Mesmo com faturamento, ainda seria necessário revisar:

- modelo de dados;
- retenção;
- particionamento;
- clustering;
- estratégia de ingestão;
- idempotência;
- recuperação;
- auditoria;
- permissões;
- segregação de ambientes;
- monitoramento;
- alertas;
- custos;
- governança;
- manutenção;
- integração com a aplicação;
- continuidade operacional.

O faturamento amplia capacidades técnicas.

Ele não substitui decisões de arquitetura.

---

## 21. Faturamento não resolve o problema estrutural da planilha

O principal problema identificado não foi a ausência de faturamento.

O problema estrutural estava na concentração de responsabilidades no Google Sheets.

A planilha avaliada acumulava:

- entrada de dados;
- lógica de negócio;
- processamento;
- cruzamentos;
- tratamento de texto;
- buscas;
- contagens;
- armazenamento;
- interface operacional;
- manutenção manual;
- apresentação de resultados.

Foram encontradas:

- 75.595 linhas;
- 35 colunas;
- 2.645.825 células;
- 146.701 fórmulas;
- 64.523 fórmulas com `XLOOKUP`;
- 5.129 fórmulas com `COUNTIFS`;
- 18 células com erro;
- padrões misturados em uma coluna crítica.

Habilitar faturamento no BigQuery não removeria nenhuma dessas características automaticamente.

---

## 22. Gargalo observado

O principal gargalo do experimento foi a publicação no Google Sheets.

A etapa de publicação registrou aproximadamente:

- 9.009 linhas;
- 114.575 células;
- 2.340 valores sanitizados;
- 87,4 segundos de duração;
- zero fórmulas nas abas técnicas publicadas.

O BigQuery processou o ciclo de referência com aproximadamente:

- 84,7 MiB processados;
- 173 MiB na métrica de bytes faturáveis.

O volume analítico permaneceu pequeno em relação à cota mensal.

A operação mais lenta foi a transferência e publicação dos resultados no Sheets.

---

## 23. Efeito do faturamento sobre o gargalo

Habilitar faturamento poderia ampliar os recursos do BigQuery, mas não aceleraria automaticamente:

- chamadas da API do Google Sheets;
- escrita de milhares de células;
- abertura da planilha;
- concorrência entre usuários;
- recálculo de fórmulas;
- alterações manuais;
- formatações;
- validações locais;
- publicação por Apps Script.

Por isso, o faturamento não foi classificado como solução para o gargalo observado.

O gargalo estava na camada de interface e publicação, não na capacidade analítica disponível.

---

## 24. Controles de custo aplicáveis

Em um projeto com faturamento, o BigQuery disponibiliza mecanismos para reduzir o risco de consumo inesperado.

Entre os mecanismos documentados estão:

- estimativa de bytes antes da consulta;
- definição de máximo de bytes faturáveis;
- cotas personalizadas;
- orçamentos;
- alertas;
- particionamento;
- clustering;
- seleção apenas das colunas necessárias;
- uso de cache;
- monitoramento de jobs;
- acompanhamento por relatórios de faturamento.

Esses controles ajudam a administrar o consumo.

Eles não substituem:

- validação de consultas;
- revisão de arquitetura;
- controle de permissões;
- testes;
- observabilidade;
- governança operacional.

---

## 25. Processamento sob demanda

O modelo avaliado foi compatível com consultas sob demanda.

Nesse modelo:

- o consumo é calculado pelo volume de dados analisado;
- a seleção de colunas influencia o volume processado;
- `SELECT *` pode aumentar o consumo;
- `LIMIT` não reduz necessariamente a leitura;
- particionamento pode reduzir o volume analisado;
- clustering pode permitir eliminação de blocos;
- consultas armazenadas em cache podem não gerar novo processamento faturável.

O experimento utilizou consultas controladas e volumes relativamente pequenos.

Não foi necessário contratar capacidade reservada.

---

## 26. Interpretação correta do resultado

O resultado não deve ser interpretado como:

> O Sandbox substitui qualquer ambiente de produção.

A interpretação correta é:

> O Sandbox foi suficiente para construir, executar e validar a prova técnica realizada, dentro do volume, da duração e das limitações do experimento.

Também não deve ser interpretado como:

> Habilitar faturamento resolveria os problemas encontrados.

A interpretação correta é:

> O faturamento ampliaria as capacidades do BigQuery, mas não eliminaria a dependência estrutural do Google Sheets nem o gargalo de publicação observado.

---

## 27. Separação do Celebra Connect

O estudo com BigQuery e Apps Script é independente do Celebra Connect.

O BigQuery foi utilizado porque o experimento investigava o potencial do ecossistema Google dentro do contexto analisado.

O Celebra Connect possui outra finalidade e outra arquitetura.

A estrutura definida para o produto utiliza:

- aplicação web;
- backend em Node.js;
- banco de dados PostgreSQL;
- execução em contêineres;
- interface por perfil;
- regras mantidas fora das fórmulas da planilha.

O BigQuery não foi definido como banco de dados do Celebra Connect.

Os códigos experimentais deste repositório não devem ser confundidos com os códigos do produto.

---

## 28. Conhecimento reaproveitado

Embora o BigQuery não faça parte da arquitetura do Celebra Connect, o experimento produziu conhecimentos reutilizáveis.

Entre eles:

- validação antes da promoção;
- uso de gerações candidatas;
- backups;
- idempotência;
- controle de estado;
- locks;
- leases;
- detecção de mudanças;
- auditoria;
- recuperação;
- publicação segura;
- sanitização;
- logs estruturados;
- encerramento automático;
- preservação de evidências.

Esses princípios são independentes da tecnologia específica utilizada para processamento.

---

## 29. Decisão técnica registrada

A decisão resultante do estudo foi:

1. o BigQuery Sandbox foi adequado à prova técnica;
2. o experimento funcionou sem faturamento;
3. o consumo analítico ficou muito abaixo da cota mensal;
4. a expiração e o limite vitalício de armazenamento restringem uso prolongado;
5. habilitar faturamento ampliaria capacidades;
6. habilitar faturamento também exigiria novos controles;
7. o faturamento não resolveria o problema estrutural da planilha;
8. o principal gargalo observado foi a publicação no Google Sheets;
9. o BigQuery não integra a arquitetura do Celebra Connect;
10. o estudo permanece válido como demonstração técnica independente.

---

## 30. Conclusão

A execução sem faturamento não foi uma simulação superficial.

O ambiente suportou:

- automação;
- processamento;
- recorrência;
- validação;
- promoção;
- auditoria;
- recuperação;
- publicação;
- encerramento automático.

O consumo do BigQuery permaneceu baixo em relação à cota disponível.

As maiores limitações estavam associadas a:

- retenção;
- expiração;
- armazenamento;
- ausência de DML;
- ausência de streaming;
- indisponibilidade do Data Transfer Service.

Mesmo que essas limitações fossem removidas por meio da habilitação de faturamento, o principal problema identificado continuaria existindo: a dependência operacional do Google Sheets.

O experimento demonstrou que o BigQuery conseguia processar os dados de forma eficiente. Também demonstrou que manter o Sheets como camada central de publicação e operação preservava gargalos, riscos de manutenção e dependência de uma interface que não foi criada para funcionar como sistema operacional completo.

Assim, o resultado do estudo não foi uma recomendação automática para habilitar faturamento.

O resultado foi uma comprovação de que:

- o processamento externo é tecnicamente viável;
- o Sandbox é suficiente para experimentos controlados;
- faturamento e arquitetura são decisões diferentes;
- aumentar capacidade não corrige, sozinho, um desenho estrutural inadequado;
- a evolução real depende da separação entre interface, regras, processamento, armazenamento e auditoria.

---

## 31. Referências oficiais

- [BigQuery Sandbox](https://docs.cloud.google.com/bigquery/docs/sandbox)
- [BigQuery Pricing](https://cloud.google.com/bigquery/pricing)
- [BigQuery Cost Best Practices](https://docs.cloud.google.com/bigquery/docs/best-practices-costs)
- [BigQuery Quotas and Limits](https://docs.cloud.google.com/bigquery/quotas)
- [Introduction to BigQuery](https://docs.cloud.google.com/bigquery/docs/introduction)
