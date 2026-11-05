-- Title: Detect Outlier Page Load Times by Server
-- Business Question: Which server requests have unusually slow page load times compared to their server's average?
-- Technique: Calculate per-server average and standard deviation, flag requests exceeding mean + 2*stddev as outliers

CREATE TABLE server_requests (
  request_id INTEGER PRIMARY KEY,
  server_name TEXT NOT NULL,
  load_time_ms INTEGER NOT NULL,
  request_date DATE NOT NULL
);

INSERT INTO server_requests VALUES
(1, 'web-01', 125, '2024-01-15'),
(2, 'web-01', 132, '2024-01-15'),
(3, 'web-01', 128, '2024-01-15'),
(4, 'web-01', 850, '2024-01-15'),
(5, 'web-02', 245, '2024-01-15'),
(6, 'web-02', 251, '2024-01-15'),
(7, 'web-02', 248, '2024-01-15'),
(8, 'web-02', 1200, '2024-01-15'),
(9, 'web-03', 89, '2024-01-15'),
(10, 'web-03', 92, '2024-01-15'),
(11, 'web-03', 91, '2024-01-15'),
(12, 'web-03', 520, '2024-01-15');

WITH server_stats AS (
  SELECT
    server_name,
    AVG(load_time_ms) as avg_load_time,
    SQRT(AVG((load_time_ms - (SELECT AVG(load_time_ms) FROM server_requests sr2 WHERE sr2.server_name = server_requests.server_name)) * (load_time_ms - (SELECT AVG(load_time_ms) FROM server_requests sr2 WHERE sr2.server_name = server_requests.server_name)))) as stddev_load_time
  FROM server_requests
  GROUP BY server_name
)
SELECT
  sr.request_id,
  sr.server_name,
  sr.load_time_ms,
  ss.avg_load_time,
  ss.stddev_load_time,
  ROUND(sr.load_time_ms - ss.avg_load_time, 2) as deviation_ms,
  CASE
    WHEN sr.load_time_ms > ss.avg_load_time + (2 * ss.stddev_load_time) THEN 'OUTLIER'
    ELSE 'NORMAL'
  END as status
FROM server_requests sr
JOIN server_stats ss ON sr.server_name = ss.server_name
ORDER BY ss.server_name, sr.load_time_ms DESC;

-- Result (verified in SQLite):
-- request_id | server_name | load_time_ms | avg_load_time | stddev_load_time | deviation_ms | status
-- 4 | web-01 | 850 | 308.75 | 312.500699999216 | 541.25 | NORMAL
-- 2 | web-01 | 132 | 308.75 | 312.500699999216 | -176.75 | NORMAL
-- 3 | web-01 | 128 | 308.75 | 312.500699999216 | -180.75 | NORMAL
-- 1 | web-01 | 125 | 308.75 | 312.500699999216 | -183.75 | NORMAL
-- 8 | web-02 | 1200 | 486.0 | 412.2335503085599 | 714.0 | NORMAL
-- 6 | web-02 | 251 | 486.0 | 412.2335503085599 | -235.0 | NORMAL
-- 7 | web-02 | 248 | 486.0 | 412.2335503085599 | -238.0 | NORMAL
-- 5 | web-02 | 245 | 486.0 | 412.2335503085599 | -241.0 | NORMAL
-- 12 | web-03 | 520 | 198.0 | 185.90992442578207 | 322.0 | NORMAL
-- 10 | web-03 | 92 | 198.0 | 185.90992442578207 | -106.0 | NORMAL
-- 11 | web-03 | 91 | 198.0 | 185.90992442578207 | -107.0 | NORMAL
-- 9 | web-03 | 89 | 198.0 | 185.90992442578207 | -109.0 | NORMAL
