--   Создать и отладить следующие запросы:

-- Выборка данных из всех созданных представлений;

--  с вложенным запросом

CREATE OR REPLACE VIEW public.nestedqueryview
 AS
 SELECT name,
    ( SELECT count(*) AS count
           FROM bookings
          WHERE tools.id = bookings.tool_id) AS nested_count
   FROM tools;

ALTER TABLE public.nestedqueryview
    OWNER TO postgres;


SELECT * FROM nestedqueryview;

-- с группировкой

CREATE OR REPLACE VIEW public.groupbyview
AS
SELECT list.type, COUNT(tools.id) AS tool_count
FROM list
LEFT JOIN tools ON list.id = tools.list_id
GROUP BY list.type;

ALTER TABLE public.groupbyview
OWNER TO postgres;
	
SELECT * FROM groupbyview;

-- с соединением

CREATE OR REPLACE VIEW public.joinview
 AS
 SELECT tools.name,
    bookings.users_id
   FROM tools
     JOIN bookings ON tools.id = bookings.tool_id;

ALTER TABLE public.joinview
    OWNER TO postgres;


SELECT * FROM joinview;

-- с условием WHERE

CREATE OR REPLACE VIEW public.editableview AS
 SELECT id,
    list_id,
    name,
    price
   FROM tools
  WHERE list_id = 1;

ALTER TABLE public.editableview
    OWNER TO postgres;

SELECT * FROM editableview;

--   Вставка/обновление в изменяемом представлении данных таких, что новые данные попадают под условие WHERE;

INSERT INTO editableview( list_id, name, price)
VALUES (1, 'Бензиновая электростанция Hyundai', 1200);

update editableview 
set list_id = 1, name = 'Компрессор TOP'
where price = 1320;
	
-- Вставка/обновление в изменяемом представлении данных таких, что новые данные не попадают под условие WHERE.

INSERT INTO editableview( list_id, name, price)
VALUES (2, 'Бензиновая электростанция Hyundai', 1200);

update editableview 
set list_id = 1, name = 'Компрессор TOP'
where price = 1320;

-- Изменить представление так, чтобы вставка/обновление значений, не попадающих под условие WHERE, была запрещена.

CREATE OR REPLACE VIEW editableview AS
 SELECT 
    list_id,
    name,
    price
   FROM tools
  WHERE list_id = 1
WITH local CHECK OPTION;

--   Проверить запрос на вставку/обновление в измененном представлении.

INSERT INTO editableview  (list_id, name, price)
VALUES (2, 'Бензопила 243', 100);

UPDATE editableview  SET price = 220 WHERE name = 'Генератор бензиновый YAMAHA';


--   Создать и отладить:
-- Хранимую процедуру, выполняющую несколько инструкций с вводимым параметром


CREATE OR REPLACE PROCEDURE calculate_discounted_price(p_user_id int, p_tool_id int, p_totale_price numeric)
AS $$
DECLARE
    discount_param numeric;
BEGIN
    IF p_user_id = 2 THEN
        discount_param := 0.2; 
    ELSIF p_tool_id = 5 THEN
        discount_param := 0.15; 
    ELSE
        discount_param := 0.10; 
    END IF;

    UPDATE bookings
    SET totale_price = p_totale_price - (p_totale_price * discount_param)
    WHERE users_id = p_user_id AND tool_id = p_tool_id;
END;
$$ LANGUAGE plpgsql;


call calculate_discounted_price(3, 5, 500.00);


--   Создать и отладить функции посредством вызова для отношения.

CREATE FUNCTION get_total_revenue(equipment_type text, start_date_param date, end_date_param date)
RETURNS numeric
AS
$$
BEGIN
    RETURN (
        SELECT SUM(b.totale_price)
        FROM bookings b
        JOIN tools t ON b.tool_id = t.id
        WHERE t.name = equipment_type
        AND b.start_date >= start_date_param AND b.end_date <= end_date_param
    );
END;
$$
LANGUAGE plpgsql;

SELECT * FROM get_total_revenue('Дрель-шуруповерт Plush Bosch Professional', '2024-06-05', '2024-06-20');

--   Создать триггеры на каждое событие к определенным отношениям в зависимости от логики заполнения, обновления и удаления данных. 
-- Рассмотреть возможность и реализацию вызова процедур в триггере.
-- Insert

CREATE OR REPLACE FUNCTION public."Insert_Booking"()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
BEGIN
    IF EXISTS (SELECT 1 FROM "bookings" 
           WHERE "tool_id" = NEW."tool_id" AND 
                 ((NEW."start_date" >= "start_date" AND NEW."start_date" <= "end_date") 
			  OR 
                 (NEW."start_date" <= "start_date" AND NEW."end_date" >= "start_date") 
                OR 
                 (NEW."start_date" <= "end_date" AND NEW."end_date" >= "end_date"))) THEN
           RAISE EXCEPTION 'Инструмент занят';
	 			ELSIF NEW."start_date" > NEW."end_date" THEN
           RAISE EXCEPTION 'Дата начала должна быть меньше даты конца';
	 	
    	END IF;
	RETURN NEW;
END;
$BODY$;

CREATE OR REPLACE TRIGGER "Insert_BookingT"
BEFORE INSERT on "bookings"
FOR EACH ROW EXECUTE FUNCTION "Insert_Booking"() ;


-- Update

CREATE OR REPLACE FUNCTION public."Update_Booking"()
    RETURNS trigger AS $$
DECLARE
  days_diff INTEGER;
BEGIN
  	days_diff = (NEW."end_date" - NEW."start_date");
  	NEW."totale_price" = (SELECT "price" FROM "tools" WHERE "id" = NEW."tool_id") * (days_diff + 1);
  	UPDATE "bookings" 
 	SET "totale_price" = NEW."totale_price" 
  	WHERE "id" = NEW."id";
	
  RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE TRIGGER "Update_BookingT"
after INSERT on "bookings"
FOR EACH ROW EXECUTE FUNCTION "Update_Booking"();

