// Randomized Quicksort — avoids O(n^2) worst case on sorted/adversarial input

class Solution {
    public int[] sortArray(int[] nums) {
        int high = nums.length - 1;
        int low = 0;
        sorting(nums, low, high);
        return nums;
    }

    public void sorting(int[] nums, int low, int high) {
        if (low < high) {
            int pi = partition(nums, low, high);
            sorting(nums, low, pi - 1);
            sorting(nums, pi + 1, high);
        }
    }

    public int partition(int[] nums, int low, int high) {
        // Randomize pivot choice so worst-case O(n^2) can't be triggered by input order
        int randomIndex = low + (int) (Math.random() * (high - low + 1));
        int temp = nums[randomIndex];
        nums[randomIndex] = nums[high];
        nums[high] = temp;

        int pivot = nums[high];
        int i = low - 1;

        for (int j = low; j < high; j++) {
            if (nums[j] < pivot) {
                i++;
                temp = nums[i];
                nums[i] = nums[j];
                nums[j] = temp;
            }
        }

        int temp2 = nums[i + 1];
        nums[i + 1] = nums[high];
        nums[high] = temp2;
        return i + 1;
    }
}
