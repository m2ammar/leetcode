# 1280. Students and Examinations
![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** `CROSS JOIN` · `LEFT JOIN` · Multi-column `JOIN` · `GROUP BY` · `COUNT`

---

## 📋 Problem Summary
Every student is expected to take every subject offered.
Find how many times each student attended the exam for each subject —
including subject pairs they never attended (should show `0`, not be missing).

---

## ✅ Solution
```sql
SELECT 
    st.student_id, 
    st.student_name, 
    s.subject_name, 
    COUNT(e.student_id) AS attended_exams
FROM Students AS st
CROSS JOIN Subjects AS s
LEFT JOIN Examinations AS e
    ON st.student_id = e.student_id
    AND s.subject_name = e.subject_name
GROUP BY st.student_id, st.student_name, s.subject_name
ORDER BY st.student_id ASC, s.subject_name ASC;
```

---

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `Students CROSS JOIN Subjects` | Builds every possible (student, subject) pair — the complete grid, with zero rows missing regardless of attendance |
| `LEFT JOIN Examinations ON student_id AND subject_name` | Attaches actual exam attendance to each pair, keeping pairs with no match (`e.*` becomes `NULL` for those) |
| `COUNT(e.student_id)` | Counts only non-null matches per group — pairs with no exam record correctly count as `0` |
| `GROUP BY student_id, student_name, subject_name` | Collapses all exam rows for a given pair into one summary row |

---

## 🤔 Why `CROSS JOIN` first?
`Students` and `Subjects` have **no shared column** to join on — every
student is meant to take every subject, so the relationship is "all
combinations," not "matching keys." That's exactly what `CROSS JOIN` gives:
a complete base grid with no `ON` condition needed.

---

## 🔄 Why not a normal `JOIN` for Examinations?
An inner `JOIN` between `Students` and `Examinations` only keeps pairs that
**already exist** in `Examinations`. Any student who never sat a given
subject's exam would be dropped from the result entirely — instead of
showing up with `attended_exams = 0`.

```sql
JOIN Examinations AS e ON ...   -- ❌ drops zero-attendance pairs
```

---

## 📚 JOIN Types at a Glance

| JOIN Type | Returns |
|---|---|
| `INNER JOIN` | Only matching rows from both tables |
| `LEFT JOIN` | All rows from the left table + matching rows from the right |
| `RIGHT JOIN` | All rows from the right table + matching rows from the left |
| `CROSS JOIN` | Every combination of rows from both tables (no `ON` needed) |
| `FULL JOIN` | All rows from both tables (not supported in MySQL) |

---

## ⚠️ Common Mistakes

### Joining Students and Subjects on a condition
```sql
JOIN Subjects AS s ON st.student_id = s.subject_name  -- ❌ no such relation
```
There's no direct relationship between the two tables — use `CROSS JOIN` instead.

### Joining Examinations on only one key
```sql
LEFT JOIN Examinations AS e ON st.student_id = e.student_id  -- ❌ incomplete match
```
The match must be on **both** `student_id` and `subject_name` at once, inside the same `LEFT JOIN`.

### Using `COUNT(*)` instead of `COUNT(e.student_id)`
```sql
COUNT(*)  -- ❌ counts the NULL row from unmatched LEFT JOIN as 1, not 0
```
`COUNT(column)` ignores `NULL`s, so unmatched pairs count correctly as `0`.

---

## ⏱️ Time Complexity
Roughly **O(S × J + E)** — S = number of students, J = number of subjects
(for the cross join grid), plus E = number of exam records to attach.

---

## 🔑 Key Learnings
- MySQL has no `FULL JOIN` — but most problems that seem to need one
  actually just need a **complete base table** (via `CROSS JOIN`) joined
  with `LEFT JOIN` onto the sparse data.
- `CROSS JOIN` requires no `ON` clause — use it when two tables have
  no direct relationship but you need every combination of their rows.
- A `LEFT JOIN` can match on **multiple columns** at once by chaining
  conditions with `AND` inside the `ON` clause.
- `COUNT(column)` vs `COUNT(*)` matters a lot with `LEFT JOIN` — always
  count a column that will be `NULL` on unmatched rows.

---

## 🧠 Final Query
```sql
SELECT 
    st.student_id, 
    st.student_name, 
    s.subject_name, 
    COUNT(e.student_id) AS attended_exams
FROM Students AS st
CROSS JOIN Subjects AS s
LEFT JOIN Examinations AS e
    ON st.student_id = e.student_id
    AND s.subject_name = e.subject_name
GROUP BY st.student_id, st.student_name, s.subject_name
ORDER BY st.student_id ASC, s.subject_name ASC;
```
