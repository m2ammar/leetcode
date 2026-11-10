# Write your MySQL query statement below
WITH cte AS (
    SELECT
        store_id,
        product_name,
        quantity,
        ROW_NUMBER() OVER (PARTITION BY store_id ORDER BY price DESC) AS rn_high,
        ROW_NUMBER() OVER (PARTITION BY store_id ORDER BY price ASC)  AS rn_low,
        COUNT(*)     OVER (PARTITION BY store_id)                     AS cnt
    FROM inventory
),
expensive AS (
    SELECT store_id, product_name, quantity
    FROM cte
    WHERE rn_high = 1 AND cnt >= 3
),
cheap AS (
    SELECT store_id, product_name, quantity
    FROM cte
    WHERE rn_low = 1
)
SELECT
    s.store_id,
    s.store_name,
    s.location,
    e.product_name AS most_exp_product,
    c.product_name AS cheapest_product,
    ROUND(c.quantity / e.quantity, 2) AS imbalance_ratio
FROM stores AS s
JOIN expensive AS e ON s.store_id = e.store_id
JOIN cheap     AS c ON s.store_id = c.store_id
WHERE e.quantity < c.quantity
ORDER BY imbalance_ratio DESC, s.store_name ASC;
