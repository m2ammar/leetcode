# 🧬 3475. DNA Pattern Recognition

![Difficulty](https://img.shields.io/badge/Difficulty-Medium-orange)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-brightgreen)

**Concepts:** `LIKE` · `REGEXP` · `Wildcards` · `Alternation` · `Anchors` · `Boolean Flags` · `ORDER BY`

---

## ✅ Problem Summary

For every row in `Samples`, return:

- ✔️ `sample_id`, `dna_sequence`, `species`
- ✔️ `has_start`: 1 if the sequence starts with `ATG`
- ✔️ `has_stop`: 1 if the sequence ends with `TAA`, `TAG`, or `TGA`
- ✔️ `has_atat`: 1 if the sequence contains `ATAT`
- ✔️ `has_ggg`: 1 if the sequence has at least 3 consecutive `G`
- ✔️ Ordered by `sample_id` ascending

---

## 🧩 Solution

```sql
SELECT
    sample_id,
    dna_sequence,
    species,
    dna_sequence LIKE 'ATG%'              AS has_start,
    dna_sequence REGEXP '(TAA|TAG|TGA)$'  AS has_stop,
    dna_sequence LIKE '%ATAT%'            AS has_atat,
    dna_sequence LIKE '%GGG%'             AS has_ggg
FROM Samples
ORDER BY sample_id;
```

---

## 🔍 Breakdown

| Clause | What it does |
|---|---|
| `dna_sequence LIKE 'ATG%'` | No wildcard at the front, so `ATG` must be the prefix |
| `dna_sequence REGEXP '(TAA\|TAG\|TGA)$'` | Group of three alternatives, `$` anchors it to the end of the string |
| `dna_sequence LIKE '%ATAT%'` | Wildcards on both sides, so `ATAT` can appear anywhere |
| `dna_sequence LIKE '%GGG%'` | "At least 3 G in a row" is the same as "contains GGG" |
| `AS has_...` | Names each flag column to match the expected output |
| `ORDER BY sample_id` | Ascending is the default |

---

## 🤔 Why flags in `SELECT`, not `WHERE`?

The problem asks for a 1/0 result per pattern for **every** sample, including samples that match nothing (like sample 5 and 7). Putting the checks in `WHERE` would drop those rows.

In MySQL, `LIKE` and `REGEXP` return `1` or `0`, so they work directly as flag columns.

```
Samples row  ──►  4 independent checks  ──►  4 flag columns (0/1)
(one row in)                                  (one row out)
```

| sample_id | dna_sequence | has_start | has_stop | has_atat | has_ggg |
|---|---|---|---|---|---|
| 4 | ATGGGGTCATCATAA | 1 | 1 | 0 | 1 |
| 5 | TCAGTCAGTCAG | 0 | 0 | 0 | 0 |

---

## 🚫 Why not `COUNT` / `SUM` / `GROUP BY`?

Those are aggregates and collapse rows. This problem is **per row**: each sample keeps its own flags, so no aggregation is needed.

## 🚫 Why not `IF` / `CASE`?

`IF(dna_sequence LIKE 'ATG%', 1, 0)` gives the same result, but it is wordier. The comparison already returns 1 or 0.

---

## 📖 LIKE vs REGEXP at a Glance

| | `LIKE` | `REGEXP` |
|---|---|---|
| Wildcards | `%` (any length), `_` (one char) | `.`, `*`, `+`, `{n,m}` |
| Anchors (`^`, `$`) | ❌ | ✅ |
| Alternation (`\|`) | ❌ | ✅ |
| Character classes `[...]` | ❌ | ✅ |
| Best for | Simple prefix / suffix / contains | Multiple alternatives, anchored patterns |

---

## ⚠️ Common Mistakes

### 1. Regex syntax inside `LIKE`
```sql
dna_sequence LIKE '%[TAA | TAG | TGA]'   -- ❌
```
`LIKE` has no brackets, alternation, or anchors, so this is treated as literal text. Even in regex, `[TAA|TAG|TGA]` is a character class (one single character), not three words.

**Fix:**
```sql
dna_sequence REGEXP '(TAA|TAG|TGA)$'     -- ✅
```

### 2. Wildcard only on one side
```sql
dna_sequence LIKE '%GGG'                 -- ❌ only matches sequences ENDING in GGG
dna_sequence LIKE '%GGG%'                -- ✅ matches GGG anywhere
```

### 3. Checking the wrong column
Using `species` instead of `dna_sequence` for the pattern checks.

### 4. Missing aliases
Flag columns without `AS has_...` produce the wrong output column names.

---

## ⏱️ Time Complexity

**O(N × L)**, where N is the number of rows and L is the sequence length. Leading wildcards (`%...`) and `REGEXP` can't use an index, so each row is scanned once per check.

---

## 🔑 Key Learnings

- 🧠 `LIKE` only knows `%` and `_`. Anchors, brackets, and alternation belong to `REGEXP`.
- 🧠 Mixing `LIKE` (simple checks) and `REGEXP` (alternation) in one query is fine.
- 🧠 Comparisons return `1`/`0` in MySQL, so they work as flag columns without `IF` or `CASE`.
- 🧠 "At least 3 consecutive G" simplifies to "contains GGG", with no quantifier needed.
- 🧠 Per-row flags mean no aggregates and no `GROUP BY`.

---

## 🏁 Final Query

```sql
SELECT
    sample_id,
    dna_sequence,
    species,
    dna_sequence LIKE 'ATG%'              AS has_start,
    dna_sequence REGEXP '(TAA|TAG|TGA)$'  AS has_stop,
    dna_sequence LIKE '%ATAT%'            AS has_atat,
    dna_sequence LIKE '%GGG%'             AS has_ggg
FROM Samples
ORDER BY sample_id;
```
