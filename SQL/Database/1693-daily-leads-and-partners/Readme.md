# 1693. Daily Leads and Partners

![Difficulty](https://img.shields.io/badge/Difficulty-Easy-brightgreen)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** `GROUP BY` · `COUNT(DISTINCT)` · Aggregation · Multi-column grouping

---

## ✅ Problem Summary

For the `DailySales` table, return one row for every `date_id` and `make_name` pair with:

- ✅ `unique_leads`: the number of **distinct** `lead_id` values
- ✅ `unique_partners`: the number of **distinct** `partner_id` values
- ✅ Rows can be returned in **any order**
- ⚠️ The table has **no primary key**, so duplicate rows are possible

---

## 💡 Solution

```sql
# Write your MySQL query statement below
select date_id, make_name, count( distinct lead_id) as unique_leads, 
    count(distinct partner_id) as unique_partners
from DailySales
group  by date_id, make_name;
```

---

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `FROM DailySales` | Reads every sale row |
| `GROUP BY date_id, make_name` | Puts rows with the same date **and** the same make into one group |
| `COUNT(DISTINCT lead_id)` | Counts each lead once per group, even if it appears many times |
| `COUNT(DISTINCT partner_id)` | Counts each partner once per group |
| `AS unique_leads / unique_partners` | Names the output columns exactly as the problem asks |

---

## 🤔 Why `GROUP BY` + `COUNT(DISTINCT)`?

The answer is one row per **(date, make)** pair, so both columns go in `GROUP BY`. Inside each group, the same lead or partner can show up in several rows, so a plain count would count rows and not people.

```
DailySales rows           GROUP BY (date_id, make_name)       Output row
-----------------         ---------------------------         -------------------------
2020-12-8 toyota 0 1  \
2020-12-8 toyota 1 0   |-->  group: (2020-12-8, toyota)  -->  leads = {0,1}   -> 2
2020-12-8 toyota 1 2  /                                       partners = {0,1,2} -> 3
```

Sample result:

| date_id | make_name | unique_leads | unique_partners |
|---|---|---|---|
| 2020-12-07 | honda | 3 | 2 |
| 2020-12-07 | toyota | 1 | 2 |
| 2020-12-08 | honda | 2 | 2 |
| 2020-12-08 | toyota | 2 | 3 |

---

## 🧠 Why not a subquery with `SELECT DISTINCT`?

You could first remove duplicates in a subquery and then count, but you would need **two** separate de-duplications (one for leads, one for partners) and then join them back. `COUNT(DISTINCT col)` does both in a single pass over one table, so it is shorter and easier to read.

---

## ⚠️ Common Mistakes

**1. Using `COUNT` without `DISTINCT`**

```sql
select date_id, make_name, count(lead_id) as unique_leads
from DailySales
group by date_id, make_name;
```

For (2020-12-8, toyota) this returns **3** (it counts rows), but the correct answer is **2**, because lead `1` appears twice.

✅ Fix: `count(distinct lead_id)`

**2. Forgetting `make_name` in `GROUP BY`**

Grouping only by `date_id` merges toyota and honda into one row per day. The output needs one row for each make.

✅ Fix: `group by date_id, make_name`

---

## ⏱️ Time Complexity

About **O(n)** with hash-based grouping, or **O(n log n)** if the engine sorts to group and de-duplicate, where `n` is the number of rows in `DailySales`.

---

## 🔑 Key Learnings

- `COUNT(col)` counts rows, `COUNT(DISTINCT col)` counts unique values
- Every non-aggregated column in `SELECT` must appear in `GROUP BY`
- Grouping by two columns makes one group per unique **pair**
- A table with no primary key can hold duplicates, so check whether the question wants distinct values
- Row order doesn't matter when the problem says "any order"

---

## 🏁 Final Query

```sql
select date_id, make_name, count( distinct lead_id) as unique_leads, 
    count(distinct partner_id) as unique_partners
from DailySales
group  by date_id, make_name;
```
