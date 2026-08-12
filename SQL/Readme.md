# 📊 LeetCode SQL Practice
**Daily SQL problem-solving journey** — building strong SQL fundamentals through LeetCode, one problem at a time.

![Language](https://img.shields.io/badge/Language-MySQL-blue)
![Study Plan](https://img.shields.io/badge/Study%20Plan-SQL%2050-orange)
![Progress](https://img.shields.io/badge/Progress-27%2F50-brightgreen)

---
## 📁 Repository Structure
```text
SQL/
├── 197_Rising_Temperature/
│   ├── README.md
│   └── solution.sql
├── 570_Managers_with_at_Least_5_Direct_Reports/
│   ├── README.md
│   └── solution.sql
├── 1075-project-employees-i
|   |── README.md
|   └── solution.sql
├── 577_Employee_Bonus/
│   ├── README.md
│   └── solution.sql
├── 584_Find_Customer_Referee/
│   ├── README.md
│   └── solution.sql
├── 595_Big_Countries/
│   ├── README.md
│   └── solution.sql
├── 620_Not_Boring_Movies/
│   ├── README.md
│   └── solution.sql
├── 1068_Product_Sales_Analysis_I/
│   ├── README.md
│   └── solution.sql
├── 1148_Article_Views_I/
│   ├── README.md
│   └── solution.sql
├── 1251_Average_Selling_Price/
│   ├── README.md
│   └── solution.sql
├── 1280_Students_and_Examinations/
│   ├── README.md
│   └── solution.sql
├── 1378_Replace_Employee_ID_With_The_Unique_Identifier/
│   ├── README.md
│   └── solution.sql
├── 1581_Customer_Who_Visited_but_Did_Not_Make_Any_Transactions/
│   ├── README.md
│   └── solution.sql
├── 1661_Average_Time_of_Process_per_Machine/
│   ├── README.md
│   └── solution.sql
├── 1683_Invalid_Tweets/
│   ├── README.md
│   └── solution.sql
├── 1757_Recyclable_and_Low_Fat_Products/
│   ├── README.md
│   └── solution.sql
├── 1934_Confirmation_Rate/
|   ├── README.md
|   └── solution.sql
├── 1633-percentage-of-users-attended-a-contest/
|   ├── README.md
|   └── solution.sql
├── 1211-Queries-Quality-and-Percentage/
|   ├── solution.sql
|   └── README.md
├── 1193_Monthly_Transactions_I
|   ├── solution.sql
|   └── README.md
├── 1174-Immediate-Food-Delivery-II
|   ├── solution.sql
|   └── README.md
├── 550_Game_Play_Analysis_IV
|   ├── solution.sql
|   └── README.md
├── 2356_Number_of_Unique_Subjects_Taught_by_Each_Teacher
|   ├── solution.sql
|   └── README.md
├── 1141_User_Activity_for_the_Past_30_Days_I
|   ├── solution.sql
|   └── README.md
├── 1070_Product_Sales_Analysis_III
|   ├── solution.sql
|   └── README.md
├── 596_Classes_With_at_Least_5_Students
|   ├── solution.sql
|   └── README.md
└── 1729-find-followers-count
    ├── solution.sql
    └── README.md
```
Each problem folder contains:
- 📘 `README.md` — Problem summary, explanation, concepts, and key learnings
- 💻 `solution.sql` — Accepted MySQL solution
---
## 📈 Progress
| # | Problem | Difficulty | Concepts |
|---:|---|:---:|---|
| 1757 | Recyclable and Low Fat Products | 🟢 Easy | `WHERE`, `AND` |
| 584 | Find Customer Referee | 🟢 Easy | `NULL`, `IS NULL`, `OR` |
| 595 | Big Countries | 🟢 Easy | `WHERE`, `OR` |
| 1148 | Article Views I | 🟢 Easy | `DISTINCT`, `ORDER BY` |
| 1683 | Invalid Tweets | 🟢 Easy | `LENGTH()` |
| 1378 | Replace Employee ID With The Unique Identifier | 🟢 Easy | `LEFT JOIN` |
| 1068 | Product Sales Analysis I | 🟢 Easy | `INNER JOIN` |
| 1581 | Customer Who Visited but Did Not Make Any Transactions | 🟢 Easy | `LEFT JOIN`, `IS NULL`, `GROUP BY` |
| 1661 | Average Time of Process per Machine | 🟢 Easy | `SELF JOIN`, `GROUP BY`, `AVG()`, `ROUND()` |
| 197 | Rising Temperature | 🟢 Easy | `SELF JOIN`, `DATEDIFF()` |
| 577 | Employee Bonus | 🟢 Easy | `LEFT JOIN`, `IS NULL`, `OR` |
| 1280 | Students and Examinations | 🟢 Easy | `CROSS JOIN`, `LEFT JOIN`, `GROUP BY`, `COUNT()` |
| 570 | Managers with at Least 5 Direct Reports | 🟠 Medium | `GROUP BY`, `HAVING`, `COUNT()`, subquery, `JOIN` |
| 1934 | Confirmation Rate | 🟠 Medium | `LEFT JOIN`, `subquery`, `GROUP BY`, `conditional aggregation`, `IFNULL`, `ROUND()` |
| 620 | Not Boring Movies | 🟢 Easy | `WHERE`, Modulo (`%`), `ORDER BY` |
| 1251 | Average Selling Price | 🟢 Easy | `LEFT JOIN`, `BETWEEN`, weighted average, `IFNULL`/`NULL` handling, `GROUP BY` |
| 1075 | Project Employees I | 🟢 Easy | `JOIN`, `ON`, `GROUP BY`, `AVG()`, `ROUND()`, Table Aliases |
| 1633 | Percentage of Users Attended a Contest | 🟢 Easy | `JOIN`, `COUNT`, `GROUP BY`, `Subquery (Scalar)`, `ROUND()`, `Multi-Column ORDER BY`, Table Aliases |
| 1211 | Queries Quality and Percentage | 🟢 Easy | `GROUP BY`, Aggregate Functions `(SUM, COUNT)`, `CASE WHEN`, `ROUND()` |
| 1193 | Monthly Transactions I | 🟠 Medium |  `GROUP BY`, `DATE_FORMAT()`, `CASE WHEN`, `SUM()`, `COUNT()`, `Conditional Aggregation` |
| 1174 | Immediate Food Delivery II | 🟠 Medium |  `Correlated Subquery`, `GROUP BY (inner)`, `CASE WHEN`, `Aggregate Functions (SUM, COUNT, MIN)`, `ROUND()` |
| 550 | Game Play Analysis IV | 🟠 Medium |  `Self Join`, `Correlated Subquery`, `DATE_ADD`, `Conditional Aggregation`, `LEFT JOIN` |
| 2356 | Number of Unique Subjects Taught by Each Teacher | 🟢 Easy | `GROUP BY`, `COUNT` `DISTINCT` |
| 1141 | User Activity for the Past 30 Days I | 🟢 Easy | `SELECT`, `WHERE`, `BETWEEN`, `IN`, `COUNT(DISTINCT)`, `GROUP BY` |
| 1070 | Product Sales Analysis III | 🟠 Medium | `MIN()`, `Subquery`, `JOIN`, `GROUP BY` |
| 596 | Classes With at Least 5 Students | 🟢 Easy | `GROUP BY`, `HAVING`, `COUNT()`, `Aggregation` |
| 1729 | Find Followers Count | 🟢 Easy | `SELECT`, `GROUP BY`, `COUNT`, `ORDER BY` |
> This table is updated as I solve more problems.
---
## 🎯 Goal

Build strong SQL fundamentals by consistently solving problems covering filtering, joins, aggregation, subqueries, and advanced SQL concepts.

---
## 🧠 Topics

**Covered so far:**
- `SELECT` & `WHERE`
- `AND` / `OR`
- `NULL` Handling
- `INNER JOIN` & `LEFT JOIN`
- `CROSS JOIN`
- Self-Joins
- Multi-column `JOIN` conditions
- Aggregate Functions (`COUNT`, `SUM`, `AVG`, `ROUND`, `DISTINCT`)
- Conditional Aggregation (`SUM(CASE WHEN ...)`)
- `CASE WHEN`
- `GROUP BY`
- Date Functions (`DATE_FORMAT()`, `DATEDIFF()`)
- `HAVING`
- Subqueries
  - Scalar Subqueries
  - Correlated Subqueries
  
- Modulo (`%`)
- Weighted Averages

**Up next:**
- CTEs
- Window Functions
