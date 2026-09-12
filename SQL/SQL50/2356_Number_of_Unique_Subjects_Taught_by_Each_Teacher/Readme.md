# 2356. Number of Unique Subjects Taught by Each Teacher

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** GROUP BY · COUNT · DISTINCT

---

## ✅ Problem Summary

- Given a `Teacher` table where each row means a teacher teaches a subject in a department
- A teacher can teach the same subject in multiple departments (duplicate `subject_id` per `teacher_id`)
- For each teacher, count how many **distinct** subjects they teach (department doesn't matter)
- Return `teacher_id` and `cnt`, in any order

## 🧠 Solution

```sql
select teacher_id, count(distinct subject_id) as cnt
from Teacher
group by teacher_id;
```

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `group by teacher_id` | Buckets all rows into one group per teacher, so aggregates below are computed per teacher |
| `count(distinct subject_id)` | Counts how many *unique* subject values appear within each teacher's group, collapsing duplicate `(subject_id, dept_id)` rows that share the same subject |
| `select teacher_id, ...` | `teacher_id` is safe to select directly (not wrapped in an aggregate) because it's the group-by column — every row in a group already shares that value |

## 🤔 Why GROUP BY + COUNT(DISTINCT)?

The table's real primary key is `(subject_id, dept_id)`, not `teacher_id` — so a teacher can legitimately appear many times, once per department they teach a subject in. That's exactly why a plain `COUNT(subject_id)` would overcount: teacher 1 teaching subject 2 in both dept 3 and dept 4 is two rows but one subject.

```
Teacher
┌────────────┐        ┌────────────┐
│ teacher_id │───1:N──│ subject_id │  (repeats across dept_id)
└────────────┘        └────────────┘
```

Sample result:

| teacher_id | cnt |
|---|---|
| 1 | 2 |
| 2 | 4 |

## ⚠️ Why not SUM(DISTINCT(teacher_id))?

An earlier draft used:

```sql
select sum(distinct(teacher_id)) as teacher_id, count(distinct(subject_id)) as cnt
from Teacher
group by teacher_id;
```

This also produces the correct output, but only by accident. Since every row in a `GROUP BY teacher_id` group already has one, identical `teacher_id` value, `SUM(DISTINCT(teacher_id))` just re-derives the number that's already sitting there — it's not "summing" anything meaningful, it just happens to equal `teacher_id` itself. It's misleading to read (looks like an aggregation is happening when it isn't) and does unnecessary work. Selecting the group-by column directly (`select teacher_id`) is simpler and says what it means.

## 🐛 Common Mistakes

**Mistake: forgetting DISTINCT inside COUNT**
```sql
-- ❌ Overcounts: counts every (subject_id, dept_id) row, not unique subjects
select teacher_id, count(subject_id) as cnt
from Teacher
group by teacher_id;
```
```sql
-- ✅ Fix: DISTINCT collapses repeated subject_id values within each group
select teacher_id, count(distinct subject_id) as cnt
from Teacher
group by teacher_id;
```

## ⏱️ Time Complexity

O(n log n) — dominated by the grouping/sorting needed to group rows by `teacher_id` and deduplicate `subject_id` within each group (n = number of rows in `Teacher`).

## 🔑 Key Learnings

- A column named in `GROUP BY` can always be selected directly — no aggregate function needed, since it's constant within each group
- `COUNT(DISTINCT col)` is the standard way to count unique values per group, not a workaround
- Watch for tables whose primary key is *not* the column you're grouping by — that's the signal duplicates may need collapsing with `DISTINCT`

## 🎯 Final Query

```sql
select teacher_id, count(distinct subject_id) as cnt
from Teacher
group by teacher_id;
```
