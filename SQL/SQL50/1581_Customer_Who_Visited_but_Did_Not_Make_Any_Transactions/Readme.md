# 1581. Customer Who Visited but Did Not Make Any Transactions

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** `LEFT JOIN` · `IS NULL` · `GROUP BY` · `COUNT()`

---

## 📋 Problem Summary

Table `Visits` logs mall visits. Table `Transactions` logs transactions tied to a `visit_id` (a visit can have zero, one, or many transactions).

Find every `customer_id` who had at least one visit with **no transaction**, and count how many such no-transaction visits they made.

---

## ✅ Solution

```sql
SELECT v.customer_id,
       COUNT(v.visit_id) AS count_no_trans
FROM Visits AS v
LEFT JOIN Transactions AS t
  ON v.visit_id = t.visit_id
WHERE t.transaction_id IS NULL
GROUP BY v.customer_id;
```

---

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `LEFT JOIN Transactions AS t ON v.visit_id = t.visit_id` | Keeps every visit, even ones with no matching transaction row |
| `WHERE t.transaction_id IS NULL` | Filters down to visits that had *no* matching transaction (the "anti-join") |
| `GROUP BY v.customer_id` | Collapses each customer's no-transaction visits into one row |
| `COUNT(v.visit_id)` | Counts how many no-transaction visits that customer had |

---

## ⚠️ Why LEFT JOIN (not INNER JOIN)

An `INNER JOIN` only keeps rows that match in **both** tables — so visits with no transaction would vanish before the `WHERE` clause ever runs, making it impossible to detect "no transaction happened." `LEFT JOIN` keeps every row from `Visits` (the left table) regardless of a match, filling unmatched `Transactions` columns with `NULL`. That `NULL` is exactly the signal `WHERE t.transaction_id IS NULL` looks for.

---

## ❌ Common Mistakes

- Using `INNER JOIN` — silently drops the exact rows the problem is asking about.
- Filtering with `t.transaction_id = NULL` instead of `IS NULL` — always evaluates to UNKNOWN, matches nothing.
- Forgetting `GROUP BY` — a customer with multiple no-transaction visits needs to be **counted**, not listed once per visit.

---

## ⏱️ Time Complexity

**O(n)** — the join is matched via `visit_id`, typically optimized with indexes; grouping is a single pass over the joined rows.

---

## 🔑 Key Learnings

- **`LEFT JOIN ... WHERE <right_table>.<col> IS NULL`** is the standard SQL idiom for "find rows in A with no match in B" — customers with no orders, employees with no manager, products never sold, etc. Worth remembering as a named pattern since it recurs constantly.
- The column checked for `IS NULL` should be one that's guaranteed non-null when a match *does* exist (like a primary/foreign key), not just any column from the right table.

---

## 🧠 Final Query

```sql
SELECT v.customer_id,
       COUNT(v.visit_id) AS count_no_trans
FROM Visits AS v
LEFT JOIN Transactions AS t
  ON v.visit_id = t.visit_id
WHERE t.transaction_id IS NULL
GROUP BY v.customer_id;
```
