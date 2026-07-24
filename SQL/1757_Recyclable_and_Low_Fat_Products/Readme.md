# 1757. Recyclable and Low Fat Products

## Difficulty
Easy

## Topic
SQL

## Concepts
- SELECT
- WHERE
- AND operator
- Filtering rows

---

## Problem Summary

Find the IDs of products that satisfy **both** conditions:

- The product is low fat.
- The product is recyclable.

Return only the `product_id`.

---

## Solution

See `solution.sql`.

---

## Explanation

```sql
SELECT product_id
FROM Products
WHERE low_fats = 'Y'
  AND recyclable = 'Y';
```

### Breakdown

### SELECT product_id

Returns only the required column.

### FROM Products

Reads data from the `Products` table.

### WHERE

Filters rows based on given conditions.

### low_fats = 'Y'

Keeps only products marked as low fat.

### AND recyclable = 'Y'

The `AND` operator requires **both** conditions to be true.

Only products that are both:

- Low fat
- Recyclable

are returned.

---

## Why use AND?

There are two conditions in the problem statement.

A product must satisfy **both** requirements.

Truth table:

| Low Fat | Recyclable | Returned? |
|---------|------------|-----------|
| Y | Y | ✅ |
| Y | N | ❌ |
| N | Y | ❌ |
| N | N | ❌ |

Since both conditions are required, `AND` is the correct operator.

---

## Time Complexity

O(n)

The database scans each row once.

---

## Key Learnings

- Use `WHERE` to filter rows.
- Use `AND` when multiple conditions must all be true.
- SQL compares string values using single quotes (`'Y'`).
- Return only the columns requested by the problem.

---

## Final Query

```sql
SELECT product_id
FROM Products
WHERE low_fats = 'Y'
  AND recyclable = 'Y';
```
