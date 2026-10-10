-- Title: Inventory Balance from Stock Movements
-- Business Question: What is the current inventory balance for each product after applying all stock movements (inbound and outbound)?
-- Technique: Window functions and aggregation to calculate running balance from movement transactions

CREATE TABLE products (
  product_id INTEGER PRIMARY KEY,
  product_name TEXT NOT NULL
);

CREATE TABLE stock_movements (
  movement_id INTEGER PRIMARY KEY,
  product_id INTEGER NOT NULL,
  movement_date DATE NOT NULL,
  quantity INTEGER NOT NULL,
  movement_type TEXT NOT NULL,
  FOREIGN KEY (product_id) REFERENCES products(product_id)
);

INSERT INTO products VALUES
(1, 'Widget A'),
(2, 'Widget B'),
(3, 'Gadget X');

INSERT INTO stock_movements VALUES
(1, 1, '2024-01-05', 100, 'inbound'),
(2, 1, '2024-01-10', 30, 'outbound'),
(3, 1, '2024-01-15', 50, 'inbound'),
(4, 1, '2024-01-20', 25, 'outbound'),
(5, 2, '2024-01-08', 200, 'inbound'),
(6, 2, '2024-01-12', 75, 'outbound'),
(7, 2, '2024-01-18', 100, 'inbound'),
(8, 3, '2024-01-06', 150, 'inbound'),
(9, 3, '2024-01-14', 40, 'outbound'),
(10, 3, '2024-01-19', 60, 'outbound'),
(11, 1, '2024-01-22', 15, 'inbound'),
(12, 2, '2024-01-21', 50, 'outbound');

WITH signed_movements AS (
  SELECT
    product_id,
    quantity * CASE WHEN movement_type = 'inbound' THEN 1 ELSE -1 END AS signed_qty
  FROM stock_movements
)
SELECT
  p.product_id,
  p.product_name,
  COALESCE(SUM(sm.signed_qty), 0) AS current_balance
FROM products p
LEFT JOIN signed_movements sm ON p.product_id = sm.product_id
GROUP BY p.product_id, p.product_name
ORDER BY p.product_id;

-- Result (verified in SQLite):
-- product_id | product_name | current_balance
-- 1 | Widget A | 110
-- 2 | Widget B | 175
-- 3 | Gadget X | 50
