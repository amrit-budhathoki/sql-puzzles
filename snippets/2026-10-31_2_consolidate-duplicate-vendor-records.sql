-- Title: Consolidate Duplicate Vendor Records
-- Business Question: Our vendor database has accumulated duplicate entries with slightly different formatting.
-- Identify duplicate vendors (same normalized name and city) and keep only the record with the lowest ID,
-- then show the cleaned vendor list without duplicates.
-- Technique: Use ROW_NUMBER() window function to rank duplicates, filter for the primary record,
-- then JOIN to remove duplicate IDs from the final result set.

CREATE TABLE vendors (
  vendor_id INTEGER PRIMARY KEY,
  vendor_name TEXT,
  city TEXT,
  contact_email TEXT,
  created_date DATE
);

INSERT INTO vendors VALUES
(1, 'Acme Corp', 'New York', 'contact@acme.com', '2023-01-15'),
(2, 'ACME CORP', 'New York', 'sales@acme.com', '2023-02-20'),
(3, 'Acme Corp.', 'New York', 'info@acme.com', '2023-03-10'),
(4, 'Global Supplies Inc', 'Chicago', 'hello@globalsup.com', '2023-01-05'),
(5, 'Global Supplies Inc', 'Chicago', 'contact@globalsup.com', '2023-02-14'),
(6, 'TechParts Ltd', 'Boston', 'sales@techparts.com', '2023-01-20'),
(7, 'TechParts LTD', 'Boston', 'support@techparts.com', '2023-03-05'),
(8, 'Premier Distribution', 'Seattle', 'bd@premier.com', '2023-02-28'),
(9, 'DataSoft Solutions', 'Austin', 'info@datasoft.com', '2023-01-10'),
(10, 'datasoft solutions', 'Austin', 'contact@datasoft.com', '2023-02-22');

WITH ranked_vendors AS (
  SELECT
    vendor_id,
    TRIM(UPPER(vendor_name)) AS normalized_name,
    city,
    contact_email,
    created_date,
    ROW_NUMBER() OVER (PARTITION BY TRIM(UPPER(vendor_name)), city ORDER BY vendor_id) AS rn
  FROM vendors
),
primary_vendors AS (
  SELECT vendor_id
  FROM ranked_vendors
  WHERE rn = 1
)
SELECT
  v.vendor_id,
  v.vendor_name,
  v.city,
  v.contact_email,
  v.created_date
FROM vendors v
WHERE v.vendor_id IN (SELECT vendor_id FROM primary_vendors)
ORDER BY v.vendor_id;

-- Result (verified in SQLite):
-- vendor_id | vendor_name | city | contact_email | created_date
-- 1 | Acme Corp | New York | contact@acme.com | 2023-01-15
-- 3 | Acme Corp. | New York | info@acme.com | 2023-03-10
-- 4 | Global Supplies Inc | Chicago | hello@globalsup.com | 2023-01-05
-- 6 | TechParts Ltd | Boston | sales@techparts.com | 2023-01-20
-- 8 | Premier Distribution | Seattle | bd@premier.com | 2023-02-28
-- 9 | DataSoft Solutions | Austin | info@datasoft.com | 2023-01-10
