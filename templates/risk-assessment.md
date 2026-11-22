# Avaliação de Riscos

## 1. Identificação

| Campo | Preenchimento |
|---|---|
| Projeto | |
| Processo avaliado | |
| Responsável pela avaliação | |
| Participantes | |
| Ambiente | Desenvolvimento / Teste / Homologação / Produção |
| Versão avaliada | |
| Data da avaliação | |
| Período observado | |
| Documento relacionado | |
| Status da avaliação | Em elaboração / Concluída / Revisada |

---

## 2. Objetivo

Este documento registra os riscos identificados durante a avaliação de uma solução, processo, automação ou pipeline de dados.

A avaliação deve:

- identificar eventos capazes de comprometer a operação;
- estimar a probabilidade e o impacto de cada risco;
- registrar os controles existentes;
- definir ações de tratamento;
- avaliar o risco residual;
- documentar evidências;
- apoiar uma decisão objetiva de aprovação, correção ou bloqueio.

---

## 3. Escopo

### 3.1 Incluído na avaliação

- [ ] Entrada e origem dos dados
- [ ] Validação dos dados
- [ ] Transformação e processamento
- [ ] Armazenamento
- [ ] Publicação dos resultados
- [ ] Auditoria
- [ ] Monitoramento
- [ ] Controle de acesso
- [ ] Segurança
- [ ] Desempenho
- [ ] Recuperação de falhas
- [ ] Retenção e descarte
- [ ] Custos e limites operacionais
- [ ] Dependências externas
- [ ] Manutenção
- [ ] Documentação

### 3.2 Fora do escopo

Descrever os elementos que não foram avaliados:

- 
- 
- 

### 3.3 Ambientes avaliados

| Ambiente | Avaliado | Evidência |
|---|---:|---|
| Desenvolvimento | Não | |
| Teste | Não | |
| Homologação | Não | |
| Produção | Não | |

---

## 4. Premissas

Registrar somente premissas confirmadas ou formalmente aceitas.

| ID | Premissa | Origem da confirmação | Data |
|---|---|---|---|
| P-01 | | | |
| P-02 | | | |
| P-03 | | | |

---

## 5. Dependências

| ID | Dependência | Tipo | Criticidade | Responsável |
|---|---|---|---|---|
| D-01 | | Interna / Externa | Baixa / Moderada / Alta / Crítica | |
| D-02 | | Interna / Externa | Baixa / Moderada / Alta / Crítica | |
| D-03 | | Interna / Externa | Baixa / Moderada / Alta / Crítica | |

---

## 6. Categorias de risco

Os riscos devem ser classificados em uma ou mais categorias.

| Categoria | Descrição |
|---|---|
| Dados | Integridade, consistência, qualidade, duplicidade, perda ou corrupção de dados |
| Segurança | Acessos indevidos, credenciais expostas, permissões excessivas ou vazamento |
| Privacidade | Exposição ou tratamento inadequado de dados pessoais ou sensíveis |
| Operação | Indisponibilidade, execução incorreta, interrupções ou dependência manual |
| Performance | Lentidão, estouro de tempo, gargalo ou consumo excessivo de recursos |
| Integração | Falha na comunicação entre sistemas, APIs, bancos, arquivos ou serviços |
| Infraestrutura | Falha de ambiente, rede, armazenamento, contêiner ou serviço externo |
| Recuperação | Incapacidade de retomar o fluxo ou restaurar um estado consistente |
| Auditoria | Ausência de rastreabilidade, evidências incompletas ou logs insuficientes |
| Conformidade | Descumprimento de política, contrato, norma ou obrigação aplicável |
| Manutenção | Complexidade, acoplamento, falta de documentação ou dependência de pessoa |
| Custo | Consumo não previsto, cobrança indevida ou ausência de controle orçamentário |
| Escalabilidade | Incapacidade de atender ao crescimento de volume, frequência ou usuários |

---

## 7. Critérios de probabilidade

A probabilidade representa a chance de o risco ocorrer no contexto avaliado.

