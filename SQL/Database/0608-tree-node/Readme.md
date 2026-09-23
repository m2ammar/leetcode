# 608. Tree Node

![Difficulty](https://img.shields.io/badge/Difficulty-Medium-orange)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** CASE · Correlated Subquery · EXISTS · Self-Reference

---

## ✅ Problem Summary
- Classify every node in a `Tree` table (`id`, `p_id`) as one of:
  - **Root** — no parent (`p_id IS NULL`)
  - **Leaf** — has a parent, but no children
  - **Inner** — has a parent AND has children
- Return every row labeled — no filtering.

---

## 🧠 Solution
```sql
select id, 
    Case 
        when p_id is null then 'Root' 
        when p_id is not null and exists (
                select 1 from Tree as t where t.p_id = Tree.id
            ) then 'Inner'
        else 'Leaf' 
    end as type
from Tree;
```

---

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `when p_id is null then 'Root'` | No parent → this is the root of the tree |
| `when p_id is not null and exists (...)` | Has a parent AND is referenced as someone else's `p_id` → has children |
| `select 1 from Tree as t where t.p_id = Tree.id` | Correlated subquery: checks if any row `t` has this outer row's `id` as its `p_id` |
| `else 'Leaf'` | Has a parent, but nothing points to it as a parent → no children |

---

## 🤔 Why Correlated Subquery?
Both tables involved are actually the **same table**, referenced twice — once as the outer row being classified (`Tree`), and once as an inner scan (`t`) checking every other row's `p_id`.

```
Outer row (Tree) Inner scan (t)
id = 2 <----match---- t.p_id = 2 (row: id=4, p_id=2)
<----match---- t.p_id = 2 (row: id=5, p_id=2)
```

If id `2` shows up as `p_id` anywhere in `t`, it means `2` has children — so it's `Inner`.

Sample result:
| id | type  |
|----|-------|
| 1  | Root  |
| 2  | Inner |
| 3  | Leaf  |

## 🤔 Why not a Self Join?
A self join (`Tree JOIN Tree t ON t.p_id = Tree.id`) would work for detecting children, but it produces **one row per matching child** — a node with 2 children shows up twice, requiring `DISTINCT` or `GROUP BY` cleanup afterward. `EXISTS` short-circuits on the first match and always returns a single true/false per row, so no duplicate handling is needed.

---

## ⚠️ Common Mistakes

**Mistake 1: Comparing a row's own id/p_id to itself**
```sql
when id = p_id then 'Inner'  -- ❌ wrong: a node is never its own parent
```
Fix: compare against a *separate* aliased copy of the table (`t.p_id = Tree.id`), not the same row's own columns.

**Mistake 2: Using WHERE to filter**
```sql
where exists (...)  -- ❌ wrong: filters rows out, but every node must be labeled
```
Fix: the child-check belongs inside the `CASE`/`EXISTS`, not in `WHERE` — every row stays, just labeled differently.

---

## ⏱️ Time Complexity
O(n²) in the worst case — for each of the n rows, the correlated subquery scans up to n rows looking for a match. Fine for LeetCode's dataset sizes.

---

## 🔑 Key Learnings
- Self-referencing tables (parent/child, org charts) are classified by checking if a row's `id` appears in another row's foreign-key-style column (`p_id`).
- `EXISTS` is the cleaner tool over self-join when you only need a true/false per row, not a full match set.
- `CASE` order matters — more specific conditions (`Inner`, which requires both a parent AND a child) must be checked before falling through to a catch-all `else` (`Leaf`).

---

## Final Query
```sql
select id, 
    Case 
        when p_id is null then 'Root' 
        when p_id is not null and exists (
                select 1 from Tree as t where t.p_id = Tree.id
            ) then 'Inner'
        else 'Leaf' 
    end as type
from Tree;
```
