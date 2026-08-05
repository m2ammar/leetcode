# 1193. Monthly Transactions I

![Difficulty](https://img.shields.io/badge/Difficulty-Medium-orange)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** `GROUP BY` · `DATE_FORMAT()` · `CASE WHEN` · `SUM()` · `COUNT()` · `Conditional Aggregation`

---

## 📋 Problem Summary

For each **month** and **country**, find:

- ✅ Total number of transactions
- ✅ Number of approved transactions
- ✅ Total transaction amount
- ✅ Total amount of approved transactions

Return one row per **month-country** combination.

---

## ✅ Solution

```sql
SELECT
    DATE_FORMAT(trans_date, '%Y-%m') AS month,
    country,
    COUNT(*) AS trans_count,
    SUM(CASE WHEN state = 'approved' THEN 1 ELSE 0 END) AS approved_count,
    SUM(amount) AS trans_total_amount,
    SUM(CASE WHEN state = 'approved' THEN amount ELSE 0 END) AS approved_total_amount
FROM Transactions
GROUP BY
    DATE_FORMAT(trans_date, '%Y-%m'),
    country;
```

---

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `DATE_FORMAT(trans_date, '%Y-%m')` | Extracts the year and month from each transaction date |
| `COUNT(*)` | Counts all transactions in each group |
| `SUM(CASE WHEN state = 'approved' THEN 1 ELSE 0 END)` | Counts only approved transactions |
| `SUM(amount)` | Calculates the total transaction amount |
| `SUM(CASE WHEN state = 'approved' THEN amount ELSE 0 END)` | Calculates the total amount of approved transactions |
| `GROUP BY month, country` | Creates one result for each month-country pair |

---

## 💡 Conditional Aggregation

This problem introduces one of the most common SQL interview techniques: **conditional aggregation**.

Instead of filtering rows with `WHERE`, we calculate multiple metrics from the same group.

### Count approved transactions

```sql
SUM(CASE
        WHEN state = 'approved' THEN 1
        ELSE 0
    END)
```

Each approved row contributes **1**, while every other row contributes **0**.

Example:

| State | Value Added |
|-------|------------:|
| approved | 1 |
| declined | 0 |
| approved | 1 |

Total:

```
1 + 0 + 1 = 2
```

---

### Sum approved transaction amounts

```sql
SUM(CASE
        WHEN state = 'approved' THEN amount
        ELSE 0
    END)
```

Example:

| State | Amount | Value Added |
|-------|-------:|------------:|
| approved | 1000 | 1000 |
| declined | 2000 | 0 |
| approved | 500 | 500 |

Total:

```
1000 + 0 + 500 = 1500
```

---

## ⚠️ Why Not Use WHERE?

Using

```sql
WHERE state = 'approved'
```

would remove all declined transactions.

Then you would no longer be able to calculate:

- Total transactions
- Total transaction amount

Because those rows would already be filtered out.

Conditional aggregation allows all statistics to be computed in a **single query**.

---

## ❌ Common Mistakes

### Using `COUNT(CASE ... ELSE 0 END)`

```sql
COUNT(CASE
          WHEN state = 'approved' THEN 1
          ELSE 0
      END)
```

This counts **every row**.

Why?

`COUNT()` counts all **non-NULL** values.

Both `1` and `0` are non-NULL.

Use:

```sql
SUM(CASE
        WHEN state = 'approved' THEN 1
        ELSE 0
    END)
```

or

```sql
COUNT(CASE
          WHEN state = 'approved' THEN 1
     END)
```

---

### Grouping by `state`

```sql
GROUP BY state, country;
```

This creates separate groups for approved and declined transactions, which does **not** match the problem requirements.

The grouping should be based on:

- Month
- Country

---

### Using `COUNT(column)` instead of `COUNT(*)`

Although both work here because `state` is never `NULL`, `COUNT(*)` clearly expresses the intention of counting every transaction.

---

## ⏱️ Time Complexity

**O(n)** — every transaction is processed once.

---

## 🔑 Key Learnings

- Use `DATE_FORMAT()` to group dates by month.
- `COUNT(*)` counts every row.
- `CASE WHEN` can create conditional values.
- `SUM(CASE WHEN ...)` is the standard pattern for **conditional aggregation**.
- Conditional aggregation lets you calculate multiple metrics in a single grouped query.
- Always group by the columns that define the required result.

---

## 🧠 Final Query

```sql
SELECT
    DATE_FORMAT(trans_date, '%Y-%m') AS month,
    country,
    COUNT(*) AS trans_count,
    SUM(CASE WHEN state = 'approved' THEN 1 ELSE 0 END) AS approved_count,
    SUM(amount) AS trans_total_amount,
    SUM(CASE WHEN state = 'approved' THEN amount ELSE 0 END) AS approved_total_amount
FROM Transactions
GROUP BY
    DATE_FORMAT(trans_date, '%Y-%m'),
    country;
```
