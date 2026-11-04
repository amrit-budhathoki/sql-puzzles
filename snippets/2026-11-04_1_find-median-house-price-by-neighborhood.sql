-- Title: Find Median House Price by Neighborhood

-- Business Question: What is the median house price in each neighborhood?
-- Technique: Use ROW_NUMBER() and window functions to find the middle value(s)
-- without relying on a MEDIAN() built-in function. For odd counts, take the middle row.
-- For even counts, average the two middle rows.

CREATE TABLE house_sales (
  sale_id INTEGER PRIMARY KEY,
  neighborhood TEXT NOT NULL,
  price INTEGER NOT NULL
);

INSERT INTO house_sales (neighborhood, price) VALUES
('Downtown', 450000),
('Downtown', 520000),
('Downtown', 485000),
('Downtown', 510000),
('Downtown', 495000),
('Suburbs', 320000),
('Suburbs', 350000),
('Suburbs', 335000),
('Suburbs', 345000),
('Suburbs', 340000),
('Suburbs', 330000),
('Suburbs', 355000);

WITH ranked_sales AS (
  SELECT
    neighborhood,
    price,
    ROW_NUMBER() OVER (PARTITION BY neighborhood ORDER BY price) AS rn,
    COUNT(*) OVER (PARTITION BY neighborhood) AS total_count
  FROM house_sales
),
median_calc AS (
  SELECT
    neighborhood,
    price,
    rn,
    total_count,
    CASE
      WHEN total_count % 2 = 1 THEN (total_count + 1) / 2
      ELSE total_count / 2
    END AS lower_mid,
    CASE
      WHEN total_count % 2 = 1 THEN (total_count + 1) / 2
      ELSE (total_count / 2) + 1
    END AS upper_mid
  FROM ranked_sales
)
SELECT
  neighborhood,
  ROUND(AVG(price), 2) AS median_price
FROM median_calc
WHERE rn IN (lower_mid, upper_mid)
GROUP BY neighborhood
ORDER BY neighborhood;

-- Result (verified in SQLite):
-- neighborhood | median_price
-- Downtown | 495000.0
-- Suburbs | 340000.0
