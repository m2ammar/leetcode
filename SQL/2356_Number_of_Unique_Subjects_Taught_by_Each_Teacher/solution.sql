# Write your MySQL query statement below
Select teacher_id, COUNT(DISTINCT subject_id) AS cnt
From Teacher
group by teacher_id;
