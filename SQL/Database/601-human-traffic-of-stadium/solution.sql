# Write your MySQL query statement below
with cte1 as (
    select id, visit_date, people, id - row_number() over (order by id) as consec
    from Stadium
    where people >= 100
),

cte2 as (
    select id, visit_date, people, count(*) over (partition by consec) as counts
    from cte1
)

select id, visit_date, people
from cte2
where counts >= 3
order by visit_date;
