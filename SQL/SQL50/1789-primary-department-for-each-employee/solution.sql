# Write your MySQL query statement below
select employee_id, department_id
from (
    select employee_id, department_id, primary_flag,
           count(department_id) over (partition by employee_id) as dept_id
    from Employee
) as t
where primary_flag = 'Y' OR dept_id = 1;
