

\restrict R9fGB7R371XuubioaUnrs1Y6aobbRzAeob8g80rEGr6YS5RQIBdefD7xwAc8UfC

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

\unrestrict R9fGB7R371XuubioaUnrs1Y6aobbRzAeob8g80rEGr6YS5RQIBdefD7xwAc8UfC

