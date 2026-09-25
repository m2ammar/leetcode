# 183. Customers Who Never Order

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** LEFT JOIN · Anti-Join · IS NULL · Aliasing

---

## ✅ Problem Summary

- Return the names of all customers who have **never placed an order**
- Every row in `Customers` must be considered, even if it has zero matches in `Orders`
- Result column must be named `Customers`
- Order of output doesn't matter

---

## 🧩 Solution

```sql
SELECT c.name AS Customers
FROM Customers AS c
LEFT JOIN Orders AS o
ON c.id = o.customerId
WHERE o.customerId IS NULL;
```

---

## 🔍 Breakdown

| Clause | What it does |
|---|---|
| `FROM Customers AS c` | Anchors the query — every customer row is kept no matter what |
| `LEFT JOIN Orders AS o ON c.id = o.customerId` | Attaches matching orders where they exist; fills `o.*` with `NULL` where a customer has none |
| `WHERE o.customerId IS NULL` | Keeps only the rows where the join found **no match** — i.e. customers with no orders |
| `SELECT c.name AS Customers` | Projects just the name, renamed to match the required output column |

---

## 🤔 Why LEFT JOIN?

`Customers` is the table you need **all rows from**, regardless of whether a match exists in `Orders`. `LEFT JOIN` guarantees that: unmatched rows still appear, with every column from the right table (`Orders`) set to `NULL`.

Join column: `Customers.id` ↔ `Orders.customerId`

```
Customers Orders
+----+-------+ +----+------------+
| id | name | | id | customerId |
+----+-------+ +----+------------+
| 1 | Joe | <----> | 2 | 1 |
| 2 | Henry | ----> NULL (no match)
| 3 | Sam | <----> | 1 | 3 |
| 4 | Max | ----> NULL (no match)
```


After the join, unmatched customers (Henry, Max) have `o.customerId = NULL` — that's the signal `WHERE` filters on.

Sample result:

| Customers |
|---|
| Henry |
| Max |

---

## ⚠️ Why not INNER JOIN or subquery (`NOT IN`)?

- **INNER JOIN** only keeps rows where both sides match — it would drop Henry and Max entirely, since they have no matching `customerId`. That's the opposite of what's needed here.
- **`NOT IN` subquery** (`WHERE c.id NOT IN (SELECT customerId FROM Orders)`) also works, but breaks silently if `Orders.customerId` ever contains a `NULL` — `NOT IN` against a list containing `NULL` returns no rows at all. `LEFT JOIN ... IS NULL` doesn't have that trap, so it's the safer default pattern.

---

## 🔑 JOIN Types at a Glance

| JOIN | Keeps |
|---|---|
| `INNER JOIN` | Only matching rows from both tables |
| `LEFT JOIN` | All rows from the left table, matched or not |
| `RIGHT JOIN` | All rows from the right table, matched or not |
| `LEFT JOIN ... WHERE right.col IS NULL` | Only left-table rows with **no** match (anti-join) |

---

## 🐛 Common Mistakes

**Mistake 1: Using RIGHT JOIN instead of LEFT JOIN**
```sql
-- Wrong: keeps every Orders row, not every Customers row
FROM Customers AS c
RIGHT JOIN Orders AS o
ON c.id = o.customerId
```
Fix: swap to `LEFT JOIN` so `Customers` — the table you want everything from — sits on the guaranteed side.

**Mistake 2: Incomplete WHERE clause**
```sql
-- Wrong: not a boolean condition, just a bare column reference
WHERE c.id
```
Fix: check for the actual signal of "no match" — `WHERE o.customerId IS NULL`.

---

## ⏱ Time Complexity

O(n + m) with an index on `Orders.customerId` (typical for a foreign key) — the join is a single pass with a hash/index lookup, not a nested loop.

---

## 🧠 Key Learnings

- The anti-join pattern: `LEFT JOIN` + `WHERE <right-table-column> IS NULL` finds rows in the left table with no counterpart in the right table
- Join direction determines which table's rows are guaranteed to survive — always put the "must-keep-everything" table on the preserved side
- `NOT IN` subqueries are risky with nullable columns; `LEFT JOIN ... IS NULL` avoids that pitfall

---

## 🏁 Final Query

```sql
SELECT c.name AS Customers
FROM Customers AS c
LEFT JOIN Orders AS o
ON c.id = o.customerId
WHERE o.customerId IS NULL;
```
