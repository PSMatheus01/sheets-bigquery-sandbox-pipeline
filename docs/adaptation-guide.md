# Guia de adaptação

## 1. Objetivo

Este documento apresenta um método para avaliar a adaptação dos princípios validados pelo experimento a outros contextos.

O guia não transforma o pipeline experimental em uma solução pronta para qualquer operação.

Seu objetivo é permitir que uma equipe identifique:

- quais elementos podem ser reaproveitados;
- quais elementos precisam ser redesenhados;
- quais dados devem ser coletados;
- quais riscos precisam ser avaliados;
- quais validações são obrigatórias;
- quais critérios determinam aprovação ou reprovação;
- quando uma planilha ainda é adequada;
- quando outra arquitetura precisa ser considerada.

---

## 2. Base experimental

O método apresentado foi derivado de dois experimentos.

### Pipeline automatizado

O pipeline validou:

- detecção de mudanças;
- confirmação de persistência;
- processamento em lote;
- geração candidata;
- validação;
- promoção;
- publicação;
- auditoria;
- recuperação;
- encerramento automático.

### Baseline de fórmulas

A baseline validou:

- monitoramento somente leitura;
- inventário estrutural;
- contagem de fórmulas;
- identificação de funções;
- identificação de erros;
- coleta de latências;
- acompanhamento de metadados;
- encerramento automático.

As orientações deste documento partem dessas evidências.

---

## 3. Limite do guia

Este guia não garante:

- compatibilidade automática;
- performance equivalente;
- atendimento regulatório;
- disponibilidade de produção;
- segurança por padrão;
- migração sem risco;
- substituição automática de fórmulas;
- redução percentual de tempo;
- redução percentual de custo;
- adequação do BigQuery a qualquer cenário.

Cada adaptação precisa ser analisada e testada de forma independente.

---

# Parte I — Elementos reaproveitáveis

## 4. Princípios transferíveis

Os seguintes princípios não dependem exclusivamente do BigQuery, do Apps Script ou do Google Sheets:

- separação entre origem e destino;
- processamento idempotente;
- geração candidata;
- validação antes da promoção;
- preservação da geração anterior;
- auditoria;
- máquina de estados;
- controle de concorrência;
- preflight;
- autorização temporária;
- rastreabilidade;
- logs estruturados;
- recuperação controlada;
- encerramento automático;
- remoção de recursos temporários;
- publicação somente após aprovação.

Esses princípios podem ser aplicados com tecnologias diferentes.

---

## 5. Componentes específicos do experimento

Os seguintes componentes pertencem ao contexto testado:

- Google Sheets como origem;
- Google Sheets como shadow;
- BigQuery Sandbox;
- Apps Script;
- Script Properties;
- gatilhos do Apps Script;
- tabelas com expiração;
- views no BigQuery;
- cotas do ambiente Google.

Esses componentes não precisam ser mantidos em uma adaptação.

A decisão depende do contexto analisado.

---

## 6. O que não deve ser copiado diretamente

Não devem ser copiados sem revisão:

- IDs;
- nomes de projetos;
- nomes de datasets;
- nomes de planilhas;
- nomes de abas;
- hashes;
- chaves de propriedades;
- intervalos;
- limites de orçamento;
- estados específicos;
- funções de recuperação;
- regras de negócio;
- schemas;
- consultas SQL;
- permissões;
- gatilhos;
- políticas de retenção.

Esses elementos foram definidos para um experimento específico.

---

# Parte II — Diagnóstico inicial

## 7. Identificação do problema

Antes de escolher uma tecnologia, o problema deve ser descrito de forma objetiva.

Perguntas mínimas:

1. qual atividade precisa ser melhorada;
2. qual é a fonte dos dados;
3. quem altera os dados;
4. quais regras são aplicadas;
5. onde as regras estão armazenadas;
6. qual é o resultado esperado;
7. quem utiliza o resultado;
8. qual é o impacto de uma falha;
9. quanto tempo o resultado pode ficar desatualizado;
10. como o processo é recuperado atualmente.

