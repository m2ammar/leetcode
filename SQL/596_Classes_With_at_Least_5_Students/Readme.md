# 596. Classes With at Least 5 Students

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** `GROUP BY` · `HAVING` · `COUNT()` · Aggregation

---

## ✅ Problem Summary

- [x] There is one table, `Courses(student, class)`, where `(student, class)` is the primary key.
- [x] Find every `class` that has **5 or more** students enrolled.
- [x] Return only the `class` column — order doesn't matter.

---

## 🧠 Solution

```sql
select class
from Courses
group by class
having count(*) >= 5;
```

---

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `select class` | Picks the column we ultimately want to return — just the class name. |
| `from Courses` | Reads every (student, class) enrollment row. |
| `group by class` | Collapses all rows into one bucket per distinct `class`, so every student in "Math" lands in the same group. |
| `having count(*) >= 5` | Filters groups (not raw rows) — keeps only the classes whose bucket contains 5 or more rows. |

---

## 🤔 Why GROUP BY + HAVING?

This problem only involves one table, so there's no join column to worry about — the real question is *"how do I count students per class, then filter on that count?"* That's exactly what `GROUP BY` + `HAVING` is built for: `GROUP BY` does the bucketing, and `HAVING` filters on an aggregate (`COUNT(*)`) the way `WHERE` filters on a raw column.

Grouping visualized:

```
Courses (raw rows)              GROUP BY class (buckets)
+---------+----------+          Math     -> A, C, E, G, H, I  (6 rows)
| A       | Math     |          English  -> B                (1 row)
| B       | English  |          Biology  -> D                (1 row)
| C       | Math     |          Computer -> F                (1 row)
| D       | Biology  |
| E       | Math     |          HAVING count(*) >= 5
| F       | Computer |               keeps only:  Math
| G       | Math     |
| H       | Math     |
| I       | Math     |
+---------+----------+
```

Sample result:

| class |
|---|
| Math  |

---

## 🚫 Why not a subquery?

You could get the same answer with a derived table:

```sql
select class
from (
  select class, count(*) as cnt
  from Courses
  group by class
) t
where cnt >= 5;
```

This works, but it's strictly more verbose for the exact same logic — `HAVING` already exists specifically to filter grouped/aggregated results, so wrapping the aggregation in a subquery just to filter with `WHERE` afterward is unnecessary indirection. `HAVING` is the idiomatic, one-pass way to do this.

---

## 🔑 WHERE vs HAVING at a Glance

| Clause | Filters on | Runs |
|---|---|---|
| `WHERE` | Raw row values (before grouping) | Before `GROUP BY` |
| `HAVING` | Aggregate values like `COUNT()`, `SUM()` | After `GROUP BY` |

---

## ⚠️ Common Mistakes

**Mistake 1: Using `WHERE` instead of `HAVING`**
```sql
-- ❌ Wrong — COUNT(*) isn't a real column, WHERE can't see it
select class
from Courses
group by class
where count(*) >= 5;
```
```sql
-- ✅ Fix — aggregate filters belong in HAVING
select class
from Courses
group by class
having count(*) >= 5;
```

**Mistake 2: Counting distinct students unnecessarily**
```sql
-- Overkill here, since (student, class) is already unique per row
having count(distinct student) >= 5;
```
Since the primary key guarantees no duplicate (student, class) pairs, a plain `count(*)` is enough — `count(distinct student)` adds nothing but extra work.

---

## ⏱️ Time Complexity

O(n) — a single pass to group all n rows by class, plus a filter over the resulting groups.

---

## 🔑 Key Learnings

- `HAVING` is to grouped/aggregated data what `WHERE` is to raw rows.
- `COUNT(*)` inside a group counts rows in that group, not the whole table.
- No join is needed when the question only concerns a single table's own columns.

---

## 🎯 Final Query

```sql
select class
from Courses
group by class
having count(*) >= 5;
```
