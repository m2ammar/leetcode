# 1164. Product Price at a Given Date

![Difficulty](https://img.shields.io/badge/Difficulty-Medium-yellow)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** CTE · Window Functions (ROW_NUMBER) · LEFT JOIN · CASE · DISTINCT

---

## ✅ Problem Summary

- Table `Products(product_id, new_price, change_date)` logs every price change for a product.
- `(product_id, change_date)` is the primary key.
- All products start at price **10** by default.
- Return the price of **every** product as it stood on **2019-08-16**:
  - If a product had a change on or before that date, use the price from its most recent such change.
  - If a product's changes all happened after that date (or it never appears with a qualifying row), it's still at the default price of 10.

---

## 🧠 Solution

```sql
with cte as (
    select
        product_id,
        new_price,
        row_number() over (partition by product_id order by change_date desc) as rn
    from Products
    where change_date <= '2019-08-16'
)
select
    p.product_id,
    case when cte.new_price is null then 10 else cte.new_price end as price
from (select distinct product_id from Products) as p
left join cte
    on cte.product_id = p.product_id
    and rn = 1;
```

---

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `with cte as (...)` | Builds a working set of only the "valid" changes — ones that happened on or before the target date. |
| `where change_date <= '2019-08-16'` | Excludes any change that happens after the target date; those are irrelevant to what the price was *on* that date. |
| `row_number() over (partition by product_id order by change_date desc)` | Ranks each product's valid changes from most recent (`rn = 1`) to oldest. |
| `(select distinct product_id from Products) as p` | Builds the full universe of product_ids, so every product gets a row in the final result — even ones with no valid change. |
| `left join cte on cte.product_id = p.product_id and rn = 1` | Attaches each product's most recent valid price (if one exists); products with no valid change come back with `NULL`. |
| `case when cte.new_price is null then 10 else cte.new_price end` | Converts the `NULL` from unmatched products into the default price of 10. |

---

## 🤔 Why CTE + Window Function?

The two tables/concepts involved:
- **`Products`** — the raw change log, many rows per product.
- **The "full product list"** — a `DISTINCT` subquery to guarantee no product gets dropped.

The common join column is `product_id`.

```
Products (raw log)              p (distinct product_id)
------------------              ------------------------
product_id | change_date              product_id
    1      |  08-14      \                 1
    1      |  08-15       \                2
    1      |  08-16   -----> ranked, rn=1  3
    2      |  08-14   ----->  kept
    3      |  08-18   -----X  filtered out (after target date)
```

Sample result:

| product_id | price |
|---|---|
| 1 | 35 |
| 2 | 50 |
| 3 | 10 |

A window function is the natural fit because "most recent row per group" is exactly what `ROW_NUMBER() OVER (PARTITION BY ... ORDER BY ...)` is built for — one pass gets every product's latest valid price ranked and ready to filter on `rn = 1`.

---

## 🤔 Why not GROUP BY + MAX(change_date)?

An alternative is `GROUP BY product_id HAVING MAX(change_date) <= '2019-08-16'`, then joining back to `Products` on `product_id` and the max date to fetch `new_price`.

This works too, but:
- It requires a second join back to `Products` just to recover `new_price`, since `MAX(change_date)` alone doesn't carry the price with it.
- It still needs a separate `UNION` (or the same `LEFT JOIN` trick) to cover products whose only changes are after the target date.
- The window function version does the "find the latest qualifying row" and "keep its price" in a single pass, without a second self-join.

Both are valid; the window function version was preferred here for being one CTE instead of a `GROUP BY` + join-back + `UNION`.

---

## ⚠️ Common Mistakes

**Mistake 1: Filtering with `WHERE change_date = '2019-08-16'`**
```sql
-- Wrong: drops any product whose last change was before the target date,
-- and wrongly excludes products that should default to 10.
select product_id, new_price as price
from Products
where change_date = '2019-08-16';
```
Fix: use `change_date <= '2019-08-16'` and take the *most recent* qualifying row per product, not an exact match.

**Mistake 2: Aggregate function inside `WHERE`**
```sql
-- Wrong: aggregates can't be used in WHERE.
where MAX(change_date) <= '2019-08-16'
```
Fix: aggregates belong in `HAVING`, after a `GROUP BY`.

**Mistake 3: Forgetting the default-10 fallback**
```sql
-- Wrong: any product with no valid change before the target date just vanishes.
select p.product_id, cte.new_price as price
from Products p
join cte on p.product_id = cte.product_id;
```
Fix: use a `LEFT JOIN` against the full distinct product list, then `CASE WHEN price IS NULL THEN 10 ELSE price END`.

---

## ⏱️ Time Complexity

`O(n log n)` — dominated by the window function's per-partition sort on `change_date`, where `n` is the number of rows in `Products`.

---

## 🔑 Key Learnings

- "On a given date" means reconstructing state *as of* that date, not filtering for an exact date match.
- `CASE` can't manufacture a missing row — it can only choose between values that already exist in the row. Missing rows need a `LEFT JOIN` (or `UNION`) first.
- `LEFT JOIN` + `CASE WHEN ... IS NULL` is a clean way to apply a default value without a separate `UNION` query.
- Aggregate functions (`MAX`, `MIN`, etc.) can only be filtered with `HAVING`, never `WHERE`.

---

## 🧾 Final Query

```sql
with cte as (
    select
        product_id,
        new_price,
        row_number() over (partition by product_id order by change_date desc) as rn
    from Products
    where change_date <= '2019-08-16'
)
select
    p.product_id,
    case when cte.new_price is null then 10 else cte.new_price end as price
from (select distinct product_id from Products) as p
left join cte
    on cte.product_id = p.product_id
    and rn = 1;
```