A tecnologia não deve ser escolhida antes da compreensão do processo.

---

## 8. Inventário da fonte

A análise deve registrar:

- tipo da fonte;
- proprietário;
- responsáveis;
- permissões;
- quantidade de registros;
- quantidade de campos;
- crescimento;
- frequência de atualização;
- horário operacional;
- dependências;
- integrações;
- dados sensíveis;
- regras;
- erros conhecidos;
- histórico disponível.

Quando a fonte for uma planilha, também devem ser avaliados:

- quantidade de abas;
- quantidade de fórmulas;
- fórmulas por coluna;
- referências externas;
- padrões misturados;
- erros;
- proteções;
- intervalos nomeados;
- scripts associados;
- gatilhos;
- integrações externas.

---

## 9. Baseline

A baseline deve ser coletada antes de qualquer afirmação de ganho.

Métricas possíveis:

| Dimensão | Exemplos |
|---|---|
| Volume | Linhas, colunas, células e arquivos |
| Regras | Fórmulas, funções, consultas e scripts |
| Qualidade | Erros, vazios, duplicidades e inconsistências |
| Uso | Usuários, alterações e horários |
| Performance | Média, mediana, P95 e máximo |
| Operação | Falhas, intervenções e indisponibilidade |
| Consumo | Jobs, bytes, runtime e armazenamento |
| Manutenção | Frequência de ajuste e dependências |

Sem uma baseline, a conclusão tende a depender apenas de percepção.

---

## 10. Coleta somente leitura

Quando a origem estiver em produção, o diagnóstico deve priorizar leitura.

A coleta não deve:

- alterar células;
- modificar fórmulas;
- inserir linhas;
- excluir linhas;
- criar abas;
- excluir abas;
- alterar formatação;
- modificar permissões;
- instalar gatilho na origem;
- executar limpeza;
- substituir conteúdo.

A identidade do alvo precisa ser validada antes da leitura.

---

## 11. Privacidade

A baseline deve armazenar somente o necessário.

Devem ser priorizados:

- contagens;
- tipos;
- métricas;
- hashes não reversíveis;
- tempos;
- totais;
- classificações;
- agregados.

Não devem ser persistidos sem necessidade:

- nomes;
- documentos;
- telefones;
- e-mails;
- endereços;
- conteúdo integral de células;
- fórmulas completas;
- credenciais;
- URLs privadas;
- tokens;
- chaves.

---

# Parte III — Classificação do processo

## 12. Processamento em lote

O processamento em lote possui maior aderência quando:

- os dados são atualizados em períodos definidos;
- existe tolerância a alguns minutos;
- o resultado pode ser reconstruído;
- as regras são determinísticas;
- a origem pode ser fotografada;
- o destino pode ser substituído por geração;
- o fluxo pode esperar estabilidade.

O experimento utilizou esse modelo.

---

## 13. Processamento em tempo real

Um processo exige outra avaliação quando depende de:

- resposta em milissegundos;
- atualização imediata;
- transações simultâneas;
- reservas;
- bloqueios de registros;
- consistência entre várias operações;
- eventos contínuos;
- milhares de escritas concorrentes.

O pipeline experimental não foi validado para esse perfil.

---

## 14. Processo analítico

Um processo analítico normalmente envolve:

- consolidação;
- filtros;
- agregações;
- cruzamentos;
- comparações;
- indicadores;
- histórico;
- relatórios.

Esse perfil possui maior compatibilidade com os princípios do experimento.

---

## 15. Processo operacional

Um processo operacional pode envolver:

- criação de registros;
- alteração de status;
- distribuição de trabalho;
- permissões por perfil;
- ações simultâneas;
- baixa latência;
- indisponibilidade mínima.

Nesse cenário, uma planilha ou um mecanismo analítico não deve ser assumido automaticamente como banco operacional.

---

# Parte IV — Definição da arquitetura

## 16. Separação de responsabilidades

A adaptação deve identificar componentes distintos para:

