-- Title: Customer Purchase Amount Distribution
-- Business Question: Create a histogram showing how many customers fall into different purchase amount ranges
-- Technique: CASE statement with WHEN conditions to bucket continuous values into discrete ranges

CREATE TABLE customer_purchases (
  customer_id INTEGER PRIMARY KEY,
  purchase_amount DECIMAL(10, 2)
);

INSERT INTO customer_purchases VALUES
(1, 15.50),
(2, 48.75),
(3, 125.00),
(4, 32.25),
(5, 250.99),
(6, 87.40),
(7, 5.10),
(8, 156.80),
(9, 42.50),
(10, 199.99),
(11, 73.25),
(12, 310.45);

SELECT
  CASE
    WHEN purchase_amount < 25 THEN 'Under $25'
    WHEN purchase_amount >= 25 AND purchase_amount < 75 THEN '$25-$74'
    WHEN purchase_amount >= 75 AND purchase_amount < 150 THEN '$75-$149'
    WHEN purchase_amount >= 150 AND purchase_amount < 250 THEN '$150-$249'
    ELSE '$250+'
  END AS price_range,
  COUNT(*) AS customer_count,
  ROUND(AVG(purchase_amount), 2) AS avg_purchase,
  ROUND(MIN(purchase_amount), 2) AS min_purchase,
  ROUND(MAX(purchase_amount), 2) AS max_purchase
FROM customer_purchases
GROUP BY price_range
ORDER BY
  CASE
    WHEN price_range = 'Under $25' THEN 1
    WHEN price_range = '$25-$74' THEN 2
    WHEN price_range = '$75-$149' THEN 3
    WHEN price_range = '$150-$249' THEN 4
    ELSE 5
  END;

-- Result (verified in SQLite):
-- price_range | customer_count | avg_purchase | min_purchase | max_purchase
-- Under $25 | 2 | 10.3 | 5.1 | 15.5
-- $25-$74 | 4 | 49.19 | 32.25 | 73.25
-- $75-$149 | 2 | 106.2 | 87.4 | 125.0
-- $150-$249 | 2 | 178.4 | 156.8 | 199.99
-- $250+ | 2 | 280.72 | 250.99 | 310.45
