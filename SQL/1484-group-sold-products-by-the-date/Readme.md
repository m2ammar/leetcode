# 1484. Group Sold Products By The Date

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

## ✅ Problem Summary
- For each `sell_date`, find the number of distinct products sold (`num_sold`)
- List those distinct product names, sorted lexicographically, comma-separated (`products`)
- Return the result ordered by `sell_date`

## 🧠 Solution
```sql
SELECT
    sell_date,
    COUNT(DISTINCT product) AS num_sold,
    GROUP_CONCAT(DISTINCT product ORDER BY product SEPARATOR ',') AS products
FROM Activities
GROUP BY sell_date
ORDER BY sell_date;
```

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `GROUP BY sell_date` | Collapses all rows for the same date into one group |
| `COUNT(DISTINCT product)` | Counts unique product names within each date's group |
| `GROUP_CONCAT(DISTINCT product ORDER BY product SEPARATOR ',')` | Concatenates the unique product names in a group into one sorted, comma-separated string |
| `ORDER BY sell_date` | Sorts the final result set by date |

## 🤔 Why GROUP_CONCAT?
`Activities` has multiple rows per `sell_date` (one row per product sold that day). `GROUP_CONCAT` is the only aggregate function that turns multiple row values within a group into a single delimited string — exactly what `products` needs.

```
sell_date     product
----------    ----------
2020-05-30    Headphone
2020-05-30    Basketball
2020-05-30    T-Shirt

        ↓  GROUP BY sell_date + GROUP_CONCAT

2020-05-30 → "Basketball,Headphone,T-Shirt"
```

## ⚠️ Why not just DISTINCT product without GROUP_CONCAT's own DISTINCT?
`COUNT(DISTINCT product)` and `GROUP_CONCAT(DISTINCT product ...)` are two independent function calls — `DISTINCT` isn't inherited between them. Omitting it from `GROUP_CONCAT` while keeping it in `COUNT` would produce a mismatch: `num_sold` counts unique products correctly, but `products` would list duplicates (e.g. `Mask,Mask`) for repeated sales on the same date.

## 🐛 Common Mistakes

**Mistake: forgetting `DISTINCT` inside `GROUP_CONCAT`**
```sql
-- ❌ Wrong: shows duplicate product names
GROUP_CONCAT(product ORDER BY product SEPARATOR ',')
```
```sql
-- ✅ Correct
GROUP_CONCAT(DISTINCT product ORDER BY product SEPARATOR ',')
```

**Mistake: relying on default row order instead of `ORDER BY` inside GROUP_CONCAT**
```sql
-- ❌ Wrong: order not guaranteed to be lexicographic
GROUP_CONCAT(DISTINCT product SEPARATOR ',')
```
```sql
-- ✅ Correct: explicitly sorts values before concatenating
GROUP_CONCAT(DISTINCT product ORDER BY product SEPARATOR ',')
```

## ⏱️ Time Complexity
O(n log n) — dominated by sorting within `GROUP_CONCAT` and the grouping/sorting on `sell_date`.

## 🔑 Key Learnings
- `GROUP_CONCAT` is an aggregate function (like `COUNT`/`SUM`), not a regex feature, despite living in the "Regex/Advanced String Functions" section
- `DISTINCT` inside different aggregate functions in the same query is independent — each function dedupes its own input only
- `ORDER BY` inside `GROUP_CONCAT` controls concatenation order and is separate from the query's outer `ORDER BY`
- Comma is `GROUP_CONCAT`'s default separator, but specifying `SEPARATOR ','` explicitly is good practice for clarity

## 🏁 Final Query
```sql
SELECT
    sell_date,
    COUNT(DISTINCT product) AS num_sold,
    GROUP_CONCAT(DISTINCT product ORDER BY product SEPARATOR ',') AS products
FROM Activities
GROUP BY sell_date
ORDER BY sell_date;
```
