# 586. Customer Placing the Largest Number of Orders

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** GROUP BY · COUNT() · ORDER BY · LIMIT

---

## ✅ Problem Summary

Given an `Orders` table:

- Find the `customer_number` of the customer who has placed the **largest number of orders**.
- The test data guarantees exactly **one** customer has strictly more orders than everyone else (no ties to handle in the base problem).
- Return just that one `customer_number`.

---

## 🧠 Solution

```sql
SELECT customer_number
FROM Orders
GROUP BY customer_number
ORDER BY COUNT(customer_number) DESC
LIMIT 1;
```

---

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `FROM Orders` | Reads every order row (each row = one placed order). |
| `GROUP BY customer_number` | Collapses all rows into one group per customer. |
| `COUNT(customer_number)` | Counts how many rows (orders) fall into each customer's group. |
| `ORDER BY COUNT(customer_number) DESC` | Sorts customers from most orders to fewest. |
| `LIMIT 1` | Keeps only the top row — the customer with the most orders. |
| `SELECT customer_number` | Outputs the customer's ID, not the count. |

---

## 🤔 Why GROUP BY + COUNT?

The `Orders` table has one row per order, and each row is tagged with the `customer_number` who placed it:

```
order_number | customer_number
------------------------------
1            | 1
2            | 2
3            | 3
4            | 3
```

To answer "who placed the most orders," we don't care about individual `order_number` values — we care about how many rows share the same `customer_number`. `GROUP BY customer_number` buckets the rows by customer, and `COUNT()` tells us the size of each bucket:

```
customer_number | order_count
--------------------------------
1                | 1
2                | 1
3                | 2   <-- largest
```

Sorting that descending and taking the first row gives us `3`.

---

## ⚠️ Common Mistakes

**Mistake 1 — confusing `MAX(order_number)` with order count**
```sql
-- Wrong: this finds the customer with the highest order_number value,
-- not the customer with the most orders.
SELECT customer_number
FROM Orders
GROUP BY customer_number
HAVING MAX(order_number)
LIMIT 1;
```
`HAVING MAX(order_number)` doesn't filter or rank by anything meaningful here — it just evaluates the max order ID as a truthy number. It has nothing to do with *how many* orders a customer placed.

**Mistake 2 — aliasing COUNT as customer_number**
```sql
-- Wrong: this outputs the *count*, mislabeled as customer_number,
-- instead of the actual customer ID.
SELECT COUNT(customer_number) AS customer_number
FROM Orders
GROUP BY customer_number
ORDER BY COUNT(customer_number) DESC;
```
This also forgets `LIMIT 1`, so it returns every group instead of just the top one.

**Mistake 3 — ordering by the wrong column**
```sql
-- Wrong: sorts by the customer_number *value* itself, not by order count.
-- Happens to pass on data where the customer with the most orders also
-- has the highest customer_number, but it's coincidental, not correct logic.
SELECT customer_number
FROM Orders
GROUP BY customer_number
ORDER BY customer_number DESC
LIMIT 1;
```

---

## ⏱️ Time Complexity

O(n) to scan and group the rows, plus O(k log k) to sort the resulting k customer groups by count — negligible for typical table sizes.

---

## 🔑 Key Learnings

- `COUNT(column)` inside a grouped query counts rows per group, not values within a single row.
- `HAVING` is for filtering *groups* by a condition — it's not a substitute for `ORDER BY` when you want to rank and pick a top result.
- Sorting by the wrong column can still produce a "correct" result on a small/coincidental test case — always sanity-check logic against a hypothetical case where the coincidence breaks (e.g., swap which customer has the most orders).
- `ORDER BY <aggregate expression> DESC LIMIT 1` is the standard pattern for "find the group with the max count."

---

## 🎯 Final Query

```sql
SELECT customer_number
FROM Orders
GROUP BY customer_number
ORDER BY COUNT(customer_number) DESC
LIMIT 1;
```
