# 3521. Find Product Recommendation Pairs

![Difficulty](https://img.shields.io/badge/Difficulty-Medium-orange)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** `Self JOIN` · `COUNT(DISTINCT)` · `GROUP BY` · `HAVING` · `ORDER BY`

---

## Problem Summary

Given the `ProductPurchases` and `ProductInfo` tables, identify product pairs frequently purchased together.

- Return distinct product pairs where `product1_id < product2_id`.
- Count the distinct customers who purchased both products.
- Include only pairs purchased by **at least 3 different customers**.
- Return both products' categories.
- Sort by customer count descending, then by both product IDs ascending.

---

## Solution

```sql
SELECT
    p1.product_id AS product1_id,
    p2.product_id AS product2_id,
    p4.category AS product1_category,
    p3.category AS product2_category,
    COUNT(DISTINCT p1.user_id) AS customer_count
FROM ProductPurchases AS p1
JOIN ProductPurchases AS p2
    ON p1.user_id = p2.user_id
    AND p1.product_id < p2.product_id
JOIN ProductInfo AS p3
    ON p2.product_id = p3.product_id
JOIN ProductInfo AS p4
    ON p1.product_id = p4.product_id
GROUP BY product1_id, product2_id
HAVING COUNT(DISTINCT p1.user_id) >= 3
ORDER BY customer_count DESC, product1_id ASC, product2_id ASC;
```

---

## Breakdown

| Clause | Purpose |
|---|---|
| `ProductPurchases` self-join | Finds products bought by the same customer |
| `p1.user_id = p2.user_id` | Matches purchases belonging to the same customer |
| `p1.product_id < p2.product_id` | Prevents identical and reversed product pairs |
| Two `ProductInfo` joins | Retrieves the category of each product |
| `COUNT(DISTINCT p1.user_id)` | Counts unique customers for each pair |
| `GROUP BY product1_id, product2_id` | Groups purchases by product pair |
| `HAVING COUNT(DISTINCT p1.user_id) >= 3` | Keeps pairs purchased by at least three customers |
| `ORDER BY` | Applies the required result ordering |

---

## Why Use a Self-Join?

A self-join compares the purchase records of a customer against their other purchase records.

For example, if customer 1 purchased products `101`, `102`, and `103`, the join generates:

| product1_id | product2_id |
|---:|---:|
| 101 | 102 |
| 101 | 103 |
| 102 | 103 |

The condition `p1.product_id < p2.product_id` ensures each pair appears in only one direction.

## Why `COUNT(DISTINCT)`?

The recommendation depends on the number of **different customers**, not the quantity purchased.

`COUNT(DISTINCT p1.user_id)` counts each customer once for a given product pair.

## Why `HAVING` Instead of `WHERE`?

`WHERE` filters individual rows before grouping. `HAVING` filters groups after aggregate calculations.

Since the requirement is to retain product pairs with at least three customers, `HAVING` is the appropriate clause.

---

## Complexity

Let \(n\) be the number of purchase records.

- **Time:** Depends on the database execution plan; self-join processing and grouping can be more expensive than a single table scan.
- **Space:** Depends on the number of generated product pairs and the grouping strategy.

---

## Key Learnings

- Self-joins can identify items purchased together by the same customer.
- An inequality condition can eliminate reversed pairs.
- `COUNT(DISTINCT ...)` counts unique customers rather than purchase quantities.
- `GROUP BY` and `HAVING` identify frequently occurring product pairs.
- Joining a lookup table twice retrieves attributes for both members of a pair.

---

**LeetCode:** 3521 — Find Product Recommendation Pairs  
**Language:** MySQL  
**Result:** Accepted — 11/11 test cases passed.
