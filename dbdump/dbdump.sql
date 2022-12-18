--
-- PostgreSQL database dump
--

-- Dumped from database version 14.5
-- Dumped by pg_dump version 15.1

-- Started on 2022-12-18 09:08:13

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 6 (class 2615 OID 16403)
-- Name: Company; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA "Company";


--
-- TOC entry 936 (class 1247 OID 16753)
-- Name: goods_need_imported_ctype; Type: TYPE; Schema: Company; Owner: -
--

CREATE TYPE "Company".goods_need_imported_ctype AS (
	goods_id integer,
	name character varying(50),
	color character varying(50),
	goods_need_imported integer
);


--
-- TOC entry 255 (class 1255 OID 16705)
-- Name: deletesaleinfo(integer); Type: PROCEDURE; Schema: Company; Owner: -
--

CREATE PROCEDURE "Company".deletesaleinfo(IN _receipt_id integer)
    LANGUAGE plpgsql
    AS $$
begin
	if _receipt_id > 0 then
		perform order_id from "Company".sale_info where receipt_id = _receipt_id;
		if not found then raise exception 'Ma hoa don % khong ton tai', _receipt_id;
		end if;
			
		DELETE FROM "Company".sale_info
		WHERE receipt_id=_receipt_id;

	else
		raise exception 'Ma hoa don phai >0';
	end if;
	
END;
$$;


--
-- TOC entry 261 (class 1255 OID 16769)
-- Name: get_buy_table(integer); Type: FUNCTION; Schema: Company; Owner: -
--

CREATE FUNCTION "Company".get_buy_table(account_id integer) RETURNS TABLE(receipt_id integer, order_id integer, goods_name character varying, categories character varying, color character varying, amount integer, sale_date date, unit_price numeric, total numeric)
    LANGUAGE plpgsql
    AS $$
	begin
		return query
		select
			si.receipt_id,
			si.order_id,
			g."name" ,
			g.categories ,
			g.color ,
			si.amount,
			si.sale_date ,
			si.unit_price ,
			si.total
		from
			"Company".sale_info si
		left join "Company".goods g on
			si.goods_id = g.goods_id
		where
			si.customer_id = (
			select
				*
			from
				"Company".get_customer_id(account_id));
	END;
$$;


--
-- TOC entry 260 (class 1255 OID 16762)
-- Name: get_customer_id(integer); Type: FUNCTION; Schema: Company; Owner: -
--

