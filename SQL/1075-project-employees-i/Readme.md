# 1075. Project Employees I

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

## Problem

Given a `Project` table (mapping employees to projects) and an `Employee` table (with each employee's years of experience), report the **average experience years** of all employees for each project, rounded to 2 decimal places.

### Schema

**Project**
| Column      | Type |
|-------------|------|
| project_id  | int  |
| employee_id | int  |

**Employee**
| Column            | Type    |
|-------------------|---------|
| employee_id       | int     |
| name              | varchar |
| experience_years  | int     |

## Approach

- Join `Project` to `Employee` on `employee_id` to attach each project's employees to their experience years.
- Group by `project_id`.
- Take `AVG(experience_years)` per group, rounded to 2 decimal places with `ROUND(..., 2)`.

## Solution

```sql
SELECT p.project_id, ROUND(AVG(e.experience_years), 2) AS average_years
FROM Project AS p
JOIN Employee AS e
    ON e.employee_id = p.employee_id
GROUP BY p.project_id;
```

## Result

Accepted — 8/8 testcases passed.

## What I Learned

- `INNER JOIN` is sufficient here since every `employee_id` in `Project` is guaranteed to exist in `Employee`.
- LeetCode's checker compares numeric values, not strings, so `2` and `2.00` are treated as equal — no need to worry about trailing zero formatting.
- Runtime/percentile ("Beats X%") on SQL problems is noisy due to shared server load and tiny test datasets — not a reliable signal of query quality for simple join+aggregate problems like this one.