| Valor | Nível | Critério de referência |
|---:|---|---|
| 1 | Raro | Pode ocorrer apenas em condições excepcionais |
| 2 | Improvável | Existe possibilidade, mas não há recorrência observada |
| 3 | Possível | Pode ocorrer durante a operação normal |
| 4 | Provável | Há sinais, histórico ou condições que favorecem a ocorrência |
| 5 | Quase certo | O evento é recorrente ou esperado sem intervenção |

---

## 8. Critérios de impacto

O impacto representa a gravidade das consequências caso o risco ocorra.

| Valor | Nível | Critério de referência |
|---:|---|---|
| 1 | Insignificante | Efeito mínimo, sem interrupção relevante ou perda de dados |
| 2 | Baixo | Efeito limitado, correção simples e impacto operacional pequeno |
| 3 | Moderado | Degradação perceptível, retrabalho ou interrupção parcial |
| 4 | Alto | Interrupção relevante, perda operacional ou comprometimento de dados |
| 5 | Crítico | Paralisação, perda grave, exposição sensível ou dano irreversível |

---

## 9. Cálculo do nível de risco

O nível do risco é calculado pela fórmula:

**Nível de risco = Probabilidade × Impacto**

### 9.1 Classificação

| Pontuação | Classificação | Tratamento esperado |
|---:|---|---|
| 1 a 4 | Baixo | Aceitar ou monitorar |
| 5 a 9 | Moderado | Planejar controle e acompanhar |
| 10 a 16 | Alto | Tratar antes da aprovação definitiva |
| 17 a 25 | Crítico | Bloquear até que o risco seja reduzido |

### 9.2 Matriz de risco

| Impacto ↓ / Probabilidade → | 1 | 2 | 3 | 4 | 5 |
|---|---:|---:|---:|---:|---:|
| 5 — Crítico | 5 | 10 | 15 | 20 | 25 |
| 4 — Alto | 4 | 8 | 12 | 16 | 20 |
| 3 — Moderado | 3 | 6 | 9 | 12 | 15 |
| 2 — Baixo | 2 | 4 | 6 | 8 | 10 |
| 1 — Insignificante | 1 | 2 | 3 | 4 | 5 |

---

## 10. Estratégias de tratamento

| Estratégia | Definição |
|---|---|
| Evitar | Remover a atividade ou condição que origina o risco |
| Reduzir | Implementar controles para diminuir a probabilidade ou o impacto |
| Transferir | Compartilhar ou transferir a responsabilidade para outra parte |
| Aceitar | Manter o risco conscientemente, com justificativa e monitoramento |
| Explorar | Aproveitar uma oportunidade associada ao risco, com controle formal |

---

## 11. Registro consolidado de riscos

| ID | Risco | Categoria | Causa | Consequência | Probabilidade | Impacto | Pontuação | Classificação | Tratamento | Responsável | Status |
|---|---|---|---|---|---:|---:|---:|---|---|---|---|
| R-01 | | | | | | | | | | | Identificado |
| R-02 | | | | | | | | | | | Identificado |
| R-03 | | | | | | | | | | | Identificado |
| R-04 | | | | | | | | | | | Identificado |
| R-05 | | | | | | | | | | | Identificado |

---

## 12. Detalhamento dos riscos

### R-01 — Título do risco

#### Descrição

Descrever objetivamente o evento de risco.

#### Categoria

- Categoria principal:
- Categorias relacionadas:

#### Causa

Descrever as condições que podem provocar o evento.

#### Consequência

Descrever os efeitos operacionais, técnicos, financeiros ou de segurança.

#### Evidências

- 
- 
- 

#### Avaliação inicial

| Critério | Valor |
|---|---:|
| Probabilidade | |
| Impacto | |
| Pontuação | |
| Classificação | |

#### Controles existentes

- 
- 
- 

#### Tratamento definido

- Estratégia:
- Ação:
- Responsável:
- Prazo:
- Evidência esperada:

#### Avaliação residual

| Critério | Valor |
|---|---:|
| Probabilidade residual | |
| Impacto residual | |
| Pontuação residual | |
| Classificação residual | |

#### Status

