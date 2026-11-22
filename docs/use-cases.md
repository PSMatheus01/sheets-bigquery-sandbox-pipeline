# Casos de uso e aplicabilidade

## 1. Objetivo

Este documento apresenta os casos de uso diretamente comprovados pelo experimento e as aplicações tecnicamente compatíveis com os mecanismos avaliados.

A análise diferencia:

- capacidades comprovadas;
- aplicações compatíveis;
- aplicações que exigiriam novos testes;
- usos adequados do Google Sheets;
- usos inadequados do Google Sheets;
- limites de generalização;
- critérios de aderência.

O objetivo não é afirmar que todos os cenários apresentados foram implementados.

O objetivo é demonstrar onde os princípios validados podem ser aplicados, desde que cada novo contexto seja submetido à sua própria análise técnica.

---

## 2. Classificação das evidências

As aplicações deste documento utilizam três classificações.

| Classificação | Significado |
|---|---|
| Comprovado | Executado e validado durante o experimento |
| Compatível | Coerente com os mecanismos testados, mas não implementado no contexto citado |
| Fora do escopo | Não testado e não sustentado pelas evidências disponíveis |

Essa separação impede que uma capacidade experimental seja apresentada como produto pronto.

---

## 3. Capacidades comprovadas

O experimento comprovou:

- leitura de uma fonte em modo somente leitura;
- detecção de mudanças por metadados;
- confirmação de persistência da mudança;
- processamento recorrente;
- carregamento em lote;
- criação de tabelas candidatas;
- criação de views candidatas;
- comparação entre gerações;
- promoção controlada;
- preservação de backups;
- validação antes e depois da promoção;
- publicação em ambiente shadow;
- publicação de valores sem fórmulas;
- sanitização de textos;
- controle por máquina de estados;
- controle de concorrência;
- auditoria de integridade;
- recuperação após bloqueio;
- encerramento automático;
- remoção de gatilhos;
- monitoramento somente leitura de uma planilha;
- inventário de fórmulas;
- identificação de erros;
- coleta de métricas de performance;
- operação no BigQuery Sandbox sem faturamento.

---

## 4. Capacidades não comprovadas

O experimento não comprovou:

- operação transacional em tempo real;
- milhares de usuários simultâneos;
- disponibilidade contínua durante todo o ano;
- ingestão por streaming;
- processamento de eventos em milissegundos;
- uso do BigQuery como banco operacional;
- substituição integral de um sistema transacional;
- sincronização bidirecional;
- edição simultânea de registros por aplicações diferentes;
- recuperação entre regiões;
- disaster recovery;
- funcionamento offline;
- uso em dados regulados sem análise adicional;
- aderência automática à LGPD;
- uso do pipeline experimental como produto final;
- integração do BigQuery ao Celebra Connect.

Esses cenários exigiriam arquitetura, testes e controles adicionais.

---

# Parte I — Casos de uso comprovados

## 5. Processamento externo de regras originalmente mantidas em fórmulas

### Classificação

**Comprovado**

### Problema

Uma planilha concentrava regras de tratamento e cruzamento de dados em milhares de fórmulas.

O inventário identificou:

- 75.595 linhas;
- 35 colunas;
- 2.645.825 células;
- 146.701 fórmulas;
- 64.523 ocorrências de `XLOOKUP`;
- 5.129 ocorrências de `COUNTIFS`;
- 18 células com erro.

### Aplicação comprovada

O experimento transferiu parte do processamento para consultas SQL e publicou valores prontos nas abas técnicas.

A publicação avaliada apresentou:

- 9.009 linhas;
- 114.575 células;
- zero fórmulas nas abas técnicas;
- 2.340 valores sanitizados.

### Resultado

Foi comprovado que regras originalmente distribuídas em fórmulas podem ser centralizadas e publicadas como valores processados.

Isso não significa que toda fórmula de qualquer planilha possa ser convertida automaticamente.

Cada regra precisa ser identificada, documentada e validada.

---

## 6. Atualização em lote após mudança confirmada

### Classificação

**Comprovado**

### Problema

Executar um processamento completo após qualquer alteração pode gerar:

- processamento desnecessário;
- leitura durante edição;
- publicação de estado intermediário;
- ciclos concorrentes;
- consumo excessivo.

### Aplicação comprovada

O detector utilizou metadados da fonte e exigiu:

- mudança identificada;
- persistência por 8 intervalos;
- aproximadamente 120 minutos de confirmação;
- ausência de outra execução concorrente.

### Resultado

O ciclo só era iniciado após a confirmação da mudança.

O intervalo utilizado foi uma decisão de segurança específica do experimento, não uma recomendação universal.

---

## 7. Publicação em ambiente shadow

### Classificação

**Comprovado**

### Problema

Alterar diretamente o ambiente de produção aumentaria o risco de:

- publicar dados incompletos;
- substituir resultados aprovados;
- interromper usuários;
- dificultar rollback;
- misturar teste e operação.

### Aplicação comprovada

O pipeline publicou em uma planilha shadow separada da produção.

A produção permaneceu:

- somente leitura;
- sem gatilhos do experimento;
- sem alteração de células;
- sem alteração de estrutura;
- sem publicação direta.

### Resultado

Foi possível testar o fluxo completo sem substituir a estrutura operacional original.

---

## 8. Validação por geração candidata

### Classificação

**Comprovado**

### Problema

Substituir uma tabela oficial antes de validar a nova geração pode tornar uma inconsistência imediatamente visível para os consumidores.

### Aplicação comprovada

O pipeline utilizou:

1. geração candidata;
2. views candidatas;
3. validação de schema;
4. validação de contagens;
5. validação de assinaturas;
6. backup da geração oficial;
7. promoção;
8. validação pós-promoção.

### Resultado

A geração candidata precisava ser aprovada antes de substituir a geração oficial.

---

## 9. Preservação e recuperação

### Classificação

**Comprovado**

### Problema

Uma validação posterior à promoção pode identificar um problema somente depois que a nova geração já foi criada.

### Aplicação comprovada

O fluxo preservou:

- backup da geração anterior;
- geração promovida;
- resultados das etapas;
- estado do ciclo;
- métricas de diagnóstico;
- histórico do bloqueio.

Quando uma validação falhou:

- o ciclo não avançou;
- a janela foi encerrada;
- o gatilho foi removido;
- a geração foi preservada;
- a retomada exigiu autorização.

### Resultado

O experimento validou interrupção segura e recuperação controlada.

---

## 10. Auditoria periódica

### Classificação

**Comprovado**

### Problema

Uma publicação pode permanecer ativa por horas sem uma verificação posterior.

### Aplicação comprovada

A auditoria verificou:

- integridade das abas;
- ausência de fórmulas inesperadas;
- ausência de resíduos;
- assinaturas;
- contagens;
- identidade do ciclo;
- proteção da produção.

### Resultado

A auditoria foi executada por gatilho e concluiu com integridade aprovada.

---

## 11. Monitoramento somente leitura de planilha legada

### Classificação

**Comprovado**

### Problema

Antes de propor uma modernização, era necessário dimensionar a estrutura existente sem interferir na operação.

### Aplicação comprovada

O monitoramento foi executado durante 24 horas e coletou:

- 96 de 96 amostras;
- 100% de cobertura;
- zero falhas de coleta;
- dimensões da planilha;
- total de fórmulas;
- distribuição por coluna;
- funções utilizadas;
- erros;
- latências;
- alterações de metadados.

O monitor não:

- escreveu na produção;
- alterou fórmulas;
- criou abas;
- executou BigQuery;
- instalou gatilho na produção.

### Resultado

Foi possível produzir uma baseline técnica sem modificar a fonte operacional.

---

## 12. Prova de conceito sem faturamento

### Classificação

**Comprovado**

### Problema

Era necessário determinar até onde o ecossistema Google poderia ser utilizado sem habilitar faturamento.

### Aplicação comprovada

O BigQuery Sandbox suportou:

- cargas em lote;
- tabelas nativas;
- views;
- consultas;
- promoção;
- validação;
- auditoria;
- processamento recorrente.

### Resultado

O ambiente sem faturamento foi suficiente para a prova técnica, respeitando:

- expiração;
- limite de armazenamento;
- ausência de DML;
- ausência de streaming;
- ausência do Data Transfer Service.

---

# Parte II — Aplicações tecnicamente compatíveis

## 13. Critério de compatibilidade

Os casos desta parte não foram implementados no experimento.

Eles são considerados compatíveis porque compartilham características com o problema testado:

