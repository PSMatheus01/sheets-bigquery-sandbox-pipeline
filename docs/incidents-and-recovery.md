# Incidentes e recuperação

## 1. Objetivo

Este documento registra os incidentes identificados durante a construção e a execução do pipeline experimental, bem como os mecanismos utilizados para:

- interromper operações inseguras;
- preservar evidências;
- impedir continuações automáticas indevidas;
- corrigir falsos bloqueios;
- recuperar ciclos;
- validar publicações;
- remover resíduos temporários;
- encerrar janelas;
- restaurar o fluxo operacional.

Os incidentes apresentados não representam uma lista hipotética de riscos.

Todos foram observados durante o desenvolvimento, a validação ou a execução controlada do experimento.

---

## 2. Escopo

Foram considerados:

- bloqueios de validação;
- divergências de assinatura;
- falhas preservadas;
- encerramento automático;
- retomada de ciclo;
- inconsistências de publicação;
- resíduos temporários;
- recuperações;
- ressalvas de performance;
- alertas estruturais;
- validações posteriores à recuperação.

Não foram incluídos:

- identificadores reais;
- nomes de projetos;
- IDs de planilhas;
- IDs de gatilhos;
- hashes operacionais;
- chaves de usuário;
- conteúdo de produção;
- incidentes hipotéticos;
- procedimentos não executados.

---

## 3. Resumo dos incidentes

| Incidente | Classificação | Impacto | Resultado |
|---|---|---|---|
| Divergência de assinaturas causada por janela móvel | Falso positivo | Auditoria com ressalva | Regra corrigida |
| Janela anterior persistida como inativa | Bloqueio de ativação | Nova janela não criada | Ativação corrigida |
| Igualdade incorreta entre raw e view clean | Falso bloqueio | Ciclo interrompido | Validação corrigida |
| Entrada em `FALHA_PRESERVADA` | Proteção esperada | Continuação automática impedida | Funcionamento aprovado |
| Encerramento após falha preservada | Proteção esperada | Gatilho removido | Funcionamento aprovado |
| Retomada de ciclo interrompido | Recuperação controlada | Ciclo retomado na etapa pendente | Recuperação aprovada |
| Inconsistência durante recuperação da publicação | Bloqueio real | Publicação não finalizada inicialmente | Recuperada e validada |
| Staging temporário remanescente | Resíduo operacional | Finalização condicionada à limpeza | Removido e validado |
| Etapas acima da meta genérica de 25 segundos | Ressalva de performance | Sem perda de integridade | Classificada, não bloqueante |
| Estados ausentes em validação estrutural | Alerta de configuração | Risco de inconsistência documental | Registrado pelo validador |

---

## 4. Princípio de falha segura

O pipeline foi construído para interromper a execução quando uma etapa obrigatória não fosse aprovada.

O comportamento esperado era:

1. registrar o resultado da etapa;
2. preservar o estado anterior;
3. registrar o motivo do bloqueio;
4. impedir o avanço automático;
5. preservar backups e gerações;
6. impedir publicação incompleta;
7. impedir retomada automática indevida;
8. remover o gatilho quando a continuidade não fosse segura;
9. exigir diagnóstico antes da recuperação.

Esse comportamento foi exercitado durante o experimento.

O sistema não tentou esconder ou ignorar os incidentes.

---

# Incidente 1 — Divergência causada por janela temporal móvel

## 5. Contexto

Uma auditoria comparava as assinaturas atuais das views com as assinaturas da última publicação aprovada.

Uma das views utilizava uma janela temporal móvel.

A regra considerava registros entre:

- o início de uma janela mensal;
- a data atual da consulta.

Com o avanço do calendário, registros antigos deixavam naturalmente de fazer parte da janela.

Consequentemente, as assinaturas atuais podiam ser diferentes das assinaturas registradas em uma publicação anterior, mesmo que nenhuma alteração indevida tivesse ocorrido na shadow.

---

## 6. Sintoma

A auditoria identificou:

- views consultadas com sucesso;
- contagens estruturalmente válidas;
- divergência entre assinaturas atuais e assinaturas históricas;
- risco de classificar a divergência como alteração indevida da shadow.

