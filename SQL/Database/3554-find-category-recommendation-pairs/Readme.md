# 3554. Find Category Recommendation Pairs

![Difficulty](https://img.shields.io/badge/Difficulty-Hard-red)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-brightgreen)

**Concepts:** CTE · GROUP BY · Self Join · HAVING · Multi-level ORDER BY

---

## ✅ Problem Summary

- Find every category pair where `category1 < category2`
- Count the **unique customers** who bought from both categories
- Keep only pairs with **at least 3** such customers
- Order by `customer_count` DESC, then `category1` ASC, then `category2` ASC

---

## 🧩 Solution

```sql
WITH cte AS (
    SELECT p.user_id,
           pif.category
    FROM ProductPurchases AS p
    JOIN ProductInfo AS pif
    ON p.product_id = pif.product_id
    GROUP BY p.user_id, pif.category
)

SELECT c1.category AS category1,
       c2.category AS category2,
       COUNT(*) AS customer_count
FROM cte AS c1
JOIN cte AS c2
ON c1.user_id = c2.user_id
WHERE c1.category < c2.category
GROUP BY c1.category, c2.category
HAVING customer_count >= 3
ORDER BY customer_count DESC, category1, category2;
```

---

## 🔍 Breakdown

| Clause | What it does |
|---|---|
| `JOIN ProductInfo` | Attaches a category to every purchase |
| `GROUP BY user_id, category` (in CTE) | Collapses to one row per (user, category) |
| `JOIN cte c2 ON c1.user_id = c2.user_id` | Pairs up the categories each user bought |
| `WHERE c1.category < c2.category` | Keeps one ordering per pair, no self-pairs |
| `GROUP BY c1.category, c2.category` | One group per category pair |
| `COUNT(*)` | Counts users, safe because the CTE is deduplicated |
| `HAVING customer_count >= 3` | Filters on the aggregate, so it can't go in WHERE |
| `ORDER BY` (3 levels) | Count DESC, then category1, then category2 |

---

## 🤔 Why dedupe in a CTE first?

A user can buy several products in the same category. In the example, user 2 bought Books 102 and 103 plus Clothing 201.

```
Without dedupe:           With dedupe:
(2, Books)    <- 102      (2, Books)
(2, Books)    <- 103      (2, Clothing)
(2, Clothing) <- 201
```

Without dedupe, the self-join makes two Books-Clothing rows for user 2 and `COUNT(*)` counts that customer twice. With one row per (user, category), each customer contributes exactly one row per pair.

---

## 🆚 Why not `COUNT(DISTINCT user_id)` instead?

Skipping the CTE and using `COUNT(DISTINCT c1.user_id)` at the end also works, but the self-join would then run on the larger, duplicated table. Deduplicating first keeps the join small and the logic easy to follow.

---

## ⚠️ Common Mistakes

**1. Not deduplicating before the self-join**
```sql
-- Wrong: counts a user once per product pair
JOIN ProductInfo ... (no GROUP BY)
```
Fix: `GROUP BY user_id, category` in the CTE.

**2. Using `<>` instead of `<`**
```sql
WHERE c1.category <> c2.category
```
This returns both (Books, Clothing) and (Clothing, Books). Fix: `c1.category < c2.category`.

**3. Forgetting the tiebreakers**
```sql
ORDER BY customer_count DESC
```
Ties come back in arbitrary order. Fix: add `category1, category2`.

---

## ⏱️ Time Complexity

Roughly O(N) for the join and dedupe, plus O(sum of k²) for the self-join, where k is the number of distinct categories per user.

---

## 🧠 Key Learnings

- "Unique customers" means checking where duplicates can sneak in before joining
- Reduce to the grain you need (one row per user per category) before pairing
- A self-join with `<` generates unordered pairs without duplicates
- Aggregate filters go in `HAVING`, not `WHERE`
- Read the whole ORDER BY rule: tiebreakers decide the output when counts tie

---

## 🏁 Final Query

```sql
WITH cte AS (
    SELECT p.user_id,
           pif.category
    FROM ProductPurchases AS p
    JOIN ProductInfo AS pif
    ON p.product_id = pif.product_id
    GROUP BY p.user_id, pif.category
)

SELECT c1.category AS category1,
       c2.category AS category2,
       COUNT(*) AS customer_count
FROM cte AS c1
JOIN cte AS c2
ON c1.user_id = c2.user_id
WHERE c1.category < c2.category
GROUP BY c1.category, c2.category
HAVING customer_count >= 3
ORDER BY customer_count DESC, category1, category2;
```
