# Write your MySQL query statement below
WITH cte AS (
    SELECT session_id,
           user_id,
           TIMESTAMPDIFF(MINUTE, MIN(event_timestamp), MAX(event_timestamp)) AS duration_minutes,
           TIMESTAMPDIFF(SECOND, MIN(event_timestamp), MAX(event_timestamp)) AS duration_second,
           SUM(CASE WHEN event_type = 'scroll'   THEN 1 ELSE 0 END) AS scroll_count,
           SUM(CASE WHEN event_type = 'click'    THEN 1 ELSE 0 END) AS click_count,
           SUM(CASE WHEN event_type = 'purchase' THEN 1 ELSE 0 END) AS purchase_count
    FROM app_events
    GROUP BY session_id, user_id
)
SELECT session_id,
       user_id,
       duration_minutes AS session_duration_minutes,
       scroll_count
FROM cte
WHERE duration_second > 1800
      AND scroll_count >= 5
      AND click_count / scroll_count < 0.20
      AND purchase_count = 0
ORDER BY scroll_count DESC, session_id;
