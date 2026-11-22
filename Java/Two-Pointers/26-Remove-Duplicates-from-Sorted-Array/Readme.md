# 26. Remove Duplicates from Sorted Array

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-Two%20Pointers-blue)
![Language](https://img.shields.io/badge/Language-Java-orange)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** Two Pointers · Read/Write Pointer · In-Place Modification · Sorted Array

---

## ✅ Problem Summary

Given an integer array `nums` sorted in non-decreasing order:

- ✔ Remove duplicates **in-place** so each unique value appears once
- ✔ Keep the relative order of the elements
- ✔ Return `k`, the number of unique elements
- ✔ The first `k` slots of `nums` must hold the unique values; anything after index `k - 1` is ignored

---

## 🧩 Solution

```java
class Solution {
    public int removeDuplicates(int[] nums) {
        int k = 1; // next slot to write a unique value into (nums[0] is always kept)

        for (int j = 1; j < nums.length; j++) {
            // nums[k - 1] is the last unique value we kept
            if (nums[j] != nums[k - 1]) {
                nums[k] = nums[j];
                k++;
            }
        }
        return k;
    }
}
```

---

## 🔍 Breakdown

| Line | What it does |
|------|--------------|
| `int k = 1` | Write pointer: the next slot for a unique value. `nums[0]` is always unique, so it is already "kept". |
| `for (int j = 1; ...)` | Read pointer: scans the rest of the array. Starts at 1 because index 0 is already kept. |
| `nums[j] != nums[k - 1]` | Is this value different from the last one we kept? Since the array is sorted, different means new. |
| `nums[k] = nums[j]` | Copy the new unique value into the next free slot of the kept section. |
| `k++` | Grow the kept section by one. Moves **only** when a new value is found. |
| `return k` | The kept section's length is exactly the number of unique values. |

---

## 🤔 Why Two Pointers?

The array is sorted, so duplicates sit next to each other. That lets one pass split the array into two zones:

```
[ kept section | scanned (duplicates) | not yet scanned ]
  0 ... k-1      k ... j-1             j ... n-1
```

Trace on `[0, 0, 1, 1, 1, 2]`:

| j | nums[j] | nums[k-1] | Different? | Action | Array | k |
|---|---------|-----------|------------|--------|-------|---|
| 1 | 0 | 0 | No | skip | `[0,0,1,1,1,2]` | 1 |
| 2 | 1 | 0 | Yes | `nums[1] = 1` | `[0,1,1,1,1,2]` | 2 |
| 3 | 1 | 1 | No | skip | `[0,1,1,1,1,2]` | 2 |
| 4 | 1 | 1 | No | skip | `[0,1,1,1,1,2]` | 2 |
| 5 | 2 | 1 | Yes | `nums[2] = 2` | `[0,1,2,1,1,2]` | 3 |

Return `3`. The first 3 slots are `[0, 1, 2]`.

---

## 🚫 Why Not a Separate Array or HashSet?

| Approach | Problem |
|----------|---------|
| Copy uniques into a new array | Uses O(n) extra space, and the judge only checks `nums`, not your new array. |
| `HashSet` to filter duplicates | O(n) extra space, loses the in-place requirement, and ignores the sorted property. |
| Two pointers (this solution) | O(1) extra space, single pass, uses sortedness. |

---

## ⚠️ Common Mistakes

### 1. Counting duplicates instead of unique values
```java
if (nums[i] == nums[i + 1]) { k++; }   // k = number of duplicates
```
The answer is the number of **unique** values, so `k` should move on the *different* case.

### 2. Returning a value instead of a count
```java
return nums[k];   // an array element, not a length
```
✅ `return k;`

### 3. Using a separate, uninitialized array
```java
int[] temp;          // never initialized, won't compile
return temp;         // wrong return type too
```
The problem requires modifying `nums` itself.

### 4. One pointer doing two jobs
Using `i` both to read and to decide where to write leaves gaps once a duplicate is skipped. Reading and writing need **separate** pointers.

### 5. Comparing with the neighbor and stopping at `length - 1`
```java
for (int i = 0; i < nums.length - 1; i++) {
    if (nums[i] != nums[i + 1]) ...
}
```
The last element never gets handled. Comparing against the **last kept value** (`nums[k - 1]`) removes that boundary problem.

### 6. Mixing the two `k` conventions
- `k` = index of last kept value: start at 0, pre-increment before writing, answer is `k + 1`
- `k` = next write slot: start at 1, write then increment, answer is `k`

Pick one and stay consistent. `nums[k++] = nums[j]` with `k` starting at 0 overwrites the value you meant to keep.

---

## ⏱ Complexity

- **Time:** O(n), one pass
- **Space:** O(1), in-place

---

## 🔑 Key Learnings

- Read pointer and write pointer are separate jobs; the write pointer moves **conditionally**
- Compare against the **last kept value**, not the next neighbor
- In a sorted array, a value is new exactly when it differs from the last kept one
- Decide the meaning of `k` first (last kept index vs. next write slot) and keep the invariant consistent
- Same read/write pattern applies to 27. Remove Element and 283. Move Zeroes

---

## 🏁 Final Solution

```java
class Solution {
    public int removeDuplicates(int[] nums) {
        int k = 1;

        for (int j = 1; j < nums.length; j++) {
            if (nums[j] != nums[k - 1]) {
                nums[k] = nums[j];
                k++;
            }
        }
        return k;
    }
}
```

**Result:** Accepted · 362 / 362 test cases · 0 ms
