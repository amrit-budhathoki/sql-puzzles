-- Title: Generate Missing Dates in Appointment Schedule
-- Business Question: A clinic has appointments on certain dates. Generate a complete date series 
-- from the minimum to maximum appointment date and identify which dates have no appointments scheduled.
-- Technique: Recursive CTE to generate a continuous date range, then LEFT JOIN to find gaps.

CREATE TABLE appointments (
  appointment_id INTEGER PRIMARY KEY,
  appointment_date DATE NOT NULL,
  patient_name TEXT NOT NULL,
  doctor_name TEXT NOT NULL
);

INSERT INTO appointments (appointment_id, appointment_date, patient_name, doctor_name) VALUES
(1, '2024-01-02', 'Alice Johnson', 'Dr. Smith'),
(2, '2024-01-02', 'Bob Williams', 'Dr. Jones'),
(3, '2024-01-04', 'Charlie Brown', 'Dr. Smith'),
(4, '2024-01-07', 'Diana Prince', 'Dr. Wilson'),
(5, '2024-01-07', 'Eve Davis', 'Dr. Jones'),
(6, '2024-01-10', 'Frank Miller', 'Dr. Smith'),
(7, '2024-01-12', 'Grace Lee', 'Dr. Wilson'),
(8, '2024-01-15', 'Henry Zhang', 'Dr. Jones');

WITH date_range AS (
  SELECT MIN(appointment_date) AS min_date, MAX(appointment_date) AS max_date FROM appointments
),
all_dates AS (
  SELECT date_range.min_date AS date_value
  FROM date_range
  UNION ALL
  SELECT DATE(all_dates.date_value, '+1 day')
  FROM all_dates, date_range
  WHERE all_dates.date_value < date_range.max_date
),
scheduled_dates AS (
  SELECT DISTINCT appointment_date FROM appointments
)
SELECT
  all_dates.date_value AS calendar_date,
  COALESCE(COUNT(appointments.appointment_id), 0) AS appointment_count,
  CASE WHEN COUNT(appointments.appointment_id) = 0 THEN 'No Appointments' ELSE 'Scheduled' END AS status
FROM all_dates
LEFT JOIN appointments ON all_dates.date_value = appointments.appointment_date
GROUP BY all_dates.date_value
ORDER BY all_dates.date_value;

-- Result (verified in SQLite):
-- calendar_date | appointment_count | status
-- 2024-01-02 | 2 | Scheduled
-- 2024-01-03 | 0 | No Appointments
-- 2024-01-04 | 1 | Scheduled
-- 2024-01-05 | 0 | No Appointments
-- 2024-01-06 | 0 | No Appointments
-- 2024-01-07 | 2 | Scheduled
-- 2024-01-08 | 0 | No Appointments
-- 2024-01-09 | 0 | No Appointments
-- 2024-01-10 | 1 | Scheduled
-- 2024-01-11 | 0 | No Appointments
-- 2024-01-12 | 1 | Scheduled
-- 2024-01-13 | 0 | No Appointments
-- 2024-01-14 | 0 | No Appointments
-- 2024-01-15 | 1 | Scheduled
