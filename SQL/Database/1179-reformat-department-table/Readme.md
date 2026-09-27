# 1179. Reformat Department Table

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** CASE Expressions · Conditional Aggregation · GROUP BY · Pivoting Rows to Columns

---

## ✅ Problem Summary

- Each row in `Department` represents one department's revenue for one month.
- Reformat the table so each department (`id`) has a single row.
- Each of the 12 months becomes its own column (`Jan_Revenue` ... `Dec_Revenue`).
- Months with no recorded revenue for that department should show `null`.

---

## 🧠 Solution

```sql
SELECT 
    id,
    SUM(CASE WHEN month = 'Jan' THEN revenue END) AS Jan_Revenue,
    SUM(CASE WHEN month = 'Feb' THEN revenue END) AS Feb_Revenue,
    SUM(CASE WHEN month = 'Mar' THEN revenue END) AS Mar_Revenue,
    SUM(CASE WHEN month = 'Apr' THEN revenue END) AS Apr_Revenue,
    SUM(CASE WHEN month = 'May' THEN revenue END) AS May_Revenue,
    SUM(CASE WHEN month = 'Jun' THEN revenue END) AS Jun_Revenue,
    SUM(CASE WHEN month = 'Jul' THEN revenue END) AS Jul_Revenue,
    SUM(CASE WHEN month = 'Aug' THEN revenue END) AS Aug_Revenue,
    SUM(CASE WHEN month = 'Sep' THEN revenue END) AS Sep_Revenue,
    SUM(CASE WHEN month = 'Oct' THEN revenue END) AS Oct_Revenue,
    SUM(CASE WHEN month = 'Nov' THEN revenue END) AS Nov_Revenue,
    SUM(CASE WHEN month = 'Dec' THEN revenue END) AS Dec_Revenue
FROM Department
GROUP BY id;
```

---

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `GROUP BY id` | Collapses all rows for a department into a single output row. |
| `CASE WHEN month = 'Jan' THEN revenue END` | Returns `revenue` only for rows where `month` matches; otherwise implicitly returns `NULL` (no `ELSE` needed). |
| `SUM(...)` | Aggregates the single non-null value per department/month combo into that month's column; ignores `NULL`s. |
| Repeated 12x | Same pattern per month, each producing one pivoted output column. |

---

## 🤔 Why Conditional Aggregation?

The `Department` table stores revenue in a "long" format — one row per (department, month) pair:

```
id | revenue | month

1 | 8000 | Jan
1 | 7000 | Feb
1 | 6000 | Mar

```

Conditional aggregation lets us "widen" this into one row per department, since `GROUP BY id` groups all of a department's rows together, and each `CASE` isolates one month's value out of that group.
```

   Department (long)              Reformatted (wide)
  id -- month -- revenue          id | Jan | Feb | Mar | ...
  1  -- Jan   -- 8000     ---->   1  | 8000| 7000| 6000| ...
  1  -- Feb   -- 7000
  1  -- Mar   -- 6000

```
  
---

## ⚠️ Why Not Just JOINs?

You could self-join the table 12 times (once per month) and merge the results, but that's far more verbose, harder to read, and less efficient — each join scans the table again. Conditional aggregation does it in a single pass over the grouped data.

---

## 🐛 Common Mistakes

**Mistake 1: Comparing instead of selecting**
```sql
-- Wrong: this evaluates a boolean comparison, not the revenue value
SUM(CASE WHEN month = 'Jan' THEN revenue = '' END)
```
```sql
-- Fix: just return the column itself
SUM(CASE WHEN month = 'Jan' THEN revenue END)
```

**Mistake 2: Mismatched WHEN condition and column alias**
```sql
-- Wrong: checking 'May' but naming the column Apr_Revenue
SUM(CASE WHEN month = 'May' THEN revenue END) AS Apr_Revenue
```
```sql
-- Fix: WHEN condition must match its own column's month
SUM(CASE WHEN month = 'Apr' THEN revenue END) AS Apr_Revenue
```

**Mistake 3: Using `ELSE 0` instead of leaving it as NULL**
```sql
-- Wrong: fills non-matching months with 0 instead of null
SUM(CASE WHEN month = 'Jan' THEN revenue ELSE 0 END)
```
```sql
-- Fix: omit ELSE (or use ELSE NULL) so SUM() correctly ignores non-matches
SUM(CASE WHEN month = 'Jan' THEN revenue END)
```

---

## ⏱️ Time Complexity

O(n), where n is the number of rows in `Department` — a single pass with grouping and aggregation, no repeated scans.

---

## 🔑 Key Learnings

- `CASE WHEN` without an `ELSE` defaults to `NULL`, which is exactly what `SUM()` needs to ignore non-matching rows.
- Conditional aggregation is the standard SQL pattern for pivoting long-format data into wide-format columns.
- Column alias and `WHEN` condition must always match — a mismatch silently produces wrong results without throwing an error.

---

## 🏁 Final Query

```sql
SELECT 
    id,
    SUM(CASE WHEN month = 'Jan' THEN revenue END) AS Jan_Revenue,
    SUM(CASE WHEN month = 'Feb' THEN revenue END) AS Feb_Revenue,
    SUM(CASE WHEN month = 'Mar' THEN revenue END) AS Mar_Revenue,
    SUM(CASE WHEN month = 'Apr' THEN revenue END) AS Apr_Revenue,
    SUM(CASE WHEN month = 'May' THEN revenue END) AS May_Revenue,
    SUM(CASE WHEN month = 'Jun' THEN revenue END) AS Jun_Revenue,
    SUM(CASE WHEN month = 'Jul' THEN revenue END) AS Jul_Revenue,
    SUM(CASE WHEN month = 'Aug' THEN revenue END) AS Aug_Revenue,
    SUM(CASE WHEN month = 'Sep' THEN revenue END) AS Sep_Revenue,
    SUM(CASE WHEN month = 'Oct' THEN revenue END) AS Oct_Revenue,
    SUM(CASE WHEN month = 'Nov' THEN revenue END) AS Nov_Revenue,
    SUM(CASE WHEN month = 'Dec' THEN revenue END) AS Dec_Revenue
FROM Department
GROUP BY id;
```
