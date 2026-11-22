# Guia de contribuição

## 1. Objetivo

Este documento estabelece os critérios para contribuições no repositório `sheets-bigquery-sandbox-pipeline`.

O repositório apresenta um estudo técnico reproduzível sobre:

- processamento externo de dados originados em planilhas;
- uso experimental do BigQuery Sandbox;
- orquestração com Google Apps Script;
- validação por camadas;
- auditoria;
- recuperação controlada;
- publicação em ambiente isolado;
- avaliação empírica de fórmulas e performance.

Toda contribuição deve preservar o caráter sanitizado, documental e reproduzível do projeto.

---

## 2. Princípios

As contribuições devem respeitar os seguintes princípios:

1. não utilizar dados reais;
2. não expor credenciais;
3. não expor identificadores do ambiente original;
4. não depender de acesso à operação que originou o estudo;
5. manter exemplos executáveis apenas com dados sintéticos;
6. separar resultados medidos de projeções;
7. diferenciar fatos comprovados de possibilidades compatíveis;
8. preservar a rastreabilidade das alterações;
9. documentar limitações;
10. evitar promessas não validadas pelo experimento.

---

## 3. Conteúdo aceito

São aceitas contribuições relacionadas a:

- correções de documentação;
- correções de links;
- melhoria da organização dos documentos;
- exemplos sintéticos;
- validações adicionais;
- correções nos scripts SQL;
- correções nos exemplos de Apps Script;
- testes reproduzíveis;
- melhorias de segurança;
- melhorias de acessibilidade;
- correções nos diagramas;
- traduções que preservem o significado técnico;
- correções de compatibilidade com serviços documentados.

---

## 4. Conteúdo não aceito

Não são aceitas contribuições que incluam:

- dados pessoais;
- dados de clientes;
- nomes de pessoas da operação original;
- nomes de empresas não autorizadas;
- identificadores de planilhas reais;
- identificadores de projetos reais;
- tokens;
- chaves de API;
- credenciais;
- URLs internas;
- logs brutos sem sanitização;
- consultas contra ambientes de produção;
- funções destrutivas sem proteção;
- código que escreva em uma origem real;
- afirmações não sustentadas por evidências;
- resultados inventados;
- métricas apresentadas sem origem;
- código malicioso;
- arquivos binários sem justificativa.

---

## 5. Estrutura do repositório

| Caminho | Finalidade |
|---|---|
| `architecture/` | Representação da arquitetura observada e experimental |
| `docs/` | Documentação técnica consolidada |
| `evidence/` | Evidências sanitizadas e resumos experimentais |
| `examples/` | Dados, configurações e resultados sintéticos |
| `src/apps-script/` | Exemplos sanitizados em Google Apps Script |
| `src/sql/` | Pipeline SQL reproduzível |
| `templates/` | Modelos reutilizáveis de avaliação e controle |
| `assets/` | Elementos visuais utilizados na documentação |

As contribuições devem ser adicionadas à pasta correspondente à sua finalidade.

A pasta `assets/` somente deve ser considerada disponível quando estiver efetivamente presente no repositório.

---

## 6. Preparação da contribuição

Antes de alterar o repositório:

1. leia o `README.md`;
2. consulte os documentos relacionados à alteração;
3. verifique se o arquivo já existe;
4. confirme que a mudança não duplica conteúdo;
5. identifique os resultados experimentais afetados;
6. remova qualquer dado real;
7. registre a justificativa técnica da mudança.

---

## 7. Documentação em Markdown

Arquivos Markdown devem:

- utilizar extensão `.md`;
- possuir um único título principal;
- respeitar a hierarquia dos títulos;
- usar tabelas válidas;
- usar listas consistentes;
- manter linhas em branco entre seções;
- evitar HTML quando o Markdown for suficiente;
- usar links relativos para arquivos internos;
- informar claramente as limitações;
- ser verificados no Preview do GitHub.

### 7.1 Exemplo de link relativo

Use:

