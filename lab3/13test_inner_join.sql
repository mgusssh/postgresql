select tools.id, tools.name, bookings.tool_id, bookings.users_id
from tools
inner join bookings on tools.id = bookings.tool_id