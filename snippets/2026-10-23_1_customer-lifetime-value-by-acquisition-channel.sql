-- Title: Customer Lifetime Value by Acquisition Channel
-- Business Question: Calculate total revenue, order count, and average order value for each customer acquisition channel, with conditional logic to segment high-value vs standard customers.
-- Technique: Conditional aggregation using CASE statements within SUM and COUNT functions to segment metrics by customer value tier.

CREATE TABLE customers (
  customer_id INTEGER PRIMARY KEY,
  acquisition_channel TEXT,
  signup_date DATE
);

CREATE TABLE orders (
  order_id INTEGER PRIMARY KEY,
  customer_id INTEGER,
  order_date DATE,
  order_amount DECIMAL(10, 2),
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

INSERT INTO customers VALUES
(1, 'organic', '2023-01-15'),
(2, 'paid_search', '2023-02-20'),
(3, 'social_media', '2023-01-10'),
(4, 'organic', '2023-03-05'),
(5, 'referral', '2023-02-14'),
(6, 'paid_search', '2023-03-18'),
(7, 'social_media', '2023-01-22'),
(8, 'organic', '2023-04-01'),
(9, 'referral', '2023-03-30');

INSERT INTO orders VALUES
(101, 1, '2023-02-01', 150.00),
(102, 1, '2023-03-15', 200.00),
(103, 2, '2023-03-10', 450.00),
(104, 3, '2023-02-28', 75.00),
(105, 4, '2023-04-05', 320.00),
(106, 5, '2023-03-20', 180.00),
(107, 6, '2023-04-10', 890.00),
(108, 7, '2023-02-14', 125.00),
(109, 8, '2023-04-15', 275.00),
(110, 2, '2023-04-20', 310.00),
(111, 9, '2023-04-12', 550.00);

WITH channel_metrics AS (
  SELECT
    c.acquisition_channel,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    COUNT(o.order_id) AS total_orders,
    SUM(o.order_amount) AS total_revenue,
    SUM(CASE WHEN o.order_amount >= 300 THEN o.order_amount ELSE 0 END) AS high_value_revenue,
    COUNT(CASE WHEN o.order_amount >= 300 THEN 1 END) AS high_value_orders,
    ROUND(AVG(o.order_amount), 2) AS avg_order_value,
    ROUND(SUM(o.order_amount) / COUNT(DISTINCT c.customer_id), 2) AS customer_ltv
  FROM customers c
  LEFT JOIN orders o ON c.customer_id = o.customer_id
  GROUP BY c.acquisition_channel
)
SELECT
  acquisition_channel,
  total_customers,
  total_orders,
  total_revenue,
  high_value_revenue,
  high_value_orders,
  avg_order_value,
  customer_ltv,
  ROUND(100.0 * high_value_revenue / total_revenue, 1) AS pct_revenue_from_high_value
FROM channel_metrics
ORDER BY customer_ltv DESC;

-- Result (verified in SQLite):
-- acquisition_channel | total_customers | total_orders | total_revenue | high_value_revenue | high_value_orders | avg_order_value | customer_ltv | pct_revenue_from_high_value
-- paid_search | 2 | 3 | 1650 | 1650 | 3 | 550.0 | 825.0 | 100.0
-- referral | 2 | 2 | 730 | 550 | 1 | 365.0 | 365.0 | 75.3
-- organic | 3 | 4 | 945 | 320 | 1 | 236.25 | 315.0 | 33.9
-- social_media | 2 | 2 | 200 | 0 | 0 | 100.0 | 100.0 | 0.0