- entrada;
- validação;
- processamento;
- armazenamento;
- publicação;
- auditoria;
- interface;
- monitoramento;
- recuperação.

Uma única ferramenta pode executar mais de uma função, mas as responsabilidades precisam permanecer identificáveis.

---

## 17. Origem

A origem deve possuir:

- identidade;
- proprietário;
- schema conhecido;
- controle de acesso;
- horário de atualização;
- regra de leitura;
- método de detecção de mudança;
- tratamento de indisponibilidade.

A origem não deve ser alterada pelo pipeline sem uma decisão explícita.

---

## 18. Destino

O destino deve possuir:

- finalidade definida;
- schema;
- retenção;
- permissões;
- estratégia de atualização;
- critérios de aprovação;
- recuperação;
- auditoria.

O destino pode ser:

- tabela;
- banco de dados;
- arquivo;
- API;
- interface;
- camada analítica;
- planilha de consulta.

A escolha depende do uso.

---

## 19. Ambiente shadow

Um ambiente shadow é adequado quando é necessário:

- observar o comportamento sem alterar a produção;
- comparar resultados;
- validar regras;
- medir performance;
- testar recuperação;
- coletar evidências.

O shadow deve permanecer separado da produção.

Ele não deve ser tratado como produção apenas porque o teste foi aprovado.

---

## 20. Ambientes

Uma adaptação deve avaliar a necessidade de:

- desenvolvimento;
- teste;
- homologação;
- shadow;
- produção.

Os ambientes devem evitar compartilhamento indevido de:

- credenciais;
- dados;
- gatilhos;
- propriedades;
- tabelas;
- filas;
- configurações.

---

# Parte V — Detecção e captura

## 21. Detecção de mudanças

Uma mudança pode ser detectada por:

- horário de modificação;
- versão;
- hash;
- evento;
- fila;
- timestamp de atualização;
- consulta incremental;
- comparação de contagem;
- marcador de processamento.

O método deve ser compatível com a fonte.

---

## 22. Confirmação de persistência

Mudança detectada não significa mudança concluída.

Pode ser necessário aguardar:

- estabilidade;
- fechamento;
- intervalo mínimo;
- ausência de edição;
- número de confirmações;
- aprovação humana.

No experimento, foram utilizados 8 intervalos e aproximadamente 120 minutos.

Esse valor não deve ser copiado automaticamente.

---

## 23. Snapshot

Quando possível, a captura deve registrar:

- identidade da fonte;
- momento inicial;
- momento final;
- versão;
- tamanho;
- schema;
- hash;
- contagem.

Se a fonte mudar durante a captura, o processo deve decidir entre:

- abortar;
- tentar novamente;
- marcar inconsistência;
- processar uma versão estável.

---

## 24. Idempotência

Uma operação idempotente pode ser repetida sem produzir duplicidade ou corrupção.

A adaptação deve definir:

- chave do ciclo;
- chave dos registros;
- geração;
- versão;
- marcador de processamento;
- comportamento em repetição;
- comportamento após interrupção.

---

# Parte VI — Geração candidata

## 25. Criação da candidata

A nova geração deve ser criada separadamente da oficial.

Ela deve possuir:

- identificação;
- ciclo;
- versão;
- horário;
- schema;
- origem;
- contagem;
- retenção;
- status.

A candidata não deve ser utilizada como oficial antes da aprovação.

---

## 26. Validações mínimas

As validações devem considerar:

- existência;
- schema;
- tipos;
- campos obrigatórios;
- quantidade de registros;
- registros vazios;
- duplicidades;
- chaves;
- datas;
- regras;
- assinaturas;
- limites;
- valores inesperados.

As regras precisam distinguir:

- igualdade obrigatória;
- subconjunto válido;
- diferença esperada;
- diferença impeditiva.

---

## 27. Critérios de bloqueio

Um bloqueio deve ocorrer quando existe risco de:

- perda de dados;
- schema incompatível;
- geração incompleta;
- duplicidade;
- inconsistência de identidade;
- ciclo incorreto;
- publicação parcial;
- concorrência;
- fonte alterada durante captura;
- regra obrigatória não atendida.

