# Write your MySQL query statement below
SELECT user_id, COUNT(*) AS prompt_count, ROUND(AVG(tokens), 2) AS avg_tokens
FROM prompts
GROUP BY user_id
HAVING COUNT(*) >= 3
       AND AVG(tokens) < MAX(tokens)
ORDER BY avg_tokens DESC, user_id ASC;
