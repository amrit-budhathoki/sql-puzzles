-- Title: Customer Account Balance Running Total

-- Business Question: Track the cumulative account balance for each customer as transactions occur over time.
-- We need to show each transaction with its running total balance for the account.
-- Technique: Window function SUM() OVER (PARTITION BY ... ORDER BY ...) to compute running totals.

CREATE TABLE transactions (
  transaction_id INTEGER PRIMARY KEY,
  customer_id INTEGER,
  transaction_date DATE,
  amount DECIMAL(10, 2)
);

INSERT INTO transactions (customer_id, transaction_date, amount) VALUES
(101, '2024-01-05', 500.00),
(101, '2024-01-12', -150.00),
(101, '2024-01-20', 300.00),
(102, '2024-01-08', 1000.00),
(102, '2024-01-15', -200.00),
(102, '2024-01-25', 450.00),
(102, '2024-02-02', -100.00),
(103, '2024-01-10', 750.00),
(103, '2024-01-28', 250.00),
(101, '2024-02-05', 200.00),
(103, '2024-02-10', -300.00);

SELECT
  customer_id,
  transaction_date,
  amount,
  SUM(amount) OVER (PARTITION BY customer_id ORDER BY transaction_date, transaction_id) AS running_balance
FROM transactions
ORDER BY customer_id, transaction_date, transaction_id;

-- Result (verified in SQLite):
-- customer_id | transaction_date | amount | running_balance
-- 101 | 2024-01-05 | 500 | 500
-- 101 | 2024-01-12 | -150 | 350
-- 101 | 2024-01-20 | 300 | 650
-- 101 | 2024-02-05 | 200 | 850
-- 102 | 2024-01-08 | 1000 | 1000
-- 102 | 2024-01-15 | -200 | 800
-- 102 | 2024-01-25 | 450 | 1250
-- 102 | 2024-02-02 | -100 | 1150
-- 103 | 2024-01-10 | 750 | 750
-- 103 | 2024-01-28 | 250 | 1000
-- 103 | 2024-02-10 | -300 | 700
