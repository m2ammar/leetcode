# 3611. Find Overbooked Employees

![Difficulty](https://img.shields.io/badge/Difficulty-Medium-orange)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-brightgreen)

**Concepts:** `CTE` · `GROUP BY` · `HAVING` · `SUM` · `COUNT` · `YEARWEEK` · `JOIN` · `ORDER BY`

---

## ✅ Problem Summary

Find employees who are **meeting-heavy** (spend more than 50% of a 40-hour work week in meetings).

- ✔️ Total meeting hours **per employee, per week** (Monday to Sunday)
- ✔️ A week is meeting-heavy if the total is **> 20 hours**
- ✔️ Count how many meeting-heavy weeks each employee has
- ✔️ Keep only employees with **at least 2** meeting-heavy weeks
- ✔️ Return `employee_id`, `employee_name`, `department`, `meeting_heavy_weeks`
- ✔️ Order by `meeting_heavy_weeks` DESC, then `employee_name` ASC

---

## 💡 Solution

```sql
WITH cte AS (
    SELECT
        employee_id,
        YEARWEEK(meeting_date, 7) AS weekly
    FROM meetings
    GROUP BY employee_id, YEARWEEK(meeting_date, 7)
    HAVING SUM(duration_hours) > 20
)

SELECT e.employee_id, e.employee_name, e.department, COUNT(c.weekly) AS meeting_heavy_weeks
FROM cte AS c
JOIN employees AS e
ON c.employee_id = e.employee_id
GROUP BY e.employee_id, e.employee_name, e.department
HAVING COUNT(*) >= 2
ORDER BY meeting_heavy_weeks DESC, e.employee_name ASC;
```

---

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `YEARWEEK(meeting_date, 7)` | Turns each date into a Monday-to-Sunday week label |
| `GROUP BY employee_id, YEARWEEK(...)` | One group per employee per week |
| `HAVING SUM(duration_hours) > 20` | Keeps only the meeting-heavy weeks |
| `WITH cte AS (...)` | Stores one row per heavy week (employee + week) |
| `JOIN employees` | Brings in name and department after filtering |
| `GROUP BY e.employee_id, ...` | One group per employee, to count their heavy weeks |
| `HAVING COUNT(*) >= 2` | Keeps employees with 2 or more heavy weeks |
| `ORDER BY` | Most heavy weeks first, ties broken by name A to Z |

---

## 🤔 Why aggregate twice?

The question has two levels: first *"how many hours per employee per week?"*, then *"how many heavy weeks per employee?"*. The second level counts the output of the first, so one `GROUP BY` isn't enough.

```
meetings (many rows per employee)
   │  GROUP BY employee + week, HAVING SUM > 20
   ▼
cte (one row per heavy week)
   │  GROUP BY employee, HAVING COUNT >= 2
   ▼
final result (one row per overbooked employee)
```

Example, after step 1:

| employee_id | weekly |
|---|---|
| 1 | 202323 |
| 1 | 202324 |
| 2 | 202323 |
| 4 | 202323 |
| 4 | 202325 |

Step 2 counts rows per employee: Alice has 2, Bob has 1, David has 2. Only Alice and David pass.

---

## 🔀 Why not a window function?

A window function like `SUM(duration_hours) OVER (PARTITION BY employee_id, week)` would work for the weekly total, but it keeps every meeting row. You'd have to remove duplicates before counting weeks, which adds steps for no gain. `GROUP BY` collapses rows exactly where this problem needs them collapsed.

---

## 📅 Week Handling: Two Ways

| Approach | Example | Notes |
|---|---|---|
| `YEARWEEK(date, 7)` | `202323` | Mode 7 starts weeks on Monday |
| Monday date | `DATE_SUB(date, INTERVAL WEEKDAY(date) DAY)` | No modes to remember; `WEEKDAY` is 0 for Monday up to 6 for Sunday |

The `7` is a **mode code**, not "7 days". Modes 1 and 7 both start weeks on Monday and only differ in how week 1 of the year is numbered, so they group the same dates together here. Mode 0 (the default) starts weeks on **Sunday** and would put Sunday meetings in the wrong week.

---

## ⚠️ Common Mistakes

**1. Grouping by week only**
```sql
GROUP BY YEARWEEK(meeting_date, 7)
```
This adds up every employee's hours in the same week into one group. Fix: include the employee.
```sql
GROUP BY employee_id, YEARWEEK(meeting_date, 7)
```

**2. Selecting columns that aren't grouped or aggregated**
```sql
SELECT meeting_id, ...   -- not in GROUP BY, not aggregated
```
MySQL may reject it or pick an arbitrary value. Fix: only select what the step needs.

**3. Counting per the wrong thing in the final step**
```sql
GROUP BY meeting_id      -- unique per meeting, so COUNT is always 1
GROUP BY weekly          -- counts employees per week, not weeks per employee
```
Fix: group by the employee, because the question asks how many weeks *each employee* had.

---

## ⏱️ Time Complexity

- Grouping `meetings`: **O(n)** with hashing (up to O(n log n) if sorted)
- Join with `employees` on the primary key: roughly **O(k)** where k is the number of heavy weeks
- Final grouping and sort: small, since only heavy weeks remain

---

## 🔑 Key Learnings

- "How many X per Y" where X is a filtered aggregate means **aggregate, filter, aggregate again**
- Every `SELECT` column must be in the `GROUP BY` or inside an aggregate
- `HAVING` filters groups; `WHERE` filters rows before grouping
- `YEARWEEK`'s second argument is a mode code; check the docs instead of guessing
- Filter first, join later: keep the CTE light and join for names at the end

---

## 🏁 Final Query

```sql
WITH cte AS (
    SELECT
        employee_id,
        YEARWEEK(meeting_date, 7) AS weekly
    FROM meetings
    GROUP BY employee_id, YEARWEEK(meeting_date, 7)
    HAVING SUM(duration_hours) > 20
)

SELECT e.employee_id, e.employee_name, e.department, COUNT(c.weekly) AS meeting_heavy_weeks
FROM cte AS c
JOIN employees AS e
ON c.employee_id = e.employee_id
GROUP BY e.employee_id, e.employee_name, e.department
HAVING COUNT(*) >= 2
ORDER BY meeting_heavy_weeks DESC, e.employee_name ASC;
```
