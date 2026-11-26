/**
 * Definition for singly-linked list.
 * public class ListNode {
 *     int val;
 *     ListNode next;
 *     ListNode() {}
 *     ListNode(int val) { this.val = val; }
 *     ListNode(int val, ListNode next) { this.val = val; this.next = next; }
 * }
 */
class Solution {
    public boolean isPalindrome(ListNode head) {

        // 1. Find the middle (slow ends at the middle, or the start of the second half)
        ListNode slow = head;
        ListNode fast = head;

        while (fast != null && fast.next != null) {
            slow = slow.next;
            fast = fast.next.next;
        }

        // 2. Reverse the second half
        ListNode current = slow;
        ListNode prev = null;
        ListNode temp = null;

        while (current != null) {
            temp = current.next;
            current.next = prev;
            prev = current;
            current = temp;
        }

        // 3. Compare both halves
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
