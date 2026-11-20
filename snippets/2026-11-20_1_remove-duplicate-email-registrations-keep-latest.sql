-- Title: Remove Duplicate Email Registrations Keep Latest
-- Business Question: We have duplicate user registrations with the same email address.
-- Identify these duplicates and remove all but the most recent registration for each email.
-- Technique: Use ROW_NUMBER() window function to rank registrations by date,
-- then filter to keep only the latest registration per email address.

CREATE TABLE user_registrations (
  registration_id INTEGER PRIMARY KEY,
  email TEXT NOT NULL,
  username TEXT,
  registration_date DATE,
  account_status TEXT
);

INSERT INTO user_registrations VALUES
(1, 'alice@example.com', 'alice_v1', '2023-01-15', 'active'),
(2, 'alice@example.com', 'alice_v2', '2023-02-20', 'active'),
(3, 'alice@example.com', 'alice_final', '2023-03-10', 'active'),
(4, 'bob@example.com', 'bob_smith', '2023-01-20', 'active'),
(5, 'charlie@example.com', 'charlie_old', '2023-01-25', 'inactive'),
(6, 'charlie@example.com', 'charlie_new', '2023-04-05', 'active'),
(7, 'diana@example.com', 'diana_01', '2023-02-01', 'active'),
(8, 'diana@example.com', 'diana_02', '2023-02-15', 'suspended'),
(9, 'diana@example.com', 'diana_03', '2023-05-01', 'active'),
(10, 'eve@example.com', 'eve_user', '2023-03-30', 'active');

WITH ranked_registrations AS (
  SELECT
    registration_id,
    email,
    username,
    registration_date,
    account_status,
    ROW_NUMBER() OVER (PARTITION BY email ORDER BY registration_date DESC) AS rn
  FROM user_registrations
)
SELECT
  email,
  COUNT(*) AS total_registrations,
  SUM(CASE WHEN rn = 1 THEN 0 ELSE 1 END) AS duplicates_to_remove,
  GROUP_CONCAT(CASE WHEN rn > 1 THEN registration_id ELSE NULL END, ', ') AS ids_to_delete,
  MAX(CASE WHEN rn = 1 THEN username END) AS kept_username,
  MAX(CASE WHEN rn = 1 THEN registration_date END) AS latest_registration_date
FROM ranked_registrations
GROUP BY email
HAVING COUNT(*) > 1
ORDER BY total_registrations DESC;

-- Result (verified in SQLite):
-- email | total_registrations | duplicates_to_remove | ids_to_delete | kept_username | latest_registration_date
-- diana@example.com | 3 | 2 | 8, 7 | diana_03 | 2023-05-01
-- alice@example.com | 3 | 2 | 2, 1 | alice_final | 2023-03-10
-- charlie@example.com | 2 | 1 | 5 | charlie_new | 2023-04-05
