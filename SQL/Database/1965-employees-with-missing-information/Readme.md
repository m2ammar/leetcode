# 1965. Employees With Missing Information

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** `UNION ALL` · `GROUP BY` · `HAVING` · `Derived Table` · `LEFT JOIN`

---

## ✅ Problem Summary

- Return the `employee_id` of every employee with missing information
- Information is missing if the **name** is missing (no row in `Employees`) or the **salary** is missing (no row in `Salaries`)
- Sort the result by `employee_id` in ascending order

---

## 💡 Solution

```sql
select employee_id
from (
    select employee_id from Employees
    union all
    select employee_id from Salaries
) as t
group by employee_id
having count(*) = 1
order by employee_id;
```

---

## 🔍 Breakdown

| Clause | What it does |
|---|---|
| `select employee_id from Employees union all select employee_id from Salaries` | Stacks the IDs from both tables into one list, keeping duplicates |
| `as t` | Gives the derived table the alias MySQL requires |
| `group by employee_id` | Collapses the stacked list to one group per ID |
| `having count(*) = 1` | Keeps IDs that appear only once, so they exist in only one table |
| `order by employee_id` | Sorts the result ascending |

---

## 🤔 Why stack and count?

An ID in **both** tables appears twice in the stacked list. An ID in **only one** table appears once. So `count(*) = 1` means the ID is missing from one side.

```
Employees:  2  4  5
Salaries:   5  1  4
            ↓ union all
Stacked:    2  4  5  5  1  4
            ↓ group by + count
 id 1 → 1   id 2 → 1   id 4 → 2   id 5 → 2
            ↓ having count(*) = 1
Result:     1, 2
```

| employee_id |
|---|
| 1 |
| 2 |

---

## 🧩 Why not two LEFT JOINs?

```sql
select e.employee_id
from Employees as e
left join Salaries as s on e.employee_id = s.employee_id
where s.salary is null

union all

select s.employee_id
from Salaries as s
left join Employees as e on s.employee_id = e.employee_id
where e.name is null
order by employee_id;
```

This also works (Accepted, 143 ms), because MySQL has no `FULL OUTER JOIN`. It needs two joins and two `where` filters. The stack-and-count version scans each table once, with no joins (Accepted, 96 ms), and is shorter.

---

## ⚠️ Common Mistakes

### 1. Using `INNER JOIN`
```sql
from Employees e join Salaries s on e.employee_id = s.employee_id
where e.name is null or s.salary is null
```
An inner join drops unmatched rows before `where` runs, so the rows you want never appear.

### 2. Testing the wrong column after a LEFT JOIN
```sql
from Employees e left join Salaries s on ...
where e.name is null   -- wrong
```
`e` is the preserved table, so its columns are never NULL here. Fix: test a column from the table you are **not** preserving (`s.salary is null`).

### 3. Using `UNION` instead of `UNION ALL` in the group-by approach
`UNION` removes duplicates, so an ID in both tables collapses to one row with a count of 1 and wrongly shows up as missing. Fix: use `UNION ALL`.

### 4. Using `WHERE count(*) = 1`
`WHERE` runs before grouping, so the count does not exist yet. Fix: use `HAVING`.

---

## ⏱️ Time Complexity

`O(n + m)` to scan both tables, plus `O((n + m) log(n + m))` for grouping and sorting.

---

## 🔑 Key Learnings

- "Missing" here means no row exists, not a NULL value inside a row
- MySQL has no `FULL OUTER JOIN`; emulate it with two `LEFT JOIN`s and `UNION`
- After a `LEFT JOIN`, test a column from the unmatched side for NULL
- Stack, group, and `having count(*) = 1` finds IDs that appear in only one source
- `UNION ALL` is required when counting, because `UNION` would erase the duplicates
- `HAVING` filters groups; `WHERE` filters rows

---

## 🏁 Final Query

```sql
select employee_id
from (
    select employee_id from Employees
    union all
    select employee_id from Salaries
) as t
group by employee_id
having count(*) = 1
order by employee_id;
```
