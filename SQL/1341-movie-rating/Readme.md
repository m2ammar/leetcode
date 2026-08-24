# 1341. Movie Rating

![Difficulty](https://img.shields.io/badge/Difficulty-Medium-orange)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-brightgreen)

**Concepts:** JOIN · GROUP BY · COUNT · AVG · ORDER BY (multi-key) · LIMIT · UNION ALL · BETWEEN

---

## ✅ Problem Summary

- [x] Find the user who rated the greatest number of movies (tie → lexicographically smaller name)
- [x] Find the movie with the highest average rating in February 2020 (tie → lexicographically smaller title)
- [x] Return both as a single two-row `results` column

---

## 🧩 Solution

```sql
(select u.name as results
from Users as u
join MovieRating as mr
on u.user_id = mr.user_id
group by u.user_id 
order by count(mr.movie_id) desc, u.name asc 
limit 1)
Union All
(Select m.title as results
from Movies as m
join MovieRating as mr
on m.movie_id = mr.movie_id
where created_at Between '2020-02-01' AND '2020-02-29'
group by m.movie_id
order by avg(mr.rating) desc, m.title asc
limit 1);
```

---

## 🔍 Breakdown

| Clause | Purpose |
|---|---|
| `JOIN Users/Movies ... MovieRating` | Bring in the name/title, since `MovieRating` only stores IDs |
| `GROUP BY u.user_id` / `GROUP BY m.movie_id` | Aggregate ratings per user / per movie |
| `COUNT(mr.movie_id)` | Number of movies each user rated |
| `AVG(mr.rating)` | Average rating per movie |
| `WHERE created_at BETWEEN '2020-02-01' AND '2020-02-29'` | Restrict part 2 to February 2020 only |
| `ORDER BY <metric> DESC, name/title ASC` | Rank by count/avg first, then break ties alphabetically |
| `LIMIT 1` | Keep only the top row from each subquery |
| `UNION ALL` | Combine both single-row results without deduplicating |

---

## 🤔 Why UNION ALL (not UNION)?

The two subqueries are conceptually unrelated — one returns a user name, the other a movie title. `UNION` removes duplicate rows across both sides, which silently drops a row whenever a user's name happens to equal a movie's title (e.g. both are `"Rebecca"`). `UNION ALL` keeps both rows regardless of overlap, which is what the problem actually wants: always exactly one row from each part.
```mermaai
Users ── user_id ──┐
├── MovieRating (movie_id, user_id, rating, created_at)
Movies ── movie_id ─┘
```


Sample result:

| results  |
|---|
| Daniel   |
| Frozen 2 |

---

## ⚠️ Common Mistakes

**Using a bare aggregate in HAVING with no comparison:**
```sql
-- Wrong: HAVING needs a condition, not a bare function
having max(mr.rating)
```
```sql
-- Fix: rank with ORDER BY instead — no filtering needed here
order by count(mr.movie_id) desc, u.name asc
```

**Using UNION instead of UNION ALL:**
```sql
-- Wrong: collapses the two rows when name == title
... Union ...
```
```sql
-- Fix: keep both independent rows
... Union All ...
```

**Unpadded date literals:**
```sql
-- Risky: relies on lenient date parsing
where created_at Between '2020-02-1' AND '2020-02-29'
```
```sql
-- Fix: zero-pad for portability/clarity
where created_at Between '2020-02-01' AND '2020-02-29'
```

---

## ⏱️ Time Complexity

O(n log n) — dominated by the GROUP BY aggregation and ORDER BY sort on each subquery (n = rows in `MovieRating`).

---

## 🔑 Key Learnings

- A single `ORDER BY metric DESC, name ASC` handles ranking + lexicographic tie-break in one clause
- `UNION` dedupes across unrelated result sets; `UNION ALL` doesn't — pick based on whether overlap is meaningful or coincidental
- Each side of a `UNION`/`UNION ALL` needs its own parentheses when using `ORDER BY ... LIMIT` per subquery

---

## Final Query

```sql
(select u.name as results
from Users as u
join MovieRating as mr
on u.user_id = mr.user_id
group by u.user_id 
order by count(mr.movie_id) desc, u.name asc 
limit 1)
Union All
(Select m.title as results
from Movies as m
join MovieRating as mr
on m.movie_id = mr.movie_id
where created_at Between '2020-02-01' AND '2020-02-29'
group by m.movie_id
order by avg(mr.rating) desc, m.title asc
limit 1);
```
