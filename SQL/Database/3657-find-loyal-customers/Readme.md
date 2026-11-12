# 3657. Find Loyal Customers

![Difficulty](https://img.shields.io/badge/Difficulty-Medium-orange)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-brightgreen)

**Concepts:** `GROUP BY` · `HAVING` · `CASE WHEN` · `SUM` · `COUNT` · `MIN` · `MAX` · `DATEDIFF`

---

## ✅ Problem Summary

Return the `customer_id` of every **loyal** customer, ordered by `customer_id` ascending. A customer is loyal only if **all** of these hold:

- ✅ At least **3 purchase** transactions
- ✅ Active for at least **30 days** (first transaction to last transaction)
- ✅ Refund rate **strictly less than 20%**, where refund rate = refunds ÷ (purchases + refunds)

---

## 🧩 Solution

```sql
SELECT customer_id
FROM customer_transactions
GROUP BY customer_id
HAVING DATEDIFF(MAX(transaction_date), MIN(transaction_date)) >= 30
   AND SUM(CASE WHEN transaction_type = 'purchase' THEN 1 ELSE 0 END) >= 3
   AND SUM(CASE WHEN transaction_type = 'refund' THEN 1 ELSE 0 END) / COUNT(*) < 0.2
ORDER BY customer_id ASC;
```

---

## 🔍 Breakdown

| Clause | What it does |
|---|---|
| `GROUP BY customer_id` | Collapses all rows of a customer into one group, so aggregates are computed per customer |
| `DATEDIFF(MAX(date), MIN(date)) >= 30` | Gap in days between the customer's last and first transaction; must be at least 30 |
| `SUM(CASE WHEN ... 'purchase' ...) >= 3` | Counts only purchase rows (1 per purchase, 0 otherwise) and requires at least 3 |
| `SUM(CASE WHEN ... 'refund' ...) / COUNT(*) < 0.2` | Refunds ÷ all transactions; must be strictly under 20% |
| `ORDER BY customer_id ASC` | Sorts the result ascending as required |

---

## 🤔 Why `HAVING` + conditional aggregation?

All three rules are about a customer's **whole group of rows**, not a single row, so they can't go in `WHERE`. `HAVING` filters groups after aggregation, and `SUM(CASE WHEN ...)` lets one `GROUP BY` count different row types separately.

```
customer 104's rows            →  one group  →  HAVING checks
purchase x5, refund x1             purchases = 5      (>= 3 ✅)
Jan 1 ... Mar 15                   days      = 73     (>= 30 ✅)
                                   refunds/total = 1/6 = 0.1667 (< 0.2 ✅)
```

| customer_id | purchases | refunds | days active | refund rate | loyal? |
|---|---|---|---|---|---|
| 101 | 4 | 0 | 46 | 0% | ✅ |
| 102 | 3 | 2 | 36 | 40% | ❌ |
| 103 | 3 | 0 | 2 | 0% | ❌ |
| 104 | 5 | 1 | 73 | 16.67% | ✅ |

---

## 🆚 Why not a CTE or subquery?

A CTE that computes `purchases`, `refunds`, `total` and `days_active` first and filters in an outer query also works, and can read more clearly with named columns. But everything here can be computed in one `GROUP BY`, so a single `HAVING` is shorter and avoids an extra layer.

---

## ⚠️ Common Mistakes

**1. Bare aggregates in `HAVING`**
```sql
HAVING MAX(transaction_date) AND MIN(transaction_date) AND COUNT(*)
```
A bare number is treated as true if non-zero, so almost everything passes. Every rule needs a comparison and a threshold.

**2. Aggregates inside `GROUP BY`**
```sql
GROUP BY customer_id, SUM(CASE ...)   -- error
```
`GROUP BY` takes columns. Aggregates belong in `HAVING` or `SELECT`.

**3. `COUNT(*)` for the purchase rule**
`COUNT(*)` counts purchases **and** refunds. The "at least 3 purchases" rule needs `SUM(CASE WHEN transaction_type = 'purchase' ...)`.

**4. Wrong ratio or direction**
```sql
SUM(CASE WHEN ... 'purchase' ...) / COUNT(*) > 20   -- purchase share, impossible threshold
```
Use the **refund** count, compare to `0.2` (not 20), and use `<`, since the rule is strictly less than 20%.

**5. `DATEDIFF` argument order**
`DATEDIFF(a, b)` returns `a - b` in MySQL. Put the later date (`MAX`) first, or the result is negative.

---

## ⏱️ Time Complexity

**O(n)** to scan and group the rows, plus **O(k log k)** to sort the `k` qualifying customers.

---

## 🔑 Key Learnings

- `HAVING` filters **groups**; every condition in it needs a comparison operator and a threshold
- `SUM(CASE WHEN ... THEN 1 ELSE 0 END)` counts rows of one type inside a single `GROUP BY`
- "Active period" = `DATEDIFF(MAX(date), MIN(date))`, measured in days, not months
- In MySQL, `/` already returns a decimal, so `1/6` is `0.1667`
- Check each condition counts **exactly the rows the rule talks about**

---

## 🏁 Final Query

```sql
SELECT customer_id
FROM customer_transactions
GROUP BY customer_id
HAVING DATEDIFF(MAX(transaction_date), MIN(transaction_date)) >= 30
   AND SUM(CASE WHEN transaction_type = 'purchase' THEN 1 ELSE 0 END) >= 3
   AND SUM(CASE WHEN transaction_type = 'refund' THEN 1 ELSE 0 END) / COUNT(*) < 0.2
ORDER BY customer_id ASC;
```
