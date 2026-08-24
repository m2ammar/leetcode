class Solution {
    public int heightChecker(int[] heights) {
        
        int[] expected = new int[heights.length];
        int counter = 0;
        int minIndex = 0;

        for (int i = 0; i < heights.length; i++) {
            expected[i] = heights[i];
        }

        for (int i = 0; i < expected.length; i++) {
            minIndex = i;

            for (int j = (i + 1); j < expected.length; j++) {
                if (expected[minIndex] > expected[j]) {
                    minIndex = j;
                }
            }
            int temp = expected[minIndex];
            expected[minIndex] = expected[i];
            expected[i] = temp;
        }

        for (int i = 0; i < heights.length; i++) {
            if (heights[i] != expected[i]) {
                counter++;
            }
        }
        return counter;
    }
}
