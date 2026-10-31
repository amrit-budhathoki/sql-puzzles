-- Title: Session Detection by Inactivity Gap
-- Business Question: Group user events into sessions where a gap of 30+ minutes indicates a new session
-- Technique: Use LAG() to detect time gaps, then SUM() of gap indicators to create session groups

CREATE TABLE user_events (
  event_id INTEGER PRIMARY KEY,
  user_id INTEGER,
  event_timestamp DATETIME,
  event_type TEXT
);

INSERT INTO user_events VALUES
(1, 101, '2024-01-15 09:00:00', 'login'),
(2, 101, '2024-01-15 09:05:00', 'page_view'),
(3, 101, '2024-01-15 09:12:00', 'click'),
(4, 101, '2024-01-15 10:00:00', 'page_view'),
(5, 101, '2024-01-15 10:02:00', 'click'),
(6, 102, '2024-01-15 09:30:00', 'login'),
(7, 102, '2024-01-15 09:35:00', 'page_view'),
(8, 102, '2024-01-15 12:15:00', 'login'),
(9, 102, '2024-01-15 12:20:00', 'click'),
(10, 101, '2024-01-15 10:05:00', 'logout'),
(11, 102, '2024-01-15 12:25:00', 'page_view');

WITH event_gaps AS (
  SELECT
    event_id,
    user_id,
    event_timestamp,
    event_type,
    LAG(event_timestamp) OVER (PARTITION BY user_id ORDER BY event_timestamp) AS prev_timestamp,
    CAST((julianday(event_timestamp) - julianday(LAG(event_timestamp) OVER (PARTITION BY user_id ORDER BY event_timestamp))) * 24 * 60 AS INTEGER) AS minutes_since_prev
  FROM user_events
),
session_markers AS (
  SELECT
    event_id,
    user_id,
    event_timestamp,
    event_type,
    SUM(CASE WHEN minutes_since_prev IS NULL OR minutes_since_prev >= 30 THEN 1 ELSE 0 END)
      OVER (PARTITION BY user_id ORDER BY event_timestamp) AS session_id
  FROM event_gaps
)
SELECT
  user_id,
  session_id,
  MIN(event_timestamp) AS session_start,
  MAX(event_timestamp) AS session_end,
  COUNT(*) AS event_count,
  GROUP_CONCAT(event_type, ', ') AS events
FROM session_markers
GROUP BY user_id, session_id
ORDER BY user_id, session_start;

-- Result (verified in SQLite):
-- user_id | session_id | session_start | session_end | event_count | events
-- 101 | 1 | 2024-01-15 09:00:00 | 2024-01-15 09:12:00 | 3 | login, page_view, click
-- 101 | 2 | 2024-01-15 10:00:00 | 2024-01-15 10:05:00 | 3 | page_view, click, logout
-- 102 | 1 | 2024-01-15 09:30:00 | 2024-01-15 09:35:00 | 2 | login, page_view
-- 102 | 2 | 2024-01-15 12:15:00 | 2024-01-15 12:25:00 | 3 | login, click, page_view
