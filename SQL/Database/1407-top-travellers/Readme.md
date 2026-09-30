# 1407. Top Travellers

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

## 📌 Problem

Given the `Users` and `Rides` tables, report the total distance traveled by each user.

The result must be ordered by:

1. `travelled_distance` in **descending order**
2. `name` in **ascending order** when two users have the same total distance

Users who have no rides must still appear with a travelled distance of `0`.

---

## 💡 Solution

```sql
SELECT u.name,
       COALESCE(SUM(r.distance), 0) AS travelled_distance
FROM Users AS u
LEFT JOIN Rides AS r
    ON u.id = r.user_id
GROUP BY u.id
ORDER BY travelled_distance DESC, u.name ASC;
```

## 🧩 Breakdown

| Clause                             | What it does                                   |
| ---------------------------------- | ---------------------------------------------- |
| `SELECT u.name`                    | Returns each user's name                       |
| `SUM(r.distance)`                  | Calculates the total distance traveled         |
| `COALESCE(..., 0)`                 | Changes `NULL` to `0` for users with no rides  |
| `FROM Users AS u`                  | Starts with all users                          |
| `LEFT JOIN Rides AS r`             | Keeps users even when they have no rides       |
| `ON u.id = r.user_id`              | Matches each ride to its user                  |
| `GROUP BY u.id`                    | Groups all rides belonging to each user        |
| `ORDER BY travelled_distance DESC` | Sorts by total distance from highest to lowest |
| `u.name ASC`                       | Sorts alphabetically when distances are equal  |

---

## 🤔 Why `LEFT JOIN`?

We need **every user** in the result, including users who have never taken a ride.

If we used an `INNER JOIN`, users without rides would disappear.

For example, Donald has no matching row in `Rides`.

With `LEFT JOIN`:

```text
Donald
   ↓
No matching ride
   ↓
r.distance = NULL
   ↓
SUM(r.distance) = NULL
   ↓
COALESCE(..., 0) = 0
```

So Donald remains in the result with a travelled distance of `0`.

---

## 🧠 Why `SUM()` and not `COUNT()`?

The problem asks for the **total distance**, not the number of rides.

For example, Lee has three rides:

```text
100 + 120 + 230 = 450
```

Therefore:

```sql
SUM(r.distance)
```

is required.

`COUNT()` would tell us how many rides the user had, which is a different question.

---

## 🔀 Why `GROUP BY`?

A user can have multiple rides.

For example:

```text
Lee → 100
Lee → 120
Lee → 230
```

`GROUP BY u.id` puts these rows into one group:

```text
Lee → SUM(100 + 120 + 230) → 450
```

This gives us one result row per user.

---

## ⚠️ Common Mistakes

### 1. Using `INNER JOIN`

```sql
FROM Users AS u
JOIN Rides AS r
    ON u.id = r.user_id
```

❌ Users without rides are removed.

Use:

```sql
LEFT JOIN Rides AS r
```

instead.

### 2. Forgetting `COALESCE`

```sql
SUM(r.distance)
```

For a user with no rides, this produces `NULL`.

The problem expects `0`, so we use:

```sql
COALESCE(SUM(r.distance), 0)
```

### 3. Using `COUNT()`

```sql
COUNT(r.distance)
```

❌ This counts rides rather than calculating the distance traveled.

### 4. Incorrect tie-breaking

The problem says that if two users have the same travelled distance, their names should be sorted alphabetically.

Therefore:

```sql
ORDER BY travelled_distance DESC, u.name ASC
```

For example:

```text
Elvis → 450
Lee   → 450
```

Both have `450`, so Elvis comes before Lee alphabetically.

---

## 📊 Example

For the given data:

```text
Elvis     → 50 + 400          = 450
Lee       → 100 + 120 + 230  = 450
Bob       → 317
Jonathan  → 312
Alex      → 222
Alice     → 120
Donald    → 0
```

Final ordering:

| name     | travelled_distance |
| -------- | -----------------: |
| Elvis    |                450 |
| Lee      |                450 |
| Bob      |                317 |
| Jonathan |                312 |
| Alex     |                222 |
| Alice    |                120 |
| Donald   |                  0 |

---

## ⏱️ Complexity

The query performs a join between `Users` and `Rides`, followed by grouping and sorting.

The exact complexity depends on the database execution plan and indexes, but conceptually:

* Join and aggregation process the input rows.
* Sorting the final grouped results adds a sorting step.

---

## 🏁 Final Query

```sql
SELECT u.name,
       COALESCE(SUM(r.distance), 0) AS travelled_distance
FROM Users AS u
LEFT JOIN Rides AS r
    ON u.id = r.user_id
GROUP BY u.id
ORDER BY travelled_distance DESC, u.name ASC;
```
