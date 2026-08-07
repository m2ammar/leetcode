# Write your MySQL query statement below
SELECT ROUND(SUM(CASE WHEN a2.event_date = DATE_ADD(a1.event_date, INTERVAL 1 DAY) THEN 1 ELSE 0 END) / COUNT(DISTINCT(a1.player_id)), 2) AS fraction
FROM Activity AS a1
LEFT JOIN Activity AS a2
ON a2.player_id = a1.player_id
WHERE a1.event_date IN (SELECT MIN(event_date) FROM Activity AS a3 WHERE a3.player_id = a1.player_id);
