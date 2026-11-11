-- Staged Chronis bootstrap: create an empty schema or validate an existing one.
DO $chronis_bootstrap$
DECLARE missing_column text;
BEGIN
    PERFORM pg_advisory_xact_lock(hashtext('chronis-bootstrap:' || current_database() || ':' || current_schema()));
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema=current_schema() AND table_type='BASE TABLE') THEN
        SELECT required.table_name || '.' || required.column_name INTO missing_column
        FROM (VALUES
        ('attendance_sessions','id'),
        ('attendance_sessions','user_id'),
        ('attendance_sessions','work_date'),
        ('attendance_sessions','check_in_time'),
        ('attendance_sessions','check_out_time'),
        ('attendance_sessions','status'),
        ('attendance_sessions','attendance_duration_minutes'),
        ('attendance_sessions','break_duration_minutes'),
        ('attendance_sessions','net_working_duration_minutes'),
        ('attendance_sessions','overtime_duration_minutes'),
        ('attendance_sessions','scheduled_duration_minutes'),
        ('attendance_sessions','is_late'),
        ('attendance_sessions','early_departure'),
        ('attendance_sessions','deleted_at'),
        ('attendance_sessions','created_by'),
        ('attendance_sessions','created_at'),
        ('attendance_sessions','updated_by'),
        ('attendance_sessions','updated_at'),
        ('attendance_sessions','version'),
        ('break_sessions','id'),
        ('break_sessions','attendance_session_id'),
        ('break_sessions','break_type'),
        ('break_sessions','start_time'),
        ('break_sessions','end_time'),
        ('break_sessions','duration_minutes'),
        ('break_sessions','reason'),
        ('break_sessions','created_by'),
        ('break_sessions','created_at'),
        ('break_sessions','updated_by'),
        ('break_sessions','updated_at'),
        ('break_sessions','version'),
        ('configuration','id'),
        ('configuration','key'),
        ('configuration','value'),
        ('configuration','description'),
        ('configuration','created_by'),
        ('configuration','created_at'),
        ('configuration','updated_by'),
        ('configuration','updated_at'),
        ('configuration','version'),
        ('daily_reports','id'),
        ('daily_reports','user_id'),
        ('daily_reports','report_date'),
        ('daily_reports','attendance_hours'),
        ('daily_reports','break_hours'),
        ('daily_reports','net_working_hours'),
        ('daily_reports','overtime_hours'),
        ('daily_reports','completed_work'),
        ('daily_reports','in_progress_work'),
        ('daily_reports','pending_work'),
        ('daily_reports','blockers_challenges'),
        ('daily_reports','tomorrow_plans'),
        ('daily_reports','status'),
        ('daily_reports','manager_feedback'),
        ('daily_reports','reviewed_by'),
        ('daily_reports','reviewed_at'),
        ('daily_reports','revision_number'),
        ('daily_reports','created_by'),
        ('daily_reports','created_at'),
        ('daily_reports','updated_by'),
        ('daily_reports','updated_at'),
        ('daily_reports','version'),
        ('engineering_client_records','user_id'),
        ('engineering_client_records','record_type'),
        ('engineering_client_records','record_key'),
        ('engineering_client_records','version'),
        ('engineering_client_records','payload'),
        ('engineering_client_records','updated_at'),
        ('engineering_client_revisions','id'),
        ('engineering_client_revisions','user_id'),
        ('engineering_client_revisions','record_type'),
        ('engineering_client_revisions','record_key'),
        ('engineering_client_revisions','version'),
        ('engineering_client_revisions','payload'),
        ('engineering_client_revisions','recorded_at'),
        ('engineering_curricula','plan_id'),
        ('engineering_curricula','payload'),
        ('engineering_curricula','updated_at'),
        ('engineering_events','id'),
        ('engineering_events','user_id'),
        ('engineering_events','event_type'),
        ('engineering_events','work_date'),
        ('engineering_events','detail'),
        ('engineering_events','recorded_at'),
        ('engineering_report_submissions','id'),
        ('engineering_report_submissions','user_id'),
        ('engineering_report_submissions','plan_id'),
        ('engineering_report_submissions','day_number'),
        ('engineering_report_submissions','version'),
        ('engineering_report_submissions','payload'),
        ('engineering_report_submissions','submitted_at'),
        ('engineering_work','id'),
        ('engineering_work','user_id'),
        ('engineering_work','plan_id'),
        ('engineering_work','day_number'),
        ('engineering_work','domain'),
        ('engineering_work','version'),
        ('engineering_work','payload'),
        ('engineering_work','updated_at'),
        ('engineering_work_revisions','id'),
        ('engineering_work_revisions','work_id'),
        ('engineering_work_revisions','user_id'),
        ('engineering_work_revisions','mutation_id'),
        ('engineering_work_revisions','version'),
        ('engineering_work_revisions','payload'),
        ('engineering_work_revisions','recorded_at'),
        ('engineering_workspace_records','user_id'),
        ('engineering_workspace_records','record_type'),
        ('engineering_workspace_records','record_key'),
        ('engineering_workspace_records','version'),
        ('engineering_workspace_records','payload'),
        ('engineering_workspace_records','updated_at'),
        ('notifications','id'),
        ('notifications','recipient_id'),
        ('notifications','sender_id'),
        ('notifications','title'),
        ('notifications','body'),
        ('notifications','type'),
        ('notifications','related_entity_type'),
        ('notifications','related_entity_id'),
        ('notifications','read_status'),
        ('notifications','read_at'),
        ('notifications','scheduled_for'),
        ('notifications','sent_at'),
        ('notifications','created_by'),
        ('notifications','created_at'),
        ('notifications','updated_by'),
        ('notifications','updated_at'),
        ('notifications','version'),
        ('project_members','id'),
        ('project_members','project_id'),
        ('project_members','user_id'),
        ('project_members','assigned_at'),
        ('project_members','created_by'),
        ('project_members','created_at'),
        ('project_members','updated_by'),
        ('project_members','updated_at'),
        ('project_members','version'),
        ('projects','id'),
        ('projects','project_code'),
        ('projects','name'),
        ('projects','description'),
        ('projects','owner_id'),
        ('projects','start_date'),
        ('projects','target_completion_date'),
        ('projects','status'),
        ('projects','priority'),
        ('projects','created_by'),
        ('projects','created_at'),
        ('projects','updated_by'),
        ('projects','updated_at'),
        ('projects','version'),
        ('refresh_tokens','id'),
        ('refresh_tokens','user_id'),
        ('refresh_tokens','token'),
        ('refresh_tokens','expiry_date'),
        ('refresh_tokens','revoked'),
        ('refresh_tokens','created_by'),
        ('refresh_tokens','created_at'),
        ('refresh_tokens','updated_by'),
        ('refresh_tokens','updated_at'),
        ('refresh_tokens','version'),
        ('retired_feature_records','source_table'),
        ('retired_feature_records','source_id'),
        ('retired_feature_records','payload'),
        ('retired_feature_records','archived_at'),
        ('signup_email_verifications','id'),
        ('signup_email_verifications','email'),
        ('signup_email_verifications','code_hash'),
        ('signup_email_verifications','code_expires_at'),
        ('signup_email_verifications','verified_at'),
        ('signup_email_verifications','token_hash'),
        ('signup_email_verifications','proof_expires_at'),
        ('signup_email_verifications','sent_at'),
        ('signup_email_verifications','window_started_at'),
        ('signup_email_verifications','send_count'),
        ('signup_email_verifications','attempts'),
        ('signup_email_verifications','consumed'),
        ('tasks','id'),
        ('tasks','task_code'),
        ('tasks','title'),
        ('tasks','description'),
        ('tasks','project_id'),
        ('tasks','assigned_to'),
        ('tasks','assigned_by'),
        ('tasks','parent_task_id'),
        ('tasks','priority'),
        ('tasks','status'),
        ('tasks','planned_start_date'),
        ('tasks','deadline'),
        ('tasks','estimated_duration_minutes'),
        ('tasks','actual_time_spent_minutes'),
        ('tasks','progress_percentage'),
        ('tasks','completion_percentage'),
        ('tasks','completed_at'),
        ('tasks','created_by'),
        ('tasks','created_at'),
        ('tasks','updated_by'),
        ('tasks','updated_at'),
        ('tasks','version'),
        ('users','id'),
        ('users','username'),
        ('users','email'),
        ('users','password'),
        ('users','enabled'),
        ('users','account_non_expired'),
        ('users','account_non_locked'),
        ('users','credentials_non_expired'),
        ('users','password_changed_at'),
        ('users','created_by'),
        ('users','created_at'),
        ('users','updated_by'),
        ('users','updated_at'),
        ('users','version'),
        ('users','first_name'),
        ('users','last_name'),
        ('users','password_reset_token'),
        ('users','password_reset_token_expiry'),
        ('users','email_verified'),
        ('users','email_verification_code_hash'),
        ('users','email_verification_code_expiry'),
        ('users','email_verification_sent_at'),
        ('users','email_verification_attempts'),
        ('users','google_subject'),
        ('users','facebook_subject'),
        ('users','timezone'),
        ('users','profile_picture_url'),
        ('work_sessions','id'),
        ('work_sessions','user_id'),
        ('work_sessions','session_start'),
        ('work_sessions','session_end'),
        ('work_sessions','elapsed_duration_minutes'),
        ('work_sessions','productive_duration_minutes'),
        ('work_sessions','status'),
        ('work_sessions','created_by'),
        ('work_sessions','created_at'),
        ('work_sessions','updated_by'),
        ('work_sessions','updated_at'),
        ('work_sessions','version'),
        ('work_updates','id'),
        ('work_updates','user_id'),
        ('work_updates','work_date'),
        ('work_updates','project_id'),
        ('work_updates','task_id'),
        ('work_updates','work_category'),
        ('work_updates','work_description'),
        ('work_updates','start_time'),
        ('work_updates','end_time'),
        ('work_updates','time_spent_minutes'),
        ('work_updates','progress_percentage'),
        ('work_updates','work_completed'),
        ('work_updates','challenges'),
        ('work_updates','blockers'),
        ('work_updates','next_steps'),
        ('work_updates','attachment_url'),
        ('work_updates','status'),
        ('work_updates','created_by'),
        ('work_updates','created_at'),
        ('work_updates','updated_by'),
        ('work_updates','updated_at'),
        ('work_updates','version')
        ) AS required(table_name,column_name)
        WHERE NOT EXISTS (SELECT 1 FROM information_schema.columns c WHERE c.table_schema=current_schema()
             AND c.table_name=required.table_name AND c.column_name=required.column_name)
        LIMIT 1;
        IF missing_column IS NOT NULL THEN
            RAISE EXCEPTION 'Existing Chronis schema is incomplete or older: missing %', missing_column;
        END IF;
        IF NOT EXISTS (SELECT 1 FROM engineering_curricula WHERE plan_id='chronis-ai-engineering-2026-11-05'
            AND jsonb_array_length(payload->'days')=92 AND jsonb_array_length(payload->'projects')=50
            AND jsonb_array_length(payload->'phases')=8) THEN
            RAISE EXCEPTION 'Existing Chronis roadmap is missing or invalid';
        END IF;
        RETURN;
    END IF;
CREATE TABLE attendance_sessions (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    work_date date NOT NULL,
    check_in_time timestamp with time zone,
    check_out_time timestamp with time zone,
    status character varying(20) DEFAULT 'ABSENT'::character varying NOT NULL,
    attendance_duration_minutes bigint,
    break_duration_minutes bigint,
    net_working_duration_minutes bigint,
    overtime_duration_minutes bigint,
    scheduled_duration_minutes bigint,
    is_late boolean DEFAULT false NOT NULL,
    early_departure boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone,
    created_by character varying(100),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by character varying(100),
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    version bigint DEFAULT 0 NOT NULL,
    CONSTRAINT ck_attendance_order CHECK (((check_out_time IS NULL) OR (check_out_time >= check_in_time)))
);



CREATE SEQUENCE attendance_sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



ALTER SEQUENCE attendance_sessions_id_seq OWNED BY attendance_sessions.id;



CREATE TABLE break_sessions (
    id bigint NOT NULL,
    attendance_session_id bigint NOT NULL,
    break_type character varying(20) DEFAULT 'SHORT'::character varying NOT NULL,
    start_time timestamp with time zone NOT NULL,
    end_time timestamp with time zone,
    duration_minutes bigint,
    reason character varying(500),
    created_by character varying(100),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by character varying(100),
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    version bigint DEFAULT 0 NOT NULL,
    CONSTRAINT ck_break_order CHECK (((end_time IS NULL) OR (end_time >= start_time)))
);



CREATE SEQUENCE break_sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



ALTER SEQUENCE break_sessions_id_seq OWNED BY break_sessions.id;



CREATE TABLE configuration (
    id bigint NOT NULL,
    key character varying(200) NOT NULL,
    value character varying(2000),
    description character varying(500),
    created_by character varying(100),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by character varying(100),
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    version bigint DEFAULT 0 NOT NULL
);



CREATE SEQUENCE configuration_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



ALTER SEQUENCE configuration_id_seq OWNED BY configuration.id;



CREATE TABLE daily_reports (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    report_date date NOT NULL,
    attendance_hours double precision,
    break_hours double precision,
    net_working_hours double precision,
    overtime_hours double precision,
    completed_work character varying(2000),
    in_progress_work character varying(2000),
    pending_work character varying(2000),
    blockers_challenges character varying(2000),
    tomorrow_plans character varying(2000),
    status character varying(30) DEFAULT 'DRAFT'::character varying NOT NULL,
    manager_feedback character varying(2000),
    reviewed_by bigint,
    reviewed_at timestamp without time zone,
    revision_number integer DEFAULT 0 NOT NULL,
    created_by character varying(100),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by character varying(100),
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    version bigint DEFAULT 0 NOT NULL
);



CREATE SEQUENCE daily_reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



ALTER SEQUENCE daily_reports_id_seq OWNED BY daily_reports.id;



CREATE TABLE engineering_client_records (
    user_id bigint NOT NULL,
    record_type character varying(40) NOT NULL,
    record_key character varying(120) NOT NULL,
    version bigint DEFAULT 1 NOT NULL,
    payload jsonb NOT NULL,
    updated_at timestamp with time zone NOT NULL
);



CREATE TABLE engineering_client_revisions (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    record_type character varying(40) NOT NULL,
    record_key character varying(120) NOT NULL,
    version bigint NOT NULL,
    payload jsonb NOT NULL,
    recorded_at timestamp with time zone NOT NULL
);



CREATE SEQUENCE engineering_client_revisions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



ALTER SEQUENCE engineering_client_revisions_id_seq OWNED BY engineering_client_revisions.id;



CREATE TABLE engineering_curricula (
    plan_id character varying(100) NOT NULL,
    payload jsonb NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);



CREATE TABLE engineering_events (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    event_type character varying(80) NOT NULL,
    work_date date NOT NULL,
    detail character varying(2000) NOT NULL,
    recorded_at timestamp with time zone NOT NULL
);



CREATE SEQUENCE engineering_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



ALTER SEQUENCE engineering_events_id_seq OWNED BY engineering_events.id;



CREATE TABLE engineering_report_submissions (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    plan_id character varying(100) NOT NULL,
    day_number integer NOT NULL,
    version integer NOT NULL,
    payload jsonb NOT NULL,
    submitted_at timestamp with time zone NOT NULL,
    CONSTRAINT engineering_report_submissions_day_number_check CHECK (((day_number >= 1) AND (day_number <= 92)))
);



CREATE SEQUENCE engineering_report_submissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



ALTER SEQUENCE engineering_report_submissions_id_seq OWNED BY engineering_report_submissions.id;



CREATE TABLE engineering_work (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    plan_id character varying(100) NOT NULL,
    day_number integer NOT NULL,
    domain character varying(30) NOT NULL,
    version bigint DEFAULT 1 NOT NULL,
    payload jsonb NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    CONSTRAINT engineering_work_day_number_check CHECK (((day_number >= 1) AND (day_number <= 92))),
    CONSTRAINT engineering_work_domain_check CHECK (((domain)::text = ANY (ARRAY[('CONCEPT'::character varying)::text, ('BASIC_CODING'::character varying)::text, ('SCENARIO'::character varying)::text, ('PROJECT'::character varying)::text, ('INTERVIEW'::character varying)::text, ('REVIEW'::character varying)::text])))
);



CREATE SEQUENCE engineering_work_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



ALTER SEQUENCE engineering_work_id_seq OWNED BY engineering_work.id;



CREATE TABLE engineering_work_revisions (
    id bigint NOT NULL,
    work_id bigint NOT NULL,
    user_id bigint NOT NULL,
    mutation_id uuid NOT NULL,
    version bigint NOT NULL,
    payload jsonb NOT NULL,
    recorded_at timestamp with time zone NOT NULL
);



CREATE SEQUENCE engineering_work_revisions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



ALTER SEQUENCE engineering_work_revisions_id_seq OWNED BY engineering_work_revisions.id;



CREATE TABLE engineering_workspace_records (
    user_id bigint NOT NULL,
    record_type character varying(32) NOT NULL,
    record_key character varying(100) NOT NULL,
    version bigint NOT NULL,
    payload jsonb NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    CONSTRAINT engineering_workspace_records_version_check CHECK ((version > 0))
);



CREATE TABLE notifications (
    id bigint NOT NULL,
    recipient_id bigint NOT NULL,
    sender_id bigint,
    title character varying(200) NOT NULL,
    body character varying(2000),
    type character varying(50) NOT NULL,
    related_entity_type character varying(100),
    related_entity_id bigint,
    read_status character varying(20) DEFAULT 'UNREAD'::character varying NOT NULL,
    read_at timestamp with time zone,
    scheduled_for timestamp with time zone,
    sent_at timestamp with time zone,
    created_by character varying(100),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by character varying(100),
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    version bigint DEFAULT 0 NOT NULL
);



CREATE SEQUENCE notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



ALTER SEQUENCE notifications_id_seq OWNED BY notifications.id;



CREATE TABLE project_members (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    user_id bigint NOT NULL,
    assigned_at timestamp with time zone,
    created_by character varying(100),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by character varying(100),
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    version bigint DEFAULT 0 NOT NULL
);



CREATE SEQUENCE project_members_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



ALTER SEQUENCE project_members_id_seq OWNED BY project_members.id;



CREATE TABLE projects (
    id bigint NOT NULL,
    project_code character varying(50) NOT NULL,
    name character varying(200) NOT NULL,
    description character varying(1000),
    owner_id bigint,
    start_date date,
    target_completion_date date,
    status character varying(30) DEFAULT 'ACTIVE'::character varying NOT NULL,
    priority character varying(20),
    created_by character varying(100),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by character varying(100),
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    version bigint DEFAULT 0 NOT NULL
);



CREATE SEQUENCE projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



ALTER SEQUENCE projects_id_seq OWNED BY projects.id;



CREATE TABLE refresh_tokens (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    token character varying(512) NOT NULL,
    expiry_date timestamp with time zone NOT NULL,
    revoked boolean DEFAULT false NOT NULL,
    created_by character varying(100),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by character varying(100),
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    version bigint DEFAULT 0 NOT NULL
);



CREATE SEQUENCE refresh_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



ALTER SEQUENCE refresh_tokens_id_seq OWNED BY refresh_tokens.id;



CREATE TABLE retired_feature_records (
    source_table character varying(40) NOT NULL,
    source_id bigint NOT NULL,
    payload jsonb NOT NULL,
    archived_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);



CREATE TABLE signup_email_verifications (
    id uuid NOT NULL,
    email character varying(200) NOT NULL,
    code_hash character varying(60),
    code_expires_at timestamp with time zone,
    verified_at timestamp with time zone,
    token_hash character varying(64),
    proof_expires_at timestamp with time zone,
    sent_at timestamp with time zone,
    window_started_at timestamp with time zone NOT NULL,
    send_count integer DEFAULT 0 NOT NULL,
    attempts integer DEFAULT 0 NOT NULL,
    consumed boolean DEFAULT false NOT NULL
);



CREATE TABLE tasks (
    id bigint NOT NULL,
    task_code character varying(50) NOT NULL,
    title character varying(200) NOT NULL,
    description character varying(2000),
    project_id bigint,
    assigned_to bigint NOT NULL,
    assigned_by bigint,
    parent_task_id bigint,
    priority character varying(20) DEFAULT 'MEDIUM'::character varying NOT NULL,
    status character varying(30) DEFAULT 'NOT_STARTED'::character varying NOT NULL,
    planned_start_date date,
    deadline date,
    estimated_duration_minutes bigint,
    actual_time_spent_minutes bigint,
    progress_percentage integer,
    completion_percentage integer,
    completed_at timestamp without time zone,
    created_by character varying(100),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by character varying(100),
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    version bigint DEFAULT 0 NOT NULL,
    CONSTRAINT ck_task_progress CHECK (((progress_percentage >= 0) AND (progress_percentage <= 100)))
);



CREATE SEQUENCE tasks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



ALTER SEQUENCE tasks_id_seq OWNED BY tasks.id;



CREATE TABLE users (
    id bigint NOT NULL,
    username character varying(100) NOT NULL,
    email character varying(200) NOT NULL,
    password character varying(255) NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    account_non_expired boolean DEFAULT true NOT NULL,
    account_non_locked boolean DEFAULT true NOT NULL,
    credentials_non_expired boolean DEFAULT true NOT NULL,
    password_changed_at timestamp with time zone,
    created_by character varying(100),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by character varying(100),
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    version bigint DEFAULT 0 NOT NULL,
    first_name character varying(100),
    last_name character varying(100),
    password_reset_token character varying(512),
    password_reset_token_expiry timestamp with time zone,
    email_verified boolean DEFAULT true NOT NULL,
    email_verification_code_hash character varying(64),
    email_verification_code_expiry timestamp with time zone,
    email_verification_sent_at timestamp with time zone,
    email_verification_attempts integer DEFAULT 0 NOT NULL,
    google_subject character varying(255),
    facebook_subject character varying(255),
    timezone character varying(50) DEFAULT 'Asia/Kolkata'::character varying NOT NULL,
    profile_picture_url character varying(500)
);



CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



ALTER SEQUENCE users_id_seq OWNED BY users.id;



CREATE TABLE work_sessions (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    session_start timestamp with time zone NOT NULL,
    session_end timestamp with time zone,
    elapsed_duration_minutes bigint,
    productive_duration_minutes bigint,
    status character varying(20) DEFAULT 'ACTIVE'::character varying NOT NULL,
    created_by character varying(100),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by character varying(100),
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    version bigint DEFAULT 0 NOT NULL
);



CREATE SEQUENCE work_sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



ALTER SEQUENCE work_sessions_id_seq OWNED BY work_sessions.id;



CREATE TABLE work_updates (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    work_date date NOT NULL,
    project_id bigint,
    task_id bigint,
    work_category character varying(50),
    work_description character varying(2000),
    start_time timestamp without time zone,
    end_time timestamp without time zone,
    time_spent_minutes bigint,
    progress_percentage integer,
    work_completed boolean DEFAULT false NOT NULL,
    challenges character varying(1000),
    blockers character varying(1000),
    next_steps character varying(1000),
    attachment_url character varying(500),
    status character varying(20) DEFAULT 'DRAFT'::character varying NOT NULL,
    created_by character varying(100),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by character varying(100),
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    version bigint DEFAULT 0 NOT NULL
);



CREATE SEQUENCE work_updates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



ALTER SEQUENCE work_updates_id_seq OWNED BY work_updates.id;



ALTER TABLE ONLY attendance_sessions ALTER COLUMN id SET DEFAULT nextval('attendance_sessions_id_seq'::regclass);



ALTER TABLE ONLY break_sessions ALTER COLUMN id SET DEFAULT nextval('break_sessions_id_seq'::regclass);



ALTER TABLE ONLY configuration ALTER COLUMN id SET DEFAULT nextval('configuration_id_seq'::regclass);



ALTER TABLE ONLY daily_reports ALTER COLUMN id SET DEFAULT nextval('daily_reports_id_seq'::regclass);



ALTER TABLE ONLY engineering_client_revisions ALTER COLUMN id SET DEFAULT nextval('engineering_client_revisions_id_seq'::regclass);



ALTER TABLE ONLY engineering_events ALTER COLUMN id SET DEFAULT nextval('engineering_events_id_seq'::regclass);



ALTER TABLE ONLY engineering_report_submissions ALTER COLUMN id SET DEFAULT nextval('engineering_report_submissions_id_seq'::regclass);



ALTER TABLE ONLY engineering_work ALTER COLUMN id SET DEFAULT nextval('engineering_work_id_seq'::regclass);



ALTER TABLE ONLY engineering_work_revisions ALTER COLUMN id SET DEFAULT nextval('engineering_work_revisions_id_seq'::regclass);



ALTER TABLE ONLY notifications ALTER COLUMN id SET DEFAULT nextval('notifications_id_seq'::regclass);



ALTER TABLE ONLY project_members ALTER COLUMN id SET DEFAULT nextval('project_members_id_seq'::regclass);



ALTER TABLE ONLY projects ALTER COLUMN id SET DEFAULT nextval('projects_id_seq'::regclass);



ALTER TABLE ONLY refresh_tokens ALTER COLUMN id SET DEFAULT nextval('refresh_tokens_id_seq'::regclass);



ALTER TABLE ONLY tasks ALTER COLUMN id SET DEFAULT nextval('tasks_id_seq'::regclass);



ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);



ALTER TABLE ONLY work_sessions ALTER COLUMN id SET DEFAULT nextval('work_sessions_id_seq'::regclass);



ALTER TABLE ONLY work_updates ALTER COLUMN id SET DEFAULT nextval('work_updates_id_seq'::regclass);



ALTER TABLE ONLY attendance_sessions
    ADD CONSTRAINT attendance_sessions_pkey PRIMARY KEY (id);



ALTER TABLE ONLY attendance_sessions
    ADD CONSTRAINT attendance_sessions_user_id_work_date_key UNIQUE (user_id, work_date);



ALTER TABLE ONLY break_sessions
    ADD CONSTRAINT break_sessions_pkey PRIMARY KEY (id);



ALTER TABLE ONLY configuration
    ADD CONSTRAINT configuration_key_key UNIQUE (key);



ALTER TABLE ONLY configuration
    ADD CONSTRAINT configuration_pkey PRIMARY KEY (id);



ALTER TABLE ONLY daily_reports
    ADD CONSTRAINT daily_reports_pkey PRIMARY KEY (id);



ALTER TABLE ONLY engineering_client_records
    ADD CONSTRAINT engineering_client_records_pkey PRIMARY KEY (user_id, record_type, record_key);



ALTER TABLE ONLY engineering_client_revisions
    ADD CONSTRAINT engineering_client_revisions_pkey PRIMARY KEY (id);



ALTER TABLE ONLY engineering_client_revisions
    ADD CONSTRAINT engineering_client_revisions_user_id_record_type_record_key UNIQUE (user_id, record_type, record_key, version);



ALTER TABLE ONLY engineering_curricula
    ADD CONSTRAINT engineering_curricula_pkey PRIMARY KEY (plan_id);



ALTER TABLE ONLY engineering_events
    ADD CONSTRAINT engineering_events_pkey PRIMARY KEY (id);



ALTER TABLE ONLY engineering_report_submissions
    ADD CONSTRAINT engineering_report_submission_user_id_plan_id_day_numbe_key UNIQUE (user_id, plan_id, day_number, version);



ALTER TABLE ONLY engineering_report_submissions
    ADD CONSTRAINT engineering_report_submissions_pkey PRIMARY KEY (id);



ALTER TABLE ONLY engineering_work
    ADD CONSTRAINT engineering_work_pkey PRIMARY KEY (id);



ALTER TABLE ONLY engineering_work_revisions
    ADD CONSTRAINT engineering_work_revisions_pkey PRIMARY KEY (id);



ALTER TABLE ONLY engineering_work_revisions
    ADD CONSTRAINT engineering_work_revisions_user_id_mutation_id_key UNIQUE (user_id, mutation_id);



ALTER TABLE ONLY engineering_work_revisions
    ADD CONSTRAINT engineering_work_revisions_work_id_version_key UNIQUE (work_id, version);



ALTER TABLE ONLY engineering_work
    ADD CONSTRAINT engineering_work_user_id_plan_id_day_number_domain_key UNIQUE (user_id, plan_id, day_number, domain);



ALTER TABLE ONLY engineering_workspace_records
    ADD CONSTRAINT engineering_workspace_records_pkey PRIMARY KEY (user_id, record_type, record_key);



ALTER TABLE ONLY notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);



ALTER TABLE ONLY project_members
    ADD CONSTRAINT project_members_pkey PRIMARY KEY (id);



ALTER TABLE ONLY project_members
    ADD CONSTRAINT project_members_project_id_user_id_key UNIQUE (project_id, user_id);



ALTER TABLE ONLY projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);



ALTER TABLE ONLY projects
    ADD CONSTRAINT projects_project_code_key UNIQUE (project_code);



ALTER TABLE ONLY refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);



ALTER TABLE ONLY refresh_tokens
    ADD CONSTRAINT refresh_tokens_token_key UNIQUE (token);



ALTER TABLE ONLY retired_feature_records
    ADD CONSTRAINT retired_feature_records_pkey PRIMARY KEY (source_table, source_id);



ALTER TABLE ONLY signup_email_verifications
    ADD CONSTRAINT signup_email_verifications_email_key UNIQUE (email);



ALTER TABLE ONLY signup_email_verifications
    ADD CONSTRAINT signup_email_verifications_pkey PRIMARY KEY (id);



ALTER TABLE ONLY tasks
    ADD CONSTRAINT tasks_pkey PRIMARY KEY (id);



ALTER TABLE ONLY tasks
    ADD CONSTRAINT tasks_task_code_key UNIQUE (task_code);



ALTER TABLE ONLY users
    ADD CONSTRAINT users_email_key UNIQUE (email);



ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);



ALTER TABLE ONLY users
    ADD CONSTRAINT users_username_key UNIQUE (username);



ALTER TABLE ONLY work_sessions
    ADD CONSTRAINT work_sessions_pkey PRIMARY KEY (id);



ALTER TABLE ONLY work_updates
    ADD CONSTRAINT work_updates_pkey PRIMARY KEY (id);



CREATE INDEX engineering_client_records_by_type ON engineering_client_records USING btree (user_id, record_type);



CREATE INDEX engineering_event_user_date ON engineering_events USING btree (user_id, work_date);



CREATE INDEX engineering_report_user_day ON engineering_report_submissions USING btree (user_id, day_number);



CREATE INDEX engineering_work_user_day ON engineering_work USING btree (user_id, day_number);



CREATE INDEX ix_notifications_recipient ON notifications USING btree (recipient_id, read_status);



CREATE INDEX ix_refresh_user ON refresh_tokens USING btree (user_id);



CREATE INDEX ix_tasks_assignee ON tasks USING btree (assigned_to);



CREATE UNIQUE INDEX ux_attendance_active ON attendance_sessions USING btree (user_id) WHERE ((check_out_time IS NULL) AND (check_in_time IS NOT NULL));



CREATE UNIQUE INDEX ux_break_active ON break_sessions USING btree (attendance_session_id) WHERE (end_time IS NULL);



CREATE UNIQUE INDEX ux_daily_report_date ON daily_reports USING btree (user_id, report_date);



CREATE UNIQUE INDEX ux_users_facebook_subject ON users USING btree (facebook_subject) WHERE (facebook_subject IS NOT NULL);



CREATE UNIQUE INDEX ux_users_google_subject ON users USING btree (google_subject) WHERE (google_subject IS NOT NULL);



ALTER TABLE ONLY attendance_sessions
    ADD CONSTRAINT attendance_sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id);



ALTER TABLE ONLY break_sessions
    ADD CONSTRAINT break_sessions_attendance_session_id_fkey FOREIGN KEY (attendance_session_id) REFERENCES attendance_sessions(id);



ALTER TABLE ONLY daily_reports
    ADD CONSTRAINT daily_reports_reviewed_by_fkey FOREIGN KEY (reviewed_by) REFERENCES users(id);



ALTER TABLE ONLY daily_reports
    ADD CONSTRAINT daily_reports_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id);



ALTER TABLE ONLY engineering_client_records
    ADD CONSTRAINT engineering_client_records_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id);



ALTER TABLE ONLY engineering_client_revisions
    ADD CONSTRAINT engineering_client_revisions_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id);



ALTER TABLE ONLY engineering_events
    ADD CONSTRAINT engineering_events_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id);



ALTER TABLE ONLY engineering_report_submissions
    ADD CONSTRAINT engineering_report_submissions_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id);



ALTER TABLE ONLY engineering_work_revisions
    ADD CONSTRAINT engineering_work_revisions_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id);



ALTER TABLE ONLY engineering_work_revisions
    ADD CONSTRAINT engineering_work_revisions_work_id_fkey FOREIGN KEY (work_id) REFERENCES engineering_work(id);



ALTER TABLE ONLY engineering_work
    ADD CONSTRAINT engineering_work_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id);



ALTER TABLE ONLY engineering_workspace_records
    ADD CONSTRAINT engineering_workspace_records_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id);



ALTER TABLE ONLY refresh_tokens
    ADD CONSTRAINT fk_refresh_user FOREIGN KEY (user_id) REFERENCES users(id);



ALTER TABLE ONLY notifications
    ADD CONSTRAINT notifications_recipient_id_fkey FOREIGN KEY (recipient_id) REFERENCES users(id);



ALTER TABLE ONLY notifications
    ADD CONSTRAINT notifications_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES users(id);



ALTER TABLE ONLY project_members
    ADD CONSTRAINT project_members_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id);



ALTER TABLE ONLY project_members
    ADD CONSTRAINT project_members_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id);



ALTER TABLE ONLY projects
    ADD CONSTRAINT projects_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES users(id);



ALTER TABLE ONLY tasks
    ADD CONSTRAINT tasks_assigned_by_fkey FOREIGN KEY (assigned_by) REFERENCES users(id);



ALTER TABLE ONLY tasks
    ADD CONSTRAINT tasks_assigned_to_fkey FOREIGN KEY (assigned_to) REFERENCES users(id);



ALTER TABLE ONLY tasks
    ADD CONSTRAINT tasks_parent_task_id_fkey FOREIGN KEY (parent_task_id) REFERENCES tasks(id);



ALTER TABLE ONLY tasks
    ADD CONSTRAINT tasks_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id);



ALTER TABLE ONLY work_sessions
    ADD CONSTRAINT work_sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id);



ALTER TABLE ONLY work_updates
    ADD CONSTRAINT work_updates_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id);



ALTER TABLE ONLY work_updates
    ADD CONSTRAINT work_updates_task_id_fkey FOREIGN KEY (task_id) REFERENCES tasks(id);



ALTER TABLE ONLY work_updates
    ADD CONSTRAINT work_updates_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id);




INSERT INTO engineering_curricula(plan_id,payload) VALUES ('chronis-ai-engineering-2026-11-05',convert_from(decode('eyJwbGFuSWQiOiJjaHJvbmlzLWFpLWVuZ2luZWVyaW5nLTIwMjYtMTEtMDUiLCJ0aW1lem9uZSI6IkFzaWEvS29sa2F0YSIsInN0YXJ0RGF0ZSI6IjIwMjYtMTEtMDUiLCJlbmREYXRlIjoiMjAyNy0wMi0wNCIsInNvdXJjZVdvcmtib29rIjoiQUlfRW5naW5lZXJpbmdfOTJfRGF5XzUwX1Byb2plY3RfU3RyaWN0X1JvYWRtYXAueGxzeCIsInBoYXNlcyI6W3sibm8iOiIwMSIsIm5hbWUiOiJQeXRob24gJiBGb3VuZGF0aW9ucyIsImxhYmVsIjoiMDEgwrcgUHl0aG9uICYgRm91bmRhdGlvbnMiLCJkYXlzIjoxMCwiZnJvbURheSI6MSwidG9EYXkiOjEwLCJzdGFydCI6IjIwMjYtMTEtMDUiLCJlbmQiOiIyMDI2LTExLTE0IiwiZmlyc3RTdWJwaGFzZSI6IkVudmlyb25tZW50ICYgdG9vbGNoYWluIiwibGFzdFN1YnBoYXNlIjoiVmlzdWFsaXphdGlvbiAmIHRlc3RzIiwiY2hlY2twb2ludEV4cGVjdGF0aW9uIjoiRXhwbGFpbiBjb25jZXB0czsgMSBjb2RlIHRlc3QvZGF5OyBkZW1vbnN0cmF0ZSBwaGFzZSBwcm9qZWN0IHNsaWNlcyBhbmQgcGFzcyBzZWxmLWFzc2Vzc21lbnQiLCJjaGVja3BvaW50RGF0ZSI6IjIwMjYtMTEtMTQiLCJyZXF1aXJlZERlbW8iOiJDTEkgVGFzayBMb2dnZXIgKyBkYXRhIHF1YWxpdHkgTVZQOyBQeXRob24gdGVzdHMgYW5kIGNvbXBsZXhpdHkgYW5hbHlzaXMuIiwicGFzc0NyaXRlcmlvbiI6Ij49NzAlIG9uIGtub3dsZWRnZSBxdWl6ICsgdmVyaWZpYWJsZSBkZW1vIn0seyJubyI6IjAyIiwibmFtZSI6IkNsYXNzaWNhbCBNTCIsImxhYmVsIjoiMDIgwrcgQ2xhc3NpY2FsIE1MIiwiZGF5cyI6MTIsImZyb21EYXkiOjExLCJ0b0RheSI6MjIsInN0YXJ0IjoiMjAyNi0xMS0xNSIsImVuZCI6IjIwMjYtMTEtMjYiLCJmaXJzdFN1YnBoYXNlIjoiTUwgbGlmZWN5Y2xlIiwibGFzdFN1YnBoYXNlIjoiU2VydmluZyBjaGVja3BvaW50IiwiY2hlY2twb2ludEV4cGVjdGF0aW9uIjoiRXhwbGFpbiBjb25jZXB0czsgMSBjb2RlIHRlc3QvZGF5OyBkZW1vbnN0cmF0ZSBwaGFzZSBwcm9qZWN0IHNsaWNlcyBhbmQgcGFzcyBzZWxmLWFzc2Vzc21lbnQiLCJjaGVja3BvaW50RGF0ZSI6IjIwMjYtMTEtMjYiLCJyZXF1aXJlZERlbW8iOiJUcmFpbi9ldmFsdWF0ZSBvbmUgcmVncmVzc29yIGFuZCBjbGFzc2lmaWVyOyBqdXN0aWZ5IG1ldHJpY3MgYW5kIGxlYWthZ2UgcHJldmVudGlvbi4iLCJwYXNzQ3JpdGVyaW9uIjoiPj03MCUgb24ga25vd2xlZGdlIHF1aXogKyB2ZXJpZmlhYmxlIGRlbW8ifSx7Im5vIjoiMDMiLCJuYW1lIjoiRGVlcCBMZWFybmluZyAmIE5MUCIsImxhYmVsIjoiMDMgwrcgRGVlcCBMZWFybmluZyAmIE5MUCIsImRheXMiOjE0LCJmcm9tRGF5IjoyMywidG9EYXkiOjM2LCJzdGFydCI6IjIwMjYtMTEtMjciLCJlbmQiOiIyMDI2LTEyLTEwIiwiZmlyc3RTdWJwaGFzZSI6IlB5VG9yY2ggZW50cnkiLCJsYXN0U3VicGhhc2UiOiJEZWVwIGxlYXJuaW5nIHJldmlldyIsImNoZWNrcG9pbnRFeHBlY3RhdGlvbiI6IkV4cGxhaW4gY29uY2VwdHM7IDEgY29kZSB0ZXN0L2RheTsgZGVtb25zdHJhdGUgcGhhc2UgcHJvamVjdCBzbGljZXMgYW5kIHBhc3Mgc2VsZi1hc3Nlc3NtZW50IiwiY2hlY2twb2ludERhdGUiOiIyMDI2LTEyLTEwIiwicmVxdWlyZWREZW1vIjoiUmVwcm9kdWNlIGEgUHlUb3JjaCBleHBlcmltZW50IGFuZCBkb2N1bWVudCBhYmxhdGlvbi9lcnJvciBhbmFseXNpcy4iLCJwYXNzQ3JpdGVyaW9uIjoiPj03MCUgb24ga25vd2xlZGdlIHF1aXogKyB2ZXJpZmlhYmxlIGRlbW8ifSx7Im5vIjoiMDQiLCJuYW1lIjoiTExNcyAmIFJBRyIsImxhYmVsIjoiMDQgwrcgTExNcyAmIFJBRyIsImRheXMiOjE2LCJmcm9tRGF5IjozNywidG9EYXkiOjUyLCJzdGFydCI6IjIwMjYtMTItMTEiLCJlbmQiOiIyMDI2LTEyLTI2IiwiZmlyc3RTdWJwaGFzZSI6IkxMTSBpbnRlcmZhY2VzIiwibGFzdFN1YnBoYXNlIjoiUkFHIGNoZWNrcG9pbnQiLCJjaGVja3BvaW50RXhwZWN0YXRpb24iOiJFeHBsYWluIGNvbmNlcHRzOyAxIGNvZGUgdGVzdC9kYXk7IGRlbW9uc3RyYXRlIHBoYXNlIHByb2plY3Qgc2xpY2VzIGFuZCBwYXNzIHNlbGYtYXNzZXNzbWVudCIsImNoZWNrcG9pbnREYXRlIjoiMjAyNi0xMi0yNiIsInJlcXVpcmVkRGVtbyI6IkNpdGVkIFJBRyBhbnN3ZXJzLCBuZWdhdGl2ZSByZXRyaWV2YWwgdGVzdHMgYW5kIGEgMjAtcXVlc3Rpb24gZXZhbCByZXBvcnQuIiwicGFzc0NyaXRlcmlvbiI6Ij49NzAlIG9uIGtub3dsZWRnZSBxdWl6ICsgdmVyaWZpYWJsZSBkZW1vIn0seyJubyI6IjA1IiwibmFtZSI6IkFnZW50cyAmIEhhcm5lc3MiLCJsYWJlbCI6IjA1IMK3IEFnZW50cyAmIEhhcm5lc3MiLCJkYXlzIjoxNywiZnJvbURheSI6NTMsInRvRGF5Ijo2OSwic3RhcnQiOiIyMDI2LTEyLTI3IiwiZW5kIjoiMjAyNy0wMS0xMiIsImZpcnN0U3VicGhhc2UiOiJBZ2VudCBwcmltaXRpdmVzIiwibGFzdFN1YnBoYXNlIjoiTXVsdGktYWdlbnQgY2hlY2twb2ludCIsImNoZWNrcG9pbnRFeHBlY3RhdGlvbiI6IkV4cGxhaW4gY29uY2VwdHM7IDEgY29kZSB0ZXN0L2RheTsgZGVtb25zdHJhdGUgcGhhc2UgcHJvamVjdCBzbGljZXMgYW5kIHBhc3Mgc2VsZi1hc3Nlc3NtZW50IiwiY2hlY2twb2ludERhdGUiOiIyMDI3LTAxLTEyIiwicmVxdWlyZWREZW1vIjoiTXVsdGktYWdlbnQgZ3JhcGggd2l0aCBhcHByb3ZhbCwgY2hlY2twb2ludHMsIGJ1ZGdldCBhbmQgMTAgc2NlbmFyaW8gZXZhbHMuIiwicGFzc0NyaXRlcmlvbiI6Ij49NzAlIG9uIGtub3dsZWRnZSBxdWl6ICsgdmVyaWZpYWJsZSBkZW1vIn0seyJubyI6IjA2IiwibmFtZSI6IlByb2R1Y3Rpb24gJiBMTE1PcHMiLCJsYWJlbCI6IjA2IMK3IFByb2R1Y3Rpb24gJiBMTE1PcHMiLCJkYXlzIjoxMCwiZnJvbURheSI6NzAsInRvRGF5Ijo3OSwic3RhcnQiOiIyMDI3LTAxLTEzIiwiZW5kIjoiMjAyNy0wMS0yMiIsImZpcnN0U3VicGhhc2UiOiJUZW5hbnQgaXNvbGF0aW9uIiwibGFzdFN1YnBoYXNlIjoiUHJvZHVjdGlvbiByZWFkaW5lc3MiLCJjaGVja3BvaW50RXhwZWN0YXRpb24iOiJFeHBsYWluIGNvbmNlcHRzOyAxIGNvZGUgdGVzdC9kYXk7IGRlbW9uc3RyYXRlIHBoYXNlIHByb2plY3Qgc2xpY2VzIGFuZCBwYXNzIHNlbGYtYXNzZXNzbWVudCIsImNoZWNrcG9pbnREYXRlIjoiMjAyNy0wMS0yMiIsInJlcXVpcmVkRGVtbyI6IlNlY3VyZSBBUEksIHRlbmFudCB0ZXN0LCB0cmFjaW5nLCByZWdyZXNzaW9uIGdhdGUgYW5kIHJvbGxiYWNrIHBsYW4uIiwicGFzc0NyaXRlcmlvbiI6Ij49NzAlIG9uIGtub3dsZWRnZSBxdWl6ICsgdmVyaWZpYWJsZSBkZW1vIn0seyJubyI6IjA3IiwibmFtZSI6IkFyY2hpdGVjdCBDYXBzdG9uZXMiLCJsYWJlbCI6IjA3IMK3IEFyY2hpdGVjdCBDYXBzdG9uZXMiLCJkYXlzIjoxMSwiZnJvbURheSI6ODAsInRvRGF5Ijo5MCwic3RhcnQiOiIyMDI3LTAxLTIzIiwiZW5kIjoiMjAyNy0wMi0wMiIsImZpcnN0U3VicGhhc2UiOiJLbm93bGVkZ2UgZ3JhcGhzIiwibGFzdFN1YnBoYXNlIjoiQ2Fwc3RvbmUgdmVyaWZpY2F0aW9uIiwiY2hlY2twb2ludEV4cGVjdGF0aW9uIjoiRXhwbGFpbiBjb25jZXB0czsgMSBjb2RlIHRlc3QvZGF5OyBkZW1vbnN0cmF0ZSBwaGFzZSBwcm9qZWN0IHNsaWNlcyBhbmQgcGFzcyBzZWxmLWFzc2Vzc21lbnQiLCJjaGVja3BvaW50RGF0ZSI6IjIwMjctMDItMDIiLCJyZXF1aXJlZERlbW8iOiJJbnRlZ3JhdGVkIHBsYXRmb3JtIGRlbW8sIGFyY2hpdGVjdHVyYWwgZGlhZ3JhbSwgdGhyZWF0IG1vZGVsIGFuZCBtZWFzdXJlbWVudC4iLCJwYXNzQ3JpdGVyaW9uIjoiPj03MCUgb24ga25vd2xlZGdlIHF1aXogKyB2ZXJpZmlhYmxlIGRlbW8ifSx7Im5vIjoiMDgiLCJuYW1lIjoiQ2FyZWVyIFJlYWRpbmVzcyIsImxhYmVsIjoiMDggwrcgQ2FyZWVyIFJlYWRpbmVzcyIsImRheXMiOjIsImZyb21EYXkiOjkxLCJ0b0RheSI6OTIsInN0YXJ0IjoiMjAyNy0wMi0wMyIsImVuZCI6IjIwMjctMDItMDQiLCJmaXJzdFN1YnBoYXNlIjoiUG9ydGZvbGlvICYgaW50ZXJ2aWV3cyIsImxhc3RTdWJwaGFzZSI6IlN5c3RlbSBkZXNpZ24gbW9jayIsImNoZWNrcG9pbnRFeHBlY3RhdGlvbiI6IkV4cGxhaW4gY29uY2VwdHM7IDEgY29kZSB0ZXN0L2RheTsgZGVtb25zdHJhdGUgcGhhc2UgcHJvamVjdCBzbGljZXMgYW5kIHBhc3Mgc2VsZi1hc3Nlc3NtZW50IiwiY2hlY2twb2ludERhdGUiOiIyMDI3LTAyLTA0IiwicmVxdWlyZWREZW1vIjoiUG9saXNoZWQgUkVBRE1FLCB0d28gbW9jayBpbnRlcnZpZXdzLCByw6lzdW3DqSBidWxsZXRzIGFuZCAzMC82MC85MCBmb2xsb3ctdXAgcGxhbi4iLCJwYXNzQ3JpdGVyaW9uIjoiPj03MCUgb24ga25vd2xlZGdlIHF1aXogKyB2ZXJpZmlhYmxlIGRlbW8ifV0sImRheXMiOlt7InBsYW5JZCI6ImNocm9uaXMtYWktZW5naW5lZXJpbmctMjAyNi0xMS0wNSIsImRheU51bWJlciI6MSwiZGF0ZSI6IjIwMjYtMTEtMDUiLCJ3ZWVrIjoxLCJwaGFzZSI6IjAxIMK3IFB5dGhvbiAmIEZvdW5kYXRpb25zIiwicGhhc2VObyI6IjAxIiwicGhhc2VEYXkiOjEsInN1YnBoYXNlIjoiRW52aXJvbm1lbnQgJiB0b29sY2hhaW4iLCJjb25jZXB0cyI6IlB5dGhvbiBpbnRlcnByZXRlciwgdmVudiwgcGlwLCBWUyBDb2RlLCBHaXQsIENMSSBhbmQgc3RhdGljIHR5cGluZyIsInRoZW9yeURlbGl2ZXJhYmxlIjoiUmVhZCArIGRpYWdyYW0gKyAzIGZsYXNoY2FyZHM7IGlkZW50aWZ5IDIgZmFpbHVyZSBtb2RlcyBpbiBlbnZpcm9ubWVudCAmIHRvb2xjaGFpbi4iLCJiYXNpY1Rhc2siOiJXcml0ZSBhIHR5cGVkIENMSSB0aGF0IGdyZWV0cyB1c2VyIGFuZCB2YWxpZGF0ZXMgYXJncyIsInNjZW5hcmlvIjoiRGVzaWduIGNvbW1hbmQgcGFyc2VyIHRoYXQgZmFpbHMgc2FmZWx5IG9uIG1pc3NpbmcgdmFsdWVzIiwicHJvamVjdFdvcmtzdHJlYW0iOiJGb3VuZGF0aW9uIGxhYiIsInByb2plY3RJZCI6bnVsbCwicHJvamVjdFRhc2siOiJGT1VOREFUSU9OIExBQjogaW1wbGVtZW50IHR5cGVkIEpTT04gVGFzayBMb2dnZXIgQ0xJLCB0ZXN0IGlucHV0IHZhbGlkYXRpb24sIGNyZWF0ZSBHaXRIdWIgcmVwbyBhbmQgd3JpdGUgbGVhcm5pbmcgbm90ZXMuIiwicHJvamVjdERlbGl2ZXJhYmxlIjoiUnVubmFibGUgVGFzayBMb2dnZXIgQ0xJICsgcHl0ZXN0IHRlc3RzICsgUkVBRE1FIChmb3VuZGF0aW9uIGxhYiwgc2VwYXJhdGUgZnJvbSBQMDHigJNQNTApLiIsImludGVydmlldyI6IkhvdyBkbyBQeXRob24gZW52aXJvbm1lbnRzIGFuZCBwYWNrYWdpbmcgZGlmZmVyIGZyb20gSmF2YT8iLCJleGl0Q3JpdGVyaWEiOiJFeHBsYWluIGVudmlyb25tZW50ICYgdG9vbGNoYWluIGluIDIgbWludXRlczsgMSB0ZXN0ZWQgY29tbWl0OyBvbmUgc2NlbmFyaW8gYW5zd2VyOyAzLzUgaW50ZXJ2aWV3IHByYWN0aWNlIHF1ZXN0aW9ucy4iLCJwbGFubmVkSG91cnMiOjYsInJlZmVyZW5jZVVybCI6Imh0dHBzOi8vZG9jcy5weXRob24ub3JnLzMvdHV0b3JpYWwvIiwic2NlbmFyaW9Gb3JtYXQiOiJJbnB1dHMg4oaSIGNvbnN0cmFpbnRzIOKGkiBlZGdlIGNhc2VzIOKGkiBhbGdvcml0aG0g4oaSIGNvbXBsZXhpdHkg4oaSIHRlc3RzOyBjb2RlIGFuZCByZWZsZWN0IiwiaW50ZXJ2aWV3U3RydWN0dXJlIjoiVXNlIGRlZmluaXRpb24g4oaSIGV4YW1wbGUg4oaSIHRyYWRlLW9mZiDihpIgY29tbW9uIGZhaWx1cmUg4oaSIHByb2R1Y3Rpb24gaW1wbGljYXRpb24ifSx7InBsYW5JZCI6ImNocm9uaXMtYWktZW5naW5lZXJpbmctMjAyNi0xMS0wNSIsImRheU51bWJlciI6MiwiZGF0ZSI6IjIwMjYtMTEtMDYiLCJ3ZWVrIjoxLCJwaGFzZSI6IjAxIMK3IFB5dGhvbiAmIEZvdW5kYXRpb25zIiwicGhhc2VObyI6IjAxIiwicGhhc2VEYXkiOjIsInN1YnBoYXNlIjoiQ29yZSBjb2xsZWN0aW9ucyIsImNvbmNlcHRzIjoic3RyL2xpc3QvdHVwbGUvZGljdC9zZXQsIHNsaWNpbmcsIGlkZW50aXR5LCBtdXRhdGlvbiwgYmlnLU8iLCJ0aGVvcnlEZWxpdmVyYWJsZSI6IlJlYWQgKyBkaWFncmFtICsgMyBmbGFzaGNhcmRzOyBpZGVudGlmeSAyIGZhaWx1cmUgbW9kZXMgaW4gY29yZSBjb2xsZWN0aW9ucy4iLCJiYXNpY1Rhc2siOiJOb3JtYWxpemUgbmVzdGVkIGRpY3Rpb25hcmllcyBhbmQgZGVkdXBsaWNhdGUgaXRlbXMgcHJlc2VydmluZyBvcmRlciIsInNjZW5hcmlvIjoiQ291bnQgZXJyb3IgdHlwZXMgaW4gMTAwayBhZ2VudCB0cmFjZXMgaW4gTyhuKSIsInByb2plY3RXb3Jrc3RyZWFtIjoiRm91bmRhdGlvbiBsYWIiLCJwcm9qZWN0SWQiOm51bGwsInByb2plY3RUYXNrIjoiRk9VTkRBVElPTiBMQUI6IGltcGxlbWVudCB0eXBlZCBKU09OIFRhc2sgTG9nZ2VyIENMSSwgdGVzdCBpbnB1dCB2YWxpZGF0aW9uLCBjcmVhdGUgR2l0SHViIHJlcG8gYW5kIHdyaXRlIGxlYXJuaW5nIG5vdGVzLiIsInByb2plY3REZWxpdmVyYWJsZSI6IlJ1bm5hYmxlIFRhc2sgTG9nZ2VyIENMSSArIHB5dGVzdCB0ZXN0cyArIFJFQURNRSAoZm91bmRhdGlvbiBsYWIsIHNlcGFyYXRlIGZyb20gUDAx4oCTUDUwKS4iLCJpbnRlcnZpZXciOiJXaGVuIGNob29zZSBkaWN0LCBzZXQsIGxpc3Qgb3IgdHVwbGUgZm9yIGFnZW50IHN0YXRlPyIsImV4aXRDcml0ZXJpYSI6IkV4cGxhaW4gY29yZSBjb2xsZWN0aW9ucyBpbiAyIG1pbnV0ZXM7IDEgdGVzdGVkIGNvbW1pdDsgb25lIHNjZW5hcmlvIGFuc3dlcjsgMy81IGludGVydmlldyBwcmFjdGljZSBxdWVzdGlvbnMuIiwicGxhbm5lZEhvdXJzIjo2LCJyZWZlcmVuY2VVcmwiOiJodHRwczovL2RvY3MucHl0aG9uLm9yZy8zL3R1dG9yaWFsLyIsInNjZW5hcmlvRm9ybWF0IjoiSW5wdXRzIOKGkiBjb25zdHJhaW50cyDihpIgZWRnZSBjYXNlcyDihpIgYWxnb3JpdGhtIOKGkiBjb21wbGV4aXR5IOKGkiB0ZXN0czsgY29kZSBhbmQgcmVmbGVjdCIsImludGVydmlld1N0cnVjdHVyZSI6IlVzZSBkZWZpbml0aW9uIOKGkiBleGFtcGxlIOKGkiB0cmFkZS1vZmYg4oaSIGNvbW1vbiBmYWlsdXJlIOKGkiBwcm9kdWN0aW9uIGltcGxpY2F0aW9uIn0seyJwbGFuSWQiOiJjaHJvbmlzLWFpLWVuZ2luZWVyaW5nLTIwMjYtMTEtMDUiLCJkYXlOdW1iZXIiOjMsImRhdGUiOiIyMDI2LTExLTA3Iiwid2VlayI6MSwicGhhc2UiOiIwMSDCtyBQeXRob24gJiBGb3VuZGF0aW9ucyIsInBoYXNlTm8iOiIwMSIsInBoYXNlRGF5IjozLCJzdWJwaGFzZSI6IkZ1bmN0aW9uYWwgcGF0dGVybnMiLCJjb25jZXB0cyI6IkZ1bmN0aW9ucywgYXJndW1lbnRzLCBjb21wcmVoZW5zaW9ucywgaXRlcmF0b3JzLCBnZW5lcmF0b3JzIiwidGhlb3J5RGVsaXZlcmFibGUiOiJSZWFkICsgZGlhZ3JhbSArIDMgZmxhc2hjYXJkczsgaWRlbnRpZnkgMiBmYWlsdXJlIG1vZGVzIGluIGZ1bmN0aW9uYWwgcGF0dGVybnMuIiwiYmFzaWNUYXNrIjoiSW1wbGVtZW50IGdlbmVyYXRvciBmb3IgcGFnaW5hdGVkIEFQSSByZWNvcmRzIiwic2NlbmFyaW8iOiJQcm9jZXNzIDFNIGV2ZW50cyB3aXRob3V0IGxvYWRpbmcgaW50byBtZW1vcnkiLCJwcm9qZWN0V29ya3N0cmVhbSI6IkZvdW5kYXRpb24gbGFiIiwicHJvamVjdElkIjpudWxsLCJwcm9qZWN0VGFzayI6IkZPVU5EQVRJT04gTEFCOiBpbXBsZW1lbnQgdHlwZWQgSlNPTiBUYXNrIExvZ2dlciBDTEksIHRlc3QgaW5wdXQgdmFsaWRhdGlvbiwgY3JlYXRlIEdpdEh1YiByZXBvIGFuZCB3cml0ZSBsZWFybmluZyBub3Rlcy4iLCJwcm9qZWN0RGVsaXZlcmFibGUiOiJSdW5uYWJsZSBUYXNrIExvZ2dlciBDTEkgKyBweXRlc3QgdGVzdHMgKyBSRUFETUUgKGZvdW5kYXRpb24gbGFiLCBzZXBhcmF0ZSBmcm9tIFAwMeKAk1A1MCkuIiwiaW50ZXJ2aWV3IjoiR2VuZXJhdG9yIHZzIGxpc3Q7IHdoeSBkb2VzIGxhenkgcHJvY2Vzc2luZyBoZWxwPyIsImV4aXRDcml0ZXJpYSI6IkV4cGxhaW4gZnVuY3Rpb25hbCBwYXR0ZXJucyBpbiAyIG1pbnV0ZXM7IDEgdGVzdGVkIGNvbW1pdDsgb25lIHNjZW5hcmlvIGFuc3dlcjsgMy81IGludGVydmlldyBwcmFjdGljZSBxdWVzdGlvbnMuIiwicGxhbm5lZEhvdXJzIjo2LCJyZWZlcmVuY2VVcmwiOiJodHRwczovL2RvY3MucHl0aG9uLm9yZy8zL3R1dG9yaWFsLyIsInNjZW5hcmlvRm9ybWF0IjoiSW5wdXRzIOKGkiBjb25zdHJhaW50cyDihpIgZWRnZSBjYXNlcyDihpIgYWxnb3JpdGhtIOKGkiBjb21wbGV4aXR5IOKGkiB0ZXN0czsgY29kZSBhbmQgcmVmbGVjdCIsImludGVydmlld1N0cnVjdHVyZSI6IlVzZSBkZWZpbml0aW9uIOKGkiBleGFtcGxlIOKGkiB0cmFkZS1vZmYg4oaSIGNvbW1vbiBmYWlsdXJlIOKGkiBwcm9kdWN0aW9uIGltcGxpY2F0aW9uIn0seyJwbGFuSWQiOiJjaHJvbmlzLWFpLWVuZ2luZWVyaW5nLTIwMjYtMTEtMDUiLCJkYXlOdW1iZXIiOjQsImRhdGUiOiIyMDI2LTExLTA4Iiwid2VlayI6MSwicGhhc2UiOiIwMSDCtyBQeXRob24gJiBGb3VuZGF0aW9ucyIsInBoYXNlTm8iOiIwMSIsInBoYXNlRGF5Ijo0LCJzdWJwaGFzZSI6IkNsZWFuIGNvZGUgJiBPT1AiLCJjb25jZXB0cyI6IkNsYXNzZXMsIGRhdGFjbGFzc2VzLCBQcm90b2NvbCwgdHlwZSBoaW50cyBhbmQgbW9kdWxlIGJvdW5kYXJpZXMiLCJ0aGVvcnlEZWxpdmVyYWJsZSI6IlJlYWQgKyBkaWFncmFtICsgMyBmbGFzaGNhcmRzOyBpZGVudGlmeSAyIGZhaWx1cmUgbW9kZXMgaW4gY2xlYW4gY29kZSAmIG9vcC4iLCJiYXNpY1Rhc2siOiJEZWZpbmUgVGFzayBhbmQgVGFza1N0b3JlIHdpdGggZGF0YWNsYXNzZXMgYW5kIHR5cGVkIGludGVyZmFjZXMiLCJzY2VuYXJpbyI6IlJlZmFjdG9yIGEgbW9ub2xpdGggaW50byB0ZXN0YWJsZSBzZXJ2aWNlL3JlcG9zaXRvcnkgbW9kdWxlcyIsInByb2plY3RXb3Jrc3RyZWFtIjoiRm91bmRhdGlvbiBsYWIiLCJwcm9qZWN0SWQiOm51bGwsInByb2plY3RUYXNrIjoiRk9VTkRBVElPTiBMQUI6IGltcGxlbWVudCB0eXBlZCBKU09OIFRhc2sgTG9nZ2VyIENMSSwgdGVzdCBpbnB1dCB2YWxpZGF0aW9uLCBjcmVhdGUgR2l0SHViIHJlcG8gYW5kIHdyaXRlIGxlYXJuaW5nIG5vdGVzLiIsInByb2plY3REZWxpdmVyYWJsZSI6IlJ1bm5hYmxlIFRhc2sgTG9nZ2VyIENMSSArIHB5dGVzdCB0ZXN0cyArIFJFQURNRSAoZm91bmRhdGlvbiBsYWIsIHNlcGFyYXRlIGZyb20gUDAx4oCTUDUwKS4iLCJpbnRlcnZpZXciOiJDb21wb3NpdGlvbiB2ZXJzdXMgaW5oZXJpdGFuY2UgaW4gdG9vbCBhYnN0cmFjdGlvbnM/IiwiZXhpdENyaXRlcmlhIjoiRXhwbGFpbiBjbGVhbiBjb2RlICYgb29wIGluIDIgbWludXRlczsgMSB0ZXN0ZWQgY29tbWl0OyBvbmUgc2NlbmFyaW8gYW5zd2VyOyAzLzUgaW50ZXJ2aWV3IHByYWN0aWNlIHF1ZXN0aW9ucy4iLCJwbGFubmVkSG91cnMiOjYsInJlZmVyZW5jZVVybCI6Imh0dHBzOi8vZG9jcy5weXRob24ub3JnLzMvdHV0b3JpYWwvIiwic2NlbmFyaW9Gb3JtYXQiOiJJbnB1dHMg4oaSIGNvbnN0cmFpbnRzIOKGkiBlZGdlIGNhc2VzIOKGkiBhbGdvcml0aG0g4oaSIGNvbXBsZXhpdHkg4oaSIHRlc3RzOyBjb2RlIGFuZCByZWZsZWN0IiwiaW50ZXJ2aWV3U3RydWN0dXJlIjoiVXNlIGRlZmluaXRpb24g4oaSIGV4YW1wbGUg4oaSIHRyYWRlLW9mZiDihpIgY29tbW9uIGZhaWx1cmUg4oaSIHByb2R1Y3Rpb24gaW1wbGljYXRpb24ifSx7InBsYW5JZCI6ImNocm9uaXMtYWktZW5naW5lZXJpbmctMjAyNi0xMS0wNSIsImRheU51bWJlciI6NSwiZGF0ZSI6IjIwMjYtMTEtMDkiLCJ3ZWVrIjoxLCJwaGFzZSI6IjAxIMK3IFB5dGhvbiAmIEZvdW5kYXRpb25zIiwicGhhc2VObyI6IjAxIiwicGhhc2VEYXkiOjUsInN1YnBoYXNlIjoiUmVsaWFiaWxpdHkgZnVuZGFtZW50YWxzIiwiY29uY2VwdHMiOiJFeGNlcHRpb25zLCBzdHJ1Y3R1cmVkIGxvZ2dpbmcsIHZhbGlkYXRpb24sIHJldHJpZXMsIGJhY2tvZmYiLCJ0aGVvcnlEZWxpdmVyYWJsZSI6IlJlYWQgKyBkaWFncmFtICsgMyBmbGFzaGNhcmRzOyBpZGVudGlmeSAyIGZhaWx1cmUgbW9kZXMgaW4gcmVsaWFiaWxpdHkgZnVuZGFtZW50YWxzLiIsImJhc2ljVGFzayI6IkJ1aWxkIHNhZmUgcmV0cnkgZGVjb3JhdG9yIHdpdGggY2FwcGVkIGF0dGVtcHRzIiwic2NlbmFyaW8iOiJBdm9pZCBkdXBsaWNhdGUgd3JpdGVzIHdoZW4gQVBJIHRpbWVzIG91dCB0aGVuIHJldHJpZXMiLCJwcm9qZWN0V29ya3N0cmVhbSI6IkZvdW5kYXRpb24gbGFiIiwicHJvamVjdElkIjpudWxsLCJwcm9qZWN0VGFzayI6IkZPVU5EQVRJT04gTEFCOiBpbXBsZW1lbnQgdHlwZWQgSlNPTiBUYXNrIExvZ2dlciBDTEksIHRlc3QgaW5wdXQgdmFsaWRhdGlvbiwgY3JlYXRlIEdpdEh1YiByZXBvIGFuZCB3cml0ZSBsZWFybmluZyBub3Rlcy4iLCJwcm9qZWN0RGVsaXZlcmFibGUiOiJSdW5uYWJsZSBUYXNrIExvZ2dlciBDTEkgKyBweXRlc3QgdGVzdHMgKyBSRUFETUUgKGZvdW5kYXRpb24gbGFiLCBzZXBhcmF0ZSBmcm9tIFAwMeKAk1A1MCkuIiwiaW50ZXJ2aWV3IjoiV2hlbiBzaG91bGQgYSBmYWlsdXJlIGJlIHJldHJpZWQgYW5kIHdoZW4gc3VyZmFjZWQ/IiwiZXhpdENyaXRlcmlhIjoiRXhwbGFpbiByZWxpYWJpbGl0eSBmdW5kYW1lbnRhbHMgaW4gMiBtaW51dGVzOyAxIHRlc3RlZCBjb21taXQ7IG9uZSBzY2VuYXJpbyBhbnN3ZXI7IDMvNSBpbnRlcnZpZXcgcHJhY3RpY2UgcXVlc3Rpb25zLiIsInBsYW5uZWRIb3VycyI6NiwicmVmZXJlbmNlVXJsIjoiaHR0cHM6Ly9kb2NzLnB5dGhvbi5vcmcvMy90dXRvcmlhbC8iLCJzY2VuYXJpb0Zvcm1hdCI6IklucHV0cyDihpIgY29uc3RyYWludHMg4oaSIGVkZ2UgY2FzZXMg4oaSIGFsZ29yaXRobSDihpIgY29tcGxleGl0eSDihpIgdGVzdHM7IGNvZGUgYW5kIHJlZmxlY3QiLCJpbnRlcnZpZXdTdHJ1Y3R1cmUiOiJVc2UgZGVmaW5pdGlvbiDihpIgZXhhbXBsZSDihpIgdHJhZGUtb2ZmIOKGkiBjb21tb24gZmFpbHVyZSDihpIgcHJvZHVjdGlvbiBpbXBsaWNhdGlvbiJ9LHsicGxhbklkIjoiY2hyb25pcy1haS1lbmdpbmVlcmluZy0yMDI2LTExLTA1IiwiZGF5TnVtYmVyIjo2LCJkYXRlIjoiMjAyNi0xMS0xMCIsIndlZWsiOjEsInBoYXNlIjoiMDEgwrcgUHl0aG9uICYgRm91bmRhdGlvbnMiLCJwaGFzZU5vIjoiMDEiLCJwaGFzZURheSI6Niwic3VicGhhc2UiOiJGaWxlcyAmIEFQSXMiLCJjb25jZXB0cyI6InBhdGhsaWIsIGpzb24sIGNzdiwgSFRUUCBzdGF0dXMsIHJlcXVlc3RzL2h0dHB4LCBzZWNyZXRzIiwidGhlb3J5RGVsaXZlcmFibGUiOiJSZWFkICsgZGlhZ3JhbSArIDMgZmxhc2hjYXJkczsgaWRlbnRpZnkgMiBmYWlsdXJlIG1vZGVzIGluIGZpbGVzICYgYXBpcy4iLCJiYXNpY1Rhc2siOiJDcmVhdGUgSlNPTiBwZXJzaXN0ZW5jZSArIENTViBpbXBvcnQgKyBtb2NrIEhUVFAgYWRhcHRlciIsInNjZW5hcmlvIjoiUmVjb3ZlciBncmFjZWZ1bGx5IGZyb20gY29ycnVwdCB0YXNrIHN0b3JlIHdpdGhvdXQgZGVsZXRpbmcgdXNlciBkYXRhIiwicHJvamVjdFdvcmtzdHJlYW0iOiJQMzEgwrcgRGV2ZWxvcGVyIFByb2R1Y3Rpdml0eSBDTEkgJiBDb2RlIFF1YWxpdHkgQXNzaXN0YW50IiwicHJvamVjdElkIjoiUDMxIiwicHJvamVjdFRhc2siOiJTVEFSVCBQMzEgRGV2ZWxvcGVyIFByb2R1Y3Rpdml0eSBDTEkgJiBDb2RlIFF1YWxpdHkgQXNzaXN0YW50OiBDTEkgZm9yIHRhc2sgY3JlYXRpb24sIGxpbnQgc3VtbWFyeSBhbmQgdGVzdCBoaXN0b3J5LiBTaGlwIHNtYWxsZXN0IHZlcmlmaWFibGUgc2xpY2U7IGRvY3VtZW50IHRlc3RzLiIsInByb2plY3REZWxpdmVyYWJsZSI6IlAzMSBsYXVuY2g6IENMSSB3b3JrcyBvbiBzYW1wbGUgcmVwb3NpdG9yeTsgZW1pdHMgSlNPTiByZXBvcnQiLCJpbnRlcnZpZXciOiJXaHkgc2VwYXJhdGUgdHJhbnNwb3J0IGVycm9ycyBmcm9tIGRhdGEgdmFsaWRhdGlvbj8iLCJleGl0Q3JpdGVyaWEiOiJFeHBsYWluIGZpbGVzICYgYXBpcyBpbiAyIG1pbnV0ZXM7IDEgdGVzdGVkIGNvbW1pdDsgb25lIHNjZW5hcmlvIGFuc3dlcjsgMy81IGludGVydmlldyBwcmFjdGljZSBxdWVzdGlvbnMuIiwicGxhbm5lZEhvdXJzIjo2LCJyZWZlcmVuY2VVcmwiOiJodHRwczovL2RvY3MucHl0aG9uLm9yZy8zL3R1dG9yaWFsLyIsInNjZW5hcmlvRm9ybWF0IjoiSW5wdXRzIOKGkiBjb25zdHJhaW50cyDihpIgZWRnZSBjYXNlcyDihpIgYWxnb3JpdGhtIOKGkiBjb21wbGV4aXR5IOKGkiB0ZXN0czsgY29kZSBhbmQgcmVmbGVjdCIsImludGVydmlld1N0cnVjdHVyZSI6IlVzZSBkZWZpbml0aW9uIOKGkiBleGFtcGxlIOKGkiB0cmFkZS1vZmYg4oaSIGNvbW1vbiBmYWlsdXJlIOKGkiBwcm9kdWN0aW9uIGltcGxpY2F0aW9uIn0seyJwbGFuSWQiOiJjaHJvbmlzLWFpLWVuZ2luZWVyaW5nLTIwMjYtMTEtMDUiLCJkYXlOdW1iZXIiOjcsImRhdGUiOiIyMDI2LTExLTExIiwid2VlayI6MSwicGhhc2UiOiIwMSDCtyBQeXRob24gJiBGb3VuZGF0aW9ucyIsInBoYXNlTm8iOiIwMSIsInBoYXNlRGF5Ijo3LCJzdWJwaGFzZSI6Ik51bWVyaWNhbCBiYXNpY3MiLCJjb25jZXB0cyI6Ik51bVB5IGFycmF5cywgYnJvYWRjYXN0aW5nLCBzaGFwZXMsIHZlY3Rvcml6YXRpb24sIGNvbXBsZXhpdHkiLCJ0aGVvcnlEZWxpdmVyYWJsZSI6IlJlYWQgKyBkaWFncmFtICsgMyBmbGFzaGNhcmRzOyBpZGVudGlmeSAyIGZhaWx1cmUgbW9kZXMgaW4gbnVtZXJpY2FsIGJhc2ljcy4iLCJiYXNpY1Rhc2siOiJDb21wYXJlIGxvb3AgdnMgdmVjdG9yaXplZCBub3JtYWxpemF0aW9uIiwic2NlbmFyaW8iOiJQcm9jZXNzIDUwayBmZWF0dXJlIHZlY3RvcnMgd2l0aCBtZW1vcnkgY29uc3RyYWludHMiLCJwcm9qZWN0V29ya3N0cmVhbSI6IlAzMSDCtyBEZXZlbG9wZXIgUHJvZHVjdGl2aXR5IENMSSAmIENvZGUgUXVhbGl0eSBBc3Npc3RhbnQiLCJwcm9qZWN0SWQiOiJQMzEiLCJwcm9qZWN0VGFzayI6IklURVJBVEUgUDMxIERldmVsb3BlciBQcm9kdWN0aXZpdHkgQ0xJICYgQ29kZSBRdWFsaXR5IEFzc2lzdGFudDogYWRkIGVkZ2UtY2FzZSBoYW5kbGluZywgdGVzdCBmaXh0dXJlLCByZXN1bHQgbG9nIG9yIEFQSSBjb250cmFjdCBhbGlnbmVkIHRvIHRvZGF54oCZcyB0b3BpYy4iLCJwcm9qZWN0RGVsaXZlcmFibGUiOiJPbmUgdGVzdGVkIGluY3JlbWVudGFsIGNvbW1pdCBmb3IgUDMxOyBub3RlIG9wZW4gZm9sbG93LXVwcyBpbiBiYWNrbG9nLiIsImludGVydmlldyI6IldoeSBkb2VzIHZlY3Rvcml6YXRpb24gb3V0cGVyZm9ybSBQeXRob24gbG9vcHM/IiwiZXhpdENyaXRlcmlhIjoiRXhwbGFpbiBudW1lcmljYWwgYmFzaWNzIGluIDIgbWludXRlczsgMSB0ZXN0ZWQgY29tbWl0OyBvbmUgc2NlbmFyaW8gYW5zd2VyOyAzLzUgaW50ZXJ2aWV3IHByYWN0aWNlIHF1ZXN0aW9ucy4iLCJwbGFubmVkSG91cnMiOjYsInJlZmVyZW5jZVVybCI6Imh0dHBzOi8vZG9jcy5weXRob24ub3JnLzMvdHV0b3JpYWwvIiwic2NlbmFyaW9Gb3JtYXQiOiJJbnB1dHMg4oaSIGNvbnN0cmFpbnRzIOKGkiBlZGdlIGNhc2VzIOKGkiBhbGdvcml0aG0g4oaSIGNvbXBsZXhpdHkg4oaSIHRlc3RzOyBjb2RlIGFuZCByZWZsZWN0IiwiaW50ZXJ2aWV3U3RydWN0dXJlIjoiVXNlIGRlZmluaXRpb24g4oaSIGV4YW1wbGUg4oaSIHRyYWRlLW9mZiDihpIgY29tbW9uIGZhaWx1cmUg4oaSIHByb2R1Y3Rpb24gaW1wbGljYXRpb24ifSx7InBsYW5JZCI6ImNocm9uaXMtYWktZW5naW5lZXJpbmctMjAyNi0xMS0wNSIsImRheU51bWJlciI6OCwiZGF0ZSI6IjIwMjYtMTEtMTIiLCJ3ZWVrIjoyLCJwaGFzZSI6IjAxIMK3IFB5dGhvbiAmIEZvdW5kYXRpb25zIiwicGhhc2VObyI6IjAxIiwicGhhc2VEYXkiOjgsInN1YnBoYXNlIjoiRGF0YSB3cmFuZ2xpbmciLCJjb25jZXB0cyI6IlBhbmRhcyBsb2FkaW5nLCBqb2lucywgbWlzc2luZyBkYXRhLCBkdXBsaWNhdGVzLCB0eXBlcyIsInRoZW9yeURlbGl2ZXJhYmxlIjoiUmVhZCArIGRpYWdyYW0gKyAzIGZsYXNoY2FyZHM7IGlkZW50aWZ5IDIgZmFpbHVyZSBtb2RlcyBpbiBkYXRhIHdyYW5nbGluZy4iLCJiYXNpY1Rhc2siOiJDbGVhbiBhIENTViBhbmQgb3V0cHV0IHN1bW1hcnkgc3RhdGlzdGljcyIsInNjZW5hcmlvIjoiQ3JlYXRlIHJlcHJvZHVjaWJsZSBjbGVhbmluZyBmb3IgbWl4ZWQgbnVsbCBhbmQgbWlzc2luZyBjYXRlZ29yaWVzIiwicHJvamVjdFdvcmtzdHJlYW0iOiJQMDEgwrcgSW50ZWxsaWdlbnQgRGF0YSBBbmFseXplciIsInByb2plY3RJZCI6IlAwMSIsInByb2plY3RUYXNrIjoiU1RBUlQgUDAxIEludGVsbGlnZW50IERhdGEgQW5hbHl6ZXI6IFVwbG9hZCBDU1YgYW5kIEV4Y2VsIGZpbGVzLjsgQW5hbHl6ZSBtaXNzaW5nIHZhbHVlcyBhbmQgb3V0bGllcnMuOyBHZW5lcmF0ZSBzdGF0aXN0aWNhbCByZXBvcnRzLi4gU2hpcCBzbWFsbGVzdCB2ZXJpZmlhYmxlIHNsaWNlOyBkb2N1bWVudCB0ZXN0cy4iLCJwcm9qZWN0RGVsaXZlcmFibGUiOiJQMDEgbGF1bmNoOiBSdW5uYWJsZSBkZW1vOyBhdXRvbWF0ZWQgdGVzdHM7IFJFQURNRTsgdXBsb2FkIGNzdiBhbmQgZXhjZWwgZmlsZXMuIiwiaW50ZXJ2aWV3IjoiV2hhdCBjYXVzZXMgc2lsZW50IGxlYWthZ2UgaW4gcHJlcHJvY2Vzc2luZz8iLCJleGl0Q3JpdGVyaWEiOiJFeHBsYWluIGRhdGEgd3JhbmdsaW5nIGluIDIgbWludXRlczsgMSB0ZXN0ZWQgY29tbWl0OyBvbmUgc2NlbmFyaW8gYW5zd2VyOyAzLzUgaW50ZXJ2aWV3IHByYWN0aWNlIHF1ZXN0aW9ucy4iLCJwbGFubmVkSG91cnMiOjYsInJlZmVyZW5jZVVybCI6Imh0dHBzOi8vZG9jcy5weXRob24ub3JnLzMvdHV0b3JpYWwvIiwic2NlbmFyaW9Gb3JtYXQiOiJJbnB1dHMg4oaSIGNvbnN0cmFpbnRzIOKGkiBlZGdlIGNhc2VzIOKGkiBhbGdvcml0aG0g4oaSIGNvbXBsZXhpdHkg4oaSIHRlc3RzOyBjb2RlIGFuZCByZWZsZWN0IiwiaW50ZXJ2aWV3U3RydWN0dXJlIjoiVXNlIGRlZmluaXRpb24g4oaSIGV4YW1wbGUg4oaSIHRyYWRlLW9mZiDihpIgY29tbW9uIGZhaWx1cmUg4oaSIHByb2R1Y3Rpb24gaW1wbGljYXRpb24ifSx7InBsYW5JZCI6ImNocm9uaXMtYWktZW5naW5lZXJpbmctMjAyNi0xMS0wNSIsImRheU51bWJlciI6OSwiZGF0ZSI6IjIwMjYtMTEtMTMiLCJ3ZWVrIjoyLCJwaGFzZSI6IjAxIMK3IFB5dGhvbiAmIEZvdW5kYXRpb25zIiwicGhhc2VObyI6IjAxIiwicGhhc2VEYXkiOjksInN1YnBoYXNlIjoiTWF0aCAmIHN0YXRpc3RpY3MiLCJjb25jZXB0cyI6Ik1lYW4vdmFyaWFuY2UsIGRpc3RyaWJ1dGlvbnMsIHByb2JhYmlsaXR5LCBCYXllcyBpbnR1aXRpb24iLCJ0aGVvcnlEZWxpdmVyYWJsZSI6IlJlYWQgKyBkaWFncmFtICsgMyBmbGFzaGNhcmRzOyBpZGVudGlmeSAyIGZhaWx1cmUgbW9kZXMgaW4gbWF0aCAmIHN0YXRpc3RpY3MuIiwiYmFzaWNUYXNrIjoiQ2FsY3VsYXRlIHotc2NvcmVzIGFuZCBjb25maWRlbmNlIGludGVydmFscyBmcm9tIGEgc2FtcGxlIiwic2NlbmFyaW8iOiJEZXRlY3QgYW5vbWFsb3VzIHRyYW5zYWN0aW9uIGFtb3VudHMgcm9idXN0bHkiLCJwcm9qZWN0V29ya3N0cmVhbSI6IlAwMSDCtyBJbnRlbGxpZ2VudCBEYXRhIEFuYWx5emVyIiwicHJvamVjdElkIjoiUDAxIiwicHJvamVjdFRhc2siOiJJVEVSQVRFIFAwMSBJbnRlbGxpZ2VudCBEYXRhIEFuYWx5emVyOiBhZGQgZWRnZS1jYXNlIGhhbmRsaW5nLCB0ZXN0IGZpeHR1cmUsIHJlc3VsdCBsb2cgb3IgQVBJIGNvbnRyYWN0IGFsaWduZWQgdG8gdG9kYXnigJlzIHRvcGljLiIsInByb2plY3REZWxpdmVyYWJsZSI6Ik9uZSB0ZXN0ZWQgaW5jcmVtZW50YWwgY29tbWl0IGZvciBQMDE7IG5vdGUgb3BlbiBmb2xsb3ctdXBzIGluIGJhY2tsb2cuIiwiaW50ZXJ2aWV3IjoiTWVhbiB2ZXJzdXMgbWVkaWFuIHVuZGVyIGV4dHJlbWUgb3V0bGllcnM/IiwiZXhpdENyaXRlcmlhIjoiRXhwbGFpbiBtYXRoICYgc3RhdGlzdGljcyBpbiAyIG1pbnV0ZXM7IDEgdGVzdGVkIGNvbW1pdDsgb25lIHNjZW5hcmlvIGFuc3dlcjsgMy81IGludGVydmlldyBwcmFjdGljZSBxdWVzdGlvbnMuIiwicGxhbm5lZEhvdXJzIjo2LCJyZWZlcmVuY2VVcmwiOiJodHRwczovL2RvY3MucHl0aG9uLm9yZy8zL3R1dG9yaWFsLyIsInNjZW5hcmlvRm9ybWF0IjoiSW5wdXRzIOKGkiBjb25zdHJhaW50cyDihpIgZWRnZSBjYXNlcyDihpIgYWxnb3JpdGhtIOKGkiBjb21wbGV4aXR5IOKGkiB0ZXN0czsgY29kZSBhbmQgcmVmbGVjdCIsImludGVydmlld1N0cnVjdHVyZSI6IlVzZSBkZWZpbml0aW9uIOKGkiBleGFtcGxlIOKGkiB0cmFkZS1vZmYg4oaSIGNvbW1vbiBmYWlsdXJlIOKGkiBwcm9kdWN0aW9uIGltcGxpY2F0aW9uIn0seyJwbGFuSWQiOiJjaHJvbmlzLWFpLWVuZ2luZWVyaW5nLTIwMjYtMTEtMDUiLCJkYXlOdW1iZXIiOjEwLCJkYXRlIjoiMjAyNi0xMS0xNCIsIndlZWsiOjIsInBoYXNlIjoiMDEgwrcgUHl0aG9uICYgRm91bmRhdGlvbnMiLCJwaGFzZU5vIjoiMDEiLCJwaGFzZURheSI6MTAsInN1YnBoYXNlIjoiVmlzdWFsaXphdGlvbiAmIHRlc3RzIiwiY29uY2VwdHMiOiJNYXRwbG90bGliLCBweXRlc3QsIGZpeHR1cmVzLCBHaXRIdWIgQ0kgYmFzaWNzLCBwaGFzZSB0ZXN0IiwidGhlb3J5RGVsaXZlcmFibGUiOiJSZWFkICsgZGlhZ3JhbSArIDMgZmxhc2hjYXJkczsgaWRlbnRpZnkgMiBmYWlsdXJlIG1vZGVzIGluIHZpc3VhbGl6YXRpb24gJiB0ZXN0cy4iLCJiYXNpY1Rhc2siOiJVbml0LXRlc3QgVGFza0xvZ2dlciBhbmQgcmVuZGVyIG1pbmkgZGF0YS1xdWFsaXR5IHJlcG9ydCIsInNjZW5hcmlvIjoiV3JpdGUgcmVncmVzc2lvbiB0ZXN0cyBmb3IgbWFsZm9ybWVkIENTViBhbmQgbWlzc2luZyBjb2x1bW5zIiwicHJvamVjdFdvcmtzdHJlYW0iOiJQMDEgwrcgSW50ZWxsaWdlbnQgRGF0YSBBbmFseXplciIsInByb2plY3RJZCI6IlAwMSIsInByb2plY3RUYXNrIjoiSVRFUkFURSBQMDEgSW50ZWxsaWdlbnQgRGF0YSBBbmFseXplcjogYWRkIGVkZ2UtY2FzZSBoYW5kbGluZywgdGVzdCBmaXh0dXJlLCByZXN1bHQgbG9nIG9yIEFQSSBjb250cmFjdCBhbGlnbmVkIHRvIHRvZGF54oCZcyB0b3BpYy4iLCJwcm9qZWN0RGVsaXZlcmFibGUiOiJPbmUgdGVzdGVkIGluY3JlbWVudGFsIGNvbW1pdCBmb3IgUDAxOyBub3RlIG9wZW4gZm9sbG93LXVwcyBpbiBiYWNrbG9nLiIsImludGVydmlldyI6IldoYXQgc2hvdWxkIGFuIEFJIGRhdGEgcGlwZWxpbmUgdW5pdCB0ZXN0IGNvdmVyPyIsImV4aXRDcml0ZXJpYSI6IkV4cGxhaW4gdmlzdWFsaXphdGlvbiAmIHRlc3RzIGluIDIgbWludXRlczsgMSB0ZXN0ZWQgY29tbWl0OyBvbmUgc2NlbmFyaW8gYW5zd2VyOyAzLzUgaW50ZXJ2aWV3IHByYWN0aWNlIHF1ZXN0aW9ucy4iLCJwbGFubmVkSG91cnMiOjYsInJlZmVyZW5jZVVybCI6Imh0dHBzOi8vZG9jcy5weXRob24ub3JnLzMvdHV0b3JpYWwvIiwic2NlbmFyaW9Gb3JtYXQiOiJJbnB1dHMg4oaSIGNvbnN0cmFpbnRzIOKGkiBlZGdlIGNhc2VzIOKGkiBhbGdvcml0aG0g4oaSIGNvbXBsZXhpdHkg4oaSIHRlc3RzOyBjb2RlIGFuZCByZWZsZWN0IiwiaW50ZXJ2aWV3U3RydWN0dXJlIjoiVXNlIGRlZmluaXRpb24g4oaSIGV4YW1wbGUg4oaSIHRyYWRlLW9mZiDihpIgY29tbW9uIGZhaWx1cmUg4oaSIHByb2R1Y3Rpb24gaW1wbGljYXRpb24ifSx7InBsYW5JZCI6ImNocm9uaXMtYWktZW5naW5lZXJpbmctMjAyNi0xMS0wNSIsImRheU51bWJlciI6MTEsImRhdGUiOiIyMDI2LTExLTE1Iiwid2VlayI6MiwicGhhc2UiOiIwMiDCtyBDbGFzc2ljYWwgTUwiLCJwaGFzZU5vIjoiMDIiLCJwaGFzZURheSI6MSwic3VicGhhc2UiOiJNTCBsaWZlY3ljbGUiLCJjb25jZXB0cyI6IlByb2JsZW0gZnJhbWluZywgc3VwZXJ2aXNlZCB0YXNrcywgZGF0YSBzcGxpdHMsIGJhc2VsaW5lcyIsInRoZW9yeURlbGl2ZXJhYmxlIjoiUmVhZCArIGRpYWdyYW0gKyAzIGZsYXNoY2FyZHM7IGlkZW50aWZ5IDIgZmFpbHVyZSBtb2RlcyBpbiBtbCBsaWZlY3ljbGUuIiwiYmFzaWNUYXNrIjoiVHJhaW4gYmFzZWxpbmUgaG91c2UtcHJpY2UgcmVncmVzc29yIG9uIHNwbGl0IGRhdGFzZXQiLCJzY2VuYXJpbyI6IkF2b2lkIGxlYWthZ2Ugd2l0aCB0YXJnZXQtZGVyaXZlZCBpbnB1dCBmaWVsZHMiLCJwcm9qZWN0V29ya3N0cmVhbSI6IlAwMiDCtyBIb3VzZSBQcmljZSBQcmVkaWN0aW9uIiwicHJvamVjdElkIjoiUDAyIiwicHJvamVjdFRhc2siOiJTVEFSVCBQMDIgSG91c2UgUHJpY2UgUHJlZGljdGlvbjogRGF0YXNldCBwcmVwcm9jZXNzaW5nLjsgTGluZWFyIGFuZCBtdWx0aXBsZSByZWdyZXNzaW9uLjsgRmVhdHVyZSBlbmdpbmVlcmluZy4uIFNoaXAgc21hbGxlc3QgdmVyaWZpYWJsZSBzbGljZTsgZG9jdW1lbnQgdGVzdHMuIiwicHJvamVjdERlbGl2ZXJhYmxlIjoiUDAyIGxhdW5jaDogUnVubmFibGUgZGVtbzsgYXV0b21hdGVkIHRlc3RzOyBSRUFETUU7IGRhdGFzZXQgcHJlcHJvY2Vzc2luZy4iLCJpbnRlcnZpZXciOiJXaHkgbXVzdCB2YWxpZGF0aW9uIGRhdGEgYmUgaGVsZCBvdXQ/IiwiZXhpdENyaXRlcmlhIjoiRXhwbGFpbiBtbCBsaWZlY3ljbGUgaW4gMiBtaW51dGVzOyAxIHRlc3RlZCBjb21taXQ7IG9uZSBzY2VuYXJpbyBhbnN3ZXI7IDMvNSBpbnRlcnZpZXcgcHJhY3RpY2UgcXVlc3Rpb25zLiIsInBsYW5uZWRIb3VycyI6NiwicmVmZXJlbmNlVXJsIjoiaHR0cHM6Ly9zY2lraXQtbGVhcm4ub3JnL3N0YWJsZS91c2VyX2d1aWRlLmh0bWwiLCJzY2VuYXJpb0Zvcm1hdCI6IklucHV0cyDihpIgY29uc3RyYWludHMg4oaSIGVkZ2UgY2FzZXMg4oaSIGFsZ29yaXRobSDihpIgY29tcGxleGl0eSDihpIgdGVzdHM7IGNvZGUgYW5kIHJlZmxlY3QiLCJpbnRlcnZpZXdTdHJ1Y3R1cmUiOiJVc2UgZGVmaW5pdGlvbiDihpIgZXhhbXBsZSDihpIgdHJhZGUtb2ZmIOKGkiBjb21tb24gZmFpbHVyZSDihpIgcHJvZHVjdGlvbiBpbXBsaWNhdGlvbiJ9LHsicGxhbklkIjoiY2hyb25pcy1haS1lbmdpbmVlcmluZy0yMDI2LTExLTA1IiwiZGF5TnVtYmVyIjoxMiwiZGF0ZSI6IjIwMjYtMTEtMTYiLCJ3ZWVrIjoyLCJwaGFzZSI6IjAyIMK3IENsYXNzaWNhbCBNTCIsInBoYXNlTm8iOiIwMiIsInBoYXNlRGF5IjoyLCJzdWJwaGFzZSI6IkZlYXR1cmUgZW5naW5lZXJpbmciLCJjb25jZXB0cyI6IlNjYWxpbmcsIGVuY29kaW5nLCBtaXNzaW5nbmVzcywgbGVha2FnZSBhbmQgQ29sdW1uVHJhbnNmb3JtZXIiLCJ0aGVvcnlEZWxpdmVyYWJsZSI6IlJlYWQgKyBkaWFncmFtICsgMyBmbGFzaGNhcmRzOyBpZGVudGlmeSAyIGZhaWx1cmUgbW9kZXMgaW4gZmVhdHVyZSBlbmdpbmVlcmluZy4iLCJiYXNpY1Rhc2siOiJCdWlsZCB0cmFpbi1vbmx5IHByZXByb2Nlc3NpbmcgcGlwZWxpbmUiLCJzY2VuYXJpbyI6IkNhdGVnb3JpY2FsIHZhbHVlIHVuc2VlbiBhdCBpbmZlcmVuY2UgY2F1c2VzIHRyYW5zZm9ybSBmYWlsdXJlIiwicHJvamVjdFdvcmtzdHJlYW0iOiJQMDIgwrcgSG91c2UgUHJpY2UgUHJlZGljdGlvbiIsInByb2plY3RJZCI6IlAwMiIsInByb2plY3RUYXNrIjoiSVRFUkFURSBQMDIgSG91c2UgUHJpY2UgUHJlZGljdGlvbjogYWRkIGVkZ2UtY2FzZSBoYW5kbGluZywgdGVzdCBmaXh0dXJlLCByZXN1bHQgbG9nIG9yIEFQSSBjb250cmFjdCBhbGlnbmVkIHRvIHRvZGF54oCZcyB0b3BpYy4iLCJwcm9qZWN0RGVsaXZlcmFibGUiOiJPbmUgdGVzdGVkIGluY3JlbWVudGFsIGNvbW1pdCBmb3IgUDAyOyBub3RlIG9wZW4gZm9sbG93LXVwcyBpbiBiYWNrbG9nLiIsImludGVydmlldyI6IldoeSBmaXQgcHJlcHJvY2Vzc2luZyBvbmx5IG9uIHRyYWluIGRhdGE/IiwiZXhpdENyaXRlcmlhIjoiRXhwbGFpbiBmZWF0dXJlIGVuZ2luZWVyaW5nIGluIDIgbWludXRlczsgMSB0ZXN0ZWQgY29tbWl0OyBvbmUgc2NlbmFyaW8gYW5zd2VyOyAzLzUgaW50ZXJ2aWV3IHByYWN0aWNlIHF1ZXN0aW9ucy4iLCJwbGFubmVkSG91cnMiOjYsInJlZmVyZW5jZVVybCI6Imh0dHBzOi8vc2Npa2l0LWxlYXJuLm9yZy9zdGFibGUvdXNlcl9ndWlkZS5odG1sIiwic2NlbmFyaW9Gb3JtYXQiOiJJbnB1dHMg4oaSIGNvbnN0cmFpbnRzIOKGkiBlZGdlIGNhc2VzIOKGkiBhbGdvcml0aG0g4oaSIGNvbXBsZXhpdHkg4oaSIHRlc3RzOyBjb2RlIGFuZCByZWZsZWN0IiwiaW50ZXJ2aWV3U3RydWN0dXJlIjoiVXNlIGRlZmluaXRpb24g4oaSIGV4YW1wbGUg4oaSIHRyYWRlLW9mZiDihpIgY29tbW9uIGZhaWx1cmUg4oaSIHByb2R1Y3Rpb24gaW1wbGljYXRpb24ifSx7InBsYW5JZCI6ImNocm9uaXMtYWktZW5naW5lZXJpbmctMjAyNi0xMS0wNSIsImRheU51bWJlciI6MTMsImRhdGUiOiIyMDI2LTExLTE3Iiwid2VlayI6MiwicGhhc2UiOiIwMiDCtyBDbGFzc2ljYWwgTUwiLCJwaGFzZU5vIjoiMDIiLCJwaGFzZURheSI6Mywic3VicGhhc2UiOiJMaW5lYXIgbW9kZWxzIiwiY29uY2VwdHMiOiJMaW5lYXIvbG9naXN0aWMgcmVncmVzc2lvbiwgcmVndWxhcml6YXRpb24sIGNvc3QgYW5kIGdyYWRpZW50cyIsInRoZW9yeURlbGl2ZXJhYmxlIjoiUmVhZCArIGRpYWdyYW0gKyAzIGZsYXNoY2FyZHM7IGlkZW50aWZ5IDIgZmFpbHVyZSBtb2RlcyBpbiBsaW5lYXIgbW9kZWxzLiIsImJhc2ljVGFzayI6IkNvbXBhcmUgbGluZWFyIHZzIHJpZGdlIHJlZ3Jlc3Npb24gb24gaG91c2luZyBmZWF0dXJlcyIsInNjZW5hcmlvIjoiRXhwbGFpbiB1bmV4cGVjdGVkIGNvZWZmaWNpZW50IHNpZ24gYW5kIGNvcnJlbGF0ZWQgaW5wdXRzIiwicHJvamVjdFdvcmtzdHJlYW0iOiJQMDMgwrcgSW50ZWxsaWdlbnQgU3BhbSBEZXRlY3Rpb24iLCJwcm9qZWN0SWQiOiJQMDMiLCJwcm9qZWN0VGFzayI6IlNUQVJUIFAwMyBJbnRlbGxpZ2VudCBTcGFtIERldGVjdGlvbjogVGV4dCBwcmVwcm9jZXNzaW5nLjsgVG9rZW5pemF0aW9uLjsgVEYtSURGLi4gU2hpcCBzbWFsbGVzdCB2ZXJpZmlhYmxlIHNsaWNlOyBkb2N1bWVudCB0ZXN0cy4iLCJwcm9qZWN0RGVsaXZlcmFibGUiOiJQMDMgbGF1bmNoOiBSdW5uYWJsZSBkZW1vOyBhdXRvbWF0ZWQgdGVzdHM7IFJFQURNRTsgdGV4dCBwcmVwcm9jZXNzaW5nLiIsImludGVydmlldyI6IkJpYXMtdmFyaWFuY2UgYW5kIEwxIHZzIEwyIHRyYWRlLW9mZnM/IiwiZXhpdENyaXRlcmlhIjoiRXhwbGFpbiBsaW5lYXIgbW9kZWxzIGluIDIgbWludXRlczsgMSB0ZXN0ZWQgY29tbWl0OyBvbmUgc2NlbmFyaW8gYW5zd2VyOyAzLzUgaW50ZXJ2aWV3IHByYWN0aWNlIHF1ZXN0aW9ucy4iLCJwbGFubmVkSG91cnMiOjYsInJlZmVyZW5jZVVybCI6Imh0dHBzOi8vc2Npa2l0LWxlYXJuLm9yZy9zdGFibGUvdXNlcl9ndWlkZS5odG1sIiwic2NlbmFyaW9Gb3JtYXQiOiJJbnB1dHMg4oaSIGNvbnN0cmFpbnRzIOKGkiBlZGdlIGNhc2VzIOKGkiBhbGdvcml0aG0g4oaSIGNvbXBsZXhpdHkg4oaSIHRlc3RzOyBjb2RlIGFuZCByZWZsZWN0IiwiaW50ZXJ2aWV3U3RydWN0dXJlIjoiVXNlIGRlZmluaXRpb24g4oaSIGV4YW1wbGUg4oaSIHRyYWRlLW9mZiDihpIgY29tbW9uIGZhaWx1cmUg4oaSIHByb2R1Y3Rpb24gaW1wbGljYXRpb24ifSx7InBsYW5JZCI6ImNocm9uaXMtYWktZW5naW5lZXJpbmctMjAyNi0xMS0wNSIsImRheU51bWJlciI6MTQsImRhdGUiOiIyMDI2LTExLTE4Iiwid2VlayI6MiwicGhhc2UiOiIwMiDCtyBDbGFzc2ljYWwgTUwiLCJwaGFzZU5vIjoiMDIiLCJwaGFzZURheSI6NCwic3VicGhhc2UiOiJDbGFzc2lmaWNhdGlvbiBtZXRyaWNzIiwiY29uY2VwdHMiOiJDb25mdXNpb24gbWF0cml4LCBwcmVjaXNpb24sIHJlY2FsbCwgRjEsIHRocmVzaG9sZHMsIFBSLUFVQyIsInRoZW9yeURlbGl2ZXJhYmxlIjoiUmVhZCArIGRpYWdyYW0gKyAzIGZsYXNoY2FyZHM7IGlkZW50aWZ5IDIgZmFpbHVyZSBtb2RlcyBpbiBjbGFzc2lmaWNhdGlvbiBtZXRyaWNzLiIsImJhc2ljVGFzayI6IlR1bmUgc3BhbSBtb2RlbCB0aHJlc2hvbGQgYW5kIGNhbGN1bGF0ZSBtZXRyaWNzIiwic2NlbmFyaW8iOiJTZWxlY3QgaGlnaC1yZWNhbGwgbW9kZWwgdW5kZXIgY29zdGx5IGZhbHNlIG5lZ2F0aXZlcyIsInByb2plY3RXb3Jrc3RyZWFtIjoiUDAzIMK3IEludGVsbGlnZW50IFNwYW0gRGV0ZWN0aW9uIiwicHJvamVjdElkIjoiUDAzIiwicHJvamVjdFRhc2siOiJJVEVSQVRFIFAwMyBJbnRlbGxpZ2VudCBTcGFtIERldGVjdGlvbjogYWRkIGVkZ2UtY2FzZSBoYW5kbGluZywgdGVzdCBmaXh0dXJlLCByZXN1bHQgbG9nIG9yIEFQSSBjb250cmFjdCBhbGlnbmVkIHRvIHRvZGF54oCZcyB0b3BpYy4iLCJwcm9qZWN0RGVsaXZlcmFibGUiOiJPbmUgdGVzdGVkIGluY3JlbWVudGFsIGNvbW1pdCBmb3IgUDAzOyBub3RlIG9wZW4gZm9sbG93LXVwcyBpbiBiYWNrbG9nLiIsImludGVydmlldyI6IldoeSBpcyBhY2N1cmFjeSBtaXNsZWFkaW5nIGZvciBpbWJhbGFuY2VkIGRhdGE/IiwiZXhpdENyaXRlcmlhIjoiRXhwbGFpbiBjbGFzc2lmaWNhdGlvbiBtZXRyaWNzIGluIDIgbWludXRlczsgMSB0ZXN0ZWQgY29tbWl0OyBvbmUgc2NlbmFyaW8gYW5zd2VyOyAzLzUgaW50ZXJ2aWV3IHByYWN0aWNlIHF1ZXN0aW9ucy4iLCJwbGFubmVkSG91cnMiOjYsInJlZmVyZW5jZVVybCI6Imh0dHBzOi8vc2Npa2l0LWxlYXJuLm9yZy9zdGFibGUvdXNlcl9ndWlkZS5odG1sIiwic2NlbmFyaW9Gb3JtYXQiOiJJbnB1dHMg4oaSIGNvbnN0cmFpbnRzIOKGkiBlZGdlIGNhc2VzIOKGkiBhbGdvcml0aG0g4oaSIGNvbXBsZXhpdHkg4oaSIHRlc3RzOyBjb2RlIGFuZCByZWZsZWN0IiwiaW50ZXJ2aWV3U3RydWN0dXJlIjoiVXNlIGRlZmluaXRpb24g4oaSIGV4YW1wbGUg4oaSIHRyYWRlLW9mZiDihpIgY29tbW9uIGZhaWx1cmUg4oaSIHByb2R1Y3Rpb24gaW1wbGljYXRpb24ifSx7InBsYW5JZCI6ImNocm9uaXMtYWktZW5naW5lZXJpbmctMjAyNi0xMS0wNSIsImRheU51bWJlciI6MTUsImRhdGUiOiIyMDI2LTExLTE5Iiwid2VlayI6MywicGhhc2UiOiIwMiDCtyBDbGFzc2ljYWwgTUwiLCJwaGFzZU5vIjoiMDIiLCJwaGFzZURheSI6NSwic3VicGhhc2UiOiJUcmVlIGVuc2VtYmxlcyIsImNvbmNlcHRzIjoiRGVjaXNpb24gdHJlZXMsIHJhbmRvbSBmb3Jlc3RzLCBYR0Jvb3N0LCBmZWF0dXJlIGltcG9ydGFuY2UiLCJ0aGVvcnlEZWxpdmVyYWJsZSI6IlJlYWQgKyBkaWFncmFtICsgMyBmbGFzaGNhcmRzOyBpZGVudGlmeSAyIGZhaWx1cmUgbW9kZXMgaW4gdHJlZSBlbnNlbWJsZXMuIiwiYmFzaWNUYXNrIjoiRml0IGNodXJuIGNsYXNzaWZpZXJzIGFuZCBjb21wYXJlIGNyb3NzLXZhbGlkYXRpb24iLCJzY2VuYXJpbyI6IkV4cGxhaW4gdHJhaW4gaGlnaCBzY29yZSBidXQgcHJvZHVjdGlvbiBwb29yIHNjb3JlIiwicHJvamVjdFdvcmtzdHJlYW0iOiJQMDQgwrcgQ3VzdG9tZXIgQ2h1cm4gUHJlZGljdGlvbiIsInByb2plY3RJZCI6IlAwNCIsInByb2plY3RUYXNrIjoiU1RBUlQgUDA0IEN1c3RvbWVyIENodXJuIFByZWRpY3Rpb246IEFuYWx5emUgY3VzdG9tZXIgYmVoYXZpb3VyLjsgRmVhdHVyZSBzZWxlY3Rpb24uOyBUcmFpbiBtdWx0aXBsZSBjbGFzc2lmaWVycy4uIFNoaXAgc21hbGxlc3QgdmVyaWZpYWJsZSBzbGljZTsgZG9jdW1lbnQgdGVzdHMuIiwicHJvamVjdERlbGl2ZXJhYmxlIjoiUDA0IGxhdW5jaDogUnVubmFibGUgZGVtbzsgYXV0b21hdGVkIHRlc3RzOyBSRUFETUU7IGFuYWx5emUgY3VzdG9tZXIgYmVoYXZpb3VyLiIsImludGVydmlldyI6IkhvdyBkZXRlY3QgYW5kIHJlcGFpciBvdmVyZml0dGluZz8iLCJleGl0Q3JpdGVyaWEiOiJFeHBsYWluIHRyZWUgZW5zZW1ibGVzIGluIDIgbWludXRlczsgMSB0ZXN0ZWQgY29tbWl0OyBvbmUgc2NlbmFyaW8gYW5zd2VyOyAzLzUgaW50ZXJ2aWV3IHByYWN0aWNlIHF1ZXN0aW9ucy4iLCJwbGFubmVkSG91cnMiOjYsInJlZmVyZW5jZVVybCI6Imh0dHBzOi8vc2Npa2l0LWxlYXJuLm9yZy9zdGFibGUvdXNlcl9ndWlkZS5odG1sIiwic2NlbmFyaW9Gb3JtYXQiOiJJbnB1dHMg4oaSIGNvbnN0cmFpbnRzIOKGkiBlZGdlIGNhc2VzIOKGkiBhbGdvcml0aG0g4oaSIGNvbXBsZXhpdHkg4oaSIHRlc3RzOyBjb2RlIGFuZCByZWZsZWN0IiwiaW50ZXJ2aWV3U3RydWN0dXJlIjoiVXNlIGRlZmluaXRpb24g4oaSIGV4YW1wbGUg4oaSIHRyYWRlLW9mZiDihpIgY29tbW9uIGZhaWx1cmUg4oaSIHByb2R1Y3Rpb24gaW1wbGljYXRpb24ifSx7InBsYW5JZCI6ImNocm9uaXMtYWktZW5naW5lZXJpbmctMjAyNi0xMS0wNSIsImRheU51bWJlciI6MTYsImRhdGUiOiIyMDI2LTExLTIwIiwid2VlayI6MywicGhhc2UiOiIwMiDCtyBDbGFzc2ljYWwgTUwiLCJwaGFzZU5vIjoiMDIiLCJwaGFzZURheSI6Niwic3VicGhhc2UiOiJWYWxpZGF0aW9uIHBhdHRlcm5zIiwiY29uY2VwdHMiOiJLLWZvbGQvc3RyYXRpZmllZCBzcGxpdHMsIHR1bmluZywgR3JpZFNlYXJjaC9SYW5kb21pemVkU2VhcmNoIiwidGhlb3J5RGVsaXZlcmFibGUiOiJSZWFkICsgZGlhZ3JhbSArIDMgZmxhc2hjYXJkczsgaWRlbnRpZnkgMiBmYWlsdXJlIG1vZGVzIGluIHZhbGlkYXRpb24gcGF0dGVybnMuIiwiYmFzaWNUYXNrIjoiV3JpdGUgY3Jvc3MtdmFsaWRhdGlvbiArIGNvbmZpZy1kcml2ZW4gdHVuaW5nIiwic2NlbmFyaW8iOiJTZXQgdXAgZ3JvdXBlZCBzcGxpdCBmb3Igc2FtZS1jdXN0b21lciByZWNvcmRzIiwicHJvamVjdFdvcmtzdHJlYW0iOiJQMDQgwrcgQ3VzdG9tZXIgQ2h1cm4gUHJlZGljdGlvbiIsInByb2plY3RJZCI6IlAwNCIsInByb2plY3RUYXNrIjoiSVRFUkFURSBQMDQgQ3VzdG9tZXIgQ2h1cm4gUHJlZGljdGlvbjogYWRkIGVkZ2UtY2FzZSBoYW5kbGluZywgdGVzdCBmaXh0dXJlLCByZXN1bHQgbG9nIG9yIEFQSSBjb250cmFjdCBhbGlnbmVkIHRvIHRvZGF54oCZcyB0b3BpYy4iLCJwcm9qZWN0RGVsaXZlcmFibGUiOiJPbmUgdGVzdGVkIGluY3JlbWVudGFsIGNvbW1pdCBmb3IgUDA0OyBub3RlIG9wZW4gZm9sbG93LXVwcyBpbiBiYWNrbG9nLiIsImludGVydmlldyI6Ikdyb3VwZWQgdmVyc3VzIHJhbmRvbSBjcm9zcy12YWxpZGF0aW9uPyIsImV4aXRDcml0ZXJpYSI6IkV4cGxhaW4gdmFsaWRhdGlvbiBwYXR0ZXJucyBpbiAyIG1pbnV0ZXM7IDEgdGVzdGVkIGNvbW1pdDsgb25lIHNjZW5hcmlvIGFuc3dlcjsgMy81IGludGVydmlldyBwcmFjdGljZSBxdWVzdGlvbnMuIiwicGxhbm5lZEhvdXJzIjo2LCJyZWZlcmVuY2VVcmwiOiJodHRwczovL3NjaWtpdC1sZWFybi5vcmcvc3RhYmxlL3VzZXJfZ3VpZGUuaHRtbCIsInNjZW5hcmlvRm9ybWF0IjoiSW5wdXRzIOKGkiBjb25zdHJhaW50cyDihpIgZWRnZSBjYXNlcyDihpIgYWxnb3JpdGhtIOKGkiBjb21wbGV4aXR5IOKGkiB0ZXN0czsgY29kZSBhbmQgcmVmbGVjdCIsImludGVydmlld1N0cnVjdHVyZSI6IlVzZSBkZWZpbml0aW9uIOKGkiBleGFtcGxlIOKGkiB0cmFkZS1vZmYg4oaSIGNvbW1vbiBmYWlsdXJlIOKGkiBwcm9kdWN0aW9uIGltcGxpY2F0aW9uIn0seyJwbGFuSWQiOiJjaHJvbmlzLWFpLWVuZ2luZWVyaW5nLTIwMjYtMTEtMDUiLCJkYXlOdW1iZXIiOjE3LCJkYXRlIjoiMjAyNi0xMS0yMSIsIndlZWsiOjMsInBoYXNlIjoiMDIgwrcgQ2xhc3NpY2FsIE1MIiwicGhhc2VObyI6IjAyIiwicGhhc2VEYXkiOjcsInN1YnBoYXNlIjoiUmVjb21tZW5kYXRpb24gc3lzdGVtcyIsImNvbmNlcHRzIjoiQ29zaW5lIHNpbWlsYXJpdHksIFRGLUlERiwgdXNlci1pdGVtIG1hdHJpY2VzLCB0b3AtSyByYW5raW5nIiwidGhlb3J5RGVsaXZlcmFibGUiOiJSZWFkICsgZGlhZ3JhbSArIDMgZmxhc2hjYXJkczsgaWRlbnRpZnkgMiBmYWlsdXJlIG1vZGVzIGluIHJlY29tbWVuZGF0aW9uIHN5c3RlbXMuIiwiYmFzaWNUYXNrIjoiUHJvZHVjZSBjb250ZW50LWJhc2VkIG1vdmllIHJlY29tbWVuZGF0aW9ucyIsInNjZW5hcmlvIjoiSGFuZGxlIGNvbGQtc3RhcnQgdXNlciB3aXRoIG5vIGhpc3RvcnkiLCJwcm9qZWN0V29ya3N0cmVhbSI6IlAwNSDCtyBNb3ZpZSBSZWNvbW1lbmRhdGlvbiBFbmdpbmUiLCJwcm9qZWN0SWQiOiJQMDUiLCJwcm9qZWN0VGFzayI6IlNUQVJUIFAwNSBNb3ZpZSBSZWNvbW1lbmRhdGlvbiBFbmdpbmU6IENvbnRlbnQtYmFzZWQgZmlsdGVyaW5nLjsgQ29sbGFib3JhdGl2ZSBmaWx0ZXJpbmcuOyBDb3NpbmUgc2ltaWxhcml0eS4uIFNoaXAgc21hbGxlc3QgdmVyaWZpYWJsZSBzbGljZTsgZG9jdW1lbnQgdGVzdHMuIiwicHJvamVjdERlbGl2ZXJhYmxlIjoiUDA1IGxhdW5jaDogUnVubmFibGUgZGVtbzsgYXV0b21hdGVkIHRlc3RzOyBSRUFETUU7IGNvbnRlbnQtYmFzZWQgZmlsdGVyaW5nLiIsImludGVydmlldyI6IkNvbGxhYm9yYXRpdmUgdnMgY29udGVudC1iYXNlZCBmaWx0ZXJpbmc/IiwiZXhpdENyaXRlcmlhIjoiRXhwbGFpbiByZWNvbW1lbmRhdGlvbiBzeXN0ZW1zIGluIDIgbWludXRlczsgMSB0ZXN0ZWQgY29tbWl0OyBvbmUgc2NlbmFyaW8gYW5zd2VyOyAzLzUgaW50ZXJ2aWV3IHByYWN0aWNlIHF1ZXN0aW9ucy4iLCJwbGFubmVkSG91cnMiOjYsInJlZmVyZW5jZVVybCI6Imh0dHBzOi8vc2Npa2l0LWxlYXJuLm9yZy9zdGFibGUvdXNlcl9ndWlkZS5odG1sIiwic2NlbmFyaW9Gb3JtYXQiOiJJbnB1dHMg4oaSIGNvbnN0cmFpbnRzIOKGkiBlZGdlIGNhc2VzIOKGkiBhbGdvcml0aG0g4oaSIGNvbXBsZXhpdHkg4oaSIHRlc3RzOyBjb2RlIGFuZCByZWZsZWN0IiwiaW50ZXJ2aWV3U3RydWN0dXJlIjoiVXNlIGRlZmluaXRpb24g4oaSIGV4YW1wbGUg4oaSIHRyYWRlLW9mZiDihpIgY29tbW9uIGZhaWx1cmUg4oaSIHByb2R1Y3Rpb24gaW1wbGljYXRpb24ifSx7InBsYW5JZCI6ImNocm9uaXMtYWktZW5naW5lZXJpbmctMjAyNi0xMS0wNSIsImRheU51bWJlciI6MTgsImRhdGUiOiIyMDI2LTExLTIyIiwid2VlayI6MywicGhhc2UiOiIwMiDCtyBDbGFzc2ljYWwgTUwiLCJwaGFzZU5vIjoiMDIiLCJwaGFzZURheSI6OCwic3VicGhhc2UiOiJVbmJhbGFuY2VkIGxlYXJuaW5nIiwiY29uY2VwdHMiOiJDbGFzcyB3ZWlnaHRzLCByZXNhbXBsaW5nLCBjYWxpYnJhdGlvbiwgbGVha2FnZSBjaGVja3MiLCJ0aGVvcnlEZWxpdmVyYWJsZSI6IlJlYWQgKyBkaWFncmFtICsgMyBmbGFzaGNhcmRzOyBpZGVudGlmeSAyIGZhaWx1cmUgbW9kZXMgaW4gdW5iYWxhbmNlZCBsZWFybmluZy4iLCJiYXNpY1Rhc2siOiJUcmFpbiBjb3N0LXNlbnNpdGl2ZSBjbGFzc2lmaWVyIHVzaW5nIHBpcGVsaW5lIiwic2NlbmFyaW8iOiJGcmF1ZCBtb2RlbCBjYXRjaGVzIGZldyByYXJlIHBvc2l0aXZlcyBidXQgaGlnaCBhY2N1cmFjeSIsInByb2plY3RXb3Jrc3RyZWFtIjoiUDA1IMK3IE1vdmllIFJlY29tbWVuZGF0aW9uIEVuZ2luZSIsInByb2plY3RJZCI6IlAwNSIsInByb2plY3RUYXNrIjoiSVRFUkFURSBQMDUgTW92aWUgUmVjb21tZW5kYXRpb24gRW5naW5lOiBhZGQgZWRnZS1jYXNlIGhhbmRsaW5nLCB0ZXN0IGZpeHR1cmUsIHJlc3VsdCBsb2cgb3IgQVBJIGNvbnRyYWN0IGFsaWduZWQgdG8gdG9kYXnigJlzIHRvcGljLiIsInByb2plY3REZWxpdmVyYWJsZSI6Ik9uZSB0ZXN0ZWQgaW5jcmVtZW50YWwgY29tbWl0IGZvciBQMDU7IG5vdGUgb3BlbiBmb2xsb3ctdXBzIGluIGJhY2tsb2cuIiwiaW50ZXJ2aWV3IjoiSG93IGNob29zZSB0aHJlc2hvbGRzIHdpdGggYnVzaW5lc3MgY29zdD8iLCJleGl0Q3JpdGVyaWEiOiJFeHBsYWluIHVuYmFsYW5jZWQgbGVhcm5pbmcgaW4gMiBtaW51dGVzOyAxIHRlc3RlZCBjb21taXQ7IG9uZSBzY2VuYXJpbyBhbnN3ZXI7IDMvNSBpbnRlcnZpZXcgcHJhY3RpY2UgcXVlc3Rpb25zLiIsInBsYW5uZWRIb3VycyI6NiwicmVmZXJlbmNlVXJsIjoiaHR0cHM6Ly9zY2lraXQtbGVhcm4ub3JnL3N0YWJsZS91c2VyX2d1aWRlLmh0bWwiLCJzY2VuYXJpb0Zvcm1hdCI6IklucHV0cyDihpIgY29uc3RyYWludHMg4oaSIGVkZ2UgY2FzZXMg4oaSIGFsZ29yaXRobSDihpIgY29tcGxleGl0eSDihpIgdGVzdHM7IGNvZGUgYW5kIHJlZmxlY3QiLCJpbnRlcnZpZXdTdHJ1Y3R1cmUiOiJVc2UgZGVmaW5pdGlvbiDihpIgZXhhbXBsZSDihpIgdHJhZGUtb2ZmIOKGkiBjb21tb24gZmFpbHVyZSDihpIgcHJvZHVjdGlvbiBpbXBsaWNhdGlvbiJ9LHsicGxhbklkIjoiY2hyb25pcy1haS1lbmdpbmVlcmluZy0yMDI2LTExLTA1IiwiZGF5TnVtYmVyIjoxOSwiZGF0ZSI6IjIwMjYtMTEtMjMiLCJ3ZWVrIjozLCJwaGFzZSI6IjAyIMK3IENsYXNzaWNhbCBNTCIsInBoYXNlTm8iOiIwMiIsInBoYXNlRGF5Ijo5LCJzdWJwaGFzZSI6IlVuc3VwZXJ2aXNlZCBtZXRob2RzIiwiY29uY2VwdHMiOiJLLW1lYW5zLCBzaWxob3VldHRlIHNjb3JlLCBmZWF0dXJlIHNjYWxpbmcsIFBDQSIsInRoZW9yeURlbGl2ZXJhYmxlIjoiUmVhZCArIGRpYWdyYW0gKyAzIGZsYXNoY2FyZHM7IGlkZW50aWZ5IDIgZmFpbHVyZSBtb2RlcyBpbiB1bnN1cGVydmlzZWQgbWV0aG9kcy4iLCJiYXNpY1Rhc2siOiJDbHVzdGVyIGN1c3RvbWVyIHNlZ21lbnRzIGFuZCBzY29yZSBjb2hlc2lvbiIsInNjZW5hcmlvIjoiQ2F0ZWdvcmljYWwtaGVhdnkgcmVjb3JkcyBicmVhayBFdWNsaWRlYW4gZGlzdGFuY2UgYXNzdW1wdGlvbnMiLCJwcm9qZWN0V29ya3N0cmVhbSI6IlAzMiDCtyBDdXN0b21lciBTZWdtZW50YXRpb24gSW50ZWxsaWdlbmNlIEFQSSIsInByb2plY3RJZCI6IlAzMiIsInByb2plY3RUYXNrIjoiU1RBUlQgUDMyIEN1c3RvbWVyIFNlZ21lbnRhdGlvbiBJbnRlbGxpZ2VuY2UgQVBJOiBDbHVzdGVyIGN1c3RvbWVycywgcHJvZmlsZSBzZWdtZW50cywgZXhwb3NlIEFQSS4gU2hpcCBzbWFsbGVzdCB2ZXJpZmlhYmxlIHNsaWNlOyBkb2N1bWVudCB0ZXN0cy4iLCJwcm9qZWN0RGVsaXZlcmFibGUiOiJQMzIgbGF1bmNoOiBSZXByb2R1Y2libGUgY2x1c3RlcmluZzsgbGFiZWxzIGFuZCBzZWdtZW50IG1ldHJpY3MiLCJpbnRlcnZpZXciOiJXaGVuIGlzIEstbWVhbnMgaW5hcHByb3ByaWF0ZT8iLCJleGl0Q3JpdGVyaWEiOiJFeHBsYWluIHVuc3VwZXJ2aXNlZCBtZXRob2RzIGluIDIgbWludXRlczsgMSB0ZXN0ZWQgY29tbWl0OyBvbmUgc2NlbmFyaW8gYW5zd2VyOyAzLzUgaW50ZXJ2aWV3IHByYWN0aWNlIHF1ZXN0aW9ucy4iLCJwbGFubmVkSG91cnMiOjYsInJlZmVyZW5jZVVybCI6Imh0dHBzOi8vc2Npa2l0LWxlYXJuLm9yZy9zdGFibGUvdXNlcl9ndWlkZS5odG1sIiwic2NlbmFyaW9Gb3JtYXQiOiJJbnB1dHMg4oaSIGNvbnN0cmFpbnRzIOKGkiBlZGdlIGNhc2VzIOKGkiBhbGdvcml0aG0g4oaSIGNvbXBsZXhpdHkg4oaSIHRlc3RzOyBjb2RlIGFuZCByZWZsZWN0IiwiaW50ZXJ2aWV3U3RydWN0dXJlIjoiVXNlIGRlZmluaXRpb24g4oaSIGV4YW1wbGUg4oaSIHRyYWRlLW9mZiDihpIgY29tbW9uIGZhaWx1cmUg4oaSIHByb2R1Y3Rpb24gaW1wbGljYXRpb24ifSx7InBsYW5JZCI6ImNocm9uaXMtYWktZW5naW5lZXJpbmctMjAyNi0xMS0wNSIsImRheU51bWJlciI6MjAsImRhdGUiOiIyMDI2LTExLTI0Iiwid2VlayI6MywicGhhc2UiOiIwMiDCtyBDbGFzc2ljYWwgTUwiLCJwaGFzZU5vIjoiMDIiLCJwaGFzZURheSI6MTAsInN1YnBoYXNlIjoiQW5vbWFseSBkZXRlY3Rpb24iLCJjb25jZXB0cyI6Iklzb2xhdGlvbiBmb3Jlc3QsIG91dGxpZXIgc2NvcmVzLCB1bnN1cGVydmlzZWQgZXZhbHVhdGlvbiIsInRoZW9yeURlbGl2ZXJhYmxlIjoiUmVhZCArIGRpYWdyYW0gKyAzIGZsYXNoY2FyZHM7IGlkZW50aWZ5IDIgZmFpbHVyZSBtb2RlcyBpbiBhbm9tYWx5IGRldGVjdGlvbi4iLCJiYXNpY1Rhc2siOiJXcml0ZSBhbm9tYWx5IGZsYWdnZXIgd2l0aCB0aHJlc2hvbGQgY2FsaWJyYXRpb24iLCJzY2VuYXJpbyI6Ik1vbml0b3IgZmFsc2UgYWxhcm1zIHVuZGVyIGNoYW5naW5nIHRyYWZmaWMiLCJwcm9qZWN0V29ya3N0cmVhbSI6IlAzMiDCtyBDdXN0b21lciBTZWdtZW50YXRpb24gSW50ZWxsaWdlbmNlIEFQSSIsInByb2plY3RJZCI6IlAzMiIsInByb2plY3RUYXNrIjoiSVRFUkFURSBQMzIgQ3VzdG9tZXIgU2VnbWVudGF0aW9uIEludGVsbGlnZW5jZSBBUEk6IGFkZCBlZGdlLWNhc2UgaGFuZGxpbmcsIHRlc3QgZml4dHVyZSwgcmVzdWx0IGxvZyBvciBBUEkgY29udHJhY3QgYWxpZ25lZCB0byB0b2RheeKAmXMgdG9waWMuIiwicHJvamVjdERlbGl2ZXJhYmxlIjoiT25lIHRlc3RlZCBpbmNyZW1lbnRhbCBjb21taXQgZm9yIFAzMjsgbm90ZSBvcGVuIGZvbGxvdy11cHMgaW4gYmFja2xvZy4iLCJpbnRlcnZpZXciOiJIb3cgZXZhbHVhdGUgYW5vbWFsaWVzIHdpdGhvdXQgbGFiZWxzPyIsImV4aXRDcml0ZXJpYSI6IkV4cGxhaW4gYW5vbWFseSBkZXRlY3Rpb24gaW4gMiBtaW51dGVzOyAxIHRlc3RlZCBjb21taXQ7IG9uZSBzY2VuYXJpbyBhbnN3ZXI7IDMvNSBpbnRlcnZpZXcgcHJhY3RpY2UgcXVlc3Rpb25zLiIsInBsYW5uZWRIb3VycyI6NiwicmVmZXJlbmNlVXJsIjoiaHR0cHM6Ly9zY2lraXQtbGVhcm4ub3JnL3N0YWJsZS91c2VyX2d1aWRlLmh0bWwiLCJzY2VuYXJpb0Zvcm1hdCI6IklucHV0cyDihpIgY29uc3RyYWludHMg4oaSIGVkZ2UgY2FzZXMg4oaSIGFsZ29yaXRobSDihpIgY29tcGxleGl0eSDihpIgdGVzdHM7IGNvZGUgYW5kIHJlZmxlY3QiLCJpbnRlcnZpZXdTdHJ1Y3R1cmUiOiJVc2UgZGVmaW5pdGlvbiDihpIgZXhhbXBsZSDihpIgdHJhZGUtb2ZmIOKGkiBjb21tb24gZmFpbHVyZSDihpIgcHJvZHVjdGlvbiBpbXBsaWNhdGlvbiJ9LHsicGxhbklkIjoiY2hyb25pcy1haS1lbmdpbmVlcmluZy0yMDI2LTExLTA1IiwiZGF5TnVtYmVyIjoyMSwiZGF0ZSI6IjIwMjYtMTEtMjUiLCJ3ZWVrIjozLCJwaGFzZSI6IjAyIMK3IENsYXNzaWNhbCBNTCIsInBoYXNlTm8iOiIwMiIsInBoYXNlRGF5IjoxMSwic3VicGhhc2UiOiJFeHBlcmltZW50IHRyYWNraW5nIiwiY29uY2VwdHMiOiJNTGZsb3cgYmFzaWNzLCBzZWVkcywgZGF0YXNldHMsIHByb3ZlbmFuY2UgYW5kIHJlcHJvZHVjaWJpbGl0eSIsInRoZW9yeURlbGl2ZXJhYmxlIjoiUmVhZCArIGRpYWdyYW0gKyAzIGZsYXNoY2FyZHM7IGlkZW50aWZ5IDIgZmFpbHVyZSBtb2RlcyBpbiBleHBlcmltZW50IHRyYWNraW5nLiIsImJhc2ljVGFzayI6IlN0b3JlIGV4cGVyaW1lbnQgcGFyYW1zLCBtZXRyaWNzIGFuZCBhcnRpZmFjdHMiLCJzY2VuYXJpbyI6IlR3byBleHBlcmltZW50IHJ1bnMgZGlmZmVyIGRlc3BpdGUgc2FtZSBtb2RlbCIsInByb2plY3RXb3Jrc3RyZWFtIjoiUDMzIMK3IE1MIEV4cGVyaW1lbnQgVHJhY2tlciBEYXNoYm9hcmQiLCJwcm9qZWN0SWQiOiJQMzMiLCJwcm9qZWN0VGFzayI6IlNUQVJUIFAzMyBNTCBFeHBlcmltZW50IFRyYWNrZXIgRGFzaGJvYXJkOiBUcmFjayBkYXRhc2V0cywgcGFyYW1ldGVycywgcnVucywgbWV0cmljcyBhbmQgYXJ0aWZhY3RzLiBTaGlwIHNtYWxsZXN0IHZlcmlmaWFibGUgc2xpY2U7IGRvY3VtZW50IHRlc3RzLiIsInByb2plY3REZWxpdmVyYWJsZSI6IlAzMyBsYXVuY2g6IENvbXBhcmUgMyBydW5zIHdpdGggcmVwcm9kdWNpYmxlIGNvbmZpZ3VyYXRpb24iLCJpbnRlcnZpZXciOiJXaGF0IGVuc3VyZXMgcmVwcm9kdWNpYmxlIG1vZGVsIHRyYWluaW5nPyIsImV4aXRDcml0ZXJpYSI6IkV4cGxhaW4gZXhwZXJpbWVudCB0cmFja2luZyBpbiAyIG1pbnV0ZXM7IDEgdGVzdGVkIGNvbW1pdDsgb25lIHNjZW5hcmlvIGFuc3dlcjsgMy81IGludGVydmlldyBwcmFjdGljZSBxdWVzdGlvbnMuIiwicGxhbm5lZEhvdXJzIjo2LCJyZWZlcmVuY2VVcmwiOiJodHRwczovL3NjaWtpdC1sZWFybi5vcmcvc3RhYmxlL3VzZXJfZ3VpZGUuaHRtbCIsInNjZW5hcmlvRm9ybWF0IjoiSW5wdXRzIOKGkiBjb25zdHJhaW50cyDihpIgZWRnZSBjYXNlcyDihpIgYWxnb3JpdGhtIOKGkiBjb21wbGV4aXR5IOKGkiB0ZXN0czsgY29kZSBhbmQgcmVmbGVjdCIsImludGVydmlld1N0cnVjdHVyZSI6IlVzZSBkZWZpbml0aW9uIOKGkiBleGFtcGxlIOKGkiB0cmFkZS1vZmYg4oaSIGNvbW1vbiBmYWlsdXJlIOKGkiBwcm9kdWN0aW9uIGltcGxpY2F0aW9uIn0seyJwbGFuSWQiOiJjaHJvbmlzLWFpLWVuZ2luZWVyaW5nLTIwMjYtMTEtMDUiLCJkYXlOdW1iZXIiOjIyLCJkYXRlIjoiMjAyNi0xMS0yNiIsIndlZWsiOjQsInBoYXNlIjoiMDIgwrcgQ2xhc3NpY2FsIE1MIiwicGhhc2VObyI6IjAyIiwicGhhc2VEYXkiOjEyLCJzdWJwaGFzZSI6IlNlcnZpbmcgY2hlY2twb2ludCIsImNvbmNlcHRzIjoiTW9kZWwgcGFja2FnaW5nLCBGYXN0QVBJIGluZmVyZW5jZSwgUHlkYW50aWMsIHVuaXQgdGVzdHMiLCJ0aGVvcnlEZWxpdmVyYWJsZSI6IlJlYWQgKyBkaWFncmFtICsgMyBmbGFzaGNhcmRzOyBpZGVudGlmeSAyIGZhaWx1cmUgbW9kZXMgaW4gc2VydmluZyBjaGVja3BvaW50LiIsImJhc2ljVGFzayI6IkV4cG9zZSAvcHJlZGljdCBhbmQgdGVzdCBpbnZhbGlkIHBheWxvYWRzIiwic2NlbmFyaW8iOiJEZXRlY3QgdHJhaW4tc2VydmluZyBza2V3IGluIGEgbW9kZWwgQVBJIiwicHJvamVjdFdvcmtzdHJlYW0iOiJQMzMgwrcgTUwgRXhwZXJpbWVudCBUcmFja2VyIERhc2hib2FyZCIsInByb2plY3RJZCI6IlAzMyIsInByb2plY3RUYXNrIjoiSVRFUkFURSBQMzMgTUwgRXhwZXJpbWVudCBUcmFja2VyIERhc2hib2FyZDogYWRkIGVkZ2UtY2FzZSBoYW5kbGluZywgdGVzdCBmaXh0dXJlLCByZXN1bHQgbG9nIG9yIEFQSSBjb250cmFjdCBhbGlnbmVkIHRvIHRvZGF54oCZcyB0b3BpYy4iLCJwcm9qZWN0RGVsaXZlcmFibGUiOiJPbmUgdGVzdGVkIGluY3JlbWVudGFsIGNvbW1pdCBmb3IgUDMzOyBub3RlIG9wZW4gZm9sbG93LXVwcyBpbiBiYWNrbG9nLiIsImludGVydmlldyI6IldoYXQgYmVsb25ncyBpbiBhIHByb2R1Y3Rpb24gaW5mZXJlbmNlIGNvbnRyYWN0PyIsImV4aXRDcml0ZXJpYSI6IkV4cGxhaW4gc2VydmluZyBjaGVja3BvaW50IGluIDIgbWludXRlczsgMSB0ZXN0ZWQgY29tbWl0OyBvbmUgc2NlbmFyaW8gYW5zd2VyOyAzLzUgaW50ZXJ2aWV3IHByYWN0aWNlIHF1ZXN0aW9ucy4iLCJwbGFubmVkSG91cnMiOjYsInJlZmVyZW5jZVVybCI6Imh0dHBzOi8vc2Npa2l0LWxlYXJuLm9yZy9zdGFibGUvdXNlcl9ndWlkZS5odG1sIiwic2NlbmFyaW9Gb3JtYXQiOiJJbnB1dHMg4oaSIGNvbnN0cmFpbnRzIOKGkiBlZGdlIGNhc2VzIOKGkiBhbGdvcml0aG0g4oaSIGNvbXBsZXhpdHkg4oaSIHRlc3RzOyBjb2RlIGFuZCByZWZsZWN0IiwiaW50ZXJ2aWV3U3RydWN0dXJlIjoiVXNlIGRlZmluaXRpb24g4oaSIGV4YW1wbGUg4oaSIHRyYWRlLW9mZiDihpIgY29tbW9uIGZhaWx1cmUg4oaSIHByb2R1Y3Rpb24gaW1wbGljYXRpb24ifSx7InBsYW5JZCI6ImNocm9uaXMtYWktZW5naW5lZXJpbmctMjAyNi0xMS0wNSIsImRheU51bWJlciI6MjMsImRhdGUiOiIyMDI2LTExLTI3Iiwid2VlayI6NCwicGhhc2UiOiIwMyDCtyBEZWVwIExlYXJuaW5nICYgTkxQIiwicGhhc2VObyI6IjAzIiwicGhhc2VEYXkiOjEsInN1YnBoYXNlIjoiUHlUb3JjaCBlbnRyeSIsImNvbmNlcHRzIjoiVGVuc29ycywgc2hhcGVzLCBkZXZpY2VzLCBhdXRvZ3JhZCIsInRoZW9yeURlbGl2ZXJhYmxlIjoiUmVhZCArIGRpYWdyYW0gKyAzIGZsYXNoY2FyZHM7IGlkZW50aWZ5IDIgZmFpbHVyZSBtb2RlcyBpbiBweXRvcmNoIGVudHJ5LiIsImJhc2ljVGFzayI6IkJ1aWxkIHRlbnNvciBvcHMgYW5kIGdyYWRpZW50IHVuaXQgdGVzdHMiLCJzY2VuYXJpbyI6IkZpeCB0ZW5zb3IgZGltZW5zaW9uIG1pc21hdGNoIGluIGJhdGNoIGluZmVyZW5jZSIsInByb2plY3RXb3Jrc3RyZWFtIjoiUDA2IMK3IEhhbmR3cml0dGVuIERpZ2l0IFJlY29nbml0aW9uIiwicHJvamVjdElkIjoiUDA2IiwicHJvamVjdFRhc2siOiJTVEFSVCBQMDYgSGFuZHdyaXR0ZW4gRGlnaXQgUmVjb2duaXRpb246IEltcGxlbWVudCBuZXVyYWwgbmV0d29ya3MuOyBGb3J3YXJkIGFuZCBiYWNrd2FyZCBwcm9wYWdhdGlvbi47IFRyYWluIG9uIE1OSVNULi4gU2hpcCBzbWFsbGVzdCB2ZXJpZmlhYmxlIHNsaWNlOyBkb2N1bWVudCB0ZXN0cy4iLCJwcm9qZWN0RGVsaXZlcmFibGUiOiJQMDYgbGF1bmNoOiBSdW5uYWJsZSBkZW1vOyBhdXRvbWF0ZWQgdGVzdHM7IFJFQURNRTsgaW1wbGVtZW50IG5ldXJhbCBuZXR3b3Jrcy4iLCJpbnRlcnZpZXciOiJXaGF0IGV4YWN0bHkgZG9lcyBhdXRvZ3JhZCB0cmFjaz8iLCJleGl0Q3JpdGVyaWEiOiJFeHBsYWluIHB5dG9yY2ggZW50cnkgaW4gMiBtaW51dGVzOyAxIHRlc3RlZCBjb21taXQ7IG9uZSBzY2VuYXJpbyBhbnN3ZXI7IDMvNSBpbnRlcnZpZXcgcHJhY3RpY2UgcXVlc3Rpb25zLiIsInBsYW5uZWRIb3VycyI6NiwicmVmZXJlbmNlVXJsIjoiaHR0cHM6Ly9kb2NzLnB5dG9yY2gub3JnL3R1dG9yaWFscy8iLCJzY2VuYXJpb0Zvcm1hdCI6IklucHV0cyDihpIgY29uc3RyYWludHMg4oaSIGVkZ2UgY2FzZXMg4oaSIGFsZ29yaXRobSDihpIgY29tcGxleGl0eSDihpIgdGVzdHM7IGNvZGUgYW5kIHJlZmxlY3QiLCJpbnRlcnZpZXdTdHJ1Y3R1cmUiOiJVc2UgZGVmaW5pdGlvbiDihpIgZXhhbXBsZSDihpIgdHJhZGUtb2ZmIOKGkiBjb21tb24gZmFpbHVyZSDihpIgcHJvZHVjdGlvbiBpbXBsaWNhdGlvbiJ9LHsicGxhbklkIjoiY2hyb25pcy1haS1lbmdpbmVlcmluZy0yMDI2LTExLTA1IiwiZGF5TnVtYmVyIjoyNCwiZGF0ZSI6IjIwMjYtMTEtMjgiLCJ3ZWVrIjo0LCJwaGFzZSI6IjAzIMK3IERlZXAgTGVhcm5pbmcgJiBOTFAiLCJwaGFzZU5vIjoiMDMiLCJwaGFzZURheSI6Miwic3VicGhhc2UiOiJOZXVyYWwgbmV0d29yayBmdW5kYW1lbnRhbHMiLCJjb25jZXB0cyI6Ik1MUHMsIGFjdGl2YXRpb24sIGJhY2twcm9wLCBvcHRpbWl6ZXJzLCBtaW5pLWJhdGNoZXMiLCJ0aGVvcnlEZWxpdmVyYWJsZSI6IlJlYWQgKyBkaWFncmFtICsgMyBmbGFzaGNhcmRzOyBpZGVudGlmeSAyIGZhaWx1cmUgbW9kZXMgaW4gbmV1cmFsIG5ldHdvcmsgZnVuZGFtZW50YWxzLiIsImJhc2ljVGFzayI6IkltcGxlbWVudCAyLWxheWVyIG5ldHdvcmsgd2l0aCB0cmFpbmluZyBsb29wIiwic2NlbmFyaW8iOiJEaWFnbm9zZSBOYU4gbG9zcyBhZnRlciBzZXZlcmFsIGJhdGNoZXMiLCJwcm9qZWN0V29ya3N0cmVhbSI6IlAwNiDCtyBIYW5kd3JpdHRlbiBEaWdpdCBSZWNvZ25pdGlvbiIsInByb2plY3RJZCI6IlAwNiIsInByb2plY3RUYXNrIjoiSVRFUkFURSBQMDYgSGFuZHdyaXR0ZW4gRGlnaXQgUmVjb2duaXRpb246IGFkZCBlZGdlLWNhc2UgaGFuZGxpbmcsIHRlc3QgZml4dHVyZSwgcmVzdWx0IGxvZyBvciBBUEkgY29udHJhY3QgYWxpZ25lZCB0byB0b2RheeKAmXMgdG9waWMuIiwicHJvamVjdERlbGl2ZXJhYmxlIjoiT25lIHRlc3RlZCBpbmNyZW1lbnRhbCBjb21taXQgZm9yIFAwNjsgbm90ZSBvcGVuIGZvbGxvdy11cHMgaW4gYmFja2xvZy4iLCJpbnRlcnZpZXciOiJIb3cgZG9lcyBiYWNrcHJvcCB1c2UgY2hhaW4gcnVsZT8iLCJleGl0Q3JpdGVyaWEiOiJFeHBsYWluIG5ldXJhbCBuZXR3b3JrIGZ1bmRhbWVudGFscyBpbiAyIG1pbnV0ZXM7IDEgdGVzdGVkIGNvbW1pdDsgb25lIHNjZW5hcmlvIGFuc3dlcjsgMy81IGludGVydmlldyBwcmFjdGljZSBxdWVzdGlvbnMuIiwicGxhbm5lZEhvdXJzIjo2LCJyZWZlcmVuY2VVcmwiOiJodHRwczovL2RvY3MucHl0b3JjaC5vcmcvdHV0b3JpYWxzLyIsInNjZW5hcmlvRm9ybWF0IjoiSW5wdXRzIOKGkiBjb25zdHJhaW50cyDihpIgZWRnZSBjYXNlcyDihpIgYWxnb3JpdGhtIOKGkiBjb21wbGV4aXR5IOKGkiB0ZXN0czsgY29kZSBhbmQgcmVmbGVjdCIsImludGVydmlld1N0cnVjdHVyZSI6IlVzZSBkZWZpbml0aW9uIOKGkiBleGFtcGxlIOKGkiB0cmFkZS1vZmYg4oaSIGNvbW1vbiBmYWlsdXJlIOKGkiBwcm9kdWN0aW9uIGltcGxpY2F0aW9uIn0seyJwbGFuSWQiOiJjaHJvbmlzLWFpLWVuZ2luZWVyaW5nLTIwMjYtMTEtMDUiLCJkYXlOdW1iZXIiOjI1LCJkYXRlIjoiMjAyNi0xMS0yOSIsIndlZWsiOjQsInBoYXNlIjoiMDMgwrcgRGVlcCBMZWFybmluZyAmIE5MUCIsInBoYXNlTm8iOiIwMyIsInBoYXNlRGF5IjozLCJzdWJwaGFzZSI6IlZpc2lvbiBDTk5zIiwiY29uY2VwdHMiOiJDb252b2x1dGlvbnMsIHBhZGRpbmcsIHN0cmlkZSwgcG9vbGluZyBhbmQgTU5JU1QiLCJ0aGVvcnlEZWxpdmVyYWJsZSI6IlJlYWQgKyBkaWFncmFtICsgMyBmbGFzaGNhcmRzOyBpZGVudGlmeSAyIGZhaWx1cmUgbW9kZXMgaW4gdmlzaW9uIGNubnMuIiwiYmFzaWNUYXNrIjoiVHJhaW4gY29tcGFjdCBkaWdpdCByZWNvZ25pemVyIGFuZCByZWNvcmQgYWNjdXJhY3kiLCJzY2VuYXJpbyI6IkluZmVyIHdyb25nIG91dHB1dCBzaGFwZSBhZnRlciBwb29saW5nIiwicHJvamVjdFdvcmtzdHJlYW0iOiJQMDcgwrcgSW1hZ2UgQ2xhc3NpZmljYXRpb24gU3lzdGVtIiwicHJvamVjdElkIjoiUDA3IiwicHJvamVjdFRhc2siOiJTVEFSVCBQMDcgSW1hZ2UgQ2xhc3NpZmljYXRpb24gU3lzdGVtOiBJbWFnZSBwcmVwcm9jZXNzaW5nLjsgQ29udm9sdXRpb24gYW5kIHBvb2xpbmcuOyBDTk4gdHJhaW5pbmcuLiBTaGlwIHNtYWxsZXN0IHZlcmlmaWFibGUgc2xpY2U7IGRvY3VtZW50IHRlc3RzLiIsInByb2plY3REZWxpdmVyYWJsZSI6IlAwNyBsYXVuY2g6IFJ1bm5hYmxlIGRlbW87IGF1dG9tYXRlZCB0ZXN0czsgUkVBRE1FOyBpbWFnZSBwcmVwcm9jZXNzaW5nLiIsImludGVydmlldyI6IldoeSBkbyBDTk5zIHNoYXJlIGZpbHRlciB3ZWlnaHRzPyIsImV4aXRDcml0ZXJpYSI6IkV4cGxhaW4gdmlzaW9uIGNubnMgaW4gMiBtaW51dGVzOyAxIHRlc3RlZCBjb21taXQ7IG9uZSBzY2VuYXJpbyBhbnN3ZXI7IDMvNSBpbnRlcnZpZXcgcHJhY3RpY2UgcXVlc3Rpb25zLiIsInBsYW5uZWRIb3VycyI6NiwicmVmZXJlbmNlVXJsIjoiaHR0cHM6Ly9kb2NzLnB5dG9yY2gub3JnL3R1dG9yaWFscy8iLCJzY2VuYXJpb0Zvcm1hdCI6IklucHV0cyDihpIgY29uc3RyYWludHMg4oaSIGVkZ2UgY2FzZXMg4oaSIGFsZ29yaXRobSDihpIgY29tcGxleGl0eSDihpIgdGVzdHM7IGNvZGUgYW5kIHJlZmxlY3QiLCJpbnRlcnZpZXdTdHJ1Y3R1cmUiOiJVc2UgZGVmaW5pdGlvbiDihpIgZXhhbXBsZSDihpIgdHJhZGUtb2ZmIOKGkiBjb21tb24gZmFpbHVyZSDihpIgcHJvZHVjdGlvbiBpbXBsaWNhdGlvbiJ9LHsicGxhbklkIjoiY2hyb25pcy1haS1lbmdpbmVlcmluZy0yMDI2LTExLTA1IiwiZGF5TnVtYmVyIjoyNiwiZGF0ZSI6IjIwMjYtMTEtMzAiLCJ3ZWVrIjo0LCJwaGFzZSI6IjAzIMK3IERlZXAgTGVhcm5pbmcgJiBOTFAiLCJwaGFzZU5vIjoiMDMiLCJwaGFzZURheSI6NCwic3VicGhhc2UiOiJUcmFuc2ZlciBsZWFybmluZyIsImNvbmNlcHRzIjoiUHJldHJhaW5lZCB2aXNpb24gZW5jb2RlcnMsIGRhdGEgYXVnbWVudGF0aW9uLCBmcmVlemluZyIsInRoZW9yeURlbGl2ZXJhYmxlIjoiUmVhZCArIGRpYWdyYW0gKyAzIGZsYXNoY2FyZHM7IGlkZW50aWZ5IDIgZmFpbHVyZSBtb2RlcyBpbiB0cmFuc2ZlciBsZWFybmluZy4iLCJiYXNpY1Rhc2siOiJGaW5lLXR1bmUgc21hbGwgY2xhc3NpZmllciB1c2luZyBwcmV0cmFpbmVkIGJhY2tib25lIiwic2NlbmFyaW8iOiJMaW1pdGVkIHNhbXBsZXMgYW5kIHNldmVyZSBjbGFzcyBpbWJhbGFuY2UiLCJwcm9qZWN0V29ya3N0cmVhbSI6IlAwNyDCtyBJbWFnZSBDbGFzc2lmaWNhdGlvbiBTeXN0ZW0iLCJwcm9qZWN0SWQiOiJQMDciLCJwcm9qZWN0VGFzayI6IklURVJBVEUgUDA3IEltYWdlIENsYXNzaWZpY2F0aW9uIFN5c3RlbTogYWRkIGVkZ2UtY2FzZSBoYW5kbGluZywgdGVzdCBmaXh0dXJlLCByZXN1bHQgbG9nIG9yIEFQSSBjb250cmFjdCBhbGlnbmVkIHRvIHRvZGF54oCZcyB0b3BpYy4iLCJwcm9qZWN0RGVsaXZlcmFibGUiOiJPbmUgdGVzdGVkIGluY3JlbWVudGFsIGNvbW1pdCBmb3IgUDA3OyBub3RlIG9wZW4gZm9sbG93LXVwcyBpbiBiYWNrbG9nLiIsImludGVydmlldyI6IldoZW4gZnJlZXplIGJhY2tib25lIHZzIHVuZnJlZXplPyIsImV4aXRDcml0ZXJpYSI6IkV4cGxhaW4gdHJhbnNmZXIgbGVhcm5pbmcgaW4gMiBtaW51dGVzOyAxIHRlc3RlZCBjb21taXQ7IG9uZSBzY2VuYXJpbyBhbnN3ZXI7IDMvNSBpbnRlcnZpZXcgcHJhY3RpY2UgcXVlc3Rpb25zLiIsInBsYW5uZWRIb3VycyI6NiwicmVmZXJlbmNlVXJsIjoiaHR0cHM6Ly9kb2NzLnB5dG9yY2gub3JnL3R1dG9yaWFscy8iLCJzY2VuYXJpb0Zvcm1hdCI6IklucHV0cyDihpIgY29uc3RyYWludHMg4oaSIGVkZ2UgY2FzZXMg4oaSIGFsZ29yaXRobSDihpIgY29tcGxleGl0eSDihpIgdGVzdHM7IGNvZGUgYW5kIHJlZmxlY3QiLCJpbnRlcnZpZXdTdHJ1Y3R1cmUiOiJVc2UgZGVmaW5pdGlvbiDihpIgZXhhbXBsZSDihpIgdHJhZGUtb2ZmIOKGkiBjb21tb24gZmFpbHVyZSDihpIgcHJvZHVjdGlvbiBpbXBsaWNhdGlvbiJ9LHsicGxhbklkIjoiY2hyb25pcy1haS1lbmdpbmVlcmluZy0yMDI2LTExLTA1IiwiZGF5TnVtYmVyIjoyNywiZGF0ZSI6IjIwMjYtMTItMDEiLCJ3ZWVrIjo0LCJwaGFzZSI6IjAzIMK3IERlZXAgTGVhcm5pbmcgJiBOTFAiLCJwaGFzZU5vIjoiMDMiLCJwaGFzZURheSI6NSwic3VicGhhc2UiOiJOTFAgcHJlcHJvY2Vzc2luZyIsImNvbmNlcHRzIjoiVG9rZW5pemF0aW9uLCB2b2NhYnVsYXJ5LCB3b3JkIGVtYmVkZGluZ3MsIFRGLUlERiIsInRoZW9yeURlbGl2ZXJhYmxlIjoiUmVhZCArIGRpYWdyYW0gKyAzIGZsYXNoY2FyZHM7IGlkZW50aWZ5IDIgZmFpbHVyZSBtb2RlcyBpbiBubHAgcHJlcHJvY2Vzc2luZy4iLCJiYXNpY1Rhc2siOiJJbXBsZW1lbnQgc2VudGltZW50IHRva2VuaXplciBhbmQgZW1iZWRkaW5nIGxvb2t1cCIsInNjZW5hcmlvIjoiSGFuZGxpbmcgdW5zZWVuIHRva2VucyBhbmQgdmFyeWluZyB0ZXh0IGxlbmd0aHMiLCJwcm9qZWN0V29ya3N0cmVhbSI6IlAwOCDCtyBTZW50aW1lbnQgQW5hbHlzaXMgRW5naW5lIiwicHJvamVjdElkIjoiUDA4IiwicHJvamVjdFRhc2siOiJTVEFSVCBQMDggU2VudGltZW50IEFuYWx5c2lzIEVuZ2luZTogUHJvY2VzcyBjdXN0b21lciByZXZpZXdzLjsgVG9rZW5pemF0aW9uIGFuZCBlbWJlZGRpbmdzLjsgU2VudGltZW50IGNsYXNzaWZpY2F0aW9uLi4gU2hpcCBzbWFsbGVzdCB2ZXJpZmlhYmxlIHNsaWNlOyBkb2N1bWVudCB0ZXN0cy4iLCJwcm9qZWN0RGVsaXZlcmFibGUiOiJQMDggbGF1bmNoOiBSdW5uYWJsZSBkZW1vOyBhdXRvbWF0ZWQgdGVzdHM7IFJFQURNRTsgcHJvY2VzcyBjdXN0b21lciByZXZpZXdzLiIsImludGVydmlldyI6IkJhZy1vZi13b3JkcyB2cyBjb250ZXh0dWFsIGVtYmVkZGluZ3M/IiwiZXhpdENyaXRlcmlhIjoiRXhwbGFpbiBubHAgcHJlcHJvY2Vzc2luZyBpbiAyIG1pbnV0ZXM7IDEgdGVzdGVkIGNvbW1pdDsgb25lIHNjZW5hcmlvIGFuc3dlcjsgMy81IGludGVydmlldyBwcmFjdGljZSBxdWVzdGlvbnMuIiwicGxhbm5lZEhvdXJzIjo2LCJyZWZlcmVuY2VVcmwiOiJodHRwczovL2RvY3MucHl0b3JjaC5vcmcvdHV0b3JpYWxzLyIsInNjZW5hcmlvRm9ybWF0IjoiSW5wdXRzIOKGkiBjb25zdHJhaW50cyDihpIgZWRnZSBjYXNlcyDihpIgYWxnb3JpdGhtIOKGkiBjb21wbGV4aXR5IOKGkiB0ZXN0czsgY29kZSBhbmQgcmVmbGVjdCIsImludGVydmlld1N0cnVjdHVyZSI6IlVzZSBkZWZpbml0aW9uIOKGkiBleGFtcGxlIOKGkiB0cmFkZS1vZmYg4oaSIGNvbW1vbiBmYWlsdXJlIOKGkiBwcm9kdWN0aW9uIGltcGxpY2F0aW9uIn0seyJwbGFuSWQiOiJjaHJvbmlzLWFpLWVuZ2luZWVyaW5nLTIwMjYtMTEtMDUiLCJkYXlOdW1iZXIiOjI4LCJkYXRlIjoiMjAyNi0xMi0wMiIsIndlZWsiOjQsInBoYXNlIjoiMDMgwrcgRGVlcCBMZWFybmluZyAmIE5MUCIsInBoYXNlTm8iOiIwMyIsInBoYXNlRGF5Ijo2LCJzdWJwaGFzZSI6IlNlcXVlbnRpYWwgbW9kZWxzIiwiY29uY2VwdHMiOiJSTk5zLCBMU1RNcywgYXR0ZW50aW9uIG9yaWdpbnMgYW5kIG1hc2tpbmciLCJ0aGVvcnlEZWxpdmVyYWJsZSI6IlJlYWQgKyBkaWFncmFtICsgMyBmbGFzaGNhcmRzOyBpZGVudGlmeSAyIGZhaWx1cmUgbW9kZXMgaW4gc2VxdWVudGlhbCBtb2RlbHMuIiwiYmFzaWNUYXNrIjoiVHJhaW4gc21hbGwgcmV2aWV3IGNsYXNzaWZpZXIgYmFzZWxpbmUiLCJzY2VuYXJpbyI6IkxvbmcgcmV2aWV3cyBmYWlsIGR1ZSB0byB2YW5pc2hpbmcgZ3JhZGllbnRzIiwicHJvamVjdFdvcmtzdHJlYW0iOiJQMDggwrcgU2VudGltZW50IEFuYWx5c2lzIEVuZ2luZSIsInByb2plY3RJZCI6IlAwOCIsInByb2plY3RUYXNrIjoiSVRFUkFURSBQMDggU2VudGltZW50IEFuYWx5c2lzIEVuZ2luZTogYWRkIGVkZ2UtY2FzZSBoYW5kbGluZywgdGVzdCBmaXh0dXJlLCByZXN1bHQgbG9nIG9yIEFQSSBjb250cmFjdCBhbGlnbmVkIHRvIHRvZGF54oCZcyB0b3BpYy4iLCJwcm9qZWN0RGVsaXZlcmFibGUiOiJPbmUgdGVzdGVkIGluY3JlbWVudGFsIGNvbW1pdCBmb3IgUDA4OyBub3RlIG9wZW4gZm9sbG93LXVwcyBpbiBiYWNrbG9nLiIsImludGVydmlldyI6IldoeSBkbyBMU1RNcyBoZWxwLCBhbmQgd2hhdCByZW1haW5zIGRpZmZpY3VsdD8iLCJleGl0Q3JpdGVyaWEiOiJFeHBsYWluIHNlcXVlbnRpYWwgbW9kZWxzIGluIDIgbWludXRlczsgMSB0ZXN0ZWQgY29tbWl0OyBvbmUgc2NlbmFyaW8gYW5zd2VyOyAzLzUgaW50ZXJ2aWV3IHByYWN0aWNlIHF1ZXN0aW9ucy4iLCJwbGFubmVkSG91cnMiOjYsInJlZmVyZW5jZVVybCI6Imh0dHBzOi8vZG9jcy5weXRvcmNoLm9yZy90dXRvcmlhbHMvIiwic2NlbmFyaW9Gb3JtYXQiOiJJbnB1dHMg4oaSIGNvbnN0cmFpbnRzIOKGkiBlZGdlIGNhc2VzIOKGkiBhbGdvcml0aG0g4oaSIGNvbXBsZXhpdHkg4oaSIHRlc3RzOyBjb2RlIGFuZCByZWZsZWN0IiwiaW50ZXJ2aWV3U3RydWN0dXJlIjoiVXNlIGRlZmluaXRpb24g4oaSIGV4YW1wbGUg4oaSIHRyYWRlLW9mZiDihpIgY29tbW9uIGZhaWx1cmUg4oaSIHByb2R1Y3Rpb24gaW1wbGljYXRpb24ifSx7InBsYW5JZCI6ImNocm9uaXMtYWktZW5naW5lZXJpbmctMjAyNi0xMS0wNSIsImRheU51bWJlciI6MjksImRhdGUiOiIyMDI2LTEyLTAzIiwid2VlayI6NSwicGhhc2UiOiIwMyDCtyBEZWVwIExlYXJuaW5nICYgTkxQIiwicGhhc2VObyI6IjAzIiwicGhhc2VEYXkiOjcsInN1YnBoYXNlIjoiSW5mb3JtYXRpb24gZXh0cmFjdGlvbiIsImNvbmNlcHRzIjoiTkVSLCByZWdleCwgc2NoZW1hIGV4dHJhY3Rpb24sIG5vcm1hbGl6YXRpb24iLCJ0aGVvcnlEZWxpdmVyYWJsZSI6IlJlYWQgKyBkaWFncmFtICsgMyBmbGFzaGNhcmRzOyBpZGVudGlmeSAyIGZhaWx1cmUgbW9kZXMgaW4gaW5mb3JtYXRpb24gZXh0cmFjdGlvbi4iLCJiYXNpY1Rhc2siOiJQYXJzZSByZXN1bWVzIGFuZCBub3JtYWxpemUgam9iIHNraWxscyIsInNjZW5hcmlvIjoiRXh0cmFjdCBkYXRlcyBmcm9tIG11bHRpbGluZ3VhbCByZXN1bWVzIHNhZmVseSIsInByb2plY3RXb3Jrc3RyZWFtIjoiUDA5IMK3IEFJIFJlc3VtZSBQYXJzZXIgYW5kIEpvYiBNYXRjaGVyIiwicHJvamVjdElkIjoiUDA5IiwicHJvamVjdFRhc2siOiJTVEFSVCBQMDkgQUkgUmVzdW1lIFBhcnNlciBhbmQgSm9iIE1hdGNoZXI6IEV4dHJhY3QgcmVzdW1lIGluZm9ybWF0aW9uLjsgSWRlbnRpZnkgc2tpbGxzIGFuZCBleHBlcmllbmNlLjsgUGFyc2Ugam9iIGRlc2NyaXB0aW9ucy4uIFNoaXAgc21hbGxlc3QgdmVyaWZpYWJsZSBzbGljZTsgZG9jdW1lbnQgdGVzdHMuIiwicHJvamVjdERlbGl2ZXJhYmxlIjoiUDA5IGxhdW5jaDogUnVubmFibGUgZGVtbzsgYXV0b21hdGVkIHRlc3RzOyBSRUFETUU7IGV4dHJhY3QgcmVzdW1lIGluZm9ybWF0aW9uLiIsImludGVydmlldyI6IkhvdyBkbyB5b3UgbWVhc3VyZSBleHRyYWN0aW9uIHF1YWxpdHk/IiwiZXhpdENyaXRlcmlhIjoiRXhwbGFpbiBpbmZvcm1hdGlvbiBleHRyYWN0aW9uIGluIDIgbWludXRlczsgMSB0ZXN0ZWQgY29tbWl0OyBvbmUgc2NlbmFyaW8gYW5zd2VyOyAzLzUgaW50ZXJ2aWV3IHByYWN0aWNlIHF1ZXN0aW9ucy4iLCJwbGFubmVkSG91cnMiOjYsInJlZmVyZW5jZVVybCI6Imh0dHBzOi8vZG9jcy5weXRvcmNoLm9yZy90dXRvcmlhbHMvIiwic2NlbmFyaW9Gb3JtYXQiOiJJbnB1dHMg4oaSIGNvbnN0cmFpbnRzIOKGkiBlZGdlIGNhc2VzIOKGkiBhbGdvcml0aG0g4oaSIGNvbXBsZXhpdHkg4oaSIHRlc3RzOyBjb2RlIGFuZCByZWZsZWN0IiwiaW50ZXJ2aWV3U3RydWN0dXJlIjoiVXNlIGRlZmluaXRpb24g4oaSIGV4YW1wbGUg4oaSIHRyYWRlLW9mZiDihpIgY29tbW9uIGZhaWx1cmUg4oaSIHByb2R1Y3Rpb24gaW1wbGljYXRpb24ifSx7InBsYW5JZCI6ImNocm9uaXMtYWktZW5naW5lZXJpbmctMjAyNi0xMS0wNSIsImRheU51bWJlciI6MzAsImRhdGUiOiIyMDI2LTEyLTA0Iiwid2VlayI6NSwicGhhc2UiOiIwMyDCtyBEZWVwIExlYXJuaW5nICYgTkxQIiwicGhhc2VObyI6IjAzIiwicGhhc2VEYXkiOjgsInN1YnBoYXNlIjoiU2VtYW50aWMgcmFua2luZyIsImNvbmNlcHRzIjoiU2VudGVuY2UgZW1iZWRkaW5ncywgY29zaW5lIHNjb3JlcywgcmFua2luZyBldmFsdWF0aW9uIiwidGhlb3J5RGVsaXZlcmFibGUiOiJSZWFkICsgZGlhZ3JhbSArIDMgZmxhc2hjYXJkczsgaWRlbnRpZnkgMiBmYWlsdXJlIG1vZGVzIGluIHNlbWFudGljIHJhbmtpbmcuIiwiYmFzaWNUYXNrIjoiQ3JlYXRlIHJlc3VtZS1qb2Igc2ltaWxhcml0eSByYW5rZXIiLCJzY2VuYXJpbyI6IkhpZ2ggbGV4aWNhbCBtYXRjaCBidXQgcG9vciBzZW1hbnRpYyBmaXQiLCJwcm9qZWN0V29ya3N0cmVhbSI6IlAwOSDCtyBBSSBSZXN1bWUgUGFyc2VyIGFuZCBKb2IgTWF0Y2hlciIsInByb2plY3RJZCI6IlAwOSIsInByb2plY3RUYXNrIjoiSVRFUkFURSBQMDkgQUkgUmVzdW1lIFBhcnNlciBhbmQgSm9iIE1hdGNoZXI6IGFkZCBlZGdlLWNhc2UgaGFuZGxpbmcsIHRlc3QgZml4dHVyZSwgcmVzdWx0IGxvZyBvciBBUEkgY29udHJhY3QgYWxpZ25lZCB0byB0b2RheeKAmXMgdG9waWMuIiwicHJvamVjdERlbGl2ZXJhYmxlIjoiT25lIHRlc3RlZCBpbmNyZW1lbnRhbCBjb21taXQgZm9yIFAwOTsgbm90ZSBvcGVuIGZvbGxvdy11cHMgaW4gYmFja2xvZy4iLCJpbnRlcnZpZXciOiJDb3NpbmUgc2ltaWxhcml0eSB2cyBkb3QgcHJvZHVjdD8iLCJleGl0Q3JpdGVyaWEiOiJFeHBsYWluIHNlbWFudGljIHJhbmtpbmcgaW4gMiBtaW51dGVzOyAxIHRlc3RlZCBjb21taXQ7IG9uZSBzY2VuYXJpbyBhbnN3ZXI7IDMvNSBpbnRlcnZpZXcgcHJhY3RpY2UgcXVlc3Rpb25zLiIsInBsYW5uZWRIb3VycyI6NiwicmVmZXJlbmNlVXJsIjoiaHR0cHM6Ly9kb2NzLnB5dG9yY2gub3JnL3R1dG9yaWFscy8iLCJzY2VuYXJpb0Zvcm1hdCI6IklucHV0cyDihpIgY29uc3RyYWludHMg4oaSIGVkZ2UgY2FzZXMg4oaSIGFsZ29yaXRobSDihpIgY29tcGxleGl0eSDihpIgdGVzdHM7IGNvZGUgYW5kIHJlZmxlY3QiLCJpbnRlcnZpZXdTdHJ1Y3R1cmUiOiJVc2UgZGVmaW5pdGlvbiDihpIgZXhhbXBsZSDihpIgdHJhZGUtb2ZmIOKGkiBjb21tb24gZmFpbHVyZSDihpIgcHJvZHVjdGlvbiBpbXBsaWNhdGlvbiJ9LHsicGxhbklkIjoiY2hyb25pcy1haS1lbmdpbmVlcmluZy0yMDI2LTExLTA1IiwiZGF5TnVtYmVyIjozMSwiZGF0ZSI6IjIwMjYtMTItMDUiLCJ3ZWVrIjo1LCJwaGFzZSI6IjAzIMK3IERlZXAgTGVhcm5pbmcgJiBOTFAiLCJwaGFzZU5vIjoiMDMiLCJwaGFzZURheSI6OSwic3VicGhhc2UiOiJPYmplY3QgZGV0ZWN0aW9uIEkiLCJjb25jZXB0cyI6IkJveGVzLCBjb25maWRlbmNlLCBJb1UsIE5NUywgYW5ub3RhdGlvbnMiLCJ0aGVvcnlEZWxpdmVyYWJsZSI6IlJlYWQgKyBkaWFncmFtICsgMyBmbGFzaGNhcmRzOyBpZGVudGlmeSAyIGZhaWx1cmUgbW9kZXMgaW4gb2JqZWN0IGRldGVjdGlvbiBpLiIsImJhc2ljVGFzayI6IlVzZSBwcmV0cmFpbmVkIFlPTE8gb24gcmVjb3JkZWQgaW1hZ2VzIiwic2NlbmFyaW8iOiJSZXNvbHZlIG92ZXJsYXBwaW5nIGJvdW5kaW5nIGJveGVzIiwicHJvamVjdFdvcmtzdHJlYW0iOiJQMTAgwrcgUmVhbC1UaW1lIE9iamVjdCBEZXRlY3Rpb24iLCJwcm9qZWN0SWQiOiJQMTAiLCJwcm9qZWN0VGFzayI6IlNUQVJUIFAxMCBSZWFsLVRpbWUgT2JqZWN0IERldGVjdGlvbjogQ2FtZXJhL3ZpZGVvIHByb2Nlc3NpbmcuOyBPYmplY3QgZGV0ZWN0aW9uLjsgQm91bmRpbmcgYm94ZXMuLiBTaGlwIHNtYWxsZXN0IHZlcmlmaWFibGUgc2xpY2U7IGRvY3VtZW50IHRlc3RzLiIsInByb2plY3REZWxpdmVyYWJsZSI6IlAxMCBsYXVuY2g6IFJ1bm5hYmxlIGRlbW87IGF1dG9tYXRlZCB0ZXN0czsgUkVBRE1FOyBjYW1lcmEvdmlkZW8gcHJvY2Vzc2luZy4iLCJpbnRlcnZpZXciOiJXaHkgZG8gd2UgbmVlZCBub24tbWF4IHN1cHByZXNzaW9uPyIsImV4aXRDcml0ZXJpYSI6IkV4cGxhaW4gb2JqZWN0IGRldGVjdGlvbiBpIGluIDIgbWludXRlczsgMSB0ZXN0ZWQgY29tbWl0OyBvbmUgc2NlbmFyaW8gYW5zd2VyOyAzLzUgaW50ZXJ2aWV3IHByYWN0aWNlIHF1ZXN0aW9ucy4iLCJwbGFubmVkSG91cnMiOjYsInJlZmVyZW5jZVVybCI6Imh0dHBzOi8vZG9jcy5weXRvcmNoLm9yZy90dXRvcmlhbHMvIiwic2NlbmFyaW9Gb3JtYXQiOiJJbnB1dHMg4oaSIGNvbnN0cmFpbnRzIOKGkiBlZGdlIGNhc2VzIOKGkiBhbGdvcml0aG0g4oaSIGNvbXBsZXhpdHkg4oaSIHRlc3RzOyBjb2RlIGFuZCByZWZsZWN0IiwiaW50ZXJ2aWV3U3RydWN0dXJlIjoiVXNlIGRlZmluaXRpb24g4oaSIGV4YW1wbGUg4oaSIHRyYWRlLW9mZiDihpIgY29tbW9uIGZhaWx1cmUg4oaSIHByb2R1Y3Rpb24gaW1wbGljYXRpb24ifSx7InBsYW5JZCI6ImNocm9uaXMtYWktZW5naW5lZXJpbmctMjAyNi0xMS0wNSIsImRheU51bWJlciI6MzIsImRhdGUiOiIyMDI2LTEyLTA2Iiwid2VlayI6NSwicGhhc2UiOiIwMyDCtyBEZWVwIExlYXJuaW5nICYgTkxQIiwicGhhc2VObyI6IjAzIiwicGhhc2VEYXkiOjEwLCJzdWJwaGFzZSI6Ik9iamVjdCBkZXRlY3Rpb24gSUkiLCJjb25jZXB0cyI6IlZpZGVvIGZyYW1lcywgaW5mZXJlbmNlIEZQUywgQ1BVL0dQVSwgdGhyZXNob2xkcyIsInRoZW9yeURlbGl2ZXJhYmxlIjoiUmVhZCArIGRpYWdyYW0gKyAzIGZsYXNoY2FyZHM7IGlkZW50aWZ5IDIgZmFpbHVyZSBtb2RlcyBpbiBvYmplY3QgZGV0ZWN0aW9uIGlpLiIsImJhc2ljVGFzayI6IkJlbmNobWFyayB3ZWJjYW0vdmlkZW8gZGV0ZWN0aW9uIG9mZmxpbmUiLCJzY2VuYXJpbyI6Ik1lZXQgMTUgRlBTIG9uIGNvbnN0cmFpbmVkIGRldmljZSIsInByb2plY3RXb3Jrc3RyZWFtIjoiUDEwIMK3IFJlYWwtVGltZSBPYmplY3QgRGV0ZWN0aW9uIiwicHJvamVjdElkIjoiUDEwIiwicHJvamVjdFRhc2siOiJJVEVSQVRFIFAxMCBSZWFsLVRpbWUgT2JqZWN0IERldGVjdGlvbjogYWRkIGVkZ2UtY2FzZSBoYW5kbGluZywgdGVzdCBmaXh0dXJlLCByZXN1bHQgbG9nIG9yIEFQSSBjb250cmFjdCBhbGlnbmVkIHRvIHRvZGF54oCZcyB0b3BpYy4iLCJwcm9qZWN0RGVsaXZlcmFibGUiOiJPbmUgdGVzdGVkIGluY3JlbWVudGFsIGNvbW1pdCBmb3IgUDEwOyBub3RlIG9wZW4gZm9sbG93LXVwcyBpbiBiYWNrbG9nLiIsImludGVydmlldyI6IlByZWNpc2lvbiB2cyByZWNhbGwgdHJhZGUtb2ZmIGluIGRldGVjdGlvbj8iLCJleGl0Q3JpdGVyaWEiOiJFeHBsYWluIG9iamVjdCBkZXRlY3Rpb24gaWkgaW4gMiBtaW51dGVzOyAxIHRlc3RlZCBjb21taXQ7IG9uZSBzY2VuYXJpbyBhbnN3ZXI7IDMvNSBpbnRlcnZpZXcgcHJhY3RpY2UgcXVlc3Rpb25zLiIsInBsYW5uZWRIb3VycyI6NiwicmVmZXJlbmNlVXJsIjoiaHR0cHM6Ly9kb2NzLnB5dG9yY2gub3JnL3R1dG9yaWFscy8iLCJzY2VuYXJpb0Zvcm1hdCI6IklucHV0cyDihpIgY29uc3RyYWludHMg4oaSIGVkZ2UgY2FzZXMg4oaSIGFsZ29yaXRobSDihpIgY29tcGxleGl0eSDihpIgdGVzdHM7IGNvZGUgYW5kIHJlZmxlY3QiLCJpbnRlcnZpZXdTdHJ1Y3R1cmUiOiJVc2UgZGVmaW5pdGlvbiDihpIgZXhhbXBsZSDihpIgdHJhZGUtb2ZmIOKGkiBjb21tb24gZmFpbHVyZSDihpIgcHJvZHVjdGlvbiBpbXBsaWNhdGlvbiJ9LHsicGxhbklkIjoiY2hyb25pcy1haS1lbmdpbmVlcmluZy0yMDI2LTExLTA1IiwiZGF5TnVtYmVyIjozMywiZGF0ZSI6IjIwMjYtMTItMDciLCJ3ZWVrIjo1LCJwaGFzZSI6IjAzIMK3IERlZXAgTGVhcm5pbmcgJiBOTFAiLCJwaGFzZU5vIjoiMDMiLCJwaGFzZURheSI6MTEsInN1YnBoYXNlIjoiVHJhbnNmb3JtZXJzIEkiLCJjb25jZXB0cyI6IlNlbGYtYXR0ZW50aW9uLCBwb3NpdGlvbnMsIGVuY29kZXIvZGVjb2RlciwgbWFza2luZyIsInRoZW9yeURlbGl2ZXJhYmxlIjoiUmVhZCArIGRpYWdyYW0gKyAzIGZsYXNoY2FyZHM7IGlkZW50aWZ5IDIgZmFpbHVyZSBtb2RlcyBpbiB0cmFuc2Zvcm1lcnMgaS4iLCJiYXNpY1Rhc2siOiJUcmFjZSBzbWFsbCBhdHRlbnRpb24gY2FsY3VsYXRpb24gaW4gTnVtUHkiLCJzY2VuYXJpbyI6IldoeSBkb2VzIG5haXZlIGF0dGVudGlvbiBjb25zdW1lIHF1YWRyYXRpYyBtZW1vcnk/IiwicHJvamVjdFdvcmtzdHJlYW0iOiJQMzQgwrcgVHJhbnNmb3JtZXItQmFzZWQgVGV4dCBTdW1tYXJpemVyIiwicHJvamVjdElkIjoiUDM0IiwicHJvamVjdFRhc2siOiJTVEFSVCBQMzQgVHJhbnNmb3JtZXItQmFzZWQgVGV4dCBTdW1tYXJpemVyOiBTdW1tYXJpemUgc2hvcnQgYXJ0aWNsZXMgd2l0aCBldmFsdWF0aW9uIGFuZCB0b2tlbiBidWRnZXRzLiBTaGlwIHNtYWxsZXN0IHZlcmlmaWFibGUgc2xpY2U7IGRvY3VtZW50IHRlc3RzLiIsInByb2plY3REZWxpdmVyYWJsZSI6IlAzNCBsYXVuY2g6IEJhc2VsaW5lICsgdGlueSB0cmFuc2Zvcm1lciArIFJPVUdFLXN0eWxlIHNjb3JlcyIsImludGVydmlldyI6IlNlbGYtYXR0ZW50aW9uIHZzIHJlY3VycmVuY2U/IiwiZXhpdENyaXRlcmlhIjoiRXhwbGFpbiB0cmFuc2Zvcm1lcnMgaSBpbiAyIG1pbnV0ZXM7IDEgdGVzdGVkIGNvbW1pdDsgb25lIHNjZW5hcmlvIGFuc3dlcjsgMy81IGludGVydmlldyBwcmFjdGljZSBxdWVzdGlvbnMuIiwicGxhbm5lZEhvdXJzIjo2LCJyZWZlcmVuY2VVcmwiOiJodHRwczovL2RvY3MucHl0b3JjaC5vcmcvdHV0b3JpYWxzLyIsInNjZW5hcmlvRm9ybWF0IjoiSW5wdXRzIOKGkiBjb25zdHJhaW50cyDihpIgZWRnZSBjYXNlcyDihpIgYWxnb3JpdGhtIOKGkiBjb21wbGV4aXR5IOKGkiB0ZXN0czsgY29kZSBhbmQgcmVmbGVjdCIsImludGVydmlld1N0cnVjdHVyZSI6IlVzZSBkZWZpbml0aW9uIOKGkiBleGFtcGxlIOKGkiB0cmFkZS1vZmYg4oaSIGNvbW1vbiBmYWlsdXJlIOKGkiBwcm9kdWN0aW9uIGltcGxpY2F0aW9uIn0seyJwbGFuSWQiOiJjaHJvbmlzLWFpLWVuZ2luZWVyaW5nLTIwMjYtMTEtMDUiLCJkYXlOdW1iZXIiOjM0LCJkYXRlIjoiMjAyNi0xMi0wOCIsIndlZWsiOjUsInBoYXNlIjoiMDMgwrcgRGVlcCBMZWFybmluZyAmIE5MUCIsInBoYXNlTm8iOiIwMyIsInBoYXNlRGF5IjoxMiwic3VicGhhc2UiOiJUcmFuc2Zvcm1lcnMgSUkiLCJjb25jZXB0cyI6Ikh1Z2dpbmcgRmFjZSB0b2tlbml6ZXIvbW9kZWwgQVBJcywgZGF0YXNldCBtYXBwaW5nIiwidGhlb3J5RGVsaXZlcmFibGUiOiJSZWFkICsgZGlhZ3JhbSArIDMgZmxhc2hjYXJkczsgaWRlbnRpZnkgMiBmYWlsdXJlIG1vZGVzIGluIHRyYW5zZm9ybWVycyBpaS4iLCJiYXNpY1Rhc2siOiJGaW5lLXR1bmUgdGlueSB0cmFuc2Zvcm1lciB3aXRoIHRyYWluL3ZhbCBsb2dzIiwic2NlbmFyaW8iOiJBdm9pZCBPT00gYnkgcmVkdWNpbmcgc2VxdWVuY2UgbGVuZ3RoIGFuZCBiYXRjaCIsInByb2plY3RXb3Jrc3RyZWFtIjoiUDM0IMK3IFRyYW5zZm9ybWVyLUJhc2VkIFRleHQgU3VtbWFyaXplciIsInByb2plY3RJZCI6IlAzNCIsInByb2plY3RUYXNrIjoiSVRFUkFURSBQMzQgVHJhbnNmb3JtZXItQmFzZWQgVGV4dCBTdW1tYXJpemVyOiBhZGQgZWRnZS1jYXNlIGhhbmRsaW5nLCB0ZXN0IGZpeHR1cmUsIHJlc3VsdCBsb2cgb3IgQVBJIGNvbnRyYWN0IGFsaWduZWQgdG8gdG9kYXnigJlzIHRvcGljLiIsInByb2plY3REZWxpdmVyYWJsZSI6Ik9uZSB0ZXN0ZWQgaW5jcmVtZW50YWwgY29tbWl0IGZvciBQMzQ7IG5vdGUgb3BlbiBmb2xsb3ctdXBzIGluIGJhY2tsb2cuIiwiaW50ZXJ2aWV3IjoiSG93IGRvIHRva2VuIElEcyBiZWNvbWUgZW1iZWRkaW5ncz8iLCJleGl0Q3JpdGVyaWEiOiJFeHBsYWluIHRyYW5zZm9ybWVycyBpaSBpbiAyIG1pbnV0ZXM7IDEgdGVzdGVkIGNvbW1pdDsgb25lIHNjZW5hcmlvIGFuc3dlcjsgMy81IGludGVydmlldyBwcmFjdGljZSBxdWVzdGlvbnMuIiwicGxhbm5lZEhvdXJzIjo2LCJyZWZlcmVuY2VVcmwiOiJodHRwczovL2RvY3MucHl0b3JjaC5vcmcvdHV0b3JpYWxzLyIsInNjZW5hcmlvRm9ybWF0IjoiSW5wdXRzIOKGkiBjb25zdHJhaW50cyDihpIgZWRnZSBjYXNlcyDihpIgYWxnb3JpdGhtIOKGkiBjb21wbGV4aXR5IOKGkiB0ZXN0czsgY29kZSBhbmQgcmVmbGVjdCIsImludGVydmlld1N0cnVjdHVyZSI6IlVzZSBkZWZpbml0aW9uIOKGkiBleGFtcGxlIOKGkiB0cmFkZS1vZmYg4oaSIGNvbW1vbiBmYWlsdXJlIOKGkiBwcm9kdWN0aW9uIGltcGxpY2F0aW9uIn0seyJwbGFuSWQiOiJjaHJvbmlzLWFpLWVuZ2luZWVyaW5nLTIwMjYtMTEtMDUiLCJkYXlOdW1iZXIiOjM1LCJkYXRlIjoiMjAyNi0xMi0wOSIsIndlZWsiOjUsInBoYXNlIjoiMDMgwrcgRGVlcCBMZWFybmluZyAmIE5MUCIsInBoYXNlTm8iOiIwMyIsInBoYXNlRGF5IjoxMywic3VicGhhc2UiOiJUcmFpbmluZyBzeXN0ZW1zIiwiY29uY2VwdHMiOiJTY2hlZHVsZXJzLCBncmFkaWVudCBhY2N1bXVsYXRpb24sIG1peGVkIHByZWNpc2lvbiwgZWFybHkgc3RvcCIsInRoZW9yeURlbGl2ZXJhYmxlIjoiUmVhZCArIGRpYWdyYW0gKyAzIGZsYXNoY2FyZHM7IGlkZW50aWZ5IDIgZmFpbHVyZSBtb2RlcyBpbiB0cmFpbmluZyBzeXN0ZW1zLiIsImJhc2ljVGFzayI6IkFkZCBjaGVja3BvaW50cyBhbmQgdHJhaW4gbG9nIHRvIERMIG1vZGVsIiwic2NlbmFyaW8iOiJUcmFpbmluZyBpbnRlcnJ1cHRlZCBhdCBlcG9jaCAzOyByZXN1bWUgY29ycmVjdGx5IiwicHJvamVjdFdvcmtzdHJlYW0iOiJQMzUgwrcgTW9kZWwgRHJpZnQgTW9uaXRvcmluZyBMYWIiLCJwcm9qZWN0SWQiOiJQMzUiLCJwcm9qZWN0VGFzayI6IlNUQVJUIFAzNSBNb2RlbCBEcmlmdCBNb25pdG9yaW5nIExhYjogRGV0ZWN0IGRhdGEgc2hpZnQgZnJvbSB0cmFpbmluZyB0byBpbmNvbWluZyBiYXRjaGVzLiBTaGlwIHNtYWxsZXN0IHZlcmlmaWFibGUgc2xpY2U7IGRvY3VtZW50IHRlc3RzLiIsInByb2plY3REZWxpdmVyYWJsZSI6IlAzNSBsYXVuY2g6IEdlbmVyYXRlIGRyaWZ0IHJlcG9ydCBhbmQgdHJpZ2dlciB0aHJlc2hvbGQgYWxlcnQiLCJpbnRlcnZpZXciOiJXaGF0IGRvZXMgZ3JhZGllbnQgYWNjdW11bGF0aW9uIGNoYW5nZT8iLCJleGl0Q3JpdGVyaWEiOiJFeHBsYWluIHRyYWluaW5nIHN5c3RlbXMgaW4gMiBtaW51dGVzOyAxIHRlc3RlZCBjb21taXQ7IG9uZSBzY2VuYXJpbyBhbnN3ZXI7IDMvNSBpbnRlcnZpZXcgcHJhY3RpY2UgcXVlc3Rpb25zLiIsInBsYW5uZWRIb3VycyI6NiwicmVmZXJlbmNlVXJsIjoiaHR0cHM6Ly9kb2NzLnB5dG9yY2gub3JnL3R1dG9yaWFscy8iLCJzY2VuYXJpb0Zvcm1hdCI6IklucHV0cyDihpIgY29uc3RyYWludHMg4oaSIGVkZ2UgY2FzZXMg4oaSIGFsZ29yaXRobSDihpIgY29tcGxleGl0eSDihpIgdGVzdHM7IGNvZGUgYW5kIHJlZmxlY3QiLCJpbnRlcnZpZXdTdHJ1Y3R1cmUiOiJVc2UgZGVmaW5pdGlvbiDihpIgZXhhbXBsZSDihpIgdHJhZGUtb2ZmIOKGkiBjb21tb24gZmFpbHVyZSDihpIgcHJvZHVjdGlvbiBpbXBsaWNhdGlvbiJ9LHsicGxhbklkIjoiY2hyb25pcy1haS1lbmdpbmVlcmluZy0yMDI2LTExLTA1IiwiZGF5TnVtYmVyIjozNiwiZGF0ZSI6IjIwMjYtMTItMTAiLCJ3ZWVrIjo2LCJwaGFzZSI6IjAzIMK3IERlZXAgTGVhcm5pbmcgJiBOTFAiLCJwaGFzZU5vIjoiMDMiLCJwaGFzZURheSI6MTQsInN1YnBoYXNlIjoiRGVlcCBsZWFybmluZyByZXZpZXciLCJjb25jZXB0cyI6IkFibGF0aW9ucywgbWV0cmljcywgZmFpbHVyZSBhbmFseXNpcywgcmVwcm9kdWNpYmlsaXR5IiwidGhlb3J5RGVsaXZlcmFibGUiOiJSZWFkICsgZGlhZ3JhbSArIDMgZmxhc2hjYXJkczsgaWRlbnRpZnkgMiBmYWlsdXJlIG1vZGVzIGluIGRlZXAgbGVhcm5pbmcgcmV2aWV3LiIsImJhc2ljVGFzayI6IkNvbXBhcmUgQ05OLCBwcmV0cmFpbmVkIG1vZGVsLCBjbGFzc2ljYWwgYmFzZWxpbmUiLCJzY2VuYXJpbyI6IkF1ZGl0IGluZmxhdGVkIG1ldHJpYyBmcm9tIGR1cGxpY2F0ZSBpbWFnZXMiLCJwcm9qZWN0V29ya3N0cmVhbSI6IlAzNSDCtyBNb2RlbCBEcmlmdCBNb25pdG9yaW5nIExhYiIsInByb2plY3RJZCI6IlAzNSIsInByb2plY3RUYXNrIjoiSVRFUkFURSBQMzUgTW9kZWwgRHJpZnQgTW9uaXRvcmluZyBMYWI6IGFkZCBlZGdlLWNhc2UgaGFuZGxpbmcsIHRlc3QgZml4dHVyZSwgcmVzdWx0IGxvZyBvciBBUEkgY29udHJhY3QgYWxpZ25lZCB0byB0b2RheeKAmXMgdG9waWMuIiwicHJvamVjdERlbGl2ZXJhYmxlIjoiT25lIHRlc3RlZCBpbmNyZW1lbnRhbCBjb21taXQgZm9yIFAzNTsgbm90ZSBvcGVuIGZvbGxvdy11cHMgaW4gYmFja2xvZy4iLCJpbnRlcnZpZXciOiJIb3cgdmVyaWZ5IGEgdHJhaW5pbmcgZXhwZXJpbWVudCBpbmRlcGVuZGVudGx5PyIsImV4aXRDcml0ZXJpYSI6IkV4cGxhaW4gZGVlcCBsZWFybmluZyByZXZpZXcgaW4gMiBtaW51dGVzOyAxIHRlc3RlZCBjb21taXQ7IG9uZSBzY2VuYXJpbyBhbnN3ZXI7IDMvNSBpbnRlcnZpZXcgcHJhY3RpY2UgcXVlc3Rpb25zLiIsInBsYW5uZWRIb3VycyI6NiwicmVmZXJlbmNlVXJsIjoiaHR0cHM6Ly9kb2NzLnB5dG9yY2gub3JnL3R1dG9yaWFscy8iLCJzY2VuYXJpb0Zvcm1hdCI6IklucHV0cyDihpIgY29uc3RyYWludHMg4oaSIGVkZ2UgY2FzZXMg4oaSIGFsZ29yaXRobSDihpIgY29tcGxleGl0eSDihpIgdGVzdHM7IGNvZGUgYW5kIHJlZmxlY3QiLCJpbnRlcnZpZXdTdHJ1Y3R1cmUiOiJVc2UgZGVmaW5pdGlvbiDihpIgZXhhbXBsZSDihpIgdHJhZGUtb2ZmIOKGkiBjb21tb24gZmFpbHVyZSDihpIgcHJvZHVjdGlvbiBpbXBsaWNhdGlvbiJ9LHsicGxhbklkIjoiY2hyb25pcy1haS1lbmdpbmVlcmluZy0yMDI2LTExLTA1IiwiZGF5TnVtYmVyIjozNywiZGF0ZSI6IjIwMjYtMTItMTEiLCJ3ZWVrIjo2LCJwaGFzZSI6IjA0IMK3IExMTXMgJiBSQUciLCJwaGFzZU5vIjoiMDQiLCJwaGFzZURheSI6MSwic3VicGhhc2UiOiJMTE0gaW50ZXJmYWNlcyIsImNvbmNlcHRzIjoiTExNIEFQSXMsIHRva2VucywgY29udGV4dCwgcm9sZXMsIHN0cnVjdHVyZWQgb3V0cHV0cywgc3RyZWFtaW5nIiwidGhlb3J5RGVsaXZlcmFibGUiOiJSZWFkICsgZGlhZ3JhbSArIDMgZmxhc2hjYXJkczsgaWRlbnRpZnkgMiBmYWlsdXJlIG1vZGVzIGluIGxsbSBpbnRlcmZhY2VzLiIsImJhc2ljVGFzayI6IldyYXAgb25lIG1vZGVsIHdpdGggdHlwZWQgYWRhcHRlciBhbmQgdGltZW91dCIsInNjZW5hcmlvIjoiUHJvdmlkZXIgcmV0dXJucyBtYWxmb3JtZWQgSlNPTiBpbnRlcm1pdHRlbnRseSIsInByb2plY3RXb3Jrc3RyZWFtIjoiUDExIMK3IE11bHRpLU1vZGVsIEFJIENoYXQgQXBwbGljYXRpb24iLCJwcm9qZWN0SWQiOiJQMTEiLCJwcm9qZWN0VGFzayI6IlNUQVJUIFAxMSBNdWx0aS1Nb2RlbCBBSSBDaGF0IEFwcGxpY2F0aW9uOiBJbnRlZ3JhdGUgbXVsdGlwbGUgbW9kZWwgcHJvdmlkZXJzLjsgU3RyZWFtIHJlc3BvbnNlcy47IE1haW50YWluIGNvbnZlcnNhdGlvbnMuLiBTaGlwIHNtYWxsZXN0IHZlcmlmaWFibGUgc2xpY2U7IGRvY3VtZW50IHRlc3RzLiIsInByb2plY3REZWxpdmVyYWJsZSI6IlAxMSBsYXVuY2g6IFJ1bm5hYmxlIGRlbW87IGF1dG9tYXRlZCB0ZXN0czsgUkVBRE1FOyBpbnRlZ3JhdGUgbXVsdGlwbGUgbW9kZWwgcHJvdmlkZXJzLiIsImludGVydmlldyI6IldoZW4gdG8gdXNlIHN0cnVjdHVyZWQgb3V0cHV0IGluc3RlYWQgb2YgcmVnZXg/IiwiZXhpdENyaXRlcmlhIjoiRXhwbGFpbiBsbG0gaW50ZXJmYWNlcyBpbiAyIG1pbnV0ZXM7IDEgdGVzdGVkIGNvbW1pdDsgb25lIHNjZW5hcmlvIGFuc3dlcjsgMy81IGludGVydmlldyBwcmFjdGljZSBxdWVzdGlvbnMuIiwicGxhbm5lZEhvdXJzIjo2LCJyZWZlcmVuY2VVcmwiOiJodHRwczovL3BsYXRmb3JtLm9wZW5haS5jb20vZG9jcy9ndWlkZXMiLCJzY2VuYXJpb0Zvcm1hdCI6IklucHV0cyDihpIgY29uc3RyYWludHMg4oaSIGVkZ2UgY2FzZXMg4oaSIGFsZ29yaXRobSDihpIgY29tcGxleGl0eSDihpIgdGVzdHM7IGNvZGUgYW5kIHJlZmxlY3QiLCJpbnRlcnZpZXdTdHJ1Y3R1cmUiOiJVc2UgZGVmaW5pdGlvbiDihpIgZXhhbXBsZSDihpIgdHJhZGUtb2ZmIOKGkiBjb21tb24gZmFpbHVyZSDihpIgcHJvZHVjdGlvbiBpbXBsaWNhdGlvbiJ9LHsicGxhbklkIjoiY2hyb25pcy1haS1lbmdpbmVlcmluZy0yMDI2LTExLTA1IiwiZGF5TnVtYmVyIjozOCwiZGF0ZSI6IjIwMjYtMTItMTIiLCJ3ZWVrIjo2LCJwaGFzZSI6IjA0IMK3IExMTXMgJiBSQUciLCJwaGFzZU5vIjoiMDQiLCJwaGFzZURheSI6Miwic3VicGhhc2UiOiJQcm9tcHQgZGVzaWduIiwiY29uY2VwdHMiOiJJbnN0cnVjdGlvbiBoaWVyYXJjaHksIGZldy1zaG90LCB2YWxpZGF0aW9uLCBkZXRlcm1pbmlzdGljIHRlc3RzIiwidGhlb3J5RGVsaXZlcmFibGUiOiJSZWFkICsgZGlhZ3JhbSArIDMgZmxhc2hjYXJkczsgaWRlbnRpZnkgMiBmYWlsdXJlIG1vZGVzIGluIHByb21wdCBkZXNpZ24uIiwiYmFzaWNUYXNrIjoiQnVpbGQgcHJvbXB0IHRlbXBsYXRlcyB3aXRoIGV4cGVjdGVkIEpTT04gc2NoZW1hIiwic2NlbmFyaW8iOiJQcm90ZWN0IHN5c3RlbSBpbnRlbnQgZnJvbSBob3N0aWxlIHVzZXIgcHJvbXB0IiwicHJvamVjdFdvcmtzdHJlYW0iOiJQMTEgwrcgTXVsdGktTW9kZWwgQUkgQ2hhdCBBcHBsaWNhdGlvbiIsInByb2plY3RJZCI6IlAxMSIsInByb2plY3RUYXNrIjoiSVRFUkFURSBQMTEgTXVsdGktTW9kZWwgQUkgQ2hhdCBBcHBsaWNhdGlvbjogYWRkIGVkZ2UtY2FzZSBoYW5kbGluZywgdGVzdCBmaXh0dXJlLCByZXN1bHQgbG9nIG9yIEFQSSBjb250cmFjdCBhbGlnbmVkIHRvIHRvZGF54oCZcyB0b3BpYy4iLCJwcm9qZWN0RGVsaXZlcmFibGUiOiJPbmUgdGVzdGVkIGluY3JlbWVudGFsIGNvbW1pdCBmb3IgUDExOyBub3RlIG9wZW4gZm9sbG93LXVwcyBpbiBiYWNrbG9nLiIsImludGVydmlldyI6IkhvdyBkbyB5b3UgcmVncmVzc2lvbi10ZXN0IHByb21wdHM/IiwiZXhpdENyaXRlcmlhIjoiRXhwbGFpbiBwcm9tcHQgZGVzaWduIGluIDIgbWludXRlczsgMSB0ZXN0ZWQgY29tbWl0OyBvbmUgc2NlbmFyaW8gYW5zd2VyOyAzLzUgaW50ZXJ2aWV3IHByYWN0aWNlIHF1ZXN0aW9ucy4iLCJwbGFubmVkSG91cnMiOjYsInJlZmVyZW5jZVVybCI6Imh0dHBzOi8vcGxhdGZvcm0ub3BlbmFpLmNvbS9kb2NzL2d1aWRlcyIsInNjZW5hcmlvRm9ybWF0IjoiSW5wdXRzIOKGkiBjb25zdHJhaW50cyDihpIgZWRnZSBjYXNlcyDihpIgYWxnb3JpdGhtIOKGkiBjb21wbGV4aXR5IOKGkiB0ZXN0czsgY29kZSBhbmQgcmVmbGVjdCIsImludGVydmlld1N0cnVjdHVyZSI6IlVzZSBkZWZpbml0aW9uIOKGkiBleGFtcGxlIOKGkiB0cmFkZS1vZmYg4oaSIGNvbW1vbiBmYWlsdXJlIOKGkiBwcm9kdWN0aW9uIGltcGxpY2F0aW9uIn0seyJwbGFuSWQiOiJjaHJvbmlzLWFpLWVuZ2luZWVyaW5nLTIwMjYtMTEtMDUiLCJkYXlOdW1iZXIiOjM5LCJkYXRlIjoiMjAyNi0xMi0xMyIsIndlZWsiOjYsInBoYXNlIjoiMDQgwrcgTExNcyAmIFJBRyIsInBoYXNlTm8iOiIwNCIsInBoYXNlRGF5IjozLCJzdWJwaGFzZSI6IlBERiBpbmdlc3Rpb24iLCJjb25jZXB0cyI6IlBERiBwYXJzaW5nLCBtZXRhZGF0YSwgT0NSIGJvdW5kYXJpZXMsIGNodW5raW5nIiwidGhlb3J5RGVsaXZlcmFibGUiOiJSZWFkICsgZGlhZ3JhbSArIDMgZmxhc2hjYXJkczsgaWRlbnRpZnkgMiBmYWlsdXJlIG1vZGVzIGluIHBkZiBpbmdlc3Rpb24uIiwiYmFzaWNUYXNrIjoiRXh0cmFjdCBQREYgdGV4dCB3aXRoIHBhZ2Uvc2VjdGlvbiBtZXRhZGF0YSIsInNjZW5hcmlvIjoiSGFuZGxlIHRhYmxlcyBzcGxpdCBiZXR3ZWVuIG11bHRpcGxlIHBhZ2VzIiwicHJvamVjdFdvcmtzdHJlYW0iOiJQMTIgwrcgUERGIFF1ZXN0aW9uIEFuc3dlcmluZyBTeXN0ZW0iLCJwcm9qZWN0SWQiOiJQMTIiLCJwcm9qZWN0VGFzayI6IlNUQVJUIFAxMiBQREYgUXVlc3Rpb24gQW5zd2VyaW5nIFN5c3RlbTogUERGIGluZ2VzdGlvbi47IERvY3VtZW50IHBhcnNpbmcuOyBDaHVua2luZy4uIFNoaXAgc21hbGxlc3QgdmVyaWZpYWJsZSBzbGljZTsgZG9jdW1lbnQgdGVzdHMuIiwicHJvamVjdERlbGl2ZXJhYmxlIjoiUDEyIGxhdW5jaDogUnVubmFibGUgZGVtbzsgYXV0b21hdGVkIHRlc3RzOyBSRUFETUU7IHBkZiBpbmdlc3Rpb24uIiwiaW50ZXJ2aWV3IjoiV2hhdCBjaHVua2luZyBlcnJvcnMgaGFybSBncm91bmRpbmc/IiwiZXhpdENyaXRlcmlhIjoiRXhwbGFpbiBwZGYgaW5nZXN0aW9uIGluIDIgbWludXRlczsgMSB0ZXN0ZWQgY29tbWl0OyBvbmUgc2NlbmFyaW8gYW5zd2VyOyAzLzUgaW50ZXJ2aWV3IHByYWN0aWNlIHF1ZXN0aW9ucy4iLCJwbGFubmVkSG91cnMiOjYsInJlZmVyZW5jZVVybCI6Imh0dHBzOi8vcGxhdGZvcm0ub3BlbmFpLmNvbS9kb2NzL2d1aWRlcyIsInNjZW5hcmlvRm9ybWF0IjoiSW5wdXRzIOKGkiBjb25zdHJhaW50cyDihpIgZWRnZSBjYXNlcyDihpIgYWxnb3JpdGhtIOKGkiBjb21wbGV4aXR5IOKGkiB0ZXN0czsgY29kZSBhbmQgcmVmbGVjdCIsImludGVydmlld1N0cnVjdHVyZSI6IlVzZSBkZWZpbml0aW9uIOKGkiBleGFtcGxlIOKGkiB0cmFkZS1vZmYg4oaSIGNvbW1vbiBmYWlsdXJlIOKGkiBwcm9kdWN0aW9uIGltcGxpY2F0aW9uIn0seyJwbGFuSWQiOiJjaHJvbmlzLWFpLWVuZ2luZWVyaW5nLTIwMjYtMTEtMDUiLCJkYXlOdW1iZXIiOjQwLCJkYXRlIjoiMjAyNi0xMi0xNCIsIndlZWsiOjYsInBoYXNlIjoiMDQgwrcgTExNcyAmIFJBRyIsInBoYXNlTm8iOiIwNCIsInBoYXNlRGF5Ijo0LCJzdWJwaGFzZSI6IlZlY3RvciByZXRyaWV2YWwiLCJjb25jZXB0cyI6IkVtYmVkZGluZ3MsIHZlY3RvciBpbmRleCwgRkFJU1MsIHRvcC1LLCBjb3NpbmUiLCJ0aGVvcnlEZWxpdmVyYWJsZSI6IlJlYWQgKyBkaWFncmFtICsgMyBmbGFzaGNhcmRzOyBpZGVudGlmeSAyIGZhaWx1cmUgbW9kZXMgaW4gdmVjdG9yIHJldHJpZXZhbC4iLCJiYXNpY1Rhc2siOiJJbXBsZW1lbnQgbG9jYWwgdmVjdG9yIHNlYXJjaCBmb3IgUERGcyIsInNjZW5hcmlvIjoiTG93IHJldHJpZXZhbCByZWNhbGwgZm9yIHN5bm9ueW0gcXVlcmllcyIsInByb2plY3RXb3Jrc3RyZWFtIjoiUDEyIMK3IFBERiBRdWVzdGlvbiBBbnN3ZXJpbmcgU3lzdGVtIiwicHJvamVjdElkIjoiUDEyIiwicHJvamVjdFRhc2siOiJJVEVSQVRFIFAxMiBQREYgUXVlc3Rpb24gQW5zd2VyaW5nIFN5c3RlbTogYWRkIGVkZ2UtY2FzZSBoYW5kbGluZywgdGVzdCBmaXh0dXJlLCByZXN1bHQgbG9nIG9yIEFQSSBjb250cmFjdCBhbGlnbmVkIHRvIHRvZGF54oCZcyB0b3BpYy4iLCJwcm9qZWN0RGVsaXZlcmFibGUiOiJPbmUgdGVzdGVkIGluY3JlbWVudGFsIGNvbW1pdCBmb3IgUDEyOyBub3RlIG9wZW4gZm9sbG93LXVwcyBpbiBiYWNrbG9nLiIsImludGVydmlldyI6IlJlY2FsbCB2ZXJzdXMgcHJlY2lzaW9uIGluIHJldHJpZXZhbD8iLCJleGl0Q3JpdGVyaWEiOiJFeHBsYWluIHZlY3RvciByZXRyaWV2YWwgaW4gMiBtaW51dGVzOyAxIHRlc3RlZCBjb21taXQ7IG9uZSBzY2VuYXJpbyBhbnN3ZXI7IDMvNSBpbnRlcnZpZXcgcHJhY3RpY2UgcXVlc3Rpb25zLiIsInBsYW5uZWRIb3VycyI6NiwicmVmZXJlbmNlVXJsIjoiaHR0cHM6Ly9wbGF0Zm9ybS5vcGVuYWkuY29tL2RvY3MvZ3VpZGVzIiwic2NlbmFyaW9Gb3JtYXQiOiJJbnB1dHMg4oaSIGNvbnN0cmFpbnRzIOKGkiBlZGdlIGNhc2VzIOKGkiBhbGdvcml0aG0g4oaSIGNvbXBsZXhpdHkg4oaSIHRlc3RzOyBjb2RlIGFuZCByZWZsZWN0IiwiaW50ZXJ2aWV3U3RydWN0dXJlIjoiVXNlIGRlZmluaXRpb24g4oaSIGV4YW1wbGUg4oaSIHRyYWRlLW9mZiDihpIgY29tbW9uIGZhaWx1cmUg4oaSIHByb2R1Y3Rpb24gaW1wbGljYXRpb24ifSx7InBsYW5JZCI6ImNocm9uaXMtYWktZW5naW5lZXJpbmctMjAyNi0xMS0wNSIsImRheU51bWJlciI6NDEsImRhdGUiOiIyMDI2LTEyLTE1Iiwid2VlayI6NiwicGhhc2UiOiIwNCDCtyBMTE1zICYgUkFHIiwicGhhc2VObyI6IjA0IiwicGhhc2VEYXkiOjUsInN1YnBoYXNlIjoiSFIgZW50ZXJwcmlzZSBhc3Npc3RhbnQiLCJjb25jZXB0cyI6Ik11bHRpLWRvY3VtZW50IFJBRywgUkJBQywgc291cmNlIGNpdGF0aW9ucyIsInRoZW9yeURlbGl2ZXJhYmxlIjoiUmVhZCArIGRpYWdyYW0gKyAzIGZsYXNoY2FyZHM7IGlkZW50aWZ5IDIgZmFpbHVyZSBtb2RlcyBpbiBociBlbnRlcnByaXNlIGFzc2lzdGFudC4iLCJiYXNpY1Rhc2siOiJCdWlsZCBIUiBwb2xpY3kgYXNzaXN0YW50IE1WUCB3aXRoIGRvY3VtZW50IGNvcnB1cyIsInNjZW5hcmlvIjoiRW5zdXJlIGNvbnRyYWN0b3JzIGNhbm5vdCByZWFkIGludGVybmFsIHNhbGFyeSBwb2xpY3kiLCJwcm9qZWN0V29ya3N0cmVhbSI6IlAxMyDCtyBFbnRlcnByaXNlIEhSIFBvbGljeSBBc3Npc3RhbnQiLCJwcm9qZWN0SWQiOiJQMTMiLCJwcm9qZWN0VGFzayI6IlNUQVJUIFAxMyBFbnRlcnByaXNlIEhSIFBvbGljeSBBc3Npc3RhbnQ6IE11bHRpcGxlIGRvY3VtZW50IGluZ2VzdGlvbi47IFBvbGljeS1iYXNlZCByZXRyaWV2YWwuOyBVc2VyLWxldmVsIHBlcm1pc3Npb25zLi4gU2hpcCBzbWFsbGVzdCB2ZXJpZmlhYmxlIHNsaWNlOyBkb2N1bWVudCB0ZXN0cy4iLCJwcm9qZWN0RGVsaXZlcmFibGUiOiJQMTMgbGF1bmNoOiBSdW5uYWJsZSBkZW1vOyBhdXRvbWF0ZWQgdGVzdHM7IFJFQURNRTsgbXVsdGlwbGUgZG9jdW1lbnQgaW5nZXN0aW9uLiIsImludGVydmlldyI6IldoYXQgaXMgdGVuYW50L3JvbGUtYXdhcmUgcmV0cmlldmFsPyIsImV4aXRDcml0ZXJpYSI6IkV4cGxhaW4gaHIgZW50ZXJwcmlzZSBhc3Npc3RhbnQgaW4gMiBtaW51dGVzOyAxIHRlc3RlZCBjb21taXQ7IG9uZSBzY2VuYXJpbyBhbnN3ZXI7IDMvNSBpbnRlcnZpZXcgcHJhY3RpY2UgcXVlc3Rpb25zLiIsInBsYW5uZWRIb3VycyI6NiwicmVmZXJlbmNlVXJsIjoiaHR0cHM6Ly9wbGF0Zm9ybS5vcGVuYWkuY29tL2RvY3MvZ3VpZGVzIiwic2NlbmFyaW9Gb3JtYXQiOiJJbnB1dHMg4oaSIGNvbnN0cmFpbnRzIOKGkiBlZGdlIGNhc2VzIOKGkiBhbGdvcml0aG0g4oaSIGNvbXBsZXhpdHkg4oaSIHRlc3RzOyBjb2RlIGFuZCByZWZsZWN0IiwiaW50ZXJ2aWV3U3RydWN0dXJlIjoiVXNlIGRlZmluaXRpb24g4oaSIGV4YW1wbGUg4oaSIHRyYWRlLW9mZiDihpIgY29tbW9uIGZhaWx1cmUg4oaSIHByb2R1Y3Rpb24gaW1wbGljYXRpb24ifSx7InBsYW5JZCI6ImNocm9uaXMtYWktZW5naW5lZXJpbmctMjAyNi0xMS0wNSIsImRheU51bWJlciI6NDIsImRhdGUiOiIyMDI2LTEyLTE2Iiwid2VlayI6NiwicGhhc2UiOiIwNCDCtyBMTE1zICYgUkFHIiwicGhhc2VObyI6IjA0IiwicGhhc2VEYXkiOjYsInN1YnBoYXNlIjoiU291cmNlLWdyb3VuZGVkIGFuc3dlcnMiLCJjb25jZXB0cyI6IkV2aWRlbmNlIHNwYW5zLCBjaXRhdGlvbiBmb3JtYXR0aW5nLCBhYnN0ZW50aW9uIHBvbGljaWVzIiwidGhlb3J5RGVsaXZlcmFibGUiOiJSZWFkICsgZGlhZ3JhbSArIDMgZmxhc2hjYXJkczsgaWRlbnRpZnkgMiBmYWlsdXJlIG1vZGVzIGluIHNvdXJjZS1ncm91bmRlZCBhbnN3ZXJzLiIsImJhc2ljVGFzayI6IlJlcXVpcmUgZXZlcnkgcmVzcG9uc2UgY2xhaW0gdG8gY2l0ZSBwYWdlIElEcyIsInNjZW5hcmlvIjoiUXVlc3Rpb24gaGFzIG5vIGFuc3dlciBpbiB1cGxvYWRlZCBkb2N1bWVudHMiLCJwcm9qZWN0V29ya3N0cmVhbSI6IlAxMyDCtyBFbnRlcnByaXNlIEhSIFBvbGljeSBBc3Npc3RhbnQiLCJwcm9qZWN0SWQiOiJQMTMiLCJwcm9qZWN0VGFzayI6IklURVJBVEUgUDEzIEVudGVycHJpc2UgSFIgUG9saWN5IEFzc2lzdGFudDogYWRkIGVkZ2UtY2FzZSBoYW5kbGluZywgdGVzdCBmaXh0dXJlLCByZXN1bHQgbG9nIG9yIEFQSSBjb250cmFjdCBhbGlnbmVkIHRvIHRvZGF54oCZcyB0b3BpYy4iLCJwcm9qZWN0RGVsaXZlcmFibGUiOiJPbmUgdGVzdGVkIGluY3JlbWVudGFsIGNvbW1pdCBmb3IgUDEzOyBub3RlIG9wZW4gZm9sbG93LXVwcyBpbiBiYWNrbG9nLiIsImludGVydmlldyI6IldoYXQgZGlzdGluZ3Vpc2hlcyBncm91bmRlZCBnZW5lcmF0aW9uIGZyb20gaGFsbHVjaW5hdGlvbj8iLCJleGl0Q3JpdGVyaWEiOiJFeHBsYWluIHNvdXJjZS1ncm91bmRlZCBhbnN3ZXJzIGluIDIgbWludXRlczsgMSB0ZXN0ZWQgY29tbWl0OyBvbmUgc2NlbmFyaW8gYW5zd2VyOyAzLzUgaW50ZXJ2aWV3IHByYWN0aWNlIHF1ZXN0aW9ucy4iLCJwbGFubmVkSG91cnMiOjYsInJlZmVyZW5jZVVybCI6Imh0dHBzOi8vcGxhdGZvcm0ub3BlbmFpLmNvbS9kb2NzL2d1aWRlcyIsInNjZW5hcmlvRm9ybWF0IjoiSW5wdXRzIOKGkiBjb25zdHJhaW50cyDihpIgZWRnZSBjYXNlcyDihpIgYWxnb3JpdGhtIOKGkiBjb21wbGV4aXR5IOKGkiB0ZXN0czsgY29kZSBhbmQgcmVmbGVjdCIsImludGVydmlld1N0cnVjdHVyZSI6IlVzZSBkZWZpbml0aW9uIOKGkiBleGFtcGxlIOKGkiB0cmFkZS1vZmYg4oaSIGNvbW1vbiBmYWlsdXJlIOKGkiBwcm9kdWN0aW9uIGltcGxpY2F0aW9uIn0seyJwbGFuSWQiOiJjaHJvbmlzLWFpLWVuZ2luZWVyaW5nLTIwMjYtMTEtMDUiLCJkYXlOdW1iZXIiOjQzLCJkYXRlIjoiMjAyNi0xMi0xNyIsIndlZWsiOjcsInBoYXNlIjoiMDQgwrcgTExNcyAmIFJBRyIsInBoYXNlTm8iOiIwNCIsInBoYXNlRGF5Ijo3LCJzdWJwaGFzZSI6IlZlY3RvciBwZXJzaXN0ZW5jZSIsImNvbmNlcHRzIjoiUG9zdGdyZXMgcGd2ZWN0b3IsIG1ldGFkYXRhIGluZGV4LCBtaWdyYXRpb24sIGZpbHRlcnMiLCJ0aGVvcnlEZWxpdmVyYWJsZSI6IlJlYWQgKyBkaWFncmFtICsgMyBmbGFzaGNhcmRzOyBpZGVudGlmeSAyIGZhaWx1cmUgbW9kZXMgaW4gdmVjdG9yIHBlcnNpc3RlbmNlLiIsImJhc2ljVGFzayI6IlBlcnNpc3QgZW1iZWRkaW5ncyB3aXRoIHRlbmFudCBtZXRhZGF0YSBhbmQgaW5kZXhlcyIsInNjZW5hcmlvIjoiRmlsdGVyIHJlY29yZHMgYmVmb3JlIHZlY3RvciBzaW1pbGFyaXR5IHNjb3JpbmciLCJwcm9qZWN0V29ya3N0cmVhbSI6IlAxMyDCtyBFbnRlcnByaXNlIEhSIFBvbGljeSBBc3Npc3RhbnQiLCJwcm9qZWN0SWQiOiJQMTMiLCJwcm9qZWN0VGFzayI6IklURVJBVEUgUDEzIEVudGVycHJpc2UgSFIgUG9saWN5IEFzc2lzdGFudDogYWRkIGVkZ2UtY2FzZSBoYW5kbGluZywgdGVzdCBmaXh0dXJlLCByZXN1bHQgbG9nIG9yIEFQSSBjb250cmFjdCBhbGlnbmVkIHRvIHRvZGF54oCZcyB0b3BpYy4iLCJwcm9qZWN0RGVsaXZlcmFibGUiOiJPbmUgdGVzdGVkIGluY3JlbWVudGFsIGNvbW1pdCBmb3IgUDEzOyBub3RlIG9wZW4gZm9sbG93LXVwcyBpbiBiYWNrbG9nLiIsImludGVydmlldyI6IldoYXQgYXJlIEFOTiBpbmRleCB0cmFkZS1vZmZzPyIsImV4aXRDcml0ZXJpYSI6IkV4cGxhaW4gdmVjdG9yIHBlcnNpc3RlbmNlIGluIDIgbWludXRlczsgMSB0ZXN0ZWQgY29tbWl0OyBvbmUgc2NlbmFyaW8gYW5zd2VyOyAzLzUgaW50ZXJ2aWV3IHByYWN0aWNlIHF1ZXN0aW9ucy4iLCJwbGFubmVkSG91cnMiOjYsInJlZmVyZW5jZVVybCI6Imh0dHBzOi8vcGxhdGZvcm0ub3BlbmFpLmNvbS9kb2NzL2d1aWRlcyIsInNjZW5hcmlvRm9ybWF0IjoiSW5wdXRzIOKGkiBjb25zdHJhaW50cyDihpIgZWRnZSBjYXNlcyDihpIgYWxnb3JpdGhtIOKGkiBjb21wbGV4aXR5IOKGkiB0ZXN0czsgY29kZSBhbmQgcmVmbGVjdCIsImludGVydmlld1N0cnVjdHVyZSI6IlVzZSBkZWZpbml0aW9uIOKGkiBleGFtcGxlIOKGkiB0cmFkZS1vZmYg4oaSIGNvbW1vbiBmYWlsdXJlIOKGkiBwcm9kdWN0aW9uIGltcGxpY2F0aW9uIn0seyJwbGFuSWQiOiJjaHJvbmlzLWFpLWVuZ2luZWVyaW5nLTIwMjYtMTEtMDUiLCJkYXlOdW1iZXIiOjQ0LCJkYXRlIjoiMjAyNi0xMi0xOCIsIndlZWsiOjcsInBoYXNlIjoiMDQgwrcgTExNcyAmIFJBRyIsInBoYXNlTm8iOiIwNCIsInBoYXNlRGF5Ijo4LCJzdWJwaGFzZSI6Ikh5YnJpZCByZXRyaWV2YWwiLCJjb25jZXB0cyI6IkJNMjUgKyBkZW5zZSwgcmVjaXByb2NhbCByYW5rIGZ1c2lvbiwgcmVyYW5raW5nIiwidGhlb3J5RGVsaXZlcmFibGUiOiJSZWFkICsgZGlhZ3JhbSArIDMgZmxhc2hjYXJkczsgaWRlbnRpZnkgMiBmYWlsdXJlIG1vZGVzIGluIGh5YnJpZCByZXRyaWV2YWwuIiwiYmFzaWNUYXNrIjoiUHJvdG90eXBlIGh5YnJpZCByZXRyaWV2YWwgYWNyb3NzIG9uZSBjb3JwdXMiLCJzY2VuYXJpbyI6IkxleGljYWwgbmFtZXMgcmFuayBsb3cgaW4gcHVyZSBzZW1hbnRpYyBzZWFyY2giLCJwcm9qZWN0V29ya3N0cmVhbSI6IlAxNCDCtyBBZHZhbmNlZCBIeWJyaWQgUkFHIFBsYXRmb3JtIiwicHJvamVjdElkIjoiUDE0IiwicHJvamVjdFRhc2siOiJTVEFSVCBQMTQgQWR2YW5jZWQgSHlicmlkIFJBRyBQbGF0Zm9ybTogSHlicmlkIGtleXdvcmQgYW5kIHZlY3RvciBzZWFyY2guOyBRdWVyeSByZXdyaXRpbmcuOyBNZXRhZGF0YSBmaWx0ZXJpbmcuLiBTaGlwIHNtYWxsZXN0IHZlcmlmaWFibGUgc2xpY2U7IGRvY3VtZW50IHRlc3RzLiIsInByb2plY3REZWxpdmVyYWJsZSI6IlAxNCBsYXVuY2g6IFJ1bm5hYmxlIGRlbW87IGF1dG9tYXRlZCB0ZXN0czsgUkVBRE1FOyBoeWJyaWQga2V5d29yZCBhbmQgdmVjdG9yIHNlYXJjaC4iLCJpbnRlcnZpZXciOiJXaGVuIGRvZXMgQk0yNSBiZWF0IGRlbnNlIHJldHJpZXZhbD8iLCJleGl0Q3JpdGVyaWEiOiJFeHBsYWluIGh5YnJpZCByZXRyaWV2YWwgaW4gMiBtaW51dGVzOyAxIHRlc3RlZCBjb21taXQ7IG9uZSBzY2VuYXJpbyBhbnN3ZXI7IDMvNSBpbnRlcnZpZXcgcHJhY3RpY2UgcXVlc3Rpb25zLiIsInBsYW5uZWRIb3VycyI6NiwicmVmZXJlbmNlVXJsIjoiaHR0cHM6Ly9wbGF0Zm9ybS5vcGVuYWkuY29tL2RvY3MvZ3VpZGVzIiwic2NlbmFyaW9Gb3JtYXQiOiJJbnB1dHMg4oaSIGNvbnN0cmFpbnRzIOKGkiBlZGdlIGNhc2VzIOKGkiBhbGdvcml0aG0g4oaSIGNvbXBsZXhpdHkg4oaSIHRlc3RzOyBjb2RlIGFuZCByZWZsZWN0IiwiaW50ZXJ2aWV3U3RydWN0dXJlIjoiVXNlIGRlZmluaXRpb24g4oaSIGV4YW1wbGUg4oaSIHRyYWRlLW9mZiDihpIgY29tbW9uIGZhaWx1cmUg4oaSIHByb2R1Y3Rpb24gaW1wbGljYXRpb24ifSx7InBsYW5JZCI6ImNocm9uaXMtYWktZW5naW5lZXJpbmctMjAyNi0xMS0wNSIsImRheU51bWJlciI6NDUsImRhdGUiOiIyMDI2LTEyLTE5Iiwid2VlayI6NywicGhhc2UiOiIwNCDCtyBMTE1zICYgUkFHIiwicGhhc2VObyI6IjA0IiwicGhhc2VEYXkiOjksInN1YnBoYXNlIjoiUkFHIGV2YWx1YXRpb24iLCJjb25jZXB0cyI6IkdvbGRlbiBRQSwgUmVjYWxsQEssIE1SUiwgZmFpdGhmdWxuZXNzLCBqdWRnZSBjYWxpYnJhdGlvbiIsInRoZW9yeURlbGl2ZXJhYmxlIjoiUmVhZCArIGRpYWdyYW0gKyAzIGZsYXNoY2FyZHM7IGlkZW50aWZ5IDIgZmFpbHVyZSBtb2RlcyBpbiByYWcgZXZhbHVhdGlvbi4iLCJiYXNpY1Rhc2siOiJCdWlsZCAyMC1xdWVyeSBldmFsdWF0aW9uIHNldCB3aXRoIGZhaWx1cmVzIiwic2NlbmFyaW8iOiJSQUcgaW1wcm92ZWQgbGF0ZW5jeSBidXQgcmVkdWNlZCBjb3JyZWN0bmVzcyIsInByb2plY3RXb3Jrc3RyZWFtIjoiUDE0IMK3IEFkdmFuY2VkIEh5YnJpZCBSQUcgUGxhdGZvcm0iLCJwcm9qZWN0SWQiOiJQMTQiLCJwcm9qZWN0VGFzayI6IklURVJBVEUgUDE0IEFkdmFuY2VkIEh5YnJpZCBSQUcgUGxhdGZvcm06IGFkZCBlZGdlLWNhc2UgaGFuZGxpbmcsIHRlc3QgZml4dHVyZSwgcmVzdWx0IGxvZyBvciBBUEkgY29udHJhY3QgYWxpZ25lZCB0byB0b2RheeKAmXMgdG9waWMuIiwicHJvamVjdERlbGl2ZXJhYmxlIjoiT25lIHRlc3RlZCBpbmNyZW1lbnRhbCBjb21taXQgZm9yIFAxNDsgbm90ZSBvcGVuIGZvbGxvdy11cHMgaW4gYmFja2xvZy4iLCJpbnRlcnZpZXciOiJIb3cgZXZhbHVhdGUgcmV0cmlldmFsIGFuZCBhbnN3ZXIgc2VwYXJhdGVseT8iLCJleGl0Q3JpdGVyaWEiOiJFeHBsYWluIHJhZyBldmFsdWF0aW9uIGluIDIgbWludXRlczsgMSB0ZXN0ZWQgY29tbWl0OyBvbmUgc2NlbmFyaW8gYW5zd2VyOyAzLzUgaW50ZXJ2aWV3IHByYWN0aWNlIHF1ZXN0aW9ucy4iLCJwbGFubmVkSG91cnMiOjYsInJlZmVyZW5jZVVybCI6Imh0dHBzOi8vcGxhdGZvcm0ub3BlbmFpLmNvbS9kb2NzL2d1aWRlcyIsInNjZW5hcmlvRm9ybWF0IjoiSW5wdXRzIOKGkiBjb25zdHJhaW50cyDihpIgZWRnZSBjYXNlcyDihpIgYWxnb3JpdGhtIOKGkiBjb21wbGV4aXR5IOKGkiB0ZXN0czsgY29kZSBhbmQgcmVmbGVjdCIsImludGVydmlld1N0cnVjdHVyZSI6IlVzZSBkZWZpbml0aW9uIOKGkiBleGFtcGxlIOKGkiB0cmFkZS1vZmYg4oaSIGNvbW1vbiBmYWlsdXJlIOKGkiBwcm9kdWN0aW9uIGltcGxpY2F0aW9uIn0seyJwbGFuSWQiOiJjaHJvbmlzLWFpLWVuZ2luZWVyaW5nLTIwMjYtMTEtMDUiLCJkYXlOdW1iZXIiOjQ2LCJkYXRlIjoiMjAyNi0xMi0yMCIsIndlZWsiOjcsInBoYXNlIjoiMDQgwrcgTExNcyAmIFJBRyIsInBoYXNlTm8iOiIwNCIsInBoYXNlRGF5IjoxMCwic3VicGhhc2UiOiJSZXRyaWV2YWwgb3B0aW1pemF0aW9uIiwiY29uY2VwdHMiOiJRdWVyeSByZXdyaXRpbmcsIHBhcmVudC1jaGlsZCByZXRyaWV2YWwsIGNhY2hpbmciLCJ0aGVvcnlEZWxpdmVyYWJsZSI6IlJlYWQgKyBkaWFncmFtICsgMyBmbGFzaGNhcmRzOyBpZGVudGlmeSAyIGZhaWx1cmUgbW9kZXMgaW4gcmV0cmlldmFsIG9wdGltaXphdGlvbi4iLCJiYXNpY1Rhc2siOiJDb21wYXJlIGNodW5rIHNpemVzIGFuZCBxdWVyeSByZXdyaXRpbmcgcXVhbGl0eSIsInNjZW5hcmlvIjoiTG9uZyBkb2N1bWVudCBjYXVzZXMgaXJyZWxldmFudCBjb250ZXh0IG92ZXJmbG93IiwicHJvamVjdFdvcmtzdHJlYW0iOiJQMTQgwrcgQWR2YW5jZWQgSHlicmlkIFJBRyBQbGF0Zm9ybSIsInByb2plY3RJZCI6IlAxNCIsInByb2plY3RUYXNrIjoiSVRFUkFURSBQMTQgQWR2YW5jZWQgSHlicmlkIFJBRyBQbGF0Zm9ybTogYWRkIGVkZ2UtY2FzZSBoYW5kbGluZywgdGVzdCBmaXh0dXJlLCByZXN1bHQgbG9nIG9yIEFQSSBjb250cmFjdCBhbGlnbmVkIHRvIHRvZGF54oCZcyB0b3BpYy4iLCJwcm9qZWN0RGVsaXZlcmFibGUiOiJPbmUgdGVzdGVkIGluY3JlbWVudGFsIGNvbW1pdCBmb3IgUDE0OyBub3RlIG9wZW4gZm9sbG93LXVwcyBpbiBiYWNrbG9nLiIsImludGVydmlldyI6IkhvdyBtaW5pbWl6ZSBjb250ZXh0IHdpdGhvdXQgbG9zaW5nIGV2aWRlbmNlPyIsImV4aXRDcml0ZXJpYSI6IkV4cGxhaW4gcmV0cmlldmFsIG9wdGltaXphdGlvbiBpbiAyIG1pbnV0ZXM7IDEgdGVzdGVkIGNvbW1pdDsgb25lIHNjZW5hcmlvIGFuc3dlcjsgMy81IGludGVydmlldyBwcmFjdGljZSBxdWVzdGlvbnMuIiwicGxhbm5lZEhvdXJzIjo2LCJyZWZlcmVuY2VVcmwiOiJodHRwczovL3BsYXRmb3JtLm9wZW5haS5jb20vZG9jcy9ndWlkZXMiLCJzY2VuYXJpb0Zvcm1hdCI6IklucHV0cyDihpIgY29uc3RyYWludHMg4oaSIGVkZ2UgY2FzZXMg4oaSIGFsZ29yaXRobSDihpIgY29tcGxleGl0eSDihpIgdGVzdHM7IGNvZGUgYW5kIHJlZmxlY3QiLCJpbnRlcnZpZXdTdHJ1Y3R1cmUiOiJVc2UgZGVmaW5pdGlvbiDihpIgZXhhbXBsZSDihpIgdHJhZGUtb2ZmIOKGkiBjb21tb24gZmFpbHVyZSDihpIgcHJvZHVjdGlvbiBpbXBsaWNhdGlvbiJ9LHsicGxhbklkIjoiY2hyb25pcy1haS1lbmdpbmVlcmluZy0yMDI2LTExLTA1IiwiZGF5TnVtYmVyIjo0NywiZGF0ZSI6IjIwMjYtMTItMjEiLCJ3ZWVrIjo3LCJwaGFzZSI6IjA0IMK3IExMTXMgJiBSQUciLCJwaGFzZU5vIjoiMDQiLCJwaGFzZURheSI6MTEsInN1YnBoYXNlIjoiTXVsdGltb2RhbCBmb3VuZGF0aW9ucyIsImNvbmNlcHRzIjoiVmlzaW9uLWxhbmd1YWdlIG1vZGVscywgaW1hZ2UgY2FwdGlvbnMsIGRvY3VtZW50IGxheW91dCIsInRoZW9yeURlbGl2ZXJhYmxlIjoiUmVhZCArIGRpYWdyYW0gKyAzIGZsYXNoY2FyZHM7IGlkZW50aWZ5IDIgZmFpbHVyZSBtb2RlcyBpbiBtdWx0aW1vZGFsIGZvdW5kYXRpb25zLiIsImJhc2ljVGFzayI6IkluZGV4IGltYWdlIGNhcHRpb25zIGFsb25nc2lkZSBQREYgc25pcHBldHMiLCJzY2VuYXJpbyI6IkFuc3dlciBxdWVzdGlvbiBhYm91dCBzY3JlZW5zaG90IHdpdGggY2l0YXRpb24iLCJwcm9qZWN0V29ya3N0cmVhbSI6IlAxNSDCtyBNdWx0aW1vZGFsIEFJIEtub3dsZWRnZSBBc3Npc3RhbnQiLCJwcm9qZWN0SWQiOiJQMTUiLCJwcm9qZWN0VGFzayI6IlNUQVJUIFAxNSBNdWx0aW1vZGFsIEFJIEtub3dsZWRnZSBBc3Npc3RhbnQ6IFVuZGVyc3RhbmQgZG9jdW1lbnRzLCB0YWJsZXMgYW5kIGltYWdlcy47IEV4dHJhY3QgdGV4dCBmcm9tIHNjYW5uZWQgZG9jdW1lbnRzLjsgUHJvY2VzcyBpbWFnZSBxdWVzdGlvbnMuLiBTaGlwIHNtYWxsZXN0IHZlcmlmaWFibGUgc2xpY2U7IGRvY3VtZW50IHRlc3RzLiIsInByb2plY3REZWxpdmVyYWJsZSI6IlAxNSBsYXVuY2g6IFJ1bm5hYmxlIGRlbW87IGF1dG9tYXRlZCB0ZXN0czsgUkVBRE1FOyB1bmRlcnN0YW5kIGRvY3VtZW50cywgdGFibGVzIGFuZCBpbWFnZXMuIiwiaW50ZXJ2aWV3IjoiV2h5IGlzIE9DUiBpbnN1ZmZpY2llbnQgZm9yIGNoYXJ0IHNlbWFudGljcz8iLCJleGl0Q3JpdGVyaWEiOiJFeHBsYWluIG11bHRpbW9kYWwgZm91bmRhdGlvbnMgaW4gMiBtaW51dGVzOyAxIHRlc3RlZCBjb21taXQ7IG9uZSBzY2VuYXJpbyBhbnN3ZXI7IDMvNSBpbnRlcnZpZXcgcHJhY3RpY2UgcXVlc3Rpb25zLiIsInBsYW5uZWRIb3VycyI6NiwicmVmZXJlbmNlVXJsIjoiaHR0cHM6Ly9wbGF0Zm9ybS5vcGVuYWkuY29tL2RvY3MvZ3VpZGVzIiwic2NlbmFyaW9Gb3JtYXQiOiJJbnB1dHMg4oaSIGNvbnN0cmFpbnRzIOKGkiBlZGdlIGNhc2VzIOKGkiBhbGdvcml0aG0g4oaSIGNvbXBsZXhpdHkg4oaSIHRlc3RzOyBjb2RlIGFuZCByZWZsZWN0IiwiaW50ZXJ2aWV3U3RydWN0dXJlIjoiVXNlIGRlZmluaXRpb24g4oaSIGV4YW1wbGUg4oaSIHRyYWRlLW9mZiDihpIgY29tbW9uIGZhaWx1cmUg4oaSIHByb2R1Y3Rpb24gaW1wbGljYXRpb24ifSx7InBsYW5JZCI6ImNocm9uaXMtYWktZW5naW5lZXJpbmctMjAyNi0xMS0wNSIsImRheU51bWJlciI6NDgsImRhdGUiOiIyMDI2LTEyLTIyIiwid2VlayI6NywicGhhc2UiOiIwNCDCtyBMTE1zICYgUkFHIiwicGhhc2VObyI6IjA0IiwicGhhc2VEYXkiOjEyLCJzdWJwaGFzZSI6IkNvbXBsZXggZG9jdW1lbnRzIiwiY29uY2VwdHMiOiJTY2FubmVkIFBERnMsIHRhYmxlcywgaW1hZ2VzLCBleHRyYWN0aW9uIGZhbGxiYWNrIiwidGhlb3J5RGVsaXZlcmFibGUiOiJSZWFkICsgZGlhZ3JhbSArIDMgZmxhc2hjYXJkczsgaWRlbnRpZnkgMiBmYWlsdXJlIG1vZGVzIGluIGNvbXBsZXggZG9jdW1lbnRzLiIsImJhc2ljVGFzayI6IlBhcnNlIGludm9pY2UgaW1hZ2UgKyB0YWJsZSBpbnRvIHR5cGVkIG9iamVjdHMiLCJzY2VuYXJpbyI6IkhhbmRsZSBibHVycmVkIHNjYW4gYW5kIG1pc3NpbmcgZmllbGQgd2l0aG91dCBpbnZlbnRpb24iLCJwcm9qZWN0V29ya3N0cmVhbSI6IlAxNSDCtyBNdWx0aW1vZGFsIEFJIEtub3dsZWRnZSBBc3Npc3RhbnQiLCJwcm9qZWN0SWQiOiJQMTUiLCJwcm9qZWN0VGFzayI6IklURVJBVEUgUDE1IE11bHRpbW9kYWwgQUkgS25vd2xlZGdlIEFzc2lzdGFudDogYWRkIGVkZ2UtY2FzZSBoYW5kbGluZywgdGVzdCBmaXh0dXJlLCByZXN1bHQgbG9nIG9yIEFQSSBjb250cmFjdCBhbGlnbmVkIHRvIHRvZGF54oCZcyB0b3BpYy4iLCJwcm9qZWN0RGVsaXZlcmFibGUiOiJPbmUgdGVzdGVkIGluY3JlbWVudGFsIGNvbW1pdCBmb3IgUDE1OyBub3RlIG9wZW4gZm9sbG93LXVwcyBpbiBiYWNrbG9nLiIsImludGVydmlldyI6IkhvdyB2YWxpZGF0ZSBtdWx0aW1vZGFsIGV4dHJhY3Rpb24gb3V0cHV0cz8iLCJleGl0Q3JpdGVyaWEiOiJFeHBsYWluIGNvbXBsZXggZG9jdW1lbnRzIGluIDIgbWludXRlczsgMSB0ZXN0ZWQgY29tbWl0OyBvbmUgc2NlbmFyaW8gYW5zd2VyOyAzLzUgaW50ZXJ2aWV3IHByYWN0aWNlIHF1ZXN0aW9ucy4iLCJwbGFubmVkSG91cnMiOjYsInJlZmVyZW5jZVVybCI6Imh0dHBzOi8vcGxhdGZvcm0ub3BlbmFpLmNvbS9kb2NzL2d1aWRlcyIsInNjZW5hcmlvRm9ybWF0IjoiSW5wdXRzIOKGkiBjb25zdHJhaW50cyDihpIgZWRnZSBjYXNlcyDihpIgYWxnb3JpdGhtIOKGkiBjb21wbGV4aXR5IOKGkiB0ZXN0czsgY29kZSBhbmQgcmVmbGVjdCIsImludGVydmlld1N0cnVjdHVyZSI6IlVzZSBkZWZpbml0aW9uIOKGkiBleGFtcGxlIOKGkiB0cmFkZS1vZmYg4oaSIGNvbW1vbiBmYWlsdXJlIOKGkiBwcm9kdWN0aW9uIGltcGxpY2F0aW9uIn0seyJwbGFuSWQiOiJjaHJvbmlzLWFpLWVuZ2luZWVyaW5nLTIwMjYtMTEtMDUiLCJkYXlOdW1iZXIiOjQ5LCJkYXRlIjoiMjAyNi0xMi0yMyIsIndlZWsiOjcsInBoYXNlIjoiMDQgwrcgTExNcyAmIFJBRyIsInBoYXNlTm8iOiIwNCIsInBoYXNlRGF5IjoxMywic3VicGhhc2UiOiJHYXRld2F5ICYgYnVkZ2V0cyIsImNvbmNlcHRzIjoiUHJvdmlkZXIgYWJzdHJhY3Rpb24sIHJldHJpZXMsIHRva2VuIGNvdW50cywgY2FjaGluZyIsInRoZW9yeURlbGl2ZXJhYmxlIjoiUmVhZCArIGRpYWdyYW0gKyAzIGZsYXNoY2FyZHM7IGlkZW50aWZ5IDIgZmFpbHVyZSBtb2RlcyBpbiBnYXRld2F5ICYgYnVkZ2V0cy4iLCJiYXNpY1Rhc2siOiJUcmFjayB0b2tlbiB1c2FnZSBhbmQgZG9sbGFycyBwZXIgc2Vzc2lvbiIsInNjZW5hcmlvIjoiUHJvdmlkZXIgcmF0ZSBsaW1pdCBoaXRzIGR1cmluZyB1c2VyIHNwaWtlIiwicHJvamVjdFdvcmtzdHJlYW0iOiJQMzYgwrcgTExNIFRva2VuIE1ldGVyICYgUHJvbXB0IEJ1ZGdldCBSb3V0ZXIiLCJwcm9qZWN0SWQiOiJQMzYiLCJwcm9qZWN0VGFzayI6IlNUQVJUIFAzNiBMTE0gVG9rZW4gTWV0ZXIgJiBQcm9tcHQgQnVkZ2V0IFJvdXRlcjogRXN0aW1hdGUgdG9rZW5zLCBjYXAgY29zdCBhbmQgZmFsbGJhY2sgYnkgcG9saWN5LiBTaGlwIHNtYWxsZXN0IHZlcmlmaWFibGUgc2xpY2U7IGRvY3VtZW50IHRlc3RzLiIsInByb2plY3REZWxpdmVyYWJsZSI6IlAzNiBsYXVuY2g6IFJlY29yZCBwZXItc2Vzc2lvbiBjb3N0IHdpdGggaGFyZCBidWRnZXQgY2VpbGluZyIsImludGVydmlldyI6IkhvdyBjaG9vc2UgcmV0cnkgYW5kIGZhbGxiYWNrIHBvbGljeT8iLCJleGl0Q3JpdGVyaWEiOiJFeHBsYWluIGdhdGV3YXkgJiBidWRnZXRzIGluIDIgbWludXRlczsgMSB0ZXN0ZWQgY29tbWl0OyBvbmUgc2NlbmFyaW8gYW5zd2VyOyAzLzUgaW50ZXJ2aWV3IHByYWN0aWNlIHF1ZXN0aW9ucy4iLCJwbGFubmVkSG91cnMiOjYsInJlZmVyZW5jZVVybCI6Imh0dHBzOi8vcGxhdGZvcm0ub3BlbmFpLmNvbS9kb2NzL2d1aWRlcyIsInNjZW5hcmlvRm9ybWF0IjoiSW5wdXRzIOKGkiBjb25zdHJhaW50cyDihpIgZWRnZSBjYXNlcyDihpIgYWxnb3JpdGhtIOKGkiBjb21wbGV4aXR5IOKGkiB0ZXN0czsgY29kZSBhbmQgcmVmbGVjdCIsImludGVydmlld1N0cnVjdHVyZSI6IlVzZSBkZWZpbml0aW9uIOKGkiBleGFtcGxlIOKGkiB0cmFkZS1vZmYg4oaSIGNvbW1vbiBmYWlsdXJlIOKGkiBwcm9kdWN0aW9uIGltcGxpY2F0aW9uIn0seyJwbGFuSWQiOiJjaHJvbmlzLWFpLWVuZ2luZWVyaW5nLTIwMjYtMTEtMDUiLCJkYXlOdW1iZXIiOjUwLCJkYXRlIjoiMjAyNi0xMi0yNCIsIndlZWsiOjgsInBoYXNlIjoiMDQgwrcgTExNcyAmIFJBRyIsInBoYXNlTm8iOiIwNCIsInBoYXNlRGF5IjoxNCwic3VicGhhc2UiOiJMTE0gc2VjdXJpdHkiLCJjb25jZXB0cyI6IlByb21wdCBpbmplY3Rpb24sIHRvb2wgcmVzdWx0IHRydXN0LCBzZWNyZXQgcmVkYWN0aW9uIiwidGhlb3J5RGVsaXZlcmFibGUiOiJSZWFkICsgZGlhZ3JhbSArIDMgZmxhc2hjYXJkczsgaWRlbnRpZnkgMiBmYWlsdXJlIG1vZGVzIGluIGxsbSBzZWN1cml0eS4iLCJiYXNpY1Rhc2siOiJXcml0ZSBtYWxpY2lvdXMtZG9jdW1lbnQgcHJvbXB0IGluamVjdGlvbiB0ZXN0cyIsInNjZW5hcmlvIjoiUmV0cmlldmVkIHBvbGljeSBmYWxzZWx5IGluc3RydWN0cyBhZ2VudCB0byBsZWFrIHNlY3JldHMiLCJwcm9qZWN0V29ya3N0cmVhbSI6IlAzNiDCtyBMTE0gVG9rZW4gTWV0ZXIgJiBQcm9tcHQgQnVkZ2V0IFJvdXRlciIsInByb2plY3RJZCI6IlAzNiIsInByb2plY3RUYXNrIjoiSVRFUkFURSBQMzYgTExNIFRva2VuIE1ldGVyICYgUHJvbXB0IEJ1ZGdldCBSb3V0ZXI6IGFkZCBlZGdlLWNhc2UgaGFuZGxpbmcsIHRlc3QgZml4dHVyZSwgcmVzdWx0IGxvZyBvciBBUEkgY29udHJhY3QgYWxpZ25lZCB0byB0b2RheeKAmXMgdG9waWMuIiwicHJvamVjdERlbGl2ZXJhYmxlIjoiT25lIHRlc3RlZCBpbmNyZW1lbnRhbCBjb21taXQgZm9yIFAzNjsgbm90ZSBvcGVuIGZvbGxvdy11cHMgaW4gYmFja2xvZy4iLCJpbnRlcnZpZXciOiJXaHkgbXVzdCByZXRyaWV2ZWQgY29udGVudCByZW1haW4gdW50cnVzdGVkPyIsImV4aXRDcml0ZXJpYSI6IkV4cGxhaW4gbGxtIHNlY3VyaXR5IGluIDIgbWludXRlczsgMSB0ZXN0ZWQgY29tbWl0OyBvbmUgc2NlbmFyaW8gYW5zd2VyOyAzLzUgaW50ZXJ2aWV3IHByYWN0aWNlIHF1ZXN0aW9ucy4iLCJwbGFubmVkSG91cnMiOjYsInJlZmVyZW5jZVVybCI6Imh0dHBzOi8vcGxhdGZvcm0ub3BlbmFpLmNvbS9kb2NzL2d1aWRlcyIsInNjZW5hcmlvRm9ybWF0IjoiSW5wdXRzIOKGkiBjb25zdHJhaW50cyDihpIgZWRnZSBjYXNlcyDihpIgYWxnb3JpdGhtIOKGkiBjb21wbGV4aXR5IOKGkiB0ZXN0czsgY29kZSBhbmQgcmVmbGVjdCIsImludGVydmlld1N0cnVjdHVyZSI6IlVzZSBkZWZpbml0aW9uIOKGkiBleGFtcGxlIOKGkiB0cmFkZS1vZmYg4oaSIGNvbW1vbiBmYWlsdXJlIOKGkiBwcm9kdWN0aW9uIGltcGxpY2F0aW9uIn0seyJwbGFuSWQiOiJjaHJvbmlzLWFpLWVuZ2luZWVyaW5nLTIwMjYtMTEtMDUiLCJkYXlOdW1iZXIiOjUxLCJkYXRlIjoiMjAyNi0xMi0yNSIsIndlZWsiOjgsInBoYXNlIjoiMDQgwrcgTExNcyAmIFJBRyIsInBoYXNlTm8iOiIwNCIsInBoYXNlRGF5IjoxNSwic3VicGhhc2UiOiJNdWx0aWxpbmd1YWwga25vd2xlZGdlIiwiY29uY2VwdHMiOiJMYW5ndWFnZSBkZXRlY3Rpb24sIG11bHRpbGluZ3VhbCBlbWJlZGRpbmdzLCBsb2NhbGl6YXRpb24iLCJ0aGVvcnlEZWxpdmVyYWJsZSI6IlJlYWQgKyBkaWFncmFtICsgMyBmbGFzaGNhcmRzOyBpZGVudGlmeSAyIGZhaWx1cmUgbW9kZXMgaW4gbXVsdGlsaW5ndWFsIGtub3dsZWRnZS4iLCJiYXNpY1Rhc2siOiJCdWlsZCBiaWxpbmd1YWwgZG9jdW1lbnQgUSZBIHRlc3QgaGFybmVzcyIsInNjZW5hcmlvIjoiUmVnaW9uYWwtbGFuZ3VhZ2UgcXVlcnkgcmV0cmlldmVzIHdyb25nIHBvbGljeSIsInByb2plY3RXb3Jrc3RyZWFtIjoiUDM3IMK3IE11bHRpbGluZ3VhbCBLbm93bGVkZ2UgQm90IiwicHJvamVjdElkIjoiUDM3IiwicHJvamVjdFRhc2siOiJTVEFSVCBQMzcgTXVsdGlsaW5ndWFsIEtub3dsZWRnZSBCb3Q6IEFuc3dlciBxdWVzdGlvbnMgYWdhaW5zdCBFbmdsaXNoIGFuZCBUZWx1Z3UvSGluZGkgc2FtcGxlcy4gU2hpcCBzbWFsbGVzdCB2ZXJpZmlhYmxlIHNsaWNlOyBkb2N1bWVudCB0ZXN0cy4iLCJwcm9qZWN0RGVsaXZlcmFibGUiOiJQMzcgbGF1bmNoOiBDcm9zcy1sYW5ndWFnZSByZXRyaWV2YWwgZXZhbHVhdGlvbiB3aXRoIGNpdGF0aW9ucyIsImludGVydmlldyI6IkhvdyBldmFsdWF0ZSBtdWx0aWxpbmd1YWwgUkFHIGZhaXJseT8iLCJleGl0Q3JpdGVyaWEiOiJFeHBsYWluIG11bHRpbGluZ3VhbCBrbm93bGVkZ2UgaW4gMiBtaW51dGVzOyAxIHRlc3RlZCBjb21taXQ7IG9uZSBzY2VuYXJpbyBhbnN3ZXI7IDMvNSBpbnRlcnZpZXcgcHJhY3RpY2UgcXVlc3Rpb25zLiIsInBsYW5uZWRIb3VycyI6NiwicmVmZXJlbmNlVXJsIjoiaHR0cHM6Ly9wbGF0Zm9ybS5vcGVuYWkuY29tL2RvY3MvZ3VpZGVzIiwic2NlbmFyaW9Gb3JtYXQiOiJJbnB1dHMg4oaSIGNvbnN0cmFpbnRzIOKGkiBlZGdlIGNhc2VzIOKGkiBhbGdvcml0aG0g4oaSIGNvbXBsZXhpdHkg4oaSIHRlc3RzOyBjb2RlIGFuZCByZWZsZWN0IiwiaW50ZXJ2aWV3U3RydWN0dXJlIjoiVXNlIGRlZmluaXRpb24g4oaSIGV4YW1wbGUg4oaSIHRyYWRlLW9mZiDihpIgY29tbW9uIGZhaWx1cmUg4oaSIHByb2R1Y3Rpb24gaW1wbGljYXRpb24ifSx7InBsYW5JZCI6ImNocm9uaXMtYWktZW5naW5lZXJpbmctMjAyNi0xMS0wNSIsImRheU51bWJlciI6NTIsImRhdGUiOiIyMDI2LTEyLTI2Iiwid2VlayI6OCwicGhhc2UiOiIwNCDCtyBMTE1zICYgUkFHIiwicGhhc2VObyI6IjA0IiwicGhhc2VEYXkiOjE2LCJzdWJwaGFzZSI6IlJBRyBjaGVja3BvaW50IiwiY29uY2VwdHMiOiJFbmQtdG8tZW5kIHRlc3RzLCBjaXRhdGlvbnMsIGF1ZGl0IHRyYWlsLCBkZW1vIiwidGhlb3J5RGVsaXZlcmFibGUiOiJSZWFkICsgZGlhZ3JhbSArIDMgZmxhc2hjYXJkczsgaWRlbnRpZnkgMiBmYWlsdXJlIG1vZGVzIGluIHJhZyBjaGVja3BvaW50LiIsImJhc2ljVGFzayI6IlJlY29yZCBhIGRlbW8gYW5kIHJ1biBldmlkZW5jZS1iYXNlZCBiZW5jaG1hcmsiLCJzY2VuYXJpbyI6IlJlZ3Jlc3Npb24gYWZ0ZXIgbW92aW5nIHRvIG5ldyBlbWJlZGRpbmcgbW9kZWwiLCJwcm9qZWN0V29ya3N0cmVhbSI6IlAzNyDCtyBNdWx0aWxpbmd1YWwgS25vd2xlZGdlIEJvdCIsInByb2plY3RJZCI6IlAzNyIsInByb2plY3RUYXNrIjoiSVRFUkFURSBQMzcgTXVsdGlsaW5ndWFsIEtub3dsZWRnZSBCb3Q6IGFkZCBlZGdlLWNhc2UgaGFuZGxpbmcsIHRlc3QgZml4dHVyZSwgcmVzdWx0IGxvZyBvciBBUEkgY29udHJhY3QgYWxpZ25lZCB0byB0b2RheeKAmXMgdG9waWMuIiwicHJvamVjdERlbGl2ZXJhYmxlIjoiT25lIHRlc3RlZCBpbmNyZW1lbnRhbCBjb21taXQgZm9yIFAzNzsgbm90ZSBvcGVuIGZvbGxvdy11cHMgaW4gYmFja2xvZy4iLCJpbnRlcnZpZXciOiJXaGF0IGFyZSBsYXVuY2ggZ2F0ZXMgZm9yIFJBRyBwcm9kdWN0cz8iLCJleGl0Q3JpdGVyaWEiOiJFeHBsYWluIHJhZyBjaGVja3BvaW50IGluIDIgbWludXRlczsgMSB0ZXN0ZWQgY29tbWl0OyBvbmUgc2NlbmFyaW8gYW5zd2VyOyAzLzUgaW50ZXJ2aWV3IHByYWN0aWNlIHF1ZXN0aW9ucy4iLCJwbGFubmVkSG91cnMiOjYsInJlZmVyZW5jZVVybCI6Imh0dHBzOi8vcGxhdGZvcm0ub3BlbmFpLmNvbS9kb2NzL2d1aWRlcyIsInNjZW5hcmlvRm9ybWF0IjoiSW5wdXRzIOKGkiBjb25zdHJhaW50cyDihpIgZWRnZSBjYXNlcyDihpIgYWxnb3JpdGhtIOKGkiBjb21wbGV4aXR5IOKGkiB0ZXN0czsgY29kZSBhbmQgcmVmbGVjdCIsImludGVydmlld1N0cnVjdHVyZSI6IlVzZSBkZWZpbml0aW9uIOKGkiBleGFtcGxlIOKGkiB0cmFkZS1vZmYg4oaSIGNvbW1vbiBmYWlsdXJlIOKGkiBwcm9kdWN0aW9uIGltcGxpY2F0aW9uIn0seyJwbGFuSWQiOiJjaHJvbmlzLWFpLWVuZ2luZWVyaW5nLTIwMjYtMTEtMDUiLCJkYXlOdW1iZXIiOjUzLCJkYXRlIjoiMjAyNi0xMi0yNyIsIndlZWsiOjgsInBoYXNlIjoiMDUgwrcgQWdlbnRzICYgSGFybmVzcyIsInBoYXNlTm8iOiIwNSIsInBoYXNlRGF5IjoxLCJzdWJwaGFzZSI6IkFnZW50IHByaW1pdGl2ZXMiLCJjb25jZXB0cyI6IlRvb2xzLCBmdW5jdGlvbiBzY2hlbWFzLCB0eXBlZCBvdXRjb21lcywgY29udHJvbCBsb29wIiwidGhlb3J5RGVsaXZlcmFibGUiOiJSZWFkICsgZGlhZ3JhbSArIDMgZmxhc2hjYXJkczsgaWRlbnRpZnkgMiBmYWlsdXJlIG1vZGVzIGluIGFnZW50IHByaW1pdGl2ZXMuIiwiYmFzaWNUYXNrIjoiQnVpbGQgc2luZ2xlIHJlc2VhcmNoIGFnZW50IHdpdGggbW9jayB0b29sIiwic2NlbmFyaW8iOiJBZ2VudCBzZW5kcyBpbnZhbGlkIGFyZ3VtZW50cyB0byBzZW5zaXRpdmUgdG9vbCIsInByb2plY3RXb3Jrc3RyZWFtIjoiUDE2IMK3IEF1dG9ub21vdXMgQUkgUmVzZWFyY2ggQXNzaXN0YW50IiwicHJvamVjdElkIjoiUDE2IiwicHJvamVjdFRhc2siOiJTVEFSVCBQMTYgQXV0b25vbW91cyBBSSBSZXNlYXJjaCBBc3Npc3RhbnQ6IEJyZWFrIHJlc2VhcmNoIGludG8gc3VidGFza3MuOyBTZWFyY2ggYW5kIHJldHJpZXZlIGluZm9ybWF0aW9uLjsgQ29tcGFyZSBtdWx0aXBsZSBzb3VyY2VzLi4gU2hpcCBzbWFsbGVzdCB2ZXJpZmlhYmxlIHNsaWNlOyBkb2N1bWVudCB0ZXN0cy4iLCJwcm9qZWN0RGVsaXZlcmFibGUiOiJQMTYgbGF1bmNoOiBSdW5uYWJsZSBkZW1vOyBhdXRvbWF0ZWQgdGVzdHM7IFJFQURNRTsgYnJlYWsgcmVzZWFyY2ggaW50byBzdWJ0YXNrcy4iLCJpbnRlcnZpZXciOiJXaGF0IGRpc3Rpbmd1aXNoZXMgYW4gYWdlbnQgZnJvbSBhIGRldGVybWluaXN0aWMgd29ya2Zsb3c/IiwiZXhpdENyaXRlcmlhIjoiRXhwbGFpbiBhZ2VudCBwcmltaXRpdmVzIGluIDIgbWludXRlczsgMSB0ZXN0ZWQgY29tbWl0OyBvbmUgc2NlbmFyaW8gYW5zd2VyOyAzLzUgaW50ZXJ2aWV3IHByYWN0aWNlIHF1ZXN0aW9ucy4iLCJwbGFubmVkSG91cnMiOjYsInJlZmVyZW5jZVVybCI6Imh0dHBzOi8vZG9jcy5sYW5nY2hhaW4uY29tL29zcy9weXRob24vbGFuZ2dyYXBoL292ZXJ2aWV3Iiwic2NlbmFyaW9Gb3JtYXQiOiJJbnB1dHMg4oaSIGNvbnN0cmFpbnRzIOKGkiBlZGdlIGNhc2VzIOKGkiBhbGdvcml0aG0g4oaSIGNvbXBsZXhpdHkg4oaSIHRlc3RzOyBjb2RlIGFuZCByZWZsZWN0IiwiaW50ZXJ2aWV3U3RydWN0dXJlIjoiVXNlIGRlZmluaXRpb24g4oaSIGV4YW1wbGUg4oaSIHRyYWRlLW9mZiDihpIgY29tbW9uIGZhaWx1cmUg4oaSIHByb2R1Y3Rpb24gaW1wbGljYXRpb24ifSx7InBsYW5JZCI6ImNocm9uaXMtYWktZW5naW5lZXJpbmctMjAyNi0xMS0wNSIsImRheU51bWJlciI6NTQsImRhdGUiOiIyMDI2LTEyLTI4Iiwid2VlayI6OCwicGhhc2UiOiIwNSDCtyBBZ2VudHMgJiBIYXJuZXNzIiwicGhhc2VObyI6IjA1IiwicGhhc2VEYXkiOjIsInN1YnBoYXNlIjoiUGxhbm5pbmcgJiBSZUFjdCIsImNvbmNlcHRzIjoiUmVhc29uLWFjdC1vYnNlcnZlLCBtYXgtc3RlcHMsIGJ1ZGdldHMsIHRvb2wtcmVzdWx0IGNoZWNrcyIsInRoZW9yeURlbGl2ZXJhYmxlIjoiUmVhZCArIGRpYWdyYW0gKyAzIGZsYXNoY2FyZHM7IGlkZW50aWZ5IDIgZmFpbHVyZSBtb2RlcyBpbiBwbGFubmluZyAmIHJlYWN0LiIsImJhc2ljVGFzayI6IkltcGxlbWVudCBib3VuZGVkIHJlc2VhcmNoIGl0ZXJhdGlvbiBsb29wIiwic2NlbmFyaW8iOiJBZ2VudCByZXBlYXRzIHNhbWUgc2VhcmNoIGluZGVmaW5pdGVseSIsInByb2plY3RXb3Jrc3RyZWFtIjoiUDE2IMK3IEF1dG9ub21vdXMgQUkgUmVzZWFyY2ggQXNzaXN0YW50IiwicHJvamVjdElkIjoiUDE2IiwicHJvamVjdFRhc2siOiJJVEVSQVRFIFAxNiBBdXRvbm9tb3VzIEFJIFJlc2VhcmNoIEFzc2lzdGFudDogYWRkIGVkZ2UtY2FzZSBoYW5kbGluZywgdGVzdCBmaXh0dXJlLCByZXN1bHQgbG9nIG9yIEFQSSBjb250cmFjdCBhbGlnbmVkIHRvIHRvZGF54oCZcyB0b3BpYy4iLCJwcm9qZWN0RGVsaXZlcmFibGUiOiJPbmUgdGVzdGVkIGluY3JlbWVudGFsIGNvbW1pdCBmb3IgUDE2OyBub3RlIG9wZW4gZm9sbG93LXVwcyBpbiBiYWNrbG9nLiIsImludGVydmlldyI6IkhvdyBkbyBzdGVwIGJ1ZGdldHMgcHJldmVudCBydW5hd2F5IGNvc3Q/IiwiZXhpdENyaXRlcmlhIjoiRXhwbGFpbiBwbGFubmluZyAmIHJlYWN0IGluIDIgbWludXRlczsgMSB0ZXN0ZWQgY29tbWl0OyBvbmUgc2NlbmFyaW8gYW5zd2VyOyAzLzUgaW50ZXJ2aWV3IHByYWN0aWNlIHF1ZXN0aW9ucy4iLCJwbGFubmVkSG91cnMiOjYsInJlZmVyZW5jZVVybCI6Imh0dHBzOi8vZG9jcy5sYW5nY2hhaW4uY29tL29zcy9weXRob24vbGFuZ2dyYXBoL292ZXJ2aWV3Iiwic2NlbmFyaW9Gb3JtYXQiOiJJbnB1dHMg4oaSIGNvbnN0cmFpbnRzIOKGkiBlZGdlIGNhc2VzIOKGkiBhbGdvcml0aG0g4oaSIGNvbXBsZXhpdHkg4oaSIHRlc3RzOyBjb2RlIGFuZCByZWZsZWN0IiwiaW50ZXJ2aWV3U3RydWN0dXJlIjoiVXNlIGRlZmluaXRpb24g4oaSIGV4YW1wbGUg4oaSIHRyYWRlLW9mZiDihpIgY29tbW9uIGZhaWx1cmUg4oaSIHByb2R1Y3Rpb24gaW1wbGljYXRpb24ifSx7InBsYW5JZCI6ImNocm9uaXMtYWktZW5naW5lZXJpbmctMjAyNi0xMS0wNSIsImRheU51bWJlciI6NTUsImRhdGUiOiIyMDI2LTEyLTI5Iiwid2VlayI6OCwicGhhc2UiOiIwNSDCtyBBZ2VudHMgJiBIYXJuZXNzIiwicGhhc2VObyI6IjA1IiwicGhhc2VEYXkiOjMsInN1YnBoYXNlIjoiUGVybWlzc2lvbnMgJiBzYW5kYm94IiwiY29uY2VwdHMiOiJUb29sIGFsbG93bGlzdHMsIGFyZ3VtZW50IHZhbGlkYXRpb24sIGRyeS1ydW4sIHNlY3JldCBib3VuZGFyaWVzIiwidGhlb3J5RGVsaXZlcmFibGUiOiJSZWFkICsgZGlhZ3JhbSArIDMgZmxhc2hjYXJkczsgaWRlbnRpZnkgMiBmYWlsdXJlIG1vZGVzIGluIHBlcm1pc3Npb25zICYgc2FuZGJveC4iLCJiYXNpY1Rhc2siOiJJbXBsZW1lbnQgc2FmZSB0b29sIHJlZ2lzdHJ5IHdpdGggc2NvcGVkIHBlcm1pc3Npb25zIiwic2NlbmFyaW8iOiJUb29sIGF0dGVtcHRzIHRvIGFjY2VzcyBmaWxlIG91dHNpZGUgd29ya3NwYWNlIiwicHJvamVjdFdvcmtzdHJlYW0iOiJQMzggwrcgU2VjdXJlIEFJIFRvb2wgUmVnaXN0cnkiLCJwcm9qZWN0SWQiOiJQMzgiLCJwcm9qZWN0VGFzayI6IlNUQVJUIFAzOCBTZWN1cmUgQUkgVG9vbCBSZWdpc3RyeTogUmVnaXN0ZXIgdmVyc2lvbmVkIHRvb2xzIHdpdGggc2NoZW1hcyBhbmQgcGVybWlzc2lvbnMuIFNoaXAgc21hbGxlc3QgdmVyaWZpYWJsZSBzbGljZTsgZG9jdW1lbnQgdGVzdHMuIiwicHJvamVjdERlbGl2ZXJhYmxlIjoiUDM4IGxhdW5jaDogVW5hdXRob3JpemVkIHRvb2wgYmxvY2tlZCBhbmQgZnVsbHkgbG9nZ2VkIiwiaW50ZXJ2aWV3IjoiV2hlcmUgZW5mb3JjZSB0b29sIHBlcm1pc3Npb25zIHZzIHByb21wdCBydWxlcz8iLCJleGl0Q3JpdGVyaWEiOiJFeHBsYWluIHBlcm1pc3Npb25zICYgc2FuZGJveCBpbiAyIG1pbnV0ZXM7IDEgdGVzdGVkIGNvbW1pdDsgb25lIHNjZW5hcmlvIGFuc3dlcjsgMy81IGludGVydmlldyBwcmFjdGljZSBxdWVzdGlvbnMuIiwicGxhbm5lZEhvdXJzIjo2LCJyZWZlcmVuY2VVcmwiOiJodHRwczovL2RvY3MubGFuZ2NoYWluLmNvbS9vc3MvcHl0aG9uL2xhbmdncmFwaC9vdmVydmlldyIsInNjZW5hcmlvRm9ybWF0IjoiSW5wdXRzIOKGkiBjb25zdHJhaW50cyDihpIgZWRnZSBjYXNlcyDihpIgYWxnb3JpdGhtIOKGkiBjb21wbGV4aXR5IOKGkiB0ZXN0czsgY29kZSBhbmQgcmVmbGVjdCIsImludGVydmlld1N0cnVjdHVyZSI6IlVzZSBkZWZpbml0aW9uIOKGkiBleGFtcGxlIOKGkiB0cmFkZS1vZmYg4oaSIGNvbW1vbiBmYWlsdXJlIOKGkiBwcm9kdWN0aW9uIGltcGxpY2F0aW9uIn0seyJwbGFuSWQiOiJjaHJvbmlzLWFpLWVuZ2luZWVyaW5nLTIwMjYtMTEtMDUiLCJkYXlOdW1iZXIiOjU2LCJkYXRlIjoiMjAyNi0xMi0zMCIsIndlZWsiOjgsInBoYXNlIjoiMDUgwrcgQWdlbnRzICYgSGFybmVzcyIsInBoYXNlTm8iOiIwNSIsInBoYXNlRGF5Ijo0LCJzdWJwaGFzZSI6IlN0YXRlZnVsIG9yY2hlc3RyYXRpb24iLCJjb25jZXB0cyI6IkxhbmdHcmFwaCBub2RlcywgZWRnZXMsIHN0YXRlLCBwZXJzaXN0ZW5jZSIsInRoZW9yeURlbGl2ZXJhYmxlIjoiUmVhZCArIGRpYWdyYW0gKyAzIGZsYXNoY2FyZHM7IGlkZW50aWZ5IDIgZmFpbHVyZSBtb2RlcyBpbiBzdGF0ZWZ1bCBvcmNoZXN0cmF0aW9uLiIsImJhc2ljVGFzayI6IkRyYXcgc3VwZXJ2aXNvci9yZXNlYXJjaC9leGVjdXRpb24gZ3JhcGgiLCJzY2VuYXJpbyI6IlJlY292ZXIgaW50ZXJydXB0ZWQgd29ya2Zsb3cgd2l0aG91dCBsb3Npbmcgc3RhdGUiLCJwcm9qZWN0V29ya3N0cmVhbSI6IlAxNyDCtyBNdWx0aS1BZ2VudCBXb3JrZmxvdyBBdXRvbWF0aW9uIiwicHJvamVjdElkIjoiUDE3IiwicHJvamVjdFRhc2siOiJTVEFSVCBQMTcgTXVsdGktQWdlbnQgV29ya2Zsb3cgQXV0b21hdGlvbjogU3VwZXJ2aXNvciBhZ2VudC47IFJlc2VhcmNoIGFnZW50LjsgQW5hbHlzaXMgYWdlbnQuLiBTaGlwIHNtYWxsZXN0IHZlcmlmaWFibGUgc2xpY2U7IGRvY3VtZW50IHRlc3RzLiIsInByb2plY3REZWxpdmVyYWJsZSI6IlAxNyBsYXVuY2g6IFJ1bm5hYmxlIGRlbW87IGF1dG9tYXRlZCB0ZXN0czsgUkVBRE1FOyBzdXBlcnZpc29yIGFnZW50LiIsImludGVydmlldyI6IldoeSBtb2RlbCBvcmNoZXN0cmF0aW9ucyBhcyBzdGF0ZSBtYWNoaW5lcz8iLCJleGl0Q3JpdGVyaWEiOiJFeHBsYWluIHN0YXRlZnVsIG9yY2hlc3RyYXRpb24gaW4gMiBtaW51dGVzOyAxIHRlc3RlZCBjb21taXQ7IG9uZSBzY2VuYXJpbyBhbnN3ZXI7IDMvNSBpbnRlcnZpZXcgcHJhY3RpY2UgcXVlc3Rpb25zLiIsInBsYW5uZWRIb3VycyI6NiwicmVmZXJlbmNlVXJsIjoiaHR0cHM6Ly9kb2NzLmxhbmdjaGFpbi5jb20vb3NzL3B5dGhvbi9sYW5nZ3JhcGgvb3ZlcnZpZXciLCJzY2VuYXJpb0Zvcm1hdCI6IklucHV0cyDihpIgY29uc3RyYWludHMg4oaSIGVkZ2UgY2FzZXMg4oaSIGFsZ29yaXRobSDihpIgY29tcGxleGl0eSDihpIgdGVzdHM7IGNvZGUgYW5kIHJlZmxlY3QiLCJpbnRlcnZpZXdTdHJ1Y3R1cmUiOiJVc2UgZGVmaW5pdGlvbiDihpIgZXhhbXBsZSDihpIgdHJhZGUtb2ZmIOKGkiBjb21tb24gZmFpbHVyZSDihpIgcHJvZHVjdGlvbiBpbXBsaWNhdGlvbiJ9LHsicGxhbklkIjoiY2hyb25pcy1haS1lbmdpbmVlcmluZy0yMDI2LTExLTA1IiwiZGF5TnVtYmVyIjo1NywiZGF0ZSI6IjIwMjYtMTItMzEiLCJ3ZWVrIjo5LCJwaGFzZSI6IjA1IMK3IEFnZW50cyAmIEhhcm5lc3MiLCJwaGFzZU5vIjoiMDUiLCJwaGFzZURheSI6NSwic3VicGhhc2UiOiJNdWx0aS1hZ2VudCBjb29yZGluYXRpb24iLCJjb25jZXB0cyI6IlN1cGVydmlzb3Igcm91dGluZywgc3BlY2lhbGlzdCBhZ2VudHMsIHNoYXJlZCBjb250ZXh0LCBoYW5kb2ZmcyIsInRoZW9yeURlbGl2ZXJhYmxlIjoiUmVhZCArIGRpYWdyYW0gKyAzIGZsYXNoY2FyZHM7IGlkZW50aWZ5IDIgZmFpbHVyZSBtb2RlcyBpbiBtdWx0aS1hZ2VudCBjb29yZGluYXRpb24uIiwiYmFzaWNUYXNrIjoiSW1wbGVtZW50IHR3byBzcGVjaWFsaXN0cyB3aXRoIGJvdW5kZWQgdGFza3MiLCJzY2VuYXJpbyI6IlR3byBhZ2VudHMgZGlzYWdyZWUgYW5kIHJlcGVhdGVkbHkgdHJhbnNmZXIgY29udHJvbCIsInByb2plY3RXb3Jrc3RyZWFtIjoiUDE3IMK3IE11bHRpLUFnZW50IFdvcmtmbG93IEF1dG9tYXRpb24iLCJwcm9qZWN0SWQiOiJQMTciLCJwcm9qZWN0VGFzayI6IklURVJBVEUgUDE3IE11bHRpLUFnZW50IFdvcmtmbG93IEF1dG9tYXRpb246IGFkZCBlZGdlLWNhc2UgaGFuZGxpbmcsIHRlc3QgZml4dHVyZSwgcmVzdWx0IGxvZyBvciBBUEkgY29udHJhY3QgYWxpZ25lZCB0byB0b2RheeKAmXMgdG9waWMuIiwicHJvamVjdERlbGl2ZXJhYmxlIjoiT25lIHRlc3RlZCBpbmNyZW1lbnRhbCBjb21taXQgZm9yIFAxNzsgbm90ZSBvcGVuIGZvbGxvdy11cHMgaW4gYmFja2xvZy4iLCJpbnRlcnZpZXciOiJIYW5kb2ZmIHZzIG1hbmFnZXItYXMtdG9vbCBvcmNoZXN0cmF0aW9uPyIsImV4aXRDcml0ZXJpYSI6IkV4cGxhaW4gbXVsdGktYWdlbnQgY29vcmRpbmF0aW9uIGluIDIgbWludXRlczsgMSB0ZXN0ZWQgY29tbWl0OyBvbmUgc2NlbmFyaW8gYW5zd2VyOyAzLzUgaW50ZXJ2aWV3IHByYWN0aWNlIHF1ZXN0aW9ucy4iLCJwbGFubmVkSG91cnMiOjYsInJlZmVyZW5jZVVybCI6Imh0dHBzOi8vZG9jcy5sYW5nY2hhaW4uY29tL29zcy9weXRob24vbGFuZ2dyYXBoL292ZXJ2aWV3Iiwic2NlbmFyaW9Gb3JtYXQiOiJJbnB1dHMg4oaSIGNvbnN0cmFpbnRzIOKGkiBlZGdlIGNhc2VzIOKGkiBhbGdvcml0aG0g4oaSIGNvbXBsZXhpdHkg4oaSIHRlc3RzOyBjb2RlIGFuZCByZWZsZWN0IiwiaW50ZXJ2aWV3U3RydWN0dXJlIjoiVXNlIGRlZmluaXRpb24g4oaSIGV4YW1wbGUg4oaSIHRyYWRlLW9mZiDihpIgY29tbW9uIGZhaWx1cmUg4oaSIHByb2R1Y3Rpb24gaW1wbGljYXRpb24ifSx7InBsYW5JZCI6ImNocm9uaXMtYWktZW5naW5lZXJpbmctMjAyNi0xMS0wNSIsImRheU51bWJlciI6NTgsImRhdGUiOiIyMDI3LTAxLTAxIiwid2VlayI6OSwicGhhc2UiOiIwNSDCtyBBZ2VudHMgJiBIYXJuZXNzIiwicGhhc2VObyI6IjA1IiwicGhhc2VEYXkiOjYsInN1YnBoYXNlIjoiUGxhbm5lci9leGVjdXRvciIsImNvbmNlcHRzIjoiVGFzayBkZWNvbXBvc2l0aW9uLCB2ZXJpZmljYXRpb24sIHN0YXRlIGNvbnRyYWN0cywgd29yayBxdWV1ZXMiLCJ0aGVvcnlEZWxpdmVyYWJsZSI6IlJlYWQgKyBkaWFncmFtICsgMyBmbGFzaGNhcmRzOyBpZGVudGlmeSAyIGZhaWx1cmUgbW9kZXMgaW4gcGxhbm5lci9leGVjdXRvci4iLCJiYXNpY1Rhc2siOiJCdWlsZCBwbGFubmVyL2V4ZWN1dG9yIGludGVyZmFjZSB3aXRoIHZhbGlkYXRpb24iLCJzY2VuYXJpbyI6IlBsYW5uZXIgb21pdHMgcmVxdWlyZWQgdmVyaWZpY2F0aW9uIHN0YWdlIiwicHJvamVjdFdvcmtzdHJlYW0iOiJQMzkgwrcgUGxhbm5lcuKAk0V4ZWN1dG9yIEFnZW50IFdvcmtiZW5jaCIsInByb2plY3RJZCI6IlAzOSIsInByb2plY3RUYXNrIjoiU1RBUlQgUDM5IFBsYW5uZXLigJNFeGVjdXRvciBBZ2VudCBXb3JrYmVuY2g6IFNlcGFyYXRlIHRhc2sgcGxhbm5pbmcsIHRvb2wgZXhlY3V0aW9uLCB2ZXJpZmljYXRpb24uIFNoaXAgc21hbGxlc3QgdmVyaWZpYWJsZSBzbGljZTsgZG9jdW1lbnQgdGVzdHMuIiwicHJvamVjdERlbGl2ZXJhYmxlIjoiUDM5IGxhdW5jaDogRGV0ZXJtaW5pc3RpYyBkZW1vIG9mIGJvdW5kZWQgZXhlY3V0aW9uIHdpdGggcmV0cmllcyIsImludGVydmlldyI6IldoeSBzZXBhcmF0ZSBwbGFubmluZyBhbmQgZXhlY3V0aW5nPyIsImV4aXRDcml0ZXJpYSI6IkV4cGxhaW4gcGxhbm5lci9leGVjdXRvciBpbiAyIG1pbnV0ZXM7IDEgdGVzdGVkIGNvbW1pdDsgb25lIHNjZW5hcmlvIGFuc3dlcjsgMy81IGludGVydmlldyBwcmFjdGljZSBxdWVzdGlvbnMuIiwicGxhbm5lZEhvdXJzIjo2LCJyZWZlcmVuY2VVcmwiOiJodHRwczovL2RvY3MubGFuZ2NoYWluLmNvbS9vc3MvcHl0aG9uL2xhbmdncmFwaC9vdmVydmlldyIsInNjZW5hcmlvRm9ybWF0IjoiSW5wdXRzIOKGkiBjb25zdHJhaW50cyDihpIgZWRnZSBjYXNlcyDihpIgYWxnb3JpdGhtIOKGkiBjb21wbGV4aXR5IOKGkiB0ZXN0czsgY29kZSBhbmQgcmVmbGVjdCIsImludGVydmlld1N0cnVjdHVyZSI6IlVzZSBkZWZpbml0aW9uIOKGkiBleGFtcGxlIOKGkiB0cmFkZS1vZmYg4oaSIGNvbW1vbiBmYWlsdXJlIOKGkiBwcm9kdWN0aW9uIGltcGxpY2F0aW9uIn0seyJwbGFuSWQiOiJjaHJvbmlzLWFpLWVuZ2luZWVyaW5nLTIwMjYtMTEtMDUiLCJkYXlOdW1iZXIiOjU5LCJkYXRlIjoiMjAyNy0wMS0wMiIsIndlZWsiOjksInBoYXNlIjoiMDUgwrcgQWdlbnRzICYgSGFybmVzcyIsInBoYXNlTm8iOiIwNSIsInBoYXNlRGF5Ijo3LCJzdWJwaGFzZSI6IkNvZGUgaW50ZWxsaWdlbmNlIiwiY29uY2VwdHMiOiJBU1QsIHJlcG9zaXRvcnkgaW5kZXhpbmcsIHNlbWFudGljIGNvZGUgcmV0cmlldmFsIiwidGhlb3J5RGVsaXZlcmFibGUiOiJSZWFkICsgZGlhZ3JhbSArIDMgZmxhc2hjYXJkczsgaWRlbnRpZnkgMiBmYWlsdXJlIG1vZGVzIGluIGNvZGUgaW50ZWxsaWdlbmNlLiIsImJhc2ljVGFzayI6IkNyZWF0ZSBjb2RlLXNlYXJjaCBvdmVyIGEgdG95IHJlcG9zaXRvcnkiLCJzY2VuYXJpbyI6IkV4cGxhaW4gcmVmZXJlbmNlIGNoYWluIGFjcm9zcyAxMCBQeXRob24gbW9kdWxlcyIsInByb2plY3RXb3Jrc3RyZWFtIjoiUDE4IMK3IEFJIENvZGluZyBBc3Npc3RhbnQiLCJwcm9qZWN0SWQiOiJQMTgiLCJwcm9qZWN0VGFzayI6IlNUQVJUIFAxOCBBSSBDb2RpbmcgQXNzaXN0YW50OiBJbmRleCBzb3VyY2UgcmVwb3NpdG9yaWVzLjsgVW5kZXJzdGFuZCBjb2RlIHJlbGF0aW9uc2hpcHMuOyBHZW5lcmF0ZSBjb2RlIHN1Z2dlc3Rpb25zLi4gU2hpcCBzbWFsbGVzdCB2ZXJpZmlhYmxlIHNsaWNlOyBkb2N1bWVudCB0ZXN0cy4iLCJwcm9qZWN0RGVsaXZlcmFibGUiOiJQMTggbGF1bmNoOiBSdW5uYWJsZSBkZW1vOyBhdXRvbWF0ZWQgdGVzdHM7IFJFQURNRTsgaW5kZXggc291cmNlIHJlcG9zaXRvcmllcy4iLCJpbnRlcnZpZXciOiJBU1QgdnMgcmVnZXggZm9yIGNvZGUgYW5hbHlzaXM/IiwiZXhpdENyaXRlcmlhIjoiRXhwbGFpbiBjb2RlIGludGVsbGlnZW5jZSBpbiAyIG1pbnV0ZXM7IDEgdGVzdGVkIGNvbW1pdDsgb25lIHNjZW5hcmlvIGFuc3dlcjsgMy81IGludGVydmlldyBwcmFjdGljZSBxdWVzdGlvbnMuIiwicGxhbm5lZEhvdXJzIjo2LCJyZWZlcmVuY2VVcmwiOiJodHRwczovL2RvY3MubGFuZ2NoYWluLmNvbS9vc3MvcHl0aG9uL2xhbmdncmFwaC9vdmVydmlldyIsInNjZW5hcmlvRm9ybWF0IjoiSW5wdXRzIOKGkiBjb25zdHJhaW50cyDihpIgZWRnZSBjYXNlcyDihpIgYWxnb3JpdGhtIOKGkiBjb21wbGV4aXR5IOKGkiB0ZXN0czsgY29kZSBhbmQgcmVmbGVjdCIsImludGVydmlld1N0cnVjdHVyZSI6IlVzZSBkZWZpbml0aW9uIOKGkiBleGFtcGxlIOKGkiB0cmFkZS1vZmYg4oaSIGNvbW1vbiBmYWlsdXJlIOKGkiBwcm9kdWN0aW9uIGltcGxpY2F0aW9uIn0seyJwbGFuSWQiOiJjaHJvbmlzLWFpLWVuZ2luZWVyaW5nLTIwMjYtMTEtMDUiLCJkYXlOdW1iZXIiOjYwLCJkYXRlIjoiMjAyNy0wMS0wMyIsIndlZWsiOjksInBoYXNlIjoiMDUgwrcgQWdlbnRzICYgSGFybmVzcyIsInBoYXNlTm8iOiIwNSIsInBoYXNlRGF5Ijo4LCJzdWJwaGFzZSI6IkNvZGUgY2hhbmdlIHNhZmV0eSIsImNvbmNlcHRzIjoiRGlmZnMsIHBhdGNoIHZhbGlkYXRpb24sIHNhbmRib3ggdGVzdHMsIGFwcHJvdmFscyIsInRoZW9yeURlbGl2ZXJhYmxlIjoiUmVhZCArIGRpYWdyYW0gKyAzIGZsYXNoY2FyZHM7IGlkZW50aWZ5IDIgZmFpbHVyZSBtb2RlcyBpbiBjb2RlIGNoYW5nZSBzYWZldHkuIiwiYmFzaWNUYXNrIjoiQ3JlYXRlIFBSLXN0eWxlIHBhdGNoIHByb3Bvc2FsIHdpdGhvdXQgYXV0by1hcHBseWluZyIsInNjZW5hcmlvIjoiQWdlbnQgd2FudHMgdG8gb3ZlcndyaXRlIGNvbmZpZ3VyYXRpb24gc2VjcmV0cyIsInByb2plY3RXb3Jrc3RyZWFtIjoiUDE4IMK3IEFJIENvZGluZyBBc3Npc3RhbnQiLCJwcm9qZWN0SWQiOiJQMTgiLCJwcm9qZWN0VGFzayI6IklURVJBVEUgUDE4IEFJIENvZGluZyBBc3Npc3RhbnQ6IGFkZCBlZGdlLWNhc2UgaGFuZGxpbmcsIHRlc3QgZml4dHVyZSwgcmVzdWx0IGxvZyBvciBBUEkgY29udHJhY3QgYWxpZ25lZCB0byB0b2RheeKAmXMgdG9waWMuIiwicHJvamVjdERlbGl2ZXJhYmxlIjoiT25lIHRlc3RlZCBpbmNyZW1lbnRhbCBjb21taXQgZm9yIFAxODsgbm90ZSBvcGVuIGZvbGxvdy11cHMgaW4gYmFja2xvZy4iLCJpbnRlcnZpZXciOiJXaHkgaHVtYW4gYXBwcm92YWwgZm9yIHNpZGUgZWZmZWN0cz8iLCJleGl0Q3JpdGVyaWEiOiJFeHBsYWluIGNvZGUgY2hhbmdlIHNhZmV0eSBpbiAyIG1pbnV0ZXM7IDEgdGVzdGVkIGNvbW1pdDsgb25lIHNjZW5hcmlvIGFuc3dlcjsgMy81IGludGVydmlldyBwcmFjdGljZSBxdWVzdGlvbnMuIiwicGxhbm5lZEhvdXJzIjo2LCJyZWZlcmVuY2VVcmwiOiJodHRwczovL2RvY3MubGFuZ2NoYWluLmNvbS9vc3MvcHl0aG9uL2xhbmdncmFwaC9vdmVydmlldyIsInNjZW5hcmlvRm9ybWF0IjoiSW5wdXRzIOKGkiBjb25zdHJhaW50cyDihpIgZWRnZSBjYXNlcyDihpIgYWxnb3JpdGhtIOKGkiBjb21wbGV4aXR5IOKGkiB0ZXN0czsgY29kZSBhbmQgcmVmbGVjdCIsImludGVydmlld1N0cnVjdHVyZSI6IlVzZSBkZWZpbml0aW9uIOKGkiBleGFtcGxlIOKGkiB0cmFkZS1vZmYg4oaSIGNvbW1vbiBmYWlsdXJlIOKGkiBwcm9kdWN0aW9uIGltcGxpY2F0aW9uIn0seyJwbGFuSWQiOiJjaHJvbmlzLWFpLWVuZ2luZWVyaW5nLTIwMjYtMTEtMDUiLCJkYXlOdW1iZXIiOjYxLCJkYXRlIjoiMjAyNy0wMS0wNCIsIndlZWsiOjksInBoYXNlIjoiMDUgwrcgQWdlbnRzICYgSGFybmVzcyIsInBoYXNlTm8iOiIwNSIsInBoYXNlRGF5Ijo5LCJzdWJwaGFzZSI6Ik1lbW9yeSAmIGNoZWNrcG9pbnRzIiwiY29uY2VwdHMiOiJTZXNzaW9uIHN0YXRlLCBkdXJhYmxlIGNoZWNrcG9pbnRzLCBzdW1tYXJpemF0aW9uLCByZXBsYXkiLCJ0aGVvcnlEZWxpdmVyYWJsZSI6IlJlYWQgKyBkaWFncmFtICsgMyBmbGFzaGNhcmRzOyBpZGVudGlmeSAyIGZhaWx1cmUgbW9kZXMgaW4gbWVtb3J5ICYgY2hlY2twb2ludHMuIiwiYmFzaWNUYXNrIjoiU3RvcmUgYWdlbnQgc3RhdGUgaW4gc3FsaXRlL3Bvc3RncmVzIiwic2NlbmFyaW8iOiJMb25nLXJ1bm5pbmcgYWdlbnQgY3Jhc2hlcyBkdXJpbmcgdG9vbCBjYWxsIiwicHJvamVjdFdvcmtzdHJlYW0iOiJQNDAgwrcgQWdlbnQgTWVtb3J5ICYgQ2hlY2twb2ludCBTZXJ2aWNlIiwicHJvamVjdElkIjoiUDQwIiwicHJvamVjdFRhc2siOiJTVEFSVCBQNDAgQWdlbnQgTWVtb3J5ICYgQ2hlY2twb2ludCBTZXJ2aWNlOiBQZXJzaXN0IGNoZWNrcG9pbnRzLCByZXN1bWUgc2FmZSBydW5zLCBtYW5hZ2Ugc3VtbWFyaWVzLiBTaGlwIHNtYWxsZXN0IHZlcmlmaWFibGUgc2xpY2U7IGRvY3VtZW50IHRlc3RzLiIsInByb2plY3REZWxpdmVyYWJsZSI6IlA0MCBsYXVuY2g6IFJlY292ZXIgaW50ZXJydXB0ZWQgMy1zdGVwIHdvcmtmbG93IHdpdGhvdXQgZHVwbGljYXRlIGFjdGlvbiIsImludGVydmlldyI6IkNoZWNrcG9pbnQgdnMgY29udmVyc2F0aW9uYWwgbWVtb3J5PyIsImV4aXRDcml0ZXJpYSI6IkV4cGxhaW4gbWVtb3J5ICYgY2hlY2twb2ludHMgaW4gMiBtaW51dGVzOyAxIHRlc3RlZCBjb21taXQ7IG9uZSBzY2VuYXJpbyBhbnN3ZXI7IDMvNSBpbnRlcnZpZXcgcHJhY3RpY2UgcXVlc3Rpb25zLiIsInBsYW5uZWRIb3VycyI6NiwicmVmZXJlbmNlVXJsIjoiaHR0cHM6Ly9kb2NzLmxhbmdjaGFpbi5jb20vb3NzL3B5dGhvbi9sYW5nZ3JhcGgvb3ZlcnZpZXciLCJzY2VuYXJpb0Zvcm1hdCI6IklucHV0cyDihpIgY29uc3RyYWludHMg4oaSIGVkZ2UgY2FzZXMg4oaSIGFsZ29yaXRobSDihpIgY29tcGxleGl0eSDihpIgdGVzdHM7IGNvZGUgYW5kIHJlZmxlY3QiLCJpbnRlcnZpZXdTdHJ1Y3R1cmUiOiJVc2UgZGVmaW5pdGlvbiDihpIgZXhhbXBsZSDihpIgdHJhZGUtb2ZmIOKGkiBjb21tb24gZmFpbHVyZSDihpIgcHJvZHVjdGlvbiBpbXBsaWNhdGlvbiJ9LHsicGxhbklkIjoiY2hyb25pcy1haS1lbmdpbmVlcmluZy0yMDI2LTExLTA1IiwiZGF5TnVtYmVyIjo2MiwiZGF0ZSI6IjIwMjctMDEtMDUiLCJ3ZWVrIjo5LCJwaGFzZSI6IjA1IMK3IEFnZW50cyAmIEhhcm5lc3MiLCJwaGFzZU5vIjoiMDUiLCJwaGFzZURheSI6MTAsInN1YnBoYXNlIjoiU3VwcG9ydCB3b3JrZmxvd3MiLCJjb25jZXB0cyI6IkludGVudCwgcmV0cmlldmFsLCBjdXN0b21lciBwb2xpY3ksIHRpY2tldCB0b29scyIsInRoZW9yeURlbGl2ZXJhYmxlIjoiUmVhZCArIGRpYWdyYW0gKyAzIGZsYXNoY2FyZHM7IGlkZW50aWZ5IDIgZmFpbHVyZSBtb2RlcyBpbiBzdXBwb3J0IHdvcmtmbG93cy4iLCJiYXNpY1Rhc2siOiJCdWlsZCBzdXBwb3J0IGFnZW50IHdpdGggcmVhZC1vbmx5IHRpY2tldCBsb29rdXAiLCJzY2VuYXJpbyI6IkN1c3RvbWVyIGFza3MgcmVmdW5kIGJ1dCBhdXRob3JpemF0aW9uIGlzIG1pc3NpbmciLCJwcm9qZWN0V29ya3N0cmVhbSI6IlAxOSDCtyBFbnRlcnByaXNlIEFJIEN1c3RvbWVyIFN1cHBvcnQgQWdlbnQiLCJwcm9qZWN0SWQiOiJQMTkiLCJwcm9qZWN0VGFzayI6IlNUQVJUIFAxOSBFbnRlcnByaXNlIEFJIEN1c3RvbWVyIFN1cHBvcnQgQWdlbnQ6IEN1c3RvbWVyIGludGVudCBjbGFzc2lmaWNhdGlvbi47IE9yZGVyIGxvb2t1cCB0b29scy47IFJlZnVuZCBhbmQgdGlja2V0IHdvcmtmbG93cy4uIFNoaXAgc21hbGxlc3QgdmVyaWZpYWJsZSBzbGljZTsgZG9jdW1lbnQgdGVzdHMuIiwicHJvamVjdERlbGl2ZXJhYmxlIjoiUDE5IGxhdW5jaDogUnVubmFibGUgZGVtbzsgYXV0b21hdGVkIHRlc3RzOyBSRUFETUU7IGN1c3RvbWVyIGludGVudCBjbGFzc2lmaWNhdGlvbi4iLCJpbnRlcnZpZXciOiJXaGF0IHBhcnRzIG9mIHN1cHBvcnQgZmxvdyBtdXN0IGJlIGRldGVybWluaXN0aWM/IiwiZXhpdENyaXRlcmlhIjoiRXhwbGFpbiBzdXBwb3J0IHdvcmtmbG93cyBpbiAyIG1pbnV0ZXM7IDEgdGVzdGVkIGNvbW1pdDsgb25lIHNjZW5hcmlvIGFuc3dlcjsgMy81IGludGVydmlldyBwcmFjdGljZSBxdWVzdGlvbnMuIiwicGxhbm5lZEhvdXJzIjo2LCJyZWZlcmVuY2VVcmwiOiJodHRwczovL2RvY3MubGFuZ2NoYWluLmNvbS9vc3MvcHl0aG9uL2xhbmdncmFwaC9vdmVydmlldyIsInNjZW5hcmlvRm9ybWF0IjoiSW5wdXRzIOKGkiBjb25zdHJhaW50cyDihpIgZWRnZSBjYXNlcyDihpIgYWxnb3JpdGhtIOKGkiBjb21wbGV4aXR5IOKGkiB0ZXN0czsgY29kZSBhbmQgcmVmbGVjdCIsImludGVydmlld1N0cnVjdHVyZSI6IlVzZSBkZWZpbml0aW9uIOKGkiBleGFtcGxlIOKGkiB0cmFkZS1vZmYg4oaSIGNvbW1vbiBmYWlsdXJlIOKGkiBwcm9kdWN0aW9uIGltcGxpY2F0aW9uIn0seyJwbGFuSWQiOiJjaHJvbmlzLWFpLWVuZ2luZWVyaW5nLTIwMjYtMTEtMDUiLCJkYXlOdW1iZXIiOjYzLCJkYXRlIjoiMjAyNy0wMS0wNiIsIndlZWsiOjksInBoYXNlIjoiMDUgwrcgQWdlbnRzICYgSGFybmVzcyIsInBoYXNlTm8iOiIwNSIsInBoYXNlRGF5IjoxMSwic3VicGhhc2UiOiJIdW1hbi1pbi10aGUtbG9vcCIsImNvbmNlcHRzIjoiQXBwcm92YWwgZ2F0ZXMsIGFjdGlvbiBwcm9wb3NhbHMsIGF1ZGl0IGV2aWRlbmNlIiwidGhlb3J5RGVsaXZlcmFibGUiOiJSZWFkICsgZGlhZ3JhbSArIDMgZmxhc2hjYXJkczsgaWRlbnRpZnkgMiBmYWlsdXJlIG1vZGVzIGluIGh1bWFuLWluLXRoZS1sb29wLiIsImJhc2ljVGFzayI6IkJ1aWxkIGFwcHJvdmFsIHF1ZXVlIGZvciBzZW5zaXRpdmUgb3BlcmF0aW9ucyIsInNjZW5hcmlvIjoiU2ltdWxhdGUgcmVmdW5kIGFmdGVyIHR3by1wZXJzb24gYXBwcm92YWwiLCJwcm9qZWN0V29ya3N0cmVhbSI6IlAxOSDCtyBFbnRlcnByaXNlIEFJIEN1c3RvbWVyIFN1cHBvcnQgQWdlbnQiLCJwcm9qZWN0SWQiOiJQMTkiLCJwcm9qZWN0VGFzayI6IklURVJBVEUgUDE5IEVudGVycHJpc2UgQUkgQ3VzdG9tZXIgU3VwcG9ydCBBZ2VudDogYWRkIGVkZ2UtY2FzZSBoYW5kbGluZywgdGVzdCBmaXh0dXJlLCByZXN1bHQgbG9nIG9yIEFQSSBjb250cmFjdCBhbGlnbmVkIHRvIHRvZGF54oCZcyB0b3BpYy4iLCJwcm9qZWN0RGVsaXZlcmFibGUiOiJPbmUgdGVzdGVkIGluY3JlbWVudGFsIGNvbW1pdCBmb3IgUDE5OyBub3RlIG9wZW4gZm9sbG93LXVwcyBpbiBiYWNrbG9nLiIsImludGVydmlldyI6IkhvdyBpbXBsZW1lbnQgcGF1c2UvcmVzdW1lIHNhZmVseT8iLCJleGl0Q3JpdGVyaWEiOiJFeHBsYWluIGh1bWFuLWluLXRoZS1sb29wIGluIDIgbWludXRlczsgMSB0ZXN0ZWQgY29tbWl0OyBvbmUgc2NlbmFyaW8gYW5zd2VyOyAzLzUgaW50ZXJ2aWV3IHByYWN0aWNlIHF1ZXN0aW9ucy4iLCJwbGFubmVkSG91cnMiOjYsInJlZmVyZW5jZVVybCI6Imh0dHBzOi8vZG9jcy5sYW5nY2hhaW4uY29tL29zcy9weXRob24vbGFuZ2dyYXBoL292ZXJ2aWV3Iiwic2NlbmFyaW9Gb3JtYXQiOiJJbnB1dHMg4oaSIGNvbnN0cmFpbnRzIOKGkiBlZGdlIGNhc2VzIOKGkiBhbGdvcml0aG0g4oaSIGNvbXBsZXhpdHkg4oaSIHRlc3RzOyBjb2RlIGFuZCByZWZsZWN0IiwiaW50ZXJ2aWV3U3RydWN0dXJlIjoiVXNlIGRlZmluaXRpb24g4oaSIGV4YW1wbGUg4oaSIHRyYWRlLW9mZiDihpIgY29tbW9uIGZhaWx1cmUg4oaSIHByb2R1Y3Rpb24gaW1wbGljYXRpb24ifSx7InBsYW5JZCI6ImNocm9uaXMtYWktZW5naW5lZXJpbmctMjAyNi0xMS0wNSIsImRheU51bWJlciI6NjQsImRhdGUiOiIyMDI3LTAxLTA3Iiwid2VlayI6MTAsInBoYXNlIjoiMDUgwrcgQWdlbnRzICYgSGFybmVzcyIsInBoYXNlTm8iOiIwNSIsInBoYXNlRGF5IjoxMiwic3VicGhhc2UiOiJJbmNpZGVudCByZXNwb25zZSBhZ2VudCIsImNvbmNlcHRzIjoiSW5jaWRlbnQgY2xhc3NpZmljYXRpb24sIHJ1bmJvb2sgc2VsZWN0aW9uLCBlc2NhbGF0aW9uIiwidGhlb3J5RGVsaXZlcmFibGUiOiJSZWFkICsgZGlhZ3JhbSArIDMgZmxhc2hjYXJkczsgaWRlbnRpZnkgMiBmYWlsdXJlIG1vZGVzIGluIGluY2lkZW50IHJlc3BvbnNlIGFnZW50LiIsImJhc2ljVGFzayI6IkJ1aWxkIGluY2lkZW50LXRyaWFnZSBhZ2VudCB1c2luZyBzeW50aGV0aWMgYWxlcnRzIiwic2NlbmFyaW8iOiJBbWJpZ3VvdXMgc2V2ZXJpdHkgcmVxdWlyZXMgaHVtYW4gZXNjYWxhdGlvbiIsInByb2plY3RXb3Jrc3RyZWFtIjoiUDQxIMK3IEFJIEluY2lkZW50IFRyaWFnZSBDb3BpbG90IiwicHJvamVjdElkIjoiUDQxIiwicHJvamVjdFRhc2siOiJTVEFSVCBQNDEgQUkgSW5jaWRlbnQgVHJpYWdlIENvcGlsb3Q6IENsYXNzaWZ5IGluY2lkZW50cyBhbmQgcHJvcG9zZSBydW5ib29rIGFjdGlvbi4gU2hpcCBzbWFsbGVzdCB2ZXJpZmlhYmxlIHNsaWNlOyBkb2N1bWVudCB0ZXN0cy4iLCJwcm9qZWN0RGVsaXZlcmFibGUiOiJQNDEgbGF1bmNoOiBQcm9kdWNlcyBjaXRlZCBzZXZlcml0eSByYXRpb25hbGUsIHJlcXVlc3RzIGVzY2FsYXRpb24iLCJpbnRlcnZpZXciOiJIb3cgYXZvaWQgYXV0b25vbW91cyBkZXN0cnVjdGl2ZSByZW1lZGlhdGlvbj8iLCJleGl0Q3JpdGVyaWEiOiJFeHBsYWluIGluY2lkZW50IHJlc3BvbnNlIGFnZW50IGluIDIgbWludXRlczsgMSB0ZXN0ZWQgY29tbWl0OyBvbmUgc2NlbmFyaW8gYW5zd2VyOyAzLzUgaW50ZXJ2aWV3IHByYWN0aWNlIHF1ZXN0aW9ucy4iLCJwbGFubmVkSG91cnMiOjYsInJlZmVyZW5jZVVybCI6Imh0dHBzOi8vZG9jcy5sYW5nY2hhaW4uY29tL29zcy9weXRob24vbGFuZ2dyYXBoL292ZXJ2aWV3Iiwic2NlbmFyaW9Gb3JtYXQiOiJJbnB1dHMg4oaSIGNvbnN0cmFpbnRzIOKGkiBlZGdlIGNhc2VzIOKGkiBhbGdvcml0aG0g4oaSIGNvbXBsZXhpdHkg4oaSIHRlc3RzOyBjb2RlIGFuZCByZWZsZWN0IiwiaW50ZXJ2aWV3U3RydWN0dXJlIjoiVXNlIGRlZmluaXRpb24g4oaSIGV4YW1wbGUg4oaSIHRyYWRlLW9mZiDihpIgY29tbW9uIGZhaWx1cmUg4oaSIHByb2R1Y3Rpb24gaW1wbGljYXRpb24ifSx7InBsYW5JZCI6ImNocm9uaXMtYWktZW5naW5lZXJpbmctMjAyNi0xMS0wNSIsImRheU51bWJlciI6NjUsImRhdGUiOiIyMDI3LTAxLTA4Iiwid2VlayI6MTAsInBoYXNlIjoiMDUgwrcgQWdlbnRzICYgSGFybmVzcyIsInBoYXNlTm8iOiIwNSIsInBoYXNlRGF5IjoxMywic3VicGhhc2UiOiJDb2RpbmcgYWdlbnQgbGlmZWN5Y2xlIiwiY29uY2VwdHMiOiJJc3N1ZSDihpIgcGxhbiDihpIgY29kZSDihpIgdGVzdCDihpIgZGlmZiDihpIgcmV2aWV3IiwidGhlb3J5RGVsaXZlcmFibGUiOiJSZWFkICsgZGlhZ3JhbSArIDMgZmxhc2hjYXJkczsgaWRlbnRpZnkgMiBmYWlsdXJlIG1vZGVzIGluIGNvZGluZyBhZ2VudCBsaWZlY3ljbGUuIiwiYmFzaWNUYXNrIjoiQnVpbGQgbWluaW1hbCBwYXRjaC1hbmQtdGVzdCBhZ2VudCIsInNjZW5hcmlvIjoiVGVzdHMgZmFpbDsgYWdlbnQgdHJpZXMgc2FtZSBwYXRjaCByZXBlYXRlZGx5IiwicHJvamVjdFdvcmtzdHJlYW0iOiJQMjAgwrcgQUkgU29mdHdhcmUgRGV2ZWxvcG1lbnQgQWdlbnQiLCJwcm9qZWN0SWQiOiJQMjAiLCJwcm9qZWN0VGFzayI6IlNUQVJUIFAyMCBBSSBTb2Z0d2FyZSBEZXZlbG9wbWVudCBBZ2VudDogQ29udmVydCByZXF1aXJlbWVudHMgaW50byB0YXNrcy47IEdlbmVyYXRlIGltcGxlbWVudGF0aW9uIHBsYW5zLjsgSW5zcGVjdCBjb2RlYmFzZXMuLiBTaGlwIHNtYWxsZXN0IHZlcmlmaWFibGUgc2xpY2U7IGRvY3VtZW50IHRlc3RzLiIsInByb2plY3REZWxpdmVyYWJsZSI6IlAyMCBsYXVuY2g6IFJ1bm5hYmxlIGRlbW87IGF1dG9tYXRlZCB0ZXN0czsgUkVBRE1FOyBjb252ZXJ0IHJlcXVpcmVtZW50cyBpbnRvIHRhc2tzLiIsImludGVydmlldyI6IkhvdyBib3VuZCBpdGVyYXRpb25zIGluIGNvZGluZyBhZ2VudHM/IiwiZXhpdENyaXRlcmlhIjoiRXhwbGFpbiBjb2RpbmcgYWdlbnQgbGlmZWN5Y2xlIGluIDIgbWludXRlczsgMSB0ZXN0ZWQgY29tbWl0OyBvbmUgc2NlbmFyaW8gYW5zd2VyOyAzLzUgaW50ZXJ2aWV3IHByYWN0aWNlIHF1ZXN0aW9ucy4iLCJwbGFubmVkSG91cnMiOjYsInJlZmVyZW5jZVVybCI6Imh0dHBzOi8vZG9jcy5sYW5nY2hhaW4uY29tL29zcy9weXRob24vbGFuZ2dyYXBoL292ZXJ2aWV3Iiwic2NlbmFyaW9Gb3JtYXQiOiJJbnB1dHMg4oaSIGNvbnN0cmFpbnRzIOKGkiBlZGdlIGNhc2VzIOKGkiBhbGdvcml0aG0g4oaSIGNvbXBsZXhpdHkg4oaSIHRlc3RzOyBjb2RlIGFuZCByZWZsZWN0IiwiaW50ZXJ2aWV3U3RydWN0dXJlIjoiVXNlIGRlZmluaXRpb24g4oaSIGV4YW1wbGUg4oaSIHRyYWRlLW9mZiDihpIgY29tbW9uIGZhaWx1cmUg4oaSIHByb2R1Y3Rpb24gaW1wbGljYXRpb24ifSx7InBsYW5JZCI6ImNocm9uaXMtYWktZW5naW5lZXJpbmctMjAyNi0xMS0wNSIsImRheU51bWJlciI6NjYsImRhdGUiOiIyMDI3LTAxLTA5Iiwid2VlayI6MTAsInBoYXNlIjoiMDUgwrcgQWdlbnRzICYgSGFybmVzcyIsInBoYXNlTm8iOiIwNSIsInBoYXNlRGF5IjoxNCwic3VicGhhc2UiOiJBZ2VudCB0ZXN0IGhhcm5lc3MiLCJjb25jZXB0cyI6Ik1vY2sgdG9vbHMsIGRldGVybWluaXN0aWMgdHJhY2VzLCByZWdyZXNzaW9uIHNjZW5hcmlvcyIsInRoZW9yeURlbGl2ZXJhYmxlIjoiUmVhZCArIGRpYWdyYW0gKyAzIGZsYXNoY2FyZHM7IGlkZW50aWZ5IDIgZmFpbHVyZSBtb2RlcyBpbiBhZ2VudCB0ZXN0IGhhcm5lc3MuIiwiYmFzaWNUYXNrIjoiRXZhbHVhdGUgY29kaW5nIGFnZW50IG9uIDEwIGNhbm5lZCBidWcgdGFza3MiLCJzY2VuYXJpbyI6IlJlZ3Jlc3Npb24gb2NjdXJzIG9ubHkgYWZ0ZXIgdG9vbCB0aW1lb3V0IiwicHJvamVjdFdvcmtzdHJlYW0iOiJQMjAgwrcgQUkgU29mdHdhcmUgRGV2ZWxvcG1lbnQgQWdlbnQiLCJwcm9qZWN0SWQiOiJQMjAiLCJwcm9qZWN0VGFzayI6IklURVJBVEUgUDIwIEFJIFNvZnR3YXJlIERldmVsb3BtZW50IEFnZW50OiBhZGQgZWRnZS1jYXNlIGhhbmRsaW5nLCB0ZXN0IGZpeHR1cmUsIHJlc3VsdCBsb2cgb3IgQVBJIGNvbnRyYWN0IGFsaWduZWQgdG8gdG9kYXnigJlzIHRvcGljLiIsInByb2plY3REZWxpdmVyYWJsZSI6Ik9uZSB0ZXN0ZWQgaW5jcmVtZW50YWwgY29tbWl0IGZvciBQMjA7IG5vdGUgb3BlbiBmb2xsb3ctdXBzIGluIGJhY2tsb2cuIiwiaW50ZXJ2aWV3IjoiV2hhdCBpcyBhIHJlbGlhYmxlIGFnZW50IGJlbmNobWFyaz8iLCJleGl0Q3JpdGVyaWEiOiJFeHBsYWluIGFnZW50IHRlc3QgaGFybmVzcyBpbiAyIG1pbnV0ZXM7IDEgdGVzdGVkIGNvbW1pdDsgb25lIHNjZW5hcmlvIGFuc3dlcjsgMy81IGludGVydmlldyBwcmFjdGljZSBxdWVzdGlvbnMuIiwicGxhbm5lZEhvdXJzIjo2LCJyZWZlcmVuY2VVcmwiOiJodHRwczovL2RvY3MubGFuZ2NoYWluLmNvbS9vc3MvcHl0aG9uL2xhbmdncmFwaC9vdmVydmlldyIsInNjZW5hcmlvRm9ybWF0IjoiSW5wdXRzIOKGkiBjb25zdHJhaW50cyDihpIgZWRnZSBjYXNlcyDihpIgYWxnb3JpdGhtIOKGkiBjb21wbGV4aXR5IOKGkiB0ZXN0czsgY29kZSBhbmQgcmVmbGVjdCIsImludGVydmlld1N0cnVjdHVyZSI6IlVzZSBkZWZpbml0aW9uIOKGkiBleGFtcGxlIOKGkiB0cmFkZS1vZmYg4oaSIGNvbW1vbiBmYWlsdXJlIOKGkiBwcm9kdWN0aW9uIGltcGxpY2F0aW9uIn0seyJwbGFuSWQiOiJjaHJvbmlzLWFpLWVuZ2luZWVyaW5nLTIwMjYtMTEtMDUiLCJkYXlOdW1iZXIiOjY3LCJkYXRlIjoiMjAyNy0wMS0xMCIsIndlZWsiOjEwLCJwaGFzZSI6IjA1IMK3IEFnZW50cyAmIEhhcm5lc3MiLCJwaGFzZU5vIjoiMDUiLCJwaGFzZURheSI6MTUsInN1YnBoYXNlIjoiQ29uY3VycmVuY3kgJiBmYWlsdXJlIiwiY29uY2VwdHMiOiJQYXJhbGxlbCBhZ2VudHMsIGlkZW1wb3RlbmN5LCByZXRyaWVzLCByYWNlIGNvbmRpdGlvbnMiLCJ0aGVvcnlEZWxpdmVyYWJsZSI6IlJlYWQgKyBkaWFncmFtICsgMyBmbGFzaGNhcmRzOyBpZGVudGlmeSAyIGZhaWx1cmUgbW9kZXMgaW4gY29uY3VycmVuY3kgJiBmYWlsdXJlLiIsImJhc2ljVGFzayI6IlJ1biBjb21wZXRpbmcgYWdlbnRzIHdpdGggc3RhdGUgdmVyc2lvbiBjaGVja3MiLCJzY2VuYXJpbyI6IlR3byBhZ2VudHMgdXBkYXRlIHNhbWUgcmVjb3JkIHNpbXVsdGFuZW91c2x5IiwicHJvamVjdFdvcmtzdHJlYW0iOiJQMjAgwrcgQUkgU29mdHdhcmUgRGV2ZWxvcG1lbnQgQWdlbnQiLCJwcm9qZWN0SWQiOiJQMjAiLCJwcm9qZWN0VGFzayI6IklURVJBVEUgUDIwIEFJIFNvZnR3YXJlIERldmVsb3BtZW50IEFnZW50OiBhZGQgZWRnZS1jYXNlIGhhbmRsaW5nLCB0ZXN0IGZpeHR1cmUsIHJlc3VsdCBsb2cgb3IgQVBJIGNvbnRyYWN0IGFsaWduZWQgdG8gdG9kYXnigJlzIHRvcGljLiIsInByb2plY3REZWxpdmVyYWJsZSI6Ik9uZSB0ZXN0ZWQgaW5jcmVtZW50YWwgY29tbWl0IGZvciBQMjA7IG5vdGUgb3BlbiBmb2xsb3ctdXBzIGluIGJhY2tsb2cuIiwiaW50ZXJ2aWV3IjoiSG93IGRvIHlvdSByZXNvbHZlIHJhY2UgY29uZGl0aW9ucyBpbiBvcmNoZXN0cmF0aW9uPyIsImV4aXRDcml0ZXJpYSI6IkV4cGxhaW4gY29uY3VycmVuY3kgJiBmYWlsdXJlIGluIDIgbWludXRlczsgMSB0ZXN0ZWQgY29tbWl0OyBvbmUgc2NlbmFyaW8gYW5zd2VyOyAzLzUgaW50ZXJ2aWV3IHByYWN0aWNlIHF1ZXN0aW9ucy4iLCJwbGFubmVkSG91cnMiOjYsInJlZmVyZW5jZVVybCI6Imh0dHBzOi8vZG9jcy5sYW5nY2hhaW4uY29tL29zcy9weXRob24vbGFuZ2dyYXBoL292ZXJ2aWV3Iiwic2NlbmFyaW9Gb3JtYXQiOiJJbnB1dHMg4oaSIGNvbnN0cmFpbnRzIOKGkiBlZGdlIGNhc2VzIOKGkiBhbGdvcml0aG0g4oaSIGNvbXBsZXhpdHkg4oaSIHRlc3RzOyBjb2RlIGFuZCByZWZsZWN0IiwiaW50ZXJ2aWV3U3RydWN0dXJlIjoiVXNlIGRlZmluaXRpb24g4oaSIGV4YW1wbGUg4oaSIHRyYWRlLW9mZiDihpIgY29tbW9uIGZhaWx1cmUg4oaSIHByb2R1Y3Rpb24gaW1wbGljYXRpb24ifSx7InBsYW5JZCI6ImNocm9uaXMtYWktZW5naW5lZXJpbmctMjAyNi0xMS0wNSIsImRheU51bWJlciI6NjgsImRhdGUiOiIyMDI3LTAxLTExIiwid2VlayI6MTAsInBoYXNlIjoiMDUgwrcgQWdlbnRzICYgSGFybmVzcyIsInBoYXNlTm8iOiIwNSIsInBoYXNlRGF5IjoxNiwic3VicGhhc2UiOiJPcmNoZXN0cmF0aW9uIHNjaGVkdWxlciIsImNvbmNlcHRzIjoiVGltZXJzLCBldmVudCB0cmlnZ2Vycywgd29ya2Zsb3cgcnVucywgam9iIG93bmVyc2hpcCIsInRoZW9yeURlbGl2ZXJhYmxlIjoiUmVhZCArIGRpYWdyYW0gKyAzIGZsYXNoY2FyZHM7IGlkZW50aWZ5IDIgZmFpbHVyZSBtb2RlcyBpbiBvcmNoZXN0cmF0aW9uIHNjaGVkdWxlci4iLCJiYXNpY1Rhc2siOiJJbXBsZW1lbnQgc2NoZWR1bGVkIGFnZW50IHJ1biB3aXRoIGV4ZWN1dGlvbiBsZWRnZXIiLCJzY2VuYXJpbyI6IlNhbWUgc2NoZWR1bGVkIGpvYiBmaXJlcyB0d2ljZSB1bmRlciByZXRyaWVzIiwicHJvamVjdFdvcmtzdHJlYW0iOiJQNDIgwrcgQWdlbnQgSGFybmVzcyBCZW5jaG1hcmsgJiBFdmFsIFN1aXRlIiwicHJvamVjdElkIjoiUDQyIiwicHJvamVjdFRhc2siOiJTVEFSVCBQNDIgQWdlbnQgSGFybmVzcyBCZW5jaG1hcmsgJiBFdmFsIFN1aXRlOiBUcmFjayB0b29sIGNhbGwgYWNjdXJhY3ksIHNhZmV0eSwgbGF0ZW5jeSBhbmQgY29zdC4gU2hpcCBzbWFsbGVzdCB2ZXJpZmlhYmxlIHNsaWNlOyBkb2N1bWVudCB0ZXN0cy4iLCJwcm9qZWN0RGVsaXZlcmFibGUiOiJQNDIgbGF1bmNoOiBSdW5zIDEwIHNlZWRlZCBzY2VuYXJpb3Mgd2l0aCByZXBvcnQgYW5kIENJIGdhdGUiLCJpbnRlcnZpZXciOiJIb3cgZW5mb3JjZSBleGFjdGx5LW9uY2UgZWZmZWN0IHdpdGggYXQtbGVhc3Qtb25jZSBkZWxpdmVyeT8iLCJleGl0Q3JpdGVyaWEiOiJFeHBsYWluIG9yY2hlc3RyYXRpb24gc2NoZWR1bGVyIGluIDIgbWludXRlczsgMSB0ZXN0ZWQgY29tbWl0OyBvbmUgc2NlbmFyaW8gYW5zd2VyOyAzLzUgaW50ZXJ2aWV3IHByYWN0aWNlIHF1ZXN0aW9ucy4iLCJwbGFubmVkSG91cnMiOjYsInJlZmVyZW5jZVVybCI6Imh0dHBzOi8vZG9jcy5sYW5nY2hhaW4uY29tL29zcy9weXRob24vbGFuZ2dyYXBoL292ZXJ2aWV3Iiwic2NlbmFyaW9Gb3JtYXQiOiJJbnB1dHMg4oaSIGNvbnN0cmFpbnRzIOKGkiBlZGdlIGNhc2VzIOKGkiBhbGdvcml0aG0g4oaSIGNvbXBsZXhpdHkg4oaSIHRlc3RzOyBjb2RlIGFuZCByZWZsZWN0IiwiaW50ZXJ2aWV3U3RydWN0dXJlIjoiVXNlIGRlZmluaXRpb24g4oaSIGV4YW1wbGUg4oaSIHRyYWRlLW9mZiDihpIgY29tbW9uIGZhaWx1cmUg4oaSIHByb2R1Y3Rpb24gaW1wbGljYXRpb24ifSx7InBsYW5JZCI6ImNocm9uaXMtYWktZW5naW5lZXJpbmctMjAyNi0xMS0wNSIsImRheU51bWJlciI6NjksImRhdGUiOiIyMDI3LTAxLTEyIiwid2VlayI6MTAsInBoYXNlIjoiMDUgwrcgQWdlbnRzICYgSGFybmVzcyIsInBoYXNlTm8iOiIwNSIsInBoYXNlRGF5IjoxNywic3VicGhhc2UiOiJNdWx0aS1hZ2VudCBjaGVja3BvaW50IiwiY29uY2VwdHMiOiJUcmFjZSByZXZpZXcsIGV2YWxzLCBwb2xpY3kgY2hlY2ssIGRlbW8iLCJ0aGVvcnlEZWxpdmVyYWJsZSI6IlJlYWQgKyBkaWFncmFtICsgMyBmbGFzaGNhcmRzOyBpZGVudGlmeSAyIGZhaWx1cmUgbW9kZXMgaW4gbXVsdGktYWdlbnQgY2hlY2twb2ludC4iLCJiYXNpY1Rhc2siOiJTaGlwIG11bHRpLWFnZW50IHRyYWNlIHdpdGggc2FmZSBhcHByb3ZhbCBkZW1vIiwic2NlbmFyaW8iOiJBZ2VudCBleGl0cyB3aXRoIGluY29tcGxldGUgcmVxdWlyZWQgd29yayIsInByb2plY3RXb3Jrc3RyZWFtIjoiUDQyIMK3IEFnZW50IEhhcm5lc3MgQmVuY2htYXJrICYgRXZhbCBTdWl0ZSIsInByb2plY3RJZCI6IlA0MiIsInByb2plY3RUYXNrIjoiSVRFUkFURSBQNDIgQWdlbnQgSGFybmVzcyBCZW5jaG1hcmsgJiBFdmFsIFN1aXRlOiBhZGQgZWRnZS1jYXNlIGhhbmRsaW5nLCB0ZXN0IGZpeHR1cmUsIHJlc3VsdCBsb2cgb3IgQVBJIGNvbnRyYWN0IGFsaWduZWQgdG8gdG9kYXnigJlzIHRvcGljLiIsInByb2plY3REZWxpdmVyYWJsZSI6Ik9uZSB0ZXN0ZWQgaW5jcmVtZW50YWwgY29tbWl0IGZvciBQNDI7IG5vdGUgb3BlbiBmb2xsb3ctdXBzIGluIGJhY2tsb2cuIiwiaW50ZXJ2aWV3IjoiV2hhdCBtYWtlcyBhbiBhZ2VudCBoYXJuZXNzIHByb2R1Y3Rpb24tcmVhZHk/IiwiZXhpdENyaXRlcmlhIjoiRXhwbGFpbiBtdWx0aS1hZ2VudCBjaGVja3BvaW50IGluIDIgbWludXRlczsgMSB0ZXN0ZWQgY29tbWl0OyBvbmUgc2NlbmFyaW8gYW5zd2VyOyAzLzUgaW50ZXJ2aWV3IHByYWN0aWNlIHF1ZXN0aW9ucy4iLCJwbGFubmVkSG91cnMiOjYsInJlZmVyZW5jZVVybCI6Imh0dHBzOi8vZG9jcy5sYW5nY2hhaW4uY29tL29zcy9weXRob24vbGFuZ2dyYXBoL292ZXJ2aWV3Iiwic2NlbmFyaW9Gb3JtYXQiOiJJbnB1dHMg4oaSIGNvbnN0cmFpbnRzIOKGkiBlZGdlIGNhc2VzIOKGkiBhbGdvcml0aG0g4oaSIGNvbXBsZXhpdHkg4oaSIHRlc3RzOyBjb2RlIGFuZCByZWZsZWN0IiwiaW50ZXJ2aWV3U3RydWN0dXJlIjoiVXNlIGRlZmluaXRpb24g4oaSIGV4YW1wbGUg4oaSIHRyYWRlLW9mZiDihpIgY29tbW9uIGZhaWx1cmUg4oaSIHByb2R1Y3Rpb24gaW1wbGljYXRpb24ifSx7InBsYW5JZCI6ImNocm9uaXMtYWktZW5naW5lZXJpbmctMjAyNi0xMS0wNSIsImRheU51bWJlciI6NzAsImRhdGUiOiIyMDI3LTAxLTEzIiwid2VlayI6MTAsInBoYXNlIjoiMDYgwrcgUHJvZHVjdGlvbiAmIExMTU9wcyIsInBoYXNlTm8iOiIwNiIsInBoYXNlRGF5IjoxLCJzdWJwaGFzZSI6IlRlbmFudCBpc29sYXRpb24iLCJjb25jZXB0cyI6IlJCQUMsIG9yZyBib3VuZGFyaWVzLCBKV1QsIHJvdy1sZXZlbCBzZWN1cml0eSIsInRoZW9yeURlbGl2ZXJhYmxlIjoiUmVhZCArIGRpYWdyYW0gKyAzIGZsYXNoY2FyZHM7IGlkZW50aWZ5IDIgZmFpbHVyZSBtb2RlcyBpbiB0ZW5hbnQgaXNvbGF0aW9uLiIsImJhc2ljVGFzayI6IkJ1aWxkIHRlbmFudC1hd2FyZSBwb2xpY3kgZmV0Y2ggQVBJIiwic2NlbmFyaW8iOiJDcm9zcy10ZW5hbnQgcXVlcnkgYnlwYXNzZXMgVUkgZmlsdGVyIiwicHJvamVjdFdvcmtzdHJlYW0iOiJQMjEgwrcgTXVsdGktVGVuYW50IEFJIFNhYVMgUGxhdGZvcm0iLCJwcm9qZWN0SWQiOiJQMjEiLCJwcm9qZWN0VGFzayI6IlNUQVJUIFAyMSBNdWx0aS1UZW5hbnQgQUkgU2FhUyBQbGF0Zm9ybTogTXVsdGlwbGUgb3JnYW5pemF0aW9ucyBhbmQgaXNvbGF0ZWQgZGF0YS47IFRlbmFudC1hd2FyZSBSQUcuOyBSQkFDIGFuZCBhdXRoZW50aWNhdGlvbi4uIFNoaXAgc21hbGxlc3QgdmVyaWZpYWJsZSBzbGljZTsgZG9jdW1lbnQgdGVzdHMuIiwicHJvamVjdERlbGl2ZXJhYmxlIjoiUDIxIGxhdW5jaDogUnVubmFibGUgZGVtbzsgYXV0b21hdGVkIHRlc3RzOyBSRUFETUU7IG11bHRpcGxlIG9yZ2FuaXphdGlvbnMgYW5kIGlzb2xhdGVkIGRhdGEuIiwiaW50ZXJ2aWV3IjoiSG93IHRlc3QgdGVuYW50IGlzb2xhdGlvbiBhdCBEQiBib3VuZGFyeT8iLCJleGl0Q3JpdGVyaWEiOiJFeHBsYWluIHRlbmFudCBpc29sYXRpb24gaW4gMiBtaW51dGVzOyAxIHRlc3RlZCBjb21taXQ7IG9uZSBzY2VuYXJpbyBhbnN3ZXI7IDMvNSBpbnRlcnZpZXcgcHJhY3RpY2UgcXVlc3Rpb25zLiIsInBsYW5uZWRIb3VycyI6NiwicmVmZXJlbmNlVXJsIjoiaHR0cHM6Ly9kb2NzLmRvY2tlci5jb20vZ2V0LXN0YXJ0ZWQvIiwic2NlbmFyaW9Gb3JtYXQiOiJJbnB1dHMg4oaSIGNvbnN0cmFpbnRzIOKGkiBlZGdlIGNhc2VzIOKGkiBhbGdvcml0aG0g4oaSIGNvbXBsZXhpdHkg4oaSIHRlc3RzOyBjb2RlIGFuZCByZWZsZWN0IiwiaW50ZXJ2aWV3U3RydWN0dXJlIjoiVXNlIGRlZmluaXRpb24g4oaSIGV4YW1wbGUg4oaSIHRyYWRlLW9mZiDihpIgY29tbW9uIGZhaWx1cmUg4oaSIHByb2R1Y3Rpb24gaW1wbGljYXRpb24ifSx7InBsYW5JZCI6ImNocm9uaXMtYWktZW5naW5lZXJpbmctMjAyNi0xMS0wNSIsImRheU51bWJlciI6NzEsImRhdGUiOiIyMDI3LTAxLTE0Iiwid2VlayI6MTEsInBoYXNlIjoiMDYgwrcgUHJvZHVjdGlvbiAmIExMTU9wcyIsInBoYXNlTm8iOiIwNiIsInBoYXNlRGF5IjoyLCJzdWJwaGFzZSI6IlBJSSAmIGNvbXBsaWFuY2UiLCJjb25jZXB0cyI6IlBJSSBkZXRlY3Rpb24sIG1hc2tpbmcsIHJldGVudGlvbiwgc2VjcmV0IG1hbmFnZW1lbnQiLCJ0aGVvcnlEZWxpdmVyYWJsZSI6IlJlYWQgKyBkaWFncmFtICsgMyBmbGFzaGNhcmRzOyBpZGVudGlmeSAyIGZhaWx1cmUgbW9kZXMgaW4gcGlpICYgY29tcGxpYW5jZS4iLCJiYXNpY1Rhc2siOiJXcml0ZSBQSUkgcmVkYWN0aW9uIG1pZGRsZXdhcmUiLCJzY2VuYXJpbyI6IkxvZ3MgbGVhayBhbiBhY2Nlc3MgdG9rZW4gYWZ0ZXIgZXhjZXB0aW9uIiwicHJvamVjdFdvcmtzdHJlYW0iOiJQNDMgwrcgUElJIFJlZGFjdGlvbiAmIFNhZmV0eSBHYXRld2F5IiwicHJvamVjdElkIjoiUDQzIiwicHJvamVjdFRhc2siOiJTVEFSVCBQNDMgUElJIFJlZGFjdGlvbiAmIFNhZmV0eSBHYXRld2F5OiBNYXNrIHNlbnNpdGl2ZSBkYXRhIGJlZm9yZSBtb2RlbCBjYWxscyBhbmQgbG9ncy4gU2hpcCBzbWFsbGVzdCB2ZXJpZmlhYmxlIHNsaWNlOyBkb2N1bWVudCB0ZXN0cy4iLCJwcm9qZWN0RGVsaXZlcmFibGUiOiJQNDMgbGF1bmNoOiBUZXN0IFBJSSBsZWFrYWdlIGNhc2VzIGFjcm9zcyByZXF1ZXN0IGFuZCB0cmFjZSIsImludGVydmlldyI6IldoYXQgZGF0YSBtdXN0IG5ldmVyIGVudGVyIHRyYWNlIGxvZ3M/IiwiZXhpdENyaXRlcmlhIjoiRXhwbGFpbiBwaWkgJiBjb21wbGlhbmNlIGluIDIgbWludXRlczsgMSB0ZXN0ZWQgY29tbWl0OyBvbmUgc2NlbmFyaW8gYW5zd2VyOyAzLzUgaW50ZXJ2aWV3IHByYWN0aWNlIHF1ZXN0aW9ucy4iLCJwbGFubmVkSG91cnMiOjYsInJlZmVyZW5jZVVybCI6Imh0dHBzOi8vZG9jcy5kb2NrZXIuY29tL2dldC1zdGFydGVkLyIsInNjZW5hcmlvRm9ybWF0IjoiSW5wdXRzIOKGkiBjb25zdHJhaW50cyDihpIgZWRnZSBjYXNlcyDihpIgYWxnb3JpdGhtIOKGkiBjb21wbGV4aXR5IOKGkiB0ZXN0czsgY29kZSBhbmQgcmVmbGVjdCIsImludGVydmlld1N0cnVjdHVyZSI6IlVzZSBkZWZpbml0aW9uIOKGkiBleGFtcGxlIOKGkiB0cmFkZS1vZmYg4oaSIGNvbW1vbiBmYWlsdXJlIOKGkiBwcm9kdWN0aW9uIGltcGxpY2F0aW9uIn0seyJwbGFuSWQiOiJjaHJvbmlzLWFpLWVuZ2luZWVyaW5nLTIwMjYtMTEtMDUiLCJkYXlOdW1iZXIiOjcyLCJkYXRlIjoiMjAyNy0wMS0xNSIsIndlZWsiOjExLCJwaGFzZSI6IjA2IMK3IFByb2R1Y3Rpb24gJiBMTE1PcHMiLCJwaGFzZU5vIjoiMDYiLCJwaGFzZURheSI6Mywic3VicGhhc2UiOiJBc3luYyBpbmdlc3Rpb24iLCJjb25jZXB0cyI6IkNlbGVyeS9xdWV1ZXMsIHJldHJpZXMsIERMUSwgb2JqZWN0IHN0b3JhZ2UiLCJ0aGVvcnlEZWxpdmVyYWJsZSI6IlJlYWQgKyBkaWFncmFtICsgMyBmbGFzaGNhcmRzOyBpZGVudGlmeSAyIGZhaWx1cmUgbW9kZXMgaW4gYXN5bmMgaW5nZXN0aW9uLiIsImJhc2ljVGFzayI6IlF1ZXVlIGxhcmdlIFBERiBlbWJlZGRpbmcgam9icyIsInNjZW5hcmlvIjoiV29ya2VyIGNyYXNoZXMgYWZ0ZXIgc2F2aW5nIGhhbGYgb2YgYSBkb2N1bWVudCIsInByb2plY3RXb3Jrc3RyZWFtIjoiUDIyIMK3IExhcmdlLVNjYWxlIERvY3VtZW50IEludGVsbGlnZW5jZSBQbGF0Zm9ybSIsInByb2plY3RJZCI6IlAyMiIsInByb2plY3RUYXNrIjoiU1RBUlQgUDIyIExhcmdlLVNjYWxlIERvY3VtZW50IEludGVsbGlnZW5jZSBQbGF0Zm9ybTogQnVsayBQREYvRE9DWCBpbmdlc3Rpb24uOyBEaXN0cmlidXRlZCBkb2N1bWVudCBwcm9jZXNzaW5nLjsgUXVldWUtYmFzZWQgZW1iZWRkaW5nIGdlbmVyYXRpb24uLiBTaGlwIHNtYWxsZXN0IHZlcmlmaWFibGUgc2xpY2U7IGRvY3VtZW50IHRlc3RzLiIsInByb2plY3REZWxpdmVyYWJsZSI6IlAyMiBsYXVuY2g6IFJ1bm5hYmxlIGRlbW87IGF1dG9tYXRlZCB0ZXN0czsgUkVBRE1FOyBidWxrIHBkZi9kb2N4IGluZ2VzdGlvbi4iLCJpbnRlcnZpZXciOiJJZGVtcG90ZW5jeSBhbmQgcmVzdW1hYmxlIHByb2Nlc3Npbmc/IiwiZXhpdENyaXRlcmlhIjoiRXhwbGFpbiBhc3luYyBpbmdlc3Rpb24gaW4gMiBtaW51dGVzOyAxIHRlc3RlZCBjb21taXQ7IG9uZSBzY2VuYXJpbyBhbnN3ZXI7IDMvNSBpbnRlcnZpZXcgcHJhY3RpY2UgcXVlc3Rpb25zLiIsInBsYW5uZWRIb3VycyI6NiwicmVmZXJlbmNlVXJsIjoiaHR0cHM6Ly9kb2NzLmRvY2tlci5jb20vZ2V0LXN0YXJ0ZWQvIiwic2NlbmFyaW9Gb3JtYXQiOiJJbnB1dHMg4oaSIGNvbnN0cmFpbnRzIOKGkiBlZGdlIGNhc2VzIOKGkiBhbGdvcml0aG0g4oaSIGNvbXBsZXhpdHkg4oaSIHRlc3RzOyBjb2RlIGFuZCByZWZsZWN0IiwiaW50ZXJ2aWV3U3RydWN0dXJlIjoiVXNlIGRlZmluaXRpb24g4oaSIGV4YW1wbGUg4oaSIHRyYWRlLW9mZiDihpIgY29tbW9uIGZhaWx1cmUg4oaSIHByb2R1Y3Rpb24gaW1wbGljYXRpb24ifSx7InBsYW5JZCI6ImNocm9uaXMtYWktZW5naW5lZXJpbmctMjAyNi0xMS0wNSIsImRheU51bWJlciI6NzMsImRhdGUiOiIyMDI3LTAxLTE2Iiwid2VlayI6MTEsInBoYXNlIjoiMDYgwrcgUHJvZHVjdGlvbiAmIExMTU9wcyIsInBoYXNlTm8iOiIwNiIsInBoYXNlRGF5Ijo0LCJzdWJwaGFzZSI6IkV2ZW50IGRyaXZlbiBzeXN0ZW1zIiwiY29uY2VwdHMiOiJPdXRib3gsIGV2ZW50IElEcywgZGVkdXAsIGV2ZW50dWFsIGNvbnNpc3RlbmN5IiwidGhlb3J5RGVsaXZlcmFibGUiOiJSZWFkICsgZGlhZ3JhbSArIDMgZmxhc2hjYXJkczsgaWRlbnRpZnkgMiBmYWlsdXJlIG1vZGVzIGluIGV2ZW50IGRyaXZlbiBzeXN0ZW1zLiIsImJhc2ljVGFzayI6IkJ1aWxkIGlkZW1wb3RlbnQgaW5nZXN0IGV2ZW50IGNvbnN1bWVyIiwic2NlbmFyaW8iOiJEdXBsaWNhdGUgZXZlbnQgY3JlYXRlcyBkb3VibGUgZW1iZWRkaW5ncyIsInByb2plY3RXb3Jrc3RyZWFtIjoiUDQ0IMK3IEV2ZW50LURyaXZlbiBFbWJlZGRpbmcgUGlwZWxpbmUiLCJwcm9qZWN0SWQiOiJQNDQiLCJwcm9qZWN0VGFzayI6IlNUQVJUIFA0NCBFdmVudC1Ecml2ZW4gRW1iZWRkaW5nIFBpcGVsaW5lOiBJbmdlc3QgcXVldWVkIGRvY3VtZW50cyB3aXRoIGRlZHVwLCByZXRyaWVzIGFuZCBETFEuIFNoaXAgc21hbGxlc3QgdmVyaWZpYWJsZSBzbGljZTsgZG9jdW1lbnQgdGVzdHMuIiwicHJvamVjdERlbGl2ZXJhYmxlIjoiUDQ0IGxhdW5jaDogRHVwbGljYXRlIGpvYiBjYW5ub3QgY3JlYXRlIGR1cGxpY2F0ZSB2ZWN0b3JzIiwiaW50ZXJ2aWV3IjoiV2hhdCBpcyB0cmFuc2FjdGlvbmFsIG91dGJveCBwYXR0ZXJuPyIsImV4aXRDcml0ZXJpYSI6IkV4cGxhaW4gZXZlbnQgZHJpdmVuIHN5c3RlbXMgaW4gMiBtaW51dGVzOyAxIHRlc3RlZCBjb21taXQ7IG9uZSBzY2VuYXJpbyBhbnN3ZXI7IDMvNSBpbnRlcnZpZXcgcHJhY3RpY2UgcXVlc3Rpb25zLiIsInBsYW5uZWRIb3VycyI6NiwicmVmZXJlbmNlVXJsIjoiaHR0cHM6Ly9kb2NzLmRvY2tlci5jb20vZ2V0LXN0YXJ0ZWQvIiwic2NlbmFyaW9Gb3JtYXQiOiJJbnB1dHMg4oaSIGNvbnN0cmFpbnRzIOKGkiBlZGdlIGNhc2VzIOKGkiBhbGdvcml0aG0g4oaSIGNvbXBsZXhpdHkg4oaSIHRlc3RzOyBjb2RlIGFuZCByZWZsZWN0IiwiaW50ZXJ2aWV3U3RydWN0dXJlIjoiVXNlIGRlZmluaXRpb24g4oaSIGV4YW1wbGUg4oaSIHRyYWRlLW9mZiDihpIgY29tbW9uIGZhaWx1cmUg4oaSIHByb2R1Y3Rpb24gaW1wbGljYXRpb24ifSx7InBsYW5JZCI6ImNocm9uaXMtYWktZW5naW5lZXJpbmctMjAyNi0xMS0wNSIsImRheU51bWJlciI6NzQsImRhdGUiOiIyMDI3LTAxLTE3Iiwid2VlayI6MTEsInBoYXNlIjoiMDYgwrcgUHJvZHVjdGlvbiAmIExMTU9wcyIsInBoYXNlTm8iOiIwNiIsInBoYXNlRGF5Ijo1LCJzdWJwaGFzZSI6IkZpbmUtdHVuaW5nIG1ldGhvZHMiLCJjb25jZXB0cyI6IkxvUkEsIFFMb1JBLCBhZGFwdGVycywgR1BVIG1lbW9yeSBsaW1pdHMiLCJ0aGVvcnlEZWxpdmVyYWJsZSI6IlJlYWQgKyBkaWFncmFtICsgMyBmbGFzaGNhcmRzOyBpZGVudGlmeSAyIGZhaWx1cmUgbW9kZXMgaW4gZmluZS10dW5pbmcgbWV0aG9kcy4iLCJiYXNpY1Rhc2siOiJSdW4gc21hbGwgYWRhcHRlciB0dW5lIG9yIGxvdy1jb3N0IG5vdGVib29rIiwic2NlbmFyaW8iOiJGaW5lLXR1bmluZyBvdmVyZml0cyB0byAxMDAgZXhhbXBsZXMiLCJwcm9qZWN0V29ya3N0cmVhbSI6IlAyMyDCtyBEb21haW4tU3BlY2lmaWMgTExNIEZpbmUtVHVuaW5nIiwicHJvamVjdElkIjoiUDIzIiwicHJvamVjdFRhc2siOiJTVEFSVCBQMjMgRG9tYWluLVNwZWNpZmljIExMTSBGaW5lLVR1bmluZzogUHJlcGFyZSBpbnN0cnVjdGlvbiBkYXRhc2V0cy47IFRyYWluIHVzaW5nIExvUkEvUUxvUkEuOyBDb21wYXJlIGJhc2UgYW5kIGFkYXB0ZWQgbW9kZWxzLi4gU2hpcCBzbWFsbGVzdCB2ZXJpZmlhYmxlIHNsaWNlOyBkb2N1bWVudCB0ZXN0cy4iLCJwcm9qZWN0RGVsaXZlcmFibGUiOiJQMjMgbGF1bmNoOiBSdW5uYWJsZSBkZW1vOyBhdXRvbWF0ZWQgdGVzdHM7IFJFQURNRTsgcHJlcGFyZSBpbnN0cnVjdGlvbiBkYXRhc2V0cy4iLCJpbnRlcnZpZXciOiJXaGVuIGNob29zZSBSQUcgb3ZlciBmaW5lLXR1bmluZz8iLCJleGl0Q3JpdGVyaWEiOiJFeHBsYWluIGZpbmUtdHVuaW5nIG1ldGhvZHMgaW4gMiBtaW51dGVzOyAxIHRlc3RlZCBjb21taXQ7IG9uZSBzY2VuYXJpbyBhbnN3ZXI7IDMvNSBpbnRlcnZpZXcgcHJhY3RpY2UgcXVlc3Rpb25zLiIsInBsYW5uZWRIb3VycyI6NiwicmVmZXJlbmNlVXJsIjoiaHR0cHM6Ly9kb2NzLmRvY2tlci5jb20vZ2V0LXN0YXJ0ZWQvIiwic2NlbmFyaW9Gb3JtYXQiOiJJbnB1dHMg4oaSIGNvbnN0cmFpbnRzIOKGkiBlZGdlIGNhc2VzIOKGkiBhbGdvcml0aG0g4oaSIGNvbXBsZXhpdHkg4oaSIHRlc3RzOyBjb2RlIGFuZCByZWZsZWN0IiwiaW50ZXJ2aWV3U3RydWN0dXJlIjoiVXNlIGRlZmluaXRpb24g4oaSIGV4YW1wbGUg4oaSIHRyYWRlLW9mZiDihpIgY29tbW9uIGZhaWx1cmUg4oaSIHByb2R1Y3Rpb24gaW1wbGljYXRpb24ifSx7InBsYW5JZCI6ImNocm9uaXMtYWktZW5naW5lZXJpbmctMjAyNi0xMS0wNSIsImRheU51bWJlciI6NzUsImRhdGUiOiIyMDI3LTAxLTE4Iiwid2VlayI6MTEsInBoYXNlIjoiMDYgwrcgUHJvZHVjdGlvbiAmIExMTU9wcyIsInBoYXNlTm8iOiIwNiIsInBoYXNlRGF5Ijo2LCJzdWJwaGFzZSI6IkRhdGFzZXQgZW5naW5lZXJpbmciLCJjb25jZXB0cyI6Ikluc3RydWN0aW9uIGV4YW1wbGVzLCBsYWJlbGluZywgc3BsaXRzLCBjb250YW1pbmF0aW9uIiwidGhlb3J5RGVsaXZlcmFibGUiOiJSZWFkICsgZGlhZ3JhbSArIDMgZmxhc2hjYXJkczsgaWRlbnRpZnkgMiBmYWlsdXJlIG1vZGVzIGluIGRhdGFzZXQgZW5naW5lZXJpbmcuIiwiYmFzaWNUYXNrIjoiQ3JlYXRlIHN5bnRoZXRpYyBldmFsL3Rlc3Qgc2FtcGxlIHdpdGggcmV2aWV3Iiwic2NlbmFyaW8iOiJFdmFsdWF0aW9uIGxlYWtlZCBpbnRvIHRyYWluaW5nIHNhbXBsZXMiLCJwcm9qZWN0V29ya3N0cmVhbSI6IlA0NSDCtyBTeW50aGV0aWMgQUkgRXZhbHVhdGlvbiBEYXRhc2V0IEdlbmVyYXRvciIsInByb2plY3RJZCI6IlA0NSIsInByb2plY3RUYXNrIjoiU1RBUlQgUDQ1IFN5bnRoZXRpYyBBSSBFdmFsdWF0aW9uIERhdGFzZXQgR2VuZXJhdG9yOiBHZW5lcmF0ZSBzZWVkIFFBIHBhaXJzIHdpdGggaHVtYW4gcmV2aWV3IGFuZCB2ZXJzaW9uaW5nLiBTaGlwIHNtYWxsZXN0IHZlcmlmaWFibGUgc2xpY2U7IGRvY3VtZW50IHRlc3RzLiIsInByb2plY3REZWxpdmVyYWJsZSI6IlA0NSBsYXVuY2g6IDIwIHJldmlld2VkIGNhc2VzIHNwbGl0IGludG8gY2xlYW4gZXZhbHVhdGlvbiBzZXRzIiwiaW50ZXJ2aWV3IjoiSG93IHByZXZlbnQgdGVzdCBzZXQgY29udGFtaW5hdGlvbj8iLCJleGl0Q3JpdGVyaWEiOiJFeHBsYWluIGRhdGFzZXQgZW5naW5lZXJpbmcgaW4gMiBtaW51dGVzOyAxIHRlc3RlZCBjb21taXQ7IG9uZSBzY2VuYXJpbyBhbnN3ZXI7IDMvNSBpbnRlcnZpZXcgcHJhY3RpY2UgcXVlc3Rpb25zLiIsInBsYW5uZWRIb3VycyI6NiwicmVmZXJlbmNlVXJsIjoiaHR0cHM6Ly9kb2NzLmRvY2tlci5jb20vZ2V0LXN0YXJ0ZWQvIiwic2NlbmFyaW9Gb3JtYXQiOiJJbnB1dHMg4oaSIGNvbnN0cmFpbnRzIOKGkiBlZGdlIGNhc2VzIOKGkiBhbGdvcml0aG0g4oaSIGNvbXBsZXhpdHkg4oaSIHRlc3RzOyBjb2RlIGFuZCByZWZsZWN0IiwiaW50ZXJ2aWV3U3RydWN0dXJlIjoiVXNlIGRlZmluaXRpb24g4oaSIGV4YW1wbGUg4oaSIHRyYWRlLW9mZiDihpIgY29tbW9uIGZhaWx1cmUg4oaSIHByb2R1Y3Rpb24gaW1wbGljYXRpb24ifSx7InBsYW5JZCI6ImNocm9uaXMtYWktZW5naW5lZXJpbmctMjAyNi0xMS0wNSIsImRheU51bWJlciI6NzYsImRhdGUiOiIyMDI3LTAxLTE5Iiwid2VlayI6MTEsInBoYXNlIjoiMDYgwrcgUHJvZHVjdGlvbiAmIExMTU9wcyIsInBoYXNlTm8iOiIwNiIsInBoYXNlRGF5Ijo3LCJzdWJwaGFzZSI6Ik9ic2VydmFiaWxpdHkgJiBxdWFsaXR5IiwiY29uY2VwdHMiOiJUcmFjZXMsIGV2YWwgbWV0cmljcywgZGFzaGJvYXJkcywgYWxlcnRzLCBNTGZsb3ciLCJ0aGVvcnlEZWxpdmVyYWJsZSI6IlJlYWQgKyBkaWFncmFtICsgMyBmbGFzaGNhcmRzOyBpZGVudGlmeSAyIGZhaWx1cmUgbW9kZXMgaW4gb2JzZXJ2YWJpbGl0eSAmIHF1YWxpdHkuIiwiYmFzaWNUYXNrIjoiVHJhY2sgcmV0cmlldmFsLCB0b2tlbnMsIGxhdGVuY3kgYW5kIGZhaWx1cmUgcmF0ZXMiLCJzY2VuYXJpbyI6IkxhdGVuY3kgd29yc2VucyBidXQgYW5zd2VyIHF1YWxpdHkgdW5jaGFuZ2VkIiwicHJvamVjdFdvcmtzdHJlYW0iOiJQMjQgwrcgTExNIEV2YWx1YXRpb24gYW5kIE9ic2VydmFiaWxpdHkgUGxhdGZvcm0iLCJwcm9qZWN0SWQiOiJQMjQiLCJwcm9qZWN0VGFzayI6IlNUQVJUIFAyNCBMTE0gRXZhbHVhdGlvbiBhbmQgT2JzZXJ2YWJpbGl0eSBQbGF0Zm9ybTogRXZhbHVhdGUgYW5zd2VyIHF1YWxpdHkuOyBEZXRlY3QgaGFsbHVjaW5hdGlvbnMuOyBNb25pdG9yIHJldHJpZXZhbCBwZXJmb3JtYW5jZS4uIFNoaXAgc21hbGxlc3QgdmVyaWZpYWJsZSBzbGljZTsgZG9jdW1lbnQgdGVzdHMuIiwicHJvamVjdERlbGl2ZXJhYmxlIjoiUDI0IGxhdW5jaDogUnVubmFibGUgZGVtbzsgYXV0b21hdGVkIHRlc3RzOyBSRUFETUU7IGV2YWx1YXRlIGFuc3dlciBxdWFsaXR5LiIsImludGVydmlldyI6IldoYXQgYmVsb25ncyBpbiBhbiBMTE0gb2JzZXJ2YWJpbGl0eSBzdGFjaz8iLCJleGl0Q3JpdGVyaWEiOiJFeHBsYWluIG9ic2VydmFiaWxpdHkgJiBxdWFsaXR5IGluIDIgbWludXRlczsgMSB0ZXN0ZWQgY29tbWl0OyBvbmUgc2NlbmFyaW8gYW5zd2VyOyAzLzUgaW50ZXJ2aWV3IHByYWN0aWNlIHF1ZXN0aW9ucy4iLCJwbGFubmVkSG91cnMiOjYsInJlZmVyZW5jZVVybCI6Imh0dHBzOi8vZG9jcy5kb2NrZXIuY29tL2dldC1zdGFydGVkLyIsInNjZW5hcmlvRm9ybWF0IjoiSW5wdXRzIOKGkiBjb25zdHJhaW50cyDihpIgZWRnZSBjYXNlcyDihpIgYWxnb3JpdGhtIOKGkiBjb21wbGV4aXR5IOKGkiB0ZXN0czsgY29kZSBhbmQgcmVmbGVjdCIsImludGVydmlld1N0cnVjdHVyZSI6IlVzZSBkZWZpbml0aW9uIOKGkiBleGFtcGxlIOKGkiB0cmFkZS1vZmYg4oaSIGNvbW1vbiBmYWlsdXJlIOKGkiBwcm9kdWN0aW9uIGltcGxpY2F0aW9uIn0seyJwbGFuSWQiOiJjaHJvbmlzLWFpLWVuZ2luZWVyaW5nLTIwMjYtMTEtMDUiLCJkYXlOdW1iZXIiOjc3LCJkYXRlIjoiMjAyNy0wMS0yMCIsIndlZWsiOjExLCJwaGFzZSI6IjA2IMK3IFByb2R1Y3Rpb24gJiBMTE1PcHMiLCJwaGFzZU5vIjoiMDYiLCJwaGFzZURheSI6OCwic3VicGhhc2UiOiJDb3N0LWF3YXJlIHNlcnZpbmciLCJjb25jZXB0cyI6InZMTE0gY29uY2VwdHMsIGJhdGNoaW5nLCBjYWNoaW5nLCBHUFUgc2VsZWN0aW9uIiwidGhlb3J5RGVsaXZlcmFibGUiOiJSZWFkICsgZGlhZ3JhbSArIDMgZmxhc2hjYXJkczsgaWRlbnRpZnkgMiBmYWlsdXJlIG1vZGVzIGluIGNvc3QtYXdhcmUgc2VydmluZy4iLCJiYXNpY1Rhc2siOiJCdWlsZCBtb2RlbC1yb3V0ZXIgc2ltdWxhdG9yIGFuZCBjYWNoZSIsInNjZW5hcmlvIjoiVGhyb3VnaHB1dCBzcGlrZXMgd2l0aG91dCBoYXJtaW5nIFA5NSBsYXRlbmN5IiwicHJvamVjdFdvcmtzdHJlYW0iOiJQNDYgwrcgQ29zdC1Bd2FyZSBNdWx0aS1Qcm92aWRlciBNb2RlbCBSb3V0ZXIiLCJwcm9qZWN0SWQiOiJQNDYiLCJwcm9qZWN0VGFzayI6IlNUQVJUIFA0NiBDb3N0LUF3YXJlIE11bHRpLVByb3ZpZGVyIE1vZGVsIFJvdXRlcjogU2VsZWN0IHNhZmUgcm91dGUgdXNpbmcgY29zdCwgbGF0ZW5jeSBhbmQgcXVhbGl0eSBwb2xpY3kuIFNoaXAgc21hbGxlc3QgdmVyaWZpYWJsZSBzbGljZTsgZG9jdW1lbnQgdGVzdHMuIiwicHJvamVjdERlbGl2ZXJhYmxlIjoiUDQ2IGxhdW5jaDogRmFsbGJhY2sgYW5kIGNpcmN1aXQtYnJlYWtlciB0ZXN0IHN1Y2NlZWRzIiwiaW50ZXJ2aWV3IjoiTGF0ZW5jeSB2cyB0aHJvdWdocHV0IHRyYWRlLW9mZnM/IiwiZXhpdENyaXRlcmlhIjoiRXhwbGFpbiBjb3N0LWF3YXJlIHNlcnZpbmcgaW4gMiBtaW51dGVzOyAxIHRlc3RlZCBjb21taXQ7IG9uZSBzY2VuYXJpbyBhbnN3ZXI7IDMvNSBpbnRlcnZpZXcgcHJhY3RpY2UgcXVlc3Rpb25zLiIsInBsYW5uZWRIb3VycyI6NiwicmVmZXJlbmNlVXJsIjoiaHR0cHM6Ly9kb2NzLmRvY2tlci5jb20vZ2V0LXN0YXJ0ZWQvIiwic2NlbmFyaW9Gb3JtYXQiOiJJbnB1dHMg4oaSIGNvbnN0cmFpbnRzIOKGkiBlZGdlIGNhc2VzIOKGkiBhbGdvcml0aG0g4oaSIGNvbXBsZXhpdHkg4oaSIHRlc3RzOyBjb2RlIGFuZCByZWZsZWN0IiwiaW50ZXJ2aWV3U3RydWN0dXJlIjoiVXNlIGRlZmluaXRpb24g4oaSIGV4YW1wbGUg4oaSIHRyYWRlLW9mZiDihpIgY29tbW9uIGZhaWx1cmUg4oaSIHByb2R1Y3Rpb24gaW1wbGljYXRpb24ifSx7InBsYW5JZCI6ImNocm9uaXMtYWktZW5naW5lZXJpbmctMjAyNi0xMS0wNSIsImRheU51bWJlciI6NzgsImRhdGUiOiIyMDI3LTAxLTIxIiwid2VlayI6MTIsInBoYXNlIjoiMDYgwrcgUHJvZHVjdGlvbiAmIExMTU9wcyIsInBoYXNlTm8iOiIwNiIsInBoYXNlRGF5Ijo5LCJzdWJwaGFzZSI6IlJlbGVhc2UgZW5naW5lZXJpbmciLCJjb25jZXB0cyI6IkNJL0NELCBEb2NrZXIsIHByb2JlcywgYmx1ZS1ncmVlbiwgU0xPIiwidGhlb3J5RGVsaXZlcmFibGUiOiJSZWFkICsgZGlhZ3JhbSArIDMgZmxhc2hjYXJkczsgaWRlbnRpZnkgMiBmYWlsdXJlIG1vZGVzIGluIHJlbGVhc2UgZW5naW5lZXJpbmcuIiwiYmFzaWNUYXNrIjoiQWRkIHRlc3QgZ2F0ZSBhbmQgZGVwbG95bWVudCBoZWFsdGggZW5kcG9pbnQiLCJzY2VuYXJpbyI6IlByb21wdCBjaGFuZ2UgY2F1c2VzIHF1YWxpdHkgcmVncmVzc2lvbiIsInByb2plY3RXb3Jrc3RyZWFtIjoiUDI1IMK3IFNjYWxhYmxlIExMTSBJbmZlcmVuY2UgUGxhdGZvcm0iLCJwcm9qZWN0SWQiOiJQMjUiLCJwcm9qZWN0VGFzayI6IlNUQVJUIFAyNSBTY2FsYWJsZSBMTE0gSW5mZXJlbmNlIFBsYXRmb3JtOiBTZXJ2ZSBvcGVuLXNvdXJjZSBMTE1zLjsgTW9kZWwgcm91dGluZy47IFJlcXVlc3QgYmF0Y2hpbmcuLiBTaGlwIHNtYWxsZXN0IHZlcmlmaWFibGUgc2xpY2U7IGRvY3VtZW50IHRlc3RzLiIsInByb2plY3REZWxpdmVyYWJsZSI6IlAyNSBsYXVuY2g6IFJ1bm5hYmxlIGRlbW87IGF1dG9tYXRlZCB0ZXN0czsgUkVBRE1FOyBzZXJ2ZSBvcGVuLXNvdXJjZSBsbG1zLiIsImludGVydmlldyI6IldoYXQgc2hvdWxkIGJsb2NrIGFuIEFJIHJlbGVhc2U/IiwiZXhpdENyaXRlcmlhIjoiRXhwbGFpbiByZWxlYXNlIGVuZ2luZWVyaW5nIGluIDIgbWludXRlczsgMSB0ZXN0ZWQgY29tbWl0OyBvbmUgc2NlbmFyaW8gYW5zd2VyOyAzLzUgaW50ZXJ2aWV3IHByYWN0aWNlIHF1ZXN0aW9ucy4iLCJwbGFubmVkSG91cnMiOjYsInJlZmVyZW5jZVVybCI6Imh0dHBzOi8vZG9jcy5kb2NrZXIuY29tL2dldC1zdGFydGVkLyIsInNjZW5hcmlvRm9ybWF0IjoiSW5wdXRzIOKGkiBjb25zdHJhaW50cyDihpIgZWRnZSBjYXNlcyDihpIgYWxnb3JpdGhtIOKGkiBjb21wbGV4aXR5IOKGkiB0ZXN0czsgY29kZSBhbmQgcmVmbGVjdCIsImludGVydmlld1N0cnVjdHVyZSI6IlVzZSBkZWZpbml0aW9uIOKGkiBleGFtcGxlIOKGkiB0cmFkZS1vZmYg4oaSIGNvbW1vbiBmYWlsdXJlIOKGkiBwcm9kdWN0aW9uIGltcGxpY2F0aW9uIn0seyJwbGFuSWQiOiJjaHJvbmlzLWFpLWVuZ2luZWVyaW5nLTIwMjYtMTEtMDUiLCJkYXlOdW1iZXIiOjc5LCJkYXRlIjoiMjAyNy0wMS0yMiIsIndlZWsiOjEyLCJwaGFzZSI6IjA2IMK3IFByb2R1Y3Rpb24gJiBMTE1PcHMiLCJwaGFzZU5vIjoiMDYiLCJwaGFzZURheSI6MTAsInN1YnBoYXNlIjoiUHJvZHVjdGlvbiByZWFkaW5lc3MiLCJjb25jZXB0cyI6IkxvYWQgdGVzdHMsIHRocmVhdCBtb2RlbHMsIGRpc2FzdGVyIHJlY292ZXJ5LCBydW5ib29rcyIsInRoZW9yeURlbGl2ZXJhYmxlIjoiUmVhZCArIGRpYWdyYW0gKyAzIGZsYXNoY2FyZHM7IGlkZW50aWZ5IDIgZmFpbHVyZSBtb2RlcyBpbiBwcm9kdWN0aW9uIHJlYWRpbmVzcy4iLCJiYXNpY1Rhc2siOiJXcml0ZSBsb2FkIHRlc3QgYW5kIHByb2R1Y3Rpb24gcm9sbGJhY2sgY2hlY2tsaXN0Iiwic2NlbmFyaW8iOiJWZWN0b3IgREIgb3V0YWdlIHdoaWxlIHJlcXVlc3RzIGNvbnRpbnVlIiwicHJvamVjdFdvcmtzdHJlYW0iOiJQNDcgwrcgQUkgUmVsZWFzZSBHYXRlICYgUHJvbXB0IFJlZ3Jlc3Npb24gQ0kiLCJwcm9qZWN0SWQiOiJQNDciLCJwcm9qZWN0VGFzayI6IlNUQVJUIFA0NyBBSSBSZWxlYXNlIEdhdGUgJiBQcm9tcHQgUmVncmVzc2lvbiBDSTogQmxvY2sgcmVsZWFzZXMgb24gZmFpbGluZyBMTE0vUkFHIHJlZ3Jlc3Npb24gY2hlY2tzLiBTaGlwIHNtYWxsZXN0IHZlcmlmaWFibGUgc2xpY2U7IGRvY3VtZW50IHRlc3RzLiIsInByb2plY3REZWxpdmVyYWJsZSI6IlA0NyBsYXVuY2g6IEdyZWVuL3JlZCBkZW1vbnN0cmF0aW9uIHdpdGggc3RvcmVkIGV2YWwgYXJ0aWZhY3RzIiwiaW50ZXJ2aWV3IjoiSG93IGRlZmluZSBncmFjZWZ1bCBkZWdyYWRhdGlvbiBhbmQgUlRPL1JQTz8iLCJleGl0Q3JpdGVyaWEiOiJFeHBsYWluIHByb2R1Y3Rpb24gcmVhZGluZXNzIGluIDIgbWludXRlczsgMSB0ZXN0ZWQgY29tbWl0OyBvbmUgc2NlbmFyaW8gYW5zd2VyOyAzLzUgaW50ZXJ2aWV3IHByYWN0aWNlIHF1ZXN0aW9ucy4iLCJwbGFubmVkSG91cnMiOjYsInJlZmVyZW5jZVVybCI6Imh0dHBzOi8vZG9jcy5kb2NrZXIuY29tL2dldC1zdGFydGVkLyIsInNjZW5hcmlvRm9ybWF0IjoiSW5wdXRzIOKGkiBjb25zdHJhaW50cyDihpIgZWRnZSBjYXNlcyDihpIgYWxnb3JpdGhtIOKGkiBjb21wbGV4aXR5IOKGkiB0ZXN0czsgY29kZSBhbmQgcmVmbGVjdCIsImludGVydmlld1N0cnVjdHVyZSI6IlVzZSBkZWZpbml0aW9uIOKGkiBleGFtcGxlIOKGkiB0cmFkZS1vZmYg4oaSIGNvbW1vbiBmYWlsdXJlIOKGkiBwcm9kdWN0aW9uIGltcGxpY2F0aW9uIn0seyJwbGFuSWQiOiJjaHJvbmlzLWFpLWVuZ2luZWVyaW5nLTIwMjYtMTEtMDUiLCJkYXlOdW1iZXIiOjgwLCJkYXRlIjoiMjAyNy0wMS0yMyIsIndlZWsiOjEyLCJwaGFzZSI6IjA3IMK3IEFyY2hpdGVjdCBDYXBzdG9uZXMiLCJwaGFzZU5vIjoiMDciLCJwaGFzZURheSI6MSwic3VicGhhc2UiOiJLbm93bGVkZ2UgZ3JhcGhzIiwiY29uY2VwdHMiOiJFbnRpdGllcywgcmVsYXRpb25zLCBOZW80aiBDeXBoZXIsIGdyYXBoIHNjaGVtYSIsInRoZW9yeURlbGl2ZXJhYmxlIjoiUmVhZCArIGRpYWdyYW0gKyAzIGZsYXNoY2FyZHM7IGlkZW50aWZ5IDIgZmFpbHVyZSBtb2RlcyBpbiBrbm93bGVkZ2UgZ3JhcGhzLiIsImJhc2ljVGFzayI6IkV4dHJhY3Qgbm9kZXMgYW5kIGVkZ2VzIGZyb20gY3VyYXRlZCB0ZXh0Iiwic2NlbmFyaW8iOiJSZXNvbHZlIHNhbWUgcGVyc29uIG1lbnRpb25lZCB1bmRlciBhbGlhc2VzIiwicHJvamVjdFdvcmtzdHJlYW0iOiJQMjYgwrcgRW50ZXJwcmlzZSBHcmFwaFJBRyBLbm93bGVkZ2UgUGxhdGZvcm0iLCJwcm9qZWN0SWQiOiJQMjYiLCJwcm9qZWN0VGFzayI6IlNUQVJUIFAyNiBFbnRlcnByaXNlIEdyYXBoUkFHIEtub3dsZWRnZSBQbGF0Zm9ybTogRXh0cmFjdCBlbnRpdGllcyBhbmQgcmVsYXRpb25zaGlwcy47IENvbnN0cnVjdCBrbm93bGVkZ2UgZ3JhcGhzLjsgQ29tYmluZSBncmFwaCBhbmQgdmVjdG9yIHJldHJpZXZhbC4uIFNoaXAgc21hbGxlc3QgdmVyaWZpYWJsZSBzbGljZTsgZG9jdW1lbnQgdGVzdHMuIiwicHJvamVjdERlbGl2ZXJhYmxlIjoiUDI2IGxhdW5jaDogUnVubmFibGUgZGVtbzsgYXV0b21hdGVkIHRlc3RzOyBSRUFETUU7IGV4dHJhY3QgZW50aXRpZXMgYW5kIHJlbGF0aW9uc2hpcHMuIiwiaW50ZXJ2aWV3IjoiV2hlbiBkb2VzIEdyYXBoUkFHIGltcHJvdmUgbXVsdGktaG9wIHF1ZXN0aW9ucz8iLCJleGl0Q3JpdGVyaWEiOiJFeHBsYWluIGtub3dsZWRnZSBncmFwaHMgaW4gMiBtaW51dGVzOyAxIHRlc3RlZCBjb21taXQ7IG9uZSBzY2VuYXJpbyBhbnN3ZXI7IDMvNSBpbnRlcnZpZXcgcHJhY3RpY2UgcXVlc3Rpb25zLiIsInBsYW5uZWRIb3VycyI6NiwicmVmZXJlbmNlVXJsIjoiaHR0cHM6Ly9kZXZlbG9wZXJzLm9wZW5haS5jb20vYXBpL2RvY3MvZ3VpZGVzL2FnZW50cy9zZGsiLCJzY2VuYXJpb0Zvcm1hdCI6IklucHV0cyDihpIgY29uc3RyYWludHMg4oaSIGVkZ2UgY2FzZXMg4oaSIGFsZ29yaXRobSDihpIgY29tcGxleGl0eSDihpIgdGVzdHM7IGNvZGUgYW5kIHJlZmxlY3QiLCJpbnRlcnZpZXdTdHJ1Y3R1cmUiOiJVc2UgZGVmaW5pdGlvbiDihpIgZXhhbXBsZSDihpIgdHJhZGUtb2ZmIOKGkiBjb21tb24gZmFpbHVyZSDihpIgcHJvZHVjdGlvbiBpbXBsaWNhdGlvbiJ9LHsicGxhbklkIjoiY2hyb25pcy1haS1lbmdpbmVlcmluZy0yMDI2LTExLTA1IiwiZGF5TnVtYmVyIjo4MSwiZGF0ZSI6IjIwMjctMDEtMjQiLCJ3ZWVrIjoxMiwicGhhc2UiOiIwNyDCtyBBcmNoaXRlY3QgQ2Fwc3RvbmVzIiwicGhhc2VObyI6IjA3IiwicGhhc2VEYXkiOjIsInN1YnBoYXNlIjoiR3JhcGggZXh0cmFjdGlvbiIsImNvbmNlcHRzIjoiVHJpcGxlIGV4dHJhY3Rpb24sIGVudGl0eSBsaW5raW5nLCBkZWR1cCwgY29uZmlkZW5jZSIsInRoZW9yeURlbGl2ZXJhYmxlIjoiUmVhZCArIGRpYWdyYW0gKyAzIGZsYXNoY2FyZHM7IGlkZW50aWZ5IDIgZmFpbHVyZSBtb2RlcyBpbiBncmFwaCBleHRyYWN0aW9uLiIsImJhc2ljVGFzayI6IkJ1aWxkIGtub3dsZWRnZS1ncmFwaCBjcmVhdGlvbiBDTEkiLCJzY2VuYXJpbyI6IkluZmVycmVkIHJlbGF0aW9uc2hpcCBjb25mbGljdHMgd2l0aCBwcmltYXJ5IHNvdXJjZSIsInByb2plY3RXb3Jrc3RyZWFtIjoiUDQ4IMK3IEtub3dsZWRnZSBHcmFwaCBFeHRyYWN0aW9uIFN0dWRpbyIsInByb2plY3RJZCI6IlA0OCIsInByb2plY3RUYXNrIjoiU1RBUlQgUDQ4IEtub3dsZWRnZSBHcmFwaCBFeHRyYWN0aW9uIFN0dWRpbzogRXh0cmFjdCB0cmlwbGVzLCByZXNvbHZlIGVudGl0aWVzIGFuZCBidWlsZCBncmFwaCBleHBsb3Jlci4gU2hpcCBzbWFsbGVzdCB2ZXJpZmlhYmxlIHNsaWNlOyBkb2N1bWVudCB0ZXN0cy4iLCJwcm9qZWN0RGVsaXZlcmFibGUiOiJQNDggbGF1bmNoOiAxMCBldmlkZW5jZS1saW5rZWQgZW50aXRpZXMvZWRnZXMgd2l0aCBncmFwaCBxdWVyaWVzIiwiaW50ZXJ2aWV3IjoiSG93IHZlcmlmeSBncmFwaCBmYWN0cyBhZ2FpbnN0IGRvY3VtZW50cz8iLCJleGl0Q3JpdGVyaWEiOiJFeHBsYWluIGdyYXBoIGV4dHJhY3Rpb24gaW4gMiBtaW51dGVzOyAxIHRlc3RlZCBjb21taXQ7IG9uZSBzY2VuYXJpbyBhbnN3ZXI7IDMvNSBpbnRlcnZpZXcgcHJhY3RpY2UgcXVlc3Rpb25zLiIsInBsYW5uZWRIb3VycyI6NiwicmVmZXJlbmNlVXJsIjoiaHR0cHM6Ly9kZXZlbG9wZXJzLm9wZW5haS5jb20vYXBpL2RvY3MvZ3VpZGVzL2FnZW50cy9zZGsiLCJzY2VuYXJpb0Zvcm1hdCI6IklucHV0cyDihpIgY29uc3RyYWludHMg4oaSIGVkZ2UgY2FzZXMg4oaSIGFsZ29yaXRobSDihpIgY29tcGxleGl0eSDihpIgdGVzdHM7IGNvZGUgYW5kIHJlZmxlY3QiLCJpbnRlcnZpZXdTdHJ1Y3R1cmUiOiJVc2UgZGVmaW5pdGlvbiDihpIgZXhhbXBsZSDihpIgdHJhZGUtb2ZmIOKGkiBjb21tb24gZmFpbHVyZSDihpIgcHJvZHVjdGlvbiBpbXBsaWNhdGlvbiJ9LHsicGxhbklkIjoiY2hyb25pcy1haS1lbmdpbmVlcmluZy0yMDI2LTExLTA1IiwiZGF5TnVtYmVyIjo4MiwiZGF0ZSI6IjIwMjctMDEtMjUiLCJ3ZWVrIjoxMiwicGhhc2UiOiIwNyDCtyBBcmNoaXRlY3QgQ2Fwc3RvbmVzIiwicGhhc2VObyI6IjA3IiwicGhhc2VEYXkiOjMsInN1YnBoYXNlIjoiUmVhbHRpbWUgdm9pY2UgSSIsImNvbmNlcHRzIjoiQVNSLCBUVFMsIFdlYlNvY2tldHMsIHR1cm4tdGFraW5nLCBWQUQiLCJ0aGVvcnlEZWxpdmVyYWJsZSI6IlJlYWQgKyBkaWFncmFtICsgMyBmbGFzaGNhcmRzOyBpZGVudGlmeSAyIGZhaWx1cmUgbW9kZXMgaW4gcmVhbHRpbWUgdm9pY2UgaS4iLCJiYXNpY1Rhc2siOiJQcm90b3R5cGUgQVNSIOKGkiB0ZXh0IHJlc3BvbnNlIOKGkiBUVFMiLCJzY2VuYXJpbyI6Ik5vaXN5IHJvb20gY3JlYXRlcyBmYWxzZSB3YWtlIGV2ZW50cyIsInByb2plY3RXb3Jrc3RyZWFtIjoiUDI3IMK3IFJlYWwtVGltZSBWb2ljZSBBSSBBc3Npc3RhbnQiLCJwcm9qZWN0SWQiOiJQMjciLCJwcm9qZWN0VGFzayI6IlNUQVJUIFAyNyBSZWFsLVRpbWUgVm9pY2UgQUkgQXNzaXN0YW50OiBTcGVlY2gtdG8tdGV4dC47IFRleHQtdG8tc3BlZWNoLjsgU3RyZWFtaW5nIGF1ZGlvLi4gU2hpcCBzbWFsbGVzdCB2ZXJpZmlhYmxlIHNsaWNlOyBkb2N1bWVudCB0ZXN0cy4iLCJwcm9qZWN0RGVsaXZlcmFibGUiOiJQMjcgbGF1bmNoOiBSdW5uYWJsZSBkZW1vOyBhdXRvbWF0ZWQgdGVzdHM7IFJFQURNRTsgc3BlZWNoLXRvLXRleHQuIiwiaW50ZXJ2aWV3IjoiSG93IHF1YW50aWZ5IGVuZC10by1lbmQgdm9pY2UgbGF0ZW5jeT8iLCJleGl0Q3JpdGVyaWEiOiJFeHBsYWluIHJlYWx0aW1lIHZvaWNlIGkgaW4gMiBtaW51dGVzOyAxIHRlc3RlZCBjb21taXQ7IG9uZSBzY2VuYXJpbyBhbnN3ZXI7IDMvNSBpbnRlcnZpZXcgcHJhY3RpY2UgcXVlc3Rpb25zLiIsInBsYW5uZWRIb3VycyI6NiwicmVmZXJlbmNlVXJsIjoiaHR0cHM6Ly9kZXZlbG9wZXJzLm9wZW5haS5jb20vYXBpL2RvY3MvZ3VpZGVzL2FnZW50cy9zZGsiLCJzY2VuYXJpb0Zvcm1hdCI6IklucHV0cyDihpIgY29uc3RyYWludHMg4oaSIGVkZ2UgY2FzZXMg4oaSIGFsZ29yaXRobSDihpIgY29tcGxleGl0eSDihpIgdGVzdHM7IGNvZGUgYW5kIHJlZmxlY3QiLCJpbnRlcnZpZXdTdHJ1Y3R1cmUiOiJVc2UgZGVmaW5pdGlvbiDihpIgZXhhbXBsZSDihpIgdHJhZGUtb2ZmIOKGkiBjb21tb24gZmFpbHVyZSDihpIgcHJvZHVjdGlvbiBpbXBsaWNhdGlvbiJ9LHsicGxhbklkIjoiY2hyb25pcy1haS1lbmdpbmVlcmluZy0yMDI2LTExLTA1IiwiZGF5TnVtYmVyIjo4MywiZGF0ZSI6IjIwMjctMDEtMjYiLCJ3ZWVrIjoxMiwicGhhc2UiOiIwNyDCtyBBcmNoaXRlY3QgQ2Fwc3RvbmVzIiwicGhhc2VObyI6IjA3IiwicGhhc2VEYXkiOjQsInN1YnBoYXNlIjoiUmVhbHRpbWUgdm9pY2UgSUkiLCJjb25jZXB0cyI6IlN0cmVhbWluZywgaW50ZXJydXB0aW9ucywgbGF0ZW5jeSwgY29udGV4dCBzdGF0ZSIsInRoZW9yeURlbGl2ZXJhYmxlIjoiUmVhZCArIGRpYWdyYW0gKyAzIGZsYXNoY2FyZHM7IGlkZW50aWZ5IDIgZmFpbHVyZSBtb2RlcyBpbiByZWFsdGltZSB2b2ljZSBpaS4iLCJiYXNpY1Rhc2siOiJBZGQgdXNlciBiYXJnZS1pbiB0byB2b2ljZSBzaW11bGF0b3IiLCJzY2VuYXJpbyI6IlNwZWFrZXIgaW50ZXJydXB0cyBtaWQtc2VudGVuY2UiLCJwcm9qZWN0V29ya3N0cmVhbSI6IlAyNyDCtyBSZWFsLVRpbWUgVm9pY2UgQUkgQXNzaXN0YW50IiwicHJvamVjdElkIjoiUDI3IiwicHJvamVjdFRhc2siOiJJVEVSQVRFIFAyNyBSZWFsLVRpbWUgVm9pY2UgQUkgQXNzaXN0YW50OiBhZGQgZWRnZS1jYXNlIGhhbmRsaW5nLCB0ZXN0IGZpeHR1cmUsIHJlc3VsdCBsb2cgb3IgQVBJIGNvbnRyYWN0IGFsaWduZWQgdG8gdG9kYXnigJlzIHRvcGljLiIsInByb2plY3REZWxpdmVyYWJsZSI6Ik9uZSB0ZXN0ZWQgaW5jcmVtZW50YWwgY29tbWl0IGZvciBQMjc7IG5vdGUgb3BlbiBmb2xsb3ctdXBzIGluIGJhY2tsb2cuIiwiaW50ZXJ2aWV3IjoiSG93IHByZXZlbnQgb3ZlcmxhcHBpbmcgcmVzcG9uc2VzPyIsImV4aXRDcml0ZXJpYSI6IkV4cGxhaW4gcmVhbHRpbWUgdm9pY2UgaWkgaW4gMiBtaW51dGVzOyAxIHRlc3RlZCBjb21taXQ7IG9uZSBzY2VuYXJpbyBhbnN3ZXI7IDMvNSBpbnRlcnZpZXcgcHJhY3RpY2UgcXVlc3Rpb25zLiIsInBsYW5uZWRIb3VycyI6NiwicmVmZXJlbmNlVXJsIjoiaHR0cHM6Ly9kZXZlbG9wZXJzLm9wZW5haS5jb20vYXBpL2RvY3MvZ3VpZGVzL2FnZW50cy9zZGsiLCJzY2VuYXJpb0Zvcm1hdCI6IklucHV0cyDihpIgY29uc3RyYWludHMg4oaSIGVkZ2UgY2FzZXMg4oaSIGFsZ29yaXRobSDihpIgY29tcGxleGl0eSDihpIgdGVzdHM7IGNvZGUgYW5kIHJlZmxlY3QiLCJpbnRlcnZpZXdTdHJ1Y3R1cmUiOiJVc2UgZGVmaW5pdGlvbiDihpIgZXhhbXBsZSDihpIgdHJhZGUtb2ZmIOKGkiBjb21tb24gZmFpbHVyZSDihpIgcHJvZHVjdGlvbiBpbXBsaWNhdGlvbiJ9LHsicGxhbklkIjoiY2hyb25pcy1haS1lbmdpbmVlcmluZy0yMDI2LTExLTA1IiwiZGF5TnVtYmVyIjo4NCwiZGF0ZSI6IjIwMjctMDEtMjciLCJ3ZWVrIjoxMiwicGhhc2UiOiIwNyDCtyBBcmNoaXRlY3QgQ2Fwc3RvbmVzIiwicGhhc2VObyI6IjA3IiwicGhhc2VEYXkiOjUsInN1YnBoYXNlIjoiVmlkZW8gcHJvY2Vzc2luZyIsImNvbmNlcHRzIjoiRnJhbWUgc2FtcGxpbmcsIGF1ZGlvIHRyYW5zY3JpcHQsIHNlbWFudGljIGluZGV4aW5nIiwidGhlb3J5RGVsaXZlcmFibGUiOiJSZWFkICsgZGlhZ3JhbSArIDMgZmxhc2hjYXJkczsgaWRlbnRpZnkgMiBmYWlsdXJlIG1vZGVzIGluIHZpZGVvIHByb2Nlc3NpbmcuIiwiYmFzaWNUYXNrIjoiRXh0cmFjdCBzY2VuZSBjYXB0aW9ucyBmcm9tIHNob3J0IHZpZGVvIHNhbXBsZSIsInNjZW5hcmlvIjoiQW5zd2VyIHF1ZXJ5IG5lZWRpbmcgdmlzdWFsICsgYXVkaW8gZXZpZGVuY2UiLCJwcm9qZWN0V29ya3N0cmVhbSI6IlAyOCDCtyBJbnRlbGxpZ2VudCBWaWRlbyBVbmRlcnN0YW5kaW5nIFBsYXRmb3JtIiwicHJvamVjdElkIjoiUDI4IiwicHJvamVjdFRhc2siOiJTVEFSVCBQMjggSW50ZWxsaWdlbnQgVmlkZW8gVW5kZXJzdGFuZGluZyBQbGF0Zm9ybTogVmlkZW8gaW5nZXN0aW9uLjsgU2NlbmUgYW5kIGZyYW1lIGV4dHJhY3Rpb24uOyBPYmplY3QgYW5kIGFjdGl2aXR5IHJlY29nbml0aW9uLi4gU2hpcCBzbWFsbGVzdCB2ZXJpZmlhYmxlIHNsaWNlOyBkb2N1bWVudCB0ZXN0cy4iLCJwcm9qZWN0RGVsaXZlcmFibGUiOiJQMjggbGF1bmNoOiBSdW5uYWJsZSBkZW1vOyBhdXRvbWF0ZWQgdGVzdHM7IFJFQURNRTsgdmlkZW8gaW5nZXN0aW9uLiIsImludGVydmlldyI6IkhvdyB0cmFkZSByZWNhbGwgdnMgdmlkZW8gaW5kZXhpbmcgY29zdD8iLCJleGl0Q3JpdGVyaWEiOiJFeHBsYWluIHZpZGVvIHByb2Nlc3NpbmcgaW4gMiBtaW51dGVzOyAxIHRlc3RlZCBjb21taXQ7IG9uZSBzY2VuYXJpbyBhbnN3ZXI7IDMvNSBpbnRlcnZpZXcgcHJhY3RpY2UgcXVlc3Rpb25zLiIsInBsYW5uZWRIb3VycyI6NiwicmVmZXJlbmNlVXJsIjoiaHR0cHM6Ly9kZXZlbG9wZXJzLm9wZW5haS5jb20vYXBpL2RvY3MvZ3VpZGVzL2FnZW50cy9zZGsiLCJzY2VuYXJpb0Zvcm1hdCI6IklucHV0cyDihpIgY29uc3RyYWludHMg4oaSIGVkZ2UgY2FzZXMg4oaSIGFsZ29yaXRobSDihpIgY29tcGxleGl0eSDihpIgdGVzdHM7IGNvZGUgYW5kIHJlZmxlY3QiLCJpbnRlcnZpZXdTdHJ1Y3R1cmUiOiJVc2UgZGVmaW5pdGlvbiDihpIgZXhhbXBsZSDihpIgdHJhZGUtb2ZmIOKGkiBjb21tb24gZmFpbHVyZSDihpIgcHJvZHVjdGlvbiBpbXBsaWNhdGlvbiJ9LHsicGxhbklkIjoiY2hyb25pcy1haS1lbmdpbmVlcmluZy0yMDI2LTExLTA1IiwiZGF5TnVtYmVyIjo4NSwiZGF0ZSI6IjIwMjctMDEtMjgiLCJ3ZWVrIjoxMywicGhhc2UiOiIwNyDCtyBBcmNoaXRlY3QgQ2Fwc3RvbmVzIiwicGhhc2VObyI6IjA3IiwicGhhc2VEYXkiOjYsInN1YnBoYXNlIjoiRG9jdW1lbnQgaW50ZWxsaWdlbmNlIiwiY29uY2VwdHMiOiJDb250cmFjdCBwYXJzaW5nLCBjbGF1c2UgZXh0cmFjdGlvbiwgc291cmNlIGV2aWRlbmNlIiwidGhlb3J5RGVsaXZlcmFibGUiOiJSZWFkICsgZGlhZ3JhbSArIDMgZmxhc2hjYXJkczsgaWRlbnRpZnkgMiBmYWlsdXJlIG1vZGVzIGluIGRvY3VtZW50IGludGVsbGlnZW5jZS4iLCJiYXNpY1Rhc2siOiJBbmFseXplIHNhbXBsZSBjb250cmFjdCBjbGF1c2VzIHdpdGggcmVmZXJlbmNlcyIsInNjZW5hcmlvIjoiQ2xhdXNlIGFic2VudDsgbW9kZWwgbXVzdCBhYnN0YWluIiwicHJvamVjdFdvcmtzdHJlYW0iOiJQNDkgwrcgQ29udHJhY3QgQ2xhdXNlIEludGVsbGlnZW5jZSBBc3Npc3RhbnQiLCJwcm9qZWN0SWQiOiJQNDkiLCJwcm9qZWN0VGFzayI6IlNUQVJUIFA0OSBDb250cmFjdCBDbGF1c2UgSW50ZWxsaWdlbmNlIEFzc2lzdGFudDogRXh0cmFjdCBhbmQgY29tcGFyZSBjb250cmFjdCBjbGF1c2VzIHdpdGggZXZpZGVuY2UgbGlua3MuIFNoaXAgc21hbGxlc3QgdmVyaWZpYWJsZSBzbGljZTsgZG9jdW1lbnQgdGVzdHMuIiwicHJvamVjdERlbGl2ZXJhYmxlIjoiUDQ5IGxhdW5jaDogR3JvdW5kZWQgcmVkLWZsYWcgY2xhc3NpZmljYXRpb24gb24gc2FtcGxlIGNsYXVzZXMiLCJpbnRlcnZpZXciOiJIb3cgcmVkdWNlIGxlZ2FsLXJpc2sgaGFsbHVjaW5hdGlvbnM/IiwiZXhpdENyaXRlcmlhIjoiRXhwbGFpbiBkb2N1bWVudCBpbnRlbGxpZ2VuY2UgaW4gMiBtaW51dGVzOyAxIHRlc3RlZCBjb21taXQ7IG9uZSBzY2VuYXJpbyBhbnN3ZXI7IDMvNSBpbnRlcnZpZXcgcHJhY3RpY2UgcXVlc3Rpb25zLiIsInBsYW5uZWRIb3VycyI6NiwicmVmZXJlbmNlVXJsIjoiaHR0cHM6Ly9kZXZlbG9wZXJzLm9wZW5haS5jb20vYXBpL2RvY3MvZ3VpZGVzL2FnZW50cy9zZGsiLCJzY2VuYXJpb0Zvcm1hdCI6IklucHV0cyDihpIgY29uc3RyYWludHMg4oaSIGVkZ2UgY2FzZXMg4oaSIGFsZ29yaXRobSDihpIgY29tcGxleGl0eSDihpIgdGVzdHM7IGNvZGUgYW5kIHJlZmxlY3QiLCJpbnRlcnZpZXdTdHJ1Y3R1cmUiOiJVc2UgZGVmaW5pdGlvbiDihpIgZXhhbXBsZSDihpIgdHJhZGUtb2ZmIOKGkiBjb21tb24gZmFpbHVyZSDihpIgcHJvZHVjdGlvbiBpbXBsaWNhdGlvbiJ9LHsicGxhbklkIjoiY2hyb25pcy1haS1lbmdpbmVlcmluZy0yMDI2LTExLTA1IiwiZGF5TnVtYmVyIjo4NiwiZGF0ZSI6IjIwMjctMDEtMjkiLCJ3ZWVrIjoxMywicGhhc2UiOiIwNyDCtyBBcmNoaXRlY3QgQ2Fwc3RvbmVzIiwicGhhc2VObyI6IjA3IiwicGhhc2VEYXkiOjcsInN1YnBoYXNlIjoiTm8tY29kZSBhZ2VudCBidWlsZGVyIEkiLCJjb25jZXB0cyI6IldvcmtmbG93IGVkaXRvciwgZ3JhcGggdmFsaWRhdGlvbiwgbm9kZSB0ZW1wbGF0ZXMiLCJ0aGVvcnlEZWxpdmVyYWJsZSI6IlJlYWQgKyBkaWFncmFtICsgMyBmbGFzaGNhcmRzOyBpZGVudGlmeSAyIGZhaWx1cmUgbW9kZXMgaW4gbm8tY29kZSBhZ2VudCBidWlsZGVyIGkuIiwiYmFzaWNUYXNrIjoiRGVzaWduIEpTT04gZ3JhcGggc2NoZW1hIGFuZCB2YWxpZGF0ZSBEQUciLCJzY2VuYXJpbyI6IkN5Y2xlcyBjYXVzZSBub250ZXJtaW5hdGluZyBleGVjdXRpb24iLCJwcm9qZWN0V29ya3N0cmVhbSI6IlAyOSDCtyBOby1Db2RlIEFJIEFnZW50IEJ1aWxkZXIgUGxhdGZvcm0iLCJwcm9qZWN0SWQiOiJQMjkiLCJwcm9qZWN0VGFzayI6IlNUQVJUIFAyOSBOby1Db2RlIEFJIEFnZW50IEJ1aWxkZXIgUGxhdGZvcm06IFZpc3VhbCB3b3JrZmxvdyBidWlsZGVyLjsgRHJhZy1hbmQtZHJvcCBhZ2VudCBub2Rlcy47IENvbm5lY3QgdG9vbHMgYW5kIG1vZGVscy4uIFNoaXAgc21hbGxlc3QgdmVyaWZpYWJsZSBzbGljZTsgZG9jdW1lbnQgdGVzdHMuIiwicHJvamVjdERlbGl2ZXJhYmxlIjoiUDI5IGxhdW5jaDogUnVubmFibGUgZGVtbzsgYXV0b21hdGVkIHRlc3RzOyBSRUFETUU7IHZpc3VhbCB3b3JrZmxvdyBidWlsZGVyLiIsImludGVydmlldyI6IkhvdyB2YWxpZGF0ZSB2aXN1YWwgd29ya2Zsb3cgcGxhbnM/IiwiZXhpdENyaXRlcmlhIjoiRXhwbGFpbiBuby1jb2RlIGFnZW50IGJ1aWxkZXIgaSBpbiAyIG1pbnV0ZXM7IDEgdGVzdGVkIGNvbW1pdDsgb25lIHNjZW5hcmlvIGFuc3dlcjsgMy81IGludGVydmlldyBwcmFjdGljZSBxdWVzdGlvbnMuIiwicGxhbm5lZEhvdXJzIjo2LCJyZWZlcmVuY2VVcmwiOiJodHRwczovL2RldmVsb3BlcnMub3BlbmFpLmNvbS9hcGkvZG9jcy9ndWlkZXMvYWdlbnRzL3NkayIsInNjZW5hcmlvRm9ybWF0IjoiSW5wdXRzIOKGkiBjb25zdHJhaW50cyDihpIgZWRnZSBjYXNlcyDihpIgYWxnb3JpdGhtIOKGkiBjb21wbGV4aXR5IOKGkiB0ZXN0czsgY29kZSBhbmQgcmVmbGVjdCIsImludGVydmlld1N0cnVjdHVyZSI6IlVzZSBkZWZpbml0aW9uIOKGkiBleGFtcGxlIOKGkiB0cmFkZS1vZmYg4oaSIGNvbW1vbiBmYWlsdXJlIOKGkiBwcm9kdWN0aW9uIGltcGxpY2F0aW9uIn0seyJwbGFuSWQiOiJjaHJvbmlzLWFpLWVuZ2luZWVyaW5nLTIwMjYtMTEtMDUiLCJkYXlOdW1iZXIiOjg3LCJkYXRlIjoiMjAyNy0wMS0zMCIsIndlZWsiOjEzLCJwaGFzZSI6IjA3IMK3IEFyY2hpdGVjdCBDYXBzdG9uZXMiLCJwaGFzZU5vIjoiMDciLCJwaGFzZURheSI6OCwic3VicGhhc2UiOiJOby1jb2RlIGFnZW50IGJ1aWxkZXIgSUkiLCJjb25jZXB0cyI6IkR5bmFtaWMgZXhlY3V0aW9uIGdyYXBoLCBhcHByb3ZhbCBub2RlcywgbG9ncyIsInRoZW9yeURlbGl2ZXJhYmxlIjoiUmVhZCArIGRpYWdyYW0gKyAzIGZsYXNoY2FyZHM7IGlkZW50aWZ5IDIgZmFpbHVyZSBtb2RlcyBpbiBuby1jb2RlIGFnZW50IGJ1aWxkZXIgaWkuIiwiYmFzaWNUYXNrIjoiUnVuIHNhdmVkIHdvcmtmbG93IEpTT04gdGhyb3VnaCBvcmNoZXN0cmF0b3IiLCJzY2VuYXJpbyI6IldvcmtmbG93IHZlcnNpb24gZWRpdGVkIGR1cmluZyBleGVjdXRpb24iLCJwcm9qZWN0V29ya3N0cmVhbSI6IlAyOSDCtyBOby1Db2RlIEFJIEFnZW50IEJ1aWxkZXIgUGxhdGZvcm0iLCJwcm9qZWN0SWQiOiJQMjkiLCJwcm9qZWN0VGFzayI6IklURVJBVEUgUDI5IE5vLUNvZGUgQUkgQWdlbnQgQnVpbGRlciBQbGF0Zm9ybTogYWRkIGVkZ2UtY2FzZSBoYW5kbGluZywgdGVzdCBmaXh0dXJlLCByZXN1bHQgbG9nIG9yIEFQSSBjb250cmFjdCBhbGlnbmVkIHRvIHRvZGF54oCZcyB0b3BpYy4iLCJwcm9qZWN0RGVsaXZlcmFibGUiOiJPbmUgdGVzdGVkIGluY3JlbWVudGFsIGNvbW1pdCBmb3IgUDI5OyBub3RlIG9wZW4gZm9sbG93LXVwcyBpbiBiYWNrbG9nLiIsImludGVydmlldyI6IkhvdyB2ZXJzaW9uIGR5bmFtaWMgd29ya2Zsb3dzIHNhZmVseT8iLCJleGl0Q3JpdGVyaWEiOiJFeHBsYWluIG5vLWNvZGUgYWdlbnQgYnVpbGRlciBpaSBpbiAyIG1pbnV0ZXM7IDEgdGVzdGVkIGNvbW1pdDsgb25lIHNjZW5hcmlvIGFuc3dlcjsgMy81IGludGVydmlldyBwcmFjdGljZSBxdWVzdGlvbnMuIiwicGxhbm5lZEhvdXJzIjo2LCJyZWZlcmVuY2VVcmwiOiJodHRwczovL2RldmVsb3BlcnMub3BlbmFpLmNvbS9hcGkvZG9jcy9ndWlkZXMvYWdlbnRzL3NkayIsInNjZW5hcmlvRm9ybWF0IjoiSW5wdXRzIOKGkiBjb25zdHJhaW50cyDihpIgZWRnZSBjYXNlcyDihpIgYWxnb3JpdGhtIOKGkiBjb21wbGV4aXR5IOKGkiB0ZXN0czsgY29kZSBhbmQgcmVmbGVjdCIsImludGVydmlld1N0cnVjdHVyZSI6IlVzZSBkZWZpbml0aW9uIOKGkiBleGFtcGxlIOKGkiB0cmFkZS1vZmYg4oaSIGNvbW1vbiBmYWlsdXJlIOKGkiBwcm9kdWN0aW9uIGltcGxpY2F0aW9uIn0seyJwbGFuSWQiOiJjaHJvbmlzLWFpLWVuZ2luZWVyaW5nLTIwMjYtMTEtMDUiLCJkYXlOdW1iZXIiOjg4LCJkYXRlIjoiMjAyNy0wMS0zMSIsIndlZWsiOjEzLCJwaGFzZSI6IjA3IMK3IEFyY2hpdGVjdCBDYXBzdG9uZXMiLCJwaGFzZU5vIjoiMDciLCJwaGFzZURheSI6OSwic3VicGhhc2UiOiJFbnRlcnByaXNlIHBsYXRmb3JtIEkiLCJjb25jZXB0cyI6IkxMTSBnYXRld2F5LCBSQUcsIG11bHRpLWFnZW50LCB0ZW5hbnRzLCBBUElzIiwidGhlb3J5RGVsaXZlcmFibGUiOiJSZWFkICsgZGlhZ3JhbSArIDMgZmxhc2hjYXJkczsgaWRlbnRpZnkgMiBmYWlsdXJlIG1vZGVzIGluIGVudGVycHJpc2UgcGxhdGZvcm0gaS4iLCJiYXNpY1Rhc2siOiJDb21wb3NlIHBsYXRmb3JtIHNlcnZpY2VzIGluIGxvY2FsIERvY2tlciBzdGFjayIsInNjZW5hcmlvIjoiT25lIHRlbmFudCBleGhhdXN0cyBzaGFyZWQgcmF0ZSBxdW90YSIsInByb2plY3RXb3Jrc3RyZWFtIjoiUDMwIMK3IEVudGVycHJpc2UgQUkgT3BlcmF0aW5nIFBsYXRmb3JtIiwicHJvamVjdElkIjoiUDMwIiwicHJvamVjdFRhc2siOiJTVEFSVCBQMzAgRW50ZXJwcmlzZSBBSSBPcGVyYXRpbmcgUGxhdGZvcm06IE11bHRpLW1vZGVsIExMTSBnYXRld2F5LjsgUkFHIGFuZCBHcmFwaFJBRy47IE11bHRpLWFnZW50IG9yY2hlc3RyYXRpb24uLiBTaGlwIHNtYWxsZXN0IHZlcmlmaWFibGUgc2xpY2U7IGRvY3VtZW50IHRlc3RzLiIsInByb2plY3REZWxpdmVyYWJsZSI6IlAzMCBsYXVuY2g6IFJ1bm5hYmxlIGRlbW87IGF1dG9tYXRlZCB0ZXN0czsgUkVBRE1FOyBtdWx0aS1tb2RlbCBsbG0gZ2F0ZXdheS4iLCJpbnRlcnZpZXciOiJIb3cgaXNvbGF0ZSByZXNvdXJjZSBsaW1pdHMgcGVyIHRlbmFudD8iLCJleGl0Q3JpdGVyaWEiOiJFeHBsYWluIGVudGVycHJpc2UgcGxhdGZvcm0gaSBpbiAyIG1pbnV0ZXM7IDEgdGVzdGVkIGNvbW1pdDsgb25lIHNjZW5hcmlvIGFuc3dlcjsgMy81IGludGVydmlldyBwcmFjdGljZSBxdWVzdGlvbnMuIiwicGxhbm5lZEhvdXJzIjo2LCJyZWZlcmVuY2VVcmwiOiJodHRwczovL2RldmVsb3BlcnMub3BlbmFpLmNvbS9hcGkvZG9jcy9ndWlkZXMvYWdlbnRzL3NkayIsInNjZW5hcmlvRm9ybWF0IjoiSW5wdXRzIOKGkiBjb25zdHJhaW50cyDihpIgZWRnZSBjYXNlcyDihpIgYWxnb3JpdGhtIOKGkiBjb21wbGV4aXR5IOKGkiB0ZXN0czsgY29kZSBhbmQgcmVmbGVjdCIsImludGVydmlld1N0cnVjdHVyZSI6IlVzZSBkZWZpbml0aW9uIOKGkiBleGFtcGxlIOKGkiB0cmFkZS1vZmYg4oaSIGNvbW1vbiBmYWlsdXJlIOKGkiBwcm9kdWN0aW9uIGltcGxpY2F0aW9uIn0seyJwbGFuSWQiOiJjaHJvbmlzLWFpLWVuZ2luZWVyaW5nLTIwMjYtMTEtMDUiLCJkYXlOdW1iZXIiOjg5LCJkYXRlIjoiMjAyNy0wMi0wMSIsIndlZWsiOjEzLCJwaGFzZSI6IjA3IMK3IEFyY2hpdGVjdCBDYXBzdG9uZXMiLCJwaGFzZU5vIjoiMDciLCJwaGFzZURheSI6MTAsInN1YnBoYXNlIjoiR292ZXJuYW5jZSBjb250cm9scyIsImNvbmNlcHRzIjoiUG9saWN5LWFzLWNvZGUsIHJpc2sgdGllcnMsIGF1ZGl0LCBhcHByb3ZhbCBjaGFpbiIsInRoZW9yeURlbGl2ZXJhYmxlIjoiUmVhZCArIGRpYWdyYW0gKyAzIGZsYXNoY2FyZHM7IGlkZW50aWZ5IDIgZmFpbHVyZSBtb2RlcyBpbiBnb3Zlcm5hbmNlIGNvbnRyb2xzLiIsImJhc2ljVGFzayI6IkJ1aWxkIHBvbGljeSBjaGVja3MgZm9yIHRvb2wgYWN0aW9ucyIsInNjZW5hcmlvIjoiTW9kZWwgcHJvcG9zZXMgdW5zYWZlIGRhdGEgZXhwb3J0IiwicHJvamVjdFdvcmtzdHJlYW0iOiJQNTAgwrcgQUkgR292ZXJuYW5jZSAmIFBvbGljeSBDb250cm9sIENlbnRlciIsInByb2plY3RJZCI6IlA1MCIsInByb2plY3RUYXNrIjoiU1RBUlQgUDUwIEFJIEdvdmVybmFuY2UgJiBQb2xpY3kgQ29udHJvbCBDZW50ZXI6IENvbmZpZ3VyZSBwb2xpY3kgcnVsZXMsIGFwcHJvdmFsIGdhdGVzIGFuZCBhdWRpdCBoaXN0b3J5LiBTaGlwIHNtYWxsZXN0IHZlcmlmaWFibGUgc2xpY2U7IGRvY3VtZW50IHRlc3RzLiIsInByb2plY3REZWxpdmVyYWJsZSI6IlA1MCBsYXVuY2g6IERlbmllZCB1bnNhZmUgdG9vbCBhY3Rpb24gc3RheXMgZGVuaWVkIGFuZCBhdWRpdGFibGUiLCJpbnRlcnZpZXciOiJIb3cgZW5mb3JjZSBub24tYnlwYXNzYWJsZSBwb2xpY3kgZ2F0ZXM/IiwiZXhpdENyaXRlcmlhIjoiRXhwbGFpbiBnb3Zlcm5hbmNlIGNvbnRyb2xzIGluIDIgbWludXRlczsgMSB0ZXN0ZWQgY29tbWl0OyBvbmUgc2NlbmFyaW8gYW5zd2VyOyAzLzUgaW50ZXJ2aWV3IHByYWN0aWNlIHF1ZXN0aW9ucy4iLCJwbGFubmVkSG91cnMiOjYsInJlZmVyZW5jZVVybCI6Imh0dHBzOi8vZGV2ZWxvcGVycy5vcGVuYWkuY29tL2FwaS9kb2NzL2d1aWRlcy9hZ2VudHMvc2RrIiwic2NlbmFyaW9Gb3JtYXQiOiJJbnB1dHMg4oaSIGNvbnN0cmFpbnRzIOKGkiBlZGdlIGNhc2VzIOKGkiBhbGdvcml0aG0g4oaSIGNvbXBsZXhpdHkg4oaSIHRlc3RzOyBjb2RlIGFuZCByZWZsZWN0IiwiaW50ZXJ2aWV3U3RydWN0dXJlIjoiVXNlIGRlZmluaXRpb24g4oaSIGV4YW1wbGUg4oaSIHRyYWRlLW9mZiDihpIgY29tbW9uIGZhaWx1cmUg4oaSIHByb2R1Y3Rpb24gaW1wbGljYXRpb24ifSx7InBsYW5JZCI6ImNocm9uaXMtYWktZW5naW5lZXJpbmctMjAyNi0xMS0wNSIsImRheU51bWJlciI6OTAsImRhdGUiOiIyMDI3LTAyLTAyIiwid2VlayI6MTMsInBoYXNlIjoiMDcgwrcgQXJjaGl0ZWN0IENhcHN0b25lcyIsInBoYXNlTm8iOiIwNyIsInBoYXNlRGF5IjoxMSwic3VicGhhc2UiOiJDYXBzdG9uZSB2ZXJpZmljYXRpb24iLCJjb25jZXB0cyI6IkFyY2hpdGVjdHVyZSwgaW50ZWdyYXRlZCB0ZXN0cywgYmVuY2htYXJrLCBkZW1vIiwidGhlb3J5RGVsaXZlcmFibGUiOiJSZWFkICsgZGlhZ3JhbSArIDMgZmxhc2hjYXJkczsgaWRlbnRpZnkgMiBmYWlsdXJlIG1vZGVzIGluIGNhcHN0b25lIHZlcmlmaWNhdGlvbi4iLCJiYXNpY1Rhc2siOiJSZWNvcmQgZGVwbG95YWJsZSBtaW5pLXBsYXRmb3JtIHdpdGggZXZhbHVhdGlvbiByZXBvcnQiLCJzY2VuYXJpbyI6IlN5c3RlbSBvdXRhZ2UgYW5kIGF1ZGl0IHRyYWlsIGdhcHMgaW4gZmluYWwgZGVtbyIsInByb2plY3RXb3Jrc3RyZWFtIjoiUDUwIMK3IEFJIEdvdmVybmFuY2UgJiBQb2xpY3kgQ29udHJvbCBDZW50ZXIiLCJwcm9qZWN0SWQiOiJQNTAiLCJwcm9qZWN0VGFzayI6IklURVJBVEUgUDUwIEFJIEdvdmVybmFuY2UgJiBQb2xpY3kgQ29udHJvbCBDZW50ZXI6IGFkZCBlZGdlLWNhc2UgaGFuZGxpbmcsIHRlc3QgZml4dHVyZSwgcmVzdWx0IGxvZyBvciBBUEkgY29udHJhY3QgYWxpZ25lZCB0byB0b2RheeKAmXMgdG9waWMuIiwicHJvamVjdERlbGl2ZXJhYmxlIjoiT25lIHRlc3RlZCBpbmNyZW1lbnRhbCBjb21taXQgZm9yIFA1MDsgbm90ZSBvcGVuIGZvbGxvdy11cHMgaW4gYmFja2xvZy4iLCJpbnRlcnZpZXciOiJXaGF0IGV2aWRlbmNlIHByb3ZlcyBwcm9kdWN0aW9uIHJlYWRpbmVzcz8iLCJleGl0Q3JpdGVyaWEiOiJFeHBsYWluIGNhcHN0b25lIHZlcmlmaWNhdGlvbiBpbiAyIG1pbnV0ZXM7IDEgdGVzdGVkIGNvbW1pdDsgb25lIHNjZW5hcmlvIGFuc3dlcjsgMy81IGludGVydmlldyBwcmFjdGljZSBxdWVzdGlvbnMuIiwicGxhbm5lZEhvdXJzIjo2LCJyZWZlcmVuY2VVcmwiOiJodHRwczovL2RldmVsb3BlcnMub3BlbmFpLmNvbS9hcGkvZG9jcy9ndWlkZXMvYWdlbnRzL3NkayIsInNjZW5hcmlvRm9ybWF0IjoiSW5wdXRzIOKGkiBjb25zdHJhaW50cyDihpIgZWRnZSBjYXNlcyDihpIgYWxnb3JpdGhtIOKGkiBjb21wbGV4aXR5IOKGkiB0ZXN0czsgY29kZSBhbmQgcmVmbGVjdCIsImludGVydmlld1N0cnVjdHVyZSI6IlVzZSBkZWZpbml0aW9uIOKGkiBleGFtcGxlIOKGkiB0cmFkZS1vZmYg4oaSIGNvbW1vbiBmYWlsdXJlIOKGkiBwcm9kdWN0aW9uIGltcGxpY2F0aW9uIn0seyJwbGFuSWQiOiJjaHJvbmlzLWFpLWVuZ2luZWVyaW5nLTIwMjYtMTEtMDUiLCJkYXlOdW1iZXIiOjkxLCJkYXRlIjoiMjAyNy0wMi0wMyIsIndlZWsiOjEzLCJwaGFzZSI6IjA4IMK3IENhcmVlciBSZWFkaW5lc3MiLCJwaGFzZU5vIjoiMDgiLCJwaGFzZURheSI6MSwic3VicGhhc2UiOiJQb3J0Zm9saW8gJiBpbnRlcnZpZXdzIiwiY29uY2VwdHMiOiJSZXN1bWUgU1RBUiBzdG9yaWVzLCBHaXRIdWIgUkVBRE1FcywgQUkgY2FzZSBzdHVkaWVzIiwidGhlb3J5RGVsaXZlcmFibGUiOiJSZWFkICsgZGlhZ3JhbSArIDMgZmxhc2hjYXJkczsgaWRlbnRpZnkgMiBmYWlsdXJlIG1vZGVzIGluIHBvcnRmb2xpbyAmIGludGVydmlld3MuIiwiYmFzaWNUYXNrIjoiV3JpdGUgcHJvamVjdCBSRUFETUUgd2l0aCBtZWFzdXJlZCBtZXRyaWNzIGFuZCB0cmFkZS1vZmZzIiwic2NlbmFyaW8iOiJEZWZlbmQgYSBkZWNpc2lvbiB0byB1c2UgUkFHIHJhdGhlciB0aGFuIGZpbmUtdHVuaW5nIiwicHJvamVjdFdvcmtzdHJlYW0iOiJQNTAgwrcgQUkgR292ZXJuYW5jZSAmIFBvbGljeSBDb250cm9sIENlbnRlciIsInByb2plY3RJZCI6IlA1MCIsInByb2plY3RUYXNrIjoiSVRFUkFURSBQNTAgQUkgR292ZXJuYW5jZSAmIFBvbGljeSBDb250cm9sIENlbnRlcjogYWRkIGVkZ2UtY2FzZSBoYW5kbGluZywgdGVzdCBmaXh0dXJlLCByZXN1bHQgbG9nIG9yIEFQSSBjb250cmFjdCBhbGlnbmVkIHRvIHRvZGF54oCZcyB0b3BpYy4iLCJwcm9qZWN0RGVsaXZlcmFibGUiOiJPbmUgdGVzdGVkIGluY3JlbWVudGFsIGNvbW1pdCBmb3IgUDUwOyBub3RlIG9wZW4gZm9sbG93LXVwcyBpbiBiYWNrbG9nLiIsImludGVydmlldyI6IkRlc2NyaWJlIGhhcmRlc3QgcHJvZHVjdGlvbiBmYWlsdXJlIGFuZCB5b3VyIGZpeD8iLCJleGl0Q3JpdGVyaWEiOiJFeHBsYWluIHBvcnRmb2xpbyAmIGludGVydmlld3MgaW4gMiBtaW51dGVzOyAxIHRlc3RlZCBjb21taXQ7IG9uZSBzY2VuYXJpbyBhbnN3ZXI7IDMvNSBpbnRlcnZpZXcgcHJhY3RpY2UgcXVlc3Rpb25zLiIsInBsYW5uZWRIb3VycyI6NiwicmVmZXJlbmNlVXJsIjoiaHR0cHM6Ly9naXRodWIuY29tL3JlYWRtZSIsInNjZW5hcmlvRm9ybWF0IjoiSW5wdXRzIOKGkiBjb25zdHJhaW50cyDihpIgZWRnZSBjYXNlcyDihpIgYWxnb3JpdGhtIOKGkiBjb21wbGV4aXR5IOKGkiB0ZXN0czsgY29kZSBhbmQgcmVmbGVjdCIsImludGVydmlld1N0cnVjdHVyZSI6IlVzZSBkZWZpbml0aW9uIOKGkiBleGFtcGxlIOKGkiB0cmFkZS1vZmYg4oaSIGNvbW1vbiBmYWlsdXJlIOKGkiBwcm9kdWN0aW9uIGltcGxpY2F0aW9uIn0seyJwbGFuSWQiOiJjaHJvbmlzLWFpLWVuZ2luZWVyaW5nLTIwMjYtMTEtMDUiLCJkYXlOdW1iZXIiOjkyLCJkYXRlIjoiMjAyNy0wMi0wNCIsIndlZWsiOjE0LCJwaGFzZSI6IjA4IMK3IENhcmVlciBSZWFkaW5lc3MiLCJwaGFzZU5vIjoiMDgiLCJwaGFzZURheSI6Miwic3VicGhhc2UiOiJTeXN0ZW0gZGVzaWduIG1vY2siLCJjb25jZXB0cyI6IkFJIGFyY2hpdGVjdHVyZSwgYWdlbnQgb3JjaGVzdHJhdGlvbiwgY29kaW5nIG1vY2ssIHJldHJvc3BlY3RpdmUiLCJ0aGVvcnlEZWxpdmVyYWJsZSI6IlJlYWQgKyBkaWFncmFtICsgMyBmbGFzaGNhcmRzOyBpZGVudGlmeSAyIGZhaWx1cmUgbW9kZXMgaW4gc3lzdGVtIGRlc2lnbiBtb2NrLiIsImJhc2ljVGFzayI6IkNvbXBsZXRlIHRpbWVkIEFJIGFyY2hpdGVjdHVyZSBkZXNpZ24gKyAyIGNvZGluZyB0YXNrcyIsInNjZW5hcmlvIjoiRGVzaWduIG11bHRpdGVuYW50IFJBRyB3aXRoIHBvbGljeS1ib3VuZCB0b29sIGV4ZWN1dGlvbiIsInByb2plY3RXb3Jrc3RyZWFtIjoiUDUwIMK3IEFJIEdvdmVybmFuY2UgJiBQb2xpY3kgQ29udHJvbCBDZW50ZXIiLCJwcm9qZWN0SWQiOiJQNTAiLCJwcm9qZWN0VGFzayI6IklURVJBVEUgUDUwIEFJIEdvdmVybmFuY2UgJiBQb2xpY3kgQ29udHJvbCBDZW50ZXI6IGFkZCBlZGdlLWNhc2UgaGFuZGxpbmcsIHRlc3QgZml4dHVyZSwgcmVzdWx0IGxvZyBvciBBUEkgY29udHJhY3QgYWxpZ25lZCB0byB0b2RheeKAmXMgdG9waWMuIiwicHJvamVjdERlbGl2ZXJhYmxlIjoiT25lIHRlc3RlZCBpbmNyZW1lbnRhbCBjb21taXQgZm9yIFA1MDsgbm90ZSBvcGVuIGZvbGxvdy11cHMgaW4gYmFja2xvZy4iLCJpbnRlcnZpZXciOiJIb3cgd291bGQgeW91IGFyY2hpdGVjdCBzZWN1cmUgZW50ZXJwcmlzZSBBSSBwbGF0Zm9ybT8iLCJleGl0Q3JpdGVyaWEiOiJFeHBsYWluIHN5c3RlbSBkZXNpZ24gbW9jayBpbiAyIG1pbnV0ZXM7IDEgdGVzdGVkIGNvbW1pdDsgb25lIHNjZW5hcmlvIGFuc3dlcjsgMy81IGludGVydmlldyBwcmFjdGljZSBxdWVzdGlvbnMuIiwicGxhbm5lZEhvdXJzIjo2LCJyZWZlcmVuY2VVcmwiOiJodHRwczovL2dpdGh1Yi5jb20vcmVhZG1lIiwic2NlbmFyaW9Gb3JtYXQiOiJJbnB1dHMg4oaSIGNvbnN0cmFpbnRzIOKGkiBlZGdlIGNhc2VzIOKGkiBhbGdvcml0aG0g4oaSIGNvbXBsZXhpdHkg4oaSIHRlc3RzOyBjb2RlIGFuZCByZWZsZWN0IiwiaW50ZXJ2aWV3U3RydWN0dXJlIjoiVXNlIGRlZmluaXRpb24g4oaSIGV4YW1wbGUg4oaSIHRyYWRlLW9mZiDihpIgY29tbW9uIGZhaWx1cmUg4oaSIHByb2R1Y3Rpb24gaW1wbGljYXRpb24ifV0sInByb2plY3RzIjpbeyJwbGFuSWQiOiJjaHJvbmlzLWFpLWVuZ2luZWVyaW5nLTIwMjYtMTEtMDUiLCJpZCI6IlAwMSIsInRpdGxlIjoiSW50ZWxsaWdlbnQgRGF0YSBBbmFseXplciIsImxldmVsIjoiQmVnaW5uZXIiLCJwaGFzZSI6IjAxIMK3IFB5dGhvbiAmIEZvdW5kYXRpb25zIiwic3RhcnREYXkiOjgsImZpcnN0U3ByaW50IjoiMjAyNi0xMS0xMiIsInN0YWNrIjoiUHl0aG9uLCBQYW5kYXMsIE51bVB5LCBNYXRwbG90bGliIiwibXZwIjoiVXBsb2FkIENTViBhbmQgRXhjZWwgZmlsZXMuOyBBbmFseXplIG1pc3NpbmcgdmFsdWVzIGFuZCBvdXRsaWVycy47IEdlbmVyYXRlIHN0YXRpc3RpY2FsIHJlcG9ydHMuIiwiZmVhdHVyZXMiOiJVcGxvYWQgQ1NWIGFuZCBFeGNlbCBmaWxlcy47IEFuYWx5emUgbWlzc2luZyB2YWx1ZXMgYW5kIG91dGxpZXJzLjsgR2VuZXJhdGUgc3RhdGlzdGljYWwgcmVwb3J0cy47IENyZWF0ZSB2aXN1YWxpemF0aW9ucy47IElkZW50aWZ5IGRhdGEtcXVhbGl0eSBpc3N1ZXMuIiwiYWNjZXB0YW5jZSI6IlJ1bm5hYmxlIGRlbW87IGF1dG9tYXRlZCB0ZXN0czsgUkVBRE1FOyB1cGxvYWQgY3N2IGFuZCBleGNlbCBmaWxlcy4iLCJpbnRlcnZpZXdUb3BpYyI6IlB5dGhvbiwgUGFuZGFzLCBkYXRhIHN0cnVjdHVyZXMsIHN0YXRpc3RpY3MuIiwicHJpb3JpdHkiOiJQb3J0Zm9saW8iLCJzb3VyY2UiOiJPcmlnaW5hbCAx4oCTMzAgKHVzZXIgc291cmNlKSIsInByb3ZlbmFuY2UiOiJvcmlnaW5hbCIsInByZXJlcXVpc2l0ZXMiOiJQeXRob24gYmFzaWNzIiwiZXN0SG91cnMiOjR9LHsicGxhbklkIjoiY2hyb25pcy1haS1lbmdpbmVlcmluZy0yMDI2LTExLTA1IiwiaWQiOiJQMDIiLCJ0aXRsZSI6IkhvdXNlIFByaWNlIFByZWRpY3Rpb24iLCJsZXZlbCI6IkJlZ2lubmVyIiwicGhhc2UiOiIwMiDCtyBDbGFzc2ljYWwgTUwiLCJzdGFydERheSI6MTEsImZpcnN0U3ByaW50IjoiMjAyNi0xMS0xNSIsInN0YWNrIjoiUHl0aG9uLCBTY2lraXQtbGVhcm4sIFBhbmRhcyIsIm12cCI6IkRhdGFzZXQgcHJlcHJvY2Vzc2luZy47IExpbmVhciBhbmQgbXVsdGlwbGUgcmVncmVzc2lvbi47IEZlYXR1cmUgZW5naW5lZXJpbmcuIiwiZmVhdHVyZXMiOiJEYXRhc2V0IHByZXByb2Nlc3NpbmcuOyBMaW5lYXIgYW5kIG11bHRpcGxlIHJlZ3Jlc3Npb24uOyBGZWF0dXJlIGVuZ2luZWVyaW5nLjsgTW9kZWwgdHJhaW5pbmcgYW5kIGV2YWx1YXRpb24uOyBQcmVkaWN0aW9uIEFQSS4iLCJhY2NlcHRhbmNlIjoiUnVubmFibGUgZGVtbzsgYXV0b21hdGVkIHRlc3RzOyBSRUFETUU7IGRhdGFzZXQgcHJlcHJvY2Vzc2luZy4iLCJpbnRlcnZpZXdUb3BpYyI6IlJlZ3Jlc3Npb24sIGxvc3MgZnVuY3Rpb25zLCBNQUUsIE1TRSwgUk1TRS4iLCJwcmlvcml0eSI6IlBvcnRmb2xpbyIsInNvdXJjZSI6Ik9yaWdpbmFsIDHigJMzMCAodXNlciBzb3VyY2UpIiwicHJvdmVuYW5jZSI6Im9yaWdpbmFsIiwicHJlcmVxdWlzaXRlcyI6IlB5dGhvbiBiYXNpY3MiLCJlc3RIb3VycyI6NH0seyJwbGFuSWQiOiJjaHJvbmlzLWFpLWVuZ2luZWVyaW5nLTIwMjYtMTEtMDUiLCJpZCI6IlAwMyIsInRpdGxlIjoiSW50ZWxsaWdlbnQgU3BhbSBEZXRlY3Rpb24iLCJsZXZlbCI6IkJlZ2lubmVyIiwicGhhc2UiOiIwMiDCtyBDbGFzc2ljYWwgTUwiLCJzdGFydERheSI6MTMsImZpcnN0U3ByaW50IjoiMjAyNi0xMS0xNyIsInN0YWNrIjoiUHl0aG9uLCBTY2lraXQtbGVhcm4sIE5MUCIsIm12cCI6IlRleHQgcHJlcHJvY2Vzc2luZy47IFRva2VuaXphdGlvbi47IFRGLUlERi4iLCJmZWF0dXJlcyI6IlRleHQgcHJlcHJvY2Vzc2luZy47IFRva2VuaXphdGlvbi47IFRGLUlERi47IE5haXZlIEJheWVzIGNsYXNzaWZpY2F0aW9uLjsgUHJlY2lzaW9uLCByZWNhbGwgYW5kIEYxIGV2YWx1YXRpb24uIiwiYWNjZXB0YW5jZSI6IlJ1bm5hYmxlIGRlbW87IGF1dG9tYXRlZCB0ZXN0czsgUkVBRE1FOyB0ZXh0IHByZXByb2Nlc3NpbmcuIiwiaW50ZXJ2aWV3VG9waWMiOiJDbGFzc2lmaWNhdGlvbiwgTkxQIHByZXByb2Nlc3NpbmcsIGNvbmZ1c2lvbiBtYXRyaXguIiwicHJpb3JpdHkiOiJQb3J0Zm9saW8iLCJzb3VyY2UiOiJPcmlnaW5hbCAx4oCTMzAgKHVzZXIgc291cmNlKSIsInByb3ZlbmFuY2UiOiJvcmlnaW5hbCIsInByZXJlcXVpc2l0ZXMiOiJQeXRob24gYmFzaWNzIiwiZXN0SG91cnMiOjR9LHsicGxhbklkIjoiY2hyb25pcy1haS1lbmdpbmVlcmluZy0yMDI2LTExLTA1IiwiaWQiOiJQMDQiLCJ0aXRsZSI6IkN1c3RvbWVyIENodXJuIFByZWRpY3Rpb24iLCJsZXZlbCI6IkludGVybWVkaWF0ZSIsInBoYXNlIjoiMDIgwrcgQ2xhc3NpY2FsIE1MIiwic3RhcnREYXkiOjE1LCJmaXJzdFNwcmludCI6IjIwMjYtMTEtMTkiLCJzdGFjayI6IlB5dGhvbiwgUGFuZGFzLCBTY2lraXQtbGVhcm4sIFhHQm9vc3QiLCJtdnAiOiJBbmFseXplIGN1c3RvbWVyIGJlaGF2aW91ci47IEZlYXR1cmUgc2VsZWN0aW9uLjsgVHJhaW4gbXVsdGlwbGUgY2xhc3NpZmllcnMuIiwiZmVhdHVyZXMiOiJBbmFseXplIGN1c3RvbWVyIGJlaGF2aW91ci47IEZlYXR1cmUgc2VsZWN0aW9uLjsgVHJhaW4gbXVsdGlwbGUgY2xhc3NpZmllcnMuOyBIYW5kbGUgY2xhc3MgaW1iYWxhbmNlLjsgSWRlbnRpZnkgY3VzdG9tZXJzIGF0IHJpc2suIiwiYWNjZXB0YW5jZSI6IlJ1bm5hYmxlIGRlbW87IGF1dG9tYXRlZCB0ZXN0czsgUkVBRE1FOyBhbmFseXplIGN1c3RvbWVyIGJlaGF2aW91ci4iLCJpbnRlcnZpZXdUb3BpYyI6Ik92ZXJmaXR0aW5nLCBjcm9zcy12YWxpZGF0aW9uLCBjbGFzcyBpbWJhbGFuY2UsIGZlYXR1cmUgaW1wb3J0YW5jZS4iLCJwcmlvcml0eSI6IlByb3RvdHlwZSIsInNvdXJjZSI6Ik9yaWdpbmFsIDHigJMzMCAodXNlciBzb3VyY2UpIiwicHJvdmVuYW5jZSI6Im9yaWdpbmFsIiwicHJlcmVxdWlzaXRlcyI6IlB5dGhvbiBiYXNpY3MiLCJlc3RIb3VycyI6OH0seyJwbGFuSWQiOiJjaHJvbmlzLWFpLWVuZ2luZWVyaW5nLTIwMjYtMTEtMDUiLCJpZCI6IlAwNSIsInRpdGxlIjoiTW92aWUgUmVjb21tZW5kYXRpb24gRW5naW5lIiwibGV2ZWwiOiJJbnRlcm1lZGlhdGUiLCJwaGFzZSI6IjAyIMK3IENsYXNzaWNhbCBNTCIsInN0YXJ0RGF5IjoxNywiZmlyc3RTcHJpbnQiOiIyMDI2LTExLTIxIiwic3RhY2siOiJQeXRob24sIFBhbmRhcywgU2Npa2l0LWxlYXJuIiwibXZwIjoiQ29udGVudC1iYXNlZCBmaWx0ZXJpbmcuOyBDb2xsYWJvcmF0aXZlIGZpbHRlcmluZy47IENvc2luZSBzaW1pbGFyaXR5LiIsImZlYXR1cmVzIjoiQ29udGVudC1iYXNlZCBmaWx0ZXJpbmcuOyBDb2xsYWJvcmF0aXZlIGZpbHRlcmluZy47IENvc2luZSBzaW1pbGFyaXR5LjsgVXNlci1pdGVtIG1hdHJpY2VzLjsgUmVjb21tZW5kYXRpb24gcmFua2luZy4iLCJhY2NlcHRhbmNlIjoiUnVubmFibGUgZGVtbzsgYXV0b21hdGVkIHRlc3RzOyBSRUFETUU7IGNvbnRlbnQtYmFzZWQgZmlsdGVyaW5nLiIsImludGVydmlld1RvcGljIjoiU2ltaWxhcml0eSwgbWF0cml4IG9wZXJhdGlvbnMsIHJlY29tbWVuZGF0aW9uIGFsZ29yaXRobXMuIiwicHJpb3JpdHkiOiJQcm90b3R5cGUiLCJzb3VyY2UiOiJPcmlnaW5hbCAx4oCTMzAgKHVzZXIgc291cmNlKSIsInByb3ZlbmFuY2UiOiJvcmlnaW5hbCIsInByZXJlcXVpc2l0ZXMiOiJQeXRob24gYmFzaWNzIiwiZXN0SG91cnMiOjh9LHsicGxhbklkIjoiY2hyb25pcy1haS1lbmdpbmVlcmluZy0yMDI2LTExLTA1IiwiaWQiOiJQMDYiLCJ0aXRsZSI6IkhhbmR3cml0dGVuIERpZ2l0IFJlY29nbml0aW9uIiwibGV2ZWwiOiJJbnRlcm1lZGlhdGUiLCJwaGFzZSI6IjAzIMK3IERlZXAgTGVhcm5pbmcgJiBOTFAiLCJzdGFydERheSI6MjMsImZpcnN0U3ByaW50IjoiMjAyNi0xMS0yNyIsInN0YWNrIjoiUHl0aG9uLCBOdW1QeSwgUHlUb3JjaCIsIm12cCI6IkltcGxlbWVudCBuZXVyYWwgbmV0d29ya3MuOyBGb3J3YXJkIGFuZCBiYWNrd2FyZCBwcm9wYWdhdGlvbi47IFRyYWluIG9uIE1OSVNULiIsImZlYXR1cmVzIjoiSW1wbGVtZW50IG5ldXJhbCBuZXR3b3Jrcy47IEZvcndhcmQgYW5kIGJhY2t3YXJkIHByb3BhZ2F0aW9uLjsgVHJhaW4gb24gTU5JU1QuOyBFdmFsdWF0ZSBjbGFzc2lmaWNhdGlvbiBhY2N1cmFjeS4iLCJhY2NlcHRhbmNlIjoiUnVubmFibGUgZGVtbzsgYXV0b21hdGVkIHRlc3RzOyBSRUFETUU7IGltcGxlbWVudCBuZXVyYWwgbmV0d29ya3MuIiwiaW50ZXJ2aWV3VG9waWMiOiJOZXVyb25zLCBhY3RpdmF0aW9uIGZ1bmN0aW9ucywgZ3JhZGllbnRzLCBiYWNrcHJvcGFnYXRpb24uIiwicHJpb3JpdHkiOiJQb3J0Zm9saW8iLCJzb3VyY2UiOiJPcmlnaW5hbCAx4oCTMzAgKHVzZXIgc291cmNlKSIsInByb3ZlbmFuY2UiOiJvcmlnaW5hbCIsInByZXJlcXVpc2l0ZXMiOiJNTCBjb25jZXB0cyIsImVzdEhvdXJzIjo4fSx7InBsYW5JZCI6ImNocm9uaXMtYWktZW5naW5lZXJpbmctMjAyNi0xMS0wNSIsImlkIjoiUDA3IiwidGl0bGUiOiJJbWFnZSBDbGFzc2lmaWNhdGlvbiBTeXN0ZW0iLCJsZXZlbCI6IkludGVybWVkaWF0ZSIsInBoYXNlIjoiMDMgwrcgRGVlcCBMZWFybmluZyAmIE5MUCIsInN0YXJ0RGF5IjoyNSwiZmlyc3RTcHJpbnQiOiIyMDI2LTExLTI5Iiwic3RhY2siOiJQeVRvcmNoLCBDTk4sIE9wZW5DViIsIm12cCI6IkltYWdlIHByZXByb2Nlc3NpbmcuOyBDb252b2x1dGlvbiBhbmQgcG9vbGluZy47IENOTiB0cmFpbmluZy4iLCJmZWF0dXJlcyI6IkltYWdlIHByZXByb2Nlc3NpbmcuOyBDb252b2x1dGlvbiBhbmQgcG9vbGluZy47IENOTiB0cmFpbmluZy47IFRyYW5zZmVyIGxlYXJuaW5nLjsgTW9kZWwgZXZhbHVhdGlvbi4iLCJhY2NlcHRhbmNlIjoiUnVubmFibGUgZGVtbzsgYXV0b21hdGVkIHRlc3RzOyBSRUFETUU7IGltYWdlIHByZXByb2Nlc3NpbmcuIiwiaW50ZXJ2aWV3VG9waWMiOiJDTk4gYXJjaGl0ZWN0dXJlLCBmaWx0ZXJzLCBwYWRkaW5nLCBzdHJpZGUgYW5kIHBvb2xpbmcuIiwicHJpb3JpdHkiOiJQcm90b3R5cGUiLCJzb3VyY2UiOiJPcmlnaW5hbCAx4oCTMzAgKHVzZXIgc291cmNlKSIsInByb3ZlbmFuY2UiOiJvcmlnaW5hbCIsInByZXJlcXVpc2l0ZXMiOiJNTCBjb25jZXB0cyIsImVzdEhvdXJzIjo4fSx7InBsYW5JZCI6ImNocm9uaXMtYWktZW5naW5lZXJpbmctMjAyNi0xMS0wNSIsImlkIjoiUDA4IiwidGl0bGUiOiJTZW50aW1lbnQgQW5hbHlzaXMgRW5naW5lIiwibGV2ZWwiOiJJbnRlcm1lZGlhdGUiLCJwaGFzZSI6IjAzIMK3IERlZXAgTGVhcm5pbmcgJiBOTFAiLCJzdGFydERheSI6MjcsImZpcnN0U3ByaW50IjoiMjAyNi0xMi0wMSIsInN0YWNrIjoiUHl0aG9uLCBOTFAsIExTVE0sIFB5VG9yY2giLCJtdnAiOiJQcm9jZXNzIGN1c3RvbWVyIHJldmlld3MuOyBUb2tlbml6YXRpb24gYW5kIGVtYmVkZGluZ3MuOyBTZW50aW1lbnQgY2xhc3NpZmljYXRpb24uIiwiZmVhdHVyZXMiOiJQcm9jZXNzIGN1c3RvbWVyIHJldmlld3MuOyBUb2tlbml6YXRpb24gYW5kIGVtYmVkZGluZ3MuOyBTZW50aW1lbnQgY2xhc3NpZmljYXRpb24uOyBDb21wYXJlIHRyYWRpdGlvbmFsIE1MIGFuZCBuZXVyYWwgbW9kZWxzLiIsImFjY2VwdGFuY2UiOiJSdW5uYWJsZSBkZW1vOyBhdXRvbWF0ZWQgdGVzdHM7IFJFQURNRTsgcHJvY2VzcyBjdXN0b21lciByZXZpZXdzLiIsImludGVydmlld1RvcGljIjoiV29yZCBlbWJlZGRpbmdzLCBSTk4sIExTVE0sIHZhbmlzaGluZyBncmFkaWVudHMuIiwicHJpb3JpdHkiOiJQcm90b3R5cGUiLCJzb3VyY2UiOiJPcmlnaW5hbCAx4oCTMzAgKHVzZXIgc291cmNlKSIsInByb3ZlbmFuY2UiOiJvcmlnaW5hbCIsInByZXJlcXVpc2l0ZXMiOiJNTCBjb25jZXB0cyIsImVzdEhvdXJzIjo4fSx7InBsYW5JZCI6ImNocm9uaXMtYWktZW5naW5lZXJpbmctMjAyNi0xMS0wNSIsImlkIjoiUDA5IiwidGl0bGUiOiJBSSBSZXN1bWUgUGFyc2VyIGFuZCBKb2IgTWF0Y2hlciIsImxldmVsIjoiSW50ZXJtZWRpYXRlIiwicGhhc2UiOiIwMyDCtyBEZWVwIExlYXJuaW5nICYgTkxQIiwic3RhcnREYXkiOjI5LCJmaXJzdFNwcmludCI6IjIwMjYtMTItMDMiLCJzdGFjayI6IlB5dGhvbiwgTkxQLCBGYXN0QVBJLCBQb3N0Z3JlU1FMIiwibXZwIjoiRXh0cmFjdCByZXN1bWUgaW5mb3JtYXRpb24uOyBJZGVudGlmeSBza2lsbHMgYW5kIGV4cGVyaWVuY2UuOyBQYXJzZSBqb2IgZGVzY3JpcHRpb25zLiIsImZlYXR1cmVzIjoiRXh0cmFjdCByZXN1bWUgaW5mb3JtYXRpb24uOyBJZGVudGlmeSBza2lsbHMgYW5kIGV4cGVyaWVuY2UuOyBQYXJzZSBqb2IgZGVzY3JpcHRpb25zLjsgQ2FsY3VsYXRlIHNlbWFudGljIG1hdGNoaW5nLjsgR2VuZXJhdGUgY2FuZGlkYXRlLWpvYiBjb21wYXJpc29ucy4iLCJhY2NlcHRhbmNlIjoiUnVubmFibGUgZGVtbzsgYXV0b21hdGVkIHRlc3RzOyBSRUFETUU7IGV4dHJhY3QgcmVzdW1lIGluZm9ybWF0aW9uLiIsImludGVydmlld1RvcGljIjoiTmFtZWQgZW50aXR5IHJlY29nbml0aW9uLCBpbmZvcm1hdGlvbiBleHRyYWN0aW9uLCByYW5raW5nIGFuZCBzaW1pbGFyaXR5LiIsInByaW9yaXR5IjoiUHJvdG90eXBlIiwic291cmNlIjoiT3JpZ2luYWwgMeKAkzMwICh1c2VyIHNvdXJjZSkiLCJwcm92ZW5hbmNlIjoib3JpZ2luYWwiLCJwcmVyZXF1aXNpdGVzIjoiTUwgY29uY2VwdHMiLCJlc3RIb3VycyI6OH0seyJwbGFuSWQiOiJjaHJvbmlzLWFpLWVuZ2luZWVyaW5nLTIwMjYtMTEtMDUiLCJpZCI6IlAxMCIsInRpdGxlIjoiUmVhbC1UaW1lIE9iamVjdCBEZXRlY3Rpb24iLCJsZXZlbCI6IkludGVybWVkaWF0ZSIsInBoYXNlIjoiMDMgwrcgRGVlcCBMZWFybmluZyAmIE5MUCIsInN0YXJ0RGF5IjozMSwiZmlyc3RTcHJpbnQiOiIyMDI2LTEyLTA1Iiwic3RhY2siOiJQeXRob24sIE9wZW5DViwgWU9MTywgUHlUb3JjaCIsIm12cCI6IkNhbWVyYS92aWRlbyBwcm9jZXNzaW5nLjsgT2JqZWN0IGRldGVjdGlvbi47IEJvdW5kaW5nIGJveGVzLiIsImZlYXR1cmVzIjoiQ2FtZXJhL3ZpZGVvIHByb2Nlc3NpbmcuOyBPYmplY3QgZGV0ZWN0aW9uLjsgQm91bmRpbmcgYm94ZXMuOyBDb25maWRlbmNlIHRocmVzaG9sZHMuOyBGUFMgYW5kIGluZmVyZW5jZSBvcHRpbWl6YXRpb24uIiwiYWNjZXB0YW5jZSI6IlJ1bm5hYmxlIGRlbW87IGF1dG9tYXRlZCB0ZXN0czsgUkVBRE1FOyBjYW1lcmEvdmlkZW8gcHJvY2Vzc2luZy4iLCJpbnRlcnZpZXdUb3BpYyI6Ik9iamVjdCBkZXRlY3Rpb24sIElvVSwgcHJlY2lzaW9uLXJlY2FsbCwgTk1TLiIsInByaW9yaXR5IjoiUHJvdG90eXBlIiwic291cmNlIjoiT3JpZ2luYWwgMeKAkzMwICh1c2VyIHNvdXJjZSkiLCJwcm92ZW5hbmNlIjoib3JpZ2luYWwiLCJwcmVyZXF1aXNpdGVzIjoiTUwgY29uY2VwdHMiLCJlc3RIb3VycyI6OH0seyJwbGFuSWQiOiJjaHJvbmlzLWFpLWVuZ2luZWVyaW5nLTIwMjYtMTEtMDUiLCJpZCI6IlAxMSIsInRpdGxlIjoiTXVsdGktTW9kZWwgQUkgQ2hhdCBBcHBsaWNhdGlvbiIsImxldmVsIjoiQWR2YW5jZWQiLCJwaGFzZSI6IjA0IMK3IExMTXMgJiBSQUciLCJzdGFydERheSI6MzcsImZpcnN0U3ByaW50IjoiMjAyNi0xMi0xMSIsInN0YWNrIjoiUmVhY3QsIFR5cGVTY3JpcHQsIEZhc3RBUEksIExMTSBBUElzIiwibXZwIjoiSW50ZWdyYXRlIG11bHRpcGxlIG1vZGVsIHByb3ZpZGVycy47IFN0cmVhbSByZXNwb25zZXMuOyBNYWludGFpbiBjb252ZXJzYXRpb25zLiIsImZlYXR1cmVzIjoiSW50ZWdyYXRlIG11bHRpcGxlIG1vZGVsIHByb3ZpZGVycy47IFN0cmVhbSByZXNwb25zZXMuOyBNYWludGFpbiBjb252ZXJzYXRpb25zLjsgSGFuZGxlIHByb3ZpZGVyIGZhaWx1cmVzLjsgTWFuYWdlIHRva2VuIHVzYWdlIGFuZCBjb3N0cy4iLCJhY2NlcHRhbmNlIjoiUnVubmFibGUgZGVtbzsgYXV0b21hdGVkIHRlc3RzOyBSRUFETUU7IGludGVncmF0ZSBtdWx0aXBsZSBtb2RlbCBwcm92aWRlcnMuIiwiaW50ZXJ2aWV3VG9waWMiOiJUb2tlbnMsIGNvbnRleHQgd2luZG93cywgdGVtcGVyYXR1cmUsIHN0cmVhbWluZywgQVBJIGRlc2lnbi4iLCJwcmlvcml0eSI6IlBvcnRmb2xpbyIsInNvdXJjZSI6Ik9yaWdpbmFsIDHigJMzMCAodXNlciBzb3VyY2UpIiwicHJvdmVuYW5jZSI6Im9yaWdpbmFsIiwicHJlcmVxdWlzaXRlcyI6IkxMTS9SQUcgYmFzaWNzIiwiZXN0SG91cnMiOjE2fSx7InBsYW5JZCI6ImNocm9uaXMtYWktZW5naW5lZXJpbmctMjAyNi0xMS0wNSIsImlkIjoiUDEyIiwidGl0bGUiOiJQREYgUXVlc3Rpb24gQW5zd2VyaW5nIFN5c3RlbSIsImxldmVsIjoiQWR2YW5jZWQiLCJwaGFzZSI6IjA0IMK3IExMTXMgJiBSQUciLCJzdGFydERheSI6MzksImZpcnN0U3ByaW50IjoiMjAyNi0xMi0xMyIsInN0YWNrIjoiUHl0aG9uLCBMYW5nQ2hhaW4sIGVtYmVkZGluZ3MsIEZBSVNTIiwibXZwIjoiUERGIGluZ2VzdGlvbi47IERvY3VtZW50IHBhcnNpbmcuOyBDaHVua2luZy4iLCJmZWF0dXJlcyI6IlBERiBpbmdlc3Rpb24uOyBEb2N1bWVudCBwYXJzaW5nLjsgQ2h1bmtpbmcuOyBFbWJlZGRpbmcgZ2VuZXJhdGlvbi47IFNlbWFudGljIHJldHJpZXZhbC47IEdyb3VuZGVkIGFuc3dlcnMuIiwiYWNjZXB0YW5jZSI6IlJ1bm5hYmxlIGRlbW87IGF1dG9tYXRlZCB0ZXN0czsgUkVBRE1FOyBwZGYgaW5nZXN0aW9uLiIsImludGVydmlld1RvcGljIjoiUkFHIHBpcGVsaW5lLCBjaHVuayBvdmVybGFwLCBlbWJlZGRpbmdzLCBoYWxsdWNpbmF0aW9uLiIsInByaW9yaXR5IjoiUG9ydGZvbGlvIiwic291cmNlIjoiT3JpZ2luYWwgMeKAkzMwICh1c2VyIHNvdXJjZSkiLCJwcm92ZW5hbmNlIjoib3JpZ2luYWwiLCJwcmVyZXF1aXNpdGVzIjoiTExNL1JBRyBiYXNpY3MiLCJlc3RIb3VycyI6MTZ9LHsicGxhbklkIjoiY2hyb25pcy1haS1lbmdpbmVlcmluZy0yMDI2LTExLTA1IiwiaWQiOiJQMTMiLCJ0aXRsZSI6IkVudGVycHJpc2UgSFIgUG9saWN5IEFzc2lzdGFudCIsImxldmVsIjoiQWR2YW5jZWQiLCJwaGFzZSI6IjA0IMK3IExMTXMgJiBSQUciLCJzdGFydERheSI6NDEsImZpcnN0U3ByaW50IjoiMjAyNi0xMi0xNSIsInN0YWNrIjoiUmVhY3QsIEZhc3RBUEksIExhbmdDaGFpbiwgUG9zdGdyZVNRTCwgcGd2ZWN0b3IiLCJtdnAiOiJNdWx0aXBsZSBkb2N1bWVudCBpbmdlc3Rpb24uOyBQb2xpY3ktYmFzZWQgcmV0cmlldmFsLjsgVXNlci1sZXZlbCBwZXJtaXNzaW9ucy4iLCJmZWF0dXJlcyI6Ik11bHRpcGxlIGRvY3VtZW50IGluZ2VzdGlvbi47IFBvbGljeS1iYXNlZCByZXRyaWV2YWwuOyBVc2VyLWxldmVsIHBlcm1pc3Npb25zLjsgU291cmNlIGNpdGF0aW9ucy47IFN0cmVhbWluZyBjaGF0LjsgQWRtaW4gZG9jdW1lbnQgbWFuYWdlbWVudC4iLCJhY2NlcHRhbmNlIjoiUnVubmFibGUgZGVtbzsgYXV0b21hdGVkIHRlc3RzOyBSRUFETUU7IG11bHRpcGxlIGRvY3VtZW50IGluZ2VzdGlvbi4iLCJpbnRlcnZpZXdUb3BpYyI6IlByb2R1Y3Rpb24gUkFHLCBtZXRhZGF0YSBmaWx0ZXJpbmcsIFJCQUMsIHJldHJpZXZhbCBxdWFsaXR5LCBzZWN1cml0eS4iLCJwcmlvcml0eSI6IkZsYWdzaGlwIiwic291cmNlIjoiT3JpZ2luYWwgMeKAkzMwICh1c2VyIHNvdXJjZSkiLCJwcm92ZW5hbmNlIjoib3JpZ2luYWwiLCJwcmVyZXF1aXNpdGVzIjoiTExNL1JBRyBiYXNpY3MiLCJlc3RIb3VycyI6MTZ9LHsicGxhbklkIjoiY2hyb25pcy1haS1lbmdpbmVlcmluZy0yMDI2LTExLTA1IiwiaWQiOiJQMTQiLCJ0aXRsZSI6IkFkdmFuY2VkIEh5YnJpZCBSQUcgUGxhdGZvcm0iLCJsZXZlbCI6IkFkdmFuY2VkIiwicGhhc2UiOiIwNCDCtyBMTE1zICYgUkFHIiwic3RhcnREYXkiOjQ0LCJmaXJzdFNwcmludCI6IjIwMjYtMTItMTgiLCJzdGFjayI6IkxhbmdDaGFpbiwgUG9zdGdyZVNRTCwgcGd2ZWN0b3IsIEJNMjUsIHJlcmFua2VycyIsIm12cCI6Ikh5YnJpZCBrZXl3b3JkIGFuZCB2ZWN0b3Igc2VhcmNoLjsgUXVlcnkgcmV3cml0aW5nLjsgTWV0YWRhdGEgZmlsdGVyaW5nLiIsImZlYXR1cmVzIjoiSHlicmlkIGtleXdvcmQgYW5kIHZlY3RvciBzZWFyY2guOyBRdWVyeSByZXdyaXRpbmcuOyBNZXRhZGF0YSBmaWx0ZXJpbmcuOyBSZXJhbmtpbmcuOyBQYXJlbnQtY2hpbGQgcmV0cmlldmFsLjsgUmV0cmlldmFsIGV2YWx1YXRpb24uIiwiYWNjZXB0YW5jZSI6IlJ1bm5hYmxlIGRlbW87IGF1dG9tYXRlZCB0ZXN0czsgUkVBRE1FOyBoeWJyaWQga2V5d29yZCBhbmQgdmVjdG9yIHNlYXJjaC4iLCJpbnRlcnZpZXdUb3BpYyI6IlJlY2FsbEBLLCBNUlIsIE5EQ0csIGh5YnJpZCBzZWFyY2ggYW5kIHJlcmFua2luZyB0cmFkZS1vZmZzLiIsInByaW9yaXR5IjoiUG9ydGZvbGlvIiwic291cmNlIjoiT3JpZ2luYWwgMeKAkzMwICh1c2VyIHNvdXJjZSkiLCJwcm92ZW5hbmNlIjoib3JpZ2luYWwiLCJwcmVyZXF1aXNpdGVzIjoiTExNL1JBRyBiYXNpY3MiLCJlc3RIb3VycyI6MTZ9LHsicGxhbklkIjoiY2hyb25pcy1haS1lbmdpbmVlcmluZy0yMDI2LTExLTA1IiwiaWQiOiJQMTUiLCJ0aXRsZSI6Ik11bHRpbW9kYWwgQUkgS25vd2xlZGdlIEFzc2lzdGFudCIsImxldmVsIjoiQWR2YW5jZWQiLCJwaGFzZSI6IjA0IMK3IExMTXMgJiBSQUciLCJzdGFydERheSI6NDcsImZpcnN0U3ByaW50IjoiMjAyNi0xMi0yMSIsInN0YWNrIjoiVmlzaW9uLWxhbmd1YWdlIG1vZGVscywgT0NSLCBlbWJlZGRpbmdzLCBSQUciLCJtdnAiOiJVbmRlcnN0YW5kIGRvY3VtZW50cywgdGFibGVzIGFuZCBpbWFnZXMuOyBFeHRyYWN0IHRleHQgZnJvbSBzY2FubmVkIGRvY3VtZW50cy47IFByb2Nlc3MgaW1hZ2UgcXVlc3Rpb25zLiIsImZlYXR1cmVzIjoiVW5kZXJzdGFuZCBkb2N1bWVudHMsIHRhYmxlcyBhbmQgaW1hZ2VzLjsgRXh0cmFjdCB0ZXh0IGZyb20gc2Nhbm5lZCBkb2N1bWVudHMuOyBQcm9jZXNzIGltYWdlIHF1ZXN0aW9ucy47IFJldHJpZXZlIG11bHRpbW9kYWwgY29udGVudC47IEFuc3dlciB3aXRoIHNvdXJjZSByZWZlcmVuY2VzLiIsImFjY2VwdGFuY2UiOiJSdW5uYWJsZSBkZW1vOyBhdXRvbWF0ZWQgdGVzdHM7IFJFQURNRTsgdW5kZXJzdGFuZCBkb2N1bWVudHMsIHRhYmxlcyBhbmQgaW1hZ2VzLiIsImludGVydmlld1RvcGljIjoiTXVsdGltb2RhbCBlbWJlZGRpbmdzLCBPQ1IsIHZpc2lvbi1sYW5ndWFnZSBtb2RlbHMsIHJldHJpZXZhbC4iLCJwcmlvcml0eSI6IlByb3RvdHlwZSIsInNvdXJjZSI6Ik9yaWdpbmFsIDHigJMzMCAodXNlciBzb3VyY2UpIiwicHJvdmVuYW5jZSI6Im9yaWdpbmFsIiwicHJlcmVxdWlzaXRlcyI6IkxMTS9SQUcgYmFzaWNzIiwiZXN0SG91cnMiOjE2fSx7InBsYW5JZCI6ImNocm9uaXMtYWktZW5naW5lZXJpbmctMjAyNi0xMS0wNSIsImlkIjoiUDE2IiwidGl0bGUiOiJBdXRvbm9tb3VzIEFJIFJlc2VhcmNoIEFzc2lzdGFudCIsImxldmVsIjoiQWR2YW5jZWQiLCJwaGFzZSI6IjA1IMK3IEFnZW50cyAmIEhhcm5lc3MiLCJzdGFydERheSI6NTMsImZpcnN0U3ByaW50IjoiMjAyNi0xMi0yNyIsInN0YWNrIjoiTGFuZ0dyYXBoLCBzZWFyY2ggdG9vbHMsIExMTSBBUElzIiwibXZwIjoiQnJlYWsgcmVzZWFyY2ggaW50byBzdWJ0YXNrcy47IFNlYXJjaCBhbmQgcmV0cmlldmUgaW5mb3JtYXRpb24uOyBDb21wYXJlIG11bHRpcGxlIHNvdXJjZXMuIiwiZmVhdHVyZXMiOiJCcmVhayByZXNlYXJjaCBpbnRvIHN1YnRhc2tzLjsgU2VhcmNoIGFuZCByZXRyaWV2ZSBpbmZvcm1hdGlvbi47IENvbXBhcmUgbXVsdGlwbGUgc291cmNlcy47IEdlbmVyYXRlIGNpdGVkIHJlcG9ydHMuOyBIYW5kbGUgZmFpbHVyZXMgYW5kIGFwcHJvdmFsLiIsImFjY2VwdGFuY2UiOiJSdW5uYWJsZSBkZW1vOyBhdXRvbWF0ZWQgdGVzdHM7IFJFQURNRTsgYnJlYWsgcmVzZWFyY2ggaW50byBzdWJ0YXNrcy4iLCJpbnRlcnZpZXdUb3BpYyI6IlJlQWN0LCBwbGFubmluZywgYWdlbnQgbG9vcHMsIGdyb3VuZGluZyBhbmQgc291cmNlIHJlbGlhYmlsaXR5LiIsInByaW9yaXR5IjoiUG9ydGZvbGlvIiwic291cmNlIjoiT3JpZ2luYWwgMeKAkzMwICh1c2VyIHNvdXJjZSkiLCJwcm92ZW5hbmNlIjoib3JpZ2luYWwiLCJwcmVyZXF1aXNpdGVzIjoiQWdlbnRzIGFuZCB0b29sIHNjaGVtYXMiLCJlc3RIb3VycyI6MTZ9LHsicGxhbklkIjoiY2hyb25pcy1haS1lbmdpbmVlcmluZy0yMDI2LTExLTA1IiwiaWQiOiJQMTciLCJ0aXRsZSI6Ik11bHRpLUFnZW50IFdvcmtmbG93IEF1dG9tYXRpb24iLCJsZXZlbCI6IkFkdmFuY2VkIiwicGhhc2UiOiIwNSDCtyBBZ2VudHMgJiBIYXJuZXNzIiwic3RhcnREYXkiOjU2LCJmaXJzdFNwcmludCI6IjIwMjYtMTItMzAiLCJzdGFjayI6IkxhbmdHcmFwaCwgc3BlY2lhbGl6ZWQgYWdlbnRzLCBQb3N0Z3JlU1FMIiwibXZwIjoiU3VwZXJ2aXNvciBhZ2VudC47IFJlc2VhcmNoIGFnZW50LjsgQW5hbHlzaXMgYWdlbnQuIiwiZmVhdHVyZXMiOiJTdXBlcnZpc29yIGFnZW50LjsgUmVzZWFyY2ggYWdlbnQuOyBBbmFseXNpcyBhZ2VudC47IEV4ZWN1dGlvbiBhZ2VudC47IFNoYXJlZCBzdGF0ZSBhbmQgaGFuZG9mZnMuOyBIdW1hbiBhcHByb3ZhbC4iLCJhY2NlcHRhbmNlIjoiUnVubmFibGUgZGVtbzsgYXV0b21hdGVkIHRlc3RzOyBSRUFETUU7IHN1cGVydmlzb3IgYWdlbnQuIiwiaW50ZXJ2aWV3VG9waWMiOiJNdWx0aS1hZ2VudCBvcmNoZXN0cmF0aW9uLCBzdGF0ZSBtYWNoaW5lcywgcGFyYWxsZWwgZXhlY3V0aW9uIGFuZCBhZ2VudCBjb29yZGluYXRpb24uIiwicHJpb3JpdHkiOiJGbGFnc2hpcCIsInNvdXJjZSI6Ik9yaWdpbmFsIDHigJMzMCAodXNlciBzb3VyY2UpIiwicHJvdmVuYW5jZSI6Im9yaWdpbmFsIiwicHJlcmVxdWlzaXRlcyI6IkFnZW50cyBhbmQgdG9vbCBzY2hlbWFzIiwiZXN0SG91cnMiOjE2fSx7InBsYW5JZCI6ImNocm9uaXMtYWktZW5naW5lZXJpbmctMjAyNi0xMS0wNSIsImlkIjoiUDE4IiwidGl0bGUiOiJBSSBDb2RpbmcgQXNzaXN0YW50IiwibGV2ZWwiOiJBZHZhbmNlZCIsInBoYXNlIjoiMDUgwrcgQWdlbnRzICYgSGFybmVzcyIsInN0YXJ0RGF5Ijo1OSwiZmlyc3RTcHJpbnQiOiIyMDI3LTAxLTAyIiwic3RhY2siOiJQeXRob24sIExhbmdHcmFwaCwgUkFHLCBHaXQgaW50ZWdyYXRpb24iLCJtdnAiOiJJbmRleCBzb3VyY2UgcmVwb3NpdG9yaWVzLjsgVW5kZXJzdGFuZCBjb2RlIHJlbGF0aW9uc2hpcHMuOyBHZW5lcmF0ZSBjb2RlIHN1Z2dlc3Rpb25zLiIsImZlYXR1cmVzIjoiSW5kZXggc291cmNlIHJlcG9zaXRvcmllcy47IFVuZGVyc3RhbmQgY29kZSByZWxhdGlvbnNoaXBzLjsgR2VuZXJhdGUgY29kZSBzdWdnZXN0aW9ucy47IElkZW50aWZ5IGJ1Z3MuOyBHZW5lcmF0ZSB0ZXN0cy47IFJldmlldyBkaWZmcyBiZWZvcmUgYXBwbHlpbmcgY2hhbmdlcy4iLCJhY2NlcHRhbmNlIjoiUnVubmFibGUgZGVtbzsgYXV0b21hdGVkIHRlc3RzOyBSRUFETUU7IGluZGV4IHNvdXJjZSByZXBvc2l0b3JpZXMuIiwiaW50ZXJ2aWV3VG9waWMiOiJDb2RlIHJldHJpZXZhbCwgcmVwb3NpdG9yeSBpbmRleGluZywgQVNULCB0b29sIHBlcm1pc3Npb25zIGFuZCBzYW5kYm94aW5nLiIsInByaW9yaXR5IjoiUHJvdG90eXBlIiwic291cmNlIjoiT3JpZ2luYWwgMeKAkzMwICh1c2VyIHNvdXJjZSkiLCJwcm92ZW5hbmNlIjoib3JpZ2luYWwiLCJwcmVyZXF1aXNpdGVzIjoiQWdlbnRzIGFuZCB0b29sIHNjaGVtYXMiLCJlc3RIb3VycyI6MTZ9LHsicGxhbklkIjoiY2hyb25pcy1haS1lbmdpbmVlcmluZy0yMDI2LTExLTA1IiwiaWQiOiJQMTkiLCJ0aXRsZSI6IkVudGVycHJpc2UgQUkgQ3VzdG9tZXIgU3VwcG9ydCBBZ2VudCIsImxldmVsIjoiQWR2YW5jZWQiLCJwaGFzZSI6IjA1IMK3IEFnZW50cyAmIEhhcm5lc3MiLCJzdGFydERheSI6NjIsImZpcnN0U3ByaW50IjoiMjAyNy0wMS0wNSIsInN0YWNrIjoiTGFuZ0dyYXBoLCBSQUcsIEZhc3RBUEksIFJlZGlzLCBQb3N0Z3JlU1FMIiwibXZwIjoiQ3VzdG9tZXIgaW50ZW50IGNsYXNzaWZpY2F0aW9uLjsgT3JkZXIgbG9va3VwIHRvb2xzLjsgUmVmdW5kIGFuZCB0aWNrZXQgd29ya2Zsb3dzLiIsImZlYXR1cmVzIjoiQ3VzdG9tZXIgaW50ZW50IGNsYXNzaWZpY2F0aW9uLjsgT3JkZXIgbG9va3VwIHRvb2xzLjsgUmVmdW5kIGFuZCB0aWNrZXQgd29ya2Zsb3dzLjsgQ3VzdG9tZXIgbWVtb3J5LjsgRXNjYWxhdGlvbiB0byBodW1hbnMuOyBBdWRpdCB0cmFpbC4iLCJhY2NlcHRhbmNlIjoiUnVubmFibGUgZGVtbzsgYXV0b21hdGVkIHRlc3RzOyBSRUFETUU7IGN1c3RvbWVyIGludGVudCBjbGFzc2lmaWNhdGlvbi4iLCJpbnRlcnZpZXdUb3BpYyI6IlRvb2wgc2FmZXR5LCBhdXRob3JpemF0aW9uLCB0cmFuc2FjdGlvbmFsIG9wZXJhdGlvbnMgYW5kIGd1YXJkcmFpbHMuIiwicHJpb3JpdHkiOiJQb3J0Zm9saW8iLCJzb3VyY2UiOiJPcmlnaW5hbCAx4oCTMzAgKHVzZXIgc291cmNlKSIsInByb3ZlbmFuY2UiOiJvcmlnaW5hbCIsInByZXJlcXVpc2l0ZXMiOiJBZ2VudHMgYW5kIHRvb2wgc2NoZW1hcyIsImVzdEhvdXJzIjoxNn0seyJwbGFuSWQiOiJjaHJvbmlzLWFpLWVuZ2luZWVyaW5nLTIwMjYtMTEtMDUiLCJpZCI6IlAyMCIsInRpdGxlIjoiQUkgU29mdHdhcmUgRGV2ZWxvcG1lbnQgQWdlbnQiLCJsZXZlbCI6IkFkdmFuY2VkIiwicGhhc2UiOiIwNSDCtyBBZ2VudHMgJiBIYXJuZXNzIiwic3RhcnREYXkiOjY1LCJmaXJzdFNwcmludCI6IjIwMjctMDEtMDgiLCJzdGFjayI6IkxhbmdHcmFwaCwgR2l0SHViIGludGVncmF0aW9uLCB0ZXN0aW5nIHRvb2xzLCBEb2NrZXIiLCJtdnAiOiJDb252ZXJ0IHJlcXVpcmVtZW50cyBpbnRvIHRhc2tzLjsgR2VuZXJhdGUgaW1wbGVtZW50YXRpb24gcGxhbnMuOyBJbnNwZWN0IGNvZGViYXNlcy4iLCJmZWF0dXJlcyI6IkNvbnZlcnQgcmVxdWlyZW1lbnRzIGludG8gdGFza3MuOyBHZW5lcmF0ZSBpbXBsZW1lbnRhdGlvbiBwbGFucy47IEluc3BlY3QgY29kZWJhc2VzLjsgR2VuZXJhdGUgY29kZSBjaGFuZ2VzLjsgUnVuIHRlc3RzLjsgQ3JlYXRlIHJldmlldy1yZWFkeSBwYXRjaGVzLiIsImFjY2VwdGFuY2UiOiJSdW5uYWJsZSBkZW1vOyBhdXRvbWF0ZWQgdGVzdHM7IFJFQURNRTsgY29udmVydCByZXF1aXJlbWVudHMgaW50byB0YXNrcy4iLCJpbnRlcnZpZXdUb3BpYyI6IkFnZW50IHJlbGlhYmlsaXR5LCB0b29sIGV4ZWN1dGlvbiwgdGVzdGluZyBsb29wcywgaHVtYW4taW4tdGhlLWxvb3AgYW5kIHNlY3VyZSBleGVjdXRpb24uIiwicHJpb3JpdHkiOiJQcm90b3R5cGUiLCJzb3VyY2UiOiJPcmlnaW5hbCAx4oCTMzAgKHVzZXIgc291cmNlKSIsInByb3ZlbmFuY2UiOiJvcmlnaW5hbCIsInByZXJlcXVpc2l0ZXMiOiJBZ2VudHMgYW5kIHRvb2wgc2NoZW1hcyIsImVzdEhvdXJzIjoxNn0seyJwbGFuSWQiOiJjaHJvbmlzLWFpLWVuZ2luZWVyaW5nLTIwMjYtMTEtMDUiLCJpZCI6IlAyMSIsInRpdGxlIjoiTXVsdGktVGVuYW50IEFJIFNhYVMgUGxhdGZvcm0iLCJsZXZlbCI6IkNvbXBsZXgiLCJwaGFzZSI6IjA2IMK3IFByb2R1Y3Rpb24gJiBMTE1PcHMiLCJzdGFydERheSI6NzAsImZpcnN0U3ByaW50IjoiMjAyNy0wMS0xMyIsInN0YWNrIjoiUmVhY3QsIEZhc3RBUEksIFBvc3RncmVTUUwsIFJlZGlzLCBEb2NrZXIuIiwibXZwIjoiTXVsdGlwbGUgb3JnYW5pemF0aW9ucyBhbmQgaXNvbGF0ZWQgZGF0YS47IFRlbmFudC1hd2FyZSBSQUcuOyBSQkFDIGFuZCBhdXRoZW50aWNhdGlvbi4iLCJmZWF0dXJlcyI6Ik11bHRpcGxlIG9yZ2FuaXphdGlvbnMgYW5kIGlzb2xhdGVkIGRhdGEuOyBUZW5hbnQtYXdhcmUgUkFHLjsgUkJBQyBhbmQgYXV0aGVudGljYXRpb24uOyBTdWJzY3JpcHRpb24gYW5kIHVzYWdlIGxpbWl0cy47IEFQSSBrZXlzIGFuZCBhdWRpdCBsb2dnaW5nLiIsImFjY2VwdGFuY2UiOiJSdW5uYWJsZSBkZW1vOyBhdXRvbWF0ZWQgdGVzdHM7IFJFQURNRTsgbXVsdGlwbGUgb3JnYW5pemF0aW9ucyBhbmQgaXNvbGF0ZWQgZGF0YS4iLCJpbnRlcnZpZXdUb3BpYyI6Ik11bHRpLXRlbmFuY3ksIGlzb2xhdGlvbiwgc2VjdXJpdHkgYW5kIFNhYVMgYXJjaGl0ZWN0dXJlLiIsInByaW9yaXR5IjoiUG9ydGZvbGlvIiwic291cmNlIjoiT3JpZ2luYWwgMeKAkzMwICh1c2VyIHNvdXJjZSkiLCJwcm92ZW5hbmNlIjoib3JpZ2luYWwiLCJwcmVyZXF1aXNpdGVzIjoiUHJvZHVjdGlvbiBBUElzIGFuZCBzdGF0ZSIsImVzdEhvdXJzIjoyOH0seyJwbGFuSWQiOiJjaHJvbmlzLWFpLWVuZ2luZWVyaW5nLTIwMjYtMTEtMDUiLCJpZCI6IlAyMiIsInRpdGxlIjoiTGFyZ2UtU2NhbGUgRG9jdW1lbnQgSW50ZWxsaWdlbmNlIFBsYXRmb3JtIiwibGV2ZWwiOiJDb21wbGV4IiwicGhhc2UiOiIwNiDCtyBQcm9kdWN0aW9uICYgTExNT3BzIiwic3RhcnREYXkiOjcyLCJmaXJzdFNwcmludCI6IjIwMjctMDEtMTUiLCJzdGFjayI6IkthZmthLCBDZWxlcnksIFJlZGlzLCBQb3N0Z3JlU1FMLCBvYmplY3Qgc3RvcmFnZS4iLCJtdnAiOiJCdWxrIFBERi9ET0NYIGluZ2VzdGlvbi47IERpc3RyaWJ1dGVkIGRvY3VtZW50IHByb2Nlc3NpbmcuOyBRdWV1ZS1iYXNlZCBlbWJlZGRpbmcgZ2VuZXJhdGlvbi4iLCJmZWF0dXJlcyI6IkJ1bGsgUERGL0RPQ1ggaW5nZXN0aW9uLjsgRGlzdHJpYnV0ZWQgZG9jdW1lbnQgcHJvY2Vzc2luZy47IFF1ZXVlLWJhc2VkIGVtYmVkZGluZyBnZW5lcmF0aW9uLjsgRGVkdXBsaWNhdGlvbiBhbmQgcmV0cmllcy47IEluY3JlbWVudGFsIGluZGV4aW5nLjsgUHJvY2Vzc2luZyBzdGF0dXMgYW5kIGFuYWx5dGljcy4iLCJhY2NlcHRhbmNlIjoiUnVubmFibGUgZGVtbzsgYXV0b21hdGVkIHRlc3RzOyBSRUFETUU7IGJ1bGsgcGRmL2RvY3ggaW5nZXN0aW9uLiIsImludGVydmlld1RvcGljIjoiRGlzdHJpYnV0ZWQgcHJvY2Vzc2luZywgaWRlbXBvdGVuY3ksIHF1ZXVlcyBhbmQgc2NhbGFiaWxpdHkuIiwicHJpb3JpdHkiOiJQcm90b3R5cGUiLCJzb3VyY2UiOiJPcmlnaW5hbCAx4oCTMzAgKHVzZXIgc291cmNlKSIsInByb3ZlbmFuY2UiOiJvcmlnaW5hbCIsInByZXJlcXVpc2l0ZXMiOiJQcm9kdWN0aW9uIEFQSXMgYW5kIHN0YXRlIiwiZXN0SG91cnMiOjI4fSx7InBsYW5JZCI6ImNocm9uaXMtYWktZW5naW5lZXJpbmctMjAyNi0xMS0wNSIsImlkIjoiUDIzIiwidGl0bGUiOiJEb21haW4tU3BlY2lmaWMgTExNIEZpbmUtVHVuaW5nIiwibGV2ZWwiOiJDb21wbGV4IiwicGhhc2UiOiIwNiDCtyBQcm9kdWN0aW9uICYgTExNT3BzIiwic3RhcnREYXkiOjc0LCJmaXJzdFNwcmludCI6IjIwMjctMDEtMTciLCJzdGFjayI6IlB5VG9yY2gsIFRyYW5zZm9ybWVycywgUEVGVCwgVFJMLiIsIm12cCI6IlByZXBhcmUgaW5zdHJ1Y3Rpb24gZGF0YXNldHMuOyBUcmFpbiB1c2luZyBMb1JBL1FMb1JBLjsgQ29tcGFyZSBiYXNlIGFuZCBhZGFwdGVkIG1vZGVscy4iLCJmZWF0dXJlcyI6IlByZXBhcmUgaW5zdHJ1Y3Rpb24gZGF0YXNldHMuOyBUcmFpbiB1c2luZyBMb1JBL1FMb1JBLjsgQ29tcGFyZSBiYXNlIGFuZCBhZGFwdGVkIG1vZGVscy47IFF1YW50aXplIHRoZSBtb2RlbC47IEV2YWx1YXRlIHBlcmZvcm1hbmNlLiIsImFjY2VwdGFuY2UiOiJSdW5uYWJsZSBkZW1vOyBhdXRvbWF0ZWQgdGVzdHM7IFJFQURNRTsgcHJlcGFyZSBpbnN0cnVjdGlvbiBkYXRhc2V0cy4iLCJpbnRlcnZpZXdUb3BpYyI6IlNGVCwgbG9zcywgTG9SQSwgcXVhbnRpemF0aW9uLCBHUFUgbWVtb3J5IGFuZCBvdmVyZml0dGluZy4iLCJwcmlvcml0eSI6IlByb3RvdHlwZSIsInNvdXJjZSI6Ik9yaWdpbmFsIDHigJMzMCAodXNlciBzb3VyY2UpIiwicHJvdmVuYW5jZSI6Im9yaWdpbmFsIiwicHJlcmVxdWlzaXRlcyI6IlByb2R1Y3Rpb24gQVBJcyBhbmQgc3RhdGUiLCJlc3RIb3VycyI6Mjh9LHsicGxhbklkIjoiY2hyb25pcy1haS1lbmdpbmVlcmluZy0yMDI2LTExLTA1IiwiaWQiOiJQMjQiLCJ0aXRsZSI6IkxMTSBFdmFsdWF0aW9uIGFuZCBPYnNlcnZhYmlsaXR5IFBsYXRmb3JtIiwibGV2ZWwiOiJDb21wbGV4IiwicGhhc2UiOiIwNiDCtyBQcm9kdWN0aW9uICYgTExNT3BzIiwic3RhcnREYXkiOjc2LCJmaXJzdFNwcmludCI6IjIwMjctMDEtMTkiLCJzdGFjayI6IlJhZ2FzLCBEZWVwRXZhbCwgTGFuZ1NtaXRoLCBNTGZsb3csIEdyYWZhbmEuIiwibXZwIjoiRXZhbHVhdGUgYW5zd2VyIHF1YWxpdHkuOyBEZXRlY3QgaGFsbHVjaW5hdGlvbnMuOyBNb25pdG9yIHJldHJpZXZhbCBwZXJmb3JtYW5jZS4iLCJmZWF0dXJlcyI6IkV2YWx1YXRlIGFuc3dlciBxdWFsaXR5LjsgRGV0ZWN0IGhhbGx1Y2luYXRpb25zLjsgTW9uaXRvciByZXRyaWV2YWwgcGVyZm9ybWFuY2UuOyBUcmFjayB0b2tlbnMgYW5kIGNvc3RzLjsgQ29tcGFyZSBtb2RlbHMgYW5kIHByb21wdHMuOyBSdW4gcmVncmVzc2lvbiB0ZXN0cy4iLCJhY2NlcHRhbmNlIjoiUnVubmFibGUgZGVtbzsgYXV0b21hdGVkIHRlc3RzOyBSRUFETUU7IGV2YWx1YXRlIGFuc3dlciBxdWFsaXR5LiIsImludGVydmlld1RvcGljIjoiRXZhbHVhdGlvbiBtZXRob2RvbG9neSwgb2JzZXJ2YWJpbGl0eSwgdHJhY2luZyBhbmQgcmVncmVzc2lvbi4iLCJwcmlvcml0eSI6IlBvcnRmb2xpbyIsInNvdXJjZSI6Ik9yaWdpbmFsIDHigJMzMCAodXNlciBzb3VyY2UpIiwicHJvdmVuYW5jZSI6Im9yaWdpbmFsIiwicHJlcmVxdWlzaXRlcyI6IlByb2R1Y3Rpb24gQVBJcyBhbmQgc3RhdGUiLCJlc3RIb3VycyI6Mjh9LHsicGxhbklkIjoiY2hyb25pcy1haS1lbmdpbmVlcmluZy0yMDI2LTExLTA1IiwiaWQiOiJQMjUiLCJ0aXRsZSI6IlNjYWxhYmxlIExMTSBJbmZlcmVuY2UgUGxhdGZvcm0iLCJsZXZlbCI6IkNvbXBsZXgiLCJwaGFzZSI6IjA2IMK3IFByb2R1Y3Rpb24gJiBMTE1PcHMiLCJzdGFydERheSI6NzgsImZpcnN0U3ByaW50IjoiMjAyNy0wMS0yMSIsInN0YWNrIjoidkxMTSwgRG9ja2VyLCBLdWJlcm5ldGVzLCBSZWRpcywgQVdTLiIsIm12cCI6IlNlcnZlIG9wZW4tc291cmNlIExMTXMuOyBNb2RlbCByb3V0aW5nLjsgUmVxdWVzdCBiYXRjaGluZy4iLCJmZWF0dXJlcyI6IlNlcnZlIG9wZW4tc291cmNlIExMTXMuOyBNb2RlbCByb3V0aW5nLjsgUmVxdWVzdCBiYXRjaGluZy47IENhY2hpbmcuOyBHUFUgcmVzb3VyY2UgbWFuYWdlbWVudC47IExvYWQgYmFsYW5jaW5nIGFuZCBhdXRvc2NhbGluZy4iLCJhY2NlcHRhbmNlIjoiUnVubmFibGUgZGVtbzsgYXV0b21hdGVkIHRlc3RzOyBSRUFETUU7IHNlcnZlIG9wZW4tc291cmNlIGxsbXMuIiwiaW50ZXJ2aWV3VG9waWMiOiJUaHJvdWdocHV0LCBsYXRlbmN5LCBLViBjYWNoZSwgYmF0Y2hpbmcsIHF1YW50aXphdGlvbiBhbmQgR1BVIHV0aWxpemF0aW9uLiIsInByaW9yaXR5IjoiUHJvdG90eXBlIiwic291cmNlIjoiT3JpZ2luYWwgMeKAkzMwICh1c2VyIHNvdXJjZSkiLCJwcm92ZW5hbmNlIjoib3JpZ2luYWwiLCJwcmVyZXF1aXNpdGVzIjoiUHJvZHVjdGlvbiBBUElzIGFuZCBzdGF0ZSIsImVzdEhvdXJzIjoyOH0seyJwbGFuSWQiOiJjaHJvbmlzLWFpLWVuZ2luZWVyaW5nLTIwMjYtMTEtMDUiLCJpZCI6IlAyNiIsInRpdGxlIjoiRW50ZXJwcmlzZSBHcmFwaFJBRyBLbm93bGVkZ2UgUGxhdGZvcm0iLCJsZXZlbCI6IkNvbXBsZXgiLCJwaGFzZSI6IjA3IMK3IEFyY2hpdGVjdCBDYXBzdG9uZXMiLCJzdGFydERheSI6ODAsImZpcnN0U3ByaW50IjoiMjAyNy0wMS0yMyIsInN0YWNrIjoiTmVvNGosIFBvc3RncmVTUUwsIExhbmdHcmFwaCwgTExNcy4iLCJtdnAiOiJFeHRyYWN0IGVudGl0aWVzIGFuZCByZWxhdGlvbnNoaXBzLjsgQ29uc3RydWN0IGtub3dsZWRnZSBncmFwaHMuOyBDb21iaW5lIGdyYXBoIGFuZCB2ZWN0b3IgcmV0cmlldmFsLiIsImZlYXR1cmVzIjoiRXh0cmFjdCBlbnRpdGllcyBhbmQgcmVsYXRpb25zaGlwcy47IENvbnN0cnVjdCBrbm93bGVkZ2UgZ3JhcGhzLjsgQ29tYmluZSBncmFwaCBhbmQgdmVjdG9yIHJldHJpZXZhbC47IFBlcmZvcm0gbXVsdGktaG9wIHJlYXNvbmluZy47IEdlbmVyYXRlIGV2aWRlbmNlLWJhY2tlZCByZXNwb25zZXMuIiwiYWNjZXB0YW5jZSI6IlJ1bm5hYmxlIGRlbW87IGF1dG9tYXRlZCB0ZXN0czsgUkVBRE1FOyBleHRyYWN0IGVudGl0aWVzIGFuZCByZWxhdGlvbnNoaXBzLiIsImludGVydmlld1RvcGljIjoiR3JhcGggbW9kZWxsaW5nLCBncmFwaCB0cmF2ZXJzYWwsIGh5YnJpZCByZXRyaWV2YWwgYW5kIGFuc3dlciBncm91bmRpbmcuIiwicHJpb3JpdHkiOiJQcm90b3R5cGUiLCJzb3VyY2UiOiJPcmlnaW5hbCAx4oCTMzAgKHVzZXIgc291cmNlKSIsInByb3ZlbmFuY2UiOiJvcmlnaW5hbCIsInByZXJlcXVpc2l0ZXMiOiJBcmNoaXRlY3R1cmUgJiBvcmNoZXN0cmF0aW9uIiwiZXN0SG91cnMiOjI4fSx7InBsYW5JZCI6ImNocm9uaXMtYWktZW5naW5lZXJpbmctMjAyNi0xMS0wNSIsImlkIjoiUDI3IiwidGl0bGUiOiJSZWFsLVRpbWUgVm9pY2UgQUkgQXNzaXN0YW50IiwibGV2ZWwiOiJDb21wbGV4IiwicGhhc2UiOiIwNyDCtyBBcmNoaXRlY3QgQ2Fwc3RvbmVzIiwic3RhcnREYXkiOjgyLCJmaXJzdFNwcmludCI6IjIwMjctMDEtMjUiLCJzdGFjayI6IkFTUiwgVFRTLCBXZWJTb2NrZXRzLCBGYXN0QVBJLCBzcGVlY2ggbW9kZWxzLiIsIm12cCI6IlNwZWVjaC10by10ZXh0LjsgVGV4dC10by1zcGVlY2guOyBTdHJlYW1pbmcgYXVkaW8uIiwiZmVhdHVyZXMiOiJTcGVlY2gtdG8tdGV4dC47IFRleHQtdG8tc3BlZWNoLjsgU3RyZWFtaW5nIGF1ZGlvLjsgQ29udmVyc2F0aW9uIGludGVycnVwdGlvbi47IENvbnRleHQtYXdhcmUgcmVzcG9uc2VzLjsgVm9pY2UgYWdlbnQgdG9vbHMuIiwiYWNjZXB0YW5jZSI6IlJ1bm5hYmxlIGRlbW87IGF1dG9tYXRlZCB0ZXN0czsgUkVBRE1FOyBzcGVlY2gtdG8tdGV4dC4iLCJpbnRlcnZpZXdUb3BpYyI6IlJlYWwtdGltZSBhdWRpbyBwaXBlbGluZXMsIGxhdGVuY3ksIGNvbmN1cnJlbmN5IGFuZCB0dXJuLXRha2luZy4iLCJwcmlvcml0eSI6IlByb3RvdHlwZSIsInNvdXJjZSI6Ik9yaWdpbmFsIDHigJMzMCAodXNlciBzb3VyY2UpIiwicHJvdmVuYW5jZSI6Im9yaWdpbmFsIiwicHJlcmVxdWlzaXRlcyI6IkFyY2hpdGVjdHVyZSAmIG9yY2hlc3RyYXRpb24iLCJlc3RIb3VycyI6Mjh9LHsicGxhbklkIjoiY2hyb25pcy1haS1lbmdpbmVlcmluZy0yMDI2LTExLTA1IiwiaWQiOiJQMjgiLCJ0aXRsZSI6IkludGVsbGlnZW50IFZpZGVvIFVuZGVyc3RhbmRpbmcgUGxhdGZvcm0iLCJsZXZlbCI6IkNvbXBsZXgiLCJwaGFzZSI6IjA3IMK3IEFyY2hpdGVjdCBDYXBzdG9uZXMiLCJzdGFydERheSI6ODQsImZpcnN0U3ByaW50IjoiMjAyNy0wMS0yNyIsInN0YWNrIjoiT3BlbkNWLCBQeVRvcmNoLCB2aXNpb24tbGFuZ3VhZ2UgbW9kZWxzLCB2ZWN0b3IgZGF0YWJhc2VzLiIsIm12cCI6IlZpZGVvIGluZ2VzdGlvbi47IFNjZW5lIGFuZCBmcmFtZSBleHRyYWN0aW9uLjsgT2JqZWN0IGFuZCBhY3Rpdml0eSByZWNvZ25pdGlvbi4iLCJmZWF0dXJlcyI6IlZpZGVvIGluZ2VzdGlvbi47IFNjZW5lIGFuZCBmcmFtZSBleHRyYWN0aW9uLjsgT2JqZWN0IGFuZCBhY3Rpdml0eSByZWNvZ25pdGlvbi47IEF1ZGlvIHRyYW5zY3JpcHRpb24uOyBWaWRlbyBzZW1hbnRpYyBpbmRleGluZy47IE5hdHVyYWwtbGFuZ3VhZ2UgdmlkZW8gc2VhcmNoLiIsImFjY2VwdGFuY2UiOiJSdW5uYWJsZSBkZW1vOyBhdXRvbWF0ZWQgdGVzdHM7IFJFQURNRTsgdmlkZW8gaW5nZXN0aW9uLiIsImludGVydmlld1RvcGljIjoiTXVsdGltb2RhbCBwcm9jZXNzaW5nIHBpcGVsaW5lcyBhbmQgbGFyZ2Utc2NhbGUgbWVkaWEgaW5kZXhpbmcuIiwicHJpb3JpdHkiOiJQcm90b3R5cGUiLCJzb3VyY2UiOiJPcmlnaW5hbCAx4oCTMzAgKHVzZXIgc291cmNlKSIsInByb3ZlbmFuY2UiOiJvcmlnaW5hbCIsInByZXJlcXVpc2l0ZXMiOiJBcmNoaXRlY3R1cmUgJiBvcmNoZXN0cmF0aW9uIiwiZXN0SG91cnMiOjI4fSx7InBsYW5JZCI6ImNocm9uaXMtYWktZW5naW5lZXJpbmctMjAyNi0xMS0wNSIsImlkIjoiUDI5IiwidGl0bGUiOiJOby1Db2RlIEFJIEFnZW50IEJ1aWxkZXIgUGxhdGZvcm0iLCJsZXZlbCI6IkNvbXBsZXgiLCJwaGFzZSI6IjA3IMK3IEFyY2hpdGVjdCBDYXBzdG9uZXMiLCJzdGFydERheSI6ODYsImZpcnN0U3ByaW50IjoiMjAyNy0wMS0yOSIsInN0YWNrIjoiUmVhY3QsIFR5cGVTY3JpcHQsIEZhc3RBUEksIExhbmdHcmFwaCwgUG9zdGdyZVNRTCwgUmVkaXMuIiwibXZwIjoiVmlzdWFsIHdvcmtmbG93IGJ1aWxkZXIuOyBEcmFnLWFuZC1kcm9wIGFnZW50IG5vZGVzLjsgQ29ubmVjdCB0b29scyBhbmQgbW9kZWxzLiIsImZlYXR1cmVzIjoiVmlzdWFsIHdvcmtmbG93IGJ1aWxkZXIuOyBEcmFnLWFuZC1kcm9wIGFnZW50IG5vZGVzLjsgQ29ubmVjdCB0b29scyBhbmQgbW9kZWxzLjsgQ29uZmlndXJlIG1lbW9yeSBhbmQgUkFHLjsgRXhlY3V0ZSB3b3JrZmxvd3MuOyBNb25pdG9yIHdvcmtmbG93IGV4ZWN1dGlvbi4iLCJhY2NlcHRhbmNlIjoiUnVubmFibGUgZGVtbzsgYXV0b21hdGVkIHRlc3RzOyBSRUFETUU7IHZpc3VhbCB3b3JrZmxvdyBidWlsZGVyLiIsImludGVydmlld1RvcGljIjoiV29ya2Zsb3cgZW5naW5lLCBkeW5hbWljIGdyYXBoIGV4ZWN1dGlvbiwgbXVsdGktdGVuYW50IHNlY3VyaXR5IGFuZCBleHRlbnNpYmlsaXR5LiIsInByaW9yaXR5IjoiRmxhZ3NoaXAiLCJzb3VyY2UiOiJPcmlnaW5hbCAx4oCTMzAgKHVzZXIgc291cmNlKSIsInByb3ZlbmFuY2UiOiJvcmlnaW5hbCIsInByZXJlcXVpc2l0ZXMiOiJBcmNoaXRlY3R1cmUgJiBvcmNoZXN0cmF0aW9uIiwiZXN0SG91cnMiOjI4fSx7InBsYW5JZCI6ImNocm9uaXMtYWktZW5naW5lZXJpbmctMjAyNi0xMS0wNSIsImlkIjoiUDMwIiwidGl0bGUiOiJFbnRlcnByaXNlIEFJIE9wZXJhdGluZyBQbGF0Zm9ybSIsImxldmVsIjoiQ29tcGxleCIsInBoYXNlIjoiMDcgwrcgQXJjaGl0ZWN0IENhcHN0b25lcyIsInN0YXJ0RGF5Ijo4OCwiZmlyc3RTcHJpbnQiOiIyMDI3LTAxLTMxIiwic3RhY2siOiJQeXRob24sIEZhc3RBUEksIFJlYWN0LCBQb3N0Z3JlU1FMLCBwZ3ZlY3RvciwgUmVkaXMsIExhbmdHcmFwaCwgRG9ja2VyLCBLdWJlcm5ldGVzLCBBV1MuIiwibXZwIjoiTXVsdGktbW9kZWwgTExNIGdhdGV3YXkuOyBSQUcgYW5kIEdyYXBoUkFHLjsgTXVsdGktYWdlbnQgb3JjaGVzdHJhdGlvbi4iLCJmZWF0dXJlcyI6Ik11bHRpLW1vZGVsIExMTSBnYXRld2F5LjsgUkFHIGFuZCBHcmFwaFJBRy47IE11bHRpLWFnZW50IG9yY2hlc3RyYXRpb24uOyBEb2N1bWVudCBpbnRlbGxpZ2VuY2UuOyBWb2ljZSBhbmQgbXVsdGltb2RhbCBBSS47IE1vZGVsIGV2YWx1YXRpb24gYW5kIG9ic2VydmFiaWxpdHkuOyBUZW5hbnQgbWFuYWdlbWVudCBhbmQgcGVybWlzc2lvbnMuOyBDbG91ZCBkZXBsb3ltZW50IGFuZCBhdXRvc2NhbGluZy4iLCJhY2NlcHRhbmNlIjoiUnVubmFibGUgZGVtbzsgYXV0b21hdGVkIHRlc3RzOyBSRUFETUU7IG11bHRpLW1vZGVsIGxsbSBnYXRld2F5LiIsImludGVydmlld1RvcGljIjoiRGVzaWduIGFuZCBvcGVyYXRlIGEgY29tcGxldGUgZW50ZXJwcmlzZSBBSSBwbGF0Zm9ybSB3aXRoIHJlbGlhYmlsaXR5LCBzZWN1cml0eSwgcGVyZm9ybWFuY2UgYW5kIG1lYXN1cmFibGUgcXVhbGl0eS4iLCJwcmlvcml0eSI6IkZsYWdzaGlwIiwic291cmNlIjoiT3JpZ2luYWwgMeKAkzMwICh1c2VyIHNvdXJjZSkiLCJwcm92ZW5hbmNlIjoib3JpZ2luYWwiLCJwcmVyZXF1aXNpdGVzIjoiQXJjaGl0ZWN0dXJlICYgb3JjaGVzdHJhdGlvbiIsImVzdEhvdXJzIjoyOH0seyJwbGFuSWQiOiJjaHJvbmlzLWFpLWVuZ2luZWVyaW5nLTIwMjYtMTEtMDUiLCJpZCI6IlAzMSIsInRpdGxlIjoiRGV2ZWxvcGVyIFByb2R1Y3Rpdml0eSBDTEkgJiBDb2RlIFF1YWxpdHkgQXNzaXN0YW50IiwibGV2ZWwiOiJCZWdpbm5lciIsInBoYXNlIjoiMDEgwrcgUHl0aG9uICYgRm91bmRhdGlvbnMiLCJzdGFydERheSI6NiwiZmlyc3RTcHJpbnQiOiIyMDI2LTExLTEwIiwic3RhY2siOiJQeXRob24sIFJ1ZmYsIHB5dGVzdCwgVHlwZXIiLCJtdnAiOiJDTEkgZm9yIHRhc2sgY3JlYXRpb24sIGxpbnQgc3VtbWFyeSBhbmQgdGVzdCBoaXN0b3J5IiwiZmVhdHVyZXMiOiJDTEkgZm9yIHRhc2sgY3JlYXRpb24sIGxpbnQgc3VtbWFyeSBhbmQgdGVzdCBoaXN0b3J5OyBDTEkgd29ya3Mgb24gc2FtcGxlIHJlcG9zaXRvcnk7IGVtaXRzIEpTT04gcmVwb3J0IiwiYWNjZXB0YW5jZSI6IkNMSSB3b3JrcyBvbiBzYW1wbGUgcmVwb3NpdG9yeTsgZW1pdHMgSlNPTiByZXBvcnQiLCJpbnRlcnZpZXdUb3BpYyI6IkFyY2hpdGVjdHVyZSBhbmQgcmVsaWFiaWxpdHkgb2YgZGV2ZWxvcGVyIHByb2R1Y3Rpdml0eSBjbGkgJiBjb2RlIHF1YWxpdHkgYXNzaXN0YW50IiwicHJpb3JpdHkiOiJQcm90b3R5cGUiLCJzb3VyY2UiOiJBZGRpdGlvbmFsIDMx4oCTNTAgKG5ldyBwcm9wb3NhbCkiLCJwcm92ZW5hbmNlIjoic3VwcGxlbWVudGFsIiwicHJlcmVxdWlzaXRlcyI6IlB5dGhvbiBmb3VuZGF0aW9ucyIsImVzdEhvdXJzIjo0fSx7InBsYW5JZCI6ImNocm9uaXMtYWktZW5naW5lZXJpbmctMjAyNi0xMS0wNSIsImlkIjoiUDMyIiwidGl0bGUiOiJDdXN0b21lciBTZWdtZW50YXRpb24gSW50ZWxsaWdlbmNlIEFQSSIsImxldmVsIjoiSW50ZXJtZWRpYXRlIiwicGhhc2UiOiIwMiDCtyBDbGFzc2ljYWwgTUwiLCJzdGFydERheSI6MTksImZpcnN0U3ByaW50IjoiMjAyNi0xMS0yMyIsInN0YWNrIjoiU2Npa2l0LWxlYXJuLCBQYW5kYXMsIEZhc3RBUEkiLCJtdnAiOiJDbHVzdGVyIGN1c3RvbWVycywgcHJvZmlsZSBzZWdtZW50cywgZXhwb3NlIEFQSSIsImZlYXR1cmVzIjoiQ2x1c3RlciBjdXN0b21lcnMsIHByb2ZpbGUgc2VnbWVudHMsIGV4cG9zZSBBUEk7IFJlcHJvZHVjaWJsZSBjbHVzdGVyaW5nOyBsYWJlbHMgYW5kIHNlZ21lbnQgbWV0cmljcyIsImFjY2VwdGFuY2UiOiJSZXByb2R1Y2libGUgY2x1c3RlcmluZzsgbGFiZWxzIGFuZCBzZWdtZW50IG1ldHJpY3MiLCJpbnRlcnZpZXdUb3BpYyI6IkFyY2hpdGVjdHVyZSBhbmQgcmVsaWFiaWxpdHkgb2YgY3VzdG9tZXIgc2VnbWVudGF0aW9uIGludGVsbGlnZW5jZSBhcGkiLCJwcmlvcml0eSI6IlByb3RvdHlwZSIsInNvdXJjZSI6IkFkZGl0aW9uYWwgMzHigJM1MCAobmV3IHByb3Bvc2FsKSIsInByb3ZlbmFuY2UiOiJzdXBwbGVtZW50YWwiLCJwcmVyZXF1aXNpdGVzIjoiQ2xhc3NpY2FsIE1MIiwiZXN0SG91cnMiOjh9LHsicGxhbklkIjoiY2hyb25pcy1haS1lbmdpbmVlcmluZy0yMDI2LTExLTA1IiwiaWQiOiJQMzMiLCJ0aXRsZSI6Ik1MIEV4cGVyaW1lbnQgVHJhY2tlciBEYXNoYm9hcmQiLCJsZXZlbCI6IkludGVybWVkaWF0ZSIsInBoYXNlIjoiMDIgwrcgQ2xhc3NpY2FsIE1MIiwic3RhcnREYXkiOjIxLCJmaXJzdFNwcmludCI6IjIwMjYtMTEtMjUiLCJzdGFjayI6IlB5dGhvbiwgTUxmbG93LCBTdHJlYW1saXQiLCJtdnAiOiJUcmFjayBkYXRhc2V0cywgcGFyYW1ldGVycywgcnVucywgbWV0cmljcyBhbmQgYXJ0aWZhY3RzIiwiZmVhdHVyZXMiOiJUcmFjayBkYXRhc2V0cywgcGFyYW1ldGVycywgcnVucywgbWV0cmljcyBhbmQgYXJ0aWZhY3RzOyBDb21wYXJlIDMgcnVucyB3aXRoIHJlcHJvZHVjaWJsZSBjb25maWd1cmF0aW9uIiwiYWNjZXB0YW5jZSI6IkNvbXBhcmUgMyBydW5zIHdpdGggcmVwcm9kdWNpYmxlIGNvbmZpZ3VyYXRpb24iLCJpbnRlcnZpZXdUb3BpYyI6IkFyY2hpdGVjdHVyZSBhbmQgcmVsaWFiaWxpdHkgb2YgbWwgZXhwZXJpbWVudCB0cmFja2VyIGRhc2hib2FyZCIsInByaW9yaXR5IjoiUHJvdG90eXBlIiwic291cmNlIjoiQWRkaXRpb25hbCAzMeKAkzUwIChuZXcgcHJvcG9zYWwpIiwicHJvdmVuYW5jZSI6InN1cHBsZW1lbnRhbCIsInByZXJlcXVpc2l0ZXMiOiJDbGFzc2ljYWwgTUwiLCJlc3RIb3VycyI6OH0seyJwbGFuSWQiOiJjaHJvbmlzLWFpLWVuZ2luZWVyaW5nLTIwMjYtMTEtMDUiLCJpZCI6IlAzNCIsInRpdGxlIjoiVHJhbnNmb3JtZXItQmFzZWQgVGV4dCBTdW1tYXJpemVyIiwibGV2ZWwiOiJJbnRlcm1lZGlhdGUiLCJwaGFzZSI6IjAzIMK3IERlZXAgTGVhcm5pbmcgJiBOTFAiLCJzdGFydERheSI6MzMsImZpcnN0U3ByaW50IjoiMjAyNi0xMi0wNyIsInN0YWNrIjoiSHVnZ2luZyBGYWNlLCBUcmFuc2Zvcm1lcnMsIFB5VG9yY2giLCJtdnAiOiJTdW1tYXJpemUgc2hvcnQgYXJ0aWNsZXMgd2l0aCBldmFsdWF0aW9uIGFuZCB0b2tlbiBidWRnZXRzIiwiZmVhdHVyZXMiOiJTdW1tYXJpemUgc2hvcnQgYXJ0aWNsZXMgd2l0aCBldmFsdWF0aW9uIGFuZCB0b2tlbiBidWRnZXRzOyBCYXNlbGluZSArIHRpbnkgdHJhbnNmb3JtZXIgKyBST1VHRS1zdHlsZSBzY29yZXMiLCJhY2NlcHRhbmNlIjoiQmFzZWxpbmUgKyB0aW55IHRyYW5zZm9ybWVyICsgUk9VR0Utc3R5bGUgc2NvcmVzIiwiaW50ZXJ2aWV3VG9waWMiOiJBcmNoaXRlY3R1cmUgYW5kIHJlbGlhYmlsaXR5IG9mIHRyYW5zZm9ybWVyLWJhc2VkIHRleHQgc3VtbWFyaXplciIsInByaW9yaXR5IjoiUHJvdG90eXBlIiwic291cmNlIjoiQWRkaXRpb25hbCAzMeKAkzUwIChuZXcgcHJvcG9zYWwpIiwicHJvdmVuYW5jZSI6InN1cHBsZW1lbnRhbCIsInByZXJlcXVpc2l0ZXMiOiJEZWVwIGxlYXJuaW5nIiwiZXN0SG91cnMiOjh9LHsicGxhbklkIjoiY2hyb25pcy1haS1lbmdpbmVlcmluZy0yMDI2LTExLTA1IiwiaWQiOiJQMzUiLCJ0aXRsZSI6Ik1vZGVsIERyaWZ0IE1vbml0b3JpbmcgTGFiIiwibGV2ZWwiOiJJbnRlcm1lZGlhdGUiLCJwaGFzZSI6IjAzIMK3IERlZXAgTGVhcm5pbmcgJiBOTFAiLCJzdGFydERheSI6MzUsImZpcnN0U3ByaW50IjoiMjAyNi0xMi0wOSIsInN0YWNrIjoiUHl0aG9uLCBFdmlkZW50bHksIEZhc3RBUEkiLCJtdnAiOiJEZXRlY3QgZGF0YSBzaGlmdCBmcm9tIHRyYWluaW5nIHRvIGluY29taW5nIGJhdGNoZXMiLCJmZWF0dXJlcyI6IkRldGVjdCBkYXRhIHNoaWZ0IGZyb20gdHJhaW5pbmcgdG8gaW5jb21pbmcgYmF0Y2hlczsgR2VuZXJhdGUgZHJpZnQgcmVwb3J0IGFuZCB0cmlnZ2VyIHRocmVzaG9sZCBhbGVydCIsImFjY2VwdGFuY2UiOiJHZW5lcmF0ZSBkcmlmdCByZXBvcnQgYW5kIHRyaWdnZXIgdGhyZXNob2xkIGFsZXJ0IiwiaW50ZXJ2aWV3VG9waWMiOiJBcmNoaXRlY3R1cmUgYW5kIHJlbGlhYmlsaXR5IG9mIG1vZGVsIGRyaWZ0IG1vbml0b3JpbmcgbGFiIiwicHJpb3JpdHkiOiJQcm90b3R5cGUiLCJzb3VyY2UiOiJBZGRpdGlvbmFsIDMx4oCTNTAgKG5ldyBwcm9wb3NhbCkiLCJwcm92ZW5hbmNlIjoic3VwcGxlbWVudGFsIiwicHJlcmVxdWlzaXRlcyI6IkRlZXAgbGVhcm5pbmciLCJlc3RIb3VycyI6OH0seyJwbGFuSWQiOiJjaHJvbmlzLWFpLWVuZ2luZWVyaW5nLTIwMjYtMTEtMDUiLCJpZCI6IlAzNiIsInRpdGxlIjoiTExNIFRva2VuIE1ldGVyICYgUHJvbXB0IEJ1ZGdldCBSb3V0ZXIiLCJsZXZlbCI6IkFkdmFuY2VkIiwicGhhc2UiOiIwNCDCtyBMTE1zICYgUkFHIiwic3RhcnREYXkiOjQ5LCJmaXJzdFNwcmludCI6IjIwMjYtMTItMjMiLCJzdGFjayI6IlB5dGhvbiwgRmFzdEFQSSwgTExNIFNES3MiLCJtdnAiOiJFc3RpbWF0ZSB0b2tlbnMsIGNhcCBjb3N0IGFuZCBmYWxsYmFjayBieSBwb2xpY3kiLCJmZWF0dXJlcyI6IkVzdGltYXRlIHRva2VucywgY2FwIGNvc3QgYW5kIGZhbGxiYWNrIGJ5IHBvbGljeTsgUmVjb3JkIHBlci1zZXNzaW9uIGNvc3Qgd2l0aCBoYXJkIGJ1ZGdldCBjZWlsaW5nIiwiYWNjZXB0YW5jZSI6IlJlY29yZCBwZXItc2Vzc2lvbiBjb3N0IHdpdGggaGFyZCBidWRnZXQgY2VpbGluZyIsImludGVydmlld1RvcGljIjoiQXJjaGl0ZWN0dXJlIGFuZCByZWxpYWJpbGl0eSBvZiBsbG0gdG9rZW4gbWV0ZXIgJiBwcm9tcHQgYnVkZ2V0IHJvdXRlciIsInByaW9yaXR5IjoiUHJvdG90eXBlIiwic291cmNlIjoiQWRkaXRpb25hbCAzMeKAkzUwIChuZXcgcHJvcG9zYWwpIiwicHJvdmVuYW5jZSI6InN1cHBsZW1lbnRhbCIsInByZXJlcXVpc2l0ZXMiOiJMTE1zICYgUkFHIiwiZXN0SG91cnMiOjE2fSx7InBsYW5JZCI6ImNocm9uaXMtYWktZW5naW5lZXJpbmctMjAyNi0xMS0wNSIsImlkIjoiUDM3IiwidGl0bGUiOiJNdWx0aWxpbmd1YWwgS25vd2xlZGdlIEJvdCIsImxldmVsIjoiQWR2YW5jZWQiLCJwaGFzZSI6IjA0IMK3IExMTXMgJiBSQUciLCJzdGFydERheSI6NTEsImZpcnN0U3ByaW50IjoiMjAyNi0xMi0yNSIsInN0YWNrIjoiRmFzdEFQSSwgbXVsdGlsaW5ndWFsIGVtYmVkZGluZ3MsIHBndmVjdG9yIiwibXZwIjoiQW5zd2VyIHF1ZXN0aW9ucyBhZ2FpbnN0IEVuZ2xpc2ggYW5kIFRlbHVndS9IaW5kaSBzYW1wbGVzIiwiZmVhdHVyZXMiOiJBbnN3ZXIgcXVlc3Rpb25zIGFnYWluc3QgRW5nbGlzaCBhbmQgVGVsdWd1L0hpbmRpIHNhbXBsZXM7IENyb3NzLWxhbmd1YWdlIHJldHJpZXZhbCBldmFsdWF0aW9uIHdpdGggY2l0YXRpb25zIiwiYWNjZXB0YW5jZSI6IkNyb3NzLWxhbmd1YWdlIHJldHJpZXZhbCBldmFsdWF0aW9uIHdpdGggY2l0YXRpb25zIiwiaW50ZXJ2aWV3VG9waWMiOiJBcmNoaXRlY3R1cmUgYW5kIHJlbGlhYmlsaXR5IG9mIG11bHRpbGluZ3VhbCBrbm93bGVkZ2UgYm90IiwicHJpb3JpdHkiOiJQcm90b3R5cGUiLCJzb3VyY2UiOiJBZGRpdGlvbmFsIDMx4oCTNTAgKG5ldyBwcm9wb3NhbCkiLCJwcm92ZW5hbmNlIjoic3VwcGxlbWVudGFsIiwicHJlcmVxdWlzaXRlcyI6IkxMTXMgJiBSQUciLCJlc3RIb3VycyI6MTZ9LHsicGxhbklkIjoiY2hyb25pcy1haS1lbmdpbmVlcmluZy0yMDI2LTExLTA1IiwiaWQiOiJQMzgiLCJ0aXRsZSI6IlNlY3VyZSBBSSBUb29sIFJlZ2lzdHJ5IiwibGV2ZWwiOiJBZHZhbmNlZCIsInBoYXNlIjoiMDUgwrcgQWdlbnRzICYgSGFybmVzcyIsInN0YXJ0RGF5Ijo1NSwiZmlyc3RTcHJpbnQiOiIyMDI2LTEyLTI5Iiwic3RhY2siOiJQeXRob24sIEZhc3RBUEksIFB5ZGFudGljIiwibXZwIjoiUmVnaXN0ZXIgdmVyc2lvbmVkIHRvb2xzIHdpdGggc2NoZW1hcyBhbmQgcGVybWlzc2lvbnMiLCJmZWF0dXJlcyI6IlJlZ2lzdGVyIHZlcnNpb25lZCB0b29scyB3aXRoIHNjaGVtYXMgYW5kIHBlcm1pc3Npb25zOyBVbmF1dGhvcml6ZWQgdG9vbCBibG9ja2VkIGFuZCBmdWxseSBsb2dnZWQiLCJhY2NlcHRhbmNlIjoiVW5hdXRob3JpemVkIHRvb2wgYmxvY2tlZCBhbmQgZnVsbHkgbG9nZ2VkIiwiaW50ZXJ2aWV3VG9waWMiOiJBcmNoaXRlY3R1cmUgYW5kIHJlbGlhYmlsaXR5IG9mIHNlY3VyZSBhaSB0b29sIHJlZ2lzdHJ5IiwicHJpb3JpdHkiOiJQcm90b3R5cGUiLCJzb3VyY2UiOiJBZGRpdGlvbmFsIDMx4oCTNTAgKG5ldyBwcm9wb3NhbCkiLCJwcm92ZW5hbmNlIjoic3VwcGxlbWVudGFsIiwicHJlcmVxdWlzaXRlcyI6IkFnZW50IGhhcm5lc3MiLCJlc3RIb3VycyI6MTZ9LHsicGxhbklkIjoiY2hyb25pcy1haS1lbmdpbmVlcmluZy0yMDI2LTExLTA1IiwiaWQiOiJQMzkiLCJ0aXRsZSI6IlBsYW5uZXLigJNFeGVjdXRvciBBZ2VudCBXb3JrYmVuY2giLCJsZXZlbCI6IkFkdmFuY2VkIiwicGhhc2UiOiIwNSDCtyBBZ2VudHMgJiBIYXJuZXNzIiwic3RhcnREYXkiOjU4LCJmaXJzdFNwcmludCI6IjIwMjctMDEtMDEiLCJzdGFjayI6IkxhbmdHcmFwaCwgTExNIEFQSXMiLCJtdnAiOiJTZXBhcmF0ZSB0YXNrIHBsYW5uaW5nLCB0b29sIGV4ZWN1dGlvbiwgdmVyaWZpY2F0aW9uIiwiZmVhdHVyZXMiOiJTZXBhcmF0ZSB0YXNrIHBsYW5uaW5nLCB0b29sIGV4ZWN1dGlvbiwgdmVyaWZpY2F0aW9uOyBEZXRlcm1pbmlzdGljIGRlbW8gb2YgYm91bmRlZCBleGVjdXRpb24gd2l0aCByZXRyaWVzIiwiYWNjZXB0YW5jZSI6IkRldGVybWluaXN0aWMgZGVtbyBvZiBib3VuZGVkIGV4ZWN1dGlvbiB3aXRoIHJldHJpZXMiLCJpbnRlcnZpZXdUb3BpYyI6IkFyY2hpdGVjdHVyZSBhbmQgcmVsaWFiaWxpdHkgb2YgcGxhbm5lcuKAk2V4ZWN1dG9yIGFnZW50IHdvcmtiZW5jaCIsInByaW9yaXR5IjoiUHJvdG90eXBlIiwic291cmNlIjoiQWRkaXRpb25hbCAzMeKAkzUwIChuZXcgcHJvcG9zYWwpIiwicHJvdmVuYW5jZSI6InN1cHBsZW1lbnRhbCIsInByZXJlcXVpc2l0ZXMiOiJBZ2VudCBoYXJuZXNzIiwiZXN0SG91cnMiOjE2fSx7InBsYW5JZCI6ImNocm9uaXMtYWktZW5naW5lZXJpbmctMjAyNi0xMS0wNSIsImlkIjoiUDQwIiwidGl0bGUiOiJBZ2VudCBNZW1vcnkgJiBDaGVja3BvaW50IFNlcnZpY2UiLCJsZXZlbCI6IkFkdmFuY2VkIiwicGhhc2UiOiIwNSDCtyBBZ2VudHMgJiBIYXJuZXNzIiwic3RhcnREYXkiOjYxLCJmaXJzdFNwcmludCI6IjIwMjctMDEtMDQiLCJzdGFjayI6IlBvc3RncmVTUUwsIFJlZGlzLCBMYW5nR3JhcGgiLCJtdnAiOiJQZXJzaXN0IGNoZWNrcG9pbnRzLCByZXN1bWUgc2FmZSBydW5zLCBtYW5hZ2Ugc3VtbWFyaWVzIiwiZmVhdHVyZXMiOiJQZXJzaXN0IGNoZWNrcG9pbnRzLCByZXN1bWUgc2FmZSBydW5zLCBtYW5hZ2Ugc3VtbWFyaWVzOyBSZWNvdmVyIGludGVycnVwdGVkIDMtc3RlcCB3b3JrZmxvdyB3aXRob3V0IGR1cGxpY2F0ZSBhY3Rpb24iLCJhY2NlcHRhbmNlIjoiUmVjb3ZlciBpbnRlcnJ1cHRlZCAzLXN0ZXAgd29ya2Zsb3cgd2l0aG91dCBkdXBsaWNhdGUgYWN0aW9uIiwiaW50ZXJ2aWV3VG9waWMiOiJBcmNoaXRlY3R1cmUgYW5kIHJlbGlhYmlsaXR5IG9mIGFnZW50IG1lbW9yeSAmIGNoZWNrcG9pbnQgc2VydmljZSIsInByaW9yaXR5IjoiUHJvdG90eXBlIiwic291cmNlIjoiQWRkaXRpb25hbCAzMeKAkzUwIChuZXcgcHJvcG9zYWwpIiwicHJvdmVuYW5jZSI6InN1cHBsZW1lbnRhbCIsInByZXJlcXVpc2l0ZXMiOiJBZ2VudCBoYXJuZXNzIiwiZXN0SG91cnMiOjE2fSx7InBsYW5JZCI6ImNocm9uaXMtYWktZW5naW5lZXJpbmctMjAyNi0xMS0wNSIsImlkIjoiUDQxIiwidGl0bGUiOiJBSSBJbmNpZGVudCBUcmlhZ2UgQ29waWxvdCIsImxldmVsIjoiQWR2YW5jZWQiLCJwaGFzZSI6IjA1IMK3IEFnZW50cyAmIEhhcm5lc3MiLCJzdGFydERheSI6NjQsImZpcnN0U3ByaW50IjoiMjAyNy0wMS0wNyIsInN0YWNrIjoiTGFuZ0dyYXBoLCByZXRyaWV2YWwsIHRpY2tldCBzdHVicyIsIm12cCI6IkNsYXNzaWZ5IGluY2lkZW50cyBhbmQgcHJvcG9zZSBydW5ib29rIGFjdGlvbiIsImZlYXR1cmVzIjoiQ2xhc3NpZnkgaW5jaWRlbnRzIGFuZCBwcm9wb3NlIHJ1bmJvb2sgYWN0aW9uOyBQcm9kdWNlcyBjaXRlZCBzZXZlcml0eSByYXRpb25hbGUsIHJlcXVlc3RzIGVzY2FsYXRpb24iLCJhY2NlcHRhbmNlIjoiUHJvZHVjZXMgY2l0ZWQgc2V2ZXJpdHkgcmF0aW9uYWxlLCByZXF1ZXN0cyBlc2NhbGF0aW9uIiwiaW50ZXJ2aWV3VG9waWMiOiJBcmNoaXRlY3R1cmUgYW5kIHJlbGlhYmlsaXR5IG9mIGFpIGluY2lkZW50IHRyaWFnZSBjb3BpbG90IiwicHJpb3JpdHkiOiJQcm90b3R5cGUiLCJzb3VyY2UiOiJBZGRpdGlvbmFsIDMx4oCTNTAgKG5ldyBwcm9wb3NhbCkiLCJwcm92ZW5hbmNlIjoic3VwcGxlbWVudGFsIiwicHJlcmVxdWlzaXRlcyI6IkFnZW50IGhhcm5lc3MiLCJlc3RIb3VycyI6MTZ9LHsicGxhbklkIjoiY2hyb25pcy1haS1lbmdpbmVlcmluZy0yMDI2LTExLTA1IiwiaWQiOiJQNDIiLCJ0aXRsZSI6IkFnZW50IEhhcm5lc3MgQmVuY2htYXJrICYgRXZhbCBTdWl0ZSIsImxldmVsIjoiQWR2YW5jZWQiLCJwaGFzZSI6IjA1IMK3IEFnZW50cyAmIEhhcm5lc3MiLCJzdGFydERheSI6NjgsImZpcnN0U3ByaW50IjoiMjAyNy0wMS0xMSIsInN0YWNrIjoicHl0ZXN0LCBMYW5nR3JhcGgsIHRyYWNpbmciLCJtdnAiOiJUcmFjayB0b29sIGNhbGwgYWNjdXJhY3ksIHNhZmV0eSwgbGF0ZW5jeSBhbmQgY29zdCIsImZlYXR1cmVzIjoiVHJhY2sgdG9vbCBjYWxsIGFjY3VyYWN5LCBzYWZldHksIGxhdGVuY3kgYW5kIGNvc3Q7IFJ1bnMgMTAgc2VlZGVkIHNjZW5hcmlvcyB3aXRoIHJlcG9ydCBhbmQgQ0kgZ2F0ZSIsImFjY2VwdGFuY2UiOiJSdW5zIDEwIHNlZWRlZCBzY2VuYXJpb3Mgd2l0aCByZXBvcnQgYW5kIENJIGdhdGUiLCJpbnRlcnZpZXdUb3BpYyI6IkFyY2hpdGVjdHVyZSBhbmQgcmVsaWFiaWxpdHkgb2YgYWdlbnQgaGFybmVzcyBiZW5jaG1hcmsgJiBldmFsIHN1aXRlIiwicHJpb3JpdHkiOiJQb3J0Zm9saW8iLCJzb3VyY2UiOiJBZGRpdGlvbmFsIDMx4oCTNTAgKG5ldyBwcm9wb3NhbCkiLCJwcm92ZW5hbmNlIjoic3VwcGxlbWVudGFsIiwicHJlcmVxdWlzaXRlcyI6IkFnZW50IGhhcm5lc3MiLCJlc3RIb3VycyI6MTZ9LHsicGxhbklkIjoiY2hyb25pcy1haS1lbmdpbmVlcmluZy0yMDI2LTExLTA1IiwiaWQiOiJQNDMiLCJ0aXRsZSI6IlBJSSBSZWRhY3Rpb24gJiBTYWZldHkgR2F0ZXdheSIsImxldmVsIjoiQ29tcGxleCIsInBoYXNlIjoiMDYgwrcgUHJvZHVjdGlvbiAmIExMTU9wcyIsInN0YXJ0RGF5Ijo3MSwiZmlyc3RTcHJpbnQiOiIyMDI3LTAxLTE0Iiwic3RhY2siOiJGYXN0QVBJLCByZWdleCwgUHJlc2lkaW8iLCJtdnAiOiJNYXNrIHNlbnNpdGl2ZSBkYXRhIGJlZm9yZSBtb2RlbCBjYWxscyBhbmQgbG9ncyIsImZlYXR1cmVzIjoiTWFzayBzZW5zaXRpdmUgZGF0YSBiZWZvcmUgbW9kZWwgY2FsbHMgYW5kIGxvZ3M7IFRlc3QgUElJIGxlYWthZ2UgY2FzZXMgYWNyb3NzIHJlcXVlc3QgYW5kIHRyYWNlIiwiYWNjZXB0YW5jZSI6IlRlc3QgUElJIGxlYWthZ2UgY2FzZXMgYWNyb3NzIHJlcXVlc3QgYW5kIHRyYWNlIiwiaW50ZXJ2aWV3VG9waWMiOiJBcmNoaXRlY3R1cmUgYW5kIHJlbGlhYmlsaXR5IG9mIHBpaSByZWRhY3Rpb24gJiBzYWZldHkgZ2F0ZXdheSIsInByaW9yaXR5IjoiUHJvdG90eXBlIiwic291cmNlIjoiQWRkaXRpb25hbCAzMeKAkzUwIChuZXcgcHJvcG9zYWwpIiwicHJvdmVuYW5jZSI6InN1cHBsZW1lbnRhbCIsInByZXJlcXVpc2l0ZXMiOiJQcm9kdWN0aW9uIiwiZXN0SG91cnMiOjI4fSx7InBsYW5JZCI6ImNocm9uaXMtYWktZW5naW5lZXJpbmctMjAyNi0xMS0wNSIsImlkIjoiUDQ0IiwidGl0bGUiOiJFdmVudC1Ecml2ZW4gRW1iZWRkaW5nIFBpcGVsaW5lIiwibGV2ZWwiOiJDb21wbGV4IiwicGhhc2UiOiIwNiDCtyBQcm9kdWN0aW9uICYgTExNT3BzIiwic3RhcnREYXkiOjczLCJmaXJzdFNwcmludCI6IjIwMjctMDEtMTYiLCJzdGFjayI6IlJlZGlzL0NlbGVyeSwgUG9zdGdyZVNRTCwgcGd2ZWN0b3IiLCJtdnAiOiJJbmdlc3QgcXVldWVkIGRvY3VtZW50cyB3aXRoIGRlZHVwLCByZXRyaWVzIGFuZCBETFEiLCJmZWF0dXJlcyI6IkluZ2VzdCBxdWV1ZWQgZG9jdW1lbnRzIHdpdGggZGVkdXAsIHJldHJpZXMgYW5kIERMUTsgRHVwbGljYXRlIGpvYiBjYW5ub3QgY3JlYXRlIGR1cGxpY2F0ZSB2ZWN0b3JzIiwiYWNjZXB0YW5jZSI6IkR1cGxpY2F0ZSBqb2IgY2Fubm90IGNyZWF0ZSBkdXBsaWNhdGUgdmVjdG9ycyIsImludGVydmlld1RvcGljIjoiQXJjaGl0ZWN0dXJlIGFuZCByZWxpYWJpbGl0eSBvZiBldmVudC1kcml2ZW4gZW1iZWRkaW5nIHBpcGVsaW5lIiwicHJpb3JpdHkiOiJQcm90b3R5cGUiLCJzb3VyY2UiOiJBZGRpdGlvbmFsIDMx4oCTNTAgKG5ldyBwcm9wb3NhbCkiLCJwcm92ZW5hbmNlIjoic3VwcGxlbWVudGFsIiwicHJlcmVxdWlzaXRlcyI6IlByb2R1Y3Rpb24iLCJlc3RIb3VycyI6Mjh9LHsicGxhbklkIjoiY2hyb25pcy1haS1lbmdpbmVlcmluZy0yMDI2LTExLTA1IiwiaWQiOiJQNDUiLCJ0aXRsZSI6IlN5bnRoZXRpYyBBSSBFdmFsdWF0aW9uIERhdGFzZXQgR2VuZXJhdG9yIiwibGV2ZWwiOiJDb21wbGV4IiwicGhhc2UiOiIwNiDCtyBQcm9kdWN0aW9uICYgTExNT3BzIiwic3RhcnREYXkiOjc1LCJmaXJzdFNwcmludCI6IjIwMjctMDEtMTgiLCJzdGFjayI6IlB5dGhvbiwgTExNIEFQSXMsIHB5dGVzdCIsIm12cCI6IkdlbmVyYXRlIHNlZWQgUUEgcGFpcnMgd2l0aCBodW1hbiByZXZpZXcgYW5kIHZlcnNpb25pbmciLCJmZWF0dXJlcyI6IkdlbmVyYXRlIHNlZWQgUUEgcGFpcnMgd2l0aCBodW1hbiByZXZpZXcgYW5kIHZlcnNpb25pbmc7IDIwIHJldmlld2VkIGNhc2VzIHNwbGl0IGludG8gY2xlYW4gZXZhbHVhdGlvbiBzZXRzIiwiYWNjZXB0YW5jZSI6IjIwIHJldmlld2VkIGNhc2VzIHNwbGl0IGludG8gY2xlYW4gZXZhbHVhdGlvbiBzZXRzIiwiaW50ZXJ2aWV3VG9waWMiOiJBcmNoaXRlY3R1cmUgYW5kIHJlbGlhYmlsaXR5IG9mIHN5bnRoZXRpYyBhaSBldmFsdWF0aW9uIGRhdGFzZXQgZ2VuZXJhdG9yIiwicHJpb3JpdHkiOiJQcm90b3R5cGUiLCJzb3VyY2UiOiJBZGRpdGlvbmFsIDMx4oCTNTAgKG5ldyBwcm9wb3NhbCkiLCJwcm92ZW5hbmNlIjoic3VwcGxlbWVudGFsIiwicHJlcmVxdWlzaXRlcyI6IlByb2R1Y3Rpb24iLCJlc3RIb3VycyI6Mjh9LHsicGxhbklkIjoiY2hyb25pcy1haS1lbmdpbmVlcmluZy0yMDI2LTExLTA1IiwiaWQiOiJQNDYiLCJ0aXRsZSI6IkNvc3QtQXdhcmUgTXVsdGktUHJvdmlkZXIgTW9kZWwgUm91dGVyIiwibGV2ZWwiOiJDb21wbGV4IiwicGhhc2UiOiIwNiDCtyBQcm9kdWN0aW9uICYgTExNT3BzIiwic3RhcnREYXkiOjc3LCJmaXJzdFNwcmludCI6IjIwMjctMDEtMjAiLCJzdGFjayI6IkZhc3RBUEksIGNhY2hpbmcsIFNESyBhZGFwdGVycyIsIm12cCI6IlNlbGVjdCBzYWZlIHJvdXRlIHVzaW5nIGNvc3QsIGxhdGVuY3kgYW5kIHF1YWxpdHkgcG9saWN5IiwiZmVhdHVyZXMiOiJTZWxlY3Qgc2FmZSByb3V0ZSB1c2luZyBjb3N0LCBsYXRlbmN5IGFuZCBxdWFsaXR5IHBvbGljeTsgRmFsbGJhY2sgYW5kIGNpcmN1aXQtYnJlYWtlciB0ZXN0IHN1Y2NlZWRzIiwiYWNjZXB0YW5jZSI6IkZhbGxiYWNrIGFuZCBjaXJjdWl0LWJyZWFrZXIgdGVzdCBzdWNjZWVkcyIsImludGVydmlld1RvcGljIjoiQXJjaGl0ZWN0dXJlIGFuZCByZWxpYWJpbGl0eSBvZiBjb3N0LWF3YXJlIG11bHRpLXByb3ZpZGVyIG1vZGVsIHJvdXRlciIsInByaW9yaXR5IjoiUHJvdG90eXBlIiwic291cmNlIjoiQWRkaXRpb25hbCAzMeKAkzUwIChuZXcgcHJvcG9zYWwpIiwicHJvdmVuYW5jZSI6InN1cHBsZW1lbnRhbCIsInByZXJlcXVpc2l0ZXMiOiJQcm9kdWN0aW9uIiwiZXN0SG91cnMiOjI4fSx7InBsYW5JZCI6ImNocm9uaXMtYWktZW5naW5lZXJpbmctMjAyNi0xMS0wNSIsImlkIjoiUDQ3IiwidGl0bGUiOiJBSSBSZWxlYXNlIEdhdGUgJiBQcm9tcHQgUmVncmVzc2lvbiBDSSIsImxldmVsIjoiQ29tcGxleCIsInBoYXNlIjoiMDYgwrcgUHJvZHVjdGlvbiAmIExMTU9wcyIsInN0YXJ0RGF5Ijo3OSwiZmlyc3RTcHJpbnQiOiIyMDI3LTAxLTIyIiwic3RhY2siOiJHaXRIdWIgQWN0aW9ucywgcHl0ZXN0LCBldmFsIGhhcm5lc3MiLCJtdnAiOiJCbG9jayByZWxlYXNlcyBvbiBmYWlsaW5nIExMTS9SQUcgcmVncmVzc2lvbiBjaGVja3MiLCJmZWF0dXJlcyI6IkJsb2NrIHJlbGVhc2VzIG9uIGZhaWxpbmcgTExNL1JBRyByZWdyZXNzaW9uIGNoZWNrczsgR3JlZW4vcmVkIGRlbW9uc3RyYXRpb24gd2l0aCBzdG9yZWQgZXZhbCBhcnRpZmFjdHMiLCJhY2NlcHRhbmNlIjoiR3JlZW4vcmVkIGRlbW9uc3RyYXRpb24gd2l0aCBzdG9yZWQgZXZhbCBhcnRpZmFjdHMiLCJpbnRlcnZpZXdUb3BpYyI6IkFyY2hpdGVjdHVyZSBhbmQgcmVsaWFiaWxpdHkgb2YgYWkgcmVsZWFzZSBnYXRlICYgcHJvbXB0IHJlZ3Jlc3Npb24gY2kiLCJwcmlvcml0eSI6IlByb3RvdHlwZSIsInNvdXJjZSI6IkFkZGl0aW9uYWwgMzHigJM1MCAobmV3IHByb3Bvc2FsKSIsInByb3ZlbmFuY2UiOiJzdXBwbGVtZW50YWwiLCJwcmVyZXF1aXNpdGVzIjoiUHJvZHVjdGlvbiIsImVzdEhvdXJzIjoyOH0seyJwbGFuSWQiOiJjaHJvbmlzLWFpLWVuZ2luZWVyaW5nLTIwMjYtMTEtMDUiLCJpZCI6IlA0OCIsInRpdGxlIjoiS25vd2xlZGdlIEdyYXBoIEV4dHJhY3Rpb24gU3R1ZGlvIiwibGV2ZWwiOiJDb21wbGV4IiwicGhhc2UiOiIwNyDCtyBBcmNoaXRlY3QgQ2Fwc3RvbmVzIiwic3RhcnREYXkiOjgxLCJmaXJzdFNwcmludCI6IjIwMjctMDEtMjQiLCJzdGFjayI6Ik5lbzRqLCBOTFAsIEdyYXBoUkFHIiwibXZwIjoiRXh0cmFjdCB0cmlwbGVzLCByZXNvbHZlIGVudGl0aWVzIGFuZCBidWlsZCBncmFwaCBleHBsb3JlciIsImZlYXR1cmVzIjoiRXh0cmFjdCB0cmlwbGVzLCByZXNvbHZlIGVudGl0aWVzIGFuZCBidWlsZCBncmFwaCBleHBsb3JlcjsgMTAgZXZpZGVuY2UtbGlua2VkIGVudGl0aWVzL2VkZ2VzIHdpdGggZ3JhcGggcXVlcmllcyIsImFjY2VwdGFuY2UiOiIxMCBldmlkZW5jZS1saW5rZWQgZW50aXRpZXMvZWRnZXMgd2l0aCBncmFwaCBxdWVyaWVzIiwiaW50ZXJ2aWV3VG9waWMiOiJBcmNoaXRlY3R1cmUgYW5kIHJlbGlhYmlsaXR5IG9mIGtub3dsZWRnZSBncmFwaCBleHRyYWN0aW9uIHN0dWRpbyIsInByaW9yaXR5IjoiUHJvdG90eXBlIiwic291cmNlIjoiQWRkaXRpb25hbCAzMeKAkzUwIChuZXcgcHJvcG9zYWwpIiwicHJvdmVuYW5jZSI6InN1cHBsZW1lbnRhbCIsInByZXJlcXVpc2l0ZXMiOiJBcmNoaXRlY3QgY2Fwc3RvbmVzIiwiZXN0SG91cnMiOjI4fSx7InBsYW5JZCI6ImNocm9uaXMtYWktZW5naW5lZXJpbmctMjAyNi0xMS0wNSIsImlkIjoiUDQ5IiwidGl0bGUiOiJDb250cmFjdCBDbGF1c2UgSW50ZWxsaWdlbmNlIEFzc2lzdGFudCIsImxldmVsIjoiQ29tcGxleCIsInBoYXNlIjoiMDcgwrcgQXJjaGl0ZWN0IENhcHN0b25lcyIsInN0YXJ0RGF5Ijo4NSwiZmlyc3RTcHJpbnQiOiIyMDI3LTAxLTI4Iiwic3RhY2siOiJGYXN0QVBJLCBPQ1IsIFJBRyIsIm12cCI6IkV4dHJhY3QgYW5kIGNvbXBhcmUgY29udHJhY3QgY2xhdXNlcyB3aXRoIGV2aWRlbmNlIGxpbmtzIiwiZmVhdHVyZXMiOiJFeHRyYWN0IGFuZCBjb21wYXJlIGNvbnRyYWN0IGNsYXVzZXMgd2l0aCBldmlkZW5jZSBsaW5rczsgR3JvdW5kZWQgcmVkLWZsYWcgY2xhc3NpZmljYXRpb24gb24gc2FtcGxlIGNsYXVzZXMiLCJhY2NlcHRhbmNlIjoiR3JvdW5kZWQgcmVkLWZsYWcgY2xhc3NpZmljYXRpb24gb24gc2FtcGxlIGNsYXVzZXMiLCJpbnRlcnZpZXdUb3BpYyI6IkFyY2hpdGVjdHVyZSBhbmQgcmVsaWFiaWxpdHkgb2YgY29udHJhY3QgY2xhdXNlIGludGVsbGlnZW5jZSBhc3Npc3RhbnQiLCJwcmlvcml0eSI6IlByb3RvdHlwZSIsInNvdXJjZSI6IkFkZGl0aW9uYWwgMzHigJM1MCAobmV3IHByb3Bvc2FsKSIsInByb3ZlbmFuY2UiOiJzdXBwbGVtZW50YWwiLCJwcmVyZXF1aXNpdGVzIjoiQXJjaGl0ZWN0IGNhcHN0b25lcyIsImVzdEhvdXJzIjoyOH0seyJwbGFuSWQiOiJjaHJvbmlzLWFpLWVuZ2luZWVyaW5nLTIwMjYtMTEtMDUiLCJpZCI6IlA1MCIsInRpdGxlIjoiQUkgR292ZXJuYW5jZSAmIFBvbGljeSBDb250cm9sIENlbnRlciIsImxldmVsIjoiQ29tcGxleCIsInBoYXNlIjoiMDcgwrcgQXJjaGl0ZWN0IENhcHN0b25lcyIsInN0YXJ0RGF5Ijo4OSwiZmlyc3RTcHJpbnQiOiIyMDI3LTAyLTAxIiwic3RhY2siOiJGYXN0QVBJLCBQb3N0Z3JlU1FMLCBMYW5nR3JhcGgiLCJtdnAiOiJDb25maWd1cmUgcG9saWN5IHJ1bGVzLCBhcHByb3ZhbCBnYXRlcyBhbmQgYXVkaXQgaGlzdG9yeSIsImZlYXR1cmVzIjoiQ29uZmlndXJlIHBvbGljeSBydWxlcywgYXBwcm92YWwgZ2F0ZXMgYW5kIGF1ZGl0IGhpc3Rvcnk7IERlbmllZCB1bnNhZmUgdG9vbCBhY3Rpb24gc3RheXMgZGVuaWVkIGFuZCBhdWRpdGFibGUiLCJhY2NlcHRhbmNlIjoiRGVuaWVkIHVuc2FmZSB0b29sIGFjdGlvbiBzdGF5cyBkZW5pZWQgYW5kIGF1ZGl0YWJsZSIsImludGVydmlld1RvcGljIjoiQXJjaGl0ZWN0dXJlIGFuZCByZWxpYWJpbGl0eSBvZiBhaSBnb3Zlcm5hbmNlICYgcG9saWN5IGNvbnRyb2wgY2VudGVyIiwicHJpb3JpdHkiOiJQb3J0Zm9saW8iLCJzb3VyY2UiOiJBZGRpdGlvbmFsIDMx4oCTNTAgKG5ldyBwcm9wb3NhbCkiLCJwcm92ZW5hbmNlIjoic3VwcGxlbWVudGFsIiwicHJlcmVxdWlzaXRlcyI6IkFyY2hpdGVjdCBjYXBzdG9uZXMiLCJlc3RIb3VycyI6Mjh9XSwic3R1ZHlCbG9ja3MiOlt7ImtleSI6InRoZW9yeSIsImtpbmQiOiJzdHVkeSIsImJsb2NrIjoidGhlb3J5IiwibGFiZWwiOiJEZWVwIGNvbmNlcHRzICYgdGhlb3J5Iiwic3RhcnQiOiIwOToxMCIsImVuZCI6IjEwOjIwIiwibWludXRlcyI6NzB9LHsia2V5IjoiYmFzaWMiLCJraW5kIjoic3R1ZHkiLCJibG9jayI6ImJhc2ljIiwibGFiZWwiOiJCYXNpYyBjb2RpbmcgJiB1bml0IHRlc3RzIiwic3RhcnQiOiIxMDozNSIsImVuZCI6IjExOjM1IiwibWludXRlcyI6NjB9LHsia2V5Ijoic2NlbmFyaW8iLCJraW5kIjoic3R1ZHkiLCJibG9jayI6InNjZW5hcmlvIiwibGFiZWwiOiJTY2VuYXJpby1iYXNlZCBjb2RpbmciLCJzdGFydCI6IjEyOjIwIiwiZW5kIjoiMTM6MjAiLCJtaW51dGVzIjo2MH0seyJrZXkiOiJwcm9qZWN0Iiwia2luZCI6InN0dWR5IiwiYmxvY2siOiJwcm9qZWN0IiwibGFiZWwiOiJSZWFsLXdvcmxkIHByb2plY3Qgc3ByaW50Iiwic3RhcnQiOiIxMzozNSIsImVuZCI6IjE1OjM1IiwibWludXRlcyI6MTIwfSx7ImtleSI6ImludGVydmlldyIsImtpbmQiOiJzdHVkeSIsImJsb2NrIjoiaW50ZXJ2aWV3IiwibGFiZWwiOiJJbnRlcnZpZXcgJiBzeXN0ZW0gZGVzaWduIiwic3RhcnQiOiIxNTo1MCIsImVuZCI6IjE2OjMwIiwibWludXRlcyI6NDB9LHsia2V5IjoicmV2aWV3Iiwia2luZCI6InN0dWR5IiwiYmxvY2siOiJyZXZpZXciLCJsYWJlbCI6IlJldmlldyAmIGV2aWRlbmNlIHBhY2thZ2luZyIsInN0YXJ0IjoiMTY6MzAiLCJlbmQiOiIxNjo0MCIsIm1pbnV0ZXMiOjEwfV0sInRpbWVsaW5lIjpbeyJrZXkiOiJsb2dpbiIsImtpbmQiOiJhZG1pbiIsImxhYmVsIjoiTG9naW4gKyBwbGFuIiwic3RhcnQiOiIwOTowMCIsImVuZCI6IjA5OjEwIiwibWludXRlcyI6MTB9LHsia2V5IjoidGhlb3J5Iiwia2luZCI6InN0dWR5IiwiYmxvY2siOiJ0aGVvcnkiLCJsYWJlbCI6IkRlZXAgY29uY2VwdHMgJiB0aGVvcnkiLCJzdGFydCI6IjA5OjEwIiwiZW5kIjoiMTA6MjAiLCJtaW51dGVzIjo3MH0seyJrZXkiOiJicmVhazEiLCJraW5kIjoiYnJlYWsiLCJsYWJlbCI6IkJyZWFrIiwic3RhcnQiOiIxMDoyMCIsImVuZCI6IjEwOjM1IiwibWludXRlcyI6MTV9LHsia2V5IjoiYmFzaWMiLCJraW5kIjoic3R1ZHkiLCJibG9jayI6ImJhc2ljIiwibGFiZWwiOiJCYXNpYyBjb2RpbmcgJiB1bml0IHRlc3RzIiwic3RhcnQiOiIxMDozNSIsImVuZCI6IjExOjM1IiwibWludXRlcyI6NjB9LHsia2V5IjoibHVuY2giLCJraW5kIjoiYnJlYWsiLCJsYWJlbCI6Ikx1bmNoIGJyZWFrIiwic3RhcnQiOiIxMTozNSIsImVuZCI6IjEyOjIwIiwibWludXRlcyI6NDV9LHsia2V5Ijoic2NlbmFyaW8iLCJraW5kIjoic3R1ZHkiLCJibG9jayI6InNjZW5hcmlvIiwibGFiZWwiOiJTY2VuYXJpby1iYXNlZCBjb2RpbmciLCJzdGFydCI6IjEyOjIwIiwiZW5kIjoiMTM6MjAiLCJtaW51dGVzIjo2MH0seyJrZXkiOiJicmVhazIiLCJraW5kIjoiYnJlYWsiLCJsYWJlbCI6IkJyZWFrIiwic3RhcnQiOiIxMzoyMCIsImVuZCI6IjEzOjM1IiwibWludXRlcyI6MTV9LHsia2V5IjoicHJvamVjdCIsImtpbmQiOiJzdHVkeSIsImJsb2NrIjoicHJvamVjdCIsImxhYmVsIjoiUmVhbC13b3JsZCBwcm9qZWN0IHNwcmludCIsInN0YXJ0IjoiMTM6MzUiLCJlbmQiOiIxNTozNSIsIm1pbnV0ZXMiOjEyMH0seyJrZXkiOiJicmVhazMiLCJraW5kIjoiYnJlYWsiLCJsYWJlbCI6IkJyZWFrIiwic3RhcnQiOiIxNTozNSIsImVuZCI6IjE1OjUwIiwibWludXRlcyI6MTV9LHsia2V5IjoiaW50ZXJ2aWV3Iiwia2luZCI6InN0dWR5IiwiYmxvY2siOiJpbnRlcnZpZXciLCJsYWJlbCI6IkludGVydmlldyAmIHN5c3RlbSBkZXNpZ24iLCJzdGFydCI6IjE1OjUwIiwiZW5kIjoiMTY6MzAiLCJtaW51dGVzIjo0MH0seyJrZXkiOiJyZXZpZXciLCJraW5kIjoic3R1ZHkiLCJibG9jayI6InJldmlldyIsImxhYmVsIjoiUmV2aWV3ICYgZXZpZGVuY2UgcGFja2FnaW5nIiwic3RhcnQiOiIxNjozMCIsImVuZCI6IjE2OjQwIiwibWludXRlcyI6MTB9LHsia2V5IjoicmVwb3J0Iiwia2luZCI6ImFkbWluIiwibGFiZWwiOiJNYW5kYXRvcnkgZGFpbHkgcmVwb3J0Iiwic3RhcnQiOiIxNjo0MCIsImVuZCI6IjE2OjU1IiwibWludXRlcyI6MTV9LHsia2V5IjoibG9nb3V0Iiwia2luZCI6ImFkbWluIiwibGFiZWwiOiJMb2dvdXQgY2hlY2siLCJzdGFydCI6IjE2OjU1IiwiZW5kIjoiMTc6MDAiLCJtaW51dGVzIjo1fV0sInJlbWluZGVycyI6W3sibiI6MSwiYXQiOiIwODo1MCIsInR5cGUiOiJQUkUtTE9HSU4gUFJFUCIsIm1lc3NhZ2UiOiI5OjAwIGNoZWNrLWluIGR1ZSBpbiAxMCBtaW51dGVzIiwicmVzcG9uc2UiOiJDaGVjayBkZXNrLCBsYXB0b3AsIGVudmlyb25tZW50IGFuZCBnb2FscyJ9LHsibiI6MiwiYXQiOiIwOTowMCIsInR5cGUiOiJMT0dJTiBOT1ciLCJtZXNzYWdlIjoiTG9nIGludG8gc3R1ZHkgZGFzaGJvYXJkOyBtYXJrIGF0dGVuZGFuY2UiLCJyZXNwb25zZSI6IlJlY29yZCBsb2dpbiwgc2VsZWN0IERhaWx5IFJvYWRtYXAgRGF5ICMifSx7Im4iOjMsImF0IjoiMTI6MjAiLCJ0eXBlIjoiU0NFTkFSSU8gQ09ESU5HIFNUQVJUIiwibWVzc2FnZSI6Ikx1bmNoIGZpbmlzaGVkOyBzdGFydCBzY2VuYXJpbyBsYWIiLCJyZXNwb25zZSI6IlJlY29yZCBzY2VuYXJpbyBhbmQgY29tcGxleGl0eSJ9LHsibiI6NCwiYXQiOiIxNjo0MCIsInR5cGUiOiJSRVBPUlQgTk9XIiwibWVzc2FnZSI6IkZpbGwgNS1kb21haW4gcHJvZ3Jlc3MgcmVwb3J0IGltbWVkaWF0ZWx5IiwicmVzcG9uc2UiOiJDb3ZlciB0aGVvcnksIGJhc2ljLCBzY2VuYXJpbywgcHJvamVjdCwgaW50ZXJ2aWV3In0seyJuIjo1LCJhdCI6IjE2OjU1IiwidHlwZSI6IkxPR09VVCBDSEVDSyIsIm1lc3NhZ2UiOiJGaW5pc2ggbG9nb3V0IG9ubHkgYWZ0ZXIgc3VibWl0dGVkIHJlcG9ydCIsInJlc3BvbnNlIjoiUmVjb3JkIGxvZ291dCBvciBlbWVyZ2VuY3kgb3ZlcnJpZGUgKyByZWFzb24ifV0sInNvdXJjZVNoYTI1NiI6IjBkNTM1ZDdlNWNmOWU3ZmE0ZTA2NjBkNGY0NmFlYmYzOWQwMzk1Zjk2MzNkMzY3NDc5MDliMDc3OTY4MDMwMjYifQ==','base64'),'UTF8')::jsonb);
END $chronis_bootstrap$@@CHRONIS_END@@
