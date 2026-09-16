# Write your MySQL query statement below
with cte as(
select d.name as Department, e.name as Employee, salary as Salary,
dense_rank() over (Partition by departmentId order by salary desc) as rnk
from Employee as e
join Department as d
on e.departmentId = d.id
)
select Department, Employee, Salary
from cte
WHERE rnk = 1;
