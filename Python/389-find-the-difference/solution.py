from collections import Counter

class Solution:
    def findTheDifference(self, s: str, t: str) -> str:
        c1 = Counter(s)
        c2 = Counter(t)
        c3 = c2 - c1
        c4 = next(iter(c3.keys()))
        return c4
