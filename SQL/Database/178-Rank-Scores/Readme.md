# 178. Rank Scores

![Difficulty](https://img.shields.io/badge/Difficulty-Medium-orange)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-brightgreen)

**Concepts:** `DENSE_RANK()` · `OVER()` · `ORDER BY` · Window Functions · Reserved Words

---

## ✅ Problem Summary

- Rank every score in the `Scores` table from highest to lowest
- Tied scores must share the **same rank**
- Ranks must be **consecutive**, with no gaps after ties
- Return `score` and `rank`, sorted by `score` in descending order

---

## 🧩 Solution

```sql
SELECT score,
       DENSE_RANK() OVER (ORDER BY score DESC) AS `rank`
FROM Scores
ORDER BY score DESC;
```

---

## 🔍 Breakdown

| Clause | What it does |
|---|---|
| `SELECT score` | Returns each score as-is |
| `DENSE_RANK()` | Assigns a rank where ties share a rank and there are no gaps |
| `OVER (ORDER BY score DESC)` | Defines the window: rank rows from highest score to lowest |
| `AS \`rank\`` | Names the output column; backticks are required because `rank` is reserved in MySQL 8.0+ |
| `FROM Scores` | Source table |
| `ORDER BY score DESC` | Sorts the final output (the `OVER` clause does not guarantee output order) |

---

## 🤔 Why `DENSE_RANK()`?

The `Scores` table has two columns:

- `id`: unique row identifier
- `score`: a decimal with two digits after the point

The ranking depends only on `score`, so the window orders by that column.

```
score:  4    4    3.85   3.65   3.65   3.5
rank:   1    1     2      3      3      4
        └────┘            └──────┘
       tie, same rank    tie, same rank, and no gap between 1 → 2 → 3 → 4
```

Sample result:

| score | rank |
|---|---|
| 4 | 1 |
| 4 | 1 |
| 3.85 | 2 |
| 3.65 | 3 |
| 3.65 | 3 |
| 3.5 | 4 |

---

## 🚫 Why not a correlated subquery?

```sql
SELECT s1.score,
       (SELECT COUNT(DISTINCT s2.score)
        FROM Scores s2
        WHERE s2.score >= s1.score) AS `rank`
FROM Scores s1
ORDER BY s1.score DESC;
```

This works too: the rank of a score is the count of distinct scores greater than or equal to it. But it re-scans the table for every row (O(n²)), and it is harder to read. `DENSE_RANK()` says exactly what it means and needs a single sort.

---

## 📊 Ranking Functions at a Glance

For scores `4, 4, 3.85, 3.65`:

| Function | Result | Behavior on ties |
|---|---|---|
| `ROW_NUMBER()` | 1, 2, 3, 4 | No ties, always unique |
| `RANK()` | 1, 1, 3, 4 | Ties share a rank, **skips** the next numbers |
| `DENSE_RANK()` | 1, 1, 2, 3 | Ties share a rank, **no gaps** |

---

## ⚠️ Common Mistakes

### 1. Using `rank` as an alias without backticks

```sql
DENSE_RANK() OVER (ORDER BY score DESC) AS rank   -- syntax error
```

Fix:

```sql
DENSE_RANK() OVER (ORDER BY score DESC) AS `rank`
```

### 2. Using `RANK()` instead of `DENSE_RANK()`

```sql
RANK() OVER (ORDER BY score DESC)   -- gives 1, 1, 3, 4 (gap after the tie)
```

The problem requires consecutive ranks, so use `DENSE_RANK()`.

### 3. Using single quotes for the alias

```sql
AS 'rank'
```

This is accepted by MySQL, but single quotes are meant for string values. Backticks are the correct way to escape identifiers.

---

## ⏱️ Time Complexity

**O(n log n)**: dominated by sorting for the window function and the final `ORDER BY`.

---

## 🔑 Key Learnings

- `rank` is a reserved word in MySQL 8.0+; escape it with backticks
- `DENSE_RANK()` = ties share a rank, no gaps; `RANK()` skips numbers after ties
- `OVER (ORDER BY ...)` defines the ranking order but does not sort the output; add a separate `ORDER BY`
- A TLE on a tiny table is usually judge noise: resubmit before rewriting anything
- The pre-window-function approach (correlated `COUNT(DISTINCT ...)`) is worth knowing for understanding, not for performance

---

## 🏁 Final Query

```sql
SELECT score,
       DENSE_RANK() OVER (ORDER BY score DESC) AS `rank`
FROM Scores
ORDER BY score DESC;
```
