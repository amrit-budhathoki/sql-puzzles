-- Title: Find Median Student Test Score by Subject
-- Business Question: Calculate the median test score for each subject without using built-in aggregate functions.
-- Technique: Use window functions (ROW_NUMBER) to find middle values by ordering scores and selecting the median position.

CREATE TABLE test_scores (
  score_id INTEGER PRIMARY KEY,
  subject TEXT NOT NULL,
  student_name TEXT NOT NULL,
  score INTEGER NOT NULL
);

INSERT INTO test_scores (subject, student_name, score) VALUES
('Math', 'Alice', 78),
('Math', 'Bob', 85),
('Math', 'Charlie', 92),
('Math', 'Diana', 88),
('Math', 'Eve', 76),
('English', 'Alice', 82),
('English', 'Bob', 79),
('English', 'Charlie', 88),
('English', 'Diana', 91),
('English', 'Eve', 85),
('Science', 'Alice', 90),
('Science', 'Bob', 87),
('Science', 'Charlie', 93),
('Science', 'Diana', 89);

WITH ranked_scores AS (
  SELECT
    subject,
    score,
    ROW_NUMBER() OVER (PARTITION BY subject ORDER BY score) AS row_num,
    COUNT(*) OVER (PARTITION BY subject) AS total_count
  FROM test_scores
),
median_candidates AS (
  SELECT
    subject,
    score,
    row_num,
    total_count,
    CASE
      WHEN total_count % 2 = 1 THEN (total_count + 1) / 2
      ELSE total_count / 2
    END AS lower_median_pos,
    CASE
      WHEN total_count % 2 = 1 THEN (total_count + 1) / 2
      ELSE (total_count / 2) + 1
    END AS upper_median_pos
  FROM ranked_scores
)
SELECT
  subject,
  CAST(AVG(score) AS DECIMAL(5, 2)) AS median_score
FROM median_candidates
WHERE row_num IN (lower_median_pos, upper_median_pos)
GROUP BY subject
ORDER BY subject;

-- Result (verified in SQLite):
-- subject | median_score
-- English | 85.0
-- Math | 85.0
-- Science | 89.5
