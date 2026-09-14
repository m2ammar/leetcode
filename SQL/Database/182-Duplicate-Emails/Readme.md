# 182. Duplicate Emails

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** GROUP BY · HAVING · COUNT · Aggregation

---

## ✅ Problem Summary

- Given the `Person` table (`id`, `email`), find every email that appears **more than once**.
- Return only the `Email` column — one row per duplicated email, order doesn't matter.
- `id` is the primary key, so duplicates can only occur in `email`.

---

## 🧠 Solution

```sql
SELECT email AS Email
FROM Person
GROUP BY email
HAVING COUNT(email) > 1;
```

---

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `SELECT email AS Email` | Picks the email column, aliased to match the required output header |
| `FROM Person` | Source table |
| `GROUP BY email` | Collapses all rows into one group per distinct email value |
| `HAVING COUNT(email) > 1` | Keeps only the groups (emails) that had more than one row |

---

## 🤔 Why GROUP BY + HAVING?

`GROUP BY` buckets rows that share the same `email` together, and `COUNT(email)` tells you how many rows landed in each bucket. `HAVING` then filters on that aggregate — something `WHERE` can't do, since `WHERE` runs before grouping happens.

```
id | email          groups by email:
1  | a@b.com   ->   a@b.com  -> [1, 3]  count = 2  ✅ kept
2  | c@d.com   ->   c@d.com  -> [2]     count = 1  ❌ dropped
3  | a@b.com
```

Result:

| Email   |
|---------|
| a@b.com |

---

## ⚠️ Why not a self-join?

An alternative is joining `Person` to itself on `email` while excluding a row matching itself:

```sql
SELECT DISTINCT p1.email AS Email
FROM Person p1
JOIN Person p2
  ON p1.email = p2.email
 AND p1.id <> p2.id;
```

This works, but:
- It needs `DISTINCT` to avoid printing the same email twice (once for each direction of the match).
- It compares every row against every other row with a matching email — for a column with many duplicates, that's more comparisons than a single grouping pass.

`GROUP BY`/`HAVING` is the more natural fit here because the question is really "how many times does each value occur," which is exactly what aggregation is for. The self-join is worth knowing because it generalizes to cases where you need the *other* duplicate row's data (not just the email itself), which `GROUP BY` alone can't give you.

---

## 🐞 Common Mistakes

**Filtering with WHERE instead of HAVING:**
```sql
-- ❌ Wrong: WHERE can't reference an aggregate like COUNT()
SELECT email
FROM Person
WHERE COUNT(email) > 1
GROUP BY email;
```
```sql
-- ✅ Fix: aggregate filters belong in HAVING, which runs after grouping
SELECT email AS Email
FROM Person
GROUP BY email
HAVING COUNT(email) > 1;
```

**Forgetting the column alias:**
```sql
-- ❌ Wrong: output header will be "email", not "Email"
SELECT email
FROM Person
GROUP BY email
HAVING COUNT(email) > 1;
```

---

## ⏱️ Time Complexity

O(n) — a single pass to build the groups (implemented via a hash or sort on `email`), followed by a constant-time check per group.

---

## 🔑 Key Learnings

- `HAVING` filters on aggregated results; `WHERE` filters on raw rows before aggregation.
- `COUNT(column)` counts non-null occurrences per group once `GROUP BY` has bucketed the rows.
- The same "find duplicates" logic can be expressed via a self-join, but grouping is the more direct tool when you only need the duplicated value itself.

---

## Final Query

```sql
SELECT email AS Email
FROM Person
GROUP BY email
HAVING COUNT(email) > 1;
```
