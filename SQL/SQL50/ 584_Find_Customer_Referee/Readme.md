# 584. Find Customer Referee

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** `SELECT` · `WHERE` · `NULL` · `IS NULL` · `OR` operator

---

## 📋 Problem Summary

Find the names of customers who are:

- ✅ Not referred by customer **2**
- ✅ Never referred by anyone (`NULL`)

Return only the `name`.

---

## ✅ Solution

```sql
SELECT name
FROM Customer
WHERE referee_id != 2
   OR referee_id IS NULL;
```

---

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `SELECT name` | Returns only the customer's name |
| `FROM Customer` | Reads data from the Customer table |
| `WHERE referee_id != 2` | Keeps customers not referred by customer 2 |
| `OR referee_id IS NULL` | Includes customers who were never referred |

---

## ⚠️ Understanding NULL

A common mistake is writing:

```sql
WHERE referee_id != 2;
```

This **does not include NULL values**.

In SQL:

- `NULL` means **unknown**
- Comparisons like `=`, `!=`, `<`, `>` against `NULL` return **UNKNOWN**
- `WHERE` only keeps rows that evaluate to **TRUE**

Therefore, customers with `NULL` referee IDs are excluded unless you explicitly write:

```sql
IS NULL
```

---

## ❌ Common Mistakes

### Using `==`

```sql
WHERE referee_id == 2;
```

SQL uses **`=`**, not `==`.

---

### Comparing with NULL

```sql
WHERE referee_id = NULL;
```

or

```sql
WHERE referee_id != NULL;
```

Both are incorrect.

Always use:

```sql
IS NULL
```

or

```sql
IS NOT NULL
```

---

## ⏱️ Time Complexity

**O(n)** — each customer row is checked once.

---

## 🔑 Key Learnings

- `NULL` is **not** equal to anything—not even another `NULL`.
- Use `IS NULL` / `IS NOT NULL` to test for NULL values.
- Combine multiple conditions with `OR` when either condition is acceptable.
- Always think about NULL whenever filtering nullable columns.

---

## 🧠 Final Query

```sql
SELECT name
FROM Customer
WHERE referee_id != 2
   OR referee_id IS NULL;
```
