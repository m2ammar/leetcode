# 1667. Fix Names in a Table

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** SUBSTRING · UPPER · LOWER · CONCAT · ORDER BY

---

## ✅ Problem Summary

- Each row in `Users` has a `user_id` (primary key) and a `name` with inconsistent casing.
- Fix every `name` so that:
  - [x] The first character is uppercase.
  - [x] All remaining characters are lowercase.
- Return the result ordered by `user_id`.

---

## 🧩 Solution

```sql
SELECT
    user_id,
    CONCAT(UPPER(SUBSTRING(name, 1, 1)), LOWER(SUBSTRING(name, 2))) AS name
FROM Users
ORDER BY user_id;
```

---

## 🔍 Breakdown

| Clause | What it does |
|---|---|
| `SUBSTRING(name, 1, 1)` | Grabs exactly 1 character starting at position 1 — the first letter of the name. |
| `UPPER(...)` | Uppercases that first letter. |
| `SUBSTRING(name, 2)` | Grabs everything from position 2 to the end of the string (no length given = "rest of string"). |
| `LOWER(...)` | Lowercases that remaining substring. |
| `CONCAT(...)` | Joins the fixed first letter and the fixed rest back into one string. |
| `ORDER BY user_id` | Satisfies the problem's required output ordering. |

---

## 🤔 Why SUBSTRING + CONCAT?

There's only one table involved here — `Users` — so there's no join to reason about. The technique is really about splitting one column into two logical pieces and reassembling them:

```
name = "aLice"
        │└──┴── SUBSTRING(name, 2)   -> "Lice" -> LOWER -> "lice"
        └──────  SUBSTRING(name, 1,1) -> "a"    -> UPPER -> "A"

CONCAT("A", "lice") -> "Alice"
```

| user_id | name (before) | name (after) |
|---|---|---|
| 1 | aLice | Alice |
| 2 | bOB | Bob |

`SUBSTRING`'s 2-argument form (`SUBSTRING(str, start)`) returns everything from `start` to the end, which is exactly why it works for "the rest of the name" without needing to know its length in advance.

---

## ⚠️ Why not `CONCAT(UPPER(LEFT(name,1)), LOWER(SUBSTRING(name,2)))`?

`LEFT(name, 1)` is a perfectly valid alternative to `SUBSTRING(name, 1, 1)` — both grab the first character. `SUBSTRING` was used here for consistency, since it also handles the "rest of the string" half of the problem; using one function family for both halves keeps the query more readable than mixing `LEFT` and `SUBSTRING`.

---

## 🐛 Common Mistakes

**Mistake 1 — omitting the length argument**
```sql
-- ❌ Wrong: returns the WHOLE string from position 1, not just the first letter
UPPER(SUBSTRING(name, 1))
```
```sql
-- ✅ Fix: give SUBSTRING a length of 1 to isolate just the first character
UPPER(SUBSTRING(name, 1, 1))
```

**Mistake 2 — missing comma between SUBSTRING arguments**
```sql
-- ❌ Wrong: "name 2" is invalid syntax, not "name, 2"
SUBSTRING(name 2)
```
```sql
-- ✅ Fix
SUBSTRING(name, 2)
```

**Mistake 3 — unnecessary GROUP BY**
```sql
-- ❌ Wrong: user_id is already the primary key, so grouping by it does nothing
-- and isn't asked for in the problem
SELECT user_id, CONCAT(...) AS name
FROM Users
GROUP BY user_id;
```
```sql
-- ✅ Fix: no aggregation is happening, so no GROUP BY is needed —
-- just ORDER BY as the problem requires
SELECT user_id, CONCAT(...) AS name
FROM Users
ORDER BY user_id;
```

---

## ⏱️ Time Complexity

O(n) — a single pass over the `Users` table with a per-row string transformation, plus an O(n log n) sort for `ORDER BY`.

---

## 🔑 Key Learnings

- `SUBSTRING(str, start)` (2 args) grabs from `start` to the end of the string.
- `SUBSTRING(str, start, length)` (3 args) grabs exactly `length` characters starting at `start`.
- SQL string positions are 1-indexed, not 0-indexed.
- `GROUP BY` is only needed when aggregating; grouping by a column that's already unique (like a primary key) changes nothing.

---

## 🧠 Final Query

```sql
SELECT
    user_id,
    CONCAT(UPPER(SUBSTRING(name, 1, 1)), LOWER(SUBSTRING(name, 2))) AS name
FROM Users
ORDER BY user_id;
```
