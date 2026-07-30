SELECT s.user_id, IFNULL(a.rate, 0) AS confirmation_rate
FROM Signups AS s
LEFT JOIN
  ( SELECT user_id, ROUND((SUM(action = 'confirmed') / COUNT(*)), 2) AS rate
    FROM Confirmations
    GROUP BY user_id ) AS a
  ON a.user_id = s.user_id;
