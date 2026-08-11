class Solution:
    def mergeAlternately(self, word1: str, word2: str) -> str:
        merge = []
        for a, b in zip(word1, word2):
            merge.append(a)
            merge.append(b)

        merge.append(word1[len(word2):])
        merge.append(word2[len(word1):])

        return "".join(merge)
