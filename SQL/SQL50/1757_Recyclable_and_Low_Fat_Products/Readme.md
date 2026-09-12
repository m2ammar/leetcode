# 1757. Recyclable and Low Fat Products

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** `SELECT` · `WHERE` · `AND` operator · Filtering rows

---

## 📋 Problem Summary

Find the IDs of products that satisfy **both** conditions:

- ✅ The product is low fat
- ✅ The product is recyclable

> Return only the `product_id`.

---

## ✅ Solution

```sql
SELECT product_id
FROM Products
WHERE low_fats = 'Y'
  AND recyclable = 'Y';
```

---

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `SELECT product_id` | Returns only the required column |
| `FROM Products` | Reads data from the `Products` table |
| `WHERE` | Filters rows based on given conditions |
| `low_fats = 'Y'` | Keeps only products marked as low fat |
| `AND recyclable = 'Y'` | Requires the row to *also* be recyclable |

---

## 🤔 Why `AND`?

There are two conditions in the problem statement, and a product must satisfy **both** of them.

| Low Fat | Recyclable | Returned? |
|:---:|:---:|:---:|
| Y | Y | ✅ |
| Y | N | ❌ |
| N | Y | ❌ |
| N | N | ❌ |

Since both conditions are required — not just one — `AND` is the correct operator. (`OR` would return a row if *either* condition were true, which is too loose here.)

---

## ⏱️ Time Complexity

**O(n)** — the database scans each row once, checking both conditions during the same pass.

---

## 🔑 Key Learnings

- Use `WHERE` to filter rows.
- Use `AND` when multiple conditions must **all** be true.
- SQL compares string values using single quotes (`'Y'`).
- Return only the columns requested by the problem.

---

## 🧠 Final Query

```sql
SELECT product_id
FROM Products
WHERE low_fats = 'Y'
  AND recyclable = 'Y';
```
