-- Title: Product Affinity Gap Analysis
-- Business Question: Which customers purchased Product A but have never purchased Product B?
-- Technique: LEFT JOIN with NULL filter to identify missing product purchases

CREATE TABLE customers (
  customer_id INTEGER PRIMARY KEY,
  customer_name TEXT NOT NULL
);

CREATE TABLE orders (
  order_id INTEGER PRIMARY KEY,
  customer_id INTEGER NOT NULL,
  product_id INTEGER NOT NULL,
  order_date DATE NOT NULL,
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE products (
  product_id INTEGER PRIMARY KEY,
  product_name TEXT NOT NULL
);

INSERT INTO customers VALUES (1, 'Alice Johnson'), (2, 'Bob Smith'), (3, 'Carol White'), (4, 'Diana Prince'), (5, 'Eve Davis'), (6, 'Frank Miller');
INSERT INTO products VALUES (101, 'Product A'), (102, 'Product B'), (103, 'Product C');
INSERT INTO orders VALUES (1001, 1, 101, '2024-01-10'), (1002, 1, 102, '2024-01-20'), (1003, 2, 101, '2024-01-15'), (1004, 3, 101, '2024-02-01'), (1005, 3, 103, '2024-02-10'), (1006, 4, 102, '2024-02-05'), (1007, 5, 101, '2024-02-15'), (1008, 5, 103, '2024-02-20'), (1009, 6, 101, '2024-03-01'), (1010, 6, 102, '2024-03-05');

SELECT DISTINCT c.customer_id, c.customer_name
FROM customers c
INNER JOIN orders o_a ON c.customer_id = o_a.customer_id AND o_a.product_id = 101
LEFT JOIN orders o_b ON c.customer_id = o_b.customer_id AND o_b.product_id = 102
WHERE o_b.order_id IS NULL
ORDER BY c.customer_id;

-- Result (verified in SQLite):
-- customer_id | customer_name
-- 2 | Bob Smith
-- 3 | Carol White
-- 5 | Eve Davis
