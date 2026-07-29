# 570. Managers with at Least 5 Direct Reports
![Difficulty](https://img.shields.io/badge/Difficulty-Medium-orange)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** `GROUP BY` · `HAVING` · `COUNT` · subquery · `JOIN`

---

## 📋 Problem Summary
Table `Employee` holds every employee, and each row's `managerId` points to that employee's manager (or is `NULL` if they have none).

Find the names of managers who have **at least 5 people reporting to them**.

---

## ✅ Solution
```sql
SELECT e.name
FROM Employee AS e
JOIN (
    SELECT managerId
    FROM Employee
    WHERE managerId IS NOT NULL
    GROUP BY managerId
    HAVING COUNT(*) >= 5
) AS report ON e.id = report.managerId;
```

---

## 🧩 Breakdown
| Clause | What it does |
|---|---|
| `WHERE managerId IS NOT NULL` | Ignores employees who don't report to anyone — nothing to count there |
| `GROUP BY managerId` | Bundles all employees together who share the same manager |
| `HAVING COUNT(*) >= 5` | Keeps only the bundles (managers) with 5 or more people in them |
| `JOIN ... ON e.id = report.managerId` | Matches the qualifying manager ids back to their own row in `Employee` to pull the `name` |

---

## ⚠️ Why the join is needed
The subquery only ever looks at the `managerId` column — it can tell you *which ids* qualify, but it has no access to `name`. The `name` column lives on the manager's *own* row (where `id` = that manager's id), not on the rows of the people reporting to them.

So the table gets used in two different roles:
- **Inside the subquery** — as a list of "who reports to whom," to count reports per manager.
- **In the outer query (`e`)** — as a lookup of "this id's own record," to fetch that manager's name.

The `JOIN` connects those two roles by matching `e.id` (the manager's own id) to `report.managerId` (the qualifying id from the count).

---

## ❌ Common Mistakes
- `WHERE managerId IS NULL` — this finds employees with *no* manager, not managers with 5+ reports. It can accidentally pass an example test case by coincidence without being correct logic.
- Forgetting `WHERE managerId IS NOT NULL` in the subquery — without it, `NULL` values could get grouped and counted as if they were a manager.
- Trying to get the name directly from the subquery — the subquery never touches `name`, so a join back to `Employee` is unavoidable.

---

## ⏱️ Time Complexity
**O(n)** — one pass to group and count, one pass to join back on `id`; both typically optimized with an index on `managerId`.

---

## 🔑 Key Learnings
- Counting relationships (`managerId` occurrences) is a classic `GROUP BY` + `HAVING COUNT(*)` pattern.
- A subquery that only selects a foreign key (like `managerId`) can identify *which* rows qualify, but a `JOIN` back to the main table is needed to retrieve other columns (like `name`) tied to that id.
- Always double-check that a query is testing the actual logic of the problem, not just producing the right output for a single example.

---

## 🧠 Final Query
```sql
SELECT e.name
FROM Employee AS e
JOIN (
    SELECT managerId
    FROM Employee
    WHERE managerId IS NOT NULL
    GROUP BY managerId
    HAVING COUNT(*) >= 5
) AS report ON e.id = report.managerId;
```
