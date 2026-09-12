# 620. Not Boring Movies
![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** `WHERE` filtering · Modulo (`%`) · `ORDER BY`

---

## 📋 Problem Summary
Report movies with an **odd-numbered ID** whose description is **not**
`"boring"`. Return the result ordered by `rating` in descending order.

---

## ✅ Solution
```sql
SELECT id, movie, description, rating
FROM Cinema
WHERE id % 2 != 0 AND description != 'boring'
ORDER BY rating DESC;
```

---

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `id % 2 != 0` | Keeps only rows with an odd `id` (modulo 2 leaves a remainder of 1 for odd numbers, 0 for even) |
| `description != 'boring'` | Excludes any movie explicitly tagged `"boring"` |
| `ORDER BY rating DESC` | Sorts the filtered result from highest to lowest rating |

---

## 🤔 Why modulo instead of `id IN (1,3,5,...)`?
Hardcoding odd IDs only works for a fixed, known dataset. `id % 2 != 0` is
a **general rule** — it works no matter how many rows the table has or
what the actual ID values are, without ever needing to be updated.

---

## ⚠️ Common Mistakes

### Using `id % 2 = 1` only
```sql
WHERE id % 2 = 1  -- ⚠️ works in MySQL, but assumes non-negative integers
```
`id % 2 != 0` is the safer general form — it doesn't assume the remainder
of an odd number is always exactly `1` (irrelevant here since `id` is a
positive primary key, but worth knowing for other engines/datatypes).

### Forgetting to filter `description` before sorting
```sql
SELECT * FROM Cinema WHERE id % 2 != 0 ORDER BY rating DESC;  -- ❌ includes boring movies
```
Both conditions must be applied in the same `WHERE` clause — filtering
only on `id` still lets boring movies with odd IDs through.

---

## ⏱️ Time Complexity
**O(n)** — a single linear scan over the `Cinema` table to filter, plus
an `O(n log n)` sort for `ORDER BY`. No joins or subqueries involved.

---

## 🔑 Key Learnings
- `%` (modulo) is the standard way to check even/odd directly in SQL —
  no need to pull data out and filter elsewhere.
- Multiple conditions in one `WHERE` clause (`AND`) are evaluated
  together per row — order of the conditions doesn't affect the result,
  only readability.
- Filtering happens **before** sorting; `ORDER BY` only ever sees rows
  that already passed the `WHERE` clause.

---

## 🧠 Final Query
```sql
SELECT id, movie, description, rating
FROM Cinema
WHERE id % 2 != 0 AND description != 'boring'
ORDER BY rating DESC;
```
