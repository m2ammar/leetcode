# 1148. Article Views I

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** `SELECT DISTINCT` · `WHERE` · `ORDER BY` · Aliasing

---

## 📋 Problem Summary

Find all authors who have viewed **at least one of their own articles**.

A row qualifies if:

- ✅ `author_id = viewer_id`

Return the result:

- As a column named **id**
- Sorted in **ascending order**

---

## ✅ Solution

```sql
SELECT DISTINCT author_id AS id
FROM Views
WHERE author_id = viewer_id
ORDER BY id;
```

---

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `SELECT DISTINCT author_id AS id` | Returns unique author IDs and renames the column to `id` |
| `FROM Views` | Reads data from the `Views` table |
| `WHERE author_id = viewer_id` | Keeps only rows where the author viewed their own article |
| `ORDER BY id` | Sorts the result in ascending order |

---

## 🤔 Why `DISTINCT`?

The table may contain duplicate rows.

Example:

| author_id | viewer_id |
|:---:|:---:|
| 4 | 4 |
| 4 | 4 |

Without `DISTINCT`, the output would be:

```
4
4
```

Using `DISTINCT` removes duplicates:

```
4
```

---

## 🤔 Why Alias (`AS id`)?

The problem requires the output column to be named:

```
id
```

Using:

```sql
author_id AS id
```

renames the column without changing the data.

---

## ⚠️ Common Mistakes

### Forgetting `DISTINCT`

```sql
SELECT author_id
FROM Views
WHERE author_id = viewer_id;
```

Duplicate authors may appear multiple times.

---

### Forgetting to rename the column

```sql
SELECT DISTINCT author_id
```

The output column would be `author_id` instead of the required `id`.

---

### Forgetting `ORDER BY`

The problem explicitly asks for ascending order.

---

## ⏱️ Time Complexity

**O(n log n)**

- Scans the table once.
- Sorting the final result takes additional time.

---

## 🔑 Key Learnings

- Use `DISTINCT` to remove duplicate rows.
- Use `AS` to rename output columns.
- Use `ORDER BY` when a specific order is required.
- Compare columns directly using `=` inside the `WHERE` clause.

---

## 🧠 Final Query

```sql
SELECT DISTINCT author_id AS id
FROM Views
WHERE author_id = viewer_id
ORDER BY id;
```
