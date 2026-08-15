# 1731. The Number of Employees Which Report to Each Employee

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** Derived Table (Subquery) · GROUP BY · JOIN · Aggregate Functions (COUNT, AVG) · ROUND

---

## ✅ Problem Summary

- [x] A manager is any employee who has at least 1 other employee reporting to them
- [x] Report each manager's `employee_id` and `name`
- [x] Report `reports_count` — the number of employees who report directly to them
- [x] Report `average_age` — the average age of their direct reports, rounded to the nearest integer
- [x] Order the result by `employee_id`

---

## 💡 Solution

```sql
select e.employee_id, e.name, e1.reports_count, e1.average_age
from Employees as e
join (
    select reports_to, count(*) as reports_count, round(avg(age), 0) as average_age
    from Employees
    where reports_to is not null
    group by reports_to
) as e1 on e.employee_id = e1.reports_to
order by e.employee_id;
```

---

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `where reports_to is not null` (inner) | Removes employees who report to nobody, so they never form a phantom group |
| `group by reports_to` (inner) | Buckets every employee by the manager they report to — one group per manager |
| `count(*)` (inner) | Counts how many employees fall in each `reports_to` group = direct report count |
| `round(avg(age), 0)` (inner) | Averages the ages within each group, rounded to the nearest whole number |
| `join ... on e.employee_id = e1.reports_to` | Matches each manager id (from the inner grouping) back to that manager's own row, to fetch their `name` |
| `order by e.employee_id` | Sorts final output by manager id |

---

## 🤔 Why a Derived Table + Join?

The table only stores each employee's *own* manager in `reports_to` — there's no row that directly says "this person is a manager." A manager only emerges as a byproduct of other rows pointing at their id.

That means the stats (count, average age) and the identity (name) live in two different places:

- **Stats** come from grouping the *reports* — rows where `reports_to` is filled in.
- **Identity** (the manager's own name) lives in a separate row, where `employee_id` equals that `reports_to` value.

```
Employees table
+----+---------+------------+
| id | name    | reports_to |
+----+---------+------------+
| 9  | Hercy   | null       |  <- manager's own row (identity)
| 6  | Alice   | 9          |  <- report (stats)
| 4  | Bob     | 9          |  <- report (stats)
+----+---------+------------+

group by reports_to          join back on employee_id = reports_to
   9 -> count=2, avg=38.5  ---------->  9 = Hercy  =>  Hercy, 2, 39
```

Sample derived table (`e1`) result:

| reports_to | reports_count | average_age |
|---|---|---|
| 9 | 2 | 39 |

Joining `e1` to `Employees` on `e.employee_id = e1.reports_to` attaches the manager's name to their already-computed stats.

---

## ⚠️ Why not GROUP BY employee_id directly?

Grouping by `employee_id` groups each employee with *themselves* — it doesn't gather the people who report to them at all, since `reports_to` and `employee_id` are different columns describing different roles. Grouping has to happen on `reports_to`, the column where multiple rows actually repeat the same value, because that repetition is what identifies a manager and their reports as a set.

---

## 🚧 Common Mistakes

**Mistake 1 — Selecting `employee_id` from a table grouped by `reports_to`:**
```sql
-- Wrong: employee_id isn't the grouping column, so its value is arbitrary
select employee_id, count(*) from Employees group by reports_to
```
Fix: select `reports_to` itself — that value *is* the manager's id.

**Mistake 2 — Filtering with `HAVING COUNT(*) >= 1`:**
```sql
-- Wrong: does nothing, since every existing group already has >= 1 row
group by reports_to having count(*) >= 1
```
Fix: exclude non-managers *before* grouping, with `where reports_to is not null`.

**Mistake 3 — Recomputing aggregates in the outer query:**
```sql
-- Wrong: outer query has no grouping structure for these reports anymore
select e.employee_id, e.name, count(*), avg(e.age) from Employees e join (...) e1 on ...
```
Fix: select the already-computed `reports_count` and `average_age` straight from the derived table.

---

## ⏱️ Time Complexity

O(n) to scan and group `Employees` once, plus O(n) for the join — overall roughly O(n) with the usual indexing/sorting overhead a database engine adds for GROUP BY and JOIN.

---

## 🔑 Key Learnings

- Group by the column where values *repeat*, not by the entity you ultimately want to describe.
- A derived table can isolate an aggregation "from the reports' perspective," separate from the outer query's "from the manager's perspective."
- `HAVING` only filters groups that already exist from `GROUP BY` — it can't manufacture a condition that isn't already tied to the grouping.
- `ROUND(x, 0)` rounds to the nearest whole number; the second argument is the decimal-place count, not a multiplier.
- A join condition is pure value-matching (`employee_id = reports_to`) — it's how two different "roles" of the same table get reconnected.

---

## 🧠 Final Query

```sql
select e.employee_id, e.name, e1.reports_count, e1.average_age
from Employees as e
join (
    select reports_to, count(*) as reports_count, round(avg(age), 0) as average_age
    from Employees
    where reports_to is not null
    group by reports_to
) as e1 on e.employee_id = e1.reports_to
order by e.employee_id;
```
