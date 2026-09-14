USE bookmart;

-- ============================================
-- SECTION A - THEORY
-- ============================================

-- A1. Answer: b
-- A2. Answer: c
-- A3. Answer: c
-- A4. Answer: b
-- A5. Answer: b
-- A6. Answer: b
-- A7. Answer: b
-- A8. Answer: b


-- ============================================
-- SECTION B - OUTPUT PREDICTION
-- ============================================

-- B1. 25 rows
SELECT COUNT(*) AS row_count
FROM books b
INNER JOIN authors a
    ON b.author_id = a.author_id;
    
-- B2. 0 rows
SELECT COUNT(*) AS row_count
FROM authors a
LEFT JOIN books b
    ON a.author_id = b.author_id
WHERE b.book_id IS NULL;

-- B3
-- Returns 3 rows:
-- Preeti Shenoy -> Chetan Bhagat
-- Alex Michaelides -> Yuval Harari
-- Malcolm Gladwell -> Yuval Harari

SELECT a.name AS author,
       m.name AS mentor
FROM authors a
JOIN authors m
    ON a.mentor_id = m.author_id;
    
-- B4
-- Returns 5 rows after UNION removes duplicate names.
SELECT name
FROM authors
WHERE country = 'India'

UNION

SELECT a.name
FROM authors a
JOIN books b
    ON a.author_id = b.author_id
WHERE b.genre = 'Mythology';

-- B5
-- Returns one value: 13
SELECT COUNT(*) AS book_count
FROM books
WHERE price > (
    SELECT AVG(price)
    FROM books
);

-- B6
-- Returns 15 rows: books that have never been sold.
SELECT *
FROM books b
WHERE NOT EXISTS (
    SELECT 1
    FROM sales s
    WHERE s.book_id = b.book_id
);

-- B7
-- Returns 1 row:
-- Atomic Habits | 30
SELECT b.title,
       SUM(s.quantity) AS total_qty
FROM sales s
JOIN books b
    ON s.book_id = b.book_id
GROUP BY b.book_id, b.title
ORDER BY total_qty DESC
LIMIT 1;

-- B8
-- Returns the Business books ranked by price from highest to lowest:
-- Talking to Strangers | 549.00 | 1
-- Outliers              | 449.00 | 2
-- Blink                 | 399.00 | 3
-- Rich Dad Poor Dad     | 299.00 | 4
SELECT title,
       price,
       RANK() OVER (
           PARTITION BY genre
           ORDER BY price DESC
       ) AS rank_in_genre
FROM books
WHERE genre = 'Business';

-- ============================================
-- SECTION C - APPLIED SQL
-- ============================================

-- C1
SELECT b.title, a.name AS author
FROM books b
INNER JOIN authors a
    ON b.author_id = a.author_id;


-- C2
SELECT a.name AS author, b.title AS book
FROM authors a
LEFT JOIN books b
    ON a.author_id = b.author_id;


-- C3
SELECT b.genre,
       SUM(s.quantity * b.price) AS revenue
FROM sales s
INNER JOIN books b
    ON s.book_id = b.book_id
GROUP BY b.genre
ORDER BY revenue DESC;

-- C4
SELECT s.city,
       SUM(s.quantity * b.price) AS revenue
FROM sales s
INNER JOIN books b
    ON s.book_id = b.book_id
GROUP BY s.city
ORDER BY revenue DESC
LIMIT 1;

-- C5
SELECT a.name AS author, b.title AS book
FROM authors a
RIGHT JOIN books b
    ON a.author_id = b.author_id;
    
-- C6
SELECT a.author_id, a.name, b.book_id, b.title
FROM authors a
LEFT JOIN books b
    ON a.author_id = b.author_id

UNION

SELECT a.author_id, a.name, b.book_id, b.title
FROM authors a
RIGHT JOIN books b
    ON a.author_id = b.author_id;
    
-- C7
SELECT a.name AS author,
       m.name AS mentor
FROM authors a
INNER JOIN authors m
    ON a.mentor_id = m.author_id;
    
-- C8
SELECT c.city, t.customer_type
FROM (SELECT DISTINCT city FROM sales) c
CROSS JOIN (SELECT DISTINCT customer_type FROM sales) t;

-- C9
SELECT name
FROM authors
WHERE country = 'India'

