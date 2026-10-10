# 601. Human Traffic of Stadium

![Difficulty](https://img.shields.io/badge/Difficulty-Hard-red)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-brightgreen)

**Concepts:** `CTE` · `ROW_NUMBER()` · `COUNT() OVER` · `PARTITION BY` · `Gaps and Islands` · `WHERE` · `ORDER BY`

---

## ✅ Problem Summary

- Return every row that belongs to a streak of **3 or more consecutive `id`s**
- Every row in the streak must have **`people >= 100`**
- Return `id`, `visit_date`, `people`
- Order the result by `visit_date` ascending

---

## 🧩 Solution

```sql
with cte1 as (
    select id, visit_date, people, id - row_number() over (order by id) as consec
    from Stadium
    where people >= 100
),

cte2 as (
    select id, visit_date, people, count(*) over (partition by consec) as counts
    from cte1
)

select id, visit_date, people
from cte2
where counts >= 3
order by visit_date;
```

---

## 🔍 Breakdown

| Clause | What it does |
|--------|--------------|
| `where people >= 100` | Keeps only qualifying rows **before** numbering them |
| `row_number() over (order by id)` | Numbers the surviving rows 1, 2, 3... in id order |
| `id - row_number()` as `consec` | Gives every row in a consecutive streak the **same value** |
| `count(*) over (partition by consec)` | Counts how many rows share each streak key |
| `where counts >= 3` | Keeps only streaks of 3 or more rows |
| `order by visit_date` | Sorts the output as the problem requires |

---

## 🤔 Why Gaps and Islands?

After filtering to `people >= 100`, ids 2, 3, 5, 6, 7, 8 remain:

| id | row_number | id - rn (`consec`) |
|----|-----------|---------|
| 2  | 1 | 1 |
| 3  | 2 | 1 |
| 5  | 3 | 2 |
| 6  | 4 | 2 |
| 7  | 5 | 2 |
| 8  | 6 | 2 |

```
ids:        2  3  _  5  6  7  8
row_number: 1  2     3  4  5  6
id - rn:    1  1     2  2  2  2
            └─┘      └────────┘
          island 1     island 2
```

Within a run of consecutive ids, both `id` and `row_number` grow by 1 each step, so their difference stays constant. A gap in ids makes `id` jump while `row_number` does not, so the difference changes and a new island starts.

---

## 🧱 Why not LAG / LEAD?

| Approach | Issue |
|----------|-------|
| `LAG` / `LEAD` | Needs separate conditions for the first, middle, and last row of a streak, combined with `OR` |
| `LAG` / `LEAD` | Looks at the previous **row**, not the previous **id**, so id gaps need extra checks |
| Gaps and islands | One key per streak, one count, one filter. It handles any streak length |

---

## ⚠️ Common Mistakes

**1. Putting the streak key in `HAVING`**
```sql
having id - row_number() over (order by id)   -- ❌ no GROUP BY, and it is not a filter
```
Compute it as a named column in the `SELECT` instead.

**2. Partitioning by the wrong column**
```sql
count(*) over (partition by visit_date)   -- ❌ visit_date is unique, so count is always 1
```
Partition by the streak key (`consec`).

**3. Nesting window functions**
```sql
count(*) over (partition by id - row_number() over (order by id))   -- ❌ not allowed
```
Compute the key in one CTE, then count in the next.

**4. Numbering before filtering**
If `row_number()` runs over all rows instead of only those with `people >= 100`, rows that fail the filter still consume numbers and the streak key breaks. Filter in `WHERE` first. `WHERE` runs before window functions.

**5. Two `WITH` keywords**
Multiple CTEs are separated by a comma, with a single `WITH`.

---

## ⏱️ Time Complexity

**O(n log n)** because the `ORDER BY id` inside the window function requires a sort.

---

## 🧠 Key Learnings

- "Consecutive" in a problem usually means **gaps and islands**
- `id - ROW_NUMBER()` collapses a consecutive run into one shared value
- Filter first, then number the rows, so the numbering only covers qualifying rows
- Window functions cannot be nested, so use a second CTE layer
- The same trick applies to consecutive days, logins, and similar streak problems

---

## 🏁 Final Query

```sql
with cte1 as (
    select id, visit_date, people, id - row_number() over (order by id) as consec
    from Stadium
    where people >= 100
),

cte2 as (
    select id, visit_date, people, count(*) over (partition by consec) as counts
    from cte1
)

select id, visit_date, people
from cte2
where counts >= 3
order by visit_date;
```
