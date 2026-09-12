# 1327. List the Products Ordered in a Period

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** JOIN · WHERE · GROUP BY · HAVING · SUM() · MONTH() · YEAR()

---

## ✅ Problem Summary

- Return product names ordered **at least 100 units total** during **February 2020**
- Sum up all `unit` values per product within that date range
- Return the product's total as `unit`
- Result can be in any order

---

## 🧠 Solution

```sql
SELECT p.product_name, SUM(o.unit) AS unit
FROM Products AS p
JOIN Orders AS o
ON p.product_id = o.product_id
WHERE MONTH(o.order_date) = 2 AND YEAR(o.order_date) = 2020
GROUP BY p.product_name
HAVING unit >= 100;
```

---

## 🧩 Breakdown

| Clause | Purpose |
|---|---|
| `JOIN ... ON p.product_id = o.product_id` | Links each order to its product name |
| `WHERE MONTH(o.order_date) = 2 AND YEAR(o.order_date) = 2020` | Filters individual order rows down to February 2020 only, *before* grouping |
| `GROUP BY p.product_name` | Collapses all remaining rows per product into one group |
| `SUM(o.unit) AS unit` | Adds up all units within each product's group |
| `HAVING unit >= 100` | Filters *groups* — keeps only products whose total reaches 100 |

---

## 🤔 Why WHERE before HAVING?

`Products` and `Orders` share `product_id` as the join key — one product can have many order rows.
```
Products                  Orders
+------------+          +------------+------------+------+
| product_id |──────────| product_id | order_date | unit |
+------------+          +------------+------------+------+

```

`WHERE` runs on raw joined rows, *before* any grouping or aggregation exists — so it can only reference per-row columns like `o.order_date`, never `SUM(o.unit)`. `HAVING` runs *after* `GROUP BY`, once aggregates exist, so it's the only clause that can filter on `SUM(o.unit) >= 100`.

Sample intermediate result (row-level, after `WHERE`, before grouping) for product_id = 1:

| product_id | order_date | unit |
|---|---|---|
| 1 | 2020-02-05 | 60 |
| 1 | 2020-02-10 | 70 |

After `GROUP BY` + `SUM`: `Leetcode Solutions → 130` ✅ passes `HAVING unit >= 100`.

---

## ⚠️ Why not filter everything in HAVING?

An early draft attempt:

```sql
GROUP BY p.product_name
HAVING unit >= 100 AND MONTH(o.order_date) = 2 AND YEAR(o.order_date) = 2020;
```

This is invalid: `o.order_date` is neither aggregated nor part of `GROUP BY`, so referencing it in `HAVING` (or even in `SELECT`) is unsafe/rejected under strict SQL mode — MySQL doesn't know *which* row's `order_date` to use for a group that may span many dates. Row-level filters belong in `WHERE`; only aggregate-level filters belong in `HAVING`.

---

## ❌ Common Mistakes

**Mistake 1: Referencing the aggregate alias in WHERE**
```sql
WHERE unit >= 100   -- ❌ unit (SUM alias) doesn't exist yet at WHERE time
```
**Fix:** Move it to `HAVING`, which runs after aggregation.

**Mistake 2: Filtering on a per-row column in HAVING**
```sql
HAVING MONTH(o.order_date) = 2   -- ❌ ungrouped, non-aggregated column
```
**Fix:** Keep row-level filters (`MONTH`, `YEAR`) in `WHERE`.

**Mistake 3: Forgetting the year**
```sql
WHERE MONTH(o.order_date) = 2   -- ❌ matches February of every year
```
**Fix:** Add `AND YEAR(o.order_date) = 2020` to pin down the exact period.

---

## ⏱️ Time Complexity

O(n) to scan and filter `Orders` rows, plus O(n log n) for the join/group-by sort — n being the number of order rows.

---

## 🔑 Key Learnings

- `WHERE` filters rows *before* grouping; `HAVING` filters groups *after* aggregation
- An aggregate alias (like `unit` from `SUM(o.unit)`) only exists post-`GROUP BY` — never usable in `WHERE`
- A column not in `GROUP BY` and not wrapped in an aggregate can't safely appear in `SELECT` or `HAVING`
- Always double-check date filters specify both month *and* year when the problem does

---

## 🏁 Final Query

```sql
SELECT p.product_name, SUM(o.unit) AS unit
FROM Products AS p
JOIN Orders AS o
ON p.product_id = o.product_id
WHERE MONTH(o.order_date) = 2 AND YEAR(o.order_date) = 2020
GROUP BY p.product_name
HAVING unit >= 100;
```
