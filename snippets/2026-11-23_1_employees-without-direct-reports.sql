-- Title: Employees Without Direct Reports
-- Business Question: Find all employees who have never managed anyone (no direct reports).
-- Technique: Anti-join using NOT EXISTS to identify employees absent from the manager relationship.

CREATE TABLE employees (
  emp_id INTEGER PRIMARY KEY,
  emp_name TEXT NOT NULL,
  department TEXT NOT NULL,
  hire_date DATE NOT NULL
);

CREATE TABLE manager_assignments (
  manager_emp_id INTEGER NOT NULL,
  direct_report_emp_id INTEGER NOT NULL,
  assignment_date DATE NOT NULL,
  PRIMARY KEY (manager_emp_id, direct_report_emp_id)
);

INSERT INTO employees VALUES (1, 'Alice Johnson', 'Engineering', '2018-01-15');
INSERT INTO employees VALUES (2, 'Bob Smith', 'Sales', '2019-03-22');
INSERT INTO employees VALUES (3, 'Carol White', 'Engineering', '2020-06-10');
INSERT INTO employees VALUES (4, 'Diana Prince', 'HR', '2017-11-05');
INSERT INTO employees VALUES (5, 'Eve Brown', 'Engineering', '2021-02-28');
INSERT INTO employees VALUES (6, 'Frank Green', 'Sales', '2020-09-13');
INSERT INTO employees VALUES (7, 'Grace Lee', 'Marketing', '2022-01-20');
INSERT INTO employees VALUES (8, 'Henry Davis', 'Engineering', '2019-07-11');

INSERT INTO manager_assignments VALUES (1, 3, '2020-07-01');
INSERT INTO manager_assignments VALUES (1, 5, '2021-03-15');
INSERT INTO manager_assignments VALUES (4, 2, '2019-04-01');
INSERT INTO manager_assignments VALUES (4, 6, '2020-10-01');
INSERT INTO manager_assignments VALUES (2, 8, '2021-08-20');

SELECT
  e.emp_id,
  e.emp_name,
  e.department,
  e.hire_date
FROM employees e
WHERE NOT EXISTS (
  SELECT 1
  FROM manager_assignments ma
  WHERE ma.manager_emp_id = e.emp_id
)
ORDER BY e.emp_name;

-- Result (verified in SQLite):
-- emp_id | emp_name | department | hire_date
-- 3 | Carol White | Engineering | 2020-06-10
-- 5 | Eve Brown | Engineering | 2021-02-28
-- 6 | Frank Green | Sales | 2020-09-13
-- 7 | Grace Lee | Marketing | 2022-01-20
-- 8 | Henry Davis | Engineering | 2019-07-11
