# 📊 Portfólio de Análise de Dados — Dataset Olist E-commerce

**Autor:** Aline Silva de Souza  
**LinkedIn:** [/in/alinesdesouza](https://linkedin.com/in/alinesdesouza)  
**Ferramentas utilizadas:** PostgreSQL · Excel · Python · Power BI

---

## 📌 Sobre o projeto

Análise end-to-end do dataset público da **Olist**, maior marketplace B2B do Brasil, disponível no [Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce).

O objetivo foi construir um portfólio completo de analista de dados júnior, respondendo perguntas reais de negócio sobre operações, vendas, logística e satisfação de clientes — usando as 4 ferramentas mais pedidas no mercado.

---

## 🗂️ Dataset

O dataset contém **99.441 pedidos** realizados entre 2016 e 2018, distribuídos em 9 tabelas:

| Arquivo | Descrição | Registros |
|---|---|---|
| olist_orders_dataset.csv | Pedidos e status | 99.441 |
| olist_order_items_dataset.csv | Itens por pedido | 112.650 |
| olist_order_payments_dataset.csv | Pagamentos | 103.886 |
| olist_order_reviews_dataset.csv | Avaliações dos clientes | 77.920 |
| olist_products_dataset.csv | Cadastro de produtos | 32.951 |
| olist_customers_dataset.csv | Cadastro de clientes | 99.441 |
| olist_sellers_dataset.csv | Cadastro de vendedores | 3.095 |
| olist_geolocation_dataset.csv | Geolocalização por CEP | — |
| product_category_name_translation.csv | Tradução das categorias | 71 |

---

## 🗺️ Estrutura do portfólio

```
portfolio-olist/
├── README.md
├── sql/
│   └── modulo1_sql_olist.sql
├── excel/
│   └── modulo2_excel_olist.xlsx
├── python/
│   └── modulo3_python_olist.ipynb
└── powerbi/
    └── modulo4_powerbi_olist.pbix
```

---

## Módulo 1 — SQL (PostgreSQL)

### Ambiente
- **Banco:** PostgreSQL
- **Interface:** DBeaver
- **Dados:** 9 tabelas importadas via CSV

### O que foi demonstrado
Domínio de SQL do básico ao avançado: agregações, JOINs entre múltiplas tabelas, funções de data, window functions e CTEs encadeadas.

---

### Query 1 — Volume de pedidos por status

**Pergunta:** Qual a saúde operacional dos pedidos?

```sql
SELECT 
    order_status,
    COUNT(*) AS total_pedidos,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentual
FROM olist_orders_dataset
GROUP BY order_status
ORDER BY total_pedidos DESC;
```

**Resultado e insight:**

| Status | Pedidos | % |
|---|---|---|
| delivered | 96.478 | 97,02% |
| shipped | 1.107 | 1,11% |
| canceled | 625 | 0,63% |

> 97% dos pedidos foram entregues com sucesso. A taxa de cancelamento de apenas 0,63% está muito abaixo da média do e-commerce brasileiro (em torno de 5%), indicando alta eficiência operacional da plataforma.

---

### Query 2 — Receita total por mês

**Pergunta:** O negócio está crescendo? Há sazonalidade?

```sql
SELECT 
    TO_CHAR(o.order_purchase_timestamp, 'YYYY-MM') AS mes,
    COUNT(DISTINCT o.order_id)                      AS total_pedidos,
    ROUND(SUM(p.payment_value)::NUMERIC, 2)         AS receita_total
FROM olist_orders_dataset o
JOIN olist_order_payments_dataset p ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
GROUP BY mes
ORDER BY mes;
```

**Insight:**
> A receita cresceu de forma consistente ao longo de 2017, saindo de R$ 127 mil em janeiro para pico de R$ 1,15M em novembro — confirmando forte impacto da Black Friday. O crescimento médio mensal foi de aproximadamente 15% ao longo do período.

---

### Query 3 — Top 10 categorias por receita

**Pergunta:** Onde o dinheiro está concentrado?

```sql
SELECT 
    t.product_category_name_english     AS categoria,
    COUNT(DISTINCT oi.order_id)         AS total_pedidos,
    ROUND(SUM(oi.price)::NUMERIC, 2)    AS receita_total,
    ROUND(AVG(oi.price)::NUMERIC, 2)    AS ticket_medio
FROM olist_order_items_dataset oi
JOIN olist_products_dataset pr           ON oi.product_id = pr.product_id
JOIN product_category_name_translation t ON pr.product_category_name = t.product_category_name
GROUP BY categoria
ORDER BY receita_total DESC
LIMIT 10;
```

**Resultado:**

| Categoria | Pedidos | Receita | Ticket Médio |
|---|---|---|---|
| health_beauty | 8.836 | R$ 1,26M | R$ 130 |
| watches_gifts | 5.624 | R$ 1,20M | R$ 201 |
| bed_bath_table | 9.417 | R$ 1,03M | R$ 93 |
| sports_leisure | 7.720 | R$ 988k | R$ 114 |
| computers_accessories | 6.689 | R$ 911k | R$ 116 |

**Insight:**
> Health & Beauty lidera em receita total (R$ 1,26M), mas Watches & Gifts tem o maior ticket médio (R$ 201) — vende menos, mas cada venda vale mais. Bed, Bath & Table tem o maior volume de pedidos (9.417) com o menor ticket do top 10 (R$ 93), caracterizando uma categoria de alto giro e baixo valor unitário.

---

### Query 4 — Tempo médio de entrega por estado

**Pergunta:** Há desigualdade logística regional?

```sql
SELECT 
    c.customer_state                                                AS estado,
    COUNT(o.order_id)                                              AS total_pedidos,
    ROUND(AVG(
        DATE_PART('day', o.order_delivered_customer_date - o.order_purchase_timestamp)
    )::NUMERIC, 1)                                                  AS dias_entrega_medio,
    ROUND(AVG(
        DATE_PART('day', o.order_estimated_delivery_date - o.order_delivered_customer_date)
    )::NUMERIC, 1)                                                  AS dias_adiantado_medio
FROM olist_orders_dataset o
JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY estado
ORDER BY dias_entrega_medio DESC;
```

**Insight:**
> Existe uma disparidade logística significativa: clientes de Roraima esperam em média 29 dias, contra 11,5 dias no Paraná — diferença de 2,5x. Os estados com maior tempo de entrega também recebem os pedidos mais adiantados em relação ao prazo estimado, sugerindo que a Olist adota prazos conservadores para regiões remotas como estratégia de gestão de expectativa.

---

### Query 5 — Impacto do atraso na satisfação do cliente (CTE)

**Pergunta:** Atraso na entrega afeta a nota do cliente?  
**Técnica:** Duas CTEs encadeadas + CASE WHEN + JOIN

```sql
WITH entregas AS (
    SELECT 
        order_id,
        DATE_PART('day', order_delivered_customer_date - order_estimated_delivery_date) AS dias_atraso
    FROM olist_orders_dataset
    WHERE order_delivered_customer_date IS NOT NULL
      AND order_estimated_delivery_date IS NOT NULL
),
classificacao AS (
    SELECT 
        order_id,
        dias_atraso,
        CASE 
            WHEN dias_atraso <= -3 THEN 'Muito adiantado'
            WHEN dias_atraso <  0  THEN 'Adiantado'
            WHEN dias_atraso =  0  THEN 'No prazo'
            WHEN dias_atraso <= 3  THEN 'Leve atraso'
            ELSE                        'Atraso grave'
        END AS situacao_entrega
    FROM entregas
)
SELECT 
    c.situacao_entrega,
    COUNT(*)                               AS total_pedidos,
    ROUND(AVG(r.review_score)::NUMERIC, 2) AS nota_media
FROM classificacao c
JOIN olist_order_reviews_dataset r ON c.order_id = r.order_id
GROUP BY c.situacao_entrega
ORDER BY nota_media DESC;
```

**Resultado:**

| Situação | Pedidos | Nota Média |
|---|---|---|
| Muito adiantado | 66.006 | ⭐ 4,30 |
| Adiantado | 2.558 | ⭐ 4,12 |
| No prazo | 2.126 | ⭐ 4,09 |
| Leve atraso | 1.446 | ⭐ 3,27 |
| Atraso grave | 3.550 | ⭐ 1,85 |

**Insight:**
> O prazo de entrega é o principal driver de satisfação do cliente. Pedidos com atraso grave têm nota 1,85 contra 4,30 dos muito adiantados — queda de 57%. Reduzir atrasos graves seria a principal alavanca para melhorar o NPS da plataforma. Vale destacar que 87% dos pedidos chegaram muito antes do prazo estimado, confirmando a estratégia conservadora de prazos da Olist.

---

## Módulo 2 — Excel

### Ambiente
- **Ferramenta:** Microsoft Excel
- **Dados:** exportados via DBeaver (resultados das queries SQL)

### Estrutura do arquivo
O arquivo `modulo2_excel_olist.xlsx` contém 6 abas:

| Aba | Conteúdo |
|---|---|
| Capa | Apresentação do projeto com hiperlinks |
| Receita_Mensal | Gráfico de linha com pico de novembro destacado |
| Top_Categorias | Barras horizontais + gráfico de dispersão |
| Tabela_regiao | Tabela dinâmica de entrega por região |
| Entrega_por_Estado | Dados brutos dos 27 estados com coluna de região |
| Atraso_vs_Satisfação | Gráfico de colunas colorido + formatação condicional |

---

### Aba Receita Mensal
- Coluna de variação % entre meses: `=(C3-C2)/C2`
- Coluna de média móvel 3 meses: `=MÉDIA(C2:C4)`
- Gráfico de linha com pico de novembro/2017 destacado em laranja

**Insight:**
> A receita cresceu de R$ 46 mil em outubro/2016 para R$ 1,15M em novembro/2017 — crescimento de 25x em 13 meses. O pico de novembro confirma o forte impacto da Black Friday no e-commerce brasileiro.

---

### Aba Top Categorias
- Coluna de participação % na receita: `=C2/SOMA($C$2:$C$11)`
- Gráfico de barras horizontais ordenado do maior para o menor
- Gráfico de dispersão: ticket médio vs volume de pedidos por categoria

**Insight:**
> O gráfico de dispersão revela que Watches & Gifts está isolado no quadrante de alto ticket médio (R$ 201) e volume médio, enquanto Bed, Bath & Table concentra alto volume com baixo ticket (R$ 93).

---

### Aba Entrega por Estado
- Coluna de região adicionada manualmente para os 27 estados
- Tabela dinâmica com média de dias de entrega por região (aba Tabela_regiao)
- Gráfico de barras com escala de cores: vermelho para Norte, verde para Sul/Sudeste

**Resultado da tabela dinâmica:**

| Região | Média dias entrega |
|---|---|
| Norte | 23,1 dias |
| Nordeste | 20,2 dias |
| Centro-Oeste | 15,1 dias |
| Sul | 13,6 dias |
| Sudeste | 12,5 dias |

---

### Aba Atraso vs Satisfação
- Gráfico de colunas com cores do verde ao vermelho (muito adiantado → atraso grave)
- Rótulos de dados com a nota exata em cada barra
- Formatação condicional tricolor nas células de nota (verde → amarelo → vermelho)

---

## Módulo 3 — Python

### Ambiente
- **Ferramenta:** Google Colab
- **Bibliotecas:** Pandas · Matplotlib · Seaborn
- **Dados:** 9 CSVs carregados via Google Drive

### Estrutura do notebook

| Célula | Tipo | Conteúdo |
|---|---|---|
| 1 | Markdown | Título, objetivo e perguntas respondidas |
| 2 | Código | Importação de bibliotecas e configurações visuais |
| 3 | Código | Conexão com Google Drive e carregamento dos 9 CSVs |
| 4 | Código | Visão geral dos datasets (shape e valores nulos) |
| 5 | Código | Análise 1 — Receita mensal com gráfico de linha |
| 6 | Código | Análise 2 — Top 10 categorias por receita |
| 7 | Código | Análise 3 — Distribuição do prazo de entrega |
| 8 | Código | Análise 4 — Nota média por situação de entrega |
| 9 | Markdown | Conclusões e principais insights |

---

### Visão geral dos dados (Célula 4)

```
=== SHAPE DOS DATASETS ===
orders      :  99,441 linhas | 8 colunas
items       : 112,650 linhas | 7 colunas
payments    : 103,886 linhas | 5 colunas
reviews     :  99,224 linhas | 7 colunas

=== VALORES NULOS EM ORDERS ===
order_approved_at               160
order_delivered_carrier_date   1783
order_delivered_customer_date  2965
```

> Os valores nulos em datas de entrega correspondem a pedidos cancelados ou ainda em trânsito — dado esperado e coerente com o negócio.

---

### Análise 1 — Receita mensal

Filtra pedidos entregues, faz JOIN com pagamentos, agrupa por mês e plota gráfico de linha com destaque no pico de novembro/2017 (Black Friday).

**Resultado:** Receita máxima de R$ 1.153.528,05 em novembro/2017.

---

### Análise 2 — Top 10 categorias

JOIN entre itens + produtos + tradução de categorias. Agrupa por categoria calculando receita total, pedidos únicos e ticket médio.

**Resultado:** Health & Beauty lidera com R$ 1,26M. Watches & Gifts tem maior ticket médio (R$ 201).

---

### Análise 3 — Prazo de entrega

Calcula o atraso em dias (entregue - estimado), classifica em 5 categorias com CASE WHEN e plota gráfico de barras coloridas.

**Resultado:** 87% dos pedidos chegaram muito antes do prazo estimado.

---

### Análise 4 — Nota por situação de entrega

Faz JOIN da tabela de entregas com reviews e calcula nota média por categoria de prazo.

**Resultado:** Atraso grave → nota 1,85 | Muito adiantado → nota 4,30 (queda de 57%).

---

### Principais conclusões

1. **Crescimento acelerado:** receita cresceu ~25x entre out/2016 e nov/2017, com pico na Black Friday de R$ 1,15M
2. **Concentração em poucas categorias:** top 3 categorias respondem por 35% da receita total
3. **Estratégia de prazo conservadora:** 87% dos pedidos chegam muito antes do prazo estimado
4. **Atraso é o principal driver de insatisfação:** pedidos com atraso grave têm nota 1,85 vs 4,30 para adiantados — queda de 57%

---

## Módulo 4 — Power BI

### Ambiente
- **Ferramenta:** Power BI Desktop
- **Dados:** 9 CSVs importados diretamente e tratados via Power Query
- **Modelo:** Relacionamentos em esquema estrela (Star Schema) otimizados para performance
- **Visual:** Dark Theme — fundo escuro com foco em tomada de decisão executiva

### O que foi demonstrado
Engenharia de dados no Power Query (limpeza de strings técnicas e tradução de termos nativos de banco de dados para português executivo), modelagem relacional, DAX avançado com regras de negócio e design UI/UX com storytelling de dados e cores com propósito (uso semafórico de alertas).

---

### Medidas DAX criadas

```dax
Receita Total = SUM(olist_order_payments_dataset[payment_value])

Total Pedidos = DISTINCTCOUNT(olist_orders_dataset[order_id])

Ticket Medio = DIVIDE([Receita Total], [Total Pedidos])

Nota Media = AVERAGE(olist_order_reviews_dataset[review_score])

Taxa Cancelamento = 
DIVIDE(
    COUNTROWS(FILTER(olist_orders_dataset, 
              olist_orders_dataset[order_status] = "canceled")),
    [Total Pedidos]
)

Tempo Medio Entrega = 
AVERAGEX(
    FILTER(olist_orders_dataset, 
           olist_orders_dataset[order_delivered_customer_date] <> BLANK()),
    DATEDIFF(olist_orders_dataset[order_purchase_timestamp],
             olist_orders_dataset[order_delivered_customer_date], DAY)
)
```

---

### Colunas calculadas e inteligência de classificação

Para corrigir a ordenação do gráfico e evitar que o Power BI organizasse as colunas textuais em ordem alfabética (o que romperia a linha lógica do negócio), foi construída uma arquitetura de duas colunas acopladas:

**1. Coluna de Classificação de Negócio:**

```dax
Situacao Entrega = 
VAR dias = DATEDIFF(
    olist_orders_dataset[order_estimated_delivery_date],
    olist_orders_dataset[order_delivered_customer_date], DAY)
RETURN
SWITCH(TRUE(),
    dias <= -3, "Muito adiantado",
    dias < 0,  "Adiantado",
    dias = 0,  "No prazo",
    dias <= 3, "Leve atraso",
    "Atraso grave"
)
```

**2. Coluna de Suporte Indexada** *(usada no recurso "Classificar por Coluna"):*

```dax
Ordem_Situacao = 
VAR dias = DATEDIFF(
    olist_orders_dataset[order_estimated_delivery_date],
    olist_orders_dataset[order_delivered_customer_date], DAY)
RETURN
SWITCH(TRUE(),
    dias <= -3, 1, -- Muito adiantado recebe peso 1
    dias < 0,  2,  -- Adiantado recebe peso 2
    dias = 0,  3,  -- No prazo recebe peso 3
    dias <= 3, 4,  -- Leve atraso recebe peso 4
    5              -- Atraso grave recebe peso 5
)
```

---

### Estrutura do dashboard

**Página 1 — Olist · Visão Geral de Negócio**
- Cartões de KPI com moldura em Ciano Neon: Receita Total (R$ 1,60 Bi) · Nota Média (4,09) · Total Pedidos (99 Mil) · Ticket Médio (R$ 16,10 Mil) · Taxa Cancelamento (0,01)
- Gráfico de Linha: evolução temporal da Receita Total por Mês, evidenciando tendências históricas
- Gráfico de Barras Horizontais: ranking de Receita Total por Categoria de Produto (tratado e formatado sem termos técnicos de banco)

**Página 2 — Olist · Logística e Entregas**
- Gráfico de Barras Horizontais com Rótulos Ativos: Tempo Médio de Entrega por Estado do Cliente — destacando os extremos operacionais (RR com 29 dias e SP com 9 dias)
- Gráfico de Rosca Avançado: distribuição do Total de Pedidos por Situação de Entrega, com precisão proporcional do volume entregue com sucesso
- Cartão de Destaque: Tempo Médio de Entrega Consolidado (12,50 dias)

**Página 3 — Olist · Satisfação do Cliente**
- Gráfico de Colunas com Cores com Propósito (uso semafórico): Nota Média por Situação de Entrega — Ciano para status saudáveis, Amarelo para "Leve atraso" e Vermelho para "Atraso grave"
- Gráfico de Barras Horizontais: Volume de Pedidos por Nota de Avaliação (contagem absoluta em cada faixa de 1 a 5 estrelas)
- Rótulos de Dados Ativos em ambos os visuais para eliminar o esforço cognitivo do usuário

---

## 📈 Principais insights do projeto

| # | Insight | Área | Ferramentas |
|---|---|---|---|
| 1 | 97% dos pedidos entregues com sucesso — cancelamento de apenas 0,63% | Operacional | SQL |
| 2 | Receita cresceu consistentemente em 2017 com pico de R$ 1,15M em novembro (Black Friday) | Comercial | SQL / Excel / Python |
| 3 | Health & Beauty lidera faturamento bruto (R$ 1,26M); Watches & Gifts domina valor por unidade com ticket médio de R$ 201 | Estratégico | SQL / Excel |
| 4 | Disparidade logística extrema: RR lidera com 29 dias de espera vs SP com 9 dias — eficiência 3,2x maior no Sudeste | Logística | SQL / Excel / Power BI |
| 5 | O Paradoxo da Expectativa: clientes que recebem "No prazo" têm satisfação (2,5) menor que os de "Leve atraso" (3,3) — indica falha de calibração na promessa de entrega | CRM / CX | SQL / Python / Power BI |
| 6 | Declínio crítico de retenção: atraso grave derruba a nota de 4,30 para 1,85 — quebra abrupta de 57% no NPS operacional | Experiência | Python / Power BI |

---

## 🛠️ Como reproduzir

### Pré-requisitos
- PostgreSQL + DBeaver
- Microsoft Excel
- Google Colab (conta Google gratuita)
- Power BI Desktop (gratuito)

### Passo a passo
1. Baixe os 9 CSVs no [Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
2. Crie o banco `olist` no PostgreSQL e importe os CSVs
3. Execute as queries da pasta `sql/`
4. Abra o arquivo `excel/modulo2_excel_olist.xlsx`
5. Acesse o notebook `python/modulo3_python_olist.ipynb` no Google Colab
6. Abra o arquivo `powerbi/modulo4_powerbi_olist.pbix` no Power BI Desktop

---

## 📦 Dataset

[Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) — disponível no Kaggle sob licença CC BY-NC-SA 4.0.
