# 389. Find the Difference
![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen) ![Topic](https://img.shields.io/badge/Topic-Python-blue) ![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** collections.Counter · Hash Map · Dictionary Subtraction · iter() · next()

---

### ✅ Problem Summary
- `t` is `s` shuffled, plus one extra letter inserted at a random position
- Return the extra letter that was added
- `0 <= s.length <= 1000`, `t.length == s.length + 1`

---

### 🧩 Solution
```python
from collections import Counter

class Solution:
    def findTheDifference(self, s: str, t: str) -> str:
        c1 = Counter(s)
        c2 = Counter(t)
        c3 = c2 - c1
        c4 = next(iter(c3.keys()))
        return c4
```

---

### 🔍 Breakdown

| Line | What it does |
|---|---|
| `c1 = Counter(s)` | Counts occurrences of every character in `s` |
| `c2 = Counter(t)` | Counts occurrences of every character in `t` |
| `c3 = c2 - c1` | Subtracts `s`'s counts from `t`'s counts — only positive leftovers survive |
| `c4 = next(iter(c3.keys()))` | Turns the remaining keys into an iterator and pulls out the single leftover key |
| `return c4` | Returns that leftover character — the extra letter |

---

### 🤔 Why Counter (Hash Map)?
`Counter` is built on top of a dictionary (hash map), so it counts every character in a single pass and gives O(1) average lookup/comparison per key. Since every character in `s` appears exactly once more in `t` (its "shuffled" copy), subtracting the two Counters cancels out every matching character — whatever remains is the one extra letter.

```
s = "abcd"          t = "abcde"

Counter(s)            Counter(t)
{a:1, b:1, c:1, d:1}  {a:1, b:1, c:1, d:1, e:1}

Counter(t) - Counter(s)  →  {e: 1}
```

Sample result: `"e"`

---

### ⚖️ Why not Bit Manipulation (XOR)?
LeetCode also tags this problem under Bit Manipulation. The trick: XOR every character of `s` together, then XOR every character of `t` together, then XOR those two results — since every letter in `s` appears twice total across both strings, it cancels itself out, leaving only the extra letter. It's a more advanced/interview-favorite optimization (O(1) space, no data structure needed), but the Hash Map approach is more intuitive to read and reason about, which matters more while still building foundational understanding.

---

### 🔑 Reference: `.keys()` / `iter()` / `next()`
| Piece | What it does |
|---|---|
| `.keys()` | Dictionary-only method (works on `Counter` since it's dict-based) — returns a *view* of the keys, not yet iterable one-at-a-time |
| `iter(x)` | Converts that view into an **iterator** — an object that remembers its position and can hand back items one at a time |
| `next(iterator)` | Pulls the next item from the iterator; here, the first (and only) key |

---

### ⚠️ Common Mistakes

**Subtracting in the wrong direction**
```python
# Wrong: subtracts t's counts from s's counts — leaves nothing, since s has no extra letter
c3 = c1 - c2
```
Fix: subtract the original (`s`) away from the one with the extra letter (`t`) → `c2 - c1`.

**Returning the whole Counter instead of the key**
```python
# Wrong: returns the whole leftover Counter object, e.g. Counter({'e': 1})
return c3
```
Fix: extract just the key with `next(iter(c3.keys()))` — the problem wants the character itself, not the count structure.

**Calling `next()` directly on `.keys()`**
```python
# Wrong: TypeError — dict_keys isn't an iterator, only iterable
next(c3.keys())
```
Fix: wrap it in `iter()` first to convert it into something `next()` can pull from.

---

### ⏱️ Time Complexity
O(n) — building each Counter is a single pass over the string; subtraction and key extraction are O(1) relative to the result size.

---

### 🔑 Key Learnings
- `Counter` works on any iterable (strings, lists, tuples) — not just characters, also words or any hashable item
- `.count()` counts one specific item at a time; `Counter` counts everything in one pass
- Counter subtraction keeps only positive leftovers — equal or higher counts in the subtracted Counter cancel out completely
- `.keys()` only exists on dict-like objects, not lists/strings/ints — those use indices, not keys
- `next(iter(x))` is a clean way to pull the first/only item out of an iterable without indexing or converting it to a list

---

### 🧠 Final Solution
```python
from collections import Counter

class Solution:
    def findTheDifference(self, s: str, t: str) -> str:
        c1 = Counter(s)
        c2 = Counter(t)
        c3 = c2 - c1
        c4 = next(iter(c3.keys()))
        return c4
```
