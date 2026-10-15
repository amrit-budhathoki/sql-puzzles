-- Title: Identify and Remove Duplicate Email Subscriptions
-- Business Question: A marketing database has duplicate email subscription records.
-- Find which email addresses have duplicates and keep only the earliest subscription.
-- Technique: Use ROW_NUMBER() window function to rank duplicates by date,
-- then filter for rank = 1 to retain only the first subscription per email.

CREATE TABLE subscriptions (
  subscription_id INTEGER PRIMARY KEY,
  email TEXT NOT NULL,
  subscription_date DATE NOT NULL,
  plan_type TEXT NOT NULL
);

INSERT INTO subscriptions (email, subscription_date, plan_type) VALUES
('alice@example.com', '2023-01-15', 'Premium'),
('bob@example.com', '2023-02-20', 'Basic'),
('alice@example.com', '2023-03-10', 'Basic'),
('charlie@example.com', '2023-01-05', 'Premium'),
('bob@example.com', '2023-04-12', 'Premium'),
('diana@example.com', '2023-02-28', 'Basic'),
('alice@example.com', '2023-05-01', 'Premium'),
('eve@example.com', '2023-03-15', 'Basic'),
('bob@example.com', '2023-06-08', 'Basic'),
('charlie@example.com', '2023-05-20', 'Basic');

WITH ranked_subscriptions AS (
  SELECT
    subscription_id,
    email,
    subscription_date,
    plan_type,
    ROW_NUMBER() OVER (PARTITION BY email ORDER BY subscription_date ASC) AS rn
  FROM subscriptions
)
SELECT
  subscription_id,
  email,
  subscription_date,
  plan_type
FROM ranked_subscriptions
WHERE rn = 1
ORDER BY email;

-- Result (verified in SQLite):
-- subscription_id | email | subscription_date | plan_type
-- 1 | alice@example.com | 2023-01-15 | Premium
-- 2 | bob@example.com | 2023-02-20 | Basic
-- 4 | charlie@example.com | 2023-01-05 | Premium
-- 6 | diana@example.com | 2023-02-28 | Basic
-- 8 | eve@example.com | 2023-03-15 | Basic
