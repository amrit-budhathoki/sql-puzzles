-- Title: Find Manager Chain and Depth for Each Employee

-- Business Question: For each employee, identify their complete reporting chain (manager, manager's manager, etc.)
-- and calculate the depth (how many levels up to the top).
-- Technique: Recursive CTE to traverse the employee hierarchy upward from each employee to the CEO.

CREATE TABLE employees (
  employee_id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  manager_id INTEGER,
  department TEXT,
  salary INTEGER
);

INSERT INTO employees VALUES
(1, 'Alice Chen', NULL, 'Executive', 150000),
(2, 'Bob Martinez', 1, 'Engineering', 120000),
(3, 'Carol Singh', 1, 'Sales', 110000),
(4, 'David Kim', 2, 'Engineering', 95000),
(5, 'Emma Rodriguez', 2, 'Engineering', 93000),
(6, 'Frank Wilson', 3, 'Sales', 85000),
(7, 'Grace Lee', 3, 'Sales', 84000),
(8, 'Henry Brown', 4, 'Engineering', 75000);

WITH RECURSIVE manager_chain AS (
  SELECT
    employee_id,
    name,
    manager_id,
    name AS manager_name,
    1 AS depth,
    CAST(name AS TEXT) AS chain
  FROM employees
  WHERE manager_id IS NULL

  UNION ALL

  SELECT
    e.employee_id,
    e.name,
    e.manager_id,
    m.name,
    m.depth + 1,
    m.chain || ' <- ' || e.name
  FROM employees e
  INNER JOIN manager_chain m ON e.manager_id = m.employee_id
)
SELECT
  employee_id,
  name,
  manager_name,
  depth,
  chain
FROM manager_chain
ORDER BY depth DESC, employee_id;

-- Result (verified in SQLite):
-- employee_id | name | manager_name | depth | chain
-- 8 | Henry Brown | David Kim | 4 | Alice Chen <- Bob Martinez <- David Kim <- Henry Brown
-- 4 | David Kim | Bob Martinez | 3 | Alice Chen <- Bob Martinez <- David Kim
-- 5 | Emma Rodriguez | Bob Martinez | 3 | Alice Chen <- Bob Martinez <- Emma Rodriguez
-- 6 | Frank Wilson | Carol Singh | 3 | Alice Chen <- Carol Singh <- Frank Wilson
-- 7 | Grace Lee | Carol Singh | 3 | Alice Chen <- Carol Singh <- Grace Lee
-- 2 | Bob Martinez | Alice Chen | 2 | Alice Chen <- Bob Martinez
-- 3 | Carol Singh | Alice Chen | 2 | Alice Chen <- Carol Singh
-- 1 | Alice Chen | Alice Chen | 1 | Alice Chen
