# 185. Department Top Three Salaries

![Difficulty](https://img.shields.io/badge/Difficulty-Hard-red)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** CTE · Window Function · DENSE_RANK() · PARTITION BY · JOIN

---

## ✅ Problem Summary
- Find employees whose salary is among the **top 3 unique salaries** within their own department
- Ties count as the same rank (e.g. two people tied for 2nd both count, and 3rd place still exists after them)
- Return Department name, Employee name, and Salary

---

## 🧠 Solution
```sql
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
```

---

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `JOIN Department d ON e.departmentId = d.id` | Brings in the department name for each employee |
| `DENSE_RANK() OVER (...)` | Assigns a rank to each employee's salary |
| `PARTITION BY e.departmentId` | Resets the ranking separately for each department |
| `ORDER BY e.salary DESC` | Ranks highest salary as 1, next highest as 2, etc. |
| `CTE (WITH cte AS (...))` | Materializes the ranked result so it can be filtered afterward |
| `WHERE emp <= 3` | Keeps only rows ranked in the top 3 within their department |

---

## 🤔 Why DENSE_RANK() + PARTITION BY?
Employee and Department are related through `Employee.departmentId → Department.id`. Each department can have many employees, so ranking needs to happen *within* each department separately, not across the whole table.