A mensagem de bloqueio deve explicar:

- condição encontrada;
- condição esperada;
- ciclo;
- etapa;
- métrica;
- impacto.

---

## 28. Diagnóstico antes do bloqueio

As métricas necessárias à investigação devem ser persistidas antes da interrupção.

Exemplos:

- contagens;
- decomposição;
- schema;
- assinatura;
- job;
- duração;
- bytes;
- identidade;
- geração;
- paridade.

Um erro sem diagnóstico aumenta o tempo de recuperação.

---

# Parte VII — Promoção e publicação

## 29. Backup

Antes da promoção, deve ser avaliada a preservação da geração anterior.

O backup precisa definir:

- conteúdo preservado;
- momento;
- retenção;
- identidade;
- relação com o ciclo;
- condição de remoção;
- condição de restauração.

---

## 30. Promoção

A promoção deve ocorrer somente quando:

- a candidata existe;
- as validações foram aprovadas;
- o ciclo é válido;
- não existe outra promoção ativa;
- o backup foi confirmado;
- as autorizações estão válidas.

---

## 31. Validação pós-promoção

Após a promoção, devem ser repetidas as validações necessárias.

A validação deve confirmar:

- geração oficial correta;
- schema;
- contagem;
- assinatura;
- views;
- dependências;
- backup;
- retenção;
- ausência de alteração concorrente.

---

## 32. Publicação

A publicação precisa definir:

- público;
- destino;
- volume;
- formato;
- sanitização;
- substituição;
- staging;
- validação;
- recuperação.

Textos iniciados por caracteres interpretáveis como fórmula precisam de tratamento quando o destino for uma planilha.

---

## 33. Staging

Recursos de staging precisam possuir:

- nome identificável;
- ciclo;
- horário;
- finalidade;
- condição de remoção;
- validação antes da exclusão.

A limpeza deve ser seletiva.

Não deve remover recursos apenas por semelhança parcial de nome.

---

# Parte VIII — Controle operacional

## 34. Máquina de estados

A máquina de estados deve registrar:

- estado atual;
- estado anterior;
- etapa atual;
- última etapa concluída;
- última falha;
- ciclo;
- aprovação;
- conclusão;
- recuperação.

Cada transição precisa ser permitida de forma explícita.

---

## 35. Preflight

Operações sensíveis devem possuir preflight.

O preflight deve verificar:

- identidade;
- configuração;
- ambiente;
- estado;
- ciclo;
- resultado anterior;
- lock;
- concessão;
- lease;
- gatilhos;
- autorização;
- origem;
- destino.

O preflight não deve executar a operação que avalia.

---

## 36. Lock

O lock impede execuções simultâneas em uma seção crítica.

A adaptação deve definir:

- escopo;
- tempo de espera;
- comportamento em indisponibilidade;
- liberação;
- registro da falha.

---

## 37. Concessão

Uma concessão representa autorização temporária.

Ela deve possuir:

- finalidade;
- ciclo;
- identidade;
- início;
- validade;
- encerramento.

Concessões expiradas ou de outro ciclo não devem autorizar operações.

---

## 38. Lease

Uma lease representa posse temporária da execução.

Ela deve impedir que dois executores assumam o mesmo ciclo.

Uma lease precisa ser:

- identificável;
- vinculada ao ciclo;
- temporária;
- renovável quando necessário;
- removida ao final;
- recuperável após expiração.

---

## 39. Gatilhos

Gatilhos devem ser controlados por:

- função;
- tipo;
- frequência;
- ambiente;
- janela;
- identidade;
- quantidade;
- remoção.

A criação precisa ser validada.

O encerramento precisa remover somente o gatilho correspondente.

---

## 40. Autorizações manuais

Autorizações manuais devem permanecer fechadas por padrão.

Quando utilizadas:

1. executar o preflight;
2. validar o resultado;
3. abrir a autorização;
4. executar somente a função permitida;
5. fechar a autorização;
6. registrar o resultado.

