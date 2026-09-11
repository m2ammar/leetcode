# 121. Best Time to Buy and Sell Stock

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-Array-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** Array Traversal · Greedy · Single Pass

---

## ✅ Problem Summary
- Given an array `prices` where `prices[i]` is the stock price on day `i`
- Find the max profit from buying on one day and selling on a later day
- Return 0 if no profit is possible

## 🧠 Solution
```java
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
```

## 🧩 Breakdown

| Line | What it does |
|---|---|
| `temp = prices[0]` | Start by assuming the first day is the lowest price seen |
| `if (prices[i] <= temp)` | Update the lowest price whenever a new low is found |
| `todayProfit = prices[i] - temp` | Profit if we sold today, given the lowest price so far |
| `if (todayProfit > sales)` | Track the best profit seen across all days |

## 🤔 Why Single Pass (Greedy)?
Since you can only sell after you buy, the best possible profit on day `i` is always `price[i] - (lowest price before or on day i)`. By tracking the running minimum as you go, you never need to look backward or recompute — one pass through the array is enough.

| Day   | 0 | 1 | 2 | 3 | 4 | 5 |
|-------|---|---|---|---|---|---|
| Price | 7 | 1 | 5 | 3 | 6 | 4 |
| temp  | 7 | 1 | 1 | 1 | 1 | 1 |
| Profit| 0 | 0 | 4 | 2 | 5 | 3 |

Max profit (`sales`) = 5, found on Day 4 (buy at temp=1, sell at price=6)


## ⚠️ Why Not Brute Force (Nested Loops)?
A brute force approach checks every pair `(i, j)` with `j > i` — O(n²). It works but becomes too slow as `prices.length` grows toward the constraint limit (10⁵). The single-pass approach reduces this to O(n).

## ⏱️ Time Complexity
O(n) — one pass through the array, O(1) extra space.

## 🔑 Key Learnings
- Tracking a running minimum avoids needing nested loops
- The optimal decision at each step (sell today vs. keep holding) only depends on the lowest price seen so far, not future prices

## Final Query
```java
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
```
