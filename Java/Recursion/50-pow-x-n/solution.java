class Solution {
    public double myPow(double x, int n) {
        return helper(x, (long) n);
    }

    private double helper(double x, long n) {

        if (n < 0) {
            return helper(1 / x, -n);
        }
        if (n == 0) {
            return 1;
        }

        double half = helper(x, n / 2);

        if (n % 2 == 0) {
            half = half * half;
            return half;
        } else {
            half = half * half * x;
            return half;
        }
    }
}
