-- Title: Top 3 Most Recent Visits Per Patient
-- Business Question: For each patient, retrieve their 3 most recent clinic visits
-- Technique: ROW_NUMBER() window function partitioned by patient_id, ordered by visit_date DESC

CREATE TABLE patients (
  patient_id INTEGER PRIMARY KEY,
  patient_name TEXT NOT NULL
);

CREATE TABLE clinic_visits (
  visit_id INTEGER PRIMARY KEY,
  patient_id INTEGER NOT NULL,
  visit_date DATE NOT NULL,
  reason TEXT NOT NULL,
  doctor TEXT NOT NULL,
  FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
);

INSERT INTO patients VALUES
  (1, 'Alice Johnson'),
  (2, 'Bob Smith'),
  (3, 'Carol White');

INSERT INTO clinic_visits VALUES
  (101, 1, '2024-01-10', 'Checkup', 'Dr. Brown'),
  (102, 1, '2024-02-15', 'Follow-up', 'Dr. Green'),
  (103, 1, '2024-03-20', 'Vaccination', 'Dr. Brown'),
  (104, 1, '2024-04-05', 'Checkup', 'Dr. Blue'),
  (105, 2, '2024-01-22', 'Dental', 'Dr. White'),
  (106, 2, '2024-03-10', 'Eye exam', 'Dr. Black'),
  (107, 2, '2024-04-12', 'Follow-up', 'Dr. White'),
  (108, 3, '2024-02-01', 'Checkup', 'Dr. Green'),
  (109, 3, '2024-03-15', 'Lab work', 'Dr. Brown'),
  (110, 3, '2024-04-18', 'Vaccination', 'Dr. Blue'),
  (111, 3, '2024-05-01', 'Follow-up', 'Dr. Green');

WITH ranked_visits AS (
  SELECT
    p.patient_id,
    p.patient_name,
    cv.visit_id,
    cv.visit_date,
    cv.reason,
    cv.doctor,
    ROW_NUMBER() OVER (PARTITION BY p.patient_id ORDER BY cv.visit_date DESC) AS visit_rank
  FROM patients p
  JOIN clinic_visits cv ON p.patient_id = cv.patient_id
)
SELECT
  patient_id,
  patient_name,
  visit_id,
  visit_date,
  reason,
  doctor,
  visit_rank
FROM ranked_visits
WHERE visit_rank <= 3
ORDER BY patient_id, visit_rank;

-- Result (verified in SQLite):
-- patient_id | patient_name | visit_id | visit_date | reason | doctor | visit_rank
-- 1 | Alice Johnson | 104 | 2024-04-05 | Checkup | Dr. Blue | 1
-- 1 | Alice Johnson | 103 | 2024-03-20 | Vaccination | Dr. Brown | 2
-- 1 | Alice Johnson | 102 | 2024-02-15 | Follow-up | Dr. Green | 3
-- 2 | Bob Smith | 107 | 2024-04-12 | Follow-up | Dr. White | 1
-- 2 | Bob Smith | 106 | 2024-03-10 | Eye exam | Dr. Black | 2
-- 2 | Bob Smith | 105 | 2024-01-22 | Dental | Dr. White | 3
-- 3 | Carol White | 111 | 2024-05-01 | Follow-up | Dr. Green | 1
-- 3 | Carol White | 110 | 2024-04-18 | Vaccination | Dr. Blue | 2
-- 3 | Carol White | 109 | 2024-03-15 | Lab work | Dr. Brown | 3
