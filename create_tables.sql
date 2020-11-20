--создаем схему
CREATE SCHEMA dim;
CREATE SCHEMA fact;
CREATE SCHEMA rejected;

--создаем таблицу дат
DROP TABLE IF EXISTS dim.calendar;
CREATE TABLE dim.calendar
AS
WITH dates AS (
    SELECT dd::date AS dt
    FROM generate_series
            ('2010-01-01'::timestamp
            , '2030-01-01'::timestamp
            , '1 day'::interval) dd
)
SELECT
    to_char(dt, 'YYYYMMDD')::int AS id,
    dt AS date,
    to_char(dt, 'YYYY-MM-DD') AS ansi_date,
    date_part('isodow', dt)::int AS day,
    date_part('week', dt)::int AS week_number,
    date_part('month', dt)::int AS month,
    date_part('isoyear', dt)::int AS year,
    (date_part('isodow', dt)::smallint BETWEEN 1 AND 5)::int AS week_day,
    (to_char(dt, 'YYYYMMDD')::int IN (
        20130101,
        20130102,
        20130103,
        20130104,
        20130105,
        20130106,
        20130107,
        20130108,
        20130223,
        20130308,
        20130310,
        20130501,
        20130502,
        20130503,
        20130509,
        20130510,
        20130612,
        20131104,
        20140101,
        20140102,
        20140103,
        20140104,
        20140105,
        20140106,
        20140107,
        20140108,
        20140223,
        20140308,
        20140310,
        20140501,
        20140502,
        20140509,
        20140612,
        20140613,
        20141103,
        20141104,
        20150101,
        20150102,
        20150103,
        20150104,
        20150105,
        20150106,
        20150107,
        20150108,
        20150109,
        20150223,
        20150308,
        20150309,
        20150501,
        20150504,
        20150509,
        20150511,
        20150612,
        20151104,
        20160101,
        20160102,
        20160103,
        20160104,
        20160105,
        20160106,
        20160107,
        20160108,
        20160222,
        20160223,
        20160307,
        20160308,
        20160501,
        20160502,
        20160503,
        20160509,
        20160612,
        20160613,
        20161104,
        20170101,
        20170102,
        20170103,
        20170104,
        20170105,
        20170106,
        20170107,
        20170108,
        20170223,
        20170224,
        20170308,
        20170501,
        20170508,
        20170509,
        20170612,
        20171104,
        20171106,
        20180101,
        20180102,
        20180103,
        20180104,
        20180105,
        20180106,
        20180107,
        20180108,
        20180223,
        20180308,
        20180309,
        20180430,
        20180501,
        20180502,
        20180509,
        20180611,
        20180612,
        20181104,
        20181105,
        20181231,
        20190101,
        20190102,
        20190103,
        20190104,
        20190105,
        20190106,
        20190107,
        20190108,
        20190223,
        20190308,
        20190501,
        20190502,
        20190503,
        20190509,
        20190510,
        20190612,
        20191104,
        20200101, 20200102, 20200103, 20200106, 20200107, 20200108,
       20200224, 20200309, 20200501, 20200504, 20200505, 20200511,
       20200612, 20201104))::int AS holiday
FROM dates
ORDER BY dt;

ALTER TABLE dim.calendar ADD PRIMARY KEY (id);

--создаем таблицу совершенных перелетов
DROP TABLE IF EXISTS fact.flights;
CREATE TABLE fact.flights (
    passenger_id varchar NOT NULL,
	departure_time timestamptz NOT NULL,
	arrival_time timestamptz NOT NULL,
	departure_delay bigint NOT NULL,
	arrival_delay bigint NOT NULL,
	aircraft_id char(3) NOT NULL,
	departure_airport_id char(3) NOT NULL,
	arrival_airport_id char(3) NOT NULL,
	conditions_id integer NOT NULL,
	amount numeric(10,2) NOT NULL

);

--справочник пассажиров
DROP TABLE IF EXISTS dim.passengers;
CREATE TABLE dim.passengers (
	id integer NOT NULL PRIMARY KEY,
    passenger_id varchar NOT NULL,
    firstname varchar NOT NULL,
    lastname varchar NOT NULL,
    contacts varchar NOT NULL
);

--справочник самолетов
DROP TABLE IF EXISTS dim.aircrafts;
CREATE TABLE dim.aircrafts (
	aircraft_id integer NOT NULL PRIMARY KEY,
    aircraft_code char(3) NOT NULL,
    model varchar NOT NULL,
    RANGE integer NOT null
);

--справочник аэропортов
DROP TABLE IF EXISTS dim.airports;
CREATE TABLE dim.airports (
	airport_id integer NOT NULL PRIMARY KEY,
    airport_code char(3) NOT NULL,
    airport_name varchar NOT NULL,
    city varchar NOT NULL,
    longitude float NOT NULL,
    latitude float NOT NULL,
    timezone varchar NOT NULL
);

--справочник тарифов
DROP TABLE IF EXISTS dim.tariff;
CREATE TABLE dim.tariff (
	conditions_id integer NOT NULL PRIMARY key,
    fare_conditions varchar NOT NULL
);

--создаем таблицу ошибок совершенных перелетов
DROP TABLE IF EXISTS rejected.flights;
CREATE TABLE rejected.flights (
	flight_id varchar,
	flight_no varchar,
	scheduled_departure varchar,
	scheduled_arrival varchar,
    passenger_id varchar,
	departure_time varchar,
	arrival_time varchar,
	ticket_no varchar,
	departure_delay varchar,
	arrival_delay varchar,
	aircraft_code varchar,
	departure_airport varchar,
	arrival_airport varchar,
	fare_conditions varchar,
	amount varchar,
	error_type varchar
);

--ошибки в справочнике пассажиров
DROP TABLE IF EXISTS rejected.passengers;
CREATE TABLE rejected.passengers (
	ticket_no varchar,
	book_ref varchar,
    passenger_id varchar,
    firstname varchar,
    lastname varchar,
    contacts varchar,
	error_type varchar
);

--ошибки справочника самолетов
DROP TABLE IF EXISTS rejected.aircrafts;
CREATE TABLE rejected.aircrafts (
    aircraft_code varchar,
    model varchar,
    RANGE varchar,
	error_type varchar
);

--ошибка справочника аэропортов
DROP TABLE IF EXISTS rejected.airports;
CREATE TABLE rejected.airports (
    airport_code varchar,
    airport_name varchar,
    city varchar,
    longitude varchar,
    latitude varchar,
    timezone varchar,
	error_type varchar
);

--ошибка справочника тарифов
DROP TABLE IF EXISTS rejected.tariff;
CREATE TABLE rejected.tariff (
	ticket_no varchar,
	flight_id varchar,
    fare_conditions varchar,
    amount varchar,
	error_type varchar
);
