# 1045. Customers Who Bought All Products

![Difficulty](https://img.shields.io/badge/Difficulty-Medium-yellow) ![Topic](https://img.shields.io/badge/Topic-SQL-blue) ![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** GROUP BY · HAVING · COUNT · DISTINCT · Scalar Subquery

---

## ✅ Problem Summary

- Return the `customer_id`s from `Customer` who bought **every** product listed in `Product`.
- `Customer` may contain duplicate rows (same customer buying the same product more than once).
- Result can be in any order.

---

## 🧠 Solution

```sql
SELECT customer_id
FROM Customer
GROUP BY customer_id
HAVING COUNT(DISTINCT product_key) = (SELECT COUNT(product_key) FROM Product);
```

---

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `GROUP BY customer_id` | Collapses the rows into one group per customer, so we can measure each customer's buying behavior individually. |
| `COUNT(DISTINCT product_key)` | Counts how many *unique* products each customer bought, ignoring duplicate purchases of the same product. |
| `(SELECT COUNT(product_key) FROM Product)` | A scalar subquery that computes the total number of products that exist, once, independent of any customer. |
| `HAVING ... = ...` | Filters groups (not rows) — keeps only the customers whose distinct-product count equals the total product count. |

---

## 🤔 Why GROUP BY + HAVING?

The question is really: "for each customer, does the set of products they bought equal the full set of products that exist?" That's a per-group condition, not a per-row condition — which is exactly what `GROUP BY` + `HAVING` is built for. `WHERE` can't be used here because `WHERE` filters rows *before* grouping and can't reference an aggregate like `COUNT(DISTINCT product_key)`.

The two tables relate through `product_key`, but only one side of the comparison actually needs it:

```
Customer                    Product
+-------------+------------+   +-------------+
| customer_id | product_key|   | product_key |
+-------------+------------+   +-------------+
     |                              |
     |-- grouped & counted          |-- counted directly
     v  (per customer)              v  (total universe)
COUNT(DISTINCT product_key)     COUNT(product_key)
```

Sample trace with the example data:

| customer_id | distinct products bought | total products | match? |
|---|---|---|---|
| 1 | {5, 6} → 2 | 2 | ✅ |
| 2 | {6} → 1 | 2 | ❌ |
| 3 | {5, 6} → 2 | 2 | ✅ |

---

## ⚠️ Why not a JOIN?

A tempting first instinct is to `LEFT JOIN Customer` to `Product` and filter somehow — but that join doesn't add any information here. Every `product_key` in `Customer` is already guaranteed (by the foreign key) to exist in `Product`, so joining just reproduces the same rows without helping identify "bought everything." The comparison we actually need — *count of what a customer bought* vs. *count of what exists* — is answered entirely by two independent counts, not by matching rows between the tables. A join only earns its place if you need columns from *both* tables in the output or the row-matching logic itself; neither is true here.

---

## 🚧 Common Mistakes

**Mistake 1 — comparing `customer_id` itself to a count**
```sql
-- Wrong: compares an identity (1, 2, 3...) to a quantity
HAVING customer_id = (SELECT COUNT(product_key) FROM Product)
```
✅ Fix: compare two *counts* — how many products this customer bought vs. how many exist in total.

**Mistake 2 — forgetting `DISTINCT` in the count**
```sql
-- Wrong: overcounts if a customer bought the same product twice
HAVING COUNT(product_key) = (SELECT COUNT(product_key) FROM Product)
```
✅ Fix: use `COUNT(DISTINCT product_key)` on the customer side, since the table can contain duplicate purchase rows.

**Mistake 3 — filtering with `WHERE` instead of `HAVING`**
```sql
-- Wrong: WHERE can't reference an aggregate, and runs before grouping
WHERE COUNT(DISTINCT product_key) = (SELECT COUNT(product_key) FROM Product)
```
✅ Fix: aggregate conditions on grouped data always belong in `HAVING`, not `WHERE`.

---

## ⏱️ Time Complexity

`O(n)` to scan and group the `Customer` table (n = number of rows), plus a constant-time scalar subquery on `Product`. With an index on `customer_id`, the grouping is efficient even at scale.

---

## 🔑 Key Learnings

- `HAVING` filters *groups*, `WHERE` filters *rows* — aggregate comparisons must go in `HAVING`.
- A scalar subquery (`SELECT COUNT(...) FROM ...`) is a clean way to inject a single external "target value" into a `HAVING` comparison.
- Always check for duplicate rows before trusting a plain `COUNT` — `COUNT(DISTINCT ...)` protects against overcounting.
- Not every problem needs a `JOIN`; sometimes two independent aggregates are all that's required.

---

## 🏁 Final Query

```sql
SELECT customer_id
FROM Customer
GROUP BY customer_id
HAVING COUNT(DISTINCT product_key) = (SELECT COUNT(product_key) FROM Product);
```
