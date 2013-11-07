--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: api_keys; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE api_keys (
    id integer NOT NULL,
    token character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id integer
);


--
-- Name: api_keys_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE api_keys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: api_keys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE api_keys_id_seq OWNED BY api_keys.id;


--
-- Name: integrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE integrations (
    id integer NOT NULL,
    type character varying(255),
    api_key character varying(255),
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    source_id character varying(255) NOT NULL,
    last_projects_refresh_at timestamp without time zone
);


--
-- Name: integrations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE integrations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: integrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE integrations_id_seq OWNED BY integrations.id;


--
-- Name: participations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE participations (
    id integer NOT NULL,
    integration_id integer NOT NULL,
    project_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    active boolean DEFAULT true
);


--
-- Name: participations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE participations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: participations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE participations_id_seq OWNED BY participations.id;


--
-- Name: projects; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE projects (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    source_name character varying(255) NOT NULL,
    source_identifier character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    web_hook character varying(255),
    web_hook_token character varying(255)
);


--
-- Name: projects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE projects_id_seq OWNED BY projects.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: tasks; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE tasks (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    project_id integer NOT NULL,
    name text NOT NULL,
    source_name character varying(255) NOT NULL,
    source_identifier character varying(255) NOT NULL,
    current_state character varying(255) NOT NULL,
    story_type character varying(255) NOT NULL,
    current_task boolean DEFAULT false,
    tsvector_name_tsearch tsvector
);


--
-- Name: tasks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tasks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tasks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tasks_id_seq OWNED BY tasks.id;


--
-- Name: time_log_entries; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE time_log_entries (
    id integer NOT NULL,
    task_id integer,
    user_id integer NOT NULL,
    running boolean DEFAULT false,
    started_at timestamp without time zone NOT NULL,
    stopped_at timestamp without time zone,
    seconds integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: time_log_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE time_log_entries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: time_log_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE time_log_entries_id_seq OWNED BY time_log_entries.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    email character varying(255),
    password_digest character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    confirmation_token character varying(255),
    password_reset_token character varying(255),
    password_reset_sent_at timestamp without time zone,
    auth_token character varying(255),
    oauth_token character varying(255),
    oauth_token_expires_at timestamp without time zone,
    refreshing character varying(255)
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY api_keys ALTER COLUMN id SET DEFAULT nextval('api_keys_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY integrations ALTER COLUMN id SET DEFAULT nextval('integrations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY participations ALTER COLUMN id SET DEFAULT nextval('participations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY projects ALTER COLUMN id SET DEFAULT nextval('projects_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tasks ALTER COLUMN id SET DEFAULT nextval('tasks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY time_log_entries ALTER COLUMN id SET DEFAULT nextval('time_log_entries_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: api_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY api_keys
    ADD CONSTRAINT api_keys_pkey PRIMARY KEY (id);


--
-- Name: integrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY integrations
    ADD CONSTRAINT integrations_pkey PRIMARY KEY (id);


--
-- Name: participations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY participations
    ADD CONSTRAINT participations_pkey PRIMARY KEY (id);


--
-- Name: projects_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tasks
    ADD CONSTRAINT tasks_pkey PRIMARY KEY (id);


--
-- Name: time_log_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY time_log_entries
    ADD CONSTRAINT time_log_entries_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_identities_on_api_key_and_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_identities_on_api_key_and_type ON integrations USING btree (api_key, type);


--
-- Name: index_projects_on_source_name_and_source_identifier; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_projects_on_source_name_and_source_identifier ON projects USING btree (source_name, source_identifier);


--
-- Name: index_tasks_on_source_name_and_source_identifier; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_tasks_on_source_name_and_source_identifier ON tasks USING btree (source_name, source_identifier);


--
-- Name: index_users_on_confirmation_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_confirmation_token ON users USING btree (confirmation_token);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20130408132756');

INSERT INTO schema_migrations (version) VALUES ('20130408133857');

INSERT INTO schema_migrations (version) VALUES ('20130408204920');

INSERT INTO schema_migrations (version) VALUES ('20130409075333');

INSERT INTO schema_migrations (version) VALUES ('20130410083747');

INSERT INTO schema_migrations (version) VALUES ('20130410084528');

INSERT INTO schema_migrations (version) VALUES ('20130410113826');

INSERT INTO schema_migrations (version) VALUES ('20130410235152');

INSERT INTO schema_migrations (version) VALUES ('20130411091647');

INSERT INTO schema_migrations (version) VALUES ('20130412132228');

INSERT INTO schema_migrations (version) VALUES ('20130412142331');

INSERT INTO schema_migrations (version) VALUES ('20130414195224');

INSERT INTO schema_migrations (version) VALUES ('20130414210008');

INSERT INTO schema_migrations (version) VALUES ('20130415103722');

INSERT INTO schema_migrations (version) VALUES ('20130415120043');

INSERT INTO schema_migrations (version) VALUES ('20130415131438');

INSERT INTO schema_migrations (version) VALUES ('20130416074311');

INSERT INTO schema_migrations (version) VALUES ('20130419082018');

INSERT INTO schema_migrations (version) VALUES ('20130419112628');

INSERT INTO schema_migrations (version) VALUES ('20130419123045');

INSERT INTO schema_migrations (version) VALUES ('20130608081959');

INSERT INTO schema_migrations (version) VALUES ('20130617090002');

INSERT INTO schema_migrations (version) VALUES ('20130709073303');

INSERT INTO schema_migrations (version) VALUES ('20130712114133');

INSERT INTO schema_migrations (version) VALUES ('20130719093946');

INSERT INTO schema_migrations (version) VALUES ('20130730084054');

INSERT INTO schema_migrations (version) VALUES ('20130802144623');

INSERT INTO schema_migrations (version) VALUES ('20130814120853');

INSERT INTO schema_migrations (version) VALUES ('20130830072235');

INSERT INTO schema_migrations (version) VALUES ('20131015120301');

INSERT INTO schema_migrations (version) VALUES ('20131024101203');

INSERT INTO schema_migrations (version) VALUES ('20131024140123');

INSERT INTO schema_migrations (version) VALUES ('20131025133404');

INSERT INTO schema_migrations (version) VALUES ('20131030081559');

INSERT INTO schema_migrations (version) VALUES ('20131107102649');