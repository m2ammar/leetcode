# 3421. Find Students Who Improved

![Difficulty](https://img.shields.io/badge/Difficulty-Medium-orange)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-brightgreen)

**Concepts:** `CTE` · `Window Functions` · `FIRST_VALUE` · `PARTITION BY` · `DISTINCT` · `ORDER BY`

---

## ✅ Problem Summary

- Return students who **improved in a subject**
- Improvement = took the subject on **at least two different dates** AND **latest score > first score**
- Output columns: `student_id`, `subject`, `first_score`, `latest_score`
- Order by `student_id`, then `subject` (both ascending)

---

## 🧩 Solution

```sql
WITH cte AS (
    SELECT
        student_id,
        subject,
        FIRST_VALUE(score) OVER (PARTITION BY student_id, subject ORDER BY exam_date ASC)  AS first_score,
        FIRST_VALUE(score) OVER (PARTITION BY student_id, subject ORDER BY exam_date DESC) AS latest_score
    FROM Scores
)
SELECT DISTINCT
    student_id,
    subject,
    first_score,
    latest_score
FROM cte
WHERE first_score < latest_score
ORDER BY student_id ASC, subject ASC;
```

---

## 🔍 Breakdown

| Clause | What it does |
|---|---|
| `PARTITION BY student_id, subject` | Builds one window per student per subject, so subjects never mix |
| `FIRST_VALUE(score) ... ORDER BY exam_date ASC` | Score on the earliest exam date in that window (`first_score`) |
| `FIRST_VALUE(score) ... ORDER BY exam_date DESC` | Score on the latest exam date in that window (`latest_score`) |
| `WITH cte AS (...)` | Holds the window results, since a window function can't be filtered in the same `SELECT` |
| `WHERE first_score < latest_score` | Keeps only improvers; also drops single-exam students (first = latest) |
| `DISTINCT` | Every exam row in a group carries the same pair, so this collapses repeats to one row |
| `ORDER BY student_id, subject` | Required output order |

---

## 🤔 Why Window Functions?

The grain is **(student_id, subject)**, not just `student_id`. A student can have several subjects, and each must be judged on its own.

```
Scores (student 101, Math)
  2023-01-15 → 70   ← first
  2023-02-15 → 85   ← latest

Both rows get: first_score = 70, latest_score = 85
```

| student_id | subject | first_score | latest_score |
|---|---|---|---|
| 101 | Math | 70 | 85 |
| 101 | Math | 70 | 85 |

`DISTINCT` then collapses these into a single row.

---

## 🆚 Why not Self Join?

A self join needs the `MIN(exam_date)` and `MAX(exam_date)` per group first (a subquery), then two joins back to `Scores` to fetch the scores on those dates. It works, but it's three steps where window functions need one. The CTE version reads top to bottom.

---

## 📊 Window Functions at a Glance

| Function | Looks at | Fits this problem? |
|---|---|---|
| `LAG` / `LEAD` | Only the adjacent row | ❌ Fails with 3+ exams (first vs latest isn't adjacent) |
| `FIRST_VALUE` | First row of the window frame | ✅ |
| `LAST_VALUE` | Last row of the **frame** (default frame stops at current row) | ⚠️ Needs `ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING` |

Using `FIRST_VALUE` twice (ASC and DESC) avoids the `LAST_VALUE` frame trap.

---

## ⚠️ Common Mistakes

**1. Partitioning by `student_id` only**

```sql
PARTITION BY student_id          -- ❌ mixes subjects
```

First/latest get computed across all subjects. E.g. Math 50 (Jan 1), Physics 90 (Jan 10), Physics 95 (Feb 10), Math 40 (Feb 20): Physics improved, but this compares 50 vs 40 and misses it.

```sql
PARTITION BY student_id, subject -- ✅
```

**2. `GROUP BY student_id` to remove duplicates**

```sql
GROUP BY student_id              -- ❌ collapses subjects, picks an arbitrary one
```

It only passes because `ONLY_FULL_GROUP_BY` is off on LeetCode. Use `SELECT DISTINCT` (or group by all four selected columns).

**3. Forgetting `DISTINCT`**

Without it, each exam row in a group produces an identical output row.

**4. Missing `ORDER BY`**

The correct order can appear by luck. The problem requires it explicitly.

---

## ⏱️ Time Complexity

**O(n log n)**, dominated by sorting inside the window partitions.

---

## 🔑 Key Learnings

- Identify the **grain** first: what is one "unit" of the answer? Here it's (student, subject)
- "First vs latest" is not "previous", so `LAG`/`LEAD` are the wrong tools
- Flip the `ORDER BY` direction to get "last" without `LAST_VALUE`
- Window functions repeat on every row of the group, so deduplicate with `DISTINCT`
- Passing the tests doesn't prove correctness: build your own failing case
- `exam_date` is a `varchar`, but `YYYY-MM-DD` sorts correctly as text; other formats need `STR_TO_DATE`

---

## 🧾 Final Query

```sql
WITH cte AS (
    SELECT
        student_id,
        subject,
        FIRST_VALUE(score) OVER (PARTITION BY student_id, subject ORDER BY exam_date ASC)  AS first_score,
        FIRST_VALUE(score) OVER (PARTITION BY student_id, subject ORDER BY exam_date DESC) AS latest_score
    FROM Scores
)
SELECT DISTINCT
    student_id,
    subject,
    first_score,
    latest_score
FROM cte
WHERE first_score < latest_score
ORDER BY student_id ASC, subject ASC;
```
