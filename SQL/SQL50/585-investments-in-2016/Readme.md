# 585. Investments in 2016

![Difficulty](https://img.shields.io/badge/Difficulty-Medium-orange)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** CTE · Window Functions · PARTITION BY · COUNT() OVER · ROUND

---

## ✅ Problem Summary

Given the `Insurance` table, report the sum of `tiv_2016` for all policyholders who:
- have a `tiv_2015` value shared with **one or more** other policyholders, **and**
- have a `(lat, lon)` pair that is **unique** — not shared with any other policyholder.

Round the result to two decimal places.

---

## 🧠 Solution

```sql
with cte as (
    select *,
        count(*) over (partition by tiv_2015) as cnt_tiv,
        count(*) over (partition by lat, lon) as cnt_loc
    from Insurance
)
select round(sum(tiv_2016), 2) as tiv_2016
from cte
where cnt_tiv > 1 AND cnt_loc = 1;
```

---

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `with cte as (...)` | Builds an intermediate result set that keeps every original row intact, plus two new annotation columns. |
| `count(*) over (partition by tiv_2015)` | For each row, counts how many rows (including itself) share the same `tiv_2015` value. Stored as `cnt_tiv`. |
| `count(*) over (partition by lat, lon)` | For each row, counts how many rows share the exact same `(lat, lon)` pair. Stored as `cnt_loc`. |
| `where cnt_tiv > 1` | Keeps only rows whose `tiv_2015` is duplicated elsewhere (Condition 1). |
| `and cnt_loc = 1` | Keeps only rows whose `(lat, lon)` location is one-of-a-kind (Condition 2). |
| `round(sum(tiv_2016), 2)` | Sums `tiv_2016` for the surviving rows and rounds to 2 decimal places. |

---

## 🤔 Why Window Functions + CTE?

This problem needs each row to be **compared against the whole table** on two different groupings (`tiv_2015`, and `(lat, lon)`) — but the final answer still needs to sum individual `tiv_2016` values row by row, not per group.

`GROUP BY` would collapse rows into groups and lose row-level detail (like `tiv_2016`, `pid`) needed for the final sum. Window functions solve this by **annotating** each row with a group-level fact without collapsing anything:

```
Insurance table                    +---------------------+
+-----+----------+-----+-----+     | tiv_2015 groups     |
| pid | tiv_2015 | lat | lon | --> | (COUNT via PARTITION)|
+-----+----------+-----+-----+     +---------------------+
                                    | (lat,lon) groups     |
                                    | (COUNT via PARTITION)|
                                    +---------------------+
```

Sample result after the CTE step:

| pid | tiv_2015 | tiv_2016 | lat | lon | cnt_tiv | cnt_loc |
|---|---|---|---|---|---|---|
| 1 | 10 | 5  | 10 | 10 | 3 | 1 |
| 2 | 20 | 20 | 20 | 20 | 1 | 2 |
| 3 | 10 | 30 | 20 | 20 | 3 | 2 |
| 4 | 10 | 40 | 40 | 40 | 3 | 1 |

Only pid 1 and pid 4 have `cnt_tiv > 1 AND cnt_loc = 1` → sum of their `tiv_2016` = 45.00.

---

## ⚠️ Why not GROUP BY + HAVING?

`GROUP BY tiv_2015 HAVING COUNT(*) > 1` would tell you *which `tiv_2015` values* are duplicated, but it collapses all matching rows into one — you'd lose the individual `pid`, `lat`, `lon`, and `tiv_2016` values needed to then check the location condition and sum correctly. To make `GROUP BY`/`HAVING` work here, you'd need **two separate grouped subqueries** (one grouped by `tiv_2015`, one grouped by `lat, lon`) and then join both back to the original table just to recover row-level detail. Window functions avoid that extra join entirely by keeping every row visible from the start.

---

## 🐛 Common Mistakes

**Mistake: filtering with aggregates directly in `WHERE`**
```sql
-- ❌ Not allowed — aggregate/window functions can't be referenced in WHERE
select round(sum(tiv_2016), 2)
from Insurance
where count(*) over (partition by tiv_2015) > 1;
```
```sql
-- ✅ Fix — compute the window function first (CTE/subquery), then filter in the outer query
with cte as (
    select *, count(*) over (partition by tiv_2015) as cnt_tiv
    from Insurance
)
select round(sum(tiv_2016), 2) from cte where cnt_tiv > 1;
```

**Mistake: treating `lat` and `lon` as independently unique**
```sql
-- ❌ Wrong — checks lat and lon separately, not as a combined pair
count(*) over (partition by lat) as cnt_lat,
count(*) over (partition by lon) as cnt_lon
```
```sql
-- ✅ Fix — partition by both columns together so only an exact (lat, lon) match counts
count(*) over (partition by lat, lon) as cnt_loc
```

---

## ⏱️ Time Complexity

O(n log n) — dominated by the sorting needed for the two `PARTITION BY` window function passes over the table.

---

## 🔑 Key Learnings

- Window functions annotate rows with group-level facts without collapsing them — ideal when you need both row-level detail and group-level context in the same query.
- A `(lat, lon)` "unique pair" check requires partitioning by **both columns together**, not each column separately.
- Aggregate/window function results can't be filtered directly in `WHERE` — compute them in a CTE or subquery first, then filter in the outer query.

---

## 🏁 Final Query

```sql
with cte as (
    select *,
        count(*) over (partition by tiv_2015) as cnt_tiv,
        count(*) over (partition by lat, lon) as cnt_loc
    from Insurance
)
select round(sum(tiv_2016), 2) as tiv_2016
from cte
where cnt_tiv > 1 AND cnt_loc = 1;
```
