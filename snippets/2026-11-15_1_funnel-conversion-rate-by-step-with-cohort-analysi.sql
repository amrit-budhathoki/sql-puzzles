-- Title: Funnel Conversion Rate by Step with Cohort Analysis
-- Business Question: What is the conversion rate between each step of the user journey (signup -> email_verified -> trial_started -> paid_subscription)?
-- Technique: Window functions to count users at each funnel step, calculate conversion rates between consecutive steps, and segment by signup cohort month.

CREATE TABLE funnel_events (
  user_id INTEGER,
  event_type TEXT,
  event_date DATE,
  cohort_month TEXT
);

INSERT INTO funnel_events VALUES
(1, 'signup', '2024-01-05', '2024-01'),
(1, 'email_verified', '2024-01-06', '2024-01'),
(1, 'trial_started', '2024-01-10', '2024-01'),
(1, 'paid_subscription', '2024-01-25', '2024-01'),
(2, 'signup', '2024-01-08', '2024-01'),
(2, 'email_verified', '2024-01-09', '2024-01'),
(2, 'trial_started', '2024-01-15', '2024-01'),
(3, 'signup', '2024-01-12', '2024-01'),
(3, 'email_verified', '2024-01-13', '2024-01'),
(4, 'signup', '2024-02-01', '2024-02'),
(4, 'email_verified', '2024-02-02', '2024-02'),
(4, 'trial_started', '2024-02-08', '2024-02'),
(5, 'signup', '2024-02-05', '2024-02');

WITH step_counts AS (
  SELECT
    cohort_month,
    event_type,
    COUNT(DISTINCT user_id) as user_count,
    CASE
      WHEN event_type = 'signup' THEN 1
      WHEN event_type = 'email_verified' THEN 2
      WHEN event_type = 'trial_started' THEN 3
      WHEN event_type = 'paid_subscription' THEN 4
    END as step_order
  FROM funnel_events
  GROUP BY cohort_month, event_type
),
step_sequence AS (
  SELECT
    cohort_month,
    event_type,
    user_count,
    step_order,
    LAG(user_count) OVER (PARTITION BY cohort_month ORDER BY step_order) as prev_step_count
  FROM step_counts
)
SELECT
  cohort_month,
  event_type as funnel_step,
  user_count,
  ROUND(100.0 * user_count / FIRST_VALUE(user_count) OVER (PARTITION BY cohort_month ORDER BY step_order), 2) as pct_of_signups,
  CASE
    WHEN prev_step_count IS NULL THEN NULL
    ELSE ROUND(100.0 * user_count / prev_step_count, 2)
  END as conversion_from_prev_step
FROM step_sequence
ORDER BY cohort_month, step_order;

-- Result (verified in SQLite):
-- cohort_month | funnel_step | user_count | pct_of_signups | conversion_from_prev_step
-- 2024-01 | signup | 3 | 100.0 | None
-- 2024-01 | email_verified | 3 | 100.0 | 100.0
-- 2024-01 | trial_started | 2 | 66.67 | 66.67
-- 2024-01 | paid_subscription | 1 | 33.33 | 50.0
-- 2024-02 | signup | 2 | 100.0 | None
-- 2024-02 | email_verified | 1 | 50.0 | 50.0
-- 2024-02 | trial_started | 1 | 50.0 | 100.0
