# 595. Big Countries

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** `SELECT` · `WHERE` · `OR` operator · Filtering rows

---

## 📋 Problem Summary

Find all countries that are considered **big**.

A country is big if it satisfies **at least one** of the following conditions:

- ✅ Area is **3,000,000 km² or more**
- ✅ Population is **25,000,000 or more**

Return:

- `name`
- `population`
- `area`

---

## ✅ Solution

```sql
SELECT name,
       population,
       area
FROM World
WHERE area >= 3000000
   OR population >= 25000000;
```

---

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `SELECT` | Returns only the required columns |
| `FROM World` | Reads data from the World table |
| `WHERE` | Filters countries based on conditions |
| `area >= 3000000` | Checks if the country's area is at least 3 million km² |
| `OR population >= 25000000` | Also includes countries with a population of at least 25 million |

---

## 🤔 Why `OR`?

The problem states that a country is considered **big if either condition is true**.

| Area ≥ 3M | Population ≥ 25M | Returned? |
|:---:|:---:|:---:|
| ✅ | ✅ | ✅ |
| ✅ | ❌ | ✅ |
| ❌ | ✅ | ✅ |
| ❌ | ❌ | ❌ |

If we used `AND`, only countries satisfying **both** conditions would be returned, which is **not** what the problem asks.

---

## ⚠️ Common Mistake

Using `AND` instead of `OR`.

❌ Incorrect

```sql
WHERE area >= 3000000
AND population >= 25000000;
```

This excludes countries that satisfy only one of the conditions.

---

## ⏱️ Time Complexity

**O(n)** — the database scans each country once and evaluates both conditions.

---

## 🔑 Key Learnings

- Use `OR` when **either** condition can be true.
- Use `AND` only when **all** conditions must be satisfied.
- Read the problem statement carefully—words like **or** and **and** directly determine the SQL operator.

---

## 🧠 Final Query

```sql
SELECT name,
       population,
       area
FROM World
WHERE area >= 3000000
   OR population >= 25000000;
```
