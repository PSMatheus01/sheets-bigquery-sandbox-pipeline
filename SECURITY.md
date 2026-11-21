# Política de segurança

## Objetivo

Esta política estabelece os critérios de segurança, privacidade e comunicação de vulnerabilidades relacionados a este repositório.

O projeto documenta uma prova de conceito com Google Sheets, Google Apps Script e BigQuery Sandbox. Todo conteúdo publicado deve ser genérico, sintético, anonimizado e independente de ambientes operacionais reais.

---

## Escopo

Esta política cobre:

- documentação;
- exemplos de Google Apps Script;
- consultas SQL;
- arquivos de configuração de exemplo;
- dados sintéticos;
- scripts auxiliares;
- workflows;
- dependências;
- diagramas;
- arquivos publicados no histórico Git.

Esta política não cobre:

- as plataformas Google Sheets, Apps Script, BigQuery ou Google Cloud;
- a plataforma GitHub;
- serviços de terceiros;
- ambientes privados;
- sistemas operacionais reais;
- produtos internos;
- implementações derivadas mantidas por terceiros.

Vulnerabilidades nas plataformas utilizadas devem ser comunicadas diretamente aos respectivos fornecedores.

---

## Versões suportadas

Somente o conteúdo mais recente da branch principal é considerado suportado.

| Versão | Suporte |
|---|---|
| `main` | Sim |
| Commits anteriores | Não |
| Forks de terceiros | Não |
| Implementações derivadas | Não |

---

## Comunicação de vulnerabilidades

Utilize a opção **Report a vulnerability**, disponível na aba **Security** do repositório.

Não abra uma issue pública para comunicar:

- credenciais expostas;
- tokens;
- chaves;
- dados pessoais;
- identificadores de ambientes;
- URLs privadas;
- vulnerabilidades exploráveis;
- acesso indevido;
- exposição de informações;
- falhas que possam comprometer usuários ou sistemas.

Não inclua informações sensíveis em:

- issues;
- pull requests;
- discussions;
- comentários;
- commits;
- nomes de branches;
- arquivos anexados publicamente.

---

## Informações do relatório

Um relatório de segurança deve conter, quando aplicável:

- descrição do problema;
- arquivo ou componente afetado;
- impacto esperado;
- forma de reprodução;
- condições necessárias;
- versão ou commit afetado;
- evidências não sensíveis;
- sugestão de correção;
- indicação de possível exposição de dados.

Não envie:

- dados reais;
- credenciais ativas;
- informações pessoais;
- dumps;
- backups;
- logs completos;
- arquivos obtidos sem autorização;
- dados pertencentes a terceiros.

---

## Conteúdo proibido

Não devem ser adicionados ao repositório:

- senhas;
- tokens;
- chaves de API;
- chaves privadas;
- arquivos `.env` reais;
- credenciais do Google Cloud;
- arquivos de contas de serviço;
- IDs reais de planilhas;
- IDs de projetos privados;
- nomes de datasets operacionais;
- identificadores de implantação;
- identificadores de gatilhos;
- propriedades de script;
- URLs internas;
- e-mails;
- CNPJs;
- nomes de pessoas;
- dados de produção;
- logs brutos;
- dumps de banco;
- backups;
- código pertencente a produtos internos;
- informações protegidas por contrato ou confidencialidade.

Configurações de exemplo devem utilizar valores claramente fictícios, como:

```text
your-project-id
your-dataset
your-spreadsheet-id
example@example.invalid
```

---

## Dados permitidos

Os exemplos devem utilizar exclusivamente:

- dados sintéticos;
- nomes fictícios;
- identificadores fictícios;
- métricas arredondadas;
- configurações genéricas;
- estruturas independentes;
- resultados produzidos para demonstração.

Nenhum exemplo deve permitir a reconstrução ou identificação de uma operação real.

---

## Tratamento de métricas

Métricas derivadas de experimentos devem ser:

- agregadas;
- anonimizadas;
- arredondadas quando necessário;
- apresentadas sem identificadores;
- desvinculadas de pessoas;
- desvinculadas de clientes;
- desvinculadas de URLs e ambientes reais.

Não devem ser publicados:

- timestamps correlacionáveis com incidentes reais;
- nomes internos de ciclos;
- identificadores de execução;
- IDs de jobs;
- IDs de planilhas;
- IDs de gatilhos;
- hashes operacionais;
- referências capazes de identificar a origem.

---

## Responsabilidade de adaptação

Os exemplos deste repositório não constituem uma solução pronta para produção.

Quem adaptar o conteúdo é responsável por avaliar:

