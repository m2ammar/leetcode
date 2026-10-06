# 1393. Capital Gain/Loss

![Difficulty](https://img.shields.io/badge/Difficulty-Medium-orange)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-brightgreen)

**Concepts:** `SUM` · `CASE WHEN` · `GROUP BY` · Conditional Aggregation

---

## ✅ Problem Summary

Given a `Stocks` table of Buy/Sell operations, the query must return:

- ✅ One row per `stock_name`
- ✅ The total capital gain or loss for that stock, aliased as `capital_gain_loss`
- ✅ Gain/loss = total of all Sell prices minus total of all Buy prices
- ✅ Rows in any order

Every Buy is guaranteed a matching later Sell (and vice versa), so there are no open positions.

---

## 💡 Solution

```sql
SELECT stock_name,
       SUM(CASE WHEN operation = 'Sell' THEN price ELSE -price END) AS capital_gain_loss
FROM Stocks
GROUP BY stock_name;
```

---

## 🧩 Breakdown

| Clause | What it does |
| --- | --- |
| `FROM Stocks` | Reads every Buy/Sell row |
| `GROUP BY stock_name` | Collapses the rows into one group per stock |
| `CASE WHEN operation = 'Sell' THEN price` | A Sell adds its price to the total |
| `ELSE -price` | A Buy (the only other value) subtracts its price from the total |
| `SUM(...)` | Adds up the signed prices inside each group |
| `AS capital_gain_loss` | Names the output column as the problem requires |

---

## 🤔 Why Conditional Aggregation?

The explanation in the problem walks through each Buy → Sell pair, which makes it look like the rows must be matched up. They don't need to be. Because every Buy has a matching Sell:

```
sum of (Sell - Buy) per pair  =  sum of all Sells  -  sum of all Buys
```

Signing each row (+ for Sell, - for Buy) lets a single `SUM` do that subtraction.

Corona Masks, signed row by row:

| operation | price | signed value |
| --- | --- | --- |
| Buy | 10 | -10 |
| Sell | 1010 | +1010 |
| Buy | 1000 | -1000 |
| Sell | 500 | +500 |
| Buy | 1000 | -1000 |
| Sell | 10000 | +10000 |
| **Total** | | **9500** |

---

## 🚫 Why not a self-join (pair each Buy with its Sell)?

Pairing rows needs a join on `stock_name` plus a rule to match each Sell to the correct earlier Buy. With several trades per stock that gets messy: you would need to order by `operation_day` and number the trades, or use window functions. All of that work produces the same total the signed `SUM` gives in one pass, so conditional aggregation is simpler, shorter and harder to get wrong.

---

## 📋 Conditional Aggregation at a Glance

| Pattern | Example |
| --- | --- |
| `SUM(CASE ...)` | `SUM(CASE WHEN operation = 'Sell' THEN price ELSE -price END)` |
| `SUM(IF(...))` (MySQL) | `SUM(IF(operation = 'Sell', price, -price))` |
| Count with a condition | `SUM(CASE WHEN status = 'Paid' THEN 1 ELSE 0 END)` |

---

## ⚠️ Common Mistakes

**1. Using assignment operators inside CASE**

```sql
-- Wrong
SUM(CASE WHEN operation = 'Sell' THEN price += price ELSE price = price END)
```

Each `CASE` branch must evaluate to a value, not perform an action. `+=` is not valid in a MySQL `SELECT`, and a single `=` is a comparison, so `price = price` is always true and returns `1`. That would silently add 1 per Buy instead of subtracting its price.

```sql
-- Fix
SUM(CASE WHEN operation = 'Sell' THEN price ELSE -price END)
```

**2. Summing the price without the sign**

```sql
-- Wrong
SELECT stock_name, SUM(price) FROM Stocks GROUP BY stock_name;
```

This adds Buys and Sells together instead of subtracting the Buys.

**3. Forgetting the alias**

Without `AS capital_gain_loss` the column gets an auto-generated name that does not match the expected output.

---

## ⏱️ Time Complexity

One scan of the table plus grouping: **O(n)** with hash aggregation (**O(n log n)** if the engine sorts to group).

---

## 🧠 Key Learnings

- A `CASE` branch returns a value; it never assigns one.
- `=` in SQL compares; it does not assign.
- Negating a value inside `SUM` turns addition into subtraction for only the rows you choose.
- Read the problem's guarantees: the Buy/Sell matching guarantee is what removes the need to pair rows.
- `GROUP BY` already gives one row per stock, so a window function would only add extra rows to deduplicate.

---

## 🏁 Final Query

```sql
SELECT stock_name,
       SUM(CASE WHEN operation = 'Sell' THEN price ELSE -price END) AS capital_gain_loss
FROM Stocks
GROUP BY stock_name;
```