Uma autorização aberta permanentemente elimina parte do controle.

---

# Parte IX — Auditoria e observabilidade

## 41. Logs estruturados

Os logs devem registrar campos consistentes, como:

- sucesso;
- status;
- etapa;
- modo;
- ciclo;
- ação;
- função executada;
- estado anterior;
- estado posterior;
- bloqueios;
- ressalvas;
- duração;
- horário.

Logs estruturados facilitam:

- busca;
- filtros;
- consolidação;
- investigação;
- auditoria.

---

## 42. Métricas

Métricas possíveis:

- duração;
- média;
- mediana;
- P95;
- máximo;
- mínimo;
- runtime diário;
- quantidade de jobs;
- bytes processados;
- bytes faturáveis;
- registros;
- células;
- falhas;
- bloqueios;
- recuperações.

---

## 43. Auditoria periódica

A auditoria deve avaliar:

- estado;
- identidade;
- geração;
- publicação;
- resíduos;
- fórmulas inesperadas;
- assinaturas;
- contagens;
- gatilhos;
- concessões;
- leases;
- segurança.

Comparações temporais precisam considerar janelas móveis e filtros dependentes da data.

---

## 44. Alertas

Um alerta precisa distinguir:

- informação;
- ressalva;
- bloqueio;
- falha preservada;
- incidente recuperado;
- incidente ativo.

A classificação evita que todo desvio seja tratado como falha crítica ou que uma falha crítica seja reduzida a mensagem informativa.

---

# Parte X — Recuperação

## 45. Falha preservada

Quando uma condição impeditiva for encontrada, o sistema deve avaliar:

- interrupção;
- preservação do estado;
- preservação da candidata;
- preservação do backup;
- encerramento da janela;
- remoção do gatilho;
- bloqueio da retomada automática.

---

## 46. Recuperador específico

Uma recuperação extraordinária deve ser restrita a:

- ciclo;
- estado;
- etapa;
- incidente;
- autorização.

O recuperador não deve se transformar em um caminho alternativo permanente.

---

## 47. Retomada

A retomada deve continuar do ponto validado quando isso for seguro.

Antes da retomada, devem ser confirmados:

- correção aplicada;
- estado esperado;
- etapa anterior aprovada;
- ausência de concorrência;
- ausência de gatilho anterior;
- preservação das evidências;
- validade da autorização.

---

## 48. Rollback

O rollback deve possuir critérios definidos.

Ele não deve ser executado apenas porque uma etapa posterior falhou.

Antes do rollback, deve ser avaliado:

- estado da geração promovida;
- validade da geração anterior;
- impacto;
- dependências;
- possibilidade de correção;
- consistência da publicação;
- evidências.

---

## 49. Encerramento

O encerramento precisa:

- marcar a janela como inativa;
- registrar o motivo;
- remover o gatilho;
- encerrar concessões;
- encerrar leases;
- preservar o estado;
- registrar o resultado.

---

# Parte XI — Performance e capacidade

## 50. Metas por etapa

Metas de performance devem considerar o tipo de operação.

Exemplo de classificação:

| Tipo | Comportamento esperado |
|---|---|
| Decisão | Curta duração |
| Validação simples | Curta duração |
| Captura | Dependente do volume |
| Promoção | Dependente da plataforma |
| Publicação | Dependente do destino |
| Auditoria | Dependente da abrangência |
| Encerramento | Curta duração |

Uma meta única para todas as etapas pode produzir diagnósticos imprecisos.

---

## 51. Percentis

A avaliação deve considerar:

- média;
- mediana;
- P95;
- máximo.

O P95 indica o valor abaixo do qual se encontram 95% das amostras.

Ele ajuda a observar execuções lentas sem depender apenas do pior caso isolado.

---

## 52. Orçamento

Um orçamento operacional pode limitar:

- runtime diário;
- bytes processados;
- quantidade de jobs;
- frequência;
- armazenamento;
- chamadas de API.

O orçamento deve reservar margem para:

