# 626. Exchange Seats

![Difficulty](https://img.shields.io/badge/Difficulty-Medium-orange)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-brightgreen)

**Concepts:** CASE Expression · MOD() · Scalar Subquery · ORDER BY

---

## ✅ Problem Summary

- [x] Swap the seat `id` of every two consecutive students
- [x] If the number of students is odd, the last student's `id` stays unchanged
- [x] Return the result ordered by `id` ascending
- [x] `id` starts at 1 and increments with no gaps

---

## 🧠 Solution

```sql
SELECT
    CASE
        WHEN MOD(id, 2) = 0 THEN id - 1
        WHEN MOD(id, 2) = 1 AND id != (SELECT COUNT(*) FROM Seat) THEN id + 1
        ELSE id
    END AS id,
    student
FROM Seat
ORDER BY id;
```

---

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `CASE WHEN MOD(id, 2) = 0 THEN id - 1` | If the row's id is even, its new id shifts down by 1 (pairs with the row above) |
| `WHEN MOD(id, 2) = 1 AND id != (SELECT COUNT(*) FROM Seat)` | If the id is odd **and** it isn't the last row, shift its id up by 1 (pairs with the row below) |
| `ELSE id` | Catches the one remaining case — an odd id that *is* the last row — and leaves it unchanged |
| `(SELECT COUNT(*) FROM Seat)` | Scalar subquery returning the total number of students, used to detect "is this the last seat?" |
| `ORDER BY id` | Sorts the final output ascending, as required |

---

## 🤔 Why CASE + a scalar subquery?

The table only has two columns, so there's no second table or JOIN involved here — the "pairing" happens entirely through arithmetic on `id` itself, since ids are sequential integers with no gaps.

```
id: 1   2   3   4   5
    └─┬─┘   └─┬─┘   └── odd + last → stays as 5
    swap    swap
    1↔2     3↔4
```

Because `id` starts at 1 and increases by 1 with no missing numbers, the row with `id = total_count` is guaranteed to be the last row — that's what makes the scalar subquery a clean way to detect "no partner exists."

**Sample result (5 students):**

| id | student |
|----|---------|
| 1  | Doris   |
| 2  | Abbot   |
| 3  | Green   |
| 4  | Emerson |
| 5  | Jeames  |

---

## 🔍 Why not LEAD/LAG?

`LEAD()`/`LAG()` window functions are a valid alternative — they'd let you look at the "next" or "previous" row's `student` value directly and swap names instead of ids. That approach avoids the odd/even arithmetic entirely, but trades it for reasoning about partition/window boundaries and NULLs at the edges.

The CASE + MOD approach was preferred here because the ids are already sequential integers — arithmetic (`id - 1` / `id + 1`) is a more direct fit than pulling in window functions for what's fundamentally a numbering problem.

---

## ⚠️ Common Mistakes

**Mistake 1 — Using `WHERE` inside a `CASE...THEN`**
```sql
-- ❌ Wrong: WHERE is a query clause, not an expression value
THEN student = student WHERE id = id - 1
```
```sql
-- ✅ Fix: THEN must return a plain value
THEN id - 1
```

**Mistake 2 — Writing an assignment instead of a value**
```sql
-- ❌ Wrong: no assignment happens inside a SELECT's CASE
THEN id = id - 1
```
```sql
-- ✅ Fix: just the arithmetic expression
THEN id - 1
```

**Mistake 3 — Splitting one CASE into two, or placing WHEN outside CASE...END**
```sql
-- ❌ Wrong: WHEN floating outside any CASE block
FROM Seat
WHEN id = (SELECT COUNT(*) FROM Seat)
```
```sql
-- ✅ Fix: all WHEN branches live inside a single CASE...END
CASE
    WHEN MOD(id, 2) = 0 THEN id - 1
    WHEN MOD(id, 2) = 1 AND id != (SELECT COUNT(*) FROM Seat) THEN id + 1
    ELSE id
END AS id
```

---

## ⏱️ Time Complexity

O(n) — a single pass over the table, plus one `COUNT(*)` scalar subquery (O(n) once, reused per row via the query planner/cache rather than recomputed per row in practice).

---

## 🔑 Key Learnings

- `CASE...THEN` in a `SELECT` returns a value for that expression — never an assignment (`=`) or a clause like `WHERE`
- A single `CASE...END` block holds all `WHEN` branches; `WHEN` cannot exist outside of one
- A scalar subquery like `(SELECT COUNT(*) FROM Seat)` can be dropped inline anywhere a single number is expected, including inside a `WHEN` condition
- Sequential, gap-free `id` columns let you detect "last row" via `id = total_count` instead of window functions

---

## 🎯 Final Query

```sql
SELECT
    CASE
        WHEN MOD(id, 2) = 0 THEN id - 1
        WHEN MOD(id, 2) = 1 AND id != (SELECT COUNT(*) FROM Seat) THEN id + 1
        ELSE id
    END AS id,
    student
FROM Seat
ORDER BY id;
```
