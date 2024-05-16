select type as catalog, 'catalog' as name
from list
union
select name as catalog, 'tools' as name
from tools