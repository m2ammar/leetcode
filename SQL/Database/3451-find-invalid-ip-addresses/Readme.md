# 3451. Find Invalid IP Addresses

![Difficulty](https://img.shields.io/badge/Difficulty-Hard-red)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-brightgreen)

**Concepts:** `SUBSTRING_INDEX` · `CAST` · `REGEXP` · `NOT REGEXP` · `LENGTH` · `REPLACE` · `GROUP BY` · `COUNT` · `ORDER BY`

---

## ✅ Problem Summary

From the `logs` table, return every **invalid IPv4 address** with how many times it appears:

- ✔️ An octet greater than `255` makes the IP invalid
- ✔️ An octet with a leading zero (e.g. `01.02.03.04`) makes the IP invalid
- ✔️ Fewer or more than `4` octets makes the IP invalid
- ✔️ Every octet must have `1` to `3` digits (this hidden rule is in the first sentence of the problem)
- ✔️ Output `ip` and `invalid_count`, ordered by `invalid_count DESC`, then `ip DESC`

---

## 💡 Solution

```sql
select ip, count(ip) as invalid_count
from logs
where cast(SUBSTRING_INDEX(SUBSTRING_INDEX(ip, '.', 1), '.', -1)  as unsigned) > 255 or 
      cast(SUBSTRING_INDEX(SUBSTRING_INDEX(ip, '.', 2), '.', -1)  as unsigned) > 255 or 
      cast(SUBSTRING_INDEX(SUBSTRING_INDEX(ip, '.', 3), '.', -1)  as unsigned) > 255 or 
      cast(SUBSTRING_INDEX(SUBSTRING_INDEX(ip, '.', 4), '.', -1)  as unsigned) > 255 or 
      LENGTH(ip) - LENGTH(REPLACE(ip, '.', '')) != 3 or 
      ip regexp '(^|\\.)0[0-9]' or
      ip NOT REGEXP '^([0-9]{1,3}\\.){3}[0-9]{1,3}$'
group by ip
order by invalid_count desc, ip desc;
```

---

## 🧩 Breakdown

| Part of the query | What it does |
|---|---|
| `SUBSTRING_INDEX(SUBSTRING_INDEX(ip, '.', n), '.', -1)` | Takes the first `n` pieces, then keeps only the last one, which is the nth octet |
| `CAST(... AS UNSIGNED) > 255` | Turns the octet text into a number so the comparison is numeric, not alphabetical (four times, one per octet) |
| `LENGTH(ip) - LENGTH(REPLACE(ip, '.', '')) != 3` | Counts the dots. A valid IP has exactly 3 |
| `ip regexp '(^\|\\.)0[0-9]'` | Finds a `0` followed by a digit at the start of the string or right after a dot, which is a leading zero |
| `ip NOT REGEXP '^([0-9]{1,3}\\.){3}[0-9]{1,3}$'` | Flags any IP that is not "1 to 3 digits, three times with dots, then 1 to 3 digits" (empty octets, junk characters, wrong octet count) |
| `OR` between all conditions | An IP is invalid if any one rule is broken |
| `GROUP BY ip` + `COUNT(ip)` | Counts how many log rows each invalid IP has |
| `ORDER BY invalid_count DESC, ip DESC` | Sorts as the problem requires |

---

## 🤔 Why check each rule separately?

`invalid_count` is **not** the number of mistakes inside an IP. It is the number of **rows** where that IP appears.

```
logs row 2: 256.1.2.3   ─┐
logs row 6: 256.1.2.3   ─┴─► invalid_count = 2 (one mistake, two rows)
```

So the query only needs a row-level yes/no question: "is this IP invalid?" That is why all rules are joined with `OR` in `WHERE`, and counting happens afterwards with `GROUP BY`.

| ip | invalid_count |
|---|---|
| 256.1.2.3 | 2 |
| 192.168.001.1 | 2 |
| 192.168.1 | 1 |

---

## 🆚 Why not `HAVING`?

`WHERE` filters **individual rows before grouping**, and "is this IP invalid?" is a per-row question. `HAVING` filters **groups after** aggregation (e.g. `COUNT(*) > 1`), which is not what we need here.

---

## ⚠️ Common Mistakes

**1. Grouping by the wrong column**
```sql
group by id   -- wrong: no such column, and one group per row
```
Fix: `group by ip`, because we count how often each IP appears.

**2. `|` in regex without brackets**
```sql
'^|\\.0[0-9]'   -- wrong: "^" alone matches every string
```
`|` splits the whole pattern. Fix: group the choice, `(^|\\.)0[0-9]`.

**3. Putting `or` inside `CAST`**
```sql
cast(piece1 or piece2 as unsigned) > 255   -- wrong: or returns 0 or 1
```
Fix: one comparison per octet, with `or` between the comparisons.

**4. `{3}` attached only to the dot**
```sql
'^[0-9]{1,3}\\.{3}[0-9]{1,3}$'   -- wrong: means three dots in a row
```
Fix: group the whole block, `^([0-9]{1,3}\\.){3}[0-9]{1,3}$`.

**5. Single backslash in a MySQL string**
```sql
'(^|\.)0[0-9]'   -- wrong: \. collapses to . (any character)
```
Fix: `\\.`, so the regex engine receives `\.`, a literal dot.

---

## ⏱️ Time Complexity

- Scan: `O(n)` over the rows, with constant work per IP (a fixed number of string operations)
- Grouping and sorting: `O(k log k)` for `k` distinct invalid IPs

---

## 🔑 Key Learnings

- The problem text has a hidden fourth rule ("1 to 3 digits") that the three bullet points don't cover. Empty octets like `1..2.3` pass the three bullets unless a shape check is added.
- `SUBSTRING_INDEX` nested twice extracts the nth piece. `-1` gives the last piece.
- Always `CAST` before comparing numbers stored as text.
- Dot-count trick: `LENGTH(x) - LENGTH(REPLACE(x, '.', ''))` counts a character.
- In regex, `|` splits the whole pattern unless grouped with `( )`, and a quantifier repeats only the item right before it.
- `^` and `$` anchor a pattern to the whole string. Without `$`, `1.2.3.4.5` would match inside.
- In a MySQL string, a literal dot in regex is written `\\.`.
- The shape check already catches the wrong-octet-count cases, so the `!= 3` dot-count line is redundant. It is harmless to keep.
- `0.0.0.0` is valid: the leading-zero regex needs `0` followed by a digit.

---

## 🧾 Final Query

```sql
select ip, count(ip) as invalid_count
from logs
where cast(SUBSTRING_INDEX(SUBSTRING_INDEX(ip, '.', 1), '.', -1)  as unsigned) > 255 or 
      cast(SUBSTRING_INDEX(SUBSTRING_INDEX(ip, '.', 2), '.', -1)  as unsigned) > 255 or 
      cast(SUBSTRING_INDEX(SUBSTRING_INDEX(ip, '.', 3), '.', -1)  as unsigned) > 255 or 
      cast(SUBSTRING_INDEX(SUBSTRING_INDEX(ip, '.', 4), '.', -1)  as unsigned) > 255 or 
      LENGTH(ip) - LENGTH(REPLACE(ip, '.', '')) != 3 or 
      ip regexp '(^|\\.)0[0-9]' or
      ip NOT REGEXP '^([0-9]{1,3}\\.){3}[0-9]{1,3}$'
group by ip
order by invalid_count desc, ip desc;
```
