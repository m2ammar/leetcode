# 88. Merge Sorted Array

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-Two%20Pointers-orange)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** Two Pointers · In-Place Merge · Backward Traversal

---

## ✅ Problem Summary
- `nums1` and `nums2` are both sorted in non-decreasing order
- `nums1` has extra trailing space (`m + n` length) to hold the merged result
- Merge both arrays **in-place**, storing the final sorted result inside `nums1`
- Optimal solution should run in `O(m + n)` time

---

## 🧠 Solution
```java
class Solution {
    public void merge(int[] nums1, int m, int[] nums2, int n) {
        int p1 = m - 1;
        int p2 = n - 1;
        int p = m + n - 1;

        while (p1 >= 0 && p2 >= 0) {
            if (nums1[p1] > nums2[p2]) {
                nums1[p] = nums1[p1];
                p1--;
                p--;
            } else {
                nums1[p] = nums2[p2];
                p2--;
                p--;
            }
        }

        while (p2 >= 0) {
            nums1[p] = nums2[p2];
            p2--;
            p--;
        }
    }
}
```

---

## 🧩 Breakdown

| Variable/Clause | What it does |
|---|---|
| `p1 = m - 1` | Points at the last *real* element in `nums1` (ignoring the trailing zero-padding) |
| `p2 = n - 1` | Points at the last element in `nums2` |
| `p = m + n - 1` | Points at the last slot of the full merged array (`nums1`'s actual end) |
| `while (p1 >= 0 && p2 >= 0)` | Runs as long as both arrays still have unplaced elements |
| `if (nums1[p1] > nums2[p2])` | Picks whichever of the two current candidates is larger |
| Cleanup `while (p2 >= 0)` | Copies any remaining `nums2` elements once `nums1`'s original elements are exhausted |

---

## 🤔 Why Merge From the Back (Not the Front)?
If you merged front-to-back like a normal merge-sort merge step, you'd overwrite `nums1`'s own unprocessed elements before reading them — since the write target and the read source are the *same array*.

Merging **backward** avoids this entirely: the slots being written to (`nums1[p]`, working from the end) are always slots that have already been "used up" (their original values already read), so nothing gets overwritten before it's needed.

```text
nums1 = [1, 2, 3, 0, 0, 0]   (m = 3, real data: 1,2,3)
nums2 = [2, 5, 6]            (n = 3)

Fill nums1 from index 5 downward — the empty back slots
get filled first, so the front (still-needed) values are
never at risk of being overwritten.
```

---

## ⚠️ Why No Cleanup Loop for Leftover `nums1`?
Only `nums2` gets a cleanup loop (`while (p2 >= 0)`) — there's no equivalent loop for leftover `nums1` elements. If `nums2` runs out first, whatever's left in `nums1` is **already sitting in the correct position** at the front of the array (since we only ever moved elements from right to left, in place) — there's nothing left to copy.

---

## ⚠️ Common Mistakes

**Mistake 1 — Missing pointer decrements in one branch**
```java
if (nums1[p1] > nums2[p2]) {
    nums1[p] = nums1[p1];
    p1--;
    // missing: p--
}
```
Every branch of the comparison must decrement **both** the source pointer (`p1` or `p2`) *and* the destination pointer `p`. Skipping `p--` in one branch causes the write index to fall out of sync, silently corrupting the merge (e.g. `[1,2,3,2,5,6]` instead of `[1,2,2,3,5,6]`) even though the array is otherwise "sorted-looking."

**Mistake 2 — Moving pointers in the wrong direction**
Since this is a backward merge, pointers must **decrement** (`p1--`, `p2--`, `p--`), not increment. Using `++` here silently breaks the whole traversal direction.

---

## ⏱ Time Complexity
O(m + n) — each element from both arrays is visited and placed exactly once.

## 💾 Space Complexity
O(1) — merged entirely in-place within `nums1`, no auxiliary array used.

---

## 🧠 Key Learnings
- When merging in-place into an array that also holds unread source data, merge **backward** to avoid overwriting values before they're read
- Every comparison branch in a two-pointer merge needs to move **all** relevant pointers (source *and* destination) — a missing decrement is a classic silent bug
- No cleanup loop is needed for the side whose elements are already correctly positioned once the other side is exhausted

---

## 🏁 Final Query
```java
class Solution {
    public void merge(int[] nums1, int m, int[] nums2, int n) {
        int p1 = m - 1;
        int p2 = n - 1;
        int p = m + n - 1;

        while (p1 >= 0 && p2 >= 0) {
            if (nums1[p1] > nums2[p2]) {
                nums1[p] = nums1[p1];
                p1--;
                p--;
            } else {
                nums1[p] = nums2[p2];
                p2--;
                p--;
            }
        }

        while (p2 >= 0) {
            nums1[p] = nums2[p2];
            p2--;
            p--;
        }
    }
}
```
