<div align="center">

# Google Sheets to BigQuery Sandbox Pipeline

### Externalização do processamento de planilhas por meio de um pipeline auditável com Google Apps Script e BigQuery Sandbox

**Estudo técnico • Prova de conceito • Padrões reutilizáveis**

<br>

![Type](https://img.shields.io/badge/type-technical%20study-blue)
![BigQuery](https://img.shields.io/badge/BigQuery-Sandbox-4285F4)
![Apps Script](https://img.shields.io/badge/Google-Apps%20Script-34A853)
![Data](https://img.shields.io/badge/data-synthetic%20and%20anonymized-success)
![License](https://img.shields.io/badge/license-under%20review-lightgrey)

</div>

---

## Visão geral

Este repositório documenta um estudo técnico sobre a modernização de processos baseados em planilhas.

A investigação partiu de uma estrutura com milhares de fórmulas, buscas, regras condicionais e tratamentos distribuídos por dezenas de milhares de linhas.

A pergunta central foi:

> **Até onde é possível retirar cálculos e regras de uma planilha, processá-los externamente e construir um pipeline recorrente, auditável e recuperável utilizando Google Apps Script e BigQuery Sandbox?**

A prova de conceito utilizou:

- **Google Sheets** como origem somente para leitura;
- **Google Apps Script** como camada de detecção e orquestração;
- **BigQuery Sandbox** como mecanismo de processamento;
- uma planilha isolada como ambiente de validação;
- **Cloud Logging** como fonte de observabilidade;
- estados persistidos, assinaturas e auditorias como mecanismos de controle.

> [!IMPORTANT]
> Este é um estudo técnico independente. O repositório não contém dados reais, credenciais, identificadores operacionais, configurações privadas ou código de produtos internos.

---

## Navegação

- [Contexto](#contexto)
- [Hipótese avaliada](#hipótese-avaliada)
- [Arquitetura experimental](#arquitetura-experimental)
- [Fluxo operacional](#fluxo-operacional)
- [Metodologia](#metodologia)
- [Resultados](#resultados)
- [Performance](#performance)
- [Consumo do BigQuery](#consumo-do-bigquery)
- [Publicação controlada](#publicação-controlada)
- [Incidentes e aprendizados](#incidentes-e-aprendizados)
- [BigQuery Sandbox](#bigquery-sandbox)
- [Cenário com faturamento](#cenário-com-faturamento)
- [Casos de uso](#casos-de-uso)
- [Quando não utilizar](#quando-não-utilizar)
- [Segurança e privacidade](#segurança-e-privacidade)
- [Conclusões](#conclusões)
- [Referências](#referências)
- [Licença](#licença)

---

# Contexto

Planilhas são excelentes ferramentas para:

- exploração;
- prototipação;
- análises rápidas;
- validação de hipóteses;
- construção inicial de processos;
- colaboração;
- experimentação.

Entretanto, quando uma planilha passa a concentrar simultaneamente dados, regras, fórmulas, indicadores e experiência operacional, sua manutenção pode se tornar progressivamente mais complexa.

Entre os sinais observados no estudo estavam:

- fórmulas copiadas por milhares de linhas;
- buscas massivas;
- regras condicionais aninhadas;
- diferentes padrões de fórmula na mesma coluna;
- células apresentando erros;
- latência variável;
- dificuldade de versionar regras;
- risco de alteração manual da estrutura;
- dependência de conhecimento especializado.

## Baseline estrutural anonimizada

O inventário utilizado como referência encontrou aproximadamente:

| Métrica | Resultado observado |
|---|---:|
| Linhas | 75,6 mil |
| Colunas | 35 |
| Células consideradas | 2,65 milhões |
| Fórmulas | 146,7 mil |
| Densidade de fórmulas | 5,54% |
| Colunas com fórmulas | 5 |
| Células apresentando erros | 18 |
| Colunas com padrões misturados | 1 |

## Funções identificadas

| Função | Ocorrências aproximadas |
|---|---:|
| `IF` | 173,2 mil |
| `SUBSTITUTE` | 151,2 mil |
| `VALUE` | 75,6 mil |
| `XLOOKUP` | 64,5 mil |
| `COUNTIFS` | 5,1 mil |
| `IMPORTRANGE` | 1 |

> [!NOTE]
> Uma fórmula pode conter várias funções. Por isso, a soma das ocorrências é superior ao total de fórmulas.

---

# Hipótese avaliada

A hipótese principal foi:

> **É possível manter a planilha de origem somente para leitura, executar limpeza, transformação, regras e agregações no BigQuery e publicar apenas resultados previamente validados?**

O estudo também buscou compreender:

1. se o fluxo poderia operar de forma recorrente;
2. se mudanças poderiam ser detectadas sem consultar todas as células;
3. se falhas parciais poderiam bloquear o avanço;
4. se publicações poderiam ser auditadas;
5. se incidentes poderiam ser recuperados sem duplicação;
6. qual seria o consumo do BigQuery;
7. quais seriam os limites do sandbox sem faturamento;
8. quais padrões poderiam ser adaptados para outros contextos.

---

# Arquitetura experimental

O experimento separou origem, processamento, validação e publicação.

```text
┌─────────────────────────────────────────┐
│ Google Sheets                           │
│ Origem mantida somente para leitura     │
└───────────────────┬─────────────────────┘
                    │
                    │ Detecção de mudanças
                    ▼
┌─────────────────────────────────────────┐
│ Google Apps Script                      │
│ Orquestração, estados e controle        │
└───────────────────┬─────────────────────┘
                    │
                    │ Captura validada
                    ▼
┌─────────────────────────────────────────┐
│ BigQuery Sandbox                        │
│ Tabelas candidatas                      │
│ Limpeza, regras e agregações            │
└───────────────────┬─────────────────────┘
                    │
                    │ Contagens e assinaturas
                    ▼
┌─────────────────────────────────────────┐
│ Validação e promoção                    │
│ Candidata → estrutura oficial           │
└───────────────────┬─────────────────────┘
                    │
                    │ Publicação aprovada
                    ▼
┌─────────────────────────────────────────┐
│ Planilha de validação isolada           │
│ Valores estáticos e sem fórmulas        │
└───────────────────┬─────────────────────┘
                    │
                    │ Auditoria
                    ▼
┌─────────────────────────────────────────┐
│ Ciclo concluído                         │
│ Integridade e resíduos verificados      │
└─────────────────────────────────────────┘
```

## Princípios adotados

- origem somente para leitura;
- separação entre estruturas candidatas e oficiais;
- nenhuma publicação sem validação;
- backups antes de promoções;
- estados persistidos;
- operações idempotentes;
- assinaturas de conteúdo;
- bloqueio diante de inconsistência;
- auditoria posterior;
- encerramento automático de gatilhos;
- ausência de fórmulas nas saídas técnicas.

---

# Fluxo operacional

O ciclo foi dividido em etapas independentes.

```text
┌──────────────────────────────┐
│ 1. Detecção de mudança       │
└──────────────┬───────────────┘
               ▼
┌──────────────────────────────┐
│ 2. Captura do snapshot       │
└──────────────┬───────────────┘
               ▼
┌──────────────────────────────┐
│ 3. Validação da candidata    │
└──────────────┬───────────────┘
               ▼
┌──────────────────────────────┐
│ 4. Criação das views         │
└──────────────┬───────────────┘
               ▼
┌──────────────────────────────┐
│ 5. Validação das views       │
└──────────────┬───────────────┘
               ▼
┌──────────────────────────────┐
│ 6. Backup das estruturas     │
└──────────────┬───────────────┘
               ▼
┌──────────────────────────────┐
│ 7. Promoção nativa           │
└──────────────┬───────────────┘
               ▼
┌──────────────────────────────┐
│ 8. Validação pós-promoção    │
└──────────────┬───────────────┘
               ▼
┌──────────────────────────────┐
│ 9. Decisão de publicação     │
└──────────────┬───────────────┘
               ▼
┌──────────────────────────────┐
│ 10. Publicação isolada       │
└──────────────┬───────────────┘
               ▼
┌──────────────────────────────┐
│ 11. Validação da publicação  │
└──────────────┬───────────────┘
               ▼
┌──────────────────────────────┐
│ 12. Finalização do ciclo     │
└──────────────────────────────┘
```

Uma etapa somente avançava quando a etapa anterior estava aprovada.

Em caso de inconsistência:

```text
Falha detectada
      │
      ▼
Estado preservado
      │
      ▼
Diagnóstico
      │
      ├── Correção controlada
      │
      ├── Recuperação por metadados
      │
      └── Rollback, quando aplicável
      │
      ▼
Nova validação
```

---

# Metodologia

O estudo foi composto por duas avaliações complementares.

## 1. Janela operacional automatizada

Duração:

```text
48 horas
```

Objetivos:

- observar recorrência;
- executar ciclos automáticos;
- medir performance;
- medir consumo;
- validar auditoria;
- testar encerramento automático;
- observar falhas e recuperações.

## 2. Baseline da planilha com fórmulas

Duração:

```text
24 horas
```

Configuração:

- amostras a cada 15 minutos;
- 96 amostras esperadas;
- 96 amostras realizadas;
- cobertura de 100%;
- zero falhas.

Objetivos:

- inventariar fórmulas;
- identificar funções;
- contar erros;
- observar variação estrutural;
- medir latência de leitura;
- construir uma referência empírica.

> [!NOTE]
> Parte da baseline ocorreu fora do expediente. Os resultados devem ser interpretados como uma amostra exploratória de curto período, e não como uma medição definitiva de todos os picos operacionais.

---

# Resultados

## Capacidades validadas

| Capacidade | Resultado |
|---|---|
| Detecção de mudanças | Validada |
| Captura da origem | Validada |
| Validação de esquema | Validada |
| Criação de tabelas candidatas | Validada |
| Criação de views | Validada |
| Aplicação de regras | Validada |
| Backup antes da promoção | Validado |
| Promoção controlada | Validada |
| Publicação sem fórmulas | Validada |
| Sanitização de textos | Validada |
| Assinaturas de conteúdo | Validadas |
| Auditoria automática | Validada |
| Bloqueio de inconsistências | Validado |
| Recuperação de incidente | Validada |
| Remoção de resíduos | Validada |
| Encerramento automático | Validado |
| Produção somente para leitura | Preservada |

## Janela automatizada

O consolidado final registrou:

- 48 horas de avaliação;
- dez ciclos operacionais;
- dez ciclos associados a mudanças;
- encerramento automático;
- remoção segura do gatilho;
- ausência de concessões residuais;
- ausência de leases residuais;
- estado final concluído e saudável.

## Auditoria

A auditoria verificou:

- estruturas publicadas;
- assinaturas;
- contagens;
- abas técnicas;
- fórmulas;
- resíduos;
- preservação das abas de negócio;
- ausência de alteração na produção.

Resultado:

```text
INTEGRIDADE APROVADA
```

---

# Performance

O consolidado reuniu 30 amostras de etapas persistidas.

| Métrica | Resultado aproximado |
|---|---:|
| Média | 12,72 s |
| Mediana | 2,27 s |
| 95% das amostras | Até 62,32 s |
| Mínimo | 0,30 s |
| Máximo | 92,08 s |
| Abaixo da meta interna de 25 s | 86,67% |

## Interpretação

A mediana inferior à média demonstra que a maioria das etapas foi rápida, enquanto algumas operações mais pesadas elevaram a média.

As etapas mais demoradas estavam associadas a:

- publicação de grande quantidade de células;
- captura de snapshot;
- promoção de estruturas;
- validação pós-promoção.

O principal gargalo observado foi a gravação de resultados no Google Sheets, e não o processamento analítico no BigQuery.

## Baseline de leitura da planilha

### Abertura

| Métrica | Resultado |
|---|---:|
| Média | 6,10 s |
| 95% das amostras | Até 10,98 s |
| Máximo | 13,89 s |

### Leitura de regiões amostradas

| Métrica | Resultado |
|---|---:|
| Média | 3,12 s |
| 95% das amostras | Até 5,59 s |
| Máximo | 9,43 s |

> [!NOTE]
> O Apps Script não expõe o tempo integral de recálculo interno do Google Sheets. Esses valores medem a interação de leitura, e não o recálculo completo das fórmulas.

---

# Consumo do BigQuery

## Ciclo recente

| Métrica | Resultado aproximado |
|---|---:|
| Jobs | 13 |
| Jobs com processamento | 9 |
| Dados processados | 84,7 MiB |
| Dados faturáveis | 173 MiB |
| Percentual de 1 TiB | 0,0165% |

## Projeções mensais

Mantido o consumo unitário observado:

| Frequência hipotética | Projeção aproximada |
|---|---:|
| 1 ciclo por dia | 5,1 GiB/mês |
| 12 ciclos por dia | 60,8 GiB/mês |
| 30 ciclos por dia | 152 GiB/mês |
| 96 ciclos por dia | 486,6 GiB/mês |

> [!WARNING]
> As projeções não representam consumo garantido. Volume, consultas, tabelas, regras e frequência podem alterar significativamente os resultados.

---

# Publicação controlada

Uma publicação recente processou aproximadamente:

| Métrica | Resultado |
|---|---:|
| Linhas publicadas | 9 mil |
| Células publicadas | 114,6 mil |
| Fórmulas publicadas | 0 |
| Textos sanitizados | 2,3 mil |
| Duração | 87,4 s |

Os textos foram sanitizados para evitar interpretação indevida como fórmulas pelo Google Sheets.

## Resultado central

Foi comprovado que era possível:

- executar o processamento fora da planilha;
- publicar valores estáticos;
- eliminar fórmulas das saídas técnicas;
- conferir contagens;
- validar assinaturas;
- identificar divergências;
- preservar versões anteriores.

---

# Incidentes e aprendizados

Os incidentes foram tratados como parte da validação da arquitetura.

## Consolidação incompleta de assinaturas

Uma publicação foi promovida, mas a consolidação das assinaturas falhou.

**Aprendizado:** operações parciais precisam ser retomáveis sem duplicar ou reexecutar desnecessariamente a publicação.

## Recurso temporário residual

Uma estrutura temporária de tentativa anterior permaneceu no destino.

**Aprendizado:** recursos temporários precisam de identificação, inventário e limpeza segura.

## Validação incompatível com janela temporal

Uma view temporal foi comparada como se devesse conter todas as linhas da origem.

**Aprendizado:** validações precisam considerar a semântica da regra, e não apenas igualdade numérica.

## Comparação de conteúdo dinâmico

Views baseadas em data corrente mudaram legitimamente com o tempo.

**Aprendizado:** estruturas dinâmicas não devem ser auditadas como snapshots imutáveis.

## Resultado dos incidentes

Os incidentes foram:

- detectados;
- preservados;
- investigados;
- corrigidos;
- documentados;
- revalidados.

O estado final permaneceu saudável e aprovado.

---

# BigQuery Sandbox

O BigQuery Sandbox permite testar recursos do BigQuery sem fornecer cartão de crédito ou vincular uma conta de faturamento.

No volume estudado, foi possível:

- criar tabelas;
- criar views;
- executar consultas;
- aplicar transformações;
- validar resultados;
- realizar auditorias;
- operar ciclos recorrentes;
- permanecer abaixo da cota mensal gratuita projetada.

## Limitações relevantes

Segundo a documentação oficial, o sandbox possui limitações como:

- limite de armazenamento;
- expiração automática de tabelas, views e partições;
- ausência de streaming;
- ausência de DML;
- indisponibilidade do BigQuery Data Transfer Service.

> [!IMPORTANT]
> O estudo demonstrou viabilidade no volume experimental. Isso não torna o sandbox automaticamente adequado para retenção permanente ou produção crítica.

---

# Cenário com faturamento

Habilitar faturamento amplia os recursos disponíveis:

- armazenamento adicional;
- retenção permanente;
- DML;
- streaming;
- cargas incrementais;
- serviços de transferência;
- maior capacidade de crescimento.

Entretanto, faturamento não resolve problemas inerentes ao uso da planilha como interface:

- edição humana;
- fórmulas divergentes;
- estrutura mutável;
- experiência genérica;
- regras distribuídas;
- dificuldade de versionamento;
- gargalos de leitura e escrita.

Uma operação com faturamento também exige:

- orçamento;
- alertas;
- limites de consulta;
- `maximumBytesBilled`;
- particionamento;
- clustering;
- revisão de permissões;
- monitoramento;
- governança;
- estratégia de retenção.

---

# Casos de uso

Os casos de uso foram classificados conforme o nível de evidência.

| Classificação | Significado |
|---|---|
| **Validado** | Implementado e observado no estudo |
| **Adaptável** | Reutiliza o mesmo padrão, mas não foi testado diretamente |
| **Revisão necessária** | Exige outra arquitetura, faturamento ou validação adicional |

## 1. Externalização de fórmulas

**Classificação:** Validado

Possibilidades:

- buscas;
- contagens condicionais;
- normalizações;
- classificações;
- filtros;
- regras;
- agregações.

## 2. Qualidade de dados

**Classificação:** Validado

Detecção de:

- datas inválidas;
- campos vazios;
- padrões incorretos;
- duplicidades;
- divergências;
- registros incompletos;
- valores fora de domínio.

## 3. Reconciliação entre bases

**Classificação:** Validado

Comparação entre:

- origem e destino;
- versão anterior e atual;
- total esperado e realizado;
- assinaturas;
- sistemas;
- períodos.

## 4. Detecção de exceções

**Classificação:** Validado

Geração de listas de:

- registros rejeitados;
- regras não atendidas;
- divergências;
- casos sem correspondência;
- itens que exigem intervenção.

## 5. Indicadores periódicos

**Classificação:** Validado

Cálculo de:

- volumes;
- taxas;
- status;
- produtividade;
- tendências;
- agrupamentos;
- resultados por período.

## 6. Publicação controlada

**Classificação:** Validado

Publicação condicionada a:

- esquema correto;
- contagens aprovadas;
- assinaturas válidas;
- sanitização;
- preservação da versão anterior.

## 7. Avaliação de migração

**Classificação:** Validado

Aplicável para:

- inventariar fórmulas;
- identificar erros;
- localizar gargalos;
- medir latência;
- avaliar complexidade;
- apoiar decisão de migração.

## 8. Consolidação de múltiplas planilhas

**Classificação:** Adaptável

Possíveis aplicações:

- consolidação por unidade;
- reunião de arquivos mensais;
- padronização de departamentos;
- centralização de resultados;
- uniformização de estruturas.

## 9. Conferência financeira

**Classificação:** Adaptável

Possíveis aplicações:

- conciliação;
- divergência de valores;
- validação de repasses;
- conferência entre períodos;
- detecção de lançamentos ausentes.

## 10. Estoque e movimentação

**Classificação:** Adaptável

Possíveis aplicações:

- comparação entre estoque esperado e realizado;
- identificação de divergências;
- consolidação entre unidades;
- detecção de movimentações atípicas.

## 11. Campanhas e produtividade

**Classificação:** Adaptável

Possíveis aplicações:

- consolidação de resultados;
- validação de metas;
- acompanhamento por equipe;
- preparação de indicadores;
- identificação de exceções.

## 12. Preparação de dados para dashboards

**Classificação:** Adaptável

Possibilidades:

- pré-calcular indicadores;
- materializar resultados;
- reduzir fórmulas;
- validar dados antes da visualização.

## 13. Processamento em tempo real

**Classificação:** Revisão necessária

O pipeline validado é orientado a lotes e gatilhos periódicos.

Ele não deve ser apresentado como solução pronta para:

- banco transacional;
- gravações concorrentes;
- resposta em tempo real;
- eventos contínuos;
- aplicações críticas de baixa latência.

---

# Quando não utilizar

Esta abordagem não deve ser adotada sem revisão para:

- aplicações transacionais;
- operações em tempo real;
- edição simultânea de registros;
- sistemas com baixa tolerância a atraso;
- retenção permanente no sandbox;
- grandes volumes sem estimativa de custo;
- dados sensíveis sem governança;
- processos críticos sem monitoramento;
- cenários que dependam exclusivamente das cotas gratuitas.

Nesses casos, devem ser avaliados:

- banco transacional;
- backend dedicado;
- filas;
- APIs;
- armazenamento permanente;
- faturamento;
- monitoramento;
- segurança;
- recuperação.

---

# Segurança e privacidade

O conteúdo público deve utilizar exclusivamente:

- dados sintéticos;
- nomes genéricos;
- configurações fictícias;
- métricas arredondadas;
- diagramas abstratos;
- exemplos reescritos.

## Conteúdo proibido

Não devem ser publicados:

- dados reais;
- nomes de pessoas;
- CNPJs;
- e-mails;
- IDs de planilhas;
- IDs de projetos;
- datasets reais;
- tokens;
- chaves;
- credenciais;
- URLs privadas;
- logs brutos;
- propriedades de script;
- identificadores de gatilhos;
- backups;
- dumps;
- código de produtos internos.

> [!CAUTION]
> Dados sensíveis nunca devem ser enviados ao Git com a intenção de removê-los depois. O histórico pode preservar o conteúdo mesmo após a exclusão do arquivo.

---

# Conclusões

O estudo demonstrou que:

1. o processamento pode ser retirado das fórmulas;
2. a planilha de origem pode permanecer somente para leitura;
3. o BigQuery pode executar limpeza, regras e agregações;
4. Apps Script pode coordenar um pipeline por estados;
5. publicações podem ser condicionadas a validações;
6. resultados podem ser auditados;
7. incidentes podem ser recuperados;
8. recursos temporários podem ser identificados e removidos;
9. saídas podem ser publicadas sem fórmulas;
10. o sandbox foi suficiente para o volume experimental.

Também demonstrou que:

- o Google Sheets continuou sendo o principal gargalo de publicação;
- o sandbox possui limitações de retenção e recursos;
- faturamento amplia o BigQuery, mas não corrige problemas da interface baseada em planilha;
- estruturas dinâmicas exigem auditorias semanticamente corretas;
- produção crítica exige análise arquitetural adicional.

## Síntese

> **O principal resultado não foi apenas processar dados no BigQuery. Foi comprovar que regras, validações, auditoria e recuperação podem ser desacopladas das fórmulas e organizadas como um pipeline controlado.**

---

# Referências

- [BigQuery Sandbox — documentação oficial](https://docs.cloud.google.com/bigquery/docs/sandbox)
- [BigQuery Pricing — documentação oficial](https://cloud.google.com/bigquery/pricing)
- [BigQuery Quotas and Limits](https://docs.cloud.google.com/bigquery/quotas)
- [Apps Script Quotas](https://developers.google.com/apps-script/guides/services/quotas)
- [Apps Script Logging](https://developers.google.com/apps-script/guides/logging)
- [GitHub — Licensing a repository](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/licensing-a-repository)

---

# Licença

A licença deste repositório ainda está em avaliação.

Enquanto não houver uma licença explícita:

- o repositório não deve ser considerado open source;
- não existe autorização automática para copiar, modificar ou distribuir seu conteúdo;
- contribuições externas não estão abertas.

A licença deverá ser definida antes da publicação definitiva.

---

<div align="center">

### Estudo de engenharia, governança e modernização de processos baseados em planilhas

**Dados sintéticos • Métricas anonimizadas • Nenhuma credencial**

</div>
