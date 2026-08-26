# 912. Sort an Array

![Difficulty](https://img.shields.io/badge/Difficulty-Medium-orange)
![Topic](https://img.shields.io/badge/Topic-Data%20Structures%20%26%20Algorithms-blue)
![Status](https://img.shields.io/badge/Status-Accepted-brightgreen)

**Concepts:** Quicksort · Recursion · Lomuto Partition Scheme · Randomized Pivot Selection

---

## ✅ Problem Summary

- Given an integer array `nums`, sort it in ascending order.
- Must be solved without built-in sort functions.
- Required time complexity: O(n log n).
- Smallest possible space complexity.

---

## 🧠 Solution

```java
class Solution {
    public int[] sortArray(int[] nums) {
        int high = nums.length - 1;
        int low = 0;
        sorting(nums, low, high);
        return nums;
    }

    public void sorting(int[] nums, int low, int high) {
        if (low < high) {
            int pi = partition(nums, low, high);
            sorting(nums, low, pi - 1);
            sorting(nums, pi + 1, high);
        }
    }

    public int partition(int[] nums, int low, int high) {
        int randomIndex = low + (int) (Math.random() * (high - low + 1));
        int temp = nums[randomIndex];
        nums[randomIndex] = nums[high];
        nums[high] = temp;

        int pivot = nums[high];
        int i = low - 1;

        for (int j = low; j < high; j++) {
            if (nums[j] < pivot) {
                i++;
                temp = nums[i];
                nums[i] = nums[j];
                nums[j] = temp;
            }
        }

        int temp2 = nums[i + 1];
        nums[i + 1] = nums[high];
        nums[high] = temp2;
        return i + 1;
    }
}
```

---

## 🧩 Breakdown

| Piece | What it does |
|---|---|
| `sortArray(nums)` | Fixed LeetCode entry point — sets up `low`/`high`, delegates to `sorting`, returns the now-sorted `nums` (sorting happens in place) |
| `sorting(nums, low, high)` | Recursive driver — if the subrange has more than one element, partitions it, then recurses on the left and right sides of the pivot |
| `partition(nums, low, high)` | Picks a random pivot, swaps it to the end, then rearranges the subrange so everything smaller than the pivot ends up left of it, returns the pivot's final resting index |
| `randomIndex` swap | Picks a pivot from a random position instead of always the last element, so no fixed input pattern (e.g. sorted or reverse-sorted) can force worst-case splits |
| Lomuto loop (`i`, `j`) | `j` scans the subrange; every time a smaller-than-pivot element is found, `i` advances and that element is swapped into the "smaller than pivot" zone |
| Final swap + `return i + 1` | Places the pivot into its correct sorted position (right after the last "smaller" element) and reports that index back to `sorting` as the split point |

---

## 🤔 Why Randomized Pivot?

Plain quicksort with a **fixed** pivot choice (always first, last, or middle element) has an O(n²) worst case — it happens whenever the input consistently produces a 1-vs-(n-1) split at every level of recursion. A sorted or reverse-sorted array is exactly the kind of input that triggers this against a fixed "always pick the last element" pivot: each partition peels off just one element instead of splitting evenly.

```
Fixed pivot (last element) on sorted input [1,2,3,4,5]:
pivot = 5 → split: [1,2,3,4] | [] → 4-vs-0, no gain from splitting
```

Picking the pivot **randomly** each time removes any fixed pattern for an input to exploit. On average, a random pivot still produces reasonably balanced splits — including on already-sorted input — making the O(n²) case astronomically unlikely rather than structurally guaranteed by the input shape.

LeetCode explicitly flags this: a fixed-last-element pivot passes the example test cases but fails LeetCode's **Restrictions Check**, which specifically detects and rejects solutions with guaranteed O(n²) worst-case behavior — that's a distinct pass/fail step from the normal test cases.

In this session, the first submission used `pivot = nums[high]` (fixed last element) — it passed all the sample test cases with 0ms runtime, but was rejected by the Restrictions Check for exactly this reason. Swapping in the random pivot selection before partitioning fixed it, with no other change to the algorithm.

---

## ⚠️ Common Mistakes

**Reusing the fixed `sortArray` signature for recursion:**
```java
// ❌ Wrong — LeetCode's sortArray(int[] nums) signature can't take extra params
public int[] sortArray(int[] nums) {
    ...
    sortArray(nums, low, pi - 1); // won't compile — wrong number of arguments
}
```
```java
// ✅ Fix — keep sortArray as a thin entry point; put the recursive logic in a separate method
public int[] sortArray(int[] nums) {
    sorting(nums, 0, nums.length - 1);
    return nums;
}
public void sorting(int[] nums, int low, int high) { ... }
```

**Off-by-one on the partition's return value:**
```java
// ❌ Wrong — the pivot is actually swapped into index i + 1, not i
nums[i + 1] = nums[high];
nums[high] = temp2;
return i;
```
```java
// ✅ Fix — return the index the pivot was actually swapped into
nums[i + 1] = nums[high];
nums[high] = temp2;
return i + 1;
```
This bug is subtle because it doesn't crash — it just tells the caller the split point is one index too far left, causing recursive calls to slice the array incorrectly and leave some elements (especially duplicates near the pivot's value) unsorted.

**A method declaring a return type it never uses:**
```java
// ❌ Wrong — sorting doesn't need to return anything; nothing captures its result
public int[] sorting(int[] nums, int low, int high) { ... }
```
```java
// ✅ Fix — sorting only mutates nums in place via partition's swaps
public void sorting(int[] nums, int low, int high) { ... }
```

---

## ⏱️ Time Complexity

O(n log n) average and (with randomized pivot) overwhelmingly likely case; true worst case remains O(n²) but is no longer forceable by any specific input ordering. Space complexity is O(log n) on average from the recursion stack (in-place partitioning, no extra arrays).

---

## 🔑 Key Learnings

- A fixed method signature required by the platform (like `sortArray(int[] nums)`) can't be repurposed for recursion — split the logic into a separate helper method with the parameters you actually need.
- A method that only mutates its input in place (via swaps) and whose return value nobody uses should be declared `void`, not given a return type.
- Quicksort's partition step returns the pivot's *final* index — off-by-one here silently breaks recursion boundaries rather than crashing, and shows up specifically on inputs with duplicate/edge values.
- A fixed pivot choice (first, last, or middle) creates a worst-case O(n²) input the algorithm can't avoid; randomizing the pivot removes that guaranteed weak point without changing the core algorithm.
- LeetCode's Restrictions Check for this problem specifically detects guaranteed-O(n²) implementations, separate from normal test case correctness — passing the sample test cases isn't enough on its own.

---

## 🏁 Final Query

```java
class Solution {
    public int[] sortArray(int[] nums) {
        int high = nums.length - 1;
        int low = 0;
        sorting(nums, low, high);
        return nums;
    }

    public void sorting(int[] nums, int low, int high) {
        if (low < high) {
            int pi = partition(nums, low, high);
            sorting(nums, low, pi - 1);
            sorting(nums, pi + 1, high);
        }
    }

    public int partition(int[] nums, int low, int high) {
        int randomIndex = low + (int) (Math.random() * (high - low + 1));
        int temp = nums[randomIndex];
        nums[randomIndex] = nums[high];
        nums[high] = temp;

        int pivot = nums[high];
        int i = low - 1;

        for (int j = low; j < high; j++) {
            if (nums[j] < pivot) {
                i++;
                temp = nums[i];
                nums[i] = nums[j];
                nums[j] = temp;
            }
        }

        int temp2 = nums[i + 1];
        nums[i + 1] = nums[high];
        nums[high] = temp2;
        return i + 1;
    }
}
```
