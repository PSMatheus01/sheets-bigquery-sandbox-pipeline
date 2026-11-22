# Checklist de implementação

## 1. Identificação

| Campo | Preenchimento |
|---|---|
| Projeto | |
| Responsável | |
| Ambiente | |
| Data da avaliação | |
| Versão | |
| Revisor | |

---

## 2. Problema

- [ ] O problema foi descrito objetivamente.
- [ ] A origem dos dados foi identificada.
- [ ] Os responsáveis pela origem foram identificados.
- [ ] O impacto de uma falha foi descrito.
- [ ] A frequência de atualização foi registrada.
- [ ] O nível de frescor necessário foi definido.
- [ ] O horário operacional foi registrado.
- [ ] As regras existentes foram inventariadas.

---

## 3. Baseline

- [ ] O volume atual foi medido.
- [ ] A quantidade de registros foi registrada.
- [ ] A quantidade de campos foi registrada.
- [ ] O crescimento foi estimado.
- [ ] As fórmulas foram inventariadas.
- [ ] Os erros foram contabilizados.
- [ ] A frequência de mudanças foi observada.
- [ ] As latências foram registradas.
- [ ] As limitações da medição foram documentadas.

---

## 4. Dados

- [ ] O schema foi definido.
- [ ] Os campos obrigatórios foram identificados.
- [ ] Os campos opcionais foram identificados.
- [ ] As chaves foram definidas.
- [ ] As regras de deduplicação foram definidas.
- [ ] Os domínios permitidos foram definidos.
- [ ] Os tipos foram definidos.
- [ ] A retenção foi definida.
- [ ] Os dados sensíveis foram identificados.
- [ ] Dados sintéticos foram preparados para teste.

---

## 5. Ambientes

- [ ] Desenvolvimento está separado.
- [ ] Teste está separado.
- [ ] Homologação está separada, quando aplicável.
- [ ] Produção está protegida.
- [ ] O ambiente shadow está separado.
- [ ] Credenciais não são compartilhadas entre ambientes.
- [ ] Configurações não são compartilhadas indevidamente.
- [ ] Gatilhos estão vinculados ao ambiente correto.

---

## 6. Processamento

- [ ] A camada raw preserva a entrada.
- [ ] A camada clean utiliza conversões seguras.
- [ ] A camada de regras está documentada.
- [ ] A geração candidata está separada.
- [ ] A geração oficial está identificada.
- [ ] A promoção possui critérios.
- [ ] A validação pós-promoção foi definida.
- [ ] Backups foram considerados.
- [ ] A idempotência foi avaliada.

---

## 7. Controles operacionais

- [ ] Existe máquina de estados.
- [ ] As transições permitidas estão documentadas.
- [ ] Existe preflight para operações sensíveis.
- [ ] Existe lock contra concorrência.
- [ ] Concessões possuem validade, quando utilizadas.
- [ ] Leases possuem validade, quando utilizadas.
- [ ] Autorizações manuais ficam fechadas por padrão.
- [ ] Gatilhos são identificáveis.
- [ ] O encerramento remove recursos temporários.
- [ ] O estado de falha segura foi definido.

---

## 8. Validação

- [ ] O schema é validado.
- [ ] As contagens são validadas.
- [ ] A decomposição é validada.
- [ ] As duplicidades são validadas.
- [ ] As regras são validadas.
- [ ] Os indicadores são validados.
- [ ] As exceções são validadas.
- [ ] As divergências são validadas.
- [ ] As métricas são persistidas antes de bloqueios.
- [ ] O resultado final possui parecer.

---

## 9. Publicação

- [ ] O destino foi validado.
- [ ] O destino não é a produção durante o teste.
- [ ] A publicação utiliza valores sanitizados.
- [ ] Textos semelhantes a fórmulas são tratados.
- [ ] O staging possui identidade.
- [ ] A limpeza do staging é seletiva.
- [ ] A publicação possui validação posterior.
- [ ] Existe comportamento definido para publicação parcial.
- [ ] O rollback foi avaliado.

---

## 10. Segurança

- [ ] O princípio de menor privilégio foi aplicado.
- [ ] Não existem credenciais no código.
- [ ] Não existem tokens no repositório.
- [ ] Não existem IDs reais em arquivos públicos.
- [ ] Logs estão sanitizados.
- [ ] Dados pessoais foram minimizados.
- [ ] Dados sintéticos são utilizados nos exemplos.
- [ ] O histórico de commits foi revisado.
- [ ] O arquivo `.gitignore` está atualizado.
- [ ] A política de segurança foi revisada.

---

## 11. Performance

- [ ] A média foi registrada.
- [ ] A mediana foi registrada.
- [ ] O P95 foi registrado.
- [ ] O máximo foi registrado.
- [ ] O gargalo foi identificado.
- [ ] O consumo foi registrado.
- [ ] O orçamento foi definido.
- [ ] Existe margem preventiva.
- [ ] Projeções estão separadas de medições.
- [ ] Metas diferentes foram definidas por tipo de etapa.

---

## 12. Recuperação

- [ ] O estado de falha preserva evidências.
- [ ] A retomada exige validação.
- [ ] A retomada está vinculada ao ciclo.
- [ ] O rollback possui critérios.
- [ ] Os backups são identificáveis.
- [ ] Recursos temporários podem ser removidos seletivamente.
- [ ] O encerramento foi testado.
- [ ] Gatilhos residuais são detectados.
- [ ] Concessões residuais são detectadas.
- [ ] Leases residuais são detectadas.

---

## 13. Documentação

- [ ] A arquitetura está documentada.
- [ ] A metodologia está documentada.
- [ ] Os resultados estão documentados.
- [ ] Os incidentes estão documentados.
- [ ] As limitações estão documentadas.
- [ ] Os casos de uso estão classificados.
- [ ] O guia de adaptação está disponível.
- [ ] As evidências estão sanitizadas.
- [ ] Os exemplos são reproduzíveis.
- [ ] Os links internos foram testados.

---

## 14. Parecer

| Critério | Resultado |
|---|---|
| Funcionalidade | |
| Integridade | |
| Segurança | |
| Performance | |
| Consumo | |
| Recuperação | |
| Documentação | |
| Resultado final | |

### Decisão

- [ ] Aprovado
- [ ] Aprovado com ressalvas
- [ ] Bloqueado
- [ ] Reprovado

### Observações

Preencher as observações relevantes antes da aprovação.
