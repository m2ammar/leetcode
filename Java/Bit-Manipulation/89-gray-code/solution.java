import java.util.*;

class Solution {
    public List<Integer> grayCode(int n) {
        List<Integer> list = new ArrayList<>();

        // 1 << n = 2^n, the number of values in an n-bit Gray code sequence
        for (int i = 0; i < (1 << n); i++) {
            // Gray code of i = i XOR (i shifted right by 1)
            int temp = i ^ (i >> 1);
            list.add(temp);
        }

        return list;
    }
}
