# 🔢 66. Plus One

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-Array%20%7C%20Math-blue)
![Language](https://img.shields.io/badge/Language-Java-orange)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** Array traversal · Carry handling · Early return · In-place update

---

## ✅ Problem Summary

- Input is an `int[] digits` representing a non-negative integer, most significant digit first
- Add **1** to the number
- Return the resulting digits as an array
- No leading zeros in the input; the result gets none either

---

## 💡 Solution

```java
class Solution {
    public int[] plusOne(int[] digits) {

        for (int i = digits.length - 1; i >= 0; i--) {
            if (digits[i] < 9) {
                digits[i] += 1;
                return digits;
            }
            digits[i] = 0;
        }

        int[] result = new int[digits.length + 1];
        result[0] = 1;
        return result;
    }
}
```

---

## 🧩 Breakdown

| Code | What it does |
|------|--------------|
| `for (i = length - 1; i >= 0; i--)` | Starts at the last digit, the one that receives the +1 |
| `if (digits[i] < 9)` | No carry is produced, so increment and finish immediately |
| `digits[i] = 0` | Digit was 9: it becomes 0 and the carry moves one place left |
| `new int[digits.length + 1]` | Reached only if **all** digits were 9 |
| `result[0] = 1` | The new leading 1; the other slots are already 0 by default |

---

## 🤔 Why traverse from the right?

Addition by hand starts at the ones place, and a carry only moves leftward.

```
[1, 2, 9]  →  9 becomes 0, carry  →  [1, 3, 0]
[9, 9, 9]  →  all become 0, carry →  [1, 0, 0, 0]
```

| Input | Output | Why |
|-------|--------|-----|
| `[1,2,3]` | `[1,2,4]` | Last digit < 9, one step |
| `[1,2,9]` | `[1,3,0]` | One carry |
| `[9]` | `[1,0]` | Carry out of the front, array grows |

---

## 🚫 Why not convert to an integer?

Converting the array to an `int` or `long`, adding 1, and converting back breaks quickly. The array can hold **up to 100 digits**, which overflows `long` (max about 9.2 × 10¹⁸, 19 digits). `BigInteger` would work but is slower and misses the point of the problem. Working digit by digit has no size limit.

---

## ⚠️ Common Mistakes

**Forgetting the all-9s case**

```java
// Wrong: [9,9] becomes [0,0], which is incorrect
for (int i = digits.length - 1; i >= 0; i--) { ... }
return digits;
```

Fix: after the loop, allocate `digits.length + 1` and set `result[0] = 1`.

**Not returning early**

```java
// Wrong: keeps looping and zeroes digits that should stay as they are
digits[i] += 1;
```

Fix: `return digits;` as soon as a digit below 9 is incremented.

---

## ⏱️ Time Complexity

- **Time:** O(n), at most one pass over the array
- **Space:** O(1) normally (in-place); O(n) only in the all-9s case

---

## 🔑 Key Learnings

- Carry only propagates while digits are 9, so most inputs finish in one step
- Java arrays initialize to 0, so the all-9s result needs only `result[0] = 1`
- Process digits the way manual addition does: right to left
- Avoid converting to numeric types when input length can be large

---

## 🏁 Final Solution

```java
class Solution {
    public int[] plusOne(int[] digits) {
        for (int i = digits.length - 1; i >= 0; i--) {
            if (digits[i] < 9) {
                digits[i] += 1;
                return digits;
            }
            digits[i] = 0;
        }
        int[] result = new int[digits.length + 1];
        result[0] = 1;
        return result;
    }
}
```