- entrada estruturada ou semiestruturada;
- processamento em lote;
- necessidade de validação;
- geração de indicadores;
- tolerância a atualização periódica;
- possibilidade de separar origem e destino;
- necessidade de auditoria;
- ausência de transações em tempo real.

A compatibilidade não elimina a necessidade de testes específicos.

---

## 14. Consolidação de indicadores comerciais

### Classificação

**Compatível**

Uma estrutura semelhante pode consolidar:

- leads recebidos;
- contatos realizados;
- conversões;
- perdas;
- produtividade;
- metas;
- indicadores por equipe;
- indicadores por período.

A aderência é maior quando:

- os dados podem ser processados em lote;
- as regras são determinísticas;
- os indicadores não exigem atualização em milissegundos;
- existe uma fonte identificável;
- existe uma estrutura de destino validável.

---

## 15. Controle de operações de atendimento

### Classificação

**Compatível**

Os mecanismos podem ser adaptados para:

- classificação de atendimentos;
- contagem de ocorrências;
- identificação de pendências;
- consolidação por operador;
- consolidação por supervisor;
- acompanhamento por período;
- verificação de regras operacionais.

Não foi comprovada a adequação do pipeline experimental para controlar diretamente uma operação em tempo real.

O uso compatível está relacionado ao processamento analítico e à consolidação periódica.

---

## 16. Validação de qualidade de dados

### Classificação

**Compatível**

A estrutura de geração candidata e validação pode ser utilizada para verificar:

- campos obrigatórios;
- tipos inválidos;
- datas inconsistentes;
- duplicidades;
- códigos inexistentes;
- relações não encontradas;
- padrões divergentes;
- valores fora de domínio.

Os registros inválidos podem ser separados antes da promoção.

O experimento comprovou o princípio de bloquear a continuidade quando uma validação obrigatória não é aprovada.

---

## 17. Consolidação de bases departamentais

### Classificação

**Compatível**

Uma organização pode possuir arquivos separados por:

- equipe;
- unidade;
- operação;
- mês;
- região;
- canal;
- parceiro.

O processamento em lote pode consolidar essas fontes em uma estrutura comum.

A adaptação exigiria:

- definição de schema;
- identificação da origem;
- regras de deduplicação;
- tratamento de conflitos;
- rastreabilidade;
- testes de volume;
- política de atualização.

---

## 18. Apuração periódica de resultados

### Classificação

**Compatível**

O modelo pode ser aplicado a apurações:

- diárias;
- semanais;
- mensais;
- por fechamento;
- por campanha;
- por ciclo operacional.

O uso é mais adequado quando o resultado pode ser reconstruído a partir da origem e das regras documentadas.

---

## 19. Homologação de regras

### Classificação

**Compatível**

Uma planilha pode continuar sendo utilizada para:

- experimentar uma regra;
- comparar versões;
- simular resultados;
- revisar exceções;
- validar entendimento;
- obter aprovação do Planejamento.

Após a validação, a regra pode ser formalizada em uma camada controlada.

Esse uso preserva a flexibilidade da planilha sem transformá-la no único local definitivo da regra.

---

## 20. Monitoramento de estruturas legadas

### Classificação

**Compatível**

O monitor somente leitura pode ser adaptado para inventariar:

- fórmulas;
- erros;
- dimensões;
- padrões por coluna;
- abas;
- latência de leitura;
- alterações de metadados;
- crescimento da estrutura.

A coleta deve respeitar:

- privacidade;
- permissões;
- limites de API;
- horário operacional;
- ausência de escrita;
- proteção de conteúdo sensível.

---

## 21. Comparação entre gerações

### Classificação

**Compatível**

O modelo de assinatura e contagem pode auxiliar na comparação entre:

- versão anterior e nova;
- candidato e oficial;
- origem e destino;
- resultado bruto e tratado;
- publicação e validação.

Assinaturas não substituem validação semântica.

Elas funcionam como evidência adicional de consistência.

---

## 22. Publicação de valores prontos

### Classificação

**Compatível**

Quando uma planilha precisa permanecer como meio de consulta ou integração, o processamento pode publicar:

- valores;
- indicadores;
- classificações;
- status;
- resumos;
- totais;
- alertas.

A publicação de valores reduz a necessidade de reproduzir toda a lógica em fórmulas.

Ela não elimina limitações de:

- escrita na API;
- volume de células;
- concorrência;
- interface;
- permissões;
- alterações manuais.

---

