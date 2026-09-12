# 1978. Employees Whose Manager Left the Company

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** `WHERE` · `IS NOT NULL` · `NOT EXISTS` · Correlated Subquery · `ORDER BY`

---

## ✅ Problem Summary

- Find employees whose:
  - `salary` is strictly less than `$30000`
  - `manager_id` is not null (they have a manager on record)
  - that manager's `employee_id` no longer exists in the table (the manager left the company)
- Return `employee_id`, ordered ascending.

---

## 🧠 Solution

```sql
SELECT e1.employee_id
FROM Employees AS e1
WHERE e1.salary < 30000
  AND e1.manager_id IS NOT NULL
  AND NOT EXISTS (
      SELECT 1
      FROM Employees AS e2
      WHERE e2.employee_id = e1.manager_id
  )
ORDER BY e1.employee_id;
```

---

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `e1.salary < 30000` | Filters to employees earning under $30,000 |
| `e1.manager_id IS NOT NULL` | Skips employees with no manager at all — nothing to check for them |
| `NOT EXISTS (...)` | Correlated subquery — checks whether `e1`'s manager still exists as a row in the table |
| `e2.employee_id = e1.manager_id` | The actual correlation — links each outer row's manager_id to the inner table's employee_id |
| `ORDER BY e1.employee_id` | Sorts the final result ascending |

---

## 🤔 Why `NOT EXISTS` (correlated subquery)?

Both `e1` and `e2` are aliases of the **same** table, but they play different roles:

- `e1` → "the employee we're currently checking"
- `e2` → "every row we scan through, looking for e1's manager"

The join column that connects them is: `e1.manager_id = e2.employee_id`

```
e1 (employee)              e2 (potential manager)
+-------------+            +-------------+
| employee_id |            | employee_id |
| manager_id  | ---------> | (matches?)  |
+-------------+            +-------------+
```

For each `e1` row, the subquery scans `e2` looking for a matching `employee_id`. If it finds one, the manager is still employed. If it finds none, that manager was deleted from the table — meaning they left the company.

**Sample result:**

| employee_id |
|---|
| 11 |

---

## ⚠️ Why not a `LEFT JOIN` instead?

A `LEFT JOIN` would also work:

```sql
SELECT e1.employee_id
FROM Employees e1
LEFT JOIN Employees e2 ON e1.manager_id = e2.employee_id
WHERE e1.salary < 30000
  AND e1.manager_id IS NOT NULL
  AND e2.employee_id IS NULL
ORDER BY e1.employee_id;
```

`NOT EXISTS` is preferred here because:
- It reads as a direct existence check ("does this manager exist?") rather than a join-then-filter-nulls pattern.
- It doesn't require pulling in unused columns from `e2` just to check `IS NULL` on one of them.
- On larger tables, `NOT EXISTS` can short-circuit as soon as one match is found, while a `LEFT JOIN` typically builds the full joined result before filtering.

---

## 🐛 Common Mistakes

**Mistake 1: Flipping the correlation**
```sql
-- Wrong — checks if e1 manages someone, not whether e1's manager exists
NOT EXISTS (SELECT 1 FROM Employees e2 WHERE e2.manager_id = e1.employee_id)
```
Fix: compare `e2.employee_id = e1.manager_id` — you're checking if e1's manager_id is a real employee_id, not whether e1 is someone's manager.

**Mistake 2: Forgetting `manager_id IS NOT NULL`**
```sql
-- Wrong — employees with no manager would incorrectly pass NOT EXISTS
WHERE salary < 30000
AND NOT EXISTS (SELECT 1 FROM Employees e2 WHERE e2.employee_id = e1.manager_id)
```
Fix: a `NULL` manager_id will never match any `employee_id`, so `NOT EXISTS` becomes true for employees who never had a manager — explicitly excluding nulls first is required.

---

## ⏱️ Time Complexity

O(n²) in the worst case — the correlated subquery re-scans the table for each outer row (mitigated in practice by the primary key index on `employee_id`).

---

## 🔑 Key Learnings

- `EXISTS` / `NOT EXISTS` only cares about row presence, not the actual selected value — `SELECT 1` is just a placeholder.
- A correlated subquery re-runs once per outer row, referencing a column from the outer query.
- Self-joins (or self-referencing subqueries) need careful attention to which alias plays which role in the comparison.

---

## Final Query

```sql
SELECT e1.employee_id
FROM Employees AS e1
WHERE e1.salary < 30000
  AND e1.manager_id IS NOT NULL
  AND NOT EXISTS (
      SELECT 1
      FROM Employees AS e2
      WHERE e2.employee_id = e1.manager_id
  )
ORDER BY e1.employee_id;
```
