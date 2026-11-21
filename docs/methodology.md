# Metodologia

## Visão geral

Este documento descreve a metodologia utilizada para avaliar:

1. a viabilidade de externalizar o processamento de uma planilha;
2. o comportamento de um pipeline automatizado no ecossistema Google;
3. o consumo do BigQuery Sandbox;
4. a recorrência e a recuperação do fluxo;
5. a dimensão estrutural da planilha baseada em fórmulas;
6. os limites das evidências coletadas.

O estudo foi dividido em duas avaliações complementares:

| Avaliação | Duração | Finalidade |
|---|---:|---|
| Pipeline automatizado | 48 horas | Recorrência, processamento, publicação, auditoria e recuperação |
| Baseline de fórmulas | 24 horas | Inventário estrutural, erros, atividade e latência de leitura |

As avaliações utilizaram a origem exclusivamente para leitura.

---

# 1. Perguntas de pesquisa

O estudo buscou responder às seguintes perguntas.

## Processamento

- É possível retirar buscas, regras e agregações das fórmulas?
- O BigQuery Sandbox suporta o volume experimental?
- O Apps Script consegue coordenar as etapas?
- Os resultados podem ser publicados sem fórmulas?

## Segurança operacional

- A origem pode permanecer somente para leitura?
- Uma etapa inconsistente pode ser bloqueada?
- Uma publicação pode ser validada antes de substituir a anterior?
- O fluxo pode se recuperar de uma falha parcial?
- Recursos temporários podem ser removidos com segurança?

## Performance

- Quais etapas concentram maior duração?
- O processamento analítico ou a publicação no Sheets é o principal gargalo?
- Qual é a variação entre execuções?
- Quanto do orçamento diário do Apps Script é consumido?

## Consumo

- Quantos jobs são executados?
- Quantos bytes são processados?
- Quantos bytes são considerados faturáveis?
- Qual seria o consumo mensal em diferentes frequências?

## Planilha baseada em fórmulas

- Quantas fórmulas existem?
- Em quais colunas estão concentradas?
- Quais funções são utilizadas?
- Existem erros visíveis?
- Existem padrões diferentes na mesma coluna?
- Qual é a latência de abertura e leitura?

---

# 2. Escopo

## Incluído

O estudo incluiu:

- leitura da origem;
- detecção de mudanças;
- captura;
- validação;
- criação de tabelas;
- criação de views;
- aplicação de regras;
- promoção;
- publicação isolada;
- sanitização;
- auditoria;
- recuperação;
- medição de consumo;
- inventário de fórmulas;
- medição de latência.

## Não incluído

O estudo não avaliou:

- banco transacional;
- processamento em tempo real;
- experiência de usuários finais;
- concorrência de centenas de usuários;
- infraestrutura produtiva;
- disponibilidade contratual;
- recuperação de desastre;
- conformidade jurídica completa;
- custo de uma solução definitiva;
- desempenho fora do volume observado.

---

# 3. Ambientes

A arquitetura utilizou três ambientes lógicos.

## Origem

Planilha utilizada como fonte de dados.

Controles:

- acesso somente para leitura;
- nenhuma publicação;
- nenhum gatilho instalado;
- nenhuma alteração de células;
- nenhuma alteração de fórmulas;
- nenhuma mudança de formatação.

## Processamento

Projeto no BigQuery Sandbox.

Responsabilidades:

- armazenar estruturas temporárias;
- executar consultas;
- aplicar regras;
- gerar resultados;
- calcular assinaturas;
- fornecer métricas de jobs.

## Destino isolado

Planilha shadow separada da origem.

Responsabilidades:

- receber resultados;
- permitir validação;
- preservar abas de negócio;
- permitir auditoria;
- evitar impacto na produção.

---

# 4. Identidade e configuração

Antes de cada etapa relevante, o fluxo verificou:

- projeto;
- dataset;
- região;
- versão;
- hash de configuração;
- experimento;
- ciclo operacional;
- identidade dos recursos;
- modo sandbox;
- permissões de escrita;
- estado atual.

Resultados incompatíveis com a configuração ativa não eram aceitos como evidência para o ciclo atual.

---

