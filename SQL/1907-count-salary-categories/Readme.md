# 1907. Count Salary Categories

![Difficulty](https://img.shields.io/badge/Difficulty-Medium-orange)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-brightgreen)

**Concepts:** UNION ALL · Subquery · COUNT() · Literal Columns · WHERE

---

## ✅ Problem Summary
- Return the number of accounts in each of 3 salary categories: Low (<20000), Average (20000–50000 inclusive), High (>50000)
- Every category must appear in the output, even with a count of 0
- Two columns: `category`, `accounts_count`

---

## 🧩 Solution
```sql
(SELECT 'Low Salary' as category, COUNT(*) as accounts_count FROM Accounts WHERE income < 20000)
UNION ALL
(SELECT 'Average Salary' as category, COUNT(*) as accounts_count FROM Accounts WHERE income >= 20000 AND income <= 50000)
UNION ALL
(SELECT 'High Salary' as category, COUNT(*) as accounts_count FROM Accounts WHERE income > 50000)
ORDER BY accounts_count DESC;
```

---

## 🔍 Breakdown

| Clause | Purpose |
|---|---|
| `SELECT 'Low Salary' as category` | Hand-typed literal label — guarantees the row exists regardless of data |
| `(SELECT COUNT(*) FROM Accounts WHERE income < 20000)` | Independent count scoped to just this category's range |
| `UNION ALL` | Stacks the three independent single-row results into one result set, keeping duplicates (e.g. equal counts) |
| Repeated per category | Same shape, three times, each with its own literal label and its own WHERE condition |

---

## 🤔 Why UNION ALL?
The output needs a fixed set of 3 rows that always exist, independent of whether matching data exists in `Accounts`. Each `SELECT` block is self-contained — one literal label, one count — so a category with zero matches still produces a row (with `accounts_count = 0`), because the row was authored directly rather than derived from grouped data.
Category rows (authored) Accounts table (queried per row)
┌────────────────┐ ┌────────────┬────────┐
│ Low Salary │──counts──▶│ account_id │ income │
│ Average Salary │──counts──▶│ ... │ ... │
│ High Salary │──counts──▶│ │ │
└────────────────┘ └────────────┴────────┘


Sample result:

| category       | accounts_count |
|----------------|-----------------|
| Low Salary     | 1               |
| Average Salary | 0               |
| High Salary    | 3               |

---

## ⚠️ Why not CASE + GROUP BY?
```sql
SELECT CASE WHEN income < 20000 THEN 'Low Salary'
            WHEN income BETWEEN 20000 AND 50000 THEN 'Average Salary'
            ELSE 'High Salary' END as category,
       COUNT(*) as accounts_count
FROM Accounts
GROUP BY category;
```
This looks simpler, but `GROUP BY` can only produce a row for a group that has at least one matching account. If zero accounts fall into "Average Salary," CASE never generates that label, so GROUP BY has nothing to group — the row disappears entirely instead of showing 0.

---

## 🧠 Common Mistakes

**Mistake 1: Filtering inside COUNT()**
```sql
COUNT(income WHERE income < 20000)  -- invalid, WHERE can't sit inside a function call
```
Fix: `WHERE` belongs to the query (`FROM ... WHERE ...`), not inside `COUNT()`.

**Mistake 2: Double-aliasing / misplaced alias**
```sql
(SELECT COUNT(*) FROM Accounts WHERE income < 20000) as 'Low Salary' as category
```
Fix: An expression can only take one alias, and it must sit inside the SELECT list before the closing parenthesis — not after it.

**Mistake 3: Missing comma between selected items**
```sql
SELECT 'Low Salary' COUNT(*) FROM Accounts WHERE income < 20000
```
Fix: `SELECT 'Low Salary', COUNT(*) FROM ...` — two separate items need a comma between them.

**Mistake 4: Using UNION instead of UNION ALL**
Plain `UNION` deduplicates rows. If two categories happen to have the same count, one row could be silently dropped. `UNION ALL` preserves all three rows regardless of matching values.

---

## ⏱ Time Complexity
O(n) — three independent full scans of `Accounts` (one per WHERE condition), each on a single unindexed numeric comparison.

---

## 🔑 Key Learnings
- `GROUP BY` can only summarize groups that already exist in the data — it can't invent an empty group.
- Literal values in a SELECT list (e.g. `'Low Salary'`) create rows that are independent of the underlying table's contents.
- `UNION ALL` combines independent SELECTs into one result set without deduplication; plain `UNION` can silently drop legitimate duplicate rows.
- An alias must attach to something in the SELECT list — never to a `WHERE` condition or after a closing parenthesis.

---

## 🎯 Final Query
```sql
(SELECT 'Low Salary' as category, COUNT(*) as accounts_count FROM Accounts WHERE income < 20000)
UNION ALL
(SELECT 'Average Salary' as category, COUNT(*) as accounts_count FROM Accounts WHERE income >= 20000 AND income <= 50000)
UNION ALL
(SELECT 'High Salary' as category, COUNT(*) as accounts_count FROM Accounts WHERE income > 50000)
ORDER BY accounts_count DESC;
```

