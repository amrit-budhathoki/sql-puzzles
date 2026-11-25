-- Title: Customers who bought Product A but not Product B
-- Business Question: Identify all customers who have purchased Product A (e.g., Laptop)
-- but have never purchased Product B (e.g., Mouse) to target them with cross-sell campaigns.
-- Technique: LEFT JOIN with NULL check to find absence of a product in purchase history.

CREATE TABLE customers (
  customer_id INTEGER PRIMARY KEY,
  customer_name TEXT NOT NULL
);

CREATE TABLE products (
  product_id INTEGER PRIMARY KEY,
  product_name TEXT NOT NULL
);

CREATE TABLE orders (
  order_id INTEGER PRIMARY KEY,
  customer_id INTEGER NOT NULL,
  product_id INTEGER NOT NULL,
  order_date DATE NOT NULL,
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
  FOREIGN KEY (product_id) REFERENCES products(product_id)
);

INSERT INTO customers VALUES (1, 'Alice Johnson'), (2, 'Bob Smith'), (3, 'Carol White'), (4, 'David Brown'), (5, 'Eve Davis'), (6, 'Frank Miller');
INSERT INTO products VALUES (101, 'Laptop'), (102, 'Mouse'), (103, 'Keyboard'), (104, 'Monitor');
INSERT INTO orders VALUES (1, 1, 101, '2024-01-15'), (2, 1, 103, '2024-02-10'), (3, 2, 101, '2024-01-20'), (4, 2, 102, '2024-02-05'), (5, 3, 101, '2024-01-25'), (6, 4, 102, '2024-02-01'), (7, 4, 104, '2024-02-15'), (8, 5, 101, '2024-01-30'), (9, 5, 102, '2024-03-01'), (10, 6, 103, '2024-02-20');

SELECT DISTINCT c.customer_id, c.customer_name
FROM customers c
INNER JOIN orders o_a ON c.customer_id = o_a.customer_id
INNER JOIN products p_a ON o_a.product_id = p_a.product_id
LEFT JOIN orders o_b ON c.customer_id = o_b.customer_id
  AND o_b.product_id = (SELECT product_id FROM products WHERE product_name = 'Mouse')
WHERE p_a.product_name = 'Laptop'
  AND o_b.order_id IS NULL
ORDER BY c.customer_id;

-- Result (verified in SQLite):
-- customer_id | customer_name
-- 1 | Alice Johnson
-- 3 | Carol White
