# 1050. Actors and Directors Who Cooperated At Least Three Times

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** `GROUP BY` · `HAVING` · `COUNT()` · Multi-column grouping

---

## ✅ Problem Summary

Given the `ActorDirector` table, the query must:

- ✔ Return every `(actor_id, director_id)` pair
- ✔ Include only pairs that appear **at least 3 times** (each row = one cooperation)
- ✔ Return the result in **any order**

---

## 💡 Solution

```sql
select actor_id, director_id
from ActorDirector
group by actor_id, director_id
having count(actor_id) >= 3;
```

---

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `select actor_id, director_id` | Returns the pair, which is exactly the output format asked for |
| `from ActorDirector` | Reads the table where each row is one cooperation |
| `group by actor_id, director_id` | Collapses all rows of the same pair into one group |
| `having count(actor_id) >= 3` | Keeps only groups that contain 3 or more rows |

---

## 🤔 Why `GROUP BY` on both columns?

"Pairs" means the **combination** of actor and director, not each one alone. Grouping by both columns makes each unique pair its own group.

```
(actor_id, director_id)  ->  rows in group
      (1, 1)             ->  3   ✅ kept
      (1, 2)             ->  2   ❌ dropped
      (2, 1)             ->  2   ❌ dropped
```

Sample result of the grouping step (before `HAVING`):

| actor_id | director_id | count |
|---|---|---|
| 1 | 1 | 3 |
| 1 | 2 | 2 |
| 2 | 1 | 2 |

Only `(1, 1)` passes the `>= 3` filter.

---

## 🔀 Why not a subquery?

An alternative is to compute the count in a subquery and filter it in the outer query:

```sql
select actor_id, director_id
from (
    select actor_id, director_id, count(*) as cnt
    from ActorDirector
    group by actor_id, director_id
) t
where cnt >= 3;
```

This also works, but it adds an extra layer for no benefit. `HAVING` is built for filtering on aggregates, so it is shorter and clearer.

---

## 📊 `WHERE` vs `HAVING` at a Glance

| | `WHERE` | `HAVING` |
|---|---|---|
| Runs | **Before** grouping | **After** grouping |
| Filters | Individual rows | Whole groups |
| Can use aggregates (`COUNT`, `SUM`)? | ❌ No | ✅ Yes |

---

## ⚠️ Common Mistakes

**1. Empty `count()`**

```sql
having count() >= 3   -- ❌ syntax error
```

Fix: tell the function what to count.

```sql
having count(*) >= 3          -- ✅ counts every row in the group
having count(actor_id) >= 3   -- ✅ counts non-NULL actor_id values
```

**2. Using `WHERE` with an aggregate**

```sql
where count(*) >= 3   -- ❌ groups don't exist yet at this stage
```

Fix: use `HAVING`, which runs after `GROUP BY`.

**3. Grouping by only one column**

```sql
group by actor_id   -- ❌ counts all of an actor's work, across every director
```

Fix: group by **both** `actor_id` and `director_id` to count each pair separately.

---

## ⏱️ Time Complexity

**O(n)** with hash-based aggregation (or **O(n log n)** if the engine sorts to group), where `n` is the number of rows in `ActorDirector`. The table is scanned once.

---

## 🧠 Key Learnings

- "Pairs" in the problem means grouping by multiple columns together
- "At least N times" is the signal for `GROUP BY` + `HAVING COUNT(...) >= N`
- `WHERE` filters rows before grouping, `HAVING` filters groups after it
- `COUNT(*)` counts all rows, while `COUNT(column)` skips NULLs in that column

---

## 🏁 Final Query

```sql
select actor_id, director_id
from ActorDirector
group by actor_id, director_id
having count(actor_id) >= 3;
```
