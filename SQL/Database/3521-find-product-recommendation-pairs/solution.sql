SELECT
    p1.product_id AS product1_id,
    p2.product_id AS product2_id,
    p4.category AS product1_category,
    p3.category AS product2_category,
    COUNT(DISTINCT p1.user_id) AS customer_count
FROM ProductPurchases AS p1
JOIN ProductPurchases AS p2
    ON p1.user_id = p2.user_id
    AND p1.product_id < p2.product_id
JOIN ProductInfo AS p3
    ON p2.product_id = p3.product_id
JOIN ProductInfo AS p4
    ON p1.product_id = p4.product_id
GROUP BY product1_id, product2_id
HAVING COUNT(DISTINCT p1.user_id) >= 3
ORDER BY customer_count DESC, product1_id ASC, product2_id ASC;
