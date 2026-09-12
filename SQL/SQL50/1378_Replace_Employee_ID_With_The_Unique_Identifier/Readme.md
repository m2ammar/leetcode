# 1378. Replace Employee ID With The Unique Identifier

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** `LEFT JOIN` · `JOIN` · `ON` · Table Aliases

---

## 📋 Problem Summary

Show the **unique ID** of every employee.

If an employee does **not** have a unique ID, return **NULL** instead.

Return:

- `unique_id`
- `name`

---

## ✅ Solution

```sql
SELECT eu.unique_id,
       e.name
FROM Employees AS e
LEFT JOIN EmployeeUNI AS eu
ON e.id = eu.id;
```

---

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `SELECT eu.unique_id, e.name` | Returns the required columns |
| `FROM Employees AS e` | Starts with the Employees table |
| `LEFT JOIN EmployeeUNI AS eu` | Joins the EmployeeUNI table while keeping all employees |
| `ON e.id = eu.id` | Matches rows using the common `id` column |

---

## 🤔 Why `LEFT JOIN`?

The problem asks us to display **every employee**, even if they don't have a matching unique ID.

A `LEFT JOIN` returns:

- ✅ All rows from the left table (`Employees`)
- ✅ Matching rows from the right table (`EmployeeUNI`)
- ✅ `NULL` when no match exists

Example:

### Employees

| id | name |
|:--:|------|
| 1 | Alice |
| 2 | Bob |
| 3 | Charlie |

### EmployeeUNI

| id | unique_id |
|:--:|:---------:|
| 2 | 101 |
| 3 | 102 |

### Result

| unique_id | name |
|:---------:|------|
| NULL | Alice |
| 101 | Bob |
| 102 | Charlie |

---

## 🔄 Why not `INNER JOIN`?

Using an `INNER JOIN`:

```sql
SELECT eu.unique_id,
       e.name
FROM Employees AS e
JOIN EmployeeUNI AS eu
ON e.id = eu.id;
```

would remove employees without a matching unique ID.

Alice would disappear from the result, which does **not** satisfy the problem requirements.

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

### Using `INNER JOIN`

```sql
JOIN EmployeeUNI
```

This excludes employees without a unique ID.

---

### Joining on the wrong column

```sql
ON e.name = eu.id
```

Always join using the common key:

```sql
ON e.id = eu.id
```

---

### Forgetting table aliases

Using aliases like `e` and `eu` makes the query shorter and easier to read.

---

## ⏱️ Time Complexity

**O(n)** — the database matches employees using the join key, typically optimized with indexes.

---

## 🔑 Key Learnings

- Use `LEFT JOIN` when every row from the left table must appear.
- `JOIN` by itself means `INNER JOIN`.
- The `ON` clause defines how two tables are related.
- Unmatched rows in a `LEFT JOIN` automatically return `NULL` for columns from the right table.

---

## 🧠 Final Query

```sql
SELECT eu.unique_id,
       e.name
FROM Employees AS e
LEFT JOIN EmployeeUNI AS eu
ON e.id = eu.id;
```
