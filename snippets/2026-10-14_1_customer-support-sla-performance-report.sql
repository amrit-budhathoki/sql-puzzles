-- Title: Customer Support SLA Performance Report
-- Business Question: Generate a KPI report showing ticket response times by priority level,
-- counting how many tickets met SLA targets (resolved within target hours) vs missed SLA
-- Technique: Conditional aggregation using CASE WHEN with COUNT to measure KPI compliance

CREATE TABLE support_tickets (
  ticket_id INTEGER PRIMARY KEY,
  priority TEXT NOT NULL,
  created_at DATETIME NOT NULL,
  resolved_at DATETIME NOT NULL,
  sla_hours INTEGER NOT NULL
);

INSERT INTO support_tickets VALUES
(1, 'critical', '2024-01-10 09:00:00', '2024-01-10 10:30:00', 2),
(2, 'critical', '2024-01-10 14:00:00', '2024-01-10 16:45:00', 2),
(3, 'high', '2024-01-11 08:00:00', '2024-01-11 12:15:00', 4),
(4, 'high', '2024-01-11 10:00:00', '2024-01-11 15:30:00', 4),
(5, 'high', '2024-01-12 09:00:00', '2024-01-12 14:00:00', 4),
(6, 'medium', '2024-01-12 13:00:00', '2024-01-13 14:30:00', 24),
(7, 'medium', '2024-01-13 11:00:00', '2024-01-14 09:00:00', 24),
(8, 'low', '2024-01-14 15:00:00', '2024-01-16 10:00:00', 48),
(9, 'critical', '2024-01-15 12:00:00', '2024-01-15 13:45:00', 2),
(10, 'low', '2024-01-15 09:00:00', '2024-01-17 15:00:00', 48);

SELECT
  priority,
  COUNT(*) as total_tickets,
  SUM(CASE WHEN CAST((julianday(resolved_at) - julianday(created_at)) * 24 AS INTEGER) <= sla_hours THEN 1 ELSE 0 END) as met_sla,
  SUM(CASE WHEN CAST((julianday(resolved_at) - julianday(created_at)) * 24 AS INTEGER) > sla_hours THEN 1 ELSE 0 END) as missed_sla,
  ROUND(100.0 * SUM(CASE WHEN CAST((julianday(resolved_at) - julianday(created_at)) * 24 AS INTEGER) <= sla_hours THEN 1 ELSE 0 END) / COUNT(*), 1) as sla_compliance_pct
FROM support_tickets
GROUP BY priority
ORDER BY CASE WHEN priority = 'critical' THEN 1 WHEN priority = 'high' THEN 2 WHEN priority = 'medium' THEN 3 ELSE 4 END;

-- Result (verified in SQLite):
-- priority | total_tickets | met_sla | missed_sla | sla_compliance_pct
-- critical | 3 | 3 | 0 | 100.0
-- high | 3 | 1 | 2 | 33.3
-- medium | 2 | 1 | 1 | 50.0
-- low | 2 | 1 | 1 | 50.0
