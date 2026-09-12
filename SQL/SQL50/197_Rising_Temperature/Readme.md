# 197. Rising Temperature

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** `SELF JOIN` · `DATEDIFF()` · `WHERE`

---

## 📋 Problem Summary

Table `Weather` has one row per date with a `temperature`. No two rows share the same `recordDate`.

Find the `id` of every date whose temperature was **higher than the previous day's** temperature. Return in any order.

---

## ✅ Solution

```sql
SELECT w1.id AS Id
FROM Weather AS w1
JOIN Weather AS w2
  ON DATEDIFF(w1.recordDate, w2.recordDate) = 1
WHERE w1.temperature > w2.temperature;
```

---

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `JOIN Weather AS w2 ON DATEDIFF(w1.recordDate, w2.recordDate) = 1` | Pairs each row (`w1`, "today") with the row exactly one day earlier (`w2`, "yesterday") |
| `WHERE w1.temperature > w2.temperature` | Keeps only pairs where today's temperature beat yesterday's |
| `SELECT w1.id` | Returns today's id, since that's the date we're reporting on |

---

## ⚠️ Why a Self-Join + DATEDIFF (not a subquery)

There's no `previous_day` column in the table — "yesterday" only exists as *another row* that happens to be one day earlier. A self-join with `DATEDIFF(...) = 1` in the `ON` clause is what manufactures that "today ↔ yesterday" relationship row by row, without assuming the data is sorted or gapless.

`DATEDIFF(date1, date2)` returns `date1 - date2` in days:

```sql
DATEDIFF('2015-01-02', '2015-01-01')  -- 1
DATEDIFF('2015-01-01', '2015-01-02')  -- -1
```

---

## ❌ Common Mistakes

- Using `LAG()` without realizing dates might have gaps — `DATEDIFF = 1` correctly excludes non-consecutive dates, while a plain `LAG()` by row order would not.
- Comparing `w1.recordDate - w2.recordDate = 1` directly on date types instead of `DATEDIFF` — not portable across all SQL dialects, though MySQL tolerates it.
- Mixing up which alias is "today" vs "yesterday" — flips the whole result.

---

## ⏱️ Time Complexity

**O(n²)** in the worst case without indexing on `recordDate`, since every row is compared against every other row to find the one-day match.

---

## 🔑 Key Learnings

- General pattern for **"compare a row to the previous row"**: self-join the table to itself, pair rows via a date/order condition in `ON`, then apply the actual comparison in `WHERE`.
- `DATEDIFF(a, b) = 1` is more robust than assuming consecutive row order, since it explicitly checks calendar-day adjacency.
- No `LIMIT` needed — the result is *every* qualifying row, not a fixed count.

---

## 🧠 Final Query

```sql
SELECT w1.id AS Id
FROM Weather AS w1
JOIN Weather AS w2
  ON DATEDIFF(w1.recordDate, w2.recordDate) = 1
WHERE w1.temperature > w2.temperature;
```
