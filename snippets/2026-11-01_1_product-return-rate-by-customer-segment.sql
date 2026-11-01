-- Title: Product Return Rate by Customer Segment
-- Business Question: What is the return rate (percentage of returned orders) for each customer segment?
-- Technique: GROUP BY with conditional aggregation to calculate return rates per segment

CREATE TABLE customers (
  customer_id INTEGER PRIMARY KEY,
  segment TEXT NOT NULL
);

CREATE TABLE orders (
  order_id INTEGER PRIMARY KEY,
  customer_id INTEGER NOT NULL,
  order_date DATE NOT NULL,
  is_returned INTEGER NOT NULL,
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

INSERT INTO customers VALUES (1, 'Premium');
INSERT INTO customers VALUES (2, 'Standard');
INSERT INTO customers VALUES (3, 'Premium');
INSERT INTO customers VALUES (4, 'Budget');
INSERT INTO customers VALUES (5, 'Standard');
INSERT INTO customers VALUES (6, 'Budget');

INSERT INTO orders VALUES (101, 1, '2024-01-05', 0);
INSERT INTO orders VALUES (102, 1, '2024-01-10', 1);
INSERT INTO orders VALUES (103, 2, '2024-01-08', 0);
INSERT INTO orders VALUES (104, 2, '2024-01-12', 0);
INSERT INTO orders VALUES (105, 3, '2024-01-15', 1);
INSERT INTO orders VALUES (106, 4, '2024-01-20', 1);
INSERT INTO orders VALUES (107, 4, '2024-01-22', 1);
INSERT INTO orders VALUES (108, 5, '2024-01-25', 0);
INSERT INTO orders VALUES (109, 5, '2024-01-28', 0);
INSERT INTO orders VALUES (110, 6, '2024-02-01', 0);

SELECT
  c.segment,
  COUNT(o.order_id) AS total_orders,
  SUM(o.is_returned) AS returned_orders,
  ROUND(100.0 * SUM(o.is_returned) / COUNT(o.order_id), 2) AS return_rate_percent
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.segment
ORDER BY return_rate_percent DESC;

-- Result (verified in SQLite):
-- segment | total_orders | returned_orders | return_rate_percent
-- Premium | 3 | 2 | 66.67
-- Budget | 3 | 2 | 66.67
-- Standard | 4 | 0 | 0.0
