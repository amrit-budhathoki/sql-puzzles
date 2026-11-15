-- Title: Extract and Count Skills from Messy Job Descriptions

-- Business Question: Parse comma and semicolon-separated skills from job descriptions,
-- clean whitespace, and count unique skills across all postings.
-- Technique: String splitting using REPLACE and SUBSTR with recursive CTEs.

CREATE TABLE job_postings (
  job_id INTEGER PRIMARY KEY,
  title TEXT,
  skills_raw TEXT
);

INSERT INTO job_postings VALUES
(1, 'Senior Developer', 'Python, JavaScript ; SQL'),
(2, 'Data Analyst', 'SQL;  Excel , Python, Tableau'),
(3, 'DevOps Engineer', 'Docker, Kubernetes ; AWS, Linux'),
(4, 'Frontend Dev', 'JavaScript, React ; CSS , HTML'),
(5, 'Database Admin', 'SQL Server; PostgreSQL , Oracle'),
(6, 'QA Tester', 'Selenium, Python ;  TestNG, Java'),
(7, 'Cloud Architect', 'AWS ; Azure, GCP , Terraform'),
(8, 'ML Engineer', 'Python, TensorFlow ; PyTorch , Pandas');

WITH RECURSIVE skill_split AS (
  SELECT
    job_id,
    TRIM(SUBSTR(
      REPLACE(REPLACE(skills_raw, ';', ','), ',', ',' || CHAR(10)),
      0,
      INSTR(REPLACE(REPLACE(skills_raw, ';', ','), ',', ',' || CHAR(10)), CHAR(10))
    )) AS skill,
    REPLACE(REPLACE(skills_raw, ';', ','), ',', ',' || CHAR(10)) AS remaining
  FROM job_postings
  WHERE skills_raw IS NOT NULL

  UNION ALL

  SELECT
    job_id,
    TRIM(SUBSTR(
      remaining,
      INSTR(remaining, CHAR(10)) + 1,
      INSTR(SUBSTR(remaining, INSTR(remaining, CHAR(10)) + 1), CHAR(10)) - 1
    )),
    SUBSTR(remaining, INSTR(remaining, CHAR(10)) + 1)
  FROM skill_split
  WHERE INSTR(remaining, CHAR(10)) > 0
)
SELECT
  TRIM(skill) AS cleaned_skill,
  COUNT(DISTINCT job_id) AS job_count
FROM skill_split
WHERE TRIM(skill) != ''
GROUP BY TRIM(skill)
ORDER BY job_count DESC, cleaned_skill;

-- Result (verified in SQLite):
-- cleaned_skill | job_count
-- 
 | 8
-- Python, | 3
-- AWS , | 1
-- AWS, | 1
-- Azure, | 1
-- CSS , | 1
-- Docker, | 1
-- Excel , | 1
-- GCP , | 1
-- JavaScript , | 1
-- JavaScript, | 1
-- Kubernetes , | 1
-- PostgreSQL , | 1
-- PyTorch , | 1
-- Python , | 1
-- React , | 1
-- SQL Server, | 1
-- SQL, | 1
-- Selenium, | 1
-- TensorFlow , | 1
