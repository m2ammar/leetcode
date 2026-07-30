# 1934. Confirmation Rate
Difficulty: Medium
Concepts: LEFT JOIN · Subquery · GROUP BY · Conditional Aggregation · IFNULL · ROUND

## 📋 Problem Summary
For every user in `Signups`, find their confirmation rate:

confirmed requests / total requests (rounded to 2 decimal places)

- Users with no confirmation requests get a rate of `0`.
- Every user from `Signups` must appear in the result, even with zero activity.

## ✅ Solution
\`\`\`sql
SELECT s.user_id, IFNULL(a.rate, 0) AS confirmation_rate
FROM Signups AS s
LEFT JOIN
  ( SELECT user_id, ROUND((SUM(action = 'confirmed') / COUNT(*)), 2) AS rate
    FROM Confirmations
    GROUP BY user_id ) AS a
  ON a.user_id = s.user_id;
\`\`\`

## 🧩 Breakdown
| Clause | What it does |
|---|---|
| Subquery on `Confirmations` | Groups by `user_id`, computes each user's confirmation rate |
| `SUM(action = 'confirmed')` | Counts rows where action is `'confirmed'` (see below) |
| `COUNT(*)` | Total number of confirmation requests for that user |
| `LEFT JOIN` from `Signups` | Keeps every signed-up user, even with no confirmation rows |
| `IFNULL(a.rate, 0)` | Converts missing (NULL) rates into `0` |

## ⚠️ Understanding `SUM(action = 'confirmed')`
`action = 'confirmed'` is a **boolean expression**, not just a filter condition.
For every row it evaluates to:
- `1` if true
- `0` if false

This works regardless of how many *distinct* values the column has — it only asks
"does this row match this one value?", not "what are all possible values?"

So `SUM(action = 'confirmed')` adds up all the 1s and 0s across rows,
effectively **counting** how many rows had `action = 'confirmed'`.

This technique is called **conditional aggregation**. Other useful variations:
- `AVG(action = 'confirmed')` → gives the ratio directly, no need to divide by `COUNT(*)`
- `COUNT(CASE WHEN action = 'confirmed' THEN 1 END)` → more portable across SQL dialects (Postgres, SQL Server don't support boolean-as-integer directly)

## ❌ Common Mistakes
- Filtering `WHERE action = 'confirmed'` inside the subquery *before* aggregating.
  This throws away the `'timeout'` rows, making `COUNT(*)` only count confirmed rows too — rate always becomes 1.
- Using `JOIN` instead of `LEFT JOIN`.
  Drops users who never appear in `Confirmations` at all.
- Forgetting `IFNULL`.
  Users with no matches from the LEFT JOIN get `NULL` instead of `0`.
- Forgetting to alias the computed column in the subquery (e.g. `AS rate`).
  Without an alias, you can't reference it in the outer query.

## ⏱️ Time Complexity
O(n) — one pass to aggregate `Confirmations` by `user_id`, one pass to join with `Signups`.

## 🔑 Key Learnings
- Boolean expressions (`col = value`) evaluate to `1`/`0` in MySQL and can be used inside aggregate functions like `SUM()` or `AVG()` — not just inside `WHERE`.
- Aggregate *before* filtering out categories you still need in the denominator.
- `LEFT JOIN` + `IFNULL` is the standard pattern for "include everyone, default missing values to 0."
- SQL clauses execute in this logical order: `FROM/JOIN → WHERE → GROUP BY → HAVING → SELECT → ORDER BY` — which is why a column from `FROM/JOIN` (like `a.rate`) can be referenced in `SELECT`, even though `SELECT` is written first.
