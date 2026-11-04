-- Title: Generate Daily Event Report Date Series
-- Business Question: Create a complete daily date series from the first to last event date in our system,
-- then count how many events occurred on each date, filling in zeros for dates with no events.
-- Technique: Recursive CTE to generate continuous date range, then LEFT JOIN with aggregated events.

CREATE TABLE events (
  event_id INTEGER PRIMARY KEY,
  event_date DATE NOT NULL,
  event_type TEXT NOT NULL,
  user_id INTEGER NOT NULL
);

INSERT INTO events VALUES
(1, '2024-01-01', 'login', 101),
(2, '2024-01-01', 'purchase', 102),
(3, '2024-01-03', 'login', 103),
(4, '2024-01-03', 'logout', 101),
(5, '2024-01-03', 'purchase', 104),
(6, '2024-01-05', 'login', 105),
(7, '2024-01-06', 'purchase', 102),
(8, '2024-01-08', 'logout', 103),
(9, '2024-01-10', 'login', 106),
(10, '2024-01-10', 'purchase', 107);

WITH RECURSIVE date_series AS (
  SELECT MIN(event_date) AS report_date FROM events
  UNION ALL
  SELECT DATE(report_date, '+1 day')
  FROM date_series
  WHERE report_date < (SELECT MAX(event_date) FROM events)
)
SELECT
  ds.report_date,
  COALESCE(COUNT(e.event_id), 0) AS event_count,
  COUNT(DISTINCT CASE WHEN e.event_type = 'login' THEN e.event_id END) AS login_count,
  COUNT(DISTINCT CASE WHEN e.event_type = 'purchase' THEN e.event_id END) AS purchase_count
FROM date_series ds
LEFT JOIN events e ON ds.report_date = e.event_date
GROUP BY ds.report_date
ORDER BY ds.report_date;

-- Result (verified in SQLite):
-- report_date | event_count | login_count | purchase_count
-- 2024-01-01 | 2 | 1 | 1
-- 2024-01-02 | 0 | 0 | 0
-- 2024-01-03 | 3 | 1 | 1
-- 2024-01-04 | 0 | 0 | 0
-- 2024-01-05 | 1 | 1 | 0
-- 2024-01-06 | 1 | 0 | 1
-- 2024-01-07 | 0 | 0 | 0
-- 2024-01-08 | 1 | 0 | 0
-- 2024-01-09 | 0 | 0 | 0
-- 2024-01-10 | 2 | 1 | 1