CREATE FUNCTION "Company".get_customer_id(_account_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare id integer;
	BEGIN
		select customer_id into id from "Company".customer natural join "Company".account where account_id = _account_id;
		return id;
	END;
$$;


--
-- TOC entry 257 (class 1255 OID 16754)
-- Name: get_goods_need_imported(); Type: FUNCTION; Schema: Company; Owner: -
--

CREATE FUNCTION "Company".get_goods_need_imported() RETURNS SETOF "Company".goods_need_imported_ctype
    LANGUAGE plpgsql
    AS $$
declare 
	res "Company".goods_need_imported_ctype;
	BEGIN
		for res in 
			with sum_amount_order as(
			select
			goods_id,
				sum(amount) as sum_amount
			from
				("Company".order od
			join "Company".goods_in_order gio on
				od.order_id = gio.order_id)
			where
				od.finished = false
			group by
				goods_id)
		
			select
				goods.goods_id,
				name,
				color,
				(case
					when (sum_amount - stock)>0 then (sum_amount - stock)
					else 0
				end) as goods_need_imported
			from
				"Company".goods
			left join sum_amount_order sao on
				goods.goods_id = sao.goods_id
			order by
				goods_need_imported desc
		loop return next res;
		end loop;
	END;
$$;


--
-- TOC entry 259 (class 1255 OID 16758)
-- Name: get_order_count(integer); Type: PROCEDURE; Schema: Company; Owner: -
--

CREATE PROCEDURE "Company".get_order_count(OUT amount integer, IN user_id integer)
    LANGUAGE plpgsql
    AS $$
declare 
	_customer_id int4;

begin
select
	customer_id
into
	_customer_id
from
	"Company".customer
natural join "Company".account a
where
	account_id = user_id;

select count(order_id) into amount from "Company".order where customer_id = _customer_id;
end;
$$;


--
-- TOC entry 258 (class 1255 OID 16786)
-- Name: get_order_count_1(integer); Type: PROCEDURE; Schema: Company; Owner: -
--

CREATE PROCEDURE "Company".get_order_count_1(IN user_id integer)
    LANGUAGE plpgsql
    AS $$
declare 
	_customer_id int4;

begin
select
	customer_id
into
	_customer_id
from
	"Company".customer
natural join "Company".account a
where
	account_id = user_id;

select * from "Company".order where customer_id = _customer_id;
end;
$$;


--
-- TOC entry 254 (class 1255 OID 16793)
-- Name: get_order_table(integer); Type: FUNCTION; Schema: Company; Owner: -
--

CREATE FUNCTION "Company".get_order_table(account_id integer) RETURNS TABLE(order_id integer, created_date date, goods_name character varying, categories character varying, color character varying, amount integer, status character varying, status_date date, finished boolean)
    LANGUAGE plpgsql
    AS $$
	begin
		return query 
		with mathang as(
		select
			gio.order_id,
			g."name" ,
			g.categories ,
			g.color ,
			gio.amount
		from
			"Company".goods_in_order gio
		left join "Company".goods g on
			gio.goods_id = g.goods_id 
		)
		
		select
			od.order_id,
			od.created_date,
			mathang."name" as goods_name,
			mathang.categories,
			mathang.color,
			mathang.amount,
			sd.definitions,
			od."date" as status_date,
			od.finished
		from
			("Company".order natural join "Company".order_tracking ) as od
			left join mathang on od.order_id = mathang.order_id
			left join "Company".status_define sd on od.status = sd.status 
		where
			customer_id = (
			select
				*
			from
				"Company".get_customer_id(account_id))
		order by created_date desc, status_date desc;
	END;
$$;


--
-- TOC entry 263 (class 1255 OID 16404)
-- Name: insertSaleInfo(integer, integer, integer, integer); Type: PROCEDURE; Schema: Company; Owner: -
--

CREATE PROCEDURE "Company"."insertSaleInfo"(IN _order_id integer, IN _goods_id integer, IN _amount integer, IN _unit_price integer)
    LANGUAGE plpgsql
    AS $$
declare 
	_today date:=CURRENT_DATE;
	_total int4;
	_customer_id int4;
	temp_amount int4;
	temp_sum_amount int4;
begin
	if _order_id < 0 then raise exception 'Ma dat hang phai >0';
	end if;
	if _goods_id < 0 then raise exception 'Ma san pham >0';
	end if;
	if _amount < 0 then raise exception 'So luong phai >0';
	end if;
	
	perform order_id from "Company".order where order_id = _order_id;
	if not found then
		raise exception 'Ma dat hang % khong ton tai', _order_id;
	end if;
	
	perform goods_id from "Company".goods_in_order where (order_id = _order_id and goods_id = _goods_id);
	if not found then
		raise exception 'Ma san pham % khong ton tai trong don hang %', _goods_id, _order_id;
	end if;

	select sum(amount) into temp_sum_amount from "Company".sale_info where (order_id = _order_id and goods_id = _goods_id);
	select amount into temp_amount from "Company".goods_in_order where (order_id = _order_id and goods_id = _goods_id);
	if _amount < 0 or  _amount > (temp_amount-temp_sum_amount)  then 
		raise exception 'So luong khong hop le. Gia tri phai nam trong khoang 0 -> %', (temp_amount-temp_sum_amount);
	end if;
	

	_total = _amount*_unit_price + _amount*_unit_price*0.08;

	select customer_id into _customer_id from "Company".order where order_id = _order_id;
	insert into "Company".sale_info(order_id, goods_id, customer_id, sale_date, amount, unit_price, tax, total) values(_order_id, _goods_id, _customer_id, _today, _amount, _unit_price, 0.08, _total);
end;
$$;


--
-- TOC entry 256 (class 1255 OID 16782)
-- Name: trg_debt(); Type: FUNCTION; Schema: Company; Owner: -
--

CREATE FUNCTION "Company".trg_debt() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare 
	_group_threshold int4;

begin 
	if(TG_OP='UPDATE') then
		if (new.amount != old.amount) then
			select debt_threshold into _group_threshold from "Company".customer_group where group_id = (select cus.group_id from "Company".customer cus where customer_id = old.customer_id);
			if (new.amount > new.personal_debt_threshold) then raise notice 'Công nợ (%) vượt quá ngưỡng cá nhân (%)', new.amount, new.personal_debt_threshold;
			end if;
			if (new.amount > _group_threshold) then raise notice 'Công nợ (%) vượt quá ngưỡng nhóm khách hàng (%)', new.amount, _group_threshold;
			end if;
		end if;
	end if;
	return null;
end
$$;


--
-- TOC entry 252 (class 1255 OID 16717)
-- Name: trg_payment(); Type: FUNCTION; Schema: Company; Owner: -
--

CREATE FUNCTION "Company".trg_payment() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	DECLARE
		curDebt int4;
	BEGIN
		if (TG_OP='INSERT') then
			select amount into curDebt from "Company".debt where customer_id = new.customer_id;
			update "Company".debt
			set amount = (curDebt - new.amount)
			where customer_id = new.customer_id;
		elsif (TG_OP='UPDATE') then
			if (new.amount != old.amount) then
				select amount into curDebt from "Company".debt where customer_id = new.customer_id;
				update "Company".debt
				set amount = (curDebt + old.amount - new.amount)
				where customer_id = new.customer_id;
			end if;
		elsif (TG_OP='DELETE') then
			select amount into curDebt from "Company".debt where customer_id = old.customer_id;
			update "Company".debt
			set amount = (curDebt + old.amount)
			where customer_id = old.customer_id;
		end if;
		return null;
	END;
$$;


--
-- TOC entry 251 (class 1255 OID 16709)
-- Name: trg_themdonban(); Type: FUNCTION; Schema: Company; Owner: -
--

CREATE FUNCTION "Company".trg_themdonban() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	curStock int4;
	curDebt int4;
begin 
	if (TG_OP='INSERT') then
		select stock into curStock from "Company".goods where goods_id = new.goods_id;
		raise notice 'stock %', curStock;
		update "Company".goods 
		set stock = (curStock - new.amount)
		where goods_id = new.goods_id;
		
		select amount into curDebt from "Company".debt where customer_id = new.customer_id;
		update "Company".debt
		set amount = (curDebt + new.total)
		where customer_id = new.customer_id;
		
	elsif (TG_OP='UPDATE') then
		if (new.goods_id != old.goods_id) then
			select stock into curStock from "Company".goods where goods_id = old.goods_id;
			update "Company".goods 
			set stock = (curStock+old.amount)
			where goods_id = old.goods_id;
		
			select stock into curStock from "Company".goods where goods_id = new.goods_id;
			update "Company".goods 
			set stock = (curStock-old.amount)
			where goods_id = new.goods_id;
		end if;
		if (new.amount != old.amount) then
			select stock into curStock from "Company".goods where goods_id = new.goods_id;
			update "Company".goods 
			set stock = (curStock-(new.amount -old.amount))
			where goods_id = new.goods_id;
		end if;
		if (new.total != old.total) then
			select amount into curDebt from "Company".debt where customer_id = new.customer_id;
			update "Company".debt
			set amount = (curDebt - old.total + new.total)
			where customer_id = new.customer_id;
		end if;
	elsif (TG_OP='DELETE') then
		select stock into curStock from "Company".goods where goods_id = old.goods_id;
		update "Company".goods 
		set stock = (curStock+old.amount)
		where goods_id = old.goods_id;
		
		select amount into curDebt from "Company".debt where customer_id = old.customer_id;
		update "Company".debt
		set amount = (curDebt - old.total)
		where customer_id = old.customer_id;
	end if;
	return null;
end
$$;


--
-- TOC entry 253 (class 1255 OID 16774)
-- Name: updateorder(integer, integer, integer, character varying); Type: PROCEDURE; Schema: Company; Owner: -
--

CREATE PROCEDURE "Company".updateorder(IN _customer_id integer, IN _goods_id integer, IN _amount integer, IN _note character varying DEFAULT NULL::character varying)
    LANGUAGE plpgsql
    AS $$
declare 
	_today date:=CURRENT_DATE;
	_person_make_order integer;
	_order_id integer;
begin
	if _amount < 0 then raise exception 'So luong hang hoa phai >0'; end if;
	if _note is null then _note = ''; end if;
	select person_make_order_id into _person_make_order from "Company".customer where customer_id = _customer_id;
	if not found then
		select (max(id)+1) into _person_make_order from "Company".person_make_order;
	end if;
	
	select (max(order_id)+1) into _order_id from "Company".order;
	
	insert into "Company"."order" (customer_id, note, created_date, person_make_order_id, finished)
	VALUES(_customer_id, _note, _today, _person_make_order, false);
	commit;
	INSERT INTO "Company".goods_in_order (goods_id, order_id, amount)
	VALUES(_goods_id, _order_id, _amount);
	INSERT INTO "Company".order_tracking
	(customer_id, order_id, "date", status)
	VALUES(_customer_id, _order_id, _today, 0);
END;
$$;


--
-- TOC entry 262 (class 1255 OID 16714)
-- Name: updatesaleinfo(integer, integer, integer, integer, date, integer); Type: PROCEDURE; Schema: Company; Owner: -
--

CREATE PROCEDURE "Company".updatesaleinfo(IN _receipt_id integer, IN _order_id integer DEFAULT NULL::integer, IN _goods_id integer DEFAULT NULL::integer, IN _unit_price integer DEFAULT NULL::integer, IN _sale_date date DEFAULT NULL::date, IN _amount integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$
declare 
	_today date:=CURRENT_DATE;
	_total int4;
	_unit_price_temp int4;
	_tax int4;
	temp_amount int4;
	temp_sum_amount int4;
	
begin
	if _receipt_id > 0 then
		perform order_id from "Company".sale_info where receipt_id = _receipt_id;
		if not found then raise exception 'Ma hoa don % khong ton tai', _receipt_id;
		end if;
		
		if _order_id is null then
			select order_id into _order_id from "Company".sale_info where receipt_id = _receipt_id;
		else
			if _order_id <= 0 then raise exception 'Ma dat hang phai >0';
			else
				perform order_id from "Company".order where order_id = _order_id;
				if not found then
					raise exception 'Ma dat hang % khong ton tai', _order_id;
				end if;
			end if;
		end if;
		
		if _goods_id is null then
			select goods_id into _goods_id from "Company".sale_info where receipt_id = _receipt_id;
		else
			if _goods_id <= 0 then raise exception 'Ma mat hang phai >0';
			else
				perform goods_id from "Company".goods_in_order where (order_id = _order_id and goods_id = _goods_id);
				if not found then
					raise exception 'Ma san pham % khong ton tai trong don hang %', _goods_id, _order_id;
				end if;
			end if;
		end if;
		
		if _amount is null then
			select amount into _amount from "Company".sale_info where receipt_id = _receipt_id;
		else
			if _amount <= 0 then raise exception 'So luong phai >0';
			else
				select sum(amount) into temp_sum_amount from "Company".sale_info where (order_id = _order_id and goods_id = _goods_id);
				select amount into temp_amount from "Company".goods_in_order where (order_id = _order_id and goods_id = _goods_id);
				if _amount < 0 or _amount > (temp_amount-temp_sum_amount) then 
					raise exception 'So luong khong hop le. Gia tri phai nam trong khoang 0 -> %', (temp_amount-temp_sum_amount);
				end if;	
				
			end if;
		end if;
		if _unit_price is null then
			select unit_price, tax into _unit_price_temp, _tax from "Company".sale_info where receipt_id = _receipt_id;
		else
			if _unit_price <= 0 then raise exception 'Don gia phai >0';
			else
				_unit_price_temp = _unit_price;
			end if;
		end if;
		_total = _unit_price_temp*_amount + _unit_price_temp*_amount*0.08;
		update "Company".sale_info 
		set order_id = _order_id, goods_id = _goods_id, amount = _amount, total = _total, unit_price = _unit_price_temp
		where receipt_id = _receipt_id;
	else
		raise exception 'Ma hoa don phai >0';
	end if;
	
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 210 (class 1259 OID 16405)
-- Name:  warehouse_staff; Type: TABLE; Schema: Company; Owner: -
--

CREATE TABLE "Company"." warehouse_staff" (
    employee_id integer NOT NULL
);


--
-- TOC entry 211 (class 1259 OID 16408)
-- Name: account; Type: TABLE; Schema: Company; Owner: -
--

CREATE TABLE "Company".account (
    account_id integer NOT NULL,
    username character varying NOT NULL,
    pass character varying NOT NULL,
    permission integer DEFAULT 0 NOT NULL
);


--
-- TOC entry 212 (class 1259 OID 16413)
-- Name: cashier_staff; Type: TABLE; Schema: Company; Owner: -
--

CREATE TABLE "Company".cashier_staff (
    employee_id integer NOT NULL
);


--
-- TOC entry 213 (class 1259 OID 16416)
-- Name: customer; Type: TABLE; Schema: Company; Owner: -
--

CREATE TABLE "Company".customer (
    customer_id integer NOT NULL,
    name character varying NOT NULL,
    phone_number character varying,
    address character varying,
    group_id integer,
    cashier_id integer,
    person_make_order_id integer,
    account_id integer
);


--
-- TOC entry 214 (class 1259 OID 16421)
-- Name: customer_group; Type: TABLE; Schema: Company; Owner: -
--

CREATE TABLE "Company".customer_group (
    group_id integer NOT NULL,
    group_name character varying,
    debt_threshold numeric
);


--
-- TOC entry 215 (class 1259 OID 16426)
-- Name: debt; Type: TABLE; Schema: Company; Owner: -
--

CREATE TABLE "Company".debt (
    customer_id integer NOT NULL,
    amount numeric NOT NULL,
    personal_debt_threshold numeric
);


--
-- TOC entry 216 (class 1259 OID 16431)
-- Name: delivery_package; Type: TABLE; Schema: Company; Owner: -
--

CREATE TABLE "Company".delivery_package (
    receipt_id integer NOT NULL,
    transport_id integer NOT NULL,
    "mass(kg)" character varying,
    delivery_status integer
);


--
-- TOC entry 217 (class 1259 OID 16436)
-- Name: delivery_staff; Type: TABLE; Schema: Company; Owner: -
--

CREATE TABLE "Company".delivery_staff (
    employee_id integer NOT NULL
);


--
-- TOC entry 218 (class 1259 OID 16439)
-- Name: driver_staff; Type: TABLE; Schema: Company; Owner: -
--

CREATE TABLE "Company".driver_staff (
    employee_id integer NOT NULL
);


--
-- TOC entry 219 (class 1259 OID 16442)
-- Name: employee; Type: TABLE; Schema: Company; Owner: -
--

CREATE TABLE "Company".employee (
    employee_id integer NOT NULL,
    account_id integer,
    scope_of_work character varying,
    manager_id integer,
    name character varying
);


--
-- TOC entry 220 (class 1259 OID 16447)
-- Name: goods; Type: TABLE; Schema: Company; Owner: -
--

CREATE TABLE "Company".goods (
    goods_id integer NOT NULL,
    name character varying,
    categories character varying,
    color character varying,
    picture bytea,
    descriptions character varying,
    stock integer,
    vendor character varying,
    spectifications character varying,
    unit character varying
);


--
-- TOC entry 221 (class 1259 OID 16452)
-- Name: goods_in_order; Type: TABLE; Schema: Company; Owner: -
--

CREATE TABLE "Company".goods_in_order (
    goods_id integer NOT NULL,
    order_id integer NOT NULL,
    amount integer NOT NULL
);


--
-- TOC entry 222 (class 1259 OID 16455)
-- Name: inside_transport; Type: TABLE; Schema: Company; Owner: -
--

CREATE TABLE "Company".inside_transport (
    transport_id integer NOT NULL,
    license_plate character varying,
    driver_staff_id integer
);


--
-- TOC entry 223 (class 1259 OID 16460)
-- Name: manager_staff; Type: TABLE; Schema: Company; Owner: -
--

CREATE TABLE "Company".manager_staff (
    employee_id integer NOT NULL
);


--
-- TOC entry 238 (class 1259 OID 16783)
-- Name: new; Type: SEQUENCE; Schema: Company; Owner: -
--

CREATE SEQUENCE "Company".new
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 224 (class 1259 OID 16463)
-- Name: order; Type: TABLE; Schema: Company; Owner: -
--

CREATE TABLE "Company"."order" (
    order_id integer NOT NULL,
    customer_id integer,
    note character varying,
    created_date date,
    person_make_order_id integer,
    finished boolean DEFAULT false NOT NULL
);


--
-- TOC entry 237 (class 1259 OID 16770)
-- Name: order_order_id_seq; Type: SEQUENCE; Schema: Company; Owner: -
--

ALTER TABLE "Company"."order" ALTER COLUMN order_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "Company".order_order_id_seq
    START WITH 1000
    INCREMENT BY 1
    MINVALUE 1000
    MAXVALUE 10000
    CACHE 1
);


--
-- TOC entry 225 (class 1259 OID 16468)
-- Name: order_tracking; Type: TABLE; Schema: Company; Owner: -
--

CREATE TABLE "Company".order_tracking (
    customer_id integer NOT NULL,
    order_id integer NOT NULL,
    date date NOT NULL,
    status integer NOT NULL
);


--
-- TOC entry 226 (class 1259 OID 16471)
-- Name: outside_transport; Type: TABLE; Schema: Company; Owner: -
--

CREATE TABLE "Company".outside_transport (
    transport_id integer NOT NULL,
    outside_license_plate character varying NOT NULL,
    outside_driver_name character varying NOT NULL
);


--
-- TOC entry 227 (class 1259 OID 16476)
-- Name: payment; Type: TABLE; Schema: Company; Owner: -
--

CREATE TABLE "Company".payment (
    date date NOT NULL,
    customer_id integer NOT NULL,
    cashier_staff_id integer NOT NULL,
    amount numeric
);


--
-- TOC entry 228 (class 1259 OID 16481)
-- Name: person_make_order; Type: TABLE; Schema: Company; Owner: -
--

CREATE TABLE "Company".person_make_order (
    id integer NOT NULL
);


--
-- TOC entry 229 (class 1259 OID 16484)
-- Name: sale_info; Type: TABLE; Schema: Company; Owner: -
--

CREATE TABLE "Company".sale_info (
    receipt_id integer NOT NULL,
    order_id integer,
    goods_id integer,
    customer_id integer,
    sale_date date,
    amount integer,
    unit_price numeric,
    tax numeric,
    total numeric
);


--
-- TOC entry 230 (class 1259 OID 16489)
-- Name: sale_info_receipt_id_seq; Type: SEQUENCE; Schema: Company; Owner: -
--

ALTER TABLE "Company".sale_info ALTER COLUMN receipt_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "Company".sale_info_receipt_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999
    CACHE 1
);


