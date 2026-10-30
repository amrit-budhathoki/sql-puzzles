-- Title: Top 3 Blog Posts by Views Per Author

-- Business Question: For each blog author, identify their top 3 most viewed posts
-- Technique: Window function ROW_NUMBER() to rank posts within each author group, then filter top N

CREATE TABLE authors (
  author_id INTEGER PRIMARY KEY,
  author_name TEXT NOT NULL
);

CREATE TABLE posts (
  post_id INTEGER PRIMARY KEY,
  author_id INTEGER NOT NULL,
  post_title TEXT NOT NULL,
  view_count INTEGER NOT NULL,
  published_date DATE NOT NULL,
  FOREIGN KEY (author_id) REFERENCES authors(author_id)
);

INSERT INTO authors (author_id, author_name) VALUES
(1, 'Alice Chen'),
(2, 'Bob Martinez'),
(3, 'Carol Williams');

INSERT INTO posts (post_id, author_id, post_title, view_count, published_date) VALUES
(101, 1, 'SQL Tips for Beginners', 4500, '2024-01-15'),
(102, 1, 'Advanced Query Optimization', 3200, '2024-02-10'),
(103, 1, 'Window Functions Explained', 2800, '2024-03-05'),
(104, 1, 'Indexing Best Practices', 1500, '2024-03-20'),
(105, 2, 'Python Data Analysis', 5600, '2024-01-20'),
(106, 2, 'Machine Learning Basics', 4100, '2024-02-15'),
(107, 2, 'Deep Learning Guide', 3400, '2024-03-10'),
(108, 2, 'Data Visualization Tricks', 2100, '2024-03-25'),
(109, 3, 'Web Development Trends', 3800, '2024-02-01'),
(110, 3, 'React Hooks Deep Dive', 2900, '2024-02-20'),
(111, 3, 'CSS Grid Mastery', 2200, '2024-03-15'),
(112, 3, 'JavaScript Async Patterns', 1800, '2024-04-01');

WITH ranked_posts AS (
  SELECT
    a.author_name,
    p.post_title,
    p.view_count,
    p.published_date,
    ROW_NUMBER() OVER (PARTITION BY p.author_id ORDER BY p.view_count DESC) AS rank
  FROM posts p
  JOIN authors a ON p.author_id = a.author_id
)
SELECT
  author_name,
  post_title,
  view_count,
  published_date,
  rank
FROM ranked_posts
WHERE rank <= 3
ORDER BY author_name, rank;

-- Result (verified in SQLite):
-- author_name | post_title | view_count | published_date | rank
-- Alice Chen | SQL Tips for Beginners | 4500 | 2024-01-15 | 1
-- Alice Chen | Advanced Query Optimization | 3200 | 2024-02-10 | 2
-- Alice Chen | Window Functions Explained | 2800 | 2024-03-05 | 3
-- Bob Martinez | Python Data Analysis | 5600 | 2024-01-20 | 1
-- Bob Martinez | Machine Learning Basics | 4100 | 2024-02-15 | 2
-- Bob Martinez | Deep Learning Guide | 3400 | 2024-03-10 | 3
-- Carol Williams | Web Development Trends | 3800 | 2024-02-01 | 1
-- Carol Williams | React Hooks Deep Dive | 2900 | 2024-02-20 | 2
-- Carol Williams | CSS Grid Mastery | 2200 | 2024-03-15 | 3