`[Resultados experimentais](docs/results.md)`

### 7.2 Exemplo de referência a código

Use:

`src/sql/03_rules_example.sql`

### 7.3 Regras para títulos

A hierarquia recomendada é:

- `#` para o título principal;
- `##` para seções;
- `###` para subseções;
- `####` somente quando necessário.

Não avance diretamente de um título de nível 2 para um título de nível 4.

---

## 8. Dados sintéticos

Contribuições com dados de exemplo devem:

- utilizar apenas informações fictícias;
- evitar nomes que possam ser confundidos com pessoas reais;
- manter o esquema documentado;
- incluir casos válidos e inválidos quando necessário;
- preservar inconsistências intencionais;
- informar o resultado esperado;
- evitar volumes desnecessários;
- usar codificação UTF-8.

Os arquivos sintéticos não devem ser substituídos por exportações de ambientes reais.

---

## 9. Arquivos CSV

Arquivos CSV devem:

- utilizar vírgula como separador;
- possuir cabeçalho;
- manter a mesma quantidade de campos em cada registro;
- usar ponto como separador decimal;
- não incluir símbolos de moeda;
- não incluir separadores de milhar;
- representar valores ausentes com campo vazio;
- utilizar datas em formato ISO quando aplicável;
- utilizar codificação UTF-8;
- terminar com uma quebra de linha.

Antes do envio, confira o arquivo no visualizador do GitHub.

---

## 10. Arquivos JSON

Arquivos JSON devem:

- iniciar com `{` ou `[`;
- terminar com `}` ou `]`;
- usar aspas duplas;
- utilizar `true`, `false` ou `null` sem aspas;
- usar ponto como separador decimal;
- não conter comentários;
- não conter vírgulas excedentes;
- não conter credenciais;
- não conter identificadores reais;
- ser validados antes do commit.

---

## 11. Scripts SQL

Scripts SQL devem:

- usar GoogleSQL quando destinados ao BigQuery;
- informar os pré-requisitos;
- utilizar os identificadores sintéticos do repositório;
- evitar acesso a ambientes reais;
- manter limites de processamento quando aplicável;
- preservar a rastreabilidade dos registros;
- usar conversões seguras;
- evitar operações destrutivas desnecessárias;
- documentar os resultados esperados;
- manter a retenção compatível com o ambiente experimental;
- separar dados medidos de projeções.

Operações como `UPDATE`, `DELETE`, `MERGE` e alterações destrutivas devem possuir justificativa e proteção explícitas.

---

## 12. Exemplos em Apps Script

Arquivos `.gs` devem:

- ser compatíveis com o runtime V8;
- evitar credenciais incorporadas;
- usar configurações sanitizadas;
- manter publicação desabilitada por padrão;
- manter autorizações manuais fechadas por padrão;
- evitar escrita em fontes reais;
- sanitizar os logs;
- validar a identidade do ambiente;
- controlar execuções concorrentes;
- registrar resultados estruturados;
- documentar os serviços avançados exigidos;
- remover recursos temporários de forma seletiva.

---

## 13. Evidências

Evidências adicionadas ao repositório devem ser:

- sanitizadas;
- agregadas;
- rastreáveis;
- suficientes para sustentar a conclusão;
- independentes de acesso ao ambiente original.

Não publique logs brutos quando um resumo estruturado for suficiente.

Toda projeção deve ser identificada como projeção. Valores projetados não devem ser apresentados como consumo medido.

---

## 14. Segurança

Antes do commit, procure por:

- senhas;
- tokens;
- chaves de API;
- credenciais;
- URLs privadas;
- identificadores de planilhas;
- identificadores de projetos operacionais;
- e-mails;
- números de documentos;
- nomes de clientes;
- conteúdo de células reais;
- dados pessoais;
- logs não sanitizados.

Problemas de segurança não devem ser publicados em uma issue pública. Siga as orientações do arquivo `SECURITY.md`.

---

## 15. Commits

As mensagens de commit devem ser curtas, objetivas e escritas no modo imperativo.

