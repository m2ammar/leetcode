class Solution {
    public int[] twoSum(int[] numbers, int target) {
        int left = 0;
        int right = numbers.length - 1;
        int[] temp = new int[2];

        while (left < right) {

            if (numbers[left] + numbers[right] == target) {
                temp[0] = left + 1;
                temp[1] = right + 1;
                break;
            } else if (numbers[left] + numbers[right] < target) {
                left += 1;
            } else if (numbers[left] + numbers[right] > target) {
                right -= 1;
            }
        }
        return temp;
    }
}