# 5. Avaliação do pipeline automatizado

## 5.1 Duração

A janela principal teve duração planejada de 48 horas.

O encerramento ocorreu na primeira execução automática posterior ao prazo.

A diferença entre o término planejado e o efetivo foi de poucos minutos, comportamento esperado para um gatilho periódico.

## 5.2 Recorrência

O executor foi acionado por gatilho temporal.

Periodicidade:

```text
Aproximadamente 15 minutos
```

Cada chamada executava no máximo uma etapa operacional.

Esse modelo reduziu o risco de ultrapassar o limite individual de duração do Apps Script.

## 5.3 Detecção de mudanças

A detecção utilizou metadados da origem.

Foram comparados:

- horário de modificação;
- referência resumida;
- estado anteriormente aprovado.

A planilha completa não precisava ser aberta durante cada verificação inicial.

## 5.4 Confirmação de mudança

Uma alteração não iniciava imediatamente um novo ciclo.

Ela precisava permanecer observável durante:

- oito intervalos;
- aproximadamente 120 minutos.

```text
Mudança inicial
      │
      ▼
Pendência registrada
      │
      ▼
Confirmações periódicas
      │
      ▼
Limiar de oito intervalos
      │
      ▼
Novo ciclo autorizado
```

O objetivo foi evitar processar uma alteração transitória ou ainda incompleta.

## 5.5 Execução por estados

O ciclo avançava por estados persistidos.

Uma etapa somente era executada quando:

- o estado anterior era compatível;
- o resultado anterior estava aprovado;
- não havia lease concorrente;
- o lock havia sido obtido;
- a janela estava válida;
- o orçamento permitia execução.

## 5.6 Orçamento diário

Foi utilizado um orçamento interno de runtime inferior à cota diária disponível.

O controle considerou:

- runtime já consumido;
- limite interno diário;
- reserva preventiva;
- auditorias pendentes;
- duração estimada da etapa.

Esse mecanismo evitou utilizar toda a cota disponível antes de uma auditoria ou encerramento.

---

# 6. Etapas do ciclo

O ciclo foi composto por 12 etapas.

| Etapa | Objetivo |
|---:|---|
| 1 | Detectar mudança |
| 2 | Capturar snapshot |
| 3 | Validar candidata |
| 4 | Criar views candidatas |
| 5 | Validar views candidatas |
| 6 | Criar backup |
| 7 | Promover estruturas |
| 8 | Validar pós-promoção |
| 9 | Decidir publicação |
| 10 | Publicar na shadow |
| 11 | Validar publicação |
| 12 | Finalizar ciclo |

Cada etapa produzia um resultado estruturado com:

- sucesso;
- status;
- parecer;
- bloqueios;
- ressalvas;
- informações;
- métricas;
- verificações;
- duração;
- horário.

---

# 7. Captura consistente

A captura utilizou uma referência da origem antes da criação das estruturas candidatas.

Depois da criação, a origem era verificada novamente.

Critério:

```text
Referência antes da captura = referência depois da captura
```

Se a origem mudasse durante a operação:

- a geração era bloqueada;
- a candidata não era promovida;
- o estado era preservado;
- uma nova tentativa era necessária.

---

# 8. Validação de dados

As validações foram divididas por camada.

## Candidatas

- existência;
- tipo;
- esquema;
- número de campos;
- contagem;
- labels;
- expiração;
- dependências.

## Views

- definição;
- dependências;
- contagens;
- assinaturas;
- comparação com estruturas candidatas;
- compatibilidade das regras.

## Pós-promoção

- estruturas oficiais;
- backups;
- contagens;
- assinaturas;
- paridade com as candidatas;
- decomposição dos registros.

## Publicação

- nome das abas;
- identificador interno;
- cabeçalhos;
- linhas;
- colunas;
- filtros;
- congelamento;
- visibilidade;
- ausência de fórmulas;
- ausência de resíduos.

---

# 9. Assinaturas operacionais

Cada saída utilizou três componentes principais:

```text
total de registros
assinatura XOR
assinatura de soma
```

As assinaturas permitiram:

