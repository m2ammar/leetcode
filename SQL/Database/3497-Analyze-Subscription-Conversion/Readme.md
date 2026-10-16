# 3497. Analyze Subscription Conversion

![Difficulty](https://img.shields.io/badge/Difficulty-Medium-orange)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-brightgreen)

**Concepts:** `GROUP BY` · `HAVING` · Conditional Aggregation · `AVG` · `ROUND` · `NULL` handling

---

## ✅ Problem Summary

From the `UserActivity` table, return only users who **converted from free trial to paid**, with:
- ✅ `trial_avg_duration`: average daily activity during the free trial (2 decimals)
- ✅ `paid_avg_duration`: average daily activity during the paid period (2 decimals)
- ✅ Sorted by `user_id` ascending

---

## 💡 Solution

```sql
SELECT user_id,
       ROUND(AVG(IF(activity_type = 'free_trial', activity_duration, NULL)), 2) AS trial_avg_duration,
       ROUND(AVG(IF(activity_type = 'paid', activity_duration, NULL)), 2) AS paid_avg_duration
FROM UserActivity
GROUP BY user_id
HAVING SUM(activity_type = 'paid') > 0
   AND SUM(activity_type = 'free_trial') > 0
ORDER BY user_id ASC;
```

---

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `GROUP BY user_id` | Collapses each user's rows into one group |
| `IF(activity_type = 'free_trial', activity_duration, NULL)` | Keeps the duration only for trial rows, `NULL` otherwise |
| `AVG(...)` | Ignores `NULL`, so only matching rows are averaged |
| `ROUND(..., 2)` | Formats to 2 decimal places |
| `SUM(activity_type = 'paid') > 0` | True if the user has at least one paid row |
| `SUM(activity_type = 'free_trial') > 0` | True if the user has at least one trial row |
| `ORDER BY user_id ASC` | Sorts the final output |

---

## 🤔 Why conditional aggregation?

One table holds both periods, and we need two different averages per user in one row.

```
UserActivity ──GROUP BY user_id──► one row per user
                                   ├─ AVG over trial rows only
                                   └─ AVG over paid rows only
```

| user_id | trial rows | paid rows | cancelled rows | Kept? |
|---|---|---|---|---|
| 1 | 3 | 3 | 0 | ✅ |
| 2 | 3 | 0 | 1 | ❌ never paid |
| 4 | 2 | 1 | 1 | ✅ converted, then cancelled |

---

## 🧩 Why not two subqueries / self-joins?

Filtering trial rows and paid rows separately and joining them back on `user_id` works, but it scans the table twice and is longer. Conditional aggregation does it in a single pass.

---

## ⚠️ Common Mistakes

**1. Using `0` instead of `NULL` in the `IF`**
```sql
AVG(IF(activity_type = 'free_trial', activity_duration, 0))  -- wrong
```
`0` is a real value, so it gets counted in the divisor and drags the average down. Use `NULL`, which `AVG` skips.

**2. Filtering with a bare column in `HAVING`**
```sql
HAVING activity_type = 'paid'  -- wrong
```
After `GROUP BY user_id`, `activity_type` has many values per group. Use an aggregate such as `SUM(activity_type = 'paid') > 0`.

**3. Checking only the paid side**
```sql
HAVING SUM(activity_type = 'paid') > 0  -- wrong, fails 11/12
```
A user with paid rows and no trial rows slips through with a `NULL` trial average. "Converted from trial" needs **both** conditions joined with `AND`.

---

## ⏱️ Time Complexity

**O(n)**: a single pass over the table, plus grouping and sorting by `user_id`.

---

## 🔑 Key Learnings

- `AVG` skips `NULL`, so `IF(cond, value, NULL)` gives a per-condition average.
- `WHERE` filters rows; `HAVING` filters groups.
- In MySQL, `activity_type = 'paid'` returns 1 or 0, so `SUM` of it counts matching rows.
- Read the problem wording closely: "converted **from free trial** to paid" means both sides must exist.

---

## ✅ Final Query

```sql
SELECT user_id,
       ROUND(AVG(IF(activity_type = 'free_trial', activity_duration, NULL)), 2) AS trial_avg_duration,
       ROUND(AVG(IF(activity_type = 'paid', activity_duration, NULL)), 2) AS paid_avg_duration
FROM UserActivity
GROUP BY user_id
HAVING SUM(activity_type = 'paid') > 0
   AND SUM(activity_type = 'free_trial') > 0
ORDER BY user_id ASC;
```
