# Write your MySQL query statement below
with cte as (
Select 
    case 
        when month(s.sale_date) in (12, 1, 2) then 'Winter'
        when month(s.sale_date) in (3, 4, 5) then 'Spring'
        when month(s.sale_date) in (6, 7, 8) then 'Summer'
        else 'Fall'
    end as season, 
    p.category, 
    sum(s.quantity) as total_quantity, 
    SUM(s.quantity * s.price) as total_revenue
from sales as s
join products as p
on s.product_id = p.product_id    
GROUP BY season, p.category
),

cte2 as (
    select season, category, total_quantity, total_revenue,
    row_number() over (partition by season order by  total_quantity desc, total_revenue desc, category asc) as rnk
    from cte
)

Select season, category, total_quantity, total_revenue
from cte2
where rnk =1
order by season;
