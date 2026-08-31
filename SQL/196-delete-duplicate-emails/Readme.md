# 196. Delete Duplicate Emails

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** CTE · Window Functions (ROW_NUMBER) · DELETE · Subquery

---

## ✅ Problem Summary
- Delete all duplicate emails from the `Person` table
- Keep only one row per unique email — the one with the **smallest `id`**
- Must be written as a `DELETE` statement, not a `SELECT`

## 🧠 Solution
```sql
WITH cte AS (
    SELECT id, email,
    ROW_NUMBER() OVER (PARTITION BY email ORDER BY id) AS cnt
    FROM Person
)

DELETE FROM Person
WHERE id IN (SELECT id FROM cte WHERE cnt > 1);
```

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `ROW_NUMBER() OVER (PARTITION BY email ORDER BY id)` | Ranks rows within each email group, smallest `id` gets rank 1 |
| `WITH cte AS (...)` | Stores the ranked result as a temporary named result set |
| `DELETE FROM Person` | Targets the actual base table (CTEs are read-only, can't be deleted from directly) |
| `WHERE id IN (SELECT id FROM cte WHERE cnt > 1)` | Deletes any row whose id was ranked 2nd or later within its email group |

## 🤔 Why Window Function?
`Person` has one column group we care about — `email` — and we want to distinguish "first occurrence" from "duplicate occurrence" within each email group.

email              | id | cnt
-------------------|----|----
john\@example.com  | 1  | 1   ← keep
john\@example.com  | 3  | 2   ← delete
bob\@example.com   | 2  | 1   ← keep


`ROW_NUMBER()` partitioned by `email` and ordered by `id` gives exactly that: rank 1 = the row to keep, rank > 1 = duplicates to delete.

## ⚠️ Why not Self-Join?
The classic alternative is a self-join:
```sql
DELETE p1 FROM Person p1, Person p2
WHERE p1.email = p2.email AND p1.id > p2.id;
```
This works too, but requires comparing every row against every other row with the same email (an `id >` condition to keep the smaller one). The window function approach is more explicit about *why* a row is a duplicate (its rank), and reads more directly as "keep rank 1 per group" — easier to reason about if joins aren't yet second nature.

## 🚨 Common Mistakes
**Trying to delete directly from the CTE:**
```sql
DELETE FROM cte WHERE cnt > 1;  -- ❌ Fails: CTE is not a real table
```
**Fix:** Delete from the actual table (`Person`), using the CTE only inside a subquery to identify which `id`s to remove.

## ⏱️ Time Complexity
O(n log n) — dominated by the partition + sort inside the window function.

## 🔑 Key Learnings
- CTEs are read-only result sets — you can `SELECT` from them, but not `DELETE`/`UPDATE` them directly
- `ROW_NUMBER() OVER (PARTITION BY ... ORDER BY ...)` is a clean way to identify "duplicates within a group"
- Window functions can't be filtered directly in `WHERE` — wrap them in a CTE/subquery first, then filter on the alias

## 🏁 Final Query
```sql
WITH cte AS (
    SELECT id, email,
    ROW_NUMBER() OVER (PARTITION BY email ORDER BY id) AS cnt
    FROM Person
)

DELETE FROM Person
WHERE id IN (SELECT id FROM cte WHERE cnt > 1);
```
