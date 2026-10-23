-- Title: Identify and Consolidate Duplicate Customer Records
-- Business Question: We have customer records that may contain duplicates based on email address and phone number combinations.
-- Find all duplicate groups and return one canonical record per customer, keeping the most recent entry.
-- Technique: Use window functions (ROW_NUMBER) to rank duplicates by registration date, then filter for the latest record in each duplicate group.

CREATE TABLE customers (
  customer_id INTEGER PRIMARY KEY,
  email TEXT NOT NULL,
  phone TEXT NOT NULL,
  name TEXT,
  city TEXT,
  registration_date DATE
);

INSERT INTO customers (customer_id, email, phone, name, city, registration_date) VALUES
(1, 'john.doe@email.com', '555-1234', 'John Doe', 'New York', '2023-01-15'),
(2, 'john.doe@email.com', '555-1234', 'Jon Doe', 'NYC', '2023-02-20'),
(3, 'sarah.smith@email.com', '555-5678', 'Sarah Smith', 'Boston', '2023-03-10'),
(4, 'sarah.smith@email.com', '555-5678', 'Sarah S.', 'Boston MA', '2023-04-05'),
(5, 'mike.jones@email.com', '555-9012', 'Michael Jones', 'Chicago', '2023-05-12'),
(6, 'mike.jones@email.com', '555-9012', 'Mike Jones', 'Chicago IL', '2023-06-08'),
(7, 'jane.wilson@email.com', '555-3456', 'Jane Wilson', 'Seattle', '2023-07-01'),
(8, 'bob.brown@email.com', '555-7890', 'Robert Brown', 'Denver', '2023-08-20'),
(9, 'bob.brown@email.com', '555-7890', 'Bob Brown', 'Denver CO', '2023-09-15'),
(10, 'alice.taylor@email.com', '555-2468', 'Alice Taylor', 'Portland', '2023-10-03');

WITH ranked_customers AS (
  SELECT
    customer_id,
    email,
    phone,
    name,
    city,
    registration_date,
    ROW_NUMBER() OVER (PARTITION BY email, phone ORDER BY registration_date DESC) AS rnk
  FROM customers
)
SELECT
  customer_id,
  email,
  phone,
  name,
  city,
  registration_date
FROM ranked_customers
WHERE rnk = 1
ORDER BY customer_id;

-- Result (verified in SQLite):
-- customer_id | email | phone | name | city | registration_date
-- 2 | john.doe@email.com | 555-1234 | Jon Doe | NYC | 2023-02-20
-- 4 | sarah.smith@email.com | 555-5678 | Sarah S. | Boston MA | 2023-04-05
-- 6 | mike.jones@email.com | 555-9012 | Mike Jones | Chicago IL | 2023-06-08
-- 7 | jane.wilson@email.com | 555-3456 | Jane Wilson | Seattle | 2023-07-01
-- 9 | bob.brown@email.com | 555-7890 | Bob Brown | Denver CO | 2023-09-15
-- 10 | alice.taylor@email.com | 555-2468 | Alice Taylor | Portland | 2023-10-03