--
-- TOC entry 231 (class 1259 OID 16490)
-- Name: saler_staff; Type: TABLE; Schema: Company; Owner: -
--

CREATE TABLE "Company".saler_staff (
    employee_id integer NOT NULL,
    person_make_order_id integer
);


--
-- TOC entry 239 (class 1259 OID 16787)
-- Name: status_define; Type: TABLE; Schema: Company; Owner: -
--

CREATE TABLE "Company".status_define (
    status integer NOT NULL,
    definitions character varying NOT NULL
);


--
-- TOC entry 232 (class 1259 OID 16493)
-- Name: transport; Type: TABLE; Schema: Company; Owner: -
--

CREATE TABLE "Company".transport (
    transport_id integer NOT NULL,
    cur_position character varying,
    delivery_locations character varying,
    status integer,
    delivery_staff_id integer NOT NULL,
    delivery_time date
);


--
-- TOC entry 233 (class 1259 OID 16498)
-- Name: vehicle; Type: TABLE; Schema: Company; Owner: -
--

CREATE TABLE "Company".vehicle (
    license_plate character varying NOT NULL
);


--
-- TOC entry 4472 (class 0 OID 16405)
-- Dependencies: 210
-- Data for Name:  warehouse_staff; Type: TABLE DATA; Schema: Company; Owner: -
--



--
-- TOC entry 4473 (class 0 OID 16408)
-- Dependencies: 211
-- Data for Name: account; Type: TABLE DATA; Schema: Company; Owner: -
--

INSERT INTO "Company".account VALUES (1, 'watson_r', '8500e430b6e1881bf460db8c5a68ef2a', 0);
INSERT INTO "Company".account VALUES (2, 'deleon_m', 'f90e7c1ab78ed9bb957b5cf8004c221e', 0);
INSERT INTO "Company".account VALUES (3, 'henry_y', '09061cda753215dd398a22fe912a787b', 0);
INSERT INTO "Company".account VALUES (4, 'melendez_e', 'a309aa41620103ca379fa49dc1a26760', 0);
INSERT INTO "Company".account VALUES (5, 'house_o', '72c4c652f28c82a878b654253f6a44fe', 0);
INSERT INTO "Company".account VALUES (6, 'suarez_t', 'de11c9a3ecea714aea216126c9d2f74b', 0);
INSERT INTO "Company".account VALUES (7, 'murray_k', '415d6321d6091ad45fac8209a9a701c9', 0);
INSERT INTO "Company".account VALUES (8, 'reyes_a', '10f21659fced68353a17d3911aa7dd14', 0);
INSERT INTO "Company".account VALUES (9, 'bowers_a', 'a2e26b5eff977b12276d7dcfdbc1cf2d', 0);
INSERT INTO "Company".account VALUES (10, 'franklin_e', 'd08d0784c6e8c5e2a18088acc2241386', 0);
INSERT INTO "Company".account VALUES (11, 'meza_n', '6e0b96694ac15957eb32fb1c54ffc327', 0);
INSERT INTO "Company".account VALUES (12, 'blackwell_j', 'ef9e5cef1e6a8a309d4ac024c67c04fb', 0);
INSERT INTO "Company".account VALUES (13, 'caldwell_e', '58cfcea9d7c4379d26de04c4f21e52d6', 0);
INSERT INTO "Company".account VALUES (14, 'shepard_j', 'be751bddde589ce224a4537f19998582', 0);
INSERT INTO "Company".account VALUES (15, 'may_a', 'd62d2b38c3e56d38eeb69f7d80d01524', 0);
INSERT INTO "Company".account VALUES (16, 'clayton_m', 'eb69b518644cb820261ceb5bf179973b', 0);
INSERT INTO "Company".account VALUES (17, 'roberts_m', '582c3e08b5057a8f72a29213c00c9582', 0);
INSERT INTO "Company".account VALUES (18, 'wilcox_t', 'a2d2503d254bfb009cd010bc91a71a94', 0);
INSERT INTO "Company".account VALUES (19, 'jarvis_a', 'bde9f624a134a8684e94400a0ad48812', 0);
INSERT INTO "Company".account VALUES (20, 'snyder_z', '635e42c3afcc079784780c2c21386794', 0);
INSERT INTO "Company".account VALUES (21, 'zuniga_w', 'daefbe3a309d1996d11b5ea0b7ff7deb', 0);
INSERT INTO "Company".account VALUES (22, 'mcgee_m', '308dccd3d55d0eee7b962d084e2d9525', 0);
INSERT INTO "Company".account VALUES (23, 'vance_m', '66c6c0979fe81eb25df1a8f313a25bce', 0);
INSERT INTO "Company".account VALUES (24, 'hess_t', 'd6c2d74b99c39bfeabb70d8fb3a22275', 0);
INSERT INTO "Company".account VALUES (25, 'shaw_m', '7ab52fed1a6066759155a39a1347b545', 0);
INSERT INTO "Company".account VALUES (26, 'boone_k', '1dccc80bc4b36ca293b406a9f4a368a0', 2);
INSERT INTO "Company".account VALUES (27, 'blake_c', 'be0a96d6bfbbea5444ef8f07336bdeea', 2);
INSERT INTO "Company".account VALUES (28, 'juarez_e', 'a1e94f496af7bd12e80bebd6bc391ff8', 2);
INSERT INTO "Company".account VALUES (29, 'cohen_a', '6287c01124a9b0b41e479172487129fb', 2);
INSERT INTO "Company".account VALUES (30, 'mcbride_s', 'c0d3e7decb2268ea6e66be5a47965c1d', 2);
INSERT INTO "Company".account VALUES (31, 'cabrera_c', '5d9a89c5d0c828176887e7c98e0e5ae5', 1);
INSERT INTO "Company".account VALUES (32, 'bates_r', '5f550caaa7a4151ce0c9d5b571d3eaad', 1);
INSERT INTO "Company".account VALUES (33, 'butler_p', '9c0502b7e0e0c161db531c3e8450dceb', 1);
INSERT INTO "Company".account VALUES (34, 'rocha_e', '4b59ac5a6fcddd640528880c87cac5d9', 1);
INSERT INTO "Company".account VALUES (35, 'woodard_m', '83e2f01f6244d151a1a0709536dac03a', 1);
INSERT INTO "Company".account VALUES (36, 'schultz_f', 'd5dce621c1fc49d57a628e281b86f009', 1);
INSERT INTO "Company".account VALUES (37, 'jennings_j', '13aef80a2d55299e73e98af9f430bf37', 1);
INSERT INTO "Company".account VALUES (38, 'walsh_i', '37d2a4eeec91ee74cb7f1c6711e7c524', 1);
INSERT INTO "Company".account VALUES (39, 'beasley_a', '098e4686acc510d5fc1ac408dc9688a5', 1);
INSERT INTO "Company".account VALUES (40, 'hall_l', '28a215c755dc63f346d5ca66bbd4e86c', 1);
INSERT INTO "Company".account VALUES (41, 'wood_e', '523d65f93b276e6c7ac55be29c4228f0', 1);
INSERT INTO "Company".account VALUES (42, 'miles_t', '447c6d7d364ed8cba83826d05a69266a', 1);
INSERT INTO "Company".account VALUES (43, 'hamilton_b', '376401ba4c7e5818b72a59f34cb1eb30', 1);
INSERT INTO "Company".account VALUES (44, 'townsend_m', '53000e0b596342bc39b00e352a789968', 1);
INSERT INTO "Company".account VALUES (45, 'lara_s', 'c400663c6686ee257ca7352294546921', 1);


--
-- TOC entry 4474 (class 0 OID 16413)
-- Dependencies: 212
-- Data for Name: cashier_staff; Type: TABLE DATA; Schema: Company; Owner: -
--

INSERT INTO "Company".cashier_staff VALUES (1);
INSERT INTO "Company".cashier_staff VALUES (2);
INSERT INTO "Company".cashier_staff VALUES (3);
INSERT INTO "Company".cashier_staff VALUES (4);
INSERT INTO "Company".cashier_staff VALUES (5);


--
-- TOC entry 4475 (class 0 OID 16416)
-- Dependencies: 213
-- Data for Name: customer; Type: TABLE DATA; Schema: Company; Owner: -
--

