-- Title: Remove Duplicate Email Subscriptions Keeping Earliest Signup
-- Business Question: Our subscription table has duplicate email addresses from users signing up multiple times.
-- Identify and remove duplicate subscriptions, keeping only the earliest signup date for each email.
-- Technique: Use ROW_NUMBER() window function to rank duplicates by signup date, then filter for rank = 1.

CREATE TABLE subscriptions (
  subscription_id INTEGER PRIMARY KEY,
  email TEXT NOT NULL,
  signup_date DATE NOT NULL,
  plan_type TEXT,
  status TEXT
);

INSERT INTO subscriptions (email, signup_date, plan_type, status) VALUES
('alice@example.com', '2024-01-15', 'premium', 'active'),
('bob@example.com', '2024-02-10', 'basic', 'active'),
('alice@example.com', '2024-03-20', 'premium', 'active'),
('charlie@example.com', '2024-01-05', 'basic', 'inactive'),
('bob@example.com', '2024-01-25', 'basic', 'active'),
('diana@example.com', '2024-02-28', 'premium', 'active'),
('alice@example.com', '2024-02-14', 'basic', 'active'),
('eve@example.com', '2024-03-10', 'premium', 'active'),
('charlie@example.com', '2024-03-15', 'premium', 'active'),
('bob@example.com', '2024-03-05', 'premium', 'inactive');

WITH ranked_subscriptions AS (
  SELECT
    subscription_id,
    email,
    signup_date,
    plan_type,
    status,
    ROW_NUMBER() OVER (PARTITION BY email ORDER BY signup_date ASC) AS rn
  FROM subscriptions
)
SELECT
  subscription_id,
  email,
  signup_date,
  plan_type,
  status
FROM ranked_subscriptions
WHERE rn = 1
ORDER BY email, signup_date;

-- Result (verified in SQLite):
-- subscription_id | email | signup_date | plan_type | status
-- 1 | alice@example.com | 2024-01-15 | premium | active
-- 5 | bob@example.com | 2024-01-25 | basic | active
-- 4 | charlie@example.com | 2024-01-05 | basic | inactive
-- 6 | diana@example.com | 2024-02-28 | premium | active
-- 8 | eve@example.com | 2024-03-10 | premium | active
