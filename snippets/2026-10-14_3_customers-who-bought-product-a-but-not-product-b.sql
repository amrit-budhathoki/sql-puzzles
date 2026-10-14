-- Title: Customers Who Bought Product A But Not Product B
-- Business Question: Identify which customers have purchased Product A but have never purchased Product B
-- Technique: Set difference using LEFT JOIN with NULL check to find rows in one table but not another

CREATE TABLE customers (
  customer_id INTEGER PRIMARY KEY,
  customer_name TEXT NOT NULL,
  email TEXT NOT NULL
);

CREATE TABLE purchases (
  purchase_id INTEGER PRIMARY KEY,
  customer_id INTEGER NOT NULL,
  product_id INTEGER NOT NULL,
  purchase_date DATE NOT NULL,
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE products (
  product_id INTEGER PRIMARY KEY,
  product_name TEXT NOT NULL
);

INSERT INTO customers VALUES
(1, 'Alice Johnson', 'alice@example.com'),
(2, 'Bob Smith', 'bob@example.com'),
(3, 'Charlie Brown', 'charlie@example.com'),
(4, 'Diana Prince', 'diana@example.com'),
(5, 'Eve Wilson', 'eve@example.com'),
(6, 'Frank Castle', 'frank@example.com');

INSERT INTO products VALUES
(101, 'Product A'),
(102, 'Product B'),
(103, 'Product C');

INSERT INTO purchases VALUES
(1, 1, 101, '2024-01-15'),
(2, 1, 102, '2024-02-01'),
(3, 2, 101, '2024-01-20'),
(4, 3, 101, '2024-01-25'),
(5, 3, 103, '2024-03-10'),
(6, 4, 102, '2024-02-05'),
(7, 4, 103, '2024-02-15'),
(8, 5, 101, '2024-01-30'),
(9, 5, 102, '2024-03-05'),
(10, 6, 103, '2024-02-20');

SELECT DISTINCT c.customer_id, c.customer_name, c.email
FROM customers c
INNER JOIN purchases p_a ON c.customer_id = p_a.customer_id AND p_a.product_id = 101
LEFT JOIN purchases p_b ON c.customer_id = p_b.customer_id AND p_b.product_id = 102
WHERE p_b.purchase_id IS NULL
ORDER BY c.customer_id;

-- Result (verified in SQLite):
-- customer_id | customer_name | email
-- 2 | Bob Smith | bob@example.com
-- 3 | Charlie Brown | charlie@example.com
