![Difficulty](https://img.shields.io/badge/Difficulty-Medium-orange)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** `LEFT JOIN` · subquery · `GROUP BY` · conditional aggregation · `IFNULL` · `ROUND`

---

## 📋 Problem Summary
Table `Signups` holds every user who signed up. Table `Confirmations` holds every confirmation request a user made, along with whether it was `'confirmed'` or `'timeout'`.

Find the **confirmation rate** for every user:

confirmed requests / total requests   (rounded to 2 decimal places)

Users with no confirmation requests at all should show a rate of `0`.

---

## ✅ Solution
```sql
SELECT s.user_id, IFNULL(a.rate, 0) AS confirmation_rate
FROM Signups AS s
LEFT JOIN (
    SELECT user_id, ROUND(SUM(action = 'confirmed') / COUNT(*), 2) AS rate
    FROM Confirmations
    GROUP BY user_id
) AS a ON a.user_id = s.user_id;
```

---

## 🧩 Breakdown
| Clause | What it does |
|---|---|
| `GROUP BY user_id` | Bundles all confirmation requests together per user |
| `SUM(action = 'confirmed')` | Counts how many of those requests were `'confirmed'` |
| `COUNT(*)` | Total number of requests (confirmed + timeout) for that user |
| `ROUND(..., 2)` | Rounds the rate to 2 decimal places |
| `LEFT JOIN ... ON a.user_id = s.user_id` | Keeps every signed-up user, even those with no confirmation rows |
| `IFNULL(a.rate, 0)` | Converts missing (`NULL`) rates into `0` |

---

## ⚠️ Why the join is needed
The subquery only ever looks at the `Confirmations` table — it can compute a rate for users who *made requests*, but it has no way to know about users who signed up and never requested a confirmation at all. That information only lives in `Signups`.

So the tables get used in two different roles:
- **`Confirmations` (subquery)** — used to calculate each active user's rate.
- **`Signups` (outer query, `s`)** — used as the full source of truth for *which users must appear* in the result.

The `LEFT JOIN` connects those two roles by matching `s.user_id` to `a.user_id`, keeping every signup regardless of whether they have a matching row in the subquery.

---

## ❌ Common Mistakes
- **Filtering before aggregating** — `WHERE action = 'confirmed'` inside the subquery throws away the `'timeout'` rows before `COUNT(*)` runs, so the rate always comes out as `1`. Aggregate over all rows, and only condition the numerator.
- **Using `JOIN` instead of `LEFT JOIN`** — drops users who never made a single confirmation request, even though the problem requires them to appear with a rate of `0`.
- **Forgetting `IFNULL`** — users with no matching subquery row return `NULL`, not `0`, unless wrapped explicitly.
- **Forgetting to alias the computed column** (`AS rate`) — without a name, the outer query has nothing to reference.

---

## ⏱️ Time Complexity
**O(n)** — one pass to aggregate `Confirmations` by `user_id`, one pass to join back with `Signups`, both typically optimized with an index on `user_id`.

---

## 🔑 Key Learnings
- Boolean expressions (`col = value`) evaluate to `1`/`0` in MySQL and can be used inside aggregates like `SUM()` or `AVG()` — not just inside `WHERE`. This is called **conditional aggregation**.
- Aggregate first, filter/condition second — filtering too early can silently corrupt a denominator.
- `LEFT JOIN` + `IFNULL` is the standard pattern for "include everyone, default missing values to 0."
- SQL clauses execute in this logical order: `FROM/JOIN → WHERE → GROUP BY → HAVING → SELECT → ORDER BY` — which is why a column from a joined subquery (like `a.rate`) can be referenced in the outer `SELECT`.

---

## 🧠 Final Query
```sql
SELECT s.user_id, IFNULL(a.rate, 0) AS confirmation_rate
FROM Signups AS s
LEFT JOIN (
    SELECT user_id, ROUND(SUM(action = 'confirmed') / COUNT(*), 2) AS rate
    FROM Confirmations
    GROUP BY user_id
) AS a ON a.user_id = s.user_id;
```
