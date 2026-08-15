# Write your MySQL query statement below
select e.employee_id, e.name, e1.reports_count, e1.average_age
from Employees as e
join (
    select reports_to, count(*) as reports_count, round(avg(age), 0) as average_age
    from Employees
    where reports_to is not null
    group by reports_to
) as e1 on e.employee_id = e1.reports_to
order by e.employee_id;
