# Write your MySQL query statement below
WITH cte AS (
    SELECT user_id,
           course_name,
           LEAD(course_name) OVER (PARTITION BY user_id ORDER BY completion_date) AS next_course
    FROM course_completions
),

cte2 AS (
    SELECT user_id
    FROM course_completions
    GROUP BY user_id
    HAVING COUNT(course_id) >= 5
       AND AVG(course_rating) >= 4
)

SELECT course_name AS first_course,
       next_course AS second_course,
       COUNT(*) AS transition_count
FROM cte AS c1
JOIN cte2 AS c2
  ON c1.user_id = c2.user_id
WHERE next_course IS NOT NULL
GROUP BY course_name, next_course
ORDER BY transition_count DESC, first_course, second_course;