- [ ] Identificado
- [ ] Em análise
- [ ] Em tratamento
- [ ] Controlado
- [ ] Aceito
- [ ] Encerrado
- [ ] Bloqueante

---

### R-02 — Título do risco

#### Descrição

Descrever objetivamente o evento de risco.

#### Categoria

- Categoria principal:
- Categorias relacionadas:

#### Causa

Descrever as condições que podem provocar o evento.

#### Consequência

Descrever os efeitos operacionais, técnicos, financeiros ou de segurança.

#### Evidências

- 
- 
- 

#### Avaliação inicial

| Critério | Valor |
|---|---:|
| Probabilidade | |
| Impacto | |
| Pontuação | |
| Classificação | |

#### Controles existentes

- 
- 
- 

#### Tratamento definido

- Estratégia:
- Ação:
- Responsável:
- Prazo:
- Evidência esperada:

#### Avaliação residual

| Critério | Valor |
|---|---:|
| Probabilidade residual | |
| Impacto residual | |
| Pontuação residual | |
| Classificação residual | |

#### Status

- [ ] Identificado
- [ ] Em análise
- [ ] Em tratamento
- [ ] Controlado
- [ ] Aceito
- [ ] Encerrado
- [ ] Bloqueante

---

### R-03 — Título do risco

#### Descrição

Descrever objetivamente o evento de risco.

#### Categoria

- Categoria principal:
- Categorias relacionadas:

#### Causa

Descrever as condições que podem provocar o evento.

#### Consequência

Descrever os efeitos operacionais, técnicos, financeiros ou de segurança.

#### Evidências

- 
- 
- 

#### Avaliação inicial

| Critério | Valor |
|---|---:|
| Probabilidade | |
| Impacto | |
| Pontuação | |
| Classificação | |

#### Controles existentes

- 
- 
- 

#### Tratamento definido

- Estratégia:
- Ação:
- Responsável:
- Prazo:
- Evidência esperada:

#### Avaliação residual

| Critério | Valor |
|---|---:|
| Probabilidade residual | |
| Impacto residual | |
| Pontuação residual | |
| Classificação residual | |

#### Status

- [ ] Identificado
- [ ] Em análise
- [ ] Em tratamento
- [ ] Controlado
- [ ] Aceito
- [ ] Encerrado
- [ ] Bloqueante

---

### R-04 — Título do risco

#### Descrição

Descrever objetivamente o evento de risco.

#### Categoria

- Categoria principal:
- Categorias relacionadas:

#### Causa

Descrever as condições que podem provocar o evento.

#### Consequência

Descrever os efeitos operacionais, técnicos, financeiros ou de segurança.

#### Evidências

- 
- 
- 

#### Avaliação inicial

| Critério | Valor |
|---|---:|
| Probabilidade | |
| Impacto | |
| Pontuação | |
| Classificação | |

#### Controles existentes

- 
- 
- 

#### Tratamento definido

- Estratégia:
- Ação:
- Responsável:
- Prazo:
- Evidência esperada:

#### Avaliação residual

| Critério | Valor |
|---|---:|
| Probabilidade residual | |
| Impacto residual | |
| Pontuação residual | |
| Classificação residual | |

#### Status

- [ ] Identificado
- [ ] Em análise
- [ ] Em tratamento
- [ ] Controlado
- [ ] Aceito
- [ ] Encerrado
- [ ] Bloqueante

---

### R-05 — Título do risco

#### Descrição

Descrever objetivamente o evento de risco.

#### Categoria

- Categoria principal:
- Categorias relacionadas:

#### Causa

Descrever as condições que podem provocar o evento.

#### Consequência

Descrever os efeitos operacionais, técnicos, financeiros ou de segurança.

#### Evidências

- 
- 
- 

#### Avaliação inicial

| Critério | Valor |
|---|---:|
| Probabilidade | |
| Impacto | |
| Pontuação | |
| Classificação | |

#### Controles existentes

- 
- 
- 

#### Tratamento definido

- Estratégia:
- Ação:
- Responsável:
- Prazo:
- Evidência esperada:

#### Avaliação residual

| Critério | Valor |
|---|---:|
| Probabilidade residual | |
| Impacto residual | |
| Pontuação residual | |
| Classificação residual | |

