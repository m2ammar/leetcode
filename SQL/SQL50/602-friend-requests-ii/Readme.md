# 602. Friend Requests II: Who Has the Most Friends

![Difficulty](https://img.shields.io/badge/Difficulty-Medium-orange)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-brightgreen)

**Concepts:** UNION ALL · Subquery · GROUP BY · Window Function (RANK) · ORDER BY · LIMIT

---

## ✅ Problem Summary

- Each row in `RequestAccepted` represents an accepted friend request between `requester_id` and `accepter_id`.
- Both columns count toward a person's total friend count — being a requester or an accepter both count as "having a friend."
- Find the person(s) with the highest total friend count, and that count.
- Test cases guarantee a single winner, but the real-world follow-up asks: what if there's a tie?

---

## 🧠 Solution (Approach 1 — Subquery)

```sql
Select id, num  
from (Select t.id, count(*) as num 
from ((SELECT requester_id as id FROM RequestAccepted)
Union All 
(SELECT accepter_id FROM RequestAccepted)) as t
group by id) as A
where num =  (SELECT MAX(num) FROM (Select t.id, count(*) as num 
from ((SELECT requester_id as id FROM RequestAccepted)
Union All 
(SELECT accepter_id FROM RequestAccepted)) as t
group by id) as B);
```

---

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `SELECT requester_id as id ... UNION ALL SELECT accepter_id ...` | Stacks both ID columns into one column, so a person is counted once per row they appear in, in either role |
| `as t` | Aliases the stacked (unioned) result so it can be treated as a normal table |
| `GROUP BY id` (inner, subquery A) | Groups the stacked IDs so `COUNT(*)` gives each person's total friend count |
| `as A` | Aliases the grouped `id, num` result as the outer query's source |
| `SELECT MAX(num) FROM (...) as B` | Repeats the same stacking + grouping logic to independently compute the single highest `num` |
| `WHERE num = (...)` | Keeps only the row(s) from `A` whose count equals the max — this is what allows ties to survive, unlike `LIMIT 1` |

---

## 🤔 Why UNION ALL + Subquery?

`RequestAccepted` has two ID columns (`requester_id`, `accepter_id`) but a "friend count" needs one unified column of IDs to group and count.

```
requester_id | accepter_id        id
     1       |     2        →      1
     1       |     3        →      2
     2       |     3        →      1
     3       |     4        →      3
                                    2
                                    3
                                    3
                                    4
```

`UNION ALL` (not `UNION`) is used deliberately — duplicates must be kept, since each row a person appears in should count once toward their total.

Sample result after grouping:

| id | num |
|----|-----|
| 1  | 2   |
| 2  | 2   |
| 3  | 3   |
| 4  | 1   |

---

## ⚠️ Why not `ORDER BY num DESC LIMIT 1`?

`LIMIT 1` was the first instinct here, and it works for the given test case — but it silently drops ties. If two people are tied for the most friends, `LIMIT 1` only returns one of them, even though the problem's follow-up expects both. Comparing against `MAX(num)` in a `WHERE` clause keeps every tied row instead of arbitrarily picking one.

---

## 🧠 Solution (Approach 2 — Window Function)

```sql
SELECT id, num
FROM (
    SELECT id, num, RANK() OVER (ORDER BY num DESC) as rnk
    FROM (
        SELECT t.id, count(*) as num
        FROM (
            (SELECT requester_id as id FROM RequestAccepted)
            UNION ALL
            (SELECT accepter_id FROM RequestAccepted)
        ) as t
        GROUP BY id
    ) as counts
) as ranked
WHERE rnk = 1;
```

The `UNION ALL` + `GROUP BY` logic appears once instead of twice. `RANK() OVER (ORDER BY num DESC)` assigns rank 1 to the highest `num` — and gives every tied row rank 1 as well, so ties are handled in the same pass instead of needing a separate `MAX()` subquery.

### RANK() vs ROW_NUMBER() at a Glance

| Function | Behavior on ties | Gaps after a tie |
|---|---|---|
| `ROW_NUMBER()` | Ignores ties — assigns a unique, sequential number to every row regardless of equal values | No gaps, but ties are broken arbitrarily by physical row order |
| `RANK()` | Assigns the same rank to rows with identical values | Skips subsequent rank numbers (e.g. two rows tied at rank 1 → next row is rank 3) |

`RANK()` is the correct choice here specifically because tied rows must share rank 1 — `ROW_NUMBER()` would arbitrarily keep only one of them.

---

## ⚠️ Common Mistakes

**Nesting aggregates directly:**
```sql
-- ❌ Wrong — COUNT() already collapses to one value per group; SUM() has nothing meaningful left to sum
sum(count(requester_id) + count(accepter_id)) as num
```
```sql
-- ✅ Fix — stack both ID columns first (UNION ALL), then COUNT(*) once per grouped id
count(*) as num
```

**Misplaced closing parenthesis breaking GROUP BY:**
```sql
-- ❌ Wrong — the subquery closes one paren too early, leaving GROUP BY dangling outside it
FROM (Select t.id, count(*) as num from (...) as t)
group by id) as B
```
```sql
-- ✅ Fix — GROUP BY must stay inside the subquery; the subquery closes after it, not before
FROM (Select t.id, count(*) as num from (...) as t
group by id) as B
```

---

## ⏱️ Time Complexity

O(n) to scan and stack both columns via `UNION ALL`, plus O(n log n) for the grouping/sorting step — dominated by the `GROUP BY` and (in Approach 1) the repeated subquery scan, or the single `RANK()` pass in Approach 2.

---

## 🔑 Key Learnings

- `COUNT()` cannot be nested inside `SUM()` at the same grouping level — aggregates can't feed directly into other aggregates in one pass.
- Two columns representing "the same kind of entity in different roles" (requester/accepter) can be unified into one column with `UNION ALL`, enabling a single `GROUP BY`.
- `UNION ALL` vs `UNION` matters when duplicates carry meaning — here, duplicates are exactly what needs counting.
- A subquery used as a value in `WHERE` must be wrapped in its own parentheses, separate from any parentheses belonging to nested derived tables.
- `LIMIT 1` picks one row after sorting; it does not handle ties. Comparing against `MAX()` — or better, using `RANK()` — is needed when ties must all be returned.
- `RANK()` shares the same rank across tied rows, unlike `ROW_NUMBER()`, making it the right tool for "find all rows tied for the top spot."

---

## 🏁 Final Query

```sql
SELECT id, num
FROM (
    SELECT id, num, RANK() OVER (ORDER BY num DESC) as rnk
    FROM (
        SELECT t.id, count(*) as num
        FROM (
            (SELECT requester_id as id FROM RequestAccepted)
            UNION ALL
            (SELECT accepter_id FROM RequestAccepted)
        ) as t
        GROUP BY id
    ) as counts
) as ranked
WHERE rnk = 1;
```
