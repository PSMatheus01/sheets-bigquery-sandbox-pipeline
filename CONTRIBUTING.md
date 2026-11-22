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

### Exemplo de link relativo

```text
[Resultados experimentais](docs/results.md)

```
### Exemplo de referência a código
```text
src/sql/03_rules_example.sql


