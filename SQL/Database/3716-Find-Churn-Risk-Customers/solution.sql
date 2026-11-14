# Write your MySQL query statement below
WITH cte1 AS (
    SELECT user_id,
        MAX(monthly_amount) AS max_amount,
        MIN(event_date) AS first_event_date,
        MAX(event_date) AS last_event_date,
        SUM(CASE WHEN event_type = 'downgrade' THEN 1 ELSE 0 END) AS downgrade_cnt
    FROM subscription_events
    GROUP BY user_id
),

cte2 AS (
    SELECT user_id,
        plan_name,
        monthly_amount,
        event_type,
        ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY event_date DESC, event_id DESC) AS t
    FROM subscription_events
)

SELECT c1.user_id,
    c2.plan_name AS current_plan,
    c2.monthly_amount AS current_monthly_amount,
    c1.max_amount AS max_historical_amount,
    DATEDIFF(c1.last_event_date, c1.first_event_date) AS days_as_subscriber
FROM cte1 AS c1
JOIN cte2 AS c2
    ON c1.user_id = c2.user_id
WHERE c2.event_type != 'cancel'
    AND c2.t = 1
    AND c1.downgrade_cnt >= 1
    AND c2.monthly_amount < (c1.max_amount * 0.5)
    AND DATEDIFF(c1.last_event_date, c1.first_event_date) >= 60
ORDER BY days_as_subscriber DESC, c1.user_id ASC;
