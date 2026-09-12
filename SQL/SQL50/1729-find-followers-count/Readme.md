# 1729. Find Followers Count
![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen) ![Topic](https://img.shields.io/badge/Topic-SQL-blue) ![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** SELECT · GROUP BY · COUNT · ORDER BY

---

### ✅ Problem Summary
- Return, for every `user_id`, the count of their followers
- Column names: `user_id`, `followers_count`
- Result ordered by `user_id` ascending

---

### 🧩 Solution
```sql
SELECT user_id, COUNT(follower_id) AS followers_count
FROM Followers
GROUP BY user_id
ORDER BY user_id ASC;
```

---

### 🔍 Breakdown

| Clause | What it does |
|---|---|
| `SELECT user_id, COUNT(follower_id)` | Picks the user and counts how many follower rows are tied to them |
| `AS followers_count` | Renames the count column to match the required output |
| `FROM Followers` | Single source table — no join needed |
| `GROUP BY user_id` | Collapses all rows for the same user into one row |
| `ORDER BY user_id ASC` | Sorts the final result by user_id |

---

### 🤔 Why GROUP BY?
This problem only involves one table, so there's no join — just an aggregation. Each row in `Followers` is one (user, follower) pair, and `GROUP BY user_id` buckets all the follower rows belonging to the same user together so `COUNT()` can tally them.

```
Followers table                 Grouped by user_id
+---------+-------------+       +---------+----------+
| user_id | follower_id |       | user_id | follower  |
+---------+-------------+       |         | rows      |
|    0    |      1      |  -->  |    0    | [1]       |
|    1    |      0      |       |    1    | [0]       |
|    2    |      0      |       |    2    | [0, 1]    |
|    2    |      1      |       +---------+----------+
+---------+-------------+
```

Sample result:

| user_id | followers_count |
|---|---|
| 0 | 1 |
| 1 | 1 |
| 2 | 2 |

---

### ⚖️ Why not COUNT(*)?
`COUNT(*)` would also work here since `(user_id, follower_id)` is the primary key — there are no duplicate rows and `follower_id` is never NULL, so both counts agree. `COUNT(follower_id)` is the more defensive habit though: it explicitly counts non-NULL values in that column, so it stays correct even if the schema ever allowed NULL followers, whereas `COUNT(*)` just counts rows regardless.

---

### ⚠️ Common Mistakes

**Forgetting `GROUP BY`**
```sql
-- Wrong: aggregates the whole table into a single row
SELECT user_id, COUNT(follower_id) AS followers_count
FROM Followers;
```
Fix: add `GROUP BY user_id` so the count is computed per user, not across the entire table.

**Ordering by the wrong column**
```sql
-- Wrong: sorts by count instead of user_id
ORDER BY followers_count ASC;
```
Fix: the problem asks for ordering by `user_id`, not by the aggregated count.

---

### ⏱️ Time Complexity
O(n log n) — a full scan of the table plus a sort for grouping/ordering (assuming no index on `user_id`; with the primary key index, grouping is closer to O(n)).

---

### 🔑 Key Learnings
- `GROUP BY` is the natural fit whenever "for each X, count/sum Y" shows up in a problem
- `COUNT(column)` vs `COUNT(*)` rarely differs in practice, but `COUNT(column)` is the safer default when NULLs could exist
- `ORDER BY` should target whatever column the problem explicitly asks to sort on — not the aggregate you just computed

---

### 🧠 Final Query
```sql
SELECT user_id, COUNT(follower_id) AS followers_count
FROM Followers
GROUP BY user_id
ORDER BY user_id ASC;
```
