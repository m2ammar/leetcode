# 1211. Queries Quality and Percentage

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** GROUP BY · Aggregate Functions (SUM, COUNT) · CASE WHEN · ROUND

---

## ✅ Problem Summary

For each `query_name`, return:
- ✔️ `quality` — the average of `rating / position` across all its queries
- ✔️ `poor_query_percentage` — the percentage of its queries with `rating < 3`
- ✔️ Both values rounded to 2 decimal places

---

## 🧩 Solution

```sql
SELECT
    query_name,
    ROUND(SUM(rating / position) / COUNT(*), 2) AS quality,
    ROUND(SUM(CASE WHEN rating < 3 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS poor_query_percentage
FROM Queries
GROUP BY query_name;
```

---

## 🔍 Breakdown

| Clause | Purpose |
|---|---|
| `GROUP BY query_name` | Groups all rows so calculations happen per query_name, not across the whole table |
| `SUM(rating / position) / COUNT(*)` | Averages the `rating / position` ratio across all rows in the group — this is `quality` |
| `SUM(CASE WHEN rating < 3 THEN 1 ELSE 0 END)` | Counts only the "poor" rows (rating < 3) within the group |
| `... / COUNT(*) * 100` | Converts the poor-row count into a percentage of the group's total rows |
| `ROUND(..., 2)` | Rounds both outputs to 2 decimal places as required |

---

## 🤔 Why conditional aggregation (`CASE WHEN` inside `SUM`)?

`Queries` has one row per (query_name, result) pair, with `rating` and `position` attached to each row.

```
Queries
+------------+----------+--------+
| query_name | position | rating |
+------------+----------+--------+
| Dog        | 1        | 5      |  ─┐
| Dog        | 2        | 5      |   ├─ grouped by query_name
| Dog        | 200      | 1      |  ─┘
| Cat        | 5        | 2      |  ─┐
| Cat        | 3        | 3      |   ├─ grouped by query_name
| Cat        | 7        | 4      |  ─┘
+------------+----------+--------+
```

Both `quality` and `poor_query_percentage` need to be computed **per group**, but they depend on different slices of the same rows — `quality` uses every row, while `poor_query_percentage` only cares about a subset (`rating < 3`). Wrapping the condition in `SUM(CASE WHEN ... THEN 1 ELSE 0 END)` lets that subset be counted *inside* the same aggregation pass as `quality`, without a second scan of the table.

Sample result:

| query_name | quality | poor_query_percentage |
|---|---|---|
| Dog | 2.50 | 33.33 |
| Cat | 0.66 | 33.33 |

---

## ⚠️ Why not a correlated subquery?

An earlier draft tried:

```sql
ROUND((SELECT COUNT(rating) / COUNT(*) * 100 FROM Queries WHERE rating < 3), 2)
```

This fails for two reasons:
- The subquery isn't correlated to the outer `query_name`, so it computes one global percentage and repeats it for every group instead of a per-group value.
- Even correlated, filtering the subquery's `FROM` with `WHERE rating < 3` makes `COUNT(rating)` and `COUNT(*)` count the same filtered rows — always 100%, since both counts run over the same restricted set.

Conditional aggregation avoids both problems: it stays inside the outer `GROUP BY`, and the `CASE WHEN` — not a `WHERE` clause — is what does the filtering, so `COUNT(*)` still reflects the group's true total.

---

## 🚨 Common Mistakes

**Mistake 1 — forgetting `SUM()` around the `CASE`:**
```sql
-- ❌ Wrong: CASE isn't aggregated, MySQL picks it from an arbitrary row in the group
ROUND((CASE WHEN rating < 3 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2)
```
```sql
-- ✅ Fix: wrap it in SUM so it's counted across the whole group
ROUND(SUM(CASE WHEN rating < 3 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2)
```

**Mistake 2 — using an uncorrelated subquery for a per-group percentage:**
```sql
-- ❌ Wrong: computes one global percentage for every query_name
(SELECT COUNT(rating) / COUNT(*) * 100 FROM Queries WHERE rating < 3)
```
```sql
-- ✅ Fix: use conditional aggregation within the same GROUP BY instead
SUM(CASE WHEN rating < 3 THEN 1 ELSE 0 END) / COUNT(*) * 100
```

---

## ⏱️ Time Complexity

`O(n)` — a single pass over the table, grouped by `query_name`; no subqueries or extra scans.

---

## 🔑 Key Learnings

- MySQL will silently accept an unaggregated expression mixed with aggregates in the same `SELECT` (non-standard `GROUP BY` behavior) — always aggregate every expression explicitly to avoid picking an arbitrary row's value.
- Conditional aggregation (`SUM(CASE WHEN ... THEN 1 ELSE 0 END)`) is the standard pattern for computing a filtered metric alongside an unfiltered one in the same `GROUP BY` pass.
- A subquery that references the outer query's grouping column must actually reference it to be correlated — otherwise it collapses to one value for the whole table.

---

## 🧠 Final Query

```sql
SELECT
    query_name,
    ROUND(SUM(rating / position) / COUNT(*), 2) AS quality,
    ROUND(SUM(CASE WHEN rating < 3 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS poor_query_percentage
FROM Queries
GROUP BY query_name;
```
