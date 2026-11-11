# Write your MySQL query statement below
SELECT b.book_id,
       b.title,
       b.author,
       b.genre,
       b.pages,
       MAX(r.session_rating) - MIN(r.session_rating) AS rating_spread,
       ROUND(
            SUM(CASE WHEN r.session_rating <= 2 OR r.session_rating >= 4 THEN 1 ELSE 0 END)
            / COUNT(*),
            2
        ) AS polarization_score

FROM books AS b
JOIN reading_sessions AS r
    ON b.book_id = r.book_id
GROUP BY b.book_id
HAVING COUNT(*) >= 5
    AND polarization_score >= 0.6
    AND MAX(r.session_rating) >= 4
    AND MIN(r.session_rating) <= 2
ORDER BY polarization_score DESC,
         b.title DESC;
