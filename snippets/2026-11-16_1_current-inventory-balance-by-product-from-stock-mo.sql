-- Title: Current Inventory Balance by Product from Stock Movements

-- Business Question: What is the current stock balance for each product after all stock movements (receipts and issues)?
-- Technique: SUM aggregate to calculate net movement; CASE to classify movement types; GROUP BY product

CREATE TABLE products (
  product_id INTEGER PRIMARY KEY,
  product_name TEXT NOT NULL
);

CREATE TABLE stock_movements (
  movement_id INTEGER PRIMARY KEY,
  product_id INTEGER NOT NULL,
  movement_type TEXT NOT NULL,
  quantity INTEGER NOT NULL,
  movement_date DATE NOT NULL,
  FOREIGN KEY (product_id) REFERENCES products(product_id)
);

INSERT INTO products VALUES (1, 'Widget A'), (2, 'Widget B'), (3, 'Gadget X'), (4, 'Gadget Y');

INSERT INTO stock_movements VALUES
(101, 1, 'RECEIPT', 100, '2024-01-05'),
(102, 1, 'ISSUE', 25, '2024-01-10'),
(103, 1, 'ISSUE', 15, '2024-01-15'),
(104, 2, 'RECEIPT', 50, '2024-01-06'),
(105, 2, 'RECEIPT', 30, '2024-01-12'),
(106, 2, 'ISSUE', 40, '2024-01-18'),
(107, 3, 'RECEIPT', 200, '2024-01-03'),
(108, 3, 'ISSUE', 60, '2024-01-09'),
(109, 3, 'ISSUE', 50, '2024-01-20'),
(110, 4, 'RECEIPT', 75, '2024-01-08'),
(111, 4, 'ISSUE', 10, '2024-01-14');

SELECT
  p.product_id,
  p.product_name,
  SUM(CASE WHEN sm.movement_type = 'RECEIPT' THEN sm.quantity ELSE 0 END) AS total_received,
  SUM(CASE WHEN sm.movement_type = 'ISSUE' THEN sm.quantity ELSE 0 END) AS total_issued,
  SUM(CASE WHEN sm.movement_type = 'RECEIPT' THEN sm.quantity ELSE -sm.quantity END) AS current_balance
FROM products p
LEFT JOIN stock_movements sm ON p.product_id = sm.product_id
GROUP BY p.product_id, p.product_name
ORDER BY p.product_id;

-- Result (verified in SQLite):
-- product_id | product_name | total_received | total_issued | current_balance
-- 1 | Widget A | 100 | 40 | 60
-- 2 | Widget B | 80 | 40 | 40
-- 3 | Gadget X | 200 | 110 | 90
-- 4 | Gadget Y | 75 | 10 | 65
