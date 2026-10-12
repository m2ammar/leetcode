# Write your MySQL query statement below
select ip, count(ip) as invalid_count
from logs
where cast(SUBSTRING_INDEX(SUBSTRING_INDEX(ip, '.', 1), '.', -1)  as unsigned) > 255 or 
      cast(SUBSTRING_INDEX(SUBSTRING_INDEX(ip, '.', 2), '.', -1)  as unsigned) > 255 or 
      cast(SUBSTRING_INDEX(SUBSTRING_INDEX(ip, '.', 3), '.', -1)  as unsigned) > 255 or 
      cast(SUBSTRING_INDEX(SUBSTRING_INDEX(ip, '.', 4), '.', -1)  as unsigned) > 255 or 
      LENGTH(ip) - LENGTH(REPLACE(ip, '.', '')) != 3 or 
      ip regexp '(^|\\.)0[0-9]' or
      ip NOT REGEXP '^([0-9]{1,3}\\.){3}[0-9]{1,3}$'
group by ip
order by invalid_count desc, ip desc;
