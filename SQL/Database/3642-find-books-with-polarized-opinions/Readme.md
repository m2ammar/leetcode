# 3642. Find Books with Polarized Opinions

![Difficulty](https://img.shields.io/badge/Difficulty-Medium-orange)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-brightgreen)

**Concepts:** `JOIN` · `GROUP BY` · `HAVING` · `CASE WHEN` · `SUM` · `COUNT` · `MAX` · `MIN` · `ROUND` · `ORDER BY`

---

## ✅ Problem Summary

Find books that readers either love or hate. A book qualifies if:

- ✔️ It has **at least 5** reading sessions
- ✔️ It has at least one rating **≥ 4** and at least one rating **≤ 2**
- ✔️ Its polarization score (extreme ratings ÷ total sessions) is **≥ 0.6**

Return the book details, `rating_spread` (highest − lowest rating) and `polarization_score` (rounded to 2 decimals), ordered by score descending, then title descending.

---

## 💡 Solution

```sql
SELECT b.book_id,
       b.title,
       b.author,
       b.genre,
       b.pages,
       MAX(r.session_rating) - MIN(r.session_rating) AS rating_spread,
       ROUND(
            SUM(CASE WHEN r.session_rating <= 2 OR r.session_rating >= 4 THEN 1 ELSE 0 END)
            / COUNT(*),
            2
        ) AS polarization_score
FROM books AS b
JOIN reading_sessions AS r
    ON b.book_id = r.book_id
GROUP BY b.book_id
HAVING COUNT(*) >= 5
    AND polarization_score >= 0.6
    AND MAX(r.session_rating) >= 4
    AND MIN(r.session_rating) <= 2
ORDER BY polarization_score DESC,
         b.title DESC;
```

---

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `JOIN ... ON b.book_id = r.book_id` | Attaches each reading session to its book |
| `GROUP BY b.book_id` | Collapses all sessions of a book into one row |
| `MAX(rating) - MIN(rating)` | Rating spread of the book |
| `SUM(CASE WHEN ... THEN 1 ELSE 0 END)` | Counts only the extreme ratings (≤ 2 or ≥ 4) inside each group |
| `/ COUNT(*)` | Divides by the total number of sessions to get the score |
| `ROUND(..., 2)` | Rounds the score to 2 decimal places |
| `HAVING COUNT(*) >= 5` | Keeps books with at least 5 sessions |
| `HAVING polarization_score >= 0.6` | Keeps books where at least 60% of ratings are extreme |
| `HAVING MAX >= 4 AND MIN <= 2` | Makes sure the book has both a high and a low rating |
| `ORDER BY score DESC, title DESC` | Required output order |

---

## 🤔 Why Conditional Aggregation?

Every rule is about a **group of sessions per book**, so the work is done after grouping:

```
books (1) ───────< reading_sessions (many)
        book_id
```

Example for *The Great Gatsby*:

| rating | extreme? |
|---|---|
| 5 | 1 |
| 1 | 1 |
| 4 | 1 |
| 2 | 1 |
| 5 | 1 |

`SUM = 5`, `COUNT(*) = 5`, so the score is `1.00`.

`CASE` inside `SUM` lets you count *some* rows of a group while `COUNT(*)` still counts *all* of them.

---

## 🚫 Why Not Filter Extreme Ratings in `WHERE`?

```sql
-- ❌ Wrong
WHERE r.session_rating >= 4 OR r.session_rating <= 2
```

`WHERE` removes rows **before** grouping, so the session count and the denominator shrink. A book with ratings `5, 1, 3, 3, 3` has 5 sessions, but after this `WHERE` only 2 rows remain and the book is wrongly rejected. Doing the check inside `SUM(CASE ...)` keeps every row in the group.

---

## ⚠️ Common Mistakes

**1. Nesting aggregates**
```sql
-- ❌
COUNT(MAX(r.session_rating))
```
Aggregates can't be nested, and counting a `MAX` doesn't answer the question. Use `SUM(CASE ...)` to count matching rows.

**2. Summing the wrong column**
```sql
-- ❌
SUM(r.session_id)   -- adds up IDs, which are just labels
-- ✅
COUNT(*)            -- total number of sessions
```

**3. Forgetting the "both sides" rule**
Ratings `4, 4, 5, 5, 4` give a score of `1.00`, but nobody rated low, so the book isn't polarized. Fix with `MAX(rating) >= 4 AND MIN(rating) <= 2` in `HAVING`.

**4. Wrong threshold**
```sql
-- ❌
polarization_score >= 6
-- ✅
polarization_score >= 0.6   -- the score is a fraction
```

---

## ⏱️ Time Complexity

`O(n)` for the join and grouping over `n` reading sessions, plus `O(k log k)` to sort the `k` qualifying books.

---

## 🔑 Key Learnings

- Use `HAVING` for conditions on aggregates, and `WHERE` only for conditions on single rows before grouping
- `SUM(CASE WHEN ... THEN 1 ELSE 0 END)` is the standard way to count rows matching a condition inside a group
- Aggregates can't be nested
- `/` in MySQL gives a decimal result, so `3/5` is `0.6` and no casting is needed
- MySQL allows using a `SELECT` alias (`polarization_score`) in `HAVING`, but other databases may not
- Selecting `b.title`, `b.author` etc. while grouping only by `b.book_id` works because `book_id` is the primary key

---

## ✅ Final Query

```sql
SELECT b.book_id,
       b.title,
       b.author,
       b.genre,
       b.pages,
       MAX(r.session_rating) - MIN(r.session_rating) AS rating_spread,
       ROUND(
            SUM(CASE WHEN r.session_rating <= 2 OR r.session_rating >= 4 THEN 1 ELSE 0 END)
            / COUNT(*),
            2
        ) AS polarization_score
FROM books AS b
JOIN reading_sessions AS r
    ON b.book_id = r.book_id
GROUP BY b.book_id
HAVING COUNT(*) >= 5
    AND polarization_score >= 0.6
    AND MAX(r.session_rating) >= 4
    AND MIN(r.session_rating) <= 2
ORDER BY polarization_score DESC,
         b.title DESC;
```