INSERT INTO "Company".customer VALUES (2000, 'Chiara Cabrera', '0909176000', '195 Ngo Tat To Ward 22, Ho Chi Minh City,Vietnam', 1, 1, NULL, 31);
INSERT INTO "Company".customer VALUES (2002, 'Paige Butler', '0909639402', '378 Vinh Son Ward 3, Ho Chi Minh City,Vietnam', 2, 1, NULL, 33);
INSERT INTO "Company".customer VALUES (2003, 'Elaine Rocha', '0909779803', '181/29 Street 3/2 Ward 11 District 10, Ho Chi Minh City,Vietnam', 2, 2, NULL, 34);
INSERT INTO "Company".customer VALUES (2004, 'Milan Woodard', '0909902404', '37 Nguyen Truong To St., Ho Chi Minh City,Vietnam', 2, 2, NULL, 35);
INSERT INTO "Company".customer VALUES (2005, 'Fern Schultz', '0909707805', '12 Nguyen Huu Canh St. Ward 19, Ho Chi Minh City,Vietnam', 2, 2, NULL, 36);
INSERT INTO "Company".customer VALUES (2006, 'Jodie Jennings', '0909545206', '142/19 Nguyen Thi Thap St. Binh Thuan Ward Dist. 7, Ho Chi Minh City,Vietnam', 2, 3, NULL, 37);
INSERT INTO "Company".customer VALUES (2007, 'Ismaeel Walsh', '0909981407', '701 Le Hong Phong Ward 10, Ho Chi Minh City,Vietnam', 3, 3, NULL, 38);
INSERT INTO "Company".customer VALUES (2008, 'Aysha Beasley', '0909659608', '130/9 Pham Van Hai St. Ward 3, Ho Chi Minh City,Vietnam', 3, 3, NULL, 39);
INSERT INTO "Company".customer VALUES (2009, 'Leonard Hall', '0909119809', '226 Tran Hung Dao Street Phan Thiet City, Ho Chi Minh City,Vietnam', 3, 4, NULL, 40);
INSERT INTO "Company".customer VALUES (2012, 'Brogan Hamilton', '09098628012', '50 Mai Hac De Street, Ho Chi Minh City,Vietnam', 4, 5, NULL, 43);
INSERT INTO "Company".customer VALUES (2013, 'Miranda Townsend', '09092184013', '60/15/1 Phan Huy ich Ward 12, Ho Chi Minh City,Vietnam', 4, 5, NULL, 44);
INSERT INTO "Company".customer VALUES (2014, 'Shakira Lara', '09098642014', '54 Nguyen Du Street, Ho Chi Minh City,Vietnam', 4, 5, NULL, 45);
INSERT INTO "Company".customer VALUES (2001, 'Romeo Bates', '0909603201', '64 Dien Bien Phu St. Dakao Ward Dist. 1, Ho Chi Minh City,Vietnam', 1, 1, 1, 32);
INSERT INTO "Company".customer VALUES (2010, 'Edie Wood', '09096362010', '204/6B Lac Long Quan Street Ward 1, Ho Chi Minh City,Vietnam', 3, 4, 8, 41);
INSERT INTO "Company".customer VALUES (2011, 'Tomasz Miles', '09098734011', '74 Dat Moi Binh Tri Dong Ward, Ho Chi Minh City,Vietnam', 3, 4, 9, 42);


--
-- TOC entry 4476 (class 0 OID 16421)
-- Dependencies: 214
-- Data for Name: customer_group; Type: TABLE DATA; Schema: Company; Owner: -
--

INSERT INTO "Company".customer_group VALUES (1, 'vip', 3000.0);
INSERT INTO "Company".customer_group VALUES (2, 'wholesale', 1000.0);
INSERT INTO "Company".customer_group VALUES (3, 'retail', 300.0);
INSERT INTO "Company".customer_group VALUES (4, 'passersby', 100);
INSERT INTO "Company".customer_group VALUES (5, 'other', 100);


--
-- TOC entry 4477 (class 0 OID 16426)
-- Dependencies: 215
-- Data for Name: debt; Type: TABLE DATA; Schema: Company; Owner: -
--

INSERT INTO "Company".debt VALUES (2000, 0, 1000000000);
INSERT INTO "Company".debt VALUES (2002, 0, 300000000);
INSERT INTO "Company".debt VALUES (2006, 0, 100000000);
INSERT INTO "Company".debt VALUES (2007, 0, 100000000);
INSERT INTO "Company".debt VALUES (2008, 0, 100000000);
INSERT INTO "Company".debt VALUES (2009, 0, 100000000);
INSERT INTO "Company".debt VALUES (2010, 0, 100000000);
INSERT INTO "Company".debt VALUES (2011, 0, 100000000);
INSERT INTO "Company".debt VALUES (2012, 0, 50000000);
INSERT INTO "Company".debt VALUES (2013, 0, 50000000);
INSERT INTO "Company".debt VALUES (2014, 0, 50000000);
INSERT INTO "Company".debt VALUES (2003, 108000000, 300000000);
INSERT INTO "Company".debt VALUES (2005, 12000000, 300000000);
INSERT INTO "Company".debt VALUES (2004, 51840000, 300000000);
INSERT INTO "Company".debt VALUES (2001, 192632000, 800000000);


--
-- TOC entry 4478 (class 0 OID 16431)
-- Dependencies: 216
-- Data for Name: delivery_package; Type: TABLE DATA; Schema: Company; Owner: -
--

INSERT INTO "Company".delivery_package VALUES (9, 1, '500', 0);
INSERT INTO "Company".delivery_package VALUES (3, 2, '150', 1);
INSERT INTO "Company".delivery_package VALUES (4, 2, '250', 1);
INSERT INTO "Company".delivery_package VALUES (5, 2, '100', 1);
INSERT INTO "Company".delivery_package VALUES (6, 3, '500', 1);
INSERT INTO "Company".delivery_package VALUES (7, 4, '250', 1);
INSERT INTO "Company".delivery_package VALUES (8, 5, '250', 0);


--
-- TOC entry 4479 (class 0 OID 16436)
-- Dependencies: 217
-- Data for Name: delivery_staff; Type: TABLE DATA; Schema: Company; Owner: -
--

INSERT INTO "Company".delivery_staff VALUES (16);
INSERT INTO "Company".delivery_staff VALUES (17);
INSERT INTO "Company".delivery_staff VALUES (18);
INSERT INTO "Company".delivery_staff VALUES (19);
INSERT INTO "Company".delivery_staff VALUES (20);


--
-- TOC entry 4480 (class 0 OID 16439)
-- Dependencies: 218
-- Data for Name: driver_staff; Type: TABLE DATA; Schema: Company; Owner: -
--

INSERT INTO "Company".driver_staff VALUES (6);
INSERT INTO "Company".driver_staff VALUES (7);
INSERT INTO "Company".driver_staff VALUES (8);
INSERT INTO "Company".driver_staff VALUES (9);
INSERT INTO "Company".driver_staff VALUES (10);


--
-- TOC entry 4481 (class 0 OID 16442)
-- Dependencies: 219
-- Data for Name: employee; Type: TABLE DATA; Schema: Company; Owner: -
--

INSERT INTO "Company".employee VALUES (1, 1, 'Thu ngan', 26, 'Robyn Watson');
INSERT INTO "Company".employee VALUES (2, 2, 'Thu ngan', 26, 'Maisie Deleon');
INSERT INTO "Company".employee VALUES (3, 3, 'Thu ngan', 26, 'Yasmin Henry');
INSERT INTO "Company".employee VALUES (4, 4, 'Thu ngan', 26, 'Elissa Melendez');
INSERT INTO "Company".employee VALUES (5, 5, 'Thu ngan', 26, 'Orla House');
INSERT INTO "Company".employee VALUES (6, 6, 'Lai xe', 27, 'Tyler Suarez');
INSERT INTO "Company".employee VALUES (7, 7, 'Lai xe', 27, 'Kaleb Murray');
INSERT INTO "Company".employee VALUES (8, 8, 'Lai xe', 27, 'Ajay Reyes');
INSERT INTO "Company".employee VALUES (9, 9, 'Lai xe', 27, 'Archie Bowers');
INSERT INTO "Company".employee VALUES (10, 10, 'Lai xe', 27, 'Eugene Franklin');
INSERT INTO "Company".employee VALUES (11, 11, 'Quan li xuat nhap hang trong kho', 28, 'Nataniel Meza');
INSERT INTO "Company".employee VALUES (12, 12, 'Quan li xuat nhap hang trong kho', 28, 'Junaid Blackwell');
INSERT INTO "Company".employee VALUES (13, 13, 'Quan li xuat nhap hang trong kho', 28, 'Eesa Caldwell');
INSERT INTO "Company".employee VALUES (14, 14, 'Quan li xuat nhap hang trong kho', 28, 'Jamal Shepard');
INSERT INTO "Company".employee VALUES (15, 15, 'Quan li xuat nhap hang trong kho', 28, 'Addie May');
INSERT INTO "Company".employee VALUES (16, 16, 'Chiu trach nhiem giao hang', 29, 'Mckenzie Clayton');
INSERT INTO "Company".employee VALUES (17, 17, 'Chiu trach nhiem giao hang', 29, 'Mohammad Roberts');
INSERT INTO "Company".employee VALUES (18, 18, 'Chiu trach nhiem giao hang', 29, 'Thalia Wilcox');
INSERT INTO "Company".employee VALUES (19, 19, 'Chiu trach nhiem giao hang', 29, 'Amie Jarvis');
INSERT INTO "Company".employee VALUES (20, 20, 'Chiu trach nhiem giao hang', 29, 'Zaara Snyder');
INSERT INTO "Company".employee VALUES (21, 21, 'Ban hang va thuc hien don hang', 30, 'Wilfred Zuniga');
INSERT INTO "Company".employee VALUES (22, 22, 'Ban hang va thuc hien don NULLhang', 30, 'Molly Mcgee');
INSERT INTO "Company".employee VALUES (23, 23, 'Ban hang va thuc hien don hang', 30, 'Marvin Vance');
INSERT INTO "Company".employee VALUES (24, 24, 'Ban hang va thuc hien don hang', 30, 'Tiana Hess');
INSERT INTO "Company".employee VALUES (25, 25, 'Ban hang va thuc hien don hang', 30, 'Martina Shaw');
INSERT INTO "Company".employee VALUES (26, 26, 'Quan ly', NULL, 'Karen Boone');
INSERT INTO "Company".employee VALUES (27, 27, 'Quan ly', NULL, 'Curtis Blake');
INSERT INTO "Company".employee VALUES (28, 28, 'Quan ly', NULL, 'Ellen Juarez');
INSERT INTO "Company".employee VALUES (29, 29, 'Quan ly', NULL, 'Adrian Cohen');
INSERT INTO "Company".employee VALUES (30, 30, 'Quan ly', NULL, 'Seth Mcbride');


--
-- TOC entry 4482 (class 0 OID 16447)
-- Dependencies: 220
-- Data for Name: goods; Type: TABLE DATA; Schema: Company; Owner: -
--

INSERT INTO "Company".goods VALUES (1, 'Kate', 'Vai', 'Red', NULL, NULL, 10000, NULL, NULL, 'm');
INSERT INTO "Company".goods VALUES (2, 'Kate', 'Vai', 'Yellow', NULL, NULL, 10000, NULL, NULL, 'm');
INSERT INTO "Company".goods VALUES (3, 'Kate', 'Vai', 'Green', NULL, NULL, 10000, NULL, NULL, 'm');
INSERT INTO "Company".goods VALUES (5, 'Silk', 'Vai', 'Red', NULL, NULL, 10000, NULL, NULL, 'm');
INSERT INTO "Company".goods VALUES (7, 'Silk', 'Vai', 'Green', NULL, NULL, 10000, NULL, NULL, 'm');
INSERT INTO "Company".goods VALUES (8, 'Silk', 'Vai', 'Blue', NULL, NULL, 10000, NULL, NULL, 'm');
INSERT INTO "Company".goods VALUES (9, 'Linen', 'Vai', 'Red', NULL, NULL, 10000, NULL, NULL, 'm');
INSERT INTO "Company".goods VALUES (10, 'Linen', 'Vai', 'Yellow', NULL, NULL, 10000, NULL, NULL, 'm');
INSERT INTO "Company".goods VALUES (15, 'Cotton', 'Vai', 'Green', NULL, NULL, 10000, NULL, NULL, 'm');
INSERT INTO "Company".goods VALUES (16, 'Cotton', 'Vai', 'Blue', NULL, NULL, 10000, NULL, NULL, 'm');
INSERT INTO "Company".goods VALUES (11, 'Linen', 'Vai', 'Black', NULL, NULL, 10000, NULL, NULL, 'm');
INSERT INTO "Company".goods VALUES (12, 'Linen', 'Vai', 'White', NULL, NULL, 10000, NULL, NULL, 'm');
INSERT INTO "Company".goods VALUES (13, 'Cotton', 'Vai', 'Black', NULL, NULL, 10000, NULL, NULL, 'm');
INSERT INTO "Company".goods VALUES (14, 'Cotton', 'Vai', 'White', NULL, NULL, 9400, NULL, NULL, 'm');
INSERT INTO "Company".goods VALUES (6, 'Silk', 'Vai', 'Yellow', NULL, NULL, 9500, NULL, NULL, 'm');
INSERT INTO "Company".goods VALUES (4, 'Kate', 'Vai', 'Blue', NULL, NULL, 9980, NULL, NULL, 'm');


--
-- TOC entry 4483 (class 0 OID 16452)
-- Dependencies: 221
-- Data for Name: goods_in_order; Type: TABLE DATA; Schema: Company; Owner: -
--

INSERT INTO "Company".goods_in_order VALUES (13, 1000, 2000);
INSERT INTO "Company".goods_in_order VALUES (13, 1001, 1000);
INSERT INTO "Company".goods_in_order VALUES (14, 1002, 1000);
INSERT INTO "Company".goods_in_order VALUES (8, 1003, 500);
INSERT INTO "Company".goods_in_order VALUES (2, 1004, 800);
INSERT INTO "Company".goods_in_order VALUES (14, 1005, 2000);
INSERT INTO "Company".goods_in_order VALUES (7, 1006, 700);
INSERT INTO "Company".goods_in_order VALUES (14, 1007, 500);
INSERT INTO "Company".goods_in_order VALUES (14, 1008, 1000);
INSERT INTO "Company".goods_in_order VALUES (16, 1009, 500);
INSERT INTO "Company".goods_in_order VALUES (13, 1002, 400);
INSERT INTO "Company".goods_in_order VALUES (13, 1010, 11000);
INSERT INTO "Company".goods_in_order VALUES (14, 1010, 10000);
INSERT INTO "Company".goods_in_order VALUES (8, 1010, 8000);
INSERT INTO "Company".goods_in_order VALUES (6, 1013, 500);
INSERT INTO "Company".goods_in_order VALUES (16, 1014, 2000);
INSERT INTO "Company".goods_in_order VALUES (9, 1021, 200);
INSERT INTO "Company".goods_in_order VALUES (16, 1022, 2000);
INSERT INTO "Company".goods_in_order VALUES (13, 1023, 200);
INSERT INTO "Company".goods_in_order VALUES (15, 1024, 100);
INSERT INTO "Company".goods_in_order VALUES (8, 1025, 200);
INSERT INTO "Company".goods_in_order VALUES (8, 1026, 1000);
INSERT INTO "Company".goods_in_order VALUES (13, 1027, 500);
INSERT INTO "Company".goods_in_order VALUES (11, 1028, 300);
INSERT INTO "Company".goods_in_order VALUES (12, 1029, 2000);
INSERT INTO "Company".goods_in_order VALUES (13, 1036, 1000);
INSERT INTO "Company".goods_in_order VALUES (8, 1037, 200);
INSERT INTO "Company".goods_in_order VALUES (4, 1038, 20);
INSERT INTO "Company".goods_in_order VALUES (7, 1039, 12);


--
-- TOC entry 4484 (class 0 OID 16455)
-- Dependencies: 222
-- Data for Name: inside_transport; Type: TABLE DATA; Schema: Company; Owner: -
--

INSERT INTO "Company".inside_transport VALUES (1, '59C-423.56', 6);
INSERT INTO "Company".inside_transport VALUES (2, '59C-402.91', 7);
INSERT INTO "Company".inside_transport VALUES (3, '59C-283.95', 8);
INSERT INTO "Company".inside_transport VALUES (4, '59C-492.52', 9);


--
-- TOC entry 4485 (class 0 OID 16460)
-- Dependencies: 223
-- Data for Name: manager_staff; Type: TABLE DATA; Schema: Company; Owner: -
--

INSERT INTO "Company".manager_staff VALUES (26);
INSERT INTO "Company".manager_staff VALUES (27);
INSERT INTO "Company".manager_staff VALUES (28);
INSERT INTO "Company".manager_staff VALUES (29);
INSERT INTO "Company".manager_staff VALUES (30);


--
-- TOC entry 4486 (class 0 OID 16463)
-- Dependencies: 224
-- Data for Name: order; Type: TABLE DATA; Schema: Company; Owner: -
--

INSERT INTO "Company"."order" OVERRIDING SYSTEM VALUE VALUES (1000, 2001, NULL, '2022-10-10', 1, false);
INSERT INTO "Company"."order" OVERRIDING SYSTEM VALUE VALUES (1001, 2003, NULL, '2022-10-10', 2, false);
INSERT INTO "Company"."order" OVERRIDING SYSTEM VALUE VALUES (1002, 2005, NULL, '2022-10-15', 3, false);
INSERT INTO "Company"."order" OVERRIDING SYSTEM VALUE VALUES (1003, 2002, NULL, '2022-10-20', 4, false);
INSERT INTO "Company"."order" OVERRIDING SYSTEM VALUE VALUES (1004, 2004, NULL, '2022-10-21', 5, false);
INSERT INTO "Company"."order" OVERRIDING SYSTEM VALUE VALUES (1007, 2010, NULL, '2022-11-05', 8, false);
INSERT INTO "Company"."order" OVERRIDING SYSTEM VALUE VALUES (1008, 2011, NULL, '2022-11-16', 9, false);
INSERT INTO "Company"."order" OVERRIDING SYSTEM VALUE VALUES (1005, 2004, NULL, '2022-11-01', 6, false);
INSERT INTO "Company"."order" OVERRIDING SYSTEM VALUE VALUES (1006, 2001, NULL, '2022-11-05', 1, false);
INSERT INTO "Company"."order" OVERRIDING SYSTEM VALUE VALUES (1009, 2011, NULL, '2022-11-28', 9, false);
INSERT INTO "Company"."order" OVERRIDING SYSTEM VALUE VALUES (1010, NULL, NULL, '2022-12-06', 2, false);
INSERT INTO "Company"."order" OVERRIDING SYSTEM VALUE VALUES (1011, NULL, NULL, '2022-12-06', 2, false);
INSERT INTO "Company"."order" OVERRIDING SYSTEM VALUE VALUES (1012, NULL, NULL, '2022-12-06', 2, false);
INSERT INTO "Company"."order" OVERRIDING SYSTEM VALUE VALUES (1013, 2001, NULL, '2022-12-06', 2, true);
INSERT INTO "Company"."order" OVERRIDING SYSTEM VALUE VALUES (1014, 2003, '', '2022-12-13', NULL, false);
INSERT INTO "Company"."order" OVERRIDING SYSTEM VALUE VALUES (1020, 2001, '', '2022-12-12', 1, false);
INSERT INTO "Company"."order" OVERRIDING SYSTEM VALUE VALUES (1021, 2001, '', '2022-12-12', 1, false);
INSERT INTO "Company"."order" OVERRIDING SYSTEM VALUE VALUES (1022, 2003, '', '2022-12-13', NULL, false);
INSERT INTO "Company"."order" OVERRIDING SYSTEM VALUE VALUES (1023, 2001, '', '2022-12-12', 1, false);
INSERT INTO "Company"."order" OVERRIDING SYSTEM VALUE VALUES (1024, 2001, '', '2022-12-12', 1, false);
INSERT INTO "Company"."order" OVERRIDING SYSTEM VALUE VALUES (1025, 2001, '', '2022-12-12', 1, false);
INSERT INTO "Company"."order" OVERRIDING SYSTEM VALUE VALUES (1026, 2001, '', '2022-12-12', 1, false);
INSERT INTO "Company"."order" OVERRIDING SYSTEM VALUE VALUES (1027, 2001, '', '2022-12-12', 1, false);
INSERT INTO "Company"."order" OVERRIDING SYSTEM VALUE VALUES (1028, 2001, '', '2022-12-14', 1, false);
INSERT INTO "Company"."order" OVERRIDING SYSTEM VALUE VALUES (1029, 2001, '', '2022-12-15', 1, false);
INSERT INTO "Company"."order" OVERRIDING SYSTEM VALUE VALUES (1030, 2001, '', '2022-12-15', 1, false);
INSERT INTO "Company"."order" OVERRIDING SYSTEM VALUE VALUES (1031, 2001, '', '2022-12-15', 1, false);
INSERT INTO "Company"."order" OVERRIDING SYSTEM VALUE VALUES (1032, 2001, '', '2022-12-15', 1, false);
INSERT INTO "Company"."order" OVERRIDING SYSTEM VALUE VALUES (1033, 2001, '', '2022-12-15', 1, false);
INSERT INTO "Company"."order" OVERRIDING SYSTEM VALUE VALUES (1034, 2001, '', '2022-12-15', 1, false);
INSERT INTO "Company"."order" OVERRIDING SYSTEM VALUE VALUES (1035, 2001, '', '2022-12-15', 1, false);
INSERT INTO "Company"."order" OVERRIDING SYSTEM VALUE VALUES (1036, 2001, '', '2022-12-15', 1, false);
INSERT INTO "Company"."order" OVERRIDING SYSTEM VALUE VALUES (1037, 2001, '', '2022-12-15', 1, false);
INSERT INTO "Company"."order" OVERRIDING SYSTEM VALUE VALUES (1038, 2001, '', '2022-12-17', 1, false);
INSERT INTO "Company"."order" OVERRIDING SYSTEM VALUE VALUES (1039, 2001, '', '2022-12-17', 1, false);


