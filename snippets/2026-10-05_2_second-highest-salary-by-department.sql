-- Title: Second Highest Salary by Department
-- Business Question: Find the second highest salary earner in each department
-- Technique: Window functions with ROW_NUMBER() to rank salaries within groups

CREATE TABLE employees (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  department TEXT NOT NULL,
  salary INTEGER NOT NULL
);

INSERT INTO employees (name, department, salary) VALUES
('Alice Johnson', 'Sales', 95000),
('Bob Smith', 'Sales', 110000),
('Charlie Brown', 'Sales', 85000),
('Diana Prince', 'Engineering', 125000),
('Eve Davis', 'Engineering', 118000),
('Frank Wilson', 'Engineering', 105000),
('Grace Lee', 'Marketing', 78000),
('Henry Ford', 'Marketing', 82000),
('Iris King', 'Operations', 92000),
('Jack Ryan', 'Operations', 88000),
('Karen White', 'Operations', 96000),
('Leo Martinez', 'Sales', 90000);

WITH ranked_salaries AS (
  SELECT
    name,
    department,
    salary,
    ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC) AS salary_rank
  FROM employees
)
SELECT
  department,
  name,
  salary
FROM ranked_salaries
WHERE salary_rank = 2
ORDER BY department;

-- Result (verified in SQLite):
-- department | name | salary
-- Engineering | Eve Davis | 118000
-- Marketing | Grace Lee | 78000
-- Operations | Iris King | 92000
-- Sales | Alice Johnson | 95000
