# 180. Consecutive Numbers

![Difficulty](https://img.shields.io/badge/Difficulty-Medium-orange)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-brightgreen)

**Concepts:** CTE · Window Functions · LAG · LEAD · DISTINCT

---

## ✅ Problem Summary

Given a `Logs` table with columns `id` (primary key, autoincrement) and `num`:
- [x] Find every `num` value that appears **at least three times in a row** (consecutively, by `id` order)
- [x] Return the result as a single column `ConsecutiveNums`, with no duplicates, in any order

---

## 🧠 Solution

```sql
with cte as (
    select id, num,
    Lag(num, 1) OVER (order by id asc) as num1,
    LEAD(num, 1) OVER (order by id asc) as num2
from Logs
)
select distinct(num) as ConsecutiveNums
from cte
where num = num1 AND num = num2;
```

---

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `LAG(num, 1) OVER (ORDER BY id ASC)` | Pulls the `num` value from the **previous** row (by `id` order) into the current row as `num1` |
| `LEAD(num, 1) OVER (ORDER BY id ASC)` | Pulls the `num` value from the **next** row (by `id` order) into the current row as `num2` |
| `WITH cte AS (...)` | Materializes the row + its neighbors' values so they can be filtered afterward — window functions can't be referenced directly in a `WHERE` at the same query level where they're computed |
| `WHERE num = num1 AND num = num2` | Keeps only rows where the current value matches **both** its previous and next neighbor — i.e. three equal values in a row |
| `SELECT DISTINCT(num)` | Removes duplicate output rows (a run of 4+ equal values would otherwise produce multiple matching rows for the same `num`) |

---

## 🤔 Why LAG/LEAD?

`LAG` and `LEAD` are window functions built exactly for "look at the neighboring row" problems, without needing a self-join.

```
Logs (ordered by id)
┌────┬─────┐        num1 (LAG)   num   num2 (LEAD)
│ id │ num │
├────┼─────┤        ┌─────┬─────┬─────┐
│ 1  │  1  │  ───►   │  -  │  1  │  1  │
│ 2  │  1  │  ───►   │  1  │  1  │  1  │  ← passes: 1=1=1
│ 3  │  1  │  ───►   │  1  │  1  │  2  │
│ 4  │  2  │  ───►   │  1  │  2  │  1  │
│ 5  │  1  │  ───►   │  2  │  1  │  2  │
│ 6  │  2  │  ───►   │  1  │  2  │  2  │
│ 7  │  2  │  ───►   │  2  │  2  │  -  │
└────┴─────┘        └─────┴─────┴─────┘
```

Only `id=2` (num=1) has both neighbors equal to itself, so `1` is the only value returned.

**Sample result:**

| ConsecutiveNums |
|---|
| 1 |

---

## ⚠️ Why not a self-join?

Before window functions were available (MySQL 8.0+), this problem was typically solved with a **three-way self-join**:

```sql
SELECT DISTINCT l1.num AS ConsecutiveNums
FROM Logs l1, Logs l2, Logs l3
WHERE l1.id = l2.id - 1
  AND l2.id = l3.id - 1
  AND l1.num = l2.num
  AND l2.num = l3.num;
```

Both work, but the window-function version is generally preferred today:
- No cartesian join across three copies of the table
- Reads closer to the plain-English requirement ("compare each row to its neighbors")
- Scales better conceptually if the "at least N consecutive" threshold ever changes

---

## ⚠️ Common Mistakes

**Mistake 1 — Grouping before comparing:**
```sql
-- ❌ Wrong: GROUP BY collapses rows and loses id order entirely
SELECT num
FROM Logs
GROUP BY num
HAVING COUNT(*) >= 3;
```
This only checks that a number appears 3+ times *anywhere* in the table, not 3 times *in a row*.

**Mistake 2 — Grouping by the primary key inside the CTE:**
```sql
-- ❌ Wrong: id is the primary key, so every group has exactly 1 row
...
GROUP BY id
HAVING COUNT(*) >= 3
```
`COUNT(*)` is always `1` per `id`, so the `HAVING` clause is never true — the query silently returns nothing.

**Mistake 3 — Only comparing the neighbors to each other:**
```sql
-- ❌ Wrong: doesn't confirm the current row matches its neighbors
WHERE num1 = num2
```
This passes whenever the previous and next values match *each other*, even if the current row's `num` is different. Must check `num = num1 AND num = num2`.

---

## ⚠️ Hidden Assumption: Gaps in `id`

`LAG`/`LEAD` ordered by `id` treat whatever row comes next in sort order as the "neighbor" — they don't check that `id` values are actually sequential (differ by 1). If `id` had gaps (e.g. from deleted rows), two non-adjacent log entries could be treated as consecutive. LeetCode's test data for this problem has no gaps in `id`, so it doesn't affect correctness here — but it's worth knowing before reusing this pattern on a real, messier table.

---

## ⏱️ Time Complexity

O(n log n) — dominated by the sort implied by `ORDER BY id` in the window function; the rest is a single linear pass.

---

## 🔑 Key Learnings

- `LAG`/`LEAD` are the go-to window functions for "compare a row to its neighbors" problems
- Window function results can't be filtered directly in the same query level — wrap them in a CTE first, then filter in the outer query
- `GROUP BY` on a primary key is a red flag — every group will have exactly one row
- `DISTINCT` (or `GROUP BY`) at the end matters whenever a run could be longer than the minimum required length

---

## 🧾 Final Query

```sql
with cte as (
    select id, num,
    Lag(num, 1) OVER (order by id asc) as num1,
    LEAD(num, 1) OVER (order by id asc) as num2
from Logs
)
select distinct(num) as ConsecutiveNums
from cte
where num = num1 AND num = num2;
```
