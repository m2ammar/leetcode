# 184. Department Highest Salary

![Difficulty](https://img.shields.io/badge/Difficulty-Medium-orange) 
![Topic](https://img.shields.io/badge/Topic-SQL-blue) 
![Status](https://img.shields.io/badge/Status-Accepted-brightgreen)

**Concepts:** CTE · Window Functions · DENSE_RANK() · PARTITION BY · JOIN

---

## ✅ Problem Summary

- Find the employee(s) with the highest salary in each department.
- If multiple employees tie for the highest salary in a department, return all of them.
- Output columns: `Department`, `Employee`, `Salary`.

## 🧠 Solution

```sql
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
```

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `JOIN Department d ON e.departmentId = d.id` | Brings in the department name for each employee row |
| `DENSE_RANK() OVER (PARTITION BY departmentId ORDER BY salary DESC)` | Ranks employees within each department by salary, highest = 1; ties share the same rank |
| `WITH cte AS (...)` | Materializes the ranked result so `rnk` can be referenced afterward |
| `WHERE rnk = 1` | Keeps only the top-salary employee(s) per department |

## 🤔 Why CTE + Window Function?

The two tables relate through a simple foreign key:

```
Employee.departmentId ──> Department.id
```

A window function computes the rank of each row *without* collapsing rows the way `GROUP BY` would — this matters here because a department can have more than one employee tied for the highest salary, and `GROUP BY` + `MAX()` would only ever return one row per department. `DENSE_RANK()` lets every tied top earner keep rank 1.

However, a window function's alias (`rnk`) isn't available to `WHERE` in the same `SELECT`, since `WHERE` executes before the `SELECT` list is evaluated. Wrapping the ranked query in a CTE materializes `rnk` as a real column first, so the outer query can filter on it normally.

Sample intermediate result (before filtering):

| Department | Employee | Salary | rnk |
|---|---|---|---|
| IT | Jim | 90000 | 1 |
| IT | Max | 90000 | 1 |
| IT | Joe | 70000 | 2 |
| Sales | Henry | 80000 | 1 |
| Sales | Sam | 60000 | 2 |

## ⚠️ Why not GROUP BY + MAX()?

```sql
select d.name as Department, e.name as Employee, max(e.salary) as Salary
from Employee as e
join Department as d
on e.departmentId = d.id
group by d.name;
```

This collapses all employees in a department into a single row, so `e.name` becomes ambiguous (MySQL will silently return some arbitrary employee's name) and ties are lost entirely — only one row per department can ever come out. `GROUP BY` is for aggregating down to one row per group; here we need to keep every tied top-earner as its own row, which only a window function can do.

## 🏆 RANK() vs DENSE_RANK() at a Glance

| Function | Behavior on ties | Behavior after a tie |
|---|---|---|
| `RANK()` | Tied rows get the same rank | Next rank skips (e.g., 1, 1, 3) |
| `DENSE_RANK()` | Tied rows get the same rank | Next rank does not skip (e.g., 1, 1, 2) |

For this problem, since we only filter on rank = 1, both would produce the same result — `DENSE_RANK()` is the safer general habit for salary-ranking problems.

## 🐛 Common Mistakes

**Mistake 1: Filtering on the window function alias directly**
```sql
-- ❌ Fails: rnk doesn't exist yet when WHERE runs
select ..., dense_rank() over (...) as rnk
from Employee e join Department d on e.departmentId = d.id
where rnk = 1;
```
✅ Fix: wrap it in a CTE (or subquery) and filter in an outer query, where `rnk` is now a real column.

**Mistake 2: Partitioning/ordering by the aliased department name**
```sql
-- ❌ Department alias isn't resolved yet at this point in the query
dense_rank() over (Partition by Department order by salary desc)
```
✅ Fix: partition by the actual source column, `departmentId`, not the `SELECT`-list alias.

## ⏱ Time Complexity

O(n log n) — dominated by the sort required to compute `DENSE_RANK()` within each partition, where n is the number of employees.

## 🔑 Key Learnings

- Window functions preserve row-level detail that `GROUP BY` destroys — essential when ties need multiple rows in the output.
- `WHERE` can't see aliases defined in the same `SELECT`'s window functions; a CTE or subquery is the standard workaround.
- `DENSE_RANK()` vs `RANK()` only diverges in behavior *after* a tie, not on the tied rows themselves.

## Final Query

```sql
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
```
