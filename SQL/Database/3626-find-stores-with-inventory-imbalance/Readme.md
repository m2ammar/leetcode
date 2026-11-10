# 3626. Find Stores with Inventory Imbalance

![Difficulty](https://img.shields.io/badge/Difficulty-Medium-orange)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-brightgreen)

**Concepts:** `CTE` · `ROW_NUMBER()` · `COUNT() OVER` · `PARTITION BY` · `JOIN` · `ROUND` · `ORDER BY`

---

## ✅ Problem Summary

- Find stores where the **most expensive** product has **less stock** than the **cheapest** product
- Only include stores with **at least 3 different products**
- Return `store_id`, `store_name`, `location`, `most_exp_product`, `cheapest_product`, `imbalance_ratio`
- `imbalance_ratio = cheapest_quantity / most_expensive_quantity`, rounded to 2 decimals
- Order by `imbalance_ratio` DESC, then `store_name` ASC

---

## 💡 Solution

```sql
WITH cte AS (
    SELECT
        store_id,
        product_name,
        quantity,
        ROW_NUMBER() OVER (PARTITION BY store_id ORDER BY price DESC) AS rn_high,
        ROW_NUMBER() OVER (PARTITION BY store_id ORDER BY price ASC)  AS rn_low,
        COUNT(*)     OVER (PARTITION BY store_id)                     AS cnt
    FROM inventory
),
expensive AS (
    SELECT store_id, product_name, quantity
    FROM cte
    WHERE rn_high = 1 AND cnt >= 3
),
cheap AS (
    SELECT store_id, product_name, quantity
    FROM cte
    WHERE rn_low = 1
)
SELECT
    s.store_id,
    s.store_name,
    s.location,
    e.product_name AS most_exp_product,
    c.product_name AS cheapest_product,
    ROUND(c.quantity / e.quantity, 2) AS imbalance_ratio
FROM stores AS s
JOIN expensive AS e ON s.store_id = e.store_id
JOIN cheap     AS c ON s.store_id = c.store_id
WHERE e.quantity < c.quantity
ORDER BY imbalance_ratio DESC, s.store_name ASC;
```

---

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `ROW_NUMBER() ... ORDER BY price DESC` (`rn_high`) | Numbers each store's products from most to least expensive, so the priciest row gets `1` |
| `ROW_NUMBER() ... ORDER BY price ASC` (`rn_low`) | Same, but cheapest first, so the cheapest row gets `1` |
| `COUNT(*) OVER (PARTITION BY store_id)` (`cnt`) | Attaches the number of products in the store to every row, without collapsing rows |
| `expensive` CTE | Keeps only the priciest row per store, and only if the store has 3+ products |
| `cheap` CTE | Keeps only the cheapest row per store |
| `JOIN expensive / cheap / stores` | Puts the priciest row, cheapest row, and store details side by side on one line |
| `WHERE e.quantity < c.quantity` | Keeps only imbalanced stores |
| `ROUND(c.quantity / e.quantity, 2)` | Cheapest quantity over priciest quantity, to 2 decimals |
| `ORDER BY` | Ratio high to low, ties broken by store name A to Z |

---

## 🤔 Why Window Functions?

The real challenge: `MAX(price)` gives you the **value**, but not the **row** it came from. We need that row's `product_name` and `quantity`. Ranking rows inside each store lets us pick the exact row.

```
inventory (one store)            ranked
+-----------+-------+          +-----------+-------+---------+--------+
| product   | price |   --->   | product   | price | rn_high | rn_low |
+-----------+-------+          +-----------+-------+---------+--------+
| Laptop    | 999.99|          | Laptop    | 999.99|    1    |   4    |
| Monitor   | 299.99|          | Monitor   | 299.99|    2    |   3    |
| Keyboard  |  79.99|          | Keyboard  |  79.99|    3    |   2    |
| Mouse     |  19.99|          | Mouse     |  19.99|    4    |   1    |
+-----------+-------+          +-----------+-------+---------+--------+
```

`rn_high = 1` is the most expensive product, `rn_low = 1` is the cheapest.

Sample result:

| store_id | store_name | location | most_exp_product | cheapest_product | imbalance_ratio |
|---|---|---|---|---|---|
| 3 | City Center | Los Angeles | Tablet | Stylus | 40.00 |
| 2 | Suburb Mall | Chicago | Phone | Case | 25.00 |
| 1 | Downtown Tech | New York | Laptop | Mouse | 10.00 |

---

## 🔀 Why not `GROUP BY` with `MAX` / `MIN`?

| Approach | Problem |
|---|---|
| `GROUP BY store_id` + `MAX(price)` | Returns the max price only; `quantity` and `product_name` come from an arbitrary row in the group |
| Self-join back on `price = MAX(price)` | Works, but needs extra subqueries and joins twice, which is harder to read |
| `ROW_NUMBER()` | Picks the exact row per store in one pass and keeps every column |

---

## ⚠️ Common Mistakes

**1. Using an aggregate inside `CASE`**

```sql
CASE WHEN MAX(price) THEN quantity END   -- ❌
```

`MAX(price)` is just a number, so `WHEN <number>` is almost always true. It never asks "is this the max-price row?"

Fix: rank the rows with `ROW_NUMBER()` and filter with `rn = 1`.

**2. Grouping by a column that isn't in the table**

```sql
FROM inventory GROUP BY store_name   -- ❌
```

`store_name` lives in `stores`, not `inventory`. Group by `store_id` or join first.

**3. Flipped ratio**

```sql
ROUND(e.quantity / c.quantity, 2)   -- ❌
ROUND(c.quantity / e.quantity, 2)   -- ✅ cheapest / most expensive
```

**4. Joining on a table alias that doesn't exist yet**

```sql
JOIN expensive AS e ON s.store_id = c.store_id   -- ❌ c is joined on the next line
```

A join condition can only reference tables already joined above it.

**5. Forgetting the imbalance condition**

Without `WHERE e.quantity < c.quantity`, every store with 3+ products comes back, including balanced ones.

**6. Filtering a window function in `WHERE` directly**

Window functions can't be used in `WHERE`. Compute them in a CTE first, then filter outside.

---

## ⏱️ Time Complexity

`O(n log n)`, dominated by the sorting done for the window functions inside each store partition.

---

## 🔑 Key Learnings

- `MAX` / `MIN` give you a value, not the row it came from. Use `ROW_NUMBER()` when you need the whole row.
- Window functions can't be used in `WHERE`: compute them in a CTE, then filter `rn = 1` outside.
- `COUNT(*) OVER (PARTITION BY ...)` adds a group count to every row without needing `GROUP BY`.
- Two ranked CTEs (`expensive` and `cheap`) joined on `store_id` are easier to read than one big `CASE`.
- If two products share the same price, `ROW_NUMBER()` picks one arbitrarily. Add a tiebreaker column to `ORDER BY` (or use `RANK()`) if ties are possible.

---

## 🏁 Final Query

```sql
WITH cte AS (
    SELECT
        store_id,
        product_name,
        quantity,
        ROW_NUMBER() OVER (PARTITION BY store_id ORDER BY price DESC) AS rn_high,
        ROW_NUMBER() OVER (PARTITION BY store_id ORDER BY price ASC)  AS rn_low,
        COUNT(*)     OVER (PARTITION BY store_id)                     AS cnt
    FROM inventory
),
expensive AS (
    SELECT store_id, product_name, quantity
    FROM cte
    WHERE rn_high = 1 AND cnt >= 3
),
cheap AS (
    SELECT store_id, product_name, quantity
    FROM cte
    WHERE rn_low = 1
)
SELECT
    s.store_id,
    s.store_name,
    s.location,
    e.product_name AS most_exp_product,
    c.product_name AS cheapest_product,
    ROUND(c.quantity / e.quantity, 2) AS imbalance_ratio
FROM stores AS s
JOIN expensive AS e ON s.store_id = e.store_id
JOIN cheap     AS c ON s.store_id = c.store_id
WHERE e.quantity < c.quantity
ORDER BY imbalance_ratio DESC, s.store_name ASC;
```
