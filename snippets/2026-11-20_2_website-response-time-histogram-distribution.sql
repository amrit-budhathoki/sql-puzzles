-- Title: Website Response Time Histogram Distribution
-- Business Question: Create a histogram showing how many requests fall into different response time ranges
-- Technique: CASE statement to bucket continuous values into discrete ranges, then COUNT to aggregate

CREATE TABLE api_requests (
  request_id INTEGER PRIMARY KEY,
  endpoint TEXT NOT NULL,
  response_time_ms INTEGER NOT NULL,
  request_date DATE NOT NULL
);

INSERT INTO api_requests (endpoint, response_time_ms, request_date) VALUES
('GET /users', 145, '2024-01-15'),
('POST /auth', 2850, '2024-01-15'),
('GET /products', 320, '2024-01-15'),
('GET /users', 78, '2024-01-15'),
('GET /cart', 1250, '2024-01-15'),
('POST /orders', 3100, '2024-01-15'),
('GET /products', 410, '2024-01-15'),
('GET /users', 95, '2024-01-15'),
('GET /cart', 890, '2024-01-15'),
('POST /auth', 2200, '2024-01-15');

SELECT
  CASE
    WHEN response_time_ms < 100 THEN '0-99ms'
    WHEN response_time_ms < 500 THEN '100-499ms'
    WHEN response_time_ms < 1000 THEN '500-999ms'
    WHEN response_time_ms < 2000 THEN '1000-1999ms'
    ELSE '2000+ms'
  END AS response_bucket,
  COUNT(*) AS request_count,
  ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM api_requests), 1) AS percentage
FROM api_requests
GROUP BY response_bucket
ORDER BY
  CASE
    WHEN response_bucket = '0-99ms' THEN 1
    WHEN response_bucket = '100-499ms' THEN 2
    WHEN response_bucket = '500-999ms' THEN 3
    WHEN response_bucket = '1000-1999ms' THEN 4
    ELSE 5
  END;

-- Result (verified in SQLite):
-- response_bucket | request_count | percentage
-- 0-99ms | 2 | 20.0
-- 100-499ms | 3 | 30.0
-- 500-999ms | 1 | 10.0
-- 1000-1999ms | 1 | 10.0
-- 2000+ms | 3 | 30.0