- auditoria;
- encerramento;
- recuperação;
- limpeza.

---

## 53. Teste de carga

Quando necessário, o teste deve utilizar:

- cópia isolada;
- dados sintéticos;
- ambiente separado;
- volume controlado;
- repetição;
- critérios definidos;
- ausência de impacto na produção.

O experimento original não executou um teste de carga com usuários simultâneos.

---

# Parte XII — Escolha tecnológica

## 54. Uso de planilha

Uma planilha pode ser adequada para:

- prototipação;
- simulação;
- homologação;
- revisão manual;
- análise pontual;
- entrada controlada;
- importação;
- exportação.

Ela apresenta menor aderência como sistema central quando existem:

- muitos usuários;
- alta concorrência;
- regras críticas;
- grande volume;
- fórmulas extensas;
- necessidade de auditoria detalhada;
- disponibilidade elevada;
- permissões complexas.

---

## 55. Uso do BigQuery

O BigQuery possui maior aderência a:

- análise;
- agregação;
- processamento em lote;
- grandes volumes;
- histórico;
- consultas analíticas.

Ele não deve ser assumido automaticamente como banco transacional da aplicação.

No experimento, foi utilizado como camada analítica.

---

## 56. Uso do Apps Script

O Apps Script pode ser adequado para:

- automação no ecossistema Google;
- orquestração;
- integração;
- prototipação;
- gatilhos;
- leitura e publicação controlada.

Sua utilização precisa considerar:

- cotas;
- duração máxima;
- runtime diário;
- quantidade de gatilhos;
- latência;
- manutenção;
- observabilidade.

---

## 57. Uso de banco operacional

Um banco operacional possui maior aderência quando existem:

- transações;
- usuários simultâneos;
- registros individuais;
- permissões;
- histórico;
- consistência;
- baixa latência;
- interface própria.

A escolha entre bancos depende de requisitos que não foram avaliados integralmente pelo experimento.

---

## 58. Escolha baseada no problema

A decisão tecnológica deve considerar:

- natureza do dado;
- volume;
- frequência;
- latência;
- concorrência;
- disponibilidade;
- retenção;
- segurança;
- equipe;
- manutenção;
- integração;
- custo;
- governança.

Nenhuma ferramenta deve ser escolhida apenas porque já está disponível.

---

# Parte XIII — Validação da adaptação

## 59. Fases recomendadas

Uma adaptação pode ser avaliada em fases:

1. diagnóstico;
2. baseline;
3. desenho;
4. protótipo;
5. shadow;
6. comparação;
7. teste de falha;
8. recuperação;
9. auditoria;
10. parecer.

A aprovação de uma fase não aprova automaticamente as seguintes.

---

## 60. Critérios funcionais

A adaptação deve confirmar:

- leitura correta;
- processamento correto;
- regras corretas;
- resultado esperado;
- ausência de duplicidade;
- consistência;
- repetibilidade;
- recuperação;
- encerramento.

---

## 61. Critérios de segurança

A adaptação deve confirmar:

- identidade;
- permissões;
- proteção da origem;
- segregação;
- logs;
- ausência de credenciais expostas;
- sanitização;
- controle de concorrência;
- rastreabilidade;
- remoção de temporários.

---

## 62. Critérios de performance

A adaptação deve registrar:

- volume;
- duração;
- mediana;
- P95;
- máximo;
- consumo;
- margem;
- gargalo;
- comportamento em repetição.

---

## 63. Critérios de aprovação

Uma adaptação pode ser considerada tecnicamente aprovada quando:

- critérios obrigatórios foram atendidos;
- bloqueios foram resolvidos;
- incidentes foram documentados;
- recuperações foram testadas;
- segurança foi validada;
- desempenho foi medido;
- limitações foram registradas;
- o estado final está íntegro;
- não existem recursos temporários ativos.

---

## 64. Critérios de reprovação

A adaptação deve ser reprovada ou suspensa quando:

