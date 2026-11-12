-- Title: Identify and Keep Latest Sensor Reading Per Device

-- Business Question: We have duplicate sensor readings from IoT devices due to
-- network retransmissions. Find all duplicates (same device_id, same reading_value)
-- and keep only the most recent one, then display the cleaned dataset.

-- Technique: Use ROW_NUMBER() window function partitioned by device_id and
-- reading_value, ordered by timestamp DESC, to rank duplicates and filter to rank 1.

CREATE TABLE sensor_readings (
  reading_id INTEGER PRIMARY KEY,
  device_id INTEGER NOT NULL,
  reading_value REAL NOT NULL,
  reading_timestamp DATETIME NOT NULL
);

INSERT INTO sensor_readings (device_id, reading_value, reading_timestamp) VALUES
(101, 22.5, '2024-01-15 10:00:00'),
(101, 22.5, '2024-01-15 10:00:15'),
(101, 22.5, '2024-01-15 10:00:30'),
(102, 18.3, '2024-01-15 10:05:00'),
(102, 18.3, '2024-01-15 10:05:10'),
(103, 25.1, '2024-01-15 10:10:00'),
(101, 23.2, '2024-01-15 10:15:00'),
(101, 23.2, '2024-01-15 10:15:05'),
(102, 19.7, '2024-01-15 10:20:00'),
(103, 25.1, '2024-01-15 10:25:00'),
(103, 25.1, '2024-01-15 10:25:30');

WITH ranked_readings AS (
  SELECT
    reading_id,
    device_id,
    reading_value,
    reading_timestamp,
    ROW_NUMBER() OVER (
      PARTITION BY device_id, reading_value
      ORDER BY reading_timestamp DESC
    ) AS rn
  FROM sensor_readings
)
SELECT
  reading_id,
  device_id,
  reading_value,
  reading_timestamp
FROM ranked_readings
WHERE rn = 1
ORDER BY device_id, reading_timestamp;

-- Result (verified in SQLite):
-- reading_id | device_id | reading_value | reading_timestamp
-- 3 | 101 | 22.5 | 2024-01-15 10:00:30
-- 8 | 101 | 23.2 | 2024-01-15 10:15:05
-- 5 | 102 | 18.3 | 2024-01-15 10:05:10
-- 9 | 102 | 19.7 | 2024-01-15 10:20:00
-- 11 | 103 | 25.1 | 2024-01-15 10:25:30
