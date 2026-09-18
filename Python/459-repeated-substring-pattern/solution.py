class Solution:
    def repeatedSubstringPattern(self, s: str) -> bool:
        n = len(s)

        for k in range(1, n):
            if n % k == 0:
                substring = s[0:k]
                repeated = substring * (n // k)
                if repeated == s:
                    return True
        return False
