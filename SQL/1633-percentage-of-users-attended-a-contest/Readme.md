# 1633. Percentage of Users Attended a Contest

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** JOIN · COUNT · GROUP BY · Subquery (Scalar) · ROUND · Multi-Column ORDER BY

---

## ✅ Problem Summary
- For each contest, find what percentage of *all* users registered
- Round the percentage to 2 decimal places
- Sort by percentage descending
- On a tie, sort by contest_id ascending

---

## 🧩 Solution

```sql
SELECT 
    r.contest_id,
    ROUND((COUNT(u.user_id) / (SELECT COUNT(*) FROM Users)) * 100, 2) AS percentage
FROM Users AS u
JOIN Register AS r
    ON u.user_id = r.user_id
GROUP BY r.contest_id
ORDER BY percentage DESC, r.contest_id ASC;
```

---

## 🔍 Breakdown

| Clause | Purpose |
|---|---|
| `JOIN Register ON u.user_id = r.user_id` | Connects each registration to the user who made it |
| `COUNT(u.user_id)` | Counts how many users registered for the current contest group |
| `(SELECT COUNT(*) FROM Users)` | Independent subquery — total number of users, unaffected by grouping |
| `ROUND(... * 100, 2)` | Converts the ratio to a percentage, rounded to 2 decimals |
| `GROUP BY r.contest_id` | Groups registrations per contest so COUNT is scoped per contest |
| `ORDER BY percentage DESC, r.contest_id ASC` | Sorts by percentage first; ties broken by contest_id ascending |

---

## 🤔 Why a Scalar Subquery?

The denominator needs the **total row count of `Users`**, completely independent of `GROUP BY r.contest_id`. Any aggregate written directly in the outer SELECT is scoped to *only the current group* — so a plain `COUNT(*)` there would just re-count users within that one contest, not all users.

A subquery `(SELECT COUNT(*) FROM Users)` executes on its own, with no join and no grouping, returning a single fixed number. Because it's a single value, it can be dropped straight into the arithmetic expression as a constant — applied identically to every output row.

```
Users              Register
+---------+   join  +------------+---------+
| user_id | ------- | contest_id | user_id |
+---------+         +------------+---------+
```

Sample result:

| contest_id | percentage |
|---|---|
| 208 | 100.0 |
| 209 | 100.0 |
| 210 | 100.0 |
| 215 | 66.67 |
| 207 | 33.33 |

---

## ⚠️ Why Not a Second GROUP BY / Separate Query?

You could compute total users in a completely separate `SELECT COUNT(*) FROM Users` query and hardcode/join the result manually — but that breaks the single-query requirement and isn't dynamic (it wouldn't update if Users changes). A scalar subquery keeps everything in one self-contained, reusable statement.

---

## 🐞 Common Mistakes

**Mistake: Summing IDs instead of counting rows**
```sql
-- Wrong: user_id is an identifier, not a quantity
u.user_id / SUM(u.user_id)
```
**Fix:**
```sql
COUNT(u.user_id) / (SELECT COUNT(*) FROM Users)
```

**Mistake: Using COUNT(*) directly in the grouped SELECT for the total**
```sql
-- Wrong: this is scoped to the current group, not all users
COUNT(u.user_id) / COUNT(*)
```
**Fix:** Use an independent scalar subquery for the denominator.

**Mistake: Forgetting the tie-breaker**
```sql
-- Incomplete: ties aren't resolved deterministically
ORDER BY percentage DESC;
```
**Fix:**
```sql
ORDER BY percentage DESC, contest_id ASC;
```

---

## ⏱️ Time Complexity
O(n log n) — dominated by the join, grouping, and final sort over `Register` rows.

---

## 🔑 Key Learnings
- Aggregates in a grouped SELECT are always scoped to their group — there's no way around that except stepping outside the grouping entirely
- A scalar subquery is how you compute a value independent of the outer query's GROUP BY
- `ORDER BY col1 DESC, col2 ASC` applies the second key only where the first key ties — no manual condition needed

---

## 🧮 Final Query

```sql
SELECT 
    r.contest_id,
    ROUND((COUNT(u.user_id) / (SELECT COUNT(*) FROM Users)) * 100, 2) AS percentage
FROM Users AS u
JOIN Register AS r
    ON u.user_id = r.user_id
GROUP BY r.contest_id
ORDER BY percentage DESC, r.contest_id ASC;
```



