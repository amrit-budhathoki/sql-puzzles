-- Title: Consecutive Day Login Streaks
-- Business Question: What is the longest consecutive day login streak for each user?
-- Technique: Use ROW_NUMBER to assign groups, then COUNT to identify streaks

CREATE TABLE logins (
  user_id INTEGER,
  login_date DATE
);

INSERT INTO logins VALUES
(1, '2024-01-01'),
(1, '2024-01-02'),
(1, '2024-01-03'),
(1, '2024-01-05'),
(1, '2024-01-06'),
(2, '2024-01-01'),
(2, '2024-01-02'),
(2, '2024-01-03'),
(2, '2024-01-04'),
(2, '2024-01-05'),
(3, '2024-01-10'),
(3, '2024-01-12');

WITH dated_logins AS (
  SELECT
    user_id,
    login_date,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY login_date) AS rn
  FROM logins
),
streak_groups AS (
  SELECT
    user_id,
    login_date,
    DATE(login_date, '-' || rn || ' days') AS streak_group
  FROM dated_logins
),
streak_counts AS (
  SELECT
    user_id,
    streak_group,
    COUNT(*) AS streak_length
  FROM streak_groups
  GROUP BY user_id, streak_group
)
SELECT
  user_id,
  MAX(streak_length) AS longest_streak_days
FROM streak_counts
GROUP BY user_id
ORDER BY user_id;

-- Result (verified in SQLite):
-- user_id | longest_streak_days
-- 1 | 3
-- 2 | 5
-- 3 | 1
