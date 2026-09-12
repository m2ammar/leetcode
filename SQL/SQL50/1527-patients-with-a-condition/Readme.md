# 1527. Patients With a Condition

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** SELECT · WHERE · LIKE · OR · Wildcards

---

## ✅ Problem Summary

- Find patients who have **Type I Diabetes**
- Type I Diabetes is any condition code starting with `DIAB1`
- `conditions` is a space-separated list of condition codes (can be empty)
- Return `patient_id`, `patient_name`, `conditions`

---

## 🧠 Solution

```sql
select patient_id, patient_name, conditions
from Patients
where conditions like 'DIAB1%' OR conditions like '% DIAB1%';
```

---

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `select patient_id, patient_name, conditions` | Returns the required columns as-is |
| `from Patients` | Source table |
| `conditions like 'DIAB1%'` | Matches when `DIAB1` is the **first** code in the string (nothing before it) |
| `conditions like '% DIAB1%'` | Matches when `DIAB1` appears **after a space**, i.e. as any code after the first |
| `OR` | Combines both cases — a code can start the string or follow a space, never anything else |

---

## 🤔 Why two LIKE patterns?

`conditions` is really a list of codes glued together with spaces, e.g. `"ACNE DIAB100"`. A code only "starts" in two possible places:

```
"DIAB100 MYOP"     -> DIAB100 is at the very start of the string
"ACNE DIAB100"      -> DIAB100 comes right after a space
```

So matching "DIAB1 as the start of some code" means checking both boundaries explicitly — `%` alone doesn't know about word boundaries, it just matches "any characters." Sample result:

| patient_id | patient_name | conditions |
|---|---|---|
| 3 | Bob | DIAB100 MYOP |
| 4 | George | ACNE DIAB100 |

---

## ⚠️ Why not `LIKE '%DIAB1%'`?

A single `LIKE '%DIAB1%'` finds `DIAB1` **anywhere** in the string, including in the middle of another code. For example, a condition string like `"XDIAB100"` would incorrectly match, even though there's no actual `DIAB1` code — it's just a substring collision. Requiring `DIAB1` to sit at the start of the string or right after a space avoids these false positives.

---

## ⚠️ Common Mistakes

**Mistake 1: Using a single unanchored LIKE**
```sql
-- Wrong: matches DIAB1 anywhere, including mid-word
where conditions like '%DIAB1%'
```
Fix: split into a "starts with" case and a "follows a space" case, joined with `OR`.

**Mistake 2: Malformed OR (no column/operator on one side)**
```sql
-- Wrong: right side isn't a valid condition
where conditions like 'DIAB1%' OR 'DIAB1_%'
```
Fix: every side of an `OR` needs its own full `column LIKE pattern` condition.

---

## ⏱ Time Complexity

O(n) — a single scan of the `Patients` table, with a pattern match against `conditions` for each row.

---

## 🔑 Key Learnings

- `%` matches any sequence of characters, `_` matches exactly one — but neither implies a word/token boundary
- To enforce "starts a token," combine a start-of-string pattern with a space-then-pattern to cover every position a token can begin
- `OR` requires a complete condition on each side; you can't shorthand a second pattern without repeating `column LIKE`

---

## Final Query

```sql
select patient_id, patient_name, conditions
from Patients
where conditions like 'DIAB1%' OR conditions like '% DIAB1%';
```
