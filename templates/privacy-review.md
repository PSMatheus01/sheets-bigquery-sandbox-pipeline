# Revisão de privacidade

## 1. Identificação

| Campo | Preenchimento |
|---|---|
| Projeto | |
| Arquivo ou processo | |
| Responsável | |
| Data | |
| Revisor | |

---

## 2. Dados utilizados

| Categoria | Presente | Finalidade |
|---|---|---|
| Nome | | |
| Documento | | |
| E-mail | | |
| Telefone | | |
| Endereço | | |
| Identificador interno | | |
| Dado financeiro | | |
| Dado sensível | | |
| Metadado | | |
| Dado agregado | | |

---

## 3. Necessidade

Para cada dado utilizado, confirmar:

- [ ] Existe finalidade definida
- [ ] O dado é necessário
- [ ] Não existe alternativa menos invasiva
- [ ] A retenção foi definida
- [ ] O acesso foi limitado
- [ ] O descarte foi definido

---

## 4. Minimização

- [ ] Somente campos necessários são coletados
- [ ] Conteúdo integral não é armazenado sem necessidade
- [ ] Logs utilizam valores agregados
- [ ] Identificadores são removidos
- [ ] Hashes não são utilizados como substituto automático de anonimização
- [ ] Dados sintéticos são utilizados em exemplos
- [ ] Dados reais não são copiados para documentação

---

## 5. Repositório

Confirmar ausência de:

- [ ] Credenciais
- [ ] Tokens
- [ ] Chaves
- [ ] IDs reais de planilhas
- [ ] IDs reais de projetos
- [ ] IDs de implantação
- [ ] IDs de gatilhos
- [ ] Chaves de usuário
- [ ] URLs internas
- [ ] Logs brutos
- [ ] Dados de clientes
- [ ] Nomes reais
- [ ] Documentos
- [ ] E-mails
- [ ] Telefones

Todos os itens devem permanecer desmarcados quando a informação estiver ausente.

---

## 6. Logs

- [ ] Logs são estruturados
- [ ] Logs são sanitizados
- [ ] Campos sensíveis são removidos
- [ ] Dados pessoais não são registrados
- [ ] IDs são substituídos quando necessário
- [ ] Retenção dos logs foi avaliada
- [ ] Acesso aos logs foi restringido

---

## 7. Dados sintéticos

- [ ] Foram criados especificamente para o projeto
- [ ] Não foram derivados diretamente de registros reais
- [ ] Não preservam combinações identificáveis
- [ ] Não utilizam nomes reais
- [ ] Não utilizam documentos reais
- [ ] Não utilizam endereços reais
- [ ] Não utilizam URLs internas
- [ ] Podem ser publicados com segurança

---

## 8. Acesso

| Perfil | Necessidade | Permissão |
|---|---|---|
| Desenvolvimento | | |
| Planejamento | | |
| Operação | | |
| Auditoria | | |
| Administração | | |

---

## 9. Retenção

| Tipo de dado | Retenção | Justificativa | Descarte |
|---|---|---|---|
| Entrada | | | |
| Processado | | | |
| Log | | | |
| Backup | | | |
| Evidência | | | |

---

## 10. Incidentes

Existe procedimento para:

- [ ] Identificação
- [ ] Contenção
- [ ] Preservação de evidências
- [ ] Avaliação de impacto
- [ ] Remoção de acesso
- [ ] Correção
- [ ] Comunicação
- [ ] Registro do encerramento

---

## 11. Parecer

- [ ] Aprovado
- [ ] Aprovado com controles
- [ ] Revisão necessária
- [ ] Publicação bloqueada

### Justificativa

Registrar o parecer com base nos dados efetivamente utilizados.
