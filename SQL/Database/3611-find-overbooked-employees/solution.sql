# Write your MySQL query statement below
WITH cte AS (
    SELECT
        employee_id,
        YEARWEEK(meeting_date, 7) AS weekly
    FROM meetings
    GROUP BY employee_id, YEARWEEK(meeting_date, 7)
    HAVING SUM(duration_hours) > 20
)

SELECT e.employee_id, e.employee_name, e.department, COUNT(c.weekly) AS meeting_heavy_weeks
FROM cte AS c
JOIN employees AS e
ON c.employee_id = e.employee_id
GROUP BY e.employee_id, e.employee_name, e.department
HAVING COUNT(*) >= 2
ORDER BY meeting_heavy_weeks DESC, e.employee_name ASC;
