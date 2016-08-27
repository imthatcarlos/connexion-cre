--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.3
-- Dumped by pg_dump version 9.5.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- Name: alter_customer_tax(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION alter_customer_tax() RETURNS boolean
    LANGUAGE plpgsql
    AS $$
                BEGIN
                IF EXISTS (
                               SELECT 1 FROM information_schema.columns 
                                               WHERE  table_schema = 'public'
                                               AND table_name  = 'job_customer'
                                               AND column_name = 'tax_code'
                ) THEN
                               ALTER TABLE job_customer ALTER COLUMN tax_code TYPE varchar(255);
                               PERFORM update_tax_code ();
                               RETURN TRUE;
                ELSE
                               ALTER TABLE job_customer ADD COLUMN tax_code varchar(255);
                               PERFORM update_tax_code ();
                               RETURN FALSE;
                END if;
END;
$$;


--
-- Name: alter_customer_tax(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION alter_customer_tax(_tbl text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
	BEGIN
	IF EXISTS (
		SELECT 1 FROM information_schema.columns 
			WHERE  table_schema = 'public'
			AND table_name  = _tbl
			AND column_name = 'tax_exempt_number'
	) THEN
--		 ALTER TABLE job_customer ADD COLUMN tax_code varchar(255);
		 UPDATE job_customer SET tax_code = tax_exempt_number;
		 ALTER TABLE job_customer DROP COLUMN tax_exempt_number;
		RETURN TRUE;
	ELSE
		RETURN FALSE;
	END if;
END;
$$;


--
-- Name: alter_job_document_log_table(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION alter_job_document_log_table(_col text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
	BEGIN

	-- IF EXISTS clause was not added to DROP COLUMN until postgres v9.  
	-- This function is backwards compatible on v8 sites.
	IF EXISTS (
		-- confirm that the table/column exists.  
		SELECT 1 
		FROM information_schema.columns 
		WHERE  table_schema = 'public'
		AND table_name  = 'job_document_log'
		AND column_name = _col
		) THEN
		EXECUTE 'ALTER TABLE job_document_log ALTER COLUMN ' || _col || ' TYPE INTEGER';
		EXECUTE 'UPDATE job_document_log SET ' || _col || ' = 0 WHERE ' || _col || ' IS NULL';
		EXECUTE 'ALTER TABLE job_document_log ALTER COLUMN ' || _col || ' SET NOT NULL ';
		RETURN TRUE;
	ELSE
		EXECUTE 'ALTER TABLE job_document_log ADD COLUMN ' || _col || ' INTEGER NOT NULL DEFAULT 0';
		RETURN FALSE;
	END IF;
END;
$$;


--
-- Name: alter_job_fixtcomp_table(text, text, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION alter_job_fixtcomp_table(_tbl text, _col text, _type text, _default text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
	BEGIN

	-- IF EXISTS clause was not added to DROP COLUMN until postgres v9.  
	-- This function is backwards compatible on v8 sites.
	IF EXISTS (
		-- confirm that the table/column exists.  
		SELECT 1 
		FROM information_schema.columns 
		WHERE  table_schema = 'public'
		AND table_name  = _tbl
		AND column_name = _col
		) THEN
		EXECUTE 'ALTER TABLE ' || _tbl || ' ALTER COLUMN ' || _col || ' TYPE ' ||  _type ;
		EXECUTE 'UPDATE ' || _tbl || ' SET ' || _col || ' = '  || _default ||' WHERE ' || _col || ' IS NULL';
		EXECUTE 'ALTER TABLE ' || _tbl || ' ALTER COLUMN ' || _col || ' SET NOT NULL ';
		RETURN TRUE;
	ELSE
		EXECUTE 'ALTER TABLE ' || _tbl || ' ADD COLUMN ' || _col || ' ' || _type  ||' NOT NULL DEFAULT ' || _default;
		RETURN FALSE;
	END IF;
END;
$$;


--
-- Name: alter_job_order_table(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION alter_job_order_table(_tbl text, _col text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
	BEGIN

	-- IF EXISTS clause was not added to DROP COLUMN until postgres v9.  
	-- This function is backwards compatible on v8 sites.
	IF EXISTS (
		-- confirm that the table/column exists.  
		SELECT 1 
		FROM information_schema.columns 
		WHERE  table_schema = 'public'
		AND table_name  = _tbl
		AND column_name = _col
		) THEN
		EXECUTE 'ALTER TABLE ' || _tbl || ' ALTER COLUMN ' || _col || ' TYPE BOOLEAN ';
		EXECUTE 'UPDATE ' || _tbl || ' SET ' || _col || ' = TRUE WHERE ' || _col || ' IS NULL';
		EXECUTE 'ALTER TABLE ' || _tbl || ' ALTER COLUMN ' || _col || ' SET NOT NULL ';
		RETURN TRUE;
	ELSE
		EXECUTE 'ALTER TABLE ' || _tbl || ' ADD COLUMN ' || _col || ' BOOLEAN NOT NULL DEFAULT TRUE ';
		RETURN FALSE;
	END IF;
END;
$$;


--
-- Name: convert_time_zone(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION convert_time_zone(_new_time_col text) RETURNS void
    LANGUAGE plpgsql
    AS $$
	BEGIN

	-- Step 1 - see if the old time column exists.  If it does then the script has not been run
	-- Step 2 - Create the new time column . 
	-- Step 3 - Convert data from old to new time columns 
	-- Step 4 - drop old columns. 
	IF EXISTS (
		-- step 1
		SELECT 1 
		FROM information_schema.columns 
		WHERE  table_schema = 'public'
		AND table_name  = 'job_project'
		AND column_name = 'bid_time'
		) THEN
		
		--- step 2
		PERFORM drop_table_column_if_exists ('job_project' , _new_time_col);
		EXECUTE 'ALTER TABLE job_project ADD COLUMN ' || _new_time_col || ' timestamp without time zone';

		-- step 3
		-- The following links were useful in creating this command:
		--   Add date to int (that should be time) : http://www.postgresql.org/docs/8.4/static/functions-datetime.html
		--   to_char to create interval string from db column : http://www.postgresql.org/docs/8.4/static/functions-formatting.html
		--   Cast string as interval : http://stackoverflow.com/questions/9376350/postgresql-how-to-concat-interval-value-2-days
		--   Escape single quote : http://stackoverflow.com/questions/12316953/insert-varchar-with-single-quotes-in-postgresql
		EXECUTE 'UPDATE job_project set ' || _new_time_col || ' = bid_date + to_char(bid_time, ''FM9999" minutes"'')::interval';
		EXECUTE 'ALTER TABLE job_project ALTER COLUMN ' || _new_time_col || ' SET NOT NULL ';
		
		-- step 4
		PERFORM drop_table_column_if_exists ('job_project' , 'bid_time');
		PERFORM drop_table_column_if_exists ('job_project' , 'bid_date');
		
		RETURN ;
	ELSE
		-- DO nothing script has already run
		RETURN;
	END IF;
END;
$$;


--
-- Name: create_gl_debit_table(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION create_gl_debit_table(_tbl text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
	BEGIN

	-- IF EXISTS clause was not added to DROP COLUMN until postgres v9.  
	-- This function is backwards compatible on v8 sites.
	IF EXISTS (
		-- confirm that the table/column exists.  
		SELECT 1 
		FROM information_schema.columns 
		WHERE  table_schema = 'public'
		AND table_name  = _tbl
		) THEN
			ALTER TABLE job_gl_debit ALTER COLUMN id TYPE INTEGER;
			ALTER TABLE job_gl_debit ALTER COLUMN id SET NOT NULL;
			ALTER TABLE job_gl_debit ALTER COLUMN bom_id TYPE INTEGER;
			ALTER TABLE job_gl_debit ALTER COLUMN bom_id SET NOT NULL;
			ALTER TABLE job_gl_debit ALTER COLUMN vendor_id TYPE INTEGER;
			ALTER TABLE job_gl_debit ALTER COLUMN vendor_id SET NOT NULL;
			ALTER TABLE job_gl_debit ALTER COLUMN vendor_name TYPE VARCHAR(256);
			ALTER TABLE job_gl_debit ALTER COLUMN vendor_name SET NOT NULL;
			ALTER TABLE job_gl_debit ALTER COLUMN transaction_id TYPE VARCHAR(256);
			ALTER TABLE job_gl_debit ALTER COLUMN transaction_id SET NOT NULL;
			ALTER TABLE job_gl_debit ALTER COLUMN total_sell TYPE NUMERIC(19,2);
			ALTER TABLE job_gl_debit ALTER COLUMN total_sell SET NOT NULL;
			ALTER TABLE job_gl_debit ALTER COLUMN transaction_date TYPE DATE;
			ALTER TABLE job_gl_debit ALTER COLUMN transaction_date SET NOT NULL;
			ALTER TABLE job_gl_debit ALTER COLUMN transaction_time TYPE TIME WITHOUT TIME ZONE;
			ALTER TABLE job_gl_debit ALTER COLUMN transaction_time SET NOT NULL;
			ALTER TABLE job_gl_debit ALTER COLUMN stock_pn TYPE VARCHAR(256);
			ALTER TABLE job_gl_debit ALTER COLUMN stock_pn SET NOT NULL;
			ALTER TABLE job_gl_debit ALTER COLUMN description TYPE VARCHAR(256);
			ALTER TABLE job_gl_debit ALTER COLUMN comment TYPE VARCHAR(256);
			ALTER TABLE job_gl_debit ALTER COLUMN order_by TYPE VARCHAR(256);
			ALTER TABLE job_gl_debit ALTER COLUMN payable_id TYPE VARCHAR(256);
			ALTER TABLE job_gl_debit ALTER COLUMN payable_id SET NOT NULL;		
		RETURN TRUE;
	ELSE
		CREATE TABLE job_gl_debit (
			id INTEGER PRIMARY KEY NOT NULL,
			bom_id INTEGER NOT NULL,
			vendor_id INTEGER NOT NULL,
			vendor_name VARCHAR(256) NOT NULL,
			transaction_id VARCHAR(256) NOT NULL,
			total_sell NUMERIC(19,2) NOT NULL,
			transaction_date DATE NOT NULL,
			transaction_time TIME WITHOUT TIME ZONE NOT NULL,
			stock_pn VARCHAR(256) NOT NULL,
			description VARCHAR(256),
			comment VARCHAR(256),
			order_by VARCHAR(256),
			payable_id VARCHAR(256) NOT NULL
		);
		RETURN FALSE;
	END IF;
END;
$$;


--
-- Name: create_log_table(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION create_log_table(_tbl text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
	BEGIN

	-- IF EXISTS clause was not added to DROP COLUMN until postgres v9.  
	-- This function is backwards compatible on v8 sites.
	IF EXISTS (
		-- confirm that the table/column exists.  
		SELECT 1 
		FROM information_schema.columns 
		WHERE  table_schema = 'public'
		AND table_name  = _tbl
		) THEN
			ALTER TABLE job_change_order_log ALTER COLUMN id TYPE INTEGER;
			ALTER TABLE job_change_order_log ALTER COLUMN id SET NOT NULL;
			ALTER TABLE job_change_order_log ALTER COLUMN user_id TYPE VARCHAR(15);
			ALTER TABLE job_change_order_log ALTER COLUMN user_id SET NOT NULL;
			ALTER TABLE job_change_order_log ALTER COLUMN date TYPE DATE;
			ALTER TABLE job_change_order_log ALTER COLUMN date SET NOT NULL;
			ALTER TABLE job_change_order_log ALTER COLUMN time TYPE TIME WITHOUT TIME ZONE;
			ALTER TABLE job_change_order_log ALTER COLUMN time SET NOT NULL;
			ALTER TABLE job_change_order_log ALTER COLUMN comment TYPE VARCHAR(256);
			ALTER TABLE job_change_order_log ALTER COLUMN comment SET NOT NULL;
			ALTER TABLE job_change_order_log ALTER COLUMN cust_change_fk TYPE INTEGER;
			ALTER TABLE job_change_order_log ALTER COLUMN cust_change_fk SET NOT NULL;		
		RETURN TRUE;
	ELSE
		CREATE TABLE job_change_order_log (
			id INTEGER PRIMARY KEY NOT NULL,
			user_id VARCHAR(15) NOT NULL,
			date DATE NOT NULL,
			time TIME WITHOUT TIME ZONE NOT NULL,
			comment VARCHAR(256) NOT NULL,
			cust_change_fk INTEGER NOT NULL
		);
		RETURN FALSE;
	END IF;
END;
$$;


--
-- Name: drop_constraint_if_exists(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION drop_constraint_if_exists(t_name text, c_name text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Look for our constraint
    IF EXISTS (SELECT constraint_name 
                   FROM information_schema.constraint_column_usage 
                   WHERE table_name = t_name AND constraint_name = c_name) THEN
        EXECUTE 'ALTER TABLE job_order DROP CONSTRAINT bom_vendor';
		RETURN TRUE;
    ELSE RETURN FALSE;	
    END IF;
END;
$$;


--
-- Name: drop_table_column_if_exists(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION drop_table_column_if_exists(_tbl text, _col text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
	BEGIN

	-- IF EXISTS clause was not added to DROP COLUMN until postgres v9.  
	-- This function is backwards compatible on v8 sites.
	IF EXISTS (
		-- confirm that the table/column exists.  
		SELECT 1 
		FROM information_schema.columns 
		WHERE  table_schema = 'public'
		AND table_name  = _tbl
		AND column_name = _col
		) THEN
		EXECUTE 'ALTER TABLE ' || _tbl || ' DROP COLUMN ' || _col;
		RETURN TRUE;
	ELSE
		RETURN FALSE;
	END IF;
END;
$$;


--
-- Name: update_tax_code(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION update_tax_code() RETURNS boolean
    LANGUAGE plpgsql
    AS $$
                BEGIN
                IF EXISTS (
                               SELECT 1 FROM information_schema.columns
                                               WHERE table_schema = 'public'
                                               AND table_name = 'job_customer'
                                               AND column_name = 'tax_exempt_number'
                ) THEN
                               UPDATE job_customer SET tax_code = tax_exempt_number;
                               ALTER TABLE job_customer DROP COLUMN tax_exempt_number;
                               RETURN TRUE;
                ELSE
                               RETURN FALSE;
                END if;
END;
$$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: job_component; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_component (
    fixture_id bigint NOT NULL,
    description character varying(255),
    quantity integer NOT NULL,
    stock_pn character varying NOT NULL,
    matrix_cell character varying(255),
    create_stamp timestamp without time zone NOT NULL,
    uom character varying(255),
    submittal_status character varying(255),
    has_notes boolean,
    addl_desc character varying(255),
    customer_item_fk bigint,
    total_id bigint,
    vendor_item_fk bigint,
    fixture_fk bigint,
    update_stamp date,
    qty_uom character varying(255),
    um_qty integer,
    pricing_uom character varying(255),
    price_per_qty integer,
    ns_stock boolean,
    order_number character varying(255),
    classification character varying(255),
    prod_cat character varying(255),
    prod_line character varying(255),
    draft_item boolean NOT NULL,
    vendor_pricing_vendor integer NOT NULL,
    customer_po character varying(255)
);


--
-- Name: job_cost; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_cost (
    id bigint NOT NULL,
    cost numeric(19,3) NOT NULL,
    formula character varying(255),
    vendor_id integer,
    extended_cost numeric(19,2),
    received_cost numeric(19,2) DEFAULT 0 NOT NULL,
    returned_cost numeric(19,2) DEFAULT 0 NOT NULL,
    received_return_cost numeric(19,2) DEFAULT 0 NOT NULL
);


--
-- Name: job_fixture; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_fixture (
    fixture_id bigint NOT NULL,
    description character varying(255),
    quantity integer NOT NULL,
    stock_pn character varying NOT NULL,
    matrix_cell character varying(255),
    create_stamp timestamp without time zone NOT NULL,
    uom character varying(255),
    submittal_status character varying(255),
    has_notes boolean,
    addl_desc character varying(255),
    fixture_type character varying(255),
    sort_order character varying(255),
    vendor_item_fk bigint,
    customer_item_fk bigint,
    bom_fk integer,
    total_id bigint,
    update_stamp date,
    qty_uom character varying(255),
    um_qty integer,
    pricing_uom character varying(255),
    price_per_qty integer,
    ns_stock boolean,
    order_number character varying(255),
    prod_cat character varying(255),
    prod_line character varying(255),
    draft_item boolean NOT NULL,
    vendor_pricing_vendor integer NOT NULL,
    customer_po character varying(255)
);


--
-- Name: job_quote; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_quote (
    id bigint NOT NULL,
    price numeric(19,3),
    extended_price numeric(19,2),
    margin numeric(19,6),
    markup numeric(19,6),
    returned_price numeric(19,2),
    received_price numeric(19,2) DEFAULT 0 NOT NULL,
    received_return_price numeric(19,2) DEFAULT 0 NOT NULL
);


--
-- Name: ProductHistoryView; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW "ProductHistoryView" AS
 SELECT fixture.fixture_id AS id,
    fixture.stock_pn AS pn,
    upper(textcat((fixture.description)::text, (fixture.addl_desc)::text)) AS description,
    vquote.cost,
    cquote.price AS sell,
    fixture.create_stamp
   FROM job_fixture fixture,
    job_cost vquote,
    job_quote cquote
  WHERE ((fixture.vendor_item_fk = vquote.id) AND (fixture.customer_item_fk = cquote.id))
UNION
 SELECT component.fixture_id AS id,
    component.stock_pn AS pn,
    upper(textcat((component.description)::text, (component.addl_desc)::text)) AS description,
    vquote.cost,
    cquote.price AS sell,
    component.create_stamp
   FROM job_component component,
    job_cost vquote,
    job_quote cquote
  WHERE ((component.vendor_item_fk = vquote.id) AND (component.customer_item_fk = cquote.id))
  ORDER BY 2;


--
-- Name: job_adjustment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_adjustment (
    id integer NOT NULL,
    bom_id integer,
    cost numeric(19,2),
    sell numeric(19,2),
    transaction_date date,
    transaction_id character varying(255),
    transaction_time time without time zone,
    vendor_id integer,
    vendor_name character varying(255)
);


--
-- Name: job_change; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_change (
    id integer NOT NULL,
    vendor_name character varying(255),
    ship_via character varying(255),
    internal_notes text,
    vendor_id integer,
    transaction_id character varying(255),
    total_cost numeric(19,2),
    shipping_notes text,
    transaction_date date,
    transaction_time time without time zone,
    total_sell numeric(19,2),
    freight_terms character varying(255),
    bom_id integer,
    status integer,
    original_po boolean,
    pending_count integer,
    address_id integer,
    document_fk character varying(255),
    customer_fk integer,
    releasematerial boolean,
    processing_status integer,
    batch_id character varying(255),
    external_date date
);


--
-- Name: job_cust_change; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_cust_change (
    id integer NOT NULL,
    status integer,
    customer_id integer,
    internal_notes text,
    change_number character varying(255),
    reason_for_change text,
    total_cost numeric(19,2),
    follow_up_date timestamp without time zone,
    transaction_date date,
    transaction_time time without time zone,
    po_number character varying(255),
    total_sell numeric(19,2),
    bom_id integer,
    approval_notes text,
    approved_by character varying(255),
    initiated_by character varying(255),
    supress_customer boolean,
    supress_vendor boolean,
    created_by character varying(255),
    new_customer_po boolean,
    internal_change boolean,
    document_fk character varying(255),
    processing_status integer,
    freight_in_exempt boolean
);


--
-- Name: job_fee_change; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_fee_change (
    id integer NOT NULL,
    rep_id integer,
    fee_change numeric(19,2),
    status integer,
    name character varying(255),
    purchase_order character varying(255),
    bom_id integer,
    transaction_date date,
    transaction_time time without time zone,
    customerchange_id integer,
    fee_id integer,
    processing_status integer
);


--
-- Name: job_fees; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_fees (
    id integer NOT NULL,
    fee numeric(19,2),
    transaction_date date,
    transaction_time time without time zone,
    received_amount numeric(19,2),
    purchase_order character varying(255),
    bom_id integer,
    fee_change numeric(19,2)
);


--
-- Name: job_order; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_order (
    id integer NOT NULL,
    vendor_name character varying(255),
    ship_via character varying(255),
    internal_notes text,
    vendor_id integer,
    hold_id character varying(255),
    total_cost numeric(19,2),
    shipping_notes text,
    transaction_date date,
    transaction_time time without time zone,
    total_sell numeric(19,2),
    freight_terms character varying(255),
    bom_id integer,
    source integer,
    ship_date date,
    reserve_date date,
    po_num character varying(255),
    address_id integer,
    vendorquote_id integer,
    document_fk character varying(255),
    original_po boolean NOT NULL,
    batch_id character varying(255),
    external_date date
);


--
-- Name: job_receive; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_receive (
    id integer NOT NULL,
    vendor_name character varying(255),
    vendor_id integer,
    transaction_id character varying(255),
    payable_id character varying(255),
    total_cost numeric(19,2),
    transaction_date date,
    transaction_time time without time zone,
    total_sell numeric(19,2),
    reconcile_amt numeric(19,2),
    bom_id integer,
    fee_payable character varying(255),
    fee_fk integer,
    fee_amount numeric(19,2)
);


--
-- Name: job_release; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_release (
    id integer NOT NULL,
    vendor_name character varying(255),
    ship_via character varying(255),
    internal_notes text,
    vendor_id integer,
    transaction_id character varying(255),
    total_cost numeric(19,2),
    shipping_notes text,
    transaction_date date,
    transaction_time time without time zone,
    total_sell numeric(19,2),
    freight_terms character varying(255),
    bom_id integer,
    external_date date,
    release_number character varying(255),
    internal_date date,
    truck_number character varying(255),
    document_fk character varying(255),
    address_id integer,
    batch_id character varying(255)
);


--
-- Name: job_return; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_return (
    id integer NOT NULL,
    vendor_name character varying(255),
    ship_via character varying(255),
    internal_notes text,
    vendor_id integer,
    transaction_id character varying(255),
    total_cost numeric(19,2),
    shipping_notes text,
    transaction_date date,
    transaction_time time without time zone,
    total_sell numeric(19,2),
    freight_terms character varying(255),
    bom_id integer,
    reason_return character varying(255),
    return_oid character varying(255),
    misc_amount numeric(19,2),
    address_id integer,
    document_fk character varying(255),
    transaction_type integer,
    misc_credit_amount numeric(19,2),
    batch_id character varying(255),
    external_date date
);


--
-- Name: job_vendor; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_vendor (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    job_id integer,
    actor_id integer,
    vendor_short_name character varying(255),
    frieght_terms character varying(255),
    rep boolean,
    next_po character varying(255),
    ship_from_br character varying(255),
    shipping_instr text,
    ship_via character varying(255),
    ship_from integer,
    address_fk integer,
    shipaddress_fk integer,
    quote_number character varying(255),
    payment_terms character varying(255),
    vendor_type integer
);


--
-- Name: TransactionSummaryView; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW "TransactionSummaryView" AS
 SELECT job_order.vendor_id,
    job_order.vendor_name,
    job_order.transaction_date AS ship_date,
    job_order.po_num,
    job_order.hold_id,
    job_order.total_cost,
    job_order.total_sell,
    'purchaseOrder'::text AS order_code,
    job_order.document_fk,
    job_order.bom_id,
    job_order.id,
    job_order.transaction_time
   FROM job_order
  WHERE (job_order.source <> 8)
UNION
 SELECT vendor.actor_id AS vendor_id,
    vendor.name AS vendor_name,
    fee.transaction_date AS ship_date,
    ''::character varying AS po_num,
    fee.purchase_order AS hold_id,
    fee.fee AS total_cost,
    0.00 AS total_sell,
    'engineFee'::text AS order_code,
    ''::character varying AS document_fk,
    fee.bom_id,
    fee.id,
    fee.transaction_time
   FROM job_fees fee,
    job_vendor vendor
  WHERE (((fee.purchase_order)::text <> ''::text) AND (fee.id = vendor.id))
UNION
 SELECT fee.rep_id AS vendor_id,
    fee.name AS vendor_name,
    fee.transaction_date AS ship_date,
    ''::character varying AS po_num,
    fee.purchase_order AS hold_id,
    fee.fee_change AS total_cost,
    0.00 AS total_sell,
    'engineChangeFee'::text AS order_code,
    ''::character varying AS document_fk,
    fee.bom_id,
    fee.id,
    fee.transaction_time
   FROM job_fee_change fee
  WHERE (fee.status = 1)
UNION
 SELECT jc.vendor_id,
    jc.vendor_name,
    jc.transaction_date AS ship_date,
    jcc.change_number AS po_num,
    jc.transaction_id AS hold_id,
    jc.total_cost,
    jc.total_sell,
    'changeOrder'::text AS order_code,
    jc.document_fk,
    jc.bom_id,
    jc.id,
    jc.transaction_time
   FROM job_change jc,
    job_cust_change jcc
  WHERE (((jc.status = 1) OR ((jc.status = 2) AND ((jc.total_cost <> (0)::numeric) OR (jc.total_sell <> (0)::numeric)))) AND (jc.customer_fk = jcc.id))
UNION
 SELECT job_receive.vendor_id,
    job_receive.vendor_name,
    job_receive.transaction_date AS ship_date,
    ''::character varying AS po_num,
    job_receive.payable_id AS hold_id,
    job_receive.total_cost,
    job_receive.total_sell,
    'receiveOrder'::text AS order_code,
    ''::character varying AS document_fk,
    job_receive.bom_id,
    job_receive.id,
    job_receive.transaction_time
   FROM job_receive
UNION
 SELECT job_release.vendor_id,
    job_release.vendor_name,
    job_release.transaction_date AS ship_date,
    ''::character varying AS po_num,
    job_release.transaction_id AS hold_id,
    job_release.total_cost,
    job_release.total_sell,
    'salesOrder'::text AS order_code,
    job_release.document_fk,
    job_release.bom_id,
    job_release.id,
    job_release.transaction_time
   FROM job_release
  WHERE (job_release.vendor_id = '-1'::integer)
UNION
 SELECT job_adjustment.vendor_id,
    job_adjustment.vendor_name,
    job_adjustment.transaction_date AS ship_date,
    ''::character varying AS po_num,
    job_adjustment.transaction_id AS hold_id,
    job_adjustment.cost AS total_cost,
    job_adjustment.sell AS total_sell,
    'totalsAdjustment'::text AS order_code,
    ''::character varying AS document_fk,
    job_adjustment.bom_id,
    job_adjustment.id,
    job_adjustment.transaction_time
   FROM job_adjustment
UNION
 SELECT job_return.vendor_id,
    job_return.vendor_name,
    job_return.transaction_date AS ship_date,
    ''::character varying AS po_num,
    job_return.transaction_id AS hold_id,
    job_return.total_cost,
    job_return.total_sell,
        CASE job_return.transaction_type
            WHEN 12 THEN 'cancelReturnOrder'::text
            ELSE 'returnOrder'::text
        END AS order_code,
    job_return.document_fk,
    job_return.bom_id,
    job_return.id,
    job_return.transaction_time
   FROM job_return
  ORDER BY 3;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: hibernate_sequence; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE hibernate_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_active_session; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_active_session (
    sessionid character varying(255) NOT NULL,
    login_time character varying(255),
    user_id timestamp without time zone,
    node character varying(255)
);


--
-- Name: job_activity; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_activity (
    username character varying(255) NOT NULL,
    jobid integer NOT NULL,
    activity_date date,
    activity_time time without time zone
);


--
-- Name: job_actor; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_actor (
    id integer NOT NULL,
    job_id integer,
    manager_id character varying(255),
    manager_name character varying(255),
    type integer NOT NULL,
    user_id character varying(255) NOT NULL,
    user_name character varying(255) NOT NULL
);


--
-- Name: job_address; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_address (
    id integer NOT NULL,
    name character varying(255),
    state character varying(255),
    country character varying(255),
    addl_address character varying(255),
    city character varying(255),
    phone character varying(255),
    street character varying(255),
    zipcode character varying(255),
    email character varying(255),
    fax character varying(255),
    addl_name character varying(255)
);


--
-- Name: job_address_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE job_address_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_adjustment_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE job_adjustment_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_admin_default; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_admin_default (
    name character varying(20) NOT NULL,
    value_id character varying(255) NOT NULL
);


--
-- Name: job_alternatives; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_alternatives (
    id integer NOT NULL,
    alt_bom_id integer,
    bom_id integer,
    name character varying(255),
    substituted boolean
);


--
-- Name: job_bom; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_bom (
    id integer NOT NULL,
    optlock integer,
    category character varying(255),
    description character varying(255),
    job_id integer,
    stock_on_hold date,
    transaction_time time without time zone,
    total_margin numeric(19,6),
    total_markup numeric(19,6),
    total_ext_cost numeric(19,2),
    total_ext_price numeric(19,2),
    active_schedule boolean,
    lock_cost boolean,
    lock_sell boolean,
    default_customer character varying(255),
    rows_per_page integer,
    type integer,
    quote_number character varying(255)
);


--
-- Name: job_bom_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE job_bom_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_category; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_category (
    name character varying(255) NOT NULL,
    job_icon integer,
    description character varying(255),
    prod_category character varying(255),
    prod_line character varying(255)
);


--
-- Name: job_change_item; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_change_item (
    id bigint NOT NULL,
    transaction_qty integer,
    new_description character varying(255),
    status integer,
    new_price numeric(19,3),
    new_cost numeric(19,3),
    new_stock_pn character varying,
    new_vendor integer,
    new_extended_cost numeric(19,2),
    new_extended_price numeric(19,2),
    new_fixture_type character varying(255),
    old_description character varying(255),
    old_status integer,
    old_quantity integer,
    extend boolean,
    old_cost numeric(19,3),
    old_fixture_type character varying(255),
    old_price numeric(19,3),
    old_extended_cost numeric(19,2),
    old_extended_price numeric(19,2),
    fixture_fk bigint,
    order_fk integer,
    component_fk bigint,
    transaction_fkey integer,
    qty_uom character varying(255),
    old_qty_uom character varying(255),
    um_qty integer,
    old_um_qty integer,
    pricing_uom character varying(255),
    old_pricing_uom character varying(255),
    price_per_qty integer,
    old_price_per_qty integer,
    hfr_quantity integer
);


--
-- Name: job_change_item_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE job_change_item_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_change_log_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE job_change_log_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_change_order_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_change_order_log (
    id integer NOT NULL,
    comment text NOT NULL,
    date date NOT NULL,
    "time" time without time zone NOT NULL,
    user_id character varying(15) NOT NULL,
    cust_change_fk integer NOT NULL
);


--
-- Name: job_change_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE job_change_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_competitor; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_competitor (
    name character varying(255) NOT NULL
);


--
-- Name: job_component_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE job_component_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_contact; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_contact (
    id integer NOT NULL,
    contact_id integer,
    contact_method character varying(255),
    address_fk integer
);


--
-- Name: job_contact_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE job_contact_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_cost_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE job_cost_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_cust_change_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE job_cust_change_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_customer; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_customer (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    job_id integer,
    actor_id integer,
    inside_sales character varying(255),
    outside_sales character varying(255),
    sales_source character varying(255),
    credit_br character varying(255),
    ship_to character varying,
    customer_po character varying(255),
    dflt_cfrt_terms character varying(255),
    dflt_vfrt_terms character varying(255),
    freight_in_exempt boolean,
    ship_from_br character varying(255),
    ship_via_cust character varying(255),
    ship_via_vend character varying(255),
    shipping_instr text,
    override_address boolean,
    shipaddress_fk integer,
    address_fk integer,
    main_contact_fk integer,
    awarded_date date,
    use_alternate_address boolean,
    altaddress_fk integer,
    ship_via_cust_direct character varying(255),
    alt_contact_fk integer,
    shipto_index character varying(255),
    tax_code character varying(255)
);


--
-- Name: job_customer_job_contact; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_customer_job_contact (
    job_customer_id integer NOT NULL,
    alternatecontacts_id integer NOT NULL
);


--
-- Name: job_customer_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE job_customer_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_document_defaults; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_document_defaults (
    id character varying(255) NOT NULL,
    bid_print_style boolean,
    bid_hide_comp boolean,
    bid_roll_comp boolean,
    bid_hide_ext_pricing boolean,
    bid_hide_vendor boolean,
    bid_ship_instr integer,
    rfq_only_vendor_items boolean,
    rfq_exclude_stock boolean,
    rfq_vend_instr integer,
    sub_for_approval boolean,
    sub_hide_comp boolean,
    res_show_line_info boolean,
    res_show_cost boolean,
    hfr_vend_instr integer,
    rel_show_cost boolean,
    rel_vend_instr integer,
    cust_disp_changed boolean,
    cust_ship_instr integer,
    vend_orig_po boolean,
    vend_release_now boolean,
    vend_disp_changed boolean,
    vend_instr integer,
    bid_subtotal_comp boolean DEFAULT false,
    res_subtotal_comp boolean DEFAULT false,
    hfr_subtotal_comp boolean DEFAULT false,
    rel_subtotal_comp boolean DEFAULT false,
    hfr_return_instr integer,
    cust_change_show_lot_line boolean,
    hfr_show_lot_line boolean,
    rel_show_lot_line boolean,
    res_show_lot_line boolean,
    vend_change_new_po_form integer,
    vend_change_show_lot_line boolean,
    bid_alternative_total_type integer,
    sub_hide_qty boolean,
    sub_hide_vendor boolean,
    bid_hide_comp_qty boolean,
    rep_print_open_qty boolean,
    rep_zero_qty boolean,
    vend_neg_use_hfr_qty boolean,
    bid_hide_zero_qty boolean,
    rel_show_billto_addr boolean,
    rfq_show_billto_addr boolean,
    vend_show_billto_addr boolean,
    cust_disp_change_value boolean,
    bid_hide_totals boolean,
    ack_title character varying(255),
    bid_address_opt integer,
    bid_show_pm boolean,
    bid_title character varying(255),
    cust_title character varying(255),
    hfr_title character varying(255),
    rel_title character varying(255),
    rep_title character varying(255),
    res_title character varying(255),
    ret_title character varying(255),
    rfq_title character varying(255),
    sub_title character varying(255),
    vend_title character varying(255),
    bid_only_items_on_order boolean
);


--
-- Name: job_document_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_document_log (
    document_name character varying(255) NOT NULL,
    transaction_type integer,
    user_name character varying(255),
    job_id integer,
    archive_path character varying(255),
    customer_document boolean,
    xml_document text,
    po_number character varying(255),
    generated_date date,
    generated_time time without time zone,
    recipient_name character varying(255),
    recipient_id character varying(255),
    document_action integer,
    transaction_detail text,
    transaction_prefix character varying(255),
    order_number character varying(255),
    faxstatus integer,
    notes text,
    resend_number integer NOT NULL
);


--
-- Name: job_document_props; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_document_props (
    document_definition character varying(255) NOT NULL,
    password character varying(255),
    user_name character varying(255),
    forms_path character varying(255),
    pdf_path character varying(255),
    archive_path character varying(255),
    archive_method integer,
    email_server character varying(255),
    fax_server character varying(255),
    fax_prefix character varying(255),
    logo_path character varying(255),
    webserviceurl character varying(255),
    formscapexmlpath character varying(255),
    email_from character varying(255),
    form_defaults_pricebr boolean
);


--
-- Name: job_fee_change_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE job_fee_change_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_fixture_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE job_fixture_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_form_note_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE job_form_note_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_form_notes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_form_notes (
    id integer NOT NULL,
    source character varying(255) NOT NULL,
    form_id integer,
    form_area integer,
    branch character varying(255),
    job_type character varying(255)
);


--
-- Name: job_gl_debit; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_gl_debit (
    id integer NOT NULL,
    bom_id integer NOT NULL,
    comment character varying(256),
    description character varying(256),
    order_by character varying(256),
    payable_id character varying(256) NOT NULL,
    stock_pn character varying(256) NOT NULL,
    total_sell numeric(19,2) NOT NULL,
    transaction_date date NOT NULL,
    transaction_id character varying(256) NOT NULL,
    transaction_time time without time zone NOT NULL,
    vendor_id integer NOT NULL,
    vendor_name character varying(256) NOT NULL
);


--
-- Name: job_gldebit_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE job_gldebit_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_ledger; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_ledger (
    job_id integer NOT NULL,
    bom_id integer,
    original_cost numeric(19,2),
    original_sell numeric(19,2),
    original_margin numeric(19,6),
    change_cost numeric(19,2),
    change_sell numeric(19,2),
    change_margin numeric(19,6),
    current_cost numeric(19,2),
    current_sell numeric(19,2),
    current_margin numeric(19,6),
    percent_complete numeric(19,2) DEFAULT 0.00 NOT NULL,
    ar_billed numeric(19,2),
    ap_billed numeric(19,2),
    total_job_cost numeric(19,2) DEFAULT 0.00 NOT NULL,
    bidding_sell numeric(19,2) DEFAULT 0.00 NOT NULL
);


--
-- Name: job_line_status; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_line_status (
    name character varying(255) NOT NULL,
    action character varying(255)
);


--
-- Name: job_log_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE job_log_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_logos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_logos (
    classifier character varying(255) NOT NULL,
    type integer NOT NULL,
    path character varying(255),
    document_fk character varying(255)
);


--
-- Name: job_lost_reason; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_lost_reason (
    name character varying(255) NOT NULL,
    description character varying(255)
);


--
-- Name: job_note_entry; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_note_entry (
    note_id integer NOT NULL,
    note_key character varying(255) NOT NULL
);


--
-- Name: job_note_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE job_note_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_notes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_notes (
    id integer NOT NULL,
    content text,
    source integer,
    user_id character varying(255),
    create_date date,
    createtask boolean NOT NULL,
    doc_area integer,
    display_type integer
);


--
-- Name: job_opened_job; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_opened_job (
    job_id integer NOT NULL,
    sessionid character varying(255)
);


--
-- Name: job_overrides; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_overrides (
    user_id character varying(255) NOT NULL,
    ship_branch character varying(255),
    price_branch character varying(255),
    sales_source character varying(255),
    use_margin boolean,
    default_percent numeric(19,2),
    default_printer character varying(255),
    job_type character varying(255)
);


--
-- Name: job_printer_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE job_printer_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_printers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_printers (
    id integer NOT NULL,
    path character varying(255),
    name character varying(255),
    document_fk character varying(255)
);


--
-- Name: job_profile; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_profile (
    user_id character varying(255) NOT NULL,
    skin character varying(255),
    home_page character varying(255),
    locale character varying(255),
    email_address character varying(255),
    text_server character varying(255),
    default_followup integer,
    phonenumber character varying(255),
    cc_address character varying(255),
    bcc_address character varying(255),
    contact_number character varying(255),
    form_signature character varying(255),
    time_zone character varying(255),
    alt_user_id character varying(255),
    fax_number character varying(255)
);


--
-- Name: job_project; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_project (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    state character varying(255),
    optlock integer,
    job_cat character varying(255),
    status character varying(255),
    city character varying(255),
    inside_sales character varying(255),
    outside_sales character varying(255),
    follow_up_date date,
    rebid_date date,
    bidder character varying(255),
    project_manager character varying(255),
    completion_date date,
    next_action character varying(255),
    architect character varying(255),
    engineer character varying(255),
    no_bid boolean,
    job_lost_reason character varying(255),
    take_off boolean,
    approval_req boolean,
    created_date timestamp without time zone,
    awardedcustomer_id integer,
    awardedschedule_id integer,
    job_lost boolean,
    credit_br character varying(255),
    ship_from_br character varying(255),
    job_lost_competitor character varying(255),
    job_project_type character varying(255),
    job_win_confidence character varying(255),
    pgm_version integer,
    bid_date_time timestamp without time zone NOT NULL,
    batch_id character varying(255)
);


--
-- Name: job_project_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE job_project_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_project_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_project_type (
    name character varying(255) NOT NULL,
    description character varying(255)
);


--
-- Name: job_quote_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE job_quote_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_receive_item; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_receive_item (
    id bigint NOT NULL,
    transaction_qty integer,
    sell numeric(19,2),
    cost numeric(19,2),
    fixture_fk bigint,
    transaction_fkey integer,
    order_fk integer,
    component_fk bigint
);


--
-- Name: job_receive_item_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE job_receive_item_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_receive_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE job_receive_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_release_hold_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE job_release_hold_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_release_item; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_release_item (
    id bigint NOT NULL,
    transaction_qty integer,
    fixture_fk bigint,
    component_fk bigint,
    release_fk integer,
    transaction_fkey integer
);


--
-- Name: job_release_item_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE job_release_item_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_release_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE job_release_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_report_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_report_users (
    id integer NOT NULL,
    user_name character varying(255),
    email_address character varying(255),
    report_fk integer
);


--
-- Name: job_reports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_reports (
    id integer NOT NULL,
    start_date timestamp without time zone NOT NULL,
    end_date timestamp without time zone NOT NULL,
    title character varying(255),
    user_id character varying(255),
    recurrance integer,
    week_day integer,
    parameters text,
    service_name character varying(255),
    job_id integer,
    expire integer
);


--
-- Name: job_return_item; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_return_item (
    id bigint NOT NULL,
    transaction_qty integer,
    order_fk integer,
    component_fk bigint,
    fixture_fk bigint,
    transaction_fkey integer,
    return_cost numeric(19,2),
    return_sell numeric(19,2),
    stock_desc character varying(255),
    stock_pn character varying(255),
    stock_prodcat character varying(255),
    stock_prodline character varying(255)
);


--
-- Name: job_return_item_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE job_return_item_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_return_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE job_return_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_shipment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_shipment (
    id integer NOT NULL,
    quantity integer,
    ship_date date,
    follow_up_date timestamp without time zone,
    shipment_date date,
    shipper character varying(255),
    tracking_number character varying(255),
    external_note character varying(255),
    internal_note character varying(255),
    component_fk bigint,
    fixture_fk bigint,
    country_origin character varying(255),
    htc_code character varying(255),
    required_on_site date,
    required_release date,
    erp_ship_id character varying(255)
);


--
-- Name: job_shipment_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE job_shipment_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_spec_note_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE job_spec_note_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_specific_notes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_specific_notes (
    id integer NOT NULL,
    type integer,
    content text NOT NULL,
    job_id integer
);


--
-- Name: job_status; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_status (
    name character varying(255) NOT NULL,
    description character varying(255),
    inactive boolean,
    event integer
);


--
-- Name: job_tasks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_tasks (
    id integer NOT NULL,
    source integer NOT NULL,
    priority integer,
    start_date date,
    description character varying(255),
    subject character varying(255),
    status character varying(255),
    completed boolean,
    note bytea,
    user_id character varying(255),
    job_id integer,
    due_date date,
    reminder boolean,
    reminder_date timestamp without time zone,
    reminder_time integer,
    email_address character varying(255),
    follow_up_type integer,
    text_server character varying(255)
);


--
-- Name: job_tasks_assignedusers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_tasks_assignedusers (
    job_tasks_id integer NOT NULL,
    job_tasks_source integer NOT NULL,
    element character varying(255)
);


--
-- Name: job_totals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_totals (
    id bigint NOT NULL,
    return_qty integer,
    change_qty integer,
    pending_qty integer,
    release_qty integer,
    receive_qty integer,
    receive_return_qty integer
);


--
-- Name: job_totals_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE job_totals_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_transaction_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_transaction_log (
    id integer NOT NULL,
    transaction_type integer,
    action character varying(255),
    line_item_key bigint,
    component boolean,
    transaction_date timestamp without time zone,
    transaction_qty integer,
    order_key integer,
    document_key character varying(255)
);


--
-- Name: job_user_preferences; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_user_preferences (
    id integer NOT NULL,
    key character varying(255),
    user_id character varying(255),
    value text
);


--
-- Name: job_vendor_pricing; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_vendor_pricing (
    id bigint NOT NULL,
    bom_id integer,
    cost numeric(19,3) NOT NULL,
    formula character varying(255),
    vendor_fk integer,
    component_fk bigint,
    fixture_fk bigint
);


--
-- Name: job_vendor_pricing_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE job_vendor_pricing_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_vendor_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE job_vendor_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_win_confidence; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_win_confidence (
    name character varying(255) NOT NULL,
    description character varying(255)
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: task_assignedusers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE task_assignedusers (
    task_id integer NOT NULL,
    task_source integer NOT NULL,
    assignedusers character varying(255)
);


--
-- Name: ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: job_active_session_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_active_session
    ADD CONSTRAINT job_active_session_pkey PRIMARY KEY (sessionid);


--
-- Name: job_activity_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_activity
    ADD CONSTRAINT job_activity_pkey PRIMARY KEY (username, jobid);


--
-- Name: job_actor_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_actor
    ADD CONSTRAINT job_actor_pkey PRIMARY KEY (id);


--
-- Name: job_address_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_address
    ADD CONSTRAINT job_address_pkey PRIMARY KEY (id);


--
-- Name: job_adjustment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_adjustment
    ADD CONSTRAINT job_adjustment_pkey PRIMARY KEY (id);


--
-- Name: job_admin_default_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_admin_default
    ADD CONSTRAINT job_admin_default_pkey PRIMARY KEY (name);


--
-- Name: job_alternatives_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_alternatives
    ADD CONSTRAINT job_alternatives_pkey PRIMARY KEY (id);


--
-- Name: job_bom_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_bom
    ADD CONSTRAINT job_bom_pkey PRIMARY KEY (id);


--
-- Name: job_category_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_category
    ADD CONSTRAINT job_category_pkey PRIMARY KEY (name);


--
-- Name: job_change_item_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_change_item
    ADD CONSTRAINT job_change_item_pkey PRIMARY KEY (id);


--
-- Name: job_change_order_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_change_order_log
    ADD CONSTRAINT job_change_order_log_pkey PRIMARY KEY (id);


--
-- Name: job_change_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_change
    ADD CONSTRAINT job_change_pkey PRIMARY KEY (id);


--
-- Name: job_competitor_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_competitor
    ADD CONSTRAINT job_competitor_pkey PRIMARY KEY (name);


--
-- Name: job_component_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_component
    ADD CONSTRAINT job_component_pkey PRIMARY KEY (fixture_id);


--
-- Name: job_contact_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_contact
    ADD CONSTRAINT job_contact_pkey PRIMARY KEY (id);


--
-- Name: job_cost_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_cost
    ADD CONSTRAINT job_cost_pkey PRIMARY KEY (id);


--
-- Name: job_cust_change_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_cust_change
    ADD CONSTRAINT job_cust_change_pkey PRIMARY KEY (id);


--
-- Name: job_customer_job_contact_alternatecontacts_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_customer_job_contact
    ADD CONSTRAINT job_customer_job_contact_alternatecontacts_id_key UNIQUE (alternatecontacts_id);


--
-- Name: job_customer_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_customer
    ADD CONSTRAINT job_customer_pkey PRIMARY KEY (id);


--
-- Name: job_document_defaults_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_document_defaults
    ADD CONSTRAINT job_document_defaults_pkey PRIMARY KEY (id);


--
-- Name: job_document_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_document_log
    ADD CONSTRAINT job_document_log_pkey PRIMARY KEY (document_name);


--
-- Name: job_document_props_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_document_props
    ADD CONSTRAINT job_document_props_pkey PRIMARY KEY (document_definition);


--
-- Name: job_fee_change_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_fee_change
    ADD CONSTRAINT job_fee_change_pkey PRIMARY KEY (id);


--
-- Name: job_fees_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_fees
    ADD CONSTRAINT job_fees_pkey PRIMARY KEY (id);


--
-- Name: job_fixture_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_fixture
    ADD CONSTRAINT job_fixture_pkey PRIMARY KEY (fixture_id);


--
-- Name: job_form_notes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_form_notes
    ADD CONSTRAINT job_form_notes_pkey PRIMARY KEY (id);


--
-- Name: job_gl_debit_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_gl_debit
    ADD CONSTRAINT job_gl_debit_pkey PRIMARY KEY (id);


--
-- Name: job_ledger_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_ledger
    ADD CONSTRAINT job_ledger_pkey PRIMARY KEY (job_id);


--
-- Name: job_line_status_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_line_status
    ADD CONSTRAINT job_line_status_pkey PRIMARY KEY (name);


--
-- Name: job_logos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_logos
    ADD CONSTRAINT job_logos_pkey PRIMARY KEY (classifier, type);


--
-- Name: job_lost_reason_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_lost_reason
    ADD CONSTRAINT job_lost_reason_pkey PRIMARY KEY (name);


--
-- Name: job_note_entry_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_note_entry
    ADD CONSTRAINT job_note_entry_pkey PRIMARY KEY (note_id, note_key);


--
-- Name: job_notes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_notes
    ADD CONSTRAINT job_notes_pkey PRIMARY KEY (id);


--
-- Name: job_opened_job_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_opened_job
    ADD CONSTRAINT job_opened_job_pkey PRIMARY KEY (job_id);


--
-- Name: job_order_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_order
    ADD CONSTRAINT job_order_pkey PRIMARY KEY (id);


--
-- Name: job_overrides_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_overrides
    ADD CONSTRAINT job_overrides_pkey PRIMARY KEY (user_id);


--
-- Name: job_printers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_printers
    ADD CONSTRAINT job_printers_pkey PRIMARY KEY (id);


--
-- Name: job_profile_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_profile
    ADD CONSTRAINT job_profile_pkey PRIMARY KEY (user_id);


--
-- Name: job_project_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_project
    ADD CONSTRAINT job_project_pkey PRIMARY KEY (id);


--
-- Name: job_project_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_project_type
    ADD CONSTRAINT job_project_type_pkey PRIMARY KEY (name);


--
-- Name: job_quote_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_quote
    ADD CONSTRAINT job_quote_pkey PRIMARY KEY (id);


--
-- Name: job_receive_item_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_receive_item
    ADD CONSTRAINT job_receive_item_pkey PRIMARY KEY (id);


--
-- Name: job_receive_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_receive
    ADD CONSTRAINT job_receive_pkey PRIMARY KEY (id);


--
-- Name: job_release_item_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_release_item
    ADD CONSTRAINT job_release_item_pkey PRIMARY KEY (id);


--
-- Name: job_release_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_release
    ADD CONSTRAINT job_release_pkey PRIMARY KEY (id);


--
-- Name: job_report_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_report_users
    ADD CONSTRAINT job_report_users_pkey PRIMARY KEY (id);


--
-- Name: job_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_reports
    ADD CONSTRAINT job_reports_pkey PRIMARY KEY (id);


--
-- Name: job_return_item_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_return_item
    ADD CONSTRAINT job_return_item_pkey PRIMARY KEY (id);


--
-- Name: job_return_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_return
    ADD CONSTRAINT job_return_pkey PRIMARY KEY (id);


--
-- Name: job_shipment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_shipment
    ADD CONSTRAINT job_shipment_pkey PRIMARY KEY (id);


--
-- Name: job_specific_notes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_specific_notes
    ADD CONSTRAINT job_specific_notes_pkey PRIMARY KEY (id);


--
-- Name: job_status_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_status
    ADD CONSTRAINT job_status_pkey PRIMARY KEY (name);


--
-- Name: job_tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_tasks
    ADD CONSTRAINT job_tasks_pkey PRIMARY KEY (id, source);


--
-- Name: job_totals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_totals
    ADD CONSTRAINT job_totals_pkey PRIMARY KEY (id);


--
-- Name: job_transaction_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_transaction_log
    ADD CONSTRAINT job_transaction_log_pkey PRIMARY KEY (id);


--
-- Name: job_user_preferences_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_user_preferences
    ADD CONSTRAINT job_user_preferences_pkey PRIMARY KEY (id);


--
-- Name: job_vendor_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_vendor
    ADD CONSTRAINT job_vendor_pkey PRIMARY KEY (id);


--
-- Name: job_vendor_pricing_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_vendor_pricing
    ADD CONSTRAINT job_vendor_pricing_pkey PRIMARY KEY (id);


--
-- Name: job_win_confidence_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_win_confidence
    ADD CONSTRAINT job_win_confidence_pkey PRIMARY KEY (name);


--
-- Name: schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: job_adjustment_bom_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX job_adjustment_bom_id_index ON job_adjustment USING btree (bom_id);


--
-- Name: job_alternatives_alt_bom_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX job_alternatives_alt_bom_id_index ON job_alternatives USING btree (alt_bom_id);


--
-- Name: job_alternatives_bom_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX job_alternatives_bom_id_index ON job_alternatives USING btree (bom_id);


--
-- Name: job_change_customer_fk_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX job_change_customer_fk_index ON job_change USING btree (customer_fk);


--
-- Name: job_change_item_component_fk_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX job_change_item_component_fk_index ON job_change_item USING btree (component_fk);


--
-- Name: job_change_item_fixture_fk_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX job_change_item_fixture_fk_index ON job_change_item USING btree (fixture_fk);


--
-- Name: job_change_item_order_fk_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX job_change_item_order_fk_index ON job_change_item USING btree (order_fk);


--
-- Name: job_component_customer_item_fk_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX job_component_customer_item_fk_index ON job_component USING btree (customer_item_fk);


--
-- Name: job_component_fixture_fk_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX job_component_fixture_fk_index ON job_component USING btree (fixture_fk);


--
-- Name: job_component_vendor_item_fk_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX job_component_vendor_item_fk_index ON job_component USING btree (vendor_item_fk);


--
-- Name: job_customer_address_fk_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX job_customer_address_fk_index ON job_customer USING btree (address_fk);


--
-- Name: job_customer_altaddress_fk_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX job_customer_altaddress_fk_index ON job_customer USING btree (altaddress_fk);


--
-- Name: job_customer_inside_sales; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX job_customer_inside_sales ON job_customer USING btree (inside_sales);


--
-- Name: job_customer_job_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX job_customer_job_id ON job_customer USING btree (job_id);


--
-- Name: job_customer_outside_sales; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX job_customer_outside_sales ON job_customer USING btree (outside_sales);


--
-- Name: job_customer_shipaddress_fk_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX job_customer_shipaddress_fk_index ON job_customer USING btree (shipaddress_fk);


--
-- Name: job_document_log_job_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX job_document_log_job_id_index ON job_document_log USING btree (job_id);


--
-- Name: job_fixture_bom_fk_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX job_fixture_bom_fk_index ON job_fixture USING btree (bom_fk);


--
-- Name: job_fixture_customer_item_fk_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX job_fixture_customer_item_fk_index ON job_fixture USING btree (customer_item_fk);


--
-- Name: job_fixture_vendor_item_fk_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX job_fixture_vendor_item_fk_index ON job_fixture USING btree (vendor_item_fk);


--
-- Name: job_order_bom_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX job_order_bom_id_index ON job_order USING btree (bom_id);


--
-- Name: job_project_awardedcustomer_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX job_project_awardedcustomer_id_index ON job_project USING btree (awardedcustomer_id);


--
-- Name: job_project_bidder; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX job_project_bidder ON job_project USING btree (bidder);


--
-- Name: job_project_project_manager; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX job_project_project_manager ON job_project USING btree (project_manager);


--
-- Name: job_receive_bom_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX job_receive_bom_id_index ON job_receive USING btree (bom_id);


--
-- Name: job_receive_item_component_fk_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX job_receive_item_component_fk_index ON job_receive_item USING btree (component_fk);


--
-- Name: job_receive_item_fixture_fk_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX job_receive_item_fixture_fk_index ON job_receive_item USING btree (fixture_fk);


--
-- Name: job_receive_item_order_fk_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX job_receive_item_order_fk_index ON job_receive_item USING btree (order_fk);


--
-- Name: job_release_bom_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX job_release_bom_id_index ON job_release USING btree (bom_id);


--
-- Name: job_release_item_component_fk_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX job_release_item_component_fk_index ON job_release_item USING btree (component_fk);


--
-- Name: job_release_item_fixture_fk_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX job_release_item_fixture_fk_index ON job_release_item USING btree (fixture_fk);


--
-- Name: job_release_item_release_fk_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX job_release_item_release_fk_index ON job_release_item USING btree (release_fk);


--
-- Name: job_shipment_component_fk_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX job_shipment_component_fk_index ON job_shipment USING btree (component_fk);


--
-- Name: job_shipment_fixture_fk_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX job_shipment_fixture_fk_index ON job_shipment USING btree (fixture_fk);


--
-- Name: job_specific_notes_job_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX job_specific_notes_job_id_index ON job_specific_notes USING btree (job_id);


--
-- Name: job_vendor_address_fk_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX job_vendor_address_fk_index ON job_vendor USING btree (address_fk);


--
-- Name: job_vendor_job_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX job_vendor_job_id_index ON job_vendor USING btree (job_id);


--
-- Name: job_vendor_shipaddress_fk_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX job_vendor_shipaddress_fk_index ON job_vendor USING btree (shipaddress_fk);


--
-- Name: fk1a03599e7dab9c80; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_contact
    ADD CONSTRAINT fk1a03599e7dab9c80 FOREIGN KEY (address_fk) REFERENCES job_address(id) ON DELETE CASCADE;


--
-- Name: fk21cea861f65080a4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_receive
    ADD CONSTRAINT fk21cea861f65080a4 FOREIGN KEY (fee_fk) REFERENCES job_fees(id);


--
-- Name: fk224d5d857dab9cd6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_release
    ADD CONSTRAINT fk224d5d857dab9cd6 FOREIGN KEY (address_id) REFERENCES job_address(id);


--
-- Name: fk224d5d8588edfc14; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_release
    ADD CONSTRAINT fk224d5d8588edfc14 FOREIGN KEY (document_fk) REFERENCES job_document_log(document_name);


--
-- Name: fk280ca0316485c84c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_receive_item
    ADD CONSTRAINT fk280ca0316485c84c FOREIGN KEY (transaction_fkey) REFERENCES job_transaction_log(id);


--
-- Name: fk280ca03170086d62; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_receive_item
    ADD CONSTRAINT fk280ca03170086d62 FOREIGN KEY (order_fk) REFERENCES job_receive(id);


--
-- Name: fk280ca031724bd8e4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_receive_item
    ADD CONSTRAINT fk280ca031724bd8e4 FOREIGN KEY (fixture_fk) REFERENCES job_fixture(fixture_id);


--
-- Name: fk280ca031c82bfc64; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_receive_item
    ADD CONSTRAINT fk280ca031c82bfc64 FOREIGN KEY (component_fk) REFERENCES job_component(fixture_id);


--
-- Name: fk2973ebdc724bd8e4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_shipment
    ADD CONSTRAINT fk2973ebdc724bd8e4 FOREIGN KEY (fixture_fk) REFERENCES job_fixture(fixture_id);


--
-- Name: fk2973ebdcc82bfc64; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_shipment
    ADD CONSTRAINT fk2973ebdcc82bfc64 FOREIGN KEY (component_fk) REFERENCES job_component(fixture_id);


--
-- Name: fk2a036491724bd8e4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_vendor_pricing
    ADD CONSTRAINT fk2a036491724bd8e4 FOREIGN KEY (fixture_fk) REFERENCES job_fixture(fixture_id);


--
-- Name: fk2a036491c82bfc64; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_vendor_pricing
    ADD CONSTRAINT fk2a036491c82bfc64 FOREIGN KEY (component_fk) REFERENCES job_component(fixture_id);


--
-- Name: fk2b5b5db4ae88f55; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_printers
    ADD CONSTRAINT fk2b5b5db4ae88f55 FOREIGN KEY (document_fk) REFERENCES job_document_props(document_definition);


--
-- Name: fk43e5944bd1633c4a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_fee_change
    ADD CONSTRAINT fk43e5944bd1633c4a FOREIGN KEY (customerchange_id) REFERENCES job_cust_change(id);


--
-- Name: fk43e5944bf65080fa; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_fee_change
    ADD CONSTRAINT fk43e5944bf65080fa FOREIGN KEY (fee_id) REFERENCES job_fees(id);


--
-- Name: fk561928a93ddade7a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_opened_job
    ADD CONSTRAINT fk561928a93ddade7a FOREIGN KEY (sessionid) REFERENCES job_active_session(sessionid);


--
-- Name: fk56bd26f3d6b513aa; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_actor
    ADD CONSTRAINT fk56bd26f3d6b513aa FOREIGN KEY (job_id) REFERENCES job_project(id);


--
-- Name: fk575d6d264ae88f55; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_logos
    ADD CONSTRAINT fk575d6d264ae88f55 FOREIGN KEY (document_fk) REFERENCES job_document_props(document_definition);


--
-- Name: fk5789044c36056b6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_order
    ADD CONSTRAINT fk5789044c36056b6 FOREIGN KEY (vendorquote_id) REFERENCES job_vendor(id);


--
-- Name: fk5789044c7dab9cd6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_order
    ADD CONSTRAINT fk5789044c7dab9cd6 FOREIGN KEY (address_id) REFERENCES job_address(id);


--
-- Name: fk5789044c88edfc14; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_order
    ADD CONSTRAINT fk5789044c88edfc14 FOREIGN KEY (document_fk) REFERENCES job_document_log(document_name);


--
-- Name: fk5789044c895b1b5f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_order
    ADD CONSTRAINT fk5789044c895b1b5f FOREIGN KEY (bom_id) REFERENCES job_bom(id) ON DELETE CASCADE;


--
-- Name: fk5e60e8c684f05110; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_user_preferences
    ADD CONSTRAINT fk5e60e8c684f05110 FOREIGN KEY (user_id) REFERENCES job_profile(user_id);


--
-- Name: fk6ba3eafb700f8171; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_component
    ADD CONSTRAINT fk6ba3eafb700f8171 FOREIGN KEY (total_id) REFERENCES job_totals(id);


--
-- Name: fk6ba3eafb724bd8e4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_component
    ADD CONSTRAINT fk6ba3eafb724bd8e4 FOREIGN KEY (fixture_fk) REFERENCES job_fixture(fixture_id);


--
-- Name: fk6ba3eafb937633a1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_component
    ADD CONSTRAINT fk6ba3eafb937633a1 FOREIGN KEY (customer_item_fk) REFERENCES job_quote(id);


--
-- Name: fk6ba3eafbf51528e1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_component
    ADD CONSTRAINT fk6ba3eafbf51528e1 FOREIGN KEY (vendor_item_fk) REFERENCES job_cost(id);


--
-- Name: fk6c5bfa202572dbbc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_customer
    ADD CONSTRAINT fk6c5bfa202572dbbc FOREIGN KEY (shipaddress_fk) REFERENCES job_address(id) ON DELETE CASCADE;


--
-- Name: fk6c5bfa207dab9c80; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_customer
    ADD CONSTRAINT fk6c5bfa207dab9c80 FOREIGN KEY (address_fk) REFERENCES job_address(id) ON DELETE CASCADE;


--
-- Name: fk6c5bfa2093e3d6e9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_customer
    ADD CONSTRAINT fk6c5bfa2093e3d6e9 FOREIGN KEY (altaddress_fk) REFERENCES job_address(id);


--
-- Name: fk6c5bfa20a4e00556; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_customer
    ADD CONSTRAINT fk6c5bfa20a4e00556 FOREIGN KEY (alt_contact_fk) REFERENCES job_contact(id) ON DELETE CASCADE;


--
-- Name: fk6c5bfa20d6b513aa; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_customer
    ADD CONSTRAINT fk6c5bfa20d6b513aa FOREIGN KEY (job_id) REFERENCES job_project(id);


--
-- Name: fk6c5bfa20ed994f46; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_customer
    ADD CONSTRAINT fk6c5bfa20ed994f46 FOREIGN KEY (main_contact_fk) REFERENCES job_contact(id) ON DELETE CASCADE;


--
-- Name: fk758581ff2cdc774; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_customer_job_contact
    ADD CONSTRAINT fk758581ff2cdc774 FOREIGN KEY (job_customer_id) REFERENCES job_customer(id);


--
-- Name: fk758581ffdb679f89; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_customer_job_contact
    ADD CONSTRAINT fk758581ffdb679f89 FOREIGN KEY (alternatecontacts_id) REFERENCES job_contact(id);


--
-- Name: fk794a4d4687ebf726; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_change_order_log
    ADD CONSTRAINT fk794a4d4687ebf726 FOREIGN KEY (cust_change_fk) REFERENCES job_cust_change(id);


--
-- Name: fk7bf4ae36d6b513aa; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_specific_notes
    ADD CONSTRAINT fk7bf4ae36d6b513aa FOREIGN KEY (job_id) REFERENCES job_project(id);


--
-- Name: fk84285d9a88edfc14; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_cust_change
    ADD CONSTRAINT fk84285d9a88edfc14 FOREIGN KEY (document_fk) REFERENCES job_document_log(document_name);


--
-- Name: fk848f36727dab9cd6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_change
    ADD CONSTRAINT fk848f36727dab9cd6 FOREIGN KEY (address_id) REFERENCES job_address(id);


--
-- Name: fk848f367288edfc14; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_change
    ADD CONSTRAINT fk848f367288edfc14 FOREIGN KEY (document_fk) REFERENCES job_document_log(document_name);


--
-- Name: fk848f3672d938bf24; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_change
    ADD CONSTRAINT fk848f3672d938bf24 FOREIGN KEY (customer_fk) REFERENCES job_cust_change(id);


--
-- Name: fk86bb37c07bb51c67; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY task_assignedusers
    ADD CONSTRAINT fk86bb37c07bb51c67 FOREIGN KEY (task_id, task_source) REFERENCES job_tasks(id, source);


--
-- Name: fk8e8f187fa3098749; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_report_users
    ADD CONSTRAINT fk8e8f187fa3098749 FOREIGN KEY (report_fk) REFERENCES job_reports(id);


--
-- Name: fk9e065ff27dab9cd6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_return
    ADD CONSTRAINT fk9e065ff27dab9cd6 FOREIGN KEY (address_id) REFERENCES job_address(id);


--
-- Name: fk9e065ff288edfc14; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_return
    ADD CONSTRAINT fk9e065ff288edfc14 FOREIGN KEY (document_fk) REFERENCES job_document_log(document_name);


--
-- Name: fka4d6c80a2572dbbc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_vendor
    ADD CONSTRAINT fka4d6c80a2572dbbc FOREIGN KEY (shipaddress_fk) REFERENCES job_address(id);


--
-- Name: fka4d6c80a7dab9c80; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_vendor
    ADD CONSTRAINT fka4d6c80a7dab9c80 FOREIGN KEY (address_fk) REFERENCES job_address(id) ON DELETE CASCADE;


--
-- Name: fka4d6c80ad6b513aa; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_vendor
    ADD CONSTRAINT fka4d6c80ad6b513aa FOREIGN KEY (job_id) REFERENCES job_project(id);


--
-- Name: fkaa50223ed6b513aa; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_bom
    ADD CONSTRAINT fkaa50223ed6b513aa FOREIGN KEY (job_id) REFERENCES job_project(id);


--
-- Name: fkaf062f87700f8171; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_fixture
    ADD CONSTRAINT fkaf062f87700f8171 FOREIGN KEY (total_id) REFERENCES job_totals(id);


--
-- Name: fkaf062f87895b1b09; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_fixture
    ADD CONSTRAINT fkaf062f87895b1b09 FOREIGN KEY (bom_fk) REFERENCES job_bom(id);


--
-- Name: fkaf062f87937633a1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_fixture
    ADD CONSTRAINT fkaf062f87937633a1 FOREIGN KEY (customer_item_fk) REFERENCES job_quote(id);


--
-- Name: fkaf062f87f51528e1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_fixture
    ADD CONSTRAINT fkaf062f87f51528e1 FOREIGN KEY (vendor_item_fk) REFERENCES job_cost(id);


--
-- Name: fkcedabf2781425083; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_profile
    ADD CONSTRAINT fkcedabf2781425083 FOREIGN KEY (user_id) REFERENCES job_overrides(user_id);


--
-- Name: fkcedc809781a4afba; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_project
    ADD CONSTRAINT fkcedc809781a4afba FOREIGN KEY (awardedcustomer_id) REFERENCES job_customer(id);


--
-- Name: fkcedc8097b23f71ec; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_project
    ADD CONSTRAINT fkcedc8097b23f71ec FOREIGN KEY (awardedschedule_id) REFERENCES job_bom(id);


--
-- Name: fke0e5818d6485c84c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_release_item
    ADD CONSTRAINT fke0e5818d6485c84c FOREIGN KEY (transaction_fkey) REFERENCES job_transaction_log(id);


--
-- Name: fke0e5818d724bd8e4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_release_item
    ADD CONSTRAINT fke0e5818d724bd8e4 FOREIGN KEY (fixture_fk) REFERENCES job_fixture(fixture_id);


--
-- Name: fke0e5818d8d1c5651; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_release_item
    ADD CONSTRAINT fke0e5818d8d1c5651 FOREIGN KEY (release_fk) REFERENCES job_release(id);


--
-- Name: fke0e5818dc82bfc64; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_release_item
    ADD CONSTRAINT fke0e5818dc82bfc64 FOREIGN KEY (component_fk) REFERENCES job_component(fixture_id);


--
-- Name: fkea6f57a859861eb5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_alternatives
    ADD CONSTRAINT fkea6f57a859861eb5 FOREIGN KEY (alt_bom_id) REFERENCES job_bom(id);


--
-- Name: fkea6f57a8895b1b5f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_alternatives
    ADD CONSTRAINT fkea6f57a8895b1b5f FOREIGN KEY (bom_id) REFERENCES job_bom(id);


--
-- Name: fkea7734c06485c84c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_change_item
    ADD CONSTRAINT fkea7734c06485c84c FOREIGN KEY (transaction_fkey) REFERENCES job_transaction_log(id);


--
-- Name: fkea7734c0724bd8e4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_change_item
    ADD CONSTRAINT fkea7734c0724bd8e4 FOREIGN KEY (fixture_fk) REFERENCES job_fixture(fixture_id);


--
-- Name: fkea7734c09323e436; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_change_item
    ADD CONSTRAINT fkea7734c09323e436 FOREIGN KEY (order_fk) REFERENCES job_change(id);


--
-- Name: fkea7734c0c82bfc64; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_change_item
    ADD CONSTRAINT fkea7734c0c82bfc64 FOREIGN KEY (component_fk) REFERENCES job_component(fixture_id);


--
-- Name: fkf47dfb406485c84c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_return_item
    ADD CONSTRAINT fkf47dfb406485c84c FOREIGN KEY (transaction_fkey) REFERENCES job_transaction_log(id);


--
-- Name: fkf47dfb40724bd8e4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_return_item
    ADD CONSTRAINT fkf47dfb40724bd8e4 FOREIGN KEY (fixture_fk) REFERENCES job_fixture(fixture_id);


--
-- Name: fkf47dfb40ac9b0db6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_return_item
    ADD CONSTRAINT fkf47dfb40ac9b0db6 FOREIGN KEY (order_fk) REFERENCES job_return(id);


--
-- Name: fkf47dfb40c82bfc64; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_return_item
    ADD CONSTRAINT fkf47dfb40c82bfc64 FOREIGN KEY (component_fk) REFERENCES job_component(fixture_id);


--
-- Name: fkf5b7e66796d0bf19; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_tasks_assignedusers
    ADD CONSTRAINT fkf5b7e66796d0bf19 FOREIGN KEY (job_tasks_id, job_tasks_source) REFERENCES job_tasks(id, source);


--
-- Name: vendor_fk_constraint; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_vendor_pricing
    ADD CONSTRAINT vendor_fk_constraint FOREIGN KEY (vendor_fk) REFERENCES job_vendor(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO schema_migrations (version) VALUES ;


