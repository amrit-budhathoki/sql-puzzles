-- Title: Second Highest Test Score Per Student Class

-- Business Question: For each class, identify the second highest test score achieved by students.
-- Technique: Use ROW_NUMBER() window function to rank scores within each class, then filter for rank = 2.

CREATE TABLE test_scores (
  score_id INTEGER PRIMARY KEY,
  student_name TEXT NOT NULL,
  class_name TEXT NOT NULL,
  score INTEGER NOT NULL
);

INSERT INTO test_scores (student_name, class_name, score) VALUES
('Alice', 'Math 101', 95),
('Bob', 'Math 101', 87),
('Charlie', 'Math 101', 92),
('Diana', 'Math 101', 88),
('Eve', 'Math 101', 90),
('Frank', 'English 201', 88),
('Grace', 'English 201', 92),
('Henry', 'English 201', 85),
('Ivy', 'English 201', 90),
('Jack', 'English 201', 87),
('Karen', 'Science 301', 78),
('Liam', 'Science 301', 82);

WITH ranked_scores AS (
  SELECT
    class_name,
    student_name,
    score,
    ROW_NUMBER() OVER (PARTITION BY class_name ORDER BY score DESC) AS rank
  FROM test_scores
)
SELECT
  class_name,
  student_name,
  score AS second_highest_score
FROM ranked_scores
WHERE rank = 2
ORDER BY class_name;

-- Result (verified in SQLite):
-- class_name | student_name | second_highest_score
-- English 201 | Ivy | 90
-- Math 101 | Charlie | 92
-- Science 301 | Karen | 78
