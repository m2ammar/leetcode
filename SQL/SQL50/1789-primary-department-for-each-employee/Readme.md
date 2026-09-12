# 1789. Primary Department for Each Employee

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** Window Functions · PARTITION BY · Derived Tables (Subquery in FROM) · WHERE with OR

---

## ✅ Problem Summary

- Employees can belong to multiple departments.
- If an employee belongs to more than one department, exactly one row has `primary_flag = 'Y'` — report that department.
- If an employee belongs to only **one** department, `primary_flag` is `'N'` for that row — report it anyway, since it's their only (and therefore primary) department.
- Return `employee_id` and `department_id` for the correct row per employee.

---

## 🧠 Solution

```sql
select employee_id, department_id
from (
    select employee_id, department_id, primary_flag,
           count(department_id) over (partition by employee_id) as dept_id
    from Employee
) as t
where primary_flag = 'Y' OR dept_id = 1;
```

---

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `count(department_id) over (partition by employee_id)` | For every row, counts how many total department rows that `employee_id` has — without collapsing any rows together. |
| `partition by employee_id` | Defines the "window": the count restarts and is computed separately for each employee, but every row is preserved. |
| `from (...) as t` | Derived table — runs the window function first so its result (`dept_id`) becomes a real, usable column. |
| `where primary_flag = 'Y' OR dept_id = 1` | Keeps a row if it's explicitly flagged primary, **or** if the employee only has one department total. |

---

## 🤔 Why Window Function + Subquery?

The query needs to compare, per row, two things: `primary_flag` (does this row say it's primary?) and a per-employee department count (does this employee even have a choice?). A window function computes that count without collapsing the individual department rows — which a plain `GROUP BY` would do.

But window functions are evaluated **after** `WHERE` runs in SQL's logical query order:

```
FROM → WHERE → GROUP BY → HAVING → window functions → SELECT → ORDER BY
```

So `dept_id` doesn't exist yet at the point `WHERE` is evaluated in the same query. Wrapping the window-function query in a subquery (derived table `t`) forces it to fully resolve first, so the outer `WHERE` can filter on `dept_id` like any ordinary column.

```
Employee
  employee_id ──┐
                 ├── partition ── dept_id (count per employee)
  department_id ─┘
```

Sample intermediate result (inside `t`):

| employee_id | department_id | primary_flag | dept_id |
|---|---|---|---|
| 1 | 1 | N | 1 |
| 2 | 1 | Y | 2 |
| 2 | 2 | N | 2 |
| 3 | 3 | N | 1 |
| 4 | 2 | N | 3 |
| 4 | 3 | Y | 3 |
| 4 | 4 | N | 3 |

---

## ⚠️ Why not a Correlated Subquery?

A correlated subquery could also compute "how many departments does this employee have?" by re-running a `COUNT` for each outer row, referencing that row's `employee_id`:

```sql
select employee_id, department_id
from Employee e
where primary_flag = 'Y'
   or (select count(*) from Employee e2 where e2.employee_id = e.employee_id) = 1;
```

This works, but it re-executes the inner count once per outer row. The window function computes the same count in a single pass over the partitioned data, so it's generally the more efficient and idiomatic choice for this kind of "per-group aggregate, per-row output" problem.

---

## 🐛 Common Mistakes

**Using `COUNT` directly in `WHERE`:**
```sql
-- ❌ Aggregate functions can't be used in WHERE
where count(department_id) = 1
```
Fix: aggregates need `GROUP BY` + `HAVING`, or a window function evaluated in a wrapping query.

**Referencing an ungrouped column in `HAVING`:**
```sql
-- ❌ primary_flag isn't in GROUP BY and isn't aggregated
group by employee_id
having primary_flag = 'Y'
```
Fix: `primary_flag` can differ per row for the same employee, so it can't be resolved once you've grouped by `employee_id` alone.

**Filtering on a window function in the same query it's computed in:**
```sql
-- ❌ dept_id doesn't exist yet when WHERE runs
select employee_id,
       count(department_id) over (partition by employee_id) as dept_id
from Employee
where dept_id = 1;
```
Fix: wrap it in a subquery/derived table and filter in the outer `WHERE`.

---

## ⏱️ Time Complexity

`O(n log n)` — dominated by the partitioning/sort step the window function performs internally; the outer filter is a single linear pass over the derived table.

---

## 🔑 Key Learnings

- Window functions (`OVER (PARTITION BY ...)`) preserve every row while still attaching a per-group aggregate — unlike `GROUP BY`, which collapses rows.
- SQL's logical evaluation order means `WHERE` always runs before window functions — any filter on a window function's result needs a wrapping subquery or CTE.
- Aggregate conditions never belong in `WHERE`; they belong in `HAVING` (with `GROUP BY`) or become window functions filtered in an outer query.
- A correlated subquery and a window function can solve the same problem, but the window function avoids repeated re-execution per row.

---

## 🎯 Final Query

```sql
select employee_id, department_id
from (
    select employee_id, department_id, primary_flag,
           count(department_id) over (partition by employee_id) as dept_id
    from Employee
) as t
where primary_flag = 'Y' OR dept_id = 1;
```
