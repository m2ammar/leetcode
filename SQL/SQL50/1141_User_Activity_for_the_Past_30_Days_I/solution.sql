# Write your MySQL query statement below
Select activity_date AS day, COUNT(DISTINCT user_id) AS active_users
From Activity
Where activity_type IN ('open_session', 'end_session', 'scroll_down', 'send_message') AND activity_date BETWEEN '2019-06-28' AND '2019-07-27'
Group by day;
