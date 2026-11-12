-- Title: Website Response Time Histogram Buckets

-- Business Question: Create a histogram showing the distribution of website response times
-- by bucketing them into 100ms ranges (0-100ms, 100-200ms, 200-300ms, etc.)
-- Technique: CASE statement to assign ranges, then GROUP BY to count occurrences per bucket

CREATE TABLE page_requests (
  request_id INTEGER PRIMARY KEY,
  page_name TEXT,
  response_time_ms INTEGER
);

INSERT INTO page_requests VALUES
  (1, 'homepage', 45),
  (2, 'product_list', 125),
  (3, 'checkout', 89),
  (4, 'homepage', 156),
  (5, 'product_detail', 203),
  (6, 'homepage', 67),
  (7, 'cart', 298),
  (8, 'product_list', 112),
  (9, 'checkout', 245),
  (10, 'product_detail', 389),
  (11, 'homepage', 78),
  (12, 'cart', 312);

SELECT
  CASE
    WHEN response_time_ms < 100 THEN '0-100ms'
    WHEN response_time_ms < 200 THEN '100-200ms'
    WHEN response_time_ms < 300 THEN '200-300ms'
    ELSE '300ms+'
  END AS response_time_bucket,
  COUNT(*) AS request_count,
  ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM page_requests), 1) AS percentage
FROM page_requests
GROUP BY response_time_bucket
ORDER BY
  CASE
    WHEN response_time_bucket = '0-100ms' THEN 1
    WHEN response_time_bucket = '100-200ms' THEN 2
    WHEN response_time_bucket = '200-300ms' THEN 3
    ELSE 4
  END;

-- Result (verified in SQLite):
-- response_time_bucket | request_count | percentage
-- 0-100ms | 4 | 33.3
-- 100-200ms | 3 | 25.0
-- 200-300ms | 3 | 25.0
-- 300ms+ | 2 | 16.7
