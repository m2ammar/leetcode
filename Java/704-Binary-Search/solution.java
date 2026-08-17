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
