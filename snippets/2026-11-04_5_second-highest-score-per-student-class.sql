-- Title: Second Highest Score Per Student Class
-- Business Question: Find the second highest exam score achieved by each student in their respective class
-- Technique Used: Window functions (RANK) to identify the second highest score per group, then filter results

CREATE TABLE student_exams (
  exam_id INTEGER PRIMARY KEY,
  student_id INTEGER,
  class_name TEXT,
  exam_score INTEGER,
  exam_date DATE
);

INSERT INTO student_exams VALUES
(1, 101, 'Math-A', 92, '2024-01-15'),
(2, 101, 'Math-A', 88, '2024-02-20'),
(3, 101, 'Math-A', 95, '2024-03-10'),
(4, 101, 'Math-A', 87, '2024-04-05'),
(5, 102, 'Math-A', 78, '2024-01-15'),
(6, 102, 'Math-A', 85, '2024-02-20'),
(7, 102, 'Math-A', 82, '2024-03-10'),
(8, 103, 'Science-B', 91, '2024-01-16'),
(9, 103, 'Science-B', 89, '2024-02-21'),
(10, 103, 'Science-B', 94, '2024-03-11'),
(11, 104, 'Science-B', 76, '2024-01-16'),
(12, 104, 'Science-B', 81, '2024-02-21');

WITH ranked_scores AS (
  SELECT
    student_id,
    class_name,
    exam_score,
    RANK() OVER (PARTITION BY student_id, class_name ORDER BY exam_score DESC) AS score_rank
  FROM student_exams
)
SELECT
  student_id,
  class_name,
  exam_score AS second_highest_score
FROM ranked_scores
WHERE score_rank = 2
ORDER BY class_name, student_id;

-- Result (verified in SQLite):
-- student_id | class_name | second_highest_score
-- 101 | Math-A | 92
-- 102 | Math-A | 82
-- 103 | Science-B | 91
-- 104 | Science-B | 76
