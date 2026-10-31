-- Title: Find Authors With No Published Articles

-- Business Question: Identify all authors in our system who have never published an article.
-- This helps identify inactive authors and potential content gaps.
-- Technique: Anti-join using NOT EXISTS to find records in one table with no matching records in another.

CREATE TABLE authors (
  author_id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT,
  created_date DATE
);

CREATE TABLE articles (
  article_id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  author_id INTEGER,
  published_date DATE,
  FOREIGN KEY (author_id) REFERENCES authors(author_id)
);

INSERT INTO authors VALUES (1, 'Alice Johnson', 'alice@example.com', '2023-01-15');
INSERT INTO authors VALUES (2, 'Bob Smith', 'bob@example.com', '2023-02-20');
INSERT INTO authors VALUES (3, 'Carol White', 'carol@example.com', '2023-03-10');
INSERT INTO authors VALUES (4, 'David Brown', 'david@example.com', '2023-04-05');
INSERT INTO authors VALUES (5, 'Eve Davis', 'eve@example.com', '2023-05-12');
INSERT INTO authors VALUES (6, 'Frank Miller', 'frank@example.com', '2023-06-18');

INSERT INTO articles VALUES (101, 'SQL Basics', 1, '2023-07-01');
INSERT INTO articles VALUES (102, 'Database Design', 1, '2023-07-15');
INSERT INTO articles VALUES (103, 'Optimization Tips', 2, '2023-08-01');
INSERT INTO articles VALUES (104, 'Query Performance', 2, '2023-08-20');
INSERT INTO articles VALUES (105, 'Advanced Joins', 3, '2023-09-10');
INSERT INTO articles VALUES (106, 'Indexing Strategies', 1, '2023-09-25');

SELECT
  a.author_id,
  a.name,
  a.email,
  a.created_date
FROM authors a
WHERE NOT EXISTS (
  SELECT 1
  FROM articles ar
  WHERE ar.author_id = a.author_id
)
ORDER BY a.author_id;

-- Result (verified in SQLite):
-- author_id | name | email | created_date
-- 4 | David Brown | david@example.com | 2023-04-05
-- 5 | Eve Davis | eve@example.com | 2023-05-12
-- 6 | Frank Miller | frank@example.com | 2023-06-18
