# 1661. Average Time of Process per Machine

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** `SELF JOIN` · `GROUP BY` · `AVG()` · `ROUND()`

---

## 📋 Problem Summary

Table `Activity` logs machine activity. Each `(machine_id, process_id)` pair has exactly one `'start'` row and one `'end'` row.

Find the **average processing time** of each machine, rounded to 3 decimal places, where processing time = `end timestamp - start timestamp` for a given process, averaged across all processes on that machine.

---

## ✅ Solution

```sql
SELECT a1.machine_id,
       ROUND(AVG(a2.timestamp - a1.timestamp), 3) AS processing_time
FROM Activity AS a1
JOIN Activity AS a2
  ON a1.machine_id = a2.machine_id
 AND a1.process_id = a2.process_id
 AND a1.activity_type = 'start'
 AND a2.activity_type = 'end'
GROUP BY a1.machine_id;
```

---

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `JOIN Activity AS a2 ON a1.machine_id = a2.machine_id AND a1.process_id = a2.process_id` | Pairs each process's `start` row with its own `end` row |
| `AND a1.activity_type = 'start' AND a2.activity_type = 'end'` | Locks `a1` to the start event and `a2` to the end event, so each pair is directional (not duplicated both ways) |
| `AVG(a2.timestamp - a1.timestamp)` | Computes each process's duration, then averages across all processes on that machine |
| `GROUP BY a1.machine_id` | Produces one average per machine |
| `ROUND(..., 3)` | Matches the problem's required precision |

---

## ⚠️ Why a Self-Join (not two separate queries)

Both the "start" and "end" times live in the **same table**, just as different rows. A self-join lets you treat one copy of the table (`a1`) as "the start event" and another copy (`a2`) as "the end event" for the *same* process, then subtract the timestamps directly in one pass — no need to pre-aggregate into a temp table first.

---

## ❌ Common Mistakes

- Joining only on `machine_id` (forgetting `process_id`) → cross-matches unrelated processes on the same machine.
- Forgetting the `activity_type` filters in the `ON` clause → matches start-to-start and end-to-end pairs too, corrupting the average.
- Subtracting in the wrong direction (`a1.timestamp - a2.timestamp`) → gives negative durations.

---

## ⏱️ Time Complexity

**O(n)** — each row is matched once via the join key, typically optimized with indexes.

---

## 🔑 Key Learnings

- Self-joins are the standard tool whenever a "before/after" or "paired event" relationship exists within a single table.
- Put the *matching conditions that define the pairing* (not just the join key) inside `ON`, not `WHERE` — it keeps the intent explicit: "these are the rows that count as a pair."
- `GROUP BY` after a self-join aggregates over all the *pairs*, not the raw rows.

---

## 🧠 Final Query

```sql
SELECT a1.machine_id,
       ROUND(AVG(a2.timestamp - a1.timestamp), 3) AS processing_time
FROM Activity AS a1
JOIN Activity AS a2
  ON a1.machine_id = a2.machine_id
 AND a1.process_id = a2.process_id
 AND a1.activity_type = 'start'
 AND a2.activity_type = 'end'
GROUP BY a1.machine_id;
```