A comparação utilizava duas referências temporais diferentes:

1. publicação congelada em uma data anterior;
2. views recalculadas na data da auditoria.

A igualdade integral não era uma premissa válida para views com janela móvel.

---

## 7. Causa

A causa foi uma regra de validação excessivamente rígida.

A divergência de assinatura era tratada como bloqueio, mesmo quando podia ser explicada pela evolução legítima da janela temporal.

O problema não estava na consulta das views nem na integridade da shadow.

O problema estava na interpretação da comparação histórica.

---

## 8. Correção aplicada

A comparação com a última publicação passou a ser informativa.

Quando as assinaturas fossem diferentes:

- a auditoria registraria a divergência;
- informaria a existência de janela móvel;
- não classificaria a divergência, isoladamente, como alteração da shadow;
- validaria a integridade da shadow por critérios independentes.

A aprovação deixou de depender da igualdade histórica das assinaturas.

Ela continuou dependendo de:

- consulta bem-sucedida das views;
- integridade das abas;
- ausência de fórmulas inesperadas;
- ausência de resíduos;
- consistência estrutural;
- validação independente da publicação.

---

## 9. Resultado

Após a correção:

- a auditoria foi aprovada;
- a divergência permaneceu registrada como ressalva;
- nenhuma alteração indevida foi encontrada;
- a shadow foi validada por critérios independentes;
- o falso bloqueio deixou de impedir a continuidade.

### Lição registrada

Assinaturas de resultados dependentes da data não devem ser comparadas como se fossem snapshots imutáveis.

A comparação precisa considerar:

- data de referência;
- intervalo temporal;
- filtros dinâmicos;
- evolução da origem;
- momento de geração da assinatura.

---

# Incidente 2 — Janela anterior persistida

## 10. Contexto

O encerramento de uma janela preservava seu registro para fins de auditoria.

A janela anterior permanecia armazenada, porém com estado inativo e encerrado.

Uma validação posterior verificava apenas se a propriedade da janela existia.

---

## 11. Sintoma

O preflight de uma nova ativação retornou bloqueio com a interpretação de que já existia:

- janela;
- concessão;
- ou lease persistida.

Entretanto:

- a janela existente estava inativa;
- a janela já havia sido encerrada;
- não havia concessão ativa;
- não havia lease ativa;
- não havia gatilho executor ativo.

---

## 12. Causa

A validação confundia:

- existência histórica da propriedade;
- existência de uma janela ativa.

O encerramento preservava corretamente o histórico, mas o ativador exigia ausência integral da propriedade.

As duas regras eram incompatíveis.

---

## 13. Correção aplicada

A ativação passou a:

1. identificar a janela anterior;
2. confirmar que ela estava encerrada;
3. preservar o conteúdo anterior;
4. arquivar o registro anterior;
5. validar a ausência de concessão ativa;
6. validar a ausência de lease ativa;
7. validar a ausência de gatilho executor;
8. criar a nova janela;
9. criar exatamente um gatilho;
10. validar o gatilho criado;
11. executar rollback em caso de falha durante a ativação.

---

## 14. Resultado

Após a correção:

- a janela anterior foi preservada;
- uma nova janela foi criada;
- exatamente um gatilho foi instalado;
- o executor não foi chamado durante a ativação;
- o estado operacional não foi alterado indevidamente;
- nenhuma concessão ou lease residual foi encontrada.

### Lição registrada

Presença histórica e atividade operacional são conceitos diferentes.

Recursos encerrados podem permanecer registrados para auditoria sem impedir novas ativações.

---

# Incidente 3 — Igualdade incorreta na validação pós-promoção

## 15. Contexto

A promoção das tabelas candidatas foi concluída.

A tabela oficial passou a conter a mesma geração aprovada da candidata.

Após a promoção, uma etapa de validação verificava:

- schema;
- retenção;
- labels;
- backups;
- views;
- contagens;
- assinaturas;
- decomposição das linhas.

---

## 16. Sintoma

A validação foi bloqueada com a interpretação de que a view clean não havia incorporado todas as linhas com conteúdo aprovadas.

