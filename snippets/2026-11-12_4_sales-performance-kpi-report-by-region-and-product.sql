-- Title: Sales Performance KPI Report by Region and Product Category
-- Business Question: Generate a KPI report showing total revenue, order count, average order value, and percentage of high-value orders (>$500) by region and product category.
-- Technique: Conditional aggregation using CASE WHEN with SUM, COUNT, AVG, and conditional COUNT for KPI calculations.

CREATE TABLE orders (
  order_id INTEGER PRIMARY KEY,
  order_date DATE,
  region TEXT,
  product_category TEXT,
  order_amount DECIMAL(10, 2)
);

INSERT INTO orders VALUES
(1, '2024-01-05', 'North', 'Electronics', 750.00),
(2, '2024-01-10', 'North', 'Electronics', 320.00),
(3, '2024-01-15', 'North', 'Furniture', 620.00),
(4, '2024-01-20', 'South', 'Electronics', 480.00),
(5, '2024-01-25', 'South', 'Furniture', 890.00),
(6, '2024-02-02', 'South', 'Electronics', 550.00),
(7, '2024-02-08', 'East', 'Furniture', 410.00),
(8, '2024-02-12', 'East', 'Electronics', 1200.00),
(9, '2024-02-18', 'West', 'Furniture', 680.00),
(10, '2024-02-25', 'West', 'Electronics', 300.00),
(11, '2024-03-05', 'North', 'Furniture', 950.00),
(12, '2024-03-10', 'South', 'Furniture', 520.00);

WITH kpi_data AS (
  SELECT
    region,
    product_category,
    SUM(order_amount) AS total_revenue,
    COUNT(*) AS order_count,
    ROUND(AVG(order_amount), 2) AS avg_order_value,
    SUM(CASE WHEN order_amount > 500 THEN 1 ELSE 0 END) AS high_value_orders,
    ROUND(100.0 * SUM(CASE WHEN order_amount > 500 THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_high_value_orders
  FROM orders
  GROUP BY region, product_category
)
SELECT
  region,
  product_category,
  total_revenue,
  order_count,
  avg_order_value,
  high_value_orders,
  pct_high_value_orders
FROM kpi_data
ORDER BY region, product_category;

-- Result (verified in SQLite):
-- region | product_category | total_revenue | order_count | avg_order_value | high_value_orders | pct_high_value_orders
-- East | Electronics | 1200 | 1 | 1200.0 | 1 | 100.0
-- East | Furniture | 410 | 1 | 410.0 | 0 | 0.0
-- North | Electronics | 1070 | 2 | 535.0 | 1 | 50.0
-- North | Furniture | 1570 | 2 | 785.0 | 2 | 100.0
-- South | Electronics | 1030 | 2 | 515.0 | 1 | 50.0
-- South | Furniture | 1410 | 2 | 705.0 | 2 | 100.0
-- West | Electronics | 300 | 1 | 300.0 | 0 | 0.0
-- West | Furniture | 680 | 1 | 680.0 | 1 | 100.0