### 15.1 Prefixos recomendados

| Prefixo | Uso |
|---|---|
| `docs:` | Documentação |
| `architecture:` | Arquitetura |
| `evidence:` | Evidências |
| `examples:` | Exemplos sintéticos |
| `sql:` | Scripts SQL |
| `apps-script:` | Apps Script |
| `templates:` | Templates |
| `security:` | Segurança |
| `assets:` | Elementos visuais |
| `fix:` | Correção |
| `chore:` | Manutenção |

### 15.2 Exemplos de mensagens

- `docs: correct relative links`
- `sql: fix synthetic classification rule`
- `security: remove exposed identifier`
- `examples: correct expected output`
- `apps-script: improve synthetic preflight`

Um commit deve representar uma alteração lógica identificável.

---

## 16. Pull requests

Uma contribuição deve informar:

- o problema corrigido;
- a alteração realizada;
- os arquivos afetados;
- as validações executadas;
- as limitações conhecidas;
- o impacto nos resultados existentes;
- a confirmação de ausência de dados sensíveis.

Alterações extensas devem ser divididas em partes revisáveis.

### 16.1 Título

O título deve representar claramente a alteração.

Exemplo:

`docs: correct experimental methodology references`

### 16.2 Descrição mínima

A descrição deve responder:

1. O que foi alterado?
2. Por que a alteração foi necessária?
3. Quais arquivos foram afetados?
4. Como a alteração foi validada?
5. Existe alguma limitação?
6. A alteração utiliza somente dados sintéticos?

---

## 17. Checklist da contribuição

Antes de enviar:

- [ ] Confirmei que o arquivo ainda não existia
- [ ] Evitei duplicação de conteúdo
- [ ] Usei apenas dados sintéticos
- [ ] Removi identificadores reais
- [ ] Removi credenciais e tokens
- [ ] Validei os arquivos JSON
- [ ] Conferi os arquivos CSV
- [ ] Revisei a sintaxe SQL
- [ ] Revisei os exemplos em Apps Script
- [ ] Testei os links relativos
- [ ] Verifiquei o Preview do Markdown
- [ ] Diferenciei medições de projeções
- [ ] Documentei as limitações
- [ ] Atualizei o histórico quando aplicável
- [ ] Revisei a alteração sob a perspectiva de segurança

---

## 18. Critérios de revisão

Uma contribuição pode ser bloqueada quando:

- duplicar conteúdo existente;
- introduzir dados reais;
- apresentar risco de segurança;
- alterar resultados sem evidência;
- quebrar a reprodução dos exemplos;
- introduzir links inválidos;
- remover limitações relevantes;
- misturar o estudo experimental com produtos externos;
- transformar uma hipótese em conclusão;
- adicionar dependência sem justificativa;
- reduzir a rastreabilidade.

---

## 19. Critérios de aceitação

Uma contribuição pode ser aceita quando:

- está alinhada ao propósito do repositório;
- preserva a segurança;
- utiliza dados adequados;
- mantém a coerência técnica;
- apresenta documentação suficiente;
- não compromete as evidências existentes;
- não introduz dependência desnecessária;
- pode ser revisada de forma objetiva;
- possui escopo identificável;
- mantém o repositório reproduzível.

---

## 20. Correções após revisão

Quando uma contribuição exigir correção:

1. preserve o histórico da discussão;
2. altere somente os arquivos relacionados;
3. não remova evidências sem justificativa;
4. responda aos pontos da revisão;
5. execute novamente as validações afetadas;
6. atualize a descrição da contribuição;
7. confirme a ausência de dados sensíveis.

---

## 21. Resultado esperado

Uma contribuição concluída deve:

- resolver um problema identificado;
- manter a documentação coerente;
- preservar a rastreabilidade;
- utilizar apenas exemplos seguros;
- permanecer compatível com a estrutura do repositório;
- apresentar evidências suficientes para revisão;
- não depender do ambiente operacional original.
