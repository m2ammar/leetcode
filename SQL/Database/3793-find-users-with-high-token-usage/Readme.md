# 3793. Find Users with High Token Usage

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** `GROUP BY` · `HAVING` · `COUNT` · `AVG` · `MAX` · `ROUND` · `ORDER BY`

---

## ✅ Problem Summary

For each user in `prompts`, return:

- ✔️ the total number of prompts (`prompt_count`)
- ✔️ the average tokens per prompt, rounded to 2 decimals (`avg_tokens`)
- ✔️ only users with **at least 3 prompts**
- ✔️ only users with **at least one prompt above their own average**
- ✔️ ordered by `avg_tokens` descending, then `user_id` ascending

---

## 💡 Solution

```sql
SELECT user_id, COUNT(*) AS prompt_count, ROUND(AVG(tokens), 2) AS avg_tokens
FROM prompts
GROUP BY user_id
HAVING COUNT(*) >= 3
       AND AVG(tokens) < MAX(tokens)
ORDER BY avg_tokens DESC, user_id ASC;
```

---

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `GROUP BY user_id` | Collapses all of a user's prompts into one group |
| `COUNT(*) AS prompt_count` | Number of prompts in the group |
| `ROUND(AVG(tokens), 2)` | Average tokens per prompt, 2 decimals |
| `HAVING COUNT(*) >= 3` | Drops users with fewer than 3 prompts |
| `HAVING AVG(tokens) < MAX(tokens)` | Keeps users with at least one prompt above their average |
| `ORDER BY avg_tokens DESC, user_id ASC` | Highest average first, ties broken by smaller `user_id` |

---

## 🤔 Why `MAX(tokens)` for "at least one"?

"At least one prompt is above the average" sounds like a row-by-row check, but it is not needed:

- If **any** prompt is above the average, the **largest** prompt is certainly above it too.
- If the largest prompt is **not** above the average, **no** prompt is.

So "does any prompt beat the average?" is the same question as "does the biggest prompt beat the average?", which is `MAX(tokens) > AVG(tokens)`.

`HAVING` runs once per group, and `MAX(tokens)` squeezes the group into a single number, so it compares two numbers per user.

| user_id | tokens | AVG | MAX | MAX > AVG? |
|---|---|---|---|---|
| 1 | 120, 80, 200 | 133.33 | 200 | ✅ |
| 3 | 300, 250, 180, 220 | 237.5 | 300 | ✅ |
| (test) | 10, 10, 10 | 10 | 10 | ❌ nothing above average |
| (test) | 10, 10, 40 | 20 | 40 | ✅ |

---

## 🧱 Why not a subquery or window function?

| Approach | Idea | Verdict |
|---|---|---|
| `HAVING ... MAX > AVG` | Compare two aggregates per group | ✅ shortest, no extra join |
| Subquery / join | Compute each user's average, then compare every row to it | Works, but more code for the same result |
| Window function | `AVG(tokens) OVER (PARTITION BY user_id)` per row, then filter | Works, but overkill for an Easy problem |

Same result, so I prefer the simplest query.

---

## 🧠 "At Least One / All" Pattern

| Condition | Use |
|---|---|
| At least one value **greater than** X | `MAX(col) > X` |
| At least one value **less than** X | `MIN(col) < X` |
| **All** values greater than X | `MIN(col) > X` |
| **All** values less than X | `MAX(col) < X` |

---

## ⚠️ Common Mistakes

**1. Comparing tokens to a count**

```sql
HAVING COUNT(*) >= 3 AND AVG(tokens) < COUNT(*)   -- wrong
```

`AVG(tokens)` is tokens per prompt and `COUNT(*)` is a number of prompts, so the comparison means nothing.

Fix: compare the average to the largest value in the group.

```sql
HAVING COUNT(*) >= 3 AND AVG(tokens) < MAX(tokens)
```

**2. Forgetting `ROUND`**

Without `ROUND(AVG(tokens), 2)` the output is `133.333333` instead of `133.33`.

**3. Using an aggregate in `WHERE`**

`WHERE COUNT(*) >= 3` is an error. `WHERE` filters rows before grouping, so conditions on aggregates belong in `HAVING`.

---

## ⏱️ Time Complexity

`O(n)` to scan and group the rows, plus the sort of the grouped result for `ORDER BY`.

---

## 🔑 Key Learnings

- `HAVING` filters **groups**, and each aggregate returns one value per group.
- "At least one above the average" is `MAX > AVG`: check the extreme, not every row.
- Always compare like with like (tokens vs tokens, not tokens vs prompt count).
- Round in the `SELECT`, and the alias can then be used in `ORDER BY`.

---

## 🏁 Final Query

```sql
SELECT user_id, COUNT(*) AS prompt_count, ROUND(AVG(tokens), 2) AS avg_tokens
FROM prompts
GROUP BY user_id
HAVING COUNT(*) >= 3
       AND AVG(tokens) < MAX(tokens)
ORDER BY avg_tokens DESC, user_id ASC;
```
