# 262. Trips and Users

![Difficulty](https://img.shields.io/badge/Difficulty-Hard-red)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-brightgreen)

**Concepts:** `CTE` · `IN (subquery)` · `CASE WHEN` · `SUM` · `COUNT` · `GROUP BY` · `BETWEEN` · `ROUND`

---

## ✅ Problem Summary

Find the daily cancellation rate of taxi trips between `2013-10-01` and `2013-10-03`:

- ✔️ Only count trips where **both** the client and the driver are **not banned**
- ✔️ Cancelled = `cancelled_by_driver` or `cancelled_by_client`
- ✔️ Rate = cancelled trips / all trips (after filtering), per day
- ✔️ Round to 2 decimal places
- ✔️ Output columns must be exactly `Day` and `Cancellation Rate`

---

## 💡 Solution

```sql
WITH unbanned AS (
    SELECT users_id
    FROM Users
    WHERE banned = 'No'
)
SELECT
    request_at AS Day,
    ROUND(
        SUM(CASE
                WHEN status IN ('cancelled_by_driver', 'cancelled_by_client') THEN 1
                ELSE 0
            END)
        / COUNT(id),
        2
    ) AS `Cancellation Rate`
FROM Trips
WHERE client_id IN (SELECT users_id FROM unbanned)
  AND driver_id IN (SELECT users_id FROM unbanned)
  AND request_at BETWEEN '2013-10-01' AND '2013-10-03'
GROUP BY request_at;
```

---

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `WITH unbanned AS (...)` | Builds a reusable list of user ids where `banned = 'No'` |
| `client_id IN (SELECT users_id FROM unbanned)` | Keeps only trips whose client is unbanned |
| `driver_id IN (SELECT users_id FROM unbanned)` | Keeps only trips whose driver is unbanned (checked separately) |
| `request_at BETWEEN ... AND ...` | Restricts to the 3 requested days |
| `GROUP BY request_at` | One output row per day |
| `CASE WHEN status IN (...) THEN 1 ELSE 0 END` | Turns each trip into 1 (cancelled) or 0 (not) |
| `SUM(...)` | Adds the 1s, giving the number of cancelled trips in the day |
| `COUNT(id)` | Total trips in the day (after filtering) |
| `ROUND(..., 2)` | Rounds the ratio to 2 decimals |

---

## 🤔 Why a CTE + two `IN` checks?

`Trips` has **two** columns pointing into `Users`:

```
Trips.client_id ──┐
                  ├──► Users.users_id  (banned = 'No')
Trips.driver_id ──┘
```

Both must be unbanned, so the same list of good users is used twice. The CTE defines it once, and each `IN` checks one column.

Example (day `2013-10-01`): trip 2 has client 2, who is banned, so it is dropped. That leaves 3 trips, 1 cancelled, so `1 / 3 = 0.33`.

---

## 🔀 Why not JOIN?

Joining `Users` twice (once as client, once as driver) also works:

```sql
FROM Trips t
JOIN Users c ON t.client_id = c.users_id AND c.banned = 'No'
JOIN Users d ON t.driver_id = d.users_id AND d.banned = 'No'
```

It is equally correct. I chose the CTE + `IN` version because the filter reads like English and the unbanned list is defined in one place.

---

## ⚠️ Common Mistakes

**1. `COUNT` with `CASE ... ELSE 0`**

```sql
COUNT(CASE WHEN status IN (...) THEN 1 ELSE 0 END)
```

`COUNT` counts non-NULL values, and both `1` and `0` are non-NULL, so it counts every row. Every day would give `1.00`.

Fix: use `SUM`, or `COUNT` with no `ELSE`.

**2. Wrong status value**

```sql
status = 'cancelled'
```

No such value exists. The statuses are `completed`, `cancelled_by_driver` and `cancelled_by_client`.

Fix: `status IN ('cancelled_by_driver', 'cancelled_by_client')`.

**3. Alias with a space and no backticks**

```sql
AS Cancellation Rate
```

Syntax error: MySQL reads `Cancellation` as the alias.

Fix: `` AS `Cancellation Rate` ``.

**4. Curly quotes copied from text**

```sql
banned = ’No’
```

SQL needs straight quotes: `'No'`.

**5. Only checking one user column**

Filtering on `client_id` alone would still count trips with a banned driver.

---

## ⏱️ Time Complexity

Roughly `O(T + U)` for `T` trips and `U` users: one pass to build the unbanned set, one pass over `Trips` with lookups into it, plus grouping by day.

---

## 🔑 Key Learnings

- A CTE can be reused in more than one place in the same query
- `COUNT(expr)` skips only NULLs, so use `SUM(CASE ...)` for conditional counts
- Two foreign keys to the same table need two separate conditions
- Match output column names exactly, and use backticks for names with spaces
- A Hard problem is often just several small filters combined

---

## 🏁 Final Query

```sql
WITH unbanned AS (
    SELECT users_id
    FROM Users
    WHERE banned = 'No'
)
SELECT
    request_at AS Day,
    ROUND(
        SUM(CASE
                WHEN status IN ('cancelled_by_driver', 'cancelled_by_client') THEN 1
                ELSE 0
            END)
        / COUNT(id),
        2
    ) AS `Cancellation Rate`
FROM Trips
WHERE client_id IN (SELECT users_id FROM unbanned)
  AND driver_id IN (SELECT users_id FROM unbanned)
  AND request_at BETWEEN '2013-10-01' AND '2013-10-03'
GROUP BY request_at;
```
