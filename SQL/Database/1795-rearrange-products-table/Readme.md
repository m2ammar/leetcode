# 1795. Rearrange Products Table

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** `UNION ALL` · `String Literals` · `Column Aliasing` · `IS NOT NULL` · `Wide to Long (Unpivot)`

---

## ✅ Problem Summary

Given `Products(product_id, store1, store2, store3)`, rearrange it so that:

- ✅ Each row is `(product_id, store, price)`
- ✅ The `store` value is the name of the column the price came from
- ✅ If a product isn't available in a store (`NULL`), that combination is **excluded**
- ✅ Rows can be returned in any order

---

## 💡 Solution

```sql
SELECT product_id, 'store1' AS store, store1 AS price
FROM Products
WHERE store1 IS NOT NULL

UNION ALL

SELECT product_id, 'store2' AS store, store2 AS price
FROM Products
WHERE store2 IS NOT NULL

UNION ALL

SELECT product_id, 'store3' AS store, store3 AS price
FROM Products
WHERE store3 IS NOT NULL;
```

---

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `SELECT product_id` | Carries the product identifier into every output row |
| `'store1' AS store` | A string literal; becomes the *value* of the `store` column |
| `store1 AS price` | Renames the store's column to `price` so all three branches share the same schema |
| `WHERE store1 IS NOT NULL` | Skips products not sold in that store (applied per branch) |
| `UNION ALL` | Stacks the three result sets into one, keeping every row |

---

## 🤔 Why one SELECT per store?

A single `SELECT` returns **one output row per input row**. Each product must appear up to **three** times, so we need three queries stacked together.

```
Products (wide)                 Result (long)
product_id | store1 store2 store3      product_id | store  | price
-----------+----------------------     -----------+--------+------
     0     |  95    100    105    -->        0     | store1 |  95
     1     |  70    null   80                0     | store2 | 100
                                             0     | store3 | 105
                                             1     | store1 |  70
                                             1     | store3 |  80
```

---

## 🆚 Why not a CROSS JOIN with CASE?

An alternative is to cross join with a derived table of store names and pick the price with `CASE`:

```sql
SELECT p.product_id, s.store,
       CASE s.store WHEN 'store1' THEN p.store1
                    WHEN 'store2' THEN p.store2
                    ELSE p.store3 END AS price
FROM Products p
CROSS JOIN (SELECT 'store1' AS store UNION ALL
            SELECT 'store2' UNION ALL
            SELECT 'store3') s
HAVING price IS NOT NULL;
```

It works, but it's harder to read and still needs a `UNION ALL` to build the store list. The three-branch `UNION ALL` is clearer and each branch is easy to verify on its own.

---

## 📚 UNION vs UNION ALL at a Glance

| | `UNION` | `UNION ALL` |
|---|---|---|
| Removes duplicates | Yes | No |
| Extra sort/dedupe cost | Yes | No |
| Use when | Duplicates must be merged | Rows are already distinct (like here, thanks to the `store` literal) |

---

## ⚠️ Common Mistakes

**1. Aliasing several columns to the same name in one SELECT**

```sql
SELECT product_id, store1 AS store, store2 AS store, store3 AS store
FROM Products;
```

This returns three columns that share a name. It does not create rows. Use one `SELECT` per store and stack them.

**2. Referencing a `price` column that doesn't exist**

```sql
WHERE price IS NOT NULL   -- unknown column
```

`price` only exists in the *output*. Filter on the real column (`store1`, `store2`, `store3`) inside each branch.

**3. Adjacent string literals get concatenated**

```sql
SELECT 'store1' 'store2' 'store3' AS store   -- one value: 'store1store2store3'
```

Fix: one literal per `SELECT`.

---

## ⏱️ Time Complexity

**O(3n) → O(n)**: the table is scanned once per store column (3 scans), which is linear in the number of rows.

---

## 🔑 Key Learnings

- MySQL has no `UNPIVOT`; wide-to-long is done with one `SELECT` per column + `UNION ALL`
- A string literal in the `SELECT` list is how you turn a column *name* into a column *value*
- The `NULL` filter belongs **inside each branch**, not once on the whole table
- Use `UNION ALL` unless you specifically need duplicates removed
- With many columns, generate the query programmatically, or use `pandas.melt()`

---

## 🏁 Final Query

```sql
SELECT product_id, 'store1' AS store, store1 AS price
FROM Products
WHERE store1 IS NOT NULL

UNION ALL

SELECT product_id, 'store2' AS store, store2 AS price
FROM Products
WHERE store2 IS NOT NULL

UNION ALL

SELECT product_id, 'store3' AS store, store3 AS price
FROM Products
WHERE store3 IS NOT NULL;
```
