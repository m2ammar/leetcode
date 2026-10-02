# 1741. Find Total Time Spent by Each Employee

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** `SELECT` · `SUM()` · `GROUP BY` · `Column Aliases` · `Arithmetic Inside Aggregates`

---

## ✅ Problem Summary

Given an `Employees` table of office entries and exits, the query must return:

- ✅ One row per **employee per day**
- ✅ The total minutes spent in the office that day (sum of `out_time - in_time` over all of that day's entries)
- ✅ Columns named `day`, `emp_id`, `total_time`
- ✅ Rows in any order

---

## 🧩 Solution

```sql
# Write your MySQL query statement below
select event_day as day, emp_id, sum(out_time - in_time) as total_time
from Employees
group by event_day, emp_id;
```

---

## 🔍 Breakdown

| Clause | What it does |
|---|---|
| `select event_day as day` | Returns the date column, renamed to `day` as the output format requires |
| `emp_id` | Identifies which employee the row belongs to |
| `sum(out_time - in_time) as total_time` | Computes the minutes for each entry, then adds them up per group |
| `from Employees` | The only table needed, no join required |
| `group by event_day, emp_id` | Collapses all entries of the same employee on the same day into one row |

---

## 🤔 Why `GROUP BY event_day, emp_id`?

An employee can enter and leave **several times in one day**, so each employee-day has multiple rows. We need one total per employee per day.

```
Employees (one row per visit)            Result (one row per employee-day)
-----------------------------            ---------------------------------
emp 1 | 11-28 | 4   -> 32   (28)         
emp 1 | 11-28 | 55  -> 200  (145)   ───►  emp 1 | 11-28 | 173
emp 1 | 12-03 | 1   -> 42   (41)    ───►  emp 1 | 12-03 | 41
emp 2 | 11-28 | 3   -> 33   (30)    ───►  emp 2 | 11-28 | 30
```

Sample output for the example input:

| day | emp_id | total_time |
|---|---|---|
| 2020-11-28 | 1 | 173 |
| 2020-11-28 | 2 | 30 |
| 2020-12-03 | 1 | 41 |
| 2020-12-09 | 2 | 27 |

Both columns must be in `GROUP BY`: `emp_id` alone would merge different days together, and `event_day` alone would merge different employees together.

---

## 🙅 Why not a window function or subquery?

A window function such as `SUM(out_time - in_time) OVER (PARTITION BY event_day, emp_id)` also works, but it keeps every original row, so you would need `DISTINCT` to get one row per employee-day. A subquery that computes each visit's duration first, then sums it, does the same work in two steps.

`GROUP BY` is shorter, easier to read, and returns exactly the shape the problem asks for, so it is the better choice here.

---

## 🧷 GROUP BY Granularity at a Glance

| Grouping | Result has one row per... |
|---|---|
| `GROUP BY emp_id` | employee (all days merged) |
| `GROUP BY event_day` | day (all employees merged) |
| `GROUP BY event_day, emp_id` | employee **and** day ✅ |

---

## ⚠️ Common Mistakes

**1. Grouping only by `emp_id`**

```sql
select event_day as day, emp_id, sum(out_time - in_time) as total_time
from Employees
group by emp_id;
```

This adds up every day for the employee, and `event_day` is not in the `GROUP BY`, so MySQL with `ONLY_FULL_GROUP_BY` raises an error (or returns an arbitrary date otherwise).

Fix: group by both columns.

```sql
group by event_day, emp_id;
```

**2. Forgetting the alias `day`**

```sql
select event_day, emp_id, sum(out_time - in_time) as total_time
```

The query runs, but the output column is named `event_day` instead of `day`, which does not match the required format.

Fix: `select event_day as day, ...`

---

## ⏱️ Time Complexity

**O(n)** to scan the table and compute each row's duration, plus the cost of grouping (hash-based or sort-based depending on the optimizer, up to **O(n log n)**).

---

## 🔑 Key Learnings

- 🧠 When a table has multiple rows per entity, `GROUP BY` plus `SUM()` collapses them into one total
- 🧠 The group key must match the granularity of the answer: here, **employee + day**
- 🧠 Arithmetic can go **inside** an aggregate, e.g. `SUM(out_time - in_time)`
- 🧠 Column aliases (`as day`) control the output column names to match the required format
- 🧠 No join is needed when all required columns live in a single table

---

## 🏁 Final Query

```sql
select event_day as day, emp_id, sum(out_time - in_time) as total_time
from Employees
group by event_day, emp_id;
```
