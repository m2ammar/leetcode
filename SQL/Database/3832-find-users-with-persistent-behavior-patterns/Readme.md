# 3832. Find Users with Persistent Behavior Patterns

![Difficulty](https://img.shields.io/badge/Difficulty-Hard-red)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-brightgreen)

**Concepts:** `CTE` · `ROW_NUMBER()` · `DATE_SUB` · `Gaps and Islands` · `GROUP BY` · `HAVING` · `Window Functions`

---

## ✅ Problem Summary

Find users who are **behaviorally stable**:

- ✅ At least **5 consecutive days** in a row
- ✅ **Exactly one action** per day during the streak
- ✅ The **same action** on every day of the streak
- ✅ If a user has several streaks, keep only one: longest first, then lexicographically smallest action, then latest start date
- ✅ Return `user_id`, `action`, `streak_length`, `start_date`, `end_date`, ordered by `streak_length DESC`, then `user_id ASC`

---

## 💡 Solution

```sql
WITH cte1 AS (
    SELECT user_id,
           action_date,
           MIN(action) AS action,
           ROW_NUMBER() OVER (PARTITION BY user_id, action ORDER BY action_date) AS cnt
    FROM activity
    GROUP BY user_id, action_date
    HAVING COUNT(*) = 1
),

cte2 AS (
    SELECT user_id,
           action_date,
           action,
           cnt,
           DATE_SUB(action_date, INTERVAL cnt DAY) AS grp
    FROM cte1
),

cte3 AS (
    SELECT user_id,
           action,
           COUNT(*) AS streak_length,
           MIN(action_date) AS start_date,
           MAX(action_date) AS end_date
    FROM cte2
    GROUP BY user_id, action, grp
    HAVING COUNT(*) >= 5
),

cte4 AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY user_id
               ORDER BY streak_length DESC, action ASC, start_date DESC
           ) AS rn
    FROM cte3
)

SELECT user_id, action, streak_length, start_date, end_date
FROM cte4
WHERE rn = 1
ORDER BY streak_length DESC, user_id ASC;
```

---

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `cte1`: `GROUP BY user_id, action_date HAVING COUNT(*) = 1` | Keeps only days where the user did exactly one action |
| `cte1`: `ROW_NUMBER() ... PARTITION BY user_id, action` | Numbers each user's clean days per action, in date order |
| `cte2`: `DATE_SUB(action_date, INTERVAL cnt DAY)` | Creates a streak ID (`grp`) that stays constant across consecutive dates |
| `cte3`: `GROUP BY user_id, action, grp` | Collapses each streak into one row |
| `cte3`: `HAVING COUNT(*) >= 5` | Keeps only streaks of at least 5 days |
| `cte4`: `ROW_NUMBER() ... ORDER BY streak_length DESC, action ASC, start_date DESC` | Ranks each user's streaks using the problem's tie-break rules |
| `WHERE rn = 1` | Keeps the single best streak per user |

---

## 🤔 Why Gaps and Islands?

Consecutive dates minus an increasing row number gives a **constant value**. A gap makes that value jump.

| action_date | cnt | action_date − cnt (grp) |
|---|---|---|
| 2024-01-01 | 1 | 2023-12-31 |
| 2024-01-02 | 2 | 2023-12-31 |
| 2024-01-03 | 3 | 2023-12-31 |
| 2024-01-05 | 4 | 2024-01-01 ← jump (gap) |
| 2024-01-06 | 5 | 2024-01-01 |

Rows that share a `grp` form one unbroken streak, so no self-join or loop is needed. Partitioning by `action` as well means a change of action also starts a new streak.

---

## 🚫 Why not a self-join or recursive CTE?

- A self-join comparing each date to the next one only finds *pairs*, not run lengths.
- A recursive CTE can walk the streaks, but it is longer, slower, and harder to read.
- Gaps and Islands solves it in one pass with window functions.

---

## ⚠️ Common Mistakes

**1. Forgetting that a multi-action day breaks the streak**
```sql
-- ❌ Counts days with 2+ actions as part of a streak
SELECT user_id, action_date, action FROM activity
```
```sql
-- ✅ Filter to exactly one action per day first
GROUP BY user_id, action_date HAVING COUNT(*) = 1
```

**2. Partitioning `ROW_NUMBER()` by user only**
```sql
-- ❌ Numbers run across different actions, so streaks of one action get split up
ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY action_date)
```
```sql
-- ✅ Partition by action too
ROW_NUMBER() OVER (PARTITION BY user_id, action ORDER BY action_date)
```

**3. Getting the tie-break order wrong**
```sql
-- ❌ start_date ASC picks the earliest start
ORDER BY streak_length DESC, action ASC, start_date ASC
```
```sql
-- ✅ The problem wants the LATEST start date
ORDER BY streak_length DESC, action ASC, start_date DESC
```

---

## ⏱️ Time Complexity

**O(N log N)**, dominated by the sorting done for the window functions and the `GROUP BY`.

---

## 🧠 Key Learnings

- Gaps and Islands = `date − ROW_NUMBER()` as a streak ID
- Filter out invalid days *before* numbering, because the numbering assumes the remaining days are consecutive
- Partition the row numbers by every attribute that must stay the same within a streak
- `ROW_NUMBER() ... WHERE rn = 1` is the standard way to pick one best row per group with custom tie-breaks
- Read tie-break wording carefully (smallest action, latest start date)

---

## 🏁 Final Query

```sql
WITH cte1 AS (
    SELECT user_id,
           action_date,
           MIN(action) AS action,
           ROW_NUMBER() OVER (PARTITION BY user_id, action ORDER BY action_date) AS cnt
    FROM activity
    GROUP BY user_id, action_date
    HAVING COUNT(*) = 1
),

cte2 AS (
    SELECT user_id,
           action_date,
           action,
           cnt,
           DATE_SUB(action_date, INTERVAL cnt DAY) AS grp
    FROM cte1
),

cte3 AS (
    SELECT user_id,
           action,
           COUNT(*) AS streak_length,
           MIN(action_date) AS start_date,
           MAX(action_date) AS end_date
    FROM cte2
    GROUP BY user_id, action, grp
    HAVING COUNT(*) >= 5
),

cte4 AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY user_id
               ORDER BY streak_length DESC, action ASC, start_date DESC
           ) AS rn
    FROM cte3
)

SELECT user_id, action, streak_length, start_date, end_date
FROM cte4
WHERE rn = 1
ORDER BY streak_length DESC, user_id ASC;
```
