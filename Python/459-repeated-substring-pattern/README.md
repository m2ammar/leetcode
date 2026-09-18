# 459. Repeated Substring Pattern

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-String-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** String Slicing · Divisors · String Multiplication · Iteration

---

## ✅ Problem Summary
Given a string `s`, determine whether it can be built by:
- Taking some substring of `s`
- Repeating that substring multiple times (2 or more)
- To reconstruct `s` exactly

## 🧠 Solution
```python
class Solution:
    def repeatedSubstringPattern(self, s: str) -> bool:
        n = len(s)

        for k in range(1, n):
            if n % k == 0:
                substring = s[0:k]
                repeated = substring * (n // k)
                if repeated == s:
                    return True
        return False
```

## 🧩 Breakdown

| Line | What it does |
|---|---|
| `n = len(s)` | Total length of the string |
| `for k in range(1, n)` | Try every possible substring length from 1 up to (but not including) n |
| `if n % k == 0` | Only proceed if `k` evenly divides `n` — a repeating unit must fit a whole number of times |
| `substring = s[0:k]` | Take the first `k` characters as the candidate repeating unit |
| `repeated = substring * (n // k)` | Repeat that candidate unit enough times to rebuild a string of length `n` |
| `if repeated == s` | Check whether the rebuilt string matches the original exactly |
| `return False` | No divisor length worked, so `s` isn't a repeated pattern |

## 🤔 Why check divisors of `n`?
If a substring of length `k` repeats to form `s`, then `n` (total length) must be a whole-number multiple of `k` — there can't be a leftover partial repeat. So only lengths where `n % k == 0` are worth testing at all; anything else is guaranteed to fail and can be skipped.

```python
# n = 12, k = 3
repeats = n // k       # 4
"abc" * repeats         # "abcabcabcabc"
```

Sample trace for `s = "abcabcabcabc"`:

| k | divisor of 12? | substring | repeated | matches s? |
|---|---|---|---|---|
| 1 | ✅ | "a" | "aaaaaaaaaaaa" | ❌ |
| 2 | ✅ | "ab" | "ababababababab..." (wrong length logic aside) | ❌ |
| 3 | ✅ | "abc" | "abcabcabcabc" | ✅ → return True |

## ⚠️ Why not check every `k` from 1 to n without the divisor filter?
You could build `substring * (n // k)` for every `k`, but if `k` doesn't divide `n` evenly, `n // k` (integer division) truncates — the rebuilt string comes out shorter than `n` and can never equal `s`. It would still technically return the correct answer, but you'd be doing wasted work on candidates that can never succeed. Filtering with `n % k == 0` first skips that wasted work.

## ⚠️ Common Mistakes

**Forgetting to check the divisor condition:**
```python
# ❌ Builds and compares for every k, even ones that can't work
for k in range(1, n):
    substring = s[0:k]
    repeated = substring * (n // k)
    if repeated == s:
        return True
```
Fix: check `n % k == 0` before doing any string building.

**Looping k up through n (inclusive):**
```python
# ❌ range(1, n + 1) lets k = n through
for k in range(1, n + 1):
```
Fix: use `range(1, n)` — if `k == n`, the "substring" is the whole string itself repeated once, which isn't a valid repeated pattern by the problem's definition.

## ⏱️ Time Complexity
O(n²) worst case — up to `n` candidate values of `k`, and each comparison/string build can take O(n) time.

## 🔑 Key Learnings
- A repeating unit's length must always be a divisor of the total string length — this cuts down candidates immediately.
- Python's `str * int` repeats a string cleanly, making reconstruction a one-liner.
- Filtering invalid candidates *before* doing expensive work (string building) avoids wasted computation.

## Final Query
```python
class Solution:
    def repeatedSubstringPattern(self, s: str) -> bool:
        n = len(s)

        for k in range(1, n):
            if n % k == 0:
                substring = s[0:k]
                repeated = substring * (n // k)
                if repeated == s:
                    return True
        return False
```
