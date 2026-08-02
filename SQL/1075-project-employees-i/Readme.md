# 1075. Project Employees I

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** `JOIN` · `ON` · `GROUP BY` · `AVG()` · `ROUND()` · Table Aliases

---

## 📋 Problem Summary

For every project, report:
- ✅ Project ID
- ✅ Average experience years of all employees working on it, rounded to 2 decimal places

The experience years live in a different table, so `Project` and `Employee` must be joined using `employee_id`.

---

## ✅ Solution

```sql
SELECT p.project_id, ROUND(AVG(e.experience_years), 2) AS average_years
FROM Project AS p
JOIN Employee AS e
ON e.employee_id = p.employee_id
GROUP BY p.project_id;
```

---

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `SELECT p.project_id, ROUND(AVG(...), 2)` | Returns the project ID and its rounded average experience |
| `FROM Project AS p` | Starts with the Project table |
| `JOIN Employee AS e` | Joins the Employee table |
| `ON e.employee_id = p.employee_id` | Matches each project row to the employee's experience years |
| `GROUP BY p.project_id` | Collapses rows into one per project so `AVG()` can aggregate per group |

---

## 🤔 Why `JOIN` + `GROUP BY`?

The `Project` table contains:
- `project_id`
- `employee_id`

The `Employee` table contains:
- `employee_id`
- `name`
- `experience_years`

The common column is:
```text
employee_id
```

Joining attaches each project's employees to their experience years. Since a project can have multiple employees, `GROUP BY project_id` is needed to collapse those rows into one average per project.

### Visualization
```
Project                       Employee
--------                      --------
project_id                    employee_id
employee_id  ─────────────►   name
                               experience_years
```

Result:
| project_id | average_years |
|---|---:|
| 1 | 2.00 |
| 2 | 2.50 |

---

## 🔄 Why not a subquery?

A correlated subquery per project (`SELECT AVG(experience_years) FROM Employee WHERE employee_id IN (...)`) would also work, but it would re-scan `Employee` once per project. A single `JOIN` + `GROUP BY` does it in one pass and is the more idiomatic approach for this kind of "aggregate per group" problem.

---

## ⚠️ Common Mistakes

### Forgetting `GROUP BY`
❌ Incorrect
```sql
SELECT p.project_id, ROUND(AVG(e.experience_years), 2) AS average_years
FROM Project AS p
JOIN Employee AS e
ON e.employee_id = p.employee_id;
```
Without `GROUP BY project_id`, MySQL collapses everything into a single row (or errors under strict `ONLY_FULL_GROUP_BY` mode), instead of one average per project.

### Rounding before aggregating
❌ Incorrect
```sql
SELECT p.project_id, AVG(ROUND(e.experience_years, 2)) AS average_years
...
```
`experience_years` is already an integer, so rounding it first does nothing useful — round the **result** of `AVG()`, not the input.

---

## ⏱️ Time Complexity

**O(n)** — the join uses the indexed `employee_id`, and the aggregation is a single linear pass over the joined rows.

---

## 🔑 Key Learnings

- `INNER JOIN` is enough here since every `employee_id` in `Project` is guaranteed to exist in `Employee`.
- `GROUP BY` is required whenever you need one aggregate value *per category* rather than one aggregate for the whole table.
- `ROUND(AVG(...), 2)` wraps the aggregate, not the raw column.
- LeetCode's checker compares numeric values, not strings, so `2` and `2.00` are treated as equal.

---

## 🧠 Final Query

```sql
SELECT p.project_id, ROUND(AVG(e.experience_years), 2) AS average_years
FROM Project AS p
JOIN Employee AS e
ON e.employee_id = p.employee_id
GROUP BY p.project_id;
```
