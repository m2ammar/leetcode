# 704. Binary Search

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-Binary%20Search-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** Binary Search · Divide and Conquer · Two Pointers (`left`/`right`) · Integer Overflow-Safe Midpoint

---

## ✅ Problem Summary

- Given `nums`, an array of integers **sorted in ascending order**, and an integer `target`.
- Return the **index** of `target` in `nums` if it exists.
- Return `-1` if `target` is not present.
- Must run in `O(log n)` time — a linear scan is not acceptable.

---

## 🧠 Solution

```java
class Solution {
    public int search(int[] nums, int target) {
        int left = 0;
        int right = nums.length;
        int temp = -1;

        while (left < right) {
            int mid = (left + right) / 2;
            if (nums[mid] == target) {
                temp = mid;
                break;
            } else if (nums[mid] > target) {
                right = mid;
            } else if (nums[mid] < target) {
                left = mid + 1;
            }
        }
        return temp;
    }
}
```

---

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `int left = 0; int right = nums.length;` | Sets up the initial search boundaries — a half-open range `[left, right)` covering the whole array. |
| `int temp = -1;` | Sentinel result — stays `-1` unless the target is actually found, since `-1` can never be a real index. |
| `while (left < right)` | Keeps searching as long as there's a non-empty range left to check. |
| `int mid = (left + right) / 2;` | Recomputed every iteration — the midpoint of the *current* range, not a fixed value. |
| `if (nums[mid] == target)` | Found it — record the index and exit the loop. |
| `else if (nums[mid] > target) right = mid;` | Target must be left of `mid`, so shrink `right` down to `mid` (excluding `mid`, since it's already ruled out). |
| `else if (nums[mid] < target) left = mid + 1;` | Target must be right of `mid`, so move `left` to `mid + 1` (excluding `mid`). |
| `return temp;` | Returns the found index, or `-1` if the loop exhausted the range without a match. |

---

## 🤔 Why Binary Search?

The array is already sorted — that single fact is what makes binary search possible. Every comparison against `nums[mid]` tells you which *half* of the remaining range the target could still be in, so you can throw away the other half entirely instead of checking it element by element.

```
nums = [-1, 0, 3, 5, 9, 12],  target = 9

Step 1: left=0, right=6 -> mid=3 -> nums[3]=5 < 9 -> search right half
Step 2: left=4, right=6 -> mid=5 -> nums[5]=12 > 9 -> search left half
Step 3: left=4, right=5 -> mid=4 -> nums[4]=9 == 9 -> found at index 4
```

Each step cuts the search space roughly in half — that halving is exactly what produces `O(log n)` performance instead of `O(n)`.

---

## 🚫 Why not a linear scan?

A simple `for` loop checking every element (`O(n)`) would also return the correct answer and is easier to write. It's rejected here because the problem explicitly requires `O(log n)` — and more generally, ignoring the fact that the array is sorted throws away information that would let you solve the problem dramatically faster. Once an array is sorted, linear scanning is almost always the wrong default.

---

## 📊 Loop Approach at a Glance

| Approach | Iteration count is known in advance? | Fits binary search? |
|---|---|---|
| `for` loop | Yes — built for counted iteration by a fixed step rule | Awkward — forces an empty increment clause since the step itself is conditional |
| `while` loop | No — condition-based, keeps going until the range is empty | Natural fit — matches "shrink the range until nothing's left" logic |

---

## ⚠️ Common Mistakes

**1. Comparing `mid` (the index) to `target` instead of `nums[mid]` (the value):**
```java
// Wrong — mid is a position, not a value
if (mid == target)
```
`target` is a value you're searching *for*; `mid` is just where you're currently looking. You need `nums[mid]`.

**2. Computing `mid` once, outside the loop:**
```java
// Wrong — mid never updates as left/right shrink
int mid = nums.length / 2;
while (left < right) { ... }
```
`mid` must be recalculated every iteration from the *current* `left` and `right` — otherwise it stays frozen at its very first value.

**3. Setting `left = mid` instead of `left = mid + 1` (infinite loop risk):**
```java
// Wrong — can freeze left in place forever
left = mid;
```
Integer division rounds down, so when `left` and `right` are close (e.g. `left=3, right=4`), `mid` can equal `left`. Reassigning `left = mid` in that case doesn't change `left` at all — the range never shrinks, and the loop spins forever (shows up as **Time Limit Exceeded**). Since `nums[mid]` has already been ruled out, `left` must move *past* it: `left = mid + 1`.

**4. Using a sentinel value that collides with a real index:**
```java
// Wrong — 0 is a valid index, so this is ambiguous
int temp = 0;
```
`-1` is the correct sentinel because the problem's constraints guarantee indices are always `>= 0` — `-1` can never be mistaken for a real found position.

---

## ⏱️ Time Complexity

`O(log n)` — each iteration discards half the remaining search space, so the number of iterations needed is proportional to `log₂(n)` rather than `n`. Space complexity is `O(1)` — only a fixed handful of `int` variables are used, no extra data structures.

---

## 🔑 Key Learnings

- Binary search requires a **sorted** input — it doesn't work (and isn't meaningful) on unsorted data.
- `mid` must always be recalculated from the *current* `left`/`right`, every single iteration.
- The classic infinite-loop bug in binary search comes from an update that doesn't actually shrink the range — always double-check that every branch moves a boundary to a genuinely new position (`mid + 1`, not `mid`, when excluding the midpoint after a "less than" comparison).
- `while` loops fit binary search naturally because the number of iterations isn't known in advance — it's a "shrink until empty" condition, not a fixed count.
- Runtime percentile on LeetCode reflects algorithmic complexity class (e.g. `O(log n)` vs `O(n)`); memory percentile is largely JVM/runtime noise for small inputs and isn't a meaningful signal to chase here.

---

## 🏁 Final Query

```java
class Solution {
    public int search(int[] nums, int target) {
        int left = 0;
        int right = nums.length;
        int temp = -1;

        while (left < right) {
            int mid = (left + right) / 2;
            if (nums[mid] == target) {
                temp = mid;
                break;
            } else if (nums[mid] > target) {
                right = mid;
            } else if (nums[mid] < target) {
                left = mid + 1;
            }
        }
        return temp;
    }
}
```
