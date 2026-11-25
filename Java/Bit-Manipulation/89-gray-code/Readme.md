# 89. Gray Code

![Difficulty](https://img.shields.io/badge/Difficulty-Medium-orange)
![Topic](https://img.shields.io/badge/Topic-Bit%20Manipulation-blue)
![Status](https://img.shields.io/badge/Status-Accepted-brightgreen)

**Concepts:** `<<` · `>>` · `^` (XOR) · Gray code · bit masks · `List<Integer>`

---

## ✅ Problem Summary

Given an integer `n`, return any valid **n-bit Gray code sequence**:

- ✔ It contains all `2ⁿ` integers in the range `[0, 2ⁿ - 1]`, each exactly once.
- ✔ The first integer is `0`.
- ✔ Every pair of adjacent integers differs by **exactly one bit**.
- ✔ The first and last integers also differ by exactly one bit (the sequence wraps around).

**Example:** `n = 2` → `[0, 1, 3, 2]` (binary `00, 01, 11, 10`)

---

## 💡 Solution

```java
import java.util.*;

class Solution {
    public List<Integer> grayCode(int n) {
        List<Integer> list = new ArrayList<>();

        for (int i = 0; i < (1 << n); i++) {
            int temp = i ^ (i >> 1);
            list.add(temp);
        }

        return list;
    }
}
```

**Result:** 16 / 16 test cases passed · Runtime 0 ms

---

## 🧩 Breakdown

| Code | What it does |
|---|---|
| `1 << n` | Shifts `1` left by `n` places, which equals `2ⁿ`, the number of values needed |
| `for (i = 0; i < (1 << n); i++)` | Visits every integer from `0` to `2ⁿ - 1` |
| `i >> 1` | Shifts the bits of `i` right by one place, which is `i / 2` rounded down |
| `i ^ (i >> 1)` | XORs `i` with its shifted copy to give the Gray code of `i` |
| `list.add(temp)` | Stores the Gray code of each `i` in order |

---

## 🤔 Why `i ^ (i >> 1)`?

Going from `i` to `i + 1` flips a **block of low bits**. For example, `0111 → 1000` flips all four bits.

The shifted copy `i >> 1` flips the same block, but **one place shorter**. XOR-ing `i` with its shifted copy cancels the overlap, so only the **top bit of that block** is left changed. That is exactly one bit per step.

**Trace for `n = 3`:**

| i | Binary | `i >> 1` | `i ^ (i >> 1)` | Gray (decimal) |
|---|---|---|---|---|
| 0 | `000` | `000` | `000` | 0 |
| 1 | `001` | `000` | `001` | 1 |
| 2 | `010` | `001` | `011` | 3 |
| 3 | `011` | `001` | `010` | 2 |
| 4 | `100` | `010` | `110` | 6 |
| 5 | `101` | `010` | `111` | 7 |
| 6 | `110` | `011` | `101` | 5 |
| 7 | `111` | `011` | `100` | 4 |

**Output:** `[0, 1, 3, 2, 6, 7, 5, 4]`

**Wraparound check:** the last value `4 = 100` and the first value `0 = 000` differ in one bit. ✔

---

## 🆚 Why not reflect-and-prefix?

The other standard method builds the list from the previous size. Take the list for `n - 1`, write it again **in reverse**, and add a leading `1` bit to the second half:

```java
List<Integer> list = new ArrayList<>();
list.add(0);
for (int i = 0; i < n; i++) {
    int add = 1 << i;
    for (int j = list.size() - 1; j >= 0; j--) {
        list.add(list.get(j) | add);
    }
}
return list;
```

Both run in `O(2ⁿ)`. The formula is shorter and needs no nested loop or reverse iteration. The reflect-and-prefix method is easier to **derive from scratch** if the formula is forgotten, so it is worth knowing as a backup.

---

## 📊 Bit Operators at a Glance

| Operator | Name | Meaning | Example |
|---|---|---|---|
| `x << k` | Left shift | Multiplies by `2ᵏ` | `1 << 3 = 8` |
| `x >> k` | Right shift | Divides by `2ᵏ`, rounding down | `6 >> 1 = 3` |
| `a & b` | AND | `1` only where both bits are `1` (clears with a `0` mask) | `1011 & 0011 = 0011` |
| `a \| b` | OR | `1` where either bit is `1` (sets with a `1` mask) | `1000 \| 0011 = 1011` |
| `a ^ b` | XOR | `1` where the bits differ (flips with a `1` mask) | `1011 ^ 0011 = 1000` |

---

## ⚠️ Common Mistakes

**1. Reading `1 << n` as `1 * n`**

```java
int total = 1 * n;   // wrong: gives n
```

Fix: the shift doubles once per place, so `1 << n` is `2ⁿ`.

```java
int total = 1 << n;  // correct: 2^n
```

**2. Reading `i >> 1` as `i / 1`**

`i >> 1` halves the number (`6 >> 1 = 3`). Dividing by `1` changes nothing.

**3. Using `+` instead of `^`**

```java
int temp = i + (i >> 1);   // wrong: adds, so bits carry
```

Fix: XOR combines bit by bit with no carry.

```java
int temp = i ^ (i >> 1);   // correct
```

---

## ⏱️ Time Complexity

- **Time:** `O(2ⁿ)`, one loop iteration per output value.
- **Space:** `O(2ⁿ)` for the returned list, and `O(1)` extra beyond that.

This is optimal, because the output itself has `2ⁿ` elements.

---

## 🔑 Key Learnings

- `1 << n` equals `2ⁿ`, and `x >> 1` halves `x`.
- XOR flips a bit when the other bit is `1` and leaves it alone when it is `0`.
- Gray code of `i` is `i ^ (i >> 1)`. Adjacent values differ by one bit because the shifted copy cancels the whole flipping block except its top bit.
- The reflect-and-prefix method builds the same kind of sequence and is the backup if the formula is forgotten.
- Keep the parentheses around `(i >> 1)` for readability.

---

## 🏁 Final Solution

```java
import java.util.*;

class Solution {
    public List<Integer> grayCode(int n) {
        List<Integer> list = new ArrayList<>();

        for (int i = 0; i < (1 << n); i++) {
            int temp = i ^ (i >> 1);
            list.add(temp);
        }

        return list;
    }
}
```
