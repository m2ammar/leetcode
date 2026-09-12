# 619. Biggest Single Number

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** GROUP BY · HAVING · Aggregate Function (MAX) · Derived Table

---

## ✅ Problem Summary
- Find numbers in `MyNumbers` that appear exactly once (no duplicates)
- Return the **largest** such number
- If no unique number exists, return `NULL`

---

## 🧠 Solution
```sql
select max(num) as num
from (
    select num from MyNumbers
    group by num
    having count(num) = 1
) as t;
```

---

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `group by num` | Groups all identical `num` values together |
| `having count(num) = 1` | Keeps only groups where the number appears exactly once (i.e., unique) |
| `as t` | Alias required by MySQL — any subquery in `FROM` must be named (derived table) |
| `max(num)` | Aggregates over the filtered result; always returns exactly one row, even if empty |

---

## 🤔 Why a Derived Table?
The filtering (`GROUP BY` + `HAVING`) has to happen *before* the max can be taken — but SQL doesn't let you re-aggregate on top of a `HAVING` result in the same `SELECT`. So the filtered result is nested as a temporary table (`t`) in the `FROM` clause, and the outer query treats it like any other table.
MyNumbers → GROUP BY + HAVING → t (derived table) → MAX(num)
[8,8,3,3,1,4] (unique nums only) [1, 4] 4

Sample result of inner query (`t`):
| num |
|---|
| 1 |
| 4 |

---

## ⚠️ Why not `ORDER BY ... LIMIT 1`?
`ORDER BY num DESC LIMIT 1` also picks the largest value — but only if a row exists. If **no** unique number exists, the filtered result is empty, and `LIMIT` on an empty set returns **zero rows**, not a row with `NULL`.

`MAX()` is an aggregate function, so it always collapses its input into exactly one row — even an empty one becomes `NULL`. That matches what LeetCode expects for the no-unique-value case.

---

## ⚠️ Common Mistakes

**Mistake 1: Comparing against a scalar count**
```sql
-- Wrong: compares num against a single total-count value, not per-value duplicates
where num in (select count(distinct num) from MyNumbers)
```
Fix: use `GROUP BY` + `HAVING COUNT(num) = 1` to check per-value duplication, not a table-wide count.

**Mistake 2: Sorting inside GROUP BY**
```sql
-- Wrong: GROUP BY only takes column names, not DESC or DISTINCT()
group by distinct(num) desc
```
Fix: sorting belongs in `ORDER BY`, not `GROUP BY`.

**Mistake 3: Using LIMIT instead of MAX for the NULL case**
```sql
-- Wrong: returns zero rows (not a NULL row) when nothing is unique
having count(num) = 1
order by num desc
limit 1
```
Fix: wrap the filtered result in a subquery and apply `MAX()` outside it.

---

## ⏱️ Time Complexity
O(n) — single pass to group and count, MySQL typically uses a hash/temp table for the `GROUP BY`.

---

## 🔑 Key Learnings
- `GROUP BY` only accepts column names — no `DESC`, no `DISTINCT()` wrapping
- A subquery placed in `FROM` is a **derived table** and *requires* an alias — even if unused downstream
- `LIMIT` returns nothing on an empty set; `MAX()` (and aggregates generally) always return exactly one row
- "Return NULL if none exists" is a strong signal to use an aggregate function as the outermost layer

---

## Final Query
```sql
select max(num) as num
from (
    select num from MyNumbers
    group by num
    having count(num) = 1
) as t;
```
