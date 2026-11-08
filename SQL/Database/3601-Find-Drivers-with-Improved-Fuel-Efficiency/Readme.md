# 3601. Find Drivers with Improved Fuel Efficiency

![Difficulty](https://img.shields.io/badge/Difficulty-Medium-orange)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-brightgreen)

**Concepts:** `CTE` · `CASE WHEN` · `AVG` · `Conditional Aggregation` · `GROUP BY` · `HAVING` · `JOIN` · `ROUND` · `WHERE`

---

## ✅ Problem Summary

- Calculate fuel efficiency per trip as `distance_km / fuel_consumed`
- First half = January to June, second half = July to December
- Average the efficiency separately for each half, per driver
- Keep only drivers who have trips in **both** halves
- Keep only drivers whose efficiency **improved** (`second_half_avg - first_half_avg > 0`)
- Round all results to 2 decimal places
- Order by `efficiency_improvement` descending, then `driver_name` ascending

---

## 🧩 Solution

```sql
WITH cte AS (
    SELECT d.driver_id,
        d.driver_name,
        AVG(CASE WHEN MONTH(t.trip_date) BETWEEN 1 AND 6 THEN t.distance_km / t.fuel_consumed END) AS first_half_avg,
        AVG(CASE WHEN MONTH(t.trip_date) BETWEEN 7 AND 12 THEN t.distance_km / t.fuel_consumed END) AS second_half_avg
    FROM drivers AS d
    JOIN trips AS t
        ON d.driver_id = t.driver_id
    GROUP BY d.driver_id, d.driver_name
    HAVING first_half_avg IS NOT NULL AND second_half_avg IS NOT NULL
)

SELECT
    driver_id,
    driver_name,
    ROUND(first_half_avg, 2) AS first_half_avg,
    ROUND(second_half_avg, 2) AS second_half_avg,
    ROUND((second_half_avg - first_half_avg), 2) AS efficiency_improvement
FROM cte
WHERE second_half_avg - first_half_avg > 0
ORDER BY efficiency_improvement DESC, driver_name ASC;
```

---

## 🔍 Breakdown

| Clause | What it does |
|---|---|
| `WITH cte AS (...)` | Computes the raw (unrounded) half-year averages once, so the outer query can reuse them |
| `JOIN trips ON driver_id` | Attaches each trip to its driver so we can group by name |
| `AVG(CASE WHEN MONTH(...) BETWEEN 1 AND 6 THEN ... END)` | Averages efficiency for first-half trips only; other trips become `NULL` and `AVG` ignores them |
| `AVG(CASE WHEN MONTH(...) BETWEEN 7 AND 12 THEN ... END)` | Same idea for the second half |
| `GROUP BY driver_id, driver_name` | One row per driver |
| `HAVING ... IS NOT NULL AND ... IS NOT NULL` | Drops drivers missing trips in either half (their average is `NULL`) |
| `ROUND(..., 2)` in the outer `SELECT` | Rounds only at the very end, from the unrounded averages |
| `WHERE second_half_avg - first_half_avg > 0` | Keeps only drivers who actually improved |
| `ORDER BY ... DESC, driver_name ASC` | Biggest improvement first, ties broken alphabetically |

---

## 🤔 Why Conditional Aggregation?

Both averages must sit on the **same row** per driver so we can subtract them.

```
trips (many rows per driver)
   │
   ├── Jan–Jun trips ──► AVG(CASE ...) ──► first_half_avg
   │
   └── Jul–Dec trips ──► AVG(CASE ...) ──► second_half_avg
                                │
                       one row per driver
```

Sample result from the example:

| driver_id | driver_name | first_half_avg | second_half_avg | efficiency_improvement |
|---|---|---|---|---|
| 2 | Bob Smith | 11.24 | 13.33 | 2.10 |
| 1 | Alice Johnson | 11.97 | 14.02 | 2.05 |

The unmatched `NULL`s do double duty: they are ignored by `AVG`, and a driver with no trips in a half ends up with a `NULL` average, which makes the "both halves" filter trivial.

---

## 🚫 Why not two separate queries joined together?

You could write one query per half and `JOIN` them on `driver_id`. That works, but it scans `trips` twice and needs extra join logic. Conditional aggregation does it in a single pass and keeps the query short.

---

## ⚠️ Common Mistakes

### 1. Ratio upside down
```sql
t.fuel_consumed / t.distance_km   -- wrong
```
Fix: efficiency is `t.distance_km / t.fuel_consumed`.

### 2. `SUM` instead of `AVG`
```sql
SUM(CASE WHEN ... END)   -- wrong, grows with the trip count
```
Fix: the problem asks for the **average** efficiency.

### 3. Rounding too early
```sql
ROUND(AVG(...), 2) AS first_half_avg   -- inside the CTE
```
Subtracting already-rounded values gives 13.33 - 11.24 = 2.09 for Bob, but the expected answer is 2.10. Fix: round only in the final `SELECT`.

### 4. Forgetting the "improved" condition
Having trips in both halves only decides who is **eligible**. Drivers whose efficiency dropped must be removed too:
```sql
WHERE second_half_avg - first_half_avg > 0
```
The example only contains improving drivers, so it passes locally but fails the hidden tests (1/11 passed before this fix).

### 5. Broken `HAVING` check
```sql
HAVING first_half_avg AND second_half_avg IS NOT NULL   -- wrong
```
`first_half_avg` alone is treated as true/false, not as a null check. Fix: give each column its own `IS NOT NULL`.

### 6. Deleting `END` along with `ELSE NULL`
`ELSE NULL` is optional, but `END` always closes the `CASE`.

---

## ⏱️ Time Complexity

**O(T + D log D)**, where T = number of trips (one pass for grouping and aggregation) and D = number of qualifying drivers (for the final sort).

---

## 🔑 Key Learnings

- `AVG(CASE WHEN ... THEN ... END)` gives several filtered aggregates in one row per group
- `AVG` ignores `NULL`s, so unmatched rows drop out automatically
- A `NULL` average can be used as an "exists in both groups" filter
- Aliases cannot be reused in the same `SELECT` list, so use a CTE and calculate on top of it
- Round only at the end, from unrounded values
- Re-read the problem statement for conditions the sample can't show (here: "improved")
- `WHERE` is for plain rows, `HAVING` is for aggregated groups

---

## 🏁 Final Query

```sql
WITH cte AS (
    SELECT d.driver_id,
        d.driver_name,
        AVG(CASE WHEN MONTH(t.trip_date) BETWEEN 1 AND 6 THEN t.distance_km / t.fuel_consumed END) AS first_half_avg,
        AVG(CASE WHEN MONTH(t.trip_date) BETWEEN 7 AND 12 THEN t.distance_km / t.fuel_consumed END) AS second_half_avg
    FROM drivers AS d
    JOIN trips AS t
        ON d.driver_id = t.driver_id
    GROUP BY d.driver_id, d.driver_name
    HAVING first_half_avg IS NOT NULL AND second_half_avg IS NOT NULL
)

SELECT
    driver_id,
    driver_name,
    ROUND(first_half_avg, 2) AS first_half_avg,
    ROUND(second_half_avg, 2) AS second_half_avg,
    ROUND((second_half_avg - first_half_avg), 2) AS efficiency_improvement
FROM cte
WHERE second_half_avg - first_half_avg > 0
ORDER BY efficiency_improvement DESC, driver_name ASC;
```
