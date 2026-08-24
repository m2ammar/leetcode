# 1051. Height Checker

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-Java-orange)
![Status](https://img.shields.io/badge/Status-Accepted-brightgreen)

**Concepts:** Selection Sort · Array Copy · Index Comparison

---

## ✅ Problem Summary

- [x] Copy `heights` into a new array `expected`
- [x] Sort `expected` in non-decreasing order using Selection Sort
- [x] Compare `heights[i]` against `expected[i]` at every index
- [x] Return the count of positions where they differ

---

## 🧩 Solution

```java
class Solution {
    public int heightChecker(int[] heights) {
        
        int[] expected = new int[heights.length];
        int counter = 0;
        int minIndex = 0;

        for (int i = 0; i < heights.length; i++) {
            expected[i] = heights[i];
        }

        for (int i = 0; i < expected.length; i++) {
            minIndex = i;

            for (int j = (i + 1); j < expected.length; j++) {
                if (expected[minIndex] > expected[j]) {
                    minIndex = j;
                }
            }
            int temp = expected[minIndex];
            expected[minIndex] = expected[i];
            expected[i] = temp;
        }

        for (int i = 0; i < heights.length; i++) {
            if (heights[i] != expected[i]) {
                counter++;
            }
        }
        return counter;
    }
}
```

---

## 🔍 Breakdown

| Step | Purpose |
|---|---|
| Copy loop | Preserve the original `heights` array untouched by duplicating it into `expected` |
| Outer loop (`i`) | Tracks the boundary between sorted (left) and unsorted (right) sections |
| `minIndex = i` | Assumes the current position holds the minimum until proven otherwise |
| Inner loop (`j = i + 1`) | Scans only the unsorted remainder, skipping already-sorted values |
| Swap after inner loop | Places the found minimum into position `i` — one swap per outer pass, not per comparison |
| Final comparison loop | Counts mismatches between the original `heights` and the now-sorted `expected` |

---

## 🤔 Why Selection Sort here?

`heights.length` is capped at 100, so time complexity isn't a concern — this problem exists purely to practice the technique. Selection Sort's defining trait — scanning the whole unsorted section for the minimum *before* swapping, rather than swapping on every comparison like Bubble Sort — was applied directly to sort `expected`.

---

## ⚠️ Common Mistakes

**Forgetting to copy `heights` into `expected` first:**
```java
// Wrong: expected is just zeros, disconnected from heights
int[] expected = new int[heights.length];
// ...sorting zeros does nothing
```
```java
// Fix: copy actual values before sorting
for (int i = 0; i < heights.length; i++) {
    expected[i] = heights[i];
}
```

**Accidentally writing Bubble Sort instead of Selection Sort:**
```java
// Wrong: swaps adjacent elements inside the inner loop (Bubble Sort)
if (expected[j] > expected[j + 1]) {
    // swap here, every time a pair is out of order
}
```
```java
// Fix: track the minimum index across the whole unsorted range,
// swap only once after the inner loop finishes
if (expected[minIndex] > expected[j]) {
    minIndex = j;
}
// swap happens here, outside the inner loop
```

---

## ⏱️ Time Complexity

O(n²) — Selection Sort's nested loops dominate; the copy and comparison loops are both O(n). Fine here since n ≤ 100.

---

## 🔑 Key Learnings

- Selection Sort swaps once per outer pass (after scanning for the min), unlike Bubble Sort which swaps on every out-of-order adjacent pair
- Always copy an array before sorting it if the original values are still needed for comparison later
- Small constraints (n ≤ 100) make a problem a safe place to practice a technique without worrying about its time complexity

---

## Final Code

```java
class Solution {
    public int heightChecker(int[] heights) {
        
        int[] expected = new int[heights.length];
        int counter = 0;
        int minIndex = 0;

        for (int i = 0; i < heights.length; i++) {
            expected[i] = heights[i];
        }

        for (int i = 0; i < expected.length; i++) {
            minIndex = i;

            for (int j = (i + 1); j < expected.length; j++) {
                if (expected[minIndex] > expected[j]) {
                    minIndex = j;
                }
            }
            int temp = expected[minIndex];
            expected[minIndex] = expected[i];
            expected[i] = temp;
        }

        for (int i = 0; i < heights.length; i++) {
            if (heights[i] != expected[i]) {
                counter++;
            }
        }
        return counter;
    }
}
```
