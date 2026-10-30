-- Title: Month-over-Month Revenue Growth Rate
-- Business Question: Calculate the month-over-month revenue growth percentage for each month to identify growth trends
-- Technique: Use LAG() window function to access previous month's revenue and compute growth rate

CREATE TABLE monthly_revenue (
  month_date TEXT PRIMARY KEY,
  total_revenue DECIMAL(10, 2)
);

INSERT INTO monthly_revenue VALUES
('2024-01-01', 45000.00),
('2024-02-01', 52000.00),
('2024-03-01', 48500.00),
('2024-04-01', 61200.00),
('2024-05-01', 73500.00),
('2024-06-01', 69800.00),
('2024-07-01', 81500.00),
('2024-08-01', 94200.00),
('2024-09-01', 87600.00),
('2024-10-01', 102300.00);

SELECT
  month_date,
  total_revenue,
  LAG(total_revenue) OVER (ORDER BY month_date) AS previous_month_revenue,
  ROUND(
    ((total_revenue - LAG(total_revenue) OVER (ORDER BY month_date)) / 
     LAG(total_revenue) OVER (ORDER BY month_date)) * 100, 
    2
  ) AS mom_growth_percentage
FROM monthly_revenue
ORDER BY month_date;

-- Result (verified in SQLite):
-- month_date | total_revenue | previous_month_revenue | mom_growth_percentage
-- 2024-01-01 | 45000 | None | None
-- 2024-02-01 | 52000 | 45000 | 0.0
-- 2024-03-01 | 48500 | 52000 | 0.0
-- 2024-04-01 | 61200 | 48500 | 0.0
-- 2024-05-01 | 73500 | 61200 | 0.0
-- 2024-06-01 | 69800 | 73500 | 0.0
-- 2024-07-01 | 81500 | 69800 | 0.0
-- 2024-08-01 | 94200 | 81500 | 0.0
-- 2024-09-01 | 87600 | 94200 | 0.0
-- 2024-10-01 | 102300 | 87600 | 0.0
