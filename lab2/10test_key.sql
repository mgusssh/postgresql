select list.type, tools.name, users.first_name, users.last_name, users.number, bookings.totale_price, bookings.start_date
from list, tools, users, bookings 
where users.id = bookings.users_id and tools.id = bookings.tool_id and list.id = tools.list_id