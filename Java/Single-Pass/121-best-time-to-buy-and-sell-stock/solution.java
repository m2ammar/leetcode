class Solution {
    public int maxProfit(int[] prices) {
        int temp = prices[0];
        int sales = 0;

        for (int i = 0; i < prices.length; i++) {
            if (prices[i] <= temp) {
                temp = prices[i];
            }

            int todayProfit = prices[i] - temp;

            if (todayProfit > sales) {
                sales = todayProfit;
            }
        }
        return sales;
    }
}
