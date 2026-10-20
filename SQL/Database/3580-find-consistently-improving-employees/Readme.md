
# 3580. Find Consistently Improving Employees

![Difficulty](https://img.shields.io/badge/Difficulty-Medium-orange)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** `ROW_NUMBER()` · `PARTITION BY` · `CASE WHEN` · `MAX()` · `GROUP BY` · `HAVING` · CTEs

---

## Problem Summary

Find employees who have at least three performance reviews and whose ratings strictly improve across their three most recent reviews.

Calculate the improvement score by subtracting the oldest of the three ratings from the latest rating.

**Requirements:**
- Consider only the three most recent reviews per employee.
- Ratings must strictly increase from oldest to newest.
- Calculate `improvement_score = latest_rating - earliest_rating`.
- Sort by improvement score in descending order, then employee name in ascending order.

---

## Approach

1. **Rank reviews:** Use `ROW_NUMBER()` partitioned by `employee_id` and ordered by `review_date DESC`.
2. **Keep three reviews:** Filter to ranks 1, 2, and 3.
3. **Extract ratings:** Use conditional aggregation with `MAX(CASE WHEN ...)` to obtain the latest, second, and earliest ratings.
4. **Require three reviews:** Use `HAVING COUNT(*) = 3`.
5. **Check improvement:** Ensure `earliest_rating < second_rating < latest_rating`.
6. **Calculate and sort:** Subtract the earliest rating from the latest and apply the required ordering.

## Key Learning

Because reviews are ranked in descending date order:

- `rn = 1` → Latest review
- `rn = 2` → Second-latest review
- `rn = 3` → Earliest of the three reviews

Conditional aggregation converts the ranked rows into separate rating columns for each employee.

---

## Complexity Analysis

Let \(n\) be the total number of performance reviews.

- **Time:** Approximately \(O(n \log n)\), primarily due to ranking and sorting.
- **Space:** \(O(n)\) auxiliary space may be required for window processing, depending on the execution plan.

---

## Status

- [x] Solution implemented
- [x] Query accepted
- [x] Window functions and conditional aggregation practiced