#### Status

- [ ] Identificado
- [ ] Em análise
- [ ] Em tratamento
- [ ] Controlado
- [ ] Aceito
- [ ] Encerrado
- [ ] Bloqueante

---

## 13. Riscos mínimos a verificar

### 13.1 Dados

- [ ] Dados incompletos
- [ ] Dados duplicados
- [ ] Tipos incompatíveis
- [ ] Datas inválidas
- [ ] Chaves ausentes
- [ ] Dados fora da janela de referência
- [ ] Divergência entre origem e destino
- [ ] Perda de rastreabilidade
- [ ] Alteração da origem durante o processamento
- [ ] Uso acidental de dados reais em ambiente de teste

### 13.2 Segurança e privacidade

- [ ] Credenciais expostas
- [ ] Identificadores reais publicados
- [ ] Permissões excessivas
- [ ] Logs com dados sensíveis
- [ ] Acesso não autorizado
- [ ] Escrita indevida na origem
- [ ] Publicação em destino incorreto
- [ ] Uso de dados pessoais sem necessidade
- [ ] Segredos armazenados no código-fonte

### 13.3 Operação

- [ ] Execuções concorrentes
- [ ] Gatilhos duplicados
- [ ] Janela de execução inválida
- [ ] Estado operacional inconsistente
- [ ] Processo interrompido sem recuperação
- [ ] Retomada automática indevida
- [ ] Autorização manual mantida aberta
- [ ] Dependência de intervenção não documentada
- [ ] Falha silenciosa
- [ ] Ausência de evidência após a execução

### 13.4 Performance e consumo

- [ ] Tempo acima da meta
- [ ] Volume acima da capacidade
- [ ] Consultas sem limite de processamento
- [ ] Consumo de cota não monitorado
- [ ] Publicação com número excessivo de operações
- [ ] Gargalo na leitura ou escrita
- [ ] Crescimento não linear
- [ ] Estouro do tempo máximo de execução
- [ ] Projeção confundida com consumo medido

### 13.5 Recuperação

- [ ] Ausência de backup
- [ ] Backup não validado
- [ ] Rollback não testado
- [ ] Recuperação sem preflight
- [ ] Remoção incorreta de objetos
- [ ] Estado de falha não preservado
- [ ] Evidências sobrescritas
- [ ] Retomada em ciclo incorreto
- [ ] Gatilho residual após encerramento

### 13.6 Manutenção

- [ ] Regras duplicadas
- [ ] Constantes dispersas
- [ ] Dependências não documentadas
- [ ] Código acoplado ao ambiente original
- [ ] Falta de testes reproduzíveis
- [ ] Falta de exemplos sintéticos
- [ ] Documentação divergente do código
- [ ] Nomes ambíguos
- [ ] Ausência de controle de versão

---

## 14. Controles avaliados

| Controle | Implementado | Validado | Evidência | Observação |
|---|---:|---:|---|---|
| Bloqueio de execução concorrente | Não | Não | | |
| Validação de identidade do ambiente | Não | Não | | |
| Produção somente leitura | Não | Não | | |
| Autorização manual fechada por padrão | Não | Não | | |
| Limite de processamento | Não | Não | | |
| Expiração e retenção controladas | Não | Não | | |
| Tabelas ou objetos candidatos | Não | Não | | |
| Backup antes da promoção | Não | Não | | |
| Validação pós-promoção | Não | Não | | |
| Estado de falha preservada | Não | Não | | |
| Recuperação controlada | Não | Não | | |
| Auditoria independente | Não | Não | | |
| Remoção seletiva de gatilhos | Não | Não | | |
| Sanitização de logs | Não | Não | | |
| Uso de dados sintéticos | Não | Não | | |

---

## 15. Plano de tratamento

| Ação | Riscos relacionados | Prioridade | Responsável | Prazo | Evidência de conclusão | Status |
|---|---|---|---|---|---|---|
| A-01 | | Baixa / Moderada / Alta / Crítica | | | | Não iniciada |
| A-02 | | Baixa / Moderada / Alta / Crítica | | | | Não iniciada |
| A-03 | | Baixa / Moderada / Alta / Crítica | | | | Não iniciada |
| A-04 | | Baixa / Moderada / Alta / Crítica | | | | Não iniciada |
| A-05 | | Baixa / Moderada / Alta / Crítica | | | | Não iniciada |

