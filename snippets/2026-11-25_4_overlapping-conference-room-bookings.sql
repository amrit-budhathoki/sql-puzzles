-- Title: Overlapping Conference Room Bookings

-- Business Question: Find all pairs of room bookings that overlap in time for the same conference room.
-- Overlapping means one booking starts before another ends.
-- Technique: Self-join on room_id with overlap condition using date range comparison.

CREATE TABLE room_bookings (
  booking_id INTEGER PRIMARY KEY,
  room_id INTEGER NOT NULL,
  booking_name TEXT NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL
);

INSERT INTO room_bookings VALUES
(1, 101, 'Team Standup', '2024-01-15', '2024-01-15'),
(2, 101, 'Budget Review', '2024-01-15', '2024-01-16'),
(3, 101, 'All Hands', '2024-01-17', '2024-01-17'),
(4, 102, 'Client Meeting', '2024-01-15', '2024-01-16'),
(5, 102, 'Project Kickoff', '2024-01-16', '2024-01-17'),
(6, 102, 'Training Session', '2024-01-18', '2024-01-19'),
(7, 103, 'Board Meeting', '2024-01-15', '2024-01-15'),
(8, 103, 'Strategy Planning', '2024-01-15', '2024-01-16'),
(9, 101, 'Sprint Planning', '2024-01-16', '2024-01-16'),
(10, 102, 'Follow-up Call', '2024-01-16', '2024-01-16');

WITH overlaps AS (
  SELECT
    b1.room_id,
    b1.booking_id AS booking_id_1,
    b1.booking_name AS booking_name_1,
    b1.start_date AS start_date_1,
    b1.end_date AS end_date_1,
    b2.booking_id AS booking_id_2,
    b2.booking_name AS booking_name_2,
    b2.start_date AS start_date_2,
    b2.end_date AS end_date_2
  FROM room_bookings b1
  JOIN room_bookings b2
    ON b1.room_id = b2.room_id
    AND b1.booking_id < b2.booking_id
    AND b1.start_date <= b2.end_date
    AND b2.start_date <= b1.end_date
)
SELECT
  room_id,
  booking_id_1,
  booking_name_1,
  start_date_1,
  end_date_1,
  booking_id_2,
  booking_name_2,
  start_date_2,
  end_date_2
FROM overlaps
ORDER BY room_id, booking_id_1, booking_id_2;

-- Result (verified in SQLite):
-- room_id | booking_id_1 | booking_name_1 | start_date_1 | end_date_1 | booking_id_2 | booking_name_2 | start_date_2 | end_date_2
-- 101 | 1 | Team Standup | 2024-01-15 | 2024-01-15 | 2 | Budget Review | 2024-01-15 | 2024-01-16
-- 101 | 2 | Budget Review | 2024-01-15 | 2024-01-16 | 9 | Sprint Planning | 2024-01-16 | 2024-01-16
-- 102 | 4 | Client Meeting | 2024-01-15 | 2024-01-16 | 5 | Project Kickoff | 2024-01-16 | 2024-01-17
-- 102 | 4 | Client Meeting | 2024-01-15 | 2024-01-16 | 10 | Follow-up Call | 2024-01-16 | 2024-01-16
-- 102 | 5 | Project Kickoff | 2024-01-16 | 2024-01-17 | 10 | Follow-up Call | 2024-01-16 | 2024-01-16
-- 103 | 7 | Board Meeting | 2024-01-15 | 2024-01-15 | 8 | Strategy Planning | 2024-01-15 | 2024-01-16