# Parte III — Usos do Google Sheets

## 23. Usos adequados

O experimento não concluiu que o Google Sheets deve ser eliminado.

A planilha continua adequada para atividades como:

- exploração inicial;
- prototipação;
- testes de regra;
- simulações;
- homologação;
- revisão manual;
- importação controlada;
- exportação;
- análises pontuais;
- conferência visual;
- coleta limitada de dados;
- colaboração de pequena escala;
- validação com usuários de negócio.

A principal vantagem da planilha é a flexibilidade.

Essa vantagem é relevante quando o processo ainda está sendo compreendido ou quando a alteração precisa ser validada rapidamente.

---

## 24. Uso como fonte integrada

Uma planilha pode permanecer como fonte de dados de uma estrutura externa.

Nesse cenário:

- usuários continuam alimentando a planilha;
- uma integração lê a fonte;
- o backend aplica validações;
- os dados são armazenados em estrutura controlada;
- a interface oficial consulta o banco;
- a planilha não concentra toda a lógica;
- alterações continuam sendo testadas antes da implementação.

Esse modelo não foi implementado pelo pipeline experimental como produto final.

Ele representa a forma como uma fonte legada pode ser integrada sem exigir substituição imediata do processo de entrada.

---

## 25. Usos inadequados

O Google Sheets apresenta risco quando passa a acumular simultaneamente:

- banco de dados;
- motor de regras;
- interface operacional;
- sistema de permissões;
- trilha de auditoria;
- processamento;
- armazenamento histórico;
- integração;
- relatório;
- controle transacional.

O risco aumenta em cenários com:

- muitos usuários simultâneos;
- fórmulas extensas;
- regras críticas;
- dados sensíveis;
- necessidade de disponibilidade elevada;
- necessidade de rastrear cada alteração;
- necessidade de segregação por perfil;
- grande volume de dados;
- integrações frequentes;
- dependência de manutenção manual;
- consequências operacionais imediatas.

---

## 26. Facilidade aparente de manutenção

A afirmação de que planilhas são fáceis de manter precisa considerar:

- quantidade de fórmulas;
- extensão das fórmulas;
- repetição por linha;
- dependências entre abas;
- referências externas;
- padrões diferentes na mesma coluna;
- permissões;
- erros silenciosos;
- alterações manuais;
- conhecimento concentrado em poucas pessoas.

Uma alteração simples de interface pode exigir a revisão de milhares de fórmulas dependentes.

A facilidade de editar não é equivalente à facilidade de manter.

---

## 27. Efeito bola de neve

O efeito bola de neve ocorre quando uma solução criada para resolver um problema pontual passa a receber novas responsabilidades.

Um ciclo comum é:

1. uma coluna é adicionada;
2. uma fórmula é criada;
3. a fórmula é replicada;
4. outra aba passa a depender dela;
5. uma integração utiliza a nova coluna;
6. uma regra adicional é incorporada;
7. exceções são adicionadas;
8. o responsável original deixa de ser o único mantenedor;
9. a estrutura se torna difícil de reconstruir.

O inventário realizado demonstrou características compatíveis com esse tipo de crescimento:

- milhares de fórmulas;
- funções aninhadas;
- buscas em grande escala;
- padrões misturados;
- erros existentes;
- regras distribuídas.

---

# Parte IV — Exemplos de aplicação por área

## 28. Operações comerciais

### Aplicações compatíveis

- consolidação de leads;
- classificação de oportunidades;
- acompanhamento de produtividade;
- análise de conversão;
- comparação entre equipes;
- validação de metas;
- consolidação por campanha.

### Limites

O pipeline experimental não substitui:

- CRM;
- distribuição transacional;
- controle de acesso por usuário;
- atualização em tempo real;
- histórico completo de interação.

---

## 29. Planejamento

### Aplicações compatíveis

- consolidação de indicadores;
- validação de regras;
- comparação de períodos;
- simulação de cenários;
- acompanhamento de desvios;
- análise de capacidade;
- inventário de fontes;
- auditoria de resultados.

O uso é compatível com o papel de Planejamento como camada de análise e governança.

---

## 30. Qualidade

### Aplicações compatíveis

- identificação de dados inválidos;
- classificação de exceções;
- contagem de inconsistências;
- comparação entre gerações;
- acompanhamento de correções;
- geração de indicadores de qualidade.

