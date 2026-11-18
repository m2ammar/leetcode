# 🧟 3673. Find Zombie Sessions

![Difficulty](https://img.shields.io/badge/Difficulty-Hard-red)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-brightgreen)

**Concepts:** `CTE` · `GROUP BY` · `Conditional Aggregation` · `CASE WHEN` · `TIMESTAMPDIFF` · `MIN / MAX` · `WHERE` · `ORDER BY`

---

## ✅ Problem Summary

Find "zombie sessions" in `app_events`. A session qualifies only if it meets **all** of these:

- ✅ Duration is **more than 30 minutes**
- ✅ At least **5 scroll** events
- ✅ Click-to-scroll ratio is **less than 0.20**
- ✅ **No purchases** during the session

Return `session_id`, `user_id`, `session_duration_minutes`, `scroll_count`, ordered by `scroll_count` DESC, then `session_id` ASC.

---

## 💡 Solution

```sql
WITH cte AS (
    SELECT session_id,
           user_id,
           TIMESTAMPDIFF(MINUTE, MIN(event_timestamp), MAX(event_timestamp)) AS duration_minutes,
           TIMESTAMPDIFF(SECOND, MIN(event_timestamp), MAX(event_timestamp)) AS duration_second,
           SUM(CASE WHEN event_type = 'scroll'   THEN 1 ELSE 0 END) AS scroll_count,
           SUM(CASE WHEN event_type = 'click'    THEN 1 ELSE 0 END) AS click_count,
           SUM(CASE WHEN event_type = 'purchase' THEN 1 ELSE 0 END) AS purchase_count
    FROM app_events
    GROUP BY session_id, user_id
)
SELECT session_id,
       user_id,
       duration_minutes AS session_duration_minutes,
       scroll_count
FROM cte
WHERE duration_second > 1800
      AND scroll_count >= 5
      AND click_count / scroll_count < 0.20
      AND purchase_count = 0
ORDER BY scroll_count DESC, session_id;
```

---

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `GROUP BY session_id, user_id` | Collapses all events into one row per session |
| `MIN/MAX(event_timestamp)` | Finds the first and last event of the session |
| `TIMESTAMPDIFF(SECOND, ...)` | Exact session length, used for the filter |
| `TIMESTAMPDIFF(MINUTE, ...)` | Whole minutes, used only for the output column |
| `SUM(CASE WHEN event_type = ... THEN 1 ELSE 0 END)` | Counts events of one type per session |
| `WHERE duration_second > 1800` | More than 30 minutes (30 × 60 seconds) |
| `click_count / scroll_count < 0.20` | Strictly less than 0.20 (exactly 0.20 is excluded) |
| `purchase_count = 0` | No purchases at all |
| `ORDER BY scroll_count DESC, session_id` | Required output ordering |

---

## 🤔 Why a CTE + Conditional Aggregation?

Every condition is a **per-session number**, so the plan is: compute the numbers first, filter second.

```
app_events (many rows per session)
        │  GROUP BY session_id
        ▼
cte (one row per session)
  duration | scrolls | clicks | purchases
        │  WHERE ...
        ▼
zombie sessions
```

| session_id | duration_second | scroll_count | click_count | purchase_count |
|---|---|---|---|---|
| S001 | 2100 | 6 | 0 | 0 |
| S003 | 3600 | 5 | 1 | 0 |

S001 passes everything. S003 fails because 1/5 = 0.20 is **not less than** 0.20.

---

## 🔄 Why not put everything in HAVING?

You can skip the CTE and filter with `HAVING` directly. It works, but repeating long `SUM(CASE ...)` expressions makes it hard to read. The CTE gives each number a name, so the final `WHERE` reads like the problem statement.

---

## ⚠️ Common Mistakes

**1. Filtering on truncated minutes**

```sql
WHERE duration_minutes > 30   -- ❌
```
`TIMESTAMPDIFF(MINUTE, ...)` rounds down. A session of 30 min 45 sec becomes `30`, and `30 > 30` is false, so it is wrongly rejected.

```sql
WHERE duration_second > 1800  -- ✅
```

**2. Ratio with no comparison**

```sql
AND click_count / scroll_count          -- ❌ only checks "is it nonzero?"
AND click_count / scroll_count < 0.20   -- ✅
```

**3. Selecting `user_id` without grouping by it**

```sql
GROUP BY session_id             -- ❌ errors under ONLY_FULL_GROUP_BY
GROUP BY session_id, user_id    -- ✅
```

---

## ⏱️ Time Complexity

`O(n)` for the single pass over `app_events` to group, plus `O(s log s)` to sort the `s` resulting sessions.

---

## 🧠 Key Learnings

- Hard problems are often several easy conditions stacked together, so break them into per-row numbers first.
- `SUM(CASE WHEN ... THEN 1 ELSE 0 END)` counts only the rows of one type.
- `TIMESTAMPDIFF` truncates, so filter on the smallest unit (seconds) and display the larger one.
- "Less than" and "more than" are strict, so watch the boundary cases (the 0.20 ratio in S003).
- `scroll_count >= 5` also protects the ratio from dividing by zero.

---

## 🏁 Final Query

```sql
WITH cte AS (
    SELECT session_id,
           user_id,
           TIMESTAMPDIFF(MINUTE, MIN(event_timestamp), MAX(event_timestamp)) AS duration_minutes,
           TIMESTAMPDIFF(SECOND, MIN(event_timestamp), MAX(event_timestamp)) AS duration_second,
           SUM(CASE WHEN event_type = 'scroll'   THEN 1 ELSE 0 END) AS scroll_count,
           SUM(CASE WHEN event_type = 'click'    THEN 1 ELSE 0 END) AS click_count,
           SUM(CASE WHEN event_type = 'purchase' THEN 1 ELSE 0 END) AS purchase_count
    FROM app_events
    GROUP BY session_id, user_id
)
SELECT session_id,
       user_id,
       duration_minutes AS session_duration_minutes,
       scroll_count
FROM cte
WHERE duration_second > 1800
      AND scroll_count >= 5
      AND click_count / scroll_count < 0.20
      AND purchase_count = 0
ORDER BY scroll_count DESC, session_id;
```
