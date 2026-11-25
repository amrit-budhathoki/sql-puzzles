-- Title: Customers Who Bought Product A But Not Product B

-- Business Question: Identify all customers who have purchased Product A (Widget Pro)
-- but have never purchased Product B (Service Plan) in their entire purchase history.
-- This helps identify upsell opportunities for customers already committed to the main product.

-- Technique: LEFT JOIN with NULL filtering to find customers in one table but absent in another.

CREATE TABLE customers (
  customer_id INTEGER PRIMARY KEY,
  customer_name TEXT NOT NULL,
  registration_date DATE
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

INSERT INTO customers VALUES (1, 'Alice Johnson', '2022-01-15');
INSERT INTO customers VALUES (2, 'Bob Smith', '2022-03-20');
INSERT INTO customers VALUES (3, 'Carol White', '2022-06-10');
INSERT INTO customers VALUES (4, 'Diana Brown', '2022-07-25');
INSERT INTO customers VALUES (5, 'Eve Davis', '2022-09-05');
INSERT INTO customers VALUES (6, 'Frank Wilson', '2022-11-12');

INSERT INTO products VALUES (101, 'Widget Pro');
INSERT INTO products VALUES (102, 'Service Plan');
INSERT INTO products VALUES (103, 'Premium Support');

INSERT INTO orders VALUES (1001, 1, 101, '2023-01-10');
INSERT INTO orders VALUES (1002, 1, 102, '2023-02-15');
INSERT INTO orders VALUES (1003, 2, 101, '2023-03-05');
INSERT INTO orders VALUES (1004, 3, 101, '2023-04-12');
INSERT INTO orders VALUES (1005, 3, 102, '2023-05-20');
INSERT INTO orders VALUES (1006, 4, 101, '2023-06-18');
INSERT INTO orders VALUES (1007, 5, 101, '2023-07-22');
INSERT INTO orders VALUES (1008, 5, 103, '2023-08-10');
INSERT INTO orders VALUES (1009, 6, 102, '2023-09-30');

SELECT DISTINCT c.customer_id, c.customer_name
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
INNER JOIN products p ON o.product_id = p.product_id
WHERE p.product_name = 'Widget Pro'
AND c.customer_id NOT IN (
  SELECT DISTINCT o2.customer_id
  FROM orders o2
  INNER JOIN products p2 ON o2.product_id = p2.product_id
  WHERE p2.product_name = 'Service Plan'
)
ORDER BY c.customer_id;

-- Result (verified in SQLite):
-- customer_id | customer_name
-- 2 | Bob Smith
-- 4 | Diana Brown
-- 5 | Eve Davis
