# 3586. Find COVID Recovery Patients

![Difficulty](https://img.shields.io/badge/Difficulty-Medium-orange)
![Topic](https://img.shields.io/badge/Topic-SQL-blue)
![Status](https://img.shields.io/badge/Status-Accepted-success)

**Concepts:** CTE · CASE · Conditional Aggregation · MIN() · JOIN · DATEDIFF() · GROUP BY · ORDER BY

---

## ✅ Problem Summary

- Find patients who tested **Positive** and later tested **Negative**.
- Identify the first Positive test date for each patient.
- Find the first Negative test date strictly after the first Positive test.
- Calculate recovery time as the difference between these two dates.
- Ignore Inconclusive tests and Negative tests that occurred before the first Positive test.
- Return `patient_id`, `patient_name`, `age`, and `recovery_time`.
- Sort by `recovery_time` ascending, then by `patient_name` ascending.

---

## 🧠 Solution

```sql
WITH first_positive AS (
    SELECT patient_id,
           MIN(CASE WHEN result = 'Positive' THEN test_date ELSE NULL END) AS positive
    FROM covid_tests
    GROUP BY patient_id
),

neg_after AS (
    SELECT f.patient_id,
           p.patient_name,
           p.age,
           MIN(c.test_date) AS inital_date,
           f.positive
    FROM first_positive AS f
    JOIN covid_tests AS c
        ON f.patient_id = c.patient_id
    JOIN patients AS p
        ON p.patient_id = c.patient_id
    WHERE c.result = 'Negative'
      AND c.test_date > f.positive
    GROUP BY f.patient_id, p.patient_name, p.age, f.positive
)

SELECT patient_id,
       patient_name,
       age,
       DATEDIFF(inital_date, positive) AS recovery_time
FROM neg_after
ORDER BY recovery_time ASC, patient_name ASC;
```

---

## 🧩 Breakdown

| Clause | What it does |
|---|---|
| `MIN(CASE WHEN result = 'Positive' THEN test_date ELSE NULL END)` | Considers only Positive test dates and finds the earliest one. `MIN()` ignores `NULL`. |
| `GROUP BY patient_id` | Produces one first-positive date per patient. |
| `JOIN covid_tests AS c` | Checks the patient's test records for a later Negative test. |
| `JOIN patients AS p` | Retrieves the patient's name and age. |
| `c.result = 'Negative'` | Keeps only Negative tests; Inconclusive tests are ignored. |
| `c.test_date > f.positive` | Ensures the Negative test occurred strictly after the first Positive test. |
| `MIN(c.test_date)` | Finds the earliest qualifying Negative test date. |
| `DATEDIFF(inital_date, positive)` | Calculates the number of days between the Negative and Positive test dates. |
| `ORDER BY recovery_time ASC, patient_name ASC` | Sorts by recovery duration, then alphabetically by patient name. |

---

## 🤔 Why Use CASE Inside MIN()?

The first CTE needs the earliest date **only among Positive tests**.

`CASE` returns the test date for Positive results and `NULL` for every other result. Since `MIN()` ignores `NULL`, it finds the earliest Positive date.

Example:

| result | test_date | Value passed to `MIN()` |
|---|---|---|
| Negative | 2023-01-20 | `NULL` |
| Positive | 2023-02-10 | `2023-02-10` |
| Negative | 2023-02-20 | `NULL` |

The minimum non-`NULL` date is `2023-02-10`.

---

## 🔍 Example Walkthrough

| Patient | First Positive | First Negative After Positive | Recovery Time |
|---|---|---|---:|
| Alice Smith | 2023-01-15 | 2023-01-25 | 10 |
| Carol Davis | 2023-02-10 | 2023-02-20 | 10 |
| Bob Johnson | 2023-02-01 | 2023-02-12 | 11 |

- **Alice:** Positive on January 15, then Negative on January 25 → 10 days.
- **Carol:** Her January 20 Negative test occurred before her Positive test, so it doesn't count. Recovery time is 10 days.
- **Bob:** The Inconclusive test is ignored. His first qualifying Negative test is February 12 → 11 days.
- **David:** Excluded because he has no Negative test after a Positive test.
- **Emma:** Excluded because she never tested Positive.

---

## ⚠️ Common Mistakes

**Mistake 1: Taking the first Negative test without checking its date**

A Negative test before the Positive test does not count as recovery.

Fix: require `c.test_date > f.positive`.

**Mistake 2: Using `MIN(result)` to find a Positive test**

`MIN(result)` compares result text values; it doesn't find the earliest Positive date.

Fix: use conditional aggregation:

```sql
MIN(CASE WHEN result = 'Positive' THEN test_date END)
```

**Mistake 3: Putting MIN() outside the conditional logic incorrectly**

Using `CASE WHEN result = 'Positive' THEN MIN(test_date) END` does not correctly calculate the minimum Positive date for each patient.

Fix: put the `CASE` expression inside `MIN()`.

**Mistake 4: Grouping by the Negative test date**

Grouping by `c.test_date` creates a separate group for each Negative date, preventing `MIN()` from selecting the earliest date across all qualifying tests.

Fix: group by patient information and the first Positive date.

**Mistake 5: Forgetting the output alias**

The calculated column must be named `recovery_time`.

Fix: `DATEDIFF(inital_date, positive) AS recovery_time`.

---

## ⏱️ Time Complexity

Let \(n\) be the number of rows in `covid_tests`.

The exact execution cost depends on the database query plan and available indexes. Conceptually, the query aggregates test dates and joins test records; sorting the \(r\) recovered patients adds approximately \(O(r \log r)\) sorting work.

---

## 🔑 Key Learnings

- Conditional aggregation lets `MIN()` consider only rows satisfying a condition.
- CTEs divide a complex SQL problem into readable steps.
- Date conditions matter when the order of events determines eligibility.
- `MIN()` combined with `WHERE` finds the earliest Negative test after a known Positive date.
- `DATEDIFF(later_date, earlier_date)` returns the number of days between dates in MySQL.
- Group at the correct level: one row per patient, not one row per test date.
- A patient is considered recovered only when a Negative test occurs after a Positive test.

---

## Final Query

```sql
WITH first_positive AS (
    SELECT patient_id,
           MIN(CASE WHEN result = 'Positive' THEN test_date ELSE NULL END) AS positive
    FROM covid_tests
    GROUP BY patient_id
),

neg_after AS (
    SELECT f.patient_id,
           p.patient_name,
           p.age,
           MIN(c.test_date) AS inital_date,
           f.positive
    FROM first_positive AS f
    JOIN covid_tests AS c
        ON f.patient_id = c.patient_id
    JOIN patients AS p
        ON p.patient_id = c.patient_id
    WHERE c.result = 'Negative'
      AND c.test_date > f.positive
    GROUP BY f.patient_id, p.patient_name, p.age, f.positive
)

SELECT patient_id,
       patient_name,
       age,
       DATEDIFF(inital_date, positive) AS recovery_time
FROM neg_after
ORDER BY recovery_time ASC, patient_name ASC;
```
