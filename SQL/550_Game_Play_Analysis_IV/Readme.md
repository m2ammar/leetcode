# 550. Game Play Analysis IV

![Difficulty](https://img.shields.io/badge/Difficulty-Medium-orange) ![Topic](https://img.shields.io/badge/Topic-SQL-blue) ![Status](https://img.shields.io/badge/Status-Accepted-brightgreen)

**Concepts:** Self Join · Correlated Subquery · DATE_ADD · Conditional Aggregation · LEFT JOIN

---

## ✅ Problem Summary

- Find the fraction of players who logged in again the day *immediately after* their first login
- Round the result to 2 decimal places
- One row per player should count toward the total, regardless of how many times they later logged in

## 💡 Solution

```sql
select round(sum(case when a2.event_date = date_add(a1.event_date, interval 1 day) then 1 else 0 end) / count(distinct(a1.player_id)), 2) as fraction
from Activity as a1
left join Activity as a2
on a2.player_id = a1.player_id
where a1.event_date in (select min(event_date) from Activity as a3 where a3.player_id = a1.player_id);
```

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `where a1.event_date in (select min(event_date) ... where a3.player_id = a1.player_id)` | Correlated subquery — restricts `a1` to only each player's *own* first-login row |
| `left join Activity a2 on a2.player_id = a1.player_id` | Joins every other activity row for that same player, keeping the player even if no follow-up login exists |
| `case when a2.event_date = date_add(a1.event_date, interval 1 day)` | Checks whether a joined row falls exactly one day after the first login |
| `sum(case when ... then 1 else 0 end)` | Counts how many players had a next-day login |
| `count(distinct(a1.player_id))` | Total number of distinct players (the denominator) |
| `round(..., 2)` | Formats the final fraction to 2 decimal places |

## 🤔 Why correlated subquery + self join?

Two tables in play, both just `Activity` aliased twice:

- `a1` = each player's first-login row only
- `a2` = all of that player's activity, used to check for a next-day row

Common column: `player_id`

```
a1 (first login)         a2 (all logins, same player)
player_id  event_date    player_id  event_date
    1      2016-03-01 ── join ──►     1      2016-03-01
                                       1      2016-03-02  ← matches date+1
```

Sample result for player 1:

| player_id | a1.event_date | a2.event_date | matched? |
|---|---|---|---|
| 1 | 2016-03-01 | 2016-03-02 | ✅ |

The correlated subquery is what makes `a1` mean "this player's first day" instead of "any player's first day" — without the `where a3.player_id = a1.player_id` link, dates could leak across players who happen to share a login date.

## ⚠️ Why not an inner join?

An `INNER JOIN` between `a1` and `a2` on `event_date = date+1` would silently drop any player who never logged in again — meaning they'd vanish from the numerator *and* not get counted as a "0" case, but more importantly `count(distinct a1.player_id)` would also shrink since `a1` rows without a match disappear entirely. `LEFT JOIN` keeps every player's `a1` row regardless of whether `a2` matches, so the denominator (total players) stays accurate, and the `CASE` expression correctly scores unmatched players as 0.

## 🔑 Common Mistakes

**Mistake 1 — uncorrelated subquery**
```sql
-- Wrong: returns a flat list of every player's min date, not tied to a1
where a1.event_date in (select min(event_date) from Activity group by player_id)
```
This lets `a1` match on *any* player's first-login date, not specifically that row's own player. Fix: correlate the subquery to `a1.player_id`.

**Mistake 2 — comparing the wrong column**
```sql
-- Wrong: checks device, not the next-day condition the problem asks for
case when a1.device_id = a2.device_id then 1 else 0 end
```
`device_id` has nothing to do with whether the player returned the next day. Fix: compare `event_date` values with `DATE_ADD`.

## ⏱️ Time Complexity

O(n²) in the worst case due to the self-join across all activity rows, though MySQL's query planner will use the primary key `(player_id, event_date)` to index the join and subquery efficiently in practice.

## 🧠 Key Learnings

- Correlated subqueries are the standard way to isolate a "first/min/max row per group" before joining
- `LEFT JOIN` is essential whenever some rows in the anchor set might have zero matches on the other side
- Prefer `DATE_ADD(date, INTERVAL 1 DAY)` over `date + 1` for date arithmetic — more explicit and portable
- Compare the actual column the problem asks about — a self-join isn't automatically "correct" just because it joins on a shared key

## 🎯 Final Query

```sql
select round(sum(case when a2.event_date = date_add(a1.event_date, interval 1 day) then 1 else 0 end) / count(distinct(a1.player_id)), 2) as fraction
from Activity as a1
left join Activity as a2
on a2.player_id = a1.player_id
where a1.event_date in (select min(event_date) from Activity as a3 where a3.player_id = a1.player_id);
```
