insert into bookings
(id, users_id, tool_id, start_date, end_date, totale_price)
values (10, 3, 2, '2024-03-01', '2024-03-02', 
	   (select price from tools where id = 2))