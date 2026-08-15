# 28. Find the Index of the First Occurrence in a String

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen) ![Topic](https://img.shields.io/badge/Topic-String-blue) ![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** String Searching · Nested Loops · Loop Bound Derivation · `break` · `for...else`

---

## ✅ Problem Summary

- Given `haystack` and `needle`, return the index of the **first** occurrence of `needle` in `haystack`.
- Return `-1` if `needle` does not occur in `haystack` at all.
- Both strings consist of lowercase English letters, length between 1 and 10⁴.

---

## 🙃 First Attempt — `.find()`

```python
class Solution:
    def strStr(self, haystack: str, needle: str) -> int:
        return haystack.find(needle)
```

This passed instantly, but it wasn't actually satisfying — the whole point of the exercise is to build the string-matching logic, not call a built-in that does it invisibly. `.find()` solves the problem but hides the concept: the loop bounds, the character comparisons, the early-exit logic — none of that gets practiced if `.find()` does it all internally. So the real solve was redone from scratch, without any built-in search.

---

## 🧠 Real Solution — Manual Nested Loop

```python
class Solution:
    def strStr(self, haystack: str, needle: str) -> int:
        m = len(needle)
        n = len(haystack) - len(needle)

        for i in range(0, n + 1):
            for j in range(m):
                if needle[j] != haystack[j + i]:
                    break
            else:
                return i
        return -1
```

---

## 🪜 How This Was Built, Step by Step

**1. What's actually being searched for?**
The first index `i` in `haystack` where lining `needle` up starting at `i` matches character-for-character all the way through.

**2. Bounding the outer loop — which starting positions are even worth trying?**
If `haystack` has length `n_total` and `needle` has length `m`, then starting the match too close to the end of `haystack` leaves no room for all of `needle` to fit. The last valid starting index is `n_total - m` — computed here as `n = len(haystack) - len(needle)`. Since `range()` stops *before* its upper bound, the loop needed `range(0, n + 1)` to actually include that last valid index — an easy off-by-one to miss.

**3. Bounding the inner loop — walking through `needle` itself.**
The inner loop just needs to touch every index of `needle`, from `0` to `m - 1`. That's simply `range(m)` — no `+1` here, since `range(m)` already produces `0` through `m - 1` directly.

**4. The comparison — and why `i + j`, not just `j`.**
Inside the inner loop, `needle[j]` is compared against `haystack[i + j]`. The `+ i` matters: `j` alone would only ever compare against the *start* of haystack repeatedly. Adding `i` shifts the comparison window to line up with wherever the outer loop currently is.

**5. Bailing out early on a mismatch — `break`, not `continue` or `return -1`.**
The moment one character fails to match, that particular `i` is already dead — no need to check the rest of `needle` against it. `continue` was ruled out because it would just skip to the next `j` value within the *same* `i`, not abandon the whole attempt. `return -1` was ruled out because a mismatch at one `i` doesn't mean no match exists at a later `i` — that would end the search too early. `break` is the right fit: it exits only the inner loop and lets the outer loop move on to try the next `i`.

**6. Knowing when a match was actually complete — `for...else`.**
After the inner loop ends, there's no immediate way to tell *why* it ended — did it `break` on a mismatch, or did it run all the way through cleanly? Python's `for...else` answers exactly that: the `else` block on a `for` loop only runs if the loop completed all its iterations without ever hitting `break`. So `else: return i` only fires when every character of `needle` matched — a genuine full match — and returns immediately, which is safe since `i` increases in order and the first full match found is the first occurrence.

**7. If nothing is ever found — the final `return -1`.**
If the outer loop finishes every `i` without the inner `else` ever firing, there's no match anywhere in `haystack`. That `return -1` sits outside both loops entirely, aligned with the outer `for i in range(...)`, so it only runs after every possibility has been exhausted.

---

## 🧩 Breakdown

| Line | What it does |
|---|---|
| `m = len(needle)` | Length of the pattern being searched for |
| `n = len(haystack) - len(needle)` | Last valid starting index for the match |
| `for i in range(0, n + 1)` | Tries every starting position in `haystack` where `needle` could still fully fit |
| `for j in range(m)` | Walks through every character of `needle` for the current `i` |
| `if needle[j] != haystack[j + i]: break` | Abandons this `i` immediately on the first mismatch |
| `else: return i` | Runs only if no mismatch occurred — a full match, return its starting index |
| `return -1` | Reached only if every `i` was tried and none produced a full match |

```
haystack = "sadbutsad"
index:      0123456789
needle  =   "sad"
             ^ first match starts at index 0
                    ^ second match at index 6 (not returned — we want the first)
```

---

## ⚠️ Why not `in`?

```python
if needle in haystack:
    return 0
else:
    return -1
```
This is wrong because `in` only answers a yes/no question ("does needle exist somewhere in haystack?") — it throws away *where* the match happened. For `haystack = "butsad"`, `needle = "sad"`, `"sad" in "butsad"` is `True`, but the actual first occurrence is at index **3**, not 0. `in` cannot express that.

---

## 🚧 Common Mistakes (from the actual attempts)

**Mistake 1 — comparing `haystack[j]` instead of `haystack[i + j]`**
```python
# Wrong: never shifts the comparison window, so it only ever checks
# the start of haystack regardless of which i is being tried
needle[j] == haystack[j]
```
✅ Fix: index into haystack with `i + j`, so the comparison window slides along with the outer loop.

**Mistake 2 — off-by-one on the outer loop's upper bound**
```python
# Wrong: skips the last valid starting index
for i in range(0, n):
```
✅ Fix: use `range(0, n + 1)` so the last valid index (where `needle` just barely fits) is included.

**Mistake 3 — returning inside the inner loop unconditionally**
```python
# Wrong: exits the whole function on the very first character checked,
# before confirming the rest of needle actually matches
for j in range(m):
    needle[j] == haystack[j]
    return k
```
✅ Fix: only return once the *entire* inner loop has confirmed a match — that's what `for...else` is for.

**Mistake 4 — using `.find()` when the goal is to learn the underlying logic**
```python
# Passes, but skips the actual concept being practiced
return haystack.find(needle)
```
✅ Fix: rebuild it manually with nested loops, so the bounds, comparisons, and early-exit logic are all understood firsthand.

---

## ⏱️ Time Complexity

- **Manual nested loop:** `O((n - m) * m)` worst case — for each of the `n - m + 1` starting positions, up to `m` character comparisons.
- **Built-in `.find()`:** effectively `O(n)` on average in CPython (uses an optimized substring search algorithm under the hood).

---

## 🔑 Key Learnings

- Loop bounds for substring search must be derived from both string lengths, not guessed — the outer loop's last valid index is `len(haystack) - len(needle)`, and `range()`'s exclusive upper bound means that value needs a `+1` to actually be included.
- `break` exits only the loop it's directly inside — useful for abandoning one starting position without derailing the whole search.
- `for...else` is the clean way to detect "did this loop complete without interruption" — exactly what's needed to confirm a full, uninterrupted character match.
- Solving with a built-in first can confirm the expected behavior, but re-deriving the manual version is where the actual concept — bounds, comparisons, early exits — gets learned.

---

## 🏁 Final Solutions

**Built-in version:**
```python
class Solution:
    def strStr(self, haystack: str, needle: str) -> int:
        return haystack.find(needle)
```

**Manual version (the one that was actually understood):**
```python
class Solution:
    def strStr(self, haystack: str, needle: str) -> int:
        m = len(needle)
        n = len(haystack) - len(needle)

        for i in range(0, n + 1):
            for j in range(m):
                if needle[j] != haystack[j + i]:
                    break
            else:
                return i
        return -1
```
