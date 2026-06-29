-- ================================================
-- PORTFÓLIO OLIST | MÓDULO 1 — ANÁLISE SQL
-- Autor: Aline S Souza
-- Banco: PostgreSQL | Dataset: Olist E-commerce
-- ================================================


-- ------------------------------------------------
-- QUERY 1 — Volume de pedidos por status
-- Pergunta: Qual a saúde operacional dos pedidos?
-- Insight: 97% dos pedidos foram entregues com 
-- sucesso. Taxa de cancelamento de apenas 0,63%,
-- bem abaixo da média do e-commerce brasileiro.
-- ------------------------------------------------

SELECT 
    order_status,
    COUNT(*) AS total_pedidos,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentual
FROM olist_orders_dataset
GROUP BY order_status
ORDER BY total_pedidos DESC;


-- ------------------------------------------------
-- QUERY 2 — Receita total por mês
-- Pergunta: O negócio está crescendo? Há sazonalidade?
-- Insight: Crescimento consistente em 2017 com pico
-- em novembro, confirmando impacto da Black Friday.
-- ------------------------------------------------

SELECT 
    TO_CHAR(o.order_purchase_timestamp, 'YYYY-MM') AS mes,
    COUNT(DISTINCT o.order_id) AS total_pedidos,
    ROUND(SUM(p.payment_value)::NUMERIC, 2) AS receita_total
FROM olist_orders_dataset o
JOIN olist_order_payments_dataset p ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
GROUP BY mes
ORDER BY mes;


-- ------------------------------------------------
-- QUERY 3 — Top 10 categorias por receita
-- Pergunta: Onde o dinheiro está concentrado?
-- Insight: Health & Beauty lidera em receita (R$1,26M),
-- mas Watches tem maior ticket médio (R$201).
-- Bed & Bath tem mais volume mas menor ticket (R$93).
-- ------------------------------------------------

SELECT 
    t.product_category_name_english  AS categoria,
    COUNT(DISTINCT oi.order_id)   AS total_pedidos,
    ROUND(SUM(oi.price)::NUMERIC, 2) AS receita_total,
    ROUND(AVG(oi.price)::NUMERIC, 2) AS ticket_medio
FROM olist_order_items_dataset oi
JOIN olist_products_dataset pr  ON oi.product_id = pr.product_id
JOIN product_category_name_translation t ON pr.product_category_name = t.product_category_name
GROUP BY categoria
ORDER BY receita_total DESC
LIMIT 10;


-- ------------------------------------------------
-- QUERY 4 — Tempo médio de entrega por estado
-- Pergunta: Há desigualdade logística regional?
-- Insight: RR espera 29 dias vs 11,5 dias no PR.
-- Estados distantes recebem com mais antecedência
-- pois a Olist usa prazos conservadores no Norte.
-- ------------------------------------------------

SELECT 
    c.customer_state AS estado,
    COUNT(o.order_id) AS total_pedidos,
    ROUND(AVG( DATE_PART('day', o.order_delivered_customer_date - o.order_purchase_timestamp))::NUMERIC, 1) AS dias_entrega_medio,
    ROUND(AVG( DATE_PART('day', o.order_estimated_delivery_date - o.order_delivered_customer_date) )::NUMERIC, 1) AS dias_adiantado_medio
FROM olist_orders_dataset o
JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY estado
ORDER BY dias_entrega_medio DESC;


-- ------------------------------------------------
-- QUERY 5 — Impacto do atraso na satisfação (CTE)
-- Pergunta: Atraso na entrega afeta a nota do cliente?
-- Insight: Atraso grave derruba nota de 4,3 para 1,85
-- (-57%). É o principal driver de insatisfação da Olist.
-- Técnica: duas CTEs encadeadas + CASE WHEN + JOIN
-- ------------------------------------------------

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



