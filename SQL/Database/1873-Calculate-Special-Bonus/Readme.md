# 1873. Calculate Special Bonus

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** `CASE WHEN` · `LEFT()` · `MOD (%)` · `ORDER BY` · conditional column

---

## ✅ Problem Summary

- Return `employee_id` and `bonus` for **every** employee
- `bonus` = full `salary` if the ID is **odd** and the name does **not** start with `'M'`
- `bonus` = `0` otherwise
- Order the result by `employee_id`

---

## 💡 Solution

```mysql
# Write your MySQL query statement below
select employee_id,
       case when employee_id % 2 = 1 and LEFT(name, 1) != 'M'
            then salary
            else 0
       end as bonus
from Employees
order by employee_id;
```

---

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `select employee_id` | Returns the ID of every employee |
| `case when ... then salary else 0 end` | Picks the bonus value depending on the condition |
| `employee_id % 2 = 1` | True for odd IDs |
| `LEFT(name, 1) != 'M'` | True if the first letter of the name is not `M` |
| `and` | Both conditions must hold to earn the bonus |
| `as bonus` | Names the computed column |
| `order by employee_id` | Sorts the output as required |

---

## 🤔 Why `CASE` in `SELECT`?

Every employee must appear in the output. Only the **value** of `bonus` changes.

```
Employees (all rows)
   │
   ▼
CASE decides per row ──► salary  (odd ID and name not M)
                    └──► 0       (otherwise)
```

| employee_id | name | salary | odd? | starts with M? | bonus |
|---|---|---|---|---|---|
| 2 | Meir | 3000 | no | yes | 0 |
| 3 | Michael | 3800 | yes | yes | 0 |
| 7 | Addilyn | 7400 | yes | no | 7400 |
| 8 | Juan | 6100 | no | no | 0 |
| 9 | Kannon | 7700 | yes | no | 7700 |

---

## 🚫 Why not `WHERE`?

`WHERE` removes rows, so employees who fail the condition would disappear from the result. The problem needs them to stay with a bonus of `0`, so the condition goes inside the `CASE`, where it changes a value instead of removing a row.

---

## ⚠️ Common Mistakes

**1. Filtering with `WHERE` / `HAVING`**
```mysql
-- Wrong: drops employees who should get 0
select employee_id, salary as bonus
from Employees
where employee_id % 2 != 0 and LEFT(name, 1) != 'M';
```
Fix: move the condition into `CASE WHEN ... THEN salary ELSE 0 END`.

**2. Using `GROUP BY` with nothing to aggregate**
```mysql
-- Unnecessary: employee_id is already unique
group by employee_id
```
Fix: remove it. `GROUP BY` is for `SUM`, `COUNT`, etc.

---

## ⏱️ Time Complexity

**O(n log n)**. One pass over the table to evaluate the `CASE`, plus the sort for `ORDER BY`.

---

## 🔑 Key Learnings

- When every row must stay but a value changes by condition, use a conditional expression in `SELECT`, not `WHERE`
- `CASE WHEN cond THEN a ELSE b END` is the SQL if/else
- `% 2 = 1` checks odd, `% 2 = 0` checks even
- `LEFT(name, 1)`, `SUBSTRING(name, 1, 1)`, and `NOT LIKE 'M%'` all test the first character
- `GROUP BY` and `HAVING` are only needed when aggregating

---

## 🏁 Final Query

```mysql
select employee_id,
       case when employee_id % 2 = 1 and LEFT(name, 1) != 'M'
            then salary
            else 0
       end as bonus
from Employees
order by employee_id;
```