UNION

SELECT name
FROM authors
WHERE born_year > 1970;

-- C10
SELECT b.*
FROM books b
LEFT JOIN sales s
    ON b.book_id = s.book_id
WHERE s.book_id IS NULL;

-- C11
SELECT *
FROM books
WHERE price > (
    SELECT AVG(price)
    FROM books
);

-- C12
SELECT *
FROM sales
WHERE book_id IN (
    SELECT book_id
    FROM books
    WHERE genre IN ('History', 'Mythology')
);

-- C13
SELECT *
FROM books
WHERE price > ALL (
    SELECT price
    FROM books
    WHERE genre = 'Fiction'
);

-- C14
SELECT b.*
FROM books b
WHERE b.price > (
    SELECT AVG(b2.price)
    FROM books b2
    WHERE b2.genre = b.genre
);

-- C15
SELECT a.*
FROM authors a
WHERE EXISTS (
    SELECT 1
    FROM books b
    WHERE b.author_id = a.author_id
      AND b.published_year > 2018
);

-- C16
SELECT a.*
FROM authors a
WHERE NOT EXISTS (
    SELECT 1
    FROM books b
    WHERE b.author_id = a.author_id
      AND b.genre = 'Business'
);

-- C17
SELECT *
FROM sales
WHERE book_id IN (
    SELECT b.book_id
    FROM books b
    INNER JOIN authors a
        ON b.author_id = a.author_id
    WHERE a.country = 'India'
);

-- C18
SELECT title,
       genre,
       price,
       AVG(price) OVER (PARTITION BY genre) AS genre_avg_price
FROM books;

-- C19
SELECT *
FROM (
    SELECT b.*,
           ROW_NUMBER() OVER (
               PARTITION BY genre
               ORDER BY price DESC, title
           ) AS rn
    FROM books b
) ranked
WHERE rn <= 2;

-- C20
SELECT sale_id,
       book_id,
       sale_date,
       quantity,
       LAG(quantity) OVER (
           ORDER BY sale_date
       ) AS previous_quantity
FROM sales
WHERE book_id = 115
ORDER BY sale_date;

-- C21
SELECT sale_id,
       book_id,
       sale_date,
       quantity,
       SUM(quantity) OVER (
           ORDER BY sale_date
       ) AS running_total
FROM sales
ORDER BY sale_date;

-- C22
WITH book_sales AS (
    SELECT book_id,
           SUM(quantity) AS total_quantity
    FROM sales
    GROUP BY book_id
)
SELECT b.title,
       bs.total_quantity
FROM books b
INNER JOIN book_sales bs
    ON b.book_id = bs.book_id;
    
-- C23
WITH genre_revenue AS (
    SELECT b.genre,
           SUM(s.quantity * b.price) AS revenue
    FROM sales s
    INNER JOIN books b
        ON s.book_id = b.book_id
    GROUP BY b.genre
),
ranked_genres AS (
    SELECT genre,
           revenue,
           RANK() OVER (ORDER BY revenue DESC) AS revenue_rank
    FROM genre_revenue
)
SELECT genre,
       revenue,
       revenue_rank
FROM ranked_genres
ORDER BY revenue_rank;

-- C24
WITH book_sales AS (
    SELECT b.book_id,
           b.title,
           b.author_id,
           b.genre,
           COALESCE(SUM(s.quantity), 0) AS total_quantity,
           COALESCE(SUM(s.quantity * b.price), 0) AS book_revenue
    FROM books b
    LEFT JOIN sales s
        ON b.book_id = s.book_id
    GROUP BY b.book_id, b.title, b.author_id, b.genre
),
ranked_books AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY genre
               ORDER BY total_quantity DESC, title
           ) AS rn
    FROM book_sales
),
genre_revenue AS (
    SELECT genre,
           SUM(book_revenue) AS total_revenue
    FROM book_sales
    GROUP BY genre
)
SELECT rb.genre,
       rb.title,
       a.name AS author,
       rb.total_quantity,
       gr.total_revenue
FROM ranked_books rb
JOIN authors a
    ON rb.author_id = a.author_id
JOIN genre_revenue gr
    ON rb.genre = gr.genre
WHERE rb.rn = 1
ORDER BY gr.total_revenue DESC;
