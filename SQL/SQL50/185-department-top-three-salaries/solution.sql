WITH cte AS (
    SELECT 
        e.name AS Employee, 
        e.salary AS Salary, 
        d.name AS Department,
        DENSE_RANK() OVER (PARTITION BY e.departmentId ORDER BY e.salary DESC) AS emp
    FROM Employee AS e
    JOIN Department AS d
        ON e.departmentId = d.id
)
SELECT Department, Employee, Salary
FROM cte
WHERE emp <= 3;
