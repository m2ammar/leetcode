# 🛒 1158. Market Analysis I

![Difficulty](https://img.shields.io/badge/Difficulty-Medium-orange)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-brightgreen)

**Concepts:** `RIGHT JOIN` · `ON vs WHERE` · `COUNT(column)` · `GROUP BY` · `YEAR()` · `Alias`

---

## ✅ Problem Summary

- Return **every user**, including users with no orders
- Show the user's `join_date`
- Count the orders they made **as a buyer** in **2019**
- Users with no 2019 orders must show `0`

---

## 🧩 Solution

```sql
select u.user_id as buyer_id, u.join_date, count(o.order_id) as orders_in_2019
from Orders as o
right join Users as u
    on u.user_id = o.buyer_id and year(o.order_date) = 2019
group by u.user_id;
```

---

## 🔍 Breakdown

| Clause | What it does |
|---|---|
| `from Orders as o right join Users as u` | Keeps **every row from Users**, attaches matching orders |
| `on u.user_id = o.buyer_id` | Matches a user to orders they made as a **buyer** |
| `and year(o.order_date) = 2019` | Only 2019 orders match; users are never removed by it |
| `group by u.user_id` | One result row per user |
| `count(o.order_id)` | Counts real orders; skips `NULL`, so unmatched users get `0` |
| `u.user_id as buyer_id` | ID from the preserved table, aliased to match the expected header |

---

## 🤔 Why an outer join?

Users has one row per user. Orders only has rows for people who bought something.

```
Users (all users)  --user_id = buyer_id-->  Orders (only buyers)
   1, 2, 3, 4                                  1, 1, 2, 4, 3, 2
```

| buyer_id | join_date | orders_in_2019 |
|---|---|---|
| 1 | 2018-01-01 | 1 |
| 3 | 2018-01-19 | 0 |

User 3 only has a 2018 order, so no order matches, but the user must still appear.

---

## 🚫 Why not a plain JOIN?

A plain `JOIN` is an inner join. Users 3 and 4 would vanish because they have no matching 2019 order. The problem needs them with `0`.

---

## 📚 JOIN Types at a Glance

| Join | Keeps |
|---|---|
| `INNER JOIN` | Only rows that match on both sides |
| `LEFT JOIN` | All left rows + matches from right |
| `RIGHT JOIN` | All right rows + matches from left |
| `FULL JOIN` | All rows from both (not in MySQL, needs `UNION`) |

---

## ⚠️ Common Mistakes

**1. Filtering the optional table in `WHERE`**
```sql
where year(o.order_date) = 2019   -- removes users with NULL order_date
```
Fix: put the condition in `ON`.

**2. Wrong join key**
```sql
on u.user_id = o.order_id   -- compares a user ID to an order ID
```
Fix: `o.buyer_id`.

**3. `count(*)` instead of `count(column)`**
```sql
count(*)   -- an unmatched user still produces 1 row, so it returns 1
```
Fix: `count(o.order_id)`.

**4. Selecting `o.buyer_id`**
```sql
select o.buyer_id   -- NULL for users with no matching order
```
Fix: `u.user_id as buyer_id`.

**5. Using `HAVING` for the date filter**
`HAVING` filters groups after grouping. It can't decide which orders match.

---

## ⏱️ Time Complexity

Roughly O(U + O) with an indexed join on `buyer_id`, plus grouping by user.

---

## 🧠 Key Learnings

- With an outer join, conditions on the optional table go in `ON`, not `WHERE`
- `count(column)` skips `NULL`s; `count(*)` counts rows
- Select the ID from the preserved table so it is never `NULL`
- An output header is just a label; use an alias to match it
- The Items table was a distractor, extra joins can change counts

---

## 🏁 Final Query

```sql
select u.user_id as buyer_id, u.join_date, count(o.order_id) as orders_in_2019
from Orders as o
right join Users as u
    on u.user_id = o.buyer_id and year(o.order_date) = 2019
group by u.user_id;
```
