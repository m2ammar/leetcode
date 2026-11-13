# 🏆 3705. Find Golden Hour Customers

![Difficulty](https://img.shields.io/badge/Difficulty-Medium-orange)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-brightgreen)

**Concepts:** `GROUP BY` · `HAVING` · `CASE WHEN` · `SUM` · `COUNT` · `AVG` · `ROUND` · `TIME()` · `BETWEEN`

---

## ✅ Problem Summary

Return every customer who meets **all** of these:

- ✅ Made at least **3 orders**
- ✅ At least **60%** of orders placed in peak hours (11:00-14:00 or 18:00-21:00)
- ✅ Average rating (over rated orders) at least **4.0**, rounded to 2 decimals
- ✅ Rated at least **50%** of their orders

Order by `average_rating` DESC, then `customer_id` DESC.

---

## 💡 Solution

```sql
SELECT  customer_id,
        COUNT(order_id) AS total_orders,
        ROUND((SUM(CASE WHEN TIME(order_timestamp) BETWEEN '11:00' AND '14:00'
                          OR TIME(order_timestamp) BETWEEN '18:00' AND '21:00'
                        THEN 1 ELSE 0 END) / COUNT(*)) * 100, 0) AS peak_hour_percentage,
        ROUND(AVG(order_rating), 2) AS average_rating
FROM restaurant_orders
GROUP BY customer_id
HAVING SUM(CASE WHEN TIME(order_timestamp) BETWEEN '11:00' AND '14:00'
                  OR TIME(order_timestamp) BETWEEN '18:00' AND '21:00'
                THEN 1 ELSE 0 END) / COUNT(*) * 100 >= 60
   AND AVG(order_rating) >= 4.0
   AND total_orders >= 3
   AND COUNT(order_rating) / COUNT(order_id) >= 0.5
ORDER BY 4 DESC, 1 DESC;
```

---

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `GROUP BY customer_id` | One row per customer, so all counts and averages are per customer |
| `CASE WHEN ... THEN 1 ELSE 0 END` | Flags each order: 1 if peak hour, 0 if not |
| `SUM(flag) / COUNT(*) * 100` | Peak-hour orders ÷ all orders, as a percentage |
| `COUNT(order_rating) / COUNT(order_id)` | Rated orders ÷ all orders (`COUNT(col)` skips NULLs) |
| `AVG(order_rating)` | Average over rated orders only (`AVG` ignores NULLs) |
| `ROUND(..., 0)` / `ROUND(..., 2)` | Display formatting only, in SELECT |
| `HAVING` | Filters on aggregates, which `WHERE` cannot do |
| `ORDER BY 4 DESC, 1 DESC` | Column positions: 4 = `average_rating`, 1 = `customer_id` |

---

## 🤔 Why conditional aggregation?

Every rule is about a **ratio per customer**, so the query has to look at all of a customer's rows at once.

```
order row  →  flag (1 = peak, 0 = not)  →  SUM(flag) / COUNT(*)  →  % per customer
```

| customer_id | orders | peak orders | peak % |
|---|---|---|---|
| 101 | 3 | 2 | 66.67 → 67 |
| 104 | 5 | 4 | 80 |

---

## 🚫 Why not WHERE?

`WHERE` filters individual rows **before** grouping. Filtering to peak-hour rows first would throw away the non-peak orders, so you could no longer compute "peak orders ÷ all orders". A cleaner alternative is computing the flag once in a CTE or subquery and then aggregating. It avoids repeating the long `CASE` in both SELECT and HAVING.

---

## ⚠️ Common Mistakes

**1. `CASE` returning the id instead of a flag**
```sql
-- ❌ returns order_id, can't be aggregated into a percentage
CASE WHEN ... THEN order_id END
-- ✅ return 1/0, then wrap in SUM
SUM(CASE WHEN ... THEN 1 ELSE 0 END)
```

**2. Misplaced bracket in `BETWEEN`**
```sql
-- ❌ BETWEEN ends up inside TIME()
TIME(order_timestamp BETWEEN '11:00' AND '14:00')
-- ✅
TIME(order_timestamp) BETWEEN '11:00' AND '14:00'
```

**3. Filtering on rounded aliases**
```sql
-- ❌ a real 59.6% rounds to 60 and wrongly passes
HAVING peak_hour_percentage >= 60
-- ✅ filter on the raw expression, round only for display
HAVING SUM(CASE ...) / COUNT(*) * 100 >= 60
```

**4. Scale mismatch / wrong aggregate for rating completion**
```sql
-- ❌ adds up star values, not a count of rated orders
SUM(order_rating) / COUNT(order_id) >= 50
-- ✅ ratio on a 0-1 scale
COUNT(order_rating) / COUNT(order_id) >= 0.5
```

**5. Guessing the rounding of the output**
The expected output showed `67`, not `66.67`, so the percentage is rounded to 0 decimals. Always check the expected table, not just the problem text.

---

## ⏱️ Time Complexity

**O(n)** to scan and group the rows, plus **O(k log k)** to sort the `k` customers in the result.

---

## 🔑 Key Learnings

- `CASE` inside `SUM` (conditional aggregation) turns a condition into a countable number
- `COUNT(col)` skips NULLs while `COUNT(*)` doesn't, which is the easy way to measure "rated share"
- `AVG` ignores NULLs, so the average is over rated orders only
- In `HAVING`, filter on raw aggregates and use `ROUND` only in SELECT
- `ORDER BY 1, 4` works with column positions
- Passing the sample case doesn't mean it's correct. Hidden tests exposed the rounding bugs

---

## 📌 Final Query

```sql
SELECT  customer_id,
        COUNT(order_id) AS total_orders,
        ROUND((SUM(CASE WHEN TIME(order_timestamp) BETWEEN '11:00' AND '14:00'
                          OR TIME(order_timestamp) BETWEEN '18:00' AND '21:00'
                        THEN 1 ELSE 0 END) / COUNT(*)) * 100, 0) AS peak_hour_percentage,
        ROUND(AVG(order_rating), 2) AS average_rating
FROM restaurant_orders
GROUP BY customer_id
HAVING SUM(CASE WHEN TIME(order_timestamp) BETWEEN '11:00' AND '14:00'
                  OR TIME(order_timestamp) BETWEEN '18:00' AND '21:00'
                THEN 1 ELSE 0 END) / COUNT(*) * 100 >= 60
   AND AVG(order_rating) >= 4.0
   AND total_orders >= 3
   AND COUNT(order_rating) / COUNT(order_id) >= 0.5
ORDER BY 4 DESC, 1 DESC;
```
