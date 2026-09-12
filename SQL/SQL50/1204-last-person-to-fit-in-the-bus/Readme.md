# 1204. Last Person to Fit in the Bus

![Difficulty](https://img.shields.io/badge/Difficulty-Medium-orange)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** CTE · Window Function · SUM() OVER · ORDER BY · LIMIT

---

## ✅ Problem Summary

- There's a queue of people boarding a bus, one at a time, in `turn` order.
- The bus has a weight limit of `1000` kg.
- Find the `person_name` of the **last** person who can board without pushing the cumulative weight over `1000` kg.
- Guaranteed: the first person alone never exceeds the limit.

---

## 🤔 Solution

```sql
WITH cte AS (
    SELECT person_name, turn,
        SUM(weight) OVER(ORDER BY turn ASC) AS p
    FROM Queue
)
SELECT cte.person_name
FROM cte
WHERE cte.p <= 1000
ORDER BY cte.turn DESC
LIMIT 1;
```

---

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `SUM(weight) OVER(ORDER BY turn ASC)` | Computes a **running total** of weight, ordered by boarding turn — each row gets the cumulative weight up to and including that person. |
| `WITH cte AS (...)` | Materializes that running total as `p` so it can be filtered on afterward (window functions can't be referenced in the same query's `WHERE`). |
| `FROM cte` | Outer query reads from the CTE, not the raw table — this is where the computed `p` column actually lives. |
| `WHERE cte.p <= 1000` | Keeps only the people whose running total still fits under the weight limit. |
| `ORDER BY cte.turn DESC LIMIT 1` | Among everyone who still fits, picks the one with the latest turn — i.e. the last person to board before the limit is exceeded. |

---

## 🧠 Why CTE + Window Function?

The `Queue` table just has `person_id, person_name, weight, turn` — no natural join needed here, since this is a single-table running-total problem, not a join problem.

The key relationship is **turn order → cumulative weight**:

```
turn:   1        2        3        4        5        6
        Alice    Alex     John C.  Marie    Bob      Winston
weight: 250      350      400      200      175      500
p:      250      600      1000     1200     1375     1875
                           ▲
                    last one <= 1000
```

A window function is the natural tool here because it lets each row "see" the sum of all rows before it (by `turn`) without collapsing the result into a single aggregated row the way a plain `GROUP BY` would.

Sample result of the CTE:

| person_name | turn | p    |
|---|---|---|
| Alice       | 1    | 250  |
| Alex        | 2    | 600  |
| John Cena   | 3    | 1000 |
| Marie       | 4    | 1200 |
| Bob         | 5    | 1375 |
| Winston     | 6    | 1875 |

Filtering `p <= 1000` and taking the last turn gives `John Cena`.

---

## ⚠️ Why not a correlated subquery?

An alternative is a correlated subquery that, for each row, sums the weight of all people with `turn <= current turn`:

```sql
SELECT person_name
FROM Queue q1
WHERE (SELECT SUM(weight) FROM Queue q2 WHERE q2.turn <= q1.turn) <= 1000
ORDER BY turn DESC
LIMIT 1;
```

This works, but it re-scans and re-sums the table once per row (O(n²) in the worst case), whereas the window function computes the running total in a single pass over the sorted data. The CTE + window function version is both clearer to read and cheaper to run as the table grows.

---

## ⚠️ Common Mistakes

**Putting the aggregate directly in `WHERE`:**
```sql
-- ❌ Fails — aggregate functions can't be used in WHERE
SELECT person_name FROM Queue WHERE SUM(weight) <= 1000;
```
`WHERE` filters rows *before* aggregation happens, so `SUM()` isn't valid there. Same restriction applies to window functions — compute them first (in a CTE or subquery), then filter on the result in an outer query.

**Selecting from the wrong table after building the CTE:**
```sql
-- ❌ cte.p is never actually joined to anything
SELECT cte.person_name FROM Queue WHERE cte.p <= 1000;
```
Once the CTE is defined, the outer query needs to read `FROM cte`, not `FROM Queue`.

**Filtering with `p <= 1000` alone, with no `ORDER BY ... LIMIT 1`:**
This returns *every* person who fits, not just the last one. The problem asks for a single name, so the result needs to be narrowed to the max `turn` (or max `p`) among the qualifying rows.

---

## ⏱️ Time Complexity

O(n log n) — dominated by the sort required for the window function's `ORDER BY turn`; the running-total computation itself is a single linear pass.

---

## 🔑 Key Learnings

- Window functions run after `WHERE` in logical query order, so they can't be filtered on directly — wrap them in a CTE/subquery first.
- A running total ordered by a sequence column (`turn`) is exactly what `SUM() OVER (ORDER BY ...)` is for.
- `ORDER BY p DESC` and `ORDER BY turn DESC` give the same top row here since `p` increases monotonically with `turn` (weights are positive) — either works, but `turn DESC` is more directly tied to what's being asked ("last person").

---

## 🏁 Final Query

```sql
WITH cte AS (
    SELECT person_name, turn,
        SUM(weight) OVER(ORDER BY turn ASC) AS p
    FROM Queue
)
SELECT cte.person_name
FROM cte
WHERE cte.p <= 1000
ORDER BY cte.turn DESC
LIMIT 1;
```
