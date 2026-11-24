-- Title: Employee Performance Ranking Within Each Department

-- Business question: Rank employees by salary within their department to understand pay equity and identify top earners.
-- Show ROW_NUMBER (unique rank even with ties), RANK (same rank for ties with gaps), and DENSE_RANK (same rank for ties without gaps).
-- Technique: Use window functions ROW_NUMBER(), RANK(), DENSE_RANK() partitioned by department, ordered by salary descending.

CREATE TABLE employees (
  employee_id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  department TEXT NOT NULL,
  salary INTEGER NOT NULL
);

INSERT INTO employees VALUES
(1, 'Alice Johnson', 'Engineering', 95000),
(2, 'Bob Smith', 'Engineering', 95000),
(3, 'Carol White', 'Engineering', 85000),
(4, 'David Brown', 'Engineering', 85000),
(5, 'Eve Davis', 'Engineering', 75000),
(6, 'Frank Miller', 'Sales', 90000),
(7, 'Grace Lee', 'Sales', 85000),
(8, 'Henry Wilson', 'Sales', 85000),
(9, 'Iris Martinez', 'Sales', 70000),
(10, 'Jack Taylor', 'HR', 80000),
(11, 'Karen Anderson', 'HR', 75000),
(12, 'Leo Thomas', 'HR', 75000);

WITH ranked_employees AS (
  SELECT
    employee_id,
    name,
    department,
    salary,
    ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC) AS row_num,
    RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS rank_pos,
    DENSE_RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS dense_rank_pos
  FROM employees
)
SELECT
  department,
  name,
  salary,
  row_num,
  rank_pos,
  dense_rank_pos
FROM ranked_employees
ORDER BY department, dense_rank_pos;

-- Result (verified in SQLite):
-- department | name | salary | row_num | rank_pos | dense_rank_pos
-- Engineering | Alice Johnson | 95000 | 1 | 1 | 1
-- Engineering | Bob Smith | 95000 | 2 | 1 | 1
-- Engineering | Carol White | 85000 | 3 | 3 | 2
-- Engineering | David Brown | 85000 | 4 | 3 | 2
-- Engineering | Eve Davis | 75000 | 5 | 5 | 3
-- HR | Jack Taylor | 80000 | 1 | 1 | 1
-- HR | Karen Anderson | 75000 | 2 | 2 | 2
-- HR | Leo Thomas | 75000 | 3 | 2 | 2
-- Sales | Frank Miller | 90000 | 1 | 1 | 1
-- Sales | Grace Lee | 85000 | 2 | 2 | 2
-- Sales | Henry Wilson | 85000 | 3 | 2 | 2
-- Sales | Iris Martinez | 70000 | 4 | 4 | 3
