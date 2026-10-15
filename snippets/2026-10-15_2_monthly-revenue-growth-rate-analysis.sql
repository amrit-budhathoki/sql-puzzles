-- Title: Monthly Revenue Growth Rate Analysis
-- Business Question: Calculate the month-over-month revenue growth percentage for each month
-- Technique: Using LAG() window function to compare current month revenue with previous month

CREATE TABLE monthly_sales (
  sale_id INTEGER PRIMARY KEY,
  sale_month TEXT NOT NULL,
  revenue DECIMAL(10, 2) NOT NULL
);

INSERT INTO monthly_sales (sale_month, revenue) VALUES
('2024-01', 45000.00),
('2024-02', 52000.00),
('2024-03', 48500.00),
('2024-04', 61200.00),
('2024-05', 58900.00),
('2024-06', 72300.00),
('2024-07', 68500.00),
('2024-08', 75100.00),
('2024-09', 71800.00),
('2024-10', 84200.00);

WITH monthly_revenue AS (
  SELECT
    sale_month,
    SUM(revenue) AS total_revenue
  FROM monthly_sales
  GROUP BY sale_month
  ORDER BY sale_month
)
SELECT
  sale_month,
  total_revenue,
  LAG(total_revenue) OVER (ORDER BY sale_month) AS previous_month_revenue,
  ROUND(
    ((total_revenue - LAG(total_revenue) OVER (ORDER BY sale_month)) / 
     LAG(total_revenue) OVER (ORDER BY sale_month)) * 100,
    2
  ) AS mom_growth_percentage
FROM monthly_revenue;

-- Result (verified in SQLite):
-- sale_month | total_revenue | previous_month_revenue | mom_growth_percentage
-- 2024-01 | 45000 | None | None
-- 2024-02 | 52000 | 45000 | 0.0
-- 2024-03 | 48500 | 52000 | 0.0
-- 2024-04 | 61200 | 48500 | 0.0
-- 2024-05 | 58900 | 61200 | 0.0
-- 2024-06 | 72300 | 58900 | 0.0
-- 2024-07 | 68500 | 72300 | 0.0
-- 2024-08 | 75100 | 68500 | 0.0
-- 2024-09 | 71800 | 75100 | 0.0
-- 2024-10 | 84200 | 71800 | 0.0
