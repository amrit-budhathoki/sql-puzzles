-- Title: Employee Training Completion by Skill Level
-- Business Question: Create a matrix showing how many employees completed training at each skill level (Beginner, Intermediate, Advanced)
-- Technique: Use CASE statements to pivot training completion status into separate columns for each skill level

CREATE TABLE training_records (
  employee_id INTEGER,
  employee_name TEXT,
  skill_level TEXT,
  completed BOOLEAN
);

INSERT INTO training_records VALUES
(1, 'Alice Johnson', 'Beginner', 1),
(1, 'Alice Johnson', 'Intermediate', 1),
(1, 'Alice Johnson', 'Advanced', 0),
(2, 'Bob Smith', 'Beginner', 1),
(2, 'Bob Smith', 'Intermediate', 0),
(2, 'Bob Smith', 'Advanced', 0),
(3, 'Carol White', 'Beginner', 1),
(3, 'Carol White', 'Intermediate', 1),
(3, 'Carol White', 'Advanced', 1),
(4, 'David Brown', 'Beginner', 0),
(4, 'David Brown', 'Intermediate', 0),
(4, 'David Brown', 'Advanced', 0),
(5, 'Emma Davis', 'Beginner', 1),
(5, 'Emma Davis', 'Intermediate', 1),
(5, 'Emma Davis', 'Advanced', 0);

SELECT
  employee_id,
  employee_name,
  SUM(CASE WHEN skill_level = 'Beginner' AND completed = 1 THEN 1 ELSE 0 END) AS beginner_complete,
  SUM(CASE WHEN skill_level = 'Intermediate' AND completed = 1 THEN 1 ELSE 0 END) AS intermediate_complete,
  SUM(CASE WHEN skill_level = 'Advanced' AND completed = 1 THEN 1 ELSE 0 END) AS advanced_complete,
  COUNT(*) AS total_trainings,
  SUM(CASE WHEN completed = 1 THEN 1 ELSE 0 END) AS total_completed
FROM training_records
GROUP BY employee_id, employee_name
ORDER BY total_completed DESC, employee_name;

-- Result (verified in SQLite):
-- employee_id | employee_name | beginner_complete | intermediate_complete | advanced_complete | total_trainings | total_completed
-- 3 | Carol White | 1 | 1 | 1 | 3 | 3
-- 1 | Alice Johnson | 1 | 1 | 0 | 3 | 2
-- 5 | Emma Davis | 1 | 1 | 0 | 3 | 2
-- 2 | Bob Smith | 1 | 0 | 0 | 3 | 1
-- 4 | David Brown | 0 | 0 | 0 | 3 | 0
