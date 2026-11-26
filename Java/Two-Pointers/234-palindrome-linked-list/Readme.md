# 234. Palindrome Linked List

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-Linked%20List-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** Linked List · Two Pointers · Slow/Fast Pointers · In-place Reversal

---

## ✅ Problem Summary

- Given the `head` of a singly linked list, return `true` if it is a palindrome, otherwise `false`
- Follow-up: solve in **O(n) time and O(1) space**

---

## 💡 Solution

```java
class Solution {
    public boolean isPalindrome(ListNode head) {

        ListNode slow = head;
        ListNode fast = head;

        while (fast != null && fast.next != null) {
            slow = slow.next;
            fast = fast.next.next;
        }

        ListNode current = slow;
        ListNode prev = null;
        ListNode temp = null;

        while (current != null) {
            temp = current.next;
            current.next = prev;
            prev = current;
            current = temp;
        }

        ListNode left = head;
        ListNode right = prev;

        while (right != null) {
            if (right.val != left.val) {
                return false;
            }
            right = right.next;
            left = left.next;
        }

        return true;
    }
}
```

---

## 🧩 Breakdown

| Part | What it does |
|------|--------------|
| `slow` moves 1, `fast` moves 2 | When `fast` runs out, `slow` is at the middle |
| `fast != null && fast.next != null` | Safe for both even (`fast` falls off) and odd (`fast` on last node) lengths |
| Reverse from `slow` | Gives a "walk backward" ability on a singly linked list |
| `prev` | Head of the reversed second half after the loop |
| Compare `left` and `right` | Walks inward from both ends, one pair per step |
| `while (right != null)` | The reversed half is the shorter one, so it decides when to stop |

---

## 🤔 Why reverse the second half?

A singly linked list can't be walked backward, so first-vs-last comparison isn't possible directly. Reversing the second half makes both ends walkable going forward:

```
original:   1 → 2 → 2 → 1
first half: 1 → 2
reversed:   1 → 2        (from the tail)
compare pair by pair
```

**Odd length needs no special case.** The center node ends up at the end of the reversed half and just compares with itself.

---

## 🚫 Why not copy into an array?

Copying values into an array and running two pointers on it is simpler, but it uses **O(n) extra space**. Reversing the second half in place meets the follow-up requirement of **O(1) space**.

---

## ⚠️ Common Mistakes

**1. Loop condition on `fast` only checking one side**
```java
while (fast.next != null)   // crashes on even length when fast is null
```
Fix: `fast != null && fast.next != null`, with `fast != null` first because `&&` short-circuits.

**2. Forgetting to advance `left`**
```java
right = right.next;   // left never moves, so every pair is compared with head
```
Fix: advance both pointers at the end of every iteration.

**3. Comparing `slow` and `fast` directly**
After the first loop, `fast` is `null` on even lists, and one pair never proves a palindrome anyway. Every pair must be compared.

---

## ⏱️ Complexity

- **Time:** O(n), three linear passes
- **Space:** O(1), only a few pointers

---

## 🔑 Key Learnings

- Slow/fast pointers find the middle in one pass without knowing the length
- Reversing a linked list needs `prev`, `curr` and a saved `next`, in the right order
- Check that **every** pointer in a two-pointer loop gets advanced
- This solution modifies the input list (the second half stays reversed)

---

## 🏁 Final Solution

```java
class Solution {
    public boolean isPalindrome(ListNode head) {

        ListNode slow = head;
        ListNode fast = head;

        while (fast != null && fast.next != null) {
            slow = slow.next;
            fast = fast.next.next;
        }

        ListNode current = slow;
        ListNode prev = null;
        ListNode temp = null;

        while (current != null) {
            temp = current.next;
            current.next = prev;
            prev = current;
            current = temp;
        }

        ListNode left = head;
        ListNode right = prev;

        while (right != null) {
            if (right.val != left.val) {
                return false;
            }
            right = right.next;
            left = left.next;
        }

        return true;
    }
}
```
