class Solution:
    def strStr(self, haystack: str, needle: str) -> int:
        m = len(needle)
        n = len(haystack) - len(needle)

        for i in range(0, n + 1):
            for j in range(m):
                if needle[j] != haystack[j + i]:
                    break
            else:
                return i
        return -1


# First attempt (passed, but relies on a built-in instead of manual logic):
# class Solution:
#     def strStr(self, haystack: str, needle: str) -> int:
#         return haystack.find(needle)
