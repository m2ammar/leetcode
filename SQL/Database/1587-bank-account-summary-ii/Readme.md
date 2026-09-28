# 1587. Bank Account Summary II

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** `JOIN` · `GROUP BY` · `SUM()` · `HAVING` · `WHERE vs HAVING`

---

## ✅ Problem Summary

- Report the `name` and `balance` of users
- Balance = sum of all transaction amounts for that account
- Only include users with a balance **higher than 10000**
- Return the result in any order

---

## 🧩 Solution

```sql
SELECT u.name, SUM(t.amount) AS balance
FROM Users AS u
JOIN Transactions AS t
    ON u.account = t.account
GROUP BY u.account
HAVING SUM(t.amount) > 10000;
```

---

## 🔍 Breakdown

| Clause | What it does |
|---|---|
| `FROM Users AS u` | Starts from the table that holds account holders' names |
| `JOIN Transactions AS t ON u.account = t.account` | Attaches every transaction to its owner |
| `GROUP BY u.account` | Collapses all of one user's transactions into a single group |
| `SUM(t.amount) AS balance` | Adds up each group's amounts to get the balance |
| `HAVING SUM(t.amount) > 10000` | Keeps only groups whose total exceeds 10000 |

---

## 🤔 Why JOIN + GROUP BY?

`Users` has the names, `Transactions` has the money. The shared column is `account`.

```
Users (account, name)  ──account──  Transactions (trans_id, account, amount, ...)
      1 user                              many transactions
```

Sample result after joining, before grouping:

| name | amount |
|---|---|
| Alice | 7000 |
| Alice | 7000 |
| Alice | -3000 |
| Bob | 1000 |

`GROUP BY` then turns Alice's three rows into one row with `SUM = 11000`.

---

## ⚖️ Why HAVING and not WHERE?

`WHERE` filters individual rows **before** grouping. At that point no sum exists yet, so `WHERE SUM(amount) > 10000` fails with *Invalid use of group function*.

| Clause | Runs | Filters | Can use aggregates? |
|---|---|---|---|
| `WHERE` | Before `GROUP BY` | Single rows | No |
| `HAVING` | After `GROUP BY` | Groups | Yes |

**Test:** can I decide if this row passes by looking at that row alone? Use `WHERE`. Do I need to combine rows first? Use `HAVING`.

---

## ⚠️ Common Mistakes

**1. Aggregate in WHERE**
```sql
WHERE SUM(t.amount) > 10000   -- ❌ Invalid use of group function
```
Fix: move it to `HAVING`.

**2. No GROUP BY**
```sql
SELECT u.name, SUM(t.amount) FROM ...   -- ❌ one total for the whole table
```
Fix: add `GROUP BY u.account` so the sum is computed per user.

**3. Grouping by a non-unique column**

Grouping by `name` would merge two different users who share a name. `account` is the primary key, so it is always safe.

---

## ⏱️ Time Complexity

`O(n + m)` for the join and grouping, where `n` = users and `m` = transactions (roughly, with hash join or indexed lookups).

---

## 🔑 Key Learnings

- `WHERE` = row-level filter, before grouping
- `HAVING` = group-level filter, after grouping
- Logical order: `FROM/JOIN → WHERE → GROUP BY → HAVING → SELECT`
- Group by the unique key (`account`), not the display column (`name`)
- Wording cues: "total / sum / average / more than N orders" usually means `HAVING`

---

## 🧾 Final Query

```sql
SELECT u.name, SUM(t.amount) AS balance
FROM Users AS u
JOIN Transactions AS t
    ON u.account = t.account
GROUP BY u.account
HAVING SUM(t.amount) > 10000;
```
