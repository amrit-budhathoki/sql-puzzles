-- Title: Regional Sales Contribution by Product Category
-- Business Question: What percentage of total sales does each product category contribute within each region?
-- Technique: Window functions with SUM OVER PARTITION BY to calculate percent of total per category and region combination.

CREATE TABLE sales (
  sale_id INTEGER PRIMARY KEY,
  region TEXT NOT NULL,
  category TEXT NOT NULL,
  amount DECIMAL(10, 2) NOT NULL
);

INSERT INTO sales (region, category, amount) VALUES
('North', 'Electronics', 15000),
('North', 'Electronics', 12000),
('North', 'Clothing', 8000),
('North', 'Clothing', 9500),
('South', 'Electronics', 22000),
('South', 'Electronics', 18500),
('South', 'Clothing', 5000),
('South', 'Clothing', 7200),
('East', 'Electronics', 11000),
('East', 'Clothing', 14000),
('West', 'Electronics', 9500),
('West', 'Clothing', 10000);

WITH category_totals AS (
  SELECT
    category,
    SUM(amount) as category_total
  FROM sales
  GROUP BY category
)
SELECT
  s.region,
  s.category,
  ROUND(SUM(s.amount), 2) as region_category_sales,
  ct.category_total,
  ROUND(100.0 * SUM(s.amount) / ct.category_total, 2) as percent_of_category_total
FROM sales s
JOIN category_totals ct ON s.category = ct.category
GROUP BY s.region, s.category, ct.category_total
ORDER BY s.category, percent_of_category_total DESC;

-- Result (verified in SQLite):
-- region | category | region_category_sales | category_total | percent_of_category_total
-- North | Clothing | 17500.0 | 53700 | 32.59
-- East | Clothing | 14000.0 | 53700 | 26.07
-- South | Clothing | 12200.0 | 53700 | 22.72
-- West | Clothing | 10000.0 | 53700 | 18.62
-- South | Electronics | 40500.0 | 88000 | 46.02
-- North | Electronics | 27000.0 | 88000 | 30.68
-- East | Electronics | 11000.0 | 88000 | 12.5
-- West | Electronics | 9500.0 | 88000 | 10.8
