# 627. Swap Sex of Employees

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** `UPDATE` · `CASE WHEN` · Conditional Logic

---

## ✅ Problem Summary

- Table `Salary` stores employee `id`, `name`, `sex` (ENUM `'m'`/`'f'`), and `salary`.
- Swap every `'m'` to `'f'` and every `'f'` to `'m'` in the `sex` column.
- Must be done with a **single `UPDATE` statement** — no `SELECT`, no temp tables.

---

## 🧠 Solution

```sql
UPDATE Salary
SET sex = CASE
            WHEN sex = 'm' THEN 'f'
            WHEN sex = 'f' THEN 'm'
          END;
```

---

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `UPDATE Salary` | Targets the `Salary` table for modification, no `WHERE` needed since every row is affected |
| `SET sex = CASE ... END` | Reassigns `sex` per row, based on its current value |
| `WHEN sex = 'm' THEN 'f'` | If current value is `'m'`, replace it with `'f'` |
| `WHEN sex = 'f' THEN 'm'` | If current value is `'f'`, replace it with `'m'` |

---

## 🤔 Why `CASE WHEN`?

`CASE WHEN` inside `SET` lets one `UPDATE` statement assign a **different value to each row** based on that row's own data — instead of writing two separate `UPDATE ... WHERE sex = 'm'` and `UPDATE ... WHERE sex = 'f'` statements (which the problem explicitly disallows via "single update statement").

Since `sex` is an ENUM with only two possible values (`'m'`, `'f'`), every row is guaranteed to match one of the two `WHEN` branches — so there's no need for an `ELSE`, and no risk of a row falling through to `NULL`.

**Sample result:**

| id | name | sex (before) | sex (after) |
|---|---|---|---|
| 1 | A | m | f |
| 2 | B | f | m |
| 3 | C | m | f |
| 4 | D | f | m |

---

## 🚫 Why not `MOD`/bitwise tricks?

Some solutions use character-code arithmetic instead, e.g.:

```sql
UPDATE Salary
SET sex = CHAR(ASCII('f') + ASCII('m') - ASCII(sex));
```

This works because ASCII('f') + ASCII('m') - ASCII('f') = ASCII('m'), and vice versa — but it's harder to read at a glance, depends on knowing the exact ASCII gap between 'f' and 'm', and breaks silently if the column ever contains a third value. `CASE WHEN` is explicit about intent — swap m→f, f→m — and fails safe (returns `NULL`) instead of producing garbage if an unexpected value shows up, once an `ELSE` is added.

---

## ⚠️ Common Mistakes

**Forgetting `ELSE` with more than two categories**
```sql
-- Fine here because sex only has 2 values, but risky as a habit:
SET sex = CASE
            WHEN sex = 'm' THEN 'f'
            WHEN sex = 'f' THEN 'm'
          END;
```
If this pattern is reused on a column with 3+ possible values, any unmatched row silently becomes `NULL`. Add `ELSE sex` when the column isn't guaranteed to be binary.

**Trying to use a `SELECT` to preview the result first**
The problem requires a single `UPDATE` with no `SELECT` — even for reasoning it through — so the swap logic has to be correct in one shot.

---

## ⏱ Time Complexity

`O(n)` — one full table scan/update pass, no subqueries or joins.

---

## 🔑 Key Learnings

- `CASE WHEN` can live inside a `SET` clause to make row-conditional updates in a single statement.
- ENUM columns with exactly two states don't need an `ELSE` — every row is guaranteed to match a `WHEN`.
- Omitting `ELSE` is a deliberate simplification here, not a default habit — worth calling out in commit/README so future-me knows it was intentional.

---

## Final Query

```sql
UPDATE Salary
SET sex = CASE
            WHEN sex = 'm' THEN 'f'
            WHEN sex = 'f' THEN 'm'
          END;
```
