# 242. Valid Anagram

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-Python-blue)
![Status](https://img.shields.io/badge/Status-Accepted-brightgreen)

**Concepts:** Hash Map · `collections.Counter` · String

---

## ✅ Problem Summary

Given two strings `s` and `t`:
- [x] Return `True` if `t` is an anagram of `s` (same letters, same frequency of each, order doesn't matter)
- [x] Return `False` otherwise

---

## 🧠 Solution

```python
from collections import Counter

class Solution:
    def isAnagram(self, s: str, t: str) -> bool:
        c1 = Counter(s)
        c2 = Counter(t)
        return c1 == c2
```

---

## 🧩 Breakdown

| Line | What it does |
|---|---|
| `Counter(s)` | Builds a frequency map of every character in `s` in a single pass — e.g. `Counter("ammar")` → `{'a': 3, 'm': 2, 'r': 1}` |
| `Counter(t)` | Same, for `t` |
| `c1 == c2` | `Counter` is a `dict` subclass, so `==` compares both the keys (which letters appear) and the values (how many of each) — exactly what "same letters, same frequency" means |

---

## 🤔 Why `Counter` instead of manual counting?

Checking anagram-ness by hand would mean writing a loop to build a frequency dict from scratch for each string, then another loop (or dict comparison) to check they match. `Counter` collapses the "count every character" step into one call, and Python's built-in dict equality collapses the "compare all frequencies" step into one operator.

```
s = "anagram"        t = "nagaram"
Counter(s)            Counter(t)
┌─────┬───┐           ┌─────┬───┐
│  a  │ 3 │           │  a  │ 3 │
│  n  │ 1 │           │  n  │ 1 │
│  g  │ 1 │    ==      │  g  │ 1 │   → True
│  r  │ 1 │           │  r  │ 1 │
│  m  │ 1 │           │  m  │ 1 │
└─────┴───┘           └─────┴───┘
```

**Sample result:** `isAnagram("anagram", "nagaram")` → `True`

---

## ⚠️ Common Mistakes

**Mistake 1 — Checking presence instead of frequency:**
```python
# ❌ Wrong: only checks that each char in t exists somewhere in s,
# not that the counts match
for char in t:
    if char not in s:
        return False
return True
```
This would incorrectly accept `s = "aab"`, `t = "abb"` as anagrams — every character in `t` does appear in `s`, but the *counts* differ (two `a`s vs one `a`).

**Mistake 2 — Wrapping an already-boolean comparison in `if/else`:**
```python
# ❌ Redundant
if c1 == c2:
    return True
else:
    return False
```
`c1 == c2` already evaluates to `True`/`False` — just return it directly.

---

## ⏱️ Time & Space Complexity

- **Time:** O(N) — building each `Counter` is a single linear pass over its string; comparing the two `Counter`s is proportional to the number of unique keys.
- **Space:** O(1) for lowercase English letters specifically, since there are at most 26 possible keys regardless of string length. (See follow-up below — this changes for Unicode input.)

---

## 🔑 Key Learnings

- `collections.Counter` builds a full character-frequency map in one call — no manual loop needed
- Two `Counter` objects (like two dicts) can be compared directly with `==`; Python checks keys and values for you
- "Same characters" and "same character *frequencies*" are different checks — anagram problems need the latter
- A boolean expression doesn't need an `if/else` wrapper if you're just returning it

---

## 🌍 Follow-up: Unicode Characters

The code itself doesn't need to change — `Counter` and Python strings work the same way regardless of what characters they contain, so this solution already handles Unicode input correctly.

What *does* change is the complexity analysis: the "O(1) space" claim relies on there being only 26 possible lowercase English letters, so a `Counter` can never hold more than 26 entries. With Unicode, the number of distinct possible characters is far larger, so the honest complexity becomes **O(N) space** in the worst case — proportional to the number of *unique* characters actually present in the input, which can scale with the length of the string.

---

## 🧾 Final Solution

```python
from collections import Counter

class Solution:
    def isAnagram(self, s: str, t: str) -> bool:
        c1 = Counter(s)
        c2 = Counter(t)
        return c1 == c2
```
