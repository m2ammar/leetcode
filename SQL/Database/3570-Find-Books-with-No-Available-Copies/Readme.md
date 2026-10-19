# 3570. Find Books with No Available Copies

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** `JOIN` · `WHERE` · `GROUP BY` · `HAVING` · `COUNT()` · `ORDER BY`

---

## ✅ Problem Summary

Given the `library_books` and `borrowing_records` tables, find books that are currently borrowed and have **zero available copies**.

The query must:

- ✔ Return the book's ID, title, author, genre, and publication year
- ✔ Count the number of current borrowers for each book
- ✔ Include only books where all copies are currently borrowed
- ✔ Sort by current borrowers in descending order, then title in ascending order

---

## 💡 Solution

```sql
SELECT
    l.book_id,
    l.title,
    l.author,
    l.genre,
    l.publication_year,
    COUNT(*) AS current_borrowers
FROM library_books AS l
JOIN borrowing_records AS b
    ON l.book_id = b.book_id
WHERE b.return_date IS NULL
GROUP BY
    l.book_id,
    l.title,
    l.author,
    l.genre,
    l.publication_year,
    l.total_copies
HAVING COUNT(*) = l.total_copies
ORDER BY
    current_borrowers DESC,
    l.title ASC;
```

---

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `FROM library_books AS l` | Starts with the library's book information |
| `JOIN borrowing_records AS b` | Connects books to their borrowing records |
| `ON l.book_id = b.book_id` | Matches each book with its borrowing records |
| `WHERE b.return_date IS NULL` | Keeps only books that have not been returned |
| `GROUP BY ...` | Groups active borrowing records by book |
| `COUNT(*) AS current_borrowers` | Counts the active borrowing records for each book |
| `HAVING COUNT(*) = l.total_copies` | Keeps books where every copy is currently borrowed |
| `ORDER BY ...` | Sorts by borrower count descending, then title ascending |

---

## 🤔 Why `HAVING`?

Counting borrowers alone is not enough. The problem asks for books with **zero available copies**.

The formula is:

`available_copies = total_copies - current_borrowers`

Zero available copies means:

`current_borrowers = total_copies`

Since `COUNT(*)` is an aggregate, we use `HAVING` to filter groups after counting them:

```sql
HAVING COUNT(*) = l.total_copies
```

For example:

| Book | Total copies | Current borrowers | Available copies | Result |
|---|---:|---:|---:|---|
| The Great Gatsby | 3 | 3 | 0 | ✅ Include |
| To Kill a Mockingbird | 3 | 2 | 1 | ❌ Exclude |
| 1984 | 1 | 1 | 0 | ✅ Include |
| Pride and Prejudice | 2 | 1 | 1 | ❌ Exclude |

---

## 🔍 Why `WHERE return_date IS NULL`?

A `NULL` return date means the book has not yet been returned.

```sql
WHERE b.return_date IS NULL
```

This ensures that returned books are not counted as current borrowers.

**Important:** `WHERE` filters individual records before grouping.

---

## ⚠️ Common Mistakes

**1. Forgetting `HAVING`**

```sql
-- ❌ Counts current borrowers but does not check availability
GROUP BY l.book_id, ...
```

Fix:

```sql
HAVING COUNT(*) = l.total_copies
```

**2. Counting returned books**

```sql
-- ❌ Includes records for books that have already been returned
COUNT(*)
```

`COUNT(*)` is correct only after filtering the records with `WHERE b.return_date IS NULL`.

**3. Using `WHERE` to filter an aggregate**

```sql
WHERE COUNT(*) = l.total_copies -- ❌
```

Fix: use `HAVING`, because aggregate groups are filtered after `GROUP BY`.

**4. Forgetting `total_copies`**

The query needs `l.total_copies` to compare the number of current borrowers against the total copies owned by the library.

---

## ⏱️ Time Complexity

Let `B` be the number of books and `R` the number of borrowing records.

The query joins and aggregates borrowing records, then sorts the qualifying results. The exact performance depends on indexes, the database engine, and its execution plan.

---

## 🧠 Key Learnings

- `WHERE return_date IS NULL` identifies active borrowing records.
- `COUNT(*)` counts the current borrowing records in each group.
- `GROUP BY` creates one group per book.
- `HAVING` filters groups based on aggregate values.
- Zero available copies means `current_borrowers = total_copies`.
- `ORDER BY current_borrowers DESC, title ASC` applies the required sorting.

---

## 🏁 Final Query

```sql
SELECT
    l.book_id,
    l.title,
    l.author,
    l.genre,
    l.publication_year,
    COUNT(*) AS current_borrowers
FROM library_books AS l
JOIN borrowing_records AS b
    ON l.book_id = b.book_id
WHERE b.return_date IS NULL
GROUP BY
    l.book_id,
    l.title,
    l.author,
    l.genre,
    l.publication_year,
    l.total_copies
HAVING COUNT(*) = l.total_copies
ORDER BY
    current_borrowers DESC,
    l.title ASC;
```
