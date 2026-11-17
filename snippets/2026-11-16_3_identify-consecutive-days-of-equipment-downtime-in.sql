-- Title: Identify Consecutive Days of Equipment Downtime Incidents

-- Business Question:
-- Equipment maintenance logs record downtime incidents by date.
-- Identify periods of consecutive downtime days (islands) and report
-- the start date, end date, and duration of each continuous incident period.
-- A gap of 1+ days with no incidents ends one island and starts another.

-- Technique:
-- Use ROW_NUMBER() to assign sequence numbers, then subtract from the date
-- to create a "group_id" for consecutive dates. Gaps create new group_ids.
-- GROUP BY the group_id to aggregate islands into start, end, and duration.

CREATE TABLE equipment_downtime (
  incident_id INTEGER PRIMARY KEY,
  equipment_id TEXT NOT NULL,
  incident_date DATE NOT NULL
);

INSERT INTO equipment_downtime VALUES
(1, 'PUMP-01', '2024-01-02'),
(2, 'PUMP-01', '2024-01-03'),
(3, 'PUMP-01', '2024-01-04'),
(4, 'PUMP-01', '2024-01-08'),
(5, 'PUMP-01', '2024-01-09'),
(6, 'MOTOR-02', '2024-01-15'),
(7, 'MOTOR-02', '2024-01-16'),
(8, 'MOTOR-02', '2024-01-17'),
(9, 'MOTOR-02', '2024-01-18'),
(10, 'PUMP-01', '2024-01-20'),
(11, 'MOTOR-02', '2024-01-22'),
(12, 'PUMP-01', '2024-01-21');

WITH dated_incidents AS (
  SELECT
    equipment_id,
    incident_date,
    ROW_NUMBER() OVER (PARTITION BY equipment_id ORDER BY incident_date) AS seq_num
  FROM equipment_downtime
),
island_groups AS (
  SELECT
    equipment_id,
    incident_date,
    DATE(incident_date, '-' || (seq_num - 1) || ' days') AS island_id
  FROM dated_incidents
)
SELECT
  equipment_id,
  MIN(incident_date) AS downtime_start,
  MAX(incident_date) AS downtime_end,
  COUNT(*) AS consecutive_days
FROM island_groups
GROUP BY equipment_id, island_id
ORDER BY equipment_id, downtime_start;

-- Result (verified in SQLite):
-- equipment_id | downtime_start | downtime_end | consecutive_days
-- MOTOR-02 | 2024-01-15 | 2024-01-18 | 4
-- MOTOR-02 | 2024-01-22 | 2024-01-22 | 1
-- PUMP-01 | 2024-01-02 | 2024-01-04 | 3
-- PUMP-01 | 2024-01-08 | 2024-01-09 | 2
-- PUMP-01 | 2024-01-20 | 2024-01-21 | 2
