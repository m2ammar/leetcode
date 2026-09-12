# 176. Second Highest Salary

![Difficulty](https://img.shields.io/badge/Difficulty-Medium-orange)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-brightgreen)

**Concepts:** Subquery · MAX() Aggregate Function · WHERE Clause · NULL Handling

---

## ✅ Problem Summary

- Find the **second highest distinct** salary from the `Employee` table
- Return the result as a column named `SecondHighestSalary`
- If there is no second highest salary, return `null`

## 💡 Solution

```sql
select max(salary) as SecondHighestSalary 
from Employee
where salary < (select max(salary) from Employee);
```

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `select max(salary) as SecondHighestSalary` | Aggregates the highest remaining value after filtering, and aliases it to the required output column name |
| `from Employee` | Source table containing `id` and `salary` |
| `where salary < (select max(salary) from Employee)` | Filters out the highest salary first, so only values strictly below it remain |
| `(select max(salary) from Employee)` | Inner scalar subquery — finds the single highest salary in the table |

## 🤔 Why Subquery + MAX?

Both tables/columns involved are just `Employee(id, salary)` — there's no join here, since the "ranking" happens against the same table's own max value.

```
Employee.salary  ──────────────►  compared against  ──────────────►  MAX(Employee.salary)
                                   (from the same table, via subquery)
```

The inner query first finds the absolute highest salary. The outer query then asks: "of everything strictly less than that, what's the highest?" — which is by definition the second highest.

Sample result for `{100, 200, 300}`:

| SecondHighestSalary |
|---|
| 200 |

## ⚠️ Why not ORDER BY + LIMIT + OFFSET?

A common alternative:

```sql
select salary as SecondHighestSalary
from Employee
order by salary desc
limit 1 offset 1;
```

This works when a second-highest value exists, but if the table has only one distinct salary, `LIMIT 1 OFFSET 1` returns **zero rows** — not a row containing `NULL`. LeetCode expects a single row with `SecondHighestSalary = null`, so this approach needs an extra wrapping query to guarantee that row exists. The subquery approach handles this automatically: `MAX()` over an empty result set naturally returns `NULL`, so no extra wrapping is needed.

## 🐛 Common Mistakes

**Mistake: using `!=` instead of `<`**
```sql
-- ❌ Incorrect: only excludes ties with the max, doesn't rank below it
where salary != (select max(salary) from Employee)
```
This still works for finding *a* value below the max, but conceptually it's "not equal to" rather than "strictly less than" — safer and clearer to filter with `<` since it directly expresses "everything ranked below the top".

**Mistake: forgetting the NULL case entirely**
```sql
-- ❌ Incorrect: errors or returns nothing on a single-row table if not handled
select max(salary) from Employee where salary < (select max(salary) from Employee limit 1 offset 1)
```
Using `LIMIT`/`OFFSET` inside the subquery instead of a clean `MAX()` comparison risks returning an empty result instead of `NULL` when no second-highest value exists.

## ⏱️ Time Complexity

O(n) — two full scans of the `Employee` table (one for the inner `MAX()`, one for the outer filtered `MAX()`), no indexing assumed.

## 🔑 Key Learnings

- A scalar subquery (`(select max(salary) from Employee)`) can be used directly inside a `WHERE` clause as if it were a single value
- `MAX()` (like all aggregate functions except `COUNT()`) returns `NULL` when applied to zero rows — this is what makes the "no second highest" case work for free
- `LIMIT`/`OFFSET` approaches are intuitive but need extra handling to guarantee a `NULL` row when the rank doesn't exist

## 🏁 Final Query

```sql
select max(salary) as SecondHighestSalary 
from Employee
where salary < (select max(salary) from Employee);
```
