# 3564. Seasonal Sales Analysis

![Difficulty](https://img.shields.io/badge/Difficulty-Medium-orange)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-brightgreen)

**Concepts:** `CTE` · `CASE` · `JOIN` · `GROUP BY` · `SUM` · `ROW_NUMBER()` · `PARTITION BY` · `ORDER BY`

---

## ✅ Problem Summary

Find the **most popular product category for each season**.

- ✔ Seasons: Winter (Dec–Feb), Spring (Mar–May), Summer (Jun–Aug), Fall (Sep–Nov)
- ✔ Popularity = total quantity sold in that season
- ✔ Tie-break 1: higher total revenue (`quantity × price`)
- ✔ Tie-break 2: lexicographically smaller category
- ✔ Return `season`, `category`, `total_quantity`, `total_revenue`, ordered by season ascending

---

## 💡 Solution

```sql
with cte as (
Select 
    case 
        when month(s.sale_date) in (12, 1, 2) then 'Winter'
        when month(s.sale_date) in (3, 4, 5) then 'Spring'
        when month(s.sale_date) in (6, 7, 8) then 'Summer'
        else 'Fall'
    end as season, 
    p.category, 
    sum(s.quantity) as total_quantity, 
    SUM(s.quantity * s.price) as total_revenue
from sales as s
join products as p
on s.product_id = p.product_id    
GROUP BY season, p.category
),

cte2 as (
    select season, category, total_quantity, total_revenue,
    row_number() over (partition by season order by  total_quantity desc, total_revenue desc, category asc) as rnk
    from cte
)

Select season, category, total_quantity, total_revenue
from cte2
where rnk =1
order by season;
```

---

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `CASE WHEN month(sale_date) IN (...)` | Maps every sale's month to its season |
| `JOIN products ON product_id` | Brings in `category` for each sale |
| `SUM(quantity)` | Total units sold per season and category |
| `SUM(quantity * price)` | Total revenue per season and category (multiply first, then sum) |
| `GROUP BY season, category` | One row per category within each season |
| `ROW_NUMBER() OVER (PARTITION BY season ...)` | Ranks categories inside each season; restarts for every season |
| `ORDER BY total_quantity DESC, total_revenue DESC, category ASC` | Applies the three popularity rules in order |
| `WHERE rnk = 1` | Keeps only the winner of each season |
| `ORDER BY season` | Guarantees the required output order |

---

## 🤔 Why two CTEs?

- `sales` has the numbers (`quantity`, `price`, `sale_date`); `products` has the `category`.
- They share the column **`product_id`**.

```
sales.product_id  ───────►  products.product_id
 (quantity, price,           (category)
  sale_date)
```

After the first CTE (aggregate per season and category), the second CTE ranks them. For Winter in the example:

| season | category | total_quantity | total_revenue | rnk |
|---|---|---|---|---|
| Winter | Apparel | 9 | 110 | **1** |
| Winter | Kitchen | 6 | 108 | 2 |
| Winter | Tech | 3 | 60 | 3 |
| Winter | Fitness | 2 | 24 | 4 |

A window function can't be filtered in the query that calculates it, so the `WHERE rnk = 1` has to sit in a **separate outer query**. That's why the ranking lives in its own CTE.

---

## 🔄 Why `ROW_NUMBER()` and not `RANK()`?

| Function | On ties |
|---|---|
| `ROW_NUMBER()` | Always gives unique numbers (1, 2, 3…), so exactly one row has `rnk = 1` |
| `RANK()` | Tied rows share a rank (1, 1, 3…), so two rows could both be `rnk = 1` |
| `DENSE_RANK()` | Tied rows share a rank with no gaps (1, 1, 2…), same risk |

Here the last tie-break is `category ASC`, and each category appears once per season, so every tie is fully resolved. `ROW_NUMBER()` is the safest choice because it guarantees exactly one winner per season.

---

## ⚠️ Common Mistakes

**1. Forgetting to carry columns through the CTE**

```sql
with cte as (
    Select case ... end as season     -- only season!
    from sales s join products p ...
)
Select season from cte GROUP BY season, category;   -- category doesn't exist here
```

✔ Fix: select `category`, `quantity` and revenue in the same CTE where you join.

**2. Grouping without aggregates**

```sql
GROUP BY season, category    -- but nothing is summed
```

✔ Fix: compute `SUM(quantity)` and `SUM(quantity * price)`.

**3. Summing price instead of revenue**

```sql
SUM(price)       -- wrong: ignores how many units sold
```

✔ Fix: `SUM(quantity * price)`.

**4. Stray comma before `FROM`**

```sql
Select season,
from cte
```

✔ Fix: remove the trailing comma.

**5. Relying on luck for output order**

```sql
where rnk = 1;      -- order not guaranteed
```

✔ Fix: add `ORDER BY season`.

---

## ⏱️ Time Complexity

- Join and group: **O(n)** for `n` sales rows (with an index on `product_id`).
- Ranking: **O(g log g)**, where `g` is the number of season–category groups (at most 4 × the number of categories).
- Overall: **O(n + g log g)**.

---

## 🧠 Key Learnings

- Aggregate first, then rank. Don't rank raw rows.
- Revenue is `SUM(quantity * price)`: multiply per row, then add up.
- `PARTITION BY season` restarts the ranking for each season.
- Multi-level tie-breaks all go in one window `ORDER BY`, in priority order.
- You can't filter a window function in the query that defines it, so use a second CTE or subquery.
- Selecting rows and ordering the output are separate steps. Add `ORDER BY` whenever the problem specifies an order.

---

## 🏁 Final Query

```sql
with cte as (
Select 
    case 
        when month(s.sale_date) in (12, 1, 2) then 'Winter'
        when month(s.sale_date) in (3, 4, 5) then 'Spring'
        when month(s.sale_date) in (6, 7, 8) then 'Summer'
        else 'Fall'
    end as season, 
    p.category, 
    sum(s.quantity) as total_quantity, 
    SUM(s.quantity * s.price) as total_revenue
from sales as s
join products as p
on s.product_id = p.product_id    
GROUP BY season, p.category
),

cte2 as (
    select season, category, total_quantity, total_revenue,
    row_number() over (partition by season order by  total_quantity desc, total_revenue desc, category asc) as rnk
    from cte
)

Select season, category, total_quantity, total_revenue
from cte2
where rnk =1
order by season;
```
