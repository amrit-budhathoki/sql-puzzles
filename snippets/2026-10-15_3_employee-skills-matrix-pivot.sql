-- Title: Employee Skills Matrix Pivot
-- Business Question: Create a matrix showing which employees have which skills
-- Technique: Using CASE expressions to pivot skill records into columns

CREATE TABLE employees (
  employee_id INTEGER PRIMARY KEY,
  employee_name TEXT NOT NULL
);

CREATE TABLE employee_skills (
  employee_id INTEGER NOT NULL,
  skill_name TEXT NOT NULL,
  proficiency_level TEXT NOT NULL,
  FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

INSERT INTO employees VALUES
  (1, 'Alice Johnson'),
  (2, 'Bob Smith'),
  (3, 'Carol White'),
  (4, 'David Brown'),
  (5, 'Eve Davis');

INSERT INTO employee_skills VALUES
  (1, 'Python', 'Expert'),
  (1, 'SQL', 'Intermediate'),
  (1, 'Excel', 'Beginner'),
  (2, 'Python', 'Intermediate'),
  (2, 'SQL', 'Expert'),
  (3, 'Excel', 'Expert'),
  (3, 'Python', 'Beginner'),
  (4, 'SQL', 'Intermediate'),
  (4, 'Excel', 'Intermediate'),
  (5, 'SQL', 'Expert'),
  (5, 'Python', 'Expert');

SELECT
  e.employee_name,
  MAX(CASE WHEN es.skill_name = 'Python' THEN es.proficiency_level ELSE NULL END) AS Python,
  MAX(CASE WHEN es.skill_name = 'SQL' THEN es.proficiency_level ELSE NULL END) AS SQL,
  MAX(CASE WHEN es.skill_name = 'Excel' THEN es.proficiency_level ELSE NULL END) AS Excel
FROM employees e
LEFT JOIN employee_skills es ON e.employee_id = es.employee_id
GROUP BY e.employee_id, e.employee_name
ORDER BY e.employee_name;

-- Result (verified in SQLite):
-- employee_name | Python | SQL | Excel
-- Alice Johnson | Expert | Intermediate | Beginner
-- Bob Smith | Intermediate | Expert | None
-- Carol White | Beginner | None | Expert
-- David Brown | None | Intermediate | Intermediate
-- Eve Davis | Expert | Expert | None
