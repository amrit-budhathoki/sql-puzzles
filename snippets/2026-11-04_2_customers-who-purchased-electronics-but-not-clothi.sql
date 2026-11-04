-- Title: Customers Who Purchased Electronics But Not Clothing

-- Business Question:
-- Identify customers who have purchased products from the Electronics category
-- but have never purchased anything from the Clothing category.
-- This helps target marketing campaigns for specific product categories.

-- Technique Used:
-- Set difference using LEFT JOIN with NULL check to find purchases in one
-- category without corresponding purchases in another category.

CREATE TABLE customers (
  customer_id INTEGER PRIMARY KEY,
  customer_name TEXT NOT NULL
);

CREATE TABLE products (
  product_id INTEGER PRIMARY KEY,
  product_name TEXT NOT NULL,
  category TEXT NOT NULL
);

CREATE TABLE orders (
  order_id INTEGER PRIMARY KEY,
  customer_id INTEGER NOT NULL,
  product_id INTEGER NOT NULL,
  order_date DATE NOT NULL,
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
  FOREIGN KEY (product_id) REFERENCES products(product_id)
);

INSERT INTO customers (customer_id, customer_name) VALUES
(1, 'Alice Johnson'),
(2, 'Bob Smith'),
(3, 'Carol White'),
(4, 'David Brown'),
(5, 'Eve Davis'),
(6, 'Frank Miller');

INSERT INTO products (product_id, product_name, category) VALUES
(101, 'Laptop', 'Electronics'),
(102, 'Monitor', 'Electronics'),
(103, 'T-Shirt', 'Clothing'),
(104, 'Jeans', 'Clothing'),
(105, 'Wireless Mouse', 'Electronics'),
(106, 'Sweater', 'Clothing');

INSERT INTO orders (order_id, customer_id, product_id, order_date) VALUES
(1001, 1, 101, '2024-01-15'),
(1002, 1, 103, '2024-02-10'),
(1003, 2, 102, '2024-01-20'),
(1004, 3, 101, '2024-01-25'),
(1005, 3, 104, '2024-03-05'),
(1006, 4, 105, '2024-02-14'),
(1007, 5, 103, '2024-03-10'),
(1008, 5, 106, '2024-03-15'),
(1009, 6, 102, '2024-01-30'),
(1010, 6, 105, '2024-02-28');

SELECT DISTINCT c.customer_id, c.customer_name
FROM customers c
INNER JOIN orders o_elec ON c.customer_id = o_elec.customer_id
INNER JOIN products p_elec ON o_elec.product_id = p_elec.product_id
  AND p_elec.category = 'Electronics'
LEFT JOIN (
  SELECT DISTINCT customer_id
  FROM orders
  INNER JOIN products ON orders.product_id = products.product_id
  WHERE products.category = 'Clothing'
) clothing_buyers ON c.customer_id = clothing_buyers.customer_id
WHERE clothing_buyers.customer_id IS NULL
ORDER BY c.customer_id;

-- Result (verified in SQLite):
-- customer_id | customer_name
-- 2 | Bob Smith
-- 4 | David Brown
-- 6 | Frank Miller
