# 1084. Sales Analysis III

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** JOIN · GROUP BY · HAVING · MIN() · MAX()

---

## ✅ Problem Summary
- Report products that were **only** sold between `2019-01-01` and `2019-03-31` (inclusive)
- A product with even one sale outside that window must be excluded
- Return `product_id` and `product_name`

---

## 💡 Solution
```sql
SELECT p.product_id, p.product_name
FROM Product AS p
JOIN Sales AS s
    ON p.product_id = s.product_id
GROUP BY p.product_id
HAVING MIN(s.sale_date) >= '2019-01-01' AND MAX(s.sale_date) <= '2019-03-31';
```

---

## 🧩 Breakdown

| Clause | Purpose |
|---|---|
| `JOIN Sales ON p.product_id = s.product_id` | Bring in every sale row for each product |
| `GROUP BY p.product_id` | Collapse all sale rows for a product into one group, so we can inspect the full spread of its dates at once |
| `HAVING MIN(s.sale_date) >= '2019-01-01'` | Confirms the *earliest* sale isn't before Q1 2019 |
| `HAVING MAX(s.sale_date) <= '2019-03-31'` | Confirms the *latest* sale isn't after Q1 2019 |

---

## 🤔 Why MIN/MAX + HAVING?

`Product` and `Sales` share `product_id`. One product can have many sale rows spread across many dates.

```
Product Sales
+----+ +-----------+------------+
| id |------<| product_id| sale_date |
+----+ +-----------+------------+
```


Filtering the date in `WHERE` only removes individual *rows* — it can't tell you whether a product also has other sales sitting outside the range, because those rows get thrown away before you ever look at them.

Grouping by `product_id` first keeps every sale row for that product visible. Then `MIN(sale_date)` and `MAX(sale_date)` give you the two extreme edges of that product's entire sales history. If both edges sit inside Q1 2019, every date in between must too — there's no way for a middle value to escape past its own extremes.

Sample result for product 1 (S8):

​```
sale_date
----------
2019-01-21   <- only sale, so MIN = MAX = 2019-01-21, both inside range → included
​```

---

## ⚠️ Why not filter by WHERE first?

```sql
-- Wrong: only checks if a product HAD a sale in Q1, not if ALL its sales were in Q1
SELECT p.product_id, p.product_name
FROM Product AS p
JOIN Sales AS s ON p.product_id = s.product_id
WHERE s.sale_date BETWEEN '2019-01-01' AND '2019-03-31';
```
This returns any product with *at least one* Q1 sale — including product 2 (G4), which also sold in June and shouldn't qualify. `WHERE` filters rows before grouping, so out-of-range rows never get a chance to disqualify their product.

---

## 🐛 Common Mistakes

**Mistake: comparing MIN/MAX to a number instead of a date boundary**
```sql
HAVING MIN(sale_date) = 1  -- meaningless, dates aren't compared to integers
```
Fix: compare against actual date literals, and use `>=` / `<=` since you're checking a range, not equality.

**Mistake: filtering with WHERE instead of HAVING**
```sql
WHERE sale_date BETWEEN '2019-01-01' AND '2019-03-31'
```
Fix: `WHERE` removes rows before grouping — you need `HAVING` so the condition applies to the aggregated MIN/MAX per group, after all rows are considered.

---

## ⏱ Time Complexity
O(n) — one pass to join, one pass to group and aggregate, where n = number of Sales rows.

---

## 🔑 Key Learnings
- `WHERE` filters rows before grouping; `HAVING` filters groups after aggregation — they answer different questions
- "Only" in a problem statement is a strong signal to check MIN/MAX (or COUNT) across the *whole* group, not to filter individual rows
- MIN and MAX being inside a range is sufficient to prove every value in between is inside that range too

---

## 🧠 Final Query
```sql
SELECT p.product_id, p.product_name
FROM Product AS p
JOIN Sales AS s
    ON p.product_id = s.product_id
GROUP BY p.product_id
HAVING MIN(s.sale_date) >= '2019-01-01' AND MAX(s.sale_date) <= '2019-03-31';
```
