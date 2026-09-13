# 181. Employees Earning More Than Their Managers

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-brightgreen)

**Concepts:** Self Join · Table Aliases · JOIN · Foreign Key Relationship · Comparison

---

## ✅ Problem Summary

* Given an `Employee` table containing employees and their managers
* Find employees whose salary is **greater than their manager's salary**
* Return the employee's name as `Employee`
* The result can be returned in any order

## 🧩 Solution

```sql
SELECT e1.name AS Employee
FROM Employee AS e1
JOIN Employee AS e2
ON e1.managerId = e2.id
WHERE e1.salary > e2.salary;
```

## 🔍 Breakdown

| Clause                  | Purpose                                                       |
| ----------------------- | ------------------------------------------------------------- |
| `Employee AS e1`        | Treats the first copy of the table as the employee            |
| `Employee AS e2`        | Treats the second copy of the same table as the manager       |
| `e1.managerId = e2.id`  | Matches each employee to their manager using the manager's ID |
| `e1.salary > e2.salary` | Keeps only employees earning more than their manager          |
| `e1.name AS Employee`   | Returns the employee's name with the required column name     |

## 🤔 Why a Self Join?

The employee and manager information are stored in the **same table**.

For example:

```text
Employee
   ↓
Joe → managerId = 3
              ↓
        id = 3 → Sam
```

So we need to join the `Employee` table with **itself**:

```text
e1 = Employee
    ↓
Employee

e2 = Employee
    ↓
Manager
```

The relationship is:

```text
e1.managerId = e2.id
```

Once joined, we can directly compare:

```text
Employee salary > Manager salary
```

## 🧠 Understanding the Join

For the example:

```text
Joe   | salary = 70000 | managerId = 3
Sam   | salary = 60000 | id = 3
```

The join connects Joe with Sam:

```text
e1 (Employee)       e2 (Manager)

Joe                 Sam
70000               60000
managerId = 3       id = 3
```

Then:

```text
70000 > 60000
```

So **Joe** is included in the result.

Henry is matched with Max:

```text
80000 > 90000
```

This is false, so Henry is excluded.

## 🚫 Common Mistakes

**Reversing the join relationship:**

```sql
-- ❌ Wrong relationship
ON e1.id = e2.managerId
```

This makes `e1` the manager and `e2` the employee.

```sql
-- ✅ Correct
ON e1.managerId = e2.id
```

Here:

```text
e1 = Employee
e2 = Manager
```

**Reversing the salary comparison:**

```sql
-- ❌ Finds managers earning more than their employees
WHERE e1.salary < e2.salary
```

```sql
-- ✅ Finds employees earning more than their managers
WHERE e1.salary > e2.salary
```

**Using `MAX()`:**

`MAX()` is unnecessary because we aren't looking for the highest salary overall. We need to compare **each employee against their specific manager**.

## ⏱️ Time Complexity

O(n) average — the self-join can be performed efficiently using the indexed primary key `id`.

## 🔑 Key Learnings

* A **self join** is used when rows in the same table have a relationship with each other
* Table aliases allow the same table to be treated as two different roles
* `managerId` is the employee's reference to their manager
* `managerId` matches the manager's `id`
* Once the tables are joined, columns from both copies can be directly compared
* The important relationship is:

```text
Employee.managerId → Manager.id
```

## 🎯 Final Query

```sql
SELECT e1.name AS Employee
FROM Employee AS e1
JOIN Employee AS e2
ON e1.managerId = e2.id
WHERE e1.salary > e2.salary;
```
