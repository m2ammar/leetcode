class Solution {
    public int[] searchRange(int[] nums, int target) {
        int left = 0;
        int right = nums.length - 1;
        int[] temp = new int[2];

        // Search 1: find leftmost occurrence
        while (left < right) {
            int mid = (left + right) / 2;
            if (nums[mid] >= target) {
                right = mid;
            } else {
                left = mid + 1;
            }
        }
        if (left < nums.length && nums[left] == target) {
            temp[0] = left;
        } else {
            temp[0] = -1;
        }

        // Search 2: find rightmost occurrence
        left = 0;
        right = nums.length - 1;
        while (left < right) {
            int mid = (left + right + 1) / 2;
            if (nums[mid] <= target) {
                left = mid;
            } else {
                right = mid - 1;
            }
        }
        if (left < nums.length && nums[left] == target) {
            temp[1] = left;
        } else {
            temp[1] = -1;
        }

        return temp;
    }
}
