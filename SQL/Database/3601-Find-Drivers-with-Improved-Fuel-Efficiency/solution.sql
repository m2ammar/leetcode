# Write your MySQL query statement below
WITH cte AS (
    SELECT d.driver_id,
        d.driver_name,
        AVG(CASE WHEN MONTH(t.trip_date) BETWEEN 1 AND 6 THEN t.distance_km / t.fuel_consumed END) AS first_half_avg,
        AVG(CASE WHEN MONTH(t.trip_date) BETWEEN 7 AND 12 THEN t.distance_km / t.fuel_consumed END) AS second_half_avg
    FROM drivers AS d
    JOIN trips AS t
        ON d.driver_id = t.driver_id
    GROUP BY d.driver_id, d.driver_name
    HAVING first_half_avg IS NOT NULL AND second_half_avg IS NOT NULL
)

SELECT
    driver_id,
    driver_name,
    ROUND(first_half_avg, 2) AS first_half_avg,
    ROUND(second_half_avg, 2) AS second_half_avg,
    ROUND((second_half_avg - first_half_avg), 2) AS efficiency_improvement
FROM cte
WHERE second_half_avg - first_half_avg > 0
ORDER BY efficiency_improvement DESC, driver_name ASC;