- escreve indevidamente na origem;
- perde dados;
- duplica registros;
- não consegue identificar a geração;
- publica antes da validação;
- não possui recuperação;
- expõe credenciais;
- deixa gatilhos desconhecidos;
- não encerra leases;
- não preserva evidências;
- não respeita permissões;
- ultrapassa limites sem controle.

---

# Parte XIV — Checklist

## 65. Diagnóstico

- [ ] Problema descrito
- [ ] Fonte identificada
- [ ] Responsáveis identificados
- [ ] Volume registrado
- [ ] Frequência registrada
- [ ] Regras inventariadas
- [ ] Dados sensíveis identificados
- [ ] Baseline coletada
- [ ] Impacto da falha descrito

---

## 66. Arquitetura

- [ ] Origem definida
- [ ] Destino definido
- [ ] Ambientes separados
- [ ] Schema definido
- [ ] Retenção definida
- [ ] Identidade do ciclo definida
- [ ] Estratégia de candidata definida
- [ ] Estratégia de backup definida
- [ ] Estratégia de publicação definida

---

## 67. Controle

- [ ] Máquina de estados definida
- [ ] Preflight implementado
- [ ] Lock definido
- [ ] Concessão definida, se necessária
- [ ] Lease definida, se necessária
- [ ] Gatilhos controlados
- [ ] Autorizações fechadas por padrão
- [ ] Encerramento definido

---

## 68. Validação

- [ ] Schema validado
- [ ] Contagens validadas
- [ ] Duplicidades avaliadas
- [ ] Regras avaliadas
- [ ] Assinaturas avaliadas
- [ ] Subconjuntos interpretados corretamente
- [ ] Métricas persistidas antes de bloqueios
- [ ] Pós-promoção validada
- [ ] Publicação validada

---

## 69. Recuperação

- [ ] Estado de falha definido
- [ ] Preservação de evidências definida
- [ ] Backups validados
- [ ] Retomada controlada
- [ ] Rollback avaliado
- [ ] Remoção seletiva de temporários
- [ ] Gatilhos removidos
- [ ] Leases encerradas
- [ ] Concessões encerradas

---

## 70. Segurança

- [ ] Origem protegida
- [ ] Princípio de menor privilégio aplicado
- [ ] Credenciais fora do código
- [ ] Logs sanitizados
- [ ] Dados sensíveis minimizados
- [ ] Identificadores removidos da documentação pública
- [ ] Dados sintéticos utilizados em exemplos
- [ ] Revisão de segurança concluída

---

## 71. Performance

- [ ] Volume medido
- [ ] Média registrada
- [ ] Mediana registrada
- [ ] P95 registrado
- [ ] Máximo registrado
- [ ] Gargalo identificado
- [ ] Orçamento definido
- [ ] Margem de segurança definida
- [ ] Consumo documentado

---

## 72. Documentação

- [ ] Arquitetura documentada
- [ ] Metodologia documentada
- [ ] Resultados documentados
- [ ] Incidentes documentados
- [ ] Limitações documentadas
- [ ] Recuperações documentadas
- [ ] Casos de uso classificados
- [ ] Dados reais removidos
- [ ] Conclusão baseada em evidência

---

## 73. Conclusão

A adaptação dos princípios do experimento não começa pela cópia de código.

Ela começa pela compreensão do problema.

Os elementos mais reutilizáveis são:

- separação;
- validação;
- idempotência;
- rastreabilidade;
- auditoria;
- recuperação;
- publicação segura.

As tecnologias utilizadas no experimento foram adequadas ao objetivo da prova técnica, mas não representam uma resposta universal.

Uma adaptação responsável precisa:

1. medir a estrutura atual;
2. identificar riscos;
3. definir critérios;
4. testar em ambiente separado;
5. provocar falhas controladas;
6. validar recuperação;
7. medir performance;
8. preservar evidências;
9. documentar limitações;
10. aprovar somente o que foi comprovado.

O resultado esperado de uma adaptação não é reproduzir o experimento original.

O resultado esperado é aplicar os princípios comprovados de acordo com as necessidades, os limites e os riscos do novo contexto.