- comparar candidata e oficial;
- comparar geração e publicação;
- identificar saídas alteradas;
- detectar divergência;
- validar recuperação.

As assinaturas não foram tratadas como mecanismo criptográfico.

Seu objetivo foi fornecer uma comparação operacional compacta.

---

# 10. Decisão seletiva de publicação

A etapa de decisão comparava a geração atual com a publicação anteriormente aprovada.

Para cada saída, eram avaliados:

- total de registros;
- XOR;
- soma;
- existência;
- completude.

Somente as saídas alteradas eram selecionadas.

Esse mecanismo evitou reescrever dados sem mudança.

---

# 11. Publicação

A publicação utilizou uma estratégia de abas temporárias.

Procedimento:

1. criar aba temporária;
2. escrever valores;
3. aplicar cabeçalhos;
4. aplicar filtros;
5. congelar cabeçalho;
6. validar contagem;
7. validar ausência de fórmulas;
8. promover a nova aba;
9. validar o conjunto publicado;
10. remover a versão anterior.

A versão anterior somente era removida após a aprovação completa da nova publicação.

---

# 12. Sanitização

Os valores textuais foram avaliados antes da publicação.

Caracteres tratados incluíram:

```text
=
+
-
@
```

O objetivo foi reduzir o risco de interpretação de dados externos como fórmulas.

As métricas registraram:

- valores sanitizados;
- valores truncados;
- células publicadas;
- fórmulas publicadas.

---

# 13. Auditoria de integridade

A auditoria verificou:

- planilha de destino;
- abas esperadas;
- ausência de abas inesperadas;
- ausência de resíduos;
- cabeçalhos;
- dimensões;
- filtros;
- congelamento;
- visibilidade;
- ausência de fórmulas;
- assinaturas;
- abas de negócio;
- produção somente para leitura.

A auditoria foi executada de forma independente da publicação.

---

# 14. Encerramento

A janela possuía um gatilho identificado.

No encerramento:

1. o prazo era verificado;
2. o gatilho exato era localizado;
3. apenas esse gatilho era removido;
4. a janela era marcada como encerrada;
5. o estado operacional era preservado;
6. o resultado era registrado.

Critérios de aprovação:

- exatamente um gatilho identificado;
- exatamente um gatilho removido;
- nenhum gatilho residual;
- nenhuma alteração na produção;
- nenhum reinício de ciclo durante o encerramento.

---

# 15. Métricas de performance

Foram coletadas durações por etapa.

As estatísticas utilizadas foram:

- quantidade de amostras;
- média;
- mediana;
- mínimo;
- máximo;
- percentil 95;
- quantidade abaixo da meta interna.

## Média

Soma das durações dividida pela quantidade de amostras.

## Mediana

Valor central das durações ordenadas.

A mediana reduz a influência de poucos casos extremos.

## Percentil 95

Valor abaixo do qual ficaram aproximadamente 95% das amostras.

Exemplo:

```text
P95 = 62 segundos
```

Interpretação:

```text
Aproximadamente 95% das amostras levaram até 62 segundos.
```

## Máximo

Maior duração observada.

O máximo ajuda a identificar o pior caso da amostra, mas não representa o comportamento típico.

---

# 16. Métricas do BigQuery

As métricas coletadas incluíram:

- quantidade de jobs;
- jobs com processamento;
- bytes processados;
- bytes faturáveis;
- cache;
- duração do job;
- duração total da etapa.

## Bytes processados

Volume lógico lido pelas consultas.

## Bytes faturáveis

Volume considerado para cobrança ou consumo da cota, incluindo mínimos aplicáveis.

## Cuidados de consolidação

Métricas repetidas em resultados diferentes não foram somadas automaticamente.

Esse cuidado evitou dupla contagem de:

- jobs;
- bytes;
- publicações;
- etapas persistidas em mais de uma chave.

---

# 17. Projeções

As projeções mensais utilizaram:

```text
consumo faturável por ciclo
×
ciclos por dia
×
30 dias
```

Foram avaliados cenários hipotéticos de frequência.

As projeções não representam garantia, pois o consumo pode variar com:

- quantidade de linhas;
- número de tabelas;
- regras;
- consultas;
- frequência;
- retenção;
- mudanças de esquema.

