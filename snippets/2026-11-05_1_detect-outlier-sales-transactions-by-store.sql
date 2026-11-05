-- Title: Detect Outlier Sales Transactions by Store
-- Business Question: Identify which sales transactions are statistical outliers (unusually high or low) compared to the average transaction amount for each store.
-- Technique: Calculate mean and standard deviation per store, then flag transactions falling outside 1.5 standard deviations from the mean.

CREATE TABLE sales_transactions (
  transaction_id INTEGER PRIMARY KEY,
  store_id INTEGER,
  amount DECIMAL(10, 2),
  transaction_date DATE
);

INSERT INTO sales_transactions VALUES
(1, 1, 45.50, '2024-01-15'),
(2, 1, 52.30, '2024-01-16'),
(3, 1, 48.75, '2024-01-17'),
(4, 1, 51.20, '2024-01-18'),
(5, 1, 890.00, '2024-01-19'),
(6, 2, 120.00, '2024-01-15'),
(7, 2, 115.50, '2024-01-16'),
(8, 2, 125.30, '2024-01-17'),
(9, 2, 118.75, '2024-01-18'),
(10, 2, 25.00, '2024-01-19'),
(11, 1, 49.99, '2024-01-20'),
(12, 2, 122.40, '2024-01-20');

WITH store_stats AS (
  SELECT
    store_id,
    AVG(amount) AS avg_amount,
    SQRT(AVG((amount - (SELECT AVG(amount) FROM sales_transactions WHERE store_id = st.store_id)) * 
             (amount - (SELECT AVG(amount) FROM sales_transactions WHERE store_id = st.store_id)))) AS stddev_amount
  FROM sales_transactions st
  GROUP BY store_id
)
SELECT
  t.transaction_id,
  t.store_id,
  t.amount,
  s.avg_amount,
  s.stddev_amount,
  CASE
    WHEN t.amount > s.avg_amount + (1.5 * s.stddev_amount) THEN 'High Outlier'
    WHEN t.amount < s.avg_amount - (1.5 * s.stddev_amount) THEN 'Low Outlier'
    ELSE 'Normal'
  END AS outlier_status
FROM sales_transactions t
JOIN store_stats s ON t.store_id = s.store_id
ORDER BY t.store_id, t.amount DESC;

-- Result (verified in SQLite):
-- transaction_id | store_id | amount | avg_amount | stddev_amount | outlier_status
-- 5 | 1 | 890 | 189.62333333333333 | 313.2252893507944 | High Outlier
-- 2 | 1 | 52.3 | 189.62333333333333 | 313.2252893507944 | Normal
-- 4 | 1 | 51.2 | 189.62333333333333 | 313.2252893507944 | Normal
-- 11 | 1 | 49.99 | 189.62333333333333 | 313.2252893507944 | Normal
-- 3 | 1 | 48.75 | 189.62333333333333 | 313.2252893507944 | Normal
-- 1 | 1 | 45.5 | 189.62333333333333 | 313.2252893507944 | Normal
-- 8 | 2 | 125.3 | 104.49166666666667 | 35.67821950745611 | Normal
-- 12 | 2 | 122.4 | 104.49166666666667 | 35.67821950745611 | Normal
-- 6 | 2 | 120 | 104.49166666666667 | 35.67821950745611 | Normal
-- 9 | 2 | 118.75 | 104.49166666666667 | 35.67821950745611 | Normal
-- 7 | 2 | 115.5 | 104.49166666666667 | 35.67821950745611 | Normal
-- 10 | 2 | 25 | 104.49166666666667 | 35.67821950745611 | Low Outlier
