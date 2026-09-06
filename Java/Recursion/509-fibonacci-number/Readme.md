# 509. Fibonacci Number

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-Recursion-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** Recursion · Base Cases · Call Stack

---

## ✅ Problem Summary

- Given `n`, return `F(n)`, where the Fibonacci sequence is defined as:
  - `F(0) = 0`
  - `F(1) = 1`
  - `F(n) = F(n - 1) + F(n - 2)` for `n > 1`
- Constraints: `0 <= n <= 30`

---

## 🧠 Solution

```java
class Solution {
    public int fib(int n) {

        if (n == 0) { return 0; }
        if (n == 1) { return 1; }

        return fib(n - 1) + fib(n - 2);
    }
}
```

---

## 🧩 Breakdown

| Line | What it does |
|---|---|
| `if (n == 0) return 0;` | Base case #1 — the recursion stops here for `n = 0`, a known fact, not computed. |
| `if (n == 1) return 1;` | Base case #2 — same idea for `n = 1`. |
| `return fib(n-1) + fib(n-2);` | Recursive case — breaks the problem into two smaller subproblems and sums their results. |

---

## 🤔 Why two base cases?

Unlike a sum-of-n or factorial problem (which only needs **one** stopping point, since each call only branches into one smaller call), Fibonacci branches into **two** recursive calls per step (`n-1` and `n-2`). That means the recursion can reach `n=1` and `n=0` in different orders depending on the path taken, so **both** values need to be handled directly as base cases — otherwise a path could undershoot into negative numbers with no defined stopping condition.

Call tree for `n = 4`:

```
                fib(4)
              /        \
         fib(3)         fib(2)
        /      \        /      \
    fib(2)   fib(1)  fib(1)   fib(0)
    /    \
 fib(1) fib(0)
```

Each branch keeps splitting until it hits `fib(1)` or `fib(0)` — the two facts we already know — and the results sum back up the tree.

---

## ⚠️ Common Mistakes

**Mistake 1 — doing arithmetic instead of recursing:**
```java
result = (n - 1) + (n - 2); // just subtracts numbers, never calls fib()
```
Fix: the recursive definition needs the **function's output** for smaller `n`, not `n` itself minus something:
```java
result = fib(n - 1) + fib(n - 2);
```

**Mistake 2 — no real base case:**
```java
if (n >= 0) {
    result += fib(n - 1) + fib(n - 2);
}
```
`n >= 0` never stops the recursion — it's true for every valid input, so calls keep drifting into negative `n` with nothing to catch them. A base case must be a condition where the function returns a **direct, known value** with no further recursive calls.

---

## ⏱️ Time Complexity

- **Time:** O(2^n) — each call branches into two more calls, forming a full binary tree of depth `n`. Fine for this problem's constraint (`n <= 30`), but would need memoization for larger `n`.
- **Space:** O(n) — max recursion depth (the call stack) at any point is `n`.

---

## 🔑 Key Learnings

- A base case is where recursion **stops and returns a known value** — not just a condition that happens to be true for valid input.
- Problems with two recursive calls per step (like Fibonacci) often need more than one base case to cover every path the recursion can take.
- Writing `fib(n-1) + fib(n-2)` looks similar to plain arithmetic on `n` — easy to accidentally skip the actual recursive call.

---

## 📌 Final Query

```java
class Solution {
    public int fib(int n) {

        if (n == 0) { return 0; }
        if (n == 1) { return 1; }

        return fib(n - 1) + fib(n - 2);
    }
}
```
