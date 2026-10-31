-- Title: Marketing Channel Budget Allocation by Quarter
-- Business Question: What percentage of total marketing spend does each channel represent in each quarter?
-- Technique: Window functions to calculate percent of total using SUM() OVER (PARTITION BY quarter)

CREATE TABLE marketing_spend (
  spend_id INTEGER PRIMARY KEY,
  quarter TEXT NOT NULL,
  channel TEXT NOT NULL,
  amount DECIMAL(10, 2) NOT NULL
);

INSERT INTO marketing_spend (quarter, channel, amount) VALUES
('Q1 2024', 'Email', 5000),
('Q1 2024', 'Social Media', 12000),
('Q1 2024', 'Search Ads', 8000),
('Q1 2024', 'Display', 3000),
('Q2 2024', 'Email', 6000),
('Q2 2024', 'Social Media', 15000),
('Q2 2024', 'Search Ads', 9000),
('Q2 2024', 'Display', 4500),
('Q3 2024', 'Email', 7000),
('Q3 2024', 'Social Media', 18000),
('Q3 2024', 'Search Ads', 11000),
('Q3 2024', 'Display', 5000);

SELECT
  quarter,
  channel,
  amount,
  ROUND(SUM(amount) OVER (PARTITION BY quarter), 2) AS quarter_total,
  ROUND(amount * 100.0 / SUM(amount) OVER (PARTITION BY quarter), 2) AS percent_of_quarter
FROM marketing_spend
ORDER BY quarter, percent_of_quarter DESC;

-- Result (verified in SQLite):
-- quarter | channel | amount | quarter_total | percent_of_quarter
-- Q1 2024 | Social Media | 12000 | 28000.0 | 42.86
-- Q1 2024 | Search Ads | 8000 | 28000.0 | 28.57
-- Q1 2024 | Email | 5000 | 28000.0 | 17.86
-- Q1 2024 | Display | 3000 | 28000.0 | 10.71
-- Q2 2024 | Social Media | 15000 | 34500.0 | 43.48
-- Q2 2024 | Search Ads | 9000 | 34500.0 | 26.09
-- Q2 2024 | Email | 6000 | 34500.0 | 17.39
-- Q2 2024 | Display | 4500 | 34500.0 | 13.04
-- Q3 2024 | Social Media | 18000 | 41000.0 | 43.9
-- Q3 2024 | Search Ads | 11000 | 41000.0 | 26.83
-- Q3 2024 | Email | 7000 | 41000.0 | 17.07
-- Q3 2024 | Display | 5000 | 41000.0 | 12.2
