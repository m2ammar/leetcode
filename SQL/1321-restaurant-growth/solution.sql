# Write your MySQL query statement below
With cte as (
    select t.visited_on as visited_on,
        sum(t.amount) Over (Order by t.visited_on Rows BETWEEN 6 PRECEding and CURRENT ROW) as amount,
        round(avg(t.amount) OVER (Order by t.visited_on ROWS BETWEEN 6 PRECEDING AND  CURRENT ROW), 2) as average_amount,
        ROW_NUMBER() OVER (ORDER BY t.visited_on) as num
    from (Select visited_on, sum(amount) as amount from Customer group by visited_on) as t
)

select visited_on, amount, average_amount
from cte
where num >= 7;
