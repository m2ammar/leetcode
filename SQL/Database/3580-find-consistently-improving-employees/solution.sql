WITH ran AS (
    SELECT
        employee_id,
        rating,
        ROW_NUMBER() OVER (
            PARTITION BY employee_id
            ORDER BY review_date DESC
        ) AS rn
    FROM performance_reviews
),

filt AS (
    SELECT
        employee_id,
        MAX(CASE WHEN rn = 1 THEN rating END) AS latest_rating,
        MAX(CASE WHEN rn = 2 THEN rating END) AS second_rating,
        MAX(CASE WHEN rn = 3 THEN rating END) AS earliest_rating
    FROM ran
    WHERE rn <= 3
    GROUP BY employee_id
    HAVING COUNT(*) = 3
)

SELECT
    e.employee_id,
    e.name,
    f.latest_rating - f.earliest_rating AS improvement_score
FROM filt AS f
JOIN employees AS e
    ON e.employee_id = f.employee_id
WHERE f.earliest_rating < f.second_rating
  AND f.second_rating < f.latest_rating
ORDER BY improvement_score DESC, e.name ASC;
