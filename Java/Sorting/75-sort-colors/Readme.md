# 75. Sort Colors

![Difficulty](https://img.shields.io/badge/Difficulty-Medium-orange)
![Topic](https://img.shields.io/badge/Topic-Bubble%20Sort-orange)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** Nested Loops · Bubble Sort · In-Place Swap · Array

---

## ✅ Problem Summary

- Given an array of `n` integers, each either `0` (red), `1` (white), or `2` (blue).
- Sort the array **in-place** so all `0`s come first, then all `1`s, then all `2`s.
- Not allowed to use any built-in sort function.

---

## 🧠 Solution

```java
class Solution {
    public void sortColors(int[] nums) {
        int size = nums.length;
        int temp = 0;

        for (int i = 0; i < size; i++) {
            for (int j = 0; j < size - i - 1; j++) {
                if (nums[j] > nums[j + 1]) {
                    temp = nums[j];
                    nums[j] = nums[j + 1];
                    nums[j + 1] = temp;
                }
            }
        }
    }
}
```

---

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `for (int i = 0; i < size; i++)` | Outer loop — one full pass per iteration |
| `for (int j = 0; j < size - i - 1; j++)` | Inner loop — walks adjacent pairs; shrinks by one each outer pass |
| `if (nums[j] > nums[j + 1])` | Only swap when the pair is actually out of order |
| `temp = nums[j]; nums[j] = nums[j+1]; nums[j+1] = temp;` | Classic 3-step swap using a temporary variable |

---

## 🤔 Why Bubble Sort here?

`nums` only ever contains 3 distinct values (0, 1, 2), so the array is small in *value range* even if `n` is large. Bubble sort's O(n²) cost is fine here because:

- This problem has **no time complexity requirement** (unlike LeetCode 912, which explicitly requires O(n log n) and rejects bubble sort outright).
- Repeated adjacent comparisons naturally group equal values together and push larger values (2s) toward the end.

```
Pass 1: [2,0,2,1,1,0] -> largest unsorted value bubbles right
Pass 2: settles the next-largest value
...
Pass n: array fully sorted [0,0,1,1,2,2]
```

**Sample result:**

Input: `[2,0,2,1,1,0]` → Output: `[0,0,1,1,2,2]`

---

## ⚠️ Why not swap unconditionally?

An early mistake was removing the `if` check and swapping `nums[j]` and `nums[j+1]` on every iteration, regardless of order:

```java
// Wrong — swaps every pair even if already in order, shuffles instead of sorting
temp = nums[j];
nums[j] = nums[j+1];
nums[j+1] = temp;
```

Without the `if (nums[j] > nums[j+1])` guard, elements get swapped back and forth with no regard to order — the array never actually converges to sorted.

---

## 🐛 Common Mistakes

**Mistake 1: Missing the comparison guard**
```java
// Wrong — always swaps
nums[j] = nums[j+1];
```
Fix: wrap the swap in `if (nums[j] > nums[j + 1])` so only out-of-order pairs get swapped.

**Mistake 2: Not shrinking the inner loop bound**
```java
// Works, but wastes comparisons on already-sorted tail
for (int j = 0; j < size - 1; j++)
```
Fix: use `size - i - 1` — each pass settles one more value at the end, so there's no need to recheck it.

---

## ⏱️ Time Complexity

O(n²) worst case — acceptable here since this problem has no complexity constraint (unlike LeetCode 912: Sort an Array, which explicitly bans quadratic sorts).

---

## 🔑 Key Learnings

- Bubble sort's inner loop bound `size - i - 1` skips the tail that previous passes already sorted — each pass guarantees the largest unsorted value "bubbles" into its correct final position.
- Always guard the swap with a comparison (`if nums[j] > nums[j+1]`) — swapping unconditionally just shuffles values instead of sorting them.
- Some problems (like this one) have no complexity requirement, so a straightforward O(n²) approach is perfectly valid — unlike LeetCode 912, which explicitly requires O(n log n).

---

## Final Query

```java
class Solution {
    public void sortColors(int[] nums) {
        int size = nums.length;
        int temp = 0;

        for (int i = 0; i < size; i++) {
            for (int j = 0; j < size - i - 1; j++) {
                if (nums[j] > nums[j + 1]) {
                    temp = nums[j];
                    nums[j] = nums[j + 1];
                    nums[j + 1] = temp;
                }
            }
        }
    }
}
```
