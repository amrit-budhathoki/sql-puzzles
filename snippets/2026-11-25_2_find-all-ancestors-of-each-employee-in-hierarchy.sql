-- Title: Find All Ancestors of Each Employee in Hierarchy
-- Business Question: For each employee, list all their managers up the chain of command.
-- Technique: Recursive CTE to traverse upward through the reporting hierarchy.

CREATE TABLE employees (
  employee_id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  manager_id INTEGER,
  department TEXT
);

INSERT INTO employees VALUES
(1, 'Alice Johnson', NULL, 'Executive'),
(2, 'Bob Smith', 1, 'Engineering'),
(3, 'Carol White', 1, 'Sales'),
(4, 'David Brown', 2, 'Engineering'),
(5, 'Eve Davis', 2, 'Engineering'),
(6, 'Frank Miller', 3, 'Sales'),
(7, 'Grace Lee', 4, 'Engineering'),
(8, 'Henry Wilson', 6, 'Sales');

WITH RECURSIVE ancestor_chain AS (
  SELECT
    employee_id,
    name,
    manager_id,
    1 AS level,
    name AS chain
  FROM employees
  WHERE manager_id IS NULL

  UNION ALL

  SELECT
    e.employee_id,
    e.name,
    e.manager_id,
    ac.level + 1,
    ac.chain || ' <- ' || e.name
  FROM employees e
  INNER JOIN ancestor_chain ac ON e.manager_id = ac.employee_id
)
SELECT
  employee_id,
  name,
  chain AS reporting_chain_bottom_to_top
FROM ancestor_chain
ORDER BY employee_id, level DESC;

-- Result (verified in SQLite):
-- employee_id | name | reporting_chain_bottom_to_top
-- 1 | Alice Johnson | Alice Johnson
-- 2 | Bob Smith | Alice Johnson <- Bob Smith
-- 3 | Carol White | Alice Johnson <- Carol White
-- 4 | David Brown | Alice Johnson <- Bob Smith <- David Brown
-- 5 | Eve Davis | Alice Johnson <- Bob Smith <- Eve Davis
-- 6 | Frank Miller | Alice Johnson <- Carol White <- Frank Miller
-- 7 | Grace Lee | Alice Johnson <- Bob Smith <- David Brown <- Grace Lee
-- 8 | Henry Wilson | Alice Johnson <- Carol White <- Frank Miller <- Henry Wilson
