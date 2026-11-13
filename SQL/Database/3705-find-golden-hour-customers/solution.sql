# Write your MySQL query statement below
SELECT  customer_id,
        COUNT(order_id) AS total_orders,
        ROUND((SUM(CASE WHEN TIME(order_timestamp) BETWEEN '11:00' AND '14:00'
                          OR TIME(order_timestamp) BETWEEN '18:00' AND '21:00'
                        THEN 1 ELSE 0 END) / COUNT(*)) * 100, 0) AS peak_hour_percentage,
        ROUND(AVG(order_rating), 2) AS average_rating
FROM restaurant_orders
GROUP BY customer_id
HAVING SUM(CASE WHEN TIME(order_timestamp) BETWEEN '11:00' AND '14:00'
                  OR TIME(order_timestamp) BETWEEN '18:00' AND '21:00'
                THEN 1 ELSE 0 END) / COUNT(*) * 100 >= 60
   AND AVG(order_rating) >= 4.0
   AND total_orders >= 3
   AND COUNT(order_rating) / COUNT(order_id) >= 0.5
ORDER BY 4 DESC, 1 DESC;
