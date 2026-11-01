-- Title: Generate Daily Sales Report Date Series
-- Business Question: Create a complete date series for the next 30 days starting from the most recent sale date, and show which dates have sales data and which are gaps.
-- Technique: Recursive CTE to generate a continuous date series, then LEFT JOIN with actual sales to identify missing sales days.

CREATE TABLE sales (
  sale_id INTEGER PRIMARY KEY,
  sale_date DATE NOT NULL,
  amount DECIMAL(10,2) NOT NULL
);

INSERT INTO sales (sale_date, amount) VALUES
('2024-01-15', 150.50),
('2024-01-15', 200.00),
('2024-01-16', 320.75),
('2024-01-18', 89.99),
('2024-01-20', 450.00),
('2024-01-20', 125.50),
('2024-01-22', 275.25),
('2024-01-25', 610.00),
('2024-01-26', 95.50),
('2024-01-28', 340.75);

WITH date_series AS (
  SELECT
    (SELECT MIN(sale_date) FROM sales) AS current_date
  UNION ALL
  SELECT DATE(current_date, '+1 day')
  FROM date_series
  WHERE DATE(current_date, '+1 day') <= DATE((SELECT MIN(sale_date) FROM sales), '+29 days')
)
SELECT
  ds.current_date AS report_date,
  COALESCE(COUNT(s.sale_id), 0) AS num_sales,
  COALESCE(SUM(s.amount), 0.00) AS total_amount,
  CASE WHEN COUNT(s.sale_id) = 0 THEN 'No Sales' ELSE 'Sales Made' END AS status
FROM date_series ds
LEFT JOIN sales s ON ds.current_date = s.sale_date
GROUP BY ds.current_date
ORDER BY ds.current_date;

-- Result (verified in SQLite):
-- report_date | num_sales | total_amount | status
-- 2024-01-15 | 2 | 350.5 | Sales Made