---

# 18. Avaliação da planilha com fórmulas

## 18.1 Duração

A baseline teve duração de 24 horas.

## 18.2 Periodicidade

```text
15 minutos
```

## 18.3 Cobertura

- 96 amostras esperadas;
- 96 amostras realizadas;
- cobertura de 100%;
- zero falhas.

## 18.4 Inventário completo

O inventário percorreu a área utilizada em blocos de linhas.

Para cada bloco foram lidos:

- fórmulas;
- valores exibidos.

Não foram persistidos:

- conteúdos das células;
- fórmulas completas;
- CNPJs;
- nomes;
- e-mails;
- dados operacionais.

---

# 19. Contagem de fórmulas

Para cada coluna foram registradas:

- quantidade de fórmulas;
- quantidade de erros;
- assinatura resumida do padrão;
- presença de padrões diferentes.

A assinatura do padrão substituiu elementos variáveis, como:

- referências de células;
- números;
- textos literais.

Depois, gerou uma referência curta não reversível para comparação estrutural.

O conteúdo integral da fórmula não foi armazenado.

---

# 20. Contagem de funções

As funções foram identificadas por análise estrutural das fórmulas.

Foram contabilizadas ocorrências como:

- `IF`;
- `VALUE`;
- `SUBSTITUTE`;
- `XLOOKUP`;
- `COUNTIFS`;
- `IMPORTRANGE`.

Uma única fórmula pode conter várias funções.

Por isso:

```text
total de ocorrências de funções
pode ser maior que
total de fórmulas
```

---

# 21. Erros da planilha

Os valores exibidos foram classificados por tipo.

Categorias avaliadas:

- `#N/A`;
- `#REF!`;
- `#VALUE!`;
- `#ERROR!`;
- `#DIV/0!`;
- `#NAME?`;
- `#NUM!`;
- `#NULL!`;
- outros erros iniciados por `#`.

O inventário identificou células exibindo erros, mas não concluiu automaticamente que todos eram causados por fórmulas quebradas.

---

# 22. Amostragem periódica

A cada intervalo foram lidas três regiões representativas:

```text
início da planilha
meio da planilha
final da planilha
```

A configuração utilizada considerou:

- 100 linhas iniciais;
- 200 linhas centrais;
- 500 linhas finais.

Total por amostra:

```text
800 linhas
```

Com 35 colunas:

```text
28.000 células amostradas
```

As regiões sobrepostas eram consolidadas para evitar dupla leitura.

---

# 23. Métricas da baseline

Cada amostra registrou:

- horário;
- última modificação;
- última linha;
- última coluna;
- quantidade de fórmulas;
- quantidade de erros;
- fórmulas por coluna;
- duração de abertura;
- duração de leitura;
- duração total da amostra.

## Mudanças de `modifiedTime`

Uma transição de `modifiedTime` indicou que a planilha estava com timestamp diferente da amostra anterior.

Isso não representa necessariamente uma única edição.

Uma transição pode corresponder a:

- uma alteração;
- várias alterações;
- uma automação;
- atividade de múltiplos usuários.

---

# 24. Critérios de aceitação

## Pipeline

O estudo foi considerado funcionalmente aprovado quando:

- a produção permaneceu somente para leitura;
- os ciclos concluíram;
- as publicações foram validadas;
- as saídas técnicas não continham fórmulas;
- a auditoria aprovou a integridade;
- incidentes foram recuperados;
- a janela encerrou automaticamente;
- não permaneceram gatilhos;
- não permaneceram leases;
- não permaneceram concessões.

## Baseline

A baseline foi considerada concluída quando:

- o inventário percorreu toda a área utilizada;
- 96 amostras foram coletadas;
- não ocorreram falhas;
- nenhuma escrita foi executada;
- nenhuma fórmula completa foi persistida;
- nenhum conteúdo operacional foi armazenado;
- o gatilho foi removido automaticamente.

---

# 25. Tratamento de incidentes

Incidentes não foram removidos da análise.

Cada incidente foi avaliado quanto a:

- causa;
- impacto;
- efeitos executados;
- estado preservado;
- possibilidade de recuperação;
- necessidade de rollback;
- correção;
- revalidação.

