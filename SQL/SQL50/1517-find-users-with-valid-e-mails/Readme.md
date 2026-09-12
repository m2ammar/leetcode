# 1517. Find Users With Valid E-Mails

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** REGEXP · Character Classes · Anchors · COLLATE · Case Sensitivity

---

## ✅ Problem Summary
- Return users whose email is valid
- A valid email has a prefix and a domain:
  - Prefix: letters (upper/lower), digits, `_`, `.`, `-` — must **start with a letter**
  - Domain: must be exactly `@leetcode.com` in lowercase

---

## 🧩 Solution
```sql
select user_id, name, mail
from Users
where mail COLLATE utf8_bin REGEXP '^[A-Za-z][A-Za-z0-9_.-]*@leetcode\\.com$';
```

---

## 🔍 Breakdown

| Clause | What it does |
|---|---|
| `^[A-Za-z]` | Anchors to the start of the string, requires exactly one letter (upper or lower) first |
| `[A-Za-z0-9_.-]*` | Allows zero or more letters, digits, underscore, period, or dash after the first letter |
| `@leetcode\\.com$` | Requires the literal domain `@leetcode.com`, with the dot escaped so it matches a real period, anchored to the end of the string |
| `mail COLLATE utf8_bin` | Forces case-sensitive comparison so `.COM` or `.Com` is rejected |

---

## 🤔 Why REGEXP?
The validation rule isn't a simple exact match or prefix/suffix check — it depends on the *shape* of the string (which characters appear, in which position). `REGEXP` lets you describe that shape directly as a pattern, in one condition, instead of chaining multiple `LIKE`/string functions together.

---

## ⚠️ Why not LIKE?
`LIKE` only supports wildcards `%` (any sequence) and `_` (any single character) — it can't express "must be a letter specifically" or "one of this specific character set." You'd need several stacked conditions (checking the first character separately, checking for disallowed characters, etc.), which gets messy and error-prone compared to one clean regex pattern.

---

## ⚠️ Common Mistakes

**Mistake 1: Single backslash for the escaped dot**
```sql
-- Wrong: SQL's string parser strips one backslash before REGEXP ever sees it
'...@leetcode\.com$'
```
Fix: use double backslash `\\.` so the regex engine actually receives `\.`

**Mistake 2: Assuming REGEXP is case-sensitive by default**
```sql
-- Wrong: matches "leetcode.COM" too, since REGEXP is case-insensitive by default
where mail REGEXP '^[A-Za-z][A-Za-z0-9_.-]*@leetcode\\.com$'
```
Fix: add `COLLATE utf8_bin` (or `BINARY`, if your column's charset allows it) to force case sensitivity

**Mistake 3: Using BINARY on a mismatched charset**
```sql
-- Wrong: BINARY casts to a different character set entirely, clashing with utf8mb4/utf8mb3 columns
where BINARY mail REGEXP '...'
```
Fix: use `COLLATE <charset>_bin` instead, matching your column's actual charset (`utf8_bin` for `utf8mb3`, `utf8mb4_bin` for `utf8mb4`)

---

## ⏱️ Time Complexity
O(n) — single pass over all rows, regex evaluated once per row

---

## 🔑 Key Learnings
- Regex anchors (`^`, `$`) and character classes (`[A-Za-z0-9_.-]`) can express structural validation in one pattern
- SQL string literals process backslashes before the regex engine does — double escaping is needed for literal special characters
- `REGEXP` is case-insensitive by default in MySQL; `COLLATE` must match the column's actual charset family

---

## 🧠 Final Query
```sql
select user_id, name, mail
from Users
where mail COLLATE utf8_bin REGEXP '^[A-Za-z][A-Za-z0-9_.-]*@leetcode\\.com$';
```