A promoção havia sido concluída corretamente.

Foram confirmados:

- tabela oficial igual à candidata;
- quantidade de registros compatível;
- schema válido;
- labels válidos;
- retenção válida;
- backups preservados;
- views oficiais estruturalmente válidas;
- views oficiais equivalentes às candidatas.

A única condição reprovada era a igualdade entre:

- total de linhas com conteúdo da tabela raw;
- total de registros da view clean.

---

## 17. Causa

A condição exigia:

`totalClean = linhasComConteudo`

Essa condição era incorreta porque a view clean aplicava:

- janela temporal;
- critérios de elegibilidade;
- regras de limpeza;
- filtros de negócio.

Portanto, a view clean era um subconjunto válido das linhas com conteúdo.

A relação correta era:

`0 <= totalClean <= linhasComConteudo`

---

## 18. Correção aplicada

A igualdade foi substituída pela validação de subconjunto.

A nova regra passou a verificar:

- total clean não negativo;
- linhas com conteúdo não negativas;
- total clean menor ou igual às linhas com conteúdo;
- total clean igual ao total da view de regras;
- total de controle compatível com a view clean.

Também foi adicionada a métrica:

`linhasNaoIncorporadas = linhasComConteudo - totalClean`

No ciclo recuperado, foram identificadas:

- 22.344 linhas não incorporadas pela view clean;
- exclusão explicada por elegibilidade ou janela temporal;
- nenhuma perda estrutural indevida.

---

## 19. Melhoria de diagnóstico

O primeiro bloqueio não persistia todas as métricas de decomposição antes de lançar o erro.

Isso dificultava a análise posterior.

A correção passou a persistir, antes dos bloqueios:

- total raw;
- linhas totalmente vazias;
- linhas com conteúdo;
- total clean;
- total da view de regras;
- total do controle;
- linhas não incorporadas;
- paridades;
- diagnósticos candidatos;
- diagnósticos oficiais;
- informações da consulta;
- bytes processados;
- bytes faturáveis;
- duração;
- job associado.

### Lição registrada

Métricas necessárias ao diagnóstico devem ser persistidas antes da avaliação que pode interromper a execução.

---

# Incidente 4 — Entrada em falha preservada

## 20. Comportamento observado

Após o bloqueio da validação pós-promoção, o executor registrou o ciclo como:

`FALHA_PRESERVADA`

Esse estado impediu:

- execução das etapas seguintes;
- publicação sem validação;
- conclusão indevida do ciclo;
- retomada automática;
- substituição silenciosa das evidências;
- rollback não validado.

A geração promovida e os backups permaneceram preservados.

---

## 21. Encerramento automático

Na chamada automática seguinte, o executor detectou o estado de falha preservada.

Ele então:

1. não retomou o ciclo;
2. não executou etapas posteriores;
3. encerrou a janela;
4. removeu o gatilho correspondente;
5. preservou o estado operacional;
6. registrou o motivo do encerramento;
7. manteve os objetos necessários para diagnóstico.

O encerramento não tentou mascarar a falha.

---

## 22. Resultado

O mecanismo de falha segura foi aprovado porque:

- o pipeline parou no ponto correto;
- nenhuma publicação inválida foi realizada;
- a produção permaneceu somente leitura;
- nenhum rollback automático destrutivo foi executado;
- os backups foram preservados;
- o gatilho foi removido;
- o diagnóstico permaneceu possível.

### Lição registrada

Um estado de falha precisa ser terminal para a automação até que exista uma autorização de recuperação específica.

---

# Incidente 5 — Retomada controlada do ciclo

## 23. Contexto

Após a correção da validação, o ciclo permaneceu em uma etapa intermediária.

As etapas anteriores já haviam sido aprovadas.

Reexecutar todo o pipeline poderia:

- duplicar operações;
- substituir evidências;
- recriar objetos;
- repetir promoções;
- dificultar a rastreabilidade;
- aumentar o risco operacional.

---

## 24. Estratégia de recuperação

Foi criado um recuperador específico para o ciclo interrompido.

O recuperador não executava diretamente a etapa pendente.

