select tools.id, tools.name, bookings.tool_id, bookings.users_id
from tools
full outer join bookings on tools.id = bookings.tool_id
where tools.id is null or bookings.tool_id is null