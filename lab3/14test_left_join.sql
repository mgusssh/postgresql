select tools.id, tools.name, bookings.tool_id, bookings.users_id
from tools 
left join bookings on tools.id = bookings.tool_id 