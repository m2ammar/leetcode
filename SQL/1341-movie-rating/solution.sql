(select u.name as results
from Users as u
join MovieRating as mr
on u.user_id = mr.user_id
group by u.user_id 
order by count(mr.movie_id) desc, u.name asc 
limit 1)
Union All
(Select m.title as results
from Movies as m
join MovieRating as mr
on m.movie_id = mr.movie_id
where created_at Between '2020-02-01' AND '2020-02-29'
group by m.movie_id
order by avg(mr.rating) desc, m.title asc
limit 1);
