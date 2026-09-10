# 42. Trapping Rain Water

![Difficulty](https://img.shields.io/badge/Difficulty-Hard-red)
![Topic](https://img.shields.io/badge/Topic-Two%20Pointers-blue)
![Status](https://img.shields.io/badge/Status-Accepted-brightgreen)

**Concepts:** Two Pointers · Running Maximum · Greedy

---

## ✅ Problem Summary

- Given an elevation map (`height[i]` = bar height at index `i`, width of each bar = 1)
- Compute how much water is trapped after it rains
- Water at any index is bounded by the shorter of the tallest bar to its left and the tallest bar to its right

**Example**
```
Input:  height = [0,1,0,2,1,0,1,3,2,1,2,1]
Output: 6
```

---

## 🧠 Solution

```java
class Solution {
    public int trap(int[] height) {
        int left = 0;
        int right = height.length - 1;
        int leftMax = 0;
        int rightMax = 0;
        int water = 0;

        while (left < right) {
            if (height[left] < height[right]) {
                leftMax = (height[left] > leftMax) ? height[left] : leftMax;
                water += leftMax - height[left];
                left++;
            } else {
                rightMax = (height[right] > rightMax) ? height[right] : rightMax;
                water += rightMax - height[right];
                right--;
            }
        }

        return water;
    }
}
```

---

## 🔍 Breakdown

| Part | What it does |
|---|---|
| `left`, `right` | Two pointers starting at both ends of the array |
| `leftMax`, `rightMax` | Running maximums of everything seen so far on each side |
| `height[left] < height[right]` | Decides which side is currently the "limiting wall" |
| `water += leftMax - height[left]` | Water trapped at `left`, using the safe/limiting max |
| `left++` / `right--` | Moves the pointer on the limiting side inward |

---

## 🤔 Why Two Pointers?

For any index `i`, the water level is `min(leftMax, rightMax)`. Computing exact `leftMax`/`rightMax` for every index by rescanning would cost O(n²).

The key insight: if `height[left] < height[right]`, then `rightMax` (whatever its true value turns out to be) is **guaranteed** to be at least `height[right]`, which is already bigger than `height[left]`. So the left side is definitely the limiting wall *right now* — we don't need to know the exact `rightMax` to trust `leftMax` as the water level at `left`.

```
height[left] < height[right]
        ↓
rightMax >= height[right] > height[left]
        ↓
min(leftMax, rightMax) = leftMax   (guaranteed, regardless of rightMax's exact value)
```

This lets each index be visited exactly once — one pass, O(n) time.

---

## ⚠️ Common Mistakes (from this session)

**Mistake 1 — comparing the wrong sides**
```java
// Wrong: compares current bar against the opposite end of the array
leftMax = (height[left] > height[right]) ? height[left] : height[right];
```
`leftMax` should only ever reflect history from the **left** side. Fix:
```java
leftMax = (height[left] > leftMax) ? height[left] : leftMax;
```

**Mistake 2 — overwriting instead of accumulating**
```java
// Wrong: erases water computed in previous iterations
water = leftMax - height[left];
```
Fix:
```java
water += leftMax - height[left];
```

---

## ⏱ Time Complexity

- Time: **O(n)** — each index visited once
- Space: **O(1)** — only a few running variables

---

## 🔑 Key Learnings

- Two pointers work here because we never need the *exact* value of the far-side max — only that it's guaranteed to be at least as big as what's needed for the comparison to hold
- `leftMax`/`rightMax` must be running maximums (`Math.max`-style), never overwritten by the current bar alone
- Water accumulates across iterations — always `+=`, never `=`

---

## 🎯 Final Query

```java
class Solution {
    public int trap(int[] height) {
        int left = 0;
        int right = height.length - 1;
        int leftMax = 0;
        int rightMax = 0;
        int water = 0;

        while (left < right) {
            if (height[left] < height[right]) {
                leftMax = (height[left] > leftMax) ? height[left] : leftMax;
                water += leftMax - height[left];
                left++;
            } else {
                rightMax = (height[right] > rightMax) ? height[right] : rightMax;
                water += rightMax - height[right];
                right--;
            }
        }

        return water;
    }
}
```