A decisão automática sobre registros sensíveis exigiria regras e validações específicas.

---

## 31. Financeiro

### Aplicações compatíveis

- consolidação de lançamentos;
- validação de campos;
- comparação de totais;
- fechamento periódico;
- identificação de divergências.

### Requisitos adicionais

Aplicações financeiras podem exigir:

- controles de acesso mais rigorosos;
- segregação de funções;
- rastreabilidade detalhada;
- retenção definida;
- conciliação;
- aprovação formal;
- requisitos regulatórios.

Esses requisitos não foram avaliados pelo experimento.

---

## 32. Recursos humanos

### Aplicações compatíveis

- consolidação de indicadores não sensíveis;
- acompanhamento de capacidade;
- agrupamento por unidade;
- validação de estruturas;
- geração de resumos.

### Requisitos adicionais

Dados pessoais exigem:

- base legal;
- minimização;
- controle de acesso;
- retenção;
- proteção;
- auditoria;
- análise de privacidade.

A aderência à LGPD não foi comprovada pelo experimento.

---

## 33. Estoque e logística

### Aplicações compatíveis

- consolidação de inventários periódicos;
- identificação de divergências;
- comparação entre fontes;
- classificação de itens;
- geração de indicadores.

### Limites

O modelo experimental não foi validado para:

- reserva transacional de estoque;
- baixa simultânea;
- rastreamento em tempo real;
- controle de concorrência entre pedidos;
- operação offline.

---

## 34. Escritórios parceiros e operações white label

### Classificação

**Compatível como conceito**

Os princípios podem apoiar estruturas adaptadas para diferentes operações, desde que exista:

- separação de dados;
- isolamento por organização;
- configuração de regras;
- identidade visual própria;
- permissões;
- auditoria;
- suporte;
- governança.

O experimento não implementou uma plataforma white label.

A possibilidade decorre da separação entre regras, processamento e apresentação, e não de uma funcionalidade já entregue.

---

# Parte V — Critérios de aderência

## 35. Cenário com alta aderência

Uma adaptação tende a ter maior aderência quando:

- os dados possuem estrutura identificável;
- as regras podem ser documentadas;
- o processamento pode ocorrer em lote;
- existe tolerância a atualização periódica;
- o resultado pode ser validado;
- a origem pode ser preservada;
- o destino pode ser separado;
- existe responsável pelas regras;
- falhas podem interromper a publicação;
- o volume é compatível com as ferramentas.

---

## 36. Cenário com aderência condicionada

A aderência precisa de análise adicional quando:

- existem várias fontes conflitantes;
- as regras mudam frequentemente;
- há dados pessoais;
- a atualização precisa ocorrer em poucos minutos;
- usuários dependem do resultado para continuar a operação;
- existem muitas integrações;
- o volume cresce rapidamente;
- o histórico precisa ser permanente;
- diferentes perfis precisam de visões específicas.

---

## 37. Cenário com baixa aderência

O modelo experimental possui baixa aderência quando o problema exige:

- transações em tempo real;
- latência em milissegundos;
- consistência transacional distribuída;
- alta disponibilidade comprovada;
- milhares de escritas simultâneas;
- processamento contínuo por streaming;
- operação sem conexão;
- retenção regulatória sem arquitetura adicional;
- recuperação entre regiões;
- banco operacional de baixa latência.

Nesses casos, a arquitetura precisa ser diferente da utilizada na prova de conceito.

---

## 38. Perguntas para avaliar um novo caso

Antes de adaptar os princípios do experimento, devem ser respondidas:

1. qual é a fonte;
2. quem altera a fonte;
3. qual é o volume;
4. qual é a frequência de atualização;
5. qual é o nível de frescor necessário;
6. as regras estão documentadas;
7. os dados possuem estrutura estável;
8. existem dados pessoais;
9. quem pode visualizar cada informação;
10. qual é o impacto de uma falha;
11. quanto tempo de indisponibilidade é aceitável;
12. o processamento pode ser refeito;
13. existe uma chave única;
14. como duplicidades são tratadas;
15. quais validações são obrigatórias;
16. qual é a retenção;
17. quem aprova mudanças;
18. qual ambiente será utilizado para teste;
19. como a publicação será validada;
20. como a recuperação será executada.

---

# Parte VI — Limites de generalização

## 39. Dados do experimento

Os resultados foram obtidos em um caso específico, com:

- fonte em Google Sheets;
- processamento em BigQuery Sandbox;
- orquestração por Apps Script;
- publicação em uma shadow;
- janela controlada;
- volume determinado;
- regras determinadas;
- gatilho periódico.

Os números de performance não devem ser transferidos automaticamente para outros ambientes.

---

## 40. Fatores que alteram o resultado

O comportamento pode variar conforme:

- volume de linhas;
- quantidade de colunas;
- tamanho dos textos;
- quantidade de fórmulas;
- complexidade das consultas;
- região do serviço;
- latência da API;
- quantidade de abas;
- concorrência;
- permissões;
- frequência de alteração;
- quantidade de ciclos;
- tamanho da publicação;
- limites da conta;
- tipo de licença do Google Workspace.

---

## 41. Necessidade de nova baseline

Cada novo caso precisa de sua própria baseline.

Uma baseline deve registrar, quando aplicável:

- volume;
- crescimento;
- fórmulas;
- erros;
- frequência de mudança;
- latência;
- usuários;
- horário operacional;
- criticidade;
- disponibilidade;
- regras;
- dependências;
- consumo.

A baseline reduz o risco de decidir apenas por percepção.

---

## 42. Dados sintéticos em documentação pública

Exemplos públicos devem utilizar somente:

- nomes fictícios;
- identificadores artificiais;
- datas genéricas;
- valores simulados;
- estruturas reduzidas;
- dados criados especificamente para demonstração.

Não devem ser publicados:

- dados de clientes;
- documentos;
- e-mails;
- nomes reais;
- URLs internas;
- IDs de planilhas;
- IDs de projetos;
- IDs de gatilhos;
- chaves;
- tokens;
- hashes do ambiente;
- logs brutos;
- conteúdo operacional.

---

# Parte VII — Relação com o Celebra Connect

## 43. Separação entre estudo e produto

O pipeline experimental e o Celebra Connect possuem finalidades diferentes.

### Pipeline experimental

- avaliou o ecossistema Google;
- utilizou BigQuery Sandbox;
- utilizou Apps Script;
- publicou em uma shadow;
- mediu fórmulas;
- validou recuperação;
- produziu evidências técnicas.

### Celebra Connect

- possui interface própria;
- utiliza backend;
- utiliza PostgreSQL;
- utiliza contêineres;
- apresenta informações por perfil;
- não utiliza BigQuery como banco da aplicação;
- não utiliza o pipeline experimental como código de produção.

Os dois contextos não devem ser misturados.

---

## 44. Conhecimentos transferíveis

Os elementos transferíveis são princípios de engenharia, como:

- separação de responsabilidades;
- validação;
- idempotência;
- auditoria;
- controle de concorrência;
- recuperação;
- logs;
- versionamento;
- homologação;
- publicação segura.

Os códigos e componentes específicos do experimento não são apresentados como módulos do Celebra Connect.

---

## 45. Papel das planilhas no contexto analisado

As planilhas podem continuar sendo utilizadas como:

- fonte integrada;
- espaço de teste;
- ambiente de simulação;
- mecanismo de homologação;
- suporte para análise pontual.

A interface operacional oficial pode permanecer fora da planilha.

Essa separação permite preservar processos existentes enquanto reduz a concentração de responsabilidades no Sheets.

---

## 46. Conclusão

O experimento comprovou que uma estrutura baseada em fórmulas pode ser analisada, processada externamente, validada e publicada de forma controlada.

Os mecanismos demonstrados possuem aplicabilidade em cenários que compartilham características como:

- processamento em lote;
- regras documentáveis;
- necessidade de validação;
- publicação periódica;
- separação entre origem e destino;
- auditoria;
- recuperação.

A aplicabilidade não deve ser confundida com implantação automática.

Cada novo caso exige:

- baseline;
- análise de aderência;
- definição de regras;
- controle de dados;
- testes;
- validação;
- governança.

O Google Sheets continua útil para experimentação, colaboração e homologação.

O risco surge quando a planilha acumula responsabilidades incompatíveis com sua natureza e passa a funcionar simultaneamente como banco, motor de regras, interface, auditoria e sistema operacional.

O principal aprendizado generalizável não é a substituição obrigatória da planilha.

É a separação consciente entre:

- entrada;
- regra;
- processamento;
- armazenamento;
- validação;
- publicação;
- auditoria;
- interface.