--
-- TOC entry 4487 (class 0 OID 16468)
-- Dependencies: 225
-- Data for Name: order_tracking; Type: TABLE DATA; Schema: Company; Owner: -
--

INSERT INTO "Company".order_tracking VALUES (2001, 1013, '2022-12-06', 0);
INSERT INTO "Company".order_tracking VALUES (2001, 1013, '2022-12-07', 1);
INSERT INTO "Company".order_tracking VALUES (2001, 1013, '2022-12-12', 2);
INSERT INTO "Company".order_tracking VALUES (2001, 1006, '2022-11-05', 0);
INSERT INTO "Company".order_tracking VALUES (2001, 1006, '2022-11-08', 1);
INSERT INTO "Company".order_tracking VALUES (2001, 1000, '2022-10-10', 0);
INSERT INTO "Company".order_tracking VALUES (2001, 1000, '2022-10-20', 1);
INSERT INTO "Company".order_tracking VALUES (2001, 1029, '2022-12-15', 0);
INSERT INTO "Company".order_tracking VALUES (2001, 1036, '2022-12-15', 0);
INSERT INTO "Company".order_tracking VALUES (2001, 1037, '2022-12-15', 0);
INSERT INTO "Company".order_tracking VALUES (2001, 1038, '2022-12-17', 0);
INSERT INTO "Company".order_tracking VALUES (2001, 1039, '2022-12-17', 0);


--
-- TOC entry 4488 (class 0 OID 16471)
-- Dependencies: 226
-- Data for Name: outside_transport; Type: TABLE DATA; Schema: Company; Owner: -
--

INSERT INTO "Company".outside_transport VALUES (5, '59C-169.27', 'Le Minh Khoi');


--
-- TOC entry 4489 (class 0 OID 16476)
-- Dependencies: 227
-- Data for Name: payment; Type: TABLE DATA; Schema: Company; Owner: -
--

INSERT INTO "Company".payment VALUES ('2022-06-11', 2005, 1, 16000000);
INSERT INTO "Company".payment VALUES ('2022-11-25', 2005, 1, 6000000);
INSERT INTO "Company".payment VALUES ('2022-12-01', 2005, 1, 20000000);
INSERT INTO "Company".payment VALUES ('2022-12-01', 2001, 1, 4000000);
INSERT INTO "Company".payment VALUES ('2022-12-03', 2001, 1, 9000000);


--
-- TOC entry 4490 (class 0 OID 16481)
-- Dependencies: 228
-- Data for Name: person_make_order; Type: TABLE DATA; Schema: Company; Owner: -
--

INSERT INTO "Company".person_make_order VALUES (1);
INSERT INTO "Company".person_make_order VALUES (2);
INSERT INTO "Company".person_make_order VALUES (3);
INSERT INTO "Company".person_make_order VALUES (4);
INSERT INTO "Company".person_make_order VALUES (5);
INSERT INTO "Company".person_make_order VALUES (6);
INSERT INTO "Company".person_make_order VALUES (7);
INSERT INTO "Company".person_make_order VALUES (8);
INSERT INTO "Company".person_make_order VALUES (9);
INSERT INTO "Company".person_make_order VALUES (10);


--
-- TOC entry 4491 (class 0 OID 16484)
-- Dependencies: 229
-- Data for Name: sale_info; Type: TABLE DATA; Schema: Company; Owner: -
--

INSERT INTO "Company".sale_info OVERRIDING SYSTEM VALUE VALUES (3, 1002, 14, 2005, '2022-12-06', 300, 50000, 0.08, 16200000);
INSERT INTO "Company".sale_info OVERRIDING SYSTEM VALUE VALUES (4, 1002, 14, 2005, '2022-12-06', 500, 50000, 0.08, 27000000);
INSERT INTO "Company".sale_info OVERRIDING SYSTEM VALUE VALUES (5, 1002, 14, 2005, '2022-12-06', 200, 50000, 0.08, 10800000);
INSERT INTO "Company".sale_info OVERRIDING SYSTEM VALUE VALUES (6, 1001, 13, 2003, '2022-12-06', 1000, 100000, 0.08, 108000000);
INSERT INTO "Company".sale_info OVERRIDING SYSTEM VALUE VALUES (7, 1000, 13, 2001, '2022-12-06', 500, 90000, 0.08, 48600000);
INSERT INTO "Company".sale_info OVERRIDING SYSTEM VALUE VALUES (8, 1000, 13, 2001, '2022-12-06', 500, 90000, 0.08, 48600000);
INSERT INTO "Company".sale_info OVERRIDING SYSTEM VALUE VALUES (9, 1000, 13, 2001, '2022-12-06', 1000, 90000, 0.08, 97200000);
INSERT INTO "Company".sale_info OVERRIDING SYSTEM VALUE VALUES (11, 1005, 14, 2004, '2022-12-06', 600, 80000, 0.08, 51840000);
INSERT INTO "Company".sale_info OVERRIDING SYSTEM VALUE VALUES (12, 1013, 6, 2001, '2022-12-10', 500, 20000, 0.08, 10800000);
INSERT INTO "Company".sale_info OVERRIDING SYSTEM VALUE VALUES (13, 1038, 4, 2001, '2022-12-17', 10, 20000, 0.08, 216000);
INSERT INTO "Company".sale_info OVERRIDING SYSTEM VALUE VALUES (14, 1038, 4, 2001, '2022-12-17', 10, 20000, 0.08, 216000);


--
-- TOC entry 4493 (class 0 OID 16490)
-- Dependencies: 231
-- Data for Name: saler_staff; Type: TABLE DATA; Schema: Company; Owner: -
--

INSERT INTO "Company".saler_staff VALUES (21, 2);
INSERT INTO "Company".saler_staff VALUES (22, 3);
INSERT INTO "Company".saler_staff VALUES (23, 4);
INSERT INTO "Company".saler_staff VALUES (24, 5);
INSERT INTO "Company".saler_staff VALUES (25, 6);


--
-- TOC entry 4498 (class 0 OID 16787)
-- Dependencies: 239
-- Data for Name: status_define; Type: TABLE DATA; Schema: Company; Owner: -
--

INSERT INTO "Company".status_define VALUES (0, 'Đang chờ');
INSERT INTO "Company".status_define VALUES (1, 'Đang xử lý');
INSERT INTO "Company".status_define VALUES (2, 'Hoàn thành');
INSERT INTO "Company".status_define VALUES (3, 'Bị huỷ');


--
-- TOC entry 4494 (class 0 OID 16493)
-- Dependencies: 232
-- Data for Name: transport; Type: TABLE DATA; Schema: Company; Owner: -
--

INSERT INTO "Company".transport VALUES (1, '"10.772273445318184, 106.65799111959888"', '"10.801996578744996, 106.61754985971994"', 0, 16, NULL);
INSERT INTO "Company".transport VALUES (5, '"10.772273445318184, 106.65799111959888"', '"10.796084569612217, 106.68573560317655"', 0, 20, NULL);
INSERT INTO "Company".transport VALUES (2, '"10.772273445318184, 106.65799111959888"', '"10.78886867287594, 106.70556685665214"', 1, 17, NULL);
INSERT INTO "Company".transport VALUES (3, '"10.772273445318184, 106.65799111959888"', '"10.758224590539701, 106.67250183638724"', 1, 18, NULL);
INSERT INTO "Company".transport VALUES (4, '"10.772273445318184, 106.65799111959888"', '"10.755468902721937, 106.66490410484782"', 1, 19, NULL);


--
-- TOC entry 4495 (class 0 OID 16498)
-- Dependencies: 233
-- Data for Name: vehicle; Type: TABLE DATA; Schema: Company; Owner: -
--

INSERT INTO "Company".vehicle VALUES ('59C-423.56');
INSERT INTO "Company".vehicle VALUES ('59C-987.86');
INSERT INTO "Company".vehicle VALUES ('59C-925.50');
INSERT INTO "Company".vehicle VALUES ('59C-703.96');
INSERT INTO "Company".vehicle VALUES ('59C-402.91');
INSERT INTO "Company".vehicle VALUES ('59C-283.95');
INSERT INTO "Company".vehicle VALUES ('59C-379.39');
INSERT INTO "Company".vehicle VALUES ('59C-265.43');
INSERT INTO "Company".vehicle VALUES ('59C-243.75');
INSERT INTO "Company".vehicle VALUES ('59C-615.15');
INSERT INTO "Company".vehicle VALUES ('59C-492.52');
INSERT INTO "Company".vehicle VALUES ('59C-169.23');
INSERT INTO "Company".vehicle VALUES ('59C-294.59');
INSERT INTO "Company".vehicle VALUES ('59C-768.54');
INSERT INTO "Company".vehicle VALUES ('59C-884.59');
INSERT INTO "Company".vehicle VALUES ('59C-532.73');
INSERT INTO "Company".vehicle VALUES ('59C-498.73');
INSERT INTO "Company".vehicle VALUES ('59C-106.91');
INSERT INTO "Company".vehicle VALUES ('59C-145.82');
INSERT INTO "Company".vehicle VALUES ('59C-200.90');


--
-- TOC entry 4504 (class 0 OID 0)
-- Dependencies: 238
-- Name: new; Type: SEQUENCE SET; Schema: Company; Owner: -
--

SELECT pg_catalog.setval('"Company".new', 1, false);


--
-- TOC entry 4505 (class 0 OID 0)
-- Dependencies: 237
-- Name: order_order_id_seq; Type: SEQUENCE SET; Schema: Company; Owner: -
--

SELECT pg_catalog.setval('"Company".order_order_id_seq', 1039, true);


--
-- TOC entry 4506 (class 0 OID 0)
-- Dependencies: 230
-- Name: sale_info_receipt_id_seq; Type: SEQUENCE SET; Schema: Company; Owner: -
--

