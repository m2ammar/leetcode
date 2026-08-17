# 610. Triangle Judgement

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** `CASE WHEN` · Conditional Expressions · Comparison Operators

---

## ✅ Problem Summary

- Table `Triangle` has three columns `x`, `y`, `z` — the lengths of three line segments, with `(x, y, z)` as the primary key.
- For every row, report whether the three lengths **can** form a triangle.
- Return `x`, `y`, `z`, and a new column `triangle` with value `'Yes'` or `'No'`.

---

## 🧠 Solution

```sql
SELECT x, y, z,
    (CASE WHEN x + y > z AND x + z > y AND z + y > x THEN 'Yes' ELSE 'No' END) AS triangle
FROM Triangle;
```

---

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `SELECT x, y, z` | Passes the three original side lengths through unchanged. |
| `CASE WHEN x + y > z AND x + z > y AND z + y > x THEN 'Yes' ELSE 'No' END` | Evaluates all three triangle-inequality conditions per row and maps the result to a `'Yes'`/`'No'` string. |
| `AS triangle` | Aliases the computed expression as the required output column. |
| `FROM Triangle` | Reads every row of the source table — no filtering needed since every row must be judged. |

---

## 🤔 Why `CASE WHEN`?

`CASE WHEN` is the standard way to turn a boolean condition into a labeled value in SQL — there's no native boolean-to-string cast, so a per-row conditional expression is the natural tool here. Each row is independent (no joins, no aggregation needed):

```
Triangle
+----+----+----+
| x  | y  | z  |
+----+----+----+
| 13 | 15 | 30 | -> 13+15=28, not > 30 -> No
| 10 | 20 | 15 | -> 10+20=30,     > 15 -> Yes
+----+----+----+
```

Sample result:

```
+----+----+----+----------+
| x  | y  | z  | triangle |
+----+----+----+----------+
| 13 | 15 | 30 | No       |
| 10 | 20 | 15 | Yes      |
+----+----+----+----------+
```

---

## 🚫 Why not `IF()`?

MySQL's `IF(condition, 'Yes', 'No')` would produce the identical result and is arguably shorter. `CASE WHEN` was preferred here because it's ANSI-standard SQL (portable to Postgres, SQL Server, etc.), while `IF()` is a MySQL-specific function. Since the goal is building transferable SQL habits rather than MySQL-only syntax, `CASE WHEN` is the better default.

---

## ⚠️ Common Mistakes

**Checking only one triangle-inequality condition:**

```sql
-- First attempt — got Accepted on LeetCode, but is not actually correct:
CASE WHEN x + y > z THEN 'Yes' ELSE 'No' END
```

The actual mathematical rule for three lengths to form a triangle is that **all three** inequalities must hold:

```
x + y > z   AND   x + z > y   AND   y + z > x
```

The single-condition version above passed LeetCode's judge only because the platform's test cases don't happen to include a row where `x + y > z` is true but one of the other two inequalities fails (e.g. `x=100, y=1, z=50`: `x+y=101>50` ✅ but `x` alone exceeds `y+z=51`, so no triangle). It is not a general-purpose correct solution.

The fix — checking all three inequalities — is the version now used as the final solution above.

---

## ⏱️ Time Complexity

`O(n)` — a single pass over the table, one constant-time comparison per row. No sorting, joins, or grouping involved.

---

## 🔑 Key Learnings

- `CASE WHEN ... THEN ... ELSE ... END` is the standard-SQL way to convert a row-level condition into a labeled output column.
- LeetCode's judge only checks the provided test cases — passing doesn't guarantee the query is mathematically complete. Double-check the underlying logic (here: the full triangle inequality) with an adversarial test case of your own, independent of whether the judge accepts a partial version.
- `IF()` is a handy MySQL shortcut, but `CASE WHEN` is the portable choice across SQL dialects.

---

## 🏁 Final Query

```sql
SELECT x, y, z,
    (CASE WHEN x + y > z AND x + z > y AND z + y > x THEN 'Yes' ELSE 'No' END) AS triangle
FROM Triangle;
```
