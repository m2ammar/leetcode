
# 3482. Analyze Organization Hierarchy

![Difficulty](https://img.shields.io/badge/Difficulty-Hard-red)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** Recursive CTEs · Hierarchical Data · Self-Joins · Aggregation · LEFT JOIN · COALESCE

---

## ✅ Problem Summary

Given an `Employees` table representing an organizational hierarchy:

- Determine each employee's hierarchy level, starting with the CEO at level 1.
- Calculate the total team size, including direct and indirect reports.
- Calculate each employee's salary budget, including their own salary and the salaries of all their direct and indirect reports.
- Sort by level ascending, budget descending, and employee name ascending.

Employees without reports should have a `team_size` of `0` and a `budget` equal to their own salary.

---

## 🧠 Solution

```sql
WITH RECURSIVE level AS (
    SELECT employee_id, 1 AS level
    FROM Employees
    WHERE manager_id IS NULL

    UNION ALL

    SELECT e.employee_id, l.level + 1
    FROM Employees AS e
    JOIN level AS l
        ON e.manager_id = l.employee_id
),
reports AS (
    SELECT manager_id, employee_id
    FROM Employees
    WHERE manager_id IS NOT NULL

    UNION ALL

    SELECT r.manager_id, e.employee_id
    FROM reports AS r
    JOIN Employees AS e
        ON e.manager_id = r.employee_id
)
SELECT
    m.employee_id,
    m.employee_name,
    l.level,
    COUNT(s.employee_id) AS team_size,
    COALESCE(SUM(s.salary), 0) + m.salary AS budget
FROM Employees AS m
LEFT JOIN reports AS r
    ON r.manager_id = m.employee_id
LEFT JOIN Employees AS s
    ON s.employee_id = r.employee_id
JOIN level AS l
    ON l.employee_id = m.employee_id
GROUP BY
    m.employee_id,
    m.employee_name,
    l.level,
    m.salary
ORDER BY
    l.level ASC,
    budget DESC,
    m.employee_name ASC;
```

---

## 🧩 Breakdown

| Component | Purpose |
|---|---|
| `level` CTE | Calculates each employee's hierarchy level recursively. |
| Anchor query | Finds the CEO using `manager_id IS NULL` and assigns level 1. |
| Recursive level query | Finds employees reporting to the previous level and increments the level. |
| `reports` CTE | Builds manager–descendant relationships for all direct and indirect reports. |
| Recursive reports query | Finds additional descendants while preserving the original manager ID. |
| `LEFT JOIN reports` | Retrieves all descendants for each employee, including employees with no reports. |
| `LEFT JOIN Employees AS s` | Retrieves the salaries of all descendants. |
| `COUNT(s.employee_id)` | Counts all direct and indirect reports. |
| `SUM(s.salary) + m.salary` | Calculates the total salary budget controlled by an employee. |
| `COALESCE(..., 0)` | Converts a NULL salary sum into zero for employees without reports. |
| `GROUP BY` | Produces one result row per employee. |
| `ORDER BY` | Sorts by level, budget, and employee name as required. |

---

## 🌳 How the Recursive `reports` CTE Works

Consider this organizational hierarchy:

```text
Alice
├── Bob
│   ├── David
│   │   └── Hank
│   └── Eva
└── Charlie
    ├── Frank
    │   ├── Ivy
    │   └── Judy
    └── Grace
```

The anchor query starts with direct reports. The recursive query follows those employees to find their reports, repeating until no further descendants are found.

For Alice, the CTE produces relationships such as:

```text
Alice → Bob
Alice → Charlie
Alice → David
Alice → Eva
Alice → Frank
Alice → Grace
Alice → Hank
Alice → Ivy
Alice → Judy
```

Alice therefore has 9 descendants.

The key is preserving `r.manager_id` during recursion. This keeps every descendant associated with the original manager rather than only their immediate manager.

---

## 💰 Salary Budget Calculation

For Alice:

- Own salary: `12000`
- All descendants' salaries: `72500`
- Total budget: `12000 + 72500 = 84500`

The query sums the salaries of all descendants and adds the current employee's salary.

For an employee without reports, `SUM(s.salary)` returns `NULL`. `COALESCE` changes that to `0`, so the employee's budget remains their own salary.

---

## ⚠️ Common Mistakes

### Mistake 1: Selecting the wrong employee ID

```sql
-- Wrong
SELECT m.manager_id AS employee_id
```

```sql
-- Correct
SELECT m.employee_id
```

The output must identify the employee being analyzed, not their manager.

### Mistake 2: Counting only direct reports

Counting rows directly from `Employees` where `manager_id = m.employee_id` excludes indirect reports.

**Fix:** Use the recursive `reports` CTE to find every descendant.

### Mistake 3: Losing the original manager ID

```sql
-- Correct recursive relationship
SELECT r.manager_id, e.employee_id
FROM reports AS r
JOIN Employees AS e
    ON e.manager_id = r.employee_id
```

Preserving `r.manager_id` ensures that descendants remain associated with the original manager.

### Mistake 4: Excluding employees without reports

Using an inner join for descendants can remove employees who have no reports.

**Fix:** Use `LEFT JOIN` so every employee remains in the result.

### Mistake 5: Forgetting the employee's own salary

The descendant salary sum excludes the current employee.

**Fix:** Add `m.salary` to the sum.

---

## ⏱️ Time Complexity

Let `n` be the number of employees and `d` the number of manager–descendant relationships generated by the recursive `reports` CTE.

- Hierarchy traversal depends on the number of employees and the hierarchy depth.
- The `reports` CTE can generate up to **O(n²)** relationships in the worst case.
- The final joins and aggregation process those relationships, making the overall worst-case work **O(n²)**, ignoring database-specific execution-plan and indexing effects.

---

## 🔑 Key Learnings

- Recursive CTEs can traverse hierarchical data such as organizational charts.
- Preserve the original manager ID to track all descendants.
- Separate hierarchy traversal from aggregation.
- Use `LEFT JOIN` to retain employees without reports.
- Use `COALESCE` to handle NULL salary sums.
- A manager's budget includes their own salary and every descendant's salary.

---

## 🏁 Final Query

```sql
WITH RECURSIVE level AS (
    SELECT employee_id, 1 AS level
    FROM Employees
    WHERE manager_id IS NULL

    UNION ALL

    SELECT e.employee_id, l.level + 1
    FROM Employees AS e
    JOIN level AS l
        ON e.manager_id = l.employee_id
),
reports AS (
    SELECT manager_id, employee_id
    FROM Employees
    WHERE manager_id IS NOT NULL

    UNION ALL

    SELECT r.manager_id, e.employee_id
    FROM reports AS r
    JOIN Employees AS e
        ON e.manager_id = r.employee_id
)
SELECT
    m.employee_id,
    m.employee_name,
    l.level,
    COUNT(s.employee_id) AS team_size,
    COALESCE(SUM(s.salary), 0) + m.salary AS budget
FROM Employees AS m
LEFT JOIN reports AS r
    ON r.manager_id = m.employee_id
LEFT JOIN Employees AS s
    ON s.employee_id = r.employee_id
JOIN level AS l
    ON l.employee_id = m.employee_id
GROUP BY
    m.employee_id,
    m.employee_name,
    l.level,
    m.salary
ORDER BY
    l.level ASC,
    budget DESC,
    m.employee_name ASC;
```