SELECT pg_catalog.setval('"Company".sale_info_receipt_id_seq', 14, true);


--
-- TOC entry 4248 (class 2606 OID 16505)
-- Name:  warehouse_staff  warehouse_staff_pkey; Type: CONSTRAINT; Schema: Company; Owner: -
--

ALTER TABLE ONLY "Company"." warehouse_staff"
    ADD CONSTRAINT " warehouse_staff_pkey" PRIMARY KEY (employee_id);


--
-- TOC entry 4254 (class 2606 OID 16507)
-- Name: customer Customer_pkey; Type: CONSTRAINT; Schema: Company; Owner: -
--

ALTER TABLE ONLY "Company".customer
    ADD CONSTRAINT "Customer_pkey" PRIMARY KEY (customer_id);


--
-- TOC entry 4250 (class 2606 OID 16509)
-- Name: account account_pkey; Type: CONSTRAINT; Schema: Company; Owner: -
--

ALTER TABLE ONLY "Company".account
    ADD CONSTRAINT account_pkey PRIMARY KEY (account_id);


--
-- TOC entry 4252 (class 2606 OID 16511)
-- Name: cashier_staff cashier_staff_pk; Type: CONSTRAINT; Schema: Company; Owner: -
--

ALTER TABLE ONLY "Company".cashier_staff
    ADD CONSTRAINT cashier_staff_pk PRIMARY KEY (employee_id);


--
-- TOC entry 4258 (class 2606 OID 16513)
-- Name: debt debt_pk; Type: CONSTRAINT; Schema: Company; Owner: -
--

ALTER TABLE ONLY "Company".debt
    ADD CONSTRAINT debt_pk PRIMARY KEY (customer_id);


--
-- TOC entry 4260 (class 2606 OID 16515)
-- Name: delivery_package delivery_package_pk; Type: CONSTRAINT; Schema: Company; Owner: -
--

ALTER TABLE ONLY "Company".delivery_package
    ADD CONSTRAINT delivery_package_pk PRIMARY KEY (receipt_id, transport_id);


--
-- TOC entry 4262 (class 2606 OID 16517)
-- Name: delivery_staff delivery_staff_pk; Type: CONSTRAINT; Schema: Company; Owner: -
--

ALTER TABLE ONLY "Company".delivery_staff
    ADD CONSTRAINT delivery_staff_pk PRIMARY KEY (employee_id);


--
-- TOC entry 4264 (class 2606 OID 16519)
-- Name: driver_staff driver_pkey; Type: CONSTRAINT; Schema: Company; Owner: -
--

ALTER TABLE ONLY "Company".driver_staff
    ADD CONSTRAINT driver_pkey PRIMARY KEY (employee_id);


--
-- TOC entry 4267 (class 2606 OID 16521)
-- Name: employee employee_pkey; Type: CONSTRAINT; Schema: Company; Owner: -
--

ALTER TABLE ONLY "Company".employee
    ADD CONSTRAINT employee_pkey PRIMARY KEY (employee_id);


--
-- TOC entry 4271 (class 2606 OID 16523)
-- Name: goods_in_order goods_in_order_pk; Type: CONSTRAINT; Schema: Company; Owner: -
--

ALTER TABLE ONLY "Company".goods_in_order
    ADD CONSTRAINT goods_in_order_pk PRIMARY KEY (goods_id, order_id);


--
-- TOC entry 4269 (class 2606 OID 16525)
-- Name: goods goods_pk; Type: CONSTRAINT; Schema: Company; Owner: -
--

ALTER TABLE ONLY "Company".goods
    ADD CONSTRAINT goods_pk PRIMARY KEY (goods_id);


--
-- TOC entry 4256 (class 2606 OID 16527)
-- Name: customer_group group_id_pkey; Type: CONSTRAINT; Schema: Company; Owner: -
--

ALTER TABLE ONLY "Company".customer_group
    ADD CONSTRAINT group_id_pkey PRIMARY KEY (group_id);


--
-- TOC entry 4273 (class 2606 OID 16529)
-- Name: inside_transport inside_transport_pk; Type: CONSTRAINT; Schema: Company; Owner: -
--

ALTER TABLE ONLY "Company".inside_transport
    ADD CONSTRAINT inside_transport_pk PRIMARY KEY (transport_id);


--
-- TOC entry 4275 (class 2606 OID 16531)
-- Name: manager_staff manager_id_pk; Type: CONSTRAINT; Schema: Company; Owner: -
--

ALTER TABLE ONLY "Company".manager_staff
    ADD CONSTRAINT manager_id_pk PRIMARY KEY (employee_id);


--
-- TOC entry 4277 (class 2606 OID 16533)
-- Name: order order_pk; Type: CONSTRAINT; Schema: Company; Owner: -
--

ALTER TABLE ONLY "Company"."order"
    ADD CONSTRAINT order_pk PRIMARY KEY (order_id);


--
-- TOC entry 4279 (class 2606 OID 16535)
-- Name: order_tracking order_tracking_pk; Type: CONSTRAINT; Schema: Company; Owner: -
--

ALTER TABLE ONLY "Company".order_tracking
    ADD CONSTRAINT order_tracking_pk PRIMARY KEY (customer_id, order_id, date);


--
-- TOC entry 4281 (class 2606 OID 16537)
-- Name: outside_transport outside_transport_pk; Type: CONSTRAINT; Schema: Company; Owner: -
--

ALTER TABLE ONLY "Company".outside_transport
    ADD CONSTRAINT outside_transport_pk PRIMARY KEY (transport_id);


--
-- TOC entry 4283 (class 2606 OID 16539)
-- Name: payment payment_pk; Type: CONSTRAINT; Schema: Company; Owner: -
--

ALTER TABLE ONLY "Company".payment
    ADD CONSTRAINT payment_pk PRIMARY KEY (date, customer_id, cashier_staff_id);


--
-- TOC entry 4285 (class 2606 OID 16541)
-- Name: person_make_order person_make_order_pk; Type: CONSTRAINT; Schema: Company; Owner: -
--

ALTER TABLE ONLY "Company".person_make_order
    ADD CONSTRAINT person_make_order_pk PRIMARY KEY (id);


--
-- TOC entry 4287 (class 2606 OID 16543)
-- Name: sale_info sale_info_pk; Type: CONSTRAINT; Schema: Company; Owner: -
--

ALTER TABLE ONLY "Company".sale_info
    ADD CONSTRAINT sale_info_pk PRIMARY KEY (receipt_id);


--
-- TOC entry 4289 (class 2606 OID 16545)
-- Name: saler_staff saler_staff_pk; Type: CONSTRAINT; Schema: Company; Owner: -
--

ALTER TABLE ONLY "Company".saler_staff
    ADD CONSTRAINT saler_staff_pk PRIMARY KEY (employee_id);


--
-- TOC entry 4291 (class 2606 OID 16547)
-- Name: transport transport_pk; Type: CONSTRAINT; Schema: Company; Owner: -
--

ALTER TABLE ONLY "Company".transport
    ADD CONSTRAINT transport_pk PRIMARY KEY (transport_id);


--
-- TOC entry 4293 (class 2606 OID 16735)
-- Name: transport transport_un; Type: CONSTRAINT; Schema: Company; Owner: -
--

ALTER TABLE ONLY "Company".transport
    ADD CONSTRAINT transport_un UNIQUE (delivery_staff_id);


--
-- TOC entry 4295 (class 2606 OID 16549)
-- Name: vehicle vehicle_pk; Type: CONSTRAINT; Schema: Company; Owner: -
--

ALTER TABLE ONLY "Company".vehicle
    ADD CONSTRAINT vehicle_pk PRIMARY KEY (license_plate);


--
-- TOC entry 4265 (class 1259 OID 16550)
-- Name: fki_fk_employee_id; Type: INDEX; Schema: Company; Owner: -
--

CREATE INDEX fki_fk_employee_id ON "Company".driver_staff USING btree (employee_id);


--
-- TOC entry 4326 (class 2620 OID 16785)
-- Name: debt debt_warning; Type: TRIGGER; Schema: Company; Owner: -
--

CREATE TRIGGER debt_warning AFTER UPDATE ON "Company".debt FOR EACH ROW EXECUTE FUNCTION "Company".trg_debt();


--
-- TOC entry 4327 (class 2620 OID 16723)
-- Name: payment delete_payment; Type: TRIGGER; Schema: Company; Owner: -
--

CREATE TRIGGER delete_payment AFTER DELETE ON "Company".payment FOR EACH ROW EXECUTE FUNCTION "Company".trg_payment();


--
-- TOC entry 4330 (class 2620 OID 16719)
-- Name: sale_info delete_sale; Type: TRIGGER; Schema: Company; Owner: -
--

CREATE TRIGGER delete_sale AFTER DELETE ON "Company".sale_info FOR EACH ROW EXECUTE FUNCTION "Company".trg_themdonban();


--
-- TOC entry 4328 (class 2620 OID 16721)
-- Name: payment insert_payment; Type: TRIGGER; Schema: Company; Owner: -
--

CREATE TRIGGER insert_payment AFTER INSERT ON "Company".payment FOR EACH ROW EXECUTE FUNCTION "Company".trg_payment();


--
-- TOC entry 4331 (class 2620 OID 16711)
-- Name: sale_info insert_sale; Type: TRIGGER; Schema: Company; Owner: -
--

CREATE TRIGGER insert_sale AFTER INSERT ON "Company".sale_info FOR EACH ROW EXECUTE FUNCTION "Company".trg_themdonban();


--
-- TOC entry 4329 (class 2620 OID 16722)
-- Name: payment update_payment; Type: TRIGGER; Schema: Company; Owner: -
--

CREATE TRIGGER update_payment AFTER UPDATE ON "Company".payment FOR EACH ROW EXECUTE FUNCTION "Company".trg_payment();


--
-- TOC entry 4332 (class 2620 OID 16715)
-- Name: sale_info update_sale; Type: TRIGGER; Schema: Company; Owner: -
--

CREATE TRIGGER update_sale AFTER UPDATE ON "Company".sale_info FOR EACH ROW EXECUTE FUNCTION "Company".trg_themdonban();


--
-- TOC entry 4296 (class 2606 OID 16551)
-- Name:  warehouse_staff _warehouse_staff_FK; Type: FK CONSTRAINT; Schema: Company; Owner: -
--

ALTER TABLE ONLY "Company"." warehouse_staff"
    ADD CONSTRAINT "_warehouse_staff_FK" FOREIGN KEY (employee_id) REFERENCES "Company".employee(employee_id);


--
-- TOC entry 4306 (class 2606 OID 16556)
-- Name: employee account_id_fk; Type: FK CONSTRAINT; Schema: Company; Owner: -
--

