select tools.name, count(bookings.tool_id) 
from tools
join bookings on tools.id = bookings.tool_id
group by tools.name
