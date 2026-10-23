-- Title: First and Last Purchase Per Customer
-- Business Question: For each customer, identify their first and last purchase dates along with order details
-- Technique: Window functions (FIRST_VALUE, LAST_VALUE) partitioned by customer_id ordered by purchase_date

CREATE TABLE customers (
  customer_id INTEGER PRIMARY KEY,
  customer_name TEXT NOT NULL
);

CREATE TABLE orders (
  order_id INTEGER PRIMARY KEY,
  customer_id INTEGER NOT NULL,
  purchase_date DATE NOT NULL,
  order_amount DECIMAL(10, 2) NOT NULL,
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

INSERT INTO customers VALUES (1, 'Alice Johnson');
INSERT INTO customers VALUES (2, 'Bob Smith');
INSERT INTO customers VALUES (3, 'Carol White');
INSERT INTO customers VALUES (4, 'David Brown');

INSERT INTO orders VALUES (101, 1, '2024-01-15', 150.00);
INSERT INTO orders VALUES (102, 1, '2024-03-10', 275.50);
INSERT INTO orders VALUES (103, 1, '2024-05-20', 89.99);
INSERT INTO orders VALUES (104, 2, '2024-02-05', 320.00);
INSERT INTO orders VALUES (105, 2, '2024-06-15', 145.75);
INSERT INTO orders VALUES (106, 3, '2024-01-20', 210.00);
INSERT INTO orders VALUES (107, 4, '2024-04-01', 95.50);
INSERT INTO orders VALUES (108, 4, '2024-04-15', 180.25);
INSERT INTO orders VALUES (109, 4, '2024-07-10', 220.00);
INSERT INTO orders VALUES (110, 3, '2024-07-25', 165.00);

WITH customer_purchase_window AS (
  SELECT
    customer_id,
    order_id,
    purchase_date,
    order_amount,
    FIRST_VALUE(purchase_date) OVER (PARTITION BY customer_id ORDER BY purchase_date) AS first_purchase_date,
    FIRST_VALUE(order_amount) OVER (PARTITION BY customer_id ORDER BY purchase_date) AS first_purchase_amount,
    LAST_VALUE(purchase_date) OVER (PARTITION BY customer_id ORDER BY purchase_date ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS last_purchase_date,
    LAST_VALUE(order_amount) OVER (PARTITION BY customer_id ORDER BY purchase_date ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS last_purchase_amount
  FROM orders
)
SELECT
  c.customer_id,
  c.customer_name,
  cpw.first_purchase_date,
  cpw.first_purchase_amount,
  cpw.last_purchase_date,
  cpw.last_purchase_amount,
  CAST((julianday(cpw.last_purchase_date) - julianday(cpw.first_purchase_date)) AS INTEGER) AS days_between_first_and_last
FROM customer_purchase_window cpw
JOIN customers c ON cpw.customer_id = c.customer_id
WHERE cpw.purchase_date = cpw.first_purchase_date OR cpw.purchase_date = cpw.last_purchase_date
ORDER BY c.customer_id, cpw.purchase_date;

-- Result (verified in SQLite):
-- customer_id | customer_name | first_purchase_date | first_purchase_amount | last_purchase_date | last_purchase_amount | days_between_first_and_last
-- 1 | Alice Johnson | 2024-01-15 | 150 | 2024-05-20 | 89.99 | 126
-- 1 | Alice Johnson | 2024-01-15 | 150 | 2024-05-20 | 89.99 | 126
-- 2 | Bob Smith | 2024-02-05 | 320 | 2024-06-15 | 145.75 | 131
-- 2 | Bob Smith | 2024-02-05 | 320 | 2024-06-15 | 145.75 | 131
-- 3 | Carol White | 2024-01-20 | 210 | 2024-07-25 | 165 | 187
-- 3 | Carol White | 2024-01-20 | 210 | 2024-07-25 | 165 | 187
-- 4 | David Brown | 2024-04-01 | 95.5 | 2024-07-10 | 220 | 100
-- 4 | David Brown | 2024-04-01 | 95.5 | 2024-07-10 | 220 | 100