ALTER TABLE ONLY "Company".employee
    ADD CONSTRAINT account_id_fk FOREIGN KEY (account_id) REFERENCES "Company".account(account_id);


--
-- TOC entry 4297 (class 2606 OID 16561)
-- Name: cashier_staff cashier_staff_fk; Type: FK CONSTRAINT; Schema: Company; Owner: -
--

ALTER TABLE ONLY "Company".cashier_staff
    ADD CONSTRAINT cashier_staff_fk FOREIGN KEY (employee_id) REFERENCES "Company".employee(employee_id);


--
-- TOC entry 4298 (class 2606 OID 16566)
-- Name: customer customer_fk; Type: FK CONSTRAINT; Schema: Company; Owner: -
--

ALTER TABLE ONLY "Company".customer
    ADD CONSTRAINT customer_fk FOREIGN KEY (person_make_order_id) REFERENCES "Company".person_make_order(id);


--
-- TOC entry 4299 (class 2606 OID 16571)
-- Name: customer customer_fk_1; Type: FK CONSTRAINT; Schema: Company; Owner: -
--

ALTER TABLE ONLY "Company".customer
    ADD CONSTRAINT customer_fk_1 FOREIGN KEY (account_id) REFERENCES "Company".account(account_id);


--
-- TOC entry 4300 (class 2606 OID 16576)
-- Name: customer customer_fk_2; Type: FK CONSTRAINT; Schema: Company; Owner: -
--

ALTER TABLE ONLY "Company".customer
    ADD CONSTRAINT customer_fk_2 FOREIGN KEY (group_id) REFERENCES "Company".customer_group(group_id);


--
-- TOC entry 4313 (class 2606 OID 16581)
-- Name: order customer_id_fk; Type: FK CONSTRAINT; Schema: Company; Owner: -
--

ALTER TABLE ONLY "Company"."order"
    ADD CONSTRAINT customer_id_fk FOREIGN KEY (customer_id) REFERENCES "Company".customer(customer_id);


--
-- TOC entry 4320 (class 2606 OID 16586)
-- Name: sale_info customer_id_fk; Type: FK CONSTRAINT; Schema: Company; Owner: -
--

ALTER TABLE ONLY "Company".sale_info
    ADD CONSTRAINT customer_id_fk FOREIGN KEY (customer_id) REFERENCES "Company".customer(customer_id);


--
-- TOC entry 4301 (class 2606 OID 16591)
-- Name: debt debt_fk; Type: FK CONSTRAINT; Schema: Company; Owner: -
--

ALTER TABLE ONLY "Company".debt
    ADD CONSTRAINT debt_fk FOREIGN KEY (customer_id) REFERENCES "Company".customer(customer_id);


--
-- TOC entry 4302 (class 2606 OID 16596)
-- Name: delivery_package delivery_package_fk; Type: FK CONSTRAINT; Schema: Company; Owner: -
--

ALTER TABLE ONLY "Company".delivery_package
    ADD CONSTRAINT delivery_package_fk FOREIGN KEY (transport_id) REFERENCES "Company".transport(transport_id);


--
-- TOC entry 4304 (class 2606 OID 16601)
-- Name: delivery_staff delivery_staff_fk; Type: FK CONSTRAINT; Schema: Company; Owner: -
--

ALTER TABLE ONLY "Company".delivery_staff
    ADD CONSTRAINT delivery_staff_fk FOREIGN KEY (employee_id) REFERENCES "Company".employee(employee_id);


--
-- TOC entry 4325 (class 2606 OID 16729)
-- Name: transport delivery_staff_fk; Type: FK CONSTRAINT; Schema: Company; Owner: -
--

ALTER TABLE ONLY "Company".transport
    ADD CONSTRAINT delivery_staff_fk FOREIGN KEY (delivery_staff_id) REFERENCES "Company".delivery_staff(employee_id);


--
-- TOC entry 4305 (class 2606 OID 16606)
-- Name: driver_staff driver_fk; Type: FK CONSTRAINT; Schema: Company; Owner: -
--

ALTER TABLE ONLY "Company".driver_staff
    ADD CONSTRAINT driver_fk FOREIGN KEY (employee_id) REFERENCES "Company".employee(employee_id);


--
-- TOC entry 4310 (class 2606 OID 16611)
-- Name: inside_transport driver_staff_fk; Type: FK CONSTRAINT; Schema: Company; Owner: -
--

ALTER TABLE ONLY "Company".inside_transport
    ADD CONSTRAINT driver_staff_fk FOREIGN KEY (driver_staff_id) REFERENCES "Company".driver_staff(employee_id);


--
-- TOC entry 4307 (class 2606 OID 16616)
-- Name: employee employee_fk; Type: FK CONSTRAINT; Schema: Company; Owner: -
--

ALTER TABLE ONLY "Company".employee
    ADD CONSTRAINT employee_fk FOREIGN KEY (manager_id) REFERENCES "Company".manager_staff(employee_id);


--
-- TOC entry 4321 (class 2606 OID 16621)
-- Name: sale_info goods_id_fk; Type: FK CONSTRAINT; Schema: Company; Owner: -
--

ALTER TABLE ONLY "Company".sale_info
    ADD CONSTRAINT goods_id_fk FOREIGN KEY (goods_id) REFERENCES "Company".goods(goods_id);


--
-- TOC entry 4308 (class 2606 OID 16626)
-- Name: goods_in_order goods_in_order_fk; Type: FK CONSTRAINT; Schema: Company; Owner: -
--

ALTER TABLE ONLY "Company".goods_in_order
    ADD CONSTRAINT goods_in_order_fk FOREIGN KEY (goods_id) REFERENCES "Company".goods(goods_id);


--
-- TOC entry 4309 (class 2606 OID 16631)
-- Name: goods_in_order goods_in_order_fk_1; Type: FK CONSTRAINT; Schema: Company; Owner: -
--

ALTER TABLE ONLY "Company".goods_in_order
    ADD CONSTRAINT goods_in_order_fk_1 FOREIGN KEY (order_id) REFERENCES "Company"."order"(order_id);


--
-- TOC entry 4311 (class 2606 OID 16636)
-- Name: inside_transport inside_transport_fk; Type: FK CONSTRAINT; Schema: Company; Owner: -
--

ALTER TABLE ONLY "Company".inside_transport
    ADD CONSTRAINT inside_transport_fk FOREIGN KEY (transport_id) REFERENCES "Company".transport(transport_id);


--
-- TOC entry 4312 (class 2606 OID 16641)
-- Name: inside_transport license_plate_fk; Type: FK CONSTRAINT; Schema: Company; Owner: -
--

ALTER TABLE ONLY "Company".inside_transport
    ADD CONSTRAINT license_plate_fk FOREIGN KEY (license_plate) REFERENCES "Company".vehicle(license_plate);


--
-- TOC entry 4322 (class 2606 OID 16646)
-- Name: sale_info order_id_fk; Type: FK CONSTRAINT; Schema: Company; Owner: -
--

ALTER TABLE ONLY "Company".sale_info
    ADD CONSTRAINT order_id_fk FOREIGN KEY (order_id) REFERENCES "Company"."order"(order_id);


--
-- TOC entry 4315 (class 2606 OID 16651)
-- Name: order_tracking order_tracking_fk; Type: FK CONSTRAINT; Schema: Company; Owner: -
--

ALTER TABLE ONLY "Company".order_tracking
    ADD CONSTRAINT order_tracking_fk FOREIGN KEY (customer_id) REFERENCES "Company".customer(customer_id);


--
-- TOC entry 4316 (class 2606 OID 16656)
-- Name: order_tracking order_tracking_fk_1; Type: FK CONSTRAINT; Schema: Company; Owner: -
--

ALTER TABLE ONLY "Company".order_tracking
    ADD CONSTRAINT order_tracking_fk_1 FOREIGN KEY (order_id) REFERENCES "Company"."order"(order_id);


--
-- TOC entry 4317 (class 2606 OID 16661)
-- Name: outside_transport outside_transport_fk; Type: FK CONSTRAINT; Schema: Company; Owner: -
--

ALTER TABLE ONLY "Company".outside_transport
    ADD CONSTRAINT outside_transport_fk FOREIGN KEY (transport_id) REFERENCES "Company".transport(transport_id);


--
-- TOC entry 4318 (class 2606 OID 16666)
-- Name: payment payment_fk; Type: FK CONSTRAINT; Schema: Company; Owner: -
--

ALTER TABLE ONLY "Company".payment
    ADD CONSTRAINT payment_fk FOREIGN KEY (customer_id) REFERENCES "Company".customer(customer_id);


--
-- TOC entry 4319 (class 2606 OID 16671)
-- Name: payment payment_fk_1; Type: FK CONSTRAINT; Schema: Company; Owner: -
--

ALTER TABLE ONLY "Company".payment
    ADD CONSTRAINT payment_fk_1 FOREIGN KEY (cashier_staff_id) REFERENCES "Company".cashier_staff(employee_id);


--
-- TOC entry 4314 (class 2606 OID 16676)
-- Name: order person_make_order_fk; Type: FK CONSTRAINT; Schema: Company; Owner: -
--

ALTER TABLE ONLY "Company"."order"
    ADD CONSTRAINT person_make_order_fk FOREIGN KEY (person_make_order_id) REFERENCES "Company".person_make_order(id);


--
-- TOC entry 4323 (class 2606 OID 16681)
-- Name: saler_staff person_make_order_id_fk; Type: FK CONSTRAINT; Schema: Company; Owner: -
--

ALTER TABLE ONLY "Company".saler_staff
    ADD CONSTRAINT person_make_order_id_fk FOREIGN KEY (person_make_order_id) REFERENCES "Company".person_make_order(id);


--
-- TOC entry 4303 (class 2606 OID 16686)
-- Name: delivery_package sale_info_id_fk; Type: FK CONSTRAINT; Schema: Company; Owner: -
--

ALTER TABLE ONLY "Company".delivery_package
    ADD CONSTRAINT sale_info_id_fk FOREIGN KEY (receipt_id) REFERENCES "Company".sale_info(receipt_id);


--
-- TOC entry 4324 (class 2606 OID 16691)
-- Name: saler_staff saler_staff_fk; Type: FK CONSTRAINT; Schema: Company; Owner: -
--

ALTER TABLE ONLY "Company".saler_staff
    ADD CONSTRAINT saler_staff_fk FOREIGN KEY (employee_id) REFERENCES "Company".employee(employee_id);


-- Completed on 2022-12-18 09:08:35

--
-- PostgreSQL database dump complete
--

