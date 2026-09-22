# 607. Sales Person

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** LEFT JOIN · GROUP BY · HAVING · Aggregate Functions (SUM) · IF() · NULL Handling

---

## ✅ Problem Summary

- Find the names of all salespersons who did **not** have any order related to the company named `"RED"`.
- A salesperson with **no orders at all** must still be included.
- A salesperson with **even one** order to RED must be **excluded entirely**, even if they also have orders to other companies.
- Return the result in any order.

---

## 🧩 Solution

```sql
select s.name
from SalesPerson as s
left join Orders as o
    on o.sales_id = s.sales_id
left join Company as c
    on c.com_id = o.com_id
group by s.name
having SUM(IF(c.name = 'RED', 1, 0)) = 0;
```

---

## 🔍 Breakdown

| Clause | What it does |
|---|---|
| `left join Orders` | Keeps every salesperson even if they have zero orders (unmatched rows get `NULL` in Orders columns) |
| `left join Company` | Brings in the company name for each order; still `NULL` if there was no order |
| `group by s.name` | Collapses all of a salesperson's order rows into a single group, so we can judge them on their **whole order history** at once |
| `SUM(IF(c.name = 'RED', 1, 0))` | Counts how many of that salesperson's rows were RED orders (NULL rows count as 0, since `NULL = 'RED'` is never TRUE) |
| `having ... = 0` | Keeps only the groups where that count is zero — i.e. no RED orders anywhere in the group |

---

## 🤔 Why GROUP BY + HAVING?

The three tables relate like this:

```
SalesPerson (1) ---< Orders >--- (1) Company
    sales_id            sales_id      com_id
                         com_id
```

A single salesperson can appear in **multiple** Orders rows — one per order, each pointing at a (possibly different) company. To decide "did this person ever order from RED," we need to look at **all their rows together**, not one row in isolation. `GROUP BY s.name` creates exactly that per-person bucket, and `HAVING` filters on an aggregate computed over the whole bucket.

Sample grouped state (from the example data) before `HAVING`:

| name | rows (company per order) | SUM(IF(name='RED',1,0)) |
|---|---|---|
| John | RED | 1 |
| Amy  | (no orders → NULL) | 0 |
| Mark | (no orders → NULL) | 0 |
| Pam  | YELLOW, RED | 1 |
| Alex | GREEN | 0 |

Only Amy, Mark, and Alex have a sum of 0, so they're the ones kept.

---

## 🚫 Why not `WHERE c.name != 'RED'`?

`WHERE` filters **row by row**, before any grouping happens — it has no concept of "this person's other rows." That breaks in two ways:

1. **A salesperson with no orders** has `c.name = NULL`. In SQL, `NULL != 'RED'` doesn't evaluate to TRUE — it evaluates to `UNKNOWN`, and `WHERE` drops anything that isn't TRUE. So they'd be wrongly excluded.
2. **A salesperson with multiple orders** (like Pam: one to YELLOW, one to RED) has one row filtered out (the RED one) but their other row (YELLOW) still passes the filter — so they'd wrongly appear in the result, even though they *did* order from RED.

`HAVING` fixes both, because it runs **after** grouping and judges the person as a whole, not one row at a time.

---

## 📊 JOIN Types at a Glance

| Join | Keeps unmatched left rows? | Use here? |
|---|---|---|
| `INNER JOIN` | No | ❌ Drops salespeople with zero orders (loses Amy, Mark) |
| `LEFT JOIN` | Yes (fills right side with NULL) | ✅ Needed so every salesperson appears at least once |
| `RIGHT JOIN` | Keeps unmatched right rows instead | ❌ Wrong direction — Orders isn't the table we need "all of" |

---

## ⚠️ Common Mistakes

**1. Using INNER JOIN and `WHERE c.name != 'RED'`**
```sql
-- ❌ Drops salespeople with no orders (Amy, Mark) entirely,
--    and still leaks Pam through her non-RED order row.
select s.name
from SalesPerson as s
join Orders as o on o.sales_id = s.sales_id
join Company as c on c.com_id = o.com_id
where c.name != 'RED';
```
✅ Fix: switch to `LEFT JOIN` so people with no orders are kept, and move the RED check into a `GROUP BY` + `HAVING` so it's judged per-person, not per-row.

**2. Adding `c.com_id IS NOT NULL` to try to "fix" the NULL case**
```sql
-- ❌ This actually makes it worse — it requires a company to exist,
--    which excludes people with no orders (the opposite of what we want).
where c.name != 'RED' and c.com_id is not null;
```
✅ Fix: don't try to patch row-level `WHERE` logic for a group-level question — use `HAVING SUM(...) = 0` instead.

**3. Using `OR c.com_id IS NULL` inside `WHERE`**
```sql
-- ❌ Correctly rescues salespeople with no orders, but still lets a
--    person like Pam through via their surviving non-RED row.
where c.name != 'RED' or c.com_id is null;
```
✅ Fix: this is still row-by-row filtering. Only `GROUP BY` + `HAVING` (or `NOT IN` / `NOT EXISTS`) can exclude someone based on *any* row in their group matching RED.

---

## ⏱️ Time Complexity

O(n) for the two joins (n = number of Orders rows, assuming indexed foreign keys), plus O(n log n) for the grouping step, depending on the query planner.

---

## 🔑 Key Learnings

- `WHERE` filters individual rows **before** grouping; `HAVING` filters whole groups **after** aggregation — they answer different kinds of questions.
- "Exclude someone if ANY of their related rows match a condition" is a signature `GROUP BY` + `HAVING` (or `NOT EXISTS`) pattern — `WHERE` alone can't express it.
- Comparisons against `NULL` (`=`, `!=`) evaluate to `UNKNOWN`, not `TRUE`/`FALSE` — and `UNKNOWN` is treated as false by `WHERE`/`HAVING`. Wrapping the comparison in `IF(..., 1, 0)` sidesteps this, since `IF` treats anything not-TRUE as the false branch.
- `LEFT JOIN` is what preserves "zero matches" cases (like a salesperson with no orders) that an `INNER JOIN` would silently drop.

---

## 🧠 Final Query

```sql
select s.name
from SalesPerson as s
left join Orders as o
    on o.sales_id = s.sales_id
left join Company as c
    on c.com_id = o.com_id
group by s.name
having SUM(IF(c.name = 'RED', 1, 0)) = 0;
```
