WITH unbanned AS (
    SELECT users_id
    FROM Users
    WHERE banned = 'No'
)
SELECT
    request_at AS Day,
    ROUND(
        SUM(CASE
                WHEN status IN ('cancelled_by_driver', 'cancelled_by_client') THEN 1
                ELSE 0
            END)
        / COUNT(id),
        2
    ) AS `Cancellation Rate`
FROM Trips
WHERE client_id IN (SELECT users_id FROM unbanned)
  AND driver_id IN (SELECT users_id FROM unbanned)
  AND request_at BETWEEN '2013-10-01' AND '2013-10-03'
GROUP BY request_at;
