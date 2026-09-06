# 34. Find First and Last Position of Element in Sorted Array

![Difficulty](https://img.shields.io/badge/Difficulty-Medium-orange)
![Topic](https://img.shields.io/badge/Topic-Binary%20Search-blue)
![Status](https://img.shields.io/badge/Status-Accepted-brightgreen)

**Concepts:** Binary Search · Biased Boundary Search · Two Independent Searches · Edge Case Handling

---

## ✅ Problem Summary
- Given a sorted (non-decreasing) array and a target, return `[firstIndex, lastIndex]` of the target's occurrences
- Return `[-1, -1]` if target isn't found
- Must run in O(log n) — rules out a linear scan

---

## 🧩 Solution
```java
class Solution {
    public int[] searchRange(int[] nums, int target) {
        int left = 0;
        int right = nums.length - 1;
        int[] temp = new int[2];

        // Search 1: find leftmost occurrence
        while (left < right) {
            int mid = (left + right) / 2;
            if (nums[mid] >= target) {
                right = mid;
            } else {
                left = mid + 1;
            }
        }
        if (left < nums.length && nums[left] == target) {
            temp[0] = left;
        } else {
            temp[0] = -1;
        }

        // Search 2: find rightmost occurrence
        left = 0;
        right = nums.length - 1;
        while (left < right) {
            int mid = (left + right + 1) / 2;
            if (nums[mid] <= target) {
                left = mid;
            } else {
                right = mid - 1;
            }
        }
        if (left < nums.length && nums[left] == target) {
            temp[1] = left;
        } else {
            temp[1] = -1;
        }

        return temp;
    }
}
```

---

## 🔍 Breakdown

| Part | Purpose |
|---|---|
| Search 1 (`nums[mid] >= target` → `right = mid`) | Biases the search to keep narrowing left after a match, converging on the **first** occurrence |
| Search 2 (`nums[mid] <= target` → `left = mid`) | Biases the search to keep narrowing right after a match, converging on the **last** occurrence |
| `(left + right + 1) / 2` in Search 2 | Rounds the midpoint **up** — without this, `left = mid` can get stuck when `left`/`right` are adjacent, causing an infinite loop |
| `left < nums.length && nums[left] == target` | Confirms the converged index is both in-bounds and an actual match, before trusting it as the answer |

---

## 🤔 Why two separate binary searches?
Finding "first occurrence" and "last occurrence" are contradictory goals on a match — one wants to keep narrowing left, the other right. A single pass can't do both, so the problem splits cleanly into two independent O(log n) searches run back-to-back. Two sequential O(log n) operations is still O(log n) overall (constant factors are dropped in Big-O), so this doesn't cost any complexity class.
Search 1 (leftmost) Search 2 (rightmost)
left→ [5,7,7,8,8,10] ←right left→ [5,7,7,8,8,10] ←right
converges to index 3 converges to index 4


Sample result for `nums=[5,7,7,8,8,10]`, `target=8`: `[3, 4]`

---

## ⚠️ Why not a single binary search + linear expansion?
A common naive approach: find *any* match with standard binary search, then walk left and right from there checking neighbors for more matches. This works, but in the worst case (e.g. an array of all the same value), that linear walk is O(n) — violating the O(log n) requirement. Two biased binary searches avoid this entirely by never scanning past what's needed.

---

## 🧠 Common Mistakes

**Mistake 1: Writing into `temp[mid]` instead of `temp[0]`/`temp[1]`**
```java
temp[mid] = mid; // invalid — mid can exceed temp's size of 2
```
Fix: `temp` has exactly 2 fixed, meaningful slots (first/last), unrelated to the value of `mid`.

**Mistake 2: Stopping the loop on first match**
Standard binary search returns immediately on `nums[mid] == target`. For boundary search, a match should *narrow the window further* (`right = mid` or `left = mid`), not return — there could be more occurrences on the biased side.

**Mistake 3: Wrong midpoint rounding causing infinite loop**
Using `(left + right) / 2` (rounds down) together with `left = mid` can get stuck when `right = left + 1`, since `mid` recomputes back to `left`. Fix: round up with `(left + right + 1) / 2` specifically when the update rule is `left = mid`.

**Mistake 4: Checking bounds with the wrong variable**
```java
if (right < nums.length && nums[left] == target) // inconsistent — mixes right and left
```
Fix: use the *same* variable for both the bounds check and the array access. `left` is the safer choice — it correctly guards the empty-array case (`nums.length == 0`), where `right` starts at `-1` and can pass a bounds check incorrectly.

**Mistake 5: Referencing `mid` after the loop**
`mid` is declared inside the `while` block, so it goes out of scope once the loop ends. Use `left` (or `right` — equal at that point, except in the empty-array edge case) as the surviving variable instead.

---

## ⏱ Time Complexity
O(log n) — two independent binary searches run sequentially, each halving the search space per iteration.

---

## 🔑 Key Learnings
- A single binary search can find *a* match; finding a *boundary* (first/last) requires biasing the narrowing direction after a match, not stopping.
- Two sequential O(log n) operations remain O(log n) overall — sequential isn't the same as nested.
- Midpoint rounding direction matters and can cause infinite loops depending on which pointer the match branch moves.
- Always validate a converged index against both bounds (`< nums.length`) and content (`== target`) before trusting it — a converged binary search index isn't automatically a real match.
- The empty-array edge case (`nums.length == 0`) breaks the usual "left equals right after the loop" assumption and must be checked with the variable that starts non-negative (`left`, not `right`).

---

## 🎯 Final Query
```java
class Solution {
    public int[] searchRange(int[] nums, int target) {
        int left = 0;
        int right = nums.length - 1;
        int[] temp = new int[2];

        // Search 1: find leftmost occurrence
        while (left < right) {
            int mid = (left + right) / 2;
            if (nums[mid] >= target) {
                right = mid;
            } else {
                left = mid + 1;
            }
        }
        if (left < nums.length && nums[left] == target) {
            temp[0] = left;
        } else {
            temp[0] = -1;
        }

        // Search 2: find rightmost occurrence
        left = 0;
        right = nums.length - 1;
        while (left < right) {
            int mid = (left + right + 1) / 2;
            if (nums[mid] <= target) {
                left = mid;
            } else {
                right = mid - 1;
            }
        }
        if (left < nums.length && nums[left] == target) {
            temp[1] = left;
        } else {
            temp[1] = -1;
        }

        return temp;
    }
}
```