Sua responsabilidade era:

1. executar um preflight somente leitura;
2. validar o ciclo autorizado;
3. validar o estado atual;
4. validar a etapa pendente;
5. validar a aprovação da etapa anterior;
6. confirmar ausência de concessão;
7. confirmar ausência de lease;
8. confirmar ausência de gatilho;
9. arquivar a janela anterior;
10. criar uma nova janela;
11. criar exatamente um gatilho;
12. permitir que o executor normal retomasse o fluxo.

---

## 25. Autorização manual temporária

A recuperação exigiu uma constante de autorização manual.

O procedimento adotado foi:

1. manter a autorização fechada durante o preflight;
2. executar o preflight;
3. confirmar a aprovação;
4. abrir temporariamente a autorização;
5. executar somente a função de retomada;
6. fechar novamente a autorização;
7. não executar o executor manualmente.

Esse mecanismo evitou que a recuperação fosse executada acidentalmente.

---

## 26. Resultado

A retomada:

- preservou a janela anterior;
- vinculou a nova janela ao ciclo recuperado;
- criou um único gatilho;
- não alterou o estado operacional durante a ativação;
- não chamou o executor diretamente;
- permitiu que o gatilho retomasse a etapa pendente;
- concluiu as etapas restantes;
- levou o ciclo ao estado final aprovado.

### Lição registrada

Uma recuperação deve restabelecer as condições normais de execução, em vez de reproduzir manualmente as ações internas do pipeline.

---

# Incidente 6 — Recuperação da publicação

## 27. Contexto

Durante a validação da publicação, uma rotina de recuperação encontrou uma condição incompatível com a finalização imediata.

O resultado histórico foi preservado como bloqueio.

A execução não foi considerada concluída até que a publicação fosse novamente verificada.

---

## 28. Comportamento seguro

A rotina:

- não aprovou uma publicação inconsistente;
- não ocultou o resultado anterior;
- preservou os dados necessários;
- registrou o bloqueio;
- exigiu recuperação;
- impediu a conclusão prematura do ciclo.

Após a correção e a execução da recuperação:

- a publicação foi reavaliada;
- as abas técnicas foram verificadas;
- os totais foram conferidos;
- as fórmulas foram verificadas;
- a estrutura esperada foi confirmada;
- o ciclo pôde prosseguir.

---

## 29. Resultado

O consolidado final registrou:

- um bloqueio histórico;
- recuperação concluída;
- ausência de bloqueio ativo;
- ciclo final aprovado;
- estado final saudável;
- publicação validada.

O bloqueio histórico foi mantido como evidência.

Ele não representava uma falha ativa no encerramento do experimento.

### Lição registrada

Resultados históricos não devem ser apagados apenas porque a condição foi posteriormente corrigida.

A recuperação deve criar nova evidência de aprovação.

---

# Incidente 7 — Staging temporário remanescente

## 30. Contexto

Durante uma das publicações, foi identificada uma aba temporária de staging que não havia sido removida no momento esperado.

A aba possuía identificação técnica e não fazia parte da estrutura final aprovada.

---

## 31. Risco

Um staging remanescente poderia:

- confundir validações posteriores;
- ser interpretado como aba inesperada;
- expor dados intermediários;
- aumentar a quantidade de abas técnicas;
- comprometer a limpeza da publicação;
- permanecer após a conclusão do ciclo.

---

## 32. Recuperação aplicada

A recuperação:

1. identificou a aba temporária específica;
2. confirmou que ela era um staging do pipeline;
3. confirmou que não era uma aba oficial;
4. removeu somente o staging correspondente;
5. preservou as abas oficiais;
6. preservou as abas de negócio;
7. executou nova validação;
8. confirmou a ausência de resíduos.

A remoção não utilizou uma regra genérica que pudesse excluir outras abas.

---

## 33. Resultado

Após a recuperação:

- o staging temporário foi removido;
- nenhuma aba oficial foi removida;
- nenhuma aba de negócio foi alterada;
- a publicação foi validada;
- o ciclo pôde ser finalizado;
- nenhuma aba inesperada permaneceu.

### Lição registrada

