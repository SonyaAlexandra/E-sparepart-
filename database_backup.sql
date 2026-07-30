

\restrict xo5hMKcd1HudlgBJQUsWy0tfgzAUOzYWOiUHbs7mT1O0BvmPn5G8gWxR7S6Aena

-- Dumped from database version 16.13 (Homebrew)
-- Dumped by pg_dump version 16.13 (Homebrew)

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: activity_logs; Type: TABLE; Schema: public; Owner: sonyaalexandrapaleng
--

CREATE TABLE public.activity_logs (
    id integer NOT NULL,
    user_id integer,
    action character varying(255) NOT NULL,
    entity_type character varying(100),
    entity_id integer,
    detail text,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.activity_logs OWNER TO sonyaalexandrapaleng;

--
-- Name: activity_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: sonyaalexandrapaleng
--

CREATE SEQUENCE public.activity_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.activity_logs_id_seq OWNER TO sonyaalexandrapaleng;

--
-- Name: activity_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER SEQUENCE public.activity_logs_id_seq OWNED BY public.activity_logs.id;


--
-- Name: bpjt_daily_counter; Type: TABLE; Schema: public; Owner: sonyaalexandrapaleng
--

CREATE TABLE public.bpjt_daily_counter (
    counter_date date NOT NULL,
    last_seq integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.bpjt_daily_counter OWNER TO sonyaalexandrapaleng;

--
-- Name: employee_id_cards; Type: TABLE; Schema: public; Owner: sonyaalexandrapaleng
--

CREATE TABLE public.employee_id_cards (
    id integer NOT NULL,
    id_card_number character varying(100) NOT NULL,
    full_name character varying(255) NOT NULL,
    is_active boolean DEFAULT true,
    notes text,
    created_by integer,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    fingerprint_id character varying(24),
    fingerprint_template text
);


ALTER TABLE public.employee_id_cards OWNER TO sonyaalexandrapaleng;

--
-- Name: COLUMN employee_id_cards.fingerprint_template; Type: COMMENT; Schema: public; Owner: sonyaalexandrapaleng
--

COMMENT ON COLUMN public.employee_id_cards.fingerprint_template IS 'FMD template dari DPUruNet (U.are.U 4500). Format: base64(XML Fmd). Diisi saat enrollment via halaman admin employees.';


--
-- Name: employee_id_cards_id_seq; Type: SEQUENCE; Schema: public; Owner: sonyaalexandrapaleng
--

CREATE SEQUENCE public.employee_id_cards_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.employee_id_cards_id_seq OWNER TO sonyaalexandrapaleng;

--
-- Name: employee_id_cards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER SEQUENCE public.employee_id_cards_id_seq OWNED BY public.employee_id_cards.id;


--
-- Name: non_inventory_approvals; Type: TABLE; Schema: public; Owner: sonyaalexandrapaleng
--

CREATE TABLE public.non_inventory_approvals (
    id integer NOT NULL,
    request_id integer NOT NULL,
    stage smallint NOT NULL,
    approver_id integer NOT NULL,
    action character varying(10) NOT NULL,
    actioned_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT non_inventory_approvals_action_check CHECK (((action)::text = ANY ((ARRAY['release'::character varying, 'cancel'::character varying])::text[])))
);


ALTER TABLE public.non_inventory_approvals OWNER TO sonyaalexandrapaleng;

--
-- Name: non_inventory_approvals_id_seq; Type: SEQUENCE; Schema: public; Owner: sonyaalexandrapaleng
--

CREATE SEQUENCE public.non_inventory_approvals_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.non_inventory_approvals_id_seq OWNER TO sonyaalexandrapaleng;

--
-- Name: non_inventory_approvals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER SEQUENCE public.non_inventory_approvals_id_seq OWNED BY public.non_inventory_approvals.id;


--
-- Name: non_inventory_items; Type: TABLE; Schema: public; Owner: sonyaalexandrapaleng
--

CREATE TABLE public.non_inventory_items (
    id integer NOT NULL,
    request_id integer NOT NULL,
    deskripsi text NOT NULL,
    qty integer DEFAULT 1 NOT NULL,
    peruntukan text DEFAULT ''::text NOT NULL,
    lampiran character varying(500) DEFAULT ''::character varying
);


ALTER TABLE public.non_inventory_items OWNER TO sonyaalexandrapaleng;

--
-- Name: non_inventory_items_id_seq; Type: SEQUENCE; Schema: public; Owner: sonyaalexandrapaleng
--

CREATE SEQUENCE public.non_inventory_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.non_inventory_items_id_seq OWNER TO sonyaalexandrapaleng;

--
-- Name: non_inventory_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER SEQUENCE public.non_inventory_items_id_seq OWNED BY public.non_inventory_items.id;


--
-- Name: non_inventory_requests; Type: TABLE; Schema: public; Owner: sonyaalexandrapaleng
--

CREATE TABLE public.non_inventory_requests (
    id integer NOT NULL,
    no_bpjt character varying(30) NOT NULL,
    pemohon_id integer NOT NULL,
    nama_pemohon character varying(150) NOT NULL,
    seksi_divisi character varying(20) NOT NULL,
    tanggal_pemakaian date NOT NULL,
    keterangan text DEFAULT ''::text NOT NULL,
    lampiran_url character varying(500) DEFAULT NULL::character varying,
    status character varying(20) DEFAULT 'pending'::character varying NOT NULL,
    current_stage smallint DEFAULT 0 NOT NULL,
    submitted_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    is_completed boolean DEFAULT false,
    is_done boolean DEFAULT false,
    CONSTRAINT non_inventory_requests_seksi_divisi_check CHECK (((seksi_divisi)::text = ANY ((ARRAY['MTC1'::character varying, 'MTC2'::character varying, 'UTL'::character varying, 'BM'::character varying])::text[]))),
    CONSTRAINT non_inventory_requests_status_check CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'stage1'::character varying, 'stage2'::character varying, 'stage3'::character varying, 'approved'::character varying, 'cancelled'::character varying])::text[])))
);


ALTER TABLE public.non_inventory_requests OWNER TO sonyaalexandrapaleng;

--
-- Name: non_inventory_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: sonyaalexandrapaleng
--

CREATE SEQUENCE public.non_inventory_requests_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.non_inventory_requests_id_seq OWNER TO sonyaalexandrapaleng;

--
-- Name: non_inventory_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER SEQUENCE public.non_inventory_requests_id_seq OWNED BY public.non_inventory_requests.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: sonyaalexandrapaleng
--

CREATE TABLE public.notifications (
    id integer NOT NULL,
    user_id integer,
    message text NOT NULL,
    is_read boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.notifications OWNER TO sonyaalexandrapaleng;

--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: sonyaalexandrapaleng
--

CREATE SEQUENCE public.notifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.notifications_id_seq OWNER TO sonyaalexandrapaleng;

--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER SEQUENCE public.notifications_id_seq OWNED BY public.notifications.id;


--
-- Name: request_items; Type: TABLE; Schema: public; Owner: sonyaalexandrapaleng
--

CREATE TABLE public.request_items (
    id integer NOT NULL,
    request_id integer,
    sparepart_id integer,
    no_baki character varying(100),
    jumlah integer DEFAULT 1 NOT NULL,
    jumlah_disetujui integer,
    mesin_area character varying(100),
    nama_item_snapshot character varying(255),
    kode_oracle_snapshot character varying(100),
    no_part_snapshot character varying(100)
);


ALTER TABLE public.request_items OWNER TO sonyaalexandrapaleng;

--
-- Name: request_items_id_seq; Type: SEQUENCE; Schema: public; Owner: sonyaalexandrapaleng
--

CREATE SEQUENCE public.request_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.request_items_id_seq OWNER TO sonyaalexandrapaleng;

--
-- Name: request_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER SEQUENCE public.request_items_id_seq OWNED BY public.request_items.id;


--
-- Name: request_order_items; Type: TABLE; Schema: public; Owner: sonyaalexandrapaleng
--

CREATE TABLE public.request_order_items (
    id integer NOT NULL,
    request_order_id integer NOT NULL,
    sparepart_id integer,
    nama_item_snapshot character varying(255) DEFAULT ''::character varying NOT NULL,
    kode_oracle_snapshot character varying(100) DEFAULT ''::character varying NOT NULL,
    jumlah integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.request_order_items OWNER TO sonyaalexandrapaleng;

--
-- Name: request_order_items_id_seq; Type: SEQUENCE; Schema: public; Owner: sonyaalexandrapaleng
--

CREATE SEQUENCE public.request_order_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.request_order_items_id_seq OWNER TO sonyaalexandrapaleng;

--
-- Name: request_order_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER SEQUENCE public.request_order_items_id_seq OWNED BY public.request_order_items.id;


--
-- Name: request_orders; Type: TABLE; Schema: public; Owner: sonyaalexandrapaleng
--

CREATE TABLE public.request_orders (
    id integer NOT NULL,
    pemohon_id integer,
    requester_name character varying(255) DEFAULT ''::character varying NOT NULL,
    sparepart_id integer,
    nama_item_snapshot character varying(255) DEFAULT ''::character varying NOT NULL,
    kode_oracle_snapshot character varying(100) DEFAULT ''::character varying NOT NULL,
    status character varying(50) DEFAULT 'pending'::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    completed_at timestamp with time zone
);


ALTER TABLE public.request_orders OWNER TO sonyaalexandrapaleng;

--
-- Name: request_orders_id_seq; Type: SEQUENCE; Schema: public; Owner: sonyaalexandrapaleng
--

CREATE SEQUENCE public.request_orders_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.request_orders_id_seq OWNER TO sonyaalexandrapaleng;

--
-- Name: request_orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER SEQUENCE public.request_orders_id_seq OWNED BY public.request_orders.id;


--
-- Name: requests; Type: TABLE; Schema: public; Owner: sonyaalexandrapaleng
--

CREATE TABLE public.requests (
    id integer NOT NULL,
    no_wr_wo character varying(100) NOT NULL,
    pemohon_id integer,
    requester_name character varying(255) NOT NULL,
    requester_source character varying(20) DEFAULT 'manual'::character varying,
    division character varying(50) NOT NULL,
    status character varying(50) DEFAULT 'pending'::character varying,
    current_stage integer DEFAULT 0,
    rejection_reason text,
    session_id character varying(100),
    submitted_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    mesin_area character varying(100) DEFAULT ''::character varying
);


ALTER TABLE public.requests OWNER TO sonyaalexandrapaleng;

--
-- Name: requests_id_seq; Type: SEQUENCE; Schema: public; Owner: sonyaalexandrapaleng
--

CREATE SEQUENCE public.requests_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.requests_id_seq OWNER TO sonyaalexandrapaleng;

--
-- Name: requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER SEQUENCE public.requests_id_seq OWNED BY public.requests.id;


--
-- Name: rfid_sessions; Type: TABLE; Schema: public; Owner: sonyaalexandrapaleng
--

CREATE TABLE public.rfid_sessions (
    session_id character varying(100) NOT NULL,
    request_id integer,
    pemohon_id integer,
    created_at timestamp without time zone DEFAULT now(),
    expires_at timestamp without time zone,
    is_active boolean DEFAULT true
);


ALTER TABLE public.rfid_sessions OWNER TO sonyaalexandrapaleng;

--
-- Name: spareparts; Type: TABLE; Schema: public; Owner: sonyaalexandrapaleng
--

CREATE TABLE public.spareparts (
    id integer NOT NULL,
    kode_oracle character varying(100) NOT NULL,
    kode_rfid character varying(255),
    no_part character varying(100),
    nama_item character varying(255) NOT NULL,
    deskripsi text,
    jenis_mesin character varying(100),
    lokasi character varying(100),
    harga numeric(15,2) DEFAULT 0,
    stok integer DEFAULT 0,
    min_stok integer DEFAULT 0,
    max_stok integer DEFAULT 0,
    usage_per_year integer DEFAULT 0,
    foto_url character varying(500),
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    pdf_url text,
    deleted_at timestamp without time zone
);


ALTER TABLE public.spareparts OWNER TO sonyaalexandrapaleng;

--
-- Name: spareparts_id_seq; Type: SEQUENCE; Schema: public; Owner: sonyaalexandrapaleng
--

CREATE SEQUENCE public.spareparts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.spareparts_id_seq OWNER TO sonyaalexandrapaleng;

--
-- Name: spareparts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER SEQUENCE public.spareparts_id_seq OWNED BY public.spareparts.id;


--
-- Name: stock_receivings; Type: TABLE; Schema: public; Owner: sonyaalexandrapaleng
--

CREATE TABLE public.stock_receivings (
    id integer NOT NULL,
    sparepart_id integer,
    no_po character varying(100),
    vendor character varying(255),
    jumlah integer NOT NULL,
    harga numeric(15,2),
    tipe character varying(20) DEFAULT 'tambah'::character varying,
    keterangan text,
    received_at timestamp without time zone DEFAULT now(),
    received_by integer,
    nama_item_snapshot character varying(255),
    kode_oracle_snapshot character varying(100)
);


ALTER TABLE public.stock_receivings OWNER TO sonyaalexandrapaleng;

--
-- Name: stock_receivings_id_seq; Type: SEQUENCE; Schema: public; Owner: sonyaalexandrapaleng
--

CREATE SEQUENCE public.stock_receivings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.stock_receivings_id_seq OWNER TO sonyaalexandrapaleng;

--
-- Name: stock_receivings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER SEQUENCE public.stock_receivings_id_seq OWNED BY public.stock_receivings.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: sonyaalexandrapaleng
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username character varying(100) NOT NULL,
    password_hash character varying(255) NOT NULL,
    full_name character varying(255) NOT NULL,
    role character varying(50) NOT NULL,
    division character varying(50),
    id_card_number character varying(100),
    telegram_chat_id bigint,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.users OWNER TO sonyaalexandrapaleng;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: sonyaalexandrapaleng
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO sonyaalexandrapaleng;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: validations; Type: TABLE; Schema: public; Owner: sonyaalexandrapaleng
--

CREATE TABLE public.validations (
    id integer NOT NULL,
    request_id integer,
    stage integer NOT NULL,
    validator_id integer,
    action character varying(20) NOT NULL,
    reason text,
    validated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.validations OWNER TO sonyaalexandrapaleng;

--
-- Name: validations_id_seq; Type: SEQUENCE; Schema: public; Owner: sonyaalexandrapaleng
--

CREATE SEQUENCE public.validations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.validations_id_seq OWNER TO sonyaalexandrapaleng;

--
-- Name: validations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER SEQUENCE public.validations_id_seq OWNED BY public.validations.id;


--
-- Name: activity_logs id; Type: DEFAULT; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER TABLE ONLY public.activity_logs ALTER COLUMN id SET DEFAULT nextval('public.activity_logs_id_seq'::regclass);


--
-- Name: employee_id_cards id; Type: DEFAULT; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER TABLE ONLY public.employee_id_cards ALTER COLUMN id SET DEFAULT nextval('public.employee_id_cards_id_seq'::regclass);


--
-- Name: non_inventory_approvals id; Type: DEFAULT; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER TABLE ONLY public.non_inventory_approvals ALTER COLUMN id SET DEFAULT nextval('public.non_inventory_approvals_id_seq'::regclass);


--
-- Name: non_inventory_items id; Type: DEFAULT; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER TABLE ONLY public.non_inventory_items ALTER COLUMN id SET DEFAULT nextval('public.non_inventory_items_id_seq'::regclass);


--
-- Name: non_inventory_requests id; Type: DEFAULT; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER TABLE ONLY public.non_inventory_requests ALTER COLUMN id SET DEFAULT nextval('public.non_inventory_requests_id_seq'::regclass);


--
-- Name: notifications id; Type: DEFAULT; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER TABLE ONLY public.notifications ALTER COLUMN id SET DEFAULT nextval('public.notifications_id_seq'::regclass);


--
-- Name: request_items id; Type: DEFAULT; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER TABLE ONLY public.request_items ALTER COLUMN id SET DEFAULT nextval('public.request_items_id_seq'::regclass);


--
-- Name: request_order_items id; Type: DEFAULT; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER TABLE ONLY public.request_order_items ALTER COLUMN id SET DEFAULT nextval('public.request_order_items_id_seq'::regclass);


--
-- Name: request_orders id; Type: DEFAULT; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER TABLE ONLY public.request_orders ALTER COLUMN id SET DEFAULT nextval('public.request_orders_id_seq'::regclass);


--
-- Name: requests id; Type: DEFAULT; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER TABLE ONLY public.requests ALTER COLUMN id SET DEFAULT nextval('public.requests_id_seq'::regclass);


--
-- Name: spareparts id; Type: DEFAULT; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER TABLE ONLY public.spareparts ALTER COLUMN id SET DEFAULT nextval('public.spareparts_id_seq'::regclass);


--
-- Name: stock_receivings id; Type: DEFAULT; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER TABLE ONLY public.stock_receivings ALTER COLUMN id SET DEFAULT nextval('public.stock_receivings_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: validations id; Type: DEFAULT; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER TABLE ONLY public.validations ALTER COLUMN id SET DEFAULT nextval('public.validations_id_seq'::regclass);


--
-- Data for Name: activity_logs; Type: TABLE DATA; Schema: public; Owner: sonyaalexandrapaleng
--

COPY public.activity_logs (id, user_id, action, entity_type, entity_id, detail, created_at) FROM stdin;
1	1	create_sparepart	sparepart	0	Sparepart: test1	2026-06-23 07:12:06.969322
2	2	update_sparepart	sparepart	925	Sparepart: test1	2026-06-23 07:30:31.806339
3	2	update_sparepart	sparepart	925	Sparepart: test1	2026-06-23 07:31:21.081515
4	2	delete_sparepart	sparepart	925	Hapus sparepart: test1	2026-06-23 07:31:50.287104
5	2	create_sparepart	sparepart	0	Sparepart: test2	2026-06-23 07:32:15.393112
6	2	create_employee	user	0	Tambah karyawan: Hasna (ID card: EMP002)	2026-06-24 09:04:09.035344
7	2	update_employee	user	3	Edit karyawan: Hasna	2026-06-24 09:04:42.89409
8	2	update_employee	user	3	Edit karyawan: Hasna	2026-06-26 10:56:50.118951
9	2	create_employee	user	0	Tambah karyawan: Vera (ID card: EMP003)	2026-06-29 15:26:08.234752
10	6	submit_request	request	1	Request 123456 dikirim oleh Vera	2026-06-29 15:28:17.787936
11	1	approve_stage1	validation	1	Elika menyetujui request 123456 (stage 1)	2026-06-29 15:28:41.761904
12	2	create_employee	user	0	Tambah karyawan: Novi (ID card: EMP004)	2026-06-29 15:30:19.406801
13	2	update_employee	user	3	Edit karyawan: Hasna	2026-06-30 10:10:36.112672
14	2	update_employee	user	3	Edit karyawan: Hasna	2026-06-30 10:12:13.160934
15	2	create_employee	user	0	Tambah karyawan: keanu (ID card: EMP005)	2026-07-01 10:07:31.267911
16	2	update_employee	user	6	Edit karyawan: keanu	2026-07-01 10:07:47.0349
17	2	update_employee	user	6	Edit karyawan: keanu	2026-07-01 10:11:13.358092
18	2	update_employee	user	3	Edit karyawan: Hasna	2026-07-01 10:12:21.05618
19	2	delete_employee	user	5	Hapus karyawan: Novi (ID card: EMP004)	2026-07-01 10:55:44.803362
20	2	delete_employee	user	4	Hapus karyawan: Vera (ID card: EMP003)	2026-07-01 10:55:48.438913
21	2	delete_employee	user	2	Hapus karyawan: Sonya Alexandra (ID card: EMP001)	2026-07-01 10:55:56.662509
22	2	update_employee	user	3	Edit karyawan: Hasna	2026-07-01 10:58:45.931123
23	2	update_employee	user	6	Edit karyawan: keanu	2026-07-01 10:59:04.771483
24	2	update_employee	user	3	Edit karyawan: Hasna	2026-07-01 11:15:37.940538
25	2	update_employee	user	3	Edit karyawan: Hasna	2026-07-01 11:15:49.136572
26	2	update_employee	user	3	Edit karyawan: Hasna	2026-07-01 11:16:57.12807
27	2	update_employee	user	3	Edit karyawan: Hasna	2026-07-01 11:18:14.773501
28	2	update_employee	user	3	Edit karyawan: Hasna	2026-07-01 11:19:23.59514
29	2	update_employee	user	3	Edit karyawan: Hasna	2026-07-01 11:20:01.390719
30	2	create_employee	user	0	Tambah karyawan: Vera (ID card: EMP001)	2026-07-01 11:20:43.892501
31	2	update_employee	user	7	Edit karyawan: Vera	2026-07-01 11:20:57.48298
32	2	update_employee	user	7	Edit karyawan: Vera	2026-07-01 11:23:35.088614
33	2	update_employee	user	3	Edit karyawan: Hasna	2026-07-01 11:23:45.787141
34	2	update_employee	user	3	Edit karyawan: Hasna	2026-07-01 11:24:37.552866
35	2	update_employee	user	3	Edit karyawan: Hasna	2026-07-01 11:25:13.211957
36	2	update_employee	user	3	Edit karyawan: Hasna	2026-07-01 11:26:13.441224
37	2	update_employee	user	3	Edit karyawan: Hasna	2026-07-01 11:32:27.877443
38	2	update_employee	user	7	Edit karyawan: Vera	2026-07-01 11:34:22.213293
39	2	update_employee	user	3	Edit karyawan: Hasna	2026-07-01 11:35:50.139308
40	2	update_employee	user	7	Edit karyawan: Vera	2026-07-01 11:37:48.890273
41	2	update_employee	user	7	Edit karyawan: Vera	2026-07-01 11:38:01.555334
42	2	create_employee	user	0	Tambah karyawan: Novi (ID card: EMP009)	2026-07-01 11:40:17.197488
43	2	update_employee	user	8	Edit karyawan: Novi	2026-07-01 11:40:43.797079
44	2	update_employee	user	3	Edit karyawan: Hasna	2026-07-01 11:48:36.09138
45	2	update_employee	user	3	Edit karyawan: Hasna	2026-07-01 11:48:46.416561
46	2	update_employee	user	3	Edit karyawan: Hasna	2026-07-01 11:49:57.900621
47	2	update_employee	user	3	Edit karyawan: Hasna	2026-07-01 11:54:45.469205
48	2	update_employee	user	3	Edit karyawan: Hasna	2026-07-01 11:54:56.897124
49	2	update_employee	user	8	Edit karyawan: Novi	2026-07-01 11:56:11.297405
50	2	update_employee	user	8	Edit karyawan: Novi	2026-07-01 13:16:40.245375
51	2	update_employee	user	3	Edit karyawan: Hasna	2026-07-01 13:16:49.906247
52	2	update_employee	user	9	Edit karyawan: Alexandra	2026-07-01 13:46:11.02946
53	2	update_employee	user	9	Edit karyawan: Alexandra	2026-07-01 13:58:49.505322
54	2	update_employee	user	3	Edit karyawan: Hasna	2026-07-01 13:59:05.099592
55	2	update_employee	user	9	Edit karyawan: Alexandra	2026-07-01 14:52:57.447131
56	2	update_employee	user	9	Edit karyawan: Alexandra	2026-07-01 14:53:03.787163
57	2	update_employee	user	9	Edit karyawan: Alexandra	2026-07-01 14:53:57.628187
58	2	update_employee	user	9	Edit karyawan: Alexandra	2026-07-01 15:19:40.455024
59	2	update_employee	user	6	Edit karyawan: keanu	2026-07-01 15:19:54.463446
60	2	update_employee	user	9	Edit karyawan: Alexandra	2026-07-02 08:36:04.178124
61	2	update_employee	user	3	Edit karyawan: Hasna	2026-07-02 09:09:12.203305
62	2	update_employee	user	3	Edit karyawan: Hasna	2026-07-02 09:09:59.826332
63	2	update_employee	user	3	Edit karyawan: Hasna	2026-07-02 09:10:24.925127
64	2	update_employee	user	9	Edit karyawan: Alexandra	2026-07-02 14:19:03.864159
65	2	delete_employee	user	9	Hapus karyawan: Alexandra (ID card: EMP010)	2026-07-02 14:19:13.084841
66	2	delete_employee	user	3	Hapus karyawan: Hasna (ID card: EMP002)	2026-07-02 14:19:15.716648
67	2	delete_employee	user	8	Hapus karyawan: Novi (ID card: EMP009)	2026-07-02 14:19:19.546832
68	2	delete_employee	user	7	Hapus karyawan: Vera (ID card: EMP001)	2026-07-02 14:19:22.60663
69	2	delete_employee	user	6	Hapus karyawan: keanu (ID card: EMP005)	2026-07-02 14:19:27.294374
70	2	create_employee	user	0	Tambah karyawan: Hasna (ID card: EMP001)	2026-07-02 14:19:41.638232
71	2	update_employee	user	10	Edit karyawan: Hasna	2026-07-02 14:20:41.128861
72	2	create_employee	user	0	Tambah karyawan: Vera (ID card: EMP002)	2026-07-02 14:32:02.398517
73	2	update_employee	user	11	Edit karyawan: Vera	2026-07-02 14:33:02.171539
74	2	create_employee	user	0	Tambah karyawan: sonya (ID card: EMP003)	2026-07-02 14:33:19.593631
75	6	submit_request	request	2	Request 123456 dikirim oleh Vera	2026-07-02 14:37:02.871708
76	2	update_employee	user	10	Edit karyawan: Hasna	2026-07-02 14:37:36.563434
77	2	delete_employee	user	11	Hapus karyawan: Vera (ID card: EMP002)	2026-07-02 14:56:32.740374
78	2	update_employee	user	10	Edit karyawan: Hasna	2026-07-03 15:42:29.633574
79	2	update_employee	user	12	Edit karyawan: sonya	2026-07-03 15:42:40.237654
80	2	update_employee	user	10	Edit karyawan: Hasna	2026-07-03 15:43:47.23988
82	2	update_employee	user	10	Edit karyawan: Hasna	2026-07-03 15:45:05.783529
81	2	update_employee	user	12	Edit karyawan: sonya	2026-07-03 15:44:44.942359
83	2	create_employee	user	0	Tambah karyawan: Vera (ID card: EMP005)	2026-07-03 15:45:36.114296
84	2	update_employee	user	10	Edit karyawan: Hasna	2026-07-07 08:44:33.814368
85	2	update_employee	user	13	Edit karyawan: Vera	2026-07-07 14:31:33.779285
86	2	update_employee	user	13	Edit karyawan: Vera	2026-07-07 14:31:46.485678
87	2	update_employee	user	12	Edit karyawan: sonya	2026-07-07 14:32:20.889645
88	2	update_employee	user	10	Edit karyawan: Hasna	2026-07-07 14:33:26.862233
89	2	update_employee	user	13	Edit karyawan: Vera	2026-07-07 14:33:48.604962
90	2	update_employee	user	12	Edit karyawan: sonya	2026-07-07 14:35:46.463937
91	2	update_employee	user	13	Edit karyawan: Vera	2026-07-07 14:37:03.504972
92	2	create_employee	user	0	Tambah karyawan: keanu (ID card: EMP004)	2026-07-07 14:51:32.476969
93	2	update_employee	user	15	Edit karyawan: Karyawan DB Test	2026-07-08 14:17:44.535358
94	2	update_employee	user	15	Edit karyawan: Karyawan DB Test	2026-07-08 14:19:20.148544
95	2	update_employee	user	10	Edit karyawan: Hasna	2026-07-08 14:21:27.035725
96	2	update_employee	user	15	Edit karyawan: Karyawan DB Test	2026-07-08 14:21:45.993329
97	2	update_employee	user	15	Edit karyawan: Karyawan DB Test	2026-07-08 14:23:28.204033
98	2	create_employee	user	0	Tambah karyawan: test2 (ID card: test2)	2026-07-08 14:24:35.425208
99	2	create_employee	user	0	Tambah karyawan: test3 (ID card: test3)	2026-07-08 14:28:29.894948
100	2	update_employee	user	18	Edit karyawan: Budi Santoso	2026-07-08 15:05:53.793588
101	2	update_employee	user	18	Edit karyawan: Budi Santoso	2026-07-08 15:05:57.728883
102	2	update_employee	user	18	Edit karyawan: Budi Santoso	2026-07-08 15:08:30.406035
103	2	update_employee	user	19	Edit karyawan: Siti Aminah	2026-07-08 15:10:18.792546
104	2	update_employee	user	20	Edit karyawan: Rian Hidayat	2026-07-08 15:32:26.251522
105	2	update_employee	user	20	Edit karyawan: Rian Hidayat	2026-07-08 15:33:20.345022
106	2	update_employee	user	20	Edit karyawan: Rian Hidayat	2026-07-08 15:33:36.017003
107	2	update_employee	user	20	Edit karyawan: Rian Hidayat	2026-07-08 15:37:56.968116
108	2	update_employee	user	20	Edit karyawan: Rian Hidayat	2026-07-08 15:39:05.404318
109	2	create_employee	user	0	Tambah karyawan: test (ID card: test)	2026-07-08 15:40:13.268513
110	2	update_employee	user	21	Edit karyawan: test	2026-07-08 15:41:41.444427
111	2	update_employee	user	21	Edit karyawan: test	2026-07-08 15:42:45.960072
112	2	update_employee	user	21	Edit karyawan: test	2026-07-09 09:55:50.130091
113	2	update_employee	user	17	Edit karyawan: test3	2026-07-09 11:38:40.91968
114	2	update_employee	user	16	Edit karyawan: test2	2026-07-09 11:39:01.846802
115	2	update_employee	user	12	Edit karyawan: sonya	2026-07-09 11:40:41.25601
116	2	update_employee	user	23	Edit karyawan: alexandra	2026-07-09 13:47:43.242689
117	2	update_employee	user	23	Edit karyawan: alexandra	2026-07-09 13:48:04.431814
118	2	update_employee	user	22	Edit karyawan: sonya	2026-07-09 13:49:05.181346
119	2	update_employee	user	24	Edit karyawan: paleng	2026-07-09 13:49:19.661336
120	2	create_employee	user	0	Tambah karyawan: keanu (ID card: EMP004)	2026-07-09 13:50:42.029085
121	2	create_employee	user	0	Tambah karyawan: Martin (ID card: EMP005)	2026-07-09 13:57:26.389488
122	2	update_employee	user	26	Edit karyawan: Martin	2026-07-09 14:53:07.082446
123	2	update_employee	user	26	Edit karyawan: Martin	2026-07-09 14:54:39.768329
124	6	submit_request	request	3	Request 123456 dikirim oleh sonya	2026-07-09 15:08:54.9165
125	1	approve_stage1	validation	3	Elika menyetujui request 123456 (stage 1)	2026-07-09 15:25:22.214709
126	1	approve_stage1	validation	2	Elika menyetujui request 123456 (stage 1)	2026-07-09 15:25:26.949978
127	2	update_user	user	2	Edit user: spvsp (spv_sp)	2026-07-10 08:10:01.306629
128	6	create	non_inventory	1	Permintaan Non-Inventory 07/26/10-1 dibuat (MTC2, 4 item)	2026-07-10 08:11:03.361923
129	2	approve	non_inventory	1	Disetujui oleh SPV Pemohon — 07/26/10-1	2026-07-10 08:11:22.970743
130	1	approve	non_inventory	1	Disetujui oleh Admin SP — 07/26/10-1	2026-07-10 08:19:28.004941
131	2	approve	non_inventory	1	Disetujui oleh SPV SP — 07/26/10-1	2026-07-10 08:19:42.282081
132	2	update_user	user	2	Edit user: spvsp (spv_sp)	2026-07-13 07:46:34.338566
133	2	update_user	user	2	Edit user: spvsp (spv_sp)	2026-07-13 07:47:11.090595
134	2	approve_stage2	validation	3	Hasna menyetujui request 123456 (stage 2)	2026-07-13 07:47:22.514755
135	2	update_user	user	2	Edit user: spvsp (spv_sp)	2026-07-13 07:47:40.900833
136	6	create	non_inventory	2	Permintaan Non-Inventory 07/26/24-1 dibuat (UTL, 1 item)	2026-07-24 11:15:16.77808
137	2	update_user	user	15	Edit user: sonyatest (spv_pemohon)	2026-07-24 11:39:33.207797
\.


--
-- Data for Name: bpjt_daily_counter; Type: TABLE DATA; Schema: public; Owner: sonyaalexandrapaleng
--

COPY public.bpjt_daily_counter (counter_date, last_seq) FROM stdin;
2026-07-10	1
2026-07-24	1
\.


--
-- Data for Name: employee_id_cards; Type: TABLE DATA; Schema: public; Owner: sonyaalexandrapaleng
--

COPY public.employee_id_cards (id, id_card_number, full_name, is_active, notes, created_by, created_at, updated_at, fingerprint_id, fingerprint_template) FROM stdin;
25	EMP004	keanu	t	jari manis	2	2026-07-09 13:50:42.011244	2026-07-09 13:50:42.011244	\N	PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz48RmlkPjxCeXRlcz5SazFTQUNBeU1BQUJ1QUF6L3Y4QUFBRmxBWWdBeEFERUFRQUFBRlpFUUtVQVhWWmtnSFVCRlM5ZVFIY0JQQzlYZ0lZQVdHTldRRUlCRG9kVmdLNEFiYUJVUUxJQk5ZTlNRSHdCVUN0UFFHc0JVVGRPUUpJQTNVRk1RRHNBOFlGTVFLVUFqVTlNUUdFQlhaTk1RRVlBL29sTGdGMEFad3RMZ0lFQTI0dExnTEFBNnpGTFFGd0FSUkpLUUwwQWJrMUtnTDRCV1lWSlFJOEFYYTVKZ0VvQVVYRklRR01BVWdoSWdJMEFTR0JIUUlNQlFDbEhnSUlBbFFkR1FKb0FxcFpHUUxzQTJJeEdRTk1CUElkR2dFb0EwQ05GZ0dzQVRBaEZnRlVBWjNGRmdJNEJWeVZGUUZJQXJYeERRRUlCUGk5RGdITUFpUUpDUVFZQWppNUNRRVVCUlRSQ1FMVUF0MEZCUVFjQTJ5dEJRUVlBd2pKQlFJZ0Fock5BUU13QXRwSkFnUFFBM2pOQVFKY0JZSHBBUUtRQVFWWkFnS0FBamxKQWdQNEJKRVpBZ1FFQXpUWS9RUWNBNFNJL1FPb0FXVDQvUU5BQW16NC9RSVlBNElrL1FIRUFPQVErUU9jQWJ6OCtRT1FCUlRNK1FQSUJMNWMrUVFvQXRvZzlRRDRBL2lzOVFEY0JQSTA5Z1JNQTFvazhnSHdCV1RVOFFKd0JZSHc4UUpJQXIxWTdRTW9Bc0k4N1FQZ0JGNWs3UUVJQklJazdnUVlBODRjN0FBQT08L0J5dGVzPjxGb3JtYXQ+MTc2OTQ3MzwvRm9ybWF0PjxWZXJzaW9uPjEuMC4wPC9WZXJzaW9uPjwvRmlkPg==
26	EMP005	Martin	t	jari jempol kiri	2	2026-07-09 13:57:26.371239	2026-07-09 14:54:39.757603	\N	PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz48RmlkPjxCeXRlcz5SazFTQUNBeU1BQUJ1QUF6L3Y4QUFBRmxBWWdBeEFERUFRQUFBRlpFUUVZQk5uVmhRSHNCRVJaYmdMSUJVZ3RiUU5BQXl3WmFRRzBBWkJ4WFFKMEFaeFJYZ01NQWNtcFhRS29CQnhCWFFPY0ErTEJWZ0hVQWczRlVnS2tCTmd4VWdJSUFhSE5VUU9BQW1XTlRnTFFBdFFOVFFNb0JFUVpUZ0hzQWN4dFNnRndBZVIxU1FOMEE4V1ZTUU9ZQkY2NVJnTXdBNUdkUmdJOEFWeHRRUVF3QTdhNVBRTXdBWkExT1FMUUFSUk5OZ1A0QWdnWkxnUU1CTnFsTGdSQUFnRnhKUU1rQXBBWkpRS0lBcXhSSlFNWUFzR1JHUU1RQkhnVkdRTlFBbFFWRlFFWUJZUnhGZ09jQlZFMUZnSWdBdEJaRFFEWUJQeGRDUVJNQkpGRkJRTjBCVjF3OWdOa0FtUVE4UVJBQWJRVTdRUjRBMXJJN1FRWUJSazg3UVNJQXFRSTZnTkFCWlZrNmdMWUFYUkE1UUNrQTQyNDVRQzhCSW5zNFFSY0JLVkU0Z09vQlRxVTRnQ3NBZzNNNFFEQUJLM0k0UU5BQlgyZzRnQ3NBMTJ3M2dDc0JEMzAzZ0xrQlp3NDNRTVVCUlFJMlFSNEF3ckkyZ0M0QkpSczFRSHdCYXg0MUFDOEFlaDQxQVJrQkpFMDFBUndBaGdRekFRTUFXUW96QUNnQW5uSXpBQ1lBMkhFekFDTUEvM0F6QUIwQWluVXlBQjBBa0IweUFBQT08L0J5dGVzPjxGb3JtYXQ+MTc2OTQ3MzwvRm9ybWF0PjxWZXJzaW9uPjEuMC4wPC9WZXJzaW9uPjwvRmlkPg==
23	EMP002	alexandra	t	jari telunjuk	\N	2026-07-09 13:12:36.749423	2026-07-09 13:48:04.420823	\N	PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz48RmlkPjxCeXRlcz5SazFTQUNBeU1BQUJ1QUF6L3Y4QUFBRmxBWWdBeEFERUFRQUFBRlpFUUpRQWFtQmpRTThBUmFCZ1FHTUF5b2RnZ0VvQXNZVmVnT0VBWVVaY1FNd0FKMDFjZ01BQTluUllRRm9BZkhOWWdGZ0ExNGRZUUpjQktraFlRSWdBcTRWWFFQSUE3WVZXUUo0QlJRQldnTXdBcjQxVlFIRUF3SWxVUUhrQVdHbFVnTGtBOFNsVVFLb0E2REZUUUprQkdVaFNRSU1BWHdKUVFMMEFqMGxQZ0hJQWt3OVBRR0VCRlROUFFGd0JPMGhQZ0hJQkt6Wk9nSWdBZ21kTlFLb0FEMDFNUUNvQThtNU1nS29CR2hSTWdPY0ExNGxMZ05vQW9ENUtnSjBBbEc1S2dKb0FwWWRKZ0RBQTBITkpRR0FCUzB4SlFRSUF6VEZJUUZZQkJTMUhRSHdCQ2FKSGdJRUJDcU5HZ1FNQVprRkZRS0FBOHpWRmdRd0Fna0JGUVBnQTNUTkZnSzBCVjFoRlFEOEJCWTlFZ0dnQlRFMUVRUWNBNFN4RWdLOEFxWXhEZ05BQktpUkRRSWtCSHE5Q2dGRUJCU2xDZ01NQlVHSkNRSElCVVVsQ2dFb0FRbWRCUU9RQWpVQkJnQ0VBc1IxQWdRRUFTVU5BUURjQTVIWS9RTFVCRTJVL1FEb0JLcEkvZ1FjQWMwRStnREFCS0RJK2dGWUJVVVkrZ1BvQXZUUStnUUFBNklZOVFOb0JVaGs5Z1BVQXVZODlRQ29BbllBOEFBQT08L0J5dGVzPjxGb3JtYXQ+MTc2OTQ3MzwvRm9ybWF0PjxWZXJzaW9uPjEuMC4wPC9WZXJzaW9uPjwvRmlkPg==
22	EMP001	sonya	t	jari jempol	\N	2026-07-09 13:12:36.749423	2026-07-09 13:49:05.167896	\N	PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz48RmlkPjxCeXRlcz5SazFTQUNBeU1BQUJ1QUF6L3Y4QUFBRmxBWWdBeEFERUFRQUFBRlpFUUtJQXhVZGtnREFBekd4aVFHTUF5RmhnZ04wQk1JRmNnR0VBamFWV2dKTUJTMWhWUUxBQXlKdFVRSHNBeXFCVFFOMEFwSnBTUUpvQWswZFBRSmNCR1Q1UFFJMEFkYUJPUURjQXBHQk9RSVlCTUVoT1FNVUFiVXBOUUcwQklwaE1RS0FBSmsxS1FDWUFTRlZLUUJrQWdsNUtRTUFCVW1wS2dEUUE5SU5IZ0pZQllRUkhnS2tBcjBaSFFIZ0JUQVJHUUdzQktKbEdRUFVBekVGRlFQVUFuVVJGZ0hzQUcwMURRSWdBSUVoRFFLVUFxa2REUVFFQWRFUkNnRjBBdFZoQ1FCMEFaRmRBZ1F3QW5wOC9nTllCRVk4L1FKY0FIRWsrUU5zQkJaRStRUG9CRkpFK2dCY0FmbDQrUVB3QWhwMDlRSGdCSXo4OFFPd0FQVUU4UVJjQXlqRThRUFVCUkN3OFFGZ0JBNVk3Z0pjQkJ6ODdRRW9CUktBNmdGWUFEazQ2UUNNQkZTZzZnUUVBbVVRNWdIVUJPMDg1UU9zQlJETTRnTDhCU1NnNFFQd0FnS1EzUUlJQlVnQTNRSDRCUlUwMmdPRUJTVEkyUVBVQlNpODJnQlFBZVdBMmdQc0Fua1EyUVFvQXIwWTJRQjBCQ0NJMmdLVUJFVGcyZ0JRQXhtazFnSWdCWVZJMUFHc0FEa3cxQVFBQlBpdzFBTEFCU3lVMUFBQT08L0J5dGVzPjxGb3JtYXQ+MTc2OTQ3MzwvRm9ybWF0PjxWZXJzaW9uPjEuMC4wPC9WZXJzaW9uPjwvRmlkPg==
24	EMP003	paleng	t	jari tengah	\N	2026-07-09 13:12:36.749423	2026-07-09 13:49:19.642726	\N	PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz48RmlkPjxCeXRlcz5SazFTQUNBeU1BQUJ1QUF6L3Y4QUFBRmxBWWdBeEFERUFRQUFBRlpFZ0tvQkNETmpRT3NCQnl4amdMNEFXRkZlZ0pNQVkzTmRnTHNCRVRGYVFMWUJKVEpYZ0tVQklqTlVRUEVBNUlsVFFLVUFmMmxSUU4wQUtwNVBRRzRBMEl0UFFIOEE5REpQUU5RQktpbFBRR1lCRVRSTVFHd0F0WVpNZ0U4QXZZVk1RUG9CS1lWTWdQZ0FVa1JLZ0pjQVkzRktRRG9CUml0S2dMQUJKQzlKUUpjQVJnSklnT0VCTm9GSVFMSUF0cEpJUUZvQXZDZElRSE1BdEl4SGdGb0EyeTlIUU84QlVTZEhnUFVBUmtOR1FGOEEyQzFHZ0s4QXZZOUZRUTBCR29oRVFNQUJMeWxEUUNrQk16RkNRTllCUzN0Q1FGWUJBalZDZ0xJQlNtWkNnSm9BSXF4QmdSRUFmejVCUU93QU8wQkJRT3NBK3pGQlFRSUJQeWxCZ1JBQWJ6aEFRT3NBOWpKQWdEOEJLaTFBUUVZQk15UkFRRllBL0RjL2dDZ0FzSEkvUVA0QXFwUStnRllBK0RjK2dRSUJNaXMrUUs4QW5wNCtnR3NCSURnK1FNVUFQRkE5Z0prQWZxNDlRR0FCRnpVOWdEc0JQb0U5Z0YwQTU0azlRUXdCSWlnOVFQc0FYRVE4UVBJQWxKWTdRS01Bb1lJN2dHZ0JEVEU3Z0V3QktKUTZRRFVCTTRrNlFHRUJUbUE2UVBVQkxvSTZRUVlBWFRJNUFBQT08L0J5dGVzPjxGb3JtYXQ+MTc2OTQ3MzwvRm9ybWF0PjxWZXJzaW9uPjEuMC4wPC9WZXJzaW9uPjwvRmlkPg==
\.


--
-- Data for Name: non_inventory_approvals; Type: TABLE DATA; Schema: public; Owner: sonyaalexandrapaleng
--

COPY public.non_inventory_approvals (id, request_id, stage, approver_id, action, actioned_at) FROM stdin;
1	1	1	2	release	2026-07-10 08:11:22.967952+07
2	1	2	1	release	2026-07-10 08:19:28.00105+07
3	1	3	2	release	2026-07-10 08:19:42.280561+07
\.


--
-- Data for Name: non_inventory_items; Type: TABLE DATA; Schema: public; Owner: sonyaalexandrapaleng
--

COPY public.non_inventory_items (id, request_id, deskripsi, qty, peruntukan, lampiran) FROM stdin;
1	1	service AC	1	AC di office	
2	1	service AC	1	AC di office	
3	1	service AC	1	AC di office	
4	1	service AC	1	AC di office	
5	2	service AC	1	AC di office	
\.


--
-- Data for Name: non_inventory_requests; Type: TABLE DATA; Schema: public; Owner: sonyaalexandrapaleng
--

COPY public.non_inventory_requests (id, no_bpjt, pemohon_id, nama_pemohon, seksi_divisi, tanggal_pemakaian, keterangan, lampiran_url, status, current_stage, submitted_at, updated_at, is_completed, is_done) FROM stdin;
1	07/26/10-1	6	Sonya alexandra	MTC2	2026-07-23			approved	3	2026-07-10 08:11:03.335182+07	2026-07-24 07:42:53.015571+07	f	t
2	07/26/24-1	6	Sonya alexandra	UTL	2026-07-06			pending	0	2026-07-24 11:15:16.771746+07	2026-07-24 11:15:16.771746+07	f	f
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: sonyaalexandrapaleng
--

COPY public.notifications (id, user_id, message, is_read, created_at) FROM stdin;
13	3	Ada request menunggu validasi Anda (SPV Pemohon MTC2): 07/26/10-1	t	2026-07-10 08:11:03.364488
2	6	Request 123456 sedang diproses Admin SP (Tahap 1)	t	2026-06-29 15:28:17.765428
4	6	Request 123456 sedang diproses SPV Pemohon (Tahap 2)	t	2026-06-29 15:28:41.82448
6	6	Request 123456 sedang diproses Admin SP (Tahap 1)	t	2026-07-02 14:37:02.847935
8	6	Request 123456 sedang diproses Admin SP (Tahap 1)	t	2026-07-09 15:08:54.895758
10	6	Request 123456 sedang diproses SPV Pemohon (Tahap 2)	t	2026-07-09 15:25:22.265391
12	6	Request 123456 sedang diproses SPV Pemohon (Tahap 2)	t	2026-07-09 15:25:27.001108
16	6	Request 07/26/10-1 sedang diproses Admin SP (Tahap 1)	t	2026-07-10 08:11:22.971956
18	6	Request 07/26/10-1 sedang diproses SPV Pemohon (Tahap 2)	t	2026-07-10 08:19:28.007322
19	6	Request 07/26/10-1 telah DISETUJUI. Silakan ambil sparepart.	t	2026-07-10 08:19:42.282619
21	6	Request 123456 sedang diproses SPV SP (Tahap 3)	t	2026-07-13 07:47:22.540638
1	1	Ada request baru menunggu validasi Admin SP: 123456	t	2026-06-29 15:28:17.749385
5	1	Ada request baru menunggu validasi Admin SP: 123456	t	2026-07-02 14:37:02.836101
7	1	Ada request baru menunggu validasi Admin SP: 123456	t	2026-07-09 15:08:54.882498
14	1	Ada request baru menunggu validasi Admin SP: 07/26/10-1	t	2026-07-10 08:11:03.384151
15	1	Ada request baru menunggu validasi Admin SP: 07/26/10-1	t	2026-07-10 08:11:22.971812
22	3	Ada request menunggu validasi Anda (SPV Pemohon UTL): 07/26/24-1	f	2026-07-24 11:15:16.790335
23	1	Ada request baru menunggu validasi Admin SP: 07/26/24-1	f	2026-07-24 11:15:16.806068
3	2	Ada request dari divisi BM menunggu validasi Anda (Tahap 2 - SPV Pemohon BM): 123456	t	2026-06-29 15:28:41.80977
9	2	Ada request dari divisi BM menunggu validasi Anda (Tahap 2 - SPV Pemohon BM): 123456	t	2026-07-09 15:25:22.252761
11	2	Ada request dari divisi BM menunggu validasi Anda (Tahap 2 - SPV Pemohon BM): 123456	t	2026-07-09 15:25:26.990088
17	2	Ada request menunggu validasi akhir SPV SP (Tahap 3): 07/26/10-1	t	2026-07-10 08:19:28.007313
20	2	Ada request menunggu validasi akhir SPV SP (Tahap 3): 123456	t	2026-07-13 07:47:22.533698
\.


--
-- Data for Name: request_items; Type: TABLE DATA; Schema: public; Owner: sonyaalexandrapaleng
--

COPY public.request_items (id, request_id, sparepart_id, no_baki, jumlah, jumlah_disetujui, mesin_area, nama_item_snapshot, kode_oracle_snapshot, no_part_snapshot) FROM stdin;
1	1	105	B221	1	1		Adjustmen bolt	SPMEBO0290	
2	2	105	B221	1	1		Adjustmen bolt	SPMEBO0290	
3	3	105	B221	1	1		Adjustmen bolt	SPMEBO0290	
\.


--
-- Data for Name: request_order_items; Type: TABLE DATA; Schema: public; Owner: sonyaalexandrapaleng
--

COPY public.request_order_items (id, request_order_id, sparepart_id, nama_item_snapshot, kode_oracle_snapshot, jumlah) FROM stdin;
\.


--
-- Data for Name: request_orders; Type: TABLE DATA; Schema: public; Owner: sonyaalexandrapaleng
--

COPY public.request_orders (id, pemohon_id, requester_name, sparepart_id, nama_item_snapshot, kode_oracle_snapshot, status, created_at, completed_at) FROM stdin;
\.


--
-- Data for Name: requests; Type: TABLE DATA; Schema: public; Owner: sonyaalexandrapaleng
--

COPY public.requests (id, no_wr_wo, pemohon_id, requester_name, requester_source, division, status, current_stage, rejection_reason, session_id, submitted_at, updated_at, mesin_area) FROM stdin;
1	123456	6	Vera	fingerprint	BM	stage2	2	\N		2026-06-29 15:28:17.634273	2026-06-29 15:28:41.722314	Line K
2	123456	6	Vera	fingerprint	BM	stage2	2	\N		2026-07-02 14:37:02.727174	2026-07-09 15:25:26.903867	Line A
3	123456	6	sonya	fingerprint	BM	stage3	3	\N		2026-07-09 15:08:54.771904	2026-07-13 07:47:22.514227	Line A
\.


--
-- Data for Name: rfid_sessions; Type: TABLE DATA; Schema: public; Owner: sonyaalexandrapaleng
--

COPY public.rfid_sessions (session_id, request_id, pemohon_id, created_at, expires_at, is_active) FROM stdin;
rfid-1782266461789647000	\N	2	2026-06-24 09:01:01.790762	2026-06-24 09:31:01.789649	t
rfid-1782266479042427000	\N	2	2026-06-24 09:01:19.042517	2026-06-24 09:31:19.042431	t
rfid-1782266479042613000	\N	2	2026-06-24 09:01:19.062719	2026-06-24 09:31:19.042614	t
rfid-1782266610353724000	\N	2	2026-06-24 09:03:30.353906	2026-06-24 09:33:30.353729	t
rfid-1782266610354212000	\N	2	2026-06-24 09:03:30.354832	2026-06-24 09:33:30.354214	t
rfid-1782266622057133000	\N	2	2026-06-24 09:03:42.057238	2026-06-24 09:33:42.057136	t
rfid-1782266622057315000	\N	2	2026-06-24 09:03:42.057451	2026-06-24 09:33:42.057316	t
rfid-1782266652897302000	\N	2	2026-06-24 09:04:12.897401	2026-06-24 09:34:12.897306	t
rfid-1782266652897590000	\N	2	2026-06-24 09:04:12.898004	2026-06-24 09:34:12.897592	t
rfid-1782266675041576000	\N	2	2026-06-24 09:04:35.041658	2026-06-24 09:34:35.04158	t
rfid-1782266675041687000	\N	2	2026-06-24 09:04:35.042453	2026-06-24 09:34:35.041688	t
rfid-1782266706675740000	\N	6	2026-06-24 09:05:06.675918	2026-06-24 09:35:06.675743	t
rfid-1782266848383027000	\N	6	2026-06-24 09:07:28.383169	2026-06-24 09:37:28.383032	t
rfid-1782266848617119000	\N	6	2026-06-24 09:07:28.617241	2026-06-24 09:37:28.61713	t
rfid-1782266848798763000	\N	6	2026-06-24 09:07:28.798837	2026-06-24 09:37:28.798767	t
rfid-1782266911571875000	\N	6	2026-06-24 09:08:31.571991	2026-06-24 09:38:31.57188	t
rfid-1782266917059517000	\N	6	2026-06-24 09:08:37.059599	2026-06-24 09:38:37.059521	t
rfid-1782272868725679000	\N	2	2026-06-24 10:47:48.753282	2026-06-24 11:17:48.725682	t
rfid-1782272868724583000	\N	2	2026-06-24 10:47:48.751073	2026-06-24 11:17:48.724588	t
rfid-1782350620751653000	\N	6	2026-06-25 08:23:40.755411	2026-06-25 08:53:40.751657	t
rfid-1782446203947263300	\N	2	2026-06-26 10:56:44.741247	2026-06-26 11:26:43.947263	t
rfid-1782446212069105700	\N	2	2026-06-26 10:56:52.860922	2026-06-26 11:26:52.069105	t
rfid-1782446212068313200	\N	2	2026-06-26 10:56:52.860906	2026-06-26 11:26:52.068313	t
rfid-1782461483189901500	\N	2	2026-06-26 15:11:23.118721	2026-06-26 15:41:23.189901	t
rfid-1782695972361769900	\N	2	2026-06-29 08:19:28.368644	2026-06-29 08:49:32.361769	t
rfid-1782695972362502400	\N	2	2026-06-29 08:19:28.414829	2026-06-29 08:49:32.362502	t
rfid-1782696001144512900	\N	6	2026-06-29 08:19:57.14383	2026-06-29 08:50:01.144512	t
rfid-1782698909640281100	\N	6	2026-06-29 09:08:25.658674	2026-06-29 09:38:29.640281	t
rfid-1782699124416437300	\N	6	2026-06-29 09:12:00.435354	2026-06-29 09:42:04.416437	t
rfid-1782699125490004900	\N	6	2026-06-29 09:12:01.502058	2026-06-29 09:42:05.490004	t
rfid-1782699125628203600	\N	6	2026-06-29 09:12:01.639783	2026-06-29 09:42:05.628203	t
rfid-1782699125790120500	\N	6	2026-06-29 09:12:01.799503	2026-06-29 09:42:05.79012	t
rfid-1782699125972329300	\N	6	2026-06-29 09:12:01.981997	2026-06-29 09:42:05.972329	t
rfid-1782699126151312400	\N	6	2026-06-29 09:12:02.16063	2026-06-29 09:42:06.151312	t
rfid-1782699126306928000	\N	6	2026-06-29 09:12:02.316184	2026-06-29 09:42:06.306928	t
rfid-1782699126529113300	\N	6	2026-06-29 09:12:02.537976	2026-06-29 09:42:06.529113	t
rfid-1782700626087847000	\N	6	2026-06-29 09:37:02.096219	2026-06-29 10:07:06.087847	t
rfid-1782700626364157100	\N	6	2026-06-29 09:37:02.3584	2026-06-29 10:07:06.364157	t
rfid-1782700626530288700	\N	6	2026-06-29 09:37:02.524515	2026-06-29 10:07:06.530288	t
rfid-1782700626761435800	\N	6	2026-06-29 09:37:02.755864	2026-06-29 10:07:06.761435	t
rfid-1782700843590907900	\N	6	2026-06-29 09:40:39.592714	2026-06-29 10:10:43.590907	t
rfid-1782701787484596300	\N	6	2026-06-29 09:56:23.504722	2026-06-29 10:26:27.484596	t
rfid-1782702215873755300	\N	6	2026-06-29 10:03:31.884249	2026-06-29 10:33:35.873755	t
rfid-1782702746584257500	\N	6	2026-06-29 10:12:22.595394	2026-06-29 10:42:26.584257	t
rfid-1782702881665212300	\N	6	2026-06-29 10:14:37.690101	2026-06-29 10:44:41.665212	t
rfid-1782702882002298900	\N	6	2026-06-29 10:14:38.011947	2026-06-29 10:44:42.002298	t
rfid-1782702882370538600	\N	6	2026-06-29 10:14:38.381706	2026-06-29 10:44:42.370538	t
rfid-1782702951008809600	\N	6	2026-06-29 10:15:47.015488	2026-06-29 10:45:51.008809	t
rfid-1782703320966722500	\N	6	2026-06-29 10:21:56.98577	2026-06-29 10:52:00.966722	t
rfid-1782706106614964700	\N	6	2026-06-29 11:08:22.649242	2026-06-29 11:38:26.614964	t
rfid-1782706215421260300	\N	6	2026-06-29 11:10:11.449292	2026-06-29 11:40:15.42126	t
rfid-1782706414774436500	\N	6	2026-06-29 11:13:30.812925	2026-06-29 11:43:34.774436	t
rfid-1782706506459289200	\N	6	2026-06-29 11:15:02.485335	2026-06-29 11:45:06.459289	t
rfid-1782706796142997700	\N	6	2026-06-29 11:19:52.134116	2026-06-29 11:49:56.142997	t
rfid-1782707005530166300	\N	6	2026-06-29 11:23:21.512583	2026-06-29 11:53:25.530166	t
rfid-1782707702144038200	\N	6	2026-06-29 11:34:58.123915	2026-06-29 12:05:02.144038	t
rfid-1782708155572635500	\N	6	2026-06-29 11:42:31.546883	2026-06-29 12:12:35.572635	t
rfid-1782713283569012500	\N	6	2026-06-29 13:07:59.59544	2026-06-29 13:38:03.569012	t
rfid-1782713394042490500	\N	6	2026-06-29 13:09:50.060556	2026-06-29 13:39:54.04249	t
rfid-1782713394985339900	\N	6	2026-06-29 13:09:51.002939	2026-06-29 13:39:54.985339	t
rfid-1782713395731806000	\N	6	2026-06-29 13:09:51.751751	2026-06-29 13:39:55.731806	t
rfid-1782714257290287900	\N	6	2026-06-29 13:24:13.298713	2026-06-29 13:54:17.290287	t
rfid-1782715407721517600	\N	6	2026-06-29 13:43:23.758455	2026-06-29 14:13:27.721517	t
rfid-1782715408865311700	\N	6	2026-06-29 13:43:24.888701	2026-06-29 14:13:28.865311	t
rfid-1782715409075269100	\N	6	2026-06-29 13:43:25.096709	2026-06-29 14:13:29.075269	t
rfid-1782715409981002600	\N	6	2026-06-29 13:43:26.005271	2026-06-29 14:13:29.981002	t
rfid-1782720312582263800	\N	6	2026-06-29 15:05:08.547656	2026-06-29 15:35:12.582263	t
rfid-1782720316842871500	\N	6	2026-06-29 15:05:12.81243	2026-06-29 15:35:16.842871	t
rfid-1782720320391877700	\N	6	2026-06-29 15:05:16.347759	2026-06-29 15:35:20.391877	t
rfid-1782720320923633900	\N	6	2026-06-29 15:05:16.881529	2026-06-29 15:35:20.923633	t
rfid-1782720563165596900	\N	2	2026-06-29 15:09:19.119612	2026-06-29 15:39:23.165596	t
rfid-1782720563169481200	\N	2	2026-06-29 15:09:19.13962	2026-06-29 15:39:23.169481	t
rfid-1782720624761444800	\N	2	2026-06-29 15:10:20.726001	2026-06-29 15:40:24.761444	t
rfid-1782720624765172100	\N	2	2026-06-29 15:10:20.738246	2026-06-29 15:40:24.765172	t
rfid-1782721534825596000	\N	2	2026-06-29 15:25:30.811077	2026-06-29 15:55:34.825596	t
rfid-1782721534826689800	\N	2	2026-06-29 15:25:30.907046	2026-06-29 15:55:34.826689	t
rfid-1782721581167380800	\N	2	2026-06-29 15:26:17.146823	2026-06-29 15:56:21.16738	t
rfid-1782721581168241000	\N	2	2026-06-29 15:26:17.155709	2026-06-29 15:56:21.168241	t
rfid-1782721637549491300	\N	6	2026-06-29 15:27:13.529253	2026-06-29 15:57:17.549491	t
rfid-1782721745072991400	\N	2	2026-06-29 15:29:01.049992	2026-06-29 15:59:05.072991	t
rfid-1782721745074209900	\N	2	2026-06-29 15:29:01.059006	2026-06-29 15:59:05.074209	t
rfid-1782783615356422100	\N	2	2026-06-30 08:40:11.029629	2026-06-30 09:10:15.356422	t
rfid-1782783635408120300	\N	6	2026-06-30 08:40:31.075018	2026-06-30 09:10:35.40812	t
rfid-1782786181268665300	\N	6	2026-06-30 09:22:56.946291	2026-06-30 09:53:01.268665	t
rfid-1782786255354767300	\N	6	2026-06-30 09:24:11.022266	2026-06-30 09:54:15.354767	t
rfid-1782786256338012900	\N	6	2026-06-30 09:24:12.002436	2026-06-30 09:54:16.338012	t
rfid-1782786256447977300	\N	6	2026-06-30 09:24:12.112988	2026-06-30 09:54:16.447977	t
rfid-1782786256606002600	\N	6	2026-06-30 09:24:12.270617	2026-06-30 09:54:16.606002	t
rfid-1782786256798605800	\N	6	2026-06-30 09:24:12.464299	2026-06-30 09:54:16.798605	t
rfid-1782786256949332500	\N	6	2026-06-30 09:24:12.616571	2026-06-30 09:54:16.949332	t
rfid-1782786430328721200	\N	6	2026-06-30 09:27:06.000362	2026-06-30 09:57:10.328721	t
rfid-1782786431152345600	\N	6	2026-06-30 09:27:06.818797	2026-06-30 09:57:11.152345	t
rfid-1782786431290058000	\N	6	2026-06-30 09:27:06.954214	2026-06-30 09:57:11.290058	t
rfid-1782786431511962400	\N	6	2026-06-30 09:27:07.177414	2026-06-30 09:57:11.511962	t
rfid-1782786431855374800	\N	6	2026-06-30 09:27:07.522054	2026-06-30 09:57:11.855374	t
rfid-1782786802292944600	\N	6	2026-06-30 09:33:17.955923	2026-06-30 10:03:22.292944	t
rfid-1782787666921171200	\N	6	2026-06-30 09:47:42.571576	2026-06-30 10:17:46.921171	t
rfid-1782787668226141200	\N	6	2026-06-30 09:47:43.87708	2026-06-30 10:17:48.226141	t
rfid-1782788893279501200	\N	2	2026-06-30 10:08:08.919492	2026-06-30 10:38:13.279501	t
rfid-1782788893280304300	\N	2	2026-06-30 10:08:08.961341	2026-06-30 10:38:13.280304	t
rfid-1782788989451026900	\N	2	2026-06-30 10:09:45.08326	2026-06-30 10:39:49.451026	t
rfid-1782788989451534700	\N	2	2026-06-30 10:09:45.092887	2026-06-30 10:39:49.451534	t
rfid-1782789057528654000	\N	6	2026-06-30 10:10:53.161122	2026-06-30 10:40:57.528654	t
rfid-1782789099232146700	\N	2	2026-06-30 10:11:34.863622	2026-06-30 10:41:39.232146	t
rfid-1782789151135115200	\N	6	2026-06-30 10:12:26.765827	2026-06-30 10:42:31.135115	t
rfid-1782792526370016700	\N	6	2026-06-30 11:08:42.014531	2026-06-30 11:38:46.370016	t
rfid-1782794775897490300	\N	6	2026-06-30 11:46:11.524865	2026-06-30 12:16:15.89749	t
rfid-1782866331364201300	\N	6	2026-07-01 07:38:45.839143	2026-07-01 08:08:51.364201	t
rfid-1782866341065226700	\N	6	2026-07-01 07:38:55.543695	2026-07-01 08:09:01.065226	t
rfid-1782868070855389300	\N	6	2026-07-01 08:07:45.405043	2026-07-01 08:37:50.855389	t
rfid-1782868415553231000	\N	6	2026-07-01 08:13:30.08405	2026-07-01 08:43:35.553231	t
rfid-1782868447614896000	\N	6	2026-07-01 08:14:07.615304	2026-07-01 08:44:07.6149	t
rfid-1782868491450347000	\N	2	2026-07-01 08:14:51.450454	2026-07-01 08:44:51.45035	t
rfid-1782868491452021000	\N	2	2026-07-01 08:14:51.45994	2026-07-01 08:44:51.452024	t
rfid-1782868867532940900	\N	6	2026-07-01 08:21:02.064552	2026-07-01 08:51:07.53294	t
rfid-1782868952002198900	\N	6	2026-07-01 08:22:26.527187	2026-07-01 08:52:32.002198	t
rfid-1782868953518930300	\N	6	2026-07-01 08:22:28.043148	2026-07-01 08:52:33.51893	t
rfid-1782868954027193200	\N	6	2026-07-01 08:22:28.551768	2026-07-01 08:52:34.027193	t
rfid-1782868954315310700	\N	6	2026-07-01 08:22:28.839195	2026-07-01 08:52:34.31531	t
rfid-1782868954497892500	\N	6	2026-07-01 08:22:29.024811	2026-07-01 08:52:34.497892	t
rfid-1782869704938346600	\N	6	2026-07-01 08:34:59.482978	2026-07-01 09:05:04.938346	t
rfid-1782869707025928400	\N	6	2026-07-01 08:35:01.557436	2026-07-01 09:05:07.025928	t
rfid-1782869708916508000	\N	6	2026-07-01 08:35:03.448781	2026-07-01 09:05:08.916508	t
rfid-1782869709831142500	\N	6	2026-07-01 08:35:04.365844	2026-07-01 09:05:09.831142	t
rfid-1782869710169541500	\N	6	2026-07-01 08:35:04.702169	2026-07-01 09:05:10.169541	t
rfid-1782869710372143300	\N	6	2026-07-01 08:35:04.905606	2026-07-01 09:05:10.372143	t
rfid-1782869710730144700	\N	6	2026-07-01 08:35:05.264853	2026-07-01 09:05:10.730144	t
rfid-1782869711122021800	\N	6	2026-07-01 08:35:05.653678	2026-07-01 09:05:11.122021	t
rfid-1782869712300902700	\N	6	2026-07-01 08:35:06.833147	2026-07-01 09:05:12.300902	t
rfid-1782869712657313700	\N	6	2026-07-01 08:35:07.190201	2026-07-01 09:05:12.657313	t
rfid-1782869713083613100	\N	6	2026-07-01 08:35:07.617212	2026-07-01 09:05:13.083613	t
rfid-1782869728067152400	\N	6	2026-07-01 08:35:22.607645	2026-07-01 09:05:28.067152	t
rfid-1782869729077135800	\N	6	2026-07-01 08:35:23.609476	2026-07-01 09:05:29.077135	t
rfid-1782869730376507300	\N	6	2026-07-01 08:35:24.909232	2026-07-01 09:05:30.376507	t
rfid-1782869733743454600	\N	6	2026-07-01 08:35:28.279115	2026-07-01 09:05:33.743454	t
rfid-1782870352228644900	\N	6	2026-07-01 08:45:46.771382	2026-07-01 09:15:52.228644	t
rfid-1782870368757501200	\N	2	2026-07-01 08:46:03.298877	2026-07-01 09:16:08.757501	t
rfid-1782870368758774300	\N	2	2026-07-01 08:46:03.364271	2026-07-01 09:16:08.758774	t
rfid-1782870372624495500	\N	2	2026-07-01 08:46:07.165095	2026-07-01 09:16:12.624495	t
rfid-1782870372626683100	\N	2	2026-07-01 08:46:07.17236	2026-07-01 09:16:12.626683	t
rfid-1782870391860219000	\N	2	2026-07-01 08:46:26.401829	2026-07-01 09:16:31.860219	t
rfid-1782870391862665000	\N	2	2026-07-01 08:46:26.415065	2026-07-01 09:16:31.862665	t
rfid-1782870431498606700	\N	2	2026-07-01 08:47:06.040783	2026-07-01 09:17:11.498606	t
rfid-1782870431500132100	\N	2	2026-07-01 08:47:06.051373	2026-07-01 09:17:11.500132	t
rfid-1782870733889905300	\N	6	2026-07-01 08:52:08.459063	2026-07-01 09:22:13.889905	t
rfid-1782871705603355900	\N	6	2026-07-01 09:08:20.163166	2026-07-01 09:38:25.603355	t
rfid-1782871706780767800	\N	6	2026-07-01 09:08:21.328357	2026-07-01 09:38:26.780767	t
rfid-1782871710822438100	\N	6	2026-07-01 09:08:25.37718	2026-07-01 09:38:30.822438	t
rfid-1782872008405610200	\N	6	2026-07-01 09:13:22.956704	2026-07-01 09:43:28.40561	t
rfid-1782873542275560400	\N	6	2026-07-01 09:38:56.840286	2026-07-01 10:09:02.27556	t
rfid-1782874704456733100	\N	6	2026-07-01 09:58:19.005443	2026-07-01 10:28:24.456733	t
rfid-1782874967272464300	\N	6	2026-07-01 10:02:41.764006	2026-07-01 10:32:47.272464	t
rfid-1782875051512058600	\N	6	2026-07-01 10:04:05.982442	2026-07-01 10:34:11.512058	t
rfid-1782875076768065700	\N	2	2026-07-01 10:04:31.239321	2026-07-01 10:34:36.768065	t
rfid-1782875076770260700	\N	2	2026-07-01 10:04:31.344466	2026-07-01 10:34:36.77026	t
rfid-1782875251263575700	\N	2	2026-07-01 10:07:25.74697	2026-07-01 10:37:31.263575	t
rfid-1782875251265720400	\N	2	2026-07-01 10:07:25.760331	2026-07-01 10:37:31.26572	t
rfid-1782875259864203900	\N	2	2026-07-01 10:07:34.328593	2026-07-01 10:37:39.864203	t
rfid-1782875259866420600	\N	2	2026-07-01 10:07:34.339973	2026-07-01 10:37:39.86642	t
rfid-1782875277869296100	\N	2	2026-07-01 10:07:52.332651	2026-07-01 10:37:57.869296	t
rfid-1782875277871590000	\N	2	2026-07-01 10:07:52.341422	2026-07-01 10:37:57.87159	t
rfid-1782875335527078000	\N	6	2026-07-01 10:08:49.990258	2026-07-01 10:38:55.527078	t
rfid-1782875456094409600	\N	2	2026-07-01 10:10:50.563143	2026-07-01 10:40:56.094409	t
rfid-1782875456097375200	\N	2	2026-07-01 10:10:50.569832	2026-07-01 10:40:56.097375	t
rfid-1782875468371784600	\N	2	2026-07-01 10:11:02.830571	2026-07-01 10:41:08.371784	t
rfid-1782875468374143900	\N	2	2026-07-01 10:11:02.839489	2026-07-01 10:41:08.374143	t
rfid-1782875493854649600	\N	6	2026-07-01 10:11:28.321562	2026-07-01 10:41:33.854649	t
rfid-1782875524222130100	\N	2	2026-07-01 10:11:58.678271	2026-07-01 10:42:04.22213	t
rfid-1782875524223659600	\N	2	2026-07-01 10:11:58.69797	2026-07-01 10:42:04.223659	t
rfid-1782875535346514600	\N	2	2026-07-01 10:12:09.801311	2026-07-01 10:42:15.346514	t
rfid-1782875535348352500	\N	2	2026-07-01 10:12:09.811081	2026-07-01 10:42:15.348352	t
rfid-1782875564978015100	\N	6	2026-07-01 10:12:39.433188	2026-07-01 10:42:44.978015	t
rfid-1782878044872144900	\N	6	2026-07-01 10:53:59.360445	2026-07-01 11:24:04.872144	t
rfid-1782878079662057100	\N	6	2026-07-01 10:54:34.137794	2026-07-01 11:24:39.662057	t
rfid-1782878164119960400	\N	2	2026-07-01 10:55:58.594031	2026-07-01 11:26:04.11996	t
rfid-1782878164121075900	\N	2	2026-07-01 10:55:58.670482	2026-07-01 11:26:04.121075	t
rfid-1782878176963156900	\N	6	2026-07-01 10:56:11.439585	2026-07-01 11:26:16.963156	t
rfid-1782878232648016200	\N	6	2026-07-01 10:57:07.127835	2026-07-01 11:27:12.648016	t
rfid-1782878260103538300	\N	6	2026-07-01 10:57:34.59996	2026-07-01 11:27:40.103538	t
rfid-1782878316140142000	\N	2	2026-07-01 10:58:30.691935	2026-07-01 11:28:36.140142	t
rfid-1782878316138001800	\N	2	2026-07-01 10:58:30.691613	2026-07-01 11:28:36.138001	t
rfid-1782878333648109400	\N	2	2026-07-01 10:58:48.126587	2026-07-01 11:28:53.648109	t
rfid-1782878333649967700	\N	2	2026-07-01 10:58:48.13665	2026-07-01 11:28:53.649967	t
rfid-1782878379543005900	\N	6	2026-07-01 10:59:34.019522	2026-07-01 11:29:39.543005	t
rfid-1782879329649632200	\N	2	2026-07-01 11:15:24.162961	2026-07-01 11:45:29.649632	t
rfid-1782879329650512100	\N	2	2026-07-01 11:15:24.216757	2026-07-01 11:45:29.650512	t
rfid-1782879345528572800	\N	2	2026-07-01 11:15:40.031507	2026-07-01 11:45:45.528572	t
rfid-1782879345530737500	\N	2	2026-07-01 11:15:40.045395	2026-07-01 11:45:45.530737	t
rfid-1782879356617122800	\N	2	2026-07-01 11:15:51.121316	2026-07-01 11:45:56.617122	t
rfid-1782879356619387800	\N	2	2026-07-01 11:15:51.129957	2026-07-01 11:45:56.619387	t
rfid-1782879409765740200	\N	2	2026-07-01 11:16:44.271859	2026-07-01 11:46:49.76574	t
rfid-1782879424734716200	\N	2	2026-07-01 11:16:59.249803	2026-07-01 11:47:04.734716	t
rfid-1782879489594318800	\N	2	2026-07-01 11:18:04.101102	2026-07-01 11:48:09.594318	t
rfid-1782879501924946100	\N	2	2026-07-01 11:18:16.443985	2026-07-01 11:48:21.924946	t
rfid-1782879424732316000	\N	2	2026-07-01 11:16:59.249735	2026-07-01 11:47:04.732316	t
rfid-1782879436477084800	\N	2	2026-07-01 11:17:10.982369	2026-07-01 11:47:16.477084	t
rfid-1782879436491072800	\N	2	2026-07-01 11:17:10.996484	2026-07-01 11:47:16.491072	t
rfid-1782879489596315700	\N	2	2026-07-01 11:18:04.113869	2026-07-01 11:48:09.596315	t
rfid-1782879501919580700	\N	2	2026-07-01 11:18:16.426387	2026-07-01 11:48:21.91958	t
rfid-1782879559620263000	\N	2	2026-07-01 11:19:14.126738	2026-07-01 11:49:19.620263	t
rfid-1782879559622383200	\N	2	2026-07-01 11:19:14.136234	2026-07-01 11:49:19.622383	t
rfid-1782879570994550700	\N	2	2026-07-01 11:19:25.500413	2026-07-01 11:49:30.99455	t
rfid-1782879570997096900	\N	2	2026-07-01 11:19:25.509243	2026-07-01 11:49:30.997096	t
rfid-1782879609741756300	\N	2	2026-07-01 11:20:04.247135	2026-07-01 11:50:09.741756	t
rfid-1782879609743634700	\N	2	2026-07-01 11:20:04.261075	2026-07-01 11:50:09.743634	t
rfid-1782879628236083900	\N	2	2026-07-01 11:20:22.742813	2026-07-01 11:50:28.236083	t
rfid-1782879628237910900	\N	2	2026-07-01 11:20:22.752712	2026-07-01 11:50:28.23791	t
rfid-1782879638403141800	\N	2	2026-07-01 11:20:32.908185	2026-07-01 11:50:38.403141	t
rfid-1782879638405667300	\N	2	2026-07-01 11:20:32.91938	2026-07-01 11:50:38.405667	t
rfid-1782879654057541700	\N	2	2026-07-01 11:20:48.562448	2026-07-01 11:50:54.057541	t
rfid-1782879654059865400	\N	2	2026-07-01 11:20:48.569754	2026-07-01 11:50:54.059865	t
rfid-1782879664988104000	\N	2	2026-07-01 11:20:59.494263	2026-07-01 11:51:04.988104	t
rfid-1782879664990589100	\N	2	2026-07-01 11:20:59.509056	2026-07-01 11:51:04.990589	t
rfid-1782879812526802800	\N	2	2026-07-01 11:23:27.044555	2026-07-01 11:53:32.526802	t
rfid-1782879812527331800	\N	2	2026-07-01 11:23:27.104173	2026-07-01 11:53:32.527331	t
rfid-1782879822313498200	\N	2	2026-07-01 11:23:36.820414	2026-07-01 11:53:42.313498	t
rfid-1782879822315019600	\N	2	2026-07-01 11:23:36.83226	2026-07-01 11:53:42.315019	t
rfid-1782879832920287300	\N	2	2026-07-01 11:23:47.430969	2026-07-01 11:53:52.920287	t
rfid-1782879832921943000	\N	2	2026-07-01 11:23:47.441187	2026-07-01 11:53:52.921943	t
rfid-1782879881141352100	\N	2	2026-07-01 11:24:35.660176	2026-07-01 11:54:41.141352	t
rfid-1782879881142299600	\N	2	2026-07-01 11:24:35.687989	2026-07-01 11:54:41.142299	t
rfid-1782879885179120700	\N	2	2026-07-01 11:24:39.69573	2026-07-01 11:54:45.17912	t
rfid-1782879885180671400	\N	2	2026-07-01 11:24:39.704618	2026-07-01 11:54:45.180671	t
rfid-1782879889653296000	\N	2	2026-07-01 11:24:44.168231	2026-07-01 11:54:49.653296	t
rfid-1782879889655535500	\N	2	2026-07-01 11:24:44.178925	2026-07-01 11:54:49.655535	t
rfid-1782879917132342100	\N	2	2026-07-01 11:25:11.649931	2026-07-01 11:55:17.132342	t
rfid-1782879917132998500	\N	2	2026-07-01 11:25:11.661649	2026-07-01 11:55:17.132998	t
rfid-1782879919973241900	\N	2	2026-07-01 11:25:14.490101	2026-07-01 11:55:19.973241	t
rfid-1782879919975159600	\N	2	2026-07-01 11:25:14.500101	2026-07-01 11:55:19.975159	t
rfid-1782879923569454500	\N	2	2026-07-01 11:25:18.086198	2026-07-01 11:55:23.569454	t
rfid-1782879923571074600	\N	2	2026-07-01 11:25:18.101217	2026-07-01 11:55:23.571074	t
rfid-1782880345602521300	\N	2	2026-07-01 11:32:20.131772	2026-07-01 12:02:25.602521	t
rfid-1782880345603312700	\N	2	2026-07-01 11:32:20.182077	2026-07-01 12:02:25.603312	t
rfid-1782880355225723800	\N	2	2026-07-01 11:32:29.743956	2026-07-01 12:02:35.225723	t
rfid-1782880355228176900	\N	2	2026-07-01 11:32:29.754621	2026-07-01 12:02:35.228176	t
rfid-1782880360782464200	\N	2	2026-07-01 11:32:35.301189	2026-07-01 12:02:40.782464	t
rfid-1782880360784653400	\N	2	2026-07-01 11:32:35.313717	2026-07-01 12:02:40.784653	t
rfid-1782880470759545100	\N	2	2026-07-01 11:34:25.296811	2026-07-01 12:04:30.759545	t
rfid-1782880470760682700	\N	2	2026-07-01 11:34:25.355032	2026-07-01 12:04:30.760682	t
rfid-1782880475068102700	\N	2	2026-07-01 11:34:29.595121	2026-07-01 12:04:35.068102	t
rfid-1782880475072494500	\N	2	2026-07-01 11:34:29.606145	2026-07-01 12:04:35.072494	t
rfid-1782880533326457000	\N	2	2026-07-01 11:35:27.853798	2026-07-01 12:05:33.326457	t
rfid-1782880560091893900	\N	2	2026-07-01 11:35:54.618904	2026-07-01 12:06:00.091893	t
rfid-1782880560093474200	\N	2	2026-07-01 11:35:54.634272	2026-07-01 12:06:00.093474	t
rfid-1782880563425148700	\N	2	2026-07-01 11:35:57.952909	2026-07-01 12:06:03.425148	t
rfid-1782880563441711400	\N	2	2026-07-01 11:35:57.970636	2026-07-01 12:06:03.441711	t
rfid-1782880676757625000	\N	2	2026-07-01 11:37:51.278661	2026-07-01 12:07:56.757625	t
rfid-1782880676760508900	\N	2	2026-07-01 11:37:51.294038	2026-07-01 12:07:56.760508	t
rfid-1782880689116083200	\N	2	2026-07-01 11:38:03.633511	2026-07-01 12:08:09.116083	t
rfid-1782880689118419300	\N	2	2026-07-01 11:38:03.643423	2026-07-01 12:08:09.118419	t
rfid-1782880764054710000	\N	6	2026-07-01 11:39:18.571681	2026-07-01 12:09:24.05471	t
rfid-1782880812973138000	\N	2	2026-07-01 11:40:07.501777	2026-07-01 12:10:12.973138	t
rfid-1782880812974663500	\N	2	2026-07-01 11:40:07.513554	2026-07-01 12:10:12.974663	t
rfid-1782880830228743200	\N	2	2026-07-01 11:40:24.748656	2026-07-01 12:10:30.228743	t
rfid-1782880830230631600	\N	2	2026-07-01 11:40:24.764038	2026-07-01 12:10:30.230631	t
rfid-1782880851727606300	\N	2	2026-07-01 11:40:46.246841	2026-07-01 12:10:51.727606	t
rfid-1782880851729492100	\N	2	2026-07-01 11:40:46.277648	2026-07-01 12:10:51.729492	t
rfid-1782881307220333800	\N	2	2026-07-01 11:48:21.754146	2026-07-01 12:18:27.220333	t
rfid-1782881307221523200	\N	2	2026-07-01 11:48:21.808724	2026-07-01 12:18:27.221523	t
rfid-1782881324127349300	\N	2	2026-07-01 11:48:38.628678	2026-07-01 12:18:44.127349	t
rfid-1782881324129613200	\N	2	2026-07-01 11:48:38.64272	2026-07-01 12:18:44.129613	t
rfid-1782881341008085200	\N	2	2026-07-01 11:48:55.550866	2026-07-01 12:19:01.008085	t
rfid-1782881341010849500	\N	2	2026-07-01 11:48:55.696648	2026-07-01 12:19:01.010849	t
rfid-1782881405431709200	\N	2	2026-07-01 11:49:59.929483	2026-07-01 12:20:05.431709	t
rfid-1782881682990342900	\N	2	2026-07-01 11:54:37.495861	2026-07-01 12:24:42.990342	t
rfid-1782881682991860000	\N	2	2026-07-01 11:54:37.548888	2026-07-01 12:24:42.99186	t
rfid-1782881692764913300	\N	2	2026-07-01 11:54:47.258491	2026-07-01 12:24:52.764913	t
rfid-1782881692766747500	\N	2	2026-07-01 11:54:47.269738	2026-07-01 12:24:52.766747	t
rfid-1782881704175828400	\N	2	2026-07-01 11:54:58.669342	2026-07-01 12:25:04.175828	t
rfid-1782881704188490900	\N	2	2026-07-01 11:54:58.681536	2026-07-01 12:25:04.18849	t
rfid-1782881778542886700	\N	2	2026-07-01 11:56:13.03779	2026-07-01 12:26:18.542886	t
rfid-1782886607994908200	\N	2	2026-07-01 13:16:42.528075	2026-07-01 13:46:47.994908	t
rfid-1782886607997146000	\N	2	2026-07-01 13:16:42.591267	2026-07-01 13:46:47.997146	t
rfid-1782886618173003700	\N	2	2026-07-01 13:16:52.694449	2026-07-01 13:46:58.173003	t
rfid-1782886618174332300	\N	2	2026-07-01 13:16:52.706497	2026-07-01 13:46:58.174332	t
rfid-1782886623514620200	\N	2	2026-07-01 13:16:58.035015	2026-07-01 13:47:03.51462	t
rfid-1782886623541441400	\N	2	2026-07-01 13:16:58.062529	2026-07-01 13:47:03.541441	t
rfid-1782887107375033300	\N	6	2026-07-01 13:25:01.931103	2026-07-01 13:55:07.375033	t
rfid-1782888363649031600	\N	2	2026-07-01 13:45:58.20452	2026-07-01 14:16:03.649031	t
rfid-1782888363651360800	\N	2	2026-07-01 13:45:58.260794	2026-07-01 14:16:03.65136	t
rfid-1782888387881151300	\N	6	2026-07-01 13:46:22.426281	2026-07-01 14:16:27.881151	t
rfid-1782889125579382500	\N	2	2026-07-01 13:58:40.135442	2026-07-01 14:28:45.579382	t
rfid-1782889125579899200	\N	2	2026-07-01 13:58:40.189163	2026-07-01 14:28:45.579899	t
rfid-1782889136694387400	\N	2	2026-07-01 13:58:51.23941	2026-07-01 14:28:56.694387	t
rfid-1782889136697063900	\N	2	2026-07-01 13:58:51.252792	2026-07-01 14:28:56.697063	t
rfid-1782889899873047900	\N	2	2026-07-01 14:11:34.431575	2026-07-01 14:41:39.873047	t
rfid-1782889899873564900	\N	2	2026-07-01 14:11:34.480654	2026-07-01 14:41:39.873564	t
rfid-1782892273582287600	\N	2	2026-07-01 14:51:08.114163	2026-07-01 15:21:13.582287	t
rfid-1782892273583335200	\N	2	2026-07-01 14:51:08.153692	2026-07-01 15:21:13.583335	t
rfid-1782892384752084300	\N	2	2026-07-01 14:52:59.278822	2026-07-01 15:23:04.752084	t
rfid-1782892384755808600	\N	2	2026-07-01 14:52:59.291243	2026-07-01 15:23:04.755808	t
rfid-1782892393154994000	\N	2	2026-07-01 14:53:07.686007	2026-07-01 15:23:13.154994	t
rfid-1782892393157941100	\N	2	2026-07-01 14:53:07.698344	2026-07-01 15:23:13.157941	t
rfid-1782892457554610700	\N	2	2026-07-01 14:54:12.090194	2026-07-01 15:24:17.55461	t
rfid-1782892457557894500	\N	2	2026-07-01 14:54:12.101709	2026-07-01 15:24:17.557894	t
rfid-1782892462945659200	\N	2	2026-07-01 14:54:17.481025	2026-07-01 15:24:22.945659	t
rfid-1782892462948255000	\N	2	2026-07-01 14:54:17.491527	2026-07-01 15:24:22.948255	t
rfid-1782892507710008500	\N	2	2026-07-01 14:55:02.245641	2026-07-01 15:25:07.710008	t
rfid-1782892507710559700	\N	2	2026-07-01 14:55:02.256793	2026-07-01 15:25:07.710559	t
rfid-1782893787195189700	\N	2	2026-07-01 15:16:21.745907	2026-07-01 15:46:27.195189	t
rfid-1782893787197274300	\N	2	2026-07-01 15:16:21.79089	2026-07-01 15:46:27.197274	t
rfid-1782893962658285000	\N	2	2026-07-01 15:19:17.209073	2026-07-01 15:49:22.658285	t
rfid-1782893962659354200	\N	2	2026-07-01 15:19:17.254764	2026-07-01 15:49:22.659354	t
rfid-1782893989067270700	\N	2	2026-07-01 15:19:43.61062	2026-07-01 15:49:49.06727	t
rfid-1782893989067689500	\N	2	2026-07-01 15:19:43.619357	2026-07-01 15:49:49.067689	t
rfid-1782894002136365000	\N	2	2026-07-01 15:19:56.679313	2026-07-01 15:50:02.136365	t
rfid-1782894002138500400	\N	2	2026-07-01 15:19:56.690894	2026-07-01 15:50:02.1385	t
rfid-1782894051537633800	\N	2	2026-07-01 15:20:46.081694	2026-07-01 15:50:51.537633	t
rfid-1782894192004057400	\N	2	2026-07-01 15:23:06.562776	2026-07-01 15:53:12.004057	t
rfid-1782894192879120400	\N	2	2026-07-01 15:23:07.424068	2026-07-01 15:53:12.87912	t
rfid-1782894616187908500	\N	2	2026-07-01 15:30:10.742918	2026-07-01 16:00:16.187908	t
rfid-1782894616190532600	\N	2	2026-07-01 15:30:10.760116	2026-07-01 16:00:16.190532	t
rfid-1782956102379992500	\N	2	2026-07-02 08:34:55.341065	2026-07-02 09:05:02.379992	t
rfid-1782956102381071300	\N	2	2026-07-02 08:34:55.411837	2026-07-02 09:05:02.381071	t
rfid-1782956173325034800	\N	2	2026-07-02 08:36:06.273468	2026-07-02 09:06:13.325034	t
rfid-1782956173327340900	\N	2	2026-07-02 08:36:06.281683	2026-07-02 09:06:13.32734	t
rfid-1782956304593873400	\N	2	2026-07-02 08:38:17.541268	2026-07-02 09:08:24.593873	t
rfid-1782956352991282100	\N	2	2026-07-02 08:39:05.940769	2026-07-02 09:09:12.991282	t
rfid-1782957840481249600	\N	2	2026-07-02 09:03:53.435251	2026-07-02 09:34:00.481249	t
rfid-1782957840483376000	\N	2	2026-07-02 09:03:53.491186	2026-07-02 09:34:00.483376	t
rfid-1782958155122047100	\N	2	2026-07-02 09:09:08.058282	2026-07-02 09:39:15.122047	t
rfid-1782958155124190500	\N	2	2026-07-02 09:09:08.066209	2026-07-02 09:39:15.12419	t
rfid-1782958161061504100	\N	2	2026-07-02 09:09:13.999903	2026-07-02 09:39:21.061504	t
rfid-1782958161063193400	\N	2	2026-07-02 09:09:14.010259	2026-07-02 09:39:21.063193	t
rfid-1782958210109895000	\N	2	2026-07-02 09:10:03.047263	2026-07-02 09:40:10.109895	t
rfid-1782958210111615200	\N	2	2026-07-02 09:10:03.057393	2026-07-02 09:40:10.111615	t
rfid-1782958234977366000	\N	2	2026-07-02 09:10:27.912417	2026-07-02 09:40:34.977366	t
rfid-1782958234978465300	\N	2	2026-07-02 09:10:27.925735	2026-07-02 09:40:34.978465	t
rfid-1782958470115569000	\N	2	2026-07-02 09:14:23.056086	2026-07-02 09:44:30.115569	t
rfid-1782958470117533100	\N	2	2026-07-02 09:14:23.068102	2026-07-02 09:44:30.117533	t
rfid-1782958474683647800	\N	2	2026-07-02 09:14:27.624667	2026-07-02 09:44:34.683647	t
rfid-1782958474685818900	\N	2	2026-07-02 09:14:27.632903	2026-07-02 09:44:34.685818	t
rfid-1782959116071762700	\N	2	2026-07-02 09:25:09.0171	2026-07-02 09:55:16.071762	t
rfid-1782960554495751100	\N	2	2026-07-02 09:49:07.447369	2026-07-02 10:19:14.495751	t
rfid-1782960554496727900	\N	2	2026-07-02 09:49:07.507365	2026-07-02 10:19:14.496727	t
rfid-1782960568909904700	\N	2	2026-07-02 09:49:21.85118	2026-07-02 10:19:28.909904	t
rfid-1782960568911829300	\N	2	2026-07-02 09:49:21.865123	2026-07-02 10:19:28.911829	t
rfid-1782964182665464400	\N	2	2026-07-02 10:49:35.642286	2026-07-02 11:19:42.665464	t
rfid-1782964182666658900	\N	2	2026-07-02 10:49:35.690967	2026-07-02 11:19:42.666658	t
rfid-1782964183877997300	\N	2	2026-07-02 10:49:36.845278	2026-07-02 11:19:43.877997	t
rfid-1782964183878996900	\N	2	2026-07-02 10:49:36.864733	2026-07-02 11:19:43.878996	t
rfid-1782964187401293800	\N	2	2026-07-02 10:49:40.370187	2026-07-02 11:19:47.401293	t
rfid-1782964187401808300	\N	2	2026-07-02 10:49:40.385078	2026-07-02 11:19:47.401808	t
rfid-1782964189258106200	\N	2	2026-07-02 10:49:42.224651	2026-07-02 11:19:49.258106	t
rfid-1782964194259363200	\N	2	2026-07-02 10:49:47.237049	2026-07-02 11:19:54.259363	t
rfid-1782964194259861000	\N	2	2026-07-02 10:49:47.237059	2026-07-02 11:19:54.259861	t
rfid-1782964430201155000	\N	2	2026-07-02 10:53:50.202083	2026-07-02 11:23:50.201158	t
rfid-1782964430201312000	\N	2	2026-07-02 10:53:50.21855	2026-07-02 11:23:50.201313	t
rfid-1782964436434635000	\N	2	2026-07-02 10:53:56.434728	2026-07-02 11:23:56.434638	t
rfid-1782964436434833000	\N	2	2026-07-02 10:53:56.435028	2026-07-02 11:23:56.434835	t
rfid-1782964444002392000	\N	2	2026-07-02 10:54:04.003806	2026-07-02 11:24:04.002396	t
rfid-1782964444003801000	\N	2	2026-07-02 10:54:04.004006	2026-07-02 11:24:04.003805	t
rfid-1782964787455245600	\N	2	2026-07-02 10:59:40.441937	2026-07-02 11:29:47.455245	t
rfid-1782964791269012000	\N	2	2026-07-02 10:59:44.248209	2026-07-02 11:29:51.269012	t
rfid-1782964791269524500	\N	2	2026-07-02 10:59:44.248192	2026-07-02 11:29:51.269524	t
rfid-1782974166490120100	\N	2	2026-07-02 13:35:59.427175	2026-07-02 14:06:06.49012	t
rfid-1782974166491282100	\N	2	2026-07-02 13:35:59.467573	2026-07-02 14:06:06.491282	t
rfid-1782974171904357100	\N	2	2026-07-02 13:36:04.838381	2026-07-02 14:06:11.904357	t
rfid-1782974171905356500	\N	2	2026-07-02 13:36:04.848203	2026-07-02 14:06:11.905356	t
rfid-1782974173728076800	\N	2	2026-07-02 13:36:06.658271	2026-07-02 14:06:13.728076	t
rfid-1782975347362922500	\N	2	2026-07-02 13:55:40.339282	2026-07-02 14:25:47.362922	t
rfid-1782975347364207900	\N	2	2026-07-02 13:55:40.41868	2026-07-02 14:25:47.364207	t
rfid-1782976597770511000	\N	2	2026-07-02 14:16:30.707408	2026-07-02 14:46:37.770511	t
rfid-1782976597771018000	\N	2	2026-07-02 14:16:30.751296	2026-07-02 14:46:37.771018	t
rfid-1782976776714249500	\N	2	2026-07-02 14:19:29.637002	2026-07-02 14:49:36.714249	t
rfid-1782976776717403300	\N	2	2026-07-02 14:19:29.646901	2026-07-02 14:49:36.717403	t
rfid-1782976791193678500	\N	2	2026-07-02 14:19:44.117583	2026-07-02 14:49:51.193678	t
rfid-1782976791194677400	\N	2	2026-07-02 14:19:44.127007	2026-07-02 14:49:51.194677	t
rfid-1782977019414458500	\N	2	2026-07-02 14:23:32.336853	2026-07-02 14:53:39.414458	t
rfid-1782977019415400400	\N	2	2026-07-02 14:23:32.347043	2026-07-02 14:53:39.4154	t
rfid-1782977440701266700	\N	2	2026-07-02 14:30:33.629596	2026-07-02 15:00:40.701266	t
rfid-1782977531634693500	\N	2	2026-07-02 14:32:04.555403	2026-07-02 15:02:11.634693	t
rfid-1782977531635488400	\N	2	2026-07-02 14:32:04.579239	2026-07-02 15:02:11.635488	t
rfid-1782977536494695400	\N	2	2026-07-02 14:32:09.414897	2026-07-02 15:02:16.494695	t
rfid-1782977591796686600	\N	2	2026-07-02 14:33:04.731244	2026-07-02 15:03:11.796686	t
rfid-1782977609016042900	\N	2	2026-07-02 14:33:21.934593	2026-07-02 15:03:29.016042	t
rfid-1782977654088854900	\N	2	2026-07-02 14:34:07.008036	2026-07-02 15:04:14.088854	t
rfid-1782977681103466000	\N	6	2026-07-02 14:34:34.021771	2026-07-02 15:04:41.103466	t
rfid-1782977591794982900	\N	2	2026-07-02 14:33:04.714055	2026-07-02 15:03:11.794982	t
rfid-1782977609017766700	\N	2	2026-07-02 14:33:21.944554	2026-07-02 15:03:29.017766	t
rfid-1782977654090720300	\N	2	2026-07-02 14:34:07.020212	2026-07-02 15:04:14.09072	t
rfid-1782977761113144200	\N	6	2026-07-02 14:35:54.058917	2026-07-02 15:06:01.113144	t
rfid-1782977845923387000	\N	2	2026-07-02 14:37:18.857081	2026-07-02 15:07:25.923387	t
rfid-1782977845925160200	\N	2	2026-07-02 14:37:18.929159	2026-07-02 15:07:25.92516	t
rfid-1782977874700748500	\N	6	2026-07-02 14:37:47.635033	2026-07-02 15:07:54.700748	t
rfid-1782978910783084900	\N	6	2026-07-02 14:55:03.70911	2026-07-02 15:25:10.783084	t
rfid-1782978933257703100	\N	6	2026-07-02 14:55:26.187442	2026-07-02 15:25:33.257703	t
rfid-1782978983129313000	\N	2	2026-07-02 14:56:16.052161	2026-07-02 15:26:23.129313	t
rfid-1782978983129992100	\N	2	2026-07-02 14:56:16.06303	2026-07-02 15:26:23.129992	t
rfid-1782978992646356600	\N	2	2026-07-02 14:56:25.570308	2026-07-02 15:26:32.646356	t
rfid-1782978992648467600	\N	2	2026-07-02 14:56:25.585274	2026-07-02 15:26:32.648467	t
rfid-1783060945929765500	\N	2	2026-07-03 13:42:17.66477	2026-07-03 14:12:25.929765	t
rfid-1783060945931393000	\N	2	2026-07-03 13:42:17.723954	2026-07-03 14:12:25.931393	t
rfid-1783061119511859600	\N	2	2026-07-03 13:45:11.231878	2026-07-03 14:15:19.511859	t
rfid-1783061119513602500	\N	2	2026-07-03 13:45:11.241714	2026-07-03 14:15:19.513602	t
rfid-1783061131749809300	\N	2	2026-07-03 13:45:23.467258	2026-07-03 14:15:31.749809	t
rfid-1783061131751964400	\N	2	2026-07-03 13:45:23.483108	2026-07-03 14:15:31.751964	t
rfid-1783068082088496500	\N	2	2026-07-03 15:41:13.848846	2026-07-03 16:11:22.088496	t
rfid-1783068143736119200	\N	2	2026-07-03 15:42:15.48765	2026-07-03 16:12:23.736119	t
rfid-1783068143737311900	\N	2	2026-07-03 15:42:15.509709	2026-07-03 16:12:23.737311	t
rfid-1783068160076541800	\N	2	2026-07-03 15:42:31.835561	2026-07-03 16:12:40.076541	t
rfid-1783068160078058900	\N	2	2026-07-03 15:42:31.844269	2026-07-03 16:12:40.078058	t
rfid-1783068180939013700	\N	2	2026-07-03 15:42:52.691445	2026-07-03 16:13:00.939013	t
rfid-1783068180953789600	\N	2	2026-07-03 15:42:52.70589	2026-07-03 16:13:00.953789	t
rfid-1783068232677934700	\N	2	2026-07-03 15:43:44.431506	2026-07-03 16:13:52.677934	t
rfid-1783068232679904200	\N	2	2026-07-03 15:43:44.4478	2026-07-03 16:13:52.679904	t
rfid-1783068237326156300	\N	2	2026-07-03 15:43:49.078852	2026-07-03 16:13:57.326156	t
rfid-1783068237329249200	\N	2	2026-07-03 15:43:49.093266	2026-07-03 16:13:57.329249	t
rfid-1783068274236127200	\N	2	2026-07-03 15:44:25.987343	2026-07-03 16:14:34.236127	t
rfid-1783068294760801900	\N	2	2026-07-03 15:44:46.521101	2026-07-03 16:14:54.760801	t
rfid-1783068294762708700	\N	2	2026-07-03 15:44:46.521111	2026-07-03 16:14:54.762708	t
rfid-1783068315491136100	\N	2	2026-07-03 15:45:07.243097	2026-07-03 16:15:15.491136	t
rfid-1783068315493085300	\N	2	2026-07-03 15:45:07.252572	2026-07-03 16:15:15.493085	t
rfid-1783388637578508500	\N	2	2026-07-07 08:43:44.975251	2026-07-07 09:13:57.578508	t
rfid-1783388637579041200	\N	2	2026-07-07 08:43:45.028648	2026-07-07 09:13:57.579041	t
rfid-1783388689085578900	\N	2	2026-07-07 08:44:36.468785	2026-07-07 09:14:49.085578	t
rfid-1783409509783023800	\N	2	2026-07-07 14:31:37.177167	2026-07-07 15:01:49.783023	t
rfid-1783409509784653200	\N	2	2026-07-07 14:31:37.235424	2026-07-07 15:01:49.784653	t
rfid-1783409521234179200	\N	2	2026-07-07 14:31:48.61869	2026-07-07 15:02:01.234179	t
rfid-1783409521236512800	\N	2	2026-07-07 14:31:48.632138	2026-07-07 15:02:01.236512	t
rfid-1783409557118565300	\N	2	2026-07-07 14:32:24.505565	2026-07-07 15:02:37.118565	t
rfid-1783409557136854000	\N	2	2026-07-07 14:32:24.523132	2026-07-07 15:02:37.136854	t
rfid-1783409621861556300	\N	2	2026-07-07 14:33:29.248045	2026-07-07 15:03:41.861556	t
rfid-1783409621862075900	\N	2	2026-07-07 14:33:29.261704	2026-07-07 15:03:41.862075	t
rfid-1783409643265176800	\N	2	2026-07-07 14:33:50.651283	2026-07-07 15:04:03.265176	t
rfid-1783409643267388100	\N	2	2026-07-07 14:33:50.663147	2026-07-07 15:04:03.267388	t
rfid-1783409730821997400	\N	2	2026-07-07 14:35:18.207305	2026-07-07 15:05:30.821997	t
rfid-1783409730823996000	\N	2	2026-07-07 14:35:18.222404	2026-07-07 15:05:30.823996	t
rfid-1783409737421334900	\N	2	2026-07-07 14:35:24.813041	2026-07-07 15:05:37.421334	t
rfid-1783409737423195500	\N	2	2026-07-07 14:35:24.832083	2026-07-07 15:05:37.423195	t
rfid-1783409761984993900	\N	2	2026-07-07 14:35:49.36772	2026-07-07 15:06:01.984993	t
rfid-1783409761987002600	\N	2	2026-07-07 14:35:49.39325	2026-07-07 15:06:01.987002	t
rfid-1783409841244310700	\N	2	2026-07-07 14:37:08.630233	2026-07-07 15:07:21.24431	t
rfid-1783409841244817200	\N	2	2026-07-07 14:37:08.645755	2026-07-07 15:07:21.244817	t
rfid-1783409855531780200	\N	2	2026-07-07 14:37:22.917728	2026-07-07 15:07:35.53178	t
rfid-1783409855533561100	\N	2	2026-07-07 14:37:22.928924	2026-07-07 15:07:35.533561	t
rfid-1783410675991819800	\N	2	2026-07-07 14:51:03.393746	2026-07-07 15:21:15.991819	t
rfid-1783410675992330000	\N	2	2026-07-07 14:51:03.403846	2026-07-07 15:21:15.99233	t
rfid-1783410684088334800	\N	2	2026-07-07 14:51:11.479795	2026-07-07 15:21:24.088334	t
rfid-1783410684088844200	\N	2	2026-07-07 14:51:11.493729	2026-07-07 15:21:24.088844	t
rfid-1783494958019358300	\N	2	2026-07-08 14:15:43.437431	2026-07-08 14:45:58.019358	t
rfid-1783494958019872700	\N	2	2026-07-08 14:15:43.492971	2026-07-08 14:45:58.019872	t
rfid-1783495099256013500	\N	2	2026-07-08 14:18:04.656362	2026-07-08 14:48:19.256013	t
rfid-1783495099258265300	\N	2	2026-07-08 14:18:04.67413	2026-07-08 14:48:19.258265	t
rfid-1783495115223610400	\N	2	2026-07-08 14:18:20.626061	2026-07-08 14:48:35.22361	t
rfid-1783495115225746100	\N	2	2026-07-08 14:18:20.638387	2026-07-08 14:48:35.225746	t
rfid-1783495171319367800	\N	2	2026-07-08 14:19:16.720332	2026-07-08 14:49:31.319367	t
rfid-1783495171320099200	\N	2	2026-07-08 14:19:16.734304	2026-07-08 14:49:31.320099	t
rfid-1783495177455153100	\N	2	2026-07-08 14:19:22.85478	2026-07-08 14:49:37.455153	t
rfid-1783495177457127400	\N	2	2026-07-08 14:19:22.863524	2026-07-08 14:49:37.457127	t
rfid-1783495235199275500	\N	2	2026-07-08 14:20:20.600025	2026-07-08 14:50:35.199275	t
rfid-1783495235200058400	\N	2	2026-07-08 14:20:20.610965	2026-07-08 14:50:35.200058	t
rfid-1783495248004663500	\N	2	2026-07-08 14:20:33.40591	2026-07-08 14:50:48.004663	t
rfid-1783495248006505000	\N	2	2026-07-08 14:20:33.419086	2026-07-08 14:50:48.006505	t
rfid-1783495304031787500	\N	2	2026-07-08 14:21:29.430401	2026-07-08 14:51:44.031787	t
rfid-1783495323125887400	\N	2	2026-07-08 14:21:48.524466	2026-07-08 14:52:03.125887	t
rfid-1783495323127537200	\N	2	2026-07-08 14:21:48.557099	2026-07-08 14:52:03.127537	t
rfid-1783495341217805600	\N	2	2026-07-08 14:22:06.614576	2026-07-08 14:52:21.217805	t
rfid-1783495341233481400	\N	2	2026-07-08 14:22:06.630827	2026-07-08 14:52:21.233481	t
rfid-1783495371060099200	\N	2	2026-07-08 14:22:36.459139	2026-07-08 14:52:51.060099	t
rfid-1783495371081010100	\N	2	2026-07-08 14:22:36.480296	2026-07-08 14:52:51.08101	t
rfid-1783495413927185000	\N	2	2026-07-08 14:23:19.325723	2026-07-08 14:53:33.927185	t
rfid-1783495425209567400	\N	2	2026-07-08 14:23:30.61776	2026-07-08 14:53:45.209567	t
rfid-1783495425207237700	\N	2	2026-07-08 14:23:30.617759	2026-07-08 14:53:45.207237	t
rfid-1783495439147171500	\N	2	2026-07-08 14:23:44.545288	2026-07-08 14:53:59.147171	t
rfid-1783495439164626800	\N	2	2026-07-08 14:23:44.562887	2026-07-08 14:53:59.164626	t
rfid-1783495537517728900	\N	2	2026-07-08 14:25:22.916003	2026-07-08 14:55:37.517728	t
rfid-1783495537519878600	\N	2	2026-07-08 14:25:22.923958	2026-07-08 14:55:37.519878	t
rfid-1783495702889108300	\N	2	2026-07-08 14:28:08.2869	2026-07-08 14:58:22.889108	t
rfid-1783495702891852700	\N	2	2026-07-08 14:28:08.307328	2026-07-08 14:58:22.891852	t
rfid-1783497739578539200	\N	2	2026-07-08 15:02:05.013776	2026-07-08 15:32:19.578539	t
rfid-1783497739579147400	\N	2	2026-07-08 15:02:05.082272	2026-07-08 15:32:19.579147	t
rfid-1783497760816430300	\N	2	2026-07-08 15:02:26.239566	2026-07-08 15:32:40.81643	t
rfid-1783497760817301500	\N	2	2026-07-08 15:02:26.248002	2026-07-08 15:32:40.817301	t
rfid-1783497777024586700	\N	2	2026-07-08 15:02:42.446884	2026-07-08 15:32:57.024586	t
rfid-1783497777025923000	\N	2	2026-07-08 15:02:42.458029	2026-07-08 15:32:57.025923	t
rfid-1783497872255117500	\N	2	2026-07-08 15:04:17.694006	2026-07-08 15:34:32.255117	t
rfid-1783497872257261000	\N	2	2026-07-08 15:04:17.703854	2026-07-08 15:34:32.257261	t
rfid-1783497891162083800	\N	2	2026-07-08 15:04:36.601386	2026-07-08 15:34:51.162083	t
rfid-1783497891162595500	\N	2	2026-07-08 15:04:36.614087	2026-07-08 15:34:51.16361	t
rfid-1783497894519746300	\N	2	2026-07-08 15:04:39.958946	2026-07-08 15:34:54.519746	t
rfid-1783497894521779700	\N	2	2026-07-08 15:04:39.969548	2026-07-08 15:34:54.521779	t
rfid-1783497970271071200	\N	2	2026-07-08 15:05:55.710754	2026-07-08 15:36:10.271071	t
rfid-1783497975548375400	\N	2	2026-07-08 15:06:00.990273	2026-07-08 15:36:15.548375	t
rfid-1783497975550257200	\N	2	2026-07-08 15:06:01.020522	2026-07-08 15:36:15.550257	t
rfid-1783498048352377200	\N	2	2026-07-08 15:07:13.793249	2026-07-08 15:37:28.352377	t
rfid-1783498048354732500	\N	2	2026-07-08 15:07:13.809572	2026-07-08 15:37:28.354732	t
rfid-1783498213540754000	\N	2	2026-07-08 15:09:58.982434	2026-07-08 15:40:13.540754	t
rfid-1783498213541846100	\N	2	2026-07-08 15:09:58.994714	2026-07-08 15:40:13.541846	t
rfid-1783498356572156700	\N	2	2026-07-08 15:12:22.014745	2026-07-08 15:42:36.572156	t
rfid-1783498356572667700	\N	2	2026-07-08 15:12:22.026557	2026-07-08 15:42:36.572667	t
rfid-1783498416007517800	\N	2	2026-07-08 15:13:21.450616	2026-07-08 15:43:36.007517	t
rfid-1783498416009367500	\N	2	2026-07-08 15:13:21.461243	2026-07-08 15:43:36.009367	t
rfid-1783499555793353200	\N	2	2026-07-08 15:32:21.248657	2026-07-08 16:02:35.793353	t
rfid-1783499564278367000	\N	2	2026-07-08 15:32:29.735499	2026-07-08 16:02:44.278367	t
rfid-1783499564279135000	\N	2	2026-07-08 15:32:29.73549	2026-07-08 16:02:44.279135	t
rfid-1783499627219369900	\N	2	2026-07-08 15:33:32.669954	2026-07-08 16:03:47.219369	t
rfid-1783499627221423900	\N	2	2026-07-08 15:33:32.680862	2026-07-08 16:03:47.221423	t
rfid-1783499631976915200	\N	2	2026-07-08 15:33:37.428689	2026-07-08 16:03:51.976915	t
rfid-1783499631979423900	\N	2	2026-07-08 15:33:37.440004	2026-07-08 16:03:51.979423	t
rfid-1783499867296257000	\N	2	2026-07-08 15:37:32.751665	2026-07-08 16:07:47.296257	t
rfid-1783499892835536900	\N	2	2026-07-08 15:37:58.305245	2026-07-08 16:08:12.835536	t
rfid-1783499892838056000	\N	2	2026-07-08 15:37:58.30522	2026-07-08 16:08:12.838056	t
rfid-1783499941126571100	\N	2	2026-07-08 15:38:46.583449	2026-07-08 16:09:01.126571	t
rfid-1783499941128761700	\N	2	2026-07-08 15:38:46.594494	2026-07-08 16:09:01.128761	t
rfid-1783499961421315600	\N	2	2026-07-08 15:39:06.879618	2026-07-08 16:09:21.421315	t
rfid-1783499961423335600	\N	2	2026-07-08 15:39:06.892714	2026-07-08 16:09:21.423335	t
rfid-1783500005652479000	\N	2	2026-07-08 15:39:51.110317	2026-07-08 16:10:05.652479	t
rfid-1783500005652993500	\N	2	2026-07-08 15:39:51.118924	2026-07-08 16:10:05.652993	t
rfid-1783500031417333900	\N	2	2026-07-08 15:40:16.874341	2026-07-08 16:10:31.417333	t
rfid-1783500031418939800	\N	2	2026-07-08 15:40:16.882962	2026-07-08 16:10:31.418939	t
rfid-1783500044224986000	\N	2	2026-07-08 15:40:29.683091	2026-07-08 16:10:44.224986	t
rfid-1783500044228087300	\N	2	2026-07-08 15:40:29.692776	2026-07-08 16:10:44.228087	t
rfid-1783500120631261800	\N	2	2026-07-08 15:41:46.089254	2026-07-08 16:12:00.631261	t
rfid-1783500126066830600	\N	2	2026-07-08 15:41:51.536064	2026-07-08 16:12:06.06683	t
rfid-1783500126064400600	\N	2	2026-07-08 15:41:51.5361	2026-07-08 16:12:06.0644	t
rfid-1783500206644827800	\N	2	2026-07-08 15:43:12.105684	2026-07-08 16:13:26.644827	t
rfid-1783500206647322200	\N	2	2026-07-08 15:43:12.115655	2026-07-08 16:13:26.647322	t
rfid-1783565032325562900	\N	2	2026-07-09 09:43:36.813254	2026-07-09 10:13:52.325562	t
rfid-1783565032326075600	\N	2	2026-07-09 09:43:36.821101	2026-07-09 10:13:52.326075	t
rfid-1783565037291557700	\N	2	2026-07-09 09:43:41.77149	2026-07-09 10:13:57.291557	t
rfid-1783565037294169600	\N	2	2026-07-09 09:43:41.781744	2026-07-09 10:13:57.294169	t
rfid-1783565042144626800	\N	2	2026-07-09 09:43:46.623594	2026-07-09 10:14:02.144626	t
rfid-1783565042147604300	\N	2	2026-07-09 09:43:46.643727	2026-07-09 10:14:02.147604	t
rfid-1783565144700912800	\N	2	2026-07-09 09:45:29.183431	2026-07-09 10:15:44.700912	t
rfid-1783565150118540900	\N	2	2026-07-09 09:45:34.617411	2026-07-09 10:15:50.11854	t
rfid-1783565150120779000	\N	2	2026-07-09 09:45:34.617411	2026-07-09 10:15:50.120779	t
rfid-1783565768205842300	\N	2	2026-07-09 09:55:52.704976	2026-07-09 10:26:08.205842	t
rfid-1783565904215346100	\N	6	2026-07-09 09:58:08.718483	2026-07-09 10:28:24.215346	t
rfid-1783571892326719200	\N	2	2026-07-09 11:37:56.785847	2026-07-09 12:08:12.326719	t
rfid-1783571892329135400	\N	2	2026-07-09 11:37:56.855385	2026-07-09 12:08:12.329135	t
rfid-1783571953670437000	\N	2	2026-07-09 11:38:58.119417	2026-07-09 12:09:13.670437	t
rfid-1783571953672837300	\N	2	2026-07-09 11:38:58.136042	2026-07-09 12:09:13.672837	t
rfid-1783571960357569200	\N	2	2026-07-09 11:39:04.813392	2026-07-09 12:09:20.357569	t
rfid-1783571960359791500	\N	2	2026-07-09 11:39:04.82325	2026-07-09 12:09:20.359791	t
rfid-1783572010315888200	\N	2	2026-07-09 11:39:54.765218	2026-07-09 12:10:10.315888	t
rfid-1783572010318058200	\N	2	2026-07-09 11:39:54.771421	2026-07-09 12:10:10.318058	t
rfid-1783572022153806000	\N	2	2026-07-09 11:40:06.601212	2026-07-09 12:10:22.153806	t
rfid-1783572022155636500	\N	2	2026-07-09 11:40:06.61207	2026-07-09 12:10:22.155636	t
rfid-1783579661971207500	\N	2	2026-07-09 13:47:26.459666	2026-07-09 14:17:41.971207	t
rfid-1783579661971717900	\N	2	2026-07-09 13:47:26.507255	2026-07-09 14:17:41.971717	t
rfid-1783579685485365200	\N	2	2026-07-09 13:47:49.964783	2026-07-09 14:18:05.485365	t
rfid-1783579685487229000	\N	2	2026-07-09 13:47:49.977203	2026-07-09 14:18:05.487229	t
rfid-1783579707866521400	\N	2	2026-07-09 13:48:12.347602	2026-07-09 14:18:27.866521	t
rfid-1783579707868573100	\N	2	2026-07-09 13:48:12.364555	2026-07-09 14:18:27.868573	t
rfid-1783579763058268800	\N	2	2026-07-09 13:49:07.538491	2026-07-09 14:19:23.058268	t
rfid-1783579763058853600	\N	2	2026-07-09 13:49:07.546848	2026-07-09 14:19:23.058853	t
rfid-1783579809421934700	\N	2	2026-07-09 13:49:53.900785	2026-07-09 14:20:09.421934	t
rfid-1783579809424708700	\N	2	2026-07-09 13:49:53.915301	2026-07-09 14:20:09.424708	t
rfid-1783579859965986100	\N	2	2026-07-09 13:50:44.448365	2026-07-09 14:20:59.965986	t
rfid-1783579859968338400	\N	2	2026-07-09 13:50:44.459974	2026-07-09 14:20:59.968338	t
rfid-1783580144181362900	\N	2	2026-07-09 13:55:28.662518	2026-07-09 14:25:44.181362	t
rfid-1783580144183630400	\N	2	2026-07-09 13:55:28.671765	2026-07-09 14:25:44.18363	t
rfid-1783582532527459500	\N	2	2026-07-09 14:35:17.039796	2026-07-09 15:05:32.527459	t
rfid-1783582532528690500	\N	2	2026-07-09 14:35:17.211009	2026-07-09 15:05:32.52869	t
rfid-1783583596201137300	\N	2	2026-07-09 14:53:00.654023	2026-07-09 15:23:16.201137	t
rfid-1783583596202822700	\N	2	2026-07-09 14:53:00.661435	2026-07-09 15:23:16.202822	t
rfid-1783583604662186200	\N	2	2026-07-09 14:53:09.11539	2026-07-09 15:23:24.662186	t
rfid-1783583604664431900	\N	2	2026-07-09 14:53:09.124399	2026-07-09 15:23:24.664431	t
rfid-1783583697986547000	\N	2	2026-07-09 14:54:42.44075	2026-07-09 15:24:57.986547	t
rfid-1783584515971747900	\N	6	2026-07-09 15:08:20.42634	2026-07-09 15:38:35.971747	t
rfid-1784519590048252000	\N	3	2026-07-20 10:53:10.103158	2026-07-20 11:23:10.048254	t
rfid-1784519946532867000	\N	3	2026-07-20 10:59:06.533692	2026-07-20 11:29:06.532869	t
rfid-1784519947238191000	\N	3	2026-07-20 10:59:07.238269	2026-07-20 11:29:07.238193	t
rfid-1784519947365588000	\N	3	2026-07-20 10:59:07.365731	2026-07-20 11:29:07.36559	t
rfid-1784595559558278000	\N	2	2026-07-21 07:59:19.581206	2026-07-21 08:29:19.558282	t
rfid-1784595559562031000	\N	2	2026-07-21 07:59:19.594353	2026-07-21 08:29:19.562036	t
rfid-1784680007990781000	\N	6	2026-07-22 07:26:47.996459	2026-07-22 07:56:47.990789	t
rfid-1784680092820472000	\N	6	2026-07-22 07:28:12.820699	2026-07-22 07:58:12.820475	t
rfid-1784681324912121000	\N	6	2026-07-22 07:48:44.912965	2026-07-22 08:18:44.912125	t
rfid-1784687780445149000	\N	6	2026-07-22 09:36:20.50059	2026-07-22 10:06:20.445151	t
rfid-1784688150500818000	\N	6	2026-07-22 09:42:30.501681	2026-07-22 10:12:30.500821	t
rfid-1784688222632272000	\N	6	2026-07-22 09:43:42.632416	2026-07-22 10:13:42.632274	t
rfid-1784688262010291000	\N	6	2026-07-22 09:44:22.010384	2026-07-22 10:14:22.010296	t
rfid-1784689568477780000	\N	6	2026-07-22 10:06:08.47822	2026-07-22 10:36:08.477787	t
rfid-1784853314815948000	\N	2	2026-07-24 07:35:14.847626	2026-07-24 08:05:14.815952	t
rfid-1784853314812224000	\N	2	2026-07-24 07:35:14.82822	2026-07-24 08:05:14.812227	t
rfid-1784853401833145000	\N	2	2026-07-24 07:36:41.833246	2026-07-24 08:06:41.833149	t
rfid-1784853401836905000	\N	2	2026-07-24 07:36:41.837037	2026-07-24 08:06:41.836909	t
rfid-1784853405467487000	\N	2	2026-07-24 07:36:45.467579	2026-07-24 08:06:45.467491	t
rfid-1784853405467616000	\N	2	2026-07-24 07:36:45.467986	2026-07-24 08:06:45.467617	t
rfid-1784853464089739000	\N	2	2026-07-24 07:37:44.089968	2026-07-24 08:07:44.089743	t
rfid-1784853464101454000	\N	2	2026-07-24 07:37:44.101623	2026-07-24 08:07:44.101458	t
rfid-1784853622562359000	\N	2	2026-07-24 07:40:22.562463	2026-07-24 08:10:22.562363	t
rfid-1784853622562605000	\N	2	2026-07-24 07:40:22.56291	2026-07-24 08:10:22.562606	t
rfid-1784853627548739000	\N	2	2026-07-24 07:40:27.548844	2026-07-24 08:10:27.548743	t
rfid-1784853627548885000	\N	2	2026-07-24 07:40:27.549075	2026-07-24 08:10:27.548887	t
rfid-1784866426544105000	\N	6	2026-07-24 11:13:46.597957	2026-07-24 11:43:46.544107	t
rfid-1784867366958271000	\N	6	2026-07-24 11:29:26.982731	2026-07-24 11:59:26.958274	t
rfid-1785115285196656000	\N	2	2026-07-27 08:21:25.201766	2026-07-27 08:51:25.19666	t
rfid-1785115285197300000	\N	2	2026-07-27 08:21:25.228873	2026-07-27 08:51:25.19731	t
rfid-1785115289233400000	\N	2	2026-07-27 08:21:29.233721	2026-07-27 08:51:29.233404	t
rfid-1785115289232726000	\N	2	2026-07-27 08:21:29.234028	2026-07-27 08:51:29.233528	t
rfid-1785116503547871000	\N	6	2026-07-27 08:41:43.548926	2026-07-27 09:11:43.547877	t
rfid-1785118262466388000	\N	6	2026-07-27 09:11:02.467259	2026-07-27 09:41:02.466392	t
rfid-1785202295550717000	\N	6	2026-07-28 08:31:35.553285	2026-07-28 09:01:35.550722	t
\.


--
-- Data for Name: spareparts; Type: TABLE DATA; Schema: public; Owner: sonyaalexandrapaleng
--

COPY public.spareparts (id, kode_oracle, kode_rfid, no_part, nama_item, deskripsi, jenis_mesin, lokasi, harga, stok, min_stok, max_stok, usage_per_year, foto_url, created_at, updated_at, pdf_url, deleted_at) FROM stdin;
1	SPPMMN0002	\N	\N	Bracket	Bracket p/n 560 075 002	PAMPAC	A11	447806.25	1	1	2	4	/static/uploads/SPPMMN0002.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
2	SPPMPM0002	\N	\N	Pulley	Pulley Driving ; p/n 320 045 001	PAMPAC	A110	232500.00	0	2	3	1	/static/uploads/SPPMPM0002.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
3	SPPMGE0008	\N	\N	Spur Gear	Spur Gear m=3 Z=14 dia. 48	PAMPAC	A111	1068000.00	0	1	3	2	\N	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
4	SPPMGE0007	\N	\N	Spur Gear	Spur Gear m=1.5 Z=16 S45C	PAMPAC	A112	252000.00	3	1	2	0	/static/uploads/SPPMGE0007.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
5	SPPMGE0002	\N	\N	Bevel Gear	Bevel Gear Shaft m=2 Z=15 S45C	PAMPAC	A113	525000.00	0	2	4	1	\N	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
6	SPPMFE0001	\N	\N	Folder	Folder p/n 740064-001 PAMPAC	PAMPAC	A115	942000.00	0	1	2	1	\N	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
7	SPPMLH0001	\N	\N	Opener	Opener p/n 470 153 001	PAMPAC	A116	718140.00	1	1	2	0	/static/uploads/SPPMLH0001.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
8	SPPMDI0001	\N	\N	Thurst Disc	Thurst Disc p/n 830 009 001	PAMPAC	A117	0.00	4	1	6	0	/static/uploads/SPPMDI0001.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
9	SPMERW0062	\N	\N	Sealing Washer	Sealing Washer p/n 830 013 001	PAMPAC	A118	14989.00	29	1	6	0	/static/uploads/SPMERW0062.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
10	SPMECK0039	\N	\N	Clamping	Clamp Ring Shregi dia 20x35RFM ( p/n FWL 912 )	PAMPAC	A119	174864.00	8	1	6	1	/static/uploads/SPMECK0039.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
11	SPPMMN0001	\N	\N	Bracket	Bracket p/n 560 074 002	PAMPAC	A12	0.00	1	1	2	1	/static/uploads/SPPMMN0001.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
12	SPPMHD0001	\N	\N	Batch Nr Holder	Batch Nr Holder  dia. 38 x 4	PAMPAC	A120	225000.00	0	16	26	27	\N	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
13	SPMEBE0309	\N	\N	Rod End	Rod End  p/n 232	PAMPAC	A121	205000.00	1	2	3	1	/static/uploads/SPMEBE0309.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
14	SPMEBE0307	\N	\N	Rod End	Rod End W454 ; p/n GBT 221	PAMPAC	A122	184880.95	3	1	2	0	/static/uploads/SPMEBE0307.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
15	SPMEBE0308	\N	\N	Rod End	Rod End W45 ; p/n GBT 222	PAMPAC	A123	0.00	0	1	2	0	\N	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
16	SPMESG0089	\N	\N	SP L Strip	Sp. L . Strip p/n 740 082 001	PAMPAC	A124	65000.00	7	1	11	9	/static/uploads/SPMESG0089.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
17	SPPMBK0001	\N	\N	Carrier Angle	Carrier Angle p/n 150 071 001 (Pendek)	PAMPAC	A125	592905.80	4	1	6	3	/static/uploads/SPPMBK0001.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
18	SPPMBK0002	\N	\N	Carrier Angle	Carrier Angle p/n 150 72 001 (Panjang)	PAMPAC	A126	663523.91	8	1	6	4	/static/uploads/SPPMBK0002.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
19	SPPMGU0001	\N	\N	Folding Rail	Folding Rail p/n 470 156 001	PAMPAC	A127	0.00	0	0	0	1	\N	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
20	SPPMGU0002	\N	\N	Folding Rail (Rear)	Folding Rail (Rear) p/n 471 270 002	PAMPAC	A128	0.00	0	0	0	1	\N	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
21	SPMECU0027	\N	\N	Slit Clamping Coupling	Slit Clamping Coupling MWS-25C  NBK (tinggi 3cm)	PAMPAC	A129	400000.00	1	1	2	1	/static/uploads/SPMECU0027.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
22	SPMEBS0034	\N	\N	Think Walled Bush	Think Walled Bush 12BX14 ; p/n GMM 543	RVS	A13	65149.00	0	1	2	8	/static/uploads/SPMEBS0034.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
23	SPMEBS0033	\N	\N	Think Walled Bush	Think Walled Bush D 1494 M10 ; p/n GMM 536	PAMPAC	A14	0.00	0	0	0	0	/static/uploads/SPMEBS0033.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
24	SPMEBS0035	\N	\N	Thin Bush	Thin Bush DIN 1494 14B (p/n GMM 544) 16 x 15	PAMPAC	A15	0.00	0	0	0	0	\N	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
25	SPMEBS0070	\N	\N	Bushing	Bushing p/n 8.11.1901.036 dia. 18 x 16 x 25	PAMPAC	A16	0.00	0	1	2	0	\N	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
26	SPMEBS0078	\N	\N	Bushing	Bushing p/n 8.11.1901.044 dia. 23 x 20 x 25	PAMPAC	A17	22991.00	15	1	6	0	/static/uploads/SPMEBS0078.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
27	SPMEBS0032	\N	\N	Sintered Bush	Sintered Bush p/n GMM 551	PAMPAC	A18	0.00	4	1	6	0	/static/uploads/SPMEBS0032.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
28	SPPMPM0001	\N	\N	Pulley	Pulley Driven ; p/n 320 013 002	PAMPAC	A19	765000.00	2	2	6	5	/static/uploads/SPPMPM0001.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
29	SPMEFI0289	\N	\N	Element Filter	Element Filter PE-3116674  PIAB	PAMPAC	A21	0.00	0	0	0	1	/static/uploads/SPMEFI0289.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
30	SPPMCT0001	\N	\N	Potensiometer	Potensiometer p/n E 19 117	PAMPAC	A210	745261.78	6	1	6	1	/static/uploads/SPPMCT0001.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
31	SPPMCX0002	\N	\N	Sucker Blue	Sucker Blue	PAMPAC	A211	175000.00	21	30	40	122	/static/uploads/SPPMCX0002.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
32	SPPMSP0006	\N	\N	Sprocket Gear	Sprocket Gear ANSI 40 Type B Z=16 (dia. 71)	PAMPAC	A212	30188.00	3	1	6	0	/static/uploads/SPPMSP0006.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
33	SPPMGE0001	\N	\N	Bevel Gear	Bevel Gear m=2 Z=30  VCN	PAMPAC	A213	983944.50	1	1	3	2	/static/uploads/SPPMGE0001.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
34	SPPMBK0003	\N	\N	Inserter Carriage	Inserter Carriage p/n 150 065 001	PAMPAC	A214	2910284.46	6	2	5	5	/static/uploads/SPPMBK0003.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
35	SPMEFI0288	\N	\N	Suc Filter	Suc Filter For Vaccume Pump IV 300 ; p/n GPV 319	PAMPAC	A215	0.00	0	0	0	5	/static/uploads/SPMEFI0288.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
36	SPPMGE0009	\N	\N	Bevel Gear	Bevel Gear Pendek m=2,z=30	PAMPAC	A216	663428.57	4	1	4	2	/static/uploads/SPPMGE0009.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
37	SPPMCT0008	\N	\N	PLC	PLC FX3G-40MT-DSS VDC 24V	PAMPAC	A23	4748000.00	1	0	0	0	/static/uploads/SPPMCT0008.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
38	SPPMMD0001	\N	\N	Power Supply	Power Supply DC Input 230 VAC ; p/n E 10 001	PAMPAC	A24	635000.00	2	1	3	2	/static/uploads/SPPMMD0001.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
39	SPECSW0115	\N	\N	Micro Switch	Micro Switch XCJ-110 (p/n E 07402)  Telemecanique	PAMPAC	A25	0.00	0	0	0	0	\N	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
40	SPECSW0111	\N	\N	Limit Switch	Limit Switch Snap Action ; p/n E 07 401 (Siemens)	PAMPAC	A26	1503000.00	3	0	5	1	/static/uploads/SPECSW0111.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
41	SPPMCT0002	\N	\N	Single Phase Preventor	Single Phase Preventor ALV - D2 ; p/n E 05 019	PAMPAC	A27	2200000.00	4	1	2	0	/static/uploads/SPPMCT0002.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
42	SPECSW0109	\N	\N	Contact Element S1	Contact Element S1 p/n E 00 001	PAMPAC	A28	0.00	2	1	2	0	/static/uploads/SPECSW0109.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
43	SPECSW0110	\N	\N	Contact Element S2	Contact Element S2 p/n E 00 002	PAMPAC	A29	9091.00	8	1	2	0	/static/uploads/SPECSW0110.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
44	SPPMNB0001	\N	\N	Bantalan no Batch	Bantalan no Batch Pampac	PAMPAC	A31	0.00	0	1	2	6	\N	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
45	SPVPCB0002	\N	\N	Sensor Cable	Sensor Cable DOL-1204-W02MN	PAMPAC	A310	350000.00	5	0	5	1	/static/uploads/SPVPCB0002.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
46	SPPIVA0163	\N	\N	Solenoid Valve	24VDC 1/4" NPT QD w/ Led Pilot  MAC	PAMPAC	A311	699000.00	2	1	2	0	/static/uploads/SPPIVA0163.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
47	SPPIVA0172	\N	\N	Solenoid Valve	MFH-5-1/8 B  Festo (5/2)	MEJA REPACK	A312	2216820.75	6	1	3	1	/static/uploads/SPPIVA0172.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
48	SPPIVA0160	\N	\N	Solenoid Valve	166B 611JB 24V CISF 8,5w  (3/2)	PAMPAC	A313	2000000.00	5	1	3	11	/static/uploads/SPPIVA0160.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
49	SPPIVA0165	\N	\N	Solenoid Valve	PR92C-DOAA-9  MAC	JINCHENG	A314	1070000.00	2	1	2	0	/static/uploads/SPPIVA0165.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
50	SPPIVA0166	\N	\N	Solenoid Valve	35A-ACB-DODA-1BA9 24VDC 7.3W  MAC	JINCHENG	A315	0.00	0	1	2	1	\N	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
51	SPPMNZ0001	\N	\N	Nozzle	Nozzle p/n 322 010 Nordson	PAMPAC	A316	1000028.57	2	1	3	1	/static/uploads/SPPMNZ0001.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
52	SPMEFI0290	\N	\N	Inline Filter Screen	Inline Filter Screen 200 mesh Nordson	PAMPAC	A317	0.00	3	1	4	3	/static/uploads/SPMEFI0290.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
53	SPJCMD0003	\N	\N	Module	Module H200 Standard p/n 276 119	PAMPAC	A32	3385000.00	5	0	0	0	/static/uploads/SPJCMD0003.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
54	SPJCBK0002	\N	\N	Seat	Seat with Carbide (p/n 276535)	PAMPAC	A33	0.00	0	0	0	3	\N	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
55	SPPMMD0004	\N	\N	Module Surebead S	Module Surebead S, 008, Purple, p/n1052928 Nordson	PAMPAC	A34	12240750.00	4	2	6	17	/static/uploads/SPPMMD0004.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
56	SPMEFI0248	\N	\N	Filter Saturn Inline	Filter Saturn Inline 200 mesh   (p/n 1007232)  Nordson	PAMPAC	A35	0.00	0	1	2	1	/static/uploads/SPMEFI0248.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
57	SPMEFI0249	\N	\N	Filter Saturn Inline	Filter Saturn Inline 200 mesh 45deg (p/n 1007235)	PAMPAC	A36	2413200.00	2	1	2	4	/static/uploads/SPMEFI0249.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
58	SPPMNZ0002	\N	\N	Nozzle Surebead 008	Nozzle Surebead 008 Orifice p/n 339695 Nordson	PAMPAC	A37	2083800.00	5	2	3	15	/static/uploads/SPPMNZ0002.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
59	SPPMPT0005	\N	\N	Pusher Strip	Pusher Strip p/n 610 478 001	PAMPAC	A38	1124888.50	4	1	5	1	/static/uploads/SPPMPT0005.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
60	SPJCSS0008	\N	\N	Photoelectric Sensor	Photoelectric Sensor VTF18-4P1240 Sick	PAMPAC	A39	1230000.00	3	1	4	1	/static/uploads/SPJCSS0008.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
61	SPPMPT0003	\N	\N	Chain Plat Front	Chain Plate Front Big Treaded ; p/n 830 017 001	PAMPAC	A41	33360.00	29	8	43	29	/static/uploads/SPPMPT0003.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
62	SPPMPT0004	\N	\N	Chain Plat Front	Chain Plate Front Big W/O Insert ; p/n 830 019 001	PAMPAC	A42	33360.00	31	8	33	20	/static/uploads/SPPMPT0004.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
63	SPPMPT0001	\N	\N	Chain Plate Rear	Chain Plate Rear Small Treaded ; p/n 830 016 001	PAMPAC	A43	0.00	0	20	70	38	/static/uploads/SPPMPT0001.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
64	SPPMPT0002	\N	\N	Chain Plate Rear	Chain Plate Rear Small W/O Insert ; p/n 830 018 00	PAMPAC	A44	43716.00	0	4	14	14	/static/uploads/SPPMPT0002.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
65	SPPMSS0001	\N	\N	Photoelectric Prox,Sensor	Photoelectric Proximity Sensor WT9L-P330  Sick	PAMPAC	A45	3428000.00	5	1	6	2	/static/uploads/SPPMSS0001.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
66	SPPMGU0010	\N	\N	Chell Angle LH	Cell Angle LH p/n W0560680AZ	PAMPAC	A51	0.00	0	20	70	10	/static/uploads/SPPMGU0010.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
67	SPPMGU0011	\N	\N	Chell Angle RH	Cell Angle RH p/n W0560681AZ	PAMPAC	A52	0.00	0	20	70	10	/static/uploads/SPPMGU0011.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
68	SPPMCA0001	\N	\N	Cam	Cam p/n SW0310013AZ	PAMPAC	A53	5828800.00	1	1	2	0	\N	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
69	SPPMCA0002	\N	\N	Cam	Cam p/n SW0310014AZ	PAMPAC	A54	0.00	0	1	2	0	\N	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
70	SPPMSH0011	\N	\N	Shaft	Shaft SFRW8-294-M5-N5	PAMPAC	A55	0.00	0	1	2	0	\N	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
71	SPPHSL0001	\N	\N	Seal profile C	Seal profile C silicone clear Id.200mm x 6mm x 4mm x8mm	DISCHARGE STATION	AA1	170000.00	50	7	57	69	/static/uploads/SPPHSL0001.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
72	SPSEDS0002	\N	\N	Seal butterfly valve	Seal butterfly valve material silicone clear DN 250	GEA	AA1	1000000.00	0	1	2	0	/static/uploads/SPSEDS0002.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
73	SPTSSL0001	\N	\N	Flexible Connector	LINAPLUS FGL Flexible Connector Rubber Sleeve, white, 3mm thick, Hose Clamp 750mm, 753mm x 300mm LG	Tipping Station	AA1	4667300.00	1	2	4	2	/static/uploads/SPTSSL0001.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
74	SPFBSE0008	\N	\N	Seal Kontainer	Seal Kontainer Dia dalam. 1720mm Silicone Clear	FBD	AA2	7750000.00	2	1	2	1	/static/uploads/SPFBSE0008.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
75	SPFBSE0010	\N	\N	Seal Bag Tight	Seal Bag Tight Dia. 987X1087X25mm Silicone Clear	FBD	AA2	6507653.06	2	3	5	20	/static/uploads/SPFBSE0010.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
76	SPFBFI0004	\N	\N	Filter Bag	Filter Bag FBD Size 8, dia 1020x1500xF/W 280mm, Polynova PES93730F Antistatic	FBD	AA3	45000000.00	3	5	10	9	\N	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
77	SPFBSE0009	\N	\N	Seal Kontainer	Seal Kontainer Dia dalam. 1420mm Silicone Clear	FBD	AA4	7250000.00	2	1	2	1	/static/uploads/SPFBSE0009.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
78	SPFBSE0014	\N	\N	Filter Dust Colector	Seal Ferulle Pipa ID 200mm x 219mm x 6mm Silicone Clear, Model ada kuping	FBD	AA4	0.00	0	1	2	10	/static/uploads/SPFBSE0014.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
79	SPMEBE0350	\N	\N	Joint Rod Head	Joint Rod Head SMG 840	RVS	B110	0.00	0	1	2	2	/static/uploads/SPMEBE0350.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
80	SPMEBE0351	\N	\N	Joint Rod Head	Joint Rod Head SMG 1040	RVS	B111	258500.00	3	0	5	1	/static/uploads/SPMEBE0351.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
81	SPMEBE0352	\N	\N	Joint Rod Head	Joint Rod Head SMG 1240	RVS	B112	0.00	3	0	5	1	/static/uploads/SPMEBE0352.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
82	SPSVPT0001	\N	\N	Finger Plate	Finger Plate  20 x 3	RVS	B115	0.00	0	1	2	9	\N	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
83	SPMEBO0277	\N	\N	Distance bolt	Distance bolt  dia. 8 X 10	RVS	B116	187041.38	2	9	14	12	/static/uploads/SPMEBO0277.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
84	SPMESG0099	\N	\N	Coil Spring	Coil Spring SWM 20-35  Misumi	RVS	B117	35625.00	5	1	2	0	/static/uploads/SPMESG0099.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
85	SPMECU0043	\N	\N	Flexible Coupling	Flexible Coupling MJT-20C-BL  NBK	RVS	B119	612200.00	3	1	6	6	/static/uploads/SPMECU0043.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
86	SPSVBK0001	\N	\N	Mounting Bracket	Mounting Bracket HFOE-D Mini  Festo	RVS	B120	28260.00	3	1	2	0	/static/uploads/SPSVBK0001.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
87	SPMEBE0368	\N	\N	Joint rod head	Joint Rod Head SMLG 1040 (KIRI)	RVS	B125	254487.18	4	1	6	2	/static/uploads/SPMEBE0368.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
88	SPSVSV0006	\N	\N	Timing Pulley	TIMING PULLEY M=8, Z=19 ALUMUNIUM	RVS	B126	564586.42	11	1	6	1	/static/uploads/SPSVSV0006.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
89	SPSVRO0005	\N	\N	Roller	Roller p/n 5626 9518 Assy	RVS	B127	478571.43	2	0	2	2	/static/uploads/SPSVRO0005.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
90	SPSVRV0001	\N	\N	Filtzring	Filtzring dia. 22 x 10 x 12	RVS	B14	0.00	0	2	3	14	/static/uploads/SPSVRV0001.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
91	SPMENI0034	\N	\N	Grease nipple A	Grease nipple A  1/4" (Lurus)	GENERAL	B15	20000.00	14	1	6	5	/static/uploads/SPMENI0034.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
92	SPMENI0035	\N	\N	Grease nipple head	Grease nipple head  1/4" (Bentuk L)	RVS	B16	24610.06	2	2	12	9	/static/uploads/SPMENI0035.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
93	SPMEBS0043	\N	\N	Plain Bearing Bushing	Plain Bearing Bushing  p/n 5903 2220 1022	RVS	B17	9000.00	178	4	5	28	/static/uploads/SPMEBS0043.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
94	SPMEBE0348	\N	\N	Camfollower	Cam follower X0M01-RSIZ-T9H-L20   (p/n 5790 159(60)) dia. 40	RVS	B18	0.00	5	1	2	0	/static/uploads/SPMEBE0348.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
95	SPMEBE0349	\N	\N	Joint Rod Head	Joint Rod Head SMLG 840 (KIRI)	JINCHENG	B19	0.00	0	1	2	3	/static/uploads/SPMEBE0349.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
96	SPMEBO0298	\N	\N	Exentric Bolt	Excentrik Bolt M12 x 40 VCN	RVS	B21	38750.00	17	1	6	1	/static/uploads/SPMEBO0298.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
97	SPSVDI0020	\N	\N	Intermadiate Disc	Intermediete Disc 39.5 x 20.5 x 0.2	RVS	B211	42000.00	82	58	108	494	/static/uploads/SPSVDI0020.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
98	SPMERW0091	\N	\N	Plain Washer	Plain Washer dia. 24,9 x 12,65 x 0,2	RVS	B212	0.00	0	1	2	0	\N	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
99	SPMERW0074	\N	\N	Ring	Ring p/n 00545102130004030 dia. 80 x 40 x 3	RVS	B213	0.00	0	1	2	1	\N	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
100	SPMERW0095	\N	\N	Shim Plate	Shim Plate  dia 12.5 x 25 x 0.5	RVS	B214	22500.00	28	2	42	30	/static/uploads/SPMERW0095.jpg	2026-06-23 07:09:21.870556	2026-06-23 07:09:21.870556	\N	\N
101	SPMERW0104	\N	\N	Distance Ring	Distance Ring p/n 5655 8795  dia. 46 x 30 x 2	RVS	B215	0.00	0	1	2	0	\N	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
102	SPSVLH0009	\N	\N	Clamp levers	Clamp Lever CLFS-10-14-M Misumi (Orange)	RVS	B216	340600.00	11	1	6	5	/static/uploads/SPSVLH0009.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
103	SPGULH0001	\N	\N	Clamp levers	Clamp Lever CLMS8-32L-B Misumi	RVS	B217	350892.40	4	1	6	2	/static/uploads/SPGULH0001.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
104	SPMECK0049	\N	\N	Mechalock	Mecha Lock in=22mm, out=37.98mm, tebal 21mm s/s	RVS	B220	1100000.00	3	1	2	0	/static/uploads/SPMECK0049.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
105	SPMEBO0290	\N	\N	Adjustmen bolt	Adjustment Bolt p/n 5664 8281	RVS	B221	63017.56	34	16	51	24	/static/uploads/SPMEBO0290.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
106	SPMEBS0048	\N	\N	Bushing Handle RVS	Bushing Handle RVS 28x16 mm Panjang 15 mm Bronze	RVS	B222	353847.40	5	1	6	3	/static/uploads/SPMEBS0048.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
107	SPMEBO0299	\N	\N	Exentric Bolt / Knife Adjuster	Excentric Bolt M12 x 35 VCN (Tirus) / KNIFE ADJUSTER	RVS	B224	40775.71	8	2	102	35	/static/uploads/SPMEBO0299.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
108	SPMESG0102	\N	\N	Telescopic Absorber	Telescopic Absorber  p/n 5975 2310 0612(Pendek)	RVS	B23	1012988.07	6	1	2	0	/static/uploads/SPMESG0102.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
109	SPSVBK0002	\N	\N	Closing slide	Closing slide  p/n 5478 6265 dia. 4 x 187	RVS	B24	685000.00	7	2	14	13	/static/uploads/SPSVBK0002.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
110	SPSVBK0003	\N	\N	Support	Support p/n 5653 9807	RVS	B25	0.00	2	1	2	0	/static/uploads/SPSVBK0003.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
111	SPMERW0102	\N	\N	Spring Washer	Spring Washer dia. 28 x 12,3 x 1,5	RVS	B26	0.00	0	2	3	8	/static/uploads/SPMERW0102.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
112	SPSVDI0002	\N	\N	Intermadiate disc	Intermadiate disc dia. 65 x 31 x 0.2	RVS	B27	50052.20	60	8	58	101	/static/uploads/SPSVDI0002.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
113	SPSVDI0003	\N	\N	Intermadiate disc	Intermadiate disc   dia. 75 x 36 x 2	RVS	B28	70155.92	38	1	6	0	/static/uploads/SPSVDI0003.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
114	SPSVDI0008	\N	\N	Intermadiate Disc	Intermediate Disc  p/n 0054 5504 0500 00972	RVS	B29	35208.33	215	8	108	76	/static/uploads/SPSVDI0008.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
115	SPSVRO0002	\N	\N	Roller (Gear Tension)	Roller p/n 5655 9397	RVS	B310	652500.00	10	7	27	42	/static/uploads/SPSVRO0002.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
116	SPMECK0046	\N	\N	Mechalock	Mecha Lock dia. 42 / 22 x 30	RVS	B311	0.00	0	1	2	0	\N	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
117	SPSVSV0001	\N	\N	Sprocket Pulley	Sprocket Pulley P32-8MGT-50  Gates	RVS	B312	0.00	0	1	2	2	\N	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
118	SPSVDI0010	\N	\N	Serrated Disc	Serrated Disc p/n 5653 1676	RVS	B313	0.00	0	1	2	0	\N	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
119	SPSVDI0011	\N	\N	Pulley	Pulley PUL 8M-24-50 Optibelt	RVS	B314	0.00	0	1	2	0	\N	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
120	SPSVSV0005	\N	\N	Toothed Disc	Toothed Disc Z-22  dia. 55 x 55	RVS	B315	0.00	0	1	2	1	\N	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
121	SPMECK0045	\N	\N	Clamping Set	Clamping Set p/n 5494 0625	RVS	B316	0.00	0	1	2	1	/static/uploads/SPMECK0045.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
122	SPSVNZ0002	\N	\N	Nozzle	NOZZLE RVS LOKAL	RVS	B317	6830226.48	14	6	11	55	/static/uploads/SPSVNZ0002.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
123	SPMECK0051	\N	\N	Mechalock	MECHA LOCK 38 X 21.5 VCN	RVS	B35	0.00	0	1	2	1	\N	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
124	SPMECK0047	\N	\N	Power Lock	Power Lock PL22-47 AS  Tsubaki	RVS	B36	0.00	0	1	2	0	\N	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
125	SPSVSV0004	\N	\N	Toothed Disc	Toothed Disc Z -22 dia. 55 x 37  Alumunium	RVS	B37	675000.00	3	1	2	0	/static/uploads/SPSVSV0004.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
126	SPMECK0044	\N	\N	Tensor	Tensor p/n 5494 0786	RVS	B38	2100000.00	1	1	3	1	/static/uploads/SPMECK0044.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
127	SPSVRO0001	\N	\N	Deflection Roller	Deflection Roller p/n 5656 5994	RVS	B39	850000.00	5	1	7	8	/static/uploads/SPSVRO0001.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
128	SPSVGE0019	\N	\N	Gear Roller Intermediette	Gear Roller Intermeditte	RVS	B410	1574166.67	7	1	2	0	/static/uploads/SPSVGE0019.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
129	SPSVBK0009	\N	\N	Adapter	Adapter GT48/2 Nr. 49.4  (p/n 5494 2743)	RVS	B42	2947502.00	1	1	2	0	/static/uploads/SPSVBK0009.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
130	SPSPSC0004	\N	\N	Auger	Auger pitch 11 dia. 10,6 x 400 (LOCAL SATEK)	RVS	B43	3450000.00	11	4	10	20	/static/uploads/SPSPSC0004.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
131	SPSVKF0024	\N	\N	BANTALAN SEALING RVS (BESAR)	BANTALAN SEALING RVS MATERIAL PERTINAX 457X32X5 MM	RVS	B44	650000.00	13	8	18	259	/static/uploads/SPSVKF0024.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
132	SPMECU0038	\N	\N	Schimid Coupling	Schmidt Coupling p/n 5493 7342	RVS	B45	0.00	0	1	2	1	/static/uploads/SPMECU0038.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
133	SPSVKF0023	\N	\N	BANTALAN SEALING RVS (KECIL)	BANTALAN SEALING RVS MATERIAL PERTINAX 320MM	RVS	B46	420000.00	16	10	20	496	/static/uploads/SPSVKF0023.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
134	SPMECU0046	\N	\N	Coupling	Coupling NSS 779 Miki Pulley	RVS	B47	0.00	0	1	2	1	/static/uploads/SPMECU0046.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
135	SPSVDI0015	\N	\N	Serrated Disc	Serrated Disc p/n 56270554	RVS	B48	427292.00	8	1	2	0	/static/uploads/SPSVDI0015.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
136	SPSVDI0016	\N	\N	Serrated Disc	Serrated Disc p/n 56269509	RVS	B49	440000.00	4	1	2	0	/static/uploads/SPSVDI0016.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
137	SPSVKF0001	\N	\N	Cross Knife (pisau cross rvs)	420 x 30 x 6 ( P/N 56269651 )	RVS	B51	3589754.35	2	25	35	180	/static/uploads/SPSVKF0001.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
138	SPSVKF0007	\N	\N	Counter Cross Flat (Bantalan Pisau cross)	420 x 25 x 6	RVS	B52	2464890.00	6	4	5	17	/static/uploads/SPSVKF0007.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
139	SPSVKF0015	\N	\N	Counter Cross Knife Horizontal	420 x 25 x 6mm p/n 5665 2213 D-K-L-P	RVS	B53	3091100.00	3	2	4	5	/static/uploads/SPSVKF0015.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
140	SPSVKF0003	\N	\N	I Notch Blade / I CUT	420 x 28 x 6 (6 line) (ABCEFGHJMNRST)	RVS	B54	3558820.00	4	8	9	23	/static/uploads/SPSVKF0003.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
141	SPSVKF0004	\N	\N	Notch Counter / Bantalan I CUT	420 x 24.45 x 7.5-5.5mm ( 6 Line ) (ABCEFGHJMNRST)	RVS	B55	3595886.14	0	1	3	15	/static/uploads/SPSVKF0004.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
142	SPSVKF0009	\N	\N	Longitudinal Knife (Pisau Belah)	dia. 35 x 9	RVS	B56	1580675.29	19	42	44	198	/static/uploads/SPSVKF0009.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
143	SPSVKF0017	\N	\N	I CUT	I CUT N-P 420 x 28 x 6mm  ( 6 Line )	RVS	B57	2625948.00	1	2	4	10	/static/uploads/SPSVKF0017.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
144	SPSVKF0016	\N	\N	Counter I Cut (Bantalan I CUT)	D-K-L-P 420 x 24.45 x 7.5-5.5mm  ( 6 Line )	RVS	B58	3238874.42	0	2	4	5	/static/uploads/SPSVKF0016.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
145	SPSVKF0008	\N	\N	Counter Cross Perforate	Counter Cross Perforate 420 x 25 x 6	RVS	B59	0.00	0	0	0	0	\N	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
146	SPMEBL0001	\N	\N	Belt	Belt Roughtop + Profil K10 polos  Seperti Contoh(hijau)	BESTPACK	BB	258285.71	5	0	4	5	/static/uploads/SPMEBL0001.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
147	SPMEBL0163	\N	\N	Timing Belt	Timing Belt 250XL L-037 Pitch 1/5" 10mm OPTIBELT	PAMPAC	BB	74098.88	48	4	34	16	/static/uploads/SPMEBL0163.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
148	SPMEBL0164	\N	\N	Transfer Belt	Transfer Belt 1118 x 30 x 2 Habasit	PAMPAC	BB	75000.00	56	5	35	153	/static/uploads/SPMEBL0164.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
149	SPMEBL0172	\N	\N	Toothed Belt	Toothed Belt TP 880 8M.30   (p/n 54942457)	RVS	BB	2484000.00	4	1	6	2	\N	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
150	SPMEBL0173	\N	\N	Toothed Belt	Toothed Belt 20 HTD 8 / 1800   (p/n 591151203190)	RVS	BB	0.00	1	2	3	4	/static/uploads/SPMEBL0173.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
151	SPMEBL0174	\N	\N	Toothed Belt	Toothed Belt HTDTP 720 8M.50 (p/n 56531904) (Pisau RVS)	RVS	BB	2896684.28	17	7	22	36	/static/uploads/SPMEBL0174.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
152	SPMEBL0183	\N	\N	Toothed Belt	Toothed Belt HTDTP 880 8M 50 Gates (Sealing)	RVS	BB	1505409.88	16	11	26	74	/static/uploads/SPMEBL0183.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
153	SPMEBL0188	\N	\N	Toothed Belt	Toothed Belt HTD 424 8M 50  Gates	RVS	BB	546250.00	9	1	6	3	/static/uploads/SPMEBL0188.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
154	SPMEBL0189	\N	\N	Toothed Belt	Toothed Belt HTDTP 800 8M 50  Gates (No Batch)	RVS	BB	2729047.42	12	1	21	6	/static/uploads/SPMEBL0189.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
155	SPTVBL0001	\N	\N	Belt Conveyor (Belt STV)	Belt Conveyor STV 2400x20x2mm	STV	BB	0.00	0	2	7	5	/static/uploads/SPTVBL0001.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
156	SPMEBL0166	\N	\N	Conveyor Belt	Conveyor Belt 118 x 4680 x 2 mm PVC	CHIMEI	BB1	296710.00	5	1	2	0	\N	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
157	SPMERL0055	\N	\N	Safety Relay Array	Safety Relay Array SRB-NA-R-C.35 24VDC 2s  Elan	RVS	C11	0.00	0	1	2	0	\N	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
158	SPSVMC0001	\N	\N	MCB	MCB 220 VAC 6A 1ph  Klockner Moeller	RVS	C110	0.00	0	1	2	0	\N	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
159	SPSVLM0003	\N	\N	Glass Lens	Glass Lens OBJ-212 10mm  Sick	RVS	C111	474034.00	5	1	2	0	/static/uploads/SPSVLM0003.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
160	SPSVSS0005	\N	\N	Proximity Sensor	Proximity Sensor IM12-04BPS-ZCK  Sick	RVS	C112	1195000.00	6	0	5	1	/static/uploads/SPSVSS0005.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
161	SPSVSS0002	\N	\N	Product Sensor	Product Sensor CM18-12NPP-KC1 Sick (Sensor Proximity)	RVS	C114	2539861.11	5	0	2	9	/static/uploads/SPSVSS0002.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
162	SPSPSS0007	\N	\N	Electronic Optic	Electronic Optic NT6 - 03012  Sick	RVS	C115	0.00	0	1	2	1	/static/uploads/SPSPSS0007.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
163	SPSPSS0008	\N	\N	Electronic Optic	Electronic Optic KT5G-2P1111 Sick	RVS	C116	0.00	0	1	2	1	/static/uploads/SPSPSS0008.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
164	SPECSW0134	\N	\N	Contact Block	Contact Block NHI-E-11-PKZO  Moeller	RVS	C117	104167.00	1	1	2	0	/static/uploads/SPECSW0134.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
165	SPSPBT0001	\N	\N	Battery Inorganic Lithium	Battery Inorganic Lithium SL-360PV 3,6V AA Germany	RVS	C118	300035.40	10	1	13	8	/static/uploads/SPSPBT0001.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
166	SPECBT0004	\N	\N	Battery	Battery LR44 Sony	RVS	C119	21863.10	14	1	2	0	/static/uploads/SPECBT0004.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
167	SPSVCN0005	\N	\N	Signal Connector	Signal Connector 12 pins (6FX2003-0SU12)  Siemens	RVS	C12	2500000.00	6	0	0	0	/static/uploads/SPSVCN0005.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
168	SPSVCN0011	\N	\N	Profibus Connector	Profibus Connector 6ES7 972-0BB42-0XA0 Siemens	RVS	C120	975000.00	2	1	3	5	/static/uploads/SPSVCN0011.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
169	SPSVBT0001	\N	\N	Battery Inorganic Lithium	Battery Inorganic Lithium SL-2361 3,6V size 2/3 AA	RVS	C121	343519.26	6	1	2	0	/static/uploads/SPSVBT0001.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
170	SPVPSK0010	\N	\N	Plug Socket	Plug Socket KMYZ-1-24-2,5  Festo	RVS	C14	92244.00	2	1	2	0	/static/uploads/SPVPSK0010.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
171	SPECCC0107	\N	\N	Contactor	Contactor DILEM-01-G 24 VDC 3ph coil 220 V  Klockner Moeller	RVS	C16	767124.33	3	1	2	0	/static/uploads/SPECCC0107.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
172	SPSVMC0002	\N	\N	MCB	MCB PKZMO-2,5 1,6 - 2,5 A 3ph  Klockner Moeller	RVS	C17	821394.60	3	1	2	0	/static/uploads/SPSVMC0002.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
173	SPECCC0108	\N	\N	Contactor	Contactor PKZM 0-1.6  Moeller	RVS	C18	668000.00	4	1	2	0	/static/uploads/SPECCC0108.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
174	SPMERL0038	\N	\N	Solid State Relay ( SSR )	Solid State Relay G3PA-210B 24VDC Omron	RVS	C19	1300000.00	2	0	5	2	/static/uploads/SPMERL0038.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
175	SPSVTP0002	\N	\N	Thermocouple	Thermofeeler PT 1005x47/12 p/n 54915225	RVS	C21	623129.25	5	0	5	7	/static/uploads/SPSVTP0002.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
176	SPSVTP0006	\N	\N	Thermocouple (RVS)	Thermocouple RTD PT100 dia.1.88x1.6x3.97x155 mm	RVS	C22	1350000.00	9	1	13	40	/static/uploads/SPSVTP0006.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
177	SPPIPP0090	\N	\N	Heat pipe	Heat Pipe p/n 59065 6070420 dia. 6.35 x 420	RVS	C23	0.00	0	2	3	3	/static/uploads/SPPIPP0090.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
178	SPMECU0037	\N	\N	Slit Clamping Coupling	Slit Clamping Coupling MFB20C-6x6 (p/n 54944843)	RVS	C24	861262.09	9	1	13	12	/static/uploads/SPMECU0037.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
179	SPSVHA0003	\N	\N	Heater	Heater (Heiztab) 230V 200W   (p/n 5493 4439)  dia. 8,2 x 445 Electroluc (Sealing Long)	RVS	C25	922500.00	16	2	14	28	/static/uploads/SPSVHA0003.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
180	SPSVHA0004	\N	\N	Heater ( Heiztab )	Heater (Heiztab) 230V 600W  dia. 8.2 x 435 (Sealling Cross)	RVS	C26	747500.00	7	3	15	69	/static/uploads/SPSVHA0004.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
181	SPSVSS0004	\N	\N	Ultrasonic Sensor	Ultrasonic Sensor 30I6103/S14 4-20mA Baumer	RVS	C27	11460538.76	1	1	2	0	/static/uploads/SPSVSS0004.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
182	SPSVPC0001	\N	\N	Bantalan No. Batch RVS	Bantalan No. Batch RVS	RVS	C28	750000.00	6	16	28	67	/static/uploads/SPSVPC0001.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
183	SPPIVA0271	\N	\N	Solenoid Valve	VIFB-03-B 03 Fieldbus Terminal 03E-F13  Festo	RVS	C3	0.00	0	1	2	0	\N	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
184	SPSVCB0001	\N	\N	Fibre Optic Cable	Fibre Optic Cable FSF-100A3021 Baumer	RVS	C3	14210000.00	1	1	2	0	\N	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
185	SPSVCT0002	\N	\N	Inverter	Inverter E82EV551K4C (0.55kW 3ph) Lenze	RVS	C3	22025000.00	2	1	2	1	/static/uploads/SPSVCT0002.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
186	SPSVMD0032	\N	\N	Simodrive	Simodrive 6SN1118-0NH01-0AA0 Siemens (Digital)	RVS	C3	35000000.00	0	2	4	8	/static/uploads/SPSVMD0032.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
187	SPSVCT0008	\N	\N	Simodrive	SIMODRIVE 6SN1118-0AE11-0AA1 SIEMENS (Analog)	RVS	C3	37500000.00	0	2	3	5	/static/uploads/SPSVCT0008.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
188	SPSVEN0002	\N	\N	Angle Encoder	Angle encoder OCD-DPB1B-0012-S060-0CC p/n.54954074	RVS	C3	21000000.00	1	0	1	4	\N	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
189	SPSVMD0002	\N	\N	Analog Output Module	Analog Output Module 6ES7-432-1HF00-0AB0 Siemens	RVS	C3	32375000.00	1	1	2	2	/static/uploads/SPSVMD0002.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
190	SPSVMD0003	\N	\N	Analog Input Module	Analog Input Module 6ES7-431-1AF00-0AB0 Siemens	RVS	C3	20587500.00	2	1	2	0	/static/uploads/SPSVMD0003.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
191	SPSVMD0004	\N	\N	Digital Input Module	Digital Input Module 6ES7-421-1BL00-0AA0 Siemens	RVS	C3	0.00	0	1	2	1	/static/uploads/SPSVMD0004.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
192	SPSVMD0011	\N	\N	Power Supply	Power Supply Sitop Power10 6EP1334-2BA20 Siemens	RVS	C3	6000000.00	2	0	1	2	/static/uploads/SPSVMD0011.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
193	SPSVMD0017	\N	\N	Digital Input Module	Digital Input Module 421-7-DHOO-OABO p/n 54934978	RVS	C3	10450000.00	1	1	2	1	/static/uploads/SPSVMD0017.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
194	SPSVMD0018	\N	\N	Digital Output Module	Digital Output Module 422-1BH10-OAAO pn 54952193	RVS	C3	10450000.00	2	1	2	0	/static/uploads/SPSVMD0018.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
195	SPSVPN0002	\N	\N	Slipring Unit	Slipring Unit SR085-2-2-V14  Moog	RVS	C3	38000000.00	3	0	2	12	\N	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
196	SPSVTC0001	\N	\N	Thermocontrol	Thermocontrol KS800-DP typ 9407 480 30001  PMA	RVS	C3	0.00	0	0	0	1	\N	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
197	SPPIVA0274	\N	\N	On Off Valve	On Off Valve HEE-D-MIDI-24 Festo	RVS	C41	1274921.00	1	1	2	0	/static/uploads/SPPIVA0274.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
198	SPSVCN0004	\N	\N	Power Connector	Power Connector size 1 (6FX2003-0LU00)  Siemens	RVS	C43	0.00	0	1	2	1	\N	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
199	SPSVMC0005	\N	\N	Auxilliary	Auxiliary FAZ-XHI11  Moeller	RVS	C44	300000.00	1	1	2	2	\N	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
200	SPSVMC0004	\N	\N	MCB	MCB FAZ-B25/2 25A 2ph  Moeller	RVS	C45	1666725.00	3	1	4	3	/static/uploads/SPSVMC0004.jpg	2026-06-23 07:09:21.909281	2026-06-23 07:09:21.909281	\N	\N
201	SPSVMC0006	\N	\N	Protective Module	Protective Modul FIM-40/2/0,03-A  Moeller	RVS	C46	0.00	0	1	2	1	/static/uploads/SPSVMC0006.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
202	SPSVRO0007	\N	\N	Felt Roller	Felt Roller D=9/25 x 10 p/n 5435 2334	RVS	C47	0.00	0	2	3	12	/static/uploads/SPSVRO0007.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
203	SPMEDB0001	\N	\N	Distanbolt	Distanbolt M10	RVS	C48	185000.00	26	1	13	19	/static/uploads/SPMEDB0001.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
204	SPSVSH0018	\N	\N	Tension Shaft	Tension Shaft Sealing Cross VCN dia 38x90 ss304	RVS	C49	273333.33	10	1	6	5	/static/uploads/SPSVSH0018.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
205	SPMESG0103	\N	\N	Telescopic Absorber	Telescopic Absorber  p/n 5975 2310 1432(panjang)	RVS	C5	2456890.18	0	1	5	6	/static/uploads/SPMESG0103.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
206	SPSVMD0022	\N	\N	Modul Blade Left	Modul Blade Left dia90x750 SKS3 Hardened Nitriding	RVS	C5	20900000.00	1	1	2	1	\N	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
207	SPSVMD0023	\N	\N	Modul Blade Right	Modul Blade Right dia90x750 SKS3Hardened Nitriding	RVS	C5	20900000.00	1	1	2	1	\N	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
208	SPSVMD0035	\N	\N	Modul Blade	Modul Blade Left RVS (DKLP) Nitriding dia 90x750	RVS	C5	20000000.00	2	1	2	0	/static/uploads/SPSVMD0035.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
209	SPSVMD0036	\N	\N	Modul Blade	Modul Blade Right RVS (DKLP) Nitriding dia 90x750	RVS	C5	20000000.00	2	1	2	0	/static/uploads/SPSVMD0036.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
210	SPSVRO0008	\N	\N	Intermediate Roller Unit	Intermediate roller unit SS304 with bearing626	RVS	C5	0.00	0	1	2	1	/static/uploads/SPSVRO0008.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
211	SPSVSE0004	\N	\N	Heating Jaw	Heating Jaw p/n 5655 7857	RVS	C5	0.00	0	1	2	1	/static/uploads/SPSVSE0004.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
212	SPSVSE0011	\N	\N	Heating Jaw LH	Heating Jaw LH p/n 5655 7923	RVS	C5	121570968.51	1	1	2	1	/static/uploads/SPSVSE0011.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
213	SPSVSH0005	\N	\N	Sealing Insert Shaft	Sealing Insert Shaft dia. 20 x 616 VCN	RVS	C5	0.00	10	1	3	4	/static/uploads/SPSVSH0005.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
214	SPSVSH0007	\N	\N	Sliding Shaft	Sliding Shaft p/n 5656 5092	RVS	C5	1030000.00	12	1	2	0	/static/uploads/SPSVSH0007.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
215	SPSVSH0008	\N	\N	Shaft	Shaft p/n 5656 5125	RVS	C5	0.00	10	1	2	0	\N	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
216	SPSVSH0011	\N	\N	Axle	Axle p/n 5655 7024	RVS	C5	0.00	0	1	2	0	\N	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
217	SPSVSH0015	\N	\N	Shaft No Batch	Shaft No Batch p/n 5655 8674	RVS	C5	0.00	0	1	2	0	\N	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
218	SPSVSH0016	\N	\N	Shaft sealing cross RVS	Shaft sealing cross RVS	RVS	C5	6403500.00	2	1	2	0	/static/uploads/SPSVSH0016.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
219	SPSVCT0005	\N	\N	Simodrive	Simodrive 6SN1112-1AC01-0AA1 Siemens	RVS	CC1	32300000.00	1	1	2	2	/static/uploads/SPSVCT0005.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
220	SPSVCT0004	\N	\N	Simodrive	SIMODRIVE 611 P/N 6SN1145-1AA01-0AA2 SIEMENS	RVS	CC2	47500000.00	1	1	2	2	/static/uploads/SPSVCT0004.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
221	SPSVCT0006	\N	\N	Simodrive	Simodrive IP 6SN1123-1AB00-OHA1 Siemens	RVS	CC2	30400000.00	4	0	2	8	\N	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
222	SPSVPT0003	\N	\N	Side Plate	Side Plate p/n 5626 9597 RVS A-M	RVS	CC3	0.00	0	1	2	2	/static/uploads/SPSVPT0003.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
223	SPSVPT0004	\N	\N	Side Plate	Side Plate p/n 5653 1934 RVS A-M	RVS	CC3	0.00	0	1	2	2	/static/uploads/SPSVPT0004.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
224	SPSVPT0008	\N	\N	Side Plate Left	Side Plate Left 436 x 100 x 40 Alumunium (RVS DKLP)	RVS	CC3	2365000.00	1	1	2	1	/static/uploads/SPSVPT0008.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
316	SPROVE0003	\N	\N	Vacum Pad Ejector	Vacum Pad Ejector ZPT20BS-A6 SMC Plus As	ROBOT	E39	0.00	60	32	62	147	/static/uploads/SPROVE0003.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
225	SPSVPT0009	\N	\N	Side Plate Right	Side Plate Right 482 x 100 x 45 Alumunium (RVS DKLP)	RVS	CC3	2725000.00	1	1	2	1	/static/uploads/SPSVPT0009.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
226	SPROCO0003	\N	\N	CONVEYOR CHAIN REXROTH	CONVEYOR CHAIN, 90+FLAT L4968 p/n 3842546070 Rexroth	ROBOT	CC4	0.00	0	1	2	0	\N	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
227	SPROPG0002	\N	\N	Planetary Gearbox	Side Plate Right 482 x 100 x 45 Alumunium (RVS DKLP)	ROBOT	CC4	5942250.00	2	1	2	0	/static/uploads/SPROPG0002.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
228	SPVPHA0001	\N	\N	Heating Cartridge	Heating Cartridge 48V 175W   (p/n 1132.0901.01.003	MEJA REPACK	D11	393750.00	14	0	5	2	/static/uploads/SPVPHA0001.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
229	SPVPTC0002	\N	\N	Thermocouple	Thermocouple p/n. 4.20.09.234.002 Sanara wire length 82 cm	MEJA REPACK	D111	349472.73	3	0	5	2	/static/uploads/SPVPTC0002.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
230	SPJCHA0002	\N	\N	Heating Cartridge	Heating Cartridge 220V 300W dia. 7,5 x 150	CHIMEI	D13	0.00	0	3	4	6	/static/uploads/SPJCHA0002.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
231	SPJCHA0001	\N	\N	Heating Cartridge	Heating Cartridge 220V 300W dia. 7,5 x 200	CHIMEI	D14	487500.00	14	1	13	7	/static/uploads/SPJCHA0001.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
232	SPJCTP0002	\N	\N	Thermocouple	Thermocouple Type K/CA M6 (cable 2000mm)	CHIMEI	D15	100000.00	3	0	5	8	\N	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
233	SPGECO0001	\N	\N	Solenoid Coil	MSFW-24-50/60-EX  Festo	CHIMEI	D16	305798.00	6	1	6	1	/static/uploads/SPGECO0001.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
234	SPMERG0012	\N	\N	Pressure Regulator	Pressure Regulator LR-1/4-D-MINI  Festo	CHIMEI	D17	0.00	0	1	2	1	\N	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
235	SPGESS0003	\N	\N	Sensor Controller	Sensor Controller PA 10-U Autonic	BESTPACK	D18	568468.00	3	0	5	1	/static/uploads/SPGESS0003.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
236	SPGESS0004	\N	\N	Photosensor	Photosensor Autonic BEN 300-DT	BESTPACK	D19	418018.00	9	1	2	0	/static/uploads/SPGESS0004.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
237	SPMEMT0087	\N	\N	Pressure Gauge	Pressure Gauge MAP-40-1-1/8-EN Festo	PAMPAC	D21	279498.00	5	1	6	2	/static/uploads/SPMEMT0087.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
238	SPJCCX0002	\N	\N	Suction cup	Suction Cup  dia. 30 x 14  Polyurethane	JINCHENG	D22	24138.00	2	2	4	2	/static/uploads/SPJCCX0002.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
239	SPPIVA0181	\N	\N	Solenoid Valve	MOFH-3-M5 Festo	CHIMEI	D23	0.00	0	1	2	1	\N	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
240	SPECSW0073	\N	\N	Proximity Switch	Proximity Switch WLL170-N132  Sick	CHIMEI	D24	790000.00	5	1	2	0	/static/uploads/SPECSW0073.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
241	SPJCSS0010	\N	\N	Infrared Sensor	Infrared Sensor WL260-S270  Sick	JINCHENG	D25	0.00	0	1	2	1	\N	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
242	SPJCCB0001	\N	\N	Fibre Optic Cable	Fibre Optic Cable LL3-TB01 Sick	CHIMEI	D26	585000.00	4	1	2	1	/static/uploads/SPJCCB0001.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
243	SPECCB0104	\N	\N	Cable Sensor	Cable Sensor DOL-0804-G02M (panjang 2 mtr) SICK  / YF8U14	CHIMEI	D27	264000.00	4	1	5	2	/static/uploads/SPECCB0104.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
244	SPSMCO0001	\N	\N	Solenoid Coil	MSFW-230AC Festo	CHIMEI	D28	238808.00	2	1	6	0	/static/uploads/SPSMCO0001.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
245	SPMERG0020	\N	\N	Filter Regulator	Filter Regulator LFR-1/4-D-MINI  Festo	CHIMEI	D29	1349521.00	3	1	3	2	/static/uploads/SPMERG0020.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
246	SPWRBR0005	\N	\N	BRAKE	BRAKE B-M10-F02-20	CHIMEI	D3	923500.00	2	1	2	0	/static/uploads/SPWRBR0005.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
247	SPJCSS0006	\N	\N	Photoelectric Sensor	Photoelectric Sensor WT150-N132 Sick	CHIMEI	D31	2200000.00	2	1	2	0	\N	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
248	SPWRCB0001	\N	\N	Fibre Optic Cable	Fibre Optic Cable LL3-DB01  Sick	CHIMEI	D32	528105.68	3	1	5	3	/static/uploads/SPWRCB0001.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
249	SPWRCL0003	\N	\N	Clutch INTRQ14115.08.10 24VDC 16 W 15Nm	Clutch INTRQ14115.08.10 24VDC 16 W 15Nm	CHIMEI	D33	0.00	0	1	2	1	\N	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
250	SPWRBR0001	\N	\N	Clutch brake	Clutch Brake ESC-025 24VDC 0.9A 2.5KG-M Yan Co.Ltd	CHIMEI	D33	0.00	0	1	2	1	\N	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
251	SPYNCT0006	\N	\N	PLC	PLC CPM2A-30CDR-A  Omron	CHIMEI	D34	0.00	0	1	2	0	\N	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
252	SPMERL0068	\N	\N	Solid State Relay ( SSR )	Solid State Relay F-10DA-H FOTEK	CHIMEI	D35	575000.00	2	1	2	0	/static/uploads/SPMERL0068.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
253	SPPIVA0288	\N	\N	Solenoid Valve	RCS2408 200D  Kuroda	CHIMEI	D36	3975000.00	1	1	4	3	/static/uploads/SPPIVA0288.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
254	SPMECU0028	\N	\N	Coupling	Coupling MJT30C-BL NBK	PAMPAC	D37	400000.00	9	2	12	8	/static/uploads/SPMECU0028.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
255	SPMERL0067	\N	\N	Solid State Relay ( SSR )	Solid State Relay G3NA-240B (input 200 - 240VAC)	CHIMEI	D38	619654.00	5	1	2	0	/static/uploads/SPMERL0067.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
256	SPHSKF0001	\N	\N	Perforated Knife	Perforate Knife 65 x 30 x 1,6	BESTPACK	D41	882556.96	9	2	7	3	/static/uploads/SPHSKF0001.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
257	SPWRKF0001	\N	\N	Shearing Knife ( Bantalan Chimei )	Shearing Knife 308 x 44 x 8 SKD 11 (Bantalan)	CHIMEI	D42	1103305.50	0	3	9	8	/static/uploads/SPWRKF0001.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
258	SPKLCO0001	\N	\N	Solenoid Coil	Solenoid Coil MSFG-24DC/42AC (p/n 803459) Festo	CHIMEI	D43	256824.00	8	1	6	1	/static/uploads/SPKLCO0001.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
259	SPJCKF0002	\N	\N	Horizontal Knife (pisau chimei )	Horizontal Knife  312 x 30 x 5 (Pisau)	CHIMEI	D46	2228526.64	4	2	7	5	/static/uploads/SPJCKF0002.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
260	SPWRRO0001	\N	\N	Roller	Roller dia. 20.2 x 335.5  Rubber Lining	CHIMEI	D47	1219000.00	1	1	2	2	/static/uploads/SPWRRO0001.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
261	SPMEPG0001	\N	\N	Plug Socket	Plug Socket MSSD-F Festo	CHIMEI	D48	40858.00	3	1	6	1	/static/uploads/SPMEPG0001.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
262	SPJCNZ0003	\N	\N	Glue Gun Nordson	Glue Gun Nordson	PAMPAC	D5	18500000.00	1	1	2	2	\N	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
263	SPJCNZ0005	\N	\N	Cordset Gun	Cordset Gun H200 (p/n 274785)	PAMPAC	D5	2176163.00	3	1	2	0	/static/uploads/SPJCNZ0005.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
264	SPPMEN0001	\N	\N	Encoder	Encoder 360PBR KUNLER 85000.835A SBELEENCD0039	PAMPAC	D5	8662901.04	2	1	2	1	\N	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
265	SPFBIS0002	\N	\N	Inflatable Seal CIP	Inflatable Seal CIP G281 S7F Dm=1720mm Silicone Transparent p/n 128637	FBD	DD1	0.00	0	1	2	1	\N	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
266	SPFBIS0003	\N	\N	Inflatable Seal CIP	Inflatable Seal Filter Ring TR 1 Valve Size 8 Lo=3086mm Mk3 Silicone 55-60 Shore Transparent p/n 129253	FBD	DD1	0.00	0	1	2	0	/static/uploads/SPFBIS0003.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
267	SPFBIS0001	\N	\N	Inflatable Seal CIP	Inflatable Seal CIP G281 S8P Dm=1420mm Silicone Transparent p/n 128638	FBD	DD2	0.00	0	1	2	1	/static/uploads/SPFBIS0001.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
268	SPIBSE0005	\N	\N	Seal	DN 250 Butterfly Valve Vibroflow Compensator, 75 Shore "A" Hardness Moulded Seal, White, EPDM FDA	GEA	DD2	0.00	0	1	2	2	\N	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
269	SPSEDS0001	\N	\N	Compression Seal	Compression Seal for Butterfly Discharge Valve, 50 Shore "A" Hardness, White 250NB, EPDM(FDA)	GEA	DD4	1773800.00	21	3	8	3	/static/uploads/SPSEDS0001.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
270	SPROOB0001	\N	\N	Bushing	Oil Free Bushing LFB-1615 BMB	ROBOT	E11	0.00	0	1	2	1	\N	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
271	SPRORE0001	\N	\N	Rotary Encoder	Rotary Encoder E58H12-102406-L-5 Autonics	ROBOT	E111	2190000.00	1	0	1	3	/static/uploads/SPRORE0001.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
272	SPROOR0001	\N	\N	O-Ring Joint	O-Ring Joint #1 1653181 Epson	ROBOT	E112	0.00	0	1	2	0	\N	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
273	SPROOR0002	\N	\N	O-Ring Joint	O-Ring Joint #1 1213267 Epson	ROBOT	E113	25500.00	1	1	2	0	/static/uploads/SPROOR0002.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
274	SPROOR0003	\N	\N	O-Ring Joint	O-Ring Joint #1 1520371 Epson	ROBOT	E114	14700.00	1	1	2	0	/static/uploads/SPROOR0003.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
275	SPROOR0004	\N	\N	O-Ring Joint	O-Ring Joint #2 1653819 Epson	ROBOT	E115	175600.00	1	1	2	0	/static/uploads/SPROOR0004.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
276	SPROOR0005	\N	\N	O-Ring Joint	O-Ring Joint #2 1213266 Epson	ROBOT	E116	51.00	1	1	2	0	/static/uploads/SPROOR0005.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
277	SPROTB0001	\N	\N	Timing Belt Joint	Timing Belt Joint #3 (Z Belt) 1554773 Epson	ROBOT	E117	0.00	0	1	2	0	\N	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
278	SPROTB0002	\N	\N	Timing Belt Joint	Timing Belt Joint #4 (U1 Belt) 1554775 Epson	ROBOT	E118	0.00	0	1	2	0	\N	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
279	SPROTB0003	\N	\N	Timing Belt Joint	Timing Belt Joint #4 (U2 Belt) 1554777 Epson	ROBOT	E119	0.00	0	1	2	0	\N	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
280	SPROOB0002	\N	\N	Bushing	Oil Free Bushing LFB-1415 BMB	ROBOT	E12	31700.00	2	1	2	0	/static/uploads/SPROOB0002.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
281	SPROOB0003	\N	\N	Bushing	Oil Free Bushing LFB-0606 BMB	ROBOT	E13	22325.00	3	1	4	1	/static/uploads/SPROOB0003.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
282	SPROCS0001	\N	\N	Coupling SUNGIL	Coupling SOH-43C-12*12 SUNGIL	ROBOT	E14	693000.00	8	1	11	12	/static/uploads/SPROCS0001.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
283	SPROCS0002	\N	\N	Coupling SUNGIL	Coupling SOH32C-12*12 SUNGIL	ROBOT	E15	500000.00	14	0	15	21	/static/uploads/SPROCS0002.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
284	SPROPG0001	\N	\N	Planetary Gearbox	Planetary Gearbox DH042, i : 20 VARITRON	ROBOT	E16	7100000.00	2	0	1	4	/static/uploads/SPROPG0001.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
285	SPROML0001	\N	\N	Mecha Lock	Mecha Lock MLR17 MISUMI	ROBOT	E17	828573.33	1	0	2	1	/static/uploads/SPROML0001.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
286	SPROML0002	\N	\N	Mecha Lock	Mecha Lock MLR12 MISUMI	ROBOT	E18	755731.67	3	1	2	0	/static/uploads/SPROML0002.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
287	SPROLB0001	\N	\N	Linear Bushing	Linear Bushing LM 8UU THK	ROBOT	E19	68220.00	10	1	6	1	/static/uploads/SPROLB0001.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
288	SPROLB0002	\N	\N	Linear Bushing	Linear Bushing LMF12 UU BMB	ROBOT	E21	275600.00	4	1	5	1	/static/uploads/SPROLB0002.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
289	SPROSE0003	\N	\N	Foto Electric Sensor	Foto Electric Sensor PZ-G51N Keyence	ROBOT	E211	0.00	0	1	2	1	\N	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
290	SPROSE0004	\N	\N	Sensor Laser	Sensor Laser LR-ZB250AN Keyence	ROBOT	E212	4500000.00	0	1	2	1	/static/uploads/SPROSE0004.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
291	SPROSE0005	\N	\N	Pressure Sensor + Bracket	Pressure Sensor + Bracket AP-C33W Keyence	ROBOT	E213	0.00	0	1	2	1	\N	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
292	SPROLS0002	\N	\N	Limit Switch	Limit Switch WLCA12-N Omron	ROBOT	E214	368480.00	4	0	5	2	/static/uploads/SPROLS0002.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
293	SPROFJ0001	\N	\N	Floating Joint	Floating Joint JA20-8-125 SMC	ROBOT	E215	420000.00	4	1	6	1	/static/uploads/SPROFJ0001.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
294	SPROPS0003	\N	\N	Power Supply	Power Supply S8FS-G05012CD Omron	ROBOT	E216	0.00	0	1	2	1	\N	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
295	SPROPS0004	\N	\N	Power Supply	Power Supply F8FS-G05005CD Omron	ROBOT	E217	596900.00	4	0	4	1	/static/uploads/SPROPS0004.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
296	SPROLS0001	\N	\N	Limit Switch	Limit Switch D4MC-2000 Omron	ROBOT	E218	0.00	0	1	2	1	/static/uploads/SPROLS0001.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
297	SPROSE0006	\N	\N	Proximity Sensor	Proximity Sensor EV-118M Keyence	ROBOT	E219	0.00	0	1	2	1	\N	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
298	SPMEBE0456	\N	\N	Bearing	Bearing 61908 RS	ROBOT	E22	0.00	0	1	2	0	\N	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
299	SPROBE0002	\N	\N	Liniear Slide Bearing	Liniear Slide Bearing RJ4JP-01-08 Drylin IGUS	ROBOT	E23	12000.00	98	16	116	32	/static/uploads/SPROBE0002.jpg	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
300	SPRODP0001	\N	\N	Dowel Pin	Dowel Pin DPTM-6-20 ACME	ROBOT	E25	0.00	0	1	2	0	\N	2026-06-23 07:09:21.915979	2026-06-23 07:09:21.915979	\N	\N
301	SPROCH0002	\N	\N	Chain Connector	Chain Connector RS 60 NKN	ROBOT	E26	95681.82	9	1	6	1	/static/uploads/SPROCH0002.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
302	SPROCH0004	\N	\N	Chain Connector	Chain Connector (SUS) RS40 NKN	ROBOT	E28	87500.00	2	1	5	5	\N	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
303	SPROTS0001	\N	\N	Tension Spring	Tension Spring AUY8-70 MISUMI	ROBOT	E29	32486.43	15	0	5	5	/static/uploads/SPROTS0001.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
304	SPROAG0001	\N	\N	Air Gripper	Air Gripper MHZ2-32D-M9BW SMC	ROBOT	E31	7000000.00	1	2	8	40	\N	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
305	SPROPC0003	\N	\N	Pneumatic Cylinder	Pneumatic Cylinder CDQ2A32-50DMZ-M9BW SMC	ROBOT	E310	850000.00	2	1	3	1	/static/uploads/SPROPC0003.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
306	SPROPC0001	\N	\N	Pneumatic Cylinder	Pneumatic Cylinder MGPM50-100Z-M9BW SMC	ROBOT	E311	3000000.00	2	1	3	1	/static/uploads/SPROPC0001.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
307	SPROEB0001	\N	\N	Electromagnetic Brake	Electromagnetic Brake 1750573 Epson	ROBOT	E312	840300.00	1	1	2	0	\N	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
308	SPROBR0001	\N	\N	Brake Release Switch	Brake Release Switch 2117817 Epson	ROBOT	E313	0.00	0	1	2	0	\N	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
309	SPROAG0002	\N	\N	Air Gripper	Air Gripper MHL2-16D2Z-M9BW SMC	ROBOT	E32	5180000.00	0	1	2	2	\N	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
310	SPROSB0001	\N	\N	Selenoid Brake with ferrite core	Selenoid Brake with ferrite core 1620666 Epson	ROBOT	E33	0.00	0	1	2	0	\N	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
311	SPROPC0005	\N	\N	Pneumatic Cylinder	Pneumatic Cylinder CDQ2B20-15M-M9BW SMC	ROBOT	E34	660000.00	6	1	6	6	/static/uploads/SPROPC0005.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
312	SPROVP0003	\N	\N	Vacum Pad	Vacum Pad ZP20BS SMC	ROBOT	E35	160000.00	72	13	43	236	/static/uploads/SPROVP0003.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
313	SPROPC0004	\N	\N	Pneumatic Cylinder	Pneumatic Cylinder CDM2L25-100-M9BW SMC	ROBOT	E36	900000.00	2	1	2	0	\N	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
314	SPROPC0002	\N	\N	Pneumatic Cylinder	Pneumatic Cylinder CDG1BN25-125-M9BW SMC	ROBOT	E37	0.00	0	1	2	4	/static/uploads/SPROPC0002.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
315	SPROPS0002	\N	\N	Power Supply	Power Supply S8FS-G10024CD Omron	ROBOT	E38	0.00	0	1	2	1	\N	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
317	SPROVE0001	\N	\N	Vacuum Ejector	Vacuum Ejector ZH10BS-06-06 SMC (PIAB)	ROBOT	E41	400000.00	17	1	21	42	/static/uploads/SPROVE0001.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
318	SPROSV0001	\N	\N	Selenoid Valve	Selenoid Valve SY5120-5DZD-C6 SMC	ROBOT	E42	975000.00	3	1	2	0	/static/uploads/SPROSV0001.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
319	SPROSV0002	\N	\N	Selenoid Valve	Selenoid Valve SY5220-5DZD-C6 SMC	ROBOT	E43	1370000.00	9	1	6	1	/static/uploads/SPROSV0002.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
320	SPROSV0003	\N	\N	Selenoid Valve	Selenoid Valve SY5320-5DZD-C6 SMC	ROBOT	E44	0.00	0	1	2	2	/static/uploads/SPROSV0003.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
321	SPROSV0004	\N	\N	Selenoid Valve	Selenoid Valve VT307-5G1-02 SMC	ROBOT	E45	660000.00	6	0	5	4	/static/uploads/SPROSV0004.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
322	SPROSV0005	\N	\N	Selenoid Valve	Selenoid Valve VXD230AA SMC	ROBOT	E46	580000.00	2	0	5	1	/static/uploads/SPROSV0005.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
323	SPROAR0001	\N	\N	Precision Regulator	Precision Regulator IR1010-01BG-A SMC	ROBOT	E47	1160000.00	3	1	2	0	/static/uploads/SPROAR0001.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
324	SPROAR0002	\N	\N	Air Regulator	Air Regulator AW30-03-BG-A SMC	ROBOT	E48	900000.00	1	1	2	0	/static/uploads/SPROAR0002.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
325	SPROSR0001	\N	\N	Snap Ring	Snap Ring H47 LOKAL	ROBOT	E49	0.00	0	1	2	0	\N	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
326	SPROCH0001	\N	\N	Chain	Chain RS60 NKN	ROBOT	E51	0.00	0	1	2	0	\N	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
327	SPROCH0003	\N	\N	Chain (SUS)	Chain (SUS) RS40 NKN	ROBOT	E52	400000.00	2	0	2	2	\N	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
328	SPROPL0001	\N	\N	PLC CPU	PLC CPU KV-7500 Keyence	ROBOT	E53	0.00	0	1	2	1	/static/uploads/SPROPL0001.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
329	SPROPS0001	\N	\N	Power Supply PLC	Power Supply PLC KV-PU1 Keyence	ROBOT	E54	1710000.00	1	1	2	0	/static/uploads/SPROPS0001.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
330	SPROPM0001	\N	\N	Positioning Module	Positioning Module KV-XH04ML Keyence	ROBOT	E55	13200000.00	1	1	2	0	/static/uploads/SPROPM0001.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
331	SPROIM0001	\N	\N	Input Module	Input Module KV-B16XC Keyence	ROBOT	E56	1960000.00	2	1	2	0	/static/uploads/SPROIM0001.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
332	SPROOM0001	\N	\N	Output Module	Output Module KV-B16RC Keyence	ROBOT	E57	3200000.00	2	0	5	17	/static/uploads/SPROOM0001.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
333	SPROSE0001	\N	\N	Proximity Sensor	Proximity Sensor EV-108M Keyence / Proximity Sensor Type IME08-02BDSZY2K SICK	ROBOT	E58	585000.00	8	5	10	10	/static/uploads/SPROSE0001.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
334	SPROSE0002	\N	\N	Foto Electric Sensor	Foto Electric Sensor PR-MB30N1 Keyence	ROBOT	E59	820000.00	3	2	6	1	\N	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
335	SPSVOG0003	\N	\N	GREASE	FGL-2 Food Grade Grease p/n L0232-098 Lubriplate (Biru)	ROBOT	EE1	430000.00	11	0	10	14	/static/uploads/SPSVOG0003.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
336	SPUFOG0001	\N	\N	GREASE	Food Grade Grease Purity FG2 Synthetic Petro Canada (Merah)	ROBOT	EE1	371982.67	11	0	10	13	/static/uploads/SPUFOG0001.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
337	SPCMOG0033	\N	\N	Paralig 91 Spray	Paralig 91 Spray	GENERAL	EE2	1349337.14	21	2	14	74	/static/uploads/SPCMOG0033.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
338	SPCMOG0034	\N	\N	Kluberoil 4UH1-1500 Spray	Kluberoil 4UH1-1500 Spray	GENERAL	EE2	1010000.00	8	2	14	42	/static/uploads/SPCMOG0034.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
339	SPROSD0001	\N	\N	Servo Drive SV2	Servo Drive SV2-010L2 (100 Watt) Keyence	ROBOT	F1	12280000.00	0	1	2	1	/static/uploads/SPROSD0001.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
340	SPROSD0002	\N	\N	Servo Drive SV2	Servo Drive SV2-075L2 (750 Watt) Keyence	ROBOT	F1	16988000.00	2	1	2	1	\N	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
341	SPROSD0004	\N	\N	Servo Drive	Servo Drive SV2 040L2 400 Watt Keyence	ROBOT	F1	11350000.00	3	1	2	0	/static/uploads/SPROSD0004.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
342	SPROSM0001	\N	\N	Servo Motor SV2	Servo Motor SV2-M010AS (100 Watt) Keyence	ROBOT	F1	7147000.00	3	1	2	3	/static/uploads/SPROSM0001.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
343	SPROSM0002	\N	\N	Servo Motor SV2	Servo Motor SV2-M075AS (750 Watt) Keyence	ROBOT	F1	10950000.00	2	1	2	0	/static/uploads/SPROSM0002.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
344	SPROSM0003	\N	\N	Servo Motor	Servo Motor SV2 M040AS 400 Watt Keyence	ROBOT	F1	9089000.00	2	1	2	1	/static/uploads/SPROSM0003.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
345	SPROFB0001	\N	\N	Flange Bearing	Iglidur J3 Flange Bearing	ROBOT	F21	17000.00	2	60	260	289	/static/uploads/SPROFB0001.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
346	SPROPP0002	\N	\N	Ass'y Gripper	Ass'y Gripper M76-1467-006.0 PTT	ROBOT	F211	0.00	0	1	2	0	\N	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
347	SPROCO0001	\N	\N	DRIVE SHAFT, 90+	DRIVE SHAFT, 90+ DRIVE/RETURN p/n 3842547653, Rexroth	ROBOT	F212	2800000.00	1	1	2	0	/static/uploads/SPROCO0001.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
348	SPROGR0001	\N	\N	Grease Robot	Grease Robot Epson	ROBOT	F22	0.00	4	1	6	6	/static/uploads/SPROGR0001.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
349	SPROBA0001	\N	\N	Battery Robot	Battery Robot Epson	ROBOT	F23	300000.00	26	5	20	20	/static/uploads/SPROBA0001.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
350	SPROSH0001	\N	\N	Shaft ulir	Shaft ulir gripper robot, M4 x 150 SS304	ROBOT	F24	150000.00	17	19	69	113	/static/uploads/SPROSH0001.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
351	SPROBE0003	\N	\N	Bearing	Sleeve Bearing P210SM-1618-15 Igus	ROBOT	F25	220500.00	10	1	2	0	/static/uploads/SPROBE0003.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
352	SPROBE0004	\N	\N	Bearing	Linear Bearing RJZM-01-08 Igus	ROBOT	F26	349125.00	9	1	6	3	/static/uploads/SPROBE0004.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
353	SPROPT0001	\N	\N	Plat Penekan	Plat penekan sachet robot, 71x40x1.2 mm SS304	ROBOT	F27	250000.00	15	1	31	35	/static/uploads/SPROPT0001.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
354	SPROBE0001	\N	\N	Pillow Block (IGUS)	Pillow Block FJUMT-02-10 Drylin IGUS	ROBOT	F28	650000.00	7	1	13	23	/static/uploads/SPROBE0001.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
355	SPROBT0001	\N	\N	Battery LITHIUM PLC	Battery LITHIUM PLC CR17335SE-R 3V merk SANYO	ROBOT	F29	753067.23	9	1	13	12	/static/uploads/SPROBT0001.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
356	SPROIM0002	\N	\N	Input unit	Input unit KV-NC16EXE Keyence	ROBOT	F31	1200000.00	2	1	2	0	/static/uploads/SPROIM0002.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
357	SPTVHA0002	\N	\N	Heating Catridge	Heating Catridge 220V 550W dia. 9.9x300mm	STV	F311	0.00	2	1	2	0	/static/uploads/SPTVHA0002.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
358	SPTVHA0003	\N	\N	Heating Catridge	Heating Catridge 220V 300W dia. 9.9x200mm	STV	F312	551000.00	2	1	2	0	/static/uploads/SPTVHA0003.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
359	SPTVHA0001	\N	\N	Heating Catridge	Heating Catridge 220V 550W dia. 9.9x350mm	STV	F313	828500.00	4	1	2	0	/static/uploads/SPTVHA0001.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
360	SPROIM0003	\N	\N	Output unit	Output unit KV-NC16ETE Keyence	ROBOT	F32	1200000.00	2	1	2	0	/static/uploads/SPROIM0003.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
361	SPROBS0001	\N	\N	Ball Screw Spline	Ball Screw Spline 1593211 Epson	ROBOT	F41	30710900.00	1	1	2	0	/static/uploads/SPROBS0001.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
362	SPROPO0001	\N	\N	Pocket conveyor robot	Pocket conveyor robot tipe A Rubber PU (SAYAP DUA)	ROBOT	F42	450000.00	18	15	55	89	/static/uploads/SPROPO0001.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
363	SPROPO0002	\N	\N	Pocket conveyor robot	Pocket conveyor robot tipe B Rubber PU	ROBOT	F43	465000.00	9	12	52	22	/static/uploads/SPROPO0002.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
364	SPROPO0003	\N	\N	Pocket conveyor robot	Pocket conveyor robot tipe C Rubber PU	ROBOT	F44	473214.29	13	12	52	18	/static/uploads/SPROPO0003.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
365	SPROBS0002	\N	\N	Ball Screw Spline	Ball Screw Spline 1792117 Epson	ROBOT	F5	31992880.00	1	1	2	0	/static/uploads/SPROBS0002.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
366	SPROCO0002	\N	\N	Sliding Rail Rexroth	Sliding Rail, VFPLUS ADVANCED L30M p/n 3842549727 Rexroth	ROBOT	F5	0.00	0	1	2	0	\N	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
367	SPROEA0001	\N	\N	Electric Actuator	Electric Actuator LEY32DS3A-100BMF-SAA21 SMC	ROBOT	F5	0.00	0	1	2	1	/static/uploads/SPROEA0001.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
368	SPROSS0001	\N	\N	Sachet Scrapper	Sachet Scrapper M76-1467-003.14 PTT	ROBOT	F5	0.00	0	1	2	0	\N	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
369	SPROPP0001	\N	\N	Pocket Plate	Pocket Plate M76-1467-004.1 PTT	ROBOT	F51	320000.00	1	1	2	0	\N	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
370	SPROVL0001	\N	\N	Vacuum Link Plate	Vacuum Link Plate #End M76-1467-001.10P PTT	ROBOT	F52	4000000.00	1	1	2	0	\N	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
371	SPROSP0002	\N	\N	Sachet Pusher	Sachet Pusher #1 M76-1467-003.34 PTT	ROBOT	F53	7500000.00	1	1	2	0	/static/uploads/SPROSP0002.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
372	SPROSP0001	\N	\N	Sachet Press Bracket	Sachet Press Bracket M76-1467-003.33 PTT	ROBOT	F54	0.00	0	1	2	1	\N	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
373	SPROVL0002	\N	\N	Vacuum Link Plate	Vacuum Link Plate #Middle M76-1467-001.10Q PTT	ROBOT	F55	6500000.00	1	1	2	0	/static/uploads/SPROVL0002.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
374	SPROVH0001	\N	\N	Vacuum Holder	Vacuum Holder M76-1467-001.10O PTT	ROBOT	F56	8500000.00	1	1	2	0	/static/uploads/SPROVH0001.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
375	SPROSP0003	\N	\N	Sachet Pusher	Sachet Pusher #2 M76-1467-003.35 PTT	ROBOT	F57	5500000.00	1	1	2	0	/static/uploads/SPROSP0003.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
376	SPGEAP0072	\N	\N	SK Outlet Filter	SK Outlet Filter, Standard, SK 3240.200 Rittal	GEA	G11	0.00	0	1	2	0	\N	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
377	SPGEAP0082	\N	\N	MCB	Miniature Circuit-Breaker 3P 6A C curve 15 kA A9F84306 Schneider	GEA	G111	685000.00	1	1	2	0	/static/uploads/SPGEAP0082.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
378	SPGEAP0083	\N	\N	RCCB	Residual Current Circuit Breaker 4P 40A 30mA Type AC A9R71440S Schneider	GEA	G112	0.00	0	1	2	0	\N	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
379	SPGEAP0084	\N	\N	Motor Circuit Breaker	Motor Circuit Breaker - Thermal-Magnetic - 9 … 14 A GV2P16 Schneider	GEA	G113	825000.00	1	1	2	0	/static/uploads/SPGEAP0084.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
380	SPGEAP0085	\N	\N	Motor Circuit Breaker	Motor Circuit Breaker - Thermal-Magnetic - 60 … 100 A GV7RE100 Schneider	GEA	G114	9500000.00	0	1	2	0	/static/uploads/SPGEAP0085.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
381	SPGEAP0086	\N	\N	Motor Circuit Breaker	Motor Circuit Breaker - Thermal-Magnetic - 132 … 220 A GV7RE220 Schneider	GEA	G115	7640000.00	1	1	2	0	/static/uploads/SPGEAP0086.png	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
382	SPGEAP0087	\N	\N	Motor Circuit Breaker	Motor Circuit Breaker - Thermal-Magnetic - 6 … 10 A GV2P14 Schneider	GEA	G116	788500.00	1	1	2	0	/static/uploads/SPGEAP0087.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
383	SPGEAP0088	\N	\N	Motor Circuit Breaker	Motor Circuit Breaker - Thermal-Magnetic - 13 … 18 A GV2P20 Schneider	GEA	G117	825500.00	1	1	2	0	/static/uploads/SPGEAP0088.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
384	SPGEAP0089	\N	\N	Motor Circuit Breaker	Motor Circuit Breaker - Thermal-Magnetic - 30 … 40 A GV3P40 Schneider	GEA	G118	1718000.00	1	1	2	0	/static/uploads/SPGEAP0089.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
385	SPGEAP0090	\N	\N	MCB	Miniature Circuit Breaker - 2P - 16A - C curve A9F74216 Schneider	GEA	G119	302000.00	1	1	2	0	/static/uploads/SPGEAP0090.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
386	SPGEAP0074	\N	\N	MCB	Miniature Circuit-Breaker 2P 6A B curve 15 kA A9F83206 Schneider	GEA	G12	0.00	0	1	2	0	\N	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
387	SPGEAP0091	\N	\N	MCB	Miniature Circuit Breaker - 2P - 10A - C curve A9F74210 Schneider	GEA	G120	245000.00	1	1	2	0	/static/uploads/SPGEAP0091.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
388	SPGEAP0092	\N	\N	MCB	Miniature Circuit Breaker - 2P - 6A - C curve A9F74206 Schneider	GEA	G121	248000.00	1	1	2	0	/static/uploads/SPGEAP0092.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
389	SPGEAP0093	\N	\N	MCB	Miniature Circuit Breaker - 1P - 4A - C curve A9F74104 Schneider	GEA	G122	107000.00	1	1	2	0	/static/uploads/SPGEAP0093.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
390	SPGEAP0094	\N	\N	MCB	Miniature Circuit Breaker - 2P - 4A - C curve A9F74204 Schneider	GEA	G123	294000.00	1	1	2	0	/static/uploads/SPGEAP0094.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
391	SPGEAP0073	\N	\N	Circuit Breaker Compact	Circuit Breaker Compact NSX630N - Micrologic 2.3 - 630 A - 3 poles 3d LV432893 Schneider	GEA	G124	0.00	0	1	2	0	\N	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
392	SPGEAP0096	\N	\N	Metering Current Transformer	Motor circuit breaker - thermal-magnetic - 4…6.3 A GV2P10 Schneider	GEA	G125	692000.00	1	1	2	0	/static/uploads/SPGEAP0096.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
393	SPGEAP0065	\N	\N	Contactor	Contactor LC1K0610M7 Schneider	GEA	G126	0.00	0	1	2	0	\N	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
394	SPGEAP0066	\N	\N	Relay	Relay DRI424730LT 230VAC Weidmuller	GEA	G127	185000.00	5	1	2	0	/static/uploads/SPGEAP0066.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
395	SPGEAP0067	\N	\N	Relay	Relay DRI424024LTD 24VDC Weidmuller	GEA	G128	150000.00	5	1	2	0	/static/uploads/SPGEAP0067.jpg	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
396	SPGEAP0068	\N	\N	Emergency stop push-button	Emergency stop push-button, switching off XB4BS8445 Schneider	GEA	G129	0.00	0	1	2	0	\N	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
397	SPGEAP0075	\N	\N	RCCB	Residual Current Circuit Breaker 2P 40A 30mA Type AC A9R71240S Schneider	GEA	G13	0.00	0	1	2	0	\N	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
398	SPGEAP0076	\N	\N	MCB	Miniature Circuit-Breaker 2P 16A C curve 15 kA A9F84216 Schneider	GEA	G14	0.00	0	1	2	0	\N	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
399	SPGEAP0077	\N	\N	MCB	Miniature Circuit-Breaker 2P 10A C curve 15 kA A9F84210 Schneider	GEA	G15	0.00	0	1	2	0	\N	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
400	SPGEAP0078	\N	\N	MCB	Miniature Circuit-Breaker 1P 20A C curve 15 kA A9F84120 Schneider	GEA	G16	0.00	0	1	2	0	\N	2026-06-23 07:09:21.922453	2026-06-23 07:09:21.922453	\N	\N
401	SPGEAP0079	\N	\N	Motor Circuit Breaker	Motor Circuit Breaker - Thermal-Magnetic - 2.5… 4 A GV2P08 Schneider	GEA	G17	700000.00	1	1	2	0	/static/uploads/SPGEAP0079.jpg	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
402	SPGEAP0080	\N	\N	Motor Circuit Breaker	Motor Circuit Breaker - Thermal-Magnetic - 1 … 1.6 A GV2P06 Schneider	GEA	G18	700000.00	1	1	2	0	/static/uploads/SPGEAP0080.jpg	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
403	SPGEAP0081	\N	\N	Motor Circuit Breaker	Motor Circuit Breaker - Thermal-Magnetic - 0.63 … 1 A GV2P05 Schneider	GEA	G19	700000.00	1	1	2	0	/static/uploads/SPGEAP0081.jpg	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
404	SPGEAP0070	\N	\N	SIMATIC	SIMATIC 6ES7155-6AA01-0BN0 Siemens	GEA	G2	0.00	0	1	2	0	\N	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
405	SPGEAP0097	\N	\N	Power Supply	SITOP PSU100S 20 A Stabilized Power Supply, input: 120/230 V AC, output: 24 V DC/20 A, 6EP1336-2BA10 Siemens	GEA	G2	0.00	0	1	2	0	\N	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
406	SPGEAP0098	\N	\N	SIMATIC	SIMATIC PM 1507 24 V/3 A Stabilized Power Supply, 6EP1332-4BA00 Siemens	GEA	G2	0.00	0	1	2	0	\N	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
407	SPGEAP0100	\N	\N	SIMATIC	SIMATIC ET 200SP, Digital Output Module, DQ 16x 24V DC/0,5A Standard, 6ES7132-6BH01-0BA0, Siemens	GEA	G2	0.00	0	1	2	0	\N	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
408	SPGEAP0101	\N	\N	SIMATIC	SIMATIC ET 200SP, Analog Input Module, AI 4XI 2-/4-Wire Standard, 6ES7134-6GD01-0BA1, Siemens	GEA	G2	0.00	0	1	2	0	\N	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
409	SPGEAP0102	\N	\N	SIMATIC	SIMATIC ET 200SP, Analog Output Module, AQ 4XU/I Standard, BU Type A0, A1, 6ES7135-6HD00-0BA1, Siemens	GEA	G2	0.00	0	1	2	0	\N	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
410	SPGEAP0103	\N	\N	SINAMICS	SINAMICS S120 Control Unit CU310-2 PN with Profinet Interface without compactflash card, 6SL3040-1LA01-0AA0, Siemens	GEA	G2	0.00	0	1	2	0	\N	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
411	SPGEAP0104	\N	\N	Com. Module	Com. Module, Profinet, 4470A, Eilersen	GEA	G2	16490200.00	6	1	2	1	/static/uploads/SPGEAP0104.jpg	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
412	SPGEAP0099	\N	\N	SIMATIC	SIMATIC ET 200SP, Digital Input Module, DI 16x 24V DC Standard, 6ES7131-6BH01-0BA0, Siemens	GEA	G21	0.00	0	1	2	0	\N	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
413	SPGEAP0105	\N	\N	AT PCM	AT PCM TT 275 FM 3Ph NEUTRAL Class II Surge Arresters	GEA	G31	0.00	0	1	2	0	\N	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
414	SPGEAP0069	\N	\N	Pushbutton	Red Flush complete illuminated pushbutton XB5AW34B5 Schneider	GEA	G311	0.00	0	1	2	0	\N	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
415	SPGEAP0071	\N	\N	SK Fan and Filter	SK Fan and Filter unit TopTherm SK 3241.100 Rittal	GEA	G311	0.00	0	1	2	0	\N	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
416	SPFBTH0004	\N	\N	Thermocouple	Thermocouple PT100 dia6x185mm SUS316 ILF RTD 0-150Celcius, kabel 3m	FBD	G313	0.00	0	1	2	0	\N	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
417	SPGEAP0106	\N	\N	Relay	Definite Time Earth Fault Relay, 230 VAC, 50/60 Hz, P9620, Broyce Control	GEA	G32	0.00	0	1	2	0	\N	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
418	SPGEAP0107	\N	\N	Multifunction Meter	Multifunction Meter, Nemo 96 HDLe, Schneider	GEA	G33	0.00	0	1	2	0	\N	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
419	SPGEAP0108	\N	\N	MX Shunt Trip Release	MX Shunt Trip Release, Compact NSX, 220-240 VAC 50/60 Hz, LV429387, Schneider	GEA	G34	855000.00	1	1	2	0	/static/uploads/SPGEAP0108.jpg	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
420	SPGEAP0109	\N	\N	Pilot Light Clear LED	Compact Pilot Light Clear LED 230V AC, CL2-523C, ABB	GEA	G35	62000.00	4	1	2	0	/static/uploads/SPGEAP0109.jpg	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
421	SPGEAP0110	\N	\N	Door-Operated Switch	Door-Operated Switch, SZ 4127.010, Rittal	GEA	G36	0.00	0	1	2	0	\N	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
422	SPGEAP0111	\N	\N	Protection Current Transformer	Protection Current Transformer, 600/5, CL5P10 15VA	GEA	G37	0.00	0	1	2	0	\N	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
423	SPGEAP0112	\N	\N	Metering Current Transformer	Metering Current Transformer, 600/5, CL3 5VA	GEA	G38	0.00	0	1	2	0	\N	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
424	SPFBTH0003	\N	\N	Thermocouple	Thermocouple PT100 dia6x325mm SUS316 ILF RTD 0-150Celcius, kabel 3m	GEA	G39	0.00	0	1	2	0	\N	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
425	SPIBSE0003	\N	\N	Seal Silicone	Seal Vibroflow IBC Dia. 265/279x309x52mm Silicone Clear	IBC	G4	0.00	0	1	2	0	\N	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
426	SPIBSE0004	\N	\N	Seal Ferrule	Seal Silicone Cap Dia. 178/197x217x32mm Silicone Clear	IBC	G4	0.00	0	1	2	0	\N	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
427	SPDCFI0003	\N	\N	Filter Dust Colector	Filter Dust Colector F/W 495 x 1000mm Mat. PE 500 AS	DUST COLECTOR	G5	0.00	0	1	2	0	\N	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
428	SPIVME0002	\N	\N	Membrane Iris Valve	Membrane Iris Valve Dia.510/510/490 mm Polypropylene	IRISH VALVE	G5	4750000.00	2	1	3	1	/static/uploads/SPIVME0002.jpg	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
429	SPTSFI0001	\N	\N	Filter Tipping Station	Filter Tipping Station F/W 495 x 720mm Mat. PE 500 AS	IRISH VALVE	G5	0.00	0	1	2	0	\N	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
430	SPFBSE0011	\N	\N	Seal Ferrule	Seal Ferrule 1" Dia. 23x42/51x1.5/5mm Silicone Clear	FBD	G51	55000.00	12	1	6	4	/static/uploads/SPFBSE0011.jpg	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
431	SPFBSE0012	\N	\N	Seal Ferrule	Seal Ferrule 2" Dia. 48x53/63x1.5/5mm Silicone Clear	FBD	G52	60000.00	7	1	11	7	/static/uploads/SPFBSE0012.jpg	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
432	SPFBSE0013	\N	\N	Seal Ferrule	Seal Ferrule jalur Pipa CIP FBD Dia. 15x21.5x4.5mm Silicone Clear	FBD	G53	50000.00	6	1	6	2	/static/uploads/SPFBSE0013.jpg	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
433	SPBLBE0004	\N	\N	DEEP GROOVE BEARING WITH SEALS	DEEP GROOVE BEARING WITH SEALS part no. 141626 DP3000 Machine	BLENDER	H11	0.00	0	0	0	0	\N	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
434	SPBLRC0001	\N	\N	ROTARY COUPLING	ROTARY COUPLING part no. 157712	BLENDER	H111	0.00	0	0	0	0	\N	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
435	SPBLRE0001	\N	\N	ROTARY ENCODER	LENZE INCREMENTAL ROTARY ENCODER part no. 163384 DP3000 Machine	BLENDER	H112	0.00	0	0	0	0	\N	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
436	SPBRJS0001	\N	\N	PRECISION SCREW	INKOMA PRECISION SCREW JACK 6:1 part no. 173215 DP3000 Machine	BLENDER	H113	0.00	0	0	0	0	\N	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
437	SPBRBE0001	\N	\N	Bearing	Bearing 6310 C3 SKF	BLENDER	H114	305750.00	4	1	2	0	/static/uploads/SPBRBE0001.jpg	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
438	SPBRBE0002	\N	\N	Bearing	Bearing 6209 C3 SKF	BLENDER	H115	148250.00	4	1	2	0	/static/uploads/SPBRBE0002.jpg	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
439	SPBRJS0002	\N	\N	Nut	Nut Spiral Bronze for DP3000	BLENDER	H116	0.00	0	0	0	0	\N	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
440	SPBLBU0001	\N	\N	TAPER LOCK BUSH	TAPER LOCK BUSH - 3020X48DIA part no. 157700 DP3000 Machine	BLENDER	H12	0.00	0	0	0	0	\N	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
441	SPBLBU0002	\N	\N	TAPER LOCK BUSH	TAPER LOCK BUSH - 3525X60DIA part no. 157701 DP3000 Machine	BLENDER	H13	0.00	0	0	0	0	\N	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
442	SPBLBU0003	\N	\N	TAPER LOCK BUSH	TAPERLOCK BUSH part no. 141630 DP3000 Machine	BLENDER	H14	0.00	0	0	0	0	\N	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
443	SPBLBU0004	\N	\N	TAPER LOCK BUSH	TAPERLOCK BUSH SUIT 25 SHAFT part no. 141634 DP3000 Machine	BLENDER	H15	0.00	0	0	0	0	\N	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
444	SPBLDS0001	\N	\N	DISC SPRING	DISC SPRING - dia 80MM X 41MM HOLE X 5MM THK - DIN2093 part no. 1341308 DP3000 Machine	BLENDER	H16	0.00	0	0	0	0	\N	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
445	SPBLDS0002	\N	\N	DISC SPRING	BELLEVILLE DISC SPRING part no. 1341307 DP3000 Machine	BLENDER	H17	0.00	0	0	0	0	\N	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
446	SPBLPC0001	\N	\N	CONNECTOR	M12 90DEG 4 PIN CONNECTOR 5M LEAD part no. 137812 DP3000 Machine	BLENDER	H18	0.00	0	0	0	0	\N	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
447	SPBLPS0001	\N	\N	PROXIMITY SENSOR	PROXIMITY SENSOR FLUSH M12X1 part no. 163389 DP3000 Machine	BLENDER	H19	0.00	0	0	0	0	\N	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
448	SPFBFI0002	\N	\N	Filter DR	Filter DR Size 4 533 PET p/n 205118	FBD	H22	0.00	0	1	2	0	\N	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
449	SPFBIS0004	\N	\N	Inflatable Seal CIP	Inflatable Seal Filter Ring DR 1 Valve Mk3 Size 4 Lo=1901mm Silicone 55-60 Shore Transparent p/n 126241	FBD	H26	0.00	0	1	2	0	\N	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
450	SPFBIS0005	\N	\N	Inflatable Seal CIP	Inflatable Seal CIP G281 S4F Dm=924mm Silicone Transparent p/n 128633	FBD	H27	0.00	0	1	2	0	\N	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
451	SPFBIS0006	\N	\N	Inflatable Seal CIP	Inflatable Seal CIP G281 S4P Dm=594mm Silicone Transparent p/n 128634	FBD	H28	0.00	0	1	2	0	\N	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
452	SPBRBE0003	\N	\N	Bearing	Bearing 6315 C4 SKF	FBD	H29	1284458.33	0	1	2	3	/static/uploads/SPBRBE0003.jpg	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
453	SPCGOF0003	\N	\N	OIL FILTER GRASSO	OIL FILTER GRASSO V p/n 0711027	CHILLER GEA	H31	0.00	0	1	2	0	\N	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
454	SPCGOF0004	\N	\N	SUCTION OIL FILTER	SUCTION OIL FILTER V-SERIES p/n  0715228	CHILLER GEA	H32	0.00	0	1	2	0	\N	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
455	SPCGOR0003	\N	\N	O-RING SET GRASSO	BASIC SET O-RING SET GRASSO V300-V600 2081017.01	CHILLER GEA	H33	0.00	0	1	2	0	\N	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
456	SPCGVR0001	\N	\N	DISCHARGE VALVE RING & SPRING SET	DISCHARGE VALVE RING & SPRING SET V300-V p/n 2081240	CHILLER GEA	H35	0.00	0	1	2	0	\N	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
457	SPCGVR0002	\N	\N	SUCTION VALVE RING & SPRING SET	SUCTION VALVE RING & SPRING SET V300-V60 p/n 2081250	CHILLER GEA	H36	0.00	0	1	2	0	\N	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
458	SPLBBU0001	\N	\N	Kit Bushing	Kit Bushing Lump Breaker HR Crusher RR 250	LUMBREAKER GEA	H37	7796655.00	2	1	2	0	/static/uploads/SPLBBU0001.jpg	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
459	SPLBOR0001	\N	\N	O-Ring	N° 1 kit with N°  2 O-Rings Lump Breaker HR Crusher RR 250	LUMBREAKER GEA	H38	726570.00	3	1	2	0	/static/uploads/SPLBOR0001.jpg	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
460	SPLBOR0002	\N	\N	O-Ring	N° 1 kit with N°  2 O-Rings for centering Lump Breaker HR Crusher RR 250	LUMBREAKER GEA	H39	1900260.00	3	1	2	0	/static/uploads/SPLBOR0002.jpg	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
461	SPLFLS0001	\N	\N	Limit Switch	Limit Switch SZL-VL-A Honeywell	LIFTER GEA	H41	0.00	0	1	2	0	\N	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
462	SPLFPS0001	\N	\N	Proximity Sensor	Proximity Sensor IIS227 IFM	LIFTER GEA	H42	0.00	0	1	2	0	\N	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
463	SPRMSS0001	\N	\N	Safety Switch with Separate Actuator	Safety Switch with Separate Actuator AZ 17-02ZK schmersal	ROTARY GEA	H43	772876.00	1	1	2	0	/static/uploads/SPRMSS0001.jpg	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
464	SPTMLU0001	\N	\N	Lubricating Element	Lubricating Element RB72/90 S3547, TMF-3_V2	TRACKMOTION GEA	H45	538384.00	0	1	2	1	/static/uploads/SPTMLU0001.jpg	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
465	SPTMLU0002	\N	\N	Lubricating Pinion	Lubricating pinion complete prelubricated with oil, TMF-3_V2	TRACKMOTION GEA	H46	3230304.00	1	1	2	0	\N	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
466	SPTMSR0001	\N	\N	Supporting Roller	Supporting Roller PWTR30 72.2RS, TMF-3_V2	TRACKMOTION GEA	H47	1430563.00	0	1	2	0	/static/uploads/SPTMSR0001.jpg	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
467	SPTMWI0001	\N	\N	Wiper Unit	Wiper Unit RB72/90 S3547 Schele, TMF-3_V2	TRACKMOTION GEA	H48	1076768.00	2	1	2	0	/static/uploads/SPTMWI0001.jpg	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
468	SPTMWI0002	\N	\N	Wiper Unit	Wiper Unit RB72/90 S3547, TMF-3_V2	TRACKMOTION GEA	H49	484545.00	7	1	6	1	/static/uploads/SPTMWI0002.jpg	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
469	SPBLBE0001	\N	\N	HTD BELT	HTD BELT - 150TX14MX85 WIDE part no. 157696 DP3000 Machine	BLENDER	H5	1150000.00	1	1	2	0	/static/uploads/SPBLBE0001.jpg	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
470	SPBLBE0002	\N	\N	HTD PULLEY BELT	HTD PULLEY BELT 8M-2000 PITC part no. 141635 DP3000 Machine	BLENDER	H5	312000.00	1	1	2	0	/static/uploads/SPBLBE0002.jpg	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
471	SPBLBE0003	\N	\N	HTD PULLEY BELT	HTD PULLEY BELT 8M-1800 PITC part no. 141636 DP3000 Machine	BLENDER	H5	284000.00	1	1	2	0	/static/uploads/SPBLBE0003.jpg	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
472	SPBLSE0002	\N	\N	Seal Bung	Seal Blender Bung Dia. 20x81x40.5mm Nitrile	BLENDER	H5	550000.00	7	1	8	9	/static/uploads/SPBLSE0002.jpg	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
473	SPBRAM0001	\N	\N	AIR MOTOR	AIR MOTOR 3/4INCH PORTS FLG MTG part no. 141250 DP3000 Machine	BLENDER	H5	0.00	0	0	0	0	\N	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
474	SPHOAR0001	\N	\N	ArmourTex FM4G Polyester	ArmourTex FM4G Polyester, ePTFE membrance ID 156mm x 600mm L	HOOPER	H5	1881071.00	2	1	2	0	/static/uploads/SPHOAR0001.jpg	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
475	SPHOFL0001	\N	\N	Fluidizer with Metal Detectable Disk	Fluidizer with Metal Detectable Disk 4305MD Solimar, 4" 1/2" NPT, 1/4" NPT Air Line Conn.	HOOPER	H5	0.00	0	1	2	1	/static/uploads/SPHOFL0001.jpg	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
476	SPIVND0001	\N	\N	Nylon Diaphragm	7oz Nylon Diaphragm  E18 Iris Valve	IRISH VALVE	H5	0.00	0	1	2	0	\N	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
477	SPLFCY0001	\N	\N	Cylinder	Cylinder CDM2E20-75TZ-NW-M9PVSAPC SMC	LIFTER GEA	H5	0.00	0	1	2	0	\N	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
478	SPMEBL0228	\N	\N	V-Belt	V-Belt SPC3150 Mitsubishi	FBD	H5	941000.00	5	1	2	0	/static/uploads/SPMEBL0228.jpg	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
479	SPTMLC0001	\N	\N	Load Cell BL	Load Cell BL 750kg 0.025 Eillersen	TRACKMOTION GEA	H5	14810850.00	3	1	2	0	/static/uploads/SPTMLC0001.jpg	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
480	SPGEAP0049	\N	\N	Inductive sensor	Inductive sensor IFT203 IFM	GEA	J11	869000.00	2	1	2	0	/static/uploads/SPGEAP0049.jpg	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
481	SPMEFT0134	\N	\N	Proximity Sensor	Proximity Sensor SME-8M-DS-24V-K-5,0-OE Festo	GEA	J111	398846.20	2	1	2	0	/static/uploads/SPMEFT0134.jpg	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
482	SPGEAP0050	\N	\N	Level sensor	Level sensor LMT102 IFM	GEA	J12	3882000.00	4	1	2	0	/static/uploads/SPGEAP0050.jpg	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
483	SPGEAP0051	\N	\N	Pressure sensor	Pressure sensor PI2799 IFM	GEA	J13	0.00	0	1	2	0	\N	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
484	SPGEAP0055	\N	\N	Flow sensor	Flow sensor SI5000 C/W E40096 IFM	GEA	J14	0.00	0	1	2	1	\N	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
485	SPGEAP0056	\N	\N	Position sensor	Position sensor MR09202 IFM	GEA	J15	447000.00	0	1	2	0	/static/uploads/SPGEAP0056.jpg	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
486	SPGEAP0058	\N	\N	Pressure sensor	Pressure sensor PN7594 IFM	GEA	J16	6323000.00	1	1	2	0	/static/uploads/SPGEAP0058.jpg	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
487	SPGEAP0059	\N	\N	Flow sensor	Flow sensor SA5000 IFM	GEA	J17	0.00	0	1	2	1	\N	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
488	SPGEAP0060	\N	\N	Inductive sensor	Inductive sensor IN5327 IFM	GEA	J18	2143000.00	2	1	2	0	/static/uploads/SPGEAP0060.jpg	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
489	SPMEFT0133	\N	\N	Proximity Sensor	Proximity Sensor SME-8-K-24-S6 Festo	GEA	J19	507469.00	2	1	2	0	/static/uploads/SPMEFT0133.jpg	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
490	SPGEAP0053	\N	\N	Wirable socket	Wirable socket E11252 IFM	GEA	J21	279520.00	4	1	5	3	\N	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
491	SPGEAP0061	\N	\N	Socket plug	Socket plug E11505 male IFM	GEA	J22	338666.67	4	1	5	3	/static/uploads/SPGEAP0061.jpg	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
492	SPGEAP0062	\N	\N	Socket plug	socket plug E11509 female IFM	GEA	J23	304000.00	0	1	2	3	/static/uploads/SPGEAP0062.jpg	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
493	SPGEAP0063	\N	\N	Wireable socket	Wireable socket EVF566 female IFM	GEA	J24	471000.00	4	1	5	3	\N	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
494	SPMEFT0121	\N	\N	Socket connector	Socket connector MSSD EB Festo	GEA	J25	32030.00	3	1	2	0	/static/uploads/SPMEFT0121.jpg	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
495	SPGEAP0052	\N	\N	Magnet safety	Magnet safety MN203S IFM	GEA	J26	977000.00	0	1	2	0	/static/uploads/SPGEAP0052.jpg	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
496	SPGEAP0057	\N	\N	SK Outlet Filter	RFID ANT513 IFM	GEA	J27	4318000.00	0	1	2	0	/static/uploads/SPGEAP0057.jpg	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
497	SPGEAP0064	\N	\N	Wireable plug	Wireable plug EVF568 male IFM	GEA	J28	471000.00	2	1	3	2	/static/uploads/SPGEAP0064.jpg	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
498	SPIVGE0001	\N	\N	Gear Iris Valve	Gear Iris Valve Z 14	GEA	J29	750000.00	2	1	2	0	/static/uploads/SPIVGE0001.jpg	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
499	SPIVGE0002	\N	\N	Gear Iris Valve	Gear Iris Valve Z 100	GEA	J31	1200000.00	2	1	2	0	/static/uploads/SPIVGE0002.jpg	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
500	SPMEFT0122	\N	\N	Solenoid Valve	Solenoid Valve VSNC-F-B52-D-G14-F8-1B2 Festo	GEA	J32	1665107.00	1	1	2	0	/static/uploads/SPMEFT0122.jpg	2026-06-23 07:09:21.927966	2026-06-23 07:09:21.927966	\N	\N
501	SPMEFT0125	\N	\N	Solenoid Valve	Solenoid valve VUVS L25 B52 D G14 F8 1B2 Festo	GEA	J33	1385881.00	2	1	2	0	/static/uploads/SPMEFT0125.jpg	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
502	SPMEFT0128	\N	\N	Solenoid Valve	Solenoid Valve VUVS-L25-M32C-AD-G14-F8-1B2 Festo	GEA	J34	935486.00	1	1	2	0	/static/uploads/SPMEFT0128.jpg	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
503	SPMEFT0129	\N	\N	Solenoid Valve	Solenoid Valve VUVS-L25-M32C-MD-G14-F8-1C1 Festo	GEA	J35	935486.00	1	1	2	0	/static/uploads/SPMEFT0129.jpg	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
504	SPMEFT0135	\N	\N	Solenoid Valve	Air Solenoid Valve VZWD-L-M22C-M-G14-50-V-1P4-5-R1 Festo	GEA	J36	1696160.00	1	1	2	0	/static/uploads/SPMEFT0135.jpg	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
505	SPMEFT0136	\N	\N	Solenoid Valve	Solenoid Valve VZWF-B-L-M22C-G12-135-1P4-10-R1 Festo	GEA	J37	2781409.00	0	1	2	0	/static/uploads/SPMEFT0136.jpg	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
506	SPMEFT0138	\N	\N	Solenoid Valve	Solenoid Valve HEE-1/2-D-MIDI-24 Festo	GEA	J38	1811579.00	2	1	2	0	/static/uploads/SPMEFT0138.jpg	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
507	SPMEFT0139	\N	\N	Solenoid Valve	Solenoid Valve HEE-1/4-D-MINI-24 Festo	GEA	J39	1519129.00	2	1	2	0	/static/uploads/SPMEFT0139.jpg	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
508	SPMEFT0123	\N	\N	Flow control valve	Exhaust air flow control valve GRE-1/4 Festo	GEA	J41	224172.00	3	1	2	0	/static/uploads/SPMEFT0123.jpg	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
509	SPMEFT0131	\N	\N	Illuminating Seal	Illuminating Seal MEB-LD-12-24-DC Festo	GEA	J43	194881.00	6	1	2	0	/static/uploads/SPMEFT0131.jpg	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
510	SPMEFT0132	\N	\N	Check Valve	Check Valve HGL-1/4-B Festo	GEA	J44	654220.00	0	1	2	0	/static/uploads/SPMEFT0132.jpg	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
511	SPGEFC0001	\N	\N	Flexible Connector	Flexible Connector FSC 550 FF 200 200 SS304 PU-UF1 Polyether Urethane Jacob Flange DN200 L 200mm	GEA	J45	0.00	0	1	2	0	\N	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
512	SPGEAP0054	\N	\N	Temperature	Temperature TD2251 IFM	GEA	J48	4232000.00	0	1	2	0	/static/uploads/SPGEAP0054.jpg	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
513	SPGEFC0002	\N	\N	Flexible Connector	Flexible Connector FSC SPIRAL FF 200 550 PU06IN Jacob	GEA	J49	0.00	0	1	2	0	\N	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
514	SPMEFT0126	\N	\N	Cylinder	Cylinder DFSP 32 20 PS PA Festo	GEA	J51	1431973.00	0	1	2	0	/static/uploads/SPMEFT0126.jpg	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
515	SPMEFT0137	\N	\N	Cylinder	Cylinder DSBC-100-150-PPVA-N3 Festo	GEA	J52	4530774.33	4	1	5	1	/static/uploads/SPMEFT0137.jpg	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
516	SPMEFT0120	\N	\N	Cylinder	Cylinder DFM-63-200-B-PPV-A-GF Festo	GEA	J53	12365955.00	0	1	2	1	/static/uploads/SPMEFT0120.jpg	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
517	SPECCC0022	\N	\N	Contactor	Contactor LC1-D09-M7 (220VAC)  Telemecanique	GENERAL ELECTRIC	K111	0.00	0	1	2	0	\N	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
518	SPECCC0081	\N	\N	Contactor	Contactor LC1-D09-Q7 (380 VAC) Telemecanique	GENERAL ELECTRIC	K112	0.00	0	1	2	1	\N	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
519	SPECCC0059	\N	\N	Contactor	Contactor LC1-D25Q7 (380VAC) Telemecanique	GENERAL ELECTRIC	K13	0.00	0	1	2	1	\N	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
520	SPMERL0063	\N	\N	Solid State Relay ( SSR )	Solid State Relay G3NA-240B (input 5 - 24VDC)  Omron	RVS	K21	1250000.00	4	1	2	0	/static/uploads/SPMERL0063.jpg	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
521	SPECCC0041	\N	\N	Overload	Overload LRD-08 (2,5-4A)  Telemecanique	GENERAL ELECTRIC	K210	0.00	0	1	2	0	\N	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
522	SPECCC0062	\N	\N	Overload	Overload LRD-16 (9-13A) Telemecanique	GENERAL ELECTRIC	K211	0.00	0	1	2	2	\N	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
523	SPECCC0090	\N	\N	Overload	Overload LRD-22 (16-24A)  Telemecanique	GENERAL ELECTRIC	K212	0.00	0	1	2	0	\N	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
524	SPECCC0053	\N	\N	Overload	Overload LRD-07 (1,6-2,5A)  Telemecanique	GENERAL ELECTRIC	K213	340000.00	1	1	2	0	/static/uploads/SPECCC0053.jpg	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
525	SPECCC0051	\N	\N	Overload	Overload LRD-14 (7-10A)  Telemecanique	GENERAL ELECTRIC	K214	340000.00	2	1	2	0	/static/uploads/SPECCC0051.jpg	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
526	SPECCC0093	\N	\N	Overload	Overload LRD-3357 (37-50A) Telemecanique	GENERAL ELECTRIC	K215	1045000.00	2	1	2	0	/static/uploads/SPECCC0093.jpg	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
527	SPECCC0052	\N	\N	Overload	Overload LRD-06 (1,0-1,7A)  Telemecanique	GENERAL ELECTRIC	K216	340000.00	1	1	2	0	/static/uploads/SPECCC0052.jpg	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
528	SPECCO0002	\N	\N	Contactor Coil	Contactor Coil LXD-1Q7 Telemecanique	GENERAL ELECTRIC	K22	0.00	0	1	2	0	\N	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
529	SPECCO0001	\N	\N	Contactor Coil	Contactor Coil LXD-1M7 Telemecanique	GENERAL ELECTRIC	K23	0.00	0	1	2	0	\N	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
530	SPECCC0026	\N	\N	Overload	Contactor LR2-K0308 (1,8-2,6A)  Telemecanique	GENERAL ELECTRIC	K28	400000.00	1	1	2	1	/static/uploads/SPECCC0026.jpg	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
531	SPECCC0010	\N	\N	Overload	Overload LRD-10 (4-6A)  Telemecanique	GENERAL ELECTRIC	K29	340000.00	0	1	2	0	/static/uploads/SPECCC0010.jpg	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
532	SPECCC0064	\N	\N	Direct Online Starter	Direct O/L Starter LE1-M35-Q7-16 (380VAC 8-11,5A)	GENERAL ELECTRIC	K31	0.00	0	1	2	0	\N	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
533	SPECCC0068	\N	\N	Direct Online Starter	Direct Online Starter LE1-M35-Q7-12 (3.7 - 5.5A)	GENERAL ELECTRIC	K32	0.00	0	1	2	0	\N	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
534	SPECCC0048	\N	\N	Direct Online Starter	Direct O/L Starter LE1-M35-Q7-06 (380VAC 0,8-1,2A)	GENERAL ELECTRIC	K33	0.00	0	1	2	0	\N	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
535	SPECCC0049	\N	\N	Direct Online Starter	Direct O/L Starter LE1-M35-Q7-08 (380VAC 1,8-2,6A)	GENERAL ELECTRIC	K34	0.00	0	1	2	0	\N	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
536	SPECCC0016	\N	\N	Direct online starter	Direct Online Starter LE1-M35-M708 220VAC 1.8-2.6A	GENERAL ELECTRIC	K35	0.00	0	1	2	0	\N	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
822	SPMEBE0407	\N	\N	Bearing	Bearing 6008 2RS	PAMPAC	S126	0.00	0	10	15	4	/static/uploads/SPMEBE0407.jpg	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
537	SPECCC0070	\N	\N	Contactor	Contactor LC1D80M7 (220 VAC) Telemecanique	GENERAL ELECTRIC	K46	1968000.00	2	1	2	0	/static/uploads/SPECCC0070.jpg	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
538	SPECCC0005	\N	\N	Contactor	Contactor LC1K0910M7 (220 VAC) Telemecanique	AC	K47	250000.00	2	0	0	0	/static/uploads/SPECCC0005.jpg	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
539	SPECCC0006	\N	\N	Contactor	Contactor LC1K1210M7 Telemecanique	AC	K49	290000.00	2	0	0	0	/static/uploads/SPECCC0006.jpg	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
540	SPECCC0008	\N	\N	Contactor/Circuit breaker	Contactor GV-ME20 (13-18A) Telemecanique	GENERAL ELECTRIC	K55	660000.00	2	1	2	0	/static/uploads/SPECCC0008.jpg	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
541	SPECMC0035	\N	\N	MCB	MCB 1 phase 10 A Siemens	GENERAL ELECTRIC	L11	0.00	0	1	2	1	\N	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
542	SPECMC0004	\N	\N	MCB	MCB NC45A C6 6A 1ph  Merlin Gerin	GENERAL ELECTRIC	L111	83000.00	4	1	2	6	/static/uploads/SPECMC0004.jpg	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
543	SPECMC0002	\N	\N	MCB	MCB NC45A C20 20A 3ph  Merlin Gerin	GENERAL ELECTRIC	L112	300000.00	1	1	2	1	/static/uploads/SPECMC0002.jpg	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
544	SPECMC0008	\N	\N	MCB	MCB NC45N C16 16A 1ph  Merlin Gerin	GENERAL ELECTRIC	L113	119750.00	2	1	2	2	/static/uploads/SPECMC0008.jpg	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
545	SPECMC0006	\N	\N	MCB	MCB NC45A C20 20A 1ph  Merlin Gerin	GENERAL ELECTRIC	L114	65000.00	1	1	2	1	/static/uploads/SPECMC0006.jpg	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
546	SPECMC0001	\N	\N	MCB	MCB NC45N C25 25A 1ph  Merlin Gerin	GENERAL ELECTRIC	L12	0.00	0	1	2	1	\N	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
547	SPECMC0022	\N	\N	MCB	MCB NC45N C2 2A 1ph  Merlin Gerin	GENERAL ELECTRIC	L13	0.00	0	1	2	0	\N	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
548	SPECMC0009	\N	\N	MCB	MCB NC45A C10 10A 3ph  Merlin Gerin	GENERAL ELECTRIC	L14	272142.86	2	1	2	0	/static/uploads/SPECMC0009.jpg	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
549	SPECMC0011	\N	\N	MCB	MCB NC45A C40 40A 3ph  Merlin Gerin	GENERAL ELECTRIC	L15	371666.67	1	1	2	0	/static/uploads/SPECMC0011.jpg	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
550	SPECMC0007	\N	\N	MCB	MCB NC45N C25 25A 3ph  Merlin Gerin	GENERAL ELECTRIC	L16	518000.00	3	1	2	1	/static/uploads/SPECMC0007.jpg	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
551	SPACMC0001	\N	\N	MCB	MCB NC45N C6 6A 3ph Merlin Gerin	GENERAL ELECTRIC	L17	420000.00	4	1	2	0	/static/uploads/SPACMC0001.jpg	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
552	SPECMC0003	\N	\N	MCB	MCB NC45N C16 16A 3ph  Merlin Gerin	GENERAL ELECTRIC	L18	0.00	0	1	2	2	/static/uploads/SPECMC0003.jpg	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
553	SPJNMC0002	\N	\N	MCB	MCCB EZC100F 75A	GENERAL ELECTRIC	L19	620000.00	2	1	2	0	/static/uploads/SPJNMC0002.jpg	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
554	SPMEMT0012	\N	\N	Hour Meter	Hour Meter TH149 (Source 240VAC) Panasonic	GENERAL ELECTRIC	L21	0.00	0	1	2	0	\N	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
555	SPMERL0014	\N	\N	Relay	Relay MY4 24VDC  Omron	GENERAL ELECTRIC	L210	0.00	0	1	2	0	\N	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
556	SPMERL0012	\N	\N	Relay	Relay MY4 220 / 240VAC  Omron	GENERAL ELECTRIC	L211	68000.00	6	1	6	2	/static/uploads/SPMERL0012.jpg	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
557	SPECSK0005	\N	\N	Socket Rellay	Socket Relay PYF-08A-N 7A  Omron	GENERAL ELECTRIC	L212	34021.05	12	0	10	17	/static/uploads/SPECSK0005.jpg	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
558	SPECSK0006	\N	\N	Socket Rellay	Socket Relay PYF-14A-N  Omron	GENERAL ELECTRIC	L213	0.00	12	1	2	0	\N	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
559	SPECSK0007	\N	\N	Socket Rellay	Socket Relay PTF-14A-E  Omron	GENERAL ELECTRIC	L214	0.00	0	1	2	0	\N	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
560	SPECSK0003	\N	\N	Socket timer	Socket Timer P2CF11-E (11 pin)  Omron	GENERAL ELECTRIC	L215	0.00	0	1	2	0	\N	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
561	SPECSK0004	\N	\N	Socket timer	Socket Timer P2CF08-E (8 pin)  Omron	GENERAL ELECTRIC	L216	155342.39	19	1	6	1	/static/uploads/SPECSK0004.jpg	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
562	SPMERL0008	\N	\N	Relay	Relay MKS2P-1 220VAC 8 pin  Omron	GENERAL ELECTRIC	L22	150000.00	9	1	6	4	/static/uploads/SPMERL0008.jpg	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
563	SPECSW0028	\N	\N	Emergency Stop Button	Emergency Stop Button XB5 AS42  Telemecanique	CHIMEI	L221	128412.70	2	1	6	1	/static/uploads/SPECSW0028.jpg	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
564	SPECSW0118	\N	\N	Limit Switch	Limit Switch Z-15GW-B 5A 125VAC-250VAC  Mulon	CHIMEI	L222	0.00	0	1	2	0	\N	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
565	SPECSW0135	\N	\N	Selector Switch	Selector Switch XB4 BD53  Telemecanique	RVS	L223	0.00	0	1	2	1	/static/uploads/SPECSW0135.jpg	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
566	SPMERL0020	\N	\N	Relay	Relay MK2P-I 24VDC 8 pin  Omron	CHIMEI	L224	68248.00	8	1	6	1	/static/uploads/SPMERL0020.jpg	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
567	SPMERL0071	\N	\N	Relay	Relay LY2 220VAC coil 220VAC  Omron	GENERAL ELECTRIC	L227	0.00	0	1	2	0	\N	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
568	SPMERL0001	\N	\N	Relay	Relay RXM 2AB2P7 Telemecanique	AC	L228	0.00	0	0	0	0	\N	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
569	SPMERL0048	\N	\N	Relay	Relay MK3PN5-I 220VAC - 11 pin (p/n 54907895)  Omron	GENERAL ELECTRIC	L229	0.00	0	1	2	0	\N	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
570	SPMERL0013	\N	\N	Relay	Relay MK3P-I 24-28VDC - 11 pin 250V	GENERAL ELECTRIC	L23	0.00	0	1	2	2	/static/uploads/SPMERL0013.jpg	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
571	SPMERL0011	\N	\N	Relay	Relay LY4 200 / 220VAC 10A 240VAC  Omron	GENERAL ELECTRIC	L24	0.00	0	1	2	0	\N	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
572	SPMERL0018	\N	\N	Relay	Relay LY4 24VDC  Omron	GENERAL ELECTRIC	L25	0.00	0	1	2	0	\N	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
573	SPMERL0054	\N	\N	Relay	Relay REL-MR-24VDC/21  Phoenix	RVS	L26	160000.00	9	1	6	2	/static/uploads/SPMERL0054.jpg	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
574	SPMERL0015	\N	\N	Relay	Relay MY2 24VDC  Omron	GENERAL ELECTRIC	L28	38000.00	10	1	6	2	\N	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
575	SPMERL0010	\N	\N	Relay	Relay MY2 220 / 240VAC  Omron	GENERAL ELECTRIC	L29	35720.00	8	0	12	14	\N	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
576	SPECTR0001	\N	\N	Krustin Kabel	Krustin  93 x 14 x 11	GENERAL ELECTRIC	L31	0.00	0	1	2	0	\N	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
577	SPECSW0082	\N	\N	Limit switch	Limit Switch W1-NJW15106 10A 125-250VAC  Omron	GENERAL ELECTRIC	L310	0.00	0	1	2	0	\N	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
578	SPECSW0003	\N	\N	Push Botton	Pushbutton XB7-EA31 Green  Telemecanique	GENERAL ELECTRIC	L311	0.00	0	1	2	0	\N	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
579	SPECSW0002	\N	\N	Push Botton	Pushbutton XB7-EA42 Red  Telemecanique	GENERAL ELECTRIC	L312	0.00	0	1	2	0	\N	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
580	SPECSW0004	\N	\N	Push Botton	Pushbutton ZB4 BA31 / XB4 BA31 Telemecanique	GENERAL ELECTRIC	L313	0.00	0	1	2	0	\N	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
581	SPECSW0022	\N	\N	Emergency Stop Button	Emergency Stop Button XB7 ES52	CHIMEI	L314	0.00	0	1	2	0	\N	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
582	SPECSW0009	\N	\N	Switch	Switch CR-253 250VAC 5A  Hanyoung	GENERAL ELECTRIC	L315	0.00	0	1	2	0	\N	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
583	SPECSW0013	\N	\N	Micro Toggle Switch	Micro Toggle Switch 10A 250VAC	GENERAL ELECTRIC	L316	0.00	0	1	2	0	\N	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
584	SPWRCP0001	\N	\N	Capasitor	Capasitor 6 mF 450VAC	GENERAL ELECTRIC	L317	35000.00	5	1	6	1	/static/uploads/SPWRCP0001.jpg	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
585	SPECCP0007	\N	\N	Capasitor	Capasitor 25 mF 450 VAC	GENERAL ELECTRIC	L318	75000.00	4	1	2	0	/static/uploads/SPECCP0007.jpg	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
586	SPACCP0001	\N	\N	Capasitor	Capasitor 30mF 400VAC	GENERAL ELECTRIC	L319	70000.00	1	1	2	0	/static/uploads/SPACCP0001.jpg	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
587	SPECTR0004	\N	\N	Krustin Kabel	Krustin 6	GENERAL ELECTRIC	L32	9500.00	1	1	6	3	/static/uploads/SPECTR0004.jpg	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
588	SPDHCP0003	\N	\N	Capasitor	Capasitor 2 mF 400 VAC	GENERAL ELECTRIC	L320	20000.00	1	1	2	0	/static/uploads/SPDHCP0003.jpg	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
589	SPDHCP0002	\N	\N	Capasitor	Capasitor 4 mF 400 VAC	GENERAL ELECTRIC	L321	20000.00	5	1	2	0	/static/uploads/SPDHCP0002.jpg	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
590	SPECTR0005	\N	\N	Krustin Kabel	Krustin 10	CONSUMABLE	L33	13500.00	5	1	6	1	/static/uploads/SPECTR0005.jpg	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
591	SPECTR0006	\N	\N	Krustin Kabel	Krustin 12	GENERAL ELECTRIC	L34	18500.00	1	1	2	1	/static/uploads/SPECTR0006.jpg	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
592	SPSVTR0002	\N	\N	Krustin Keramik	Krustin Keramik 2 terminal 40 x 23 x 17	RVS	L36	0.00	0	1	2	0	\N	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
593	SPJNTR0001	\N	\N	Terminal Block	Terminal Block 60A 4P	GENERAL ELECTRIC	L37	0.00	0	1	2	0	\N	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
594	SPECSW0016	\N	\N	Limit Switch	Limit Switch TM 1307 15A 250VAC	GENERAL ELECTRIC	L38	0.00	0	1	2	0	\N	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
595	SPECSW0072	\N	\N	Limit Switch	Limit Switch TM 1704 15A 250VAC  Tend	CHIMEI	L39	75000.00	11	1	2	0	/static/uploads/SPECSW0072.jpg	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
596	SPECTI0001	\N	\N	Timer	Timer H3CR-A8 200-240V  Omron	GENERAL ELECTRIC	L41	280000.00	3	1	2	0	/static/uploads/SPECTI0001.jpg	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
597	SPECLM0037	\N	\N	Pilot Lamp	Pilot Lamp XB7-EC 03 MP Hijau	GENERAL ELECTRIC	L410	0.00	0	1	2	0	\N	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
598	SPECLM0038	\N	\N	Pilot Lamp	Pilot Lamp XB7-EC 04 Merah	GENERAL ELECTRIC	L410	0.00	0	1	2	0	\N	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
599	SPECLM0039	\N	\N	Pilot Lamp	Pilot Lamp XB7-EC 05 MP Kuning	GENERAL ELECTRIC	L410	0.00	0	1	2	0	\N	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
600	SPECSW0014	\N	\N	Selector Switch	Selector Switch 2B2-BE 101 10A 240V / 3A 240V	GENERAL ELECTRIC	L411	0.00	0	1	2	0	\N	2026-06-23 07:09:21.934414	2026-06-23 07:09:21.934414	\N	\N
601	SPMERL0009	\N	\N	Relay	Relay LY2 220VAC 10A coil 24VDC  Omron	GENERAL ELECTRIC	L413	0.00	0	1	2	0	\N	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
602	SPECSW0139	\N	\N	Limit Switch	Limit Switch Z-15GW21-B 15A 125-480 Vac Omron	GENERAL ELECTRIC	L414	0.00	0	1	2	0	\N	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
603	SPECTR0008	\N	\N	Terminal Block	Terminal Block 25A 12P	GENERAL ELECTRIC	L42	35000.00	2	1	2	0	/static/uploads/SPECTR0008.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
604	SPECTI0008	\N	\N	Timer	Timer H5CX-L8 100-240 VAC  Omron	GENERAL ELECTRIC	L43	2100000.00	2	1	3	1	/static/uploads/SPECTI0008.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
605	SPJNTC0007	\N	\N	Thermocontrol	Thermocontrol E5CN-R2MT-500 240VAC  Omron	GENERAL ELECTRIC	L45	0.00	0	1	2	0	\N	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
606	SPACMD0003	\N	\N	Phase Failure Device	PHASE FAILURE DEVICE KMK 01 KRK	GENERAL ELECTRIC	L48	0.00	0	1	2	0	\N	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
607	SPECSW0063	\N	\N	Emergency Stop Button	Emergency Stop Button CR-257R 5A 250 VAC Hanyoung	GENERAL ELECTRIC	L51	0.00	0	1	2	0	\N	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
608	SPJNTC0009	\N	\N	Thermocontrol	Thermocontrol E5CZ-R2T Omron	GENERAL ELECTRIC	L52	0.00	0	1	2	0	\N	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
609	SPECCP0015	\N	\N	Capasitor	Capasitor 35uF 220VAC/450VAC	GENERAL ELECTRIC	L54	76500.00	4	1	2	0	/static/uploads/SPECCP0015.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
610	SPECCP0016	\N	\N	Capasitor	Capasitor 45uF 220VAC/450VAC	GENERAL ELECTRIC	L55	95000.00	3	1	4	1	/static/uploads/SPECCP0016.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
611	SPECSW0027	\N	\N	Contact Block	Contact Block ZBE-101 Telemecanique	GENERAL ELECTRIC	L58	30500.00	10	1	2	0	/static/uploads/SPECSW0027.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
612	SPECSW0042	\N	\N	Contact Block	Contact Block ZBE-102 NC Telemechanique	GENERAL ELECTRIC	L59	30500.00	8	1	2	0	/static/uploads/SPECSW0042.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
613	SPROCY0001	\N	\N	Electric Actuator	Electric Actuator LEY32DS3A-150BMF-SAA21 SMC	ROBOT	LL1	0.00	0	1	2	0	\N	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
614	SPROCY0002	\N	\N	Electric Actuator	Electric Actuator LEY32DS3A-150BMF SMC	ROBOT	LL1	15300000.00	2	0	1	3	/static/uploads/SPROCY0002.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
615	SPROCO0004	\N	\N	CONVEYOR SECTION VFPLUS 90 AL	CONVEYOR SECTION VFPLUS 90 AL, L=1000MM p/n 3842996023 Rexroth	ROBOT	LL2	0.00	0	1	2	0	\N	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
616	SPCMOG0029	\N	\N	WD-40 Spray	WD-40 Spray 226 gram	SPAREPART MESIN	LL3	82000.06	29	4	14	118	/static/uploads/SPCMOG0029.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
617	SPCHTM0024	\N	\N	Contact Cleaner	Contact Cleaner Drathon 150PS	GENERAL ELECTRIC	LL4	745187.11	14	2	12	109	/static/uploads/SPCHTM0024.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
618	SPCHTM0011	\N	\N	Cleaner & Degreaser	Cleaner & Degreaser Drathon 140	GENERAL	LL4	283500.00	14	8	23	228	/static/uploads/SPCHTM0011.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
619	SPCHTM0010	\N	\N	WD-40  Liter	Kaleng 4Liter	GENERAL	LL5	625000.00	1	1	3	2	/static/uploads/SPCHTM0010.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
620	SPCHTM0004	\N	\N	Belt Dresser	Belt Dresser Drathon 250	GENERAL	LL5	316805.50	6	0	0	0	/static/uploads/SPCHTM0004.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
621	SPECST0001	\N	\N	Steker 1 ph	Steker 1ph 1 ph 10-16 637 2 pin  Uticon , Clipsal	GENERAL ELECTRIC	M11	9916.67	18	1	21	55	/static/uploads/SPECST0001.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
622	SPECST0005	\N	\N	Steker AC	Steker AC 13A AC 250V  MK	GENERAL ELECTRIC	M12	30000.00	1	1	6	1	/static/uploads/SPECST0005.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
623	SPECST0002	\N	\N	Steker 3ph	Steker 3ph 16A 5pin 380v  Legrand	GENERAL ELECTRIC	M14	0.00	0	1	2	4	/static/uploads/SPECST0002.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
624	SPECST0018	\N	\N	Stop Kontak	Stop kontak 4 Lubang Uticon	GENERAL ELECTRIC	M16	20794.12	6	4	9	19	\N	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
625	SPECSW0007	\N	\N	Saklar	Saklar Double 10A 250VAC  MK (PANASONIC)	GENERAL ELECTRIC	M21	0.00	0	1	2	2	/static/uploads/SPECSW0007.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
626	SPECSW0005	\N	\N	Saklar	Saklar Tunggal 10A 250VAC  MK (PANASONIC)	GENERAL ELECTRIC	M22	0.00	0	1	2	2	/static/uploads/SPECSW0005.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
627	SPECST0009	\N	\N	Stopkontak	Stopkontak AC 13A 250 V  MK	GENERAL ELECTRIC	M24	70000.00	1	0	0	0	/static/uploads/SPECST0009.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
628	SPECST0007	\N	\N	Stopkontak 3ph	Stopkontak 3ph P17 16A 5pin 380v  Legrand	GENERAL ELECTRIC	M25	346000.00	1	1	3	2	/static/uploads/SPECST0007.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
629	SPECST0006	\N	\N	Stop kontak Inbow	Stopkontak Inbow HA0142 1ph MK ( PANASONIC)	GENERAL ELECTRIC	M26	0.00	24	4	5	6	/static/uploads/SPECST0006.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
630	SPMETA0001	\N	\N	Isolasi Listrik	Isolasi Listrik  20mm x 3/4" x 0,18m	GENERAL ELECTRIC	M31	9998.33	13	2	22	59	/static/uploads/SPMETA0001.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
631	SPECFA0012	\N	\N	Cooling Fan	Rotary Fan MU1225-51B 230VAC  Orix	GENERAL ELECTRIC	M34	120000.00	2	1	3	1	/static/uploads/SPECFA0012.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
632	SPECST0025	\N	\N	Over Steker Wontro	Oversteker Wontro (2 in 3 hole out)	GENERAL ELECTRIC	M35	0.00	0	1	2	0	\N	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
633	SPECST0020	\N	\N	Over Steker	Over Steker 1 Ph	GENERAL ELECTRIC	M37	0.00	0	1	2	0	\N	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
634	SPMEFT0107	\N	\N	Fitting	Fitting QSL-1/2-16  Festo	RVS	N11	0.00	0	1	2	0	\N	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
635	SPMEFT0049	\N	\N	Fitting	Fitting QSY-6  Festo	GENERAL	N111	59217.48	12	1	6	3	/static/uploads/SPMEFT0049.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
636	SPMEFT0140	\N	\N	Fitting	Fitting QS 10 8	GENERAL	N112	58536.79	17	0	20	15	/static/uploads/SPMEFT0140.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
637	SPMEFT0038	\N	\N	Fitting	Fitting PM 10 PISCO / QSS-10	GENERAL	N113	88377.00	8	1	6	3	/static/uploads/SPMEFT0038.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
638	SPMEFT0079	\N	\N	Fitting	Fitting QS-1/4-10  Festo	GENERAL	N115	38016.00	14	1	6	3	/static/uploads/SPMEFT0079.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
639	SPMEFT0103	\N	\N	Fitting	Fitting QS-1/8-8  Festo	GENERAL	N116	27525.62	19	0	10	8	/static/uploads/SPMEFT0103.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
640	SPMEFT0141	\N	\N	Fitting	Fitting QS 8 6	GENERAL	N117	45023.81	5	0	20	12	/static/uploads/SPMEFT0141.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
641	SPMEFT0142	\N	\N	Fitting	Fitting QS 12 10	GENERAL	N118	59054.96	8	1	6	2	/static/uploads/SPMEFT0142.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
642	SPMEFT0059	\N	\N	Fitting	Fitting QSL-3/8-10  Festo	GENERAL	N12	56765.00	16	1	6	2	/static/uploads/SPMEFT0059.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
643	SPMEFT0106	\N	\N	Fitting	Fitting QSL-1/2-10  Festo	GENERAL	N13	85291.50	7	1	6	2	/static/uploads/SPMEFT0106.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
644	SPMEFT0035	\N	\N	Speed Control Fitting	Speed Control Fitting GRLA-1/4-QS-8-D  Festo	JINCHENG	N14	250771.00	20	1	6	0	\N	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
645	SPMESN0004	\N	\N	Silencer	Silencer U-1/8  Festo	GENERAL	N15	62829.00	24	0	20	6	\N	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
646	SPMEFT0024	\N	\N	Push in Fitting	Push In Fitting QS-1/2-10 Festo	GENERAL	N16	55318.02	32	1	6	3	/static/uploads/SPMEFT0024.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
647	SPMEFT0075	\N	\N	Push in Fitting	Push In Fitting QSF-1/4-8-B Festo	GENERAL	N17	47350.00	5	4	14	7	/static/uploads/SPMEFT0075.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
648	SPMEFT0130	\N	\N	Silencer	Silencer U-1/4 Festo	GENERAL	N18	68041.05	18	1	6	1	/static/uploads/SPMEFT0130.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
649	SPMEFT0105	\N	\N	Speed Control Fitting	Speed Control Fitting GRLA-3/8-QS-8-RS-B  Festo	RVS	N19	0.00	0	1	2	0	\N	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
650	SPMEFT0050	\N	\N	Fitting	Fitting QS-1/8-6  Festo	GENERAL	N21	23634.00	18	5	15	8	/static/uploads/SPMEFT0050.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
651	SPMEFT0090	\N	\N	Fitting	Fitting QSL-3/8-8  Festo	GENERAL	N210	0.00	0	5	10	0	\N	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
652	SPMEFT0092	\N	\N	Fitting	Fitting QSL-1/8-6   (p/n 153046)  Festo	GENERAL	N211	37120.00	1	5	15	18	/static/uploads/SPMEFT0092.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
653	SPMEFT0098	\N	\N	Fitting	Fitting QSL-1/4-8  Festo	GENERAL	N212	44627.00	17	5	10	5	/static/uploads/SPMEFT0098.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
654	SPMEFT0089	\N	\N	Fitting	Fitting QSL-1/2-12  Festo	GENERAL	N213	90064.00	6	5	10	3	/static/uploads/SPMEFT0089.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
655	SPMEFT0097	\N	\N	Fitting	Fitting QSL-1/4-10  Festo	GENERAL	N214	51566.00	3	5	10	1	/static/uploads/SPMEFT0097.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
656	SPMEFT0048	\N	\N	Fitting	Fitting QSL-1/8-4 Festo	GENERAL	N215	34624.00	24	5	10	1	/static/uploads/SPMEFT0048.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
657	SPMEFT0015	\N	\N	Fitting	Fitting QST-8  Festo	GENERAL	N216	65904.39	23	5	15	6	/static/uploads/SPMEFT0015.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
658	SPMEFT0013	\N	\N	Fitting	Fitting QSMT-6  Festo	GENERAL	N217	53386.00	29	5	15	18	/static/uploads/SPMEFT0013.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
659	SPMEFT0014	\N	\N	Fitting	Fitting QSF-1/4-6  Festo	GENERAL	\N	0.00	0	5	10	1	\N	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
660	SPMEFT0007	\N	\N	Fitting	Fitting QSS-6  Festo	GENERAL	N219	63117.00	30	5	15	22	/static/uploads/SPMEFT0007.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
661	SPMEFT0104	\N	\N	Fitting	Fitting QS-3/8-8  Festo	GENERAL	N22	32115.00	6	5	10	1	/static/uploads/SPMEFT0104.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
662	SPMEFT0008	\N	\N	Fitting	Fitting QSS-8  Festo	GENERAL	N220	72488.24	9	5	15	10	/static/uploads/SPMEFT0008.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
663	SPMEFT0045	\N	\N	Speed Control Fitting	Speed Control Fitting GRLA-1/8-QS-4-RS-B  Festo	GENERAL	N221	0.00	0	1	2	0	\N	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
664	SPMEFT0046	\N	\N	Speed Control Fitting (Fitting 6)	Speed Control Fitting GRLA-M5-QS-6-RS-D  Festo	GENERAL	N222	262878.00	25	1	21	18	\N	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
665	SPMEFT0047	\N	\N	Speed Control Fitting	Speed Control Fitting GRLA-1/4-QS-6-RS-B  Festo	GENERAL	N223	289866.81	13	1	6	3	/static/uploads/SPMEFT0047.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
666	SPMEFT0043	\N	\N	Speed Control Fitting	Speed Control Fitting GRLA-1/8-QS-6-RS-B  Festo	GENERAL	N224	262878.00	2	0	10	14	/static/uploads/SPMEFT0043.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
667	SPMENI0031	\N	\N	Reducer Nipple	Reducer Nipple  D-1/2i-3/4a Festo	GENERAL	N225	38617.00	10	4	24	6	/static/uploads/SPMENI0031.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
668	SPMENI0032	\N	\N	Reducer Nipple	Reducer Neeple D-1/4i-1/2a  Festo	GENERAL	N218	24327.00	6	1	6	1	/static/uploads/SPMENI0032.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
669	SPMENI0033	\N	\N	Reducer Nipple	Reducer Neeple D-3/8i-1/2a  Festo	GENERAL	N227	28352.00	6	1	6	4	/static/uploads/SPMENI0033.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
670	SPMEFT0061	\N	\N	Speed Control Fitting	Speed Control Fitting GRLA-3/8-QS-6-RS-B  Festo	GENERAL	N228	386274.00	10	1	6	0	\N	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
671	SPMEFT0088	\N	\N	Fitting	Fitting QS-1/2-12  Festo	GENERAL	N23	0.00	10	5	10	0	\N	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
672	SPMEFT0051	\N	\N	Fitting	Fitting QSL-3/8-6  Festo	GENERAL	N230	45461.00	3	5	10	2	/static/uploads/SPMEFT0051.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
673	SPMENI0007	\N	\N	Double Nipple	Double Nipple 1/8"  s/s	GENERAL	N231	0.00	0	5	10	0	\N	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
674	SPMEFT0019	\N	\N	Fitting	Fitting QS-1/8-4  Festo	GENERAL	N234	0.00	0	5	10	0	\N	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
675	SPMEFT0100	\N	\N	Fitting	Fitting QSF-B-1/4-10  Festo	GENERAL	N235	61032.00	14	5	10	1	/static/uploads/SPMEFT0100.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
676	SPMEFT0099	\N	\N	Fitting	Fitting QSY-8  Festo	GENERAL	N236	70548.71	8	5	10	0	/static/uploads/SPMEFT0099.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
677	SPPISO0021	\N	\N	Sock selang	Sok Selang  1/2"	GENERAL	N237	0.00	0	1	2	0	\N	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
678	SPMEFT0022	\N	\N	Fitting	Fitting QSML-M5-6  Festo	PAMPAC	N24	43097.05	26	5	15	35	/static/uploads/SPMEFT0022.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
679	SPIPCY0001	\N	\N	Pneumatic Cylinder	Pneumatic Cylinder ADVU-25-25-P-A-S2  Festo	PAMPAC	N240	2106872.00	2	1	2	0	/static/uploads/SPIPCY0001.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
680	SPMEFT0062	\N	\N	Fitting	Fitting QST-10  Festo	GENERAL	N241	0.00	0	5	10	5	/static/uploads/SPMEFT0062.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
681	SPMEFT0005	\N	\N	Fitting	Fitting QS-1/4-8  Festo	GENERAL	N25	0.00	0	5	10	5	/static/uploads/SPMEFT0005.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
682	SPMEFT0057	\N	\N	Fitting	Fitting QS-1/4-6   Festo	GENERAL	N26	27944.00	7	5	10	5	\N	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
683	SPMEFT0054	\N	\N	Fitting	Fitting QSL-1/4-6  Festo	GENERAL	N27	40873.00	10	5	15	7	/static/uploads/SPMEFT0054.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
684	SPMEFT0064	\N	\N	Fitting	Fitting QSL-1/8-10  Festo	GENERAL	N28	49880.00	10	5	10	2	/static/uploads/SPMEFT0064.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
685	SPMEFT0012	\N	\N	Fitting	Fitting QSL-1/8-8  Festo	GENERAL	N29	42783.90	0	5	10	4	/static/uploads/SPMEFT0012.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
686	SPJNCY0012	\N	\N	Cylinder	Cylinder Festo DSNU 20-80 PPV A	JINCHENG	N31	712362.00	3	1	4	1	/static/uploads/SPJNCY0012.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
687	SPJNCY0007	\N	\N	Double acting Cylinder	Double Acting Cylinder 16-50P FESTO	JINCHENG	N310	0.00	0	1	2	1	/static/uploads/SPJNCY0007.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
688	SPSVCY0001	\N	\N	Pneumatic Cylinder	Pneumatic Cylinder ADVU-50-10-P-A Festo	RVS	N311	2875889.67	3	1	2	0	/static/uploads/SPSVCY0001.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
689	SPPMCY0002	\N	\N	Round Cylinder	ROUND CYLINDER DGS 16 10 (9123) FESTO	PAMPAC	N314	0.00	0	1	2	0	\N	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
690	SPJCCY0003	\N	\N	Pneumatic Cylinder	Pneumatic Cylinder DSNU-20-25-PPV-A-Q  Festo	JINCHENG	N32	1033460.00	4	1	2	0	/static/uploads/SPJCCY0003.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
691	SPJCCY0004	\N	\N	Pneumatic Cylinder	Pneumatic Cylinder DSNU-20-40-PPV-A-Q  Festo	PAMPAC	N33	1113429.00	6	1	2	0	/static/uploads/SPJCCY0004.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
692	SPPMCY0001	\N	\N	Pneumatic Cylinder	Pneumatic Cylinder DGS 12-25 ; p/n GPP 333  Festo	PAMPAC	N34	515781.00	6	2	3	3	/static/uploads/SPPMCY0001.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
693	SPGUCY0002	\N	\N	Double acting Cylinder	Double Acting Cylinder DSNU 25-50 PPV-A Festo	PAMPAC	N35	691647.00	1	1	2	0	/static/uploads/SPGUCY0002.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
694	SPPMCY0003	\N	\N	Pneumatic Cylinder	Pneumatic Cylinder ADVULQ-20-50-A-P-A  Festo	MEJA REPACK	N36	2410783.00	2	1	4	3	/static/uploads/SPPMCY0003.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
695	SPWRCY0001	\N	\N	Pneumatic Cylinder	Pneumatic Cylinder ADVC-32-10-I-P  Festo	CHIMEI	N38	571025.00	0	1	2	4	/static/uploads/SPWRCY0001.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
696	SPJNCY0010	\N	\N	Pneumatic Cylinder	Cylinder DSBC 80-200-PPV-A N3 Festo	GENERAL	N4	3135283.00	1	1	2	0	/static/uploads/SPJNCY0010.jpg	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
697	SPMEHO0015	\N	\N	Tubing	Tubing PUN-6x1  Festo	GENERAL	N5	0.00	0	0	0	0	\N	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
698	SPMEHO0021	\N	\N	Tubing	Tubing PUN-16 x 2,5  Festo	GENERAL	N5	0.00	0	0	0	0	\N	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
699	SPMEHO0090	\N	\N	Tubing	Tubing PUN-8x1,25  Festo	GENERAL	N5	0.00	0	0	0	0	\N	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
700	SPMEHO0106	\N	\N	Spiral Air Hose	Spiral Air Hose   orange	GENERAL	N5	0.00	0	0	0	0	\N	2026-06-23 07:09:21.941079	2026-06-23 07:09:21.941079	\N	\N
701	SPMEHO0118	\N	\N	Tubing	Tubing PUN-10x1,5  Festo	GENERAL	N5	0.00	0	0	0	0	\N	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
702	SPMEOR0152	\N	\N	O Ring	O Ring 58 x 2 Vitton	RVS	O16	0.00	0	1	2	0	\N	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
703	SPMESL0356	\N	\N	Seal TC	Seal TC 25 / 40 / 7	GENERAL	O210	0.00	12	1	2	0	\N	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
704	SPMESL0226	\N	\N	Seal TC	Seal TC 30 / 40 / 7	GENERAL	O213	0.00	12	1	2	0	\N	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
705	SPMESL0273	\N	\N	Seal TC	Seal TC 30 / 47 / 7	RVS	O214	13045.85	3	1	6	0	/static/uploads/SPMESL0273.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
706	SPMESL0113	\N	\N	Seal TC (SCREW RVS)	Seal TC 30 / 52 / 7	RVS	O216	0.00	10	1	2	0	\N	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
707	SPMESL0251	\N	\N	Seal TC (SCREW RVS)	Seal TC 30 / 55 / 12	RVS	O217	0.00	5	1	2	0	\N	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
708	SPMESL0073	\N	\N	Seal TC	Seal TC  15 / 30 / 7	GENERAL	O22	0.00	12	1	2	0	\N	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
709	SPMESL0266	\N	\N	Seal TC	Seal TC  38 / 52 / 7	RVS	O221	0.00	10	1	2	0	\N	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
710	SPMESL0271	\N	\N	Seal TC	Seal TC 40 / 47 / 4 ( untuk bearing HK 4020 )	RVS	O223	0.00	12	1	2	1	\N	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
711	SPMESL0272	\N	\N	Seal TC	Seal TC 20 / 26 / 4	RVS	O23	0.00	10	4	5	12	\N	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
712	SPMESL0015	\N	\N	Oil Seal	Oil Seal PDY 20	RVS	O231	0.00	0	1	2	0	\N	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
713	SPMESL0162	\N	\N	Oil Seal	Oil Seal PDY 25	RVS	O232	0.00	0	1	2	0	\N	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
714	SPMESL0267	\N	\N	V Ring	V Ring V-020  (p/n 5494 2708)	RVS	O233	7000.00	27	5	55	84	/static/uploads/SPMESL0267.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
715	SPMESL0268	\N	\N	V Ring	V Ring V-030  (p/n 5494 2709)	RVS	O234	11000.01	33	4	54	78	/static/uploads/SPMESL0268.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
716	SPMEPC0082	\N	\N	Rubber Gasket	Rubber Gasket  ID 12 x 3 Black	RVS	O237	38571.43	19	1	11	0	/static/uploads/SPMEPC0082.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
717	SPMEPC0083	\N	\N	Rubber Gasket	Rubber Gasket  ID 30 x 4 Green	RVS	O238	85000.00	16	0	12	11	/static/uploads/SPMEPC0083.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
718	SPMESL0275	\N	\N	Seal TC/SD	Seal SD 50 / 58 / 4A (Bearing HK5025)	RVS	O239	0.00	0	1	2	5	/static/uploads/SPMESL0275.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
719	SPMESL0270	\N	\N	Seal TC	Seal TC 30 / 42 / 7	RVS	O242	22966.52	11	1	6	1	/static/uploads/SPMESL0270.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
720	SPMESL0156	\N	\N	Seal TC	Seal TC  20 / 30 / 7	JINCHENG	O25	0.00	5	1	2	1	/static/uploads/SPMESL0156.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
721	SPMESL0078	\N	\N	Seal TC	Seal TC 25 / 32 / 4	RVS	O27	18000.00	4	1	6	1	/static/uploads/SPMESL0078.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
722	SPMESL0232	\N	\N	Seal TC	Seal TC 25 / 35 / 7 Vitton	RVS	O28	0.00	10	1	2	0	\N	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
723	SPMEPC0016	\N	\N	Sponge Seal dia. 5 mm	Sponge Seal dia. 5 mm	RVS	O31	50000.00	5	1	6	1	/static/uploads/SPMEPC0016.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
724	SPMESL0276	\N	\N	Seal TC	Seal TC 22 / 35 / 7	RVS	O312	0.00	5	1	2	0	\N	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
725	SPMECU0026	\N	\N	Rubber Coupling / Element	Rubber for Coupling / Element L-095  Lovejoy	RVS	O318	23148.00	1	1	2	0	/static/uploads/SPMECU0026.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
726	SPSVSL0004	\N	\N	Seal Roll	Seal Roll penarik Size: Dia. 43x55x5,5 Silicone Shore 80 (Radius)	RVS	O32	67500.00	48	6	106	103	\N	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
727	SPMEPC0084	\N	\N	Rubber Gasket	Rubber Gasket  ID 96 x 5 White	RVS	O320	0.00	0	1	2	0	\N	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
728	SPMESL0281	\N	\N	Rubber Seal For Coupling	Rubber Seal For Coupling N-Eupex 80 Flender	RVS	O328	0.00	0	1	2	1	/static/uploads/SPMESL0281.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
729	SPSVSL0002	\N	\N	Seal Roll (Roller Intermediate)	Seal Roll Penarik Dia. 27.5x42x5.5 Silicone Shore 40-50 (Radius)	RVS	O33	67430.56	53	0	100	56	/static/uploads/SPSVSL0002.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
730	SPSVSL0003	\N	\N	Seal Roll	Seal Roll penarik Size: Dia. 43x55x5,5 Silicone Shore 80	RVS	O34	71037.55	75	11	111	87	/static/uploads/SPSVSL0003.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
731	SPMESL0365	\N	\N	Gasket Butterfly	Gasket Butterfly Valve White EPDM Dia 4inch	FBD	O35	525000.00	4	1	6	0	/static/uploads/SPMESL0365.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
732	SPMESG0125	\N	\N	Per Tekan	Per Tekan dia. kawat 0.6 ; pitch 4.5  dia. 9 x 28	CHIMEI	P11	0.00	0	1	2	0	\N	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
733	SPMESG0061	\N	\N	Per tarik (Chimei)	Per Tarik dia. kawat 1,5 dia. 12 x 10	CHIMEI	P110	8121.40	48	4	39	99	/static/uploads/SPMESG0061.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
734	SPMESG0100	\N	\N	Per Tarik	Per Tarik (Kerucut ujung) dia. kawat 3,5	RVS	P111	27917.00	7	1	2	0	/static/uploads/SPMESG0100.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
735	SPMESG0091	\N	\N	Tension Spring	Tension Spring  Cold Drawn Steel ; p/n 490 028 001	PAMPAC	P116	0.00	0	1	2	0	\N	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
736	SPMESG0063	\N	\N	Per tarik	Per Tarik dia. kawat 2  dia. 24 x 244	JINCHENG	P118	51722.33	5	2	7	1	/static/uploads/SPMESG0063.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
737	SPMESG0059	\N	\N	Per Tekan	Per Tekan dia. kawat 1,5 ; pitch 8 dia. 13,5 x 100	JINCHENG	P119	7500.00	2	1	2	0	/static/uploads/SPMESG0059.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
738	SPHSBK0002	\N	\N	Spring Stopper	Spring Stopper A-58  Cyclops	PAMPAC	P120	0.00	0	1	2	0	\N	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
739	SPMESG0107	\N	\N	Per Tarik	Per Tarik dia.kwt 1,dia.per 15, panjang 12 s/s	RVS	P123	0.00	0	1	2	11	/static/uploads/SPMESG0107.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
740	SPMESG0041	\N	\N	Per Tekan	Per Tekan dia.dlm8.5; dia.kwt1.5; l=25; pitch3 s/s	PAMPAC	P125	0.00	0	1	2	1	/static/uploads/SPMESG0041.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
741	SPMESG0060	\N	\N	Per Tarik	Per Tarik dia. kawat 3 dia. 22x165 (incld 2 hook)	JINCHENG	P18	20000.00	1	1	2	0	/static/uploads/SPMESG0060.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
742	SPMESG0062	\N	\N	Per tarik	Per Tarik dia. kawat 2  dia. 24 x 197	JINCHENG	P19	63333.33	4	2	6	1	/static/uploads/SPMESG0062.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
743	SPMESG0057	\N	\N	Per Tarik	Per Tarik dia. kawat 3 dia. 22 x 215 incl`d 2 hooks	JINCHENG	P23	0.00	0	1	2	0	\N	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
744	SPMESG0090	\N	\N	Tension Spring	Tension Spring  Steel ; p/n 490 027 001	PAMPAC	P24	0.00	3	1	2	0	/static/uploads/SPMESG0090.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
745	SPPMLH0003	\N	\N	Stick Pusher	Sachet Pusher Stick 328 x 9.5 x 9.5 SUS304	PAMPAC	P31	325000.00	8	1	2	20	/static/uploads/SPPMLH0003.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
746	SPPMSP0008	\N	\N	Pusher Guide	Guide Pusher Pampac POM Putih 48x26.3x12mm	PAMPAC	P32	320000.00	9	0	10	17	/static/uploads/SPPMSP0008.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
747	SPPMSP0007	\N	\N	Pusher Head	Head Pusher Pampac PVC 50.2x22x45mm	PAMPAC	P33	450000.00	0	10	30	84	/static/uploads/SPPMSP0007.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
748	SPPMCH0002	\N	\N	Connecting Link	Connecting Link DID OJ 35	PAMPAC	P41	93100.00	0	1	2	1	/static/uploads/SPPMCH0002.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
749	SPMECH0038	\N	\N	Connecting Link	Connecting Link CL 35-1	PAMPAC	P410	105000.00	10	4	9	5	/static/uploads/SPMECH0038.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
750	SPMECH0037	\N	\N	Connecting Link	Connecting Link RS 25-1	CHIMEI	P46	100000.00	20	1	2	0	/static/uploads/SPMECH0037.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
751	SPMECH0027	\N	\N	Connecting Link	Chain Link Inner p/n SBMECHLINK0002	PAMPAC	P47	0.00	0	1	2	0	\N	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
752	SPMECH0026	\N	\N	Connecting Link	Connecting Link 08B  DID	PAMPAC	P48	120000.00	4	2	12	13	/static/uploads/SPMECH0026.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
753	SPMECH0020	\N	\N	Connecting Link	Connecting Link For Pusher Chain ; p/n GTC 161	PAMPAC	P49	0.00	0	1	2	3	\N	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
754	SPPMCH0001	\N	\N	Chain Link	Chain Link DID 08B	PAMPAC	P51	2526000.00	0	1	2	1	/static/uploads/SPPMCH0001.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
755	SPMECH0025	\N	\N	Chain Carton	Chain Carton p/n SBMECCHEN0015	PAMPAC	P52	0.00	0	1	2	0	\N	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
756	SPMECH0028	\N	\N	Chain Link	Chain Link Extended 1" SBMECCHEN0050	CHIMEI	P53	0.00	0	1	2	0	\N	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
757	SPPMCT0004	\N	\N	Inverter	Inverter FR-E540-1.5K (1,5kW 3ph) Mitsubishi	PAMPAC	Q1	0.00	0	1	2	1	/static/uploads/SPPMCT0004.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
758	SPPMCT0005	\N	\N	Inverter	Inverter FRN0.75E1S-7A Fuji Elektrik	PAMPAC	Q1	0.00	0	1	2	0	\N	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
759	SPPMCT0006	\N	\N	Inverter	Inverter FRN0.75E1S-4A Fuji Electric	PAMPAC	Q1	0.00	0	1	2	1	\N	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
760	SPSVFU0001	\N	\N	Antistatic bar	Antistatic bar EXAIR 18" 7018-10,length:3m/10 feet	PAMPAC	Q2	9727500.00	5	1	6	11	/static/uploads/SPSVFU0001.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
761	SPSVMD0021	\N	\N	Power supply	Power supply 30v,50/60hz,2 outlet,model 7907 EXAIR	PAMPAC	Q2	9950000.00	5	1	2	4	/static/uploads/SPSVMD0021.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
762	SPMETA0002	\N	\N	Selongsong Heater	Selongsong Heater  dia. 6	PAMPAC	Q3	0.00	27	2	3	14	/static/uploads/SPMETA0002.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
763	SPMETA0004	\N	\N	Selongsong Heater	Selongsong Heater  dia. 8	PAMPAC	Q3	0.00	0	1	2	19	/static/uploads/SPMETA0004.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
764	SPMETA0005	\N	\N	Selongsong Heater	Selongsong Heater  dia. 10	PAMPAC	Q3	0.00	0	1	2	20	/static/uploads/SPMETA0005.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
765	SPMETA0066	\N	\N	Selongsong Heater (RVS)	Selongsong Heater  dia. 4	PAMPAC	Q3	0.00	24	2	3	21	/static/uploads/SPMETA0066.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
766	SPCNMO0005	\N	\N	SPEED CONTROL MOTOR USP 560-2E ORIENTAL	SPEED CONTROL MOTOR USP 560-2E ORIENTAL	JINCHENG	Q31	0.00	0	1	2	0	\N	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
767	SPJCGE0002	\N	\N	Gear Head	Gear Head 5GU15K Oriental	CHIMEI	Q31	2180000.00	1	1	2	0	/static/uploads/SPJCGE0002.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
768	SPJCGE0004	\N	\N	Gear Head	Gear Head 5GU25KB Oriental	CHIMEI	Q31	2297000.00	4	1	2	1	/static/uploads/SPJCGE0004.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
769	SPNDGE0002	\N	\N	Gear Head	Gear Head 5GU36KB  Oriental	CHIMEI	Q31	0.00	0	1	2	0	\N	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
770	SPNDMO0001	\N	\N	Speed Control Motor	Speed Control Motor US560-502E  Oriental	CHIMEI	Q31	0.00	0	1	2	0	\N	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
771	SPYNMO0002	\N	\N	Gear Head	Gear Head 5GN25K  Oriental	GENERAL	Q31	1465000.00	1	1	2	0	/static/uploads/SPYNMO0002.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
772	SPSVGE0005	\N	\N	Planetary gearbox	Planetary Gear Box for Cross Knife Alpha AS14 SP075S-MF2-16-0C1-2S/14mm	RVS	Q4	0.00	0	1	2	2	/static/uploads/SPSVGE0005.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
773	SPSVGE0007	\N	\N	Gearbox	Gearbox SP075-MF1-4-121-200  Alpha (Slider) AS14	RVS	Q4	20570000.00	1	1	2	0	/static/uploads/SPSVGE0007.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
774	SPSVGE0009	\N	\N	Gearbox	SP075-MF1-10-121-000 Alpha (No.Batch) AS14	RVS	Q4	0.00	0	1	2	1	/static/uploads/SPSVGE0009.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
775	SPSVGE0004	\N	\N	Angle Planetary Gearbox	Angle Planetary SPC 075S-MF2-14-0E0-1K01 Alpha	RVS	Q5	45835000.00	1	1	2	1	/static/uploads/SPSVGE0004.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
776	SPSVSE0007	\N	\N	Longitudinal heater roller left	Longitudinal Heater Roller Left p/n 5655 7635	RVS	Q5	0.00	0	1	2	1	\N	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
777	SPSVSE0008	\N	\N	Longitudinal heater roller right	Longitudinal Heater Roller Right p/n 5655 7630	RVS	Q5	0.00	0	1	2	1	\N	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
778	SPMEBE0370	\N	\N	Bearing	Bearing  51208	RVS	R110	99800.00	12	1	6	4	/static/uploads/SPMEBE0370.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
779	SPMEBE0312	\N	\N	Bearing	Bearing 6901 Z	PAMPAC	R111	0.00	0	1	2	0	\N	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
780	SPMEBE0330	\N	\N	Bearing	Bearing NK 6 / 10T	RVS	R113	0.00	0	1	2	0	\N	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
781	SPMEBE0178	\N	\N	Bearing	Bearing 6902 ZZ	CONVEYOR	R117	0.00	0	1	2	0	\N	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
782	SPMECU0002	\N	\N	Quick Coupler Set	Quick Coupler Set SM40 - PH20	CONSUMABLE	R12	175000.00	4	1	2	0	/static/uploads/SPMECU0002.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
783	SPMEBE0369	\N	\N	Bearing	Bearing NA 5908	RVS	R19	194430.00	10	4	14	6	/static/uploads/SPMEBE0369.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
784	SPMECK0004	\N	\N	Klem Selang	Antistatic bar EXAIR 18" 7018-10,length:3m/10 feet	CONSUMABLE	R21	5000.00	11	1	6	7	/static/uploads/SPMECK0004.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
785	SPMECK0033	\N	\N	Klem Selang	Klem Selang  7"	CONSUMABLE	R210	13500.00	3	1	2	0	/static/uploads/SPMECK0033.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
786	SPMECK0012	\N	\N	Klem Selang	Klem Selang  3/4" s/s	CONSUMABLE	R211	0.00	0	10	15	12	/static/uploads/SPMECK0012.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
787	SPMECK0007	\N	\N	Klem Selang	Klem Selang  1"  s/s	CONSUMABLE	R22	7500.00	5	4	9	14	/static/uploads/SPMECK0007.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
788	SPMECK0009	\N	\N	Klem Selang	Klem Selang  1 1/2"  s/s	CONSUMABLE	R23	0.00	0	1	6	4	/static/uploads/SPMECK0009.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
789	SPMECK0005	\N	\N	Klem Selang	Klem Selang  2"  s/s	CONSUMABLE	R24	0.00	0	10	15	20	/static/uploads/SPMECK0005.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
790	SPMECK0032	\N	\N	Klem Selang	Klem Selang  4"	CONSUMABLE	R25	15000.00	1	4	9	8	\N	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
791	SPMECK0002	\N	\N	Klem Selang	Klem Selang  6" s/s	CONSUMABLE	R26	11000.00	1	1	6	3	/static/uploads/SPMECK0002.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
792	SPMECK0003	\N	\N	Klem Selang	Klem Selang  5" s/s	CONSUMABLE	R27	0.00	0	1	6	3	/static/uploads/SPMECK0003.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
793	SPMEBE0376	\N	\N	Bearing	Bearing 6906A	RVS	R28	33000.00	14	1	2	0	/static/uploads/SPMEBE0376.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
794	SPBMGL0015	\N	\N	Lem	Lem Korea Alteco	CONSUMABLE	R31	14122.43	56	2	7	81	/static/uploads/SPBMGL0015.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
795	SPBMGL0001	\N	\N	Lem	Lem Plastic Steel Dexton	CONSUMABLE	R32	14720.24	13	0	5	23	/static/uploads/SPBMGL0001.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
796	SPMETA0037	\N	\N	Seal Tape	Seal Tape  dia. 12mm x 0.10 x 10m Tombo	GENERAL	R34	7000.00	70	2	7	63	/static/uploads/SPMETA0037.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
797	SPBMGL0007	\N	\N	Lem Gasket	Lem Gasket Threebond	CONSUMABLE	R35	46732.14	1	1	6	3	/static/uploads/SPBMGL0007.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
798	SPBMGL0009	\N	\N	Retaining Compound	Retaining Compound 609  Loctite	GENERAL	R36	0.00	0	1	2	0	/static/uploads/SPBMGL0009.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
799	SPBMGL0010	\N	\N	Thread Locker	Thread Locker 262  Loctite	GENERAL	R37	360000.00	7	1	6	4	/static/uploads/SPBMGL0010.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
800	SPWSTO0005	\N	\N	Recoil Insert	Recoil Insert  M10 x 1,5 (1,5D)	Workshop	R38	16000.00	18	1	6	1	/static/uploads/SPWSTO0005.jpg	2026-06-23 07:09:21.959216	2026-06-23 07:09:21.959216	\N	\N
801	SPWSTO0008	\N	\N	Recoil Insert	Recoil Insert M6 x 1 (1,5D)	Workshop	R38	14000.00	9	1	6	1	/static/uploads/SPWSTO0008.jpg	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
802	SPWSTO0009	\N	\N	Recoil Insert	Recoil Insert M8 x 1,25 (1,5D)	Workshop	R38	14000.00	12	1	2	0	/static/uploads/SPWSTO0009.jpg	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
803	SPWSTO0016	\N	\N	Recoil Insert	Recoil Insert M12 x 1.75 (1.5D)	Workshop	R38	26000.00	20	1	2	0	/static/uploads/SPWSTO0016.jpg	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
804	SPMEFI0447	\N	\N	Filter	Vesda Dual Stage Filter	UTILITY	R51	0.00	0	0	0	1	/static/uploads/SPMEFI0447.jpg	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
805	SPCMAB0022	\N	\N	Batu Gerinda	Batugerinda 4" Best Touch WA60 100x2x16 Nippon	CONSUMABLE	R54	25000.00	7	1	6	1	/static/uploads/SPCMAB0022.jpg	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
806	SPMEBE0257	\N	\N	Bearing	Bearing 607 A	CHECK WEIGHER	S11	0.00	0	10	15	5	\N	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
807	SPMEBE0005	\N	\N	Bearing	Bearing 6204 2Z	GENERAL	S110	24725.00	14	10	15	2	/static/uploads/SPMEBE0005.jpg	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
808	SPMEBE0030	\N	\N	Bearing (SCREW RVS)	Bearing 6205 2Z	RVS	S111	39500.00	9	10	11	0	\N	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
809	SPMEBE0027	\N	\N	Bearing	Bearing 6207 2RS	GENERAL	S113	0.00	0	10	11	0	\N	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
810	SPMEBE0386	\N	\N	Bearing	Bearing 6208 2Z	GENERAL	S114	0.00	0	10	11	0	\N	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
811	SPMEBE0283	\N	\N	Bearing	Bearing 6000 2Z	PAMPAC	S115	23410.00	12	10	40	25	/static/uploads/SPMEBE0283.jpg	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
812	SPMEBE0018	\N	\N	Bearing	Bearing 6001 2Z	RVS	S116	24910.00	64	10	40	35	/static/uploads/SPMEBE0018.jpg	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
813	SPMEBE0009	\N	\N	Bearing	Bearing 6002 2Z	RVS	S117	30000.00	7	10	40	105	/static/uploads/SPMEBE0009.jpg	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
814	SPMEBE0037	\N	\N	Bearing	Bearing 6003 2Z	GENERAL	S118	35000.00	13	10	20	7	/static/uploads/SPMEBE0037.jpg	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
815	SPMEBE0437	\N	\N	Bearing	Bearing 6004 2Z	PAMPAC	S119	23460.00	10	10	15	1	\N	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
816	SPMEBE0024	\N	\N	Bearing	Bearing 608 2Z	GENERAL	S12	0.00	0	10	20	6	/static/uploads/SPMEBE0024.jpg	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
817	SPMEBE0056	\N	\N	Bearing	Bearing 6004 RS	GENERAL	S121	25980.00	17	10	20	7	/static/uploads/SPMEBE0056.jpg	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
818	SPMEBE0338	\N	\N	Bearing	Bearing 6005 2Z	PAMPAC	S122	39700.00	10	10	30	26	/static/uploads/SPMEBE0338.jpg	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
819	SPMEBE0013	\N	\N	Bearing (SCREW RVS)	Bearing 6006 2Z	RVS	S123	33570.00	29	10	15	1	/static/uploads/SPMEBE0013.jpg	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
820	SPMEBE0361	\N	\N	Bearing	Bearing 16005	RVS	S124	50437.00	3	10	11	0	/static/uploads/SPMEBE0361.jpg	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
821	SPMEBE0042	\N	\N	Bearing	Bearing 6007 2Z	PAMPAC	S125	37540.00	29	10	15	3	/static/uploads/SPMEBE0042.jpg	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
823	SPMEBE0310	\N	\N	Bearing	Bearing 688A 2Z	PAMPAC	S13	101546.59	14	10	15	5	/static/uploads/SPMEBE0310.jpg	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
824	SPMEBE0394	\N	\N	Bearing	Bearing 626 2Z	RVS	S14	11000.00	3	10	20	8	/static/uploads/SPMEBE0394.jpg	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
825	SPMEBE0292	\N	\N	Bearing	Bearing 6200 2Z	RVS	S15	14800.00	8	10	15	1	/static/uploads/SPMEBE0292.jpg	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
826	SPMEBE0049	\N	\N	Bearing	Bearing 6200 2RS	RVS	S16	16564.00	10	10	15	1	/static/uploads/SPMEBE0049.jpg	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
827	SPMEBE0279	\N	\N	Bearing	Bearing 6201 2Z	GENERAL	S17	15119.05	9	10	15	5	/static/uploads/SPMEBE0279.jpg	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
828	SPMEBE0038	\N	\N	Bearing (SCREW RVS)	Bearing 6203 2Z	RVS	S18	0.00	0	10	20	7	/static/uploads/SPMEBE0038.jpg	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
829	SPMEBE0313	\N	\N	Bearing	Bearing 6202 RS	PAMPAC	S19	0.00	0	10	15	5	/static/uploads/SPMEBE0313.jpg	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
830	SPMEBE0255	\N	\N	Bearing	Bearing CF12	JINCHENG	S21	94197.75	0	10	15	1	/static/uploads/SPMEBE0255.jpg	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
831	SPMEBE0418	\N	\N	Bearing	Bearing 6301 2Z	PAMPAC	S210	21500.00	7	10	20	9	/static/uploads/SPMEBE0418.jpg	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
832	SPMEBE0341	\N	\N	Bearing	Bearing 6302 RS	RVS	S211	42500.00	10	10	15	2	/static/uploads/SPMEBE0341.jpg	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
833	SPMEBE0177	\N	\N	Bearing	Bearing 6303 2Z	GENERAL	S212	45500.00	10	10	15	0	\N	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
834	SPMEBE0033	\N	\N	Bearing	Bearing 6304 2Z	GENERAL	S213	50000.00	0	10	11	0	\N	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
835	SPMEBE0031	\N	\N	Bearing	Bearing 6306 2Z	GENERAL	S215	0.00	0	10	11	0	\N	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
836	SPMEBE0364	\N	\N	Bearing	Bearing L68110  Timken	RVS	S217	52500.00	4	10	11	0	/static/uploads/SPMEBE0364.jpg	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
837	SPMEBE0054	\N	\N	Bearing	Bearing 3205 A	GENERAL	S219	0.00	0	10	11	0	\N	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
838	SPMEBE0296	\N	\N	Bearing	Bearing CF 8 A	CHIMEI	S22	64227.89	14	10	15	1	/static/uploads/SPMEBE0296.jpg	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
839	SPMEBE0053	\N	\N	Bearing	Bearing 30205	GENERAL	S220	0.00	0	10	11	0	\N	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
840	SPMEBE0029	\N	\N	Bearing	Bearing 30206 J2 / Q	GENERAL	S221	0.00	0	10	11	0	\N	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
841	SPMEBE0358	\N	\N	Bearing	Bearing 320 / 32X	RVS	S223	90000.00	5	10	15	1	/static/uploads/SPMEBE0358.jpg	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
842	SPMEBE0408	\N	\N	Bearing	Bearing HK 2520	RVS	S225	19550.00	3	10	11	0	/static/uploads/SPMEBE0408.jpg	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
843	SPMEBE0240	\N	\N	Bearing	Bearing 6206 RS	GENERAL	S226	60000.00	10	10	15	5	/static/uploads/SPMEBE0240.jpg	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
844	SPMEBE0239	\N	\N	Bearing	Bearing 6205 RS	GENERAL	S227	30575.00	1	10	30	20	/static/uploads/SPMEBE0239.jpg	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
845	SPMEBE0431	\N	\N	Bearing	Bearing 51102	Workshop	S23	0.00	0	10	11	0	\N	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
846	SPMEBE0014	\N	\N	Bearing	Bearing 6900 Z	GENERAL	S26	0.00	0	10	11	0	\N	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
847	SPMEBE0363	\N	\N	Bearing	Bearing 16004	RVS	S27	0.00	0	10	15	1	\N	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
848	SPMEBE0359	\N	\N	Bearing	Bearing 7201	RVS	S29	70936.67	8	10	11	0	/static/uploads/SPMEBE0359.jpg	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
849	SPMEBE0450	\N	\N	Bearing	Bearing NK 8/12 TN	PAMPAC	S31	0.00	0	10	11	0	\N	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
850	SPMEBE0335	\N	\N	Bearing	Bearing HK 5025  incl`d Inner (TR 45 x 50 x 25)	RVS	S310	51700.00	20	10	11	0	/static/uploads/SPMEBE0335.jpg	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
851	SPMEBE0353	\N	\N	Bearing	Bearing TLA 4020 Z  IKO	RVS	S311	43335.00	3	10	20	12	/static/uploads/SPMEBE0353.jpg	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
852	SPMEBE0354	\N	\N	Bearing	Bearing BK-1015  INA (Schimidth)	RVS	S312	37000.00	57	10	40	74	/static/uploads/SPMEBE0354.jpg	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
853	SPMEBE0055	\N	\N	Bearing	Bearing RNA NA 6908	RVS	S313	199185.00	8	10	15	2	/static/uploads/SPMEBE0055.jpg	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
854	SPMEBE0261	\N	\N	Bearing	Bearing 6013 2Z	JINCHENG	S315	112000.00	6	10	11	0	/static/uploads/SPMEBE0261.jpg	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
855	SPMEBE0365	\N	\N	Bearing	Bearing RNA NA 6906	RVS	S317	174900.00	12	10	15	4	/static/uploads/SPMEBE0365.jpg	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
856	SPMEBE0305	\N	\N	Bearing	Linier Bearing KUG L BAR 8 2 LS ; p/n GBL 152	PAMPAC	S32	0.00	0	10	11	0	\N	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
857	SPMEBE0170	\N	\N	Bearing	Bearing 207 2Z	CHECK WEIGHER	S322	0.00	0	10	11	0	\N	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
858	SPMEBE0237	\N	\N	Linier Bearing	Linier Bearing LBD 12 UU	PAMPAC	S33	67725.00	3	10	15	2	/static/uploads/SPMEBE0237.jpg	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
859	SPMEBE0260	\N	\N	Linier Bearing	Linier Bearing SDM 16  Ease	JINCHENG	S34	56028.14	7	10	20	6	/static/uploads/SPMEBE0260.jpg	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
860	SPMEBE0345	\N	\N	Bearing	Bearing HK Series (Laher) HK 0509	RVS	S35	11800.00	21	10	15	4	/static/uploads/SPMEBE0345.jpg	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
861	SPMEBE0346	\N	\N	Bearing	Bearing HK 1216	RVS	S37	0.00	0	10	11	0	\N	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
862	SPMEBE0355	\N	\N	Bearing	Bearing HK-2020 INA	RVS	S38	27000.00	28	10	40	45	\N	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
863	SPMEBE0340	\N	\N	Bearing	Bearing HK 3020	RVS	S39	21315.94	22	10	20	7	/static/uploads/SPMEBE0340.jpg	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
864	SPMEBE0371	\N	\N	Bearing	Bearing HK2538 IKO	RVS	S410	27720.00	12	10	15	2	/static/uploads/SPMEBE0371.jpg	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
865	SPMEBE0227	\N	\N	Flange Bearing	Flange Bearing FC 205J  NTN	GENERAL	S45	0.00	0	10	11	0	\N	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
866	SPMEBE0426	\N	\N	Bearing	Bearing UC 204	GENERAL	S46	0.00	0	10	11	0	\N	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
867	SPMEBE0366	\N	\N	Bearing	Bearing NAX 2030 Z	RVS	S48	194264.05	13	10	40	41	/static/uploads/SPMEBE0366.jpg	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
868	SPMEBE0367	\N	\N	Bearing	Bearing NAX 3042 Z	RVS	S49	280250.00	3	10	15	4	/static/uploads/SPMEBE0367.jpg	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
869	SPMEBE0214	\N	\N	Pillow Block (SCREW RVS)	Pillow Block UKF 206  FYH	RVS	S51	0.00	0	5	6	0	\N	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
870	SPMEBE0421	\N	\N	Pillow Block	Pillow Block F 206 J	GENERAL	S51	0.00	0	5	6	0	\N	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
871	SPMEBE0203	\N	\N	Pillow Block	Pillow Block FL206 dan Bearing UC206	GENERAL	S510	0.00	0	5	6	0	\N	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
872	SPMEBE0060	\N	\N	Bearing	Bearing UC 206	GENERAL	S511	0.00	0	5	6	0	\N	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
873	SPMEBE0314	\N	\N	Bearing	Bearing 2202 RS	CONVEYOR	S512	0.00	0	5	6	0	\N	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
874	SPMEBE0197	\N	\N	Pillow Block	Pillow Block FC 206 FYH	GENERAL	S52	0.00	0	1	2	0	\N	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
875	SPMEBE0050	\N	\N	Pillow Block	Pillow Block UCP 205	PAMPAC	S56	0.00	0	1	2	0	\N	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
876	SPMEBE0058	\N	\N	Bearing	Bearing UK 206 - H2306	GENERAL	S57	0.00	0	1	2	0	\N	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
877	SPMEBE0045	\N	\N	Pillow Block	Pillow Block UCP 204 J	GENERAL	S59	0.00	0	1	2	0	\N	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
878	SPMEBE0424	\N	\N	Pillow Block	Pillow Block F206J dan Bearing UC 206	GENERAL	S59	0.00	0	1	2	0	\N	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
879	SPBOGI0002	\N	\N	Cartridge for CMU	Cartridge for CMU, p/n S199-003-5090-0 Boiler	BOILER	T11	0.00	0	0	0	0	\N	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
880	SPPWUV0004	\N	\N	UV Quartz Glass	UV Quartz Glass 130 W, p/n 4-008373 Loopo 200	PURIFIED WATER	T111	0.00	0	0	0	0	\N	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
881	SPCTGI0001	\N	\N	Biocide	Biocide (Z-428) CT	COOLING TOWER	T12	0.00	0	0	0	0	\N	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
882	SPCTGI0002	\N	\N	Antiscalant	Antiscalant (Z-342) CT	COOLING TOWER	T13	0.00	0	0	0	0	\N	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
883	SPCTGI0003	\N	\N	Biodispersant	Biodispersant (Z-506) CT	COOLING TOWER	T14	0.00	0	0	0	0	\N	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
884	SPCYBO0001	\N	\N	Bola - bola ATCS	Bola - bola ATCS Balltech Chiller York	CHILLER	T15	0.00	0	0	0	0	\N	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
885	SPCYFI0001	\N	\N	Filter Dryer	Filter Dryer Chiller York	CHILLER	T16	0.00	0	0	0	0	\N	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
886	SPCYOL0002	\N	\N	Oil Filter	Oil Filter Chiller York	CHILLER	T17	0.00	0	0	0	0	\N	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
887	SPPWFT0001	\N	\N	Filter for Tank	Filter for Tank Type VTV0.2, p/n 299999 Loopo 200 dan Loopo 100	PURIFIED WATER	T18	0.00	0	0	0	0	\N	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
888	SPPWGI0001	\N	\N	Osmotron	NaHSO3 (SMB) Osmotron	PURIFIED WATER	T19	0.00	0	0	0	0	\N	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
889	SPWTFI0001	\N	\N	Filter	Filter Bag 5 - 25 mikron BWT - BAG Filter BFS 221	UTILITY	T2	0.00	0	0	0	0	\N	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
890	SPTSFI0002	\N	\N	Filter Tipping Station	Filter Tipping Station F/W 495 x 720mm Mat PE 500 AS	UTILITY	T22	0.00	0	0	0	0	\N	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
891	SPMEBA0001	\N	\N	Temp & RH Transmitter	Temp & RH Transmitter KLK-M.1 Produal	UTILITY	T23	0.00	0	0	0	0	\N	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
892	SPMEBA0002	\N	\N	Diff. Pressure Transmitter for Flow	Diff. Pressure Transmitter for Flow IML-M Produal	UTILITY	T24	0.00	0	0	0	0	\N	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
893	SPMEBA0003	\N	\N	Diff. Pressure Transmitter for Filter	Diff. Pressure Transmitter for Filter PEL 2500-M-N Produal	UTILITY	T25	0.00	0	0	0	0	\N	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
894	SPMEBA0004	\N	\N	Diff. Pressure Transmitter for Room	Diff. Pressure Transmitter for Room PEL-M Produal	UTILITY	T26	0.00	0	0	0	0	\N	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
895	SPMEBA0005	\N	\N	Temp Sensor (EH)	Temp Sensor (EH) TEK PT1000 Produal	UTILITY	T27	0.00	0	0	0	0	\N	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
896	SPMEBA0006	\N	\N	Diif. Pressure Switch (EH)	Diif. Pressure Switch (EH) PEK 400 Produal	UTILITY	T28	0.00	0	0	0	0	\N	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
897	SPMEBA0007	\N	\N	Wireless T & RH	Wireless T & RH TEFL-2.2 Produal	UTILITY	T31	0.00	0	0	0	0	\N	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
898	SPMEBA0008	\N	\N	Wireless Base Station	Wireless Base Station FLTA v2.2 Produal	UTILITY	T32	0.00	0	0	0	0	\N	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
899	SPMEBA0009	\N	\N	Room Terminal Unit	Room Terminal Unit Temp CO2 ROU-S-CO2 Produal	UTILITY	T33	0.00	0	0	0	0	\N	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
900	SPMEBA0010	\N	\N	Pressure Transmitter (Water)	Pressure Transmitter (Water) VPL-16 Produal	UTILITY	T34	0.00	0	0	0	0	\N	2026-06-23 07:09:21.967482	2026-06-23 07:09:21.967482	\N	\N
901	SPMEBA0011	\N	\N	Temp. Sensor (Water)	Temp. Sensor (Water) TEAT PT1000 Produal	UTILITY	T35	0.00	0	0	0	0	\N	2026-06-23 07:09:21.975552	2026-06-23 07:09:21.975552	\N	\N
902	SPMEBA0012	\N	\N	Outside Temp & RH	Outside Temp & RH KLU 100 Produal	UTILITY	T36	0.00	0	0	0	0	\N	2026-06-23 07:09:21.975552	2026-06-23 07:09:21.975552	\N	\N
903	SPMEBA0013	\N	\N	SCR	SCR 1phase BRA4030 Conch	UTILITY	T37	0.00	0	0	0	0	\N	2026-06-23 07:09:21.975552	2026-06-23 07:09:21.975552	\N	\N
904	SPMEBA0014	\N	\N	SCR	SCR 3phase 35A CR3-A4035C Conch	UTILITY	T38	0.00	0	0	0	0	\N	2026-06-23 07:09:21.975552	2026-06-23 07:09:21.975552	\N	\N
905	SPMEBA0015	\N	\N	SCR	SCR 3phase 75A CR3-A4075C Conch	UTILITY	T39	0.00	0	0	0	0	\N	2026-06-23 07:09:21.975552	2026-06-23 07:09:21.975552	\N	\N
906	SPMEFI0261	\N	\N	Medium Filter	Medium Filter 24 x 24 x 12 Single Frame 150Celcius	FBD	W2	2400000.00	85	18	23	308	/static/uploads/SPMEFI0261.jpg	2026-06-23 07:09:21.975552	2026-06-23 07:09:21.975552	\N	\N
907	SPMEHO0074	\N	\N	Hose	Hose 6 ft Auto (p/n KNHA0623) Keystone	PAMPAC	W2	0.00	0	1	2	0	\N	2026-06-23 07:09:21.975552	2026-06-23 07:09:21.975552	\N	\N
908	SPMETA0020	\N	\N	Isolator Tahan Panas	Isolator Tahan Panas (tanpa lem)	CHIMEI	W2	0.00	0	0	0	6	\N	2026-06-23 07:09:21.975552	2026-06-23 07:09:21.975552	\N	\N
909	SPTYMO0001	\N	\N	SERVO MOTOR	Servo motor mistubishi HG-KR73	TOYO	Z1	11000000.00	1	1	2	1	/static/uploads/SPTYMO0001.jpg	2026-06-23 07:09:21.975552	2026-06-23 07:09:21.975552	\N	\N
910	SPTYMO0002	\N	\N	SERVO MOTOR	Servo motor mistubishi HG-KR43	TOYO	Z1	8000000.00	1	1	2	0	/static/uploads/SPTYMO0002.jpg	2026-06-23 07:09:21.975552	2026-06-23 07:09:21.975552	\N	\N
911	SPTYMO0003	\N	\N	SERVO MOTOR	Servo motor mistubishi HG-KR23	TOYO	Z1	0.00	1	1	2	0	/static/uploads/SPTYMO0003.jpg	2026-06-23 07:09:21.975552	2026-06-23 07:09:21.975552	\N	\N
912	SPPMGE0011	\N	\N	Gearbox	Gear Box NMRV050  i:30 Motovario	PAMPAC	Z2	2090000.00	1	1	2	0	/static/uploads/SPPMGE0011.jpg	2026-06-23 07:09:21.975552	2026-06-23 07:09:21.975552	\N	\N
913	SPWRCL0001	\N	\N	Electromagnetic Clutch	Electromagnetic Clutch S.S50-K26 24V 11W  PE-EI	CHIMEI	Z2	6750000.00	1	0	1	2	/static/uploads/SPWRCL0001.jpg	2026-06-23 07:09:21.975552	2026-06-23 07:09:21.975552	\N	\N
914	SPWRGE0001	\N	\N	Gearbox	Gear Box NMRV050  i:30 Motovario	CHIMEI	\N	0.00	0	1	2	0	\N	2026-06-23 07:09:21.975552	2026-06-23 07:09:21.975552	\N	\N
915	SPWRMO0002	\N	\N	Motor	Motor 0.25HP 0.18KW 1370RPM 3ph 220/380V TECO	CHIMEI	Z2	3500000.00	0	1	2	0	\N	2026-06-23 07:09:21.975552	2026-06-23 07:09:21.975552	\N	\N
916	SPSVGE0013	\N	\N	Planetary gearbox	Planetary Gear Box Cross Knife u/ shaft motor AS 19mm	RVS	Z2	38500000.00	1	0	1	2	/static/uploads/SPSVGE0013.jpg	2026-06-23 07:09:21.975552	2026-06-23 07:09:21.975552	\N	\N
917	SPSVGE0021	\N	\N	Gearbox	Gear Box SP075S-MF1-4-1E1 Alpha (Slider) suit to Motor 1FK7042	RVS	Z3	24160000.00	2	1	2	0	/static/uploads/SPSVGE0021.jpg	2026-06-23 07:09:21.975552	2026-06-23 07:09:21.975552	\N	\N
918	SPSVGE0022	\N	\N	Gearbox	Gear Box SP075S-MF1-10-1E1-2S Alpha (No Batch) suit to Motor 1FK7042	RVS	Z3	26500000.00	2	1	2	1	/static/uploads/SPSVGE0022.jpg	2026-06-23 07:09:21.975552	2026-06-23 07:09:21.975552	\N	\N
919	SPSVGE0023	\N	\N	Planetary gearbox	Gear Box SPC075S-MF2-14-0E0-1K01 Alpha (Sealing) suit to Motor 1FK7042 AS 19	RVS	Z5	49300000.00	1	1	2	1	/static/uploads/SPSVGE0023.jpg	2026-06-23 07:09:21.975552	2026-06-23 07:09:21.975552	\N	\N
920	SPSVMO0003	\N	\N	Servo motor	Servomotor 1FK7042-5AF71-IEA3 Siemens	RVS	Z5	34200000.00	1	1	2	1	/static/uploads/SPSVMO0003.jpg	2026-06-23 07:09:21.975552	2026-06-23 07:09:21.975552	\N	\N
921	SPSVMO0006	\N	\N	Servo Motor	Motor Servo 1FK7042-5AF71-EB3 Siemens	RVS	Z5	0.00	0	1	2	1	\N	2026-06-23 07:09:21.975552	2026-06-23 07:09:21.975552	\N	\N
922	SPTSFI0003	\N	\N	Filter Bag	Filter Bag Dalamatic 0.7 p/n2626511 Polyester Oleophobic Anti-Static EU Food Size: 495 mm W x 708 mm L	GEA	\N	0.00	0	1	2	2	\N	2026-06-23 07:09:21.975552	2026-06-23 07:09:21.975552	\N	\N
923	SPJSPPO0001	\N	\N	Pocket	Pocket Jinsung 80x75x78mm	Jinsung	F45	475000.00	1	10	30	38	\N	2026-06-23 07:09:21.975552	2026-06-23 07:09:21.975552	\N	\N
924	SPMERW0103	\N	\N	Limit Switch	Limit Switch AZ 16-12 ZVRK Scamersal	RVS	C42	0.00	0	1	2	0	\N	2026-06-23 07:09:41.022825	2026-06-23 07:09:41.022825	\N	\N
925	123456			test1	test1			0.00	30	0	0	0	/static/uploads/1782174681075705000.webp	2026-06-23 07:12:06.964514	2026-06-23 07:31:50.284938	/static/uploads/pdf_1782174681076233000.pdf	2026-06-23 07:31:50.284938
\.


--
-- Data for Name: stock_receivings; Type: TABLE DATA; Schema: public; Owner: sonyaalexandrapaleng
--

COPY public.stock_receivings (id, sparepart_id, no_po, vendor, jumlah, harga, tipe, keterangan, received_at, received_by, nama_item_snapshot, kode_oracle_snapshot) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: sonyaalexandrapaleng
--

COPY public.users (id, username, password_hash, full_name, role, division, id_card_number, telegram_chat_id, created_at) FROM stdin;
6	pemohon	$2a$10$cPFJszsDeKMMVH/H6fwYjeKn1kpbPVEeDXsg2pgDHaR8x3a6FUlo.	pemohon	pemohon	\N	CARD-USER-001	\N	2026-04-07 07:46:57.779141
3	mtc1	$2a$10$bn1l0FaUVF82WKl/qvrmweUWqkbDFEQaCjMYgY6Zp8uzOP4gh7dkG	jansen	spv_pemohon	MTC1,MTC2,UTL	CARD-SPV-MTC1	\N	2026-04-07 07:46:57.779141
5	utl	$2a$10$SbEwVFN9mKqnssfnAlx4M.hjqSp/0aQ.Bd.P/byxPjho8RjsWa66e	Olga	spv_pemohon	MTC2,UTL	CARD-SPV-UTL	\N	2026-04-07 07:46:57.779141
4	mtc2	$2a$10$mOsjtEuYBFf1qwfu1lnXKeDL.ID9Bv7Qb306.zZPPvLdQLkIzkfV.	Rizky	spv_pemohon	MTC1,MTC2	CARD-SPV-MTC2	\N	2026-04-07 07:46:57.779141
2	spvsp	$2a$10$vuGd3XNCxq8zyRyg1BhUAeS2KjcxirPyVFIg4XcDQtwPXzH/SbAza	Hasna	spv_sp	MTC2	\N	\N	2026-04-07 07:46:57.779141
15	sonyatest	$2a$10$YmQ7djzo3d.HsH7r5WYe/uqrnTWRyJncJVMtbVdEKb.GmKm.Q6wju	sonyatesting	spv_pemohon	BM	\N	\N	2026-06-09 10:10:19.746891
1	adminsp	$2a$10$qiS4UhPOsnM/tiCScDKwpee3M5Xi9cE2pS84VRV.3CNJjn6n4YB3S	Elika	admin_sp	\N	CARD-ADMIN-001	\N	2026-04-07 07:46:57.779141
\.


--
-- Data for Name: validations; Type: TABLE DATA; Schema: public; Owner: sonyaalexandrapaleng
--

COPY public.validations (id, request_id, stage, validator_id, action, reason, validated_at) FROM stdin;
1	1	1	1	approved		2026-06-29 15:28:41.705573
2	3	1	1	approved		2026-07-09 15:25:22.138154
3	2	1	1	approved		2026-07-09 15:25:26.880137
4	3	2	2	approved		2026-07-13 07:47:22.512984
\.


--
-- Name: activity_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sonyaalexandrapaleng
--

SELECT pg_catalog.setval('public.activity_logs_id_seq', 137, true);


--
-- Name: employee_id_cards_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sonyaalexandrapaleng
--

SELECT pg_catalog.setval('public.employee_id_cards_id_seq', 26, true);


--
-- Name: non_inventory_approvals_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sonyaalexandrapaleng
--

SELECT pg_catalog.setval('public.non_inventory_approvals_id_seq', 3, true);


--
-- Name: non_inventory_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sonyaalexandrapaleng
--

SELECT pg_catalog.setval('public.non_inventory_items_id_seq', 5, true);


--
-- Name: non_inventory_requests_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sonyaalexandrapaleng
--

SELECT pg_catalog.setval('public.non_inventory_requests_id_seq', 2, true);


--
-- Name: notifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sonyaalexandrapaleng
--

SELECT pg_catalog.setval('public.notifications_id_seq', 23, true);


--
-- Name: request_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sonyaalexandrapaleng
--

SELECT pg_catalog.setval('public.request_items_id_seq', 3, true);


--
-- Name: request_order_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sonyaalexandrapaleng
--

SELECT pg_catalog.setval('public.request_order_items_id_seq', 1, false);


--
-- Name: request_orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sonyaalexandrapaleng
--

SELECT pg_catalog.setval('public.request_orders_id_seq', 1, false);


--
-- Name: requests_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sonyaalexandrapaleng
--

SELECT pg_catalog.setval('public.requests_id_seq', 3, true);


--
-- Name: spareparts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sonyaalexandrapaleng
--

SELECT pg_catalog.setval('public.spareparts_id_seq', 926, true);


--
-- Name: stock_receivings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sonyaalexandrapaleng
--

SELECT pg_catalog.setval('public.stock_receivings_id_seq', 1, false);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sonyaalexandrapaleng
--

SELECT pg_catalog.setval('public.users_id_seq', 15, true);


--
-- Name: validations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sonyaalexandrapaleng
--

SELECT pg_catalog.setval('public.validations_id_seq', 4, true);


--
-- Name: activity_logs activity_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER TABLE ONLY public.activity_logs
    ADD CONSTRAINT activity_logs_pkey PRIMARY KEY (id);


--
-- Name: bpjt_daily_counter bpjt_daily_counter_pkey; Type: CONSTRAINT; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER TABLE ONLY public.bpjt_daily_counter
    ADD CONSTRAINT bpjt_daily_counter_pkey PRIMARY KEY (counter_date);


--
-- Name: employee_id_cards employee_id_cards_fingerprint_id_key; Type: CONSTRAINT; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER TABLE ONLY public.employee_id_cards
    ADD CONSTRAINT employee_id_cards_fingerprint_id_key UNIQUE (fingerprint_id);


--
-- Name: employee_id_cards employee_id_cards_id_card_number_key; Type: CONSTRAINT; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER TABLE ONLY public.employee_id_cards
    ADD CONSTRAINT employee_id_cards_id_card_number_key UNIQUE (id_card_number);


--
-- Name: employee_id_cards employee_id_cards_pkey; Type: CONSTRAINT; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER TABLE ONLY public.employee_id_cards
    ADD CONSTRAINT employee_id_cards_pkey PRIMARY KEY (id);


--
-- Name: non_inventory_approvals non_inventory_approvals_pkey; Type: CONSTRAINT; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER TABLE ONLY public.non_inventory_approvals
    ADD CONSTRAINT non_inventory_approvals_pkey PRIMARY KEY (id);


--
-- Name: non_inventory_items non_inventory_items_pkey; Type: CONSTRAINT; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER TABLE ONLY public.non_inventory_items
    ADD CONSTRAINT non_inventory_items_pkey PRIMARY KEY (id);


--
-- Name: non_inventory_requests non_inventory_requests_no_bpjt_key; Type: CONSTRAINT; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER TABLE ONLY public.non_inventory_requests
    ADD CONSTRAINT non_inventory_requests_no_bpjt_key UNIQUE (no_bpjt);


--
-- Name: non_inventory_requests non_inventory_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER TABLE ONLY public.non_inventory_requests
    ADD CONSTRAINT non_inventory_requests_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: request_items request_items_pkey; Type: CONSTRAINT; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER TABLE ONLY public.request_items
    ADD CONSTRAINT request_items_pkey PRIMARY KEY (id);


--
-- Name: request_order_items request_order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER TABLE ONLY public.request_order_items
    ADD CONSTRAINT request_order_items_pkey PRIMARY KEY (id);


--
-- Name: request_orders request_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER TABLE ONLY public.request_orders
    ADD CONSTRAINT request_orders_pkey PRIMARY KEY (id);


--
-- Name: requests requests_pkey; Type: CONSTRAINT; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER TABLE ONLY public.requests
    ADD CONSTRAINT requests_pkey PRIMARY KEY (id);


--
-- Name: rfid_sessions rfid_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER TABLE ONLY public.rfid_sessions
    ADD CONSTRAINT rfid_sessions_pkey PRIMARY KEY (session_id);


--
-- Name: spareparts spareparts_kode_oracle_key; Type: CONSTRAINT; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER TABLE ONLY public.spareparts
    ADD CONSTRAINT spareparts_kode_oracle_key UNIQUE (kode_oracle);


--
-- Name: spareparts spareparts_pkey; Type: CONSTRAINT; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER TABLE ONLY public.spareparts
    ADD CONSTRAINT spareparts_pkey PRIMARY KEY (id);


--
-- Name: stock_receivings stock_receivings_pkey; Type: CONSTRAINT; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER TABLE ONLY public.stock_receivings
    ADD CONSTRAINT stock_receivings_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: validations validations_pkey; Type: CONSTRAINT; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER TABLE ONLY public.validations
    ADD CONSTRAINT validations_pkey PRIMARY KEY (id);


--
-- Name: idx_activity_logs_created_at; Type: INDEX; Schema: public; Owner: sonyaalexandrapaleng
--

CREATE INDEX idx_activity_logs_created_at ON public.activity_logs USING btree (created_at);


--
-- Name: idx_activity_logs_user_id; Type: INDEX; Schema: public; Owner: sonyaalexandrapaleng
--

CREATE INDEX idx_activity_logs_user_id ON public.activity_logs USING btree (user_id);


--
-- Name: idx_emp_fingerprint_id; Type: INDEX; Schema: public; Owner: sonyaalexandrapaleng
--

CREATE INDEX idx_emp_fingerprint_id ON public.employee_id_cards USING btree (fingerprint_id) WHERE (fingerprint_id IS NOT NULL);


--
-- Name: idx_employee_fingerprint_id; Type: INDEX; Schema: public; Owner: sonyaalexandrapaleng
--

CREATE INDEX idx_employee_fingerprint_id ON public.employee_id_cards USING btree (fingerprint_id) WHERE (fingerprint_id IS NOT NULL);


--
-- Name: idx_employee_id_cards_active; Type: INDEX; Schema: public; Owner: sonyaalexandrapaleng
--

CREATE INDEX idx_employee_id_cards_active ON public.employee_id_cards USING btree (is_active);


--
-- Name: idx_employee_id_cards_number; Type: INDEX; Schema: public; Owner: sonyaalexandrapaleng
--

CREATE INDEX idx_employee_id_cards_number ON public.employee_id_cards USING btree (id_card_number);


--
-- Name: idx_ni_approvals_req; Type: INDEX; Schema: public; Owner: sonyaalexandrapaleng
--

CREATE INDEX idx_ni_approvals_req ON public.non_inventory_approvals USING btree (request_id);


--
-- Name: idx_ni_items_request; Type: INDEX; Schema: public; Owner: sonyaalexandrapaleng
--

CREATE INDEX idx_ni_items_request ON public.non_inventory_items USING btree (request_id);


--
-- Name: idx_ni_requests_divisi; Type: INDEX; Schema: public; Owner: sonyaalexandrapaleng
--

CREATE INDEX idx_ni_requests_divisi ON public.non_inventory_requests USING btree (seksi_divisi);


--
-- Name: idx_ni_requests_pemohon; Type: INDEX; Schema: public; Owner: sonyaalexandrapaleng
--

CREATE INDEX idx_ni_requests_pemohon ON public.non_inventory_requests USING btree (pemohon_id);


--
-- Name: idx_ni_requests_status; Type: INDEX; Schema: public; Owner: sonyaalexandrapaleng
--

CREATE INDEX idx_ni_requests_status ON public.non_inventory_requests USING btree (status);


--
-- Name: idx_notifications_is_read; Type: INDEX; Schema: public; Owner: sonyaalexandrapaleng
--

CREATE INDEX idx_notifications_is_read ON public.notifications USING btree (is_read);


--
-- Name: idx_notifications_user_id; Type: INDEX; Schema: public; Owner: sonyaalexandrapaleng
--

CREATE INDEX idx_notifications_user_id ON public.notifications USING btree (user_id);


--
-- Name: idx_request_items_request_id; Type: INDEX; Schema: public; Owner: sonyaalexandrapaleng
--

CREATE INDEX idx_request_items_request_id ON public.request_items USING btree (request_id);


--
-- Name: idx_request_orders_pemohon; Type: INDEX; Schema: public; Owner: sonyaalexandrapaleng
--

CREATE INDEX idx_request_orders_pemohon ON public.request_orders USING btree (pemohon_id);


--
-- Name: idx_request_orders_status; Type: INDEX; Schema: public; Owner: sonyaalexandrapaleng
--

CREATE INDEX idx_request_orders_status ON public.request_orders USING btree (status);


--
-- Name: idx_requests_current_stage; Type: INDEX; Schema: public; Owner: sonyaalexandrapaleng
--

CREATE INDEX idx_requests_current_stage ON public.requests USING btree (current_stage);


--
-- Name: idx_requests_division; Type: INDEX; Schema: public; Owner: sonyaalexandrapaleng
--

CREATE INDEX idx_requests_division ON public.requests USING btree (division);


--
-- Name: idx_requests_pemohon_id; Type: INDEX; Schema: public; Owner: sonyaalexandrapaleng
--

CREATE INDEX idx_requests_pemohon_id ON public.requests USING btree (pemohon_id);


--
-- Name: idx_requests_status; Type: INDEX; Schema: public; Owner: sonyaalexandrapaleng
--

CREATE INDEX idx_requests_status ON public.requests USING btree (status);


--
-- Name: idx_ro_items_order; Type: INDEX; Schema: public; Owner: sonyaalexandrapaleng
--

CREATE INDEX idx_ro_items_order ON public.request_order_items USING btree (request_order_id);


--
-- Name: idx_spareparts_deleted_at; Type: INDEX; Schema: public; Owner: sonyaalexandrapaleng
--

CREATE INDEX idx_spareparts_deleted_at ON public.spareparts USING btree (deleted_at);


--
-- Name: idx_spareparts_jenis_mesin; Type: INDEX; Schema: public; Owner: sonyaalexandrapaleng
--

CREATE INDEX idx_spareparts_jenis_mesin ON public.spareparts USING btree (jenis_mesin);


--
-- Name: idx_spareparts_kode_oracle; Type: INDEX; Schema: public; Owner: sonyaalexandrapaleng
--

CREATE INDEX idx_spareparts_kode_oracle ON public.spareparts USING btree (kode_oracle);


--
-- Name: idx_spareparts_kode_rfid; Type: INDEX; Schema: public; Owner: sonyaalexandrapaleng
--

CREATE INDEX idx_spareparts_kode_rfid ON public.spareparts USING btree (kode_rfid);


--
-- Name: idx_stock_receivings_received_at; Type: INDEX; Schema: public; Owner: sonyaalexandrapaleng
--

CREATE INDEX idx_stock_receivings_received_at ON public.stock_receivings USING btree (received_at);


--
-- Name: idx_stock_receivings_sparepart_id; Type: INDEX; Schema: public; Owner: sonyaalexandrapaleng
--

CREATE INDEX idx_stock_receivings_sparepart_id ON public.stock_receivings USING btree (sparepart_id);


--
-- Name: idx_validations_request_id; Type: INDEX; Schema: public; Owner: sonyaalexandrapaleng
--

CREATE INDEX idx_validations_request_id ON public.validations USING btree (request_id);


--
-- Name: activity_logs activity_logs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER TABLE ONLY public.activity_logs
    ADD CONSTRAINT activity_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: employee_id_cards employee_id_cards_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER TABLE ONLY public.employee_id_cards
    ADD CONSTRAINT employee_id_cards_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: non_inventory_approvals non_inventory_approvals_approver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER TABLE ONLY public.non_inventory_approvals
    ADD CONSTRAINT non_inventory_approvals_approver_id_fkey FOREIGN KEY (approver_id) REFERENCES public.users(id);


--
-- Name: non_inventory_approvals non_inventory_approvals_request_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER TABLE ONLY public.non_inventory_approvals
    ADD CONSTRAINT non_inventory_approvals_request_id_fkey FOREIGN KEY (request_id) REFERENCES public.non_inventory_requests(id) ON DELETE CASCADE;


--
-- Name: non_inventory_items non_inventory_items_request_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER TABLE ONLY public.non_inventory_items
    ADD CONSTRAINT non_inventory_items_request_id_fkey FOREIGN KEY (request_id) REFERENCES public.non_inventory_requests(id) ON DELETE CASCADE;


--
-- Name: non_inventory_requests non_inventory_requests_pemohon_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER TABLE ONLY public.non_inventory_requests
    ADD CONSTRAINT non_inventory_requests_pemohon_id_fkey FOREIGN KEY (pemohon_id) REFERENCES public.users(id);


--
-- Name: notifications notifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: request_items request_items_request_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER TABLE ONLY public.request_items
    ADD CONSTRAINT request_items_request_id_fkey FOREIGN KEY (request_id) REFERENCES public.requests(id) ON DELETE CASCADE;


--
-- Name: request_items request_items_sparepart_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER TABLE ONLY public.request_items
    ADD CONSTRAINT request_items_sparepart_id_fkey FOREIGN KEY (sparepart_id) REFERENCES public.spareparts(id);


--
-- Name: request_order_items request_order_items_request_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER TABLE ONLY public.request_order_items
    ADD CONSTRAINT request_order_items_request_order_id_fkey FOREIGN KEY (request_order_id) REFERENCES public.request_orders(id) ON DELETE CASCADE;


--
-- Name: request_order_items request_order_items_sparepart_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER TABLE ONLY public.request_order_items
    ADD CONSTRAINT request_order_items_sparepart_id_fkey FOREIGN KEY (sparepart_id) REFERENCES public.spareparts(id) ON DELETE SET NULL;


--
-- Name: request_orders request_orders_pemohon_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER TABLE ONLY public.request_orders
    ADD CONSTRAINT request_orders_pemohon_id_fkey FOREIGN KEY (pemohon_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: request_orders request_orders_sparepart_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER TABLE ONLY public.request_orders
    ADD CONSTRAINT request_orders_sparepart_id_fkey FOREIGN KEY (sparepart_id) REFERENCES public.spareparts(id) ON DELETE SET NULL;


--
-- Name: requests requests_pemohon_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER TABLE ONLY public.requests
    ADD CONSTRAINT requests_pemohon_id_fkey FOREIGN KEY (pemohon_id) REFERENCES public.users(id);


--
-- Name: rfid_sessions rfid_sessions_pemohon_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER TABLE ONLY public.rfid_sessions
    ADD CONSTRAINT rfid_sessions_pemohon_id_fkey FOREIGN KEY (pemohon_id) REFERENCES public.users(id);


--
-- Name: rfid_sessions rfid_sessions_request_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER TABLE ONLY public.rfid_sessions
    ADD CONSTRAINT rfid_sessions_request_id_fkey FOREIGN KEY (request_id) REFERENCES public.requests(id);


--
-- Name: stock_receivings stock_receivings_received_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER TABLE ONLY public.stock_receivings
    ADD CONSTRAINT stock_receivings_received_by_fkey FOREIGN KEY (received_by) REFERENCES public.users(id);


--
-- Name: stock_receivings stock_receivings_sparepart_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER TABLE ONLY public.stock_receivings
    ADD CONSTRAINT stock_receivings_sparepart_id_fkey FOREIGN KEY (sparepart_id) REFERENCES public.spareparts(id);


--
-- Name: validations validations_request_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER TABLE ONLY public.validations
    ADD CONSTRAINT validations_request_id_fkey FOREIGN KEY (request_id) REFERENCES public.requests(id) ON DELETE CASCADE;


--
-- Name: validations validations_validator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sonyaalexandrapaleng
--

ALTER TABLE ONLY public.validations
    ADD CONSTRAINT validations_validator_id_fkey FOREIGN KEY (validator_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

\unrestrict xo5hMKcd1HudlgBJQUsWy0tfgzAUOzYWOiUHbs7mT1O0BvmPn5G8gWxR7S6Aena

