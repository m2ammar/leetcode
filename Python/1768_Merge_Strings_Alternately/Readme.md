# 1768. Merge Strings Alternately

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-Python-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** `zip()` · String Slicing · `str.join()`

---

## ✅ Problem Summary

- [x] Given two strings `word1` and `word2`, merge them by alternating characters, starting with `word1`.
- [x] If one string is longer than the other, append the leftover characters to the end of the merged result.
- [x] Return the merged string.

---

## 🧠 Solution

```python3
class Solution:
    def mergeAlternately(self, word1: str, word2: str) -> str:
        merge = []
        for a, b in zip(word1, word2):
            merge.append(a)
            merge.append(b)

        merge.append(word1[len(word2):])
        merge.append(word2[len(word1):])

        return "".join(merge)
```

---

## 🧩 Breakdown

| Line | What it does |
|---|---|
| `merge = []` | An empty list to collect characters as the result is built. |
| `for a, b in zip(word1, word2):` | Walks through both strings together, pairing up characters at matching positions. Stops automatically at the shorter string. |
| `merge.append(a); merge.append(b)` | Adds one character from each word per round, in alternating order (word1's char first, then word2's). |
| `merge.append(word1[len(word2):])` | Grabs whatever's left in `word1` after the point where `word2` ran out. Empty string if `word1` wasn't the longer one. |
| `merge.append(word2[len(word1):])` | Same idea, reversed — grabs `word2`'s leftover tail if it was the longer one. |
| `"".join(merge)` | Glues every item in the list into one final string, with no characters in between. |

---

## 🤔 Why zip() + slicing?

`zip()` is the natural tool for "walk through two sequences together, position by position" — exactly what alternating merge needs. It automatically stops at the shorter string, so the loop never needs a manual length check or index counter.

Visualized:

```
word1: a s d e w y c
word2: d f c

zip pairs (stops at word2's length = 3):
(a, d)  (s, f)  (d, c)

Leftover in word1 (index 3 onward): e w y c
Leftover in word2 (index 3 onward): (nothing, word2 is shorter)

Merged: a d s f d c + e w y c → adsfdcewyc
```

Since only one word can actually have leftover characters, using **both** `word1[len(word2):]` and `word2[len(word1):]` is safe — whichever word wasn't the longer one just contributes an empty string (`""`), since slicing past a string's end in Python never raises an error.

---

## 🚫 Why not manual indexing?

An alternative is tracking an index manually with a `while` loop:

```python
i = 0
merge = []
while i < len(word1) and i < len(word2):
    merge.append(word1[i])
    merge.append(word2[i])
    i += 1
merge.append(word1[i:])
merge.append(word2[i:])
return "".join(merge)
```

This works identically, but `zip()` removes the need to manage the index and the stop condition yourself — Python's `for` loop already knows to stop once the shorter sequence is exhausted. Less to get wrong, more readable.

---

## ⚠️ Common Mistakes

**Mistake 1: Forgetting the leftover tail entirely**
```python
# ❌ Wrong — drops any leftover characters from the longer word
for a, b in zip(word1, word2):
    merge.append(a)
    merge.append(b)
return "".join(merge)
```
```python
# ✅ Fix — always account for both possible leftovers
merge.append(word1[len(word2):])
merge.append(word2[len(word1):])
```

**Mistake 2: Using string concatenation in the loop instead of a list**
```python
# ❌ Works, but inefficient — creates a new string object every iteration
result = ""
for a, b in zip(word1, word2):
    result += a + b
```
```python
# ✅ Fix — build a list, join once at the end
merge = []
for a, b in zip(word1, word2):
    merge.append(a)
    merge.append(b)
return "".join(merge)
```

---

## ⏱️ Time Complexity

O(n + m) — one pass through the zipped portion, plus the leftover slice, where n and m are the lengths of word1 and word2.

---

## 🔑 Key Learnings

- `zip()` pairs sequences by position and stops at the shorter one automatically — no manual index tracking needed.
- `string[len(other):]` is a clean way to grab "whatever's left after the part already used."
- Slicing past a string's length in Python returns `""` instead of raising an error — safe to use without checking lengths first.
- Building a list and `"".join()`-ing at the end is the idiomatic, efficient way to construct strings in a loop.

---

## 🎯 Final Query

```python3
class Solution:
    def mergeAlternately(self, word1: str, word2: str) -> str:
        merge = []
        for a, b in zip(word1, word2):
            merge.append(a)
            merge.append(b)

        merge.append(word1[len(word2):])
        merge.append(word2[len(word1):])

        return "".join(merge)
```
