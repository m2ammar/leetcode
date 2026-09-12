# Write your MySQL query statement below
with cte as (
    select *,
        count(*) over (partition by tiv_2015) as cnt_tiv,
        count(*) over (partition by lat, lon) as cnt_loc
    from Insurance
)
select round(sum(tiv_2016), 2) as tiv_2016
from cte
where cnt_tiv > 1 AND cnt_loc = 1;
