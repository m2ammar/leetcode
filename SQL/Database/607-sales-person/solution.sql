# Write your MySQL query statement below
select s.name
from SalesPerson as s
left join Orders as o
    on o.sales_id = s.sales_id
left join Company as c
    on c.com_id = o.com_id
group by s.name
having SUM(IF(c.name = 'RED', 1, 0)) = 0;
