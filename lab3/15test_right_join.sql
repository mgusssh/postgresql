select tools.id, tools.name, bookings.tool_id, bookings.users_id
from tools
right join bookings on (tools.id = bookings.tool_id)