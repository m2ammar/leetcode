# Write your MySQL query statement below
SELECT user_id,
       ROUND(AVG(IF(activity_type = 'free_trial', activity_duration, NULL)), 2) AS trial_avg_duration,
       ROUND(AVG(IF(activity_type = 'paid', activity_duration, NULL)), 2) AS paid_avg_duration
FROM UserActivity
GROUP BY user_id
HAVING SUM(activity_type = 'paid') > 0
   AND SUM(activity_type = 'free_trial') > 0
ORDER BY user_id ASC;
