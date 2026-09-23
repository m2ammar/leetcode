select id, 
    Case 
        when p_id is null then 'Root' 
        when p_id is not null and exists (
                select 1 from Tree as t where t.p_id = Tree.id
            ) then 'Inner'
        else 'Leaf' 
    end as type
from Tree;
