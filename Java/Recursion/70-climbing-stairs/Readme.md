# 70. Climbing Stairs

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-green)
![Topic](https://img.shields.io/badge/Topic-Recursion-blue)
![Status](https://img.shields.io/badge/Status-Accepted-brightgreen)

**Concepts:** Recursion · Base Cases · Memoization · Overlapping Subproblems

---

## ✅ Problem Summary

- [x] You are climbing a staircase that takes `n` steps to reach the top
- [x] Each move, you can climb either `1` or `2` steps
- [x] Return the number of **distinct ways** to reach the top
- [x] Constraints: `1 <= n <= 45`

---

## 🤔 Solution

```java
class Solution {
    public int climbStairs(int n) {

        int[] memo = new int[n + 1];
        for (int i = 0; i < memo.length; i++) {
            memo[i] = -1;
        }
        return helper(n, memo);

    }

    private int helper(int n, int[] memo) {
        if (n == 0) {
            return 1;
        }
        if (n == 1) {
            return 1;
        }

        if (memo[n] != -1) {
            return memo[n];
        }

        int result = helper(n - 1, memo) + helper(n - 2, memo);
        memo[n] = result;

        return result;
    }
}
```

---

## 🧩 Breakdown

| Line | What it does |
|---|---|
| `int[] memo = new int[n + 1]` | Creates one array, sized to hold an answer for every `n` from `0` to the target — created **once**, in the entry method |
| `for (...) memo[i] = -1` | Marks every slot as "not computed yet" — needed because Java defaults `int[]` slots to `0`, which could be confused with a real answer |
| `return helper(n, memo)` | Hands off to a private helper that does the actual recursion, passing the *same* memo array along every time |
| `if (n == 0) return 1;` | Base case: one way to be at the top with zero steps taken — you're already there |
| `if (n == 1) return 1;` | Base case: only one way to climb a single step |
| `if (memo[n] != -1) return memo[n];` | If this subproblem was already solved on a previous branch, return the stored answer instantly — skip recomputing it |
| `helper(n - 1, memo) + helper(n - 2, memo)` | Your last move to reach step `n` was either a 1-step (from `n-1`) or a 2-step (from `n-2`) — sum of both counts every way |
| `memo[n] = result` | Store the answer **before** returning, so any other branch that needs `helper(n)` again gets it instantly |

---

## 🧠 Why Recursion + Memoization?

This problem is really "count the number of ways," and the key insight is that reaching step `n` only has two possible last moves — a 1-step or a 2-step. That naturally gives a recursive relationship:

```
ways(n) = ways(n-1) + ways(n-2)
```

This is the exact same shape as the Fibonacci sequence, just framed as a staircase instead of a number sequence.

**The relationship between steps:**

```
        ways(n)
        /      \
  ways(n-1)   ways(n-2)
```

**Sample trace for n = 4 (without memoization) — showing the repeated work:**

```
climbStairs(4)
├── climbStairs(3)
│   ├── climbStairs(2)      <- computed here
│   │   ├── climbStairs(1)
│   │   └── climbStairs(0)
│   └── climbStairs(1)
└── climbStairs(2)          <- computed AGAIN here
    ├── climbStairs(1)
    └── climbStairs(0)
```

| n | ways(n) |
|---|---|
| 0 | 1 |
| 1 | 1 |
| 2 | 2 |
| 3 | 3 |
| 4 | 5 |
| 5 | 8 |

---

## ⚠️ Why Not Plain Recursion (No Memoization)?

A pure recursive version (no `memo` array) is simpler to write, but it recomputes the same subproblems over and over — as seen in the trace above, `climbStairs(2)` alone gets computed twice just for `n=4`. This repetition roughly **doubles at every level**, so by `n=45` the number of redundant calls explodes into the billions, causing a **Time Limit Exceeded** error.

Memoization fixes this by storing each subproblem's answer the first time it's solved, so every repeat request is an instant array lookup instead of a full recursive re-exploration.

---

## 🐛 Common Mistakes

**Mistake 1 — Comparing `memo[n]` to `n` instead of the sentinel value:**
```java
// Wrong — memo[n] starts at 0 (Java's default), not n
if (memo[n] != n) {
    return memo[n];
}
```
```java
// Fix — compare against the sentinel value (-1) that means "not computed yet"
if (memo[n] != -1) {
    return memo[n];
}
```

**Mistake 2 — Creating a new `memo` array inside every recursive call:**
```java
// Wrong — recreates an empty array on every single call, remembers nothing
private int helper(int n) {
    int[] memo = new int[n + 1];
    ...
}
```
```java
// Fix — create memo ONCE in the entry method, pass the same array through every call
public int climbStairs(int n) {
    int[] memo = new int[n + 1];
    return helper(n, memo);
}
private int helper(int n, int[] memo) { ... }
```

**Mistake 3 — Forgetting to store the result before returning:**
```java
// Wrong — computes the answer but never saves it, so it gets recomputed every time
int result = helper(n - 1, memo) + helper(n - 2, memo);
return result;
```
```java
// Fix — store it in memo[n] first
int result = helper(n - 1, memo) + helper(n - 2, memo);
memo[n] = result;
return result;
```

---

## ⏱️ Time Complexity

- **Without memoization:** O(2^n) — exponential, each call branches into two more calls
- **With memoization:** O(n) — each subproblem from `0` to `n` is computed exactly once, then reused via array lookup

---

## 🔑 Key Learnings

- A `StackOverflowError` happens when recursion never reaches its base case — each call pushes a new frame onto the call stack until memory runs out
- Overlapping subproblems (the same smaller input computed by multiple different branches) is the signal that plain recursion will be too slow
- Memoization requires the storage (array/map) to be created **once**, outside the recursive calls, and passed along through every call — recreating it inside the recursive method defeats the purpose
- A sentinel value (like `-1`) is needed to distinguish "not computed yet" from "computed, and the answer is a real value" — especially important when `0` is a valid possible answer
- This problem is structurally identical to Fibonacci — recognizing that shape helps spot similar patterns in other counting problems (tiling, coin paths, etc.)

---

## 🔁 Final Query

```java
class Solution {
    public int climbStairs(int n) {

        int[] memo = new int[n + 1];
        for (int i = 0; i < memo.length; i++) {
            memo[i] = -1;
        }
        return helper(n, memo);

    }

    private int helper(int n, int[] memo) {
        if (n == 0) {
            return 1;
        }
        if (n == 1) {
            return 1;
        }

        if (memo[n] != -1) {
            return memo[n];
        }

        int result = helper(n - 1, memo) + helper(n - 2, memo);
        memo[n] = result;

        return result;
    }
}
```
