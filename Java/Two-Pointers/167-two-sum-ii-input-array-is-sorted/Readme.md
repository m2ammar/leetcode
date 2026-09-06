# 167. Two Sum II - Input Array Is Sorted

![Difficulty](https://img.shields.io/badge/Difficulty-Medium-orange)
![Topic](https://img.shields.io/badge/Topic-Two%20Pointers-red)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** Two Pointers · Sorted Array · Constant Space

---

## ✅ Problem Summary

- Given a 1-indexed array `numbers`, sorted in non-decreasing order, and a target sum.
- Find the two numbers that add up to `target`.
- Return their 1-indexed positions as `[index1, index2]`, with `index1 < index2`.
- Exactly one solution is guaranteed to exist; the same element can't be used twice.
- Must use only constant extra space (no hash map).

---

## 🧠 Solution

```java
class Solution {
    public int[] twoSum(int[] numbers, int target) {
        int left = 0;
        int right = numbers.length - 1;
        int[] temp = new int[2];

        while (left < right) {

            if (numbers[left] + numbers[right] == target) {
                temp[0] = left + 1;
                temp[1] = right + 1;
                break;
            } else if (numbers[left] + numbers[right] < target) {
                left += 1;
            } else if (numbers[left] + numbers[right] > target) {
                right -= 1;
            }
        }
        return temp;
    }
}
```

---

## 🧩 Breakdown

| Line | What it does |
|---|---|
| `int left = 0; int right = numbers.length - 1;` | Two pointers start at opposite ends of the sorted array. |
| `while (left < right)` | Loop stops before the pointers meet or cross — prevents reusing the same element twice. |
| `numbers[left] + numbers[right] == target` | Found the pair — store 1-indexed positions and `break` immediately. |
| `numbers[left] + numbers[right] < target` | Sum too small — move `left` forward to bring in a larger value. |
| `numbers[left] + numbers[right] > target` | Sum too big — move `right` backward to bring in a smaller value. |
| `return temp;` | Returned outside the loop, since Java requires every path to return a value. |

---

## 🤔 Why Two Pointers?

The array is already **sorted**, which is what makes this technique work at all: moving `left` forward always gives an equal-or-larger value, and moving `right` backward always gives an equal-or-smaller value. That guarantee lets each comparison make a confident directional decision — no guessing, no need to check every pair.

```
numbers: [-1, 0]
           ^   ^
         left right   →  sum = -1  →  matches target (-1)  →  return [1, 2]
```

Each step shrinks the search space by exactly one element from one side, so the whole array is covered in a single pass — O(n) time, O(1) space, satisfying the problem's constant-space requirement directly.

---

## ⚠️ Why not a Hash Map (like classic Two Sum)?

The original **Two Sum (#1)** problem is typically solved with a hash map: store each number's index while scanning, and check if `target - current` has already been seen. That's O(n) time too, but O(n) *space*.

This problem explicitly requires **constant extra space**, which rules the hash map approach out. Since the array is also guaranteed sorted (unlike #1), two pointers becomes not just an alternative — it's the intended, more efficient technique for this exact variant.

---

## 🐛 Common Mistakes

**Using `left <= right` instead of `left < right`:**
```java
// ❌ allows left and right to point at the same element
while (left <= right) { ... }
```
Fix: `left == right` means only one element is available — using it twice is forbidden by the problem. The loop must stop before pointers meet.

**Only handling one direction of movement:**
```java
// ❌ else branch always decrements right, even when the sum is too small
if (sum == target) { ... }
else { right -= 1; }
```
Fix: sum-too-small and sum-too-big are different cases needing different pointer movements — `left += 1` and `right -= 1` are not interchangeable.

**Storing the result without stopping the loop:**
```java
// ❌ no break — loop keeps re-checking the same match forever
if (sum == target) {
    temp[0] = left + 1;
    temp[1] = right + 1;
}
```
Fix: without `break` (or an immediate `return`), `left` and `right` never move again once matched, causing an infinite loop.

**Forgetting the +1 for 1-indexing:**
```java
// ❌ returns raw 0-indexed positions
temp[0] = left;
temp[1] = right;
```
Fix: the problem explicitly asks for 1-indexed output, even though Java arrays are 0-indexed internally.

---

## ⏱️ Time Complexity

`O(n)` — each pointer moves at most `n` times total, and the array is scanned at most once. Space is `O(1)`, satisfying the constant-space requirement.

---

## 🔑 Key Learnings

- Two pointers only works reliably because the array is sorted — sortedness is what guarantees a directional move (`left++` or `right--`) changes the sum predictably.
- `left < right`, not `left <= right`, is the correct stopping condition whenever reusing the same element is disallowed.
- A match found inside a loop still needs an explicit `break` or `return` — storing a result doesn't stop execution by itself.
- Same underlying "narrow the range from both ends" logic as binary search, just comparing a running sum against a target instead of a midpoint value.

---

## 🎯 Final Query

```java
class Solution {
    public int[] twoSum(int[] numbers, int target) {
        int left = 0;
        int right = numbers.length - 1;
        int[] temp = new int[2];

        while (left < right) {

            if (numbers[left] + numbers[right] == target) {
                temp[0] = left + 1;
                temp[1] = right + 1;
                break;
            } else if (numbers[left] + numbers[right] < target) {
                left += 1;
            } else if (numbers[left] + numbers[right] > target) {
                right -= 1;
            }
        }
        return temp;
    }
}
```
