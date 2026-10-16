-- Title: Funnel Drop-off Analysis by Device Type
-- Business Question: For each stage in the user journey, calculate the drop-off rate from the previous stage, broken down by device type
-- Technique: Window functions (LAG) to compare consecutive stages and GROUP BY with CASE for conditional aggregation

CREATE TABLE user_events (
  event_id INTEGER PRIMARY KEY,
  user_id INTEGER,
  event_stage TEXT,
  device_type TEXT,
  event_date DATE
);

INSERT INTO user_events VALUES
(1, 101, 'landing', 'mobile', '2024-01-15'),
(2, 101, 'signup', 'mobile', '2024-01-15'),
(3, 102, 'landing', 'desktop', '2024-01-15'),
(4, 102, 'signup', 'desktop', '2024-01-15'),
(5, 102, 'checkout', 'desktop', '2024-01-15'),
(6, 103, 'landing', 'mobile', '2024-01-16'),
(7, 104, 'landing', 'desktop', '2024-01-16'),
(8, 104, 'signup', 'desktop', '2024-01-16'),
(9, 105, 'landing', 'tablet', '2024-01-16'),
(10, 105, 'signup', 'tablet', '2024-01-16'),
(11, 105, 'checkout', 'tablet', '2024-01-16'),
(12, 106, 'landing', 'mobile', '2024-01-17');

WITH stage_users AS (
  SELECT
    device_type,
    event_stage,
    COUNT(DISTINCT user_id) as unique_users
  FROM user_events
  GROUP BY device_type, event_stage
),
stage_sequence AS (
  SELECT
    device_type,
    event_stage,
    unique_users,
    LAG(unique_users) OVER (PARTITION BY device_type ORDER BY 
      CASE event_stage WHEN 'landing' THEN 1 WHEN 'signup' THEN 2 WHEN 'checkout' THEN 3 END) as prev_stage_users
  FROM stage_users
)
SELECT
  device_type,
  event_stage,
  unique_users,
  prev_stage_users,
  CASE
    WHEN prev_stage_users IS NULL THEN NULL
    ELSE ROUND(100.0 * (prev_stage_users - unique_users) / prev_stage_users, 2)
  END as dropoff_rate_percent
FROM stage_sequence
ORDER BY device_type, 
  CASE event_stage WHEN 'landing' THEN 1 WHEN 'signup' THEN 2 WHEN 'checkout' THEN 3 END;

-- Result (verified in SQLite):
-- device_type | event_stage | unique_users | prev_stage_users | dropoff_rate_percent
-- desktop | landing | 2 | None | None
-- desktop | signup | 2 | 2 | 0.0
-- desktop | checkout | 1 | 2 | 50.0
-- mobile | landing | 3 | None | None
-- mobile | signup | 1 | 3 | 66.67
-- tablet | landing | 1 | None | None
-- tablet | signup | 1 | 1 | 0.0
-- tablet | checkout | 1 | 1 | 0.0
