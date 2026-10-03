# 3220. Odd and Even Transactions

![Difficulty](https://img.shields.io/badge/Difficulty-Medium-orange)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** `SUM` · `CASE WHEN` · `MOD` · `GROUP BY` · `ORDER BY` · `Conditional Aggregation`

---

## ✅ Problem Summary

Given `transactions(transaction_id, amount, transaction_date)`, return for each day:

- ✅ `odd_sum`: the total of amounts that are **odd**
- ✅ `even_sum`: the total of amounts that are **even**
- ✅ `0` (not `NULL`) when a day has no odd or no even amounts
- ✅ Rows ordered by `transaction_date` ascending

---

## 💡 Solution

```sql
SELECT transaction_date,
       SUM(CASE WHEN MOD(amount, 2) != 0 THEN amount ELSE 0 END) AS odd_sum,
       SUM(CASE WHEN MOD(amount, 2) = 0 THEN amount ELSE 0 END) AS even_sum
FROM transactions
GROUP BY transaction_date
ORDER BY transaction_date;
```

---

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `MOD(amount, 2)` | Remainder after dividing by 2: `0` for even, `1` for odd |
| `CASE WHEN ... THEN amount ELSE 0 END` | Gives each row its amount if it matches, otherwise 0 |
| `SUM(CASE ...)` | Adds up only the matching amounts for each group |
| `AS odd_sum` / `AS even_sum` | One `SUM(CASE ...)` per output column |
| `GROUP BY transaction_date` | Collapses rows to one per day |
| `ORDER BY transaction_date` | Sorts days ascending |

---

## 🤔 Why conditional aggregation?

The **amount** (not the transaction ID) decides odd or even. Each day needs **two totals in one row**, so each column gets its own `SUM(CASE ...)`.

```
transaction_date | amount | odd?  even?        odd_sum | even_sum
-----------------+--------+------------        --------+---------
2024-07-01       |  150   |  0     150
2024-07-01       |  200   |  0     200   -->     75    |   350
2024-07-01       |   75   | 75      0
```

Because the `ELSE` branch contributes `0`, a day with no odd amounts still sums to `0`, not `NULL`.

---

## 🆚 Why not filter with WHERE and JOIN?

Another approach is two separate queries (one filtered to odd, one to even), joined on the date:

```sql
SELECT t.transaction_date, ...
FROM (SELECT DISTINCT transaction_date FROM transactions) t
LEFT JOIN (... WHERE MOD(amount,2) != 0 GROUP BY ...) o ON ...
LEFT JOIN (... WHERE MOD(amount,2) = 0  GROUP BY ...) e ON ...;
```

It works, but it scans the table several times and needs `COALESCE` to turn missing values into 0. Conditional aggregation does it in **one pass** with `ELSE 0` handling the zeros.

---

## 📚 Conditional Aggregation at a Glance

| Goal | Pattern |
|---|---|
| Sum only matching rows | `SUM(CASE WHEN cond THEN col ELSE 0 END)` |
| Count only matching rows | `SUM(CASE WHEN cond THEN 1 ELSE 0 END)` |
| Count with NULL-skipping | `COUNT(CASE WHEN cond THEN col END)` |

---

## ⚠️ Common Mistakes

**1. Returning a label instead of a value**

```sql
SUM(CASE WHEN MOD(amount, 2) = 0 THEN 'even_sum' END)
```

`SUM` needs numbers. Return `amount`, and put the name in `AS even_sum`.

**2. `ELSE` outside the `CASE`, or a `CASE` with no `END`**

```sql
SUM(CASE WHEN ... THEN ...) ... ELSE 0
```

The shape is always `CASE WHEN ... THEN ... ELSE ... END`, with `ELSE 0` inside.

**3. Forgetting `GROUP BY`**

Without it, `SUM` collapses the whole table into one row and `transaction_date` isn't aggregated.

**4. Trying one `CASE` for both columns**

A `CASE` returns one value per row, and each `SUM` makes one column. Two output columns need two `SUM(CASE ...)`.

---

## ⏱️ Time Complexity

**O(n)**: one scan of the table, then grouping and sorting the distinct dates.

---

## 🔑 Key Learnings

- Odd or even is a property of the **amount**, tested with `MOD(amount, 2)`
- `SUM(CASE ...)` is how you get several filtered totals in a single pass
- `ELSE 0` is what satisfies the "display as 0" rule
- One output column = one aggregate expression
- `amount % 2` is a shorthand for `MOD(amount, 2)` in MySQL

---

## 🏁 Final Query

```sql
SELECT transaction_date,
       SUM(CASE WHEN MOD(amount, 2) != 0 THEN amount ELSE 0 END) AS odd_sum,
       SUM(CASE WHEN MOD(amount, 2) = 0 THEN amount ELSE 0 END) AS even_sum
FROM transactions
GROUP BY transaction_date
ORDER BY transaction_date;
```
