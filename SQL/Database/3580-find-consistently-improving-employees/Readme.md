# 3580. Find Consistently Improving Employees

![Difficulty](https://img.shields.io/badge/Difficulty-Medium-orange)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** Window Functions · `ROW_NUMBER()` · CTEs · Conditional Aggregation · `CASE WHEN` · `MAX()` · `GROUP BY` · `HAVING`

---

## ✅ Problem Summary

Given an `Employees` table and a `PerformanceReviews` table:

- Identify employees who have at least three performance reviews.
- Consider only each employee's three most recent reviews.
- Check whether their ratings strictly increase from the oldest review to the newest.
- Calculate the improvement score as the latest rating minus the earliest rating.
- Sort by improvement score descending, then employee name ascending.

---

## 🧠 Solution

```sql
WITH ran AS (
    SELECT
        employee_id,
        rating,
        ROW_NUMBER() OVER (
            PARTITION BY employee_id
            ORDER BY review_date DESC
        ) AS rn
    FROM performance_reviews
),

filt AS (
    SELECT
        employee_id,
        MAX(CASE WHEN rn = 1 THEN rating END) AS latest_rating,
        MAX(CASE WHEN rn = 2 THEN rating END) AS second_rating,
        MAX(CASE WHEN rn = 3 THEN rating END) AS earliest_rating
    FROM ran
    WHERE rn <= 3
    GROUP BY employee_id
    HAVING COUNT(*) = 3
)

SELECT
    e.employee_id,
    e.name,
    f.latest_rating - f.earliest_rating AS improvement_score
FROM filt AS f
JOIN employees AS e
    ON e.employee_id = f.employee_id
WHERE f.earliest_rating < f.second_rating
  AND f.second_rating < f.latest_rating
ORDER BY improvement_score DESC, e.name ASC;
```

---

## 🧩 Breakdown

| Component | Purpose |
|---|---|
| `ran` CTE | Ranks each employee's reviews from newest to oldest. |
| `ROW_NUMBER()` | Assigns a unique rank to each review within an employee's records. |
| `PARTITION BY employee_id` | Restarts the ranking for each employee. |
| `ORDER BY review_date DESC` | Places the most recent review at rank 1. |
| `filt` CTE | Extracts the three most recent ratings into separate columns. |
| `WHERE rn <= 3` | Keeps only the three latest reviews per employee. |
| `MAX(CASE WHEN ...)` | Retrieves the rating associated with each rank. |
| `HAVING COUNT(*) = 3` | Excludes employees with fewer than three reviews. |
| `WHERE` conditions | Require ratings to strictly increase from oldest to newest. |
| `latest_rating - earliest_rating` | Calculates the improvement score. |
| `JOIN Employees` | Retrieves the employee's name. |
| `ORDER BY` | Sorts by improvement score descending and name ascending. |

---

## 🔢 How `ROW_NUMBER()` Works

Suppose an employee has these performance reviews:

| Review date | Rating |
|---|---:|
| 2023-01-10 | 2 |
| 2023-02-10 | 3 |
| 2023-03-10 | 5 |
| 2023-04-10 | 4 |

Since reviews are ranked using `ORDER BY review_date DESC`, the result is:

| Rating | Review rank |
|---:|---:|
| 4 | 1 |
| 5 | 2 |
| 3 | 3 |
| 2 | 4 |

The query keeps ranks 1, 2, and 3.

Therefore:

- `rn = 1` → Latest rating: `4`
- `rn = 2` → Second-latest rating: `5`
- `rn = 3` → Earliest of the three selected ratings: `3`

The selected ratings are `3 → 5 → 4`. This employee is excluded because the ratings do not strictly increase.

---

## 🧮 Conditional Aggregation

The expression:

```sql
MAX(CASE WHEN rn = 1 THEN rating END)
```

works by returning the rating only for the row where `rn = 1`. For all other rows, `CASE` returns `NULL`.

`MAX()` then extracts the non-NULL rating for that employee.

The same technique creates `latest_rating`, `second_rating`, and `earliest_rating`.

This transforms multiple review rows into a single row per employee.

---

## 📈 Checking Consistent Improvement

The query uses:

```sql
WHERE f.earliest_rating < f.second_rating
  AND f.second_rating < f.latest_rating
```

Both comparisons must be true.

For example:

| Oldest | Middle | Latest | Result |
|---:|---:|---:|---|
| 2 | 3 | 5 | Qualifies |
| 2 | 2 | 5 | Excluded — equal ratings |
| 2 | 5 | 4 | Excluded — latest rating decreased |
| 5 | 3 | 4 | Excluded — not increasing |

The ratings must increase **strictly**; equal consecutive ratings do not qualify.

---

## 💯 Improvement Score

The formula is:

```sql
latest_rating - earliest_rating
```

For an employee whose selected ratings are `2 → 3 → 5`:

- Latest rating: `5`
- Earliest rating: `2`
- Improvement score: `5 - 2 = 3`

The score measures the overall improvement across the three selected reviews, not the sum of the individual rating changes.

---

## ⚠️ Common Mistakes

### Mistake 1: Ranking reviews in ascending order

```sql
ORDER BY review_date ASC
```

This assigns rank 1 to the oldest review instead of the newest.

**Fix:** Use `ORDER BY review_date DESC`.

### Mistake 2: Checking only the latest and earliest ratings

A latest rating greater than the earliest rating does not guarantee consistent improvement.

For example, `2 → 5 → 4` has a higher latest rating than its earliest rating, but it is not strictly increasing.

**Fix:** Compare all three ratings in chronological order.

### Mistake 3: Reversing the improvement score

```sql
earliest_rating - latest_rating
```

This calculates the opposite of the required score.

**Fix:** Subtract the earliest rating from the latest rating.

### Mistake 4: Forgetting to exclude employees with fewer than three reviews

Employees need at least three reviews to evaluate the selected sequence.

**Fix:** Use `HAVING COUNT(*) = 3` after filtering to the three latest ranks.

### Mistake 5: Misunderstanding `MAX(CASE WHEN ...)`

`MAX()` is not being used to find the highest rating across all three reviews. It extracts the rating belonging to a specific rank.

**Fix:** Use a separate conditional aggregation expression for each rank.

---

## ⏱️ Time Complexity

Let `n` be the total number of performance reviews.

- **Ranking:** Approximately `O(n log n)` due to ordering within employee partitions.
- **Aggregation:** Processes the selected review rows.
- **Overall:** Approximately `O(n log n)`, depending on indexes and the database execution plan.

The window function's sorting is typically the dominant operation.

---

## 🔑 Key Learnings

- Use `ROW_NUMBER()` to rank records within groups.
- Use `PARTITION BY` to restart ranking for each employee.
- Use `CASE WHEN` with aggregation to extract specific ranked values.
- Use `HAVING` to filter grouped results.
- Check every required condition when evaluating a sequence.
- Keep score calculation separate from eligibility filtering.

---

## 🏁 Final Query

```sql
WITH ran AS (
    SELECT
        employee_id,
        rating,
        ROW_NUMBER() OVER (
            PARTITION BY employee_id
            ORDER BY review_date DESC
        ) AS rn
    FROM performance_reviews
),

filt AS (
    SELECT
        employee_id,
        MAX(CASE WHEN rn = 1 THEN rating END) AS latest_rating,
        MAX(CASE WHEN rn = 2 THEN rating END) AS second_rating,
        MAX(CASE WHEN rn = 3 THEN rating END) AS earliest_rating
    FROM ran
    WHERE rn <= 3
    GROUP BY employee_id
    HAVING COUNT(*) = 3
)

SELECT
    e.employee_id,
    e.name,
    f.latest_rating - f.earliest_rating AS improvement_score
FROM filt AS f
JOIN employees AS e
    ON e.employee_id = f.employee_id
WHERE f.earliest_rating < f.second_rating
  AND f.second_rating < f.latest_rating
ORDER BY improvement_score DESC, e.name ASC;
```
