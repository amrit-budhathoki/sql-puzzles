-- Title: Find Employees Earning More Than Their Manager
-- Business Question: Which employees earn more than their direct manager?
-- Technique: Self join to compare employee and manager salary relationships
-- This helps identify potential compensation anomalies in the organization.

CREATE TABLE employees (
  employee_id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  department TEXT NOT NULL,
  salary DECIMAL(10, 2) NOT NULL,
  manager_id INTEGER
);

INSERT INTO employees VALUES
(1, 'Alice Johnson', 'Engineering', 120000, NULL),
(2, 'Bob Smith', 'Engineering', 95000, 1),
(3, 'Carol White', 'Engineering', 130000, 1),
(4, 'David Brown', 'Sales', 80000, 5),
(5, 'Eve Davis', 'Sales', 75000, NULL),
(6, 'Frank Miller', 'Engineering', 110000, 2),
(7, 'Grace Lee', 'HR', 85000, NULL),
(8, 'Henry Wilson', 'Sales', 85000, 5),
(9, 'Iris Taylor', 'HR', 92000, 7),
(10, 'Jack Anderson', 'Engineering', 125000, 1),
(11, 'Karen Thomas', 'Sales', 78000, 5),
(12, 'Leo Martinez', 'Engineering', 105000, 3);

SELECT
  e.employee_id,
  e.name AS employee_name,
  e.salary AS employee_salary,
  m.name AS manager_name,
  m.salary AS manager_salary,
  (e.salary - m.salary) AS salary_difference
FROM employees e
INNER JOIN employees m ON e.manager_id = m.employee_id
WHERE e.salary > m.salary
ORDER BY salary_difference DESC;

-- Result (verified in SQLite):
-- employee_id | employee_name | employee_salary | manager_name | manager_salary | salary_difference
-- 6 | Frank Miller | 110000 | Bob Smith | 95000 | 15000
-- 3 | Carol White | 130000 | Alice Johnson | 120000 | 10000
-- 8 | Henry Wilson | 85000 | Eve Davis | 75000 | 10000
-- 9 | Iris Taylor | 92000 | Grace Lee | 85000 | 7000
-- 4 | David Brown | 80000 | Eve Davis | 75000 | 5000
-- 10 | Jack Anderson | 125000 | Alice Johnson | 120000 | 5000
-- 11 | Karen Thomas | 78000 | Eve Davis | 75000 | 3000
