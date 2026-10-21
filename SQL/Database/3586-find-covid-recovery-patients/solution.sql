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
