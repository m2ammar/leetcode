# 🎮 511. Game Play Analysis I

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** `SELECT` · `MIN()` · `GROUP BY` · `Aliases` · `Aggregate Functions`

---

## ✅ Problem Summary

Given the `Activity` table, the query must:

- ✔️ Return **one row per player**
- ✔️ Show each player's **first login date** (the earliest `event_date`)
- ✔️ Name the columns `player_id` and `first_login`
- ✔️ Return rows in **any order**

---

## 💡 Solution

```sql
SELECT player_id, MIN(event_date) AS first_login
FROM Activity
GROUP BY player_id;
```

---

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `SELECT player_id` | Reports which player each result row belongs to |
| `MIN(event_date)` | Picks the earliest date inside each player's group |
| `AS first_login` | Renames the result column to match the expected output |
| `FROM Activity` | The table holding every login record |
| `GROUP BY player_id` | Collapses many rows per player into one group per player |

---

## 🤔 Why `GROUP BY` + `MIN()`?

`Activity` has **many rows per player** (one per login day), but the answer needs **one row per player**.

Think of a gym attendance register: every visit is a line with a member ID and a date. To find each member's first visit, you sort the lines into one pile per member, then take the earliest date from each pile.

```
player_id = 1  →  [ 2016-03-01, 2016-05-02 ]  →  MIN = 2016-03-01
player_id = 2  →  [ 2017-06-25 ]              →  MIN = 2017-06-25
player_id = 3  →  [ 2016-03-02, 2018-07-03 ]  →  MIN = 2016-03-02
```

Sample result:

| player_id | first_login |
|---|---|
| 1 | 2016-03-01 |
| 2 | 2017-06-25 |
| 3 | 2016-03-02 |

---

## 🚫 Why not `ORDER BY` + `LIMIT 1`?

`ORDER BY event_date LIMIT 1` returns the earliest row of the **whole table**, not of each player. Getting one row per player that way needs a window function (`ROW_NUMBER() OVER (PARTITION BY player_id ORDER BY event_date)`) plus a filter, which is more code for the same result. When you only need the earliest **value**, `MIN()` with `GROUP BY` is simpler and clearer.

---

## 📚 Aggregate Functions at a Glance

| Function | Returns (per group) |
|---|---|
| `MIN(col)` | Smallest value (earliest date) |
| `MAX(col)` | Largest value (latest date) |
| `COUNT(col)` | Number of non-NULL values |
| `SUM(col)` | Total of the values |
| `AVG(col)` | Average of the values |

---

## ⚠️ Common Mistakes

### 1. Using `HAVING` to find the earliest date

```sql
-- ❌ Wrong idea
GROUP BY player_id
HAVING event_date = MIN(event_date)
```

`HAVING` **filters groups out**. Here nothing should be removed. Every player must appear, with a value **calculated** from their group. Use an aggregate function in `SELECT` instead.

### 2. Assuming the "first row" is the first login

Tables have **no guaranteed row order**. The top row for a player is not necessarily their earliest date. Always compare **dates**, not row positions.

### 3. Adding a non-grouped column

```sql
-- ❌ device_id is not grouped and not aggregated
SELECT player_id, device_id, MIN(event_date)
FROM Activity
GROUP BY player_id;
```

If a player used several devices, SQL has no rule for which `device_id` to show, and it will not necessarily be the device from the first login. Finding that device needs a different technique (see problem 512).

---

## ⏱️ Time Complexity

**O(n)** with a hash aggregate over `n` rows (or O(n log n) if the engine sorts to group). The `(player_id, event_date)` primary key can also let MySQL read the earliest date per player straight from the index.

---

## 🧠 Key Learnings

- "First" means the **earliest date**, not the first row
- `GROUP BY` builds one pile per player; an aggregate function reads one value from each pile
- `HAVING` filters groups; `MIN()` computes a value per group
- Every `SELECT` column must be either **grouped** or **aggregated**
- Alias the result column exactly as the expected output names it

---

## 🏁 Final Query

```sql
SELECT player_id, MIN(event_date) AS first_login
FROM Activity
GROUP BY player_id;
```
