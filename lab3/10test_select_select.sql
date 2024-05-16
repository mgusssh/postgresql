select tools.list_id, tools.name
from tools
where tools.list_id in(select list.id
			from list
			where list.type like 'Г%')