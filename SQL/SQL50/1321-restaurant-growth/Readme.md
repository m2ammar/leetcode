# 1321. Restaurant Growth

![Difficulty](https://img.shields.io/badge/Difficulty-Medium-orange)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-brightgreen)

**Concepts:** Derived Table · GROUP BY · CTE · Window Functions (SUM/AVG OVER) · ROW_NUMBER() · Moving Average

---

## ✅ Problem Summary

- Every customer visit has a `visited_on` date and an `amount` paid.
- Multiple customers can visit on the same date.
- Compute a **7-day moving average** of total daily amount: for each day, sum/average the current day plus the 6 days before it.
- Only return rows once a full 7-day window is available (i.e., starting from the 7th day of data).
- `average_amount` rounded to 2 decimal places.
- Order results by `visited_on` ascending.

---

## 🧠 Solution

```sql
With cte as (
    select t.visited_on as visited_on,
        sum(t.amount) Over (Order by t.visited_on Rows BETWEEN 6 PRECEding and CURRENT ROW) as amount,
        round(avg(t.amount) OVER (Order by t.visited_on ROWS BETWEEN 6 PRECEDING AND  CURRENT ROW), 2) as average_amount,
        ROW_NUMBER() OVER (ORDER BY t.visited_on) as num
    from (Select visited_on, sum(amount) as amount from Customer group by visited_on) as t
)

select visited_on, amount, average_amount
from cte
where num >= 7;
```

---

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `Select visited_on, sum(amount) ... group by visited_on` (innermost derived table `t`) | Collapses multiple customers on the same date into **one row per day**, with total amount for that day. Required because raw rows are per-customer-visit, not per-day. |
| `sum(t.amount) OVER (ORDER BY t.visited_on ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)` | Running 7-row window sum, ordered by date — the "moving" total for the current day and the 6 before it. |
| `round(avg(t.amount) OVER (...), 2)` | Same window, but averaged instead of summed, rounded to 2 decimals. |
| `ROW_NUMBER() OVER (ORDER BY t.visited_on)` | Labels each day 1, 2, 3... in date order — used to detect when a *full* 7-day window exists. |
| `WITH cte as (...)` | Wraps the windowed calculation so it can be filtered afterward — window functions can't be filtered by WHERE in the same SELECT they're computed in. |
| `where num >= 7` | Keeps only rows from the 7th day of data onward, since earlier rows don't yet have 6 full days behind them. |

---

## 🤔 Why a derived table + CTE (two layers)?

The query needs three distinct stages, each depending on the last:

```
Customer (per-visit rows, dates can repeat)
        │  GROUP BY visited_on
        ▼
   derived table t (one row per day)
        │  window functions (SUM/AVG/ROW_NUMBER)
        ▼
        cte (daily totals + running window + row position)
        │  WHERE num >= 7
        ▼
   final result (only rows with a full 7-day window)
```

Window functions can't run on top of a `GROUP BY` in the same `SELECT`, and their results can't be filtered by `WHERE` in the same `SELECT` either — both are resolved *after* `WHERE` runs. So each transformation needs its own layer: derived table for the grouping, CTE for the windowing, outer query for the filter.

**Sample result (`t`, after grouping):**

| visited_on | amount |
|---|---|
| 2019-01-01 | 100 |
| 2019-01-02 | 110 |
| ... | ... |
| 2019-01-10 | 280 *(John + Jade combined)* |

---

## ⚠️ Why not filter on `visited_on >= '2019-01-07'` instead of `ROW_NUMBER()`?

A hardcoded date filter only works by coincidence — it happens to match "the 7th day" *only* because this particular dataset has no gaps and starts on Jan 1. `ROW_NUMBER()` counts **row position**, not calendar values, so `num >= 7` correctly means "a full 7-day window exists" regardless of what the actual dates are, whether they span multiple months/years, or whether some days are missing entirely.

---

## 🐛 Common Mistakes

**1. Running the window function directly on `Customer` without grouping first**
```sql
-- ❌ Wrong: counts 7 *rows* (customer visits), not 7 *days*
sum(amount) OVER (ORDER BY visited_on ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)
FROM Customer
```
Since `visited_on` can repeat (multiple customers, same day), "7 preceding rows" no longer equals "7 preceding days."
```sql
-- ✅ Fixed: group into one row per day first, then window over that
FROM (SELECT visited_on, SUM(amount) AS amount FROM Customer GROUP BY visited_on) t
```

**2. Missing `ORDER BY` inside `OVER()`**
```sql
-- ❌ Wrong: "6 PRECEDING" is meaningless without a defined row order
SUM(amount) OVER (ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)
```
```sql
-- ✅ Fixed
SUM(amount) OVER (ORDER BY visited_on ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)
```

**3. Filtering with a hardcoded date instead of row position**
```sql
-- ❌ Fragile: only correct because this dataset has no date gaps
WHERE visited_on >= '2019-01-07'
```
```sql
-- ✅ Generalizes to any date range or gaps
WHERE num >= 7   -- num = ROW_NUMBER() OVER (ORDER BY visited_on)
```

---

## ⏱️ Time Complexity

O(n log n) — dominated by the `GROUP BY` and the `ORDER BY` inside the window functions (sorting daily rows). The window computation itself is O(n) given a sorted order.

---

## 🔑 Key Learnings

- Window functions operate on rows as given — if the grain of the data isn't what the problem needs (per-day here), aggregate first.
- `ROWS BETWEEN 6 PRECEDING AND CURRENT ROW` needs an `ORDER BY` inside `OVER()` to mean anything.
- Window function results can't be filtered in the same `SELECT` — wrap in a CTE/derived table and filter in the outer query.
- Prefer filtering on a computed row position (`ROW_NUMBER()`) over a literal value from the dataset (like a specific date) when the filter is really about *position*, not *value* — it keeps the query correct for any input.

---

## 🏁 Final Query

```sql
With cte as (
    select t.visited_on as visited_on,
        sum(t.amount) Over (Order by t.visited_on Rows BETWEEN 6 PRECEding and CURRENT ROW) as amount,
        round(avg(t.amount) OVER (Order by t.visited_on ROWS BETWEEN 6 PRECEDING AND  CURRENT ROW), 2) as average_amount,
        ROW_NUMBER() OVER (ORDER BY t.visited_on) as num
    from (Select visited_on, sum(amount) as amount from Customer group by visited_on) as t
)

select visited_on, amount, average_amount
from cte
where num >= 7;
```
