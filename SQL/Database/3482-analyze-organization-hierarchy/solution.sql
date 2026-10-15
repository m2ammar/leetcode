WITH RECURSIVE level AS (
    SELECT employee_id, 1 AS level
    FROM Employees
    WHERE manager_id IS NULL

    UNION ALL

    SELECT e.employee_id, l.level + 1
    FROM Employees AS e
    JOIN level AS l
        ON e.manager_id = l.employee_id
),
reports AS (
    SELECT manager_id, employee_id
    FROM Employees
    WHERE manager_id IS NOT NULL

    UNION ALL

    SELECT r.manager_id, e.employee_id
    FROM reports AS r
    JOIN Employees AS e
        ON e.manager_id = r.employee_id
)
SELECT
    m.employee_id,
    m.employee_name,
    l.level,
    COUNT(s.employee_id) AS team_size,
    COALESCE(SUM(s.salary), 0) + m.salary AS budget
FROM Employees AS m
LEFT JOIN reports AS r
    ON r.manager_id = m.employee_id
LEFT JOIN Employees AS s
    ON s.employee_id = r.employee_id
JOIN level AS l
    ON l.employee_id = m.employee_id
GROUP BY
    m.employee_id,
    m.employee_name,
    l.level,
    m.salary
ORDER BY
    l.level ASC,
    budget DESC,
    m.employee_name ASC;
