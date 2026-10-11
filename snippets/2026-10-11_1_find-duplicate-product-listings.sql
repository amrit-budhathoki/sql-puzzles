-- Title: Find Duplicate Product Listings
-- Business Question: Identify products that are listed multiple times in our catalog with different prices
-- Technique: Self join to compare rows within the same table, detecting duplicates by product name
-- but different pricing, which may indicate data quality issues or legitimate variants

CREATE TABLE product_listings (
  listing_id INTEGER PRIMARY KEY,
  product_name TEXT NOT NULL,
  price DECIMAL(10, 2),
  supplier_id INTEGER,
  last_updated DATE
);

INSERT INTO product_listings VALUES
(1, 'Wireless Mouse', 29.99, 101, '2024-01-15'),
(2, 'Wireless Mouse', 34.99, 102, '2024-01-16'),
(3, 'USB-C Cable', 12.99, 101, '2024-01-10'),
(4, 'Mechanical Keyboard', 89.99, 103, '2024-01-14'),
(5, 'Mechanical Keyboard', 79.99, 104, '2024-01-17'),
(6, 'Mechanical Keyboard', 89.99, 103, '2024-01-18'),
(7, 'Monitor Stand', 45.00, 105, '2024-01-12'),
(8, 'HDMI Cable', 8.99, 106, '2024-01-11'),
(9, 'HDMI Cable', 8.99, 106, '2024-01-19'),
(10, 'Desk Lamp', 55.00, 107, '2024-01-13');

SELECT
  a.listing_id,
  a.product_name,
  a.price,
  a.supplier_id,
  b.listing_id AS duplicate_listing_id,
  b.price AS duplicate_price,
  b.supplier_id AS duplicate_supplier_id,
  CASE
    WHEN a.price != b.price THEN 'Price Mismatch'
    WHEN a.supplier_id != b.supplier_id THEN 'Different Supplier'
    ELSE 'Exact Duplicate'
  END AS discrepancy_type
FROM product_listings a
INNER JOIN product_listings b
  ON a.product_name = b.product_name
  AND a.listing_id < b.listing_id
ORDER BY a.product_name, a.listing_id, b.listing_id;

-- Result (verified in SQLite):
-- listing_id | product_name | price | supplier_id | duplicate_listing_id | duplicate_price | duplicate_supplier_id | discrepancy_type
-- 8 | HDMI Cable | 8.99 | 106 | 9 | 8.99 | 106 | Exact Duplicate
-- 4 | Mechanical Keyboard | 89.99 | 103 | 5 | 79.99 | 104 | Price Mismatch
-- 4 | Mechanical Keyboard | 89.99 | 103 | 6 | 89.99 | 103 | Exact Duplicate
-- 5 | Mechanical Keyboard | 79.99 | 104 | 6 | 89.99 | 103 | Price Mismatch
-- 1 | Wireless Mouse | 29.99 | 101 | 2 | 34.99 | 102 | Price Mismatch
