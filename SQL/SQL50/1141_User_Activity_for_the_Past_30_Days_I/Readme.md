# 1141. User Activity for the Past 30 Days I

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-green)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-brightgreen)

**Concepts:** `SELECT` · `WHERE` · `BETWEEN` · `IN` · `COUNT(DISTINCT)` · `GROUP BY`

---

## ✅ Problem Summary

- Find the daily active user count for the 30-day period ending `2019-07-27` (inclusive)
- A user counts as active on a day if they logged **at least one** valid activity that day
- Valid activity types: `open_session`, `end_session`, `scroll_down`, `send_message`
- Return one row per day that has at least one active user — skip days with zero activity
- Output columns: `day`, `active_users`

---

## 🧠 Solution

```sql
select activity_date as day, count(distinct user_id) as active_users
from Activity
where activity_type in ('open_session', 'end_session', 'scroll_down', 'send_message')
  and activity_date between '2019-06-28' and '2019-07-27'
group by day;
```

---

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `where activity_type in (...)` | Restricts rows to the four valid activity types (redundant here since the column is an ENUM of exactly those values, but makes the filter explicit and self-documenting) |
| `and activity_date between '2019-06-28' and '2019-07-27'` | Limits rows to the 30-day window ending 2019-07-27 inclusive |
| `count(distinct user_id)` | Counts each user once per day, even if they have multiple activity rows that day |
| `group by day` | Collapses rows into one per calendar day |

---

## 🤔 Why `COUNT(DISTINCT)` + `GROUP BY`?

The `Activity` table can have multiple rows per user per day (one row per activity, e.g. `open_session`, `scroll_down`, `end_session` all on the same date). Grouping by day and counting **distinct** `user_id` values collapses those duplicates so each user is only counted once per day.

```
Activity
 ├─ user_id  ──┐
 ├─ session_id │  (many rows can share the same user_id + activity_date)
 ├─ activity_date
 └─ activity_type
```

Sample result:

| day | active_users |
|---|---|
| 2019-07-20 | 2 |
| 2019-07-21 | 2 |

---

## 🔍 Why not a subquery per day?

An alternative is to generate a calendar of the 30 days and, for each one, run a correlated subquery counting distinct users active that day. That works but is unnecessary here — a single `GROUP BY` over the filtered rows does the same job in one pass, is simpler to read, and avoids row-by-row subquery evaluation. A generated date range only becomes necessary if the problem required showing days with **zero** active users, which this one explicitly does not.

---

## ⚠️ Common Mistakes

**Forgetting `DISTINCT` in the count:**
```sql
-- Wrong: overcounts users with multiple activities on the same day
count(user_id) as active_users
```
```sql
-- Fix: count each user once per day
count(distinct user_id) as active_users
```

**Using `>=` / `<=` instead of `BETWEEN`, or getting the window backwards:**
```sql
-- Wrong direction — this reads *after* July 27, not the 30 days ending on it
where activity_date between '2019-07-27' and '2019-08-26'
```
```sql
-- Fix: 30 days ending 2019-07-27 inclusive starts on 2019-06-28
where activity_date between '2019-06-28' and '2019-07-27'
```

---

## ⏱️ Time Complexity

O(n) — a single scan of the filtered rows plus a group/aggregate pass, where n is the number of rows in the date range.

---

## 🔑 Key Learnings

- `COUNT(DISTINCT col)` is the standard way to dedupe within a `GROUP BY` when the grain of the table is finer than what you want to report on
- `BETWEEN` is inclusive on both ends — double-check the 30-day math (end date minus 29 days = start date) rather than assuming
- Filtering on an `ENUM` column with `IN` is often redundant validation, but it's cheap and keeps the query readable/self-documenting

---

## 🧾 Final Query

```sql
select activity_date as day, count(distinct user_id) as active_users
from Activity
where activity_type in ('open_session', 'end_session', 'scroll_down', 'send_message')
  and activity_date between '2019-06-28' and '2019-07-27'
group by day;
```
