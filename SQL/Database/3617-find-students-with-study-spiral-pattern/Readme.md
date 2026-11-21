# 🔁 3617. Find Students with Study Spiral Pattern

![Difficulty](https://img.shields.io/badge/Difficulty-Hard-red)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-brightgreen)

**Concepts:** `CTE` · `LAG` · `SUM() OVER` · `ROW_NUMBER` · `FIRST_VALUE` · `Self JOIN` · `HAVING` · `Gaps and Islands`

---

## ✅ Problem Summary

Return students who follow a **Study Spiral Pattern**:
- ✅ At least **3 different subjects** repeating in the same order
- ✅ The cycle repeats **at least 2 full times** (6+ sessions)
- ✅ Consecutive sessions have **no gap longer than 2 days**
- ✅ Output `cycle_length` and `total_study_hours`
- ✅ Order by `cycle_length` DESC, then `total_study_hours` DESC

---

## 🧩 Solution

```sql
# Write your MySQL query statement below
WITH cte1 AS (
    SELECT student_id, subject, session_date, hours_studied,
           LAG(session_date) OVER (PARTITION BY student_id ORDER BY session_date) AS prev_date
    FROM study_sessions
),
cte2 AS (
    SELECT student_id, subject, session_date, hours_studied,
           CASE WHEN prev_date IS NULL OR DATEDIFF(session_date, prev_date) > 2
                THEN 1 ELSE 0 END AS new_streak
    FROM cte1
),
cte3 AS (
    SELECT student_id, subject, session_date, hours_studied,
           SUM(new_streak) OVER (PARTITION BY student_id ORDER BY session_date) AS streak_id
    FROM cte2
),
cte4 AS (
    SELECT student_id, subject, session_date, hours_studied, streak_id,
           ROW_NUMBER() OVER (PARTITION BY student_id, streak_id ORDER BY session_date) AS pos
    FROM cte3
),
cte5 AS (
    SELECT student_id, subject, session_date, hours_studied, pos, streak_id,
           FIRST_VALUE(subject) OVER (PARTITION BY student_id, streak_id ORDER BY pos) AS first_subject
    FROM cte4
),
cte6 AS (
    SELECT student_id, streak_id, MIN(pos) - 1 AS cycle_length
    FROM cte5
    WHERE subject = first_subject AND pos > 1
    GROUP BY student_id, streak_id
),
cte7 AS (
    SELECT a.student_id, a.streak_id, COUNT(*) AS matches
    FROM cte5 a
    JOIN cte6 k
      ON a.student_id = k.student_id
     AND a.streak_id = k.streak_id
    JOIN cte5 b
      ON b.student_id = a.student_id
     AND b.streak_id = a.streak_id
     AND a.pos > k.cycle_length
     AND b.pos = a.pos - k.cycle_length
    WHERE a.subject = b.subject
    GROUP BY a.student_id, a.streak_id
),
cte8 AS (
    SELECT student_id
    FROM cte5
    GROUP BY student_id
    HAVING COUNT(DISTINCT streak_id) = 1
)
SELECT c6.student_id,
       s.student_name,
       s.major,
       c6.cycle_length,
       SUM(c5.hours_studied) AS total_study_hours
FROM cte6 c6
JOIN cte5 c5
  ON c6.student_id = c5.student_id
 AND c6.streak_id = c5.streak_id
JOIN students s
  ON c6.student_id = s.student_id
JOIN cte7 m
  ON m.student_id = c6.student_id
 AND m.streak_id = c6.streak_id
JOIN cte8 n
  ON n.student_id = c6.student_id
GROUP BY c6.student_id, s.student_name, s.major, c6.cycle_length, c6.streak_id, m.matches
HAVING c6.cycle_length >= 3
   AND COUNT(*) >= 2 * c6.cycle_length
   AND COUNT(*) % c6.cycle_length = 0
   AND COUNT(DISTINCT c5.subject) = c6.cycle_length
   AND m.matches = COUNT(*) - c6.cycle_length
ORDER BY c6.cycle_length DESC, total_study_hours DESC;
```

---

## 🔍 Breakdown

| CTE | What it does |
|---|---|
| `cte1` | `LAG` gets each student's previous session date |
| `cte2` | Flags `new_streak = 1` when there is no previous date or the gap is > 2 days |
| `cte3` | Running `SUM(new_streak)` gives each streak an ID (gaps and islands) |
| `cte4` | `ROW_NUMBER` gives each session its position inside its streak |
| `cte5` | `FIRST_VALUE` attaches the streak's first subject to every row |
| `cte6` | Keeps rows that repeat the first subject; `MIN(pos) - 1` is the cycle length |
| `cte7` | Self-join: counts sessions whose subject equals the one `cycle_length` positions earlier |
| `cte8` | Keeps only students with exactly one streak in their whole history |
| Final `HAVING` | cycle ≥ 3, ≥ 2 full cycles, whole streak is whole cycles, distinct subjects = cycle, every later session matches |

---

## 🤔 Why Gaps and Islands?

A "streak" is a run of sessions where each gap is ≤ 2 days. A new streak starts wherever a gap breaks the rule, and a running sum of those break flags labels each streak.

```
dates:      Oct1  Oct2  Oct3 | Oct9  Oct10
new_streak:   1     0     0   |   1     0
streak_id:    1     1     1   |   2     2
```

---

## 🆚 Why not a simple count check?

Checking only cycle length, session count, and distinct subjects accepts `A, B, C, A, C, B`. The first cycle is A-B-C, the second is A-C-B, so it is not a real repeat. The self-join in `cte7` compares each session to the one exactly `cycle_length` earlier, which catches this.

---

## ⚠️ Common Mistakes

**1. Treating a 2-day gap as a break**
```sql
DATEDIFF(session_date, prev_date) >= 2   -- ❌ breaks valid streaks
DATEDIFF(session_date, prev_date) > 2    -- ✅ "no gaps longer than 2 days"
```

**2. Filtering a window function in WHERE**
```sql
WHERE subject = FIRST_VALUE(subject) OVER (...)   -- ❌ WHERE runs before windows
```
Compute `first_subject` in one CTE, filter on it in the next.

**3. Counting rows instead of distinct streaks**
```sql
HAVING COUNT(streak_id) = 1            -- ❌ counts rows
HAVING COUNT(DISTINCT streak_id) = 1   -- ✅ counts streaks
```

**4. Forgetting `streak_id` in GROUP BY**
A student's streaks get merged, so counts and hours are wrong.

**5. Selecting non-aggregated columns after GROUP BY**
After grouping by streak, `subject` and `session_date` have no single value.

---

## ⏱️ Time Complexity

Window functions sort per student: **O(n log n)**. The self-join matches positions within a streak, so it is bounded by streak length per student.

---

## 🔑 Key Learnings

- 🧠 Gaps and islands: `LAG` → flag → running `SUM` → streak ID
- 🧠 `WHERE` can't see window functions; use a CTE layer first
- 🧠 Cycle length = (position of first repeat of the first subject) − 1
- 🧠 Validate a repeating pattern by comparing each row to the one `k` positions earlier
- 🧠 Hidden test case revealed an unstated rule: a student with a stray session outside the pattern (a separate streak) does not qualify. This came from the failing test, not the problem statement.

---

## 🏁 Final Query


```sql
# Write your MySQL query statement below
WITH cte1 AS (
    SELECT student_id, subject, session_date, hours_studied,
           LAG(session_date) OVER (PARTITION BY student_id ORDER BY session_date) AS prev_date
    FROM study_sessions
),
cte2 AS (
    SELECT student_id, subject, session_date, hours_studied,
           CASE WHEN prev_date IS NULL OR DATEDIFF(session_date, prev_date) > 2
                THEN 1 ELSE 0 END AS new_streak
    FROM cte1
),
cte3 AS (
    SELECT student_id, subject, session_date, hours_studied,
           SUM(new_streak) OVER (PARTITION BY student_id ORDER BY session_date) AS streak_id
    FROM cte2
),
cte4 AS (
    SELECT student_id, subject, session_date, hours_studied, streak_id,
           ROW_NUMBER() OVER (PARTITION BY student_id, streak_id ORDER BY session_date) AS pos
    FROM cte3
),
cte5 AS (
    SELECT student_id, subject, session_date, hours_studied, pos, streak_id,
           FIRST_VALUE(subject) OVER (PARTITION BY student_id, streak_id ORDER BY pos) AS first_subject
    FROM cte4
),
cte6 AS (
    SELECT student_id, streak_id, MIN(pos) - 1 AS cycle_length
    FROM cte5
    WHERE subject = first_subject AND pos > 1
    GROUP BY student_id, streak_id
),
cte7 AS (
    SELECT a.student_id, a.streak_id, COUNT(*) AS matches
    FROM cte5 a
    JOIN cte6 k
      ON a.student_id = k.student_id
     AND a.streak_id = k.streak_id
    JOIN cte5 b
      ON b.student_id = a.student_id
     AND b.streak_id = a.streak_id
     AND a.pos > k.cycle_length
     AND b.pos = a.pos - k.cycle_length
    WHERE a.subject = b.subject
    GROUP BY a.student_id, a.streak_id
),
cte8 AS (
    SELECT student_id
    FROM cte5
    GROUP BY student_id
    HAVING COUNT(DISTINCT streak_id) = 1
)
SELECT c6.student_id,
       s.student_name,
       s.major,
       c6.cycle_length,
       SUM(c5.hours_studied) AS total_study_hours
FROM cte6 c6
JOIN cte5 c5
  ON c6.student_id = c5.student_id
 AND c6.streak_id = c5.streak_id
JOIN students s
  ON c6.student_id = s.student_id
JOIN cte7 m
  ON m.student_id = c6.student_id
 AND m.streak_id = c6.streak_id
JOIN cte8 n
  ON n.student_id = c6.student_id
GROUP BY c6.student_id, s.student_name, s.major, c6.cycle_length, c6.streak_id, m.matches
HAVING c6.cycle_length >= 3
   AND COUNT(*) >= 2 * c6.cycle_length
   AND COUNT(*) % c6.cycle_length = 0
   AND COUNT(DISTINCT c5.subject) = c6.cycle_length
   AND m.matches = COUNT(*) - c6.cycle_length
ORDER BY c6.cycle_length DESC, total_study_hours DESC;
```
