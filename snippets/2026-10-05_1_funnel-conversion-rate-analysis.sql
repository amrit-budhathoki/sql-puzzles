-- Title: Funnel Conversion Rate Analysis
-- Business Question: What is the conversion rate at each stage of the customer journey
-- from signup to purchase, and how many customers drop off at each funnel stage?
-- Technique: Use GROUP BY and window functions to calculate stage-wise conversion rates

CREATE TABLE funnel_events (
  event_id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  event_type TEXT NOT NULL,
  event_date DATE NOT NULL
);

INSERT INTO funnel_events VALUES
(1, 101, 'signup', '2024-01-01'),
(2, 101, 'view_product', '2024-01-02'),
(3, 101, 'add_to_cart', '2024-01-03'),
(4, 101, 'purchase', '2024-01-04'),
(5, 102, 'signup', '2024-01-01'),
(6, 102, 'view_product', '2024-01-02'),
(7, 102, 'add_to_cart', '2024-01-03'),
(8, 103, 'signup', '2024-01-01'),
(9, 103, 'view_product', '2024-01-02'),
(10, 104, 'signup', '2024-01-01'),
(11, 105, 'signup', '2024-01-02'),
(12, 105, 'view_product', '2024-01-03');

WITH stage_counts AS (
  SELECT
    'signup' AS stage,
    COUNT(DISTINCT user_id) AS user_count
  FROM funnel_events
  WHERE event_type = 'signup'
  UNION ALL
  SELECT
    'view_product' AS stage,
    COUNT(DISTINCT user_id) AS user_count
  FROM funnel_events
  WHERE event_type = 'view_product'
  UNION ALL
  SELECT
    'add_to_cart' AS stage,
    COUNT(DISTINCT user_id) AS user_count
  FROM funnel_events
  WHERE event_type = 'add_to_cart'
  UNION ALL
  SELECT
    'purchase' AS stage,
    COUNT(DISTINCT user_id) AS user_count
  FROM funnel_events
  WHERE event_type = 'purchase'
)
SELECT
  stage,
  user_count,
  ROUND(100.0 * user_count / (SELECT user_count FROM stage_counts WHERE stage = 'signup'), 2) AS conversion_rate_pct
FROM stage_counts
ORDER BY
  CASE WHEN stage = 'signup' THEN 1
       WHEN stage = 'view_product' THEN 2
       WHEN stage = 'add_to_cart' THEN 3
       WHEN stage = 'purchase' THEN 4 END;

-- Result (verified in SQLite):
-- stage | user_count | conversion_rate_pct
-- signup | 5 | 100.0
-- view_product | 4 | 80.0
-- add_to_cart | 2 | 40.0
-- purchase | 1 | 20.0
