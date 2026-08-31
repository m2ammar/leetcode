# Write your MySQL query statement below
WITH cte AS (
    SELECT id, email,
    ROW_NUMBER() OVER (PARTITION BY email ORDER BY id) AS cnt
    FROM Person
)

DELETE FROM Person
WHERE id IN (SELECT id FROM cte WHERE cnt > 1);
