-- 602. Friend Requests II: Who Has the Most Friends
-- Approach 1: Subquery-based (max computed separately, compared via WHERE)

Select id, num  
from (Select t.id, count(*) as num 
from ((SELECT requester_id as id FROM RequestAccepted)
Union All 
(SELECT accepter_id FROM RequestAccepted)) as t
group by id) as A
where num =  (SELECT MAX(num) FROM (Select t.id, count(*) as num 
from ((SELECT requester_id as id FROM RequestAccepted)
Union All 
(SELECT accepter_id FROM RequestAccepted)) as t
group by id) as B);


-- Approach 2: Window function (RANK) - handles ties in one pass, no repeated logic

SELECT id, num
FROM (
    SELECT id, num, RANK() OVER (ORDER BY num DESC) as rnk
    FROM (
        SELECT t.id, count(*) as num
        FROM (
            (SELECT requester_id as id FROM RequestAccepted)
            UNION ALL
            (SELECT accepter_id FROM RequestAccepted)
        ) as t
        GROUP BY id
    ) as counts
) as ranked
WHERE rnk = 1;
