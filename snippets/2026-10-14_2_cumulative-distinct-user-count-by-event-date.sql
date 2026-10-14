-- Title: Cumulative Distinct User Count by Event Date
-- Business Question: Show how many distinct users have visited by each date, along with running total of unique users
-- Technique: Window function SUM(COUNT(DISTINCT ...)) to compute cumulative distinct counts over ordered dates

CREATE TABLE user_visits (
  visit_id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  visit_date DATE NOT NULL,
  page_visited TEXT NOT NULL
);

INSERT INTO user_visits VALUES
(1, 101, '2024-01-01', 'home'),
(2, 102, '2024-01-01', 'products'),
(3, 101, '2024-01-02', 'checkout'),
(4, 103, '2024-01-02', 'home'),
(5, 104, '2024-01-03', 'home'),
(6, 101, '2024-01-03', 'confirmation'),
(7, 105, '2024-01-04', 'products'),
(8, 102, '2024-01-04', 'home'),
(9, 106, '2024-01-05', 'checkout'),
(10, 103, '2024-01-05', 'products'),
(11, 107, '2024-01-05', 'home'),
(12, 101, '2024-01-06', 'products');

WITH daily_distinct_users AS (
  SELECT
    visit_date,
    COUNT(DISTINCT user_id) AS users_that_day
  FROM user_visits
  GROUP BY visit_date
),
cumulative_users AS (
  SELECT
    visit_date,
    users_that_day,
    SUM(users_that_day) OVER (ORDER BY visit_date) AS cumulative_distinct_users
  FROM daily_distinct_users
)
SELECT
  visit_date,
  users_that_day,
  cumulative_distinct_users
FROM cumulative_users
ORDER BY visit_date;

-- Result (verified in SQLite):
-- visit_date | users_that_day | cumulative_distinct_users
-- 2024-01-01 | 2 | 2
-- 2024-01-02 | 2 | 4
-- 2024-01-03 | 2 | 6
-- 2024-01-04 | 2 | 8
-- 2024-01-05 | 3 | 11
-- 2024-01-06 | 1 | 12
