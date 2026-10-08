# 1890. The Latest Login in 2020

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** `MAX()` · `GROUP BY` · `WHERE` · `Half-Open Range` · `DATETIME`

---

## ✅ Problem Summary

- Report the **latest login** per user, **only within the year 2020**
- Users with **no logins in 2020** must not appear
- Output columns: `user_id`, `last_stamp`
- Rows can be returned in any order

---

## 🧩 Solution

```sql
select user_id, max(time_stamp) as last_stamp
from Logins
where time_stamp >= '2020-01-01' and time_stamp < '2021-01-01'
group by user_id;
```

---

## 🔍 Breakdown

| Clause | What it does |
|---|---|
| `where time_stamp >= '2020-01-01' and time_stamp < '2021-01-01'` | Keeps only logins that fall inside 2020 |
| `group by user_id` | Collapses all remaining logins into one group per user |
| `max(time_stamp)` | Picks the latest login in each group |
| `as last_stamp` | Names the output column as required |

Users with no 2020 logins are removed by `WHERE` before grouping, so they never form a group.

---

## 🤔 Why a half-open range?

`time_stamp` is a `DATETIME`, so "during 2020" means from the first instant of 2020 up to, but not including, the first instant of 2021.

```
 2020-01-01 00:00:00                         2021-01-01 00:00:00
        [=========== 2020 ===========)
   inclusive (>=)                          exclusive (<)
```

Sample (user 8 has two 2020 logins, user 6 has one):

| user_id | last_stamp |
|---|---|
| 6 | 2020-06-30 15:06:07 |
| 8 | 2020-12-30 00:46:50 |
| 2 | 2020-01-16 02:49:50 |

---

## 🚫 Why not `YEAR(time_stamp) = 2020`?

Both return the same rows, but `YEAR()` wraps the column in a function. MySQL then has to compute `YEAR()` for every row, so an index on `time_stamp` can't be used. The bare-column range lets MySQL jump straight to the matching rows through the index.

---

## ⚠️ Common Mistakes

**1. Using `MIN` instead of `MAX`**
```sql
select user_id, min(time_stamp) as last_stamp   -- ❌ earliest login
```
Fix: use `max()` for the latest login.

**2. Ending the range at `'2020-12-31'`**
```sql
where time_stamp <= '2020-12-31'   -- ❌ means 2020-12-31 00:00:00
```
A login at `2020-12-31 15:30:00` is dropped. Fix: `time_stamp < '2021-01-01'`.

**3. Hard-coding `'2020-12-31 23:59:59'`**
Breaks if the column stores fractional seconds (23:59:59.5 slips through).

---

## ⏱️ Time Complexity

- Without an index: O(n) full scan
- With an index on `time_stamp`: the range filter avoids scanning rows outside 2020, then grouping runs on the matching rows only

---

## 🔑 Key Learnings

- `MAX()` with `GROUP BY` gives the latest value per group
- `DATETIME` boundaries need care: a bare date means midnight
- Prefer a half-open range (`>= start`, `< next start`) for date filters
- Avoid wrapping indexed columns in functions inside `WHERE`

---

## 🏁 Final Query

```sql
select user_id, max(time_stamp) as last_stamp
from Logins
where time_stamp >= '2020-01-01' and time_stamp < '2021-01-01'
group by user_id;
```
