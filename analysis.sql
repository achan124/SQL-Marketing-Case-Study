-- =================================================================
-- Project: E-Commerce and Marketing Data Analysis
-- Author: Alexia Chan
-- =================================================================



--------------------------------------------------------------------
-- DATA CLEANING
--------------------------------------------------------------------

-- Replace missing product_id with 0
UPDATE transactions
SET product_id = 0
WHERE product_id IS NULL;

-- Replace missing gross_revenue with 0
UPDATE transactions
SET gross_revenue = 0
WHERE gross_revenue IS NULL;



--------------------------------------------------------------------
-- EXPLORATORY ANALYSIS
--------------------------------------------------------------------

-- ==================================
-- PRODUCT INSIGHTS:
-- ==================================

-- Top 10 selling products by revenue
SELECT TOP 10 product_id, ROUND(SUM(gross_revenue), 2) AS total_revenue
FROM transactions
GROUP BY product_id
ORDER BY total_revenue DESC;

-- Revenue by category or brand
SELECT p.category, ROUND(SUM(t.gross_revenue), 2) AS total_revenue
FROM products p
JOIN transactions t
    ON p.product_id = t.product_id
GROUP BY p.category
ORDER BY total_revenue DESC;

-- Product performance trend (revenue per product over time)
SELECT p.product_id, MONTH(t.timestamp) AS month, ROUND(SUM(t.gross_revenue), 2) AS total_revenue
FROM products p
JOIN transactions t 
    ON p.product_id = t.product_id
GROUP BY p.product_id, MONTH(t.timestamp)
ORDER BY p.product_id, month;

-- ==================================
-- MARKETING INSIGHTS:
-- ==================================

-- Total revenue generated per campaign
SELECT c.campaign_id, ROUND(SUM(t.gross_revenue), 2) AS total_revenue
FROM campaigns c
JOIN transactions t 
    ON c.campaign_id = t.campaign_id
GROUP BY c.campaign_id
ORDER BY total_revenue DESC;

-- Average order value per campaign
SELECT campaign_id, ROUND(AVG(gross_revenue), 2) AS average_order_value
FROM transactions
GROUP BY campaign_id
ORDER BY  average_order_value DESC;

-- Number of customers per aquisition channel
SELECT COUNT(customer_id) as number_of_customers, acquisition_channel
FROM customers
GROUP BY acquisition_channel
ORDER BY number_of_customers DESC;

-- Revenue per acquisition channel
SELECT c.acquisition_channel, ROUND(SUM(t.gross_revenue), 2) AS total_revenue
FROM customers c 
JOIN transactions t 
    ON c.customer_id = t.customer_id
GROUP BY c.acquisition_channel
ORDER BY total_revenue DESC;

-- Repeat customers per acquisition channel
WITH customer_purchases AS (
    SELECT customer_id, COUNT(*) AS num_purchases
    FROM transactions
    GROUP BY customer_id
)
SELECT c.acquisition_channel, COUNT(*) as repeat_customers
FROM customer_purchases cp
JOIN customers c 
    ON cp.customer_id = c.customer_id
WHERE cp.num_purchases > 1
GROUP BY c.acquisition_channel;

-- Count of users at each stage of funnel
SELECT event_type, COUNT(DISTINCT customer_id) as user_count
FROM events
GROUP BY event_type;



--------------------------------------------------------------------
-- USER JOURNEY DROPOFF VIEW
--------------------------------------------------------------------

GO
-- View: user_journey
-- Shows dropoff rate between each stage of the user journey
-- Stage order: view -> click -> add_to_cart -> purchase
-- 'bounce' events excluded

CREATE VIEW user_journey AS
SELECT 
    first.event_type AS first_stage,
    second.event_type AS second_stage,
    first.user_count AS first_stage_user_count,
    second.user_count AS second_stage_user_count,
    first.user_count - second.user_count AS dropoff_count,
    ROUND(CAST(first.user_count - second.user_count AS float) / first.user_count, 3) AS dropoff_rate
FROM (
    SELECT event_type, COUNT(DISTINCT customer_id) AS user_count
    FROM events
    WHERE event_type != 'bounce'
    GROUP BY event_type
) first
LEFT JOIN (
    SELECT event_type, COUNT(DISTINCT customer_id) AS user_count
    FROM events
    WHERE event_type != 'bounce'
    GROUP BY event_type
) second
    ON (first.event_type = 'view' AND second.event_type = 'click')
    OR (first.event_type = 'click' AND second.event_type = 'add_to_cart')
    OR (first.event_type = 'add_to_cart' AND second.event_type = 'purchase');

-- Example usage:
-- SELECT * 
-- FROM user_journey
-- ORDER BY CASE first_stage
--         WHEN 'view' THEN 1
--         WHEN 'click' THEN 2
--         WHEN 'add_to_cart' THEN 3
--         WHEN 'purchase' THEN 4
--     END