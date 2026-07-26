# 1068. Product Sales Analysis I

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** `INNER JOIN` · `JOIN` · `ON` · Table Aliases

---

## 📋 Problem Summary

For every sale, report:

- ✅ Product name
- ✅ Year of sale
- ✅ Price

The product name is stored in a different table, so the two tables must be joined using `product_id`.

---

## ✅ Solution

```sql
SELECT p.product_name,
       s.year,
       s.price
FROM Sales AS s
JOIN Product AS p
ON s.product_id = p.product_id;
```

---

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `SELECT p.product_name, s.year, s.price` | Returns the required columns |
| `FROM Sales AS s` | Starts with the Sales table |
| `JOIN Product AS p` | Joins the Product table |
| `ON s.product_id = p.product_id` | Matches each sale with its corresponding product |

---

## 🤔 Why `INNER JOIN`?

The `Sales` table contains:

- `product_id`
- `year`
- `price`

The `Product` table contains:

- `product_id`
- `product_name`

The common column is:

```text
product_id
```

An **INNER JOIN** combines rows where the `product_id` exists in both tables.

### Visualization

```
Sales                         Product
------                        --------
product_id  ─────────────►    product_id
year                          product_name
price
```

Result:

| product_name | year | price |
|--------------|------|------:|
| Nokia | 2008 | 5000 |
| Nokia | 2009 | 5000 |
| Apple | 2011 | 9000 |

---

## 🔄 Why not `LEFT JOIN`?

A `LEFT JOIN` would also work because every `product_id` in the `Sales` table has a matching product.

However, the problem only requires matching records.

`JOIN` (which means `INNER JOIN`) is simpler and communicates the intent more clearly.

---

## 📚 JOIN Types at a Glance

| JOIN Type | Returns |
|---|---|
| `INNER JOIN` | Only matching rows from both tables |
| `LEFT JOIN` | All rows from the left table + matching rows from the right |
| `RIGHT JOIN` | All rows from the right table + matching rows from the left |
| `FULL JOIN` | All rows from both tables (not supported in MySQL) |

---

## ⚠️ Common Mistakes

### Joining on the wrong column

❌ Incorrect

```sql
ON s.sale_id = p.product_id;
```

Always join using the common key:

```sql
ON s.product_id = p.product_id;
```

---

### Forgetting the `ON` clause

```sql
SELECT *
FROM Sales
JOIN Product;
```

Without an `ON` condition, the query creates a Cartesian product (every row matched with every other row).

---

### Confusing `JOIN` with `LEFT JOIN`

Remember:

- `JOIN` = `INNER JOIN`
- Returns only matching rows.

---

## ⏱️ Time Complexity

**O(n)** — the database joins rows using the indexed `product_id`, making the operation efficient.

---

## 🔑 Key Learnings

- `JOIN` is the same as `INNER JOIN`.
- Use `ON` to specify the relationship between tables.
- Join tables using their common key.
- Table aliases (`s` and `p`) improve readability and reduce typing.

---

## 🧠 Final Query

```sql
SELECT p.product_name,
       s.year,
       s.price
FROM Sales AS s
JOIN Product AS p
ON s.product_id = p.product_id;
```
