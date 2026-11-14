# 3716. Find Churn Risk Customers

![Difficulty](https://img.shields.io/badge/Difficulty-Medium-orange)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-brightgreen)

**Concepts:** `CTE` · `ROW_NUMBER()` · `PARTITION BY` · `GROUP BY` · `CASE WHEN` · `DATEDIFF` · `JOIN`

---

## ✅ Problem Summary

Return every user who shows warning signs before churning. A user qualifies only if **all** of these hold:

- ✅ Currently active (their last event is not `cancel`)
- ✅ Has at least one `downgrade` in their history
- ✅ Current `monthly_amount` is strictly less than 50% of their historical maximum
- ✅ Subscriber for at least 60 days (first event date to last event date)

Output: `user_id`, `current_plan`, `current_monthly_amount`, `max_historical_amount`, `days_as_subscriber`, ordered by `days_as_subscriber DESC`, then `user_id ASC`.

---

## 🧩 Solution

```sql
# Write your MySQL query statement below
WITH cte1 AS (
    SELECT user_id,
        MAX(monthly_amount) AS max_amount,
        MIN(event_date) AS first_event_date,
        MAX(event_date) AS last_event_date,
        SUM(CASE WHEN event_type = 'downgrade' THEN 1 ELSE 0 END) AS downgrade_cnt
    FROM subscription_events
    GROUP BY user_id
),

cte2 AS (
    SELECT user_id,
        plan_name,
        monthly_amount,
        event_type,
        ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY event_date DESC, event_id DESC) AS t
    FROM subscription_events
)

SELECT c1.user_id,
    c2.plan_name AS current_plan,
    c2.monthly_amount AS current_monthly_amount,
    c1.max_amount AS max_historical_amount,
    DATEDIFF(c1.last_event_date, c1.first_event_date) AS days_as_subscriber
FROM cte1 AS c1
JOIN cte2 AS c2
    ON c1.user_id = c2.user_id
WHERE c2.event_type != 'cancel'
    AND c2.t = 1
    AND c1.downgrade_cnt >= 1
    AND c2.monthly_amount < (c1.max_amount * 0.5)
    AND DATEDIFF(c1.last_event_date, c1.first_event_date) >= 60
ORDER BY days_as_subscriber DESC, c1.user_id ASC;
```

---

## 🔍 Breakdown

| Clause | What it does |
|---|---|
| `cte1` + `GROUP BY user_id` | Builds per-user history stats: max amount, first/last event date, downgrade count |
| `SUM(CASE WHEN ... 'downgrade')` | Counts downgrades per user (a flag for "has any downgrade") |
| `cte2` + `ROW_NUMBER() ... DESC` | Ranks each user's events newest-first so the latest event gets `t = 1` |
| `event_date DESC, event_id DESC` | Tiebreaker: if two events share a date, the higher `event_id` counts as later |
| `JOIN ... ON user_id` | Combines history stats (cte1) with the current state (cte2) |
| `c2.t = 1` | Keeps only each user's latest event |
| `c2.event_type != 'cancel'` | Active means the last event is not a cancel |
| `downgrade_cnt >= 1` | At least one downgrade in history |
| `monthly_amount < max_amount * 0.5` | Strictly under 50% of peak revenue, with no division |
| `DATEDIFF(...) >= 60` | At least 60 days between first and last event |

---

## 🤔 Why two CTEs?

The problem mixes two kinds of information:

- **Whole-history stats** (max amount, first date, downgrade count) need `GROUP BY`
- **One specific row** (the latest event's plan and amount) needs row ranking

These can't be done in one pass, because `GROUP BY` collapses rows before a window function can rank them. So each gets its own layer, and they're joined on the shared column.

```
subscription_events
   │
   ├── GROUP BY user_id ───────► cte1: one row per user (history stats)
   │                                   │
   └── ROW_NUMBER() per user ──► cte2: latest event = t = 1
                                       │
                         JOIN ON user_id ──► filter ──► result
```

Sample for user 501:

| user_id | max_amount | downgrade_cnt | latest event | current amount | days |
|---|---|---|---|---|---|
| 501 | 29.99 | 2 | downgrade → basic | 9.99 | 79 |

---

## ⚖️ Why not a self-join on `MAX(event_date)`?

You could find the latest event by joining each user back to their `MAX(event_date)`. It works until two events share the same date for one user, which returns both rows and breaks the "current state" logic. `ROW_NUMBER()` with an `event_id` tiebreaker always returns exactly one row per user, so the result is deterministic.

---

## ⚠️ Common Mistakes

**1. Filtering on a window function in `HAVING`/`WHERE`**
```sql
-- Wrong: window functions can't be filtered at the level they're computed
SELECT ..., ROW_NUMBER() OVER (...) AS rn FROM t GROUP BY user_id HAVING rn = 1;
```
Fix: compute `ROW_NUMBER()` in a CTE (no `GROUP BY`), then filter `t = 1` in the outer query.

**2. Checking the wrong column for "active"**
```sql
-- Wrong: event_type is never NULL, so this filters nothing (cancel users slip through)
WHERE c2.event_type IS NOT NULL
```
Fix: `WHERE c2.event_type != 'cancel'`. The NULL in the schema belongs to `plan_name`, not `event_type`.

**3. A weak 50% check**
```sql
-- Wrong: true for any single downgrade
AND c2.monthly_amount < c1.max_amount
```
Fix: `c2.monthly_amount < c1.max_amount * 0.5`

**4. Using `COUNT` for days**
```sql
-- Wrong: counts rows, not days (and needs a GROUP BY)
COUNT(c2.t) AS days_as_subscriber
```
Fix: `DATEDIFF(last_event_date, first_event_date)`

---

## ⏱️ Time Complexity

**O(n log n)**: one pass for `GROUP BY`, plus sorting within each partition for `ROW_NUMBER()`.

---

## 🔑 Key Learnings

- Layer your query when a problem mixes whole-history aggregates with one specific row
- Window functions can't be filtered in the same layer they're computed
- Always add a unique tiebreaker (`event_id`) to window `ORDER BY` for deterministic results
- Compare ratios by multiplying (`a < b * 0.5`) instead of dividing, and use strict `<` when the requirement says "less than"
- Read schema notes carefully: `NULL` was in `plan_name`, not `event_type`
- Aliases defined in `SELECT` aren't available in `WHERE`; repeat the expression or compute it in an earlier CTE

---

## 🏁 Final Query

```sql
WITH cte1 AS (
    SELECT user_id,
        MAX(monthly_amount) AS max_amount,
        MIN(event_date) AS first_event_date,
        MAX(event_date) AS last_event_date,
        SUM(CASE WHEN event_type = 'downgrade' THEN 1 ELSE 0 END) AS downgrade_cnt
    FROM subscription_events
    GROUP BY user_id
),

cte2 AS (
    SELECT user_id,
        plan_name,
        monthly_amount,
        event_type,
        ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY event_date DESC, event_id DESC) AS t
    FROM subscription_events
)

SELECT c1.user_id,
    c2.plan_name AS current_plan,
    c2.monthly_amount AS current_monthly_amount,
    c1.max_amount AS max_historical_amount,
    DATEDIFF(c1.last_event_date, c1.first_event_date) AS days_as_subscriber
FROM cte1 AS c1
JOIN cte2 AS c2
    ON c1.user_id = c2.user_id
WHERE c2.event_type != 'cancel'
    AND c2.t = 1
    AND c1.downgrade_cnt >= 1
    AND c2.monthly_amount < (c1.max_amount * 0.5)
    AND DATEDIFF(c1.last_event_date, c1.first_event_date) >= 60
ORDER BY days_as_subscriber DESC, c1.user_id ASC;
```
