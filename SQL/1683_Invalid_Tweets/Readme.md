# 1683. Invalid Tweets

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** `SELECT` · `WHERE` · `LENGTH()` · String Functions

---

## 📋 Problem Summary

Find the IDs of tweets that are **invalid**.

A tweet is considered invalid if:

- ✅ The number of characters in `content` is **greater than 15**

Return only the `tweet_id`.

---

## ✅ Solution

```sql
SELECT tweet_id
FROM Tweets
WHERE LENGTH(content) > 15;
```

---

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `SELECT tweet_id` | Returns only the tweet IDs |
| `FROM Tweets` | Reads data from the Tweets table |
| `WHERE` | Filters rows based on a condition |
| `LENGTH(content)` | Calculates the length of each tweet |
| `> 15` | Returns only tweets with more than 15 characters |

---

## 🤔 Why `LENGTH()`?

`LENGTH()` returns the length of a string.

Example:

```sql
SELECT LENGTH('Hello');
```

Output:

```
5
```

In this problem:

```sql
WHERE LENGTH(content) > 15
```

means:

> Return only tweets whose content contains more than 15 characters.

---

## ⚠️ LENGTH() vs CHAR_LENGTH()

For English text, both functions usually return the same result.

Example:

```sql
SELECT LENGTH('SQL');
```

Output

```
3
```

```sql
SELECT CHAR_LENGTH('SQL');
```

Output

```
3
```

However, Unicode characters are different.

Example:

```sql
SELECT LENGTH('😊');
```

Output

```
4
```

because the emoji occupies 4 bytes.

```sql
SELECT CHAR_LENGTH('😊');
```

Output

```
1
```

because it is one character.

For this LeetCode problem, `LENGTH()` works perfectly because the content contains only English letters, numbers, spaces, and punctuation.

---

## ⚠️ Common Mistakes

### Forgetting the function

❌ Incorrect

```sql
WHERE content > 15;
```

`content` is text, not a number.

---

### Using the wrong comparison

❌ Incorrect

```sql
WHERE LENGTH(content) >= 15;
```

The problem says **strictly greater than 15**, so the correct operator is:

```sql
>
```

---

## ⏱️ Time Complexity

**O(n)** — each tweet is checked once.

---

## 🔑 Key Learnings

- Use `LENGTH()` to measure the size of a string.
- String functions can be used directly inside a `WHERE` clause.
- Read comparison operators carefully (`>`, `>=`, `<`, `<=`).
- When filtering based on text length, `LENGTH()` is often the simplest solution.

---

## 🧠 Final Query

```sql
SELECT tweet_id
FROM Tweets
WHERE LENGTH(content) > 15;
```
