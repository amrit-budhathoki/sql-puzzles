-- Title: Multi-Stage Funnel Conversion Analysis
-- Business Question: What are the conversion rates between each stage of our sales funnel?
-- Technique: Self-join to pair consecutive funnel stages and calculate percentage conversions

CREATE TABLE funnel_events (
  event_id INTEGER PRIMARY KEY,
  user_id INTEGER,
  stage_name TEXT,
  event_date DATE
);

INSERT INTO funnel_events VALUES
(1, 101, 'page_view', '2024-01-01'),
(2, 101, 'add_to_cart', '2024-01-01'),
(3, 101, 'checkout', '2024-01-01'),
(4, 101, 'payment', '2024-01-01'),
(5, 102, 'page_view', '2024-01-01'),
(6, 102, 'add_to_cart', '2024-01-01'),
(7, 102, 'checkout', '2024-01-01'),
(8, 103, 'page_view', '2024-01-01'),
(9, 103, 'add_to_cart', '2024-01-01'),
(10, 104, 'page_view', '2024-01-01'),
(11, 105, 'page_view', '2024-01-01'),
(12, 106, 'page_view', '2024-01-01');

WITH stage_order AS (
  SELECT 'page_view' as stage, 1 as stage_num
  UNION ALL SELECT 'add_to_cart', 2
  UNION ALL SELECT 'checkout', 3
  UNION ALL SELECT 'payment', 4
),
stage_counts AS (
  SELECT stage_name, COUNT(DISTINCT user_id) as user_count
  FROM funnel_events
  GROUP BY stage_name
)
SELECT
  s1.stage as from_stage,
  s2.stage as to_stage,
  c1.user_count as users_at_from,
  c2.user_count as users_at_to,
  ROUND(100.0 * c2.user_count / c1.user_count, 2) as conversion_rate_percent
FROM stage_order s1
JOIN stage_order s2 ON s2.stage_num = s1.stage_num + 1
JOIN stage_counts c1 ON c1.stage_name = s1.stage
JOIN stage_counts c2 ON c2.stage_name = s2.stage
ORDER BY s1.stage_num;

-- Result (verified in SQLite):
-- from_stage | to_stage | users_at_from | users_at_to | conversion_rate_percent
-- page_view | add_to_cart | 6 | 3 | 50.0
-- add_to_cart | checkout | 3 | 2 | 66.67
-- checkout | payment | 2 | 1 | 50.0
