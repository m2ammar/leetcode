# Write your MySQL query statement below
WITH cte1 AS (
    SELECT student_id, subject, session_date, hours_studied,
           LAG(session_date) OVER (PARTITION BY student_id ORDER BY session_date) AS prev_date
    FROM study_sessions
),
cte2 AS (
    SELECT student_id, subject, session_date, hours_studied,
           CASE WHEN prev_date IS NULL OR DATEDIFF(session_date, prev_date) > 2
                THEN 1 ELSE 0 END AS new_streak
    FROM cte1
),
cte3 AS (
    SELECT student_id, subject, session_date, hours_studied,
           SUM(new_streak) OVER (PARTITION BY student_id ORDER BY session_date) AS streak_id
    FROM cte2
),
cte4 AS (
    SELECT student_id, subject, session_date, hours_studied, streak_id,
           ROW_NUMBER() OVER (PARTITION BY student_id, streak_id ORDER BY session_date) AS pos
    FROM cte3
),
cte5 AS (
    SELECT student_id, subject, session_date, hours_studied, pos, streak_id,
           FIRST_VALUE(subject) OVER (PARTITION BY student_id, streak_id ORDER BY pos) AS first_subject
    FROM cte4
),
cte6 AS (
    SELECT student_id, streak_id, MIN(pos) - 1 AS cycle_length
    FROM cte5
    WHERE subject = first_subject AND pos > 1
    GROUP BY student_id, streak_id
),
cte7 AS (
    SELECT a.student_id, a.streak_id, COUNT(*) AS matches
    FROM cte5 a
    JOIN cte6 k
      ON a.student_id = k.student_id
     AND a.streak_id = k.streak_id
    JOIN cte5 b
      ON b.student_id = a.student_id
     AND b.streak_id = a.streak_id
     AND a.pos > k.cycle_length
     AND b.pos = a.pos - k.cycle_length
    WHERE a.subject = b.subject
    GROUP BY a.student_id, a.streak_id
),
cte8 AS (
    SELECT student_id
    FROM cte5
    GROUP BY student_id
    HAVING COUNT(DISTINCT streak_id) = 1
)
SELECT c6.student_id,
       s.student_name,
       s.major,
       c6.cycle_length,
       SUM(c5.hours_studied) AS total_study_hours
FROM cte6 c6
JOIN cte5 c5
  ON c6.student_id = c5.student_id
 AND c6.streak_id = c5.streak_id
JOIN students s
  ON c6.student_id = s.student_id
JOIN cte7 m
  ON m.student_id = c6.student_id
 AND m.streak_id = c6.streak_id
JOIN cte8 n
  ON n.student_id = c6.student_id
GROUP BY c6.student_id, s.student_name, s.major, c6.cycle_length, c6.streak_id, m.matches
HAVING c6.cycle_length >= 3
   AND COUNT(*) >= 2 * c6.cycle_length
   AND COUNT(*) % c6.cycle_length = 0
   AND COUNT(DISTINCT c5.subject) = c6.cycle_length
   AND m.matches = COUNT(*) - c6.cycle_length
ORDER BY c6.cycle_length DESC, total_study_hours DESC;
