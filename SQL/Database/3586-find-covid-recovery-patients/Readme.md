3586. Find COVID Recovery Patients



Concepts: CTE · Conditional Aggregation · MIN() · JOIN · DATEDIFF() · GROUP BY · ORDER BY
✅ Problem Summary
- Find patients who tested Positive and later tested Negative.
- Use the patient's first Positive test date as the recovery starting point.
- Find the first Negative test date strictly after that Positive test.
- Calculate recovery_time as the difference in days between those two dates.
- Ignore Inconclusive tests and Negative tests that occurred before the first Positive test.
- Return patient_id, patient_name, age, and recovery_time.
- Sort by recovery_time ascending, then patient_name ascending.
🧠 Solution
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
🧩 Breakdown
Clause	What it does
MIN(CASE WHEN result = 'Positive' THEN test_date ELSE NULL END)	Keeps Positive test dates and returns the earliest one; MIN() ignores NULL.
GROUP BY patient_id	Produces one first-positive date per patient.
JOIN covid_tests AS c	Looks at that patient's test records to find a later Negative test.
c.result = 'Negative'	Keeps only Negative tests; Inconclusive results are ignored.
c.test_date > f.positive	Ensures the Negative test happened strictly after the first Positive test.
MIN(c.test_date)	Selects the earliest qualifying Negative test date.
DATEDIFF(inital_date, positive)	Calculates the number of days between the qualifying Negative date and first Positive date.
ORDER BY recovery_time ASC, patient_name ASC	Sorts by recovery duration, then alphabetically by patient name.


🤔 Why Use CASE Inside MIN()?
The first CTE needs the earliest date only among Positive tests. CASE returns the test date for Positive results and NULL for all other results. Since MIN() ignores NULL, it finds the earliest Positive date without removing other rows before aggregation.

Conceptually:
result	test_date	Value passed to MIN()
Negative	2023-01-20	NULL
Positive	2023-02-10	2023-02-10
Negative	2023-02-20	NULL


The minimum non-NULL value is 2023-02-10.
🔍 Example Walkthrough
Patient	First Positive	First Negative after Positive	Recovery time
Alice Smith	2023-01-15	2023-01-25	10
Carol Davis	2023-02-10	2023-02-20	10
Bob Johnson	2023-02-01	2023-02-12	11


- Alice: Positive on January 15, then Negative on January 25 → 10 days.
- Carol: The Negative test on January 20 occurred before her Positive test, so it does not count. Her recovery time is 10 days.
- Bob: The Inconclusive test is ignored; the first qualifying Negative test is February 12 → 11 days.
- David: Excluded because there is no Negative test after a Positive test.
- Emma: Excluded because she never tested Positive.
⚠️ Common Mistakes
Mistake 1: Taking the first Negative test without checking its date

A Negative test before the Positive test does not count as recovery.

Fix: require c.test_date > f.positive.

Mistake 2: Using MIN(result) to find a Positive test

MIN(result) compares result text values; it does not find the earliest Positive date.

Fix: use conditional aggregation with MIN(CASE WHEN result = 'Positive' THEN test_date END).

Mistake 3: Grouping by the Negative test date

Grouping by c.test_date creates a separate group for each Negative date, so MIN() cannot select the earliest date across all qualifying tests.

Fix: group by patient information and the first Positive date, not each Negative test date.

Mistake 4: Forgetting the output alias

The calculated column must be named recovery_time to match the requested result format.

Fix: DATEDIFF(inital_date, positive) AS recovery_time.
⏱️ Time Complexity
Let \(n\) be the number of rows in covid_tests. The exact execution cost depends on the database's query plan and indexes. Conceptually, the query aggregates test dates and joins the test records; sorting the recovered patients adds a sorting cost of approximately \(O(r \log r)\), where \(r\) is the number of patients returned.
🔑 Key Learnings
- Conditional aggregation lets MIN() consider only rows that satisfy a condition.
- CTEs help break a multi-step SQL problem into readable stages.
- A date condition is essential when the order of events matters.
- MIN() can find the earliest Negative test after a known Positive date when combined with a filter.
- DATEDIFF(later_date, earlier_date) returns the number of days between dates in MySQL.
- Group at the intended level: one row per patient, not one row per test date.
Final Query
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
