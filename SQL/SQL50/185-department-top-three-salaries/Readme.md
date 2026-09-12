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

```text
Department (1)───< Employee (many)
     id                departmentId
```

`PARTITION BY departmentId` tells the window function "restart the ranking every time the department changes." `DENSE_RANK()` is the right ranking function here (over `ROW_NUMBER()` or plain `RANK()`) because it handles **unique salaries** correctly — ties share the same rank, and the next distinct salary continues at rank+1 with no gap.
Sample intermediate result (before filtering):

| Department | Employee | Salary | emp |
|---|---|---|---|
| IT | Max | 90000 | 1 |
| IT | Joe | 85000 | 2 |
| IT | Randy | 85000 | 2 |
| IT | Will | 70000 | 3 |
| IT | Janet | 69000 | 4 |
| Sales | Henry | 80000 | 1 |
| Sales | Sam | 60000 | 2 |

---

## ⚠️ Why not RANK() or ROW_NUMBER()?
- **ROW_NUMBER()** gives every row a distinct number even on ties — Joe and Randy (both 85000) would get different ranks (2 and 3), incorrectly dropping one of them from "top 3."
- **RANK()** handles ties correctly but leaves gaps — after two rows tied at rank 2, the next distinct salary would jump to rank 4 instead of 3, which breaks "top three *unique* salaries."
- **DENSE_RANK()** is the only one of the three that keeps ties together *and* keeps ranks sequential with no gaps — exactly what "top three unique salaries" requires.

---

## 🔑 Window Function Ranking Types at a Glance

| Function | Ties | Gaps after ties |
|---|---|---|
| `ROW_NUMBER()` | Breaks ties (arbitrary order) | No gaps (by definition) |
| `RANK()` | Keeps ties equal | Leaves gaps |
| `DENSE_RANK()` | Keeps ties equal | No gaps |

---

## ⚠️ Common Mistakes

**Mistake 1 — Partitioning by the wrong column**
```sql
DENSE_RANK() OVER (PARTITION BY e.id ORDER BY e.salary DESC)
```
`e.id` is the Employee primary key, so every "partition" contains exactly one row — the rank is always 1 for everyone. Fix: partition by `departmentId`, the column that actually groups employees by department.

**Mistake 2 — Filtering on the window function alias directly**
```sql
SELECT Department, Employee, Salary, DENSE_RANK() OVER (...) AS emp
FROM Employee JOIN Department ...
WHERE emp <= 3;
```
`WHERE` executes before `SELECT` in SQL's logical query order, so the `emp` alias doesn't exist yet when `WHERE` runs. Fix: compute the window function inside a CTE (or subquery), then filter in the outer query where `emp` is already a resolved column.

---

## ⏱ Time Complexity
O(n log n) — dominated by the sort required for the window function's `ORDER BY` within each partition.

---

## 🧠 Key Learnings
- Window functions execute at the `SELECT` stage, **after** `WHERE` — their aliases aren't visible to `WHERE` in the same query
- A CTE is the standard fix for filtering on a window function's result
- `PARTITION BY` should match whatever column represents "each group" in the problem statement — not the primary key
- `DENSE_RANK()` is the correct ranking function whenever "top N unique values" is the requirement

---

## 🏁 Final Query
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
