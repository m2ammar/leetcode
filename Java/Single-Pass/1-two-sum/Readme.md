# 1. Two Sum

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-Java-orange)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** `HashMap` · `containsKey` · `put` · `get` · Complement · One Pass · Array

---

## ✅ Problem Summary

Given an integer array `nums` and an integer `target`:

- ✅ Return the **indices** of the two numbers that add up to `target`
- ✅ Exactly one valid answer exists
- ✅ The same element cannot be used twice
- ✅ The answer can be returned in any order
- ✅ Follow-up: do better than O(n²)

---

## 💡 Solution

```java
import java.util.HashMap;

class Solution {
    public int[] twoSum(int[] nums, int target) {
        HashMap<Integer, Integer> map = new HashMap<>(); // number -> index
        int[] arr = new int[2];

        for (int i = 0; i < nums.length; i++) {
            int temp = target - nums[i]; // the value we need to find

            if (map.containsKey(temp)) {
                arr[0] = map.get(temp); // earlier index
                arr[1] = i;             // current index
                return arr;
            }

            map.put(nums[i], i);
        }

        return arr; // never reached: a solution is guaranteed
    }
}
```

---

## 🔍 Breakdown

| Line | What it does |
|------|--------------|
| `HashMap<Integer, Integer> map` | Stores every number seen so far (key) with its index (value) |
| `int temp = target - nums[i]` | The exact value needed to pair with the current number |
| `map.containsKey(temp)` | O(1) check: did we already pass the number we need? |
| `arr[0] = map.get(temp)` | Index of the earlier number |
| `arr[1] = i` | Index of the current number |
| `return arr` inside the `if` | Stop as soon as the pair is found |
| `map.put(nums[i], i)` | Remember the current number for later elements |
| `return arr` at the end | Only satisfies the compiler, never runs |

---

## 🤔 Why HashMap?

At each element we only need to answer one question: *"Have I already seen `target - nums[i]`?"*

A `HashMap` answers that in O(1), which replaces the inner loop.

```
nums = [2, 7, 11, 15], target = 9

i = 0 → nums[0] = 2, temp = 7 → map is empty, no match → put(2, 0)   map: {2→0}
i = 1 → nums[1] = 7, temp = 2 → map has 2 (index 0)   → return [0, 1]
```

The map only ever holds elements **before** the current index, so the current element can never match itself.

---

## 🧩 Why not Brute Force?

```java
for (int i = 0; i < nums.length; i++) {
    for (int j = i + 1; j < nums.length; j++) {
        if (nums[i] + nums[j] == target) return new int[]{i, j};
    }
}
```

- ✅ Correct, and a fine baseline
- ❌ O(n²) time, which is exactly what the follow-up asks us to beat
- The HashMap trades O(n) extra space for O(n) time

---

## ⚠️ Common Mistakes

### 1. Only checking neighbors
```java
int temp2 = nums[i + 1] + nums[i];   // ❌ misses non-adjacent pairs
```
Fails on `[1,5,4]`, target 5 (answer is `[0,2]`). Also throws `ArrayIndexOutOfBoundsException` at the last index.

### 2. Assigning an int to an int[]
```java
arr = i;        // ❌ compile error
arr[0] = i;     // ✅
```

### 3. Wrong order: put before check
```java
map.put(nums[i], i);            // ❌ current element enters the map first
if (map.containsKey(temp)) ...  // can match itself
```
On `[3,3]`, target 6 this returns `[0, 0]`, reusing one element. Always **check first, then put**.

### 4. Storing the wrong key/value
```java
map.put(i, target);      // ❌
map.put(nums[i], i);     // ✅ number as key, index as value
```
We look up by *number*, and we need the *index* back.

### 5. Missing final return
```java
for (...) { ... }
}   // ❌ error: missing return statement
```
Java checks every path, so the method needs a `return` (or a `throw`) after the loop.

---

## ⏱️ Time Complexity

- **Time:** O(n), one pass, each lookup and insert is O(1) on average
- **Space:** O(n), the map can hold up to n − 1 entries

---

## 🧠 Key Learnings

- Look for the **complement** (`target - current`) instead of scanning for a partner
- Use a `HashMap` for O(1) "have I seen this?" checks
- **Check first, then put**, so an element never pairs with itself
- Map key = the value you search by, map value = the data you need back (the index)
- Two pointers needs a sorted array, and sorting would lose the original indices
- Pattern to reuse: *"for each element, look up what you need in a map of what you've already seen"*

---

## 📌 Final Solution

```java
import java.util.HashMap;

class Solution {
    public int[] twoSum(int[] nums, int target) {
        HashMap<Integer, Integer> map = new HashMap<>();
        int[] arr = new int[2];

        for (int i = 0; i < nums.length; i++) {
            int temp = target - nums[i];

            if (map.containsKey(temp)) {
                arr[0] = map.get(temp);
                arr[1] = i;
                return arr;
            }
            map.put(nums[i], i);
        }
        return arr;
    }
}
```
