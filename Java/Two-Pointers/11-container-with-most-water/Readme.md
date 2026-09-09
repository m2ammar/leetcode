# 11. Container With Most Water

![Difficulty](https://img.shields.io/badge/Difficulty-Medium-orange)
![Topic](https://img.shields.io/badge/Topic-Two%20Pointers-blue)
![Status](https://img.shields.io/badge/Status-Accepted-brightgreen)

**Concepts:** Two Pointers · Greedy Pointer Movement · Array Traversal

---

## ✅ Problem Summary

- Given an integer array `height`, each index `i` represents a vertical line from `(i, 0)` to `(i, height[i])`.
- Pick two lines that, together with the x-axis, form a container.
- Return the **maximum amount of water** that container can hold.
- The container cannot be slanted — height is limited by the *shorter* of the two chosen lines.

---

## 🤔 Solution

```java
class Solution {
    public int maxArea(int[] height) {
        int area = 0;
        int left = 0;
        int right = height.length - 1;

        while (left < right) {
            int shorterHeight = (height[left] < height[right]) ? height[left] : height[right];
            int currentArea = shorterHeight * (right - left);

            if (area < currentArea) {
                area = currentArea;
            }

            if (height[left] < height[right]) {
                left++;
            } else {
                right--;
            }
        }
        return area;
    }
}
```

---

## 🧩 Breakdown

| Line | What it does |
|---|---|
| `left = 0`, `right = height.length - 1` | Start with the widest possible container — both ends of the array |
| `shorterHeight = min(height[left], height[right])` | Water can only rise as high as the **shorter** wall |
| `currentArea = shorterHeight * (right - left)` | Area = height × width, recalculated every iteration |
| `if (area < currentArea) area = currentArea;` | Tracks the best area seen so far, independent of pointer movement |
| `if (height[left] < height[right]) left++; else right--;` | Always moves the **shorter** pointer inward — the only move that can possibly improve the area |

---

## 🧠 Why Two Pointers?

Brute force checks every pair `(i, j)` — O(n²), which times out on large inputs (n up to 10⁵).

The two-pointer approach starts at maximum width and shrinks inward, but only from the side that *can't* help anymore (the shorter wall) — since width will shrink no matter which pointer moves, only moving the shorter side has any chance of finding a taller wall that compensates for the lost width.

```
left                                   right
 ↓                                       ↓
[1,   8,   6,   2,   5,   4,   8,   3,   7]
 |----------------- width ---------------|
```

Each iteration shrinks the width by exactly one step from one side, guaranteeing every "useful" pair is implicitly considered without checking all of them explicitly.

---

## ⚠️ Why not Brute Force?

Checking every pair with nested loops is O(n²) — correct, but far too slow for `n = 10⁵` (roughly 10 billion comparisons). The two-pointer method achieves the same correctness in a single O(n) pass by proving that moving the taller pointer can never produce a better answer than what's already been checked.

---

## ⚠️ Common Mistakes (from this session)

**Mistake 1 — moving both pointers every iteration**
```java
left++;
right--; // wrong: always shrinks both sides regardless of which is shorter
```
Fix: only move the pointer on the shorter side, inside a single `if/else`.

**Mistake 2 — using `height[i] * height[j]` as the area**
```java
area = height[i] * height[j]; // wrong: this ignores width entirely
```
Fix: area = `min(height[i], height[j]) * (j - i)` — width matters as much as height.

**Mistake 3 — overwriting the "best" tracker every loop**
```java
area = height[i] * (j - i); // wrong: wipes out the previous best every iteration
```
Fix: keep `area` as a running max, only updated inside an `if` when the new value is larger.

---

## ⏱️ Time Complexity

- **Brute force:** O(n²) — times out on large inputs
- **Two pointers:** O(n) — single pass, each pointer moves at most n times total

**Space:** O(1) — constant extra space either way

---

## 🔑 Key Learnings

- Width in these problems is a distance (`j - i`), not a count of elements
- The container's height is always bounded by the *shorter* wall — water spills over the short side
- "Two tallest lines" is not a valid heuristic — position (width) matters just as much as height
- In two-pointer problems, always separate "update the best answer" logic from "which pointer moves" logic — they are independent decisions each iteration
- Moving the taller pointer can never improve the answer, since width always shrinks and the limiting height can only get worse or stay the same

---

## Final Query

```java
class Solution {
    public int maxArea(int[] height) {
        int area = 0;
        int left = 0;
        int right = height.length - 1;

        while (left < right) {
            int shorterHeight = (height[left] < height[right]) ? height[left] : height[right];
            int currentArea = shorterHeight * (right - left);

            if (area < currentArea) {
                area = currentArea;
            }

            if (height[left] < height[right]) {
                left++;
            } else {
                right--;
            }
        }
        return area;
    }
}
```
