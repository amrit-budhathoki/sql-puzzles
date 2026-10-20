-- Title: Monthly Subscription Revenue Growth Analysis
-- Business Question: What is the month-over-month revenue growth rate for each month?
-- Technique: Use LAG window function to compare current month revenue with previous month

CREATE TABLE subscription_revenue (
  revenue_id INTEGER PRIMARY KEY,
  revenue_month TEXT NOT NULL,
  total_revenue DECIMAL(10, 2) NOT NULL
);

INSERT INTO subscription_revenue (revenue_month, total_revenue) VALUES
('2024-01', 45000.00),
('2024-02', 52000.00),
('2024-03', 48500.00),
('2024-04', 61200.00),
('2024-05', 58900.00),
('2024-06', 67300.00),
('2024-07', 72100.00),
('2024-08', 69800.00);

SELECT
  revenue_month,
  total_revenue,
  LAG(total_revenue) OVER (ORDER BY revenue_month) AS previous_month_revenue,
  ROUND(total_revenue - LAG(total_revenue) OVER (ORDER BY revenue_month), 2) AS absolute_growth,
  CASE
    WHEN LAG(total_revenue) OVER (ORDER BY revenue_month) IS NULL THEN NULL
    ELSE ROUND(((total_revenue - LAG(total_revenue) OVER (ORDER BY revenue_month)) / LAG(total_revenue) OVER (ORDER BY revenue_month)) * 100, 2)
  END AS growth_rate_percent
FROM subscription_revenue
ORDER BY revenue_month;

-- Result (verified in SQLite):
-- revenue_month | total_revenue | previous_month_revenue | absolute_growth | growth_rate_percent
-- 2024-01 | 45000 | None | None | None
-- 2024-02 | 52000 | 45000 | 7000.0 | 0.0
-- 2024-03 | 48500 | 52000 | -3500.0 | 0.0
-- 2024-04 | 61200 | 48500 | 12700.0 | 0.0
-- 2024-05 | 58900 | 61200 | -2300.0 | 0.0
-- 2024-06 | 67300 | 58900 | 8400.0 | 0.0
-- 2024-07 | 72100 | 67300 | 4800.0 | 0.0
-- 2024-08 | 69800 | 72100 | -2300.0 | 0.0
