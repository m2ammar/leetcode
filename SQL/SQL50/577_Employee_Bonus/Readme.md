# 577. Employee Bonus

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** `LEFT JOIN` · `IS NULL` · `OR` operator

---

## 📋 Problem Summary

Table `Employee` holds all employees. Table `Bonus` holds bonuses for *some* employees (not all).

Report the `name` and `bonus` of every employee who either:
- ✅ Has a bonus less than `1000`
- ✅ Has no bonus at all

---

## ✅ Solution

```sql
SELECT e.name, b.bonus
FROM Employee AS e
LEFT JOIN Bonus AS b
  ON e.empId = b.empId
WHERE b.bonus < 1000
   OR b.bonus IS NULL;
```

---

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `LEFT JOIN Bonus AS b ON e.empId = b.empId` | Keeps every employee, even those with no row in `Bonus` |
| `WHERE b.bonus < 1000` | Catches employees who *do* have a bonus, but a small one |
| `OR b.bonus IS NULL` | Catches employees who never got a bonus row at all |

---

## ⚠️ Why LEFT JOIN + IS NULL

An `INNER JOIN` would silently drop every employee with no `Bonus` row — exactly the group the problem asks for. `LEFT JOIN` preserves them with `b.bonus` as `NULL`, and the `WHERE` clause explicitly checks both cases: a real value under 1000, or no value at all.

---

## ❌ Common Mistakes

- `WHERE b.bonus = NULL` instead of `IS NULL` — always evaluates to UNKNOWN, matches nothing.
- Using `INNER JOIN` — drops employees with no bonus before `WHERE` can even see them.
- Forgetting the `OR b.bonus IS NULL` branch entirely — only returns employees with a real (low) bonus, missing the "no bonus" group.

---

## ⏱️ Time Complexity

**O(n)** — the join is matched via `empId`, typically optimized with indexes.

---

## 🔑 Key Learnings

- Same pattern as **1581**: `LEFT JOIN` + `IS NULL` to surface "missing" rows from a related table.
- Whenever a condition needs to cover both "a value below a threshold" *and* "no value at all," combine them with `OR ... IS NULL` — a single `<` comparison will never catch the `NULL` case on its own.

---

## 🧠 Final Query

```sql
SELECT e.name, b.bonus
FROM Employee AS e
LEFT JOIN Bonus AS b
  ON e.empId = b.empId
WHERE b.bonus < 1000
   OR b.bonus IS NULL;
```