Recursos temporários devem possuir identidade inequívoca e remoção seletiva.

Uma rotina de limpeza não deve excluir objetos apenas por semelhança de nome.

---

# Incidente 8 — Ressalvas de performance

## 34. Contexto

Uma meta genérica de 25 segundos foi utilizada como referência durante parte do experimento.

Algumas etapas ultrapassaram essa meta.

Entre elas:

| Etapa | Duração observada |
|---|---:|
| Recuperação associada à publicação | 92.083 ms |
| Publicação na shadow | 87.404 ms |
| Captura otimizada | 31.651 ms |
| Promoção nativa | 31.001 ms |
| Validação pós-promoção | 22.082 ms |

---

## 35. Classificação

Esses resultados foram classificados como ressalvas de performance, e não como falhas de integridade.

As etapas:

- terminaram dentro do limite máximo de execução aplicável;
- não corromperam os dados;
- não ultrapassaram o orçamento diário;
- não produziram publicação parcial;
- não impediram a auditoria;
- não deixaram gatilhos residuais.

A publicação foi o principal gargalo observado.

---

## 36. Interpretação

Uma meta única não representava adequadamente etapas com responsabilidades diferentes.

Operações como:

- consulta de estado;
- decisão;
- encerramento;
- validação simples;

não possuem o mesmo perfil de:

- captura;
- promoção;
- publicação de milhares de células;
- comparação integral de estruturas.

### Lição registrada

A avaliação de performance precisa considerar:

- tipo de etapa;
- volume processado;
- percentis;
- pior caso;
- orçamento diário;
- integridade;
- impacto operacional.

---

# Incidente 9 — Alerta estrutural de configuração

## 37. Contexto

Uma validação estrutural identificou estados utilizados pelo executor que não estavam integralmente representados na configuração documental avaliada.

O executor conseguia percorrer os estados durante o experimento, mas a divergência indicava risco de inconsistência entre:

- implementação;
- configuração;
- documentação;
- validação estática.

---

## 38. Classificação

O resultado foi tratado como alerta estrutural.

Ele não foi classificado como falha do ciclo porque:

- o executor percorreu a máquina de estados;
- os ciclos foram concluídos;
- as transições foram registradas;
- não houve estado desconhecido durante a execução consolidada.

Ainda assim, o alerta foi preservado como evidência de que validadores estáticos podem detectar divergências que não aparecem imediatamente durante uma execução específica.

### Lição registrada

Configuração, implementação e documentação precisam representar a mesma máquina de estados.

---

# Controles de recuperação

## 39. Locks

Locks foram utilizados para impedir que duas execuções alterassem o estado operacional simultaneamente.

As funções críticas verificavam a obtenção do lock antes de continuar.

Quando o lock não pudesse ser obtido, a execução deveria terminar sem iniciar uma nova operação.

---

## 40. Concessões

Concessões temporárias representavam autorização para uma etapa controlada.

Elas possuíam:

- vínculo com o ciclo;
- validade;
- identidade;
- finalidade;
- encerramento.

Uma concessão de outro ciclo não poderia autorizar a execução atual.

---

## 41. Leases

Leases representavam a posse temporária de uma execução.

Elas impediam que outro executor assumisse simultaneamente a mesma operação.

As validações verificavam:

- existência;
- validade;
- ciclo;
- identidade;
- expiração;
- ausência de outra lease ativa.

---

## 42. Gatilhos

Cada janela deveria possuir exatamente um gatilho executor.

Os controles verificavam:

- função associada;
- tipo de evento;
- quantidade de gatilhos;
- vínculo com a janela;
- identificador esperado;
- remoção no encerramento.

Ao final das janelas avaliadas:

- o gatilho correspondente foi removido;
- nenhum gatilho executor residual permaneceu.

---

## 43. Backups

Antes da promoção, as tabelas oficiais anteriores eram preservadas.

Os backups permitiram:

- comparar a geração anterior;
- manter evidências;
- analisar divergências;
- evitar perda imediata;
- preparar eventual rollback.

Durante o incidente de validação pós-promoção, os backups permaneceram disponíveis.

---

