# Write your MySQL query statement below
with cte as (
    select id, num,
    Lag(num, 1) OVER (order by id asc) as num1,
    LEAD(num, 1) OVER (order by id asc) as num2
from Logs
)
select distinct(num) as ConsecutiveNums
from cte
where num = num1 AND num = num2;
