# Write your MySQL query statement below
WITH cte AS (
    SELECT user_id,
           reaction,
           COUNT(*) AS cnt,
           SUM(COUNT(*)) OVER (PARTITION BY user_id) AS total
    FROM reactions
    GROUP BY user_id, reaction
)
SELECT user_id,
       reaction AS dominant_reaction,
       ROUND(cnt / total, 2) AS reaction_ratio
FROM cte
WHERE total >= 5
  AND cnt / total >= 0.6
ORDER BY reaction_ratio DESC, user_id ASC;
