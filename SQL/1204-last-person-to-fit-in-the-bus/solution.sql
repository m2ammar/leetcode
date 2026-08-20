# Write your MySQL query statement below
WITH cte AS (
    SELECT person_name, turn,
        SUM(weight) OVER(ORDER BY turn ASC) AS p
    FROM Queue
)
SELECT cte.person_name
FROM cte
WHERE cte.p <= 1000
ORDER BY cte.turn DESC
LIMIT 1;