---

## 16. Risco residual

O risco residual é o risco que permanece depois da aplicação e validação dos controles.

| ID | Pontuação inicial | Classificação inicial | Controles aplicados | Pontuação residual | Classificação residual | Aceito |
|---|---:|---|---|---:|---|---:|
| R-01 | | | | | | Não |
| R-02 | | | | | | Não |
| R-03 | | | | | | Não |
| R-04 | | | | | | Não |
| R-05 | | | | | | Não |

A aceitação de risco deve conter:

- justificativa objetiva;
- responsável pela aceitação;
- data da decisão;
- período de validade;
- condição de reavaliação;
- evidência da aprovação.

---

## 17. Critérios de bloqueio

A avaliação deve resultar em bloqueio quando houver pelo menos uma das seguintes condições:

- risco crítico sem controle validado;
- possibilidade de escrita indevida na origem;
- exposição de credenciais ou dados sensíveis;
- ausência de recuperação para falha destrutiva;
- divergência de dados sem explicação comprovada;
- execução em ambiente ou identidade incorreta;
- publicação sem validação de integridade;
- gatilho, concessão ou bloqueio residual não previsto;
- dependência de autorização manual mantida aberta;
- impossibilidade de comprovar o estado final;
- evidência insuficiente para avaliar um risco de alto impacto.

---

## 18. Critérios para aprovação

### 18.1 Aprovado

Aplicável quando:

- não existem riscos altos ou críticos pendentes;
- os controles obrigatórios foram validados;
- o risco residual foi aceito formalmente;
- as evidências são suficientes;
- o estado final é íntegro.

### 18.2 Aprovado com ressalvas

Aplicável quando:

- permanecem riscos baixos ou moderados;
- as limitações estão documentadas;
- não existe risco crítico sem controle;
- as ressalvas não impedem o objetivo avaliado;
- existe responsável pelo acompanhamento.

### 18.3 Bloqueado

Aplicável quando:

- existe impedimento temporário;
- faltam evidências essenciais;
- um controle obrigatório ainda não foi validado;
- existe risco alto ou crítico pendente;
- a execução segura depende de uma correção.

### 18.4 Reprovado

Aplicável quando:

- o risco é incompatível com o objetivo;
- a solução viola um requisito obrigatório;
- o tratamento necessário é inviável;
- o benefício não justifica o risco residual;
- a integridade ou segurança não pode ser comprovada.

---

## 19. Parecer final

### 19.1 Resultado

Selecionar uma opção:

- [ ] Aprovado
- [ ] Aprovado com ressalvas
- [ ] Bloqueado
- [ ] Reprovado

### 19.2 Resumo do parecer

Descrever objetivamente:

- os principais riscos identificados;
- os controles implementados;
- os riscos residuais;
- as limitações da avaliação;
- a justificativa da decisão.

### 19.3 Condições associadas

- 
- 
- 

### 19.4 Responsáveis

| Papel | Nome ou função | Data | Aprovação |
|---|---|---|---|
| Responsável pela avaliação | | | |
| Responsável técnico | | | |
| Responsável operacional | | | |
| Responsável pela decisão | | | |

---

## 20. Evidências relacionadas

| ID | Evidência | Localização | Tipo | Data |
|---|---|---|---|---|
| E-01 | | | Log / Relatório / Consulta / Captura / Documento | |
| E-02 | | | Log / Relatório / Consulta / Captura / Documento | |
| E-03 | | | Log / Relatório / Consulta / Captura / Documento | |
| E-04 | | | Log / Relatório / Consulta / Captura / Documento | |
| E-05 | | | Log / Relatório / Consulta / Captura / Documento | |

---

## 21. Histórico de revisões

| Versão | Data | Responsável | Alteração |
|---|---|---|---|
| 1.0.0 | | | Criação da avaliação |
