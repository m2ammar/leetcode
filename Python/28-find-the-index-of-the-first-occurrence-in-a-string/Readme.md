# 28. Find the Index of the First Occurrence in a String

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen) ![Topic](https://img.shields.io/badge/Topic-String-blue) ![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** String Searching · Built-in Methods · Sliding Window (manual alternative)

---

## ✅ Problem Summary

- Given `haystack` and `needle`, return the index of the **first** occurrence of `needle` in `haystack`.
- Return `-1` if `needle` does not occur in `haystack` at all.
- Both strings consist of lowercase English letters, length between 1 and 10⁴.

---

## 🧠 Solution

```python
class Solution:
    def strStr(self, haystack: str, needle: str) -> int:
        return haystack.find(needle)
```

---

## 🧩 Breakdown

| Line | What it does |
|---|---|
| `haystack.find(needle)` | Searches `haystack` for the first occurrence of `needle` and returns its starting index. |
| *(built-in behavior)* | If `needle` isn't found anywhere in `haystack`, `.find()` automatically returns `-1` — exactly matching what the problem asks for, with no extra logic needed. |

---

## 🤔 Why `.find()`?

`str.find()` is a built-in method that does precisely what the problem describes: locate the first index where a substring begins, or signal "not found" with `-1`. Since the problem's expected output format (index, or `-1`) matches `.find()`'s return contract exactly, there's no translation layer needed — no `if/else`, no manual searching.

```
haystack = "sadbutsad"
index:      0123456789
needle  =   "sad"
             ^ first match starts at index 0
                    ^ second match at index 6 (not returned — we want the first)
```

`.find()` scans left to right and stops at the very first match, which is exactly the "first occurrence" behavior required.

---

## ⚠️ Why not `in`?

A tempting first instinct is:
```python
if needle in haystack:
    return 0
else:
    return -1
```
This is wrong because `in` only answers a yes/no question ("does needle exist somewhere in haystack?") — it throws away *where* the match happened. For `haystack = "butsad"`, `needle = "sad"`, `"sad" in "butsad"` is `True`, but the actual first occurrence is at index **3**, not 0. `in` cannot express that.

---

## 🚧 Common Mistakes

**Mistake 1 — using `in` and assuming the match is always at index 0**
```python
# Wrong: returns 0 whenever needle exists anywhere, regardless of actual position
if needle in haystack:
    return 0
```
✅ Fix: use `.find()`, which returns the real starting index, not just presence/absence.

**Mistake 2 — hardcoding the needle's length as a bound**
```python
# Wrong: assumes needle is always length 3
for i in range(len(haystack) - 3):
```
✅ Fix: the valid range of starting positions depends on `len(needle)`, not a fixed number — it should be `range(len(haystack) - len(needle) + 1)`.

**Mistake 3 — off-by-one in the manual loop's upper bound**
```python
# Wrong: misses the last valid starting position
for i in range(len(haystack) - len(needle)):
```
✅ Fix: use `+ 1` in the range so the last valid index (where the remaining haystack is exactly `len(needle)` long) is included.

---

## 🔍 Manual Alternative (Sliding Window)

Since interviews often ask for `strStr()` to be implemented without built-ins, here's the underlying logic `.find()` performs internally:

```python
class Solution:
    def strStr(self, haystack: str, needle: str) -> int:
        n, m = len(haystack), len(needle)
        for i in range(n - m + 1):
            if haystack[i:i+m] == needle:
                return i
        return -1
```

| Piece | Purpose |
|---|---|
| `range(n - m + 1)` | Only checks starting positions where enough characters remain in `haystack` for `needle` to fully fit. |
| `haystack[i:i+m]` | Slices out a chunk of `haystack` the same length as `needle`, starting at position `i`. |
| `== needle` | Direct string comparison — order and content must match exactly. |
| `return i` | Returns immediately on the first match, guaranteeing it's the *first* occurrence. |
| `return -1` | Reached only if the loop finishes with no match found. |

---

## ⏱️ Time Complexity

- **Built-in `.find()`:** effectively `O(n)` on average in CPython (uses an optimized substring search algorithm under the hood).
- **Manual sliding window:** `O((n - m) * m)` worst case — for each of the `n - m + 1` starting positions, comparing up to `m` characters via slicing.

---

## 🔑 Key Learnings

- `str.find()` returns an **index** (or `-1`), while `in` only returns a **boolean** — they answer different questions and aren't interchangeable when position matters.
- Loop bounds for substring search must be derived from `len(needle)`, not hardcoded — the valid range of starting positions is `range(len(haystack) - len(needle) + 1)`.
- Built-ins are the right choice in production code; manual implementation is a distinct skill worth practicing separately for interviews.

---

## 🏁 Final Query

```python
class Solution:
    def strStr(self, haystack: str, needle: str) -> int:
        return haystack.find(needle)
```
