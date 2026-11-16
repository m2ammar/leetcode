# 3808. Find Emotionally Consistent Users

![Difficulty](https://img.shields.io/badge/Difficulty-Medium-orange)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-brightgreen)

**Concepts:** `CTE` · `GROUP BY` · `Window Function` · `SUM() OVER` · `PARTITION BY` · `ROUND` · `WHERE`

---

## ✅ Problem Summary

- Count each user's total reactions
- Keep only users with **at least 5** reactions (each row is a different content item, since `(user_id, content_id)` is the primary key)
- Keep a user only if **at least 60%** of their reactions are the same type
- Return `user_id`, `dominant_reaction`, `reaction_ratio` (rounded to 2 decimals)
- Order by `reaction_ratio` DESC, then `user_id` ASC

---

## 💡 Solution

```sql
WITH cte AS (
    SELECT user_id,
           reaction,
           COUNT(*) AS cnt,
           SUM(COUNT(*)) OVER (PARTITION BY user_id) AS total
    FROM reactions
    GROUP BY user_id, reaction
)
SELECT user_id,
       reaction AS dominant_reaction,
       ROUND(cnt / total, 2) AS reaction_ratio
FROM cte
WHERE total >= 5
  AND cnt / total >= 0.6
ORDER BY reaction_ratio DESC, user_id ASC;
```

---

## 🤔 Breakdown

| Clause | What it does |
|---|---|
| `GROUP BY user_id, reaction` | Collapses the table to one row per (user, reaction) pair |
| `COUNT(*) AS cnt` | How many times this user gave this reaction (numerator) |
| `SUM(COUNT(*)) OVER (PARTITION BY user_id)` | Adds up the `cnt` values of all of that user's rows, giving the user's total reactions (denominator) |
| `WHERE total >= 5` | Keeps users with at least 5 reactions |
| `WHERE cnt / total >= 0.6` | Keeps only the reaction that makes up 60%+ of the user's reactions |
| `ROUND(cnt / total, 2)` | Rounds only for display, after filtering |
| `ORDER BY` | Ratio high to low, then user id low to high |

---

## 🧩 Why CTE + Window Function?

The numerator and the denominator live at **different grain levels**:

- `cnt` is per (user, reaction)
- `total` is per user

A single `GROUP BY` can only produce one level. The window function runs *after* grouping, on the grouped rows, so it can sum the per-reaction counts into a per-user total without losing the per-reaction rows.

```
reactions (raw rows)
   │  GROUP BY user_id, reaction
   ▼
(user, reaction, cnt)  ──SUM(cnt) OVER (PARTITION BY user_id)──►  + total
   │
   ▼
outer query: plain WHERE filter on cnt and total
```

Sample CTE rows for user 1:

| user_id | reaction | cnt | total |
|---|---|---|---|
| 1 | like | 4 | 5 |
| 1 | wow | 1 | 5 |

---

## ⚖️ Why not a self-join / second subquery?

You could compute totals in a separate `GROUP BY user_id` subquery and join it back on `user_id`. It works, but it scans and joins twice. The window version keeps everything in one pass and reads top to bottom.

---

## ⚠️ Common Mistakes

**1. Dividing counts from the same group**
```sql
COUNT(reaction) / COUNT(*)   -- always n / n = 1
```
Fix: get the numerator and denominator at different grains (CTE + window).

**2. Window function inside `HAVING`**
```sql
HAVING COUNT(*) OVER (...) >= 0.6   -- windows run after HAVING
```
Fix: compute it in a CTE, then filter in the outer query.

**3. Aggregating again in the outer query**
```sql
FROM cte GROUP BY user_id, reaction   -- CTE is already one row per pair
```
Fix: the outer query only needs `WHERE`, no `GROUP BY` or `HAVING`.

**4. Filtering on the `ROUND` alias**
```sql
WHERE reaction_ratio >= 0.6   -- alias not available in WHERE, and rounding first can flip results (0.595 → 0.60)
```
Fix: filter on `cnt / total >= 0.6`, round only in `SELECT`.

---

## ⏱️ Time Complexity

`O(n)` for the grouping pass, plus a window over the grouped rows and a sort on the (small) result.

---

## 🔑 Key Learnings

- Decide the **grain** of each row before writing any filter
- Window functions run after `GROUP BY` and `HAVING`, and can wrap aggregates like `SUM(COUNT(*)) OVER (...)`
- `WHERE` filters plain columns, `HAVING` filters aggregates, and neither can use a `SELECT` alias for a rounded value
- Round at the end, never before comparing
- With a threshold of 60%, at most one reaction per user can qualify, so no tie handling is needed

---

## 📌 Final Query

```sql
WITH cte AS (
    SELECT user_id,
           reaction,
           COUNT(*) AS cnt,
           SUM(COUNT(*)) OVER (PARTITION BY user_id) AS total
    FROM reactions
    GROUP BY user_id, reaction
)
SELECT user_id,
       reaction AS dominant_reaction,
       ROUND(cnt / total, 2) AS reaction_ratio
FROM cte
WHERE total >= 5
  AND cnt / total >= 0.6
ORDER BY reaction_ratio DESC, user_id ASC;
```
