-- Title: Second Highest Salary Per Department

-- Business Question: For each department, identify the employee with the second highest salary.
-- Technique: Use ROW_NUMBER() window function partitioned by department, ordered by salary descending, then filter for rank 2.

CREATE TABLE employees (
  emp_id INTEGER PRIMARY KEY,
  emp_name TEXT NOT NULL,
  department TEXT NOT NULL,
  salary DECIMAL(10, 2)
);

INSERT INTO employees VALUES
(1, 'Alice Johnson', 'Engineering', 95000),
(2, 'Bob Smith', 'Engineering', 105000),
(3, 'Charlie Brown', 'Engineering', 85000),
(4, 'Diana Prince', 'Sales', 75000),
(5, 'Eve Wilson', 'Sales', 82000),
(6, 'Frank Miller', 'Sales', 70000),
(7, 'Grace Lee', 'HR', 65000),
(8, 'Henry Davis', 'HR', 72000),
(9, 'Iris Chen', 'HR', 68000),
(10, 'Jack Moore', 'Engineering', 92000),
(11, 'Karen White', 'Sales', 80000);

WITH ranked_employees AS (
  SELECT
    emp_id,
    emp_name,
    department,
    salary,
    ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC) AS salary_rank
  FROM employees
)
SELECT
  emp_id,
  emp_name,
  department,
  salary
FROM ranked_employees
WHERE salary_rank = 2
ORDER BY department;

-- Result (verified in SQLite):
-- emp_id | emp_name | department | salary
-- 1 | Alice Johnson | Engineering | 95000
-- 9 | Iris Chen | HR | 68000
-- 11 | Karen White | Sales | 80000
