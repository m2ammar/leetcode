# 1070. Product Sales Analysis III

![Difficulty](https://img.shields.io/badge/Difficulty-orange)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-brightgreen)

**Concepts:** MIN() · Subquery · JOIN · GROUP BY

---

## ✅ Problem Summary

- [x] Find the earliest (`MIN`) `year` each `product_id` was sold
- [x] Return **all** sale rows for that product that occurred in that first year
- [x] Output columns: `product_id`, `first_year`, `quantity`, `price`

---

## 🤔 Solution

```sql
select s.product_id, s.year as first_year, s.quantity, s.price
from Sales AS s
join (select product_id, min(year) as min_year from Sales group by product_id) as initial
on  s.product_id = initial.product_id
AND initial.min_year = s.year;
```

---

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `select product_id, min(year) as min_year ... group by product_id` (subquery, aliased `initial`) | For each product, computes the true earliest year, given a usable name (`min_year`) |
| `from Sales AS s join (...) as initial` | Joins the full `Sales` table back to that one-row-per-product summary |
| `on s.product_id = initial.product_id AND initial.min_year = s.year` | Keeps only the rows whose year matches that product's first year |
| `select s.product_id, s.year as first_year, s.quantity, s.price` | Returns `quantity`/`price` from the actual first-year row(s), not an arbitrary one |

---

## 🤔 Why JOIN a subquery?

Two tables are effectively involved:

- `Sales` — every sale, one row per `(sale_id, year)`
- `initial` (derived) — one row per `product_id`, holding only its minimum year

The common column is `product_id`, narrowed further by matching `year = min_year`.

```
Sales                          initial
+----+-----+------+       +----+---------+
| pid| year| ...  |       | pid| min_year|
+----+-----+------+       +----+---------+
| 100| 2008|  ...  <----->| 100|   2008  |
| 100| 2009|  ...  |      | 200|   2011  |
| 200| 2011|  ...  <----->
```

Sample result:

| product_id | first_year | quantity | price |
|---|---|---|---|
| 100 | 2008 | 10 | 5000 |
| 200 | 2011 | 15 | 9000 |

This guarantees `quantity` and `price` genuinely belong to the first-year row — not just whatever row the engine happened to pick.

---

## ⚠️ Why not plain `GROUP BY` with unaggregated columns?

```sql
select product_id, min(year) as first_year, quantity, price
from Sales
group by product_id;
```

`quantity` and `price` aren't wrapped in an aggregate function and aren't in the `GROUP BY` list, so MySQL (with `ONLY_FULL_GROUP_BY` relaxed) is free to pull them from **any** row in that product's group — not necessarily the row where `year = MIN(year)`. It can pass small test cases by coincidence while being wrong in general.

---

## 🐛 Common Mistakes

**Mistake 1: trusting GROUP BY to align unaggregated columns with an aggregate**

```sql
-- ❌ Runs fine, correctness isn't guaranteed
select product_id, min(year) as first_year, quantity, price
from Sales
group by product_id;
```

**Mistake 2: referencing an unaliased aggregate column from a subquery**

```sql
-- ❌ Errors: the subquery's column is literally named `min(year)`, not `year`
join (select product_id, min(year) from Sales group by product_id) as initial
on s.product_id = initial.product_id AND initial.year = s.year;
```

Aggregate expressions don't inherit the name of the column they wrap — `initial.year` doesn't exist unless it's explicitly aliased.

**Fix: alias the aggregate, then join back on that alias**

```sql
-- ✅ quantity/price pulled from the real min-year row, and the alias resolves
join (select product_id, min(year) as min_year from Sales group by product_id) as initial
on s.product_id = initial.product_id AND initial.min_year = s.year;
```

---

## ⏱️ Time Complexity

O(n) for the subquery's grouping pass, plus O(n) for the join (indexed on `product_id`) — overall roughly O(n) to O(n log n) depending on the join strategy MySQL picks.

---

## 🔑 Key Learnings

- `GROUP BY` only guarantees correctness for columns that are either grouped on or wrapped in an aggregate function — everything else is undefined per the SQL standard, even if MySQL lets it run.
- The safe pattern for "give me the full row associated with a MIN/MAX" is: aggregate in a subquery, then join back on the aggregated value.
- Unaliased aggregate expressions (`min(year)`) don't take on the wrapped column's name — reference them by alias, not by the original column name.
- A query passing LeetCode's test cases isn't proof of correctness — it's proof the test cases didn't expose the bug.

---

## Final Query

```sql
select s.product_id, s.year as first_year, s.quantity, s.price
from Sales AS s
join (select product_id, min(year) as min_year from Sales group by product_id) as initial
on  s.product_id = initial.product_id
AND initial.min_year = s.year;
```
