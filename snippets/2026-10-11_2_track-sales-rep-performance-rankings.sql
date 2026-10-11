-- Title: Track Sales Rep Performance Rankings

-- Business Question: Rank sales representatives by their total sales amount within each region,
-- showing different ranking methods (ROW_NUMBER, RANK, DENSE_RANK) to understand performance tiers.
-- Technique: Use ROW_NUMBER, RANK, and DENSE_RANK window functions partitioned by region
-- and ordered by total sales to identify top performers and handle tied sales scenarios.

CREATE TABLE sales_reps (
  rep_id INTEGER PRIMARY KEY,
  rep_name TEXT NOT NULL,
  region TEXT NOT NULL,
  total_sales DECIMAL(10, 2) NOT NULL
);

INSERT INTO sales_reps (rep_id, rep_name, region, total_sales) VALUES
(1, 'Alice Johnson', 'North', 45000.00),
(2, 'Bob Smith', 'North', 38000.00),
(3, 'Carol White', 'North', 45000.00),
(4, 'David Brown', 'North', 32000.00),
(5, 'Emma Davis', 'South', 52000.00),
(6, 'Frank Wilson', 'South', 48000.00),
(7, 'Grace Lee', 'South', 48000.00),
(8, 'Henry Taylor', 'South', 41000.00),
(9, 'Iris Martinez', 'East', 55000.00),
(10, 'Jack Anderson', 'East', 50000.00),
(11, 'Karen Thomas', 'East', 50000.00),
(12, 'Leo Jackson', 'East', 39000.00);

SELECT
  region,
  rep_name,
  total_sales,
  ROW_NUMBER() OVER (PARTITION BY region ORDER BY total_sales DESC) AS row_rank,
  RANK() OVER (PARTITION BY region ORDER BY total_sales DESC) AS rank_with_gaps,
  DENSE_RANK() OVER (PARTITION BY region ORDER BY total_sales DESC) AS dense_rank_no_gaps
FROM sales_reps
ORDER BY region, total_sales DESC;

-- Result (verified in SQLite):
-- region | rep_name | total_sales | row_rank | rank_with_gaps | dense_rank_no_gaps
-- East | Iris Martinez | 55000 | 1 | 1 | 1
-- East | Jack Anderson | 50000 | 2 | 2 | 2
-- East | Karen Thomas | 50000 | 3 | 2 | 2
-- East | Leo Jackson | 39000 | 4 | 4 | 3
-- North | Alice Johnson | 45000 | 1 | 1 | 1
-- North | Carol White | 45000 | 2 | 1 | 1
-- North | Bob Smith | 38000 | 3 | 3 | 2
-- North | David Brown | 32000 | 4 | 4 | 3
-- South | Emma Davis | 52000 | 1 | 1 | 1
-- South | Frank Wilson | 48000 | 2 | 2 | 2
-- South | Grace Lee | 48000 | 3 | 2 | 2
-- South | Henry Taylor | 41000 | 4 | 4 | 3
