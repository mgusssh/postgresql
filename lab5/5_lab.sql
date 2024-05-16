-- 1

SELECT rolname
FROM pg_roles;

-- 2 

GRANT SELECT ON TABLE 
public.bookings TO reader_role;

GRANT INSERT ON TABLE 
public.bookings TO insert_role;

GRANT UPDATE ON TABLE 
public.bookings TO update_role;

CREATE ROLE delete_role;

GRANT DELETE ON TABLE 
public.bookings TO delete_role;

-- 3 

CREATE USER connect_role WITH PASSWORD '11111';
GRANT CONNECT ON DATABASE rental_inventory TO connect_role;
ALTER USER connect_role CREATEDB;
GRANT ALL PRIVILEGES ON DATABASE rental_inventory TO connect_role;

SET ROLE connect_role;
CREATE DATABASE test;
RESET ROLE;

SET ROLE connect_role;
drop database test;
RESET ROLE;

-- 4

ALTER USER connect_role WITH PASSWORD '22222';
ALTER USER connect_role VALID UNTIL '2024-05-15';

-- 5

create role Admin superuser;

-- 6

SET ROLE admin;
CREATE USER "user";
GRANT reader_role TO "user";
REVOKE "reader_role" FROM "user";

GRANT SELECT (users_id, tool_id, start_date, end_date, totale_price) ON "bookings" TO "user";

SET ROLE "user";
SELECT *
FROM "bookings";
RESET ROLE;

-- 7

REVOKE SELECT (id) ON public."bookings" FROM "user";

SET ROLE "user";
SELECT id
FROM "bookings";
RESET ROLE;

-- 8 
SET ROLE Manager_1;
CREATE USER Manager_1;
GRANT reader_role TO Manager_1;
GRANT update_role TO Manager_1;
DELETE FROM public.bookings WHERE ID=9
 

-- 9

REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM manager_1;
DROP USER manager_1;

-- 10

CREATE GROUP managers;
GRANT reader_role TO managers;
GRANT update_role TO managers;
GRANT insert_role TO managers;


-- 11

CREATE USER manager;
GRANT managers TO manager;

-- 12

CREATE USER user_test;
GRANT reader_role TO user_test;
GRANT update_role TO user_test;
GRANT insert_role TO user_test;

