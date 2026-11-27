-- 3832. Find Users with Persistent Behavior Patterns
-- Gaps and Islands: one action per day, same action, 5+ consecutive days

WITH cte1 AS (
    SELECT user_id,
           action_date,
           MIN(action) AS action,
           ROW_NUMBER() OVER (PARTITION BY user_id, action ORDER BY action_date) AS cnt
    FROM activity
    GROUP BY user_id, action_date
    HAVING COUNT(*) = 1
),

cte2 AS (
    SELECT user_id,
           action_date,
           action,
           cnt,
           DATE_SUB(action_date, INTERVAL cnt DAY) AS grp
    FROM cte1
),

cte3 AS (
    SELECT user_id,
           action,
           COUNT(*) AS streak_length,
           MIN(action_date) AS start_date,
           MAX(action_date) AS end_date
    FROM cte2
    GROUP BY user_id, action, grp
    HAVING COUNT(*) >= 5
),

cte4 AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY user_id
               ORDER BY streak_length DESC, action ASC, start_date DESC
           ) AS rn
    FROM cte3
)

SELECT user_id,
       action,
       streak_length,
       start_date,
       end_date
FROM cte4
WHERE rn = 1
ORDER BY streak_length DESC, user_id ASC;
