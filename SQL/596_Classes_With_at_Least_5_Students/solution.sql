SELECT class
From Courses
Group by class
Having COUNT(*) >= 5;
