# 177. Nth Highest Salary

![Difficulty](https://img.shields.io/badge/Difficulty-Medium-orange)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-brightgreen)

**Concepts:** User-Defined Functions · DECLARE/SET · DISTINCT · ORDER BY · LIMIT/OFFSET

---

## ✅ Problem Summary
- Given an integer `N`, return the `N`th highest **distinct** salary from the `Employee` table
- If fewer than `N` distinct salaries exist, return `null`

## 🧩 Solution
```sql
CREATE FUNCTION getNthHighestSalary(N INT) RETURNS INT
BEGIN
    DECLARE var INT;
    SET var = N - 1;
    RETURN (
        SELECT DISTINCT salary
        FROM Employee
        ORDER BY salary DESC
        LIMIT 1 OFFSET var
    );
END
```

## 🔍 Breakdown

| Clause | Purpose |
|---|---|
| `DECLARE var INT;` | Declares a local variable to hold the computed offset |
| `SET var = N - 1;` | MySQL's `LIMIT`/`OFFSET` clauses reject inline expressions like `N - 1`, so the subtraction is done ahead of time and stored |
| `SELECT DISTINCT salary` | Removes duplicate salary values so repeated salaries don't distort ranking |
| `ORDER BY salary DESC` | Sorts salaries from highest to lowest, so position 1 = highest |
| `LIMIT 1 OFFSET var` | Skips `N-1` rows, then grabs exactly 1 row — landing on the Nth highest |

## 🤔 Why DECLARE + SET?
MySQL's `LIMIT`/`OFFSET` clauses only accept literals or variables — not arithmetic expressions computed inline.

```
N (rank)     →  offset (rows to skip)
1 (highest)  →  0
2            →  1
3            →  2
```

## 🚫 Why not a fixed subquery (like MAX + WHERE <)?
176's approach only needs one comparison for "2nd highest." Since N is variable here, you'd need an unknown number of chained comparisons. Sorting once with LIMIT/OFFSET scales to any N.

## ⚠️ Common Mistakes

**Using OFFSET with an inline expression:**
```sql
-- ❌ Throws a syntax error
LIMIT 1 OFFSET N - 1
```
```sql
-- ✅ Compute it first, then reference the variable
SET var = N - 1;
LIMIT 1 OFFSET var
```

**Forgetting DISTINCT:**
```sql
-- ❌ Duplicate salaries throw off row positions
SELECT salary FROM Employee ORDER BY salary DESC LIMIT 1 OFFSET var
```
```sql
-- ✅ Distinct values only, so each position = one rank
SELECT DISTINCT salary FROM Employee ORDER BY salary DESC LIMIT 1 OFFSET var
```

## ⏱️ Time Complexity
O(n log n) — dominated by the ORDER BY sort over all rows.

## 🔑 Key Learnings
- MySQL functions accept parameters and RETURN a single scalar value inside a BEGIN...END block
- LIMIT/OFFSET cannot take inline arithmetic — compute it into a variable first with DECLARE + SET
- A scalar subquery that returns zero rows is automatically treated as NULL
- Sorting + OFFSET generalizes to any rank N, unlike fixed comparison chains

## 🎯 Final Query
```sql
CREATE FUNCTION getNthHighestSalary(N INT) RETURNS INT
BEGIN
    DECLARE var INT;
    SET var = N - 1;
    RETURN (
        SELECT DISTINCT salary
        FROM Employee
        ORDER BY salary DESC
        LIMIT 1 OFFSET var
    );
END
```
