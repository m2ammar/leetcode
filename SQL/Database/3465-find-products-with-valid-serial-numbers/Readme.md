# 🔎 3465. Find Products with Valid Serial Numbers

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** `REGEXP_LIKE` · Word Boundary `\b` · Quantifier `{n}` · Case-Sensitive Match Type · `ORDER BY`

---

## ✅ Problem Summary

Table: `products` (`product_id`, `product_name`, `description`)

The query must return:

- ✅ Products whose `description` **contains** a valid serial number (it can appear anywhere in the text)
- ✅ A valid serial is `SN` (case-sensitive) + exactly 4 digits + `-` + exactly 4 digits
- ✅ All three columns: `product_id`, `product_name`, `description`
- ✅ Rows ordered by `product_id` ascending

---

## 💡 Solution

```sql
# Write your MySQL query statement below
select  product_id, product_name, description   
from products
where regexp_like (description, '\\bSN[0-9]{4}-[0-9]{4}\\b', 'c')
order by product_id asc;
```

---

## 🧩 Breakdown

| Part | What it does |
|------|--------------|
| `select product_id, product_name, description` | Returns the three required columns |
| `from products` | Reads from the `products` table |
| `regexp_like(description, pattern, 'c')` | Keeps rows where the pattern appears anywhere in `description`, matched case-sensitively |
| `\\b` (front) | MySQL turns `\\` into `\`, so the regex engine sees `\b`: a word boundary. `SN` must start a word, so `xSN1234-5678` is rejected |
| `SN` | Literal, uppercase letters |
| `[0-9]{4}` | Exactly 4 digits |
| `-` | Literal hyphen |
| `[0-9]{4}` | Exactly 4 digits |
| `\\b` (back) | Word boundary right after the last digit: the next character must not be a word character, which rejects a 5th digit |
| `'c'` | Match type: case-sensitive. MySQL 8 is case-insensitive by default, so `sn1234-5678` would match without it |
| `order by product_id asc` | Sorts the result by `product_id` ascending (`asc` is the default) |

---

## 🤔 Why the back `\\b`?

`REGEXP_LIKE` only asks "does the pattern appear anywhere?", so it is satisfied as soon as it finds 4 digits after the hyphen.

```
Product SN1234-56789 is available now
           ^^^^^^^^^
           SN1234-5678 matches here, leaving the 9 unchecked
```

Without a check after the last 4 digits, product 3 matches wrongly. The boundary asks whether the next character is a word character. `9` is, so there is no boundary and the match fails. A space, punctuation, or the end of the string gives a boundary, so those pass.

| Description | Front `\b` | Back `\b` | Result |
|-------------|-----------|-----------|--------|
| `... with SN1234-5678` | ✅ space before `S` | ✅ end of string | ✅ Match |
| `... SN9876-1234 in ...` | ✅ | ✅ space after | ✅ Match |
| `... SN1234-56789 is ...` | ✅ | ❌ `8` followed by `9` | ❌ No match |
| `No serial number here` | ❌ | ❌ | ❌ No match |

---

## 🚫 Why not `^` and `$`?

```sql
-- ❌ Wrong
'^SN[0-9]{4}-[0-9]{4}$'
```

`^` pins the match to the start of the whole string and `$` to its end, so the description would have to be exactly the serial number. The serial can sit in the middle of the text, so this returns nothing. `^.*SN...[0-9]{4}.*$` lets the serial float again, but the trailing `.*` swallows the extra `9` and product 3 comes back. The check belongs at the end of the serial, not at the end of the string.

---

## ⚠️ Common Mistakes

### 1. Using `=` for a pattern

```sql
-- ❌ Wrong: exact string comparison
where description = '^(?=.*SN[0-9]{4}-[0-9]{4})'
-- ✅ Fix: use REGEXP_LIKE (or REGEXP)
where regexp_like(description, '...')
```

### 2. Misplaced quantifier

```sql
-- ❌ Wrong: class containing 0-9, {, 4, }
[0-9{4}]
-- ✅ Fix: quantifier outside the brackets
[0-9]{4}
```

### 3. Single backslash in a MySQL string

```sql
-- ❌ Wrong: MySQL reads \b as a backspace character, so nothing matches
'\bSN[0-9]{4}-[0-9]{4}\b'
-- ✅ Fix: double the backslash
'\\bSN[0-9]{4}-[0-9]{4}\\b'
```

### 4. Invalid or missing match type

```sql
-- ❌ Wrong: 's' is not a MySQL match type
regexp_like(description, '...', 'sn')
-- ✅ Fix: 'c' for case-sensitive
regexp_like(description, '...', 'c')
```

### 5. Putting `\\b` after a lookahead

```sql
-- ❌ Wrong: a lookahead is zero-width, so \\b checks position 0, not the end of the serial
'^(?=.*SN[0-9]{4}-[0-9]{4})\\b'
-- ✅ Fix: put the boundary directly after the last [0-9]{4}
'\\bSN[0-9]{4}-[0-9]{4}\\b'
```

---

## ⏱️ Time Complexity

**O(n · L)**, where `n` is the number of rows and `L` is the average description length. Each description is scanned once for the pattern, and `ORDER BY` on the key adds a sort of O(n log n) (often free if `product_id` is already ordered by the index).

---

## 🧠 Key Learnings

- `REGEXP_LIKE` searches anywhere in the string, so `^` and `$` are only for whole-string matches
- `{n}` means "at least n", not "exactly n", unless something after it stops the run: "exactly" needs a boundary
- Backslashes go through MySQL's string parser first, so write `\\b` to give the regex engine `\b`
- MySQL 8 regex is case-insensitive by default: pass `'c'` for case-sensitive
- Lookaheads are zero-width, so they don't move the position where later tokens are checked
- `\b` treats `_` as a word character, so `SN1234-5678_` is rejected. For a strict "not followed by a digit" check, use `(?![0-9])` instead

---

## 📌 Final Query

```sql
select  product_id, product_name, description   
from products
where regexp_like (description, '\\bSN[0-9]{4}-[0-9]{4}\\b', 'c')
order by product_id asc;
```
