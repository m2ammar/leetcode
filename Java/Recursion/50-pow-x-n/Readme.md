# 50. Pow(x, n)

![Difficulty](https://img.shields.io/badge/Difficulty-Medium-orange)
![Topic](https://img.shields.io/badge/Topic-Recursion-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** Recursion · Divide and Conquer · Integer Overflow Handling

---

## ✅ Problem Summary

- Implement `pow(x, n)` — compute `x` raised to the power `n`.
- `n` can be negative, zero, or positive.
- Must not use any built-in power function.
- `n` ranges across the full `int` range, including `Integer.MIN_VALUE`.

---

## Solution

```java
class Solution {
    public double myPow(double x, int n) {
        return helper(x, (long) n);
    }

    private double helper(double x, long n) {

        if (n < 0) {
            return helper(1 / x, -n);
        }
        if (n == 0) {
            return 1;
        }

        double half = helper(x, n / 2);

        if (n % 2 == 0) {
            half = half * half;
            return half;
        } else {
            half = half * half * x;
            return half;
        }
    }
}
```

---

## 🧩 Breakdown

| Part | What it does |
|---|---|
| `myPow(x, n)` | Public entry point matching LeetCode's required signature; casts `n` to `long` before any negation happens. |
| `helper(x, n)` with `n < 0` | Converts a negative-exponent problem into a positive one: `x^-n = (1/x)^n`. |
| `n == 0` | Base case — any number to the power 0 is 1. |
| `half = helper(x, n/2)` | Single recursive call that computes `x^(n/2)`, reused instead of calling twice. |
| `n % 2 == 0` branch | Even exponent: `x^n = half * half`. |
| `else` branch | Odd exponent: `x^n = half * half * x`, to account for the floor-divided remainder. |

---

## 🤔 Why Divide and Conquer?

Naively multiplying `x` by itself `n` times is O(n). By halving `n` each recursive call, the depth of recursion is O(log n), so the total work is O(log n) instead of O(n).

```
pow(x, 8)
 └─ pow(x, 4)
     └─ pow(x, 2)
         └─ pow(x, 1)
             └─ pow(x, 0) = 1
```

Each level squares the result of the level below it, so the exponent doubles back up as the recursion unwinds.

---

## ⚠️ Common Mistakes

**1. Calling the recursive function twice per level**

```java
// Wasteful — computes x^(n/2) twice
return helper(x, n/2) * helper(x, n/2);
```

Fix: store the result once in a variable (`half`) and reuse it — this is what actually gets you O(log n) instead of O(n).

**2. Negating `n` directly as an `int`**

```java
// Overflows when n == Integer.MIN_VALUE (-2147483648)
return helper(x, -n);
```

Since `int` ranges from `-2147483648` to `2147483647`, negating `Integer.MIN_VALUE` overflows and silently wraps back to the same negative value — causing infinite recursion and a `StackOverflowError`.

Fix: cast `n` to `long` *before* negating, and carry a `long` through a private helper method (since the public `myPow` signature must stay `int` per LeetCode's method signature).

```java
return helper(x, (long) n); // safe — long can hold 2147483648
```

**3. Multiplying by the literal `2` in the odd case**

```java
// Wrong — 2 is not related to the base
half = half * half * 2;
```

Fix: multiply by `x` (the base), not the number 2 — the extra factor needed comes from the remainder integer division drops, and that remainder always corresponds to one more copy of `x`.

---

## ⏱️ Time Complexity

- **Time:** O(log n) — the exponent is halved each recursive call.
- **Space:** O(log n) — recursion call stack depth.

---

## 🔑 Key Learnings

- Divide-and-conquer recursion turns an O(n) problem into O(log n) by halving the problem size each call.
- Reuse a single recursive call's result instead of calling twice for the same subproblem.
- Watch for integer overflow at range boundaries (`Integer.MIN_VALUE`) — negating it in a 32-bit `int` wraps around instead of throwing an error, which is easy to miss until it causes infinite recursion.
- When a required method signature can't be changed but you need a wider type internally, delegate to a private helper method with the wider type.

---

## Final Query

```java
class Solution {
    public double myPow(double x, int n) {
        return helper(x, (long) n);
    }

    private double helper(double x, long n) {

        if (n < 0) {
            return helper(1 / x, -n);
        }
        if (n == 0) {
            return 1;
        }

        double half = helper(x, n / 2);

        if (n % 2 == 0) {
            half = half * half;
            return half;
        } else {
            half = half * half * x;
            return half;
        }
    }
}
```
