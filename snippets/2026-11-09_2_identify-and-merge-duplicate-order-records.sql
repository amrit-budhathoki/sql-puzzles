-- Title: Identify and Merge Duplicate Order Records
-- Business Question: Our order system has duplicate records for the same customer orders (same customer, order date, and total amount). Identify these duplicates and keep only the most recent record ID, removing all older duplicates.
-- Technique: Use window functions (ROW_NUMBER) to rank duplicate records and filter to keep only the latest entry per group.

CREATE TABLE orders (
  order_id INTEGER PRIMARY KEY,
  customer_id INTEGER,
  order_date DATE,
  total_amount DECIMAL(10, 2),
  created_at TIMESTAMP
);

INSERT INTO orders VALUES
(1, 101, '2024-01-15', 250.00, '2024-01-15 10:30:00'),
(2, 101, '2024-01-15', 250.00, '2024-01-15 10:35:00'),
(3, 101, '2024-01-15', 250.00, '2024-01-15 10:40:00'),
(4, 102, '2024-01-16', 180.50, '2024-01-16 14:20:00'),
(5, 102, '2024-01-16', 180.50, '2024-01-16 14:25:00'),
(6, 103, '2024-01-17', 420.75, '2024-01-17 09:15:00'),
(7, 104, '2024-01-18', 95.00, '2024-01-18 16:45:00'),
(8, 104, '2024-01-18', 95.00, '2024-01-18 16:50:00'),
(9, 104, '2024-01-18', 95.00, '2024-01-18 16:55:00'),
(10, 105, '2024-01-19', 310.25, '2024-01-19 11:10:00'),
(11, 105, '2024-01-20', 310.25, '2024-01-20 08:30:00');

WITH ranked_orders AS (
  SELECT
    order_id,
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id, order_date, total_amount ORDER BY created_at DESC) AS rn
  FROM orders
)
SELECT
  customer_id,
  order_date,
  total_amount,
  order_id AS kept_order_id,
  COUNT(*) OVER (PARTITION BY customer_id, order_date, total_amount) AS duplicate_count
FROM ranked_orders
WHERE rn = 1
ORDER BY customer_id, order_date;

-- Result (verified in SQLite):
-- customer_id | order_date | total_amount | kept_order_id | duplicate_count
-- 101 | 2024-01-15 | 250 | 3 | 1
-- 102 | 2024-01-16 | 180.5 | 5 | 1
-- 103 | 2024-01-17 | 420.75 | 6 | 1
-- 104 | 2024-01-18 | 95 | 9 | 1
-- 105 | 2024-01-19 | 310.25 | 10 | 1
-- 105 | 2024-01-20 | 310.25 | 11 | 1
