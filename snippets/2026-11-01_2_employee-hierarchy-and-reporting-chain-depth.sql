-- Title: Employee Hierarchy and Reporting Chain Depth
-- Business Question: For each employee, show their name, direct manager, and the depth level in the organizational hierarchy (CEO at level 1).
-- Technique: Recursive CTE to traverse the employee-manager relationship tree from root nodes (employees with no manager) down through all subordinates.

CREATE TABLE employees (
  employee_id INTEGER PRIMARY KEY,
  employee_name TEXT NOT NULL,
  manager_id INTEGER,
  department TEXT,
  salary DECIMAL(10, 2)
);

INSERT INTO employees VALUES
(1, 'Alice Johnson', NULL, 'Executive', 150000),
(2, 'Bob Smith', 1, 'Engineering', 95000),
(3, 'Carol White', 1, 'Sales', 85000),
(4, 'David Brown', 2, 'Engineering', 75000),
(5, 'Eve Davis', 2, 'Engineering', 72000),
(6, 'Frank Miller', 3, 'Sales', 65000),
(7, 'Grace Lee', 3, 'Sales', 63000),
(8, 'Henry Wilson', 4, 'Engineering', 60000),
(9, 'Iris Martinez', 5, 'Engineering', 58000),
(10, 'Jack Thompson', 6, 'Sales', 55000);

WITH RECURSIVE hierarchy AS (
  SELECT
    employee_id,
    employee_name,
    manager_id,
    department,
    1 AS hierarchy_level,
    employee_name AS reporting_chain
  FROM employees
  WHERE manager_id IS NULL
  
  UNION ALL
  
  SELECT
    e.employee_id,
    e.employee_name,
    e.manager_id,
    e.department,
    h.hierarchy_level + 1,
    h.reporting_chain || ' -> ' || e.employee_name
  FROM employees e
  INNER JOIN hierarchy h ON e.manager_id = h.employee_id
)
SELECT
  employee_id,
  employee_name,
  manager_id,
  department,
  hierarchy_level,
  reporting_chain
FROM hierarchy
ORDER BY hierarchy_level, employee_id;

-- Result (verified in SQLite):
-- employee_id | employee_name | manager_id | department | hierarchy_level | reporting_chain
-- 1 | Alice Johnson | None | Executive | 1 | Alice Johnson
-- 2 | Bob Smith | 1 | Engineering | 2 | Alice Johnson -> Bob Smith
-- 3 | Carol White | 1 | Sales | 2 | Alice Johnson -> Carol White
-- 4 | David Brown | 2 | Engineering | 3 | Alice Johnson -> Bob Smith -> David Brown
-- 5 | Eve Davis | 2 | Engineering | 3 | Alice Johnson -> Bob Smith -> Eve Davis
-- 6 | Frank Miller | 3 | Sales | 3 | Alice Johnson -> Carol White -> Frank Miller
-- 7 | Grace Lee | 3 | Sales | 3 | Alice Johnson -> Carol White -> Grace Lee
-- 8 | Henry Wilson | 4 | Engineering | 4 | Alice Johnson -> Bob Smith -> David Brown -> Henry Wilson
-- 9 | Iris Martinez | 5 | Engineering | 4 | Alice Johnson -> Bob Smith -> Eve Davis -> Iris Martinez
-- 10 | Jack Thompson | 6 | Sales | 4 | Alice Johnson -> Carol White -> Frank Miller -> Jack Thompson
