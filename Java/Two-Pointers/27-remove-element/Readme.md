# 🧹 27. Remove Element

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-Arrays%20%7C%20Two%20Pointers-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** `Two Pointers` · `In-Place Modification` · `Read/Write Pointers` · `Invariants`

---

## ✅ Problem Summary

Given an integer array `nums` and an integer `val`:

- ✔️ Remove every occurrence of `val` **in-place**
- ✔️ Put the non-`val` elements in the **first `k` slots** of `nums` (order may change)
- ✔️ Return `k`, the number of elements not equal to `val`
- ✔️ Whatever sits beyond index `k` doesn't matter

---

## 💡 Solution

```java
class Solution {
    public int removeElement(int[] nums, int val) {
        int k = 0;

        for (int i = 0; i < nums.length; i++) {
            if (nums[i] != val) {
                nums[k] = nums[i];
                k++;
            }
        }

        return k;
    }
}
```

**Result:** 116 / 116 test cases passed · Runtime 0 ms

---

## 🔍 Breakdown

| Code | What it does |
|------|--------------|
| `int k = 0` | Write pointer: count of keepers so far **and** index of the next free slot |
| `for (int i ...)` | Read pointer: scans every element once |
| `if (nums[i] != val)` | Only keepers get copied; `val` elements are skipped |
| `nums[k] = nums[i]` | Place the keeper in the next free slot |
| `k++` | Advance the write pointer |
| `return k` | First `k` slots now hold exactly the non-`val` values |

---

## 🧩 Why Read/Write Two Pointers?

`i` reads ahead, `k` writes behind. Since `k <= i` always holds, a write never overwrites an element that hasn't been read yet.

```
nums = [0, 1, 2, 2, 3, 0, 4, 2], val = 2

i scans →  0  1  2  2  3  0  4  2
k writes → [0, 1, 3, 0, 4, _, _, _]   k = 5
```

| i | nums[i] | Action | k after |
|---|---------|--------|---------|
| 0 | 0 | keep → `nums[0] = 0` | 1 |
| 1 | 1 | keep → `nums[1] = 1` | 2 |
| 2 | 2 | skip | 2 |
| 3 | 2 | skip | 2 |
| 4 | 3 | keep → `nums[2] = 3` | 3 |
| 5 | 0 | keep → `nums[3] = 0` | 4 |
| 6 | 4 | keep → `nums[4] = 4` | 5 |
| 7 | 2 | skip | 5 |

---

## 🤔 Why not shift elements left on every removal?

Deleting each `val` by shifting everything after it costs O(n) per removal, so O(n²) worst case. The read/write pointer approach touches each element once.

**Another valid approach:** two pointers from both ends. When `nums[i] == val`, overwrite it with the last element and shrink the array size. It does fewer writes when `val` is rare, and it's allowed here because the problem says order may change. Both are O(n), but my version always preserves the original order of the keepers.

---

## ⚠️ Common Mistakes

### ❌ Counting without placing

```java
if (nums[i] != val) {
    k++;           // returns the right k, but nums is never rearranged
}
```

The judge checks the first `k` slots of `nums`, not just the returned number.

### ❌ Writing into the slot you just read

```java
else if (nums[i] == val) {
    nums[i] = nums[k + 1];   // out of bounds on [3], and may copy another val
}
```

The fix is to write each **keeper** into `nums[k]`, and drop the `else` branch entirely.

---

## ⏱️ Time Complexity

- **Time:** O(n), single pass
- **Space:** O(1), fully in-place

---

## 🧠 Key Learnings

- A pointer can be both a **count** and an **index** (`k` is "how many keepers" and "next free slot")
- Think "which slot is waiting to be filled?", not "how do I delete this?"
- When order doesn't matter and the target is rare, swapping from the end reduces writes
- Always trace a 1-element array (`[3]`, `val = 3`) to catch boundary bugs

---

## 🏁 Final Solution

```java
class Solution {
    public int removeElement(int[] nums, int val) {
        int k = 0;

        for (int i = 0; i < nums.length; i++) {
            if (nums[i] != val) {
                nums[k] = nums[i];
                k++;
            }
        }

        return k;
    }
}
```
