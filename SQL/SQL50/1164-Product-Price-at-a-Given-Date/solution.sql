# Write your MySQL query statement below
with cte as (
    select
        product_id,
        new_price,
        row_number() over (partition by product_id order by change_date desc) as rn
    from Products
    where change_date <= '2019-08-16'
)
select
    p.product_id,
    case when cte.new_price is null then 10 else cte.new_price end as price
from (select distinct product_id from Products) as p
left join cte
    on cte.product_id = p.product_id
    and rn = 1;
