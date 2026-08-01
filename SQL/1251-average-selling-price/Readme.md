# 1251. Average Selling Price

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** `LEFT JOIN` · `BETWEEN` · Weighted Average · `IFNULL` / `NULL` handling · `GROUP BY`

---

## 📋 Problem Summary

Given a `Prices` table (product price per date range, non-overlapping
periods) and a `UnitsSold` table (units sold per product per purchase
date), find the **average selling price** for each product:

```
average_price = total revenue / total units sold
```

If a product has no recorded sales, its `average_price` should be `0`.

---

## ✅ Solution

```sql
SELECT p.product_id,
       ROUND(IFNULL(SUM(u.units * p.price), 0) / IFNULL(SUM(u.units), 1), 2) AS average_price
FROM Prices AS p
LEFT JOIN UnitsSold AS u
  ON p.product_id = u.product_id
 AND u.purchase_date BETWEEN p.start_date AND p.end_date
GROUP BY p.product_id;
```

---

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `LEFT JOIN ... ON p.product_id = u.product_id AND u.purchase_date BETWEEN p.start_date AND p.end_date` | Matches each sale to the correct price *period*, not just the correct product — and keeps every product from `Prices` even if it has zero matching sales |
| `SUM(u.units * p.price)` | Total revenue: unit price × units sold, summed per row before aggregating |
| `SUM(u.units)` | Total units sold across all matched periods |
| `IFNULL(..., 0)` / `IFNULL(..., 1)` | Guards against `NULL` when a product has no sales (see below) |
| `ROUND(..., 2)` | Rounds the final weighted average to 2 decimal places |
| `GROUP BY p.product_id` | Aggregates all matched rows down to one row per product |

---

## 🤔 Why not just join on `product_id`?

Each product can have **multiple price periods** (different `start_date`
/`end_date` rows, non-overlapping). Joining on `product_id` alone
matches every sale to *every* price row for that product, wildly
inflating both the revenue sum and the units sum. The join must also
confirm the purchase falls inside that specific price period:

```sql
AND u.purchase_date BETWEEN p.start_date AND p.end_date
```

## 🤔 Why is this a *weighted* average, not `AVG(price)`?

`AVG(price)` would treat every price period equally, regardless of how
many units sold in each. The correct formula weights each period by
its units sold — total revenue divided by total units — which is why
the numerator has to be `SUM(units * price)`, not `SUM(price)`.

---

## ⚠️ Common Mistakes

### Using `INNER JOIN` instead of `LEFT JOIN`
```sql
JOIN UnitsSold AS u ON ...  -- ❌ silently drops products with zero sales
```
An inner join only keeps products that have at least one matching row
in `UnitsSold`. A product with no sales at all disappears from the
result entirely — but the problem expects it to appear with
`average_price = 0`.

### Fixing the join but forgetting `NULL` propagates through `SUM`
```sql
ROUND(SUM(u.units * p.price) / IFNULL(SUM(u.units), 1), 2)  -- ❌ still NULL
```
`LEFT JOIN` alone only restores the *row* for unmatched products — the
joined columns (`u.units`, `u.price`) come back `NULL` for those rows.
`SUM()` over an all-`NULL` group returns `NULL`, not `0`. So
`SUM(u.units * p.price)` is `NULL`, and `NULL / anything` is still
`NULL`. Guarding only the denominator isn't enough — **both** sides of
the division need an `IFNULL`:
```sql
IFNULL(SUM(u.units * p.price), 0) / IFNULL(SUM(u.units), 1)
```
The denominator defaults to `1` (not `0`) purely to avoid a
divide-by-zero — since the numerator is already forced to `0` in that
case, the result is `0 / 1 = 0` as required.

### Cancelling terms in the formula
```sql
SUM(units) * SUM(price) / SUM(units)  -- ❌ SUM(units) cancels out algebraically
```
This collapses to just `SUM(price)`, which isn't a weighted average at
all — it's the unweighted sum of period prices.

---

## ⏱️ Time Complexity

**O(n × m)** in the worst case for the join (each price period checked
against each sale for a product), though in practice indexed date
range lookups make this efficient. Followed by `O(k log k)` for the
final `GROUP BY`/sort, where `k` is the number of distinct products.

---

## 🔑 Key Learnings

- A `LEFT JOIN` and a `NULL`-safe aggregate are **two separate fixes**
  for two separate problems: missing *rows* vs. missing *values*.
  Forgetting either one breaks the query in a different way.
- `SUM()` (and most aggregates) over zero matched rows returns `NULL`,
  not `0` — this is standard SQL behavior, not a bug, and it's easy to
  overlook until a "no matches" edge case exposes it.
- Multi-column join conditions (`product_id` **and** a date range) are
  often required when a "lookup" table has time-bound validity periods
  rather than one static value per key.

---

## 🧠 Final Query

```sql
SELECT p.product_id,
       ROUND(IFNULL(SUM(u.units * p.price), 0) / IFNULL(SUM(u.units), 1), 2) AS average_price
FROM Prices AS p
LEFT JOIN UnitsSold AS u
  ON p.product_id = u.product_id
 AND u.purchase_date BETWEEN p.start_date AND p.end_date
GROUP BY p.product_id;
```