- autenticação;
- autorização;
- gestão de segredos;
- criptografia;
- retenção;
- privacidade;
- LGPD;
- logs;
- auditoria;
- backup;
- recuperação;
- disponibilidade;
- limites de consumo;
- faturamento;
- permissões do Google Cloud;
- permissões das planilhas;
- risco de injeção de fórmulas;
- tratamento de dados pessoais;
- requisitos contratuais;
- requisitos regulatórios.

A utilização em ambiente produtivo exige revisão técnica, jurídica e de segurança independente.

---

## Práticas de desenvolvimento seguro

Alterações no repositório devem observar:

- princípio do menor privilégio;
- separação entre configuração e código;
- ausência de credenciais no código-fonte;
- validação de entrada;
- sanitização antes da publicação em planilhas;
- consultas parametrizadas quando aplicável;
- controle de limites de execução;
- controle de bytes processados;
- logs sem dados sensíveis;
- operações idempotentes;
- estados recuperáveis;
- revisão por Pull Request;
- testes antes do merge;
- documentação de alterações relevantes.

---

## Segurança no Google Apps Script

Exemplos de Apps Script devem:

- solicitar apenas permissões necessárias;
- evitar acesso desnecessário a arquivos;
- separar configuração e lógica;
- não armazenar segredos diretamente no código;
- não registrar conteúdo sensível;
- validar o ID e a identidade dos recursos acessados;
- utilizar locks em operações concorrentes;
- impedir retomadas automáticas após falhas preservadas;
- remover gatilhos temporários com segurança;
- registrar resultados sem expor dados operacionais.

---

## Segurança no BigQuery

Exemplos de BigQuery devem:

- utilizar datasets de demonstração;
- evitar dados pessoais;
- limitar bytes processados;
- utilizar localização consistente;
- validar tabelas e views antes da promoção;
- separar estruturas candidatas e oficiais;
- aplicar expiração compatível com o sandbox;
- impedir substituição sem validação;
- registrar jobs sem publicar identificadores reais;
- evitar permissões administrativas desnecessárias.

---

## Segurança na publicação em planilhas

Valores publicados em planilhas devem ser tratados contra interpretação indevida como fórmulas.

Entradas iniciadas por caracteres como:

```text
=
+
-
@
```

devem ser avaliadas e sanitizadas conforme o contexto.

A sanitização deve preservar o conteúdo esperado sem permitir a execução de fórmulas introduzidas por dados externos.

---

## Dependências

Dependências adicionadas ao projeto devem:

- possuir origem verificável;
- utilizar versões identificáveis;
- ter finalidade documentada;
- ser avaliadas quanto a vulnerabilidades conhecidas;
- evitar permissões desnecessárias;
- ser removidas quando não utilizadas.

Dependências não devem ser adicionadas apenas por conveniência quando a mesma necessidade puder ser atendida com recursos nativos de maneira segura e simples.

---

## Incidente de exposição

Se um conteúdo sensível for enviado ao repositório:

1. interrompa novas alterações;
2. restrinja imediatamente o acesso ao repositório;
3. identifique o conteúdo exposto;
4. revogue ou substitua as credenciais afetadas;
5. preserve as evidências necessárias;
6. remova o conteúdo do histórico Git;
7. revise branches, tags, releases e artefatos;
8. verifique logs e acessos;
9. documente o incidente;
10. confirme que os controles preventivos foram corrigidos.

> Excluir apenas o arquivo no commit mais recente não garante sua remoção do histórico.

---

## Divulgação responsável

Problemas de segurança não devem ser divulgados publicamente antes de:

- confirmação;
- avaliação de impacto;
- proteção das informações afetadas;
- preparação da correção;
- conclusão da orientação oficial.

Detalhes técnicos capazes de facilitar exploração devem permanecer restritos durante o tratamento do incidente.

---

## Testes de segurança

Não é permitido utilizar este repositório como justificativa para:

- acessar sistemas sem autorização;
- testar credenciais de terceiros;
- consultar dados reais;
- explorar ambientes;
- executar varreduras não autorizadas;
- interferir em serviços;
- coletar informações protegidas.

Testes devem ocorrer somente em:

- ambientes próprios;
- dados sintéticos;
- projetos autorizados;
- recursos criados especificamente para demonstração.

---

## Limitações

Este repositório possui finalidade educacional e experimental.

Seu conteúdo não oferece garantia de:

- ausência de vulnerabilidades;
- adequação a qualquer ambiente;
- conformidade legal automática;
- disponibilidade;
- suporte comercial;
- desempenho específico;
- compatibilidade com qualquer volume;
- segurança sem configuração adicional.

---

## Reconhecimento

Relatos responsáveis podem ser reconhecidos publicamente mediante autorização da pessoa responsável e desde que o reconhecimento não exponha informações sensíveis.

Não existe programa de recompensa financeira associado a este repositório.