## 44. Preflights

Os preflights foram executados antes de operações sensíveis.

Eles verificavam:

- identidade;
- configuração;
- experimento;
- ciclo;
- estado;
- etapa;
- resultado anterior;
- autorizações;
- janela;
- concessão;
- lease;
- gatilhos;
- modo Sandbox;
- proteção da produção.

Os preflights não deveriam:

- chamar o executor;
- alterar o estado;
- abrir a produção para escrita;
- criar gatilhos;
- consultar dados desnecessários;
- executar etapas operacionais.

---

## 45. Autorizações manuais

As autorizações manuais permaneciam fechadas por padrão.

Elas eram abertas somente para uma execução específica e fechadas imediatamente após o uso.

Esse mecanismo foi utilizado em:

- ativações;
- retomadas;
- recuperações;
- operações extraordinárias.

A autorização não substituía o preflight.

As duas condições eram necessárias.

---

## 46. Persistência de evidências

Os resultados não eram apagados após a recuperação.

O histórico preservava:

- bloqueios;
- ressalvas;
- estados;
- etapas;
- horários;
- métricas;
- diagnósticos;
- decisões;
- recuperações.

Por isso, o consolidado final podia apresentar um bloqueio histórico mesmo com o estado final aprovado.

Essa preservação foi intencional.

---

## 47. Classificação dos resultados

| Status | Interpretação |
|---|---|
| `OK` | Etapa aprovada sem ressalva relevante |
| `RESSALVA` | Etapa aprovada com informação que deve permanecer registrada |
| `BLOQUEIO` | Condição obrigatória não atendida |
| `FALHA_PRESERVADA` | Falha registrada, ciclo protegido contra retomada automática |
| `CICLO_CONCLUIDO` | Fluxo operacional concluído |
| `INTEGRIDADE APROVADA` | Auditoria concluída sem inconsistência impeditiva |

Uma ressalva não era automaticamente uma falha.

Um bloqueio histórico não era automaticamente um bloqueio ativo.

A interpretação dependia de:

- ciclo;
- etapa;
- horário;
- estado atual;
- recuperação posterior;
- resultado final.

---

## 48. Resultado consolidado das recuperações

Ao final do experimento:

- o ciclo estava concluído;
- o ciclo estava aprovado;
- não havia bloqueio ativo;
- não havia falha não tratada;
- não havia janela ativa;
- não havia concessão ativa;
- não havia lease ativa;
- não havia gatilho executor;
- não havia staging inesperado;
- a publicação estava validada;
- a produção permanecia somente leitura;
- os incidentes históricos estavam preservados.

---

## 49. O que os incidentes comprovaram

Os incidentes permitiram validar comportamentos que não seriam comprovados em uma execução sem erros.

Foi possível verificar:

- interrupção segura;
- preservação do estado;
- preservação de backups;
- encerramento automático;
- remoção de gatilho;
- bloqueio de retomada indevida;
- diagnóstico pós-falha;
- correção de regra;
- retomada do mesmo ciclo;
- recuperação de publicação;
- remoção seletiva de resíduo;
- validação posterior;
- manutenção do histórico.

---

## 50. Conclusão

O experimento não foi considerado bem-sucedido porque não apresentou incidentes.

Ele foi considerado bem-sucedido porque os incidentes:

- foram detectados;
- interromperam o fluxo quando necessário;
- não produziram escrita indevida na produção;
- não foram ignorados;
- não foram apagados do histórico;
- puderam ser diagnosticados;
- foram corrigidos;
- foram recuperados;
- foram validados novamente;
- não deixaram resíduos ativos.

A falha preservada demonstrou que o pipeline conseguia parar.

A retomada controlada demonstrou que ele conseguia continuar sem repetir todo o ciclo.

A remoção do staging demonstrou que ele conseguia limpar um resíduo específico sem afetar objetos legítimos.

A auditoria demonstrou que divergências temporais precisavam ser interpretadas de acordo com a natureza dos dados.

O resultado final confirmou que segurança operacional não significa ausência de falhas.

Segurança operacional significa detectar, preservar, interromper, diagnosticar, recuperar e validar.
