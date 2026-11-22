# Plano de testes

## 1. Identificação

| Campo | Preenchimento |
|---|---|
| Projeto | |
| Versão | |
| Ambiente | |
| Responsável | |
| Data de início | |
| Data de encerramento | |

---

## 2. Objetivo

Descrever o que será validado e qual decisão o teste deverá sustentar.

---

## 3. Escopo incluído

- [ ] Origem
- [ ] Detecção
- [ ] Captura
- [ ] Limpeza
- [ ] Regras
- [ ] Indicadores
- [ ] Exceções
- [ ] Publicação
- [ ] Auditoria
- [ ] Recuperação
- [ ] Encerramento
- [ ] Performance
- [ ] Consumo

---

## 4. Escopo não incluído

Registrar explicitamente o que não será validado.

---

## 5. Ambientes

| Ambiente | Finalidade | Dados permitidos | Escrita permitida |
|---|---|---|---|
| Desenvolvimento | | | |
| Teste | | | |
| Shadow | | | |
| Produção | | | |

---

## 6. Dados de teste

- [ ] Dados sintéticos
- [ ] Cópia sanitizada
- [ ] Dados agregados
- [ ] Produção somente leitura

### Restrições

Registrar os dados que não podem ser utilizados.

---

## 7. Casos de teste

| ID | Cenário | Entrada | Ação | Resultado esperado | Evidência |
|---|---|---|---|---|---|
| T-01 | | | | | |
| T-02 | | | | | |
| T-03 | | | | | |
| T-04 | | | | | |
| T-05 | | | | | |

---

## 8. Testes funcionais

- [ ] Dados carregados
- [ ] Schema validado
- [ ] Conversões seguras
- [ ] Regras aplicadas
- [ ] Indicadores calculados
- [ ] Exceções identificadas
- [ ] Divergências identificadas
- [ ] Auditoria aprovada

---

## 9. Testes de segurança

- [ ] Produção somente leitura
- [ ] Sem credenciais no código
- [ ] Sem dados pessoais em logs
- [ ] Sem gatilho indevido
- [ ] Sem escrita fora do destino
- [ ] Autorização fechada por padrão
- [ ] Locks verificados
- [ ] Encerramento verificado

---

## 10. Testes de falha

| ID | Falha provocada | Comportamento esperado | Resultado |
|---|---|---|---|
| F-01 | Schema inválido | Bloqueio | |
| F-02 | Contagem divergente | Bloqueio | |
| F-03 | Objeto ausente | Bloqueio | |
| F-04 | Publicação incompleta | Preservação | |
| F-05 | Auditoria reprovada | Falha preservada | |

---

## 11. Testes de recuperação

- [ ] Evidência preservada
- [ ] Estado preservado
- [ ] Backup disponível
- [ ] Retomada controlada
- [ ] Publicação revalidada
- [ ] Auditoria reexecutada
- [ ] Resíduos removidos
- [ ] Estado final íntegro

---

## 12. Performance

| Métrica | Meta | Resultado |
|---|---:|---:|
| Média | | |
| Mediana | | |
| P95 | | |
| Máximo | | |
| Runtime diário | | |
| Bytes processados | | |

---

## 13. Critérios de aprovação

- [ ] Todos os bloqueios foram resolvidos
- [ ] Nenhum dado foi perdido
- [ ] Nenhuma escrita indevida ocorreu
- [ ] A auditoria foi aprovada
- [ ] A recuperação foi validada
- [ ] Os limites foram documentados
- [ ] O estado final está íntegro

---

## 14. Resultado

- [ ] Aprovado
- [ ] Aprovado com ressalvas
- [ ] Bloqueado
- [ ] Reprovado

### Parecer

Registrar o parecer técnico e as evidências utilizadas.