Bloqueios históricos permaneceram documentados mesmo depois da recuperação.

Essa abordagem evitou apresentar somente execuções bem-sucedidas e preservou os aprendizados da prova.

---

# 26. Fontes de evidência

As evidências vieram de:

- resultados persistidos;
- Script Properties;
- logs de execução;
- Cloud Logging;
- metadados do BigQuery;
- inventário das planilhas;
- relatórios consolidados;
- auditorias.

## Limitação das Script Properties

Algumas chaves preservavam apenas o resultado mais recente.

Por isso, o Cloud Logging foi utilizado para complementar a análise histórica.

## Limitação do Cloud Logging

Exportações podem:

- possuir limites;
- exigir divisão por períodos;
- repetir resultados;
- omitir partes de mensagens grandes;
- conter logs truncados.

As conclusões foram baseadas em evidências compatíveis entre mais de uma fonte quando necessário.

---

# 27. Privacidade

A coleta foi desenhada para armazenar somente métricas agregadas.

Não foram persistidos:

- CNPJs;
- nomes;
- e-mails;
- telefones;
- textos operacionais;
- fórmulas completas;
- dados de clientes;
- conteúdo integral de células.

Os resultados públicos utilizam:

- números arredondados;
- nomes genéricos;
- períodos não correlacionáveis;
- ausência de identificadores;
- ausência de logs brutos.

---

# 28. Limitações metodológicas

O estudo possui limitações.

## Período

- a janela automatizada teve duração de 48 horas;
- a baseline teve duração de 24 horas;
- parte da baseline ocorreu fora do expediente.

## Amostra

- o inventário estrutural foi completo;
- a medição periódica utilizou regiões amostradas;
- nem todos os picos operacionais foram necessariamente observados.

## Recálculo

O Apps Script não expõe o tempo total de recálculo interno do Google Sheets.

Portanto, foram medidos:

- abertura;
- leitura;
- duração do monitor;
- quantidade de fórmulas;
- quantidade de erros;
- estabilidade estrutural.

## Generalização

Os resultados não garantem o mesmo comportamento em:

- outros volumes;
- outras regiões;
- outras contas;
- outros esquemas;
- outras frequências;
- ambientes com faturamento;
- ambientes produtivos.

---

# 29. Reprodutibilidade

Uma adaptação metodologicamente equivalente precisa preservar:

- origem somente para leitura;
- destino isolado;
- configuração versionada;
- identificação dos recursos;
- etapas independentes;
- estados persistidos;
- candidatas;
- validação antes da promoção;
- backups;
- assinaturas;
- auditoria;
- logs;
- dados sintéticos para testes;
- encerramento automático.

Resultados comparáveis exigem que:

- períodos sejam registrados;
- volumes sejam informados;
- consultas sejam equivalentes;
- unidades sejam preservadas;
- bytes processados e faturáveis sejam separados;
- projeções sejam identificadas como projeções;
- incidentes sejam incluídos.

---

# 30. Síntese metodológica

A metodologia combinou:

```text
INVENTÁRIO
+
EXPERIMENTO CONTROLADO
+
OBSERVAÇÃO TEMPORAL
+
MÉTRICAS
+
AUDITORIA
+
ANÁLISE DE INCIDENTES
```

Essa combinação permitiu avaliar não apenas se o pipeline funcionava, mas também:

- como se comportava;
- quanto consumia;
- onde era mais lento;
- como reagia a falhas;
- quais controles eram necessários;
- quais limites permaneciam.

---

# Referências

- [BigQuery Sandbox](https://docs.cloud.google.com/bigquery/docs/sandbox)
- [BigQuery Quotas and Limits](https://docs.cloud.google.com/bigquery/quotas)
- [BigQuery Jobs](https://docs.cloud.google.com/bigquery/docs/jobs-overview)
- [Google Apps Script — Quotas](https://developers.google.com/apps-script/guides/services/quotas)
- [Google Apps Script — Triggers](https://developers.google.com/apps-script/guides/triggers)
- [Google Apps Script — Logging](https://developers.google.com/apps-script/guides/logging)
