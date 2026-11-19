# 🎓 3764. Most Common Course Pairs

![Difficulty](https://img.shields.io/badge/Difficulty-Hard-red)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-brightgreen)

**Concepts:** `CTE` · `Window Function` · `LEAD` · `PARTITION BY` · `HAVING` · `JOIN` · `GROUP BY`

---

## 📋 Problem Summary

- ✅ Keep only **top performers**: students with at least 5 completed courses and an average rating of 4 or higher
- ✅ Order each top performer's courses chronologically
- ✅ Find every consecutive pair (Course A → Course B)
- ✅ Count how often each pair occurs across all top performers
- ✅ Sort by count (DESC), then first course (ASC), then second course (ASC)

---

## 💡 Solution

```sql
WITH cte AS (
    SELECT user_id,
           course_name,
           LEAD(course_name) OVER (PARTITION BY user_id ORDER BY completion_date) AS next_course
    FROM course_completions
),

cte2 AS (
    SELECT user_id
    FROM course_completions
    GROUP BY user_id
    HAVING COUNT(course_id) >= 5
       AND AVG(course_rating) >= 4
)

SELECT course_name AS first_course,
       next_course AS second_course,
       COUNT(*) AS transition_count
FROM cte AS c1
JOIN cte2 AS c2
  ON c1.user_id = c2.user_id
WHERE next_course IS NOT NULL
GROUP BY course_name, next_course
ORDER BY transition_count DESC, first_course, second_course;
```

---

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `LEAD(course_name) OVER (...)` | Pulls the course from the **next row** in the same window |
| `PARTITION BY user_id` | Restarts the window per student, so pairs never cross users |
| `ORDER BY completion_date` | Makes "next" mean the next course chronologically |
| `cte` | One row per course with its follow-up course (`next_course`) |
| `cte2` | The list of top-performer `user_id`s |
| `HAVING COUNT(...) >= 5 AND AVG(...) >= 4` | Filters groups after aggregation (`WHERE` can't do this) |
| `JOIN cte2` | Keeps only pairs that belong to top performers |
| `WHERE next_course IS NOT NULL` | Drops each user's last course, which has no pair |
| `GROUP BY course_name, next_course` | One group per distinct pair |
| `COUNT(*)` | How many times the pair occurred |

---

## 🤔 Why LEAD?

A transition is a row paired with the row right after it. `LEAD` gives each row access to its neighbour without joining the table to itself.

For user 2, the CTE produces:

```
Python Basics    -> React Basics
React Basics     -> Node.js
Node.js          -> Docker
Docker           -> AWS Fundamentals
AWS Fundamentals -> NULL   (no next course, filtered out later)
```

5 courses give 4 transitions, so n courses always give n - 1 pairs.

| first_course | second_course | transition_count |
|---|---|---|
| Node.js | Docker | 2 |
| React Basics | Node.js | 2 |
| Docker | AWS Fundamentals | 1 |

---

## 🆚 Why not a self-join?

The alternative is `ROW_NUMBER()` per user, then joining the table to itself on `rn + 1`. It gives the same result but needs an extra CTE and a join condition (`a.user_id = b.user_id AND b.rn = a.rn + 1`). `LEAD` says the same thing in one line and is easier to read and debug.

---

## 🪟 Window Functions at a Glance

| Function | Looks at |
|---|---|
| `LEAD(col, n)` | The **next** n-th row |
| `LAG(col, n)` | The **previous** n-th row |
| `ROW_NUMBER()` | Position in the partition (1, 2, 3...) |
| `RANK()` | Rank with gaps on ties |

---

## ⚠️ Common Mistakes

**1. Offset 0 in LEAD**
```sql
LEAD(course_name, 0, 1) OVER (...)   -- offset 0 = the current row
```
Fix: use the default offset of 1, `LEAD(course_name) OVER (...)`.

**2. Grouping by user and course for the top-performer check**
```sql
GROUP BY user_id, course_id   -- every group has size 1
```
Fix: `(user_id, course_id)` is unique, so group by `user_id` only to count courses per student.

**3. Wrong alias for the second course**
```sql
course_name AS second_course   -- gives pairs like "Docker, Docker"
```
Fix: the second course is `next_course`.

**4. Filtering `next_course IS NOT NULL` inside the CTE**
The window is computed after `WHERE`, so removing rows early changes what `LEAD` sees. Filter in the final select instead.

**5. Forgetting to use the top-performer CTE**
Defining `cte2` but never joining it counts every student.

---

## ⏱️ Time Complexity

**O(n log n)**, dominated by sorting for the window (`PARTITION BY` + `ORDER BY`) and the `GROUP BY`.

---

## 🔑 Key Learnings

- `LEAD(col)` reads the next row's value; the last row of each partition gets `NULL`
- `PARTITION BY` isolates each user's sequence, `ORDER BY` defines "next"
- Per-user aggregation (`HAVING`) and per-pair aggregation can't share one `GROUP BY`, so use a separate CTE
- Filter on the `LEAD` result **after** the CTE, never inside it
- n items in a sequence produce n - 1 consecutive pairs

---

## ✅ Final Query

```sql
WITH cte AS (
    SELECT user_id,
           course_name,
           LEAD(course_name) OVER (PARTITION BY user_id ORDER BY completion_date) AS next_course
    FROM course_completions
),

cte2 AS (
    SELECT user_id
    FROM course_completions
    GROUP BY user_id
    HAVING COUNT(course_id) >= 5
       AND AVG(course_rating) >= 4
)

SELECT course_name AS first_course,
       next_course AS second_course,
       COUNT(*) AS transition_count
FROM cte AS c1
JOIN cte2 AS c2
  ON c1.user_id = c2.user_id
WHERE next_course IS NOT NULL
GROUP BY course_name, next_course
ORDER BY transition_count DESC, first_course, second_course;
```
