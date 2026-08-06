# 1174. Immediate Food Delivery II

![Difficulty](https://img.shields.io/badge/Difficulty-Medium-yellow) 
![Topic](https://img.shields.io/badge/Topic-SQL-blue) 
![Status](https://img.shields.io/badge/Status-Accepted-brightgreen)

**Concepts:** Correlated Subquery · GROUP BY (inner) · CASE WHEN · Aggregate Functions (SUM, COUNT, MIN) · ROUND

---

## ✅ Problem Summary

- Each customer's **first order** is the row with their earliest `order_date`.
- An order is **immediate** if `order_date = customer_pref_delivery_date`, otherwise it's **scheduled**.
- Return the percentage of first orders (one per customer) that are immediate, rounded to 2 decimal places.

## 🧩 Solution

```sql
SELECT ROUND(SUM(CASE WHEN order_date = customer_pref_delivery_date THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS immediate_percentage
FROM Delivery
WHERE order_date IN (
    SELECT MIN(order_date)
    FROM Delivery AS d2
    WHERE d2.customer_id = Delivery.customer_id
);
```

## 🔍 Breakdown

| Clause | What it does |
|---|---|
| `WHERE order_date IN (SELECT MIN(order_date) FROM Delivery d2 WHERE d2.customer_id = Delivery.customer_id)` | Correlated subquery — for each outer row, finds that *same customer's* earliest `order_date`, and keeps only rows matching it. This isolates exactly one row per customer: their first order. |
| `CASE WHEN order_date = customer_pref_delivery_date THEN 1 ELSE 0 END` | Flags a first order as `1` if it's immediate, `0` if scheduled. |
| `SUM(...)` | Counts how many first orders were immediate. |
| `COUNT(*)` | Total number of first orders — equal to the total number of distinct customers. |
| `ROUND(... / ... * 100, 2)` | Converts the ratio to a percentage, rounded to 2 decimals. |

## 🤔 Why a Correlated Subquery?

Both tables here are really the same table (`Delivery`), aliased so the subquery can look at each customer's own row set independently of the outer query's current row.

```
Delivery (outer)              Delivery d2 (inner, per customer_id)
+-------------+------------+  +-------------+------------+
| customer_id | order_date |  | customer_id | order_date |
+-------------+------------+  +-------------+------------+
      1  <----- correlated ---->   1        2019-08-01
      1                            1        2019-08-11
                                   MIN() -> 2019-08-01
```

The subquery re-runs *once per outer row*, filtered to that row's `customer_id`, and returns just that customer's minimum date. The outer `WHERE order_date IN (...)` then keeps only the row(s) matching it — i.e., the first order.

Sample result after the filter (before the aggregation):

| customer_id | order_date | customer_pref_delivery_date |
|---|---|---|
| 1 | 2019-08-01 | 2019-08-02 |
| 2 | 2019-08-02 | 2019-08-02 |
| 3 | 2019-08-21 | 2019-08-22 |
| 4 | 2019-08-09 | 2019-08-09 |

## ⚠️ Why not a flat `GROUP BY customer_id`?

A single-level `GROUP BY customer_id` can give you `MIN(order_date)` per customer, but it **collapses rows** — so you lose the ability to also read that specific row's `customer_pref_delivery_date`, since a group might contain multiple different values for it. `GROUP BY` only lets you select aggregates or grouped columns, never an arbitrary column tied to "the row where the minimum occurred." That's exactly the gap a correlated subquery (or a window function + outer filter, or a self-join) fills.

## 🚨 Common Mistakes

**Mistake 1: Computing the percentage over the whole table**
```sql
-- Wrong: uses ALL orders, not just each customer's first order
SELECT ROUND(SUM(CASE WHEN order_date = customer_pref_delivery_date THEN 1 ELSE 0 END) / COUNT(*) * 100, 2)
FROM Delivery;
```
This gives 3/7 = 42.86 instead of 2/4 = 50.00 — it never filters down to first orders, so repeat customers' later orders wrongly count too.

**Mistake 2: Subquery returning the wrong number of columns**
```sql
-- Wrong: subquery selects 2 columns but is compared against 1
WHERE order_date = (SELECT customer_id, MIN(order_date) FROM Delivery GROUP BY customer_id)
```
Fix: once correlated to the outer `customer_id`, the subquery only needs `MIN(order_date)` — no `customer_id`, no `GROUP BY`.

**Mistake 3: Forgetting to correlate the subquery**
```sql
-- Wrong: finds the single earliest date in the whole table, not per customer
WHERE order_date IN (SELECT MIN(order_date) FROM Delivery)
```
This ties the minimum to the entire table rather than to each row's own `customer_id`, so it can miss or misattribute first orders when customers share order dates.

## ⏱️ Time Complexity

O(n²) in the naive correlated-subquery form (the inner query re-scans `Delivery` for every outer row), though MySQL's optimizer typically uses an index on `customer_id` to make each correlated lookup fast in practice. An equivalent window-function or GROUP BY + JOIN rewrite runs closer to O(n log n).

## 🔑 Key Learnings

- "First/latest row per group" problems can't be solved with a flat `GROUP BY` alone — you need a correlated subquery, window function, or self-join to pull the *whole row* tied to the minimum/maximum.
- A subquery used with `=` must return exactly one column and one row; used with `IN`, one column but any number of rows.
- Correlating a subquery to the outer row (`d2.customer_id = Delivery.customer_id`) is what scopes an aggregate like `MIN()` to "per group" instead of "whole table."

## 🎯 Final Query

```sql
SELECT ROUND(SUM(CASE WHEN order_date = customer_pref_delivery_date THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS immediate_percentage
FROM Delivery
WHERE order_date IN (
    SELECT MIN(order_date)
    FROM Delivery AS d2
    WHERE d2.customer_id = Delivery.customer_id
);
```
