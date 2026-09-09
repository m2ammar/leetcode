class Solution {
    public int maxArea(int[] height) {
        int area = 0;
        int left = 0;
        int right = height.length - 1;

        while (left < right) {
            int shorterHeight = (height[left] < height[right]) ? height[left] : height[right];
            int currentArea = shorterHeight * (right - left);

            if (area < currentArea) {
                area = currentArea;
            }

            if (height[left] < height[right]) {
                left++;
            } else {
                right--;
            }
        }
        return area;
    }
}
