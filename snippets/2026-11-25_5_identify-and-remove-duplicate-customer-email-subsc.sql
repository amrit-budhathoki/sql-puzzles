-- Title: Identify and Remove Duplicate Customer Email Subscriptions

-- Business Question: Find duplicate email subscriptions where the same email appears multiple times,
-- and keep only the subscription with the earliest signup date, removing all others.
-- Technique: Use ROW_NUMBER() window function to rank rows by email and signup_date,
-- then filter to keep only rank 1 (earliest subscription per email).

CREATE TABLE subscriptions (
  subscription_id INTEGER PRIMARY KEY,
  email TEXT NOT NULL,
  signup_date DATE NOT NULL,
  subscription_tier TEXT NOT NULL
);

INSERT INTO subscriptions VALUES
(1, 'alice@example.com', '2023-01-15', 'premium'),
(2, 'alice@example.com', '2023-02-20', 'basic'),
(3, 'alice@example.com', '2023-01-10', 'premium'),
(4, 'bob@example.com', '2023-03-01', 'basic'),
(5, 'charlie@example.com', '2023-01-25', 'premium'),
(6, 'bob@example.com', '2023-02-15', 'premium'),
(7, 'diana@example.com', '2023-04-10', 'basic'),
(8, 'charlie@example.com', '2023-03-30', 'basic'),
(9, 'eve@example.com', '2023-02-05', 'premium'),
(10, 'alice@example.com', '2023-01-05', 'basic');

WITH ranked_subscriptions AS (
  SELECT
    subscription_id,
    email,
    signup_date,
    subscription_tier,
    ROW_NUMBER() OVER (PARTITION BY email ORDER BY signup_date ASC, subscription_id ASC) AS rn
  FROM subscriptions
)
SELECT
  subscription_id,
  email,
  signup_date,
  subscription_tier,
  CASE WHEN rn = 1 THEN 'KEEP' ELSE 'REMOVE' END AS action
FROM ranked_subscriptions
ORDER BY email, signup_date;

-- Result (verified in SQLite):
-- subscription_id | email | signup_date | subscription_tier | action
-- 10 | alice@example.com | 2023-01-05 | basic | KEEP
-- 3 | alice@example.com | 2023-01-10 | premium | REMOVE
-- 1 | alice@example.com | 2023-01-15 | premium | REMOVE
-- 2 | alice@example.com | 2023-02-20 | basic | REMOVE
-- 6 | bob@example.com | 2023-02-15 | premium | KEEP
-- 4 | bob@example.com | 2023-03-01 | basic | REMOVE
-- 5 | charlie@example.com | 2023-01-25 | premium | KEEP
-- 8 | charlie@example.com | 2023-03-30 | basic | REMOVE
-- 7 | diana@example.com | 2023-04-10 | basic | KEEP
-- 9 | eve@example.com | 2023-02-05 | premium | KEEP
