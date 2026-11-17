# Write your MySQL query statement below
WITH cte AS (
    SELECT p.user_id,
           pif.category
    FROM ProductPurchases AS p
    JOIN ProductInfo AS pif
    ON p.product_id = pif.product_id
    GROUP BY p.user_id, pif.category
)

SELECT c1.category AS category1,
       c2.category AS category2,
       COUNT(*) AS customer_count
FROM cte AS c1
JOIN cte AS c2
ON c1.user_id = c2.user_id
WHERE c1.category < c2.category
GROUP BY c1.category, c2.category
HAVING customer_count >= 3
ORDER BY customer_count DESC, category1, category2;
