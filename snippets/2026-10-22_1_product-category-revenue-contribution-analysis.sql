-- Title: Product Category Revenue Contribution Analysis
-- Business Question: What percentage of total revenue does each product category contribute, ranked by contribution?
-- Technique: Window functions (SUM OVER), aggregate functions, and percentage calculation with CTE

CREATE TABLE sales (
  sale_id INTEGER PRIMARY KEY,
  product_id INTEGER,
  category TEXT,
  amount DECIMAL(10, 2),
  sale_date DATE
);

CREATE TABLE products (
  product_id INTEGER PRIMARY KEY,
  product_name TEXT,
  category TEXT
);

INSERT INTO products VALUES
(1, 'Laptop Pro', 'Electronics'),
(2, 'USB Cable', 'Electronics'),
(3, 'Office Chair', 'Furniture'),
(4, 'Desk Lamp', 'Furniture'),
(5, 'Notebook Set', 'Stationery'),
(6, 'Pen Pack', 'Stationery');

INSERT INTO sales VALUES
(1, 1, 'Electronics', 1200.00, '2024-01-10'),
(2, 2, 'Electronics', 15.50, '2024-01-12'),
(3, 3, 'Furniture', 450.00, '2024-01-15'),
(4, 4, 'Furniture', 89.99, '2024-01-18'),
(5, 5, 'Stationery', 25.00, '2024-01-20'),
(6, 1, 'Electronics', 1200.00, '2024-02-05'),
(7, 6, 'Stationery', 12.50, '2024-02-08'),
(8, 3, 'Furniture', 450.00, '2024-02-10'),
(9, 2, 'Electronics', 15.50, '2024-02-12'),
(10, 5, 'Stationery', 25.00, '2024-02-15');

WITH category_revenue AS (
  SELECT
    category,
    SUM(amount) AS category_total,
    SUM(SUM(amount)) OVER () AS grand_total
  FROM sales
  GROUP BY category
)
SELECT
  category,
  category_total,
  grand_total,
  ROUND(100.0 * category_total / grand_total, 2) AS revenue_percentage
FROM category_revenue
ORDER BY revenue_percentage DESC;

-- Result (verified in SQLite):
-- category | category_total | grand_total | revenue_percentage
-- Electronics | 2431.0 | 3483.49 | 69.79
-- Furniture | 989.99 | 3483.49 | 28.42
-- Stationery | 62.5 | 3483.49 | 1.79
