import java.util.HashMap;

class Solution {
    public int[] twoSum(int[] nums, int target) {
        HashMap<Integer, Integer> map = new HashMap<>(); // number -> index
        int[] arr = new int[2];

        for (int i = 0; i < nums.length; i++) {
            int temp = target - nums[i]; // the value we need to find

            // check earlier elements first
            if (map.containsKey(temp)) {
                arr[0] = map.get(temp); // earlier index
                arr[1] = i;             // current index
                return arr;
            }

            // then remember the current element for later ones
            map.put(nums[i], i);
        }

        return arr; // never reached: a solution is guaranteed
    }
}
