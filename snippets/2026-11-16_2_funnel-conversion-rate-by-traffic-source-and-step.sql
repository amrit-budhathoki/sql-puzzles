-- Title: Funnel Conversion Rate by Traffic Source and Step
-- Business Question: What is the conversion rate at each step of our signup funnel (landing page -> form start -> form complete -> payment) broken down by traffic source?
-- Technique: Calculate step-wise conversion rates using window functions and conditional aggregation to track user progression through funnel stages.

CREATE TABLE funnel_events (
  event_id INTEGER PRIMARY KEY,
  user_id INTEGER,
  traffic_source TEXT,
  funnel_step TEXT,
  event_timestamp DATETIME
);

INSERT INTO funnel_events VALUES
(1, 101, 'organic', 'landing_page', '2024-01-15 10:00:00'),
(2, 101, 'organic', 'form_start', '2024-01-15 10:05:00'),
(3, 101, 'organic', 'form_complete', '2024-01-15 10:10:00'),
(4, 101, 'organic', 'payment', '2024-01-15 10:15:00'),
(5, 102, 'organic', 'landing_page', '2024-01-15 10:02:00'),
(6, 102, 'organic', 'form_start', '2024-01-15 10:07:00'),
(7, 103, 'organic', 'landing_page', '2024-01-15 10:03:00'),
(8, 104, 'paid_search', 'landing_page', '2024-01-15 10:01:00'),
(9, 104, 'paid_search', 'form_start', '2024-01-15 10:06:00'),
(10, 104, 'paid_search', 'form_complete', '2024-01-15 10:11:00'),
(11, 105, 'paid_search', 'landing_page', '2024-01-15 10:04:00'),
(12, 106, 'social', 'landing_page', '2024-01-15 10:00:30'),
(13, 106, 'social', 'form_start', '2024-01-15 10:05:30'),
(14, 106, 'social', 'form_complete', '2024-01-15 10:10:30'),
(15, 106, 'social', 'payment', '2024-01-15 10:15:30');

WITH funnel_steps AS (
  SELECT
    traffic_source,
    funnel_step,
    COUNT(DISTINCT user_id) as step_users
  FROM funnel_events
  GROUP BY traffic_source, funnel_step
),
step_sequence AS (
  SELECT
    traffic_source,
    'landing_page' as funnel_step,
    1 as step_order
  FROM (SELECT DISTINCT traffic_source FROM funnel_events)
  UNION ALL
  SELECT traffic_source, 'form_start', 2 FROM (SELECT DISTINCT traffic_source FROM funnel_events)
  UNION ALL
  SELECT traffic_source, 'form_complete', 3 FROM (SELECT DISTINCT traffic_source FROM funnel_events)
  UNION ALL
  SELECT traffic_source, 'payment', 4 FROM (SELECT DISTINCT traffic_source FROM funnel_events)
)
SELECT
  ss.traffic_source,
  ss.funnel_step,
  ss.step_order,
  COALESCE(fs.step_users, 0) as users_at_step,
  ROUND(100.0 * COALESCE(fs.step_users, 0) / MAX(CASE WHEN ss.step_order = 1 THEN COALESCE(fs.step_users, 0) END) OVER (PARTITION BY ss.traffic_source), 2) as conversion_rate_pct
FROM step_sequence ss
LEFT JOIN funnel_steps fs ON ss.traffic_source = fs.traffic_source AND ss.funnel_step = fs.funnel_step
ORDER BY ss.traffic_source, ss.step_order;

-- Result (verified in SQLite):
-- traffic_source | funnel_step | step_order | users_at_step | conversion_rate_pct
-- organic | landing_page | 1 | 3 | 100.0
-- organic | form_start | 2 | 2 | 66.67
-- organic | form_complete | 3 | 1 | 33.33
-- organic | payment | 4 | 1 | 33.33
-- paid_search | landing_page | 1 | 2 | 100.0
-- paid_search | form_start | 2 | 1 | 50.0
-- paid_search | form_complete | 3 | 1 | 50.0
-- paid_search | payment | 4 | 0 | 0.0
-- social | landing_page | 1 | 1 | 100.0
-- social | form_start | 2 | 1 | 100.0
-- social | form_complete | 3 | 1 | 100.0
-- social | payment | 4 | 1 | 100.0
