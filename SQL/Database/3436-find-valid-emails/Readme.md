# 3436. Find Valid Emails

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** `REGEXP` · `Character Sets` · `Quantifiers` · `Anchors` · `Escaping` · `ORDER BY`

---

## ✅ Problem Summary

Given a `Users` table (`user_id`, `email`), return every row whose email is **valid**:

- ✔️ Contains exactly one `@`
- ✔️ Ends with `.com`
- ✔️ The part before `@` has only letters, digits, and underscores
- ✔️ The part between `@` and `.com` has only letters
- ✔️ Result is ordered by `user_id` ascending

---

## 🧩 Solution

```sql
select user_id, email
from Users
where email regexp '^[A-Za-z0-9_]+@[A-Za-z]+\\.com$'
order by user_id;
```

---

## 🔍 Breakdown

| Piece | What it does |
|---|---|
| `^` | Anchors the match to the **start** of the string |
| `[A-Za-z0-9_]+` | One or more letters, digits, or underscores (the name part) |
| `@` | A literal `@`, exactly once |
| `[A-Za-z]+` | One or more letters (the domain name) |
| `\\.com` | A literal dot followed by `com` |
| `$` | Anchors the match to the **end** of the string |
| `order by user_id` | Sorts the result ascending |

---

## 🤔 Why REGEXP?

The rules describe the **shape** of a string, not a fixed value. `REGEXP` lets one pattern describe that shape from start to end:

```
^  name chars  @  letters  .com  $
   [A-Za-z0-9_]+   [A-Za-z]+
```

Sample result:

| user_id | email |
|---|---|
| 1 | alice@example.com |
| 4 | david@domain.com |

"Exactly one `@`" needs no extra check: neither character set allows `@`, so a second one can never match.

---

## ⚖️ Why not LIKE?

`LIKE` only has `%` (any text) and `_` (any one character). It cannot say "only letters, digits, and underscores", so you would need several `LIKE` conditions plus extra string functions, and it still would not check every character. A single `REGEXP` is shorter and checks the whole structure.

---

## 🧱 Regex Pieces at a Glance

| Symbol | Meaning |
|---|---|
| `[abc]` | Any one character from the set |
| `[A-Za-z0-9_]` | Letter, digit, or underscore |
| `+` | One or more of the previous item |
| `*` | Zero or more of the previous item |
| `^` / `$` | Start / end of the string |
| `.` | **Any** character |
| `\\.` | A real dot (MySQL needs the doubled backslash in a string) |

---

## ⚠️ Common Mistakes

**1. Spaces inside the pattern**

```sql
'^[A-Za-z]+ @ + [A-Za-z] + .com $'   -- ❌
```

A space is a real character, so the email would have to contain spaces. Fix: no spaces anywhere in the pattern.

**2. Detached or misplaced `+`**

```sql
'^[A-Za-z]+_+@+[A-Za-z]+\\.com+$'    -- ❌
```

`_+` forces an underscore, `@+` allows several `@`, and `com+` repeats the `m`. Fix: put underscore inside the set, use a bare `@`, and no `+` after `com`.

**3. Unescaped dot**

```sql
'...\\.com' vs '....com'
```

An unescaped `.` matches any character, so `abc@gmailXcom` would pass. Fix: `\\.`

**4. Stray hyphens inside brackets**

```sql
'[A-Za-z-0-9-_]'                     -- ❌
```

Extra `-` characters can be read as literal hyphens, so `my-name@gmail.com` could pass. Fix: `[A-Za-z0-9_]`

---

## ⏱️ Time Complexity

- **Regex check:** O(n × m), where n is the number of rows and m is the email length
- **Sorting:** O(n log n)

---

## 🧠 Key Learnings

- `REGEXP` is used **once**; the whole pattern lives in one string
- A space inside a regex is a real character
- `+` must touch the character or set it repeats
- An unescaped `.` means "any character"; escape it as `\\.` in MySQL
- Anchors `^` and `$` stop partial matches in the middle of a longer string
- Inside `[ ]`, ranges sit side by side with no separators; avoid stray `-`

---

## 🏁 Final Query

```sql
select user_id, email
from Users
where email regexp '^[A-Za-z0-9_]+@[A-Za-z]+\\.com$'
order by user_id;
```
