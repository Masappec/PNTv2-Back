--
-- PostgreSQL database dump
--

-- Dumped from database version 16.2 (Debian 16.2-1.pgdg120+2)
-- Dumped by pg_dump version 16.2 (Debian 16.2-1.pgdg120+2)

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
-- Name: asked_question; Type: TYPE; Schema: public; Owner: auth_user
--

CREATE TYPE public.asked_question AS (
	question character varying(255),
	answer text
);


ALTER TYPE public.asked_question OWNER TO auth_user;

--
-- Name: normative; Type: TYPE; Schema: public; Owner: auth_user
--

CREATE TYPE public.normative AS (
	title character varying(255),
	description text,
	url character varying(255),
	is_active boolean
);


ALTER TYPE public.normative OWNER TO auth_user;

--
-- Name: tutorial; Type: TYPE; Schema: public; Owner: auth_user
--

CREATE TYPE public.tutorial AS (
	title character varying(255),
	description text,
	url character varying(255),
	is_active boolean
);


ALTER TYPE public.tutorial OWNER TO auth_user;

--
-- Name: admin_register_pedagogy_area(public.asked_question[], public.tutorial[], public.normative[], integer); Type: FUNCTION; Schema: public; Owner: auth_user
--

CREATE FUNCTION public.admin_register_pedagogy_area(preguntas public.asked_question[], tutoriales public.tutorial[], normativas public.normative[], user_insert integer) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
DECLARE
    pedagogy_area_id_ INTEGER = 0;
    result JSONB;
BEGIN
    -- Consultar si existe un área de pedagogía
    SELECT id INTO pedagogy_area_id_
    FROM public.app_admin_pedagogyarea
    WHERE deleted = false
    LIMIT 1;

    -- Si no existe un área de pedagogía, crearla
    
    IF pedagogy_area_id_ IS NULL THEN
        INSERT INTO public.app_admin_pedagogyarea (
            created_at, updated_at, deleted, deleted_at, published, user_created_id, user_deleted_id, user_updated_id)
        VALUES (current_timestamp, current_timestamp, false, null, true, user_insert, null, user_insert)
        RETURNING id INTO pedagogy_area_id_;
    END IF;

    -- Insertar las preguntas frecuentes
    DELETE FROM public.app_admin_frequentlyaskedquestions as faq
    WHERE faq.pedagogy_area_id = pedagogy_area_id_;
    FOR i IN 1..array_length(preguntas, 1) LOOP
        INSERT INTO public.app_admin_frequentlyaskedquestions (
            created_at, updated_at, deleted, deleted_at, question, answer, is_active, pedagogy_area_id, user_created_id, user_deleted_id, user_updated_id)
        VALUES (
            current_timestamp, current_timestamp, false, null,
            preguntas[i].question, preguntas[i].answer, true, pedagogy_area_id_, user_insert, null, user_insert
        );
    END LOOP;

    -- Insertar los tutoriales
    DELETE FROM public.app_admin_tutorialvideo as tv
    WHERE tv.pedagogy_area_id = pedagogy_area_id_;
    FOR i IN 1..array_length(tutoriales, 1) LOOP
        -- Agregar lógica para insertar los tutoriales según sea necesario
		INSERT INTO public.app_admin_tutorialvideo(
			created_at, updated_at, deleted, deleted_at, title, url, description, pedagogy_area_id, user_created_id,
             user_deleted_id, user_updated_id, is_active
		)
		VALUES (
            current_timestamp, current_timestamp, false, null,
            tutoriales[i].title, tutoriales[i].url, tutoriales[i].description, pedagogy_area_id_, user_insert, null, user_insert, 
            true
			
		);
    END LOOP;

    -- Insertar las normativas
    DELETE FROM public.app_admin_normativedocument as nv
    WHERE nv.pedagogy_area_id = pedagogy_area_id_;
    FOR i IN 1..array_length(normativas, 1) LOOP
        -- Agregar lógica para insertar las normativas según sea necesario
		INSERT INTO public.app_admin_normativedocument(
			created_at, updated_at, deleted, deleted_at, title, url, description, pedagogy_area_id, user_created_id, user_deleted_id, user_updated_id,
            is_active 
		)
		VALUES (
            current_timestamp, current_timestamp, false, null,
            normativas[i].title, normativas[i].url, normativas[i].description, pedagogy_area_id_, user_insert, null, user_insert, true
        );
		
    END LOOP;
	
	
    -- Devolver el resultado JSONB

    -- Devolver el resultado JSONB
    RETURN jsonb_build_object(
    'pedagogy', (pa.*),
    'faq', (
        SELECT jsonb_agg(DISTINCT faq.*)
        FROM public.app_admin_frequentlyaskedquestions faq
        WHERE faq.pedagogy_area_id = pa.id
    ),
    'normative', (
        SELECT jsonb_agg(DISTINCT nov.*)
        FROM public.app_admin_normativedocument nov
        WHERE nov.pedagogy_area_id = pa.id
    ),
    'tutorial', (
        SELECT jsonb_agg(DISTINCT tv.*)
        FROM public.app_admin_tutorialvideo tv
        WHERE tv.pedagogy_area_id = pa.id
    )
)
FROM public.app_admin_pedagogyarea pa
WHERE pa.deleted = false
GROUP BY pa.id;

END;
$$;


ALTER FUNCTION public.admin_register_pedagogy_area(preguntas public.asked_question[], tutoriales public.tutorial[], normativas public.normative[], user_insert integer) OWNER TO auth_user;

--
-- Name: admin_select_pedagogy_area(); Type: FUNCTION; Schema: public; Owner: auth_user
--

CREATE FUNCTION public.admin_select_pedagogy_area() RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
DECLARE
    result JSONB;
BEGIN
    -- Consultar si existe un área de pedagogía
  

    -- Devolver el resultado JSONB

    -- Devolver el resultado JSONB
    RETURN jsonb_build_object(
    'pedagogy', (pa.*),
    'faq', (
        SELECT jsonb_agg(DISTINCT faq.*)
        FROM public.app_admin_frequentlyaskedquestions faq
        WHERE faq.pedagogy_area_id = pa.id
    ),
    'normative', (
        SELECT jsonb_agg(DISTINCT nov.*)
        FROM public.app_admin_normativedocument nov
        WHERE nov.pedagogy_area_id = pa.id
    ),
    'tutorial', (
        SELECT jsonb_agg(DISTINCT tv.*)
        FROM public.app_admin_tutorialvideo tv
        WHERE tv.pedagogy_area_id = pa.id
    )
)
FROM public.app_admin_pedagogyarea pa
WHERE pa.deleted = false
GROUP BY pa.id;
END;
$$;


ALTER FUNCTION public.admin_select_pedagogy_area() OWNER TO auth_user;

--
-- Name: admin_update_pedagogy_area(public.asked_question[], public.tutorial[], public.normative[], integer, integer); Type: FUNCTION; Schema: public; Owner: auth_user
--

CREATE FUNCTION public.admin_update_pedagogy_area(preguntas public.asked_question[], tutoriales public.tutorial[], normativas public.normative[], user_update integer, area_pedagogy_id integer) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
DECLARE
    result JSONB;
    pedagogy_area_id INTEGER;
BEGIN
    -- Consultar si existe un área de pedagogía
    SELECT id INTO pedagogy_area_id
    FROM public.app_admin_pedagogyarea
    WHERE deleted = false AND id = area_pedagogy_id
    LIMIT 1;

    -- Si no existe un área de pedagogía, crearla
    IF pedagogy_area_id IS NULL THEN
        
        --MENSAJE DE ERROR
        RAISE EXCEPTION 'No existe un área de pedagogía con el id %', area_pedagogy_id;
    END IF;



    DELETE FROM public.app_admin_frequentlyaskedquestions
    WHERE pedagogy_area_id = pedagogy_area_id;
    -- Insertar las preguntas frecuentes
    FOR i IN 1..array_length(preguntas, 1) LOOP
        INSERT INTO public.app_admin_frequentlyaskedquestions (
            created_at, updated_at, deleted, deleted_at, question, answer, is_active, pedagogy_area_id, user_created_id, user_deleted_id, user_updated_id)
        VALUES (
            current_timestamp, current_timestamp, false, null,
            preguntas[i].question, preguntas[i].answer, true, pedagogy_area_id, user_insert, null, user_insert
        );
    END LOOP;


    DELETE FROM public.app_admin_tutorialvideo
    WHERE pedagogy_area_id = pedagogy_area_id;
    -- Insertar los tutoriales
    FOR i IN 1..array_length(tutoriales, 1) LOOP
        -- Agregar lógica para insertar los tutoriales según sea necesario
		INSERT INTO public.app_admin_tutorialvideo(
			created_at, updated_at, deleted, deleted_at, title, url, description, pedagogy_area_id, user_created_id, user_deleted_id, user_updated_id
		)
		VALUES (
            current_timestamp, current_timestamp, false, null,
            tutoriales[i].title, tutoriales[i].url, tutoriales[i].description, pedagogy_area_id, user_insert, null, user_insert
			
		);
    END LOOP;


    DELETE FROM public.app_admin_normativedocument
    WHERE pedagogy_area_id = pedagogy_area_id;

    -- Insertar las normativas
    FOR i IN 1..array_length(normativas, 1) LOOP
        -- Agregar lógica para insertar las normativas según sea necesario
		INSERT INTO public.app_admin_normativedocument(
			created_at, updated_at, deleted, deleted_at, title, url, description, pedagogy_area_id, user_created_id, user_deleted_id, user_updated_id 
		)
		VALUES (
            current_timestamp, current_timestamp, false, null,
            normativas[i].title, normativas[i].url, normativas[i].description, pedagogy_area_id, user_insert, null, user_insert
        );
		
    END LOOP;

    -- Devolver el resultado JSONB
    RETURN jsonb_build_object(
			'pedagogy', (pa.*),
			'faq', jsonb_agg(faq.*),
			'normative', jsonb_agg(nov.*),
			'tutorial', jsonb_agg(tv.*)
	)
	FROM public.app_admin_pedagogyarea pa
	JOIN public.app_admin_frequentlyaskedquestions faq ON pa.id = faq.pedagogy_area_id
	LEFT JOIN public.app_admin_normativedocument nov ON pa.id = nov.pedagogy_area_id
	LEFT JOIN public.app_admin_tutorialvideo tv ON pa.id = tv.pedagogy_area_id
	WHERE pa.deleted = false GROUP BY pa.id;
END;
$$;


ALTER FUNCTION public.admin_update_pedagogy_area(preguntas public.asked_question[], tutoriales public.tutorial[], normativas public.normative[], user_update integer, area_pedagogy_id integer) OWNER TO auth_user;

--
-- Name: auth_register_citizen_user(character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, boolean, character varying, character varying, character varying, boolean); Type: FUNCTION; Schema: public; Owner: auth_user
--

CREATE FUNCTION public.auth_register_citizen_user(p_username character varying, p_email character varying, p_password character varying, p_first_name character varying, p_last_name character varying, p_identification character varying, p_phone character varying, p_city character varying, p_race character varying, p_disability boolean, p_age_range character varying, p_province character varying, p_gender character varying, p_accept_terms boolean) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
DECLARE  
    role_id INT;
    v_user_id INT;
    user_data JSONB;
    v_fecha_actual DATE;
BEGIN
 	v_fecha_actual := CURRENT_DATE;
    -- Validar términos y condiciones
    IF NOT p_accept_terms THEN
        RAISE EXCEPTION 'Debe aceptar los términos y condiciones';
    END IF;

    -- Obtener el ID del rol 'Ciudadano'
    SELECT id INTO role_id FROM auth_group WHERE name = 'Ciudadano';

    -- Intentar crear un usuario
    BEGIN
        INSERT INTO auth_user(username, email, 
							  password, first_name, last_name, is_superuser,
							  is_staff,is_active,date_joined,created_at,updated_at,deleted)
        VALUES(p_username, p_email, p_password,
			   p_first_name, p_last_name, false,false,
			   false,v_fecha_actual,v_fecha_actual,v_fecha_actual,false)
        RETURNING id INTO v_user_id;
    EXCEPTION WHEN unique_violation THEN
        -- Capturar excepción si hay una violación de unicidad (correo o nombre de usuario duplicado)
        RAISE EXCEPTION 'Ya existe un usuario con ese correo o nombre de usuario';
    END;

    -- Asignar el usuario al grupo 'Ciudadano'
    BEGIN
        INSERT INTO auth_user_groups (user_id, group_id) VALUES (v_user_id, role_id);
    END;

    -- Intentar crear datos personales
    BEGIN
        INSERT INTO auth_person(
            first_name,
            last_name,
            identification,
            phone,
            city,
            race,
            disability,
            age_range,
            province,
            accept_terms,
			gender,
            user_id
        )
        VALUES (
            p_first_name,
            p_last_name,
            p_identification,
            p_phone,
            p_city,
            p_race,
            p_disability,
            p_age_range,
            p_province,
            p_accept_terms,
			p_gender,
            v_user_id
        );
    EXCEPTION WHEN unique_violation THEN
        -- Capturar excepción si hay una violación de unicidad (por ejemplo, identification duplicada)
        RAISE EXCEPTION 'Ya existe una persona con esa identificación';
    END;

    -- Obtener datos del usuario con grupos
    SELECT
        jsonb_build_object(
            'id', u.id,
            'first_name', u.first_name,
            'last_name', u.last_name,
            'username', u.username,
            'email', u.email,
            'identification', p.identification,
            'phone', p.phone,
            'city', p.city,
            'country', p.country,
            'province', p.province,
            'group', jsonb_agg(jsonb_build_object('id', g.id, 'name', g.name))
        )
    INTO
        user_data
    FROM
        auth_user u
    LEFT JOIN
        auth_user_groups ug ON u.id = ug.user_id
    LEFT JOIN
        auth_group g ON ug.group_id = g.id
    LEFT JOIN
        auth_person p ON u.id = p.user_id
    WHERE
        u.id = v_user_id
    GROUP BY
        u.id, p.id;

    RETURN user_data;
END $$;


ALTER FUNCTION public.auth_register_citizen_user(p_username character varying, p_email character varying, p_password character varying, p_first_name character varying, p_last_name character varying, p_identification character varying, p_phone character varying, p_city character varying, p_race character varying, p_disability boolean, p_age_range character varying, p_province character varying, p_gender character varying, p_accept_terms boolean) OWNER TO auth_user;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: activity_log; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.activity_log (
    id bigint NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted boolean,
    deleted_at timestamp with time zone,
    ip character varying(255),
    activity character varying(255) NOT NULL,
    description text NOT NULL,
    ip_address character varying(255) NOT NULL,
    user_agent character varying(255) NOT NULL,
    is_active boolean NOT NULL,
    user_id integer NOT NULL,
    user_created_id integer,
    user_deleted_id integer,
    user_updated_id integer
);


ALTER TABLE public.activity_log OWNER TO auth_user;

--
-- Name: activity_log_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.activity_log ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.activity_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: app_admin_accesstoinformation; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.app_admin_accesstoinformation (
    id bigint NOT NULL,
    email character varying(255) NOT NULL,
    created_at timestamp with time zone,
    deleted boolean,
    deleted_at timestamp with time zone,
    is_active boolean NOT NULL,
    updated_at timestamp with time zone,
    user_created_id integer,
    user_deleted_id integer,
    user_updated_id integer,
    ip character varying(255)
);


ALTER TABLE public.app_admin_accesstoinformation OWNER TO auth_user;

--
-- Name: app_admin_accesstoinformation_establishment; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.app_admin_accesstoinformation_establishment (
    id bigint NOT NULL,
    accesstoinformation_id bigint NOT NULL,
    establishment_id bigint NOT NULL
);


ALTER TABLE public.app_admin_accesstoinformation_establishment OWNER TO auth_user;

--
-- Name: app_admin_accesstoinformation_establishment_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.app_admin_accesstoinformation_establishment ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.app_admin_accesstoinformation_establishment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: app_admin_accesstoinformation_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.app_admin_accesstoinformation ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.app_admin_accesstoinformation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: app_admin_configuration; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.app_admin_configuration (
    id bigint NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted boolean,
    deleted_at timestamp with time zone,
    name character varying(255) NOT NULL,
    value character varying(255) NOT NULL,
    is_active boolean NOT NULL,
    type_config character varying(255),
    user_created_id integer,
    user_deleted_id integer,
    user_updated_id integer,
    ip character varying(255)
);


ALTER TABLE public.app_admin_configuration OWNER TO auth_user;

--
-- Name: app_admin_configuration_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.app_admin_configuration ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.app_admin_configuration_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: app_admin_email; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.app_admin_email (
    id bigint NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted boolean,
    deleted_at timestamp with time zone,
    from_email character varying(255) NOT NULL,
    to_email character varying(255) NOT NULL,
    subject character varying(255) NOT NULL,
    body text NOT NULL,
    status character varying(255),
    error text,
    bcc character varying(255),
    cc character varying(255),
    reply_to character varying(255),
    user_created_id integer,
    user_deleted_id integer,
    user_updated_id integer,
    ip character varying(255)
);


ALTER TABLE public.app_admin_email OWNER TO auth_user;

--
-- Name: app_admin_email_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.app_admin_email ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.app_admin_email_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: app_admin_establishment; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.app_admin_establishment (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    abbreviation character varying(255) NOT NULL,
    logo character varying(100) NOT NULL,
    highest_authority character varying(255) NOT NULL,
    first_name_authority character varying(255) NOT NULL,
    last_name_authority character varying(255) NOT NULL,
    job_authority character varying(255) NOT NULL,
    email_authority character varying(255) NOT NULL,
    created_at timestamp with time zone,
    deleted boolean,
    deleted_at timestamp with time zone,
    updated_at timestamp with time zone,
    code character varying(255),
    is_active boolean NOT NULL,
    user_created_id integer,
    user_deleted_id integer,
    user_updated_id integer,
    ip character varying(255),
    slug character varying(255),
    address character varying(255) NOT NULL,
    function_organization_id bigint,
    type_institution_id bigint,
    type_organization_id bigint,
    identification character varying(255),
    visits integer NOT NULL
);


ALTER TABLE public.app_admin_establishment OWNER TO auth_user;

--
-- Name: app_admin_establishment_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.app_admin_establishment ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.app_admin_establishment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: app_admin_formfields; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.app_admin_formfields (
    id bigint NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted boolean,
    deleted_at timestamp with time zone,
    name character varying(255) NOT NULL,
    description character varying(255) NOT NULL,
    form_type character varying(255) NOT NULL,
    model character varying(255),
    is_active boolean NOT NULL,
    role character varying(255),
    type_field character varying(255),
    "order" integer NOT NULL,
    options jsonb,
    permission_required character varying(255),
    content_type_id integer,
    object_id integer,
    user_created_id integer,
    user_deleted_id integer,
    user_updated_id integer,
    ip character varying(255),
    CONSTRAINT app_admin_formfields_object_id_check CHECK ((object_id >= 0))
);


ALTER TABLE public.app_admin_formfields OWNER TO auth_user;

--
-- Name: app_admin_formfields_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.app_admin_formfields ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.app_admin_formfields_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: app_admin_frequentlyaskedquestions; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.app_admin_frequentlyaskedquestions (
    id bigint NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted boolean,
    deleted_at timestamp with time zone,
    question text NOT NULL,
    answer text NOT NULL,
    is_active boolean NOT NULL,
    pedagogy_area_id bigint,
    user_created_id integer,
    user_deleted_id integer,
    user_updated_id integer,
    ip character varying(255)
);


ALTER TABLE public.app_admin_frequentlyaskedquestions OWNER TO auth_user;

--
-- Name: app_admin_frequentlyaskedquestions_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.app_admin_frequentlyaskedquestions ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.app_admin_frequentlyaskedquestions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: app_admin_functionorganization; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.app_admin_functionorganization (
    id bigint NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted boolean,
    deleted_at timestamp with time zone,
    ip character varying(255),
    name character varying(255) NOT NULL,
    is_active boolean NOT NULL,
    user_created_id integer,
    user_deleted_id integer,
    user_updated_id integer
);


ALTER TABLE public.app_admin_functionorganization OWNER TO auth_user;

--
-- Name: app_admin_functionorganization_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.app_admin_functionorganization ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.app_admin_functionorganization_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: app_admin_lawenforcement; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.app_admin_lawenforcement (
    id bigint NOT NULL,
    highest_committe character varying(255) NOT NULL,
    first_name_committe character varying(255) NOT NULL,
    last_name_committe character varying(255) NOT NULL,
    job_committe character varying(255) NOT NULL,
    email_committe character varying(255) NOT NULL,
    created_at timestamp with time zone,
    deleted boolean,
    deleted_at timestamp with time zone,
    is_active boolean NOT NULL,
    updated_at timestamp with time zone,
    user_created_id integer,
    user_deleted_id integer,
    user_updated_id integer,
    ip character varying(255)
);


ALTER TABLE public.app_admin_lawenforcement OWNER TO auth_user;

--
-- Name: app_admin_lawenforcement_establishment; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.app_admin_lawenforcement_establishment (
    id bigint NOT NULL,
    lawenforcement_id bigint NOT NULL,
    establishment_id bigint NOT NULL
);


ALTER TABLE public.app_admin_lawenforcement_establishment OWNER TO auth_user;

--
-- Name: app_admin_lawenforcement_establishment_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.app_admin_lawenforcement_establishment ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.app_admin_lawenforcement_establishment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: app_admin_lawenforcement_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.app_admin_lawenforcement ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.app_admin_lawenforcement_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: app_admin_normativedocument; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.app_admin_normativedocument (
    id bigint NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted boolean,
    deleted_at timestamp with time zone,
    title character varying(255) NOT NULL,
    description text NOT NULL,
    url character varying(255) NOT NULL,
    is_active boolean NOT NULL,
    pedagogy_area_id bigint,
    user_created_id integer,
    user_deleted_id integer,
    user_updated_id integer,
    ip character varying(255)
);


ALTER TABLE public.app_admin_normativedocument OWNER TO auth_user;

--
-- Name: app_admin_normativedocument_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.app_admin_normativedocument ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.app_admin_normativedocument_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: app_admin_pedagogyarea; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.app_admin_pedagogyarea (
    id bigint NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted boolean,
    deleted_at timestamp with time zone,
    published boolean NOT NULL,
    user_created_id integer,
    user_deleted_id integer,
    user_updated_id integer,
    ip character varying(255)
);


ALTER TABLE public.app_admin_pedagogyarea OWNER TO auth_user;

--
-- Name: app_admin_pedagogyarea_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.app_admin_pedagogyarea ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.app_admin_pedagogyarea_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: app_admin_tutorialvideo; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.app_admin_tutorialvideo (
    id bigint NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted boolean,
    deleted_at timestamp with time zone,
    title character varying(255) NOT NULL,
    description text NOT NULL,
    url character varying(255) NOT NULL,
    is_active boolean NOT NULL,
    pedagogy_area_id bigint,
    user_created_id integer,
    user_deleted_id integer,
    user_updated_id integer,
    ip character varying(255)
);


ALTER TABLE public.app_admin_tutorialvideo OWNER TO auth_user;

--
-- Name: app_admin_tutorialvideo_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.app_admin_tutorialvideo ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.app_admin_tutorialvideo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: app_admin_typeinstitution; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.app_admin_typeinstitution (
    id bigint NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted boolean,
    deleted_at timestamp with time zone,
    ip character varying(255),
    name character varying(255) NOT NULL,
    is_active boolean NOT NULL,
    user_created_id integer,
    user_deleted_id integer,
    user_updated_id integer
);


ALTER TABLE public.app_admin_typeinstitution OWNER TO auth_user;

--
-- Name: app_admin_typeinstitution_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.app_admin_typeinstitution ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.app_admin_typeinstitution_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: app_admin_typeorganization; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.app_admin_typeorganization (
    id bigint NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted boolean,
    deleted_at timestamp with time zone,
    ip character varying(255),
    name character varying(255) NOT NULL,
    is_active boolean NOT NULL,
    user_created_id integer,
    user_deleted_id integer,
    user_updated_id integer
);


ALTER TABLE public.app_admin_typeorganization OWNER TO auth_user;

--
-- Name: app_admin_typeorganization_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.app_admin_typeorganization ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.app_admin_typeorganization_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: app_admin_userestablishment; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.app_admin_userestablishment (
    id bigint NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted boolean,
    deleted_at timestamp with time zone,
    is_active boolean NOT NULL,
    establishment_id bigint,
    user_id integer,
    user_created_id integer,
    user_deleted_id integer,
    user_updated_id integer,
    ip character varying(255)
);


ALTER TABLE public.app_admin_userestablishment OWNER TO auth_user;

--
-- Name: app_admin_userestablishment_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.app_admin_userestablishment ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.app_admin_userestablishment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: auth_group; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.auth_group (
    id integer NOT NULL,
    name character varying(150) NOT NULL
);


ALTER TABLE public.auth_group OWNER TO auth_user;

--
-- Name: auth_group_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.auth_group ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.auth_group_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: auth_group_permissions; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.auth_group_permissions (
    id bigint NOT NULL,
    group_id integer NOT NULL,
    permission_id integer NOT NULL
);


ALTER TABLE public.auth_group_permissions OWNER TO auth_user;

--
-- Name: auth_group_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.auth_group_permissions ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.auth_group_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: auth_permission; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.auth_permission (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    content_type_id integer NOT NULL,
    codename character varying(100) NOT NULL
);


ALTER TABLE public.auth_permission OWNER TO auth_user;

--
-- Name: auth_permission_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.auth_permission ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.auth_permission_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: auth_person; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.auth_person (
    id integer NOT NULL,
    first_name character varying(255) NOT NULL,
    last_name character varying(255) NOT NULL,
    identification character varying(255) NOT NULL,
    phone character varying(255),
    address character varying(255),
    city character varying(255),
    country character varying(255),
    province character varying(255),
    user_id bigint,
    accept_terms boolean NOT NULL,
    disability boolean NOT NULL,
    gender character varying(255),
    job character varying(255),
    race character varying(255),
    age_range character varying(255)
);


ALTER TABLE public.auth_person OWNER TO auth_user;

--
-- Name: auth_person_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.auth_person ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.auth_person_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: auth_user; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.auth_user (
    id bigint NOT NULL,
    password character varying(128) NOT NULL,
    last_login timestamp with time zone,
    is_superuser boolean NOT NULL,
    username character varying(150) NOT NULL,
    first_name character varying(150) NOT NULL,
    last_name character varying(150) NOT NULL,
    email character varying(254) NOT NULL,
    is_staff boolean NOT NULL,
    is_active boolean NOT NULL,
    date_joined timestamp with time zone NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    deleted boolean NOT NULL,
    deleted_at timestamp with time zone,
    ip character varying(255)
);


ALTER TABLE public.auth_user OWNER TO auth_user;

--
-- Name: auth_user_groups; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.auth_user_groups (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    group_id integer NOT NULL
);


ALTER TABLE public.auth_user_groups OWNER TO auth_user;

--
-- Name: auth_user_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.auth_user_groups ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.auth_user_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: auth_user_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.auth_user ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.auth_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: auth_user_user_permissions; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.auth_user_user_permissions (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    permission_id integer NOT NULL
);


ALTER TABLE public.auth_user_user_permissions OWNER TO auth_user;

--
-- Name: auth_user_user_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.auth_user_user_permissions ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.auth_user_user_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: django_admin_log; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.django_admin_log (
    id integer NOT NULL,
    action_time timestamp with time zone NOT NULL,
    object_id text,
    object_repr character varying(200) NOT NULL,
    action_flag smallint NOT NULL,
    change_message text NOT NULL,
    content_type_id integer,
    user_id bigint NOT NULL,
    CONSTRAINT django_admin_log_action_flag_check CHECK ((action_flag >= 0))
);


ALTER TABLE public.django_admin_log OWNER TO auth_user;

--
-- Name: django_admin_log_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.django_admin_log ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.django_admin_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: django_celery_beat_clockedschedule; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.django_celery_beat_clockedschedule (
    id integer NOT NULL,
    clocked_time timestamp with time zone NOT NULL
);


ALTER TABLE public.django_celery_beat_clockedschedule OWNER TO auth_user;

--
-- Name: django_celery_beat_clockedschedule_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.django_celery_beat_clockedschedule ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.django_celery_beat_clockedschedule_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: django_celery_beat_crontabschedule; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.django_celery_beat_crontabschedule (
    id integer NOT NULL,
    minute character varying(240) NOT NULL,
    hour character varying(96) NOT NULL,
    day_of_week character varying(64) NOT NULL,
    day_of_month character varying(124) NOT NULL,
    month_of_year character varying(64) NOT NULL,
    timezone character varying(63) NOT NULL
);


ALTER TABLE public.django_celery_beat_crontabschedule OWNER TO auth_user;

--
-- Name: django_celery_beat_crontabschedule_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.django_celery_beat_crontabschedule ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.django_celery_beat_crontabschedule_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: django_celery_beat_intervalschedule; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.django_celery_beat_intervalschedule (
    id integer NOT NULL,
    every integer NOT NULL,
    period character varying(24) NOT NULL
);


ALTER TABLE public.django_celery_beat_intervalschedule OWNER TO auth_user;

--
-- Name: django_celery_beat_intervalschedule_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.django_celery_beat_intervalschedule ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.django_celery_beat_intervalschedule_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: django_celery_beat_periodictask; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.django_celery_beat_periodictask (
    id integer NOT NULL,
    name character varying(200) NOT NULL,
    task character varying(200) NOT NULL,
    args text NOT NULL,
    kwargs text NOT NULL,
    queue character varying(200),
    exchange character varying(200),
    routing_key character varying(200),
    expires timestamp with time zone,
    enabled boolean NOT NULL,
    last_run_at timestamp with time zone,
    total_run_count integer NOT NULL,
    date_changed timestamp with time zone NOT NULL,
    description text NOT NULL,
    crontab_id integer,
    interval_id integer,
    solar_id integer,
    one_off boolean NOT NULL,
    start_time timestamp with time zone,
    priority integer,
    headers text NOT NULL,
    clocked_id integer,
    expire_seconds integer,
    CONSTRAINT django_celery_beat_periodictask_expire_seconds_check CHECK ((expire_seconds >= 0)),
    CONSTRAINT django_celery_beat_periodictask_priority_check CHECK ((priority >= 0)),
    CONSTRAINT django_celery_beat_periodictask_total_run_count_check CHECK ((total_run_count >= 0))
);


ALTER TABLE public.django_celery_beat_periodictask OWNER TO auth_user;

--
-- Name: django_celery_beat_periodictask_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.django_celery_beat_periodictask ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.django_celery_beat_periodictask_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: django_celery_beat_periodictasks; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.django_celery_beat_periodictasks (
    ident smallint NOT NULL,
    last_update timestamp with time zone NOT NULL
);


ALTER TABLE public.django_celery_beat_periodictasks OWNER TO auth_user;

--
-- Name: django_celery_beat_solarschedule; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.django_celery_beat_solarschedule (
    id integer NOT NULL,
    event character varying(24) NOT NULL,
    latitude numeric(9,6) NOT NULL,
    longitude numeric(9,6) NOT NULL
);


ALTER TABLE public.django_celery_beat_solarschedule OWNER TO auth_user;

--
-- Name: django_celery_beat_solarschedule_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.django_celery_beat_solarschedule ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.django_celery_beat_solarschedule_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: django_content_type; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.django_content_type (
    id integer NOT NULL,
    app_label character varying(100) NOT NULL,
    model character varying(100) NOT NULL
);


ALTER TABLE public.django_content_type OWNER TO auth_user;

--
-- Name: django_content_type_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.django_content_type ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.django_content_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: django_migrations; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.django_migrations (
    id bigint NOT NULL,
    app character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    applied timestamp with time zone NOT NULL
);


ALTER TABLE public.django_migrations OWNER TO auth_user;

--
-- Name: django_migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.django_migrations ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.django_migrations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: django_rest_passwordreset_resetpasswordtoken; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.django_rest_passwordreset_resetpasswordtoken (
    created_at timestamp with time zone NOT NULL,
    key character varying(64) NOT NULL,
    ip_address inet,
    user_agent character varying(256) NOT NULL,
    user_id bigint NOT NULL,
    id integer NOT NULL
);


ALTER TABLE public.django_rest_passwordreset_resetpasswordtoken OWNER TO auth_user;

--
-- Name: django_rest_passwordreset_resetpasswordtoken_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.django_rest_passwordreset_resetpasswordtoken ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.django_rest_passwordreset_resetpasswordtoken_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: django_session; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.django_session (
    session_key character varying(40) NOT NULL,
    session_data text NOT NULL,
    expire_date timestamp with time zone NOT NULL
);


ALTER TABLE public.django_session OWNER TO auth_user;

--
-- Name: entity_app_attachment; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.entity_app_attachment (
    id bigint NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted boolean,
    deleted_at timestamp with time zone,
    ip character varying(255),
    name character varying(255),
    description text,
    url_download character varying(255),
    is_active boolean,
    user_created_id integer,
    user_deleted_id integer,
    user_updated_id integer
);


ALTER TABLE public.entity_app_attachment OWNER TO auth_user;

--
-- Name: entity_app_attachment_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.entity_app_attachment ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.entity_app_attachment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: entity_app_category; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.entity_app_category (
    id bigint NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted boolean,
    deleted_at timestamp with time zone,
    ip character varying(255),
    name character varying(255) NOT NULL,
    description text NOT NULL,
    is_active boolean NOT NULL,
    user_created_id integer,
    user_deleted_id integer,
    user_updated_id integer
);


ALTER TABLE public.entity_app_category OWNER TO auth_user;

--
-- Name: entity_app_category_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.entity_app_category ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.entity_app_category_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: entity_app_columnfile; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.entity_app_columnfile (
    id bigint NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted boolean,
    deleted_at timestamp with time zone,
    ip character varying(255),
    name character varying(255) NOT NULL,
    code character varying(255),
    user_created_id integer,
    user_deleted_id integer,
    user_updated_id integer,
    format character varying(255),
    regex character varying(255),
    type character varying(255) NOT NULL
);


ALTER TABLE public.entity_app_columnfile OWNER TO auth_user;

--
-- Name: entity_app_columnfile_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.entity_app_columnfile ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.entity_app_columnfile_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: entity_app_establishmentnumeral; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.entity_app_establishmentnumeral (
    id bigint NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted boolean,
    deleted_at timestamp with time zone,
    ip character varying(255),
    value text NOT NULL,
    establishment_id bigint NOT NULL,
    numeral_id bigint NOT NULL,
    user_created_id integer,
    user_deleted_id integer,
    user_updated_id integer
);


ALTER TABLE public.entity_app_establishmentnumeral OWNER TO auth_user;

--
-- Name: entity_app_establishmentnumeral_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.entity_app_establishmentnumeral ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.entity_app_establishmentnumeral_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: entity_app_extension; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.entity_app_extension (
    id bigint NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted boolean,
    deleted_at timestamp with time zone,
    ip character varying(255),
    is_active boolean NOT NULL,
    status character varying(50) NOT NULL,
    expiry_date timestamp with time zone,
    motive text NOT NULL,
    solicity_id bigint NOT NULL,
    user_id integer NOT NULL,
    user_created_id integer,
    user_deleted_id integer,
    user_updated_id integer
);


ALTER TABLE public.entity_app_extension OWNER TO auth_user;

--
-- Name: entity_app_extension_attachments; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.entity_app_extension_attachments (
    id bigint NOT NULL,
    extension_id bigint NOT NULL,
    attachment_id bigint NOT NULL
);


ALTER TABLE public.entity_app_extension_attachments OWNER TO auth_user;

--
-- Name: entity_app_extension_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.entity_app_extension_attachments ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.entity_app_extension_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: entity_app_extension_files; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.entity_app_extension_files (
    id bigint NOT NULL,
    extension_id bigint NOT NULL,
    filepublication_id bigint NOT NULL
);


ALTER TABLE public.entity_app_extension_files OWNER TO auth_user;

--
-- Name: entity_app_extension_files_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.entity_app_extension_files ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.entity_app_extension_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: entity_app_extension_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.entity_app_extension ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.entity_app_extension_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: entity_app_filepublication; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.entity_app_filepublication (
    id bigint NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted boolean,
    deleted_at timestamp with time zone,
    ip character varying(255),
    name character varying(255),
    description text,
    url_download character varying(100),
    is_active boolean,
    user_created_id integer,
    user_deleted_id integer,
    user_updated_id integer,
    file_join_id bigint,
    is_colab boolean
);


ALTER TABLE public.entity_app_filepublication OWNER TO auth_user;

--
-- Name: entity_app_filepublication_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.entity_app_filepublication ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.entity_app_filepublication_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: entity_app_insistency; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.entity_app_insistency (
    id bigint NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted boolean,
    deleted_at timestamp with time zone,
    ip character varying(255),
    is_active boolean NOT NULL,
    status character varying(50) NOT NULL,
    expiry_date timestamp with time zone,
    motive text NOT NULL,
    solicity_id bigint NOT NULL,
    user_id integer NOT NULL,
    user_created_id integer,
    user_deleted_id integer,
    user_updated_id integer
);


ALTER TABLE public.entity_app_insistency OWNER TO auth_user;

--
-- Name: entity_app_insistency_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.entity_app_insistency ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.entity_app_insistency_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: entity_app_numeral; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.entity_app_numeral (
    id bigint NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted boolean,
    deleted_at timestamp with time zone,
    ip character varying(255),
    name character varying(255) NOT NULL,
    description text NOT NULL,
    parent_id bigint,
    user_created_id integer,
    user_deleted_id integer,
    user_updated_id integer,
    is_default boolean NOT NULL,
    type_transparency character varying(255) NOT NULL
);


ALTER TABLE public.entity_app_numeral OWNER TO auth_user;

--
-- Name: entity_app_numeral_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.entity_app_numeral ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.entity_app_numeral_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: entity_app_numeral_templates; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.entity_app_numeral_templates (
    id bigint NOT NULL,
    numeral_id bigint NOT NULL,
    templatefile_id bigint NOT NULL
);


ALTER TABLE public.entity_app_numeral_templates OWNER TO auth_user;

--
-- Name: entity_app_numeral_templates_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.entity_app_numeral_templates ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.entity_app_numeral_templates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: entity_app_publication; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.entity_app_publication (
    id bigint NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted boolean,
    deleted_at timestamp with time zone,
    ip character varying(255),
    name character varying(255),
    description text,
    is_active boolean,
    establishment_id bigint,
    user_created_id integer,
    user_deleted_id integer,
    user_updated_id integer,
    type_publication_id bigint,
    slug character varying(255),
    notes text
);


ALTER TABLE public.entity_app_publication OWNER TO auth_user;

--
-- Name: entity_app_publication_attachment; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.entity_app_publication_attachment (
    id bigint NOT NULL,
    publication_id bigint NOT NULL,
    attachment_id bigint NOT NULL
);


ALTER TABLE public.entity_app_publication_attachment OWNER TO auth_user;

--
-- Name: entity_app_publication_attachment_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.entity_app_publication_attachment ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.entity_app_publication_attachment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: entity_app_publication_file_publication; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.entity_app_publication_file_publication (
    id bigint NOT NULL,
    publication_id bigint NOT NULL,
    filepublication_id bigint NOT NULL
);


ALTER TABLE public.entity_app_publication_file_publication OWNER TO auth_user;

--
-- Name: entity_app_publication_file_publication_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.entity_app_publication_file_publication ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.entity_app_publication_file_publication_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: entity_app_publication_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.entity_app_publication ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.entity_app_publication_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: entity_app_publication_tag; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.entity_app_publication_tag (
    id bigint NOT NULL,
    publication_id bigint NOT NULL,
    tag_id bigint NOT NULL
);


ALTER TABLE public.entity_app_publication_tag OWNER TO auth_user;

--
-- Name: entity_app_publication_tag_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.entity_app_publication_tag ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.entity_app_publication_tag_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: entity_app_publication_type_format; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.entity_app_publication_type_format (
    id bigint NOT NULL,
    publication_id bigint NOT NULL,
    typeformats_id bigint NOT NULL
);


ALTER TABLE public.entity_app_publication_type_format OWNER TO auth_user;

--
-- Name: entity_app_publication_type_format_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.entity_app_publication_type_format ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.entity_app_publication_type_format_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: entity_app_solicity; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.entity_app_solicity (
    id bigint NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted boolean,
    deleted_at timestamp with time zone,
    ip character varying(255),
    address character varying(255) NOT NULL,
    text text NOT NULL,
    is_active boolean NOT NULL,
    status character varying(50) NOT NULL,
    expiry_date timestamp with time zone,
    have_extension boolean NOT NULL,
    establishment_id bigint NOT NULL,
    user_created_id integer,
    user_deleted_id integer,
    user_updated_id integer,
    is_manual boolean NOT NULL,
    email character varying(254) NOT NULL,
    first_name character varying(255) NOT NULL,
    format_receipt character varying(255) NOT NULL,
    city character varying(255) NOT NULL,
    last_name character varying(255) NOT NULL,
    phone character varying(255) NOT NULL,
    format_send character varying(255) NOT NULL,
    date timestamp with time zone NOT NULL,
    gender character varying(255) NOT NULL,
    number_saip character varying(255),
    race_identification character varying(255) NOT NULL,
    date_mail_send timestamp with time zone
);


ALTER TABLE public.entity_app_solicity OWNER TO auth_user;

--
-- Name: entity_app_solicity_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.entity_app_solicity ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.entity_app_solicity_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: entity_app_solicityresponse; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.entity_app_solicityresponse (
    id bigint NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted boolean,
    deleted_at timestamp with time zone,
    ip character varying(255),
    text text NOT NULL,
    is_active boolean NOT NULL,
    solicity_id bigint NOT NULL,
    user_id integer NOT NULL,
    user_created_id integer,
    user_deleted_id integer,
    user_updated_id integer
);


ALTER TABLE public.entity_app_solicityresponse OWNER TO auth_user;

--
-- Name: entity_app_solicityresponse_attachments; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.entity_app_solicityresponse_attachments (
    id bigint NOT NULL,
    solicityresponse_id bigint NOT NULL,
    attachment_id bigint NOT NULL
);


ALTER TABLE public.entity_app_solicityresponse_attachments OWNER TO auth_user;

--
-- Name: entity_app_solicityresponse_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.entity_app_solicityresponse_attachments ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.entity_app_solicityresponse_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: entity_app_solicityresponse_files; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.entity_app_solicityresponse_files (
    id bigint NOT NULL,
    solicityresponse_id bigint NOT NULL,
    filepublication_id bigint NOT NULL
);


ALTER TABLE public.entity_app_solicityresponse_files OWNER TO auth_user;

--
-- Name: entity_app_solicityresponse_files_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.entity_app_solicityresponse_files ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.entity_app_solicityresponse_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: entity_app_solicityresponse_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.entity_app_solicityresponse ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.entity_app_solicityresponse_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: entity_app_tag; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.entity_app_tag (
    id bigint NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted boolean,
    deleted_at timestamp with time zone,
    ip character varying(255),
    name character varying(255),
    description text,
    is_active boolean,
    user_created_id integer,
    user_deleted_id integer,
    user_updated_id integer
);


ALTER TABLE public.entity_app_tag OWNER TO auth_user;

--
-- Name: entity_app_tag_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.entity_app_tag ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.entity_app_tag_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: entity_app_templatefile; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.entity_app_templatefile (
    id bigint NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted boolean,
    deleted_at timestamp with time zone,
    ip character varying(255),
    name character varying(255) NOT NULL,
    code character varying(255),
    description text NOT NULL,
    is_active boolean NOT NULL,
    vertical_template boolean NOT NULL,
    max_inserts integer,
    user_created_id integer,
    user_deleted_id integer,
    user_updated_id integer
);


ALTER TABLE public.entity_app_templatefile OWNER TO auth_user;

--
-- Name: entity_app_templatefile_columns; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.entity_app_templatefile_columns (
    id bigint NOT NULL,
    templatefile_id bigint NOT NULL,
    columnfile_id bigint NOT NULL
);


ALTER TABLE public.entity_app_templatefile_columns OWNER TO auth_user;

--
-- Name: entity_app_templatefile_columns_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.entity_app_templatefile_columns ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.entity_app_templatefile_columns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: entity_app_templatefile_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.entity_app_templatefile ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.entity_app_templatefile_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: entity_app_timelinesolicity; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.entity_app_timelinesolicity (
    id bigint NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted boolean,
    deleted_at timestamp with time zone,
    ip character varying(255),
    status character varying(255) NOT NULL,
    solicity_id bigint NOT NULL,
    user_created_id integer,
    user_deleted_id integer,
    user_updated_id integer
);


ALTER TABLE public.entity_app_timelinesolicity OWNER TO auth_user;

--
-- Name: entity_app_timelinesolicity_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.entity_app_timelinesolicity ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.entity_app_timelinesolicity_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: entity_app_transparencyactive; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.entity_app_transparencyactive (
    id bigint NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted boolean,
    deleted_at timestamp with time zone,
    ip character varying(255),
    slug character varying(255),
    month integer NOT NULL,
    year integer NOT NULL,
    establishment_id bigint NOT NULL,
    numeral_id bigint NOT NULL,
    user_created_id integer,
    user_deleted_id integer,
    user_updated_id integer,
    max_date_to_publish timestamp with time zone,
    published boolean NOT NULL,
    published_at timestamp with time zone,
    status character varying(255) NOT NULL
);


ALTER TABLE public.entity_app_transparencyactive OWNER TO auth_user;

--
-- Name: entity_app_transparencyactive_files; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.entity_app_transparencyactive_files (
    id bigint NOT NULL,
    transparencyactive_id bigint NOT NULL,
    filepublication_id bigint NOT NULL
);


ALTER TABLE public.entity_app_transparencyactive_files OWNER TO auth_user;

--
-- Name: entity_app_transparencyactive_files_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.entity_app_transparencyactive_files ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.entity_app_transparencyactive_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: entity_app_transparencyactive_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.entity_app_transparencyactive ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.entity_app_transparencyactive_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: entity_app_transparencycolab; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.entity_app_transparencycolab (
    id bigint NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted boolean,
    deleted_at timestamp with time zone,
    ip character varying(255),
    slug character varying(255),
    month integer NOT NULL,
    year integer NOT NULL,
    status character varying(255) NOT NULL,
    published boolean NOT NULL,
    published_at timestamp with time zone,
    max_date_to_publish timestamp with time zone,
    establishment_id bigint NOT NULL,
    numeral_id bigint NOT NULL,
    user_created_id integer,
    user_deleted_id integer,
    user_updated_id integer
);


ALTER TABLE public.entity_app_transparencycolab OWNER TO auth_user;

--
-- Name: entity_app_transparencycolab_files; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.entity_app_transparencycolab_files (
    id bigint NOT NULL,
    transparencycolab_id bigint NOT NULL,
    filepublication_id bigint NOT NULL
);


ALTER TABLE public.entity_app_transparencycolab_files OWNER TO auth_user;

--
-- Name: entity_app_transparencycolab_files_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.entity_app_transparencycolab_files ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.entity_app_transparencycolab_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: entity_app_transparencycolab_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.entity_app_transparencycolab ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.entity_app_transparencycolab_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: entity_app_transparencyfocal; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.entity_app_transparencyfocal (
    id bigint NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted boolean,
    deleted_at timestamp with time zone,
    ip character varying(255),
    slug character varying(255),
    month integer NOT NULL,
    year integer NOT NULL,
    status character varying(255) NOT NULL,
    published boolean NOT NULL,
    published_at timestamp with time zone,
    max_date_to_publish timestamp with time zone,
    establishment_id bigint NOT NULL,
    numeral_id bigint NOT NULL,
    user_created_id integer,
    user_deleted_id integer,
    user_updated_id integer
);


ALTER TABLE public.entity_app_transparencyfocal OWNER TO auth_user;

--
-- Name: entity_app_transparencyfocal_files; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.entity_app_transparencyfocal_files (
    id bigint NOT NULL,
    transparencyfocal_id bigint NOT NULL,
    filepublication_id bigint NOT NULL
);


ALTER TABLE public.entity_app_transparencyfocal_files OWNER TO auth_user;

--
-- Name: entity_app_transparencyfocal_files_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.entity_app_transparencyfocal_files ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.entity_app_transparencyfocal_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: entity_app_transparencyfocal_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.entity_app_transparencyfocal ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.entity_app_transparencyfocal_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: entity_app_typeformats; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.entity_app_typeformats (
    id bigint NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted boolean,
    deleted_at timestamp with time zone,
    ip character varying(255),
    name character varying(255),
    description text,
    user_created_id integer,
    user_deleted_id integer,
    user_updated_id integer
);


ALTER TABLE public.entity_app_typeformats OWNER TO auth_user;

--
-- Name: entity_app_typeformats_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.entity_app_typeformats ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.entity_app_typeformats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: entity_app_typepublication; Type: TABLE; Schema: public; Owner: auth_user
--

CREATE TABLE public.entity_app_typepublication (
    id bigint NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted boolean,
    deleted_at timestamp with time zone,
    ip character varying(255),
    name character varying(255),
    description text,
    is_active boolean,
    user_created_id integer,
    user_deleted_id integer,
    user_updated_id integer,
    code character varying(255)
);


ALTER TABLE public.entity_app_typepublication OWNER TO auth_user;

--
-- Name: entity_app_typepublication_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_user
--

ALTER TABLE public.entity_app_typepublication ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.entity_app_typepublication_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Data for Name: activity_log; Type: TABLE DATA; Schema: public; Owner: auth_user
--

COPY public.activity_log (id, created_at, updated_at, deleted, deleted_at, ip, activity, description, ip_address, user_agent, is_active, user_id, user_created_id, user_deleted_id, user_updated_id) FROM stdin;
\.


--
-- Data for Name: app_admin_accesstoinformation_establishment; Type: TABLE DATA; Schema: public; Owner: auth_user
--

COPY public.app_admin_accesstoinformation_establishment (id, accesstoinformation_id, establishment_id) FROM stdin;
1	1	1
2	2	2
3	3	3
4	4	4
5	5	5
6	6	6
7	7	7
8	8	8
9	9	9
10	10	10
11	11	11
12	12	12
13	13	13
14	14	14
15	15	15
16	16	16
17	17	17
18	18	18
19	19	19
20	20	20
21	21	21
22	22	22
23	23	23
24	24	24
25	25	25
26	26	26
27	27	27
28	28	28
29	29	29
30	30	30
31	31	31
32	32	32
33	33	33
34	34	34
35	35	35
36	36	36
37	37	37
38	38	38
39	39	39
40	40	40
41	41	41
42	42	42
43	43	43
44	44	44
45	45	45
46	46	46
47	47	47
48	48	48
49	49	49
50	50	50
51	51	51
52	52	52
53	53	53
54	54	54
55	55	55
56	56	56
57	57	57
58	58	58
59	59	59
60	60	60
61	61	61
62	62	62
63	63	63
64	64	64
65	65	65
66	66	66
67	67	67
68	68	68
69	69	69
70	70	70
71	71	71
72	72	72
73	73	73
74	74	74
75	75	75
76	76	76
77	77	77
78	78	78
79	79	79
80	80	80
81	81	81
82	82	82
83	83	83
84	84	84
85	85	85
86	86	86
87	87	87
88	88	88
89	89	89
90	90	90
91	91	91
92	92	92
93	93	93
94	94	94
95	95	95
96	96	96
97	97	97
98	98	98
99	99	99
100	100	100
101	101	101
102	102	102
103	103	103
104	104	104
105	105	105
106	106	106
107	107	107
108	108	108
109	109	109
110	110	110
111	111	111
112	112	112
113	113	113
\.


--
-- Data for Name: app_admin_configuration; Type: TABLE DATA; Schema: public; Owner: auth_user
--

COPY public.app_admin_configuration (id, created_at, updated_at, deleted, deleted_at, name, value, is_active, type_config, user_created_id, user_deleted_id, user_updated_id, ip) FROM stdin;
1	2024-01-07 14:50:02.542+00	2024-01-07 14:50:02.542+00	f	\N	HOST	smtp-relay.brevo.com	t	SMTP	1	\N	\N	\N
2	2024-01-07 14:50:16.316+00	2024-01-07 14:50:16.316+00	f	\N	PORT	587	t	SMTP	\N	\N	\N	\N
3	2024-01-07 14:50:36.365+00	2024-01-07 14:50:36.365+00	f	\N	USER	anderson.sinaluisa@gmail.com	t	SMTP	\N	\N	\N	\N
4	2024-01-07 14:50:52.461+00	2024-01-07 14:50:52.461+00	f	\N	PASSWORD	83vLrXsKAk45G9ST	t	SMTP	\N	\N	\N	\N
5	2024-01-07 14:51:48.948+00	2024-01-07 14:51:57.804+00	f	\N	USE_TLS	False	t	SMTP	\N	\N	\N	\N
\.


--
-- Data for Name: app_admin_email; Type: TABLE DATA; Schema: public; Owner: auth_user
--


--
-- Data for Name: app_admin_establishment; Type: TABLE DATA; Schema: public; Owner: auth_user
--

--
-- Data for Name: app_admin_formfields; Type: TABLE DATA; Schema: public; Owner: auth_user
--

COPY public.app_admin_formfields (id, created_at, updated_at, deleted, deleted_at, name, description, form_type, model, is_active, role, type_field, "order", options, permission_required, content_type_id, object_id, user_created_id, user_deleted_id, user_updated_id, ip) FROM stdin;
1	2023-12-29 15:43:09.828+00	2023-12-31 15:04:02.122+00	f	\N	identification	Número de cédula Persona Superadministradora PNT DPE	Usuario	Person	t	Superadministradora PNT DPE	text	3	\N	add_user_monitoreo_pnt_dpe	\N	\N	\N	\N	\N	\N
2	2023-12-29 15:44:04.749+00	2023-12-31 15:04:42.326+00	f	\N	password	Contraseña Persona Superadministradora PNT DPE	Usuario	User	t	Superadministradora PNT DPE	password	6	\N	add_user_monitoreo_pnt_dpe	\N	\N	\N	\N	\N	\N
3	2023-12-29 15:44:46.374+00	2023-12-31 15:04:28.182+00	f	\N	first_name	Nombre(s) de la Persona Superadministradora PNT DPE	Usuario	User	t	Superadministradora PNT DPE	text	1	\N	add_user_monitoreo_pnt_dpe	\N	\N	\N	\N	\N	\N
4	2023-12-29 15:45:16.411+00	2023-12-31 15:03:42.791+00	f	\N	last_name	Apellido(s) de la Persona Superadministradora PNT DPE	Usuario	User	t	Superadministradora PNT DPE	text	2	\N	add_user_monitoreo_pnt_dpe	\N	\N	\N	\N	\N	\N
5	2023-12-29 15:46:26.665+00	2023-12-31 15:04:20.721+00	f	\N	job	Cargo de la Persona Superadministradora PNT DPE	Usuario	Person	t	Superadministradora PNT DPE	text	4	\N	add_user_monitoreo_pnt_dpe	\N	\N	\N	\N	\N	\N
6	2023-12-29 15:46:53.245+00	2023-12-31 15:04:33.422+00	f	\N	email	Correo de la Persona Superadministradora PNT DPE	Usuario	Person	t	Superadministradora PNT DPE	email	5	\N	add_user_monitoreo_pnt_dpe	\N	\N	\N	\N	\N	\N
7	2023-12-29 15:52:47.791+00	2023-12-29 15:52:47.791+00	f	\N	identification	Número de cédula Persona Monitoreo PNT DPE	Usuario	Person	t	Monitoreo DPE	text	0	\N	add_user_monitoreo_dpe	\N	\N	\N	\N	\N	\N
8	2023-12-29 15:53:35.447+00	2023-12-29 15:53:35.447+00	f	\N	password	Contraseña Persona Monitoreo PNT DPE	Usuario	Person	t	Monitoreo DPE	password	0	\N	add_user_monitoreo_dpe	\N	\N	\N	\N	\N	\N
9	2023-12-29 15:53:56.641+00	2023-12-29 15:53:56.641+00	f	\N	first_name	Nombre(s) de la Persona Monitoreo PNT DPE	Usuario	User	t	Monitoreo DPE	text	0	\N	add_user_monitoreo_dpe	\N	\N	\N	\N	\N	\N
10	2023-12-29 15:54:12.945+00	2023-12-29 15:54:12.945+00	f	\N	last_name	Apellido(s) de la Persona Monitoreo PNT DPE	Usuario	User	t	Monitoreo DPE	text	0	\N	add_user_monitoreo_dpe	\N	\N	\N	\N	\N	\N
11	2023-12-29 15:54:29.357+00	2023-12-29 15:54:29.357+00	f	\N	job	Cargo de la Persona Monitoreo PNT DPE	Usuario	Person	t	Monitoreo DPE	text	0	\N	add_user_monitoreo_dpe	\N	\N	\N	\N	\N	\N
12	2023-12-29 15:54:46.864+00	2024-01-01 21:27:47.176+00	f	\N	email	Correo de la Persona Monitoreo PNT DPE	Usuario	User	t	Monitoreo DPE	email	0	\N	add_user_monitoreo_dpe	\N	\N	\N	\N	\N	\N
13	2023-12-29 15:59:48.968+00	2023-12-29 15:59:48.968+00	f	\N	identification	Número de cédula Persona Supervisora PNT Institución	Usuario	Person	t	Supervisora PNT	text	0	\N	add_user_supervisora_pnt	\N	\N	\N	\N	\N	\N
14	2023-12-29 16:00:12.086+00	2023-12-29 16:00:12.086+00	f	\N	password	Contraseña Persona Supervisora PNT Institución	Usuario	User	t	Supervisora PNT	password	0	\N	add_user_supervisora_pnt	\N	\N	\N	\N	\N	\N
15	2023-12-29 16:00:32.46+00	2023-12-29 16:00:32.46+00	f	\N	first_name	Nombre(s) de la persona Supervisora PNT Institución	Usuario	User	t	Supervisora PNT	text	0	\N	add_user_supervisora_pnt	\N	\N	\N	\N	\N	\N
16	2023-12-29 16:00:45.961+00	2023-12-29 16:00:45.961+00	f	\N	last_name	Apellido(s) de la persona Supervisora PNT Institución	Usuario	User	t	Supervisora PNT	text	0	\N	add_user_supervisora_pnt	\N	\N	\N	\N	\N	\N
17	2023-12-29 16:01:01.192+00	2023-12-29 16:01:01.192+00	f	\N	job	Cargo de la persona Supervisora PNT Institución	Usuario	User	t	Supervisora PNT	text	0	\N	add_user_supervisora_pnt	\N	\N	\N	\N	\N	\N
18	2023-12-29 16:01:21.829+00	2023-12-29 16:01:21.829+00	f	\N	email	Correo de la persona Supervisora PNT Institución	Usuario	User	t	Supervisora PNT	text	0	\N	add_user_supervisora_pnt	\N	\N	\N	\N	\N	\N
19	2023-12-29 16:09:10.992+00	2023-12-29 16:09:10.992+00	f	\N	identification	Número de cédula Persona Carga PNT Institución	Usuario	User	t	Carga PNT	text	0	\N	add_user_carga_pnt	\N	\N	\N	\N	\N	\N
20	2023-12-29 16:09:30.105+00	2023-12-29 16:09:30.105+00	f	\N	password	Contraseña Persona Carga PNT Institución	Usuario	User	t	Carga PNT	password	0	\N	add_user_carga_pnt	\N	\N	\N	\N	\N	\N
21	2023-12-29 16:09:49.119+00	2023-12-29 16:09:49.119+00	f	\N	first_name	Nombre(s) de la persona Carga PNT Institución	Usuario	User	t	Carga PNT	text	0	\N	add_user_carga_pnt	\N	\N	\N	\N	\N	\N
22	2023-12-29 16:10:06.909+00	2023-12-29 16:10:06.909+00	f	\N	last_name	Apellido(s) de la persona Carga PNT Institución	Usuario	User	t	Carga PNT	text	0	\N	add_user_carga_pnt	\N	\N	\N	\N	\N	\N
23	2023-12-29 16:10:21.978+00	2023-12-29 16:10:21.978+00	f	\N	job	Cargo de la persona Carga PNT Institución	Usuario	User	t	Carga PNT	text	0	\N	add_user_carga_pnt	\N	\N	\N	\N	\N	\N
24	2023-12-29 16:10:44.596+00	2023-12-29 16:10:44.596+00	f	\N	email	Correo de la persona Carga PNT Institución	Usuario	User	t	Carga PNT	email	0	\N	add_user_carga_pnt	\N	\N	\N	\N	\N	\N
26	2023-12-29 16:24:54.73+00	2023-12-31 15:34:29.575+00	f	\N	password	Contraseña	Usuario	User	t	Ciudadano	password	12	\N	add_user_ciudadano	\N	\N	\N	\N	\N	\N
43	2023-12-29 16:24:54.73+00	2023-12-31 15:34:29.575+00	f	\N	confirm_password	Confirmar Contraseña	Usuario	User	t	Ciudadano	password	12	\N	add_user_ciudadano	\N	\N	\N	\N	\N	\N
27	2023-12-29 16:25:17.841+00	2023-12-31 15:05:37.121+00	f	\N	first_name	Nombre(s)	Usuario	User	t	Ciudadano	text	1	\N	add_user_ciudadano	\N	\N	\N	\N	\N	\N
28	2023-12-29 16:25:34.495+00	2023-12-31 15:05:41.25+00	f	\N	last_name	Apellido(s)	Usuario	User	t	Ciudadano	text	2	\N	add_user_ciudadano	\N	\N	\N	\N	\N	\N
29	2023-12-29 16:25:52.559+00	2023-12-31 15:07:12.821+00	f	\N	email	Correo Electrónico	Usuario	User	t	Ciudadano	text	11	\N	add_user_ciudadano	\N	\N	\N	\N	\N	\N
30	2023-12-29 16:26:14.707+00	2023-12-31 15:07:04.962+00	f	\N	phone	Teléfono de contacto	Usuario	Person	t	Ciudadano	tel	10	\N	add_user_ciudadano	\N	\N	\N	\N	\N	\N
37	2023-12-29 16:29:20.676+00	2023-12-31 15:07:29.016+00	f	\N	accept_terms	Aceptar Términos y Condiciones	Usuario	Person	t	Ciudadano	checkbox	13	\N	add_user_ciudadano	\N	\N	\N	\N	\N	\N
38	2023-12-30 00:23:08.417+00	2023-12-30 00:23:08.417+00	f	\N	name	Nombre Completo de la Institución	Entidad	Establishment	t	DPE	text	0	\N	\N	\N	\N	\N	\N	\N	\N
39	2024-01-01 16:43:50.894+00	2024-01-01 16:43:50.895+00	f	\N	establishment_id	Institución a la que pertenece	Usuario	User	t	Carga PNT	select	7	\N	add_user_carga_pnt	11	\N	\N	\N	\N	\N
42	2024-01-01 20:41:21.642+00	2024-01-01 20:41:21.642+00	f	\N	establishment_id	Institución a la que pertenece	Usuario	User	t	Supervisora PNT	select	7	\N	add_user_supervisora_pnt	11	\N	\N	\N	\N	\N
44	2023-12-29 15:43:09.828+00	2023-12-31 15:04:02.122+00	f	\N	gender	Género	Usuario	Person	t	Ciudadano	select	3	[{"id": "Masculino", "name": "Masculino", "color": "#00B8D9"}, {"id": "Femenino", "name": "Femenino", "color": "#00B8D9"}, {"id": "LGBTIQ+", "name": "LGBTIQ+", "color": "#00B8D9"}, {"id": "Otro", "name": "Otro", "color": "#00B8D9"}]	add_user_ciudadano	\N	\N	\N	\N	\N	\N
45	2023-12-29 15:43:09.828+00	2023-12-31 15:04:02.122+00	f	\N	race	Identificación cultural	Usuario	Person	t	Ciudadano	select	4	[{"id": "Mestiza", "name": "Mestiza", "color": "#00B8D9"}, {"id": "Pueblo montubio", "name": "Pueblo montubio", "color": "#00B8D9"}, {"id": "Pueblo o nacionalidadades indígenas", "name": "Pueblo o nacionalidadades indígenas", "color": "#00B8D9"}, {"id": "Pueblo afrodescendiente", "name": "Pueblo afrodescendiente", "color": "#00B8D9"}, {"id": "Blanca", "name": "Blanca", "color": "#00B8D9"}]	add_user_ciudadano	\N	\N	\N	\N	\N	\N
46	2023-12-29 15:43:09.828+00	2023-12-31 15:04:02.122+00	f	\N	username	Usuario	Usuario	Person	t	Ciudadano	text	4	\N	add_user_ciudadano	\N	\N	\N	\N	\N	\N
47	2023-12-29 15:43:09.828+00	2023-12-31 15:04:02.122+00	f	\N	username	Usuario	Usuario	Person	t	Superadministradora PNT DPE	text	4	\N	add_user_monitoreo_pnt_dpe	\N	\N	\N	\N	\N	\N
48	2023-12-29 15:43:09.828+00	2023-12-31 15:04:02.122+00	f	\N	username	Usuario	Usuario	Person	t	Monitoreo DPE	text	4	\N	add_user_monitoreo_dpe	\N	\N	\N	\N	\N	\N
49	2023-12-29 15:43:09.828+00	2023-12-31 15:04:02.122+00	f	\N	username	Usuario	Usuario	Person	t	Supervisora PNT	text	4	\N	add_user_supervisora_pnt	\N	\N	\N	\N	\N	\N
50	2023-12-29 15:43:09.828+00	2023-12-31 15:04:02.122+00	f	\N	username	Usuario	Usuario	Person	t	Carga PNT	text	4	\N	add_user_carga_pnt	\N	\N	\N	\N	\N	\N
\.


--
-- Data for Name: app_admin_frequentlyaskedquestions; Type: TABLE DATA; Schema: public; Owner: auth_user
--

COPY public.app_admin_frequentlyaskedquestions (id, created_at, updated_at, deleted, deleted_at, question, answer, is_active, pedagogy_area_id, user_created_id, user_deleted_id, user_updated_id, ip) FROM stdin;
7	2024-07-23 18:54:47.999699+00	2024-07-23 18:54:47.999699+00	f	\N	¿Qué es una SAIP?	Por sus siglas significa solicitud de acceso a la información pública (SAIP), y es la obligación que tienen las instituciones públicas privadas que administran fondos del Estado de responder los requerimientos de las personas interesadas en solicitar información pública.	t	1	1	\N	1	\N
\.


--
-- Data for Name: app_admin_functionorganization; Type: TABLE DATA; Schema: public; Owner: auth_user
--

COPY public.app_admin_functionorganization (id, created_at, updated_at, deleted, deleted_at, ip, name, is_active, user_created_id, user_deleted_id, user_updated_id) FROM stdin;
1	2024-07-23 05:52:18.831905+00	2024-07-23 05:52:18.831919+00	f	\N	\N	FUNCIÓN EJECUTIVA	t	\N	\N	\N
2	2024-07-23 05:52:18.833836+00	2024-07-23 05:52:18.833848+00	f	\N	\N	OTRAS INSTITUCIONES PÚBLICAS	t	\N	\N	\N
3	2024-07-23 05:52:18.835339+00	2024-07-23 05:52:18.835348+00	f	\N	\N	FUNCIÓN LEGISLATIVA	t	\N	\N	\N
4	2024-07-23 05:52:18.836683+00	2024-07-23 05:52:18.836692+00	f	\N	\N	FUNCION JUDICIAL	t	\N	\N	\N
5	2024-07-23 05:52:18.837873+00	2024-07-23 05:52:18.837882+00	f	\N	\N	FUNCIÓN ELECTORAL	t	\N	\N	\N
6	2024-07-23 05:52:18.839095+00	2024-07-23 05:52:18.839104+00	f	\N	\N	FUNCION DE TRANSPARENCIA Y CONTROL SOCIAL	t	\N	\N	\N
7	2024-07-23 05:52:18.840431+00	2024-07-23 05:52:18.84044+00	f	\N	\N	GOBIERNOS AUTÓNOMOS DESCENTRALIZADOS	t	\N	\N	\N
8	2024-07-23 05:52:18.84184+00	2024-07-23 05:52:18.841849+00	f	\N	\N	ENTIDADES PRIVADAS	t	\N	\N	\N
9	2024-07-23 05:52:47.636882+00	2024-07-23 05:52:47.636913+00	f	\N	\N	FUNCIÓN EJECUTIVA	t	\N	\N	\N
10	2024-07-23 05:52:47.641067+00	2024-07-23 05:52:47.64109+00	f	\N	\N	OTRAS INSTITUCIONES PÚBLICAS	t	\N	\N	\N
11	2024-07-23 05:52:47.643134+00	2024-07-23 05:52:47.643149+00	f	\N	\N	FUNCIÓN LEGISLATIVA	t	\N	\N	\N
12	2024-07-23 05:52:47.646565+00	2024-07-23 05:52:47.646581+00	f	\N	\N	FUNCION JUDICIAL	t	\N	\N	\N
13	2024-07-23 05:52:47.648727+00	2024-07-23 05:52:47.648741+00	f	\N	\N	FUNCIÓN ELECTORAL	t	\N	\N	\N
14	2024-07-23 05:52:47.649962+00	2024-07-23 05:52:47.649974+00	f	\N	\N	FUNCION DE TRANSPARENCIA Y CONTROL SOCIAL	t	\N	\N	\N
15	2024-07-23 05:52:47.651436+00	2024-07-23 05:52:47.651449+00	f	\N	\N	GOBIERNOS AUTÓNOMOS DESCENTRALIZADOS	t	\N	\N	\N
16	2024-07-23 05:52:47.65298+00	2024-07-23 05:52:47.652991+00	f	\N	\N	ENTIDADES PRIVADAS	t	\N	\N	\N
17	2024-07-23 05:55:39.001802+00	2024-07-23 05:55:39.001813+00	f	\N	\N	FUNCIÓN EJECUTIVA	t	\N	\N	\N
18	2024-07-23 05:55:39.003503+00	2024-07-23 05:55:39.003518+00	f	\N	\N	OTRAS INSTITUCIONES PÚBLICAS	t	\N	\N	\N
19	2024-07-23 05:55:39.004707+00	2024-07-23 05:55:39.004725+00	f	\N	\N	FUNCIÓN LEGISLATIVA	t	\N	\N	\N
20	2024-07-23 05:55:39.005912+00	2024-07-23 05:55:39.005921+00	f	\N	\N	FUNCION JUDICIAL	t	\N	\N	\N
21	2024-07-23 05:55:39.007024+00	2024-07-23 05:55:39.007034+00	f	\N	\N	FUNCIÓN ELECTORAL	t	\N	\N	\N
22	2024-07-23 05:55:39.008416+00	2024-07-23 05:55:39.008426+00	f	\N	\N	FUNCION DE TRANSPARENCIA Y CONTROL SOCIAL	t	\N	\N	\N
23	2024-07-23 05:55:39.009573+00	2024-07-23 05:55:39.009583+00	f	\N	\N	GOBIERNOS AUTÓNOMOS DESCENTRALIZADOS	t	\N	\N	\N
24	2024-07-23 05:55:39.010807+00	2024-07-23 05:55:39.010818+00	f	\N	\N	ENTIDADES PRIVADAS	t	\N	\N	\N
\.




--
-- Data for Name: app_admin_normativedocument; Type: TABLE DATA; Schema: public; Owner: auth_user
--

COPY public.app_admin_normativedocument (id, created_at, updated_at, deleted, deleted_at, title, description, url, is_active, pedagogy_area_id, user_created_id, user_deleted_id, user_updated_id, ip) FROM stdin;
7	2024-07-23 18:54:47.999699+00	2024-07-23 18:54:47.999699+00	f	\N	Ley Orgánica de Transparencia y Acceso a la Información Pública (LOTAIP)	Ley Orgánica de Transparencia y Acceso a la Información Pública (LOTAIP)	https://transparencia.dpe.gob.ec/transparencia/LOTAIP2023RO.pdf	t	1	1	\N	1	\N
\.


--
-- Data for Name: app_admin_pedagogyarea; Type: TABLE DATA; Schema: public; Owner: auth_user
--

COPY public.app_admin_pedagogyarea (id, created_at, updated_at, deleted, deleted_at, published, user_created_id, user_deleted_id, user_updated_id, ip) FROM stdin;
1	2024-07-23 14:36:00.069787+00	2024-07-23 14:36:00.069787+00	f	\N	t	1	\N	1	\N
\.


--
-- Data for Name: app_admin_tutorialvideo; Type: TABLE DATA; Schema: public; Owner: auth_user
--

COPY public.app_admin_tutorialvideo (id, created_at, updated_at, deleted, deleted_at, title, description, url, is_active, pedagogy_area_id, user_created_id, user_deleted_id, user_updated_id, ip) FROM stdin;
7	2024-07-23 18:54:47.999699+00	2024-07-23 18:54:47.999699+00	f	\N	Transparencia LOTAIP – Formato 1.1 Estructura orgánica	Tutorial del Formato 1.1 Estructura orgánica.	https://www.youtube.com/embed/10LuMEf0qyE	t	1	1	\N	1	\N
\.


--
-- Data for Name: app_admin_typeinstitution; Type: TABLE DATA; Schema: public; Owner: auth_user
--

COPY public.app_admin_typeinstitution (id, created_at, updated_at, deleted, deleted_at, ip, name, is_active, user_created_id, user_deleted_id, user_updated_id) FROM stdin;
1	2024-07-23 05:52:18.721943+00	2024-07-23 05:52:18.721974+00	f	\N	\N	Institución de la Función Ejecutiva	t	\N	\N	\N
2	2024-07-23 05:52:18.731186+00	2024-07-23 05:52:18.731247+00	f	\N	\N	Institución Adscrita a la Secretaría Nacional de Gestión de Riesgos	t	\N	\N	\N
3	2024-07-23 05:52:18.733688+00	2024-07-23 05:52:18.733709+00	f	\N	\N	Institución Adscrita a la Presidencia de la República	t	\N	\N	\N
4	2024-07-23 05:52:18.735708+00	2024-07-23 05:52:18.735725+00	f	\N	\N	Institución Adscrita a la SENPLADES	t	\N	\N	\N
5	2024-07-23 05:52:18.744843+00	2024-07-23 05:52:18.744865+00	f	\N	\N	Institución Adscrita al Ministerio de Coordinación de Seguridad	t	\N	\N	\N
6	2024-07-23 05:52:18.746866+00	2024-07-23 05:52:18.747159+00	f	\N	\N	Ministerio Sectorial	t	\N	\N	\N
7	2024-07-23 05:52:18.749955+00	2024-07-23 05:52:18.749971+00	f	\N	\N	Entidad Adscrita al Ministerio de Cultura	t	\N	\N	\N
8	2024-07-23 05:52:18.751932+00	2024-07-23 05:52:18.751946+00	f	\N	\N	Entidad Adscrita al Ministerio de Agricultura	t	\N	\N	\N
9	2024-07-23 05:52:18.759002+00	2024-07-23 05:52:18.759044+00	f	\N	\N	Entidad Dependiente del Ministerio de Ambiente	t	\N	\N	\N
10	2024-07-23 05:52:18.760894+00	2024-07-23 05:52:18.76091+00	f	\N	\N	Adscrito al Ministerio de Ambiente	t	\N	\N	\N
11	2024-07-23 05:52:18.76248+00	2024-07-23 05:52:18.762493+00	f	\N	\N	Adscrita a la Comandancia General de la Fuerza Aérea	t	\N	\N	\N
12	2024-07-23 05:52:18.764022+00	2024-07-23 05:52:18.764178+00	f	\N	\N	Adscrita al Ministerio de Desarrollo Urbano y Vivienda	t	\N	\N	\N
13	2024-07-23 05:52:18.765582+00	2024-07-23 05:52:18.765595+00	f	\N	\N	Dependencia del Ministerio del Interior	t	\N	\N	\N
14	2024-07-23 05:52:18.766924+00	2024-07-23 05:52:18.766935+00	f	\N	\N	Entidad Dependiente de la Policía Nacional	t	\N	\N	\N
15	2024-07-23 05:52:18.768057+00	2024-07-23 05:52:18.768096+00	f	\N	\N	Institución Adscrita al Ministerio de Inclusión Económica y Social	t	\N	\N	\N
16	2024-07-23 05:52:18.76919+00	2024-07-23 05:52:18.769199+00	f	\N	\N	Institución Adscrita al Ministerio de Energía y Recursos Naturales No Renovables	t	\N	\N	\N
17	2024-07-23 05:52:18.770972+00	2024-07-23 05:52:18.770983+00	f	\N	\N	Entidad Adscrita al Ministerio de Salud Pública	t	\N	\N	\N
18	2024-07-23 05:52:18.772334+00	2024-07-23 05:52:18.772348+00	f	\N	\N	Institutición Adscrita al Ministerio de Relaciones Laborales	t	\N	\N	\N
19	2024-07-23 05:52:18.77346+00	2024-07-23 05:52:18.773476+00	f	\N	\N	Institución Adscrita al Ministerio de Telecomunicaciones y de la Sociedad de la Información	t	\N	\N	\N
20	2024-07-23 05:52:18.774597+00	2024-07-23 05:52:18.774606+00	f	\N	\N	Otro	t	\N	\N	\N
21	2024-07-23 05:52:18.775729+00	2024-07-23 05:52:18.775739+00	f	\N	\N	Órgano de la Función Legislativa	t	\N	\N	\N
22	2024-07-23 05:52:18.776994+00	2024-07-23 05:52:18.777003+00	f	\N	\N	Organismo del Sector Público	t	\N	\N	\N
23	2024-07-23 05:52:18.778125+00	2024-07-23 05:52:18.778133+00	f	\N	\N	Órgano de la Función Judicial	t	\N	\N	\N
24	2024-07-23 05:52:18.779248+00	2024-07-23 05:52:18.779257+00	f	\N	\N	Órgano Autónomo de la Función Judicial	t	\N	\N	\N
25	2024-07-23 05:52:18.780444+00	2024-07-23 05:52:18.780453+00	f	\N	\N	Organismo de la Función Electoral	t	\N	\N	\N
26	2024-07-23 05:52:18.781516+00	2024-07-23 05:52:18.781525+00	f	\N	\N	Adscrito al Consejo Nacional Electoral	t	\N	\N	\N
27	2024-07-23 05:52:18.782731+00	2024-07-23 05:52:18.78274+00	f	\N	\N	Organismo de la Función de Transparencia y Control Social	t	\N	\N	\N
28	2024-07-23 05:52:18.78403+00	2024-07-23 05:52:18.78404+00	f	\N	\N	Entidad del Régimen Autónomo Descentralizado	t	\N	\N	\N
29	2024-07-23 05:52:18.785385+00	2024-07-23 05:52:18.785394+00	f	\N	\N	Entidad del Sector Público Financiero	t	\N	\N	\N
30	2024-07-23 05:52:18.786671+00	2024-07-23 05:52:18.78668+00	f	\N	\N	Entidad de Educación Superior	t	\N	\N	\N
31	2024-07-23 05:52:18.787812+00	2024-07-23 05:52:18.787822+00	f	\N	\N	Adscrita a la Escuela Politécnica Nacional	t	\N	\N	\N
32	2024-07-23 05:52:18.79128+00	2024-07-23 05:52:18.791325+00	f	\N	\N	Instituto Superior	t	\N	\N	\N
33	2024-07-23 05:52:18.793413+00	2024-07-23 05:52:18.793431+00	f	\N	\N	Empresa Pública	t	\N	\N	\N
34	2024-07-23 05:52:18.794762+00	2024-07-23 05:52:18.794774+00	f	\N	\N	Empresa Pública Municipal	t	\N	\N	\N
35	2024-07-23 05:52:18.795904+00	2024-07-23 05:52:18.795914+00	f	\N	\N	Empresa Pública Metropolitana	t	\N	\N	\N
36	2024-07-23 05:52:18.79714+00	2024-07-23 05:52:18.79715+00	f	\N	\N	Empresa Pública Mancomunada	t	\N	\N	\N
37	2024-07-23 05:52:18.798582+00	2024-07-23 05:52:18.798593+00	f	\N	\N	Empresa Pública Provincial	t	\N	\N	\N
38	2024-07-23 05:52:18.799641+00	2024-07-23 05:52:18.79965+00	f	\N	\N	Colegio Municipal	t	\N	\N	\N
39	2024-07-23 05:52:18.801003+00	2024-07-23 05:52:18.801012+00	f	\N	\N	Consorcio	t	\N	\N	\N
40	2024-07-23 05:52:18.802358+00	2024-07-23 05:52:18.802368+00	f	\N	\N	Mancomunidad	t	\N	\N	\N
41	2024-07-23 05:52:18.803592+00	2024-07-23 05:52:18.803601+00	f	\N	\N	Mancomunidad Provincial	t	\N	\N	\N
42	2024-07-23 05:52:18.804761+00	2024-07-23 05:52:18.804773+00	f	\N	\N	Adscrito a la Municipalidad	t	\N	\N	\N
43	2024-07-23 05:52:18.808261+00	2024-07-23 05:52:18.808276+00	f	\N	\N	Sociedad anónima	t	\N	\N	\N
44	2024-07-23 05:52:18.809616+00	2024-07-23 05:52:18.809626+00	f	\N	\N	Sociedad Anónima mercantl, mixta	t	\N	\N	\N
45	2024-07-23 05:52:18.810892+00	2024-07-23 05:52:18.810902+00	f	\N	\N	Compañía Anónima, reguladas por la Ley de Compañías	t	\N	\N	\N
46	2024-07-23 05:52:18.812435+00	2024-07-23 05:52:18.812445+00	f	\N	\N	Unidad Ejecutora UE Ministerio de Cultura	t	\N	\N	\N
47	2024-07-23 05:52:18.813857+00	2024-07-23 05:52:18.813902+00	f	\N	\N	Subsidiaria de PETROECUADOR	t	\N	\N	\N
48	2024-07-23 05:52:18.817251+00	2024-07-23 05:52:18.817263+00	f	\N	\N	Organismos del sector público creados por ley	t	\N	\N	\N
49	2024-07-23 05:52:18.818739+00	2024-07-23 05:52:18.818751+00	f	\N	\N	Personas jurídicas cond derecho público	t	\N	\N	\N
50	2024-07-23 05:52:18.820579+00	2024-07-23 05:52:18.820589+00	f	\N	\N	Institución Pública	t	\N	\N	\N
51	2024-07-23 05:52:18.822531+00	2024-07-23 05:52:18.822542+00	f	\N	\N	Entidad Adscrita al Gobierno Provincial	t	\N	\N	\N
52	2024-07-23 05:52:18.823886+00	2024-07-23 05:52:18.823897+00	f	\N	\N	Entidad Creada por el Gobierno Provincial	t	\N	\N	\N
53	2024-07-23 05:52:18.825997+00	2024-07-23 05:52:18.826007+00	f	\N	\N	Institución Adscrita al Ministerio de Economía y Finanzas	t	\N	\N	\N
54	2024-07-23 05:52:18.827201+00	2024-07-23 05:52:18.827212+00	f	\N	\N	Adscrita al Ministerio de Defensa	t	\N	\N	\N
55	2024-07-23 05:52:18.828917+00	2024-07-23 05:52:18.828927+00	f	\N	\N	Adscrito al Ministerio de Recursos Naturales no Renovables	t	\N	\N	\N
56	2024-07-23 05:52:18.830342+00	2024-07-23 05:52:18.830351+00	f	\N	\N	Entidad Privada	t	\N	\N	\N
57	2024-07-23 05:52:54.741265+00	2024-07-23 05:52:54.741295+00	f	\N	\N	Institución de la Función Ejecutiva	t	\N	\N	\N
58	2024-07-23 05:52:54.744107+00	2024-07-23 05:52:54.744126+00	f	\N	\N	Institución Adscrita a la Secretaría Nacional de Gestión de Riesgos	t	\N	\N	\N
59	2024-07-23 05:52:54.746555+00	2024-07-23 05:52:54.746572+00	f	\N	\N	Institución Adscrita a la Presidencia de la República	t	\N	\N	\N
60	2024-07-23 05:52:54.750879+00	2024-07-23 05:52:54.750897+00	f	\N	\N	Institución Adscrita a la SENPLADES	t	\N	\N	\N
61	2024-07-23 05:52:54.753821+00	2024-07-23 05:52:54.753838+00	f	\N	\N	Institución Adscrita al Ministerio de Coordinación de Seguridad	t	\N	\N	\N
62	2024-07-23 05:52:54.75694+00	2024-07-23 05:52:54.756959+00	f	\N	\N	Ministerio Sectorial	t	\N	\N	\N
63	2024-07-23 05:52:54.7601+00	2024-07-23 05:52:54.760121+00	f	\N	\N	Entidad Adscrita al Ministerio de Cultura	t	\N	\N	\N
64	2024-07-23 05:52:54.762145+00	2024-07-23 05:52:54.762255+00	f	\N	\N	Entidad Adscrita al Ministerio de Agricultura	t	\N	\N	\N
65	2024-07-23 05:52:54.764926+00	2024-07-23 05:52:54.764939+00	f	\N	\N	Entidad Dependiente del Ministerio de Ambiente	t	\N	\N	\N
66	2024-07-23 05:52:54.766428+00	2024-07-23 05:52:54.766441+00	f	\N	\N	Adscrito al Ministerio de Ambiente	t	\N	\N	\N
67	2024-07-23 05:52:54.769904+00	2024-07-23 05:52:54.769948+00	f	\N	\N	Adscrita a la Comandancia General de la Fuerza Aérea	t	\N	\N	\N
68	2024-07-23 05:52:54.771949+00	2024-07-23 05:52:54.771966+00	f	\N	\N	Adscrita al Ministerio de Desarrollo Urbano y Vivienda	t	\N	\N	\N
69	2024-07-23 05:52:54.773447+00	2024-07-23 05:52:54.773458+00	f	\N	\N	Dependencia del Ministerio del Interior	t	\N	\N	\N
70	2024-07-23 05:52:54.776645+00	2024-07-23 05:52:54.776658+00	f	\N	\N	Entidad Dependiente de la Policía Nacional	t	\N	\N	\N
71	2024-07-23 05:52:54.778037+00	2024-07-23 05:52:54.778049+00	f	\N	\N	Institución Adscrita al Ministerio de Inclusión Económica y Social	t	\N	\N	\N
72	2024-07-23 05:52:54.779415+00	2024-07-23 05:52:54.779429+00	f	\N	\N	Institución Adscrita al Ministerio de Energía y Recursos Naturales No Renovables	t	\N	\N	\N
73	2024-07-23 05:52:54.780702+00	2024-07-23 05:52:54.780712+00	f	\N	\N	Entidad Adscrita al Ministerio de Salud Pública	t	\N	\N	\N
74	2024-07-23 05:52:54.782399+00	2024-07-23 05:52:54.78241+00	f	\N	\N	Institutición Adscrita al Ministerio de Relaciones Laborales	t	\N	\N	\N
75	2024-07-23 05:52:54.786483+00	2024-07-23 05:52:54.786501+00	f	\N	\N	Institución Adscrita al Ministerio de Telecomunicaciones y de la Sociedad de la Información	t	\N	\N	\N
76	2024-07-23 05:52:54.78819+00	2024-07-23 05:52:54.788203+00	f	\N	\N	Otro	t	\N	\N	\N
77	2024-07-23 05:52:54.791327+00	2024-07-23 05:52:54.791342+00	f	\N	\N	Órgano de la Función Legislativa	t	\N	\N	\N
78	2024-07-23 05:52:54.79298+00	2024-07-23 05:52:54.792992+00	f	\N	\N	Organismo del Sector Público	t	\N	\N	\N
79	2024-07-23 05:52:54.794135+00	2024-07-23 05:52:54.794146+00	f	\N	\N	Órgano de la Función Judicial	t	\N	\N	\N
80	2024-07-23 05:52:54.79824+00	2024-07-23 05:52:54.798254+00	f	\N	\N	Órgano Autónomo de la Función Judicial	t	\N	\N	\N
81	2024-07-23 05:52:54.79992+00	2024-07-23 05:52:54.799933+00	f	\N	\N	Organismo de la Función Electoral	t	\N	\N	\N
82	2024-07-23 05:52:54.801946+00	2024-07-23 05:52:54.801959+00	f	\N	\N	Adscrito al Consejo Nacional Electoral	t	\N	\N	\N
83	2024-07-23 05:52:54.804957+00	2024-07-23 05:52:54.804971+00	f	\N	\N	Organismo de la Función de Transparencia y Control Social	t	\N	\N	\N
84	2024-07-23 05:52:54.806587+00	2024-07-23 05:52:54.806601+00	f	\N	\N	Entidad del Régimen Autónomo Descentralizado	t	\N	\N	\N
85	2024-07-23 05:52:54.81039+00	2024-07-23 05:52:54.810409+00	f	\N	\N	Entidad del Sector Público Financiero	t	\N	\N	\N
86	2024-07-23 05:52:54.81222+00	2024-07-23 05:52:54.812241+00	f	\N	\N	Entidad de Educación Superior	t	\N	\N	\N
87	2024-07-23 05:52:54.814023+00	2024-07-23 05:52:54.814038+00	f	\N	\N	Adscrita a la Escuela Politécnica Nacional	t	\N	\N	\N
88	2024-07-23 05:52:54.815746+00	2024-07-23 05:52:54.815762+00	f	\N	\N	Instituto Superior	t	\N	\N	\N
89	2024-07-23 05:52:54.819783+00	2024-07-23 05:52:54.819801+00	f	\N	\N	Empresa Pública	t	\N	\N	\N
90	2024-07-23 05:52:54.821777+00	2024-07-23 05:52:54.821793+00	f	\N	\N	Empresa Pública Municipal	t	\N	\N	\N
91	2024-07-23 05:52:54.823245+00	2024-07-23 05:52:54.82326+00	f	\N	\N	Empresa Pública Metropolitana	t	\N	\N	\N
92	2024-07-23 05:52:54.824687+00	2024-07-23 05:52:54.8247+00	f	\N	\N	Empresa Pública Mancomunada	t	\N	\N	\N
93	2024-07-23 05:52:54.82818+00	2024-07-23 05:52:54.828195+00	f	\N	\N	Empresa Pública Provincial	t	\N	\N	\N
94	2024-07-23 05:52:54.830256+00	2024-07-23 05:52:54.830272+00	f	\N	\N	Colegio Municipal	t	\N	\N	\N
95	2024-07-23 05:52:54.834439+00	2024-07-23 05:52:54.834456+00	f	\N	\N	Consorcio	t	\N	\N	\N
96	2024-07-23 05:52:54.83628+00	2024-07-23 05:52:54.836296+00	f	\N	\N	Mancomunidad	t	\N	\N	\N
97	2024-07-23 05:52:54.837819+00	2024-07-23 05:52:54.837834+00	f	\N	\N	Mancomunidad Provincial	t	\N	\N	\N
98	2024-07-23 05:52:54.839319+00	2024-07-23 05:52:54.839332+00	f	\N	\N	Adscrito a la Municipalidad	t	\N	\N	\N
99	2024-07-23 05:52:54.844377+00	2024-07-23 05:52:54.844398+00	f	\N	\N	Sociedad anónima	t	\N	\N	\N
100	2024-07-23 05:52:54.849066+00	2024-07-23 05:52:54.849085+00	f	\N	\N	Sociedad Anónima mercantl, mixta	t	\N	\N	\N
101	2024-07-23 05:52:54.850998+00	2024-07-23 05:52:54.851016+00	f	\N	\N	Compañía Anónima, reguladas por la Ley de Compañías	t	\N	\N	\N
102	2024-07-23 05:52:54.853204+00	2024-07-23 05:52:54.853221+00	f	\N	\N	Unidad Ejecutora UE Ministerio de Cultura	t	\N	\N	\N
103	2024-07-23 05:52:54.855973+00	2024-07-23 05:52:54.85599+00	f	\N	\N	Subsidiaria de PETROECUADOR	t	\N	\N	\N
104	2024-07-23 05:52:54.857609+00	2024-07-23 05:52:54.857624+00	f	\N	\N	Organismos del sector público creados por ley	t	\N	\N	\N
105	2024-07-23 05:52:54.859563+00	2024-07-23 05:52:54.85958+00	f	\N	\N	Personas jurídicas cond derecho público	t	\N	\N	\N
106	2024-07-23 05:52:54.861659+00	2024-07-23 05:52:54.861672+00	f	\N	\N	Institución Pública	t	\N	\N	\N
107	2024-07-23 05:52:54.863063+00	2024-07-23 05:52:54.863075+00	f	\N	\N	Entidad Adscrita al Gobierno Provincial	t	\N	\N	\N
108	2024-07-23 05:52:54.864386+00	2024-07-23 05:52:54.864397+00	f	\N	\N	Entidad Creada por el Gobierno Provincial	t	\N	\N	\N
109	2024-07-23 05:52:54.86557+00	2024-07-23 05:52:54.865582+00	f	\N	\N	Institución Adscrita al Ministerio de Economía y Finanzas	t	\N	\N	\N
110	2024-07-23 05:52:54.866934+00	2024-07-23 05:52:54.866948+00	f	\N	\N	Adscrita al Ministerio de Defensa	t	\N	\N	\N
111	2024-07-23 05:52:54.868342+00	2024-07-23 05:52:54.868355+00	f	\N	\N	Adscrito al Ministerio de Recursos Naturales no Renovables	t	\N	\N	\N
112	2024-07-23 05:52:54.869727+00	2024-07-23 05:52:54.869738+00	f	\N	\N	Entidad Privada	t	\N	\N	\N
113	2024-07-23 05:55:38.926144+00	2024-07-23 05:55:38.926173+00	f	\N	\N	Institución de la Función Ejecutiva	t	\N	\N	\N
114	2024-07-23 05:55:38.929428+00	2024-07-23 05:55:38.929448+00	f	\N	\N	Institución Adscrita a la Secretaría Nacional de Gestión de Riesgos	t	\N	\N	\N
115	2024-07-23 05:55:38.931228+00	2024-07-23 05:55:38.931246+00	f	\N	\N	Institución Adscrita a la Presidencia de la República	t	\N	\N	\N
116	2024-07-23 05:55:38.932756+00	2024-07-23 05:55:38.932772+00	f	\N	\N	Institución Adscrita a la SENPLADES	t	\N	\N	\N
117	2024-07-23 05:55:38.934427+00	2024-07-23 05:55:38.934443+00	f	\N	\N	Institución Adscrita al Ministerio de Coordinación de Seguridad	t	\N	\N	\N
118	2024-07-23 05:55:38.936471+00	2024-07-23 05:55:38.936485+00	f	\N	\N	Ministerio Sectorial	t	\N	\N	\N
119	2024-07-23 05:55:38.937807+00	2024-07-23 05:55:38.93782+00	f	\N	\N	Entidad Adscrita al Ministerio de Cultura	t	\N	\N	\N
120	2024-07-23 05:55:38.939121+00	2024-07-23 05:55:38.939132+00	f	\N	\N	Entidad Adscrita al Ministerio de Agricultura	t	\N	\N	\N
121	2024-07-23 05:55:38.940226+00	2024-07-23 05:55:38.940237+00	f	\N	\N	Entidad Dependiente del Ministerio de Ambiente	t	\N	\N	\N
122	2024-07-23 05:55:38.941318+00	2024-07-23 05:55:38.941329+00	f	\N	\N	Adscrito al Ministerio de Ambiente	t	\N	\N	\N
123	2024-07-23 05:55:38.942616+00	2024-07-23 05:55:38.942626+00	f	\N	\N	Adscrita a la Comandancia General de la Fuerza Aérea	t	\N	\N	\N
124	2024-07-23 05:55:38.943886+00	2024-07-23 05:55:38.943897+00	f	\N	\N	Adscrita al Ministerio de Desarrollo Urbano y Vivienda	t	\N	\N	\N
125	2024-07-23 05:55:38.945525+00	2024-07-23 05:55:38.945536+00	f	\N	\N	Dependencia del Ministerio del Interior	t	\N	\N	\N
126	2024-07-23 05:55:38.946647+00	2024-07-23 05:55:38.946658+00	f	\N	\N	Entidad Dependiente de la Policía Nacional	t	\N	\N	\N
127	2024-07-23 05:55:38.947899+00	2024-07-23 05:55:38.947911+00	f	\N	\N	Institución Adscrita al Ministerio de Inclusión Económica y Social	t	\N	\N	\N
128	2024-07-23 05:55:38.949123+00	2024-07-23 05:55:38.949133+00	f	\N	\N	Institución Adscrita al Ministerio de Energía y Recursos Naturales No Renovables	t	\N	\N	\N
129	2024-07-23 05:55:38.950419+00	2024-07-23 05:55:38.95043+00	f	\N	\N	Entidad Adscrita al Ministerio de Salud Pública	t	\N	\N	\N
130	2024-07-23 05:55:38.951793+00	2024-07-23 05:55:38.951803+00	f	\N	\N	Institutición Adscrita al Ministerio de Relaciones Laborales	t	\N	\N	\N
131	2024-07-23 05:55:38.95323+00	2024-07-23 05:55:38.953242+00	f	\N	\N	Institución Adscrita al Ministerio de Telecomunicaciones y de la Sociedad de la Información	t	\N	\N	\N
132	2024-07-23 05:55:38.954455+00	2024-07-23 05:55:38.954466+00	f	\N	\N	Otro	t	\N	\N	\N
133	2024-07-23 05:55:38.95582+00	2024-07-23 05:55:38.95583+00	f	\N	\N	Órgano de la Función Legislativa	t	\N	\N	\N
134	2024-07-23 05:55:38.9571+00	2024-07-23 05:55:38.957111+00	f	\N	\N	Organismo del Sector Público	t	\N	\N	\N
135	2024-07-23 05:55:38.958267+00	2024-07-23 05:55:38.958278+00	f	\N	\N	Órgano de la Función Judicial	t	\N	\N	\N
136	2024-07-23 05:55:38.959371+00	2024-07-23 05:55:38.959381+00	f	\N	\N	Órgano Autónomo de la Función Judicial	t	\N	\N	\N
137	2024-07-23 05:55:38.960734+00	2024-07-23 05:55:38.960745+00	f	\N	\N	Organismo de la Función Electoral	t	\N	\N	\N
138	2024-07-23 05:55:38.961874+00	2024-07-23 05:55:38.961884+00	f	\N	\N	Adscrito al Consejo Nacional Electoral	t	\N	\N	\N
139	2024-07-23 05:55:38.96319+00	2024-07-23 05:55:38.9632+00	f	\N	\N	Organismo de la Función de Transparencia y Control Social	t	\N	\N	\N
140	2024-07-23 05:55:38.964427+00	2024-07-23 05:55:38.964437+00	f	\N	\N	Entidad del Régimen Autónomo Descentralizado	t	\N	\N	\N
141	2024-07-23 05:55:38.965476+00	2024-07-23 05:55:38.965486+00	f	\N	\N	Entidad del Sector Público Financiero	t	\N	\N	\N
142	2024-07-23 05:55:38.967187+00	2024-07-23 05:55:38.967198+00	f	\N	\N	Entidad de Educación Superior	t	\N	\N	\N
143	2024-07-23 05:55:38.968466+00	2024-07-23 05:55:38.968477+00	f	\N	\N	Adscrita a la Escuela Politécnica Nacional	t	\N	\N	\N
144	2024-07-23 05:55:38.969599+00	2024-07-23 05:55:38.969609+00	f	\N	\N	Instituto Superior	t	\N	\N	\N
145	2024-07-23 05:55:38.970847+00	2024-07-23 05:55:38.970858+00	f	\N	\N	Empresa Pública	t	\N	\N	\N
146	2024-07-23 05:55:38.972032+00	2024-07-23 05:55:38.972041+00	f	\N	\N	Empresa Pública Municipal	t	\N	\N	\N
147	2024-07-23 05:55:38.973161+00	2024-07-23 05:55:38.97317+00	f	\N	\N	Empresa Pública Metropolitana	t	\N	\N	\N
148	2024-07-23 05:55:38.974286+00	2024-07-23 05:55:38.974296+00	f	\N	\N	Empresa Pública Mancomunada	t	\N	\N	\N
149	2024-07-23 05:55:38.975408+00	2024-07-23 05:55:38.975417+00	f	\N	\N	Empresa Pública Provincial	t	\N	\N	\N
150	2024-07-23 05:55:38.976608+00	2024-07-23 05:55:38.976616+00	f	\N	\N	Colegio Municipal	t	\N	\N	\N
151	2024-07-23 05:55:38.977837+00	2024-07-23 05:55:38.977874+00	f	\N	\N	Consorcio	t	\N	\N	\N
152	2024-07-23 05:55:38.979337+00	2024-07-23 05:55:38.979347+00	f	\N	\N	Mancomunidad	t	\N	\N	\N
153	2024-07-23 05:55:38.980737+00	2024-07-23 05:55:38.980747+00	f	\N	\N	Mancomunidad Provincial	t	\N	\N	\N
154	2024-07-23 05:55:38.982113+00	2024-07-23 05:55:38.982123+00	f	\N	\N	Adscrito a la Municipalidad	t	\N	\N	\N
155	2024-07-23 05:55:38.983336+00	2024-07-23 05:55:38.983346+00	f	\N	\N	Sociedad anónima	t	\N	\N	\N
156	2024-07-23 05:55:38.98473+00	2024-07-23 05:55:38.98474+00	f	\N	\N	Sociedad Anónima mercantl, mixta	t	\N	\N	\N
157	2024-07-23 05:55:38.986094+00	2024-07-23 05:55:38.986104+00	f	\N	\N	Compañía Anónima, reguladas por la Ley de Compañías	t	\N	\N	\N
158	2024-07-23 05:55:38.987402+00	2024-07-23 05:55:38.987574+00	f	\N	\N	Unidad Ejecutora UE Ministerio de Cultura	t	\N	\N	\N
159	2024-07-23 05:55:38.988846+00	2024-07-23 05:55:38.988855+00	f	\N	\N	Subsidiaria de PETROECUADOR	t	\N	\N	\N
160	2024-07-23 05:55:38.990092+00	2024-07-23 05:55:38.990102+00	f	\N	\N	Organismos del sector público creados por ley	t	\N	\N	\N
161	2024-07-23 05:55:38.991476+00	2024-07-23 05:55:38.991488+00	f	\N	\N	Personas jurídicas cond derecho público	t	\N	\N	\N
162	2024-07-23 05:55:38.992739+00	2024-07-23 05:55:38.992749+00	f	\N	\N	Institución Pública	t	\N	\N	\N
163	2024-07-23 05:55:38.993854+00	2024-07-23 05:55:38.993864+00	f	\N	\N	Entidad Adscrita al Gobierno Provincial	t	\N	\N	\N
164	2024-07-23 05:55:38.995114+00	2024-07-23 05:55:38.995124+00	f	\N	\N	Entidad Creada por el Gobierno Provincial	t	\N	\N	\N
165	2024-07-23 05:55:38.996294+00	2024-07-23 05:55:38.996304+00	f	\N	\N	Institución Adscrita al Ministerio de Economía y Finanzas	t	\N	\N	\N
166	2024-07-23 05:55:38.99743+00	2024-07-23 05:55:38.997439+00	f	\N	\N	Adscrita al Ministerio de Defensa	t	\N	\N	\N
167	2024-07-23 05:55:38.998938+00	2024-07-23 05:55:38.998948+00	f	\N	\N	Adscrito al Ministerio de Recursos Naturales no Renovables	t	\N	\N	\N
168	2024-07-23 05:55:39.000084+00	2024-07-23 05:55:39.000098+00	f	\N	\N	Entidad Privada	t	\N	\N	\N
\.


--
-- Data for Name: app_admin_typeorganization; Type: TABLE DATA; Schema: public; Owner: auth_user
--

COPY public.app_admin_typeorganization (id, created_at, updated_at, deleted, deleted_at, ip, name, is_active, user_created_id, user_deleted_id, user_updated_id) FROM stdin;
1	2024-07-23 05:53:12.720882+00	2024-07-23 05:53:12.720914+00	f	\N	\N	1. Organismos y dependencias de las funciones Ejecutiva, Legislativa, Judicial, Electoral y de Transparencia y Control Social	t	\N	\N	\N
2	2024-07-23 05:53:12.726434+00	2024-07-23 05:53:12.726453+00	f	\N	\N	2. Las entidades que integran el régimen autónomo descentralizado.	t	\N	\N	\N
3	2024-07-23 05:53:12.727943+00	2024-07-23 05:53:12.727958+00	f	\N	\N	3. Los organismos y entidades creados por la Constitución o la ley para el ejercicio de la potestad estatal, para la prestación de servicios públicos o para desarrollar actividades económicas asumidas por el Estado.	t	\N	\N	\N
4	2024-07-23 05:53:12.729703+00	2024-07-23 05:53:12.729717+00	f	\N	\N	4. Las personas jurídicas creadas por acto normativo de los gobiernos autónomos descentralizados para la prestación de servicios públicos.	t	\N	\N	\N
5	2024-07-23 05:53:12.73148+00	2024-07-23 05:53:12.731494+00	f	\N	\N	5. Otras Entidades	t	\N	\N	\N
\.


--
-- Data for Name: app_admin_userestablishment; Type: TABLE DATA; Schema: public; Owner: auth_user
--


--
-- Data for Name: auth_group; Type: TABLE DATA; Schema: public; Owner: auth_user
--

COPY public.auth_group (id, name) FROM stdin;
5	Superadministradora PNT DPE
1	Ciudadano
2	Carga PNT
3	Supervisora PNT
6	Administrador
4	Monitoreo DPE
\.


--
-- Data for Name: auth_group_permissions; Type: TABLE DATA; Schema: public; Owner: auth_user
--

COPY public.auth_group_permissions (id, group_id, permission_id) FROM stdin;
1	1	144
2	1	145
3	1	146
4	1	147
5	2	200
6	2	148
7	2	149
8	2	150
9	2	151
10	2	172
11	2	173
12	2	174
13	2	175
14	2	184
15	2	185
16	2	186
17	2	187
18	2	180
19	2	181
20	2	182
21	2	183
55	3	193
56	3	194
57	3	195
58	3	34
59	3	172
60	3	173
61	3	175
62	3	184
63	3	185
64	3	187
65	3	180
66	3	181
67	3	183
77	6	25
78	6	26
79	6	27
80	6	28
81	6	21
82	6	22
83	6	23
84	6	193
85	6	194
86	6	24
87	6	195
88	6	88
89	6	90
90	6	47
91	6	48
92	6	49
93	6	50
94	6	63
95	6	34
96	6	33
97	6	35
98	6	43
99	6	44
100	6	45
101	6	46
102	6	229
103	6	231
104	6	230
105	6	232
106	6	228
107	6	172
108	6	173
109	6	225
110	6	175
111	6	184
112	6	185
113	6	227
114	6	187
115	6	180
116	6	181
117	6	226
118	6	183
119	4	25
120	4	21
121	4	47
122	4	43
123	4	232
124	4	228
125	4	225
126	4	227
127	4	226
\.


--
-- Data for Name: auth_permission; Type: TABLE DATA; Schema: public; Owner: auth_user
--

COPY public.auth_permission (id, name, content_type_id, codename) FROM stdin;
1	Can add log entry	1	add_logentry
2	Can change log entry	1	change_logentry
3	Can delete log entry	1	delete_logentry
4	Can view log entry	1	view_logentry
5	Can add permission	2	add_permission
6	Can change permission	2	change_permission
7	Can delete permission	2	delete_permission
8	Can view permission	2	view_permission
9	Can add group	3	add_group
10	Can change group	3	change_group
11	Can delete group	3	delete_group
12	Can view group	3	view_group
13	Can add content type	4	add_contenttype
14	Can change content type	4	change_contenttype
15	Can delete content type	4	delete_contenttype
16	Can view content type	4	view_contenttype
17	Can add session	5	add_session
18	Can change session	5	change_session
19	Can delete session	5	delete_session
20	Can view session	5	view_session
21	Can add user	6	add_user
22	Can change user	6	change_user
23	Can delete user	6	delete_user
24	Can view user	6	view_user
25	Can add role	7	add_role
26	Can change role	7	change_role
27	Can delete role	7	delete_role
28	Can view role	7	view_role
29	Can add Datos Personales	8	add_person
30	Can change Datos Personales	8	change_person
31	Can delete Datos Personales	8	delete_person
32	Can view Datos Personales	8	view_person
33	Puede crear usuario ciudadano	3	add_user_ciudadano
34	Puede crear usuario Carga PNT	3	add_user_carga_pnt
35	Puede crear usuario Supervisora PNT	3	add_user_supervisora_pnt
36	Puede crear usuario Monitoreo DPE	3	add_user_monitoreo_dpe
37	Puede crear usuario Supervisora PNT DPE	3	add_user_monitoreo_pnt_dpe
38	Puede ver usuarios internos	3	view_users_internal
39	Can add Password Reset Token	9	add_resetpasswordtoken
40	Can change Password Reset Token	9	change_resetpasswordtoken
41	Can delete Password Reset Token	9	delete_resetpasswordtoken
42	Can view Password Reset Token	9	view_resetpasswordtoken
43	Can add user	10	add_user
44	Can change user	10	change_user
45	Can delete user	10	delete_user
46	Can view user	10	view_user
47	Can add Institución	11	add_establishment
48	Can change Institución	11	change_establishment
49	Can delete Institución	11	delete_establishment
50	Can view Institución	11	view_establishment
51	Can add Comité de Transparencia	12	add_lawenforcement
52	Can change Comité de Transparencia	12	change_lawenforcement
53	Can delete Comité de Transparencia	12	delete_lawenforcement
54	Can view Comité de Transparencia	12	view_lawenforcement
55	Can add Acceso a la Información	13	add_accesstoinformation
56	Can change Acceso a la Información	13	change_accesstoinformation
57	Can delete Acceso a la Información	13	delete_accesstoinformation
58	Can view Acceso a la Información	13	view_accesstoinformation
59	Can add Campo de Formulario	14	add_formfields
60	Can change Campo de Formulario	14	change_formfields
61	Can delete Campo de Formulario	14	delete_formfields
62	Can view Campo de Formulario	14	view_formfields
63	Can add Area de Pedagogia	15	add_pedagogyarea
64	Can change Area de Pedagogia	15	change_pedagogyarea
65	Can delete Area de Pedagogia	15	delete_pedagogyarea
66	Can view Area de Pedagogia	15	view_pedagogyarea
67	Can add Video Tutorial	16	add_tutorialvideo
68	Can change Video Tutorial	16	change_tutorialvideo
69	Can delete Video Tutorial	16	delete_tutorialvideo
70	Can view Video Tutorial	16	view_tutorialvideo
71	Can add Documento Normativo	17	add_normativedocument
72	Can change Documento Normativo	17	change_normativedocument
73	Can delete Documento Normativo	17	delete_normativedocument
74	Can view Documento Normativo	17	view_normativedocument
75	Can add Pregunta Frecuente	18	add_frequentlyaskedquestions
76	Can change Pregunta Frecuente	18	change_frequentlyaskedquestions
77	Can delete Pregunta Frecuente	18	delete_frequentlyaskedquestions
78	Can view Pregunta Frecuente	18	view_frequentlyaskedquestions
79	Can add Usuario por Institución	19	add_userestablishment
80	Can change Usuario por Institución	19	change_userestablishment
81	Can delete Usuario por Institución	19	delete_userestablishment
82	Can view Usuario por Institución	19	view_userestablishment
83	Can add Email	20	add_email
84	Can change Email	20	change_email
85	Can delete Email	20	delete_email
86	Can view Email	20	view_email
87	Can add Configuración	21	add_configuration
88	Can change Configuración	21	change_configuration
89	Can delete Configuración	21	delete_configuration
90	Can view Configuración	21	view_configuration
91	Puede ver configuración	21	can_view_configuration
92	Can add Tipo de Organización	22	add_typeorganization
93	Can change Tipo de Organización	22	change_typeorganization
94	Can delete Tipo de Organización	22	delete_typeorganization
95	Can view Tipo de Organización	22	view_typeorganization
96	Can add Tipo de Institución	23	add_typeinstitution
97	Can change Tipo de Institución	23	change_typeinstitution
98	Can delete Tipo de Institución	23	delete_typeinstitution
99	Can view Tipo de Institución	23	view_typeinstitution
100	Can add Función de Organización	24	add_functionorganization
101	Can change Función de Organización	24	change_functionorganization
102	Can delete Función de Organización	24	delete_functionorganization
103	Can view Función de Organización	24	view_functionorganization
104	Can add Institución	25	add_establishmentextended
105	Can change Institución	25	change_establishmentextended
106	Can delete Institución	25	delete_establishmentextended
107	Can view Institución	25	view_establishmentextended
108	Can add Publicación	26	add_publication
109	Can change Publicación	26	change_publication
110	Can delete Publicación	26	delete_publication
111	Can view Publicación	26	view_publication
112	Can add Tipo de Publicación	27	add_typepublication
113	Can change Tipo de Publicación	27	change_typepublication
114	Can delete Tipo de Publicación	27	delete_typepublication
115	Can view Tipo de Publicación	27	view_typepublication
116	Can add BaseModel	28	add_typeformats
117	Can change BaseModel	28	change_typeformats
118	Can delete BaseModel	28	delete_typeformats
119	Can view BaseModel	28	view_typeformats
120	Can add Etiqueta	29	add_tag
121	Can change Etiqueta	29	change_tag
122	Can delete Etiqueta	29	delete_tag
123	Can view Etiqueta	29	view_tag
124	Can add Archivo Publicación	30	add_filepublication
125	Can change Archivo Publicación	30	change_filepublication
126	Can delete Archivo Publicación	30	delete_filepublication
127	Can view Archivo Publicación	30	view_filepublication
128	Can add Activity Log	31	add_activitylog
129	Can change Activity Log	31	change_activitylog
130	Can delete Activity Log	31	delete_activitylog
131	Can view Activity Log	31	view_activitylog
132	Can add user establishment extended	32	add_userestablishmentextended
133	Can change user establishment extended	32	change_userestablishmentextended
134	Can delete user establishment extended	32	delete_userestablishmentextended
135	Can view user establishment extended	32	view_userestablishmentextended
136	Can add Adjunto	33	add_attachment
137	Can change Adjunto	33	change_attachment
138	Can delete Adjunto	33	delete_attachment
139	Can view Adjunto	33	view_attachment
140	Can add Categoría	34	add_category
141	Can change Categoría	34	change_category
142	Can delete Categoría	34	delete_category
143	Can view Categoría	34	view_category
144	Can add Solicitud	35	add_solicity
145	Can change Solicitud	35	change_solicity
146	Can delete Solicitud	35	delete_solicity
147	Can view Solicitud	35	view_solicity
148	Can add Respuesta de Solicitud	36	add_solicityresponse
149	Can change Respuesta de Solicitud	36	change_solicityresponse
150	Can delete Respuesta de Solicitud	36	delete_solicityresponse
151	Can view Respuesta de Solicitud	36	view_solicityresponse
152	Can add Insistencia	37	add_insistency
153	Can change Insistencia	37	change_insistency
154	Can delete Insistencia	37	delete_insistency
155	Can view Insistencia	37	view_insistency
156	Can add Prórroga	38	add_extension
157	Can change Prórroga	38	change_extension
158	Can delete Prórroga	38	delete_extension
159	Can view Prórroga	38	view_extension
160	Can add Columna de Plantilla de Archivo	39	add_columnfile
161	Can change Columna de Plantilla de Archivo	39	change_columnfile
162	Can delete Columna de Plantilla de Archivo	39	delete_columnfile
163	Can view Columna de Plantilla de Archivo	39	view_columnfile
164	Can add Plantilla de Archivo	40	add_templatefile
165	Can change Plantilla de Archivo	40	change_templatefile
166	Can delete Plantilla de Archivo	40	delete_templatefile
167	Can view Plantilla de Archivo	40	view_templatefile
168	Can add Numeral	41	add_numeral
169	Can change Numeral	41	change_numeral
170	Can delete Numeral	41	delete_numeral
171	Can view Numeral	41	view_numeral
172	Can add Transparencia Activa	42	add_transparencyactive
173	Can change Transparencia Activa	42	change_transparencyactive
174	Can delete Transparencia Activa	42	delete_transparencyactive
175	Can view Transparencia Activa	42	view_transparencyactive
176	Can add Numeral de Establecimiento	43	add_establishmentnumeral
177	Can change Numeral de Establecimiento	43	change_establishmentnumeral
178	Can delete Numeral de Establecimiento	43	delete_establishmentnumeral
179	Can view Numeral de Establecimiento	43	view_establishmentnumeral
180	Can add Transparencia Focalizada	44	add_transparencyfocal
181	Can change Transparencia Focalizada	44	change_transparencyfocal
182	Can delete Transparencia Focalizada	44	delete_transparencyfocal
183	Can view Transparencia Focalizada	44	view_transparencyfocal
184	Can add Transparencia Colaborativa	45	add_transparencycolab
185	Can change Transparencia Colaborativa	45	change_transparencycolab
186	Can delete Transparencia Colaborativa	45	delete_transparencycolab
187	Can view Transparencia Colaborativa	45	view_transparencycolab
188	Can add Historial de Solicitud	46	add_timelinesolicity
189	Can change Historial de Solicitud	46	change_timelinesolicity
190	Can delete Historial de Solicitud	46	delete_timelinesolicity
191	Can view Historial de Solicitud	46	view_timelinesolicity
192	Puede agregar usuarios de entidad	6	add_user_establishment
193	Puede eliminar usuarios de entidad	6	delete_user_establishment
194	Puede actualizar usuarios de entidad	6	update_user_establishment
195	Puede ver usuarios de entidad	6	view_user_establishment
196	Puede ver informacion de institución	11	view_establishment_internal
197	Puede agregar informacion de institución	11	add_establishment_internal
198	Puede eliminar informacion de institución	11	delete_establishment_internal
199	Puede actualizar informacion de institución	11	update_establishment_internal
200	Puede agregar solicitudes manuales	36	add_manual_solicity
201	Can add crontab	47	add_crontabschedule
202	Can change crontab	47	change_crontabschedule
203	Can delete crontab	47	delete_crontabschedule
204	Can view crontab	47	view_crontabschedule
205	Can add interval	48	add_intervalschedule
206	Can change interval	48	change_intervalschedule
207	Can delete interval	48	delete_intervalschedule
208	Can view interval	48	view_intervalschedule
209	Can add periodic task	49	add_periodictask
210	Can change periodic task	49	change_periodictask
211	Can delete periodic task	49	delete_periodictask
212	Can view periodic task	49	view_periodictask
213	Can add periodic tasks	50	add_periodictasks
214	Can change periodic tasks	50	change_periodictasks
215	Can delete periodic tasks	50	delete_periodictasks
216	Can view periodic tasks	50	view_periodictasks
217	Can add solar event	51	add_solarschedule
218	Can change solar event	51	change_solarschedule
219	Can delete solar event	51	delete_solarschedule
220	Can view solar event	51	view_solarschedule
221	Can add clocked	52	add_clockedschedule
222	Can change clocked	52	change_clockedschedule
223	Can delete clocked	52	delete_clockedschedule
224	Can view clocked	52	view_clockedschedule
225	Ver Transparencias de Todas las entidades	42	view_all_transparencyactive
226	Ver Transparencias de Todas las entidades	44	view_all_transparencyfocal
227	Ver Transparencias de Todas las entidades	45	view_all_transparencycollab
228	Ver Solicitudes de Todas las entidades	35	view_all_solicities
229	Ver Estado de cumplimiento de Todas las entidades	25	view_all_compliancestatus
230	Indicadores Generales Ciudadano	25	view_general_indicators
231	Indicadores de Entidad	25	view_entity_indicators
232	Indicadores de Monitoreo	25	view_monitoring_indicators
\.


--
-- Data for Name: auth_person; Type: TABLE DATA; Schema: public; Owner: auth_user
--

COPY public.auth_person (id, first_name, last_name, identification, phone, address, city, country, province, user_id, accept_terms, disability, gender, job, race, age_range) FROM stdin;
1	Configuracion	Configuracion	0999999999	0959999999	av publica	GUAYAQUIL	Ecuador	GUAYAS	1	t	f	masculino	ADMINISTRADOR	\N	\N
2	Anderson	Sinaluisa		0959998855	\N		\N		2	t	f	Masculino	\N	Mestiza	
3	Anderson	Sinaluisa	0953227857				Ecuador		3	t	f	\N	\N		
4	Roberto	Esteves	0917583791				Ecuador		4	t	f	\N	\N		
53	Publicador	13	0999999999				Ecuador		56	t	f	\N	\N		
5	Roberto	Esteves		0991726077	\N		\N		5	t	f	Masculino	\N	Mestiza	
6	Anderson	Sinaluisa		0959998855	\N		\N		6	t	f	Masculino	\N	Mestiza	
54	Publicador	14	0999999999				Ecuador		57	t	f	\N	\N		
7	Estefania	MOntalvo		0983608272	\N		\N		7	t	f	Femenino	\N	Mestiza	
8	MARGARITA	COLLANTES		0998473217	\N		\N		8	t	f	Femenino	\N	Pueblo afrodescendiente	
9	PABLO	ARIAS		000000	\N		\N		9	t	f	Masculino	\N	Mestiza	
10	Diego Andres	Quezada Gomez		0983459212	\N		\N		10	t	f	Masculino	\N	Mestiza	
11	Boris	Castro		0984304377	\N		\N		11	t	f	Masculino	\N	Mestiza	
12	Ana	Cisneros		0984120068	\N		\N		12	t	f	Femenino	\N	Mestiza	
13	Melanie Alexandra	Pincay Fraco		0986762373	\N		\N		13	t	f	Femenino	\N	Mestiza	
14	CRISTIAN PATRICIO	DIAZ GOMEZ		22492098	\N		\N		14	t	f	Masculino	\N	Mestiza	
15	Juana Elena	Lopez Ehmig		0992603525	\N		\N		15	t	f	Femenino	\N	Blanca	
16	JAIME	VILLARREAL		0983050212	\N		\N		16	t	f	Masculino	\N	Pueblo montubio	
17	Patricia	Hidalgo		0998005988	\N		\N		17	t	f	Femenino	\N	Mestiza	
18	Jose Luis	Pesantez Cuesta		0984488473	\N		\N		18	t	f	Masculino	\N	Mestiza	
19	NICOLE ISABEL	ARCENTALES NARANJO		0967222151	\N		\N		19	t	f	Femenino	\N	Mestiza	
20	JUAN	CASTRO		0997265050	\N		\N		20	t	f	Masculino	\N	Mestiza	
21	Ana William	Alava Gandara		0939828394	\N		\N		21	t	f	Otro	\N	Mestiza	
22	Madelayne Elizabeth	Hidalgo Barros		0978682698	\N		\N		22	t	f	Femenino	\N	Mestiza	
23	Patricia	Hidalgo		0998005988	\N		\N		23	t	f	Femenino	\N	Mestiza	
24	Olga Norma	Vargas Alvarado		0995080281	\N		\N		24	t	f	Femenino	\N	Pueblo o nacionalidadades indígenas	
25	Alfredo José	López Delgado		0998234980	\N		\N		25	t	f	Masculino	\N	Mestiza	
26	JAKELINE ISBELLA	QUINGA TIPAN		0998755617	\N		\N		26	t	f	Femenino	\N	Mestiza	
27	Patricia	Hidalgo		0998005988	\N		\N		27	t	f	Femenino	\N	Mestiza	
28	David	Sánchez		0998867718	\N		\N		28	t	f	Masculino	\N	Mestiza	
29	Ramiro	Morales		2525726	\N		\N		29	t	f	Masculino	\N	Mestiza	
30	Patricia	Hidalgo		0998005988	\N		\N		30	t	f	Femenino	\N	Mestiza	
31	Ricardo Sebastian	Cordova Guerra		0984645496	\N		\N		31	t	f	Masculino	\N	Mestiza	
32	Jacqueline	Navarrete		0967738439	\N		\N		32	t	f	Femenino	\N	Mestiza	
33	LENIN ABDON	FALCON GARZON		0998789598	\N		\N		33	t	f	Masculino	\N	Mestiza	
34	Priscila	Villarreal		0988250706	\N		\N		35	t	f	Femenino	\N	Mestiza	
35	william	Gándara		0987291434	\N		\N		38	t	f	Masculino	\N	Mestiza	
36	FREDDY WILMER	VILLEGAS ALAVA		0998765443	\N		\N		39	t	f	Masculino	\N	Mestiza	
37	LENIN ABDON	FALCON GARZON		0998789598	\N		\N		40	t	f	Masculino	\N	Mestiza	
38	Juan	Baldeon		0996527877	\N		\N		41	t	f	Masculino	\N	Mestiza	
39	pedro vicente	Castañeda Cabascango		0978512645	\N		\N		42	t	f	Masculino	\N	Pueblo o nacionalidadades indígenas	
40	Anderson	Sinaluisa	0953227857				Ecuador		43	t	f	\N	\N		
41	Publicador	1	0999999999				Ecuador		44	t	f	\N	\N		
42	Publicador	2	0999999999				Ecuador		45	t	f	\N	\N		
43	Publicador	3	0999999999				Ecuador		46	t	f	\N	\N		
44	Publicador	4	0999999999				Ecuador		47	t	f	\N	\N		
45	Publicador	5	0999999999				Ecuador		48	t	f	\N	\N		
46	Publicador	6	0999999999				Ecuador		49	t	f	\N	\N		
47	Publicador	7	0999999999				Ecuador		50	t	f	\N	\N		
48	Publicador	8	0999999999				Ecuador		51	t	f	\N	\N		
49	Publicador	9	0999999999				Ecuador		52	t	f	\N	\N		
50	Publicador	10	0999999999				Ecuador		53	t	f	\N	\N		
51	Publicador	11	0999999999				Ecuador		54	t	f	\N	\N		
52	Publicador	12	0999999999				Ecuador		55	t	f	\N	\N		
55	Publicador	15	0999999999				Ecuador		58	t	f	\N	\N		
56	Publicador	16	0999999999				Ecuador		59	t	f	\N	\N		
57	Publicador	17	0999999999				Ecuador		60	t	f	\N	\N		
58	Publicador	18	0999999999				Ecuador		61	t	f	\N	\N		
59	Publicador	19	0999999999				Ecuador		62	t	f	\N	\N		
60	Publicador	20	0999999999				Ecuador		63	t	f	\N	\N		
61	Publicador	21	0999999999				Ecuador		64	t	f	\N	\N		
62	Publicador	22	0999999999				Ecuador		65	t	f	\N	\N		
63	Publicador	23	0999999999				Ecuador		66	t	f	\N	\N		
64	Publicador	24	0999999999				Ecuador		67	t	f	\N	\N		
65	Publicador	25	0999999999				Ecuador		68	t	f	\N	\N		
66	Publicador	26	0999999999				Ecuador		69	t	f	\N	\N		
67	Publicador	27	0999999999				Ecuador		70	t	f	\N	\N		
68	Publicador	28	0999999999				Ecuador		71	t	f	\N	\N		
69	Publicador	29	0999999999				Ecuador		72	t	f	\N	\N		
70	Publicador	30	0999999999				Ecuador		73	t	f	\N	\N		
71	Publicador	31	0999999999				Ecuador		74	t	f	\N	\N		
72	Publicador	32	0999999999				Ecuador		75	t	f	\N	\N		
73	Publicador	33	0999999999				Ecuador		76	t	f	\N	\N		
74	Publicador	34	0999999999				Ecuador		77	t	f	\N	\N		
75	Publicador	35	0999999999				Ecuador		78	t	f	\N	\N		
101	Johana Patricia	Castellanos Toscano	1723378889				Ecuador		104	t	f	\N	\N		
76	Publicador	36	0999999999				Ecuador		79	t	f	\N	\N		
77	Publicador	37	0999999999				Ecuador		80	t	f	\N	\N		
102	Johana Patricia	Castellanos Toscano	1723378889				Ecuador		105	t	f	\N	\N		
78	Publicador	38	0999999999				Ecuador		81	t	f	\N	\N		
124	Isabel Victoria	Andrade Araujo	1803006582				Ecuador		127	t	f	\N	\N		
79	Publicador	39	0999999999				Ecuador		82	t	f	\N	\N		
103	Jenny Cecilia	Cañar Cueva	1900311349				Ecuador		106	t	f	\N	\N		
80	Publicador	40	0999999999				Ecuador		83	t	f	\N	\N		
81	ALEJANDRO	CHUQUIRALAO		0999578159	\N		\N		84	t	f	Masculino	\N	Mestiza	
104	Edwin	Pilco	0603833187				Ecuador		107	t	f	\N	\N		
105	CARMITA	RODRIGUEZ	1708926496				Ecuador		108	t	f	\N	\N		
106	patricio	alvarez	1711308781				Ecuador		109	t	f	\N	\N		
83	Roberto	Esteves	0917583791				Ecuador		86	t	f	\N	\N		
84	Anderson	Sinaluisa	0953227857				Ecuador		87	t	f	\N	\N		
82	monitoreo	monitoreo	0953227857				Ecuador		85	t	f	\N	\N		
107	bolivar	quispe	1802145506				Ecuador		110	t	f	\N	\N		
85	Gabriela	Vivanco	1717763096				Ecuador		88	t	f	\N	\N		
86	Gabriela	Vivanco	1717763096				Ecuador		89	t	f	\N	\N		
108	Jenny Cecilia	Cañar Cueva	1900311349				Ecuador		111	t	f	\N	\N		
87	Patricio	Alvarez	1711308781				Ecuador		90	t	f	\N	\N		
88	Patricio	Alvarez	1711308781				Ecuador		91	t	f	\N	\N		
109	CARMITA	RODRIGUEZ	1708926496				Ecuador		112	t	f	\N	\N		
89	BOLIVAR	QUISPE	1802145506				Ecuador		92	t	f	\N	\N		
90	Angelica	Viscaino	1719067306				Ecuador		93	t	f	\N	\N		
91	Manuel Estuardo	Solano Moreno		091500257	\N		\N		94	t	f	Masculino	\N	Mestiza	
110	Neithan Iván	Bravo Andrade	1712747839				Ecuador		113	t	f	\N	\N		
92	Anabel	Aguilar	1719067306				Ecuador		95	t	f	\N	\N		
93	BOLIVAR	QUISPE	1802145506				Ecuador		96	t	f	\N	\N		
111	Martin Sebastián	Sotomayor Vélez	1721982575				Ecuador		114	t	f	\N	\N		
94	Santiago	Moscoso	0103834016				Ecuador		97	t	f	\N	\N		
95	Genny del Pilar	Vélez Ponce	1306115468				Ecuador		98	t	f	\N	\N		
112	CARMITA	RODRIGUEZ	1708926496				Ecuador		115	t	f	\N	\N		
96	Edwin	Pilco	0603833187				Ecuador		99	t	f	\N	\N		
113	Araid Victoria	Bravo Andrade	1751938992				Ecuador		116	t	f	\N	\N		
98	Gabriel Santiago	Moscoso González	0103834016				Ecuador		101	t	f	\N	\N		
99	Genny del Pilar	Vélez Ponce	1306115468				Ecuador		102	t	f	\N	\N		
114	CARMITA	RODRIGUEZ	1708926496				Ecuador		117	t	f	\N	\N		
100	Edwin	Pilco	0603833187				Ecuador		103	t	f	\N	\N		
115	Jorge Esteban	Poma Almeida	1751939040				Ecuador		118	t	f	\N	\N		
116	Eduardo	Córdova Sánchez	1711887487				Ecuador		119	t	f	\N	\N		
117	luis	barragan	1707083554				Ecuador		120	t	f	\N	\N		
118	Carla	Cisneros	1713167714				Ecuador		121	t	f	\N	\N		
119	pedro	almeida	1707083554				Ecuador		122	t	f	\N	\N		
120	Jenny	Cañar	1900311349				Ecuador		123	t	f	\N	\N		
97	Cristina	Llumipanta	1719067306				Ecuador		100	t	f	\N	\N		
121	luis	barragan	1719251488				Ecuador		124	t	f	\N	\N		
122	Johana Patricia	Castellanos Toscano	1723378889				Ecuador		125	t	f	\N	\N		
123	Carlos Julio	Vásconez Alban	1803006582				Ecuador		126	t	f	\N	\N		
125	Geovanny Armando	López Ramos		0983324148	\N		\N		128	t	f	Masculino	\N	Mestiza	
126	Juan	Perez		23930303	\N		\N		129	t	f	Masculino	\N	Mestiza	
127	Maria	Sanchez	1735487579				Ecuador		130	t	f	\N	\N		
128	Roberto	Mendoza	1356789865				Ecuador		131	t	f	\N	\N		
129	Graciela	Cornejo	0703269217				Ecuador		132	t	f	\N	\N		
130	Yessi	Poveda		0000000	\N		\N		133	t	f	Femenino	\N	Mestiza	
\.


--
-- Data for Name: auth_user; Type: TABLE DATA; Schema: public; Owner: auth_user
--

COPY public.auth_user (id, password, last_login, is_superuser, username, first_name, last_name, email, is_staff, is_active, date_joined, created_at, updated_at, deleted, deleted_at, ip) FROM stdin;
1	pbkdf2_sha256$600000$SMwY6jDvWaZS43UjJ4ENe0$TsIHmk7ieyOgwPBM2TUnhc+n93alh+VlUchv2NduaGg=	2024-01-02 17:41:54.625+00	t	superadmin@pnt.com	Super	Administrador	superadmin@pnt.com	t	t	2023-12-21 16:25:03.247+00	2023-12-21 16:25:04.733+00	2023-12-21 16:25:04.733+00	f	\N	\N
4	pbkdf2_sha256$600000$t64uM3DqRtnICpPoqlVboy$ktZblDDE032F/EsO/rTw6W8zeB9ZvYB9oydjdla4Ov0=	\N	f	resteves_CARGA	Roberto	Esteves	hola@masappec.com	f	t	2024-07-23 14:30:21.612978+00	2024-07-23 14:30:22.148642+00	2024-07-23 14:30:22.148653+00	f	\N	\N
16	pbkdf2_sha256$600000$vH6sqsZ1NrQNtym7EWNdkO$l3H+l13sL2cxy4T0ZNO3pQ9EajF8GWglR26DLztcF6Y=	\N	f	jaime138413	JAIME	VILLARREAL	villarreal138413@gmail.com	f	t	2024-07-25 00:00:00+00	2024-07-25 00:00:00+00	2024-07-25 15:45:46.751738+00	f	\N	\N
5	pbkdf2_sha256$600000$oX4Z8Fk1aIifq3z2wLSVqt$SotrcLeHgHgKXJ02IC0bc7wW/4r0+oKtNLh+XwX7dSA=	\N	f	resteves_ciudadano	Roberto	Esteves	info@robertoesteves.com	f	t	2024-07-24 00:00:00+00	2024-07-24 00:00:00+00	2024-07-24 15:31:54.367305+00	f	\N	\N
6	pbkdf2_sha256$600000$2USv0iqbJgidxbtNMyCuwU$aV/UyMii5LJssbNbhFg4gT1tqnUnnNEmEiCl2HUvPCY=	\N	f	anderson_ciudadano1	Anderson	Sinaluisa	bapaco2763@stikezz.com	f	t	2024-07-24 00:00:00+00	2024-07-24 00:00:00+00	2024-07-24 16:51:26.855973+00	f	\N	\N
7	pbkdf2_sha256$600000$fJR3kRC0I6uY0BV2bzPbSY$EiJzYJ8ujlxA4MNVRVwC4LBqHbEVT/pwgS5CiBHDyK4=	\N	f	emc	Estefania	MOntalvo	estefaniamontalvocozar@gmail.com	f	t	2024-07-25 00:00:00+00	2024-07-25 00:00:00+00	2024-07-25 15:37:34.525303+00	f	\N	\N
11	pbkdf2_sha256$600000$qUzFvr0c5OyVTEaeLKGMFm$zw30zaoUFC7EK+layH7fthV025TGg2qU+O0YdThCe6I=	\N	f	bcastro	Boris	Castro	boris_castro_a@hotmail.com	f	t	2024-07-25 00:00:00+00	2024-07-25 00:00:00+00	2024-07-25 15:41:35.254239+00	f	\N	\N
12	pbkdf2_sha256$600000$HkxeKdd3zNILPHKjjjcRoK$vdvViuaAOwLKvWIUNuYdaTJD0cv5VBzB7j4oYOQlSMY=	\N	f	1714143730	Ana	Cisneros	anita.c.82mau@gmail.com	f	t	2024-07-25 00:00:00+00	2024-07-25 00:00:00+00	2024-07-25 00:00:00+00	f	\N	\N
8	pbkdf2_sha256$600000$zsBhUdlbBK7mgc5BCuvCkR$gmmZ2IcLEdEmbgzu67v5nxu4jwwzn6Kwj17zncLNiCg=	\N	f	1964	MARGARITA	COLLANTES	margcollant@gmail.com	f	t	2024-07-25 00:00:00+00	2024-07-25 00:00:00+00	2024-07-25 00:00:00+00	f	\N	\N
9	pbkdf2_sha256$600000$QDijqYiT7s9d8IzecdsNsC$3ljoHJleITULqDhbetZcK5sx0Q/xdiSobOYjTSx+TPo=	\N	f	PGARIAS	PABLO	ARIAS	pablo.arias@seps.gob.ec	f	t	2024-07-25 00:00:00+00	2024-07-25 00:00:00+00	2024-07-25 00:00:00+00	f	\N	\N
10	pbkdf2_sha256$600000$kn7LSv5U3ZXbUH15sFaOzd$fkMthdsiQn9jNmTJaV3j6cFsXKbDqKesXFfkc8a05Is=	\N	f	dquezada	Diego Andres	Quezada Gomez	dieguin88@yahoo.com	f	t	2024-07-25 00:00:00+00	2024-07-25 00:00:00+00	2024-07-25 00:00:00+00	f	\N	\N
14	pbkdf2_sha256$600000$OyX2DOmj6UACs78QJWSTCk$FLT1KH/qd9baETYswRm3rt45BPPqAFUv+ao6GKGi6+M=	\N	f	CDIAZ	CRISTIAN PATRICIO	DIAZ GOMEZ	cdiaz@cpccs.gob.ec	f	t	2024-07-25 00:00:00+00	2024-07-25 00:00:00+00	2024-07-25 00:00:00+00	f	\N	\N
20	pbkdf2_sha256$600000$l4lFTjcwroRoVTqZCGXZ8e$hbciSnedqniJtSFa3Tnre7W3j5d+9bOoF5jL2FItsA4=	\N	f	JCASTROSB	JUAN	CASTRO	JCASTRO@SUPERBANCOS.GOB.EC	f	t	2024-07-25 00:00:00+00	2024-07-25 00:00:00+00	2024-07-25 15:46:21.923721+00	f	\N	\N
22	pbkdf2_sha256$600000$160IFR3GsH8oWQiB4ZHbHk$cXpunYJAr7PqKrKNN8Q8F0MMsPvWXrFSy4potNaZilY=	\N	f	mhidalgo	Madelayne Elizabeth	Hidalgo Barros	hidalgomadeffy@gmail.com	f	t	2024-07-25 00:00:00+00	2024-07-25 00:00:00+00	2024-07-25 00:00:00+00	f	\N	\N
15	pbkdf2_sha256$600000$6mTDJPMCZI0jT0FtvnISc1$7piqryw8v05Fr+90tLKJ7bQiTIATIDNmK2kn1oUQk5A=	\N	f	elenaehmig	Juana Elena	Lopez Ehmig	jelopeze@uce.edu.ec	f	t	2024-07-25 00:00:00+00	2024-07-25 00:00:00+00	2024-07-25 00:00:00+00	f	\N	\N
18	pbkdf2_sha256$600000$7OJkSY3n29CbZQKVWEw3ES$N8v18B194gzdFVtP2/bpxBxAOofgJwBu4U2PLgT56XU=	\N	f	jpesantez	Jose Luis	Pesantez Cuesta	jpesantez@supérbancos.gob.ec	f	t	2024-07-25 00:00:00+00	2024-07-25 00:00:00+00	2024-07-25 00:00:00+00	f	\N	\N
17	pbkdf2_sha256$600000$rPmYjE7M4OFwPcyoLAvs4D$jR3E2UKmkSjltCrOm0cE32hN2gYhP8TnSMBdXJpB9Ao=	\N	f	patriciahidalgoa	Patricia	Hidalgo	patricia.hidalgoa@ute.edu.ec	f	t	2024-07-25 00:00:00+00	2024-07-25 00:00:00+00	2024-07-25 00:00:00+00	f	\N	\N
19	pbkdf2_sha256$600000$zGCp0dzGc1HOMgjSr0BgGC$Unjbvzep4dq7BJJoi9dXet4n74Bd4BsA7F0qvR6+GVo=	\N	f	NICOLE_ISA_UCE	NICOLE ISABEL	ARCENTALES NARANJO	niarcentales@uce.edu.ec	f	t	2024-07-25 00:00:00+00	2024-07-25 00:00:00+00	2024-07-25 00:00:00+00	f	\N	\N
21	pbkdf2_sha256$600000$yWwlr90XdksD4apBxprSXn$uVage+RRTkI02S+Fn1HSDiigVQO7tsjvXaQXW9iVTPo=	\N	f	anaywill	Ana William	Alava Gandara	aalava@participacionciudadana.org	f	t	2024-07-25 00:00:00+00	2024-07-25 00:00:00+00	2024-07-25 00:00:00+00	f	\N	\N
13	pbkdf2_sha256$600000$l3HGfDseBqnRX0neUwM1Zr$VAmT4YD+ahFeo3JH3uXxgl/7P7+Ta10SKebzlGviRLg=	\N	f	Melanie Pincay	Melanie Alexandra	Pincay Fraco	malaniepincayfranco@gmail.com	f	t	2024-07-25 00:00:00+00	2024-07-25 00:00:00+00	2024-07-25 00:00:00+00	f	\N	\N
25	pbkdf2_sha256$600000$B0kCm21NcDwEDSdg2n7PBg$/3Iwl/j2njA1ZrqeAVticKjG4LJZHg2/E13vLuj/93g=	\N	f	Aalfredo83	Alfredo José	López Delgado	abogados.procesos@gmail.com	f	t	2024-07-25 00:00:00+00	2024-07-25 00:00:00+00	2024-07-25 00:00:00+00	f	\N	\N
24	pbkdf2_sha256$600000$jsHrkV3AUrlUArXwZ3DtIc$AT+ACJYJCT7GU6208APVN6b2UbbLp1SvVh4+eJanoes=	\N	f	1500278062	Olga Norma	Vargas Alvarado	normavargas964@hotmail.com	f	t	2024-07-25 00:00:00+00	2024-07-25 00:00:00+00	2024-07-25 15:50:25.894827+00	f	\N	\N
27	pbkdf2_sha256$600000$xjqjLOHTXr2Gu6Lhtu6elN$STJRRBDZQ0o4V24VjR7vwW19telpvvun89sQqGlJOu0=	\N	f	patrihidalgoa	Patricia	Hidalgo	lizethpauker@gmail.com	f	t	2024-07-25 00:00:00+00	2024-07-25 00:00:00+00	2024-07-25 00:00:00+00	f	\N	\N
23	pbkdf2_sha256$600000$cfHp86W5WSiMvVs6y3fT3r$katvgKMlucHEIFJj5plSVrhgYsJrg6cNABxs7x9LOT4=	\N	f	phidalgoa	Patricia	Hidalgo	patrihidal@yahoo.com	f	t	2024-07-25 00:00:00+00	2024-07-25 00:00:00+00	2024-07-25 00:00:00+00	f	\N	\N
26	pbkdf2_sha256$600000$xsJbC1HmTi6FvGup811M3e$TY438BOsgLZrrpHZuf2YqaUP7JwVwL8QGHQ0SG7r0xs=	\N	f	jake.quinga	JAKELINE ISBELLA	QUINGA TIPAN	jakeis_1007@hotmail.com	f	t	2024-07-25 00:00:00+00	2024-07-25 00:00:00+00	2024-07-25 00:00:00+00	f	\N	\N
29	pbkdf2_sha256$600000$fNsDCZfsWpIzeO7qY2ew6d$XDtuHWWYiTKD/mkDz+6pZD9DxsIsl19nyAiGN9+odcc=	\N	f	rmorales66	Ramiro	Morales	ramiro.morales@quitohonesto.gob.ec	f	t	2024-07-25 00:00:00+00	2024-07-25 00:00:00+00	2024-07-25 00:00:00+00	f	\N	\N
28	pbkdf2_sha256$600000$FxMOzYXsg6fYTusNXjjSax$Kb5t6qKVLFwlTMVyEtGGK/jAAP29BGkoPuCKd01cYvQ=	\N	f	davidsa	David	Sánchez	davidsa3220@gmail.com	f	t	2024-07-25 00:00:00+00	2024-07-25 00:00:00+00	2024-07-25 00:00:00+00	f	\N	\N
30	pbkdf2_sha256$600000$R3H7Bj8QP8afiiAefu2Awx$z+JA37RNmvonu7pGBZABR/txK7Y5K5DdzyWt3dIuoAQ=	\N	f	1704593498	Patricia	Hidalgo	lizeth_pauker@hotmail.com	f	t	2024-07-25 00:00:00+00	2024-07-25 00:00:00+00	2024-07-25 00:00:00+00	f	\N	\N
31	pbkdf2_sha256$600000$Qj9ZfiwI3Nx1x0oiKwlMun$bFIx/BqBkRtGn5/n9hgMkY8yvE6K4RNCIHaZ1doizOQ=	\N	f	rcordova	Ricardo Sebastian	Cordova Guerra	sebas_2117_1@hotmail.com	f	t	2024-07-25 00:00:00+00	2024-07-25 00:00:00+00	2024-07-25 00:00:00+00	f	\N	\N
32	pbkdf2_sha256$600000$84kSQvI1VvgvpQtBsGYzxL$Rodqqpj1dyCvZ8uETTUx2wQlzsdqBoe9A8hTlvSEO8g=	\N	f	jakynavarrete	Jacqueline	Navarrete	jacqueline.navarrete@conagopare.gob.ec	f	t	2024-07-25 00:00:00+00	2024-07-25 00:00:00+00	2024-07-25 00:00:00+00	f	\N	\N
2	pbkdf2_sha256$600000$DZT4k8oCSIvh9XgrwSO2NX$f2nt53a+3czFLwGv5B+JNpbvP66T9bFXA2sVnTXHzlk=	\N	f	anderson	Anderson	Sinaluisa	andersonsinaluisa@gmail.com	f	t	2024-07-23 00:00:00+00	2024-07-23 00:00:00+00	2024-07-25 15:58:13.675612+00	f	\N	\N
3	pbkdf2_sha256$600000$uvXJGznfKgwGh36nWC3a97$q2BfmcRh+Z9TSESdHCfEn+yJsUAQH53xNvrIZalbHJY=	\N	f	anderson_carga	Anderson	Sinaluisa	afullink@gmail.com	f	t	2024-07-23 06:09:07.800377+00	2024-07-23 06:09:08.22492+00	2024-07-23 06:09:08.224931+00	f	\N	\N
38	pbkdf2_sha256$600000$B1MPAezLdGzs13MfGnAAjm$DObf1jOTzyXAYMvCJnamHjbdJ/k/40Ajh/W5amOF4DQ=	\N	f	will	william	Gándara	wgandara@participacionciudadana.org	f	t	2024-07-25 00:00:00+00	2024-07-25 00:00:00+00	2024-07-25 16:01:36.015321+00	f	\N	\N
40	pbkdf2_sha256$600000$VjVrFHJYpELPB6jg8AYW4Q$J0QPjwEDBPd3O1pSTKtgB34aD/GepZwMFC/iga5Fuww=	\N	f	lfalcon	LENIN ABDON	FALCON GARZON	lfalcon@igualdadgenero.gob.ec	f	t	2024-07-25 00:00:00+00	2024-07-25 00:00:00+00	2024-07-25 16:03:47.500364+00	f	\N	\N
41	pbkdf2_sha256$600000$bl18HQc3WJHuVYgFNdATQn$lgBwe0hD9bvE+84QIDR0sOtgfNS6dpt2oT57xN/UEP0=	\N	f	jebaldeon	Juan	Baldeon	jebaldeon@ciudadaniaydesarrollo.org	f	t	2024-07-25 00:00:00+00	2024-07-25 00:00:00+00	2024-07-25 00:00:00+00	f	\N	\N
33	pbkdf2_sha256$600000$99iT3pMLWwCsmwyQy7jMrl$4RPPp0EPlPy+N41lfSsxDMsX7cvf/foeloQBO+CNfTc=	\N	f	LFALCON	LENIN ABDON	FALCON GARZON	lfalcon@iguladadgenero.gob.ec	f	t	2024-07-25 00:00:00+00	2024-07-25 00:00:00+00	2024-07-25 00:00:00+00	f	\N	\N
35	pbkdf2_sha256$600000$vBsACjIXNboaXTJbeZo8mU$MYYsnQiBJObFat05JerVvy35Rki/tmrPv2vjvwHPqeU=	\N	f	villarreale	Priscila	Villarreal	villarreale@presidencia.gob.ec	f	t	2024-07-25 00:00:00+00	2024-07-25 00:00:00+00	2024-07-25 00:00:00+00	f	\N	\N
39	pbkdf2_sha256$600000$pIbo7CEPBn923pGrVJ4Jlc$8ebqirfnUpayQ9gDAvFU3GYziYs8d5Zt6kqQAVidQrY=	\N	f	1703373454	FREDDY WILMER	VILLEGAS ALAVA	fwvillegas@gmail.com	f	t	2024-07-25 00:00:00+00	2024-07-25 00:00:00+00	2024-07-25 00:00:00+00	f	\N	\N
42	pbkdf2_sha256$600000$dXf6VzTnP1xngbXBGxOWxT$qOU+s9JLocfqT5VXNxCOhtZw7LrOQixz4cZnZ5EVpC0=	\N	f	pedro	pedro vicente	Castañeda Cabascango	cabascangodavid326@gmail.com	f	t	2024-07-25 00:00:00+00	2024-07-25 00:00:00+00	2024-07-25 00:00:00+00	f	\N	\N
43	pbkdf2_sha256$600000$MdKYZ4PUh4g9nucKt4IWuK$vFj6APp3W8jXNsE8AYGKQIlhd54sd9LbNUKRKCLkHks=	\N	f	publicador0	Anderson	Sinaluisa	figniberde@gufum.com	f	t	2024-07-26 02:10:04.499408+00	2024-07-26 02:10:04.914951+00	2024-07-26 02:10:04.914961+00	f	\N	\N
44	pbkdf2_sha256$600000$qiXt5WKvt57xNIus3i9N75$OC+hxzaSMNjysnvQiQMy+EZig2nL5Ez6Qv8Di2CDPV0=	\N	f	publicador1	Publicador	1	publicador1@correo.com	f	t	2024-07-26 03:09:29.165088+00	2024-07-26 03:09:29.668397+00	2024-07-26 03:09:29.668406+00	f	\N	\N
45	pbkdf2_sha256$600000$QeVmxAL4EKZC4mFfBOPTIh$mzz0DCrhSASGz4PpGCMH/ohqv9doUTJZ2fdoiy0g45E=	\N	f	publicador2	Publicador	2	publicador2@correo.com	f	t	2024-07-26 03:10:31.921273+00	2024-07-26 03:10:32.418474+00	2024-07-26 03:10:32.418484+00	f	\N	\N
46	pbkdf2_sha256$600000$6PURWoHPNFrJ8C3Y9BN274$nBo5TCLe6xe9tDdbQIxN3/VOUyzbs0Yp/hOZXQclqdU=	\N	f	publicador3	Publicador	3	publicador3@correo.com	f	t	2024-07-26 03:10:33.024315+00	2024-07-26 03:10:33.470792+00	2024-07-26 03:10:33.470803+00	f	\N	\N
47	pbkdf2_sha256$600000$TFIOiGjmBqioheJ6GNyK36$RBLiyETbrSLcM1wmVFvhtjrSZzLgeVhjUQnFYk8zauk=	\N	f	publicador4	Publicador	4	publicador4@correo.com	f	t	2024-07-26 03:10:34.20034+00	2024-07-26 03:10:34.778156+00	2024-07-26 03:10:34.778165+00	f	\N	\N
48	pbkdf2_sha256$600000$EvFNk1uPdnjPzPOEdCkiZi$MrFHylPXxBUB1dnpwJW25X5aRebA81RIUTwsY9wY/EQ=	\N	f	publicador5	Publicador	5	publicador5@correo.com	f	t	2024-07-26 03:10:35.415681+00	2024-07-26 03:10:35.911637+00	2024-07-26 03:10:35.911651+00	f	\N	\N
49	pbkdf2_sha256$600000$e1Ox8hOE60KcCcDAVKsbru$ZcLacVSd/kJj+LTKRSWl2e22AayprNToUO8vrDm8ARs=	\N	f	publicador6	Publicador	6	publicador6@correo.com	f	t	2024-07-26 03:10:36.49983+00	2024-07-26 03:10:36.991512+00	2024-07-26 03:10:36.991522+00	f	\N	\N
50	pbkdf2_sha256$600000$G2WLiygvDChN2UP4ylk5m2$Y05DmzoNiaL/UuSndYsSZkajLc8JA7D46cS/28Tb7To=	\N	f	publicador7	Publicador	7	publicador7@correo.com	f	t	2024-07-26 03:10:37.63141+00	2024-07-26 03:10:38.135057+00	2024-07-26 03:10:38.135068+00	f	\N	\N
51	pbkdf2_sha256$600000$ZXKk5wXjhQ9JXFCdWS43O1$/CURU86hqA8PuztEG/fcL8Reoef5nxm5uUoV0SqCqno=	\N	f	publicador8	Publicador	8	publicador8@correo.com	f	t	2024-07-26 03:10:38.767408+00	2024-07-26 03:10:39.340695+00	2024-07-26 03:10:39.340705+00	f	\N	\N
52	pbkdf2_sha256$600000$8uFbS3D5SAgF2bpUAQS55B$pc/1obuWwQiZw6ckFIVD24ztJCs/jQAg8WQ3M+EW6/E=	\N	f	publicador9	Publicador	9	publicador9@correo.com	f	t	2024-07-26 03:10:40.021149+00	2024-07-26 03:10:40.468337+00	2024-07-26 03:10:40.468346+00	f	\N	\N
53	pbkdf2_sha256$600000$5PBIRyXmWEn33tU6plb7ub$tUuA6d750qe1nn3lAYmQ6glnQO+LGXQjHYIWkzoblm4=	\N	f	publicador10	Publicador	10	publicador10@correo.com	f	t	2024-07-26 03:10:41.044612+00	2024-07-26 03:10:41.484484+00	2024-07-26 03:10:41.484493+00	f	\N	\N
54	pbkdf2_sha256$600000$9a1pDdXYvx2laSF08pqyIQ$IkMStUJQZlFV60mWfmDjLC3Pe33A/by4hBeXqQb9tQk=	\N	f	publicador11	Publicador	11	publicador11@correo.com	f	t	2024-07-26 03:10:42.037884+00	2024-07-26 03:10:42.4594+00	2024-07-26 03:10:42.459408+00	f	\N	\N
55	pbkdf2_sha256$600000$WDWWZS5iI5bZahXfNjPiUp$snTlFXfRFTqQ+y0JYd6YoKJhVZXnFrgvX3QS67A3JcY=	\N	f	publicador12	Publicador	12	publicador12@correo.com	f	t	2024-07-26 03:10:43.056918+00	2024-07-26 03:10:43.474151+00	2024-07-26 03:10:43.474159+00	f	\N	\N
56	pbkdf2_sha256$600000$Vf8tj30vHO52gPaGMQtxWD$xQIZoHkSPqcLfJrQ1vLU2HdLh4+rk2fIuHkYNwiT6DM=	\N	f	publicador13	Publicador	13	publicador13@correo.com	f	t	2024-07-26 03:10:44.015961+00	2024-07-26 03:10:44.433622+00	2024-07-26 03:10:44.433631+00	f	\N	\N
57	pbkdf2_sha256$600000$pjTkT9YkjyvNEjhsoa9D6n$RjqBDis8pGS9ksZ4m3GxpjmwsZ8sRZSuyE2+4h5kwgI=	\N	f	publicador14	Publicador	14	publicador14@correo.com	f	t	2024-07-26 03:10:44.969861+00	2024-07-26 03:10:45.393263+00	2024-07-26 03:10:45.393273+00	f	\N	\N
58	pbkdf2_sha256$600000$W0Mvy4VKxivnZfCyH7Bxhl$+dBGbDMwlNuDk/huXXVegX/YNzPBxEZahM6kGVMopvo=	\N	f	publicador15	Publicador	15	publicador15@correo.com	f	t	2024-07-26 03:10:46.092823+00	2024-07-26 03:10:46.540281+00	2024-07-26 03:10:46.54029+00	f	\N	\N
59	pbkdf2_sha256$600000$uwJg1nysjYZgKuSGv33FZJ$c7Rvec676sQVoqsitmPX+YviTSwgQM1yz6lxcSZKqeA=	\N	f	publicador16	Publicador	16	publicador16@correo.com	f	t	2024-07-26 03:10:47.285448+00	2024-07-26 03:10:47.832408+00	2024-07-26 03:10:47.832416+00	f	\N	\N
60	pbkdf2_sha256$600000$jUJ0lnNoCzoGSxV0cTZbp1$d51ash+y0RS0PiH9K9K5kQauU8ieXw64Gqbn/AB3/wM=	\N	f	publicador17	Publicador	17	publicador17@correo.com	f	t	2024-07-26 03:10:48.530706+00	2024-07-26 03:10:49.067637+00	2024-07-26 03:10:49.067647+00	f	\N	\N
61	pbkdf2_sha256$600000$rtSzWaFaknBZwphJ5yxO4n$/2TPV/+iaV44AJDDAOQm1k38yTIbvUpHQf487+77rlI=	\N	f	publicador18	Publicador	18	publicador18@correo.com	f	t	2024-07-26 03:10:49.736284+00	2024-07-26 03:10:50.274808+00	2024-07-26 03:10:50.274817+00	f	\N	\N
62	pbkdf2_sha256$600000$n7CsSW09lGHaCDx5aCIbKQ$daYJYmcY2X2+Ue3ac6lx9Y48zJ5O4l9TpSJAI+b7m6g=	\N	f	publicador19	Publicador	19	publicador19@correo.com	f	t	2024-07-26 03:10:50.942588+00	2024-07-26 03:10:51.44247+00	2024-07-26 03:10:51.442479+00	f	\N	\N
63	pbkdf2_sha256$600000$dbAZRq7ROto9xFMFEbZ2T9$0pKvD6LD/noRp2eTQ8ScOZ02I9hC0xE2k5wdFFSxxMo=	\N	f	publicador20	Publicador	20	publicador20@correo.com	f	t	2024-07-26 03:10:52.124398+00	2024-07-26 03:10:52.648028+00	2024-07-26 03:10:52.648037+00	f	\N	\N
64	pbkdf2_sha256$600000$7dWl6aV9qpZ0MUx3Grkma6$52puioOvE2Ebs8/U4qSb+3naHG3hhVHXQXit5aIh9ik=	\N	f	publicador21	Publicador	21	publicador21@correo.com	f	t	2024-07-26 03:10:53.301296+00	2024-07-26 03:10:53.832951+00	2024-07-26 03:10:53.832963+00	f	\N	\N
65	pbkdf2_sha256$600000$6sSadp2RaxsIOKSgPBjgAA$vszYqyQXEMEVatNkwOa2vJILnOGS1wo/tXFadzDbImk=	\N	f	publicador22	Publicador	22	publicador22@correo.com	f	t	2024-07-26 03:10:54.638898+00	2024-07-26 03:10:55.27374+00	2024-07-26 03:10:55.273756+00	f	\N	\N
66	pbkdf2_sha256$600000$0nPLDLIR1LdRiyZNfjswLg$CR7aKvH/W1Ypv+5/IBqv/6kJQ6f2zVoQ6LekGVQXdK4=	\N	f	publicador23	Publicador	23	publicador23@correo.com	f	t	2024-07-26 03:10:55.888686+00	2024-07-26 03:10:56.372852+00	2024-07-26 03:10:56.372862+00	f	\N	\N
67	pbkdf2_sha256$600000$10ynfbDoXQROoRFV74aUIj$aSZDZkRP6WBKEHK9JbiqvNE1zrbfYt4ZjtO1dDWuDyI=	\N	f	publicador24	Publicador	24	publicador24@correo.com	f	t	2024-07-26 03:10:56.988454+00	2024-07-26 03:10:57.470794+00	2024-07-26 03:10:57.470804+00	f	\N	\N
68	pbkdf2_sha256$600000$7yb1ssdbkKhwT1U41iwYaE$i0IOCWtkvUQIdqAdyIW/s6C19xUU6sG9v2xZvidaj+c=	\N	f	publicador25	Publicador	25	publicador25@correo.com	f	t	2024-07-26 03:10:58.102432+00	2024-07-26 03:10:58.542224+00	2024-07-26 03:10:58.542233+00	f	\N	\N
69	pbkdf2_sha256$600000$xBw9KHysmIRn5OLP1mQ7S0$AUUFo8w5F7QNoK24O3Gm+AwnGwuWjQqLatSM41xhx9U=	\N	f	publicador26	Publicador	26	publicador26@correo.com	f	t	2024-07-26 03:10:59.112085+00	2024-07-26 03:10:59.556921+00	2024-07-26 03:10:59.556932+00	f	\N	\N
70	pbkdf2_sha256$600000$By6YpRwKzUZL9ZQUnmScDJ$RzQyTS9qX+hqshFIp2cETfavpLdzx22FIT0wsFeWw6E=	\N	f	publicador27	Publicador	27	publicador27@correo.com	f	t	2024-07-26 03:11:00.162932+00	2024-07-26 03:11:00.603909+00	2024-07-26 03:11:00.603919+00	f	\N	\N
71	pbkdf2_sha256$600000$hVKoouephdjl85wbdEmCpu$Lc8/yz4ZZeLCss2MC9SpoDpwmhUx7/8ybV3awoCI11M=	\N	f	publicador28	Publicador	28	publicador28@correo.com	f	t	2024-07-26 03:11:01.272894+00	2024-07-26 03:11:01.854118+00	2024-07-26 03:11:01.854128+00	f	\N	\N
72	pbkdf2_sha256$600000$U8IvDJN4lnvXBNObttsopO$qYYAwKxBM+N9TOSxphkkOJnkTEAbJTdIQdpOttuqklI=	\N	f	publicador29	Publicador	29	publicador29@correo.com	f	t	2024-07-26 03:11:02.565008+00	2024-07-26 03:11:03.060192+00	2024-07-26 03:11:03.060201+00	f	\N	\N
73	pbkdf2_sha256$600000$UXPK4uNfeaussaqU6EcPo8$QOoUW/s1eqge/x+W6sDohblwj1pMn6sgVllypASce/c=	\N	f	publicador30	Publicador	30	publicador30@correo.com	f	t	2024-07-26 03:11:03.721856+00	2024-07-26 03:11:04.202435+00	2024-07-26 03:11:04.202444+00	f	\N	\N
74	pbkdf2_sha256$600000$jjuThANDpmxCyvG7G3b7lX$YiJP4Y7e8TU47inRy3azI9x7saBU7Ez++K8ykT8fTxA=	\N	f	publicador31	Publicador	31	publicador31@correo.com	f	t	2024-07-26 03:11:04.828723+00	2024-07-26 03:11:05.283731+00	2024-07-26 03:11:05.28374+00	f	\N	\N
75	pbkdf2_sha256$600000$ORYfBlx13J8uaCKjEDEMqJ$JbfFDfhRTu/z16W7nTCEqpJbN8JRa10oYABAqv3sbJ8=	\N	f	publicador32	Publicador	32	publicador32@correo.com	f	t	2024-07-26 03:11:05.865021+00	2024-07-26 03:11:06.311639+00	2024-07-26 03:11:06.311648+00	f	\N	\N
76	pbkdf2_sha256$600000$k7ucRpmMTrdvBy5QKQnBki$nYCNvloOr38UcZFZeeGo2RDIym6dvpNYE4rJ8y27pfU=	\N	f	publicador33	Publicador	33	publicador33@correo.com	f	t	2024-07-26 03:11:06.898114+00	2024-07-26 03:11:07.325721+00	2024-07-26 03:11:07.325731+00	f	\N	\N
77	pbkdf2_sha256$600000$8KSXLjJHZ3G7OlBpfh3wVB$JXsQUhQIh3s0jyUKKwk0DI0o1/6aS4aM7am603WdFXM=	\N	f	publicador34	Publicador	34	publicador34@correo.com	f	t	2024-07-26 03:11:07.92955+00	2024-07-26 03:11:08.370585+00	2024-07-26 03:11:08.370595+00	f	\N	\N
78	pbkdf2_sha256$600000$PIq28ODQ140maIfPFxH9OK$XUzD35Zdptlp5Vk48Hv/de+krEhRyJRN2KrS79nFJJc=	\N	f	publicador35	Publicador	35	publicador35@correo.com	f	t	2024-07-26 03:11:08.927559+00	2024-07-26 03:11:09.371976+00	2024-07-26 03:11:09.371985+00	f	\N	\N
79	pbkdf2_sha256$600000$ywjkWl5p2P8X1KTMI6gOM8$foRsHITttL06R1zKqaa7PkkrGP2SnWo3FMTbnR7NCTk=	\N	f	publicador36	Publicador	36	publicador36@correo.com	f	t	2024-07-26 03:11:09.928667+00	2024-07-26 03:11:10.368963+00	2024-07-26 03:11:10.368971+00	f	\N	\N
80	pbkdf2_sha256$600000$iMN2sdE6TVHef1Wz4P0MQx$BL7ATxpqlTRi/ioM0FEGsVo6PTQxEYixsIewUygI6RY=	\N	f	publicador37	Publicador	37	publicador37@correo.com	f	t	2024-07-26 03:11:11.018314+00	2024-07-26 03:11:11.529947+00	2024-07-26 03:11:11.529956+00	f	\N	\N
81	pbkdf2_sha256$600000$O8zRktRrId9jP5UUPKp29P$mVq/m0awXInM4rYyXdEcip2W6OHjJRssXE638upDER8=	\N	f	publicador38	Publicador	38	publicador38@correo.com	f	t	2024-07-26 03:11:12.152333+00	2024-07-26 03:11:12.681238+00	2024-07-26 03:11:12.681247+00	f	\N	\N
82	pbkdf2_sha256$600000$KQeJ7oKK6o2QgfmuZBCi8C$m4C2KiJeSACKsnOoWHgkHu5Ycsp7FK9YdpXlgld4TFs=	\N	f	publicador39	Publicador	39	publicador39@correo.com	f	t	2024-07-26 03:11:13.258063+00	2024-07-26 03:11:13.695116+00	2024-07-26 03:11:13.695125+00	f	\N	\N
83	pbkdf2_sha256$600000$DlqfDrVYTbjdrLUUhm1FBM$VYng90fsQsh9f801oHlqdWZ/kXaHGeEt3l3LfOxdMkI=	\N	f	publicador40	Publicador	40	publicador40@correo.com	f	t	2024-07-26 03:11:14.267402+00	2024-07-26 03:11:14.697257+00	2024-07-26 03:11:14.697266+00	f	\N	\N
84	pbkdf2_sha256$600000$WcZyb1nKpH2uRLNbVOjTKQ$Y7Qr1eySY9Y7/yKMQsVRD9F4gYYCGuy9+kGeieyOxO0=	\N	f	lachscomputer	ALEJANDRO	CHUQUIRALAO	lachscomputer@yahoo.com	f	f	2024-07-26 00:00:00+00	2024-07-26 00:00:00+00	2024-07-26 00:00:00+00	f	\N	\N
95	pbkdf2_sha256$600000$NRm7DPZTblmIyXsRzZZRgB$3YRyORndnJ/A8PFikIzundMokj1XDOifAD1Hi1OkKWg=	\N	t	anabel2024	Anabel	Aguilar	cristinaissue@gmail.com	f	t	2024-07-29 15:12:12.557647+00	2024-07-29 15:12:13.06191+00	2024-07-29 15:12:13.072959+00	f	\N	\N
96	pbkdf2_sha256$600000$AOjGvS5fDrYovTobPBTEwG$ICvez70ssLOgIhE97cOLtyg0HjBFjj9WcbFVNf2mXxs=	\N	f	MONITOREO_DPE_BQ	BOLIVAR	QUISPE	bolivar.quispemonitoreo@dpe.gob.ec	f	t	2024-07-29 15:12:13.229123+00	2024-07-29 15:12:13.67953+00	2024-07-29 15:12:13.67954+00	f	\N	\N
97	pbkdf2_sha256$600000$XsowHPqZbsVXR9gpoqqhDX$D5bdYLbUdzhHIkoFAIk6vmmyOPpclRlSWZ6WkoHffQA=	\N	f	santiago719@hotmail.com	Santiago	Moscoso	gabriel.moscoso@dpe.gob.ec	f	t	2024-07-29 15:12:26.978265+00	2024-07-29 15:12:27.452083+00	2024-07-29 15:12:27.452093+00	f	\N	\N
98	pbkdf2_sha256$600000$7MBgbCfgQAWvFjPJ4dMOg4$CQ+jDrGe8BQ6/P13NgBAZc+YDvxkNMMhRrD44DDnOps=	\N	f	Genny2024	Genny del Pilar	Vélez Ponce	genny.velez@dpe.gob.ec	f	t	2024-07-29 15:13:31.132388+00	2024-07-29 15:13:31.585237+00	2024-07-29 15:13:31.585246+00	f	\N	\N
86	pbkdf2_sha256$600000$HNlDac0qegcQnnzGrPiQWK$kOgBobK/dmQSVD3PW1/qWm3kdw5MSdW5tHUMUKik9iU=	\N	t	dpe_admin	Roberto	Esteves	hola1@masappec.com	f	t	2024-07-29 02:38:01.268296+00	2024-07-29 02:38:01.751912+00	2024-07-29 02:38:01.774529+00	f	\N	\N
87	pbkdf2_sha256$600000$EdGxTxFfHFwHCI3T5WyOgk$VmrsOyCdYnkJri9bQI0MIDLIWA+QQkjOcxX2SUZP6xE=	\N	f	supervisora	Anderson	Sinaluisa	supervisora@gmail.com	f	t	2024-07-29 13:37:31.059774+00	2024-07-29 13:37:31.527639+00	2024-07-29 13:37:31.527651+00	f	\N	\N
85	pbkdf2_sha256$600000$1lKrtBCoLCmvsplUzIjZLU$GwNgHhQEC2x4cpkD9Co8hKlm9XUs1pqn8C6VFqYF8kQ=	\N	f	monitoreo	monitoreo	monitoreo	monitoreo@gmail.com	f	t	2024-07-26 16:34:28.979681+00	2024-07-26 16:34:29.679742+00	2024-07-26 16:34:29.679751+00	f	\N	\N
88	pbkdf2_sha256$600000$ntYoMVffOT3bvt9rNty4Qz$6PBRPLNDZmm6HLMpHzmE9VXEhkxKIkQGJuwGB981GNw=	\N	f	gvivanco	Gabriela	Vivanco	gabriela.vivanco@dpe.gob.ec	f	t	2024-07-29 15:05:39.94736+00	2024-07-29 15:05:40.416257+00	2024-07-29 15:05:40.416267+00	f	\N	\N
89	pbkdf2_sha256$600000$AwndoWM4xTdFhMXcIHQU6B$QZoHp498VOfE7OYO6nMlKXOJFEhaDuBSDHt6ICDDVGU=	\N	t	gvivanco24	Gabriela	Vivanco	cgvivanco24@gmail.com	f	t	2024-07-29 15:07:25.99251+00	2024-07-29 15:07:26.473096+00	2024-07-29 15:07:26.483269+00	f	\N	\N
90	pbkdf2_sha256$600000$pABDtmRmEmn2IWpF61GXbx$xkqY3ZnawKb2T+SQjJzDG7pM27M7FB3ur7K8Tt0SWe8=	\N	f	wpalvarez	Patricio	Alvarez	wilson.alvarez@dpe.gob.ec	f	t	2024-07-29 15:07:38.107012+00	2024-07-29 15:07:38.560536+00	2024-07-29 15:07:38.560546+00	f	\N	\N
91	pbkdf2_sha256$600000$OVlDdqeAdZ2ij87oz7iUYv$i0yDGo7CQco93vhIZn2ZvjwFbY7tqZpZXaZBqadwkmo=	\N	t	wpalvarezadmin	Patricio	Alvarez	wilson.alvarez@hotmail.gob.ec	f	t	2024-07-29 15:09:34.758781+00	2024-07-29 15:09:35.287793+00	2024-07-29 15:09:35.298131+00	f	\N	\N
92	pbkdf2_sha256$600000$5HCL59tLDSvBdfCMHEhGhM$b//nUtmLPPV8LEPZC1v1KuTCzeUWBS6dZQf+McSVT4o=	\N	t	dpe_admin+BQ	BOLIVAR	QUISPE	bolivar.quispe@dpe.gob.ec	f	t	2024-07-29 15:10:00.371456+00	2024-07-29 15:10:00.90185+00	2024-07-29 15:10:00.916528+00	f	\N	\N
93	pbkdf2_sha256$600000$Z1B1TfrsJd0NcImT91kQxY$0Cx1z+HlHYbcRosuqf/zZoBM1XWWgnx0jg9L8vJliL0=	\N	f	Pepito	Angelica	Viscaino	pepito@gmail.com	f	t	2024-07-29 15:10:23.938177+00	2024-07-29 15:10:24.464296+00	2024-07-29 15:10:24.464306+00	f	\N	\N
94	pbkdf2_sha256$600000$u1OhB1dAgP10GjAvQuWUwK$Bu9sju6b2svWS8ADJrkpHu74WRZXllHpIZ277XrGzWQ=	\N	f	manuel.solano	Manuel Estuardo	Solano Moreno	manuel.solano@dpe.gob.ec	f	f	2024-07-29 00:00:00+00	2024-07-29 00:00:00+00	2024-07-29 00:00:00+00	f	\N	\N
99	pbkdf2_sha256$600000$ULFxxfnnmO7QSMYr7skCu6$FxcguYtR4dCqKn3pZsN3iT+7Z9GAsOtQc2xjfTdAliM=	\N	f	edwinpilco	Edwin	Pilco	edwin.pilco@dpe.gob.ec	f	t	2024-07-29 15:13:59.105969+00	2024-07-29 15:13:59.609972+00	2024-07-29 15:13:59.609982+00	f	\N	\N
101	pbkdf2_sha256$600000$LIDDTZ1pnh2jqO6SatBKDt$2cD59fKNtstyAlB1jH5lFK3+hJxoyoiBeo0A2lP/UzI=	\N	t	santiago719	Gabriel Santiago	Moscoso González	santiago719@hotmail.com	f	t	2024-07-29 15:15:34.237906+00	2024-07-29 15:15:34.71112+00	2024-07-29 15:15:34.72069+00	f	\N	\N
102	pbkdf2_sha256$600000$ZPFk8elGxf2E6RRZEqWCVs$ID5iyKfpGNfy1Jo/eAdw0f9Eg9J+bKSfmdLFxmTeOMk=	\N	t	1306115468	Genny del Pilar	Vélez Ponce	gennyvp1@hotmail.com	f	t	2024-07-29 15:17:29.04477+00	2024-07-29 15:17:29.538275+00	2024-07-29 15:17:29.548777+00	f	\N	\N
103	pbkdf2_sha256$600000$U9nObPvHaFtkIhpVmpHDvp$78ucWd8wDH+c+liAr4iWosS1oNtg2OFBRqIcNL7ryDA=	\N	t	0603833187	Edwin	Pilco	edwineduardopc@gmail.com	f	t	2024-07-29 15:17:57.985579+00	2024-07-29 15:17:58.450268+00	2024-07-29 15:17:58.463678+00	f	\N	\N
104	pbkdf2_sha256$600000$TrYNB6cWbe6cHSiYLqtuFz$ZoLHZQLlMZcBVXvt/zkLQjtrapKqbl9j0PQYYTJxP+4=	\N	t	1723378889	Johana Patricia	Castellanos Toscano	johana.castellanos@dpe.gob.es	f	t	2024-07-29 15:18:27.197145+00	2024-07-29 15:18:27.648769+00	2024-07-29 15:18:27.659748+00	f	\N	\N
105	pbkdf2_sha256$600000$eSW9fq4cn3yTmvU2Z7s0e0$aa1CmxJ8tBN7PSFPZPREYmX7dNfv1M+Z+1Ny4FHid3Y=	\N	f	JohanaC	Johana Patricia	Castellanos Toscano	joby_1089typ@hotmail.com	f	t	2024-07-29 15:20:41.844656+00	2024-07-29 15:20:42.324857+00	2024-07-29 15:20:42.324867+00	f	\N	\N
106	pbkdf2_sha256$600000$0b4m8p55nL1iUOARmauUjC$lLXJfhVVMzqVRoJ5F1LMKEeeM0xwhJOnSZp0uBgaQlk=	\N	f	Jenny.canar	Jenny Cecilia	Cañar Cueva	jenny.canar@dpe.gob.ec	f	t	2024-07-29 15:23:17.018957+00	2024-07-29 15:23:17.449165+00	2024-07-29 15:23:17.449174+00	f	\N	\N
107	pbkdf2_sha256$600000$vARbYKfCkoGueAsNzLE0Ka$cbPR5g9mPgLCwQosSb2nxSTvBzbR43PDUZP2/LVOhHc=	\N	f	eduardopilco	Edwin	Pilco	lira2666@yahoo.es	f	t	2024-07-29 15:23:39.237897+00	2024-07-29 15:23:39.653881+00	2024-07-29 15:23:39.653891+00	f	\N	\N
108	pbkdf2_sha256$600000$0X1TCeNjnLMCloaj6muxB0$8q1Yjj6i4Y92HeujLKQZ2rUFM5taEECSgyXBMiue0gg=	\N	f	Carmitarz	CARMITA	RODRIGUEZ	carmen.rodriguez@dpe.gob.ec	f	t	2024-07-29 15:25:26.673569+00	2024-07-29 15:25:27.170381+00	2024-07-29 15:25:27.17039+00	f	\N	\N
109	pbkdf2_sha256$600000$KTVfE3QpQtkryeiWnGCdfm$NPXPmwH3dQHzUhf1knNDtKcWVlBkC6j4S20cDRVq3KY=	\N	f	wpalvarezcarga	patricio	alvarez	wilson@hotmail.com	f	t	2024-07-29 15:26:42.96606+00	2024-07-29 15:26:43.383635+00	2024-07-29 15:26:43.383644+00	f	\N	\N
110	pbkdf2_sha256$600000$P7tY7NUd3HFjg6LYQ8xocv$q0Yd7N55+6SxLeZSUo7JeElnGmaO9/rXqlV+kuysTRM=	\N	f	cargaBQ	bolivar	quispe	bolivar.quispeccarga@dpe.gob.ec	f	t	2024-07-29 15:26:53.570787+00	2024-07-29 15:26:54.04397+00	2024-07-29 15:26:54.043979+00	f	\N	\N
111	pbkdf2_sha256$600000$K66qyTLkEShcnSNJntLsOe$j+L8QtTDUp6iB37W1y00HzHUYKbmotlcnqaHAnMZiJo=	\N	t	1900311349	Jenny Cecilia	Cañar Cueva	jcecilia.24@hotmail.com	f	t	2024-07-29 15:28:22.088108+00	2024-07-29 15:28:22.60121+00	2024-07-29 15:28:22.614137+00	f	\N	\N
112	pbkdf2_sha256$600000$x3wEWhux8HPxAEuUMihqMH$n82WdGCIJ/sd0MjhpWd+FUQgtuApD3nggc9Zv0E8G4A=	\N	t	carmitarz	CARMITA	RODRIGUEZ	carmita1989superadministradora@hotmail.com	f	t	2024-07-29 15:28:30.852394+00	2024-07-29 15:28:31.287396+00	2024-07-29 15:28:31.305122+00	f	\N	\N
113	pbkdf2_sha256$600000$XQkHNuUZLicvBZhzQpP3gl$w45qFaUahWMLH2IlLweFMnmOKkPy1d7dHT7mHL4xPJY=	\N	f	n_bravo	Neithan Iván	Bravo Andrade	nbravo@mgob.ec	f	t	2024-07-29 15:28:54.54805+00	2024-07-29 15:28:55.152443+00	2024-07-29 15:28:55.152453+00	f	\N	\N
114	pbkdf2_sha256$600000$0wmEzmi7Ueb9VLME9cjYM8$G6wxsamRu7pDDP9kx0Cw+VGS2Sc8lDc+TTAsD9lTkQg=	\N	f	Martin2024	Martin Sebastián	Sotomayor Vélez	martin.sotomayor4@dpe.gob.ec	f	t	2024-07-29 15:29:17.380917+00	2024-07-29 15:29:17.815921+00	2024-07-29 15:29:17.815931+00	f	\N	\N
115	pbkdf2_sha256$600000$UtTOAq53gh4i5pEN8RhOdw$JH1RDPvj4JYIhvcVHIvv0XcxPGglBmnkxMf8U3/DbCA=	\N	f	CARMITA RZ	CARMITA	RODRIGUEZ	carmita1989supervisora@hotmail.com	f	t	2024-07-29 15:30:34.372366+00	2024-07-29 15:30:34.831074+00	2024-07-29 15:30:34.831084+00	f	\N	\N
116	pbkdf2_sha256$600000$Lxojs6XdkeimPZn2dzg7PH$NNyK8depjWOg9z0zT+UPdxVpnwTtaxFvPKG+OU3WYtM=	\N	t	a_bravo	Araid Victoria	Bravo Andrade	abravo@mgob.gob.ec	f	t	2024-07-29 15:30:46.778888+00	2024-07-29 15:30:47.309039+00	2024-07-29 15:30:47.319417+00	f	\N	\N
117	pbkdf2_sha256$600000$oOOuc1Aku2cAQySwEGLGaW$Clq1PvNbGFdfEgi2l+hjzpZsydSspwE8dRkvv9t1ouw=	\N	f	CARMIÑA	CARMITA	RODRIGUEZ	carmita1989pnt@hotmail.com	f	t	2024-07-29 15:32:07.169055+00	2024-07-29 15:32:07.606234+00	2024-07-29 15:32:07.606243+00	f	\N	\N
118	pbkdf2_sha256$600000$ESnARH4JvBXsRC2O9gO6ha$bjOC7Hw/bx2rS3ZqT786byOT7mp94oGaw6lZX9VBV4M=	\N	f	jorge_poma	Jorge Esteban	Poma Almeida	jpoma@mgob.gob.ec	f	t	2024-07-29 15:33:38.380859+00	2024-07-29 15:33:38.86787+00	2024-07-29 15:33:38.867882+00	f	\N	\N
119	pbkdf2_sha256$600000$Qm7XTIjwZ994UZmkwVVAty$ZARNt9vwidtLvUQf0DrDYGoNmDA9isA5ObesdZjheuk=	\N	t	Edducordova	Eduardo	Córdova Sánchez	edducordova@gmail.com	f	t	2024-07-29 15:35:48.60083+00	2024-07-29 15:35:49.070229+00	2024-07-29 15:35:49.080529+00	f	\N	\N
120	pbkdf2_sha256$600000$44g8Sx3IKxD8G4SlpT5l1i$adzPz4kjbzCondab+OTEYMZovLuDQ0IycbjIPnGt7HE=	\N	f	monitoreodpe	luis	barragan	luis.barragan@dpe.gob.ec	f	t	2024-07-29 15:35:58.990377+00	2024-07-29 15:35:59.454407+00	2024-07-29 15:35:59.454416+00	f	\N	\N
121	pbkdf2_sha256$600000$d9KxbYEnTSR3ih5vO8CuLW$hwNBwSzkWvoj+BJrE0umAttL8W10SOJaGPglLn4+Upk=	\N	f	cacisneros	Carla	Cisneros	carla.cisneros@minecuador.gob.ec	f	t	2024-07-29 15:36:29.266632+00	2024-07-29 15:36:29.774586+00	2024-07-29 15:36:29.774596+00	f	\N	\N
122	pbkdf2_sha256$600000$SdnsgEBnNQ5245Z1cYOLuf$HLsJY5no9d5YbbN1O75Tm0igCfMNqFdLZk8A1RD1oH0=	\N	t	secretaria	pedro	almeida	siged@dpe.gob.ec	f	t	2024-07-29 15:38:26.120398+00	2024-07-29 15:38:26.579785+00	2024-07-29 15:38:26.591539+00	f	\N	\N
123	pbkdf2_sha256$600000$q1F77zR0Ql7LBZHNKUwHvA$axn8zWPs/lwDfo+xBfE5Ity417FKqNqMIbfYHwJ8FB8=	\N	f	Jc	Jenny	Cañar	jenny.canarpnt@dpe.gob.ec	f	t	2024-07-29 15:44:47.74415+00	2024-07-29 15:44:48.191744+00	2024-07-29 15:44:48.191754+00	f	\N	\N
100	pbkdf2_sha256$600000$c8VoJEfLn1OKDRgnDz7gUL$sez9hcviwEjesY7ULY8PtXAFwJzMoBFDnD9XgLyq94g=	\N	f	Defensoria2024	Cristina	Llumipanta	cris@gmail.com	f	t	2024-07-29 15:14:40.689747+00	2024-07-29 15:14:41.234521+00	2024-07-29 15:14:41.23453+00	f	\N	\N
124	pbkdf2_sha256$600000$NTyCulFfOGMUGxQmnhWqQn$q/oJa2tbIqdUEpyLTRCwq1ucIljsLqO3t/cFRugZH3w=	\N	f	cargaLBP	luis	barragan	carga@dpe.gob.ec	f	t	2024-07-29 15:48:35.633533+00	2024-07-29 15:48:36.096026+00	2024-07-29 15:48:36.096036+00	f	\N	\N
125	pbkdf2_sha256$600000$32CnYNzcYpQHO0qJ4vkWnp$clHMOvyhfm7ViY74oLfHDw6pEuiWm733182ogJnxe/M=	\N	f	JCastellanos	Johana Patricia	Castellanos Toscano	johana.castellano@dpe.gob.ec	f	t	2024-07-29 15:49:50.54127+00	2024-07-29 15:49:51.033963+00	2024-07-29 15:49:51.033972+00	f	\N	\N
126	pbkdf2_sha256$600000$aBYNSSk9hEnX0x19zNkSRt$c4GbtpDu4x9XLJWX+MmJjpB32zmbWfsER0WMqzXRvsg=	\N	f	carlos_vasconez	Carlos Julio	Vásconez Alban	cvasconez@hotmail.com	f	t	2024-07-29 15:54:45.199545+00	2024-07-29 15:54:45.640778+00	2024-07-29 15:54:45.640787+00	f	\N	\N
127	pbkdf2_sha256$600000$7qShF5aBl2Ubi4mP8kPay9$b1l73XbPShtUW6/n19902Zu976f+uB0hDS9l2y8C3vs=	\N	t	Isabel_Andrade	Isabel Victoria	Andrade Araujo	Isabel.And@hotmail.com	f	t	2024-07-29 16:01:51.5742+00	2024-07-29 16:01:52.103198+00	2024-07-29 16:01:52.115785+00	f	\N	\N
128	pbkdf2_sha256$600000$WVF1BBKmbEZrTLkMjLMRrp$3ruI5gQlh7GBwr7gFWuzfjkyghCcGjCPE7Q93FDkPxk=	\N	f	geovanny.lopez	Geovanny Armando	López Ramos	geovanny.lopez@dpe.gob.ec	f	f	2024-07-29 00:00:00+00	2024-07-29 00:00:00+00	2024-07-29 00:00:00+00	f	\N	\N
129	pbkdf2_sha256$600000$MlUDV0FPbhbzQ0XyqYxW1G$/hBWFIgL/9shnc8NB3JrS62ppCmLEUbnIQPLavrUfKg=	\N	f	edobejar	Juan	Perez	edobejar@gmail.com	f	t	2024-08-07 00:00:00+00	2024-08-07 00:00:00+00	2024-08-07 00:00:00+00	f	\N	\N
130	pbkdf2_sha256$600000$zHySBx8eL5E1CbbOjJsnca$dX/x0DKP97mgifxt+rmuVPp9CXJHpwqizZWbMTCU7/0=	\N	f	m.sanchez	Maria	Sanchez	m.sanchez@correo.com	f	t	2024-08-07 21:45:54.996635+00	2024-08-07 21:45:55.419259+00	2024-08-07 21:45:55.419269+00	f	\N	\N
131	pbkdf2_sha256$600000$9v4mzQ0pjIfJAzsYD54DpD$x8pg/p9E5zaOoiDLJbW+Nb5k2xt8QWY1QkHzS0CMp7k=	\N	t	r.mendoza	Roberto	Mendoza	r.mendoza@correo.com	f	t	2024-08-07 21:48:38.036389+00	2024-08-07 21:48:38.518227+00	2024-08-07 21:48:38.531883+00	f	\N	\N
132	pbkdf2_sha256$600000$Tz2SrMT6DxEgZvOutg5hL3$NsDdKjBQYeiXbAYabgc99yyWdwO2UDWndoLL7Hw4/po=	\N	f	g.cornejo	Graciela	Cornejo	g.cornejo@mig.gob.ec	f	t	2024-08-07 21:56:38.371694+00	2024-08-07 21:56:38.90515+00	2024-08-07 21:56:38.905162+00	f	\N	\N
133	pbkdf2_sha256$600000$eIS8izQ4jrIwrZk8D8r7Z0$pkv0AeTTyXrncdq8aY2kmPzzcufO08vppufJwfqc/0s=	\N	f	Yessi	Yessi	Poveda	japch.1990@hotmail.com	f	t	2024-08-15 00:00:00+00	2024-08-15 00:00:00+00	2024-08-15 00:00:00+00	f	\N	\N
\.


--
-- Data for Name: auth_user_groups; Type: TABLE DATA; Schema: public; Owner: auth_user
--

COPY public.auth_user_groups (id, user_id, group_id) FROM stdin;
1	1	5
2	2	1
4	4	2
7	5	1
8	6	1
11	7	1
12	8	1
13	9	1
14	10	1
15	11	1
16	12	1
17	13	1
18	14	1
19	15	1
20	16	1
21	17	1
22	18	1
23	19	1
24	20	1
25	21	1
26	22	1
27	23	1
28	24	1
29	25	1
30	26	1
31	27	1
32	28	1
33	29	1
34	30	1
35	31	1
36	32	1
37	33	1
38	35	1
39	38	1
40	39	1
41	40	1
42	41	1
43	42	1
44	43	2
45	44	2
46	45	2
47	46	2
48	47	2
49	48	2
50	49	2
51	50	2
52	51	2
53	52	2
54	53	2
55	54	2
56	55	2
57	56	2
58	57	2
59	58	2
60	59	2
61	60	2
62	61	2
63	62	2
64	63	2
65	64	2
66	65	2
67	66	2
68	67	2
69	68	2
70	69	2
71	70	2
72	71	2
73	72	2
74	73	2
75	74	2
76	75	2
77	76	2
78	77	2
79	78	2
80	79	2
81	80	2
82	81	2
83	82	2
84	83	2
85	84	1
91	86	5
92	87	3
93	85	4
94	88	4
95	89	5
96	90	4
97	91	5
98	92	5
99	93	4
100	94	1
101	95	5
102	96	4
103	97	4
104	98	4
105	99	4
107	101	5
108	102	5
109	103	5
110	104	5
111	105	4
113	106	4
114	107	2
115	108	4
116	109	2
117	110	2
118	111	5
119	112	5
120	113	4
121	114	2
122	115	3
123	116	5
124	117	2
125	118	2
126	119	5
127	120	4
128	121	2
129	122	5
130	123	2
131	100	2
132	124	2
133	125	2
134	126	4
135	127	5
136	128	1
137	3	2
138	129	1
139	130	4
140	131	5
141	132	2
142	133	1
\.


--
-- Data for Name: auth_user_user_permissions; Type: TABLE DATA; Schema: public; Owner: auth_user
--

COPY public.auth_user_user_permissions (id, user_id, permission_id) FROM stdin;
\.


--
-- Data for Name: django_admin_log; Type: TABLE DATA; Schema: public; Owner: auth_user
--

COPY public.django_admin_log (id, action_time, object_id, object_repr, action_flag, change_message, content_type_id, user_id) FROM stdin;
\.


--
-- Data for Name: django_celery_beat_clockedschedule; Type: TABLE DATA; Schema: public; Owner: auth_user
--

COPY public.django_celery_beat_clockedschedule (id, clocked_time) FROM stdin;
\.


--
-- Data for Name: django_celery_beat_crontabschedule; Type: TABLE DATA; Schema: public; Owner: auth_user
--

COPY public.django_celery_beat_crontabschedule (id, minute, hour, day_of_week, day_of_month, month_of_year, timezone) FROM stdin;
\.


--
-- Data for Name: django_celery_beat_intervalschedule; Type: TABLE DATA; Schema: public; Owner: auth_user
--

COPY public.django_celery_beat_intervalschedule (id, every, period) FROM stdin;
\.


--
-- Data for Name: django_celery_beat_periodictask; Type: TABLE DATA; Schema: public; Owner: auth_user
--

COPY public.django_celery_beat_periodictask (id, name, task, args, kwargs, queue, exchange, routing_key, expires, enabled, last_run_at, total_run_count, date_changed, description, crontab_id, interval_id, solar_id, one_off, start_time, priority, headers, clocked_id, expire_seconds) FROM stdin;
\.


--
-- Data for Name: django_celery_beat_periodictasks; Type: TABLE DATA; Schema: public; Owner: auth_user
--

COPY public.django_celery_beat_periodictasks (ident, last_update) FROM stdin;
\.


--
-- Data for Name: django_celery_beat_solarschedule; Type: TABLE DATA; Schema: public; Owner: auth_user
--

COPY public.django_celery_beat_solarschedule (id, event, latitude, longitude) FROM stdin;
\.


--
-- Data for Name: django_content_type; Type: TABLE DATA; Schema: public; Owner: auth_user
--

COPY public.django_content_type (id, app_label, model) FROM stdin;
1	admin	logentry
2	auth	permission
3	auth	group
4	contenttypes	contenttype
5	sessions	session
6	app	user
7	app	role
8	app	person
9	django_rest_passwordreset	resetpasswordtoken
10	auth	user
11	app_admin	establishment
12	app_admin	lawenforcement
13	app_admin	accesstoinformation
14	app_admin	formfields
15	app_admin	pedagogyarea
16	app_admin	tutorialvideo
17	app_admin	normativedocument
18	app_admin	frequentlyaskedquestions
19	app_admin	userestablishment
20	app_admin	email
21	app_admin	configuration
22	app_admin	typeorganization
23	app_admin	typeinstitution
24	app_admin	functionorganization
25	entity_app	establishmentextended
26	entity_app	publication
27	entity_app	typepublication
28	entity_app	typeformats
29	entity_app	tag
30	entity_app	filepublication
31	entity_app	activitylog
32	entity_app	userestablishmentextended
33	entity_app	attachment
34	entity_app	category
35	entity_app	solicity
36	entity_app	solicityresponse
37	entity_app	insistency
38	entity_app	extension
39	entity_app	columnfile
40	entity_app	templatefile
41	entity_app	numeral
42	entity_app	transparencyactive
43	entity_app	establishmentnumeral
44	entity_app	transparencyfocal
45	entity_app	transparencycolab
46	entity_app	timelinesolicity
47	django_celery_beat	crontabschedule
48	django_celery_beat	intervalschedule
49	django_celery_beat	periodictask
50	django_celery_beat	periodictasks
51	django_celery_beat	solarschedule
52	django_celery_beat	clockedschedule
\.


--
-- Data for Name: django_migrations; Type: TABLE DATA; Schema: public; Owner: auth_user
--

COPY public.django_migrations (id, app, name, applied) FROM stdin;
1	contenttypes	0001_initial	2024-07-23 05:48:49.642043+00
2	contenttypes	0002_remove_content_type_name	2024-07-23 05:48:49.652623+00
3	auth	0001_initial	2024-07-23 05:48:49.731015+00
4	auth	0002_alter_permission_name_max_length	2024-07-23 05:48:49.73739+00
5	auth	0003_alter_user_email_max_length	2024-07-23 05:48:49.74742+00
6	auth	0004_alter_user_username_opts	2024-07-23 05:48:49.755671+00
7	auth	0005_alter_user_last_login_null	2024-07-23 05:48:49.765217+00
8	auth	0006_require_contenttypes_0002	2024-07-23 05:48:49.768952+00
9	auth	0007_alter_validators_add_error_messages	2024-07-23 05:48:49.776877+00
10	auth	0008_alter_user_username_max_length	2024-07-23 05:48:49.783881+00
11	auth	0009_alter_user_last_name_max_length	2024-07-23 05:48:49.7903+00
12	auth	0010_alter_group_name_max_length	2024-07-23 05:48:49.7978+00
13	auth	0011_update_proxy_permissions	2024-07-23 05:48:49.807023+00
14	auth	0012_alter_user_first_name_max_length	2024-07-23 05:48:49.813951+00
15	app	0001_initial	2024-07-23 05:48:49.89416+00
16	admin	0001_initial	2024-07-23 05:48:49.935014+00
17	admin	0002_logentry_remove_auto_add	2024-07-23 05:48:49.947002+00
18	admin	0003_logentry_add_action_flag_choices	2024-07-23 05:48:49.959296+00
19	app	0002_role	2024-07-23 05:48:49.964631+00
20	app	0003_person	2024-07-23 05:48:49.994825+00
21	app	0004_alter_person_user	2024-07-23 05:48:50.01535+00
22	app	0005_alter_person_user	2024-07-23 05:48:50.028817+00
23	app	0006_remove_person_type_person_person_accept_terms_and_more	2024-07-23 05:48:50.083067+00
24	app	0007_person_age_range_alter_person_gender	2024-07-23 05:48:50.09985+00
25	app	0008_alter_person_options_alter_person_address_and_more	2024-07-23 05:48:50.149384+00
26	app	0009_alter_person_country	2024-07-23 05:48:50.159358+00
27	app	0010_create_procedure_auth_register	2024-07-23 05:48:50.172578+00
28	app	0011_user_ip	2024-07-23 05:48:50.192696+00
29	django_rest_passwordreset	0001_initial	2024-07-23 05:48:50.234927+00
30	django_rest_passwordreset	0002_pk_migration	2024-07-23 05:48:50.375039+00
31	django_rest_passwordreset	0003_allow_blank_and_null_fields	2024-07-23 05:48:50.400125+00
32	sessions	0001_initial	2024-07-23 05:48:50.432387+00
33	app_admin	0001_initial	2024-07-23 05:49:43.772789+00
34	app_admin	0002_alter_accesstoinformation_establishment_and_more	2024-07-23 05:49:43.787491+00
35	app_admin	0003_accesstoinformation_created_at_and_more	2024-07-23 05:49:43.87493+00
36	app_admin	0004_alter_accesstoinformation_options_and_more	2024-07-23 05:49:43.89173+00
37	app_admin	0005_formfields	2024-07-23 05:49:43.905277+00
38	app_admin	0006_alter_formfields_type_field	2024-07-23 05:49:43.91118+00
39	app_admin	0007_pedagogyarea_tutorialvideo_normativedocument_and_more	2024-07-23 05:49:43.981207+00
40	app_admin	0008_establishment_code	2024-07-23 05:49:43.990029+00
41	app_admin	0009_formfields_order	2024-07-23 05:49:43.99532+00
42	app_admin	0010_formfields_options_formfields_permission_required	2024-07-23 05:49:44.00411+00
43	app_admin	0011_formfields_content_type_formfields_object_id	2024-07-23 05:49:44.028677+00
44	app_admin	0012_userestablishment	2024-07-23 05:49:44.0652+00
45	app_admin	0013_establishment_is_active_alter_establishment_code	2024-07-23 05:49:44.097233+00
46	app_admin	0014_accesstoinformation_user_created_and_more	2024-07-23 05:49:44.865201+00
47	app_admin	0015_create_pedagogyare_functions	2024-07-23 05:49:45.028185+00
48	app_admin	0016_accesstoinformation_ip_configuration_ip_email_ip_and_more	2024-07-23 05:49:45.448455+00
49	app_admin	0017_alter_pedagogyarea_options_establishment_slug	2024-07-23 05:49:45.496265+00
50	app_admin	0018_establishment_address_typeorganization_and_more	2024-07-23 05:49:45.734806+00
51	app_admin	0019_establishment_identification	2024-07-23 05:49:45.77233+00
52	app_admin	0020_alter_configuration_options_establishment_visits	2024-07-23 05:49:45.829108+00
53	django_celery_beat	0001_initial	2024-07-23 05:50:58.46902+00
54	django_celery_beat	0002_auto_20161118_0346	2024-07-23 05:50:58.487146+00
55	django_celery_beat	0003_auto_20161209_0049	2024-07-23 05:50:58.499404+00
56	django_celery_beat	0004_auto_20170221_0000	2024-07-23 05:50:58.504984+00
57	django_celery_beat	0005_add_solarschedule_events_choices	2024-07-23 05:50:58.516003+00
58	django_celery_beat	0006_auto_20180322_0932	2024-07-23 05:50:58.541876+00
59	django_celery_beat	0007_auto_20180521_0826	2024-07-23 05:50:58.55649+00
60	django_celery_beat	0008_auto_20180914_1922	2024-07-23 05:50:58.579829+00
61	django_celery_beat	0006_auto_20180210_1226	2024-07-23 05:50:58.595399+00
62	django_celery_beat	0006_periodictask_priority	2024-07-23 05:50:58.604259+00
63	django_celery_beat	0009_periodictask_headers	2024-07-23 05:50:58.614043+00
64	django_celery_beat	0010_auto_20190429_0326	2024-07-23 05:50:58.829801+00
65	django_celery_beat	0011_auto_20190508_0153	2024-07-23 05:50:58.849719+00
66	django_celery_beat	0012_periodictask_expire_seconds	2024-07-23 05:50:58.86081+00
67	django_celery_beat	0013_auto_20200609_0727	2024-07-23 05:50:58.869861+00
68	django_celery_beat	0014_remove_clockedschedule_enabled	2024-07-23 05:50:58.876304+00
69	django_celery_beat	0015_edit_solarschedule_events_choices	2024-07-23 05:50:58.882806+00
70	django_celery_beat	0016_alter_crontabschedule_timezone	2024-07-23 05:50:58.891937+00
71	django_celery_beat	0017_alter_crontabschedule_month_of_year	2024-07-23 05:50:58.900249+00
72	django_celery_beat	0018_improve_crontab_helptext	2024-07-23 05:50:58.911011+00
73	entity_app	0001_initial	2024-07-23 05:50:59.308617+00
74	entity_app	0002_activitylog	2024-07-23 05:50:59.362196+00
75	entity_app	0003_remove_filepublication_publication_and_more	2024-07-23 05:50:59.470271+00
76	entity_app	0004_alter_filepublication_options_and_more	2024-07-23 05:50:59.561277+00
77	entity_app	0005_userestablishmentextended	2024-07-23 05:50:59.566379+00
78	entity_app	0006_alter_userestablishmentextended_table	2024-07-23 05:50:59.573272+00
79	entity_app	0007_publication_slug	2024-07-23 05:50:59.604785+00
80	entity_app	0008_publication_notes	2024-07-23 05:50:59.626016+00
81	entity_app	0009_attachment_publication_attachment	2024-07-23 05:50:59.717839+00
82	entity_app	0010_category_solicity_solicityresponse_insistency_and_more	2024-07-23 05:51:00.066698+00
83	entity_app	0011_columnfile_solicity_is_manual_templatefile_numeral_and_more	2024-07-23 05:51:00.667949+00
84	entity_app	0012_columnfile_format_columnfile_regex_columnfile_type	2024-07-23 05:51:00.815755+00
85	entity_app	0013_transparencyactive_max_date_to_publish_and_more	2024-07-23 05:51:01.054217+00
86	entity_app	0014_rename_title_solicity_address_remove_solicity_user_and_more	2024-07-23 05:51:01.681188+00
87	entity_app	0015_numeral_is_default	2024-07-23 05:51:01.734997+00
88	entity_app	0016_transparencyfocal_transparencycolab	2024-07-23 05:51:01.967314+00
89	entity_app	0017_rename_identification_solicity_city_and_more	2024-07-23 05:51:02.640212+00
90	entity_app	0018_alter_solicity_date	2024-07-23 05:51:02.684924+00
91	entity_app	0019_alter_timelinesolicity_status	2024-07-23 05:51:02.733514+00
92	entity_app	0020_numeral_type_transparency	2024-07-23 05:51:02.782215+00
93	entity_app	0021_alter_transparencycolab_unique_together_and_more	2024-07-23 05:51:02.879708+00
94	entity_app	0022_alter_solicityresponse_category	2024-07-23 05:51:02.960406+00
95	entity_app	0023_remove_solicityresponse_category	2024-07-23 05:51:03.007475+00
96	entity_app	0024_extension_attachments_extension_files_and_more	2024-07-23 05:51:03.43142+00
97	entity_app	0025_alter_establishmentextended_options_and_more	2024-07-23 05:51:03.564119+00
98	entity_app	0026_solicity_date_mail_send	2024-07-23 05:51:03.619977+00
\.


--
-- Data for Name: django_rest_passwordreset_resetpasswordtoken; Type: TABLE DATA; Schema: public; Owner: auth_user
--

COPY public.django_rest_passwordreset_resetpasswordtoken (created_at, key, ip_address, user_agent, user_id, id) FROM stdin;
\.


--
-- Data for Name: django_session; Type: TABLE DATA; Schema: public; Owner: auth_user
--

COPY public.django_session (session_key, session_data, expire_date) FROM stdin;
\.


--
-- Data for Name: entity_app_attachment; Type: TABLE DATA; Schema: public; Owner: auth_user
--

COPY public.entity_app_attachment (id, created_at, updated_at, deleted, deleted_at, ip, name, description, url_download, is_active, user_created_id, user_deleted_id, user_updated_id) FROM stdin;
\.


--
-- Data for Name: entity_app_category; Type: TABLE DATA; Schema: public; Owner: auth_user
--

COPY public.entity_app_category (id, created_at, updated_at, deleted, deleted_at, ip, name, description, is_active, user_created_id, user_deleted_id, user_updated_id) FROM stdin;
\.


--
-- Data for Name: entity_app_columnfile; Type: TABLE DATA; Schema: public; Owner: auth_user
--

COPY public.entity_app_columnfile (id, created_at, updated_at, deleted, deleted_at, ip, name, code, user_created_id, user_deleted_id, user_updated_id, format, regex, type) FROM stdin;
1	2024-05-18 15:31:34.913+00	2024-05-18 15:31:34.913+00	f	\N	\N	Organización Política o Alianza	organizacion-politica-o-alianza	\N	\N	\N	\N	\N	str
2	2024-05-18 15:31:34.924+00	2024-05-18 15:31:34.924+00	f	\N	\N	Proceso Electoral	proceso-electoral	\N	\N	\N	\N	\N	str
3	2024-05-18 15:31:34.934+00	2024-05-18 15:31:34.934+00	f	\N	\N	Mes	mes	\N	\N	\N	\N	\N	str
4	2024-05-18 15:31:34.943+00	2024-05-18 15:31:34.943+00	f	\N	\N	Dignidad	dignidad	\N	\N	\N	\N	\N	str
5	2024-05-18 15:31:34.952+00	2024-05-18 15:31:34.952+00	f	\N	\N	Provincia	provincia	\N	\N	\N	\N	\N	str
6	2024-05-18 15:31:34.962+00	2024-05-18 15:31:34.962+00	f	\N	\N	Circunscripción	circunscripcion	\N	\N	\N	\N	\N	str
7	2024-05-18 15:31:34.971+00	2024-05-18 15:31:34.971+00	f	\N	\N	Cantón	canton	\N	\N	\N	\N	\N	str
8	2024-05-18 15:31:34.981+00	2024-05-18 15:31:34.981+00	f	\N	\N	Parroquia	parroquia	\N	\N	\N	\N	\N	str
9	2024-05-18 15:31:34.99+00	2024-05-18 15:31:34.99+00	f	\N	\N	Código Cuenta	codigo-cuenta	\N	\N	\N	\N	\N	str
10	2024-05-18 15:31:34.999+00	2024-05-18 15:31:34.999+00	f	\N	\N	Cuenta	cuenta	\N	\N	\N	\N	\N	str
11	2024-05-18 15:31:35.011+00	2024-05-18 15:31:35.011+00	f	\N	\N	Código Subcuenta	codigo-subcuenta	\N	\N	\N	\N	\N	str
12	2024-05-18 15:31:35.021+00	2024-05-18 15:31:35.021+00	f	\N	\N	Subcuenta	subcuenta	\N	\N	\N	\N	\N	str
13	2024-05-18 15:31:35.032+00	2024-05-18 15:31:35.032+00	f	\N	\N	Fecha Comprobante de Venta	fecha-comprobante-de-venta	\N	\N	\N	\N	\N	str
14	2024-05-18 15:31:35.042+00	2024-05-18 15:31:35.042+00	f	\N	\N	Nro. Comprobante de Venta	nro-comprobante-de-venta	\N	\N	\N	\N	\N	str
15	2024-05-18 15:31:35.053+00	2024-05-18 15:31:35.053+00	f	\N	\N	Nro. RUC del Proveedor	nro-ruc-del-proveedor	\N	\N	\N	\N	\N	str
16	2024-05-18 15:31:35.063+00	2024-05-18 15:31:35.063+00	f	\N	\N	Nombre del Proveedor	nombre-del-proveedor	\N	\N	\N	\N	\N	str
17	2024-05-18 15:31:35.074+00	2024-05-18 15:31:35.074+00	f	\N	\N	Descripción del Gasto	descripcion-del-gasto	\N	\N	\N	\N	\N	str
18	2024-05-18 15:31:35.084+00	2024-05-18 15:31:35.084+00	f	\N	\N	Subtotal	subtotal	\N	\N	\N	\N	\N	str
19	2024-05-18 15:31:35.094+00	2024-05-18 15:31:35.094+00	f	\N	\N	IVA	iva	\N	\N	\N	\N	\N	str
20	2024-05-18 15:31:35.104+00	2024-05-18 15:31:35.104+00	f	\N	\N	Total	total	\N	\N	\N	\N	\N	str
21	2024-05-18 15:31:35.12+00	2024-05-18 15:31:35.12+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion	\N	\N	\N	\N	\N	str
22	2024-05-18 15:31:35.129+00	2024-05-18 15:31:35.129+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion	\N	\N	\N	\N	\N	str
23	2024-05-18 15:31:35.137+00	2024-05-18 15:31:35.137+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion	\N	\N	\N	\N	\N	str
24	2024-05-18 15:31:35.145+00	2024-05-18 15:31:35.146+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion	\N	\N	\N	\N	\N	str
25	2024-05-18 15:31:35.153+00	2024-05-18 15:31:35.153+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion	\N	\N	\N	\N	\N	str
26	2024-05-18 15:31:35.162+00	2024-05-18 15:31:35.162+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion	\N	\N	\N	\N	\N	str
27	2024-05-18 15:31:35.171+00	2024-05-18 15:31:35.171+00	f	\N	\N	LICENCIA	licencia	\N	\N	\N	\N	\N	str
28	2024-05-18 15:31:35.187+00	2024-05-18 15:31:35.187+00	f	\N	\N	Institución	institucion	\N	\N	\N	\N	\N	str
29	2024-05-18 15:31:35.196+00	2024-05-18 15:31:35.196+00	f	\N	\N	Descripción	descripcion	\N	\N	\N	\N	\N	str
30	2024-05-18 15:31:35.206+00	2024-05-18 15:31:35.206+00	f	\N	\N	Nombre del campo	nombre-del-campo	\N	\N	\N	\N	\N	str
31	2024-05-18 15:31:35.218+00	2024-05-18 15:31:35.218+00	f	\N	\N	Organización Política o Alianza	organizacion-politica-o-alianza-olzf	\N	\N	\N	\N	\N	str
32	2024-05-18 15:31:35.23+00	2024-05-18 15:31:35.23+00	f	\N	\N	Proceso Electoral	proceso-electoral-k05c	\N	\N	\N	\N	\N	str
33	2024-05-18 15:31:35.242+00	2024-05-18 15:31:35.242+00	f	\N	\N	Mes	mes-qgmo	\N	\N	\N	\N	\N	str
34	2024-05-18 15:31:35.255+00	2024-05-18 15:31:35.255+00	f	\N	\N	Dignidad	dignidad-vx08	\N	\N	\N	\N	\N	str
35	2024-05-18 15:31:35.267+00	2024-05-18 15:31:35.267+00	f	\N	\N	Provincia	provincia-nb68	\N	\N	\N	\N	\N	str
36	2024-05-18 15:31:35.278+00	2024-05-18 15:31:35.278+00	f	\N	\N	Circunscripción	circunscripcion-nmmi	\N	\N	\N	\N	\N	str
37	2024-05-18 15:31:35.289+00	2024-05-18 15:31:35.289+00	f	\N	\N	Cantón	canton-8bs1	\N	\N	\N	\N	\N	str
38	2024-05-18 15:31:35.3+00	2024-05-18 15:31:35.3+00	f	\N	\N	Parroquia	parroquia-r30d	\N	\N	\N	\N	\N	str
39	2024-05-18 15:31:35.312+00	2024-05-18 15:31:35.312+00	f	\N	\N	Código Cuenta	codigo-cuenta-x2tz	\N	\N	\N	\N	\N	str
40	2024-05-18 15:31:35.322+00	2024-05-18 15:31:35.322+00	f	\N	\N	Cuenta	cuenta-u0ju	\N	\N	\N	\N	\N	str
41	2024-05-18 15:31:35.332+00	2024-05-18 15:31:35.332+00	f	\N	\N	Código Subcuenta	codigo-subcuenta-a2bq	\N	\N	\N	\N	\N	str
42	2024-05-18 15:31:35.344+00	2024-05-18 15:31:35.344+00	f	\N	\N	Fecha Comprobante de Venta	fecha-comprobante-de-venta-xfnm	\N	\N	\N	\N	\N	str
43	2024-05-18 15:31:35.355+00	2024-05-18 15:31:35.355+00	f	\N	\N	Nro. Comprobante de Venta	nro-comprobante-de-venta-qbm2	\N	\N	\N	\N	\N	str
44	2024-05-18 15:31:35.365+00	2024-05-18 15:31:35.365+00	f	\N	\N	Nro. RUC del Proveedor	nro-ruc-del-proveedor-dv4j	\N	\N	\N	\N	\N	str
45	2024-05-18 15:31:35.376+00	2024-05-18 15:31:35.376+00	f	\N	\N	Nombre del Proveedor	nombre-del-proveedor-fkoq	\N	\N	\N	\N	\N	str
46	2024-05-18 15:31:35.385+00	2024-05-18 15:31:35.385+00	f	\N	\N	Descripción del Gasto	descripcion-del-gasto-ybq5	\N	\N	\N	\N	\N	str
47	2024-05-18 15:31:35.396+00	2024-05-18 15:31:35.396+00	f	\N	\N	Subtotal	subtotal-5ouk	\N	\N	\N	\N	\N	str
48	2024-05-18 15:31:35.406+00	2024-05-18 15:31:35.406+00	f	\N	\N	IVA	iva-hsjz	\N	\N	\N	\N	\N	str
49	2024-05-18 15:31:35.417+00	2024-05-18 15:31:35.417+00	f	\N	\N	Total	total-b6e6	\N	\N	\N	\N	\N	str
50	2024-05-18 15:31:35.435+00	2024-05-18 15:31:35.435+00	f	\N	\N	Numeración	numeracion	\N	\N	\N	\N	\N	str
51	2024-05-18 15:31:35.445+00	2024-05-18 15:31:35.445+00	f	\N	\N	Puesto Institucional 	puesto-institucional	\N	\N	\N	\N	\N	str
52	2024-05-18 15:31:35.452+00	2024-05-18 15:31:35.452+00	f	\N	\N	Régimen laboral al que pertenece 	regimen-laboral-al-que-pertenece	\N	\N	\N	\N	\N	str
53	2024-05-18 15:31:35.459+00	2024-05-18 15:31:35.459+00	f	\N	\N	Número de partida presupuestaria	numero-de-partida-presupuestaria	\N	\N	\N	\N	\N	str
54	2024-05-18 15:31:35.465+00	2024-05-18 15:31:35.465+00	f	\N	\N	Grado jerárquico o escala al que pertenece el puesto	grado-jerarquico-o-escala-al-que-pertenece-el-puesto	\N	\N	\N	\N	\N	str
55	2024-05-18 15:31:35.473+00	2024-05-18 15:31:35.473+00	f	\N	\N	Remuneración mensual unificada	remuneracion-mensual-unificada	\N	\N	\N	\N	\N	str
56	2024-05-18 15:31:35.482+00	2024-05-18 15:31:35.482+00	f	\N	\N	Remuneración unificada (anual)	remuneracion-unificada-anual	\N	\N	\N	\N	\N	str
57	2024-05-18 15:31:35.491+00	2024-05-18 15:31:35.491+00	f	\N	\N	Décimo Tercera Remuneración	decimo-tercera-remuneracion	\N	\N	\N	\N	\N	str
58	2024-05-18 15:31:35.5+00	2024-05-18 15:31:35.5+00	f	\N	\N	Décima Cuarta Remuneración	decima-cuarta-remuneracion	\N	\N	\N	\N	\N	str
59	2024-05-18 15:31:35.509+00	2024-05-18 15:31:35.509+00	f	\N	\N	Horas suplementarias y extraordinarias	horas-suplementarias-y-extraordinarias	\N	\N	\N	\N	\N	str
60	2024-05-18 15:31:35.517+00	2024-05-18 15:31:35.517+00	f	\N	\N	Encargos y subrogaciones	encargos-y-subrogaciones	\N	\N	\N	\N	\N	str
61	2024-05-18 15:31:35.525+00	2024-05-18 15:31:35.525+00	f	\N	\N	Total ingresos adicionales	total-ingresos-adicionales	\N	\N	\N	\N	\N	str
62	2024-05-18 15:31:35.543+00	2024-05-18 15:31:35.544+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN	fecha-actualizacion-de-la-informacion-gkq7	\N	\N	\N	\N	\N	str
63	2024-05-18 15:31:35.553+00	2024-05-18 15:31:35.553+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN	periodicidad-de-actualizacion-de-la-informacion-1bx2	\N	\N	\N	\N	\N	str
64	2024-05-18 15:31:35.563+00	2024-05-18 15:31:35.563+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACION	unidad-poseedora-de-la-informacion-99zc	\N	\N	\N	\N	\N	str
65	2024-05-18 15:31:35.574+00	2024-05-18 15:31:35.574+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	persona-responsable-de-la-unidad-poseedora-de-la-informacion-uclb	\N	\N	\N	\N	\N	str
66	2024-05-18 15:31:35.583+00	2024-05-18 15:31:35.583+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-tjq7	\N	\N	\N	\N	\N	str
67	2024-05-18 15:31:35.593+00	2024-05-18 15:31:35.593+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-xwld	\N	\N	\N	\N	\N	str
68	2024-05-18 15:31:35.602+00	2024-05-18 15:31:35.602+00	f	\N	\N	LICENCIA	licencia-lxuo	\N	\N	\N	\N	\N	str
69	2024-05-18 15:31:35.619+00	2024-05-18 15:31:35.619+00	f	\N	\N	Institución	institucion-3g0q	\N	\N	\N	\N	\N	str
70	2024-05-18 15:31:35.629+00	2024-05-18 15:31:35.629+00	f	\N	\N	Descripción	descripcion-ok8l	\N	\N	\N	\N	\N	str
71	2024-05-18 15:31:35.638+00	2024-05-18 15:31:35.638+00	f	\N	\N	Nombre del Campo	nombre-del-campo-7vha	\N	\N	\N	\N	\N	str
72	2024-05-18 15:31:35.649+00	2024-05-18 15:31:35.649+00	f	\N	\N	Numeración	numeracion-vvge	\N	\N	\N	\N	\N	str
73	2024-05-18 15:31:35.66+00	2024-05-18 15:31:35.66+00	f	\N	\N	Puesto Institucional 	puesto-institucional-mc9k	\N	\N	\N	\N	\N	str
74	2024-05-18 15:31:35.67+00	2024-05-18 15:31:35.67+00	f	\N	\N	Régimen laboral al que pertenece 	regimen-laboral-al-que-pertenece-w6ql	\N	\N	\N	\N	\N	str
75	2024-05-18 15:31:35.68+00	2024-05-18 15:31:35.68+00	f	\N	\N	Número de partida presupuestaria	numero-de-partida-presupuestaria-4clv	\N	\N	\N	\N	\N	str
76	2024-05-18 15:31:35.691+00	2024-05-18 15:31:35.691+00	f	\N	\N	Grado jerárquico o escala al que pertenece el puesto	grado-jerarquico-o-escala-al-que-pertenece-el-puesto-hqcx	\N	\N	\N	\N	\N	str
77	2024-05-18 15:31:35.701+00	2024-05-18 15:31:35.701+00	f	\N	\N	Remuneración mensual unificada	remuneracion-mensual-unificada-ib0v	\N	\N	\N	\N	\N	str
78	2024-05-18 15:31:35.711+00	2024-05-18 15:31:35.711+00	f	\N	\N	Remuneración unificada (anual)	remuneracion-unificada-anual-segp	\N	\N	\N	\N	\N	str
79	2024-05-18 15:31:35.721+00	2024-05-18 15:31:35.721+00	f	\N	\N	Décimo Tercera Remuneración	decimo-tercera-remuneracion-eeid	\N	\N	\N	\N	\N	str
80	2024-05-18 15:31:35.732+00	2024-05-18 15:31:35.732+00	f	\N	\N	Décima Cuarta Remuneración	decima-cuarta-remuneracion-iren	\N	\N	\N	\N	\N	str
81	2024-05-18 15:31:35.742+00	2024-05-18 15:31:35.742+00	f	\N	\N	Horas suplementarias y extraordinarias	horas-suplementarias-y-extraordinarias-auow	\N	\N	\N	\N	\N	str
82	2024-05-18 15:31:35.751+00	2024-05-18 15:31:35.751+00	f	\N	\N	Encargos y subrogaciones	encargos-y-subrogaciones-gik9	\N	\N	\N	\N	\N	str
83	2024-05-18 15:31:35.761+00	2024-05-18 15:31:35.761+00	f	\N	\N	Total ingresos adicionales	total-ingresos-adicionales-xg8s	\N	\N	\N	\N	\N	str
84	2024-05-18 15:31:35.782+00	2024-05-18 15:31:35.782+00	f	\N	\N	Nombre de Entidad	nombre-de-entidad	\N	\N	\N	\N	\N	str
85	2024-05-18 15:31:35.791+00	2024-05-18 15:31:35.791+00	f	\N	\N	Fecha	fecha	\N	\N	\N	\N	\N	str
86	2024-05-18 15:31:35.801+00	2024-05-18 15:31:35.801+00	f	\N	\N	Nombre de Informe	nombre-de-informe	\N	\N	\N	\N	\N	str
87	2024-05-18 15:31:35.811+00	2024-05-18 15:31:35.812+00	f	\N	\N	Enlace a Informe	enlace-a-informe	\N	\N	\N	\N	\N	str
88	2024-05-18 15:31:35.83+00	2024-05-18 15:31:35.831+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-wnlr	\N	\N	\N	\N	\N	str
89	2024-05-18 15:31:35.843+00	2024-05-18 15:31:35.843+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-tfy9	\N	\N	\N	\N	\N	str
90	2024-05-18 15:31:35.855+00	2024-05-18 15:31:35.855+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-gg2l	\N	\N	\N	\N	\N	str
91	2024-05-18 15:31:35.867+00	2024-05-18 15:31:35.867+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-0pgi	\N	\N	\N	\N	\N	str
92	2024-05-18 15:31:35.879+00	2024-05-18 15:31:35.879+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-mgsd	\N	\N	\N	\N	\N	str
93	2024-05-18 15:31:35.892+00	2024-05-18 15:31:35.892+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-1vn1	\N	\N	\N	\N	\N	str
94	2024-05-18 15:31:35.905+00	2024-05-18 15:31:35.905+00	f	\N	\N	LICENCIA	licencia-y7c0	\N	\N	\N	\N	\N	str
95	2024-05-18 15:31:35.927+00	2024-05-18 15:31:35.927+00	f	\N	\N	Institución	institucion-ej6n	\N	\N	\N	\N	\N	str
96	2024-05-18 15:31:35.939+00	2024-05-18 15:31:35.939+00	f	\N	\N	Descripción	descripcion-5j0h	\N	\N	\N	\N	\N	str
97	2024-05-18 15:31:35.951+00	2024-05-18 15:31:35.951+00	f	\N	\N	Nombre del campo	nombre-del-campo-r62q	\N	\N	\N	\N	\N	str
98	2024-05-18 15:31:35.973+00	2024-05-18 15:31:35.973+00	f	\N	\N	Nombre de Entidad	nombre-de-entidad-ji6t	\N	\N	\N	\N	\N	str
99	2024-05-18 15:31:35.986+00	2024-05-18 15:31:35.986+00	f	\N	\N	Fecha	fecha-s18k	\N	\N	\N	\N	\N	str
100	2024-05-18 15:31:35.998+00	2024-05-18 15:31:35.998+00	f	\N	\N	Nombre de Informe	nombre-de-informe-wnna	\N	\N	\N	\N	\N	str
101	2024-05-18 15:31:36.01+00	2024-05-18 15:31:36.01+00	f	\N	\N	Enlace a Informe	enlace-a-informe-4auw	\N	\N	\N	\N	\N	str
102	2024-05-18 15:31:36.031+00	2024-05-18 15:31:36.031+00	f	\N	\N	Tipo	tipo	\N	\N	\N	\N	\N	str
103	2024-05-18 15:31:36.041+00	2024-05-18 15:31:36.041+00	f	\N	\N	Fecha de suscripción	fecha-de-suscripcion	\N	\N	\N	\N	\N	str
104	2024-05-18 15:31:36.051+00	2024-05-18 15:31:36.051+00	f	\N	\N	Objeto	objeto	\N	\N	\N	\N	\N	str
105	2024-05-18 15:31:36.061+00	2024-05-18 15:31:36.061+00	f	\N	\N	Nombre de la organización o persona jurídica	nombre-de-la-organizacion-o-persona-juridica	\N	\N	\N	\N	\N	str
106	2024-05-18 15:31:36.071+00	2024-05-18 15:31:36.071+00	f	\N	\N	Plazo de duración	plazo-de-duracion	\N	\N	\N	\N	\N	str
107	2024-05-18 15:31:36.081+00	2024-05-18 15:31:36.081+00	f	\N	\N	Enlace para descargar el convenio	enlace-para-descargar-el-convenio	\N	\N	\N	\N	\N	str
108	2024-05-18 15:31:36.1+00	2024-05-18 15:31:36.1+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN	fecha-actualizacion-de-la-informacion-3abv	\N	\N	\N	\N	\N	str
109	2024-05-18 15:31:36.112+00	2024-05-18 15:31:36.112+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN	periodicidad-de-actualizacion-de-la-informacion-o7uz	\N	\N	\N	\N	\N	str
110	2024-05-18 15:31:36.124+00	2024-05-18 15:31:36.124+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN	unidad-poseedora-de-la-informacion-zwyw	\N	\N	\N	\N	\N	str
111	2024-05-18 15:31:36.135+00	2024-05-18 15:31:36.135+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	persona-responsable-de-la-unidad-poseedora-de-la-informacion-spsc	\N	\N	\N	\N	\N	str
112	2024-05-18 15:31:36.147+00	2024-05-18 15:31:36.147+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-wv3p	\N	\N	\N	\N	\N	str
113	2024-05-18 15:31:36.159+00	2024-05-18 15:31:36.159+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-pqiu	\N	\N	\N	\N	\N	str
114	2024-05-18 15:31:36.171+00	2024-05-18 15:31:36.171+00	f	\N	\N	LICENCIA	licencia-mliu	\N	\N	\N	\N	\N	str
115	2024-05-18 15:31:36.192+00	2024-05-18 15:31:36.192+00	f	\N	\N	Institución	institucion-wxa0	\N	\N	\N	\N	\N	str
116	2024-05-18 15:31:36.203+00	2024-05-18 15:31:36.203+00	f	\N	\N	Descripción	descripcion-0in8	\N	\N	\N	\N	\N	str
117	2024-05-18 15:31:36.215+00	2024-05-18 15:31:36.215+00	f	\N	\N	Nombre del campo	nombre-del-campo-8xz0	\N	\N	\N	\N	\N	str
118	2024-05-18 15:31:36.228+00	2024-05-18 15:31:36.229+00	f	\N	\N	Tipo	tipo-2jmr	\N	\N	\N	\N	\N	str
119	2024-05-18 15:31:36.241+00	2024-05-18 15:31:36.241+00	f	\N	\N	Fecha de suscripción	fecha-de-suscripcion-rhu7	\N	\N	\N	\N	\N	str
120	2024-05-18 15:31:36.252+00	2024-05-18 15:31:36.252+00	f	\N	\N	Objeto del convenio	objeto-del-convenio	\N	\N	\N	\N	\N	str
121	2024-05-18 15:31:36.264+00	2024-05-18 15:31:36.265+00	f	\N	\N	Nombre de la organización o persona jurídica	nombre-de-la-organizacion-o-persona-juridica-z6jf	\N	\N	\N	\N	\N	str
122	2024-05-18 15:31:36.278+00	2024-05-18 15:31:36.278+00	f	\N	\N	Plazo de duración	plazo-de-duracion-g5fs	\N	\N	\N	\N	\N	str
123	2024-05-18 15:31:36.29+00	2024-05-18 15:31:36.29+00	f	\N	\N	Enlace para descargar el convenio	enlace-para-descargar-el-convenio-6k44	\N	\N	\N	\N	\N	str
124	2024-05-18 15:31:36.313+00	2024-05-18 15:31:36.313+00	f	\N	\N	Nombre de Entidad 	nombre-de-entidad-codp	\N	\N	\N	\N	\N	str
125	2024-05-18 15:31:36.322+00	2024-05-18 15:31:36.322+00	f	\N	\N	Número de Resolución o Informe	numero-de-resolucion-o-informe	\N	\N	\N	\N	\N	str
126	2024-05-18 15:31:36.335+00	2024-05-18 15:31:36.335+00	f	\N	\N	Fecha	fecha-fnas	\N	\N	\N	\N	\N	str
127	2024-05-18 15:31:36.348+00	2024-05-18 15:31:36.348+00	f	\N	\N	Descripción	descripcion-uiei	\N	\N	\N	\N	\N	str
128	2024-05-18 15:31:36.359+00	2024-05-18 15:31:36.359+00	f	\N	\N	Enlace 	enlace	\N	\N	\N	\N	\N	str
129	2024-05-18 15:31:36.376+00	2024-05-18 15:31:36.376+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-1f1f	\N	\N	\N	\N	\N	str
314	2024-05-18 15:31:38.495+00	2024-05-18 15:31:38.495+00	f	\N	\N	Enlace para acceder al reporte del servicio	enlace-para-acceder-al-reporte-del-servicio	\N	\N	\N	\N	\N	str
130	2024-05-18 15:31:36.388+00	2024-05-18 15:31:36.388+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-veb8	\N	\N	\N	\N	\N	str
131	2024-05-18 15:31:36.4+00	2024-05-18 15:31:36.4+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-leby	\N	\N	\N	\N	\N	str
132	2024-05-18 15:31:36.412+00	2024-05-18 15:31:36.412+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-f5gj	\N	\N	\N	\N	\N	str
133	2024-05-18 15:31:36.423+00	2024-05-18 15:31:36.424+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-ygct	\N	\N	\N	\N	\N	str
134	2024-05-18 15:31:36.434+00	2024-05-18 15:31:36.434+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-upk5	\N	\N	\N	\N	\N	str
135	2024-05-18 15:31:36.445+00	2024-05-18 15:31:36.445+00	f	\N	\N	LICENCIA	licencia-p2cc	\N	\N	\N	\N	\N	str
136	2024-05-18 15:31:36.463+00	2024-05-18 15:31:36.463+00	f	\N	\N	Institución	institucion-05a2	\N	\N	\N	\N	\N	str
137	2024-05-18 15:31:36.475+00	2024-05-18 15:31:36.475+00	f	\N	\N	Descripción	descripcion-akkr	\N	\N	\N	\N	\N	str
138	2024-05-18 15:31:36.488+00	2024-05-18 15:31:36.488+00	f	\N	\N	Nombre del campo	nombre-del-campo-q4hy	\N	\N	\N	\N	\N	str
139	2024-05-18 15:31:36.498+00	2024-05-18 15:31:36.498+00	f	\N	\N	Nombre de Entidad 	nombre-de-entidad-6lyg	\N	\N	\N	\N	\N	str
140	2024-05-18 15:31:36.508+00	2024-05-18 15:31:36.508+00	f	\N	\N	Número de Resolución o Informe	numero-de-resolucion-o-informe-uqja	\N	\N	\N	\N	\N	str
141	2024-05-18 15:31:36.518+00	2024-05-18 15:31:36.518+00	f	\N	\N	Fecha	fecha-eo6u	\N	\N	\N	\N	\N	str
142	2024-05-18 15:31:36.528+00	2024-05-18 15:31:36.528+00	f	\N	\N	Descripción	descripcion-8b5j	\N	\N	\N	\N	\N	str
143	2024-05-18 15:31:36.538+00	2024-05-18 15:31:36.538+00	f	\N	\N	Enlace 	enlace-db6b	\N	\N	\N	\N	\N	str
144	2024-05-18 15:31:36.556+00	2024-05-18 15:31:36.556+00	f	\N	\N	Nombre de Entidad 	nombre-de-entidad-f36q	\N	\N	\N	\N	\N	str
145	2024-05-18 15:31:36.566+00	2024-05-18 15:31:36.566+00	f	\N	\N	Número de Resolución o Informe	numero-de-resolucion-o-informe-y6w0	\N	\N	\N	\N	\N	str
146	2024-05-18 15:31:36.577+00	2024-05-18 15:31:36.577+00	f	\N	\N	Fecha	fecha-9fqe	\N	\N	\N	\N	\N	str
147	2024-05-18 15:31:36.587+00	2024-05-18 15:31:36.587+00	f	\N	\N	Descripción	descripcion-ya91	\N	\N	\N	\N	\N	str
148	2024-05-18 15:31:36.598+00	2024-05-18 15:31:36.598+00	f	\N	\N	Enlace 	enlace-iqje	\N	\N	\N	\N	\N	str
149	2024-05-18 15:31:36.614+00	2024-05-18 15:31:36.614+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-fje8	\N	\N	\N	\N	\N	str
150	2024-05-18 15:31:36.624+00	2024-05-18 15:31:36.624+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-6qkh	\N	\N	\N	\N	\N	str
151	2024-05-18 15:31:36.634+00	2024-05-18 15:31:36.634+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-5x9s	\N	\N	\N	\N	\N	str
152	2024-05-18 15:31:36.645+00	2024-05-18 15:31:36.645+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-9lz9	\N	\N	\N	\N	\N	str
153	2024-05-18 15:31:36.655+00	2024-05-18 15:31:36.655+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-k79u	\N	\N	\N	\N	\N	str
154	2024-05-18 15:31:36.665+00	2024-05-18 15:31:36.665+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-wfiv	\N	\N	\N	\N	\N	str
155	2024-05-18 15:31:36.676+00	2024-05-18 15:31:36.676+00	f	\N	\N	LICENCIA	licencia-xy27	\N	\N	\N	\N	\N	str
156	2024-05-18 15:31:36.694+00	2024-05-18 15:31:36.694+00	f	\N	\N	Institución	institucion-ylt5	\N	\N	\N	\N	\N	str
157	2024-05-18 15:31:36.704+00	2024-05-18 15:31:36.704+00	f	\N	\N	Descripción	descripcion-al3z	\N	\N	\N	\N	\N	str
158	2024-05-18 15:31:36.716+00	2024-05-18 15:31:36.716+00	f	\N	\N	Nombre del campo	nombre-del-campo-0v8d	\N	\N	\N	\N	\N	str
159	2024-05-18 15:31:36.727+00	2024-05-18 15:31:36.727+00	f	\N	\N	Nombre de Entidad 	nombre-de-entidad-f4cx	\N	\N	\N	\N	\N	str
160	2024-05-18 15:31:36.737+00	2024-05-18 15:31:36.737+00	f	\N	\N	Número de Resolución o Informe	numero-de-resolucion-o-informe-lg36	\N	\N	\N	\N	\N	str
161	2024-05-18 15:31:36.747+00	2024-05-18 15:31:36.747+00	f	\N	\N	Fecha	fecha-ka2q	\N	\N	\N	\N	\N	str
162	2024-05-18 15:31:36.757+00	2024-05-18 15:31:36.757+00	f	\N	\N	Descripción	descripcion-kh7y	\N	\N	\N	\N	\N	str
163	2024-05-18 15:31:36.767+00	2024-05-18 15:31:36.767+00	f	\N	\N	Enlace 	enlace-92u5	\N	\N	\N	\N	\N	str
164	2024-05-18 15:31:36.783+00	2024-05-18 15:31:36.783+00	f	\N	\N	Nombre de Entidad 	nombre-de-entidad-rixj	\N	\N	\N	\N	\N	str
165	2024-05-18 15:31:36.794+00	2024-05-18 15:31:36.794+00	f	\N	\N	Número de Resolución o Informe	numero-de-resolucion-o-informe-j4k5	\N	\N	\N	\N	\N	str
166	2024-05-18 15:31:36.804+00	2024-05-18 15:31:36.804+00	f	\N	\N	Fecha	fecha-8p00	\N	\N	\N	\N	\N	str
167	2024-05-18 15:31:36.814+00	2024-05-18 15:31:36.814+00	f	\N	\N	Descripción	descripcion-bftq	\N	\N	\N	\N	\N	str
168	2024-05-18 15:31:36.824+00	2024-05-18 15:31:36.824+00	f	\N	\N	Enlace 	enlace-fbvk	\N	\N	\N	\N	\N	str
169	2024-05-18 15:31:36.841+00	2024-05-18 15:31:36.841+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-8j89	\N	\N	\N	\N	\N	str
170	2024-05-18 15:31:36.851+00	2024-05-18 15:31:36.851+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-tyaf	\N	\N	\N	\N	\N	str
171	2024-05-18 15:31:36.861+00	2024-05-18 15:31:36.861+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-ux17	\N	\N	\N	\N	\N	str
172	2024-05-18 15:31:36.871+00	2024-05-18 15:31:36.871+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-og8u	\N	\N	\N	\N	\N	str
173	2024-05-18 15:31:36.881+00	2024-05-18 15:31:36.881+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-6v1l	\N	\N	\N	\N	\N	str
174	2024-05-18 15:31:36.891+00	2024-05-18 15:31:36.891+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-39lu	\N	\N	\N	\N	\N	str
175	2024-05-18 15:31:36.901+00	2024-05-18 15:31:36.901+00	f	\N	\N	LICENCIA	licencia-oby0	\N	\N	\N	\N	\N	str
176	2024-05-18 15:31:36.917+00	2024-05-18 15:31:36.917+00	f	\N	\N	Institución	institucion-d2zy	\N	\N	\N	\N	\N	str
177	2024-05-18 15:31:36.927+00	2024-05-18 15:31:36.927+00	f	\N	\N	Descripción	descripcion-mwov	\N	\N	\N	\N	\N	str
178	2024-05-18 15:31:36.937+00	2024-05-18 15:31:36.937+00	f	\N	\N	Nombre del campo	nombre-del-campo-2p66	\N	\N	\N	\N	\N	str
179	2024-05-18 15:31:36.95+00	2024-05-18 15:31:36.95+00	f	\N	\N	Nombre de Entidad 	nombre-de-entidad-ktnn	\N	\N	\N	\N	\N	str
180	2024-05-18 15:31:36.96+00	2024-05-18 15:31:36.96+00	f	\N	\N	Número de Resolución o Informe	numero-de-resolucion-o-informe-96o0	\N	\N	\N	\N	\N	str
181	2024-05-18 15:31:36.971+00	2024-05-18 15:31:36.971+00	f	\N	\N	Fecha	fecha-vscb	\N	\N	\N	\N	\N	str
182	2024-05-18 15:31:36.981+00	2024-05-18 15:31:36.981+00	f	\N	\N	Descripción	descripcion-oi30	\N	\N	\N	\N	\N	str
183	2024-05-18 15:31:36.992+00	2024-05-18 15:31:36.992+00	f	\N	\N	Enlace 	enlace-diuh	\N	\N	\N	\N	\N	str
184	2024-05-18 15:31:37.01+00	2024-05-18 15:31:37.01+00	f	\N	\N	Nombre de Entidad 	nombre-de-entidad-te3a	\N	\N	\N	\N	\N	str
185	2024-05-18 15:31:37.02+00	2024-05-18 15:31:37.02+00	f	\N	\N	Número de Resolución o Informe	numero-de-resolucion-o-informe-2jl6	\N	\N	\N	\N	\N	str
186	2024-05-18 15:31:37.03+00	2024-05-18 15:31:37.03+00	f	\N	\N	Fecha	fecha-f2jz	\N	\N	\N	\N	\N	str
187	2024-05-18 15:31:37.039+00	2024-05-18 15:31:37.039+00	f	\N	\N	Descripción	descripcion-wsha	\N	\N	\N	\N	\N	str
188	2024-05-18 15:31:37.049+00	2024-05-18 15:31:37.049+00	f	\N	\N	Enlace 	enlace-o8la	\N	\N	\N	\N	\N	str
189	2024-05-18 15:31:37.066+00	2024-05-18 15:31:37.066+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-pakv	\N	\N	\N	\N	\N	str
190	2024-05-18 15:31:37.076+00	2024-05-18 15:31:37.076+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-tn9n	\N	\N	\N	\N	\N	str
191	2024-05-18 15:31:37.085+00	2024-05-18 15:31:37.085+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-1uyk	\N	\N	\N	\N	\N	str
192	2024-05-18 15:31:37.095+00	2024-05-18 15:31:37.095+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-12ek	\N	\N	\N	\N	\N	str
193	2024-05-18 15:31:37.105+00	2024-05-18 15:31:37.106+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-unif	\N	\N	\N	\N	\N	str
194	2024-05-18 15:31:37.118+00	2024-05-18 15:31:37.118+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-ma51	\N	\N	\N	\N	\N	str
195	2024-05-18 15:31:37.128+00	2024-05-18 15:31:37.128+00	f	\N	\N	LICENCIA	licencia-zywr	\N	\N	\N	\N	\N	str
196	2024-05-18 15:31:37.145+00	2024-05-18 15:31:37.145+00	f	\N	\N	Institución	institucion-44mp	\N	\N	\N	\N	\N	str
197	2024-05-18 15:31:37.154+00	2024-05-18 15:31:37.154+00	f	\N	\N	Descripción	descripcion-olva	\N	\N	\N	\N	\N	str
198	2024-05-18 15:31:37.166+00	2024-05-18 15:31:37.166+00	f	\N	\N	Nombre del campo	nombre-del-campo-c24o	\N	\N	\N	\N	\N	str
199	2024-05-18 15:31:37.177+00	2024-05-18 15:31:37.177+00	f	\N	\N	Nombre de Entidad 	nombre-de-entidad-ma9l	\N	\N	\N	\N	\N	str
200	2024-05-18 15:31:37.187+00	2024-05-18 15:31:37.187+00	f	\N	\N	Número de Resolución o Informe	numero-de-resolucion-o-informe-ope0	\N	\N	\N	\N	\N	str
201	2024-05-18 15:31:37.198+00	2024-05-18 15:31:37.198+00	f	\N	\N	Fecha	fecha-66ye	\N	\N	\N	\N	\N	str
202	2024-05-18 15:31:37.209+00	2024-05-18 15:31:37.209+00	f	\N	\N	Descripción	descripcion-py8i	\N	\N	\N	\N	\N	str
203	2024-05-18 15:31:37.22+00	2024-05-18 15:31:37.22+00	f	\N	\N	Enlace 	enlace-upos	\N	\N	\N	\N	\N	str
204	2024-05-18 15:31:37.237+00	2024-05-18 15:31:37.237+00	f	\N	\N	Nombre de Entidad 	nombre-de-entidad-0vf4	\N	\N	\N	\N	\N	str
205	2024-05-18 15:31:37.247+00	2024-05-18 15:31:37.247+00	f	\N	\N	Número de Resolución o Informe	numero-de-resolucion-o-informe-ipb8	\N	\N	\N	\N	\N	str
206	2024-05-18 15:31:37.257+00	2024-05-18 15:31:37.257+00	f	\N	\N	Fecha	fecha-emvc	\N	\N	\N	\N	\N	str
207	2024-05-18 15:31:37.267+00	2024-05-18 15:31:37.267+00	f	\N	\N	Descripción	descripcion-z6v9	\N	\N	\N	\N	\N	str
208	2024-05-18 15:31:37.278+00	2024-05-18 15:31:37.278+00	f	\N	\N	Enlace 	enlace-sdlm	\N	\N	\N	\N	\N	str
209	2024-05-18 15:31:37.295+00	2024-05-18 15:31:37.295+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-s4bb	\N	\N	\N	\N	\N	str
210	2024-05-18 15:31:37.306+00	2024-05-18 15:31:37.306+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-ho16	\N	\N	\N	\N	\N	str
211	2024-05-18 15:31:37.316+00	2024-05-18 15:31:37.316+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-w3ht	\N	\N	\N	\N	\N	str
212	2024-05-18 15:31:37.326+00	2024-05-18 15:31:37.326+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-xsld	\N	\N	\N	\N	\N	str
213	2024-05-18 15:31:37.336+00	2024-05-18 15:31:37.336+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-63eb	\N	\N	\N	\N	\N	str
214	2024-05-18 15:31:37.347+00	2024-05-18 15:31:37.347+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-qj6k	\N	\N	\N	\N	\N	str
215	2024-05-18 15:31:37.357+00	2024-05-18 15:31:37.357+00	f	\N	\N	LICENCIA	licencia-22xa	\N	\N	\N	\N	\N	str
216	2024-05-18 15:31:37.374+00	2024-05-18 15:31:37.374+00	f	\N	\N	Institución	institucion-czhq	\N	\N	\N	\N	\N	str
217	2024-05-18 15:31:37.383+00	2024-05-18 15:31:37.383+00	f	\N	\N	Descripción	descripcion-wg1p	\N	\N	\N	\N	\N	str
218	2024-05-18 15:31:37.393+00	2024-05-18 15:31:37.393+00	f	\N	\N	Nombre del campo	nombre-del-campo-7qnx	\N	\N	\N	\N	\N	str
219	2024-05-18 15:31:37.402+00	2024-05-18 15:31:37.402+00	f	\N	\N	Nombre de Entidad 	nombre-de-entidad-vw70	\N	\N	\N	\N	\N	str
220	2024-05-18 15:31:37.409+00	2024-05-18 15:31:37.409+00	f	\N	\N	Número de Resolución o Informe	numero-de-resolucion-o-informe-8bhm	\N	\N	\N	\N	\N	str
221	2024-05-18 15:31:37.417+00	2024-05-18 15:31:37.417+00	f	\N	\N	Fecha	fecha-hyyy	\N	\N	\N	\N	\N	str
222	2024-05-18 15:31:37.429+00	2024-05-18 15:31:37.429+00	f	\N	\N	Descripción	descripcion-p0n7	\N	\N	\N	\N	\N	str
223	2024-05-18 15:31:37.44+00	2024-05-18 15:31:37.44+00	f	\N	\N	Enlace 	enlace-8zc7	\N	\N	\N	\N	\N	str
224	2024-05-18 15:31:37.458+00	2024-05-18 15:31:37.458+00	f	\N	\N	Nombre de Entidad 	nombre-de-entidad-q1dj	\N	\N	\N	\N	\N	str
225	2024-05-18 15:31:37.469+00	2024-05-18 15:31:37.469+00	f	\N	\N	Número de Resolución o Informe	numero-de-resolucion-o-informe-3xou	\N	\N	\N	\N	\N	str
226	2024-05-18 15:31:37.479+00	2024-05-18 15:31:37.479+00	f	\N	\N	Fecha	fecha-lrgr	\N	\N	\N	\N	\N	str
227	2024-05-18 15:31:37.489+00	2024-05-18 15:31:37.489+00	f	\N	\N	Descripción	descripcion-9axd	\N	\N	\N	\N	\N	str
228	2024-05-18 15:31:37.499+00	2024-05-18 15:31:37.499+00	f	\N	\N	Enlace 	enlace-jvt2	\N	\N	\N	\N	\N	str
229	2024-05-18 15:31:37.516+00	2024-05-18 15:31:37.516+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-vj3v	\N	\N	\N	\N	\N	str
230	2024-05-18 15:31:37.526+00	2024-05-18 15:31:37.526+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-z2ar	\N	\N	\N	\N	\N	str
231	2024-05-18 15:31:37.536+00	2024-05-18 15:31:37.536+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-19l3	\N	\N	\N	\N	\N	str
232	2024-05-18 15:31:37.546+00	2024-05-18 15:31:37.546+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-t1qh	\N	\N	\N	\N	\N	str
233	2024-05-18 15:31:37.556+00	2024-05-18 15:31:37.556+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-8x91	\N	\N	\N	\N	\N	str
234	2024-05-18 15:31:37.566+00	2024-05-18 15:31:37.566+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-4p4b	\N	\N	\N	\N	\N	str
235	2024-05-18 15:31:37.577+00	2024-05-18 15:31:37.577+00	f	\N	\N	LICENCIA	licencia-dskg	\N	\N	\N	\N	\N	str
236	2024-05-18 15:31:37.596+00	2024-05-18 15:31:37.596+00	f	\N	\N	Institución	institucion-k22n	\N	\N	\N	\N	\N	str
237	2024-05-18 15:31:37.606+00	2024-05-18 15:31:37.606+00	f	\N	\N	Descripción	descripcion-7a9d	\N	\N	\N	\N	\N	str
238	2024-05-18 15:31:37.617+00	2024-05-18 15:31:37.617+00	f	\N	\N	Nombre del campo	nombre-del-campo-07sn	\N	\N	\N	\N	\N	str
239	2024-05-18 15:31:37.629+00	2024-05-18 15:31:37.629+00	f	\N	\N	Nombre de Entidad 	nombre-de-entidad-k41p	\N	\N	\N	\N	\N	str
240	2024-05-18 15:31:37.642+00	2024-05-18 15:31:37.642+00	f	\N	\N	Número de Resolución o Informe	numero-de-resolucion-o-informe-h310	\N	\N	\N	\N	\N	str
241	2024-05-18 15:31:37.652+00	2024-05-18 15:31:37.653+00	f	\N	\N	Fecha	fecha-jgfh	\N	\N	\N	\N	\N	str
242	2024-05-18 15:31:37.664+00	2024-05-18 15:31:37.664+00	f	\N	\N	Descripción	descripcion-p9hc	\N	\N	\N	\N	\N	str
243	2024-05-18 15:31:37.675+00	2024-05-18 15:31:37.675+00	f	\N	\N	Enlace 	enlace-z3px	\N	\N	\N	\N	\N	str
244	2024-05-18 15:31:37.691+00	2024-05-18 15:31:37.691+00	f	\N	\N	Nombre de Entidad 	nombre-de-entidad-d79t	\N	\N	\N	\N	\N	str
245	2024-05-18 15:31:37.701+00	2024-05-18 15:31:37.701+00	f	\N	\N	Número de Resolución o Informe	numero-de-resolucion-o-informe-454f	\N	\N	\N	\N	\N	str
246	2024-05-18 15:31:37.711+00	2024-05-18 15:31:37.711+00	f	\N	\N	Fecha	fecha-cbms	\N	\N	\N	\N	\N	str
247	2024-05-18 15:31:37.721+00	2024-05-18 15:31:37.721+00	f	\N	\N	Descripción	descripcion-f35k	\N	\N	\N	\N	\N	str
248	2024-05-18 15:31:37.731+00	2024-05-18 15:31:37.731+00	f	\N	\N	Enlace 	enlace-gu77	\N	\N	\N	\N	\N	str
249	2024-05-18 15:31:37.748+00	2024-05-18 15:31:37.748+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-edp3	\N	\N	\N	\N	\N	str
250	2024-05-18 15:31:37.758+00	2024-05-18 15:31:37.758+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-935n	\N	\N	\N	\N	\N	str
251	2024-05-18 15:31:37.769+00	2024-05-18 15:31:37.769+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-nvvr	\N	\N	\N	\N	\N	str
252	2024-05-18 15:31:37.78+00	2024-05-18 15:31:37.78+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-498s	\N	\N	\N	\N	\N	str
625	2024-05-18 15:31:42.246+00	2024-05-18 15:31:42.246+00	f	\N	\N	Institución	institucion-zoap	\N	\N	\N	\N	\N	str
253	2024-05-18 15:31:37.791+00	2024-05-18 15:31:37.791+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-bskr	\N	\N	\N	\N	\N	str
254	2024-05-18 15:31:37.802+00	2024-05-18 15:31:37.802+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-e55l	\N	\N	\N	\N	\N	str
255	2024-05-18 15:31:37.813+00	2024-05-18 15:31:37.813+00	f	\N	\N	LICENCIA	licencia-7va5	\N	\N	\N	\N	\N	str
256	2024-05-18 15:31:37.83+00	2024-05-18 15:31:37.83+00	f	\N	\N	Institución	institucion-gvcm	\N	\N	\N	\N	\N	str
257	2024-05-18 15:31:37.841+00	2024-05-18 15:31:37.841+00	f	\N	\N	Descripción	descripcion-iq7k	\N	\N	\N	\N	\N	str
258	2024-05-18 15:31:37.853+00	2024-05-18 15:31:37.853+00	f	\N	\N	Nombre del campo	nombre-del-campo-9wxr	\N	\N	\N	\N	\N	str
259	2024-05-18 15:31:37.865+00	2024-05-18 15:31:37.865+00	f	\N	\N	Nombre de Entidad 	nombre-de-entidad-xf7g	\N	\N	\N	\N	\N	str
260	2024-05-18 15:31:37.876+00	2024-05-18 15:31:37.876+00	f	\N	\N	Número de Resolución o Informe	numero-de-resolucion-o-informe-r1l3	\N	\N	\N	\N	\N	str
261	2024-05-18 15:31:37.886+00	2024-05-18 15:31:37.886+00	f	\N	\N	Fecha	fecha-csyb	\N	\N	\N	\N	\N	str
262	2024-05-18 15:31:37.896+00	2024-05-18 15:31:37.896+00	f	\N	\N	Descripción	descripcion-ug5q	\N	\N	\N	\N	\N	str
263	2024-05-18 15:31:37.905+00	2024-05-18 15:31:37.905+00	f	\N	\N	Enlace 	enlace-bkf0	\N	\N	\N	\N	\N	str
264	2024-05-18 15:31:37.922+00	2024-05-18 15:31:37.922+00	f	\N	\N	Nombre de Entidad 	nombre-de-entidad-dsbe	\N	\N	\N	\N	\N	str
265	2024-05-18 15:31:37.933+00	2024-05-18 15:31:37.933+00	f	\N	\N	Número de Resolución o Informe	numero-de-resolucion-o-informe-k69c	\N	\N	\N	\N	\N	str
266	2024-05-18 15:31:37.943+00	2024-05-18 15:31:37.943+00	f	\N	\N	Fecha	fecha-eu6r	\N	\N	\N	\N	\N	str
267	2024-05-18 15:31:37.952+00	2024-05-18 15:31:37.952+00	f	\N	\N	Descripción	descripcion-6lzo	\N	\N	\N	\N	\N	str
268	2024-05-18 15:31:37.963+00	2024-05-18 15:31:37.963+00	f	\N	\N	Enlace 	enlace-643f	\N	\N	\N	\N	\N	str
269	2024-05-18 15:31:37.98+00	2024-05-18 15:31:37.98+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-k1hw	\N	\N	\N	\N	\N	str
270	2024-05-18 15:31:37.99+00	2024-05-18 15:31:37.99+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-z8u0	\N	\N	\N	\N	\N	str
271	2024-05-18 15:31:38+00	2024-05-18 15:31:38+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-hfbc	\N	\N	\N	\N	\N	str
272	2024-05-18 15:31:38.01+00	2024-05-18 15:31:38.01+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-ko9w	\N	\N	\N	\N	\N	str
273	2024-05-18 15:31:38.02+00	2024-05-18 15:31:38.02+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-xu6z	\N	\N	\N	\N	\N	str
274	2024-05-18 15:31:38.03+00	2024-05-18 15:31:38.03+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-hksa	\N	\N	\N	\N	\N	str
275	2024-05-18 15:31:38.039+00	2024-05-18 15:31:38.039+00	f	\N	\N	LICENCIA	licencia-xh01	\N	\N	\N	\N	\N	str
276	2024-05-18 15:31:38.056+00	2024-05-18 15:31:38.056+00	f	\N	\N	Institución	institucion-jxau	\N	\N	\N	\N	\N	str
277	2024-05-18 15:31:38.067+00	2024-05-18 15:31:38.067+00	f	\N	\N	Descripción	descripcion-1bx1	\N	\N	\N	\N	\N	str
278	2024-05-18 15:31:38.077+00	2024-05-18 15:31:38.077+00	f	\N	\N	Nombre del campo	nombre-del-campo-ozsd	\N	\N	\N	\N	\N	str
279	2024-05-18 15:31:38.088+00	2024-05-18 15:31:38.088+00	f	\N	\N	Nombre de Entidad 	nombre-de-entidad-kw7g	\N	\N	\N	\N	\N	str
280	2024-05-18 15:31:38.098+00	2024-05-18 15:31:38.098+00	f	\N	\N	Número de Resolución o Informe	numero-de-resolucion-o-informe-w3ug	\N	\N	\N	\N	\N	str
281	2024-05-18 15:31:38.109+00	2024-05-18 15:31:38.109+00	f	\N	\N	Fecha	fecha-6qn4	\N	\N	\N	\N	\N	str
282	2024-05-18 15:31:38.119+00	2024-05-18 15:31:38.119+00	f	\N	\N	Descripción	descripcion-tne2	\N	\N	\N	\N	\N	str
283	2024-05-18 15:31:38.13+00	2024-05-18 15:31:38.13+00	f	\N	\N	Enlace 	enlace-lvf4	\N	\N	\N	\N	\N	str
284	2024-05-18 15:31:38.148+00	2024-05-18 15:31:38.148+00	f	\N	\N	No.	no	\N	\N	\N	\N	\N	str
285	2024-05-18 15:31:38.156+00	2024-05-18 15:31:38.156+00	f	\N	\N	Apellidos y Nombres de los servidores y servidoras	apellidos-y-nombres-de-los-servidores-y-servidoras	\N	\N	\N	\N	\N	str
286	2024-05-18 15:31:38.166+00	2024-05-18 15:31:38.166+00	f	\N	\N	Puesto Institucional	puesto-institucional-2t9w	\N	\N	\N	\N	\N	str
287	2024-05-18 15:31:38.175+00	2024-05-18 15:31:38.175+00	f	\N	\N	Unidad a la que pertenece	unidad-a-la-que-pertenece	\N	\N	\N	\N	\N	str
288	2024-05-18 15:31:38.184+00	2024-05-18 15:31:38.184+00	f	\N	\N	Dirección institucional	direccion-institucional	\N	\N	\N	\N	\N	str
289	2024-05-18 15:31:38.193+00	2024-05-18 15:31:38.193+00	f	\N	\N	Ciudad en la que labora	ciudad-en-la-que-labora	\N	\N	\N	\N	\N	str
290	2024-05-18 15:31:38.201+00	2024-05-18 15:31:38.201+00	f	\N	\N	Teléfono institucional	telefono-institucional	\N	\N	\N	\N	\N	str
291	2024-05-18 15:31:38.21+00	2024-05-18 15:31:38.21+00	f	\N	\N	Extensión telefónica	extension-telefonica	\N	\N	\N	\N	\N	str
292	2024-05-18 15:31:38.218+00	2024-05-18 15:31:38.218+00	f	\N	\N	Correo Electrónico institucional	correo-electronico-institucional	\N	\N	\N	\N	\N	str
293	2024-05-18 15:31:38.227+00	2024-05-18 15:31:38.227+00	f	\N	\N	Unnamed: 9	unnamed-9	\N	\N	\N	\N	\N	str
294	2024-05-18 15:31:38.246+00	2024-05-18 15:31:38.246+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN	fecha-actualizacion-de-la-informacion-wk4n	\N	\N	\N	\N	\N	str
295	2024-05-18 15:31:38.256+00	2024-05-18 15:31:38.257+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN	periodicidad-de-actualizacion-de-la-informacion-794g	\N	\N	\N	\N	\N	str
296	2024-05-18 15:31:38.267+00	2024-05-18 15:31:38.267+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACION	unidad-poseedora-de-la-informacion-mq4h	\N	\N	\N	\N	\N	str
297	2024-05-18 15:31:38.279+00	2024-05-18 15:31:38.279+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	persona-responsable-de-la-unidad-poseedora-de-la-informacion-u1w9	\N	\N	\N	\N	\N	str
298	2024-05-18 15:31:38.29+00	2024-05-18 15:31:38.29+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-vkgn	\N	\N	\N	\N	\N	str
299	2024-05-18 15:31:38.302+00	2024-05-18 15:31:38.302+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-l47v	\N	\N	\N	\N	\N	str
300	2024-05-18 15:31:38.313+00	2024-05-18 15:31:38.313+00	f	\N	\N	LICENCIA	licencia-kbfu	\N	\N	\N	\N	\N	str
301	2024-05-18 15:31:38.335+00	2024-05-18 15:31:38.335+00	f	\N	\N	Institución	institucion-17h9	\N	\N	\N	\N	\N	str
302	2024-05-18 15:31:38.347+00	2024-05-18 15:31:38.347+00	f	\N	\N	Descripción	descripcion-6mq6	\N	\N	\N	\N	\N	str
303	2024-05-18 15:31:38.36+00	2024-05-18 15:31:38.36+00	f	\N	\N	Nombre del campo	nombre-del-campo-f67t	\N	\N	\N	\N	\N	str
304	2024-05-18 15:31:38.372+00	2024-05-18 15:31:38.372+00	f	\N	\N	No.	no-sxpr	\N	\N	\N	\N	\N	str
305	2024-05-18 15:31:38.383+00	2024-05-18 15:31:38.384+00	f	\N	\N	Apellidos y Nombres de los servidores y servidoras	apellidos-y-nombres-de-los-servidores-y-servidoras-snvk	\N	\N	\N	\N	\N	str
306	2024-05-18 15:31:38.395+00	2024-05-18 15:31:38.396+00	f	\N	\N	Puesto Institucional	puesto-institucional-g7xw	\N	\N	\N	\N	\N	str
307	2024-05-18 15:31:38.407+00	2024-05-18 15:31:38.407+00	f	\N	\N	Unidad a la que pertenece	unidad-a-la-que-pertenece-7h5c	\N	\N	\N	\N	\N	str
308	2024-05-18 15:31:38.418+00	2024-05-18 15:31:38.418+00	f	\N	\N	Dirección institucional	direccion-institucional-d8oi	\N	\N	\N	\N	\N	str
309	2024-05-18 15:31:38.43+00	2024-05-18 15:31:38.43+00	f	\N	\N	Ciudad en la que labora	ciudad-en-la-que-labora-witm	\N	\N	\N	\N	\N	str
310	2024-05-18 15:31:38.442+00	2024-05-18 15:31:38.442+00	f	\N	\N	Teléfono institucional	telefono-institucional-aicz	\N	\N	\N	\N	\N	str
311	2024-05-18 15:31:38.454+00	2024-05-18 15:31:38.454+00	f	\N	\N	Extensión telefónica	extension-telefonica-vv62	\N	\N	\N	\N	\N	str
312	2024-05-18 15:31:38.465+00	2024-05-18 15:31:38.465+00	f	\N	\N	Correo Electrónico institucional	correo-electronico-institucional-mdc3	\N	\N	\N	\N	\N	str
313	2024-05-18 15:31:38.486+00	2024-05-18 15:31:38.486+00	f	\N	\N	Denominación del servicio público que se brinda	denominacion-del-servicio-publico-que-se-brinda	\N	\N	\N	\N	\N	str
626	2024-05-18 15:31:42.296+00	2024-05-18 15:31:42.296+00	f	\N	\N	Descripción	descripcion-pplf	\N	\N	\N	\N	\N	str
315	2024-05-18 15:31:38.505+00	2024-05-18 15:31:38.505+00	f	\N	\N	Número de personas que acceden mensualmente al servicio institucional	numero-de-personas-que-acceden-mensualmente-al-servicio-institucional	\N	\N	\N	\N	\N	str
316	2024-05-18 15:31:38.515+00	2024-05-18 15:31:38.515+00	f	\N	\N	Enlace para descargar el formulario o formato del servicio (impreso) / Correo electrónico para solicitar el servicio	enlace-para-descargar-el-formulario-o-formato-del-servicio-impreso-correo-electronico-para-solicitar-el-servicio	\N	\N	\N	\N	\N	str
317	2024-05-18 15:31:38.524+00	2024-05-18 15:31:38.524+00	f	\N	\N	Enlace para el servicio por internet (en línea)	enlace-para-el-servicio-por-internet-en-linea	\N	\N	\N	\N	\N	str
318	2024-05-18 15:31:38.534+00	2024-05-18 15:31:38.534+00	f	\N	\N	Porcentaje de satisfacción sobre el uso del servicio	porcentaje-de-satisfaccion-sobre-el-uso-del-servicio	\N	\N	\N	\N	\N	str
319	2024-05-18 15:31:38.553+00	2024-05-18 15:31:38.553+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN	fecha-actualizacion-de-la-informacion-pmof	\N	\N	\N	\N	\N	str
320	2024-05-18 15:31:38.565+00	2024-05-18 15:31:38.565+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN	periodicidad-de-actualizacion-de-la-informacion-8dm2	\N	\N	\N	\N	\N	str
321	2024-05-18 15:31:38.577+00	2024-05-18 15:31:38.577+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACION	unidad-poseedora-de-la-informacion-u102	\N	\N	\N	\N	\N	str
322	2024-05-18 15:31:38.587+00	2024-05-18 15:31:38.587+00	f	\N	\N	PERSONAL RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	personal-responsable-de-la-unidad-poseedora-de-la-informacion	\N	\N	\N	\N	\N	str
323	2024-05-18 15:31:38.599+00	2024-05-18 15:31:38.599+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-fx47	\N	\N	\N	\N	\N	str
324	2024-05-18 15:31:38.609+00	2024-05-18 15:31:38.609+00	f	\N	\N	NÚMERO TELEFÓNICO DEL O LA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	numero-telefonico-del-o-la-responsable-de-la-unidad-poseedora-de-la-informacion	\N	\N	\N	\N	\N	str
325	2024-05-18 15:31:38.621+00	2024-05-18 15:31:38.621+00	f	\N	\N	ENLACE A PORTAL ÚNICO DE TRÁMITES CIUDADANOS	enlace-a-portal-unico-de-tramites-ciudadanos	\N	\N	\N	\N	\N	str
326	2024-05-18 15:31:38.633+00	2024-05-18 15:31:38.633+00	f	\N	\N	LICENCIA	licencia-3bc5	\N	\N	\N	\N	\N	str
327	2024-05-18 15:31:38.652+00	2024-05-18 15:31:38.653+00	f	\N	\N	Institución	institucion-bvur	\N	\N	\N	\N	\N	str
328	2024-05-18 15:31:38.664+00	2024-05-18 15:31:38.664+00	f	\N	\N	Descripción 	descripcion-ts3y	\N	\N	\N	\N	\N	str
329	2024-05-18 15:31:38.676+00	2024-05-18 15:31:38.676+00	f	\N	\N	Nombre del Campo	nombre-del-campo-7jvz	\N	\N	\N	\N	\N	str
330	2024-05-18 15:31:38.688+00	2024-05-18 15:31:38.688+00	f	\N	\N	Denominación del servicio público que se brinda	denominacion-del-servicio-publico-que-se-brinda-2ixp	\N	\N	\N	\N	\N	str
331	2024-05-18 15:31:38.7+00	2024-05-18 15:31:38.7+00	f	\N	\N	Enlace para acceder al reporte del servicio	enlace-para-acceder-al-reporte-del-servicio-p6oi	\N	\N	\N	\N	\N	str
332	2024-05-18 15:31:38.712+00	2024-05-18 15:31:38.712+00	f	\N	\N	Número de personas que acceden mensualmente al servicio institucional	numero-de-personas-que-acceden-mensualmente-al-servicio-institucional-s90o	\N	\N	\N	\N	\N	str
333	2024-05-18 15:31:38.725+00	2024-05-18 15:31:38.725+00	f	\N	\N	Enlace para descargar el formulario o formato del servicio (impreso) / Correo electrónico para solicitar el servicio	enlace-para-descargar-el-formulario-o-formato-del-servicio-impreso-correo-electronico-para-solicitar-el-servicio-fnf1	\N	\N	\N	\N	\N	str
334	2024-05-18 15:31:38.737+00	2024-05-18 15:31:38.738+00	f	\N	\N	Enlace para el servicio por internet (en línea)	enlace-para-el-servicio-por-internet-en-linea-cdz1	\N	\N	\N	\N	\N	str
335	2024-05-18 15:31:38.751+00	2024-05-18 15:31:38.751+00	f	\N	\N	Porcentaje de satisfacción sobre el uso del servicio	porcentaje-de-satisfaccion-sobre-el-uso-del-servicio-924c	\N	\N	\N	\N	\N	str
336	2024-05-18 15:31:38.775+00	2024-05-18 15:31:38.775+00	f	\N	\N	No.	no-ndoe	\N	\N	\N	\N	\N	str
337	2024-05-18 15:31:38.786+00	2024-05-18 15:31:38.787+00	f	\N	\N	Número del informe 	numero-del-informe	\N	\N	\N	\N	\N	str
338	2024-05-18 15:31:38.797+00	2024-05-18 15:31:38.797+00	f	\N	\N	Tipo de examen	tipo-de-examen	\N	\N	\N	\N	\N	str
339	2024-05-18 15:31:38.808+00	2024-05-18 15:31:38.808+00	f	\N	\N	Nombre del examen	nombre-del-examen	\N	\N	\N	\N	\N	str
340	2024-05-18 15:31:38.819+00	2024-05-18 15:31:38.819+00	f	\N	\N	Período analizado	periodo-analizado	\N	\N	\N	\N	\N	str
341	2024-05-18 15:31:38.83+00	2024-05-18 15:31:38.83+00	f	\N	\N	Area o proceso auditado	area-o-proceso-auditado	\N	\N	\N	\N	\N	str
342	2024-05-18 15:31:38.841+00	2024-05-18 15:31:38.841+00	f	\N	\N	Enlace para descargar el informe específico	enlace-para-descargar-el-informe-especifico	\N	\N	\N	\N	\N	str
343	2024-05-18 15:31:38.852+00	2024-05-18 15:31:38.852+00	f	\N	\N	Enlace para descargar el reporte de seguimiento al cumplimiento de recomendaciones del informe de auditoría	enlace-para-descargar-el-reporte-de-seguimiento-al-cumplimiento-de-recomendaciones-del-informe-de-auditoria	\N	\N	\N	\N	\N	str
344	2024-05-18 15:31:38.862+00	2024-05-18 15:31:38.862+00	f	\N	\N	Información adicional sobre el informe de auditoría	informacion-adicional-sobre-el-informe-de-auditoria	\N	\N	\N	\N	\N	str
345	2024-05-18 15:31:38.878+00	2024-05-18 15:31:38.878+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-maqx	\N	\N	\N	\N	\N	str
346	2024-05-18 15:31:38.89+00	2024-05-18 15:31:38.89+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-g9l9	\N	\N	\N	\N	\N	str
347	2024-05-18 15:31:38.903+00	2024-05-18 15:31:38.903+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-dc1p	\N	\N	\N	\N	\N	str
348	2024-05-18 15:31:38.915+00	2024-05-18 15:31:38.915+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-rqsx	\N	\N	\N	\N	\N	str
349	2024-05-18 15:31:38.927+00	2024-05-18 15:31:38.927+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-82dy	\N	\N	\N	\N	\N	str
350	2024-05-18 15:31:38.939+00	2024-05-18 15:31:38.939+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-9zq5	\N	\N	\N	\N	\N	str
351	2024-05-18 15:31:38.949+00	2024-05-18 15:31:38.949+00	f	\N	\N	Enlace al sitio web de la Contraloría General del Estado para consulta de informes aprobados	enlace-al-sitio-web-de-la-contraloria-general-del-estado-para-consulta-de-informes-aprobados	\N	\N	\N	\N	\N	str
352	2024-05-18 15:31:38.962+00	2024-05-18 15:31:38.962+00	f	\N	\N	LICENCIA	licencia-25sx	\N	\N	\N	\N	\N	str
353	2024-05-18 15:31:38.982+00	2024-05-18 15:31:38.982+00	f	\N	\N	Institución	institucion-3r2x	\N	\N	\N	\N	\N	str
354	2024-05-18 15:31:38.993+00	2024-05-18 15:31:38.993+00	f	\N	\N	Descripción	descripcion-actj	\N	\N	\N	\N	\N	str
355	2024-05-18 15:31:39.005+00	2024-05-18 15:31:39.005+00	f	\N	\N	Nombre del campo	nombre-del-campo-9wtn	\N	\N	\N	\N	\N	str
356	2024-05-18 15:31:39.017+00	2024-05-18 15:31:39.017+00	f	\N	\N	No	no-ygxo	\N	\N	\N	\N	\N	str
357	2024-05-18 15:31:39.03+00	2024-05-18 15:31:39.03+00	f	\N	\N	Número del informe	numero-del-informe-hg80	\N	\N	\N	\N	\N	str
358	2024-05-18 15:31:39.041+00	2024-05-18 15:31:39.041+00	f	\N	\N	Tipo de examen	tipo-de-examen-f0lm	\N	\N	\N	\N	\N	str
359	2024-05-18 15:31:39.052+00	2024-05-18 15:31:39.053+00	f	\N	\N	Nombre del examen	nombre-del-examen-nfkf	\N	\N	\N	\N	\N	str
360	2024-05-18 15:31:39.065+00	2024-05-18 15:31:39.065+00	f	\N	\N	Período analizado	periodo-analizado-fyft	\N	\N	\N	\N	\N	str
361	2024-05-18 15:31:39.076+00	2024-05-18 15:31:39.076+00	f	\N	\N	Área o proceso auditado	area-o-proceso-auditado-3jxn	\N	\N	\N	\N	\N	str
362	2024-05-18 15:31:39.088+00	2024-05-18 15:31:39.089+00	f	\N	\N	Enlace para descargar el informe específico	enlace-para-descargar-el-informe-especifico-zvit	\N	\N	\N	\N	\N	str
363	2024-05-18 15:31:39.1+00	2024-05-18 15:31:39.1+00	f	\N	\N	Enlace para descargar el reporte de seguimiento al cumplimiento de recomendaciones del informe de auditoría	enlace-para-descargar-el-reporte-de-seguimiento-al-cumplimiento-de-recomendaciones-del-informe-de-auditoria-db1c	\N	\N	\N	\N	\N	str
364	2024-05-18 15:31:39.112+00	2024-05-18 15:31:39.112+00	f	\N	\N	Información adicional sobre el informe de auditoría	informacion-adicional-sobre-el-informe-de-auditoria-kykc	\N	\N	\N	\N	\N	str
365	2024-05-18 15:31:39.132+00	2024-05-18 15:31:39.132+00	f	\N	\N	No. de personas con acciones afirmativas	no-de-personas-con-acciones-afirmativas	\N	\N	\N	\N	\N	str
366	2024-05-18 15:31:39.141+00	2024-05-18 15:31:39.141+00	f	\N	\N	Acción afirmativa	accion-afirmativa	\N	\N	\N	\N	\N	str
367	2024-05-18 15:31:39.16+00	2024-05-18 15:31:39.16+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN	fecha-actualizacion-de-la-informacion-ni0t	\N	\N	\N	\N	\N	str
368	2024-05-18 15:31:39.171+00	2024-05-18 15:31:39.171+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN	periodicidad-de-actualizacion-de-la-informacion-ypfw	\N	\N	\N	\N	\N	str
369	2024-05-18 15:31:39.183+00	2024-05-18 15:31:39.183+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN	unidad-poseedora-de-la-informacion-naux	\N	\N	\N	\N	\N	str
370	2024-05-18 15:31:39.196+00	2024-05-18 15:31:39.196+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	persona-responsable-de-la-unidad-poseedora-de-la-informacion-j90x	\N	\N	\N	\N	\N	str
371	2024-05-18 15:31:39.208+00	2024-05-18 15:31:39.208+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-e3nx	\N	\N	\N	\N	\N	str
372	2024-05-18 15:31:39.22+00	2024-05-18 15:31:39.22+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-ivht	\N	\N	\N	\N	\N	str
373	2024-05-18 15:31:39.231+00	2024-05-18 15:31:39.231+00	f	\N	\N	LICENCIA	licencia-9krg	\N	\N	\N	\N	\N	str
374	2024-05-18 15:31:39.251+00	2024-05-18 15:31:39.251+00	f	\N	\N	Institución	institucion-ljtn	\N	\N	\N	\N	\N	str
375	2024-05-18 15:31:39.262+00	2024-05-18 15:31:39.262+00	f	\N	\N	Descripción	descripcion-oqxq	\N	\N	\N	\N	\N	str
376	2024-05-18 15:31:39.272+00	2024-05-18 15:31:39.272+00	f	\N	\N	Nombre del campo	nombre-del-campo-daux	\N	\N	\N	\N	\N	str
377	2024-05-18 15:31:39.283+00	2024-05-18 15:31:39.283+00	f	\N	\N	No. de personas con acciones afirmativas	no-de-personas-con-acciones-afirmativas-gpsv	\N	\N	\N	\N	\N	str
378	2024-05-18 15:31:39.293+00	2024-05-18 15:31:39.293+00	f	\N	\N	Acción afirmativa	accion-afirmativa-94po	\N	\N	\N	\N	\N	str
379	2024-05-18 15:31:39.312+00	2024-05-18 15:31:39.312+00	f	\N	\N	EJERCICIO	ejercicio	\N	\N	\N	\N	\N	str
380	2024-05-18 15:31:39.32+00	2024-05-18 15:31:39.32+00	f	\N	\N	ID_SECTORIAL	id_sectorial	\N	\N	\N	\N	\N	str
381	2024-05-18 15:31:39.329+00	2024-05-18 15:31:39.329+00	f	\N	\N	SECTORIAL	sectorial	\N	\N	\N	\N	\N	str
382	2024-05-18 15:31:39.338+00	2024-05-18 15:31:39.338+00	f	\N	\N	ID_GRUPO	id_grupo	\N	\N	\N	\N	\N	str
383	2024-05-18 15:31:39.347+00	2024-05-18 15:31:39.347+00	f	\N	\N	GRUPO	grupo	\N	\N	\N	\N	\N	str
384	2024-05-18 15:31:39.355+00	2024-05-18 15:31:39.355+00	f	\N	\N	CODIFICADO	codificado	\N	\N	\N	\N	\N	str
385	2024-05-18 15:31:39.363+00	2024-05-18 15:31:39.363+00	f	\N	\N	PROFORMA	proforma	\N	\N	\N	\N	\N	str
386	2024-05-18 15:31:39.381+00	2024-05-18 15:31:39.381+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-d5n5	\N	\N	\N	\N	\N	str
387	2024-05-18 15:31:39.39+00	2024-05-18 15:31:39.39+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-vpre	\N	\N	\N	\N	\N	str
388	2024-05-18 15:31:39.4+00	2024-05-18 15:31:39.4+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-qkz0	\N	\N	\N	\N	\N	str
389	2024-05-18 15:31:39.41+00	2024-05-18 15:31:39.41+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-k1hh	\N	\N	\N	\N	\N	str
390	2024-05-18 15:31:39.42+00	2024-05-18 15:31:39.42+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-t25b	\N	\N	\N	\N	\N	str
391	2024-05-18 15:31:39.43+00	2024-05-18 15:31:39.43+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-hvb3	\N	\N	\N	\N	\N	str
392	2024-05-18 15:31:39.44+00	2024-05-18 15:31:39.44+00	f	\N	\N	LICENCIA	licencia-6eud	\N	\N	\N	\N	\N	str
393	2024-05-18 15:31:39.449+00	2024-05-18 15:31:39.449+00	f	\N	\N	ENLACE PARA DIRECCIONAR A LA PROFORMA DEL PRESUPUESTO GENERAL DEL ESTADO 	enlace-para-direccionar-a-la-proforma-del-presupuesto-general-del-estado	\N	\N	\N	\N	\N	str
394	2024-05-18 15:31:39.465+00	2024-05-18 15:31:39.465+00	f	\N	\N	Institución	institucion-ofy3	\N	\N	\N	\N	\N	str
395	2024-05-18 15:31:39.475+00	2024-05-18 15:31:39.475+00	f	\N	\N	Descripción	descripcion-mhfj	\N	\N	\N	\N	\N	str
396	2024-05-18 15:31:39.485+00	2024-05-18 15:31:39.485+00	f	\N	\N	Nombre del campo	nombre-del-campo-6zjm	\N	\N	\N	\N	\N	str
397	2024-05-18 15:31:39.495+00	2024-05-18 15:31:39.495+00	f	\N	\N	EJERCICIO	ejercicio-bd4c	\N	\N	\N	\N	\N	str
398	2024-05-18 15:31:39.506+00	2024-05-18 15:31:39.506+00	f	\N	\N	ID_SECTORIAL	id_sectorial-r02z	\N	\N	\N	\N	\N	str
399	2024-05-18 15:31:39.515+00	2024-05-18 15:31:39.515+00	f	\N	\N	SECTORIAL	sectorial-e0nf	\N	\N	\N	\N	\N	str
400	2024-05-18 15:31:39.525+00	2024-05-18 15:31:39.525+00	f	\N	\N	ID_GRUPO	id_grupo-4da4	\N	\N	\N	\N	\N	str
401	2024-05-18 15:31:39.535+00	2024-05-18 15:31:39.535+00	f	\N	\N	GRUPO	grupo-wim5	\N	\N	\N	\N	\N	str
402	2024-05-18 15:31:39.545+00	2024-05-18 15:31:39.545+00	f	\N	\N	CODIFICADO	codificado-fzmk	\N	\N	\N	\N	\N	str
403	2024-05-18 15:31:39.555+00	2024-05-18 15:31:39.555+00	f	\N	\N	PROFORMA	proforma-game	\N	\N	\N	\N	\N	str
404	2024-05-18 15:31:39.572+00	2024-05-18 15:31:39.572+00	f	\N	\N	EJERCICIO	ejercicio-186t	\N	\N	\N	\N	\N	str
405	2024-05-18 15:31:39.583+00	2024-05-18 15:31:39.583+00	f	\N	\N	MES	mes-eju5	\N	\N	\N	\N	\N	str
406	2024-05-18 15:31:39.591+00	2024-05-18 15:31:39.591+00	f	\N	\N	SECTOR	sector	\N	\N	\N	\N	\N	str
407	2024-05-18 15:31:39.6+00	2024-05-18 15:31:39.6+00	f	\N	\N	NOMBRE SECTOR	nombre-sector	\N	\N	\N	\N	\N	str
408	2024-05-18 15:31:39.608+00	2024-05-18 15:31:39.608+00	f	\N	\N	CODIGO UDAF	codigo-udaf	\N	\N	\N	\N	\N	str
409	2024-05-18 15:31:39.618+00	2024-05-18 15:31:39.618+00	f	\N	\N	NOMBRE ENTIDAD	nombre-entidad	\N	\N	\N	\N	\N	str
410	2024-05-18 15:31:39.627+00	2024-05-18 15:31:39.627+00	f	\N	\N	CODIGO EOD	codigo-eod	\N	\N	\N	\N	\N	str
411	2024-05-18 15:31:39.637+00	2024-05-18 15:31:39.637+00	f	\N	\N	NOMBRE EOD	nombre-eod	\N	\N	\N	\N	\N	str
412	2024-05-18 15:31:39.646+00	2024-05-18 15:31:39.646+00	f	\N	\N	GRUPO GASTO	grupo-gasto	\N	\N	\N	\N	\N	str
413	2024-05-18 15:31:39.655+00	2024-05-18 15:31:39.655+00	f	\N	\N	NOMBRE GRUPO	nombre-grupo	\N	\N	\N	\N	\N	str
414	2024-05-18 15:31:39.664+00	2024-05-18 15:31:39.664+00	f	\N	\N	TIPO PRESUPUESTO	tipo-presupuesto	\N	\N	\N	\N	\N	str
415	2024-05-18 15:31:39.672+00	2024-05-18 15:31:39.672+00	f	\N	\N	ITEM	item	\N	\N	\N	\N	\N	str
416	2024-05-18 15:31:39.681+00	2024-05-18 15:31:39.681+00	f	\N	\N	NOMBRE ITEM	nombre-item	\N	\N	\N	\N	\N	str
417	2024-05-18 15:31:39.69+00	2024-05-18 15:31:39.69+00	f	\N	\N	INICIAL	inicial	\N	\N	\N	\N	\N	str
418	2024-05-18 15:31:39.701+00	2024-05-18 15:31:39.701+00	f	\N	\N	CODIFICADO	codificado-5ovg	\N	\N	\N	\N	\N	str
419	2024-05-18 15:31:39.709+00	2024-05-18 15:31:39.709+00	f	\N	\N	COMPROMETIDO	comprometido	\N	\N	\N	\N	\N	str
420	2024-05-18 15:31:39.72+00	2024-05-18 15:31:39.72+00	f	\N	\N	DEVENGADO	devengado	\N	\N	\N	\N	\N	str
421	2024-05-18 15:31:39.73+00	2024-05-18 15:31:39.73+00	f	\N	\N	PAGADO	pagado	\N	\N	\N	\N	\N	str
422	2024-05-18 15:31:39.748+00	2024-05-18 15:31:39.748+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-7k07	\N	\N	\N	\N	\N	str
423	2024-05-18 15:31:39.759+00	2024-05-18 15:31:39.759+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-0ukg	\N	\N	\N	\N	\N	str
424	2024-05-18 15:31:39.771+00	2024-05-18 15:31:39.771+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-mx4k	\N	\N	\N	\N	\N	str
425	2024-05-18 15:31:39.783+00	2024-05-18 15:31:39.783+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-4lbq	\N	\N	\N	\N	\N	str
426	2024-05-18 15:31:39.793+00	2024-05-18 15:31:39.793+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-mf3j	\N	\N	\N	\N	\N	str
427	2024-05-18 15:31:39.804+00	2024-05-18 15:31:39.804+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-hmy4	\N	\N	\N	\N	\N	str
428	2024-05-18 15:31:39.814+00	2024-05-18 15:31:39.814+00	f	\N	\N	LICENCIA	licencia-o7dy	\N	\N	\N	\N	\N	str
627	2024-05-18 15:31:42.348+00	2024-05-18 15:31:42.348+00	f	\N	\N	Nombre del campo	nombre-del-campo-o75c	\N	\N	\N	\N	\N	str
429	2024-05-18 15:31:39.823+00	2024-05-18 15:31:39.823+00	f	\N	\N	ENLACE PARA DIRECCIONAR A LA EJECUCIÓN DEL PRESUPUESTO GENERAL DEL ESTADO 	enlace-para-direccionar-a-la-ejecucion-del-presupuesto-general-del-estado	\N	\N	\N	\N	\N	str
430	2024-05-18 15:31:39.841+00	2024-05-18 15:31:39.841+00	f	\N	\N	Institución	institucion-v7qx	\N	\N	\N	\N	\N	str
431	2024-05-18 15:31:39.851+00	2024-05-18 15:31:39.851+00	f	\N	\N	Descripción	descripcion-w4vc	\N	\N	\N	\N	\N	str
432	2024-05-18 15:31:39.861+00	2024-05-18 15:31:39.861+00	f	\N	\N	Nombre del campo	nombre-del-campo-t3lm	\N	\N	\N	\N	\N	str
433	2024-05-18 15:31:39.872+00	2024-05-18 15:31:39.872+00	f	\N	\N	Ejercicio	ejercicio-bfyw	\N	\N	\N	\N	\N	str
434	2024-05-18 15:31:39.882+00	2024-05-18 15:31:39.882+00	f	\N	\N	Mes	mes-u4rq	\N	\N	\N	\N	\N	str
435	2024-05-18 15:31:39.893+00	2024-05-18 15:31:39.893+00	f	\N	\N	Sector	sector-24dj	\N	\N	\N	\N	\N	str
436	2024-05-18 15:31:39.903+00	2024-05-18 15:31:39.903+00	f	\N	\N	Nombre Sector	nombre-sector-z8vq	\N	\N	\N	\N	\N	str
437	2024-05-18 15:31:39.915+00	2024-05-18 15:31:39.915+00	f	\N	\N	Código UDAF	codigo-udaf-hrek	\N	\N	\N	\N	\N	str
438	2024-05-18 15:31:39.925+00	2024-05-18 15:31:39.925+00	f	\N	\N	Nombre Entidad	nombre-entidad-7ka5	\N	\N	\N	\N	\N	str
439	2024-05-18 15:31:39.937+00	2024-05-18 15:31:39.937+00	f	\N	\N	Código EOD	codigo-eod-hnpn	\N	\N	\N	\N	\N	str
440	2024-05-18 15:31:39.947+00	2024-05-18 15:31:39.948+00	f	\N	\N	Nombre EOD	nombre-eod-31kf	\N	\N	\N	\N	\N	str
441	2024-05-18 15:31:39.958+00	2024-05-18 15:31:39.958+00	f	\N	\N	Grupo Gasto	grupo-gasto-sne6	\N	\N	\N	\N	\N	str
442	2024-05-18 15:31:39.968+00	2024-05-18 15:31:39.968+00	f	\N	\N	Nombre Grupo	nombre-grupo-lb20	\N	\N	\N	\N	\N	str
443	2024-05-18 15:31:39.98+00	2024-05-18 15:31:39.98+00	f	\N	\N	Tipo Presupuesto	tipo-presupuesto-d4i0	\N	\N	\N	\N	\N	str
444	2024-05-18 15:31:39.991+00	2024-05-18 15:31:39.991+00	f	\N	\N	Item	item-j3ha	\N	\N	\N	\N	\N	str
445	2024-05-18 15:31:40.001+00	2024-05-18 15:31:40.001+00	f	\N	\N	Nombre Item	nombre-item-9i5p	\N	\N	\N	\N	\N	str
446	2024-05-18 15:31:40.011+00	2024-05-18 15:31:40.011+00	f	\N	\N	Inicial	inicial-wrb3	\N	\N	\N	\N	\N	str
447	2024-05-18 15:31:40.022+00	2024-05-18 15:31:40.022+00	f	\N	\N	Codificado	codificado-7y7h	\N	\N	\N	\N	\N	str
448	2024-05-18 15:31:40.033+00	2024-05-18 15:31:40.033+00	f	\N	\N	Comprometido	comprometido-ooen	\N	\N	\N	\N	\N	str
449	2024-05-18 15:31:40.045+00	2024-05-18 15:31:40.045+00	f	\N	\N	Devengado	devengado-aigy	\N	\N	\N	\N	\N	str
450	2024-05-18 15:31:40.056+00	2024-05-18 15:31:40.056+00	f	\N	\N	Pagado	pagado-cwc1	\N	\N	\N	\N	\N	str
451	2024-05-18 15:31:40.072+00	2024-05-18 15:31:40.072+00	f	\N	\N	AÑO	ano	\N	\N	\N	\N	\N	str
452	2024-05-18 15:31:40.084+00	2024-05-18 15:31:40.084+00	f	\N	\N	SECTORIAL	sectorial-zt7u	\N	\N	\N	\N	\N	str
453	2024-05-18 15:31:40.094+00	2024-05-18 15:31:40.094+00	f	\N	\N	GRUPO	grupo-hkk6	\N	\N	\N	\N	\N	str
454	2024-05-18 15:31:40.105+00	2024-05-18 15:31:40.105+00	f	\N	\N	CODIFICADO	codificado-6pyw	\N	\N	\N	\N	\N	str
455	2024-05-18 15:31:40.116+00	2024-05-18 15:31:40.116+00	f	\N	\N	DEVENGADO	devengado-saup	\N	\N	\N	\N	\N	str
456	2024-05-18 15:31:40.133+00	2024-05-18 15:31:40.133+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-bpsu	\N	\N	\N	\N	\N	str
457	2024-05-18 15:31:40.146+00	2024-05-18 15:31:40.146+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-zl5a	\N	\N	\N	\N	\N	str
458	2024-05-18 15:31:40.156+00	2024-05-18 15:31:40.156+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-9oko	\N	\N	\N	\N	\N	str
459	2024-05-18 15:31:40.166+00	2024-05-18 15:31:40.166+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-880y	\N	\N	\N	\N	\N	str
460	2024-05-18 15:31:40.176+00	2024-05-18 15:31:40.176+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-mxmn	\N	\N	\N	\N	\N	str
461	2024-05-18 15:31:40.186+00	2024-05-18 15:31:40.186+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-4xfl	\N	\N	\N	\N	\N	str
462	2024-05-18 15:31:40.196+00	2024-05-18 15:31:40.196+00	f	\N	\N	LICENCIA	licencia-3hyt	\N	\N	\N	\N	\N	str
463	2024-05-18 15:31:40.204+00	2024-05-18 15:31:40.204+00	f	\N	\N	ENLACE PARA DIRECCIONAR AL PRESUPUESTO HISTÓRICO	enlace-para-direccionar-al-presupuesto-historico	\N	\N	\N	\N	\N	str
464	2024-05-18 15:31:40.221+00	2024-05-18 15:31:40.221+00	f	\N	\N	Institución	institucion-gdqd	\N	\N	\N	\N	\N	str
465	2024-05-18 15:31:40.232+00	2024-05-18 15:31:40.232+00	f	\N	\N	Descripción	descripcion-95fo	\N	\N	\N	\N	\N	str
466	2024-05-18 15:31:40.244+00	2024-05-18 15:31:40.244+00	f	\N	\N	Nombre del campo	nombre-del-campo-otbs	\N	\N	\N	\N	\N	str
467	2024-05-18 15:31:40.257+00	2024-05-18 15:31:40.257+00	f	\N	\N	AÑO	ano-pqg1	\N	\N	\N	\N	\N	str
468	2024-05-18 15:31:40.27+00	2024-05-18 15:31:40.27+00	f	\N	\N	SECTORIAL	sectorial-t35l	\N	\N	\N	\N	\N	str
469	2024-05-18 15:31:40.283+00	2024-05-18 15:31:40.283+00	f	\N	\N	GRUPO	grupo-8xbo	\N	\N	\N	\N	\N	str
470	2024-05-18 15:31:40.294+00	2024-05-18 15:31:40.295+00	f	\N	\N	CODIFICADO	codificado-3clx	\N	\N	\N	\N	\N	str
471	2024-05-18 15:31:40.306+00	2024-05-18 15:31:40.306+00	f	\N	\N	DEVENGADO	devengado-fz7o	\N	\N	\N	\N	\N	str
472	2024-05-18 15:31:40.328+00	2024-05-18 15:31:40.328+00	f	\N	\N	EJERCICIO	ejercicio-sf3b	\N	\N	\N	\N	\N	str
473	2024-05-18 15:31:40.341+00	2024-05-18 15:31:40.341+00	f	\N	\N	GRUPO	grupo-pc9t	\N	\N	\N	\N	\N	str
474	2024-05-18 15:31:40.352+00	2024-05-18 15:31:40.352+00	f	\N	\N	ID CUENTA	id-cuenta	\N	\N	\N	\N	\N	str
475	2024-05-18 15:31:40.363+00	2024-05-18 15:31:40.363+00	f	\N	\N	SUBGRUPO	subgrupo	\N	\N	\N	\N	\N	str
476	2024-05-18 15:31:40.374+00	2024-05-18 15:31:40.374+00	f	\N	\N	DENOMINACIÓN	denominacion	\N	\N	\N	\N	\N	str
477	2024-05-18 15:31:40.386+00	2024-05-18 15:31:40.387+00	f	\N	\N	TOTAL	total-5ahv	\N	\N	\N	\N	\N	str
478	2024-05-18 15:31:40.406+00	2024-05-18 15:31:40.406+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-7s7e	\N	\N	\N	\N	\N	str
479	2024-05-18 15:31:40.418+00	2024-05-18 15:31:40.418+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-85mm	\N	\N	\N	\N	\N	str
480	2024-05-18 15:31:40.43+00	2024-05-18 15:31:40.43+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-ykf2	\N	\N	\N	\N	\N	str
481	2024-05-18 15:31:40.442+00	2024-05-18 15:31:40.442+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-n4lu	\N	\N	\N	\N	\N	str
482	2024-05-18 15:31:40.454+00	2024-05-18 15:31:40.454+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-qiu8	\N	\N	\N	\N	\N	str
483	2024-05-18 15:31:40.466+00	2024-05-18 15:31:40.466+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-kl4r	\N	\N	\N	\N	\N	str
484	2024-05-18 15:31:40.478+00	2024-05-18 15:31:40.478+00	f	\N	\N	LICENCIA	licencia-f4n0	\N	\N	\N	\N	\N	str
485	2024-05-18 15:31:40.488+00	2024-05-18 15:31:40.488+00	f	\N	\N	ENLACE PARA DIRECCIONAR AL ESTADO DE SITUACIÓN FINANCIERA 	enlace-para-direccionar-al-estado-de-situacion-financiera	\N	\N	\N	\N	\N	str
486	2024-05-18 15:31:40.508+00	2024-05-18 15:31:40.508+00	f	\N	\N	Institución	institucion-7436	\N	\N	\N	\N	\N	str
487	2024-05-18 15:31:40.52+00	2024-05-18 15:31:40.52+00	f	\N	\N	Descripción	descripcion-aptq	\N	\N	\N	\N	\N	str
488	2024-05-18 15:31:40.531+00	2024-05-18 15:31:40.531+00	f	\N	\N	Nombre del campo	nombre-del-campo-dg0e	\N	\N	\N	\N	\N	str
489	2024-05-18 15:31:40.543+00	2024-05-18 15:31:40.543+00	f	\N	\N	EJERCICIO	ejercicio-u9i6	\N	\N	\N	\N	\N	str
490	2024-05-18 15:31:40.554+00	2024-05-18 15:31:40.554+00	f	\N	\N	GRUPO	grupo-yyv2	\N	\N	\N	\N	\N	str
491	2024-05-18 15:31:40.566+00	2024-05-18 15:31:40.566+00	f	\N	\N	ID CUENTA	id-cuenta-ek6f	\N	\N	\N	\N	\N	str
492	2024-05-18 15:31:40.577+00	2024-05-18 15:31:40.577+00	f	\N	\N	SUBGRUPO	subgrupo-g6za	\N	\N	\N	\N	\N	str
493	2024-05-18 15:31:40.588+00	2024-05-18 15:31:40.588+00	f	\N	\N	DENOMINACIÓN	denominacion-llfx	\N	\N	\N	\N	\N	str
494	2024-05-18 15:31:40.601+00	2024-05-18 15:31:40.601+00	f	\N	\N	TOTAL	total-ktp4	\N	\N	\N	\N	\N	str
495	2024-05-18 15:31:40.622+00	2024-05-18 15:31:40.622+00	f	\N	\N	Nivel superior	nivel-superior	\N	\N	\N	\N	\N	str
496	2024-05-18 15:31:40.634+00	2024-05-18 15:31:40.634+00	f	\N	\N	Unidad	unidad	\N	\N	\N	\N	\N	str
497	2024-05-18 15:31:40.644+00	2024-06-29 21:50:38.486+00	f	\N	\N	Nivel de los Procesos de la Estructura Funcional	nivel-de-los-procesos-de-la-estructura	\N	\N	\N	\N	\N	string
498	2024-05-18 15:31:40.665+00	2024-05-18 15:31:40.665+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-it2d	\N	\N	\N	\N	\N	str
499	2024-05-18 15:31:40.673+00	2024-05-18 15:31:40.673+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-6898	\N	\N	\N	\N	\N	str
500	2024-05-18 15:31:40.682+00	2024-05-18 15:31:40.682+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-srqd	\N	\N	\N	\N	\N	str
501	2024-05-18 15:31:40.692+00	2024-05-18 15:31:40.692+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-v4j3	\N	\N	\N	\N	\N	str
502	2024-05-18 15:31:40.702+00	2024-05-18 15:31:40.702+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-kecf	\N	\N	\N	\N	\N	str
503	2024-05-18 15:31:40.713+00	2024-05-18 15:31:40.714+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-9tl8	\N	\N	\N	\N	\N	str
504	2024-05-18 15:31:40.723+00	2024-05-18 15:31:40.723+00	f	\N	\N	LICENCIA	licencia-qe52	\N	\N	\N	\N	\N	str
505	2024-05-18 15:31:40.732+00	2024-05-18 15:31:40.732+00	f	\N	\N	ENLACE PARA CONSULTAR EL ORGANIGRAMA ESTRUCTURAL	enlace-para-consultar-el-organigrama-estructural	\N	\N	\N	\N	\N	str
506	2024-05-18 15:31:40.751+00	2024-05-18 15:31:40.751+00	f	\N	\N	Institución	institucion-pq7p	\N	\N	\N	\N	\N	str
507	2024-05-18 15:31:40.764+00	2024-05-18 15:31:40.764+00	f	\N	\N	Descripción	descripcion-vuqx	\N	\N	\N	\N	\N	str
508	2024-05-18 15:31:40.775+00	2024-05-18 15:31:40.775+00	f	\N	\N	Nombre del campo	nombre-del-campo-k3ky	\N	\N	\N	\N	\N	str
509	2024-05-18 15:31:40.786+00	2024-05-18 15:31:40.786+00	f	\N	\N	Nivel superior	nivel-superior-uyij	\N	\N	\N	\N	\N	str
510	2024-05-18 15:31:40.798+00	2024-05-18 15:31:40.798+00	f	\N	\N	Unidad	unidad-9oih	\N	\N	\N	\N	\N	str
511	2024-05-18 15:31:40.81+00	2024-06-29 21:49:43.371+00	f	\N	\N	Nivel de los Procesos de la Estructura	nivel-de-los-procesos-de-la-estructura-bebv	\N	\N	\N	\N	\N	string
512	2024-05-18 15:31:40.833+00	2024-05-18 15:31:40.833+00	f	\N	\N	Fecha	fecha-5e0u	\N	\N	\N	\N	\N	str
513	2024-05-18 15:31:40.843+00	2024-05-18 15:31:40.843+00	f	\N	\N	GAD o Entidad	gad-o-entidad	\N	\N	\N	\N	\N	str
514	2024-05-18 15:31:40.854+00	2024-05-18 15:31:40.854+00	f	\N	\N	Tipo	tipo-lb5k	\N	\N	\N	\N	\N	str
515	2024-05-18 15:31:40.864+00	2024-05-18 15:31:40.864+00	f	\N	\N	Título	titulo	\N	\N	\N	\N	\N	str
516	2024-05-18 15:31:40.874+00	2024-05-18 15:31:40.874+00	f	\N	\N	Enlace 	enlace-t5kd	\N	\N	\N	\N	\N	str
517	2024-05-18 15:31:40.892+00	2024-05-18 15:31:40.893+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN	fecha-actualizacion-de-la-informacion-rytr	\N	\N	\N	\N	\N	str
518	2024-05-18 15:31:40.903+00	2024-05-18 15:31:40.903+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN	periodicidad-de-actualizacion-de-la-informacion-a8q7	\N	\N	\N	\N	\N	str
519	2024-05-18 15:31:40.914+00	2024-05-18 15:31:40.914+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN	unidad-poseedora-de-la-informacion-vx9e	\N	\N	\N	\N	\N	str
520	2024-05-18 15:31:40.925+00	2024-05-18 15:31:40.925+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	persona-responsable-de-la-unidad-poseedora-de-la-informacion-6pvb	\N	\N	\N	\N	\N	str
521	2024-05-18 15:31:40.937+00	2024-05-18 15:31:40.937+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-454y	\N	\N	\N	\N	\N	str
522	2024-05-18 15:31:40.948+00	2024-05-18 15:31:40.948+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-nkm8	\N	\N	\N	\N	\N	str
523	2024-05-18 15:31:40.959+00	2024-05-18 15:31:40.959+00	f	\N	\N	LICENCIA	licencia-xdzi	\N	\N	\N	\N	\N	str
524	2024-05-18 15:31:40.976+00	2024-05-18 15:31:40.976+00	f	\N	\N	Institución	institucion-2l0q	\N	\N	\N	\N	\N	str
525	2024-05-18 15:31:40.987+00	2024-05-18 15:31:40.987+00	f	\N	\N	Descripción	descripcion-d95r	\N	\N	\N	\N	\N	str
526	2024-05-18 15:31:40.999+00	2024-05-18 15:31:40.999+00	f	\N	\N	Nombre del campo	nombre-del-campo-v96g	\N	\N	\N	\N	\N	str
527	2024-05-18 15:31:41.011+00	2024-05-18 15:31:41.011+00	f	\N	\N	Fecha	fecha-fy9a	\N	\N	\N	\N	\N	str
528	2024-05-18 15:31:41.024+00	2024-05-18 15:31:41.024+00	f	\N	\N	GAD o Entidad	gad-o-entidad-1o92	\N	\N	\N	\N	\N	str
529	2024-05-18 15:31:41.036+00	2024-05-18 15:31:41.036+00	f	\N	\N	Tipo	tipo-3csu	\N	\N	\N	\N	\N	str
530	2024-05-18 15:31:41.046+00	2024-05-18 15:31:41.046+00	f	\N	\N	Título	titulo-cjnm	\N	\N	\N	\N	\N	str
531	2024-05-18 15:31:41.06+00	2024-05-18 15:31:41.06+00	f	\N	\N	Enlace 	enlace-anba	\N	\N	\N	\N	\N	str
532	2024-05-18 15:31:41.079+00	2024-05-18 15:31:41.079+00	f	\N	\N	Fecha	fecha-bz2l	\N	\N	\N	\N	\N	str
533	2024-05-18 15:31:41.091+00	2024-05-18 15:31:41.091+00	f	\N	\N	GAD o Entidad	gad-o-entidad-fbns	\N	\N	\N	\N	\N	str
534	2024-05-18 15:31:41.104+00	2024-05-18 15:31:41.104+00	f	\N	\N	Tipo	tipo-iwv2	\N	\N	\N	\N	\N	str
535	2024-05-18 15:31:41.115+00	2024-05-18 15:31:41.115+00	f	\N	\N	Título	titulo-ibya	\N	\N	\N	\N	\N	str
536	2024-05-18 15:31:41.127+00	2024-05-18 15:31:41.127+00	f	\N	\N	Enlace	enlace-tv68	\N	\N	\N	\N	\N	str
537	2024-05-18 15:31:41.151+00	2024-05-18 15:31:41.151+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN	fecha-actualizacion-de-la-informacion-eeeg	\N	\N	\N	\N	\N	str
538	2024-05-18 15:31:41.162+00	2024-05-18 15:31:41.162+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN	periodicidad-de-actualizacion-de-la-informacion-dfbw	\N	\N	\N	\N	\N	str
539	2024-05-18 15:31:41.173+00	2024-05-18 15:31:41.173+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN	unidad-poseedora-de-la-informacion-0tf2	\N	\N	\N	\N	\N	str
540	2024-05-18 15:31:41.186+00	2024-05-18 15:31:41.186+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	persona-responsable-de-la-unidad-poseedora-de-la-informacion-f5xr	\N	\N	\N	\N	\N	str
541	2024-05-18 15:31:41.2+00	2024-05-18 15:31:41.2+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-oa48	\N	\N	\N	\N	\N	str
542	2024-05-18 15:31:41.212+00	2024-05-18 15:31:41.212+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-ckvy	\N	\N	\N	\N	\N	str
543	2024-05-18 15:31:41.224+00	2024-05-18 15:31:41.224+00	f	\N	\N	LICENCIA	licencia-t9ru	\N	\N	\N	\N	\N	str
544	2024-05-18 15:31:41.245+00	2024-05-18 15:31:41.245+00	f	\N	\N	Institución	institucion-l6xi	\N	\N	\N	\N	\N	str
545	2024-05-18 15:31:41.257+00	2024-05-18 15:31:41.257+00	f	\N	\N	Descripción	descripcion-a95g	\N	\N	\N	\N	\N	str
546	2024-05-18 15:31:41.27+00	2024-05-18 15:31:41.27+00	f	\N	\N	Nombre del campo	nombre-del-campo-cjbb	\N	\N	\N	\N	\N	str
547	2024-05-18 15:31:41.281+00	2024-05-18 15:31:41.281+00	f	\N	\N	Fecha	fecha-bxqg	\N	\N	\N	\N	\N	str
548	2024-05-18 15:31:41.292+00	2024-05-18 15:31:41.292+00	f	\N	\N	GAD o Entidad	gad-o-entidad-m15q	\N	\N	\N	\N	\N	str
549	2024-05-18 15:31:41.303+00	2024-05-18 15:31:41.303+00	f	\N	\N	Tipo	tipo-woba	\N	\N	\N	\N	\N	str
550	2024-05-18 15:31:41.313+00	2024-05-18 15:31:41.313+00	f	\N	\N	Título	titulo-urtm	\N	\N	\N	\N	\N	str
551	2024-05-18 15:31:41.321+00	2024-05-18 15:31:41.321+00	f	\N	\N	Enlace Acta	enlace-acta	\N	\N	\N	\N	\N	str
552	2024-05-18 15:31:41.34+00	2024-05-18 15:31:41.34+00	f	\N	\N	Número de Proceso	numero-de-proceso	\N	\N	\N	\N	\N	str
553	2024-05-18 15:31:41.348+00	2024-05-18 15:31:41.348+00	f	\N	\N	Fecha de ingreso	fecha-de-ingreso	\N	\N	\N	\N	\N	str
554	2024-05-18 15:31:41.357+00	2024-05-18 15:31:41.357+00	f	\N	\N	Materia	materia	\N	\N	\N	\N	\N	str
555	2024-05-18 15:31:41.366+00	2024-05-18 15:31:41.366+00	f	\N	\N	Delito o Asunto	delito-o-asunto	\N	\N	\N	\N	\N	str
556	2024-05-18 15:31:41.374+00	2024-05-18 15:31:41.374+00	f	\N	\N	Tipo de acción	tipo-de-accion	\N	\N	\N	\N	\N	str
557	2024-05-18 15:31:41.384+00	2024-05-18 15:31:41.384+00	f	\N	\N	Provincia	provincia-c64z	\N	\N	\N	\N	\N	str
558	2024-05-18 15:31:41.394+00	2024-05-18 15:31:41.394+00	f	\N	\N	Cantón	canton-6377	\N	\N	\N	\N	\N	str
559	2024-05-18 15:31:41.402+00	2024-05-18 15:31:41.402+00	f	\N	\N	Dependencia Jurisdiccional	dependencia-jurisdiccional	\N	\N	\N	\N	\N	str
560	2024-05-18 15:31:41.41+00	2024-05-18 15:31:41.41+00	f	\N	\N	Estado	estado	\N	\N	\N	\N	\N	str
561	2024-05-18 15:31:41.419+00	2024-05-18 15:31:41.419+00	f	\N	\N	Resumen de Sentencia	resumen-de-sentencia	\N	\N	\N	\N	\N	str
562	2024-05-18 15:31:41.429+00	2024-05-18 15:31:41.429+00	f	\N	\N	Enlace al Texto Íntegro del Proceso y Sentencia	enlace-al-texto-integro-del-proceso-y-sentencia	\N	\N	\N	\N	\N	str
563	2024-05-18 15:31:41.448+00	2024-05-18 15:31:41.448+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN	fecha-actualizacion-de-la-informacion-sju3	\N	\N	\N	\N	\N	str
564	2024-05-18 15:31:41.459+00	2024-05-18 15:31:41.459+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN	periodicidad-de-actualizacion-de-la-informacion-zd4v	\N	\N	\N	\N	\N	str
565	2024-05-18 15:31:41.47+00	2024-05-18 15:31:41.47+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN	unidad-poseedora-de-la-informacion-8mkf	\N	\N	\N	\N	\N	str
566	2024-05-18 15:31:41.482+00	2024-05-18 15:31:41.482+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	persona-responsable-de-la-unidad-poseedora-de-la-informacion-o9p2	\N	\N	\N	\N	\N	str
567	2024-05-18 15:31:41.493+00	2024-05-18 15:31:41.493+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-9pen	\N	\N	\N	\N	\N	str
568	2024-05-18 15:31:41.504+00	2024-05-18 15:31:41.504+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-zvir	\N	\N	\N	\N	\N	str
569	2024-05-18 15:31:41.516+00	2024-05-18 15:31:41.516+00	f	\N	\N	LICENCIA	licencia-81z0	\N	\N	\N	\N	\N	str
570	2024-05-18 15:31:41.528+00	2024-05-18 15:31:41.528+00	f	\N	\N	ENLACE A CONSULTAS DE PROCESOS JUDICIALES ELECTRÓNICOS E-SATJE	enlace-a-consultas-de-procesos-judiciales-electronicos-e-satje	\N	\N	\N	\N	\N	str
571	2024-05-18 15:31:41.552+00	2024-05-18 15:31:41.552+00	f	\N	\N	Institución	institucion-z42z	\N	\N	\N	\N	\N	str
572	2024-05-18 15:31:41.567+00	2024-05-18 15:31:41.567+00	f	\N	\N	Descripción	descripcion-oupv	\N	\N	\N	\N	\N	str
573	2024-05-18 15:31:41.583+00	2024-05-18 15:31:41.583+00	f	\N	\N	Nombre del campo	nombre-del-campo-r8iz	\N	\N	\N	\N	\N	str
574	2024-05-18 15:31:41.598+00	2024-05-18 15:31:41.598+00	f	\N	\N	Número de Proceso	numero-de-proceso-up1e	\N	\N	\N	\N	\N	str
575	2024-05-18 15:31:41.612+00	2024-05-18 15:31:41.612+00	f	\N	\N	Fecha de ingreso	fecha-de-ingreso-pmf7	\N	\N	\N	\N	\N	str
576	2024-05-18 15:31:41.628+00	2024-05-18 15:31:41.628+00	f	\N	\N	Materia	materia-evqz	\N	\N	\N	\N	\N	str
577	2024-05-18 15:31:41.642+00	2024-05-18 15:31:41.642+00	f	\N	\N	Delito o Asunto	delito-o-asunto-osko	\N	\N	\N	\N	\N	str
578	2024-05-18 15:31:41.657+00	2024-05-18 15:31:41.657+00	f	\N	\N	Tipo de acción	tipo-de-accion-hoo1	\N	\N	\N	\N	\N	str
579	2024-05-18 15:31:41.672+00	2024-05-18 15:31:41.672+00	f	\N	\N	Provincia	provincia-2p52	\N	\N	\N	\N	\N	str
580	2024-05-18 15:31:41.683+00	2024-05-18 15:31:41.683+00	f	\N	\N	Cantón	canton-tod3	\N	\N	\N	\N	\N	str
581	2024-05-18 15:31:41.694+00	2024-05-18 15:31:41.694+00	f	\N	\N	Dependencia Jurisdiccional	dependencia-jurisdiccional-izfp	\N	\N	\N	\N	\N	str
582	2024-05-18 15:31:41.706+00	2024-05-18 15:31:41.706+00	f	\N	\N	Estado	estado-pahi	\N	\N	\N	\N	\N	str
583	2024-05-18 15:31:41.718+00	2024-05-18 15:31:41.718+00	f	\N	\N	Resumen de Sentencia	resumen-de-sentencia-3q5o	\N	\N	\N	\N	\N	str
584	2024-05-18 15:31:41.729+00	2024-05-18 15:31:41.729+00	f	\N	\N	Enlace al Texto Íntegro del Proceso y Sentencia	enlace-al-texto-integro-del-proceso-y-sentencia-jtn2	\N	\N	\N	\N	\N	str
585	2024-05-18 15:31:41.75+00	2024-05-18 15:31:41.75+00	f	\N	\N	Número de causa	numero-de-causa	\N	\N	\N	\N	\N	str
586	2024-05-18 15:31:41.761+00	2024-05-18 15:31:41.761+00	f	\N	\N	Año	ano-azjx	\N	\N	\N	\N	\N	str
587	2024-05-18 15:31:41.773+00	2024-05-18 15:31:41.773+00	f	\N	\N	Fecha	fecha-ds1j	\N	\N	\N	\N	\N	str
588	2024-05-18 15:31:41.784+00	2024-05-18 15:31:41.784+00	f	\N	\N	Provincia	provincia-9y78	\N	\N	\N	\N	\N	str
589	2024-05-18 15:31:41.793+00	2024-05-18 15:31:41.793+00	f	\N	\N	Accionante	accionante	\N	\N	\N	\N	\N	str
590	2024-05-18 15:31:41.803+00	2024-05-18 15:31:41.803+00	f	\N	\N	Accionado	accionado	\N	\N	\N	\N	\N	str
591	2024-05-18 15:31:41.813+00	2024-05-18 15:31:41.813+00	f	\N	\N	Tipo de Causa	tipo-de-causa	\N	\N	\N	\N	\N	str
592	2024-05-18 15:31:41.823+00	2024-05-18 15:31:41.823+00	f	\N	\N	Organización Política	organizacion-politica	\N	\N	\N	\N	\N	str
593	2024-05-18 15:31:41.833+00	2024-05-18 15:31:41.833+00	f	\N	\N	Enlace a Sentencia	enlace-a-sentencia	\N	\N	\N	\N	\N	str
594	2024-05-18 15:31:41.852+00	2024-05-18 15:31:41.852+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-v219	\N	\N	\N	\N	\N	str
595	2024-05-18 15:31:41.864+00	2024-05-18 15:31:41.864+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-vm64	\N	\N	\N	\N	\N	str
596	2024-05-18 15:31:41.876+00	2024-05-18 15:31:41.876+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-ofhu	\N	\N	\N	\N	\N	str
597	2024-05-18 15:31:41.89+00	2024-05-18 15:31:41.89+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-g53z	\N	\N	\N	\N	\N	str
598	2024-05-18 15:31:41.901+00	2024-05-18 15:31:41.901+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-oker	\N	\N	\N	\N	\N	str
599	2024-05-18 15:31:41.913+00	2024-05-18 15:31:41.913+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-pa0u	\N	\N	\N	\N	\N	str
600	2024-05-18 15:31:41.925+00	2024-05-18 15:31:41.925+00	f	\N	\N	LICENCIA	licencia-lito	\N	\N	\N	\N	\N	str
601	2024-05-18 15:31:41.945+00	2024-05-18 15:31:41.945+00	f	\N	\N	Institución	institucion-c130	\N	\N	\N	\N	\N	str
602	2024-05-18 15:31:41.957+00	2024-05-18 15:31:41.957+00	f	\N	\N	Descripción	descripcion-z4zm	\N	\N	\N	\N	\N	str
603	2024-05-18 15:31:41.969+00	2024-05-18 15:31:41.969+00	f	\N	\N	Nombre del campo	nombre-del-campo-p7bn	\N	\N	\N	\N	\N	str
604	2024-05-18 15:31:41.977+00	2024-05-18 15:31:41.977+00	f	\N	\N	Número de Causa	numero-de-causa-o91y	\N	\N	\N	\N	\N	str
605	2024-05-18 15:31:41.988+00	2024-05-18 15:31:41.988+00	f	\N	\N	Año	ano-xequ	\N	\N	\N	\N	\N	str
606	2024-05-18 15:31:41.999+00	2024-05-18 15:31:41.999+00	f	\N	\N	Fecha	fecha-yhxm	\N	\N	\N	\N	\N	str
607	2024-05-18 15:31:42.011+00	2024-05-18 15:31:42.011+00	f	\N	\N	Provincia	provincia-7w6h	\N	\N	\N	\N	\N	str
608	2024-05-18 15:31:42.023+00	2024-05-18 15:31:42.023+00	f	\N	\N	Accionante	accionante-lyex	\N	\N	\N	\N	\N	str
609	2024-05-18 15:31:42.036+00	2024-05-18 15:31:42.036+00	f	\N	\N	Accionado	accionado-jkbm	\N	\N	\N	\N	\N	str
610	2024-05-18 15:31:42.049+00	2024-05-18 15:31:42.049+00	f	\N	\N	Tipo de causa	tipo-de-causa-yh45	\N	\N	\N	\N	\N	str
611	2024-05-18 15:31:42.065+00	2024-05-18 15:31:42.066+00	f	\N	\N	Organización Política	organizacion-politica-uiq4	\N	\N	\N	\N	\N	str
612	2024-05-18 15:31:42.079+00	2024-05-18 15:31:42.079+00	f	\N	\N	Enlace a Sentencia	enlace-a-sentencia-xd7v	\N	\N	\N	\N	\N	str
613	2024-05-18 15:31:42.104+00	2024-05-18 15:31:42.104+00	f	\N	\N	Unidad	unidad-0lkg	\N	\N	\N	\N	\N	str
614	2024-05-18 15:31:42.114+00	2024-05-18 15:31:42.114+00	f	\N	\N	Objetivo	objetivo	\N	\N	\N	\N	\N	str
615	2024-05-18 15:31:42.123+00	2024-05-18 15:31:42.123+00	f	\N	\N	Indicador	indicador	\N	\N	\N	\N	\N	str
616	2024-05-18 15:31:42.132+00	2024-05-18 15:31:42.132+00	f	\N	\N	Meta cuantificable	meta-cuantificable	\N	\N	\N	\N	\N	str
617	2024-05-18 15:31:42.141+00	2024-05-18 15:31:42.141+00	f	\N	\N	Enlace al sistema de gestión de planificación para verificación de los indicadores y metas cuantificables por procesos o niveles	enlace-al-sistema-de-gestion-de-planificacion-para-verificacion-de-los-indicadores-y-metas-cuantificables-por-procesos-o-niveles	\N	\N	\N	\N	\N	str
618	2024-05-18 15:31:42.159+00	2024-05-18 15:31:42.159+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-hrmv	\N	\N	\N	\N	\N	str
619	2024-05-18 15:31:42.17+00	2024-05-18 15:31:42.17+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-x2lv	\N	\N	\N	\N	\N	str
620	2024-05-18 15:31:42.181+00	2024-05-18 15:31:42.181+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-cxbt	\N	\N	\N	\N	\N	str
621	2024-05-18 15:31:42.192+00	2024-05-18 15:31:42.192+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-btr7	\N	\N	\N	\N	\N	str
622	2024-05-18 15:31:42.204+00	2024-05-18 15:31:42.204+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-hywl	\N	\N	\N	\N	\N	str
623	2024-05-18 15:31:42.216+00	2024-05-18 15:31:42.216+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-w4j2	\N	\N	\N	\N	\N	str
624	2024-05-18 15:31:42.228+00	2024-05-18 15:31:42.228+00	f	\N	\N	LICENCIA	licencia-j5xp	\N	\N	\N	\N	\N	str
628	2024-05-18 15:31:42.362+00	2024-05-18 15:31:42.362+00	f	\N	\N	Unidad	unidad-h3mp	\N	\N	\N	\N	\N	str
629	2024-05-18 15:31:42.377+00	2024-05-18 15:31:42.377+00	f	\N	\N	Objetivo	objetivo-6kdu	\N	\N	\N	\N	\N	str
630	2024-05-18 15:31:42.405+00	2024-05-18 15:31:42.405+00	f	\N	\N	Indicador	indicador-o214	\N	\N	\N	\N	\N	str
631	2024-05-18 15:31:42.421+00	2024-05-18 15:31:42.421+00	f	\N	\N	Meta cuantificable	meta-cuantificable-9m0s	\N	\N	\N	\N	\N	str
632	2024-05-18 15:31:42.434+00	2024-05-18 15:31:42.434+00	f	\N	\N	Enlace al sistema de gestión de planificación para verificación de los indicadores y metas cuantificables por procesos o niveles	enlace-al-sistema-de-gestion-de-planificacion-para-verificacion-de-los-indicadores-y-metas-cuantificables-por-procesos-o-niveles-lj4a	\N	\N	\N	\N	\N	str
633	2024-05-18 15:31:42.455+00	2024-05-18 15:31:42.455+00	f	\N	\N	Nombre del mecanismo 	nombre-del-mecanismo	\N	\N	\N	\N	\N	str
634	2024-05-18 15:31:42.463+00	2024-05-18 15:31:42.463+00	f	\N	\N	Número de certificado	numero-de-certificado	\N	\N	\N	\N	\N	str
635	2024-05-18 15:31:42.473+00	2024-05-18 15:31:42.473+00	f	\N	\N	Período	periodo	\N	\N	\N	\N	\N	str
636	2024-05-18 15:31:42.485+00	2024-05-18 15:31:42.485+00	f	\N	\N	Enlace	enlace-wd15	\N	\N	\N	\N	\N	str
637	2024-05-18 15:31:42.5+00	2024-05-18 15:31:42.5+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN	fecha-actualizacion-de-la-informacion-ub02	\N	\N	\N	\N	\N	str
638	2024-05-18 15:31:42.511+00	2024-05-18 15:31:42.511+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN	periodicidad-de-actualizacion-de-la-informacion-7wrf	\N	\N	\N	\N	\N	str
639	2024-05-18 15:31:42.522+00	2024-05-18 15:31:42.522+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN	unidad-poseedora-de-la-informacion-m01y	\N	\N	\N	\N	\N	str
640	2024-05-18 15:31:42.532+00	2024-05-18 15:31:42.532+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	persona-responsable-de-la-unidad-poseedora-de-la-informacion-n10x	\N	\N	\N	\N	\N	str
641	2024-05-18 15:31:42.542+00	2024-05-18 15:31:42.542+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-5uyw	\N	\N	\N	\N	\N	str
642	2024-05-18 15:31:42.552+00	2024-05-18 15:31:42.552+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-de4z	\N	\N	\N	\N	\N	str
643	2024-05-18 15:31:42.562+00	2024-05-18 15:31:42.562+00	f	\N	\N	LICENCIA	licencia-mpjw	\N	\N	\N	\N	\N	str
644	2024-05-18 15:31:42.571+00	2024-05-18 15:31:42.571+00	f	\N	\N	ENLACE PARA LA DESCARGA DE OTROS MECANISMOS DE RENDICIÓN DE CUENTAS	enlace-para-la-descarga-de-otros-mecanismos-de-rendicion-de-cuentas	\N	\N	\N	\N	\N	str
645	2024-05-18 15:31:42.587+00	2024-05-18 15:31:42.587+00	f	\N	\N	Institución	institucion-imgi	\N	\N	\N	\N	\N	str
646	2024-05-18 15:31:42.598+00	2024-05-18 15:31:42.598+00	f	\N	\N	Descripción	descripcion-rolr	\N	\N	\N	\N	\N	str
647	2024-05-18 15:31:42.609+00	2024-05-18 15:31:42.609+00	f	\N	\N	Nombre del campo	nombre-del-campo-416l	\N	\N	\N	\N	\N	str
648	2024-05-18 15:31:42.619+00	2024-05-18 15:31:42.619+00	f	\N	\N	Nombre del mecanismo	nombre-del-mecanismo-3bhg	\N	\N	\N	\N	\N	str
649	2024-05-18 15:31:42.629+00	2024-05-18 15:31:42.629+00	f	\N	\N	Número de certificado	numero-de-certificado-g2x8	\N	\N	\N	\N	\N	str
650	2024-05-18 15:31:42.639+00	2024-05-18 15:31:42.639+00	f	\N	\N	Período	periodo-1tvp	\N	\N	\N	\N	\N	str
651	2024-05-18 15:31:42.65+00	2024-05-18 15:31:42.65+00	f	\N	\N	Enlace	enlace-m38f	\N	\N	\N	\N	\N	str
652	2024-05-18 15:31:42.668+00	2024-05-18 15:31:42.668+00	f	\N	\N	FECHA DE PUBLICACIÓN	fecha-de-publicacion	\N	\N	\N	\N	\N	str
653	2024-05-18 15:31:42.676+00	2024-05-18 15:31:42.676+00	f	\N	\N	CÓDIGO DEL PROCESO	codigo-del-proceso	\N	\N	\N	\N	\N	str
654	2024-05-18 15:31:42.685+00	2024-05-18 15:31:42.685+00	f	\N	\N	TIPO DE PROCESO	tipo-de-proceso	\N	\N	\N	\N	\N	str
655	2024-05-18 15:31:42.694+00	2024-05-18 15:31:42.694+00	f	\N	\N	OBJETO DEL PROCESO	objeto-del-proceso	\N	\N	\N	\N	\N	str
656	2024-05-18 15:31:42.704+00	2024-05-18 15:31:42.704+00	f	\N	\N	PRESUPUESTO REFERENCIAL (USD)	presupuesto-referencial-usd	\N	\N	\N	\N	\N	str
657	2024-05-18 15:31:42.71+00	2024-05-18 15:31:42.71+00	f	\N	\N	PARTIDA PRESUPUESTARIA	partida-presupuestaria	\N	\N	\N	\N	\N	str
658	2024-05-18 15:31:42.718+00	2024-05-18 15:31:42.718+00	f	\N	\N	MONTO DE LA ADJUDICACIÓN (USD)	monto-de-la-adjudicacion-usd	\N	\N	\N	\N	\N	str
659	2024-05-18 15:31:42.726+00	2024-05-18 15:31:42.726+00	f	\N	\N	ETAPA DE LA CONTRATACIÓN	etapa-de-la-contratacion	\N	\N	\N	\N	\N	str
660	2024-05-18 15:31:42.734+00	2024-05-18 15:31:42.734+00	f	\N	\N	IDENTIFICACIÓN DEL CONTRATISTA	identificacion-del-contratista	\N	\N	\N	\N	\N	str
661	2024-05-18 15:31:42.743+00	2024-05-18 15:31:42.743+00	f	\N	\N	LINK PARA DESCARGAR EL PROCESO DE CONTRATACIÓN DESDE EL PORTAL DE COMPRAS PÚBLICAS	link-para-descargar-el-proceso-de-contratacion-desde-el-portal-de-compras-publicas	\N	\N	\N	\N	\N	str
662	2024-05-18 15:31:42.759+00	2024-05-18 15:31:42.759+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-evcr	\N	\N	\N	\N	\N	str
663	2024-05-18 15:31:42.77+00	2024-05-18 15:31:42.77+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-livw	\N	\N	\N	\N	\N	str
664	2024-05-18 15:31:42.779+00	2024-05-18 15:31:42.779+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-smjh	\N	\N	\N	\N	\N	str
665	2024-05-18 15:31:42.789+00	2024-05-18 15:31:42.789+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-jouw	\N	\N	\N	\N	\N	str
666	2024-05-18 15:31:42.799+00	2024-05-18 15:31:42.799+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-wgf8	\N	\N	\N	\N	\N	str
667	2024-05-18 15:31:42.809+00	2024-05-18 15:31:42.809+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-07dd	\N	\N	\N	\N	\N	str
668	2024-05-18 15:31:42.818+00	2024-05-18 15:31:42.818+00	f	\N	\N	Enlace para la búsqueda de procesos de contratación desde el Sistema Oficial de Contratación Pública	enlace-para-la-busqueda-de-procesos-de-contratacion-desde-el-sistema-oficial-de-contratacion-publica	\N	\N	\N	\N	\N	str
669	2024-05-18 15:31:42.828+00	2024-05-18 15:31:42.828+00	f	\N	\N	LICENCIA 	licencia-p4pw	\N	\N	\N	\N	\N	str
670	2024-05-18 15:31:42.844+00	2024-05-18 15:31:42.844+00	f	\N	\N	Institución	institucion-kvgs	\N	\N	\N	\N	\N	str
671	2024-05-18 15:31:42.854+00	2024-05-18 15:31:42.854+00	f	\N	\N	Descripción	descripcion-7rlu	\N	\N	\N	\N	\N	str
672	2024-05-18 15:31:42.864+00	2024-05-18 15:31:42.864+00	f	\N	\N	Nombre del campo	nombre-del-campo-l0je	\N	\N	\N	\N	\N	str
673	2024-05-18 15:31:42.874+00	2024-05-18 15:31:42.874+00	f	\N	\N	Fecha de publicación	fecha-de-publicacion-a484	\N	\N	\N	\N	\N	str
674	2024-05-18 15:31:42.885+00	2024-05-18 15:31:42.885+00	f	\N	\N	Código del proceso	codigo-del-proceso-8unq	\N	\N	\N	\N	\N	str
675	2024-05-18 15:31:42.895+00	2024-05-18 15:31:42.895+00	f	\N	\N	Tipo de proceso	tipo-de-proceso-ox7j	\N	\N	\N	\N	\N	str
676	2024-05-18 15:31:42.906+00	2024-05-18 15:31:42.906+00	f	\N	\N	Objeto del proceso	objeto-del-proceso-9hqa	\N	\N	\N	\N	\N	str
677	2024-05-18 15:31:42.918+00	2024-05-18 15:31:42.918+00	f	\N	\N	Presupuesto referencial (USD)	presupuesto-referencial-usd-xmge	\N	\N	\N	\N	\N	str
678	2024-05-18 15:31:42.93+00	2024-05-18 15:31:42.93+00	f	\N	\N	Partida presupuestaria	partida-presupuestaria-2mzz	\N	\N	\N	\N	\N	str
679	2024-05-18 15:31:42.941+00	2024-05-18 15:31:42.941+00	f	\N	\N	Monto de la adjudicación (USD)	monto-de-la-adjudicacion-usd-24v6	\N	\N	\N	\N	\N	str
680	2024-05-18 15:31:42.952+00	2024-05-18 15:31:42.952+00	f	\N	\N	Etapa de la contratación	etapa-de-la-contratacion-xl0v	\N	\N	\N	\N	\N	str
681	2024-05-18 15:31:42.961+00	2024-05-18 15:31:42.961+00	f	\N	\N	RUC 	ruc	\N	\N	\N	\N	\N	str
682	2024-05-18 15:31:42.97+00	2024-05-18 15:31:42.97+00	f	\N	\N	Link para descargar el proceso de contratación desde el portal de comprass públicas	link-para-descargar-el-proceso-de-contratacion-desde-el-portal-de-comprass-publicas	\N	\N	\N	\N	\N	str
683	2024-05-18 15:31:42.99+00	2024-05-18 15:31:42.99+00	f	\N	\N	No.	no-qoi1	\N	\N	\N	\N	\N	str
684	2024-05-18 15:31:43.001+00	2024-05-18 15:31:43.001+00	f	\N	\N	Apellidos y Nombres de los servidores y servidoras	apellidos-y-nombres-de-los-servidores-y-servidoras-iht2	\N	\N	\N	\N	\N	str
685	2024-05-18 15:31:43.011+00	2024-05-18 15:31:43.011+00	f	\N	\N	Puesto Institucional	puesto-institucional-wwrq	\N	\N	\N	\N	\N	str
686	2024-05-18 15:31:43.022+00	2024-05-18 15:31:43.022+00	f	\N	\N	Unidad a la que pertenece	unidad-a-la-que-pertenece-i9sz	\N	\N	\N	\N	\N	str
687	2024-05-18 15:31:43.032+00	2024-05-18 15:31:43.032+00	f	\N	\N	Dirección institucional	direccion-institucional-31fl	\N	\N	\N	\N	\N	str
688	2024-05-18 15:31:43.042+00	2024-05-18 15:31:43.042+00	f	\N	\N	Ciudad en la que labora	ciudad-en-la-que-labora-5z79	\N	\N	\N	\N	\N	str
689	2024-05-18 15:31:43.052+00	2024-05-18 15:31:43.052+00	f	\N	\N	Teléfono institucional	telefono-institucional-dwes	\N	\N	\N	\N	\N	str
690	2024-05-18 15:31:43.062+00	2024-05-18 15:31:43.062+00	f	\N	\N	Extensión telefónica	extension-telefonica-62yo	\N	\N	\N	\N	\N	str
691	2024-05-18 15:31:43.072+00	2024-05-18 15:31:43.072+00	f	\N	\N	Correo Electrónico institucional	correo-electronico-institucional-m2mv	\N	\N	\N	\N	\N	str
692	2024-05-18 15:31:43.083+00	2024-05-18 15:31:43.083+00	f	\N	\N	Unnamed: 9	unnamed-9-adsq	\N	\N	\N	\N	\N	str
693	2024-05-18 15:31:43.107+00	2024-05-18 15:31:43.107+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN	fecha-actualizacion-de-la-informacion-j64x	\N	\N	\N	\N	\N	str
694	2024-05-18 15:31:43.12+00	2024-05-18 15:31:43.12+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN	periodicidad-de-actualizacion-de-la-informacion-hcdl	\N	\N	\N	\N	\N	str
695	2024-05-18 15:31:43.139+00	2024-05-18 15:31:43.139+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACION	unidad-poseedora-de-la-informacion-ta2q	\N	\N	\N	\N	\N	str
696	2024-05-18 15:31:43.153+00	2024-05-18 15:31:43.154+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	persona-responsable-de-la-unidad-poseedora-de-la-informacion-etgk	\N	\N	\N	\N	\N	str
697	2024-05-18 15:31:43.167+00	2024-05-18 15:31:43.167+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-mzkj	\N	\N	\N	\N	\N	str
698	2024-05-18 15:31:43.18+00	2024-05-18 15:31:43.18+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-l2r1	\N	\N	\N	\N	\N	str
699	2024-05-18 15:31:43.193+00	2024-05-18 15:31:43.193+00	f	\N	\N	LICENCIA	licencia-inyh	\N	\N	\N	\N	\N	str
700	2024-05-18 15:31:43.212+00	2024-05-18 15:31:43.212+00	f	\N	\N	Institución	institucion-yo2t	\N	\N	\N	\N	\N	str
701	2024-05-18 15:31:43.223+00	2024-05-18 15:31:43.223+00	f	\N	\N	Descripción	descripcion-zvqa	\N	\N	\N	\N	\N	str
702	2024-05-18 15:31:43.235+00	2024-05-18 15:31:43.235+00	f	\N	\N	Nombre del campo	nombre-del-campo-84yx	\N	\N	\N	\N	\N	str
703	2024-05-18 15:31:43.246+00	2024-05-18 15:31:43.246+00	f	\N	\N	No.	no-iqx1	\N	\N	\N	\N	\N	str
704	2024-05-18 15:31:43.257+00	2024-05-18 15:31:43.257+00	f	\N	\N	Apellidos y Nombres de los servidores y servidoras	apellidos-y-nombres-de-los-servidores-y-servidoras-7507	\N	\N	\N	\N	\N	str
705	2024-05-18 15:31:43.268+00	2024-05-18 15:31:43.268+00	f	\N	\N	Puesto Institucional	puesto-institucional-bbnw	\N	\N	\N	\N	\N	str
706	2024-05-18 15:31:43.278+00	2024-05-18 15:31:43.278+00	f	\N	\N	Unidad a la que pertenece	unidad-a-la-que-pertenece-6yqn	\N	\N	\N	\N	\N	str
707	2024-05-18 15:31:43.289+00	2024-05-18 15:31:43.289+00	f	\N	\N	Dirección institucional	direccion-institucional-g2p4	\N	\N	\N	\N	\N	str
708	2024-05-18 15:31:43.299+00	2024-05-18 15:31:43.299+00	f	\N	\N	Ciudad en la que labora	ciudad-en-la-que-labora-xcwz	\N	\N	\N	\N	\N	str
709	2024-05-18 15:31:43.308+00	2024-05-18 15:31:43.308+00	f	\N	\N	Teléfono institucional	telefono-institucional-ww7b	\N	\N	\N	\N	\N	str
710	2024-05-18 15:31:43.319+00	2024-05-18 15:31:43.319+00	f	\N	\N	Extensión telefónica	extension-telefonica-xmhs	\N	\N	\N	\N	\N	str
711	2024-05-18 15:31:43.329+00	2024-05-18 15:31:43.33+00	f	\N	\N	Correo Electrónico institucional	correo-electronico-institucional-ga7n	\N	\N	\N	\N	\N	str
712	2024-05-18 15:31:43.353+00	2024-05-18 15:31:43.353+00	f	\N	\N	Fecha 	fecha-11wz	\N	\N	\N	\N	\N	str
713	2024-05-18 15:31:43.367+00	2024-05-18 15:31:43.367+00	f	\N	\N	Descripción	descripcion-dz2g	\N	\N	\N	\N	\N	str
714	2024-05-18 15:31:43.377+00	2024-05-18 15:31:43.377+00	f	\N	\N	Ocasión o motivo	ocasion-o-motivo	\N	\N	\N	\N	\N	str
715	2024-05-18 15:31:43.388+00	2024-05-18 15:31:43.388+00	f	\N	\N	Persona natural o jurídica 	persona-natural-o-juridica	\N	\N	\N	\N	\N	str
716	2024-05-18 15:31:43.397+00	2024-05-18 15:31:43.397+00	f	\N	\N	Enlace para descargar el documento mediante el cual se oficializa el regalo o donativo	enlace-para-descargar-el-documento-mediante-el-cual-se-oficializa-el-regalo-o-donativo	\N	\N	\N	\N	\N	str
717	2024-05-18 15:31:43.416+00	2024-05-18 15:31:43.416+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-x8mc	\N	\N	\N	\N	\N	str
718	2024-05-18 15:31:43.427+00	2024-05-18 15:31:43.427+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-vt28	\N	\N	\N	\N	\N	str
719	2024-05-18 15:31:43.44+00	2024-05-18 15:31:43.44+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-ayx1	\N	\N	\N	\N	\N	str
720	2024-05-18 15:31:43.453+00	2024-05-18 15:31:43.453+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-ysmb	\N	\N	\N	\N	\N	str
721	2024-05-18 15:31:43.465+00	2024-05-18 15:31:43.465+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-5b7k	\N	\N	\N	\N	\N	str
722	2024-05-18 15:31:43.475+00	2024-05-18 15:31:43.475+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-jkef	\N	\N	\N	\N	\N	str
723	2024-05-18 15:31:43.486+00	2024-05-18 15:31:43.486+00	f	\N	\N	LICENCIA	licencia-k5vy	\N	\N	\N	\N	\N	str
724	2024-05-18 15:31:43.505+00	2024-05-18 15:31:43.505+00	f	\N	\N	Institución	institucion-6q95	\N	\N	\N	\N	\N	str
725	2024-05-18 15:31:43.518+00	2024-05-18 15:31:43.518+00	f	\N	\N	Descripción	descripcion-79v5	\N	\N	\N	\N	\N	str
726	2024-05-18 15:31:43.529+00	2024-05-18 15:31:43.529+00	f	\N	\N	Nombre del campo	nombre-del-campo-zymf	\N	\N	\N	\N	\N	str
727	2024-05-18 15:31:43.541+00	2024-05-18 15:31:43.541+00	f	\N	\N	Fecha 	fecha-b544	\N	\N	\N	\N	\N	str
728	2024-05-18 15:31:43.553+00	2024-05-18 15:31:43.553+00	f	\N	\N	Descripción 	descripcion-2nx3	\N	\N	\N	\N	\N	str
729	2024-05-18 15:31:43.562+00	2024-05-18 15:31:43.562+00	f	\N	\N	Motivo 	motivo	\N	\N	\N	\N	\N	str
730	2024-05-18 15:31:43.573+00	2024-05-18 15:31:43.573+00	f	\N	\N	Persona natural o jurídica 	persona-natural-o-juridica-xcha	\N	\N	\N	\N	\N	str
731	2024-05-18 15:31:43.585+00	2024-05-18 15:31:43.585+00	f	\N	\N	Enlace para descargar el documento mediante el cual se oficializa el regalo o donativo	enlace-para-descargar-el-documento-mediante-el-cual-se-oficializa-el-regalo-o-donativo-vvn7	\N	\N	\N	\N	\N	str
732	2024-05-18 15:31:43.606+00	2024-05-18 15:31:43.606+00	f	\N	\N	Tema 	tema	\N	\N	\N	\N	\N	str
733	2024-05-18 15:31:43.615+00	2024-05-18 15:31:43.615+00	f	\N	\N	Número de requerimientos	numero-de-requerimientos	\N	\N	\N	\N	\N	str
734	2024-05-18 15:31:43.625+00	2024-05-18 15:31:43.625+00	f	\N	\N	Enlace para descargar el detalle de la información solicitada frecuentemente	enlace-para-descargar-el-detalle-de-la-informacion-solicitada-frecuentemente	\N	\N	\N	\N	\N	str
735	2024-05-18 15:31:43.634+00	2024-05-18 15:31:43.634+00	f	\N	\N	Enlace para descargar la solicitud de información complementaria que haya sido solicitada recurrentemente	enlace-para-descargar-la-solicitud-de-informacion-complementaria-que-haya-sido-solicitada-recurrentemente	\N	\N	\N	\N	\N	str
736	2024-05-18 15:31:43.654+00	2024-05-18 15:31:43.654+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN	fecha-actualizacion-de-la-informacion-7c2k	\N	\N	\N	\N	\N	str
737	2024-05-18 15:31:43.665+00	2024-05-18 15:31:43.665+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN	periodicidad-de-actualizacion-de-la-informacion-irtb	\N	\N	\N	\N	\N	str
738	2024-05-18 15:31:43.676+00	2024-05-18 15:31:43.676+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN	unidad-poseedora-de-la-informacion-xuea	\N	\N	\N	\N	\N	str
739	2024-05-18 15:31:43.687+00	2024-05-18 15:31:43.687+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	persona-responsable-de-la-unidad-poseedora-de-la-informacion-izpa	\N	\N	\N	\N	\N	str
740	2024-05-18 15:31:43.697+00	2024-05-18 15:31:43.697+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-48uo	\N	\N	\N	\N	\N	str
741	2024-05-18 15:31:43.708+00	2024-05-18 15:31:43.708+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-rxbb	\N	\N	\N	\N	\N	str
742	2024-05-18 15:31:43.719+00	2024-05-18 15:31:43.719+00	f	\N	\N	LICENCIA	licencia-6t2i	\N	\N	\N	\N	\N	str
743	2024-05-18 15:31:43.739+00	2024-05-18 15:31:43.739+00	f	\N	\N	Institución	institucion-b6vf	\N	\N	\N	\N	\N	str
744	2024-05-18 15:31:43.752+00	2024-05-18 15:31:43.752+00	f	\N	\N	Descripción	descripcion-ypzo	\N	\N	\N	\N	\N	str
745	2024-05-18 15:31:43.762+00	2024-05-18 15:31:43.762+00	f	\N	\N	Nombre del campo	nombre-del-campo-nicg	\N	\N	\N	\N	\N	str
746	2024-05-18 15:31:43.775+00	2024-05-18 15:31:43.775+00	f	\N	\N	Tema	tema-4ydo	\N	\N	\N	\N	\N	str
747	2024-05-18 15:31:43.786+00	2024-05-18 15:31:43.786+00	f	\N	\N	Número de requerimientos	numero-de-requerimientos-cuxn	\N	\N	\N	\N	\N	str
748	2024-05-18 15:31:43.797+00	2024-05-18 15:31:43.797+00	f	\N	\N	Enlace para descargar el detalle de la información solicitada frecuentemente	enlace-para-descargar-el-detalle-de-la-informacion-solicitada-frecuentemente-d9ib	\N	\N	\N	\N	\N	str
749	2024-05-18 15:31:43.811+00	2024-05-18 15:31:43.811+00	f	\N	\N	Enlace para descargar la solicitud de información complementaria que haya sido solicitada recurrentemente	enlace-para-descargar-la-solicitud-de-informacion-complementaria-que-haya-sido-solicitada-recurrentemente-2rz1	\N	\N	\N	\N	\N	str
750	2024-05-18 15:31:43.832+00	2024-05-18 15:31:43.832+00	f	\N	\N	Organización política, candidato/a	organizacion-politica-candidatoa	\N	\N	\N	\N	\N	str
751	2024-05-18 15:31:43.844+00	2024-05-18 15:31:43.844+00	f	\N	\N	Proceso Electoral	proceso-electoral-jkcb	\N	\N	\N	\N	\N	str
752	2024-05-18 15:31:43.855+00	2024-05-18 15:31:43.855+00	f	\N	\N	Dignidad	dignidad-3jyi	\N	\N	\N	\N	\N	str
753	2024-05-18 15:31:43.865+00	2024-05-18 15:31:43.865+00	f	\N	\N	Monto recibido	monto-recibido	\N	\N	\N	\N	\N	str
754	2024-05-18 15:31:43.875+00	2024-05-18 15:31:43.875+00	f	\N	\N	Monto gastado	monto-gastado	\N	\N	\N	\N	\N	str
755	2024-05-18 15:31:43.895+00	2024-05-18 15:31:43.895+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-w7qe	\N	\N	\N	\N	\N	str
756	2024-05-18 15:31:43.907+00	2024-05-18 15:31:43.907+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-dpx0	\N	\N	\N	\N	\N	str
757	2024-05-18 15:31:43.918+00	2024-05-18 15:31:43.918+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-a0y4	\N	\N	\N	\N	\N	str
758	2024-05-18 15:31:43.928+00	2024-05-18 15:31:43.928+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-5rnh	\N	\N	\N	\N	\N	str
759	2024-05-18 15:31:43.94+00	2024-05-18 15:31:43.94+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-ckav	\N	\N	\N	\N	\N	str
760	2024-05-18 15:31:43.952+00	2024-05-18 15:31:43.952+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-q9v0	\N	\N	\N	\N	\N	str
761	2024-05-18 15:31:43.962+00	2024-05-18 15:31:43.962+00	f	\N	\N	LICENCIA	licencia-jurc	\N	\N	\N	\N	\N	str
762	2024-05-18 15:31:43.972+00	2024-05-18 15:31:43.972+00	f	\N	\N	Enlace para direccionar a los planes de trabajo de las candidatas y candidatos a las distintas elecciones	enlace-para-direccionar-a-los-planes-de-trabajo-de-las-candidatas-y-candidatos-a-las-distintas-elecciones	\N	\N	\N	\N	\N	str
763	2024-05-18 15:31:43.98+00	2024-05-18 15:31:43.98+00	f	\N	\N	Enlace para direccionar a los resultados de los procesos electorales	enlace-para-direccionar-a-los-resultados-de-los-procesos-electorales	\N	\N	\N	\N	\N	str
764	2024-05-18 15:31:43.99+00	2024-05-18 15:31:43.99+00	f	\N	\N	Enlace para direccionar a las actas de cada junta y recinto electoral 	enlace-para-direccionar-a-las-actas-de-cada-junta-y-recinto-electoral	\N	\N	\N	\N	\N	str
765	2024-05-18 15:31:44.008+00	2024-05-18 15:31:44.008+00	f	\N	\N	Institución	institucion-i9j9	\N	\N	\N	\N	\N	str
766	2024-05-18 15:31:44.022+00	2024-05-18 15:31:44.022+00	f	\N	\N	Descripción	descripcion-hmdu	\N	\N	\N	\N	\N	str
767	2024-05-18 15:31:44.033+00	2024-05-18 15:31:44.033+00	f	\N	\N	Nombre del campo	nombre-del-campo-o9dv	\N	\N	\N	\N	\N	str
768	2024-05-18 15:31:44.043+00	2024-05-18 15:31:44.043+00	f	\N	\N	Organización política, candidato/a	organizacion-politica-candidatoa-i6lq	\N	\N	\N	\N	\N	str
769	2024-05-18 15:31:44.055+00	2024-05-18 15:31:44.055+00	f	\N	\N	Proceso Electoral	proceso-electoral-gljw	\N	\N	\N	\N	\N	str
770	2024-05-18 15:31:44.067+00	2024-05-18 15:31:44.068+00	f	\N	\N	Dignidad	dignidad-25zd	\N	\N	\N	\N	\N	str
771	2024-05-18 15:31:44.079+00	2024-05-18 15:31:44.079+00	f	\N	\N	Monto recibido	monto-recibido-2vvh	\N	\N	\N	\N	\N	str
772	2024-05-18 15:31:44.09+00	2024-05-18 15:31:44.09+00	f	\N	\N	Monto gastado	monto-gastado-l9li	\N	\N	\N	\N	\N	str
773	2024-05-18 15:31:44.11+00	2024-05-18 15:31:44.11+00	f	\N	\N	Organización Política o Alianza	organizacion-politica-o-alianza-535y	\N	\N	\N	\N	\N	str
774	2024-05-18 15:31:44.124+00	2024-05-18 15:31:44.124+00	f	\N	\N	Proceso Electoral	proceso-electoral-tqki	\N	\N	\N	\N	\N	str
775	2024-05-18 15:31:44.136+00	2024-05-18 15:31:44.136+00	f	\N	\N	Mes	mes-uo03	\N	\N	\N	\N	\N	str
776	2024-05-18 15:31:44.147+00	2024-05-18 15:31:44.147+00	f	\N	\N	Dignidad	dignidad-85bw	\N	\N	\N	\N	\N	str
777	2024-05-18 15:31:44.158+00	2024-05-18 15:31:44.158+00	f	\N	\N	Provincia	provincia-fd3c	\N	\N	\N	\N	\N	str
778	2024-05-18 15:31:44.17+00	2024-05-18 15:31:44.17+00	f	\N	\N	Circunscripción	circunscripcion-yah8	\N	\N	\N	\N	\N	str
779	2024-05-18 15:31:44.205+00	2024-05-18 15:31:44.205+00	f	\N	\N	Cantón	canton-7efe	\N	\N	\N	\N	\N	str
780	2024-05-18 15:31:44.217+00	2024-05-18 15:31:44.217+00	f	\N	\N	Parroquia	parroquia-6ypz	\N	\N	\N	\N	\N	str
781	2024-05-18 15:31:44.227+00	2024-05-18 15:31:44.227+00	f	\N	\N	Código Cuenta	codigo-cuenta-4y2n	\N	\N	\N	\N	\N	str
782	2024-05-18 15:31:44.238+00	2024-05-18 15:31:44.238+00	f	\N	\N	Cuenta	cuenta-m1gn	\N	\N	\N	\N	\N	str
783	2024-05-18 15:31:44.248+00	2024-05-18 15:31:44.248+00	f	\N	\N	Código Subcuenta	codigo-subcuenta-9ysr	\N	\N	\N	\N	\N	str
784	2024-05-18 15:31:44.258+00	2024-05-18 15:31:44.258+00	f	\N	\N	Subcuenta	subcuenta-rwre	\N	\N	\N	\N	\N	str
785	2024-05-18 15:31:44.269+00	2024-05-18 15:31:44.269+00	f	\N	\N	Fecha Comprobante de Venta	fecha-comprobante-de-venta-zbq4	\N	\N	\N	\N	\N	str
786	2024-05-18 15:31:44.279+00	2024-05-18 15:31:44.279+00	f	\N	\N	Nro. Comprobante de Venta	nro-comprobante-de-venta-lyg5	\N	\N	\N	\N	\N	str
787	2024-05-18 15:31:44.29+00	2024-05-18 15:31:44.29+00	f	\N	\N	Nro. RUC del Proveedor	nro-ruc-del-proveedor-ytth	\N	\N	\N	\N	\N	str
788	2024-05-18 15:31:44.302+00	2024-05-18 15:31:44.302+00	f	\N	\N	Nombre del Proveedor	nombre-del-proveedor-i9tt	\N	\N	\N	\N	\N	str
789	2024-05-18 15:31:44.312+00	2024-05-18 15:31:44.312+00	f	\N	\N	Descripción del Gasto	descripcion-del-gasto-j2ik	\N	\N	\N	\N	\N	str
790	2024-05-18 15:31:44.323+00	2024-05-18 15:31:44.323+00	f	\N	\N	Subtotal	subtotal-vx9q	\N	\N	\N	\N	\N	str
791	2024-05-18 15:31:44.335+00	2024-05-18 15:31:44.335+00	f	\N	\N	IVA	iva-pvbt	\N	\N	\N	\N	\N	str
792	2024-05-18 15:31:44.346+00	2024-05-18 15:31:44.346+00	f	\N	\N	Total	total-fu3j	\N	\N	\N	\N	\N	str
793	2024-05-18 15:31:44.364+00	2024-05-18 15:31:44.364+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-ib3b	\N	\N	\N	\N	\N	str
794	2024-05-18 15:31:44.375+00	2024-05-18 15:31:44.375+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-6702	\N	\N	\N	\N	\N	str
795	2024-05-18 15:31:44.386+00	2024-05-18 15:31:44.386+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-xo9y	\N	\N	\N	\N	\N	str
796	2024-05-18 15:31:44.397+00	2024-05-18 15:31:44.397+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-v7tr	\N	\N	\N	\N	\N	str
797	2024-05-18 15:31:44.408+00	2024-05-18 15:31:44.408+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-zsq5	\N	\N	\N	\N	\N	str
798	2024-05-18 15:31:44.419+00	2024-05-18 15:31:44.419+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-xu4t	\N	\N	\N	\N	\N	str
799	2024-05-18 15:31:44.43+00	2024-05-18 15:31:44.43+00	f	\N	\N	LICENCIA	licencia-b5xa	\N	\N	\N	\N	\N	str
800	2024-05-18 15:31:44.44+00	2024-05-18 15:31:44.44+00	f	\N	\N	Enlace para direccionar a los planes de trabajo de las candidatas y candidatos a las distintas elecciones	enlace-para-direccionar-a-los-planes-de-trabajo-de-las-candidatas-y-candidatos-a-las-distintas-elecciones-0sgi	\N	\N	\N	\N	\N	str
979	2024-05-18 15:31:46.491+00	2024-05-18 15:31:46.491+00	f	\N	\N	Enlace al estado 	enlace-al-estado	\N	\N	\N	\N	\N	str
801	2024-05-18 15:31:44.451+00	2024-05-18 15:31:44.451+00	f	\N	\N	Enlace para direccionar a los resultados de los procesos electorales	enlace-para-direccionar-a-los-resultados-de-los-procesos-electorales-uldg	\N	\N	\N	\N	\N	str
802	2024-05-18 15:31:44.462+00	2024-05-18 15:31:44.462+00	f	\N	\N	Enlace para direccionar a las actas de cada junta y recinto electoral 	enlace-para-direccionar-a-las-actas-de-cada-junta-y-recinto-electoral-u1kv	\N	\N	\N	\N	\N	str
803	2024-05-18 15:31:44.478+00	2024-05-18 15:31:44.478+00	f	\N	\N	Institución	institucion-qdmn	\N	\N	\N	\N	\N	str
804	2024-05-18 15:31:44.489+00	2024-05-18 15:31:44.489+00	f	\N	\N	Descripción	descripcion-d0ih	\N	\N	\N	\N	\N	str
805	2024-05-18 15:31:44.499+00	2024-05-18 15:31:44.499+00	f	\N	\N	Nombre del campo	nombre-del-campo-ih1k	\N	\N	\N	\N	\N	str
806	2024-05-18 15:31:44.51+00	2024-05-18 15:31:44.51+00	f	\N	\N	Organización Política o Alianza	organizacion-politica-o-alianza-m1hu	\N	\N	\N	\N	\N	str
807	2024-05-18 15:31:44.521+00	2024-05-18 15:31:44.521+00	f	\N	\N	Proceso Electoral	proceso-electoral-kqk2	\N	\N	\N	\N	\N	str
808	2024-05-18 15:31:44.531+00	2024-05-18 15:31:44.531+00	f	\N	\N	Mes	mes-2g4j	\N	\N	\N	\N	\N	str
809	2024-05-18 15:31:44.541+00	2024-05-18 15:31:44.541+00	f	\N	\N	Dignidad	dignidad-bq7p	\N	\N	\N	\N	\N	str
810	2024-05-18 15:31:44.552+00	2024-05-18 15:31:44.552+00	f	\N	\N	Provincia	provincia-a8g1	\N	\N	\N	\N	\N	str
811	2024-05-18 15:31:44.561+00	2024-05-18 15:31:44.561+00	f	\N	\N	Circunscripción	circunscripcion-pmbd	\N	\N	\N	\N	\N	str
812	2024-05-18 15:31:44.573+00	2024-05-18 15:31:44.573+00	f	\N	\N	Cantón	canton-h0ds	\N	\N	\N	\N	\N	str
813	2024-05-18 15:31:44.585+00	2024-05-18 15:31:44.585+00	f	\N	\N	Parroquia	parroquia-owuj	\N	\N	\N	\N	\N	str
814	2024-05-18 15:31:44.596+00	2024-05-18 15:31:44.596+00	f	\N	\N	Código Cuenta	codigo-cuenta-veta	\N	\N	\N	\N	\N	str
815	2024-05-18 15:31:44.608+00	2024-05-18 15:31:44.608+00	f	\N	\N	Cuenta	cuenta-h5ru	\N	\N	\N	\N	\N	str
816	2024-05-18 15:31:44.62+00	2024-05-18 15:31:44.62+00	f	\N	\N	Código Subcuenta	codigo-subcuenta-kv50	\N	\N	\N	\N	\N	str
817	2024-05-18 15:31:44.632+00	2024-05-18 15:31:44.632+00	f	\N	\N	Subcuenta	subcuenta-ht1r	\N	\N	\N	\N	\N	str
818	2024-05-18 15:31:44.644+00	2024-05-18 15:31:44.644+00	f	\N	\N	Fecha Comprobante de Venta	fecha-comprobante-de-venta-e3yb	\N	\N	\N	\N	\N	str
819	2024-05-18 15:31:44.657+00	2024-05-18 15:31:44.657+00	f	\N	\N	Nro. Comprobante de Venta	nro-comprobante-de-venta-8lob	\N	\N	\N	\N	\N	str
820	2024-05-18 15:31:44.669+00	2024-05-18 15:31:44.669+00	f	\N	\N	Nro. RUC del Proveedor	nro-ruc-del-proveedor-7gwa	\N	\N	\N	\N	\N	str
821	2024-05-18 15:31:44.681+00	2024-05-18 15:31:44.681+00	f	\N	\N	Nombre del Proveedor	nombre-del-proveedor-b2ye	\N	\N	\N	\N	\N	str
822	2024-05-18 15:31:44.694+00	2024-05-18 15:31:44.694+00	f	\N	\N	Descripción del Gasto	descripcion-del-gasto-ss7l	\N	\N	\N	\N	\N	str
823	2024-05-18 15:31:44.706+00	2024-05-18 15:31:44.706+00	f	\N	\N	Subtotal	subtotal-o771	\N	\N	\N	\N	\N	str
824	2024-05-18 15:31:44.719+00	2024-05-18 15:31:44.719+00	f	\N	\N	IVA	iva-psq5	\N	\N	\N	\N	\N	str
825	2024-05-18 15:31:44.73+00	2024-05-18 15:31:44.73+00	f	\N	\N	Total	total-xbd1	\N	\N	\N	\N	\N	str
826	2024-05-18 15:31:44.749+00	2024-05-18 15:31:44.749+00	f	\N	\N	Proceso Electoral	proceso-electoral-8eeh	\N	\N	\N	\N	\N	str
827	2024-05-18 15:31:44.762+00	2024-05-18 15:31:44.762+00	f	\N	\N	Provincia	provincia-smhc	\N	\N	\N	\N	\N	str
828	2024-05-18 15:31:44.773+00	2024-05-18 15:31:44.773+00	f	\N	\N	Cantón	canton-7iog	\N	\N	\N	\N	\N	str
829	2024-05-18 15:31:44.785+00	2024-05-18 15:31:44.785+00	f	\N	\N	Circunscripción	circunscripcion-rl1p	\N	\N	\N	\N	\N	str
830	2024-05-18 15:31:44.796+00	2024-05-18 15:31:44.796+00	f	\N	\N	Parroquia	parroquia-npbk	\N	\N	\N	\N	\N	str
831	2024-05-18 15:31:44.805+00	2024-05-18 15:31:44.805+00	f	\N	\N	Zona	zona	\N	\N	\N	\N	\N	str
832	2024-05-18 15:31:44.814+00	2024-05-18 15:31:44.814+00	f	\N	\N	Junta	junta	\N	\N	\N	\N	\N	str
833	2024-05-18 15:31:44.826+00	2024-05-18 15:31:44.826+00	f	\N	\N	Dignidad	dignidad-ufcz	\N	\N	\N	\N	\N	str
834	2024-05-18 15:31:44.835+00	2024-05-18 15:31:44.835+00	f	\N	\N	Enlace al Acta	enlace-al-acta	\N	\N	\N	\N	\N	str
835	2024-05-18 15:31:44.857+00	2024-05-18 15:31:44.857+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-0ram	\N	\N	\N	\N	\N	str
836	2024-05-18 15:31:44.87+00	2024-05-18 15:31:44.87+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-ae9k	\N	\N	\N	\N	\N	str
837	2024-05-18 15:31:44.881+00	2024-05-18 15:31:44.881+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-w1p5	\N	\N	\N	\N	\N	str
838	2024-05-18 15:31:44.892+00	2024-05-18 15:31:44.892+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-0a7s	\N	\N	\N	\N	\N	str
839	2024-05-18 15:31:44.903+00	2024-05-18 15:31:44.903+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-yujz	\N	\N	\N	\N	\N	str
840	2024-05-18 15:31:44.913+00	2024-05-18 15:31:44.913+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-gb9y	\N	\N	\N	\N	\N	str
841	2024-05-18 15:31:44.924+00	2024-05-18 15:31:44.924+00	f	\N	\N	LICENCIA	licencia-vy6x	\N	\N	\N	\N	\N	str
842	2024-05-18 15:31:44.935+00	2024-05-18 15:31:44.935+00	f	\N	\N	Enlace para direccionar a los planes de trabajo de las candidatas y candidatos a las distintas elecciones	enlace-para-direccionar-a-los-planes-de-trabajo-de-las-candidatas-y-candidatos-a-las-distintas-elecciones-b500	\N	\N	\N	\N	\N	str
843	2024-05-18 15:31:44.945+00	2024-05-18 15:31:44.945+00	f	\N	\N	Enlace para direccionar a los resultados de los procesos electorales	enlace-para-direccionar-a-los-resultados-de-los-procesos-electorales-e0q2	\N	\N	\N	\N	\N	str
844	2024-05-18 15:31:44.956+00	2024-05-18 15:31:44.956+00	f	\N	\N	Enlace para direccionar a las actas de cada junta y recinto electoral 	enlace-para-direccionar-a-las-actas-de-cada-junta-y-recinto-electoral-1hm7	\N	\N	\N	\N	\N	str
845	2024-05-18 15:31:44.973+00	2024-05-18 15:31:44.973+00	f	\N	\N	Institución	institucion-yu1o	\N	\N	\N	\N	\N	str
846	2024-05-18 15:31:44.984+00	2024-05-18 15:31:44.984+00	f	\N	\N	Descripción	descripcion-xqfa	\N	\N	\N	\N	\N	str
847	2024-05-18 15:31:44.993+00	2024-05-18 15:31:44.993+00	f	\N	\N	Nombre del campo	nombre-del-campo-pq9g	\N	\N	\N	\N	\N	str
848	2024-05-18 15:31:45.004+00	2024-05-18 15:31:45.004+00	f	\N	\N	Proceso Electoral	proceso-electoral-ekp2	\N	\N	\N	\N	\N	str
849	2024-05-18 15:31:45.014+00	2024-05-18 15:31:45.014+00	f	\N	\N	Provincia	provincia-y4li	\N	\N	\N	\N	\N	str
850	2024-05-18 15:31:45.024+00	2024-05-18 15:31:45.024+00	f	\N	\N	Cantón	canton-cvcm	\N	\N	\N	\N	\N	str
851	2024-05-18 15:31:45.034+00	2024-05-18 15:31:45.034+00	f	\N	\N	Circunscripción	circunscripcion-uwbl	\N	\N	\N	\N	\N	str
852	2024-05-18 15:31:45.044+00	2024-05-18 15:31:45.044+00	f	\N	\N	Parroquia	parroquia-nxg5	\N	\N	\N	\N	\N	str
853	2024-05-18 15:31:45.054+00	2024-05-18 15:31:45.054+00	f	\N	\N	Zona	zona-r6xm	\N	\N	\N	\N	\N	str
854	2024-05-18 15:31:45.063+00	2024-05-18 15:31:45.063+00	f	\N	\N	Junta	junta-5x1f	\N	\N	\N	\N	\N	str
855	2024-05-18 15:31:45.073+00	2024-05-18 15:31:45.073+00	f	\N	\N	Dignidad	dignidad-wg2q	\N	\N	\N	\N	\N	str
856	2024-05-18 15:31:45.083+00	2024-05-18 15:31:45.083+00	f	\N	\N	Enlace al Acta	enlace-al-acta-t9ff	\N	\N	\N	\N	\N	str
857	2024-05-18 15:31:45.1+00	2024-05-18 15:31:45.1+00	f	\N	\N	Proceso Electoral	proceso-electoral-vt33	\N	\N	\N	\N	\N	str
858	2024-05-18 15:31:45.11+00	2024-05-18 15:31:45.11+00	f	\N	\N	Dignidad	dignidad-k6ex	\N	\N	\N	\N	\N	str
859	2024-05-18 15:31:45.118+00	2024-05-18 15:31:45.118+00	f	\N	\N	Candidato, Candidata o Partido	candidato-candidata-o-partido	\N	\N	\N	\N	\N	str
860	2024-05-18 15:31:45.128+00	2024-05-18 15:31:45.128+00	f	\N	\N	Organización Política o Alianza	organizacion-politica-o-alianza-3q1i	\N	\N	\N	\N	\N	str
861	2024-05-18 15:31:45.137+00	2024-05-18 15:31:45.137+00	f	\N	\N	Enlace a Plan de Trabajo	enlace-a-plan-de-trabajo	\N	\N	\N	\N	\N	str
862	2024-05-18 15:31:45.154+00	2024-05-18 15:31:45.154+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-b886	\N	\N	\N	\N	\N	str
863	2024-05-18 15:31:45.164+00	2024-05-18 15:31:45.164+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-ap3k	\N	\N	\N	\N	\N	str
864	2024-05-18 15:31:45.174+00	2024-05-18 15:31:45.174+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-1l9l	\N	\N	\N	\N	\N	str
865	2024-05-18 15:31:45.185+00	2024-05-18 15:31:45.185+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-bqkz	\N	\N	\N	\N	\N	str
1092	2024-05-18 15:31:47.736+00	2024-05-18 15:31:47.736+00	f	\N	\N	Cantón	canton-9bp6	\N	\N	\N	\N	\N	str
866	2024-05-18 15:31:45.195+00	2024-05-18 15:31:45.195+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-fpr3	\N	\N	\N	\N	\N	str
867	2024-05-18 15:31:45.205+00	2024-05-18 15:31:45.205+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-ur3k	\N	\N	\N	\N	\N	str
868	2024-05-18 15:31:45.215+00	2024-05-18 15:31:45.215+00	f	\N	\N	LICENCIA	licencia-9cdg	\N	\N	\N	\N	\N	str
869	2024-05-18 15:31:45.225+00	2024-05-18 15:31:45.225+00	f	\N	\N	Enlace para direccionar a los planes de trabajo de las candidatas y candidatos a las distintas elecciones	enlace-para-direccionar-a-los-planes-de-trabajo-de-las-candidatas-y-candidatos-a-las-distintas-elecciones-ysyu	\N	\N	\N	\N	\N	str
870	2024-05-18 15:31:45.237+00	2024-05-18 15:31:45.237+00	f	\N	\N	Enlace para direccionar a los resultados de los procesos electorales	enlace-para-direccionar-a-los-resultados-de-los-procesos-electorales-s7k1	\N	\N	\N	\N	\N	str
871	2024-05-18 15:31:45.246+00	2024-05-18 15:31:45.246+00	f	\N	\N	Enlace para direccionar a las actas de cada junta y recinto electoral 	enlace-para-direccionar-a-las-actas-de-cada-junta-y-recinto-electoral-6hm4	\N	\N	\N	\N	\N	str
872	2024-05-18 15:31:45.263+00	2024-05-18 15:31:45.263+00	f	\N	\N	Institución	institucion-gcij	\N	\N	\N	\N	\N	str
873	2024-05-18 15:31:45.273+00	2024-05-18 15:31:45.273+00	f	\N	\N	Descripción	descripcion-jdjc	\N	\N	\N	\N	\N	str
874	2024-05-18 15:31:45.284+00	2024-05-18 15:31:45.284+00	f	\N	\N	Nombre del campo	nombre-del-campo-ae5o	\N	\N	\N	\N	\N	str
875	2024-05-18 15:31:45.296+00	2024-05-18 15:31:45.296+00	f	\N	\N	Proceso Electoral	proceso-electoral-nx3i	\N	\N	\N	\N	\N	str
876	2024-05-18 15:31:45.308+00	2024-05-18 15:31:45.308+00	f	\N	\N	Dignidad	dignidad-t8fs	\N	\N	\N	\N	\N	str
877	2024-05-18 15:31:45.32+00	2024-05-18 15:31:45.32+00	f	\N	\N	Candidato, Candidata o Partido	candidato-candidata-o-partido-qlaw	\N	\N	\N	\N	\N	str
878	2024-05-18 15:31:45.331+00	2024-05-18 15:31:45.331+00	f	\N	\N	Organización Política o Alianza	organizacion-politica-o-alianza-6xmf	\N	\N	\N	\N	\N	str
879	2024-05-18 15:31:45.342+00	2024-05-18 15:31:45.342+00	f	\N	\N	Enlace a Plan de Trabajo	enlace-a-plan-de-trabajo-r52g	\N	\N	\N	\N	\N	str
880	2024-05-18 15:31:45.359+00	2024-05-18 15:31:45.359+00	f	\N	\N	Proceso Electoral	proceso-electoral-98xe	\N	\N	\N	\N	\N	str
881	2024-05-18 15:31:45.37+00	2024-05-18 15:31:45.37+00	f	\N	\N	Provincia	provincia-3fxk	\N	\N	\N	\N	\N	str
882	2024-05-18 15:31:45.379+00	2024-05-18 15:31:45.379+00	f	\N	\N	Cantón	canton-azfl	\N	\N	\N	\N	\N	str
883	2024-05-18 15:31:45.389+00	2024-05-18 15:31:45.389+00	f	\N	\N	Circunscripción	circunscripcion-k7jd	\N	\N	\N	\N	\N	str
884	2024-05-18 15:31:45.4+00	2024-05-18 15:31:45.4+00	f	\N	\N	Parroquia	parroquia-a28j	\N	\N	\N	\N	\N	str
885	2024-05-18 15:31:45.411+00	2024-05-18 15:31:45.411+00	f	\N	\N	Zona	zona-r6sw	\N	\N	\N	\N	\N	str
886	2024-05-18 15:31:45.421+00	2024-05-18 15:31:45.421+00	f	\N	\N	Junta	junta-d7na	\N	\N	\N	\N	\N	str
887	2024-05-18 15:31:45.431+00	2024-05-18 15:31:45.431+00	f	\N	\N	Dignidad	dignidad-k4rj	\N	\N	\N	\N	\N	str
888	2024-05-18 15:31:45.44+00	2024-05-18 15:31:45.44+00	f	\N	\N	Candidato, Candidata, Organización Política o Alianza, Votos Nulos o Blancos	candidato-candidata-organizacion-politica-o-alianza-votos-nulos-o-blancos	\N	\N	\N	\N	\N	str
889	2024-05-18 15:31:45.45+00	2024-05-18 15:31:45.45+00	f	\N	\N	Organización Política o Alianza, Votos Nulos o Blancos	organizacion-politica-o-alianza-votos-nulos-o-blancos	\N	\N	\N	\N	\N	str
890	2024-05-18 15:31:45.458+00	2024-05-18 15:31:45.458+00	f	\N	\N	Votos	votos	\N	\N	\N	\N	\N	str
891	2024-05-18 15:31:45.475+00	2024-05-18 15:31:45.475+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-r30c	\N	\N	\N	\N	\N	str
892	2024-05-18 15:31:45.486+00	2024-05-18 15:31:45.487+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-5leq	\N	\N	\N	\N	\N	str
893	2024-05-18 15:31:45.499+00	2024-05-18 15:31:45.499+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-eke7	\N	\N	\N	\N	\N	str
894	2024-05-18 15:31:45.512+00	2024-05-18 15:31:45.512+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-cs6r	\N	\N	\N	\N	\N	str
895	2024-05-18 15:31:45.524+00	2024-05-18 15:31:45.524+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-na26	\N	\N	\N	\N	\N	str
896	2024-05-18 15:31:45.535+00	2024-05-18 15:31:45.535+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-h809	\N	\N	\N	\N	\N	str
897	2024-05-18 15:31:45.545+00	2024-05-18 15:31:45.545+00	f	\N	\N	LICENCIA	licencia-0yba	\N	\N	\N	\N	\N	str
898	2024-05-18 15:31:45.555+00	2024-05-18 15:31:45.555+00	f	\N	\N	Enlace para direccionar a los planes de trabajo de las candidatas y candidatos a las distintas elecciones	enlace-para-direccionar-a-los-planes-de-trabajo-de-las-candidatas-y-candidatos-a-las-distintas-elecciones-0bgx	\N	\N	\N	\N	\N	str
899	2024-05-18 15:31:45.565+00	2024-05-18 15:31:45.565+00	f	\N	\N	Enlace para direccionar a los resultados de los procesos electorales	enlace-para-direccionar-a-los-resultados-de-los-procesos-electorales-41v3	\N	\N	\N	\N	\N	str
900	2024-05-18 15:31:45.576+00	2024-05-18 15:31:45.576+00	f	\N	\N	Enlace para direccionar a las actas de cada junta y recinto electoral 	enlace-para-direccionar-a-las-actas-de-cada-junta-y-recinto-electoral-wbb8	\N	\N	\N	\N	\N	str
901	2024-05-18 15:31:45.593+00	2024-05-18 15:31:45.593+00	f	\N	\N	Institución	institucion-wh5v	\N	\N	\N	\N	\N	str
902	2024-05-18 15:31:45.604+00	2024-05-18 15:31:45.604+00	f	\N	\N	Descripción	descripcion-ifr3	\N	\N	\N	\N	\N	str
903	2024-05-18 15:31:45.614+00	2024-05-18 15:31:45.614+00	f	\N	\N	Nombre del campo	nombre-del-campo-7uir	\N	\N	\N	\N	\N	str
904	2024-05-18 15:31:45.625+00	2024-05-18 15:31:45.625+00	f	\N	\N	Proceso Electoral	proceso-electoral-q8bh	\N	\N	\N	\N	\N	str
905	2024-05-18 15:31:45.637+00	2024-05-18 15:31:45.637+00	f	\N	\N	Provincia	provincia-2ug1	\N	\N	\N	\N	\N	str
906	2024-05-18 15:31:45.647+00	2024-05-18 15:31:45.647+00	f	\N	\N	Cantón	canton-mrwa	\N	\N	\N	\N	\N	str
907	2024-05-18 15:31:45.657+00	2024-05-18 15:31:45.657+00	f	\N	\N	Circunscripción	circunscripcion-24nd	\N	\N	\N	\N	\N	str
908	2024-05-18 15:31:45.667+00	2024-05-18 15:31:45.667+00	f	\N	\N	Parroquia	parroquia-0s13	\N	\N	\N	\N	\N	str
909	2024-05-18 15:31:45.677+00	2024-05-18 15:31:45.677+00	f	\N	\N	Zona	zona-x4fj	\N	\N	\N	\N	\N	str
910	2024-05-18 15:31:45.687+00	2024-05-18 15:31:45.687+00	f	\N	\N	Junta	junta-otaz	\N	\N	\N	\N	\N	str
911	2024-05-18 15:31:45.697+00	2024-05-18 15:31:45.697+00	f	\N	\N	Dignidad	dignidad-w9hw	\N	\N	\N	\N	\N	str
912	2024-05-18 15:31:45.708+00	2024-05-18 15:31:45.708+00	f	\N	\N	Candidato, Candidata, Organización Política o Alianza, Votos Nulos o Blancos	candidato-candidata-organizacion-politica-o-alianza-votos-nulos-o-blancos-c8kz	\N	\N	\N	\N	\N	str
913	2024-05-18 15:31:45.718+00	2024-05-18 15:31:45.718+00	f	\N	\N	Organización Política o Alianza, Votos Nulos o Blancos	organizacion-politica-o-alianza-votos-nulos-o-blancos-tqbq	\N	\N	\N	\N	\N	str
914	2024-05-18 15:31:45.727+00	2024-05-18 15:31:45.727+00	f	\N	\N	Votos	votos-vvfg	\N	\N	\N	\N	\N	str
915	2024-05-18 15:31:45.746+00	2024-05-18 15:31:45.746+00	f	\N	\N	Nombres y apellidos	nombres-y-apellidos	\N	\N	\N	\N	\N	str
916	2024-05-18 15:31:45.755+00	2024-05-18 15:31:45.755+00	f	\N	\N	Denominación del puesto	denominacion-del-puesto	\N	\N	\N	\N	\N	str
917	2024-05-18 15:31:45.764+00	2024-05-18 15:31:45.764+00	f	\N	\N	Responsabilidad LOTAIP	responsabilidad-lotaip	\N	\N	\N	\N	\N	str
918	2024-05-18 15:31:45.773+00	2024-05-18 15:31:45.773+00	f	\N	\N	Dirección de la oficina	direccion-de-la-oficina	\N	\N	\N	\N	\N	str
919	2024-05-18 15:31:45.782+00	2024-05-18 15:31:45.782+00	f	\N	\N	Número telefónico	numero-telefonico	\N	\N	\N	\N	\N	str
920	2024-05-18 15:31:45.793+00	2024-05-18 15:31:45.793+00	f	\N	\N	Extensión telefónica	extension-telefonica-n4je	\N	\N	\N	\N	\N	str
921	2024-05-18 15:31:45.803+00	2024-05-18 15:31:45.803+00	f	\N	\N	Correo electrónico	correo-electronico	\N	\N	\N	\N	\N	str
922	2024-05-18 15:31:45.821+00	2024-05-18 15:31:45.821+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-c5ez	\N	\N	\N	\N	\N	str
923	2024-05-18 15:31:45.831+00	2024-05-18 15:31:45.831+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-72do	\N	\N	\N	\N	\N	str
924	2024-05-18 15:31:45.842+00	2024-05-18 15:31:45.842+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-o757	\N	\N	\N	\N	\N	str
925	2024-05-18 15:31:45.853+00	2024-05-18 15:31:45.853+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-7aqx	\N	\N	\N	\N	\N	str
926	2024-05-18 15:31:45.864+00	2024-05-18 15:31:45.864+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-b85a	\N	\N	\N	\N	\N	str
927	2024-05-18 15:31:45.874+00	2024-05-18 15:31:45.874+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-47d2	\N	\N	\N	\N	\N	str
928	2024-05-18 15:31:45.883+00	2024-05-18 15:31:45.883+00	f	\N	\N	Enlace para descargar el acuerdo o resolución de creación del comité de transparencia        	enlace-para-descargar-el-acuerdo-o-resolucion-de-creacion-del-comite-de-transparencia	\N	\N	\N	\N	\N	str
929	2024-05-18 15:31:45.892+00	2024-05-18 15:31:45.892+00	f	\N	\N	Enlace para descargar el acuerdo o resolución para delegar el manejo de las solicitudes de acceso a la información pública en territorio        	enlace-para-descargar-el-acuerdo-o-resolucion-para-delegar-el-manejo-de-las-solicitudes-de-acceso-a-la-informacion-publica-en-territorio	\N	\N	\N	\N	\N	str
930	2024-05-18 15:31:45.9+00	2024-05-18 15:31:45.9+00	f	\N	\N	Enlace para la recepción de solicitudes de acceso a la información pública por vía electrónica        	enlace-para-la-recepcion-de-solicitudes-de-acceso-a-la-informacion-publica-por-via-electronica	\N	\N	\N	\N	\N	str
931	2024-05-18 15:31:45.908+00	2024-05-18 15:31:45.908+00	f	\N	\N	Enlace para descargar el listado de responsables de atender las solicitudes de acceso a la información en las delegaciones provinciales 	enlace-para-descargar-el-listado-de-responsables-de-atender-las-solicitudes-de-acceso-a-la-informacion-en-las-delegaciones-provinciales	\N	\N	\N	\N	\N	str
932	2024-05-18 15:31:45.918+00	2024-05-18 15:31:45.918+00	f	\N	\N	LICENCIA	licencia-yfvi	\N	\N	\N	\N	\N	str
933	2024-05-18 15:31:45.935+00	2024-05-18 15:31:45.935+00	f	\N	\N	Institución	institucion-afkz	\N	\N	\N	\N	\N	str
934	2024-05-18 15:31:45.946+00	2024-05-18 15:31:45.946+00	f	\N	\N	Descripción	descripcion-5wej	\N	\N	\N	\N	\N	str
935	2024-05-18 15:31:45.956+00	2024-05-18 15:31:45.956+00	f	\N	\N	Nombre del Campo	nombre-del-campo-sgm8	\N	\N	\N	\N	\N	str
936	2024-05-18 15:31:45.966+00	2024-05-18 15:31:45.966+00	f	\N	\N	Nombres y apellidos	nombres-y-apellidos-kbuu	\N	\N	\N	\N	\N	str
937	2024-05-18 15:31:45.975+00	2024-05-18 15:31:45.975+00	f	\N	\N	Denominación del puesto	denominacion-del-puesto-7ig5	\N	\N	\N	\N	\N	str
938	2024-05-18 15:31:45.985+00	2024-05-18 15:31:45.985+00	f	\N	\N	Responsabilidad LOTAIP	responsabilidad-lotaip-bdw2	\N	\N	\N	\N	\N	str
939	2024-05-18 15:31:45.995+00	2024-05-18 15:31:45.995+00	f	\N	\N	Dirección de la oficina	direccion-de-la-oficina-viee	\N	\N	\N	\N	\N	str
940	2024-05-18 15:31:46.005+00	2024-05-18 15:31:46.005+00	f	\N	\N	Número telefónico	numero-telefonico-tckb	\N	\N	\N	\N	\N	str
941	2024-05-18 15:31:46.015+00	2024-05-18 15:31:46.015+00	f	\N	\N	Extensión telefónica	extension-telefonica-5wos	\N	\N	\N	\N	\N	str
942	2024-05-18 15:31:46.025+00	2024-05-18 15:31:46.025+00	f	\N	\N	Correo electrónico	correo-electronico-q1r2	\N	\N	\N	\N	\N	str
943	2024-05-18 15:31:46.044+00	2024-05-18 15:31:46.044+00	f	\N	\N	TIPO	tipo-0bxq	\N	\N	\N	\N	\N	str
944	2024-05-18 15:31:46.052+00	2024-05-18 15:31:46.052+00	f	\N	\N	DESCRIPCIÓN DE REGULACIÓN	descripcion-de-regulacion	\N	\N	\N	\N	\N	str
945	2024-05-18 15:31:46.06+00	2024-05-18 15:31:46.061+00	f	\N	\N	ENLACE A REGULACIÓN	enlace-a-regulacion	\N	\N	\N	\N	\N	str
946	2024-05-18 15:31:46.08+00	2024-05-18 15:31:46.08+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-69tf	\N	\N	\N	\N	\N	str
947	2024-05-18 15:31:46.089+00	2024-05-18 15:31:46.089+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-d24h	\N	\N	\N	\N	\N	str
948	2024-05-18 15:31:46.1+00	2024-05-18 15:31:46.1+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-u962	\N	\N	\N	\N	\N	str
949	2024-05-18 15:31:46.112+00	2024-05-18 15:31:46.112+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-mwwi	\N	\N	\N	\N	\N	str
950	2024-05-18 15:31:46.124+00	2024-05-18 15:31:46.124+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-ybrk	\N	\N	\N	\N	\N	str
951	2024-05-18 15:31:46.137+00	2024-05-18 15:31:46.137+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-jz8x	\N	\N	\N	\N	\N	str
952	2024-05-18 15:31:46.15+00	2024-05-18 15:31:46.15+00	f	\N	\N	LICENCIA	licencia-6a53	\N	\N	\N	\N	\N	str
953	2024-05-18 15:31:46.171+00	2024-05-18 15:31:46.171+00	f	\N	\N	Institución	institucion-hzwf	\N	\N	\N	\N	\N	str
954	2024-05-18 15:31:46.182+00	2024-05-18 15:31:46.182+00	f	\N	\N	Descripción	descripcion-dhhk	\N	\N	\N	\N	\N	str
955	2024-05-18 15:31:46.194+00	2024-05-18 15:31:46.194+00	f	\N	\N	Nombre del campo	nombre-del-campo-pkcq	\N	\N	\N	\N	\N	str
956	2024-05-18 15:31:46.206+00	2024-05-18 15:31:46.206+00	f	\N	\N	Tipo	tipo-8wer	\N	\N	\N	\N	\N	str
957	2024-05-18 15:31:46.217+00	2024-05-18 15:31:46.217+00	f	\N	\N	Descripción de Regulación	descripcion-de-regulacion-yhpw	\N	\N	\N	\N	\N	str
958	2024-05-18 15:31:46.231+00	2024-05-18 15:31:46.231+00	f	\N	\N	Enlace a Regulación	enlace-a-regulacion-az0l	\N	\N	\N	\N	\N	str
959	2024-05-18 15:31:46.256+00	2024-05-18 15:31:46.256+00	f	\N	\N	TIPO	tipo-0zcm	\N	\N	\N	\N	\N	str
960	2024-05-18 15:31:46.268+00	2024-05-18 15:31:46.268+00	f	\N	\N	DESCRIPCIÓN DE REGULACIÓN	descripcion-de-regulacion-35q5	\N	\N	\N	\N	\N	str
961	2024-05-18 15:31:46.281+00	2024-05-18 15:31:46.281+00	f	\N	\N	ENLACE A REGULACIÓN	enlace-a-regulacion-lyuj	\N	\N	\N	\N	\N	str
962	2024-05-18 15:31:46.301+00	2024-05-18 15:31:46.301+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-ry5l	\N	\N	\N	\N	\N	str
963	2024-05-18 15:31:46.313+00	2024-05-18 15:31:46.313+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-yt9u	\N	\N	\N	\N	\N	str
964	2024-05-18 15:31:46.325+00	2024-05-18 15:31:46.325+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-o794	\N	\N	\N	\N	\N	str
965	2024-05-18 15:31:46.337+00	2024-05-18 15:31:46.338+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-y4ol	\N	\N	\N	\N	\N	str
966	2024-05-18 15:31:46.347+00	2024-05-18 15:31:46.347+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-e22w	\N	\N	\N	\N	\N	str
967	2024-05-18 15:31:46.357+00	2024-05-18 15:31:46.357+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-yh1e	\N	\N	\N	\N	\N	str
968	2024-05-18 15:31:46.368+00	2024-05-18 15:31:46.368+00	f	\N	\N	LICENCIA	licencia-bdxd	\N	\N	\N	\N	\N	str
969	2024-05-18 15:31:46.387+00	2024-05-18 15:31:46.387+00	f	\N	\N	Institución	institucion-zowd	\N	\N	\N	\N	\N	str
970	2024-05-18 15:31:46.397+00	2024-05-18 15:31:46.397+00	f	\N	\N	Descripción	descripcion-kk4u	\N	\N	\N	\N	\N	str
971	2024-05-18 15:31:46.408+00	2024-05-18 15:31:46.408+00	f	\N	\N	Nombre del campo	nombre-del-campo-nhn7	\N	\N	\N	\N	\N	str
972	2024-05-18 15:31:46.418+00	2024-05-18 15:31:46.418+00	f	\N	\N	Tipo	tipo-pq9z	\N	\N	\N	\N	\N	str
973	2024-05-18 15:31:46.428+00	2024-05-18 15:31:46.428+00	f	\N	\N	Descripción de Regulación	descripcion-de-regulacion-hgq8	\N	\N	\N	\N	\N	str
974	2024-05-18 15:31:46.438+00	2024-05-18 15:31:46.438+00	f	\N	\N	Enlace a Regulación	enlace-a-regulacion-9iu4	\N	\N	\N	\N	\N	str
975	2024-05-18 15:31:46.455+00	2024-05-18 15:31:46.455+00	f	\N	\N	Nombre del Plan o Programa	nombre-del-plan-o-programa	\N	\N	\N	\N	\N	str
976	2024-05-18 15:31:46.465+00	2024-05-18 15:31:46.465+00	f	\N	\N	Período	periodo-syr6	\N	\N	\N	\N	\N	str
977	2024-05-18 15:31:46.474+00	2024-05-18 15:31:46.474+00	f	\N	\N	Monto	monto	\N	\N	\N	\N	\N	str
978	2024-05-18 15:31:46.482+00	2024-05-18 15:31:46.482+00	f	\N	\N	Enlace al Plan o Programa	enlace-al-plan-o-programa	\N	\N	\N	\N	\N	str
980	2024-05-18 15:31:46.507+00	2024-05-18 15:31:46.507+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN	fecha-actualizacion-de-la-informacion-t72v	\N	\N	\N	\N	\N	str
981	2024-05-18 15:31:46.516+00	2024-05-18 15:31:46.516+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN	periodicidad-de-actualizacion-de-la-informacion-s6gz	\N	\N	\N	\N	\N	str
982	2024-05-18 15:31:46.527+00	2024-05-18 15:31:46.527+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN	unidad-poseedora-de-la-informacion-f6x9	\N	\N	\N	\N	\N	str
983	2024-05-18 15:31:46.537+00	2024-05-18 15:31:46.537+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	persona-responsable-de-la-unidad-poseedora-de-la-informacion-2ait	\N	\N	\N	\N	\N	str
984	2024-05-18 15:31:46.545+00	2024-05-18 15:31:46.545+00	f	\N	\N	CORREO ELECTRÓNICO DEL O LA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	correo-electronico-del-o-la-responsable-de-la-unidad-poseedora-de-la-informacion	\N	\N	\N	\N	\N	str
985	2024-05-18 15:31:46.555+00	2024-05-18 15:31:46.555+00	f	\N	\N	NÚMERO TELEFÓNICO DEL O LA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	numero-telefonico-del-o-la-responsable-de-la-unidad-poseedora-de-la-informacion-w4zy	\N	\N	\N	\N	\N	str
986	2024-05-18 15:31:46.564+00	2024-05-18 15:31:46.564+00	f	\N	\N	LICENCIA	licencia-ln5q	\N	\N	\N	\N	\N	str
987	2024-05-18 15:31:46.581+00	2024-05-18 15:31:46.581+00	f	\N	\N	Institución	institucion-sbv5	\N	\N	\N	\N	\N	str
988	2024-05-18 15:31:46.593+00	2024-05-18 15:31:46.593+00	f	\N	\N	Descripción	descripcion-ms8k	\N	\N	\N	\N	\N	str
989	2024-05-18 15:31:46.604+00	2024-05-18 15:31:46.604+00	f	\N	\N	Nombre del campo	nombre-del-campo-44y9	\N	\N	\N	\N	\N	str
990	2024-05-18 15:31:46.614+00	2024-05-18 15:31:46.614+00	f	\N	\N	Nombre del Plan o Programa	nombre-del-plan-o-programa-fr55	\N	\N	\N	\N	\N	str
991	2024-05-18 15:31:46.624+00	2024-05-18 15:31:46.624+00	f	\N	\N	Período	periodo-qbd4	\N	\N	\N	\N	\N	str
992	2024-05-18 15:31:46.634+00	2024-05-18 15:31:46.634+00	f	\N	\N	Monto	monto-97f4	\N	\N	\N	\N	\N	str
993	2024-05-18 15:31:46.643+00	2024-05-18 15:31:46.643+00	f	\N	\N	Enlace al Plan o Programa	enlace-al-plan-o-programa-piz8	\N	\N	\N	\N	\N	str
994	2024-05-18 15:31:46.653+00	2024-05-18 15:31:46.653+00	f	\N	\N	Enlace al estado 	enlace-al-estado-nnx4	\N	\N	\N	\N	\N	str
995	2024-05-18 15:31:46.671+00	2024-05-18 15:31:46.671+00	f	\N	\N	Número de Sentencia o Dictamen	numero-de-sentencia-o-dictamen	\N	\N	\N	\N	\N	str
996	2024-05-18 15:31:46.681+00	2024-05-18 15:31:46.681+00	f	\N	\N	Fecha	fecha-11z1	\N	\N	\N	\N	\N	str
997	2024-05-18 15:31:46.69+00	2024-05-18 15:31:46.69+00	f	\N	\N	Tipo de Acción	tipo-de-accion-vmb0	\N	\N	\N	\N	\N	str
998	2024-05-18 15:31:46.7+00	2024-05-18 15:31:46.7+00	f	\N	\N	Materia	materia-0euy	\N	\N	\N	\N	\N	str
999	2024-05-18 15:31:46.709+00	2024-05-18 15:31:46.709+00	f	\N	\N	Decisión resumen	decision-resumen	\N	\N	\N	\N	\N	str
1000	2024-05-18 15:31:46.717+00	2024-05-18 15:31:46.717+00	f	\N	\N	Enlace al Texto Íntegro de la Sentencia	enlace-al-texto-integro-de-la-sentencia	\N	\N	\N	\N	\N	str
1001	2024-05-18 15:31:46.733+00	2024-05-18 15:31:46.733+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-unke	\N	\N	\N	\N	\N	str
1002	2024-05-18 15:31:46.743+00	2024-05-18 15:31:46.743+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-tse4	\N	\N	\N	\N	\N	str
1003	2024-05-18 15:31:46.753+00	2024-05-18 15:31:46.753+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-a9r1	\N	\N	\N	\N	\N	str
1004	2024-05-18 15:31:46.762+00	2024-05-18 15:31:46.762+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-vjjf	\N	\N	\N	\N	\N	str
1005	2024-05-18 15:31:46.772+00	2024-05-18 15:31:46.772+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-glhg	\N	\N	\N	\N	\N	str
1006	2024-05-18 15:31:46.781+00	2024-05-18 15:31:46.781+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-07yb	\N	\N	\N	\N	\N	str
1007	2024-05-18 15:31:46.791+00	2024-05-18 15:31:46.791+00	f	\N	\N	LICENCIA	licencia-py18	\N	\N	\N	\N	\N	str
1008	2024-05-18 15:31:46.799+00	2024-05-18 15:31:46.799+00	f	\N	\N	ENLACE QUE DIRECCIONA AL SISTEMA DE GESTIÓN DE ACCIONES CONSTITUCIONALES 	enlace-que-direcciona-al-sistema-de-gestion-de-acciones-constitucionales	\N	\N	\N	\N	\N	str
1009	2024-05-18 15:31:46.815+00	2024-05-18 15:31:46.815+00	f	\N	\N	Institución	institucion-blg3	\N	\N	\N	\N	\N	str
1010	2024-05-18 15:31:46.825+00	2024-05-18 15:31:46.825+00	f	\N	\N	Descripción	descripcion-zzdq	\N	\N	\N	\N	\N	str
1011	2024-05-18 15:31:46.835+00	2024-05-18 15:31:46.835+00	f	\N	\N	Nombre del campo	nombre-del-campo-cbtb	\N	\N	\N	\N	\N	str
1012	2024-05-18 15:31:46.845+00	2024-05-18 15:31:46.845+00	f	\N	\N	Número de Sentencia o Dictamen	numero-de-sentencia-o-dictamen-4pjv	\N	\N	\N	\N	\N	str
1013	2024-05-18 15:31:46.856+00	2024-05-18 15:31:46.856+00	f	\N	\N	Fecha	fecha-tzgv	\N	\N	\N	\N	\N	str
1014	2024-05-18 15:31:46.865+00	2024-05-18 15:31:46.865+00	f	\N	\N	Tipo de Acción	tipo-de-accion-eabt	\N	\N	\N	\N	\N	str
1015	2024-05-18 15:31:46.875+00	2024-05-18 15:31:46.875+00	f	\N	\N	Materia	materia-tsp4	\N	\N	\N	\N	\N	str
1016	2024-05-18 15:31:46.887+00	2024-05-18 15:31:46.887+00	f	\N	\N	Decisión resumen	decision-resumen-rujw	\N	\N	\N	\N	\N	str
1017	2024-05-18 15:31:46.899+00	2024-05-18 15:31:46.899+00	f	\N	\N	Enlace al Texto Íntegro de la Sentencia	enlace-al-texto-integro-de-la-sentencia-c564	\N	\N	\N	\N	\N	str
1018	2024-05-18 15:31:46.92+00	2024-05-18 15:31:46.92+00	f	\N	\N	Denominación de la organización sindical	denominacion-de-la-organizacion-sindical	\N	\N	\N	\N	\N	str
1019	2024-05-18 15:31:46.93+00	2024-05-18 15:31:46.93+00	f	\N	\N	Fecha de suscripción del contrato 	fecha-de-suscripcion-del-contrato	\N	\N	\N	\N	\N	str
1020	2024-05-18 15:31:46.94+00	2024-05-18 15:31:46.94+00	f	\N	\N	Enlace para descargar el contrato colectivo original	enlace-para-descargar-el-contrato-colectivo-original	\N	\N	\N	\N	\N	str
1021	2024-05-18 15:31:46.95+00	2024-05-18 15:31:46.95+00	f	\N	\N	Fecha de la última reforma o revisión 	fecha-de-la-ultima-reforma-o-revision	\N	\N	\N	\N	\N	str
1022	2024-05-18 15:31:46.96+00	2024-05-18 15:31:46.96+00	f	\N	\N	Enlace para descargar todas las reformas completas del contrato colectivo 	enlace-para-descargar-todas-las-reformas-completas-del-contrato-colectivo	\N	\N	\N	\N	\N	str
1023	2024-05-18 15:31:46.979+00	2024-05-18 15:31:46.98+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-tls5	\N	\N	\N	\N	\N	str
1024	2024-05-18 15:31:46.992+00	2024-05-18 15:31:46.992+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-hzn3	\N	\N	\N	\N	\N	str
1025	2024-05-18 15:31:47.004+00	2024-05-18 15:31:47.004+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-jzpp	\N	\N	\N	\N	\N	str
1026	2024-05-18 15:31:47.015+00	2024-05-18 15:31:47.015+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-a442	\N	\N	\N	\N	\N	str
1027	2024-05-18 15:31:47.027+00	2024-05-18 15:31:47.027+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-wlsj	\N	\N	\N	\N	\N	str
1028	2024-05-18 15:31:47.037+00	2024-05-18 15:31:47.037+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-zyvx	\N	\N	\N	\N	\N	str
1029	2024-05-18 15:31:47.047+00	2024-05-18 15:31:47.047+00	f	\N	\N	LICENCIA	licencia-9x9n	\N	\N	\N	\N	\N	str
1030	2024-05-18 15:31:47.065+00	2024-05-18 15:31:47.065+00	f	\N	\N	Institución	institucion-csvx	\N	\N	\N	\N	\N	str
1031	2024-05-18 15:31:47.076+00	2024-05-18 15:31:47.076+00	f	\N	\N	Descripción	descripcion-w7gf	\N	\N	\N	\N	\N	str
1032	2024-05-18 15:31:47.087+00	2024-05-18 15:31:47.088+00	f	\N	\N	Nombre del campo	nombre-del-campo-nn1y	\N	\N	\N	\N	\N	str
1033	2024-05-18 15:31:47.099+00	2024-05-18 15:31:47.099+00	f	\N	\N	Denominación de la organización sindical	denominacion-de-la-organizacion-sindical-o64n	\N	\N	\N	\N	\N	str
1034	2024-05-18 15:31:47.11+00	2024-05-18 15:31:47.11+00	f	\N	\N	Fecha de suscripción del contrato	fecha-de-suscripcion-del-contrato-29o4	\N	\N	\N	\N	\N	str
1035	2024-05-18 15:31:47.123+00	2024-05-18 15:31:47.123+00	f	\N	\N	Enlace para descargar el contrato colectivo original	enlace-para-descargar-el-contrato-colectivo-original-7kix	\N	\N	\N	\N	\N	str
1036	2024-05-18 15:31:47.135+00	2024-05-18 15:31:47.135+00	f	\N	\N	Fecha de la última reforma o revisión 	fecha-de-la-ultima-reforma-o-revision-bpm4	\N	\N	\N	\N	\N	str
1037	2024-05-18 15:31:47.146+00	2024-05-18 15:31:47.146+00	f	\N	\N	Enlace para descargar todas las reformas completas del contrato colectivo 	enlace-para-descargar-todas-las-reformas-completas-del-contrato-colectivo-dct8	\N	\N	\N	\N	\N	str
1038	2024-05-18 15:31:47.17+00	2024-05-18 15:31:47.17+00	f	\N	\N	Tema	tema-jhra	\N	\N	\N	\N	\N	str
1039	2024-05-18 15:31:47.18+00	2024-05-18 15:31:47.181+00	f	\N	\N	Número de Resolución	numero-de-resolucion	\N	\N	\N	\N	\N	str
1040	2024-05-18 15:31:47.19+00	2024-05-18 15:31:47.19+00	f	\N	\N	Fecha de la clasificación de la información reservada	fecha-de-la-clasificacion-de-la-informacion-reservada	\N	\N	\N	\N	\N	str
1041	2024-05-18 15:31:47.201+00	2024-05-18 15:31:47.201+00	f	\N	\N	Período de vigencia de la clasificación de la reserva	periodo-de-vigencia-de-la-clasificacion-de-la-reserva	\N	\N	\N	\N	\N	str
1042	2024-05-18 15:31:47.21+00	2024-05-18 15:31:47.21+00	f	\N	\N	Enlace para descargar la resolución de clasificación de información reservada	enlace-para-descargar-la-resolucion-de-clasificacion-de-informacion-reservada	\N	\N	\N	\N	\N	str
1043	2024-05-18 15:31:47.228+00	2024-05-18 15:31:47.228+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN	fecha-actualizacion-de-la-informacion-zhny	\N	\N	\N	\N	\N	str
1044	2024-05-18 15:31:47.239+00	2024-05-18 15:31:47.239+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN	periodicidad-de-actualizacion-de-la-informacion-m4g2	\N	\N	\N	\N	\N	str
1045	2024-05-18 15:31:47.249+00	2024-05-18 15:31:47.249+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN	unidad-poseedora-de-la-informacion-avmx	\N	\N	\N	\N	\N	str
1046	2024-05-18 15:31:47.259+00	2024-05-18 15:31:47.259+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	persona-responsable-de-la-unidad-poseedora-de-la-informacion-d1hm	\N	\N	\N	\N	\N	str
1047	2024-05-18 15:31:47.269+00	2024-05-18 15:31:47.269+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-8bip	\N	\N	\N	\N	\N	str
1048	2024-05-18 15:31:47.278+00	2024-05-18 15:31:47.278+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-sn0u	\N	\N	\N	\N	\N	str
1049	2024-05-18 15:31:47.288+00	2024-05-18 15:31:47.288+00	f	\N	\N	LICENCIA	licencia-y2v8	\N	\N	\N	\N	\N	str
1050	2024-05-18 15:31:47.296+00	2024-05-18 15:31:47.296+00	f	\N	\N	ENLACE PARA DESCARGAR EL LISTADO ÍNDICE DE INFORMACIÓN RESERVADA - CERTIFICADO DE CUMPLIMIENTO 	enlace-para-descargar-el-listado-indice-de-informacion-reservada-certificado-de-cumplimiento	\N	\N	\N	\N	\N	str
1051	2024-05-18 15:31:47.304+00	2024-05-18 15:31:47.304+00	f	\N	\N	ENLACE PARA DESCARGAR EL LISTADO ÍNDICE DE INFORMACIÓN RESERVADA - REPORTE DEL LITERAL C) (SISTEMA DE LA DEFENSORÍA DEL PUEBLO DE ECUADOR)	enlace-para-descargar-el-listado-indice-de-informacion-reservada-reporte-del-literal-c-sistema-de-la-defensoria-del-pueblo-de-ecuador	\N	\N	\N	\N	\N	str
1052	2024-05-18 15:31:47.321+00	2024-05-18 15:31:47.321+00	f	\N	\N	Institución	institucion-8xex	\N	\N	\N	\N	\N	str
1053	2024-05-18 15:31:47.331+00	2024-05-18 15:31:47.331+00	f	\N	\N	Descripción	descripcion-scra	\N	\N	\N	\N	\N	str
1054	2024-05-18 15:31:47.34+00	2024-05-18 15:31:47.34+00	f	\N	\N	Nombre del campo	nombre-del-campo-qmtx	\N	\N	\N	\N	\N	str
1055	2024-05-18 15:31:47.351+00	2024-05-18 15:31:47.351+00	f	\N	\N	Tema	tema-4t3c	\N	\N	\N	\N	\N	str
1056	2024-05-18 15:31:47.361+00	2024-05-18 15:31:47.361+00	f	\N	\N	Número de resolución	numero-de-resolucion-n20a	\N	\N	\N	\N	\N	str
1057	2024-05-18 15:31:47.371+00	2024-05-18 15:31:47.371+00	f	\N	\N	Fecha de la clasificación de la información reservada	fecha-de-la-clasificacion-de-la-informacion-reservada-byhg	\N	\N	\N	\N	\N	str
1058	2024-05-18 15:31:47.382+00	2024-05-18 15:31:47.382+00	f	\N	\N	Período de vigencia de la clasificación de la reserva	periodo-de-vigencia-de-la-clasificacion-de-la-reserva-ttce	\N	\N	\N	\N	\N	str
1059	2024-05-18 15:31:47.392+00	2024-05-18 15:31:47.392+00	f	\N	\N	Enlace para descargar la resolución de clasificación de información reservada	enlace-para-descargar-la-resolucion-de-clasificacion-de-informacion-reservada-hh5c	\N	\N	\N	\N	\N	str
1060	2024-05-18 15:31:47.409+00	2024-05-18 15:31:47.409+00	f	\N	\N	Código	codigo	\N	\N	\N	\N	\N	str
1061	2024-05-18 15:31:47.418+00	2024-05-18 15:31:47.418+00	f	\N	\N	Fecha de Presentación	fecha-de-presentacion	\N	\N	\N	\N	\N	str
1062	2024-05-18 15:31:47.428+00	2024-05-18 15:31:47.428+00	f	\N	\N	Tipo 	tipo-gio5	\N	\N	\N	\N	\N	str
1063	2024-05-18 15:31:47.436+00	2024-05-18 15:31:47.436+00	f	\N	\N	Proyecto, enmienda o reforma constitucional	proyecto-enmienda-o-reforma-constitucional	\N	\N	\N	\N	\N	str
1064	2024-05-18 15:31:47.445+00	2024-05-18 15:31:47.445+00	f	\N	\N	Proponente(s)	proponentes	\N	\N	\N	\N	\N	str
1065	2024-05-18 15:31:47.453+00	2024-05-18 15:31:47.453+00	f	\N	\N	Comisión	comision	\N	\N	\N	\N	\N	str
1066	2024-05-18 15:31:47.463+00	2024-05-18 15:31:47.463+00	f	\N	\N	Estado	estado-9qjn	\N	\N	\N	\N	\N	str
1067	2024-05-18 15:31:47.471+00	2024-05-18 15:31:47.471+00	f	\N	\N	Enlace a proyecto de ley documentos e informes	enlace-a-proyecto-de-ley-documentos-e-informes	\N	\N	\N	\N	\N	str
1068	2024-05-18 15:31:47.488+00	2024-05-18 15:31:47.488+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-7mvv	\N	\N	\N	\N	\N	str
1069	2024-05-18 15:31:47.498+00	2024-05-18 15:31:47.498+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-d9ha	\N	\N	\N	\N	\N	str
1070	2024-05-18 15:31:47.508+00	2024-05-18 15:31:47.508+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-zebx	\N	\N	\N	\N	\N	str
1071	2024-05-18 15:31:47.518+00	2024-05-18 15:31:47.518+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-kjvn	\N	\N	\N	\N	\N	str
1072	2024-05-18 15:31:47.528+00	2024-05-18 15:31:47.528+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-we2e	\N	\N	\N	\N	\N	str
1073	2024-05-18 15:31:47.538+00	2024-05-18 15:31:47.538+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-ewbt	\N	\N	\N	\N	\N	str
1074	2024-05-18 15:31:47.548+00	2024-05-18 15:31:47.548+00	f	\N	\N	LICENCIA	licencia-xmgv	\N	\N	\N	\N	\N	str
1075	2024-05-18 15:31:47.564+00	2024-05-18 15:31:47.564+00	f	\N	\N	Institución	institucion-zlc1	\N	\N	\N	\N	\N	str
1076	2024-05-18 15:31:47.575+00	2024-05-18 15:31:47.575+00	f	\N	\N	Descripción	descripcion-cbe2	\N	\N	\N	\N	\N	str
1077	2024-05-18 15:31:47.586+00	2024-05-18 15:31:47.586+00	f	\N	\N	Nombre del campo	nombre-del-campo-12a9	\N	\N	\N	\N	\N	str
1078	2024-05-18 15:31:47.596+00	2024-05-18 15:31:47.596+00	f	\N	\N	Código	codigo-6epr	\N	\N	\N	\N	\N	str
1079	2024-05-18 15:31:47.606+00	2024-05-18 15:31:47.606+00	f	\N	\N	Fecha de Presentación	fecha-de-presentacion-b7ng	\N	\N	\N	\N	\N	str
1080	2024-05-18 15:31:47.615+00	2024-05-18 15:31:47.615+00	f	\N	\N	Tipo	tipo-0z15	\N	\N	\N	\N	\N	str
1081	2024-05-18 15:31:47.626+00	2024-05-18 15:31:47.626+00	f	\N	\N	Proyecto, enmienda o reforma constitucional	proyecto-enmienda-o-reforma-constitucional-9m9x	\N	\N	\N	\N	\N	str
1082	2024-05-18 15:31:47.636+00	2024-05-18 15:31:47.636+00	f	\N	\N	Proponente(s)	proponentes-4jrd	\N	\N	\N	\N	\N	str
1083	2024-05-18 15:31:47.646+00	2024-05-18 15:31:47.646+00	f	\N	\N	Comisión	comision-da49	\N	\N	\N	\N	\N	str
1084	2024-05-18 15:31:47.656+00	2024-05-18 15:31:47.656+00	f	\N	\N	Estado	estado-seed	\N	\N	\N	\N	\N	str
1085	2024-05-18 15:31:47.665+00	2024-05-18 15:31:47.665+00	f	\N	\N	Enlace a proyecto de ley, documentos e informes	enlace-a-proyecto-de-ley-documentos-e-informes-a11q	\N	\N	\N	\N	\N	str
1086	2024-05-18 15:31:47.681+00	2024-05-18 15:31:47.682+00	f	\N	\N	Código	codigo-1c1l	\N	\N	\N	\N	\N	str
1087	2024-05-18 15:31:47.692+00	2024-05-18 15:31:47.692+00	f	\N	\N	Fecha de Presentación	fecha-de-presentacion-pxz2	\N	\N	\N	\N	\N	str
1088	2024-05-18 15:31:47.7+00	2024-05-18 15:31:47.7+00	f	\N	\N	Proyecto	proyecto	\N	\N	\N	\N	\N	str
1089	2024-05-18 15:31:47.708+00	2024-05-18 15:31:47.708+00	f	\N	\N	Comisión Especializada Permanente u Ocasional	comision-especializada-permanente-u-ocasional	\N	\N	\N	\N	\N	str
1090	2024-05-18 15:31:47.716+00	2024-05-18 15:31:47.716+00	f	\N	\N	Fecha de socialización	fecha-de-socializacion	\N	\N	\N	\N	\N	str
1091	2024-05-18 15:31:47.726+00	2024-05-18 15:31:47.726+00	f	\N	\N	Provincia	provincia-qhl0	\N	\N	\N	\N	\N	str
1093	2024-05-18 15:31:47.744+00	2024-05-18 15:31:47.744+00	f	\N	\N	Temática abordada	tematica-abordada	\N	\N	\N	\N	\N	str
1094	2024-05-18 15:31:47.753+00	2024-05-18 15:31:47.753+00	f	\N	\N	Público objetivo	publico-objetivo	\N	\N	\N	\N	\N	str
1095	2024-05-18 15:31:47.761+00	2024-05-18 15:31:47.761+00	f	\N	\N	Enlace a documentos de socialización	enlace-a-documentos-de-socializacion	\N	\N	\N	\N	\N	str
1096	2024-05-18 15:31:47.778+00	2024-05-18 15:31:47.778+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-te94	\N	\N	\N	\N	\N	str
1097	2024-05-18 15:31:47.788+00	2024-05-18 15:31:47.788+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-jdk8	\N	\N	\N	\N	\N	str
1098	2024-05-18 15:31:47.798+00	2024-05-18 15:31:47.798+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-r714	\N	\N	\N	\N	\N	str
1099	2024-05-18 15:31:47.808+00	2024-05-18 15:31:47.808+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-dn7l	\N	\N	\N	\N	\N	str
1100	2024-05-18 15:31:47.818+00	2024-05-18 15:31:47.818+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-53vj	\N	\N	\N	\N	\N	str
1101	2024-05-18 15:31:47.828+00	2024-05-18 15:31:47.828+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-5mo1	\N	\N	\N	\N	\N	str
1102	2024-05-18 15:31:47.838+00	2024-05-18 15:31:47.838+00	f	\N	\N	LICENCIA	licencia-28gp	\N	\N	\N	\N	\N	str
1103	2024-05-18 15:31:47.854+00	2024-05-18 15:31:47.854+00	f	\N	\N	Institución	institucion-n1aw	\N	\N	\N	\N	\N	str
1104	2024-05-18 15:31:47.864+00	2024-05-18 15:31:47.864+00	f	\N	\N	Descripción	descripcion-tz8i	\N	\N	\N	\N	\N	str
1105	2024-05-18 15:31:47.874+00	2024-05-18 15:31:47.874+00	f	\N	\N	Nombre del campo	nombre-del-campo-4hls	\N	\N	\N	\N	\N	str
1106	2024-05-18 15:31:47.884+00	2024-05-18 15:31:47.884+00	f	\N	\N	Código	codigo-9ord	\N	\N	\N	\N	\N	str
1107	2024-05-18 15:31:47.894+00	2024-05-18 15:31:47.894+00	f	\N	\N	Fecha de Presentación	fecha-de-presentacion-wmvv	\N	\N	\N	\N	\N	str
1108	2024-05-18 15:31:47.904+00	2024-05-18 15:31:47.904+00	f	\N	\N	Proyecto	proyecto-pza0	\N	\N	\N	\N	\N	str
1109	2024-05-18 15:31:47.914+00	2024-05-18 15:31:47.914+00	f	\N	\N	Comisión	comision-2t1j	\N	\N	\N	\N	\N	str
1110	2024-05-18 15:31:47.924+00	2024-05-18 15:31:47.924+00	f	\N	\N	Fecha de socialización	fecha-de-socializacion-9432	\N	\N	\N	\N	\N	str
1111	2024-05-18 15:31:47.933+00	2024-05-18 15:31:47.933+00	f	\N	\N	Provincia	provincia-ipc9	\N	\N	\N	\N	\N	str
1112	2024-05-18 15:31:47.944+00	2024-05-18 15:31:47.944+00	f	\N	\N	Cantón	canton-fd9m	\N	\N	\N	\N	\N	str
1113	2024-05-18 15:31:47.955+00	2024-05-18 15:31:47.955+00	f	\N	\N	Temática abordada	tematica-abordada-az0y	\N	\N	\N	\N	\N	str
1114	2024-05-18 15:31:47.966+00	2024-05-18 15:31:47.966+00	f	\N	\N	Público objetivo	publico-objetivo-cgnu	\N	\N	\N	\N	\N	str
1115	2024-05-18 15:31:47.977+00	2024-05-18 15:31:47.977+00	f	\N	\N	Enlace a documentos de socialización	enlace-a-documentos-de-socializacion-407d	\N	\N	\N	\N	\N	str
1116	2024-05-18 15:31:47.995+00	2024-05-18 15:31:47.995+00	f	\N	\N	No. Sesión	no-sesion	\N	\N	\N	\N	\N	str
1117	2024-05-18 15:31:48.007+00	2024-05-18 15:31:48.007+00	f	\N	\N	Tipo	tipo-cnrc	\N	\N	\N	\N	\N	str
1118	2024-05-18 15:31:48.017+00	2024-05-18 15:31:48.017+00	f	\N	\N	Pleno o nombre de la comisión	pleno-o-nombre-de-la-comision	\N	\N	\N	\N	\N	str
1119	2024-05-18 15:31:48.029+00	2024-05-18 15:31:48.029+00	f	\N	\N	Fecha	fecha-pfra	\N	\N	\N	\N	\N	str
1120	2024-05-18 15:31:48.04+00	2024-05-18 15:31:48.04+00	f	\N	\N	Hora	hora	\N	\N	\N	\N	\N	str
1121	2024-05-18 15:31:48.049+00	2024-05-18 15:31:48.049+00	f	\N	\N	Asambleísta	asambleista	\N	\N	\N	\N	\N	str
1122	2024-05-18 15:31:48.058+00	2024-05-18 15:31:48.058+00	f	\N	\N	Asistencia	asistencia	\N	\N	\N	\N	\N	str
1123	2024-05-18 15:31:48.07+00	2024-05-18 15:31:48.07+00	f	\N	\N	Enlace Acta	enlace-acta-81ne	\N	\N	\N	\N	\N	str
1124	2024-05-18 15:31:48.088+00	2024-05-18 15:31:48.088+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-86u4	\N	\N	\N	\N	\N	str
1125	2024-05-18 15:31:48.099+00	2024-05-18 15:31:48.099+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-1rnl	\N	\N	\N	\N	\N	str
1126	2024-05-18 15:31:48.11+00	2024-05-18 15:31:48.11+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-odwk	\N	\N	\N	\N	\N	str
1127	2024-05-18 15:31:48.121+00	2024-05-18 15:31:48.122+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-wr2u	\N	\N	\N	\N	\N	str
1128	2024-05-18 15:31:48.134+00	2024-05-18 15:31:48.134+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-cptb	\N	\N	\N	\N	\N	str
1129	2024-05-18 15:31:48.146+00	2024-05-18 15:31:48.146+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-2xej	\N	\N	\N	\N	\N	str
1130	2024-05-18 15:31:48.158+00	2024-05-18 15:31:48.158+00	f	\N	\N	LICENCIA	licencia-cl7o	\N	\N	\N	\N	\N	str
1131	2024-05-18 15:31:48.176+00	2024-05-18 15:31:48.176+00	f	\N	\N	Institución	institucion-0wq9	\N	\N	\N	\N	\N	str
1132	2024-05-18 15:31:48.187+00	2024-05-18 15:31:48.187+00	f	\N	\N	Descripción	descripcion-esr9	\N	\N	\N	\N	\N	str
1133	2024-05-18 15:31:48.199+00	2024-05-18 15:31:48.199+00	f	\N	\N	Nombre del campo	nombre-del-campo-go4h	\N	\N	\N	\N	\N	str
1134	2024-05-18 15:31:48.21+00	2024-05-18 15:31:48.21+00	f	\N	\N	No. Sesión	no-sesion-ccrw	\N	\N	\N	\N	\N	str
1135	2024-05-18 15:31:48.221+00	2024-05-18 15:31:48.221+00	f	\N	\N	Tipo	tipo-b4e7	\N	\N	\N	\N	\N	str
1136	2024-05-18 15:31:48.232+00	2024-05-18 15:31:48.232+00	f	\N	\N	Pleno o nombre de la comisión	pleno-o-nombre-de-la-comision-qus3	\N	\N	\N	\N	\N	str
1137	2024-05-18 15:31:48.243+00	2024-05-18 15:31:48.243+00	f	\N	\N	Fecha	fecha-zasb	\N	\N	\N	\N	\N	str
1138	2024-05-18 15:31:48.254+00	2024-05-18 15:31:48.254+00	f	\N	\N	Hora	hora-qq01	\N	\N	\N	\N	\N	str
1139	2024-05-18 15:31:48.266+00	2024-05-18 15:31:48.266+00	f	\N	\N	Asistencia	asistencia-xime	\N	\N	\N	\N	\N	str
1140	2024-05-18 15:31:48.279+00	2024-05-18 15:31:48.279+00	f	\N	\N	Enlace al acta	enlace-al-acta-xtaf	\N	\N	\N	\N	\N	str
1141	2024-05-18 15:31:48.298+00	2024-05-18 15:31:48.298+00	f	\N	\N	No. Sesión	no-sesion-1xca	\N	\N	\N	\N	\N	str
1142	2024-05-18 15:31:48.309+00	2024-05-18 15:31:48.309+00	f	\N	\N	Tipo	tipo-pinr	\N	\N	\N	\N	\N	str
1143	2024-05-18 15:31:48.319+00	2024-05-18 15:31:48.319+00	f	\N	\N	Pleno o nombre de la comisión	pleno-o-nombre-de-la-comision-lm4n	\N	\N	\N	\N	\N	str
1144	2024-05-18 15:31:48.33+00	2024-05-18 15:31:48.33+00	f	\N	\N	Fecha	fecha-myjp	\N	\N	\N	\N	\N	str
1145	2024-05-18 15:31:48.341+00	2024-05-18 15:31:48.341+00	f	\N	\N	Hora	hora-fx9j	\N	\N	\N	\N	\N	str
1146	2024-05-18 15:31:48.35+00	2024-05-18 15:31:48.35+00	f	\N	\N	Moción	mocion	\N	\N	\N	\N	\N	str
1147	2024-05-18 15:31:48.36+00	2024-05-18 15:31:48.36+00	f	\N	\N	Proponente	proponente	\N	\N	\N	\N	\N	str
1148	2024-05-18 15:31:48.371+00	2024-05-18 15:31:48.371+00	f	\N	\N	Asambleísta	asambleista-36vi	\N	\N	\N	\N	\N	str
1149	2024-05-18 15:31:48.381+00	2024-05-18 15:31:48.381+00	f	\N	\N	Voto	voto	\N	\N	\N	\N	\N	str
1150	2024-05-18 15:31:48.398+00	2024-05-18 15:31:48.398+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-pj53	\N	\N	\N	\N	\N	str
1151	2024-05-18 15:31:48.409+00	2024-05-18 15:31:48.41+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-3adt	\N	\N	\N	\N	\N	str
1152	2024-05-18 15:31:48.419+00	2024-05-18 15:31:48.42+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-jy4y	\N	\N	\N	\N	\N	str
1153	2024-05-18 15:31:48.43+00	2024-05-18 15:31:48.43+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-10km	\N	\N	\N	\N	\N	str
1154	2024-05-18 15:31:48.44+00	2024-05-18 15:31:48.44+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-616r	\N	\N	\N	\N	\N	str
1155	2024-05-18 15:31:48.451+00	2024-05-18 15:31:48.451+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-p0fm	\N	\N	\N	\N	\N	str
1156	2024-05-18 15:31:48.463+00	2024-05-18 15:31:48.463+00	f	\N	\N	LICENCIA	licencia-3s0b	\N	\N	\N	\N	\N	str
1157	2024-05-18 15:31:48.481+00	2024-05-18 15:31:48.481+00	f	\N	\N	Institución	institucion-ktw8	\N	\N	\N	\N	\N	str
1158	2024-05-18 15:31:48.493+00	2024-05-18 15:31:48.493+00	f	\N	\N	Descripción	descripcion-2bnc	\N	\N	\N	\N	\N	str
1159	2024-05-18 15:31:48.504+00	2024-05-18 15:31:48.504+00	f	\N	\N	Nombre del campo	nombre-del-campo-wxds	\N	\N	\N	\N	\N	str
1160	2024-05-18 15:31:48.514+00	2024-05-18 15:31:48.514+00	f	\N	\N	No. Sesión	no-sesion-tjrm	\N	\N	\N	\N	\N	str
1161	2024-05-18 15:31:48.526+00	2024-05-18 15:31:48.526+00	f	\N	\N	Tipo	tipo-lhsr	\N	\N	\N	\N	\N	str
1162	2024-05-18 15:31:48.536+00	2024-05-18 15:31:48.536+00	f	\N	\N	Pleno o nombre de la comisión	pleno-o-nombre-de-la-comision-ty03	\N	\N	\N	\N	\N	str
1163	2024-05-18 15:31:48.547+00	2024-05-18 15:31:48.547+00	f	\N	\N	Fecha	fecha-ig66	\N	\N	\N	\N	\N	str
1164	2024-05-18 15:31:48.557+00	2024-05-18 15:31:48.557+00	f	\N	\N	Hora	hora-t5qy	\N	\N	\N	\N	\N	str
1165	2024-05-18 15:31:48.567+00	2024-05-18 15:31:48.567+00	f	\N	\N	Moción	mocion-a4py	\N	\N	\N	\N	\N	str
1166	2024-05-18 15:31:48.577+00	2024-05-18 15:31:48.577+00	f	\N	\N	Proponente	proponente-vayf	\N	\N	\N	\N	\N	str
1167	2024-05-18 15:31:48.588+00	2024-05-18 15:31:48.588+00	f	\N	\N	Asambleísta	asambleista-10ob	\N	\N	\N	\N	\N	str
1168	2024-05-18 15:31:48.6+00	2024-05-18 15:31:48.6+00	f	\N	\N	Voto	voto-j3b9	\N	\N	\N	\N	\N	str
1169	2024-05-18 15:31:48.617+00	2024-05-18 15:31:48.617+00	f	\N	\N	Institución	institucion-c1n0	\N	\N	\N	\N	\N	str
1170	2024-05-18 15:31:48.626+00	2024-05-18 15:31:48.626+00	f	\N	\N	Asunto	asunto	\N	\N	\N	\N	\N	str
1171	2024-05-18 15:31:48.636+00	2024-05-18 15:31:48.636+00	f	\N	\N	Asambleísta	asambleista-hh1w	\N	\N	\N	\N	\N	str
1172	2024-05-18 15:31:48.645+00	2024-05-18 15:31:48.645+00	f	\N	\N	Fecha Solicitud	fecha-solicitud	\N	\N	\N	\N	\N	str
1173	2024-05-18 15:31:48.653+00	2024-05-18 15:31:48.653+00	f	\N	\N	DTS Solicitud	dts-solicitud	\N	\N	\N	\N	\N	str
1174	2024-05-18 15:31:48.662+00	2024-05-18 15:31:48.662+00	f	\N	\N	Fecha respuesta	fecha-respuesta	\N	\N	\N	\N	\N	str
1175	2024-05-18 15:31:48.671+00	2024-05-18 15:31:48.671+00	f	\N	\N	No. Oficio Respuesta	no-oficio-respuesta	\N	\N	\N	\N	\N	str
1176	2024-05-18 15:31:48.679+00	2024-05-18 15:31:48.679+00	f	\N	\N	Enlace a documentos	enlace-a-documentos	\N	\N	\N	\N	\N	str
1177	2024-05-18 15:31:48.695+00	2024-05-18 15:31:48.695+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-hppt	\N	\N	\N	\N	\N	str
1178	2024-05-18 15:31:48.706+00	2024-05-18 15:31:48.706+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-hr01	\N	\N	\N	\N	\N	str
1179	2024-05-18 15:31:48.717+00	2024-05-18 15:31:48.717+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-7oro	\N	\N	\N	\N	\N	str
1180	2024-05-18 15:31:48.728+00	2024-05-18 15:31:48.728+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-1kj7	\N	\N	\N	\N	\N	str
1181	2024-05-18 15:31:48.739+00	2024-05-18 15:31:48.739+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-n5kv	\N	\N	\N	\N	\N	str
1182	2024-05-18 15:31:48.75+00	2024-05-18 15:31:48.75+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-jzi6	\N	\N	\N	\N	\N	str
1183	2024-05-18 15:31:48.761+00	2024-05-18 15:31:48.761+00	f	\N	\N	LICENCIA	licencia-r9s4	\N	\N	\N	\N	\N	str
1184	2024-05-18 15:31:48.779+00	2024-05-18 15:31:48.779+00	f	\N	\N	Institución	institucion-t2l6	\N	\N	\N	\N	\N	str
1185	2024-05-18 15:31:48.79+00	2024-05-18 15:31:48.79+00	f	\N	\N	Descripción	descripcion-o83u	\N	\N	\N	\N	\N	str
1186	2024-05-18 15:31:48.8+00	2024-05-18 15:31:48.8+00	f	\N	\N	Nombre del campo	nombre-del-campo-xw5h	\N	\N	\N	\N	\N	str
1187	2024-05-18 15:31:48.811+00	2024-05-18 15:31:48.812+00	f	\N	\N	Institución	institucion-lhgx	\N	\N	\N	\N	\N	str
1188	2024-05-18 15:31:48.823+00	2024-05-18 15:31:48.823+00	f	\N	\N	Asunto	asunto-bniv	\N	\N	\N	\N	\N	str
1189	2024-05-18 15:31:48.833+00	2024-05-18 15:31:48.833+00	f	\N	\N	Asambleísta	asambleista-s6jc	\N	\N	\N	\N	\N	str
1190	2024-05-18 15:31:48.845+00	2024-05-18 15:31:48.845+00	f	\N	\N	Fecha Solicitud	fecha-solicitud-9phi	\N	\N	\N	\N	\N	str
1191	2024-05-18 15:31:48.856+00	2024-05-18 15:31:48.856+00	f	\N	\N	DTS Solicitud	dts-solicitud-v3id	\N	\N	\N	\N	\N	str
1192	2024-05-18 15:31:48.867+00	2024-05-18 15:31:48.867+00	f	\N	\N	Fecha respuesta	fecha-respuesta-846s	\N	\N	\N	\N	\N	str
1193	2024-05-18 15:31:48.878+00	2024-05-18 15:31:48.878+00	f	\N	\N	No. Oficio Respuesta	no-oficio-respuesta-pnuu	\N	\N	\N	\N	\N	str
1194	2024-05-18 15:31:48.889+00	2024-05-18 15:31:48.889+00	f	\N	\N	Enlace a documentos	enlace-a-documentos-rety	\N	\N	\N	\N	\N	str
1195	2024-05-18 15:31:48.906+00	2024-05-18 15:31:48.906+00	f	\N	\N	Código	codigo-61bb	\N	\N	\N	\N	\N	str
1196	2024-05-18 15:31:48.914+00	2024-05-18 15:31:48.914+00	f	\N	\N	Fecha de solicitud	fecha-de-solicitud	\N	\N	\N	\N	\N	str
1197	2024-05-18 15:31:48.924+00	2024-05-18 15:31:48.924+00	f	\N	\N	Persona enjuiciada	persona-enjuiciada	\N	\N	\N	\N	\N	str
1198	2024-05-18 15:31:48.932+00	2024-05-18 15:31:48.932+00	f	\N	\N	Solicitante (s)	solicitante-s	\N	\N	\N	\N	\N	str
1199	2024-05-18 15:31:48.941+00	2024-05-18 15:31:48.941+00	f	\N	\N	Institución de la persona enjuiciada	institucion-de-la-persona-enjuiciada	\N	\N	\N	\N	\N	str
1200	2024-05-18 15:31:48.949+00	2024-05-18 15:31:48.949+00	f	\N	\N	Fecha de resolución	fecha-de-resolucion	\N	\N	\N	\N	\N	str
1201	2024-05-18 15:31:48.96+00	2024-05-18 15:31:48.96+00	f	\N	\N	Estado	estado-keea	\N	\N	\N	\N	\N	str
1202	2024-05-18 15:31:48.969+00	2024-05-18 15:31:48.969+00	f	\N	\N	Documento o resolución	documento-o-resolucion	\N	\N	\N	\N	\N	str
1203	2024-05-18 15:31:48.978+00	2024-05-18 15:31:48.978+00	f	\N	\N	Enlace a documento	enlace-a-documento	\N	\N	\N	\N	\N	str
1204	2024-05-18 15:31:48.995+00	2024-05-18 15:31:48.995+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-ytkb	\N	\N	\N	\N	\N	str
1205	2024-05-18 15:31:49.006+00	2024-05-18 15:31:49.006+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-q4dk	\N	\N	\N	\N	\N	str
1206	2024-05-18 15:31:49.015+00	2024-05-18 15:31:49.015+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-fe7y	\N	\N	\N	\N	\N	str
1207	2024-05-18 15:31:49.025+00	2024-05-18 15:31:49.025+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-huc4	\N	\N	\N	\N	\N	str
1208	2024-05-18 15:31:49.035+00	2024-05-18 15:31:49.035+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-mqrf	\N	\N	\N	\N	\N	str
1209	2024-05-18 15:31:49.046+00	2024-05-18 15:31:49.046+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-yi94	\N	\N	\N	\N	\N	str
1210	2024-05-18 15:31:49.057+00	2024-05-18 15:31:49.057+00	f	\N	\N	LICENCIA	licencia-un0w	\N	\N	\N	\N	\N	str
1211	2024-05-18 15:31:49.076+00	2024-05-18 15:31:49.076+00	f	\N	\N	Institución	institucion-mjgm	\N	\N	\N	\N	\N	str
1212	2024-05-18 15:31:49.087+00	2024-05-18 15:31:49.087+00	f	\N	\N	Descripción	descripcion-czrd	\N	\N	\N	\N	\N	str
1213	2024-05-18 15:31:49.099+00	2024-05-18 15:31:49.099+00	f	\N	\N	Nombre del campo	nombre-del-campo-3g1a	\N	\N	\N	\N	\N	str
1214	2024-05-18 15:31:49.108+00	2024-05-18 15:31:49.108+00	f	\N	\N	Código del trámite	codigo-del-tramite	\N	\N	\N	\N	\N	str
1215	2024-05-18 15:31:49.12+00	2024-05-18 15:31:49.12+00	f	\N	\N	Fecha de solicitud	fecha-de-solicitud-cijc	\N	\N	\N	\N	\N	str
1216	2024-05-18 15:31:49.131+00	2024-05-18 15:31:49.131+00	f	\N	\N	Persona enjuiciada	persona-enjuiciada-q9xw	\N	\N	\N	\N	\N	str
1217	2024-05-18 15:31:49.143+00	2024-05-18 15:31:49.143+00	f	\N	\N	Solicitante (s)	solicitante-s-z0r6	\N	\N	\N	\N	\N	str
1218	2024-05-18 15:31:49.153+00	2024-05-18 15:31:49.153+00	f	\N	\N	Institución de la persona enjuiciada	institucion-de-la-persona-enjuiciada-5g3z	\N	\N	\N	\N	\N	str
1219	2024-05-18 15:31:49.163+00	2024-05-18 15:31:49.163+00	f	\N	\N	Fecha de la resolución	fecha-de-la-resolucion	\N	\N	\N	\N	\N	str
1220	2024-05-18 15:31:49.175+00	2024-05-18 15:31:49.175+00	f	\N	\N	Estado	estado-17et	\N	\N	\N	\N	\N	str
1221	2024-05-18 15:31:49.188+00	2024-05-18 15:31:49.188+00	f	\N	\N	Documento o resolución	documento-o-resolucion-hnc0	\N	\N	\N	\N	\N	str
1222	2024-05-18 15:31:49.2+00	2024-05-18 15:31:49.2+00	f	\N	\N	Enlace a documento	enlace-a-documento-qkxw	\N	\N	\N	\N	\N	str
1223	2024-05-18 15:31:49.218+00	2024-05-18 15:31:49.218+00	f	\N	\N	Fecha	fecha-xov8	\N	\N	\N	\N	\N	str
1224	2024-05-18 15:31:49.228+00	2024-05-18 15:31:49.228+00	f	\N	\N	Entidad	entidad	\N	\N	\N	\N	\N	str
1225	2024-05-18 15:31:49.243+00	2024-05-18 15:31:49.243+00	f	\N	\N	Tipo	tipo-i0ip	\N	\N	\N	\N	\N	str
1226	2024-05-18 15:31:49.252+00	2024-05-18 15:31:49.252+00	f	\N	\N	Detalle	detalle	\N	\N	\N	\N	\N	str
1227	2024-05-18 15:31:49.265+00	2024-05-18 15:31:49.265+00	f	\N	\N	Enlace a documento	enlace-a-documento-yryy	\N	\N	\N	\N	\N	str
1228	2024-05-18 15:31:49.283+00	2024-05-18 15:31:49.283+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-b4n2	\N	\N	\N	\N	\N	str
1229	2024-05-18 15:31:49.294+00	2024-05-18 15:31:49.294+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-jq50	\N	\N	\N	\N	\N	str
1230	2024-05-18 15:31:49.305+00	2024-05-18 15:31:49.305+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-19vg	\N	\N	\N	\N	\N	str
1231	2024-05-18 15:31:49.316+00	2024-05-18 15:31:49.316+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-3bf3	\N	\N	\N	\N	\N	str
1232	2024-05-18 15:31:49.328+00	2024-05-18 15:31:49.328+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-539m	\N	\N	\N	\N	\N	str
1233	2024-05-18 15:31:49.339+00	2024-05-18 15:31:49.339+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-uehz	\N	\N	\N	\N	\N	str
1234	2024-05-18 15:31:49.349+00	2024-05-18 15:31:49.349+00	f	\N	\N	LICENCIA	licencia-bigw	\N	\N	\N	\N	\N	str
1235	2024-05-18 15:31:49.368+00	2024-05-18 15:31:49.368+00	f	\N	\N	Institución	institucion-xrxd	\N	\N	\N	\N	\N	str
1236	2024-05-18 15:31:49.378+00	2024-05-18 15:31:49.378+00	f	\N	\N	Descripción	descripcion-2tx7	\N	\N	\N	\N	\N	str
1237	2024-05-18 15:31:49.389+00	2024-05-18 15:31:49.389+00	f	\N	\N	Nombre del campo	nombre-del-campo-jdks	\N	\N	\N	\N	\N	str
1238	2024-05-18 15:31:49.399+00	2024-05-18 15:31:49.399+00	f	\N	\N	Fecha	fecha-kzsc	\N	\N	\N	\N	\N	str
1239	2024-05-18 15:31:49.409+00	2024-05-18 15:31:49.409+00	f	\N	\N	Entidad	entidad-eum1	\N	\N	\N	\N	\N	str
1240	2024-05-18 15:31:49.419+00	2024-05-18 15:31:49.419+00	f	\N	\N	Tipo	tipo-v2gd	\N	\N	\N	\N	\N	str
1241	2024-05-18 15:31:49.431+00	2024-05-18 15:31:49.431+00	f	\N	\N	Detalle	detalle-zp6g	\N	\N	\N	\N	\N	str
1242	2024-05-18 15:31:49.441+00	2024-05-18 15:31:49.441+00	f	\N	\N	Enlace a documento	enlace-a-documento-z890	\N	\N	\N	\N	\N	str
1243	2024-05-18 15:31:49.459+00	2024-05-18 15:31:49.459+00	f	\N	\N	Fecha	fecha-egae	\N	\N	\N	\N	\N	str
1244	2024-05-18 15:31:49.47+00	2024-05-18 15:31:49.47+00	f	\N	\N	Asambleísta	asambleista-62bp	\N	\N	\N	\N	\N	str
1245	2024-05-18 15:31:49.48+00	2024-05-18 15:31:49.48+00	f	\N	\N	Principal o suplente	principal-o-suplente	\N	\N	\N	\N	\N	str
1246	2024-05-18 15:31:49.489+00	2024-05-18 15:31:49.489+00	f	\N	\N	Período de funciones	periodo-de-funciones	\N	\N	\N	\N	\N	str
1247	2024-05-18 15:31:49.497+00	2024-05-18 15:31:49.497+00	f	\N	\N	Enlace a declaración	enlace-a-declaracion	\N	\N	\N	\N	\N	str
1248	2024-05-18 15:31:49.515+00	2024-05-18 15:31:49.515+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-imfe	\N	\N	\N	\N	\N	str
1249	2024-05-18 15:31:49.525+00	2024-05-18 15:31:49.525+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-xgdy	\N	\N	\N	\N	\N	str
1250	2024-05-18 15:31:49.535+00	2024-05-18 15:31:49.535+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-7n12	\N	\N	\N	\N	\N	str
1251	2024-05-18 15:31:49.546+00	2024-05-18 15:31:49.546+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-l9u7	\N	\N	\N	\N	\N	str
1252	2024-05-18 15:31:49.557+00	2024-05-18 15:31:49.557+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-zomo	\N	\N	\N	\N	\N	str
1253	2024-05-18 15:31:49.569+00	2024-05-18 15:31:49.569+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-grh1	\N	\N	\N	\N	\N	str
1254	2024-05-18 15:31:49.58+00	2024-05-18 15:31:49.58+00	f	\N	\N	LICENCIA	licencia-kt4d	\N	\N	\N	\N	\N	str
1255	2024-05-18 15:31:49.597+00	2024-05-18 15:31:49.597+00	f	\N	\N	Institución	institucion-56el	\N	\N	\N	\N	\N	str
1256	2024-05-18 15:31:49.607+00	2024-05-18 15:31:49.607+00	f	\N	\N	Descripción	descripcion-593i	\N	\N	\N	\N	\N	str
1257	2024-05-18 15:31:49.617+00	2024-05-18 15:31:49.617+00	f	\N	\N	Nombre del campo	nombre-del-campo-1h68	\N	\N	\N	\N	\N	str
1258	2024-05-18 15:31:49.628+00	2024-05-18 15:31:49.628+00	f	\N	\N	Fecha	fecha-8cvl	\N	\N	\N	\N	\N	str
1259	2024-05-18 15:31:49.638+00	2024-05-18 15:31:49.638+00	f	\N	\N	Asambleísta	asambleista-lk7y	\N	\N	\N	\N	\N	str
1260	2024-05-18 15:31:49.649+00	2024-05-18 15:31:49.649+00	f	\N	\N	Principal o suplente	principal-o-suplente-iids	\N	\N	\N	\N	\N	str
1261	2024-05-18 15:31:49.659+00	2024-05-18 15:31:49.659+00	f	\N	\N	Período de funciones	periodo-de-funciones-ucqb	\N	\N	\N	\N	\N	str
1262	2024-05-18 15:31:49.67+00	2024-05-18 15:31:49.67+00	f	\N	\N	Enlace a declaración	enlace-a-declaracion-p14q	\N	\N	\N	\N	\N	str
1263	2024-05-18 15:31:49.69+00	2024-05-18 15:31:49.69+00	f	\N	\N	Cuenta	cuenta-bdcx	\N	\N	\N	\N	\N	str
1264	2024-05-18 15:31:49.7+00	2024-05-18 15:31:49.7+00	f	\N	\N	Categoría	categoria	\N	\N	\N	\N	\N	str
1265	2024-05-18 15:31:49.712+00	2024-05-18 15:31:49.712+00	f	\N	\N	Descripción	descripcion-uv3v	\N	\N	\N	\N	\N	str
1266	2024-05-18 15:31:49.722+00	2024-05-18 15:31:49.723+00	f	\N	\N	Asignado	asignado	\N	\N	\N	\N	\N	str
1267	2024-05-18 15:31:49.732+00	2024-05-18 15:31:49.732+00	f	\N	\N	Modificado	modificado	\N	\N	\N	\N	\N	str
1268	2024-05-18 15:31:49.745+00	2024-05-18 15:31:49.745+00	f	\N	\N	Codificado	codificado-ehjo	\N	\N	\N	\N	\N	str
1269	2024-05-18 15:31:49.755+00	2024-05-18 15:31:49.755+00	f	\N	\N	Monto certificado	monto-certificado	\N	\N	\N	\N	\N	str
1270	2024-05-18 15:31:49.767+00	2024-05-18 15:31:49.767+00	f	\N	\N	Comprometido	comprometido-75mw	\N	\N	\N	\N	\N	str
1271	2024-05-18 15:31:49.779+00	2024-05-18 15:31:49.779+00	f	\N	\N	Devengado	devengado-q47c	\N	\N	\N	\N	\N	str
1272	2024-05-18 15:31:49.791+00	2024-05-18 15:31:49.791+00	f	\N	\N	Pagado	pagado-il96	\N	\N	\N	\N	\N	str
1273	2024-05-18 15:31:49.802+00	2024-05-18 15:31:49.802+00	f	\N	\N	Saldo por comprometer	saldo-por-comprometer	\N	\N	\N	\N	\N	str
1274	2024-05-18 15:31:49.812+00	2024-05-18 15:31:49.812+00	f	\N	\N	Saldo por devengar	saldo-por-devengar	\N	\N	\N	\N	\N	str
1275	2024-05-18 15:31:49.822+00	2024-05-18 15:31:49.822+00	f	\N	\N	Saldo por pagar	saldo-por-pagar	\N	\N	\N	\N	\N	str
1276	2024-05-18 15:31:49.832+00	2024-05-18 15:31:49.832+00	f	\N	\N	Porcentaje de ejecución	porcentaje-de-ejecucion	\N	\N	\N	\N	\N	str
1277	2024-05-18 15:31:49.852+00	2024-05-18 15:31:49.852+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN	fecha-actualizacion-de-la-informacion-flvw	\N	\N	\N	\N	\N	str
1278	2024-05-18 15:31:49.864+00	2024-05-18 15:31:49.864+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN	periodicidad-de-actualizacion-de-la-informacion-fssc	\N	\N	\N	\N	\N	str
1279	2024-05-18 15:31:49.876+00	2024-05-18 15:31:49.876+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN	unidad-poseedora-de-la-informacion-f48u	\N	\N	\N	\N	\N	str
1280	2024-05-18 15:31:49.889+00	2024-05-18 15:31:49.889+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	persona-responsable-de-la-unidad-poseedora-de-la-informacion-h37r	\N	\N	\N	\N	\N	str
1281	2024-05-18 15:31:49.901+00	2024-05-18 15:31:49.901+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-pm7b	\N	\N	\N	\N	\N	str
1282	2024-05-18 15:31:49.913+00	2024-05-18 15:31:49.913+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-q8pm	\N	\N	\N	\N	\N	str
1283	2024-05-18 15:31:49.926+00	2024-05-18 15:31:49.926+00	f	\N	\N	LICENCIA	licencia-qf3j	\N	\N	\N	\N	\N	str
1284	2024-05-18 15:31:49.946+00	2024-05-18 15:31:49.946+00	f	\N	\N	Institución	institucion-ih1l	\N	\N	\N	\N	\N	str
1285	2024-05-18 15:31:49.959+00	2024-05-18 15:31:49.959+00	f	\N	\N	Descripción	descripcion-tlix	\N	\N	\N	\N	\N	str
1286	2024-05-18 15:31:49.973+00	2024-05-18 15:31:49.973+00	f	\N	\N	Nombre del campo	nombre-del-campo-2eoe	\N	\N	\N	\N	\N	str
1287	2024-05-18 15:31:49.986+00	2024-05-18 15:31:49.986+00	f	\N	\N	Cuenta	cuenta-vysi	\N	\N	\N	\N	\N	str
1288	2024-05-18 15:31:49.998+00	2024-05-18 15:31:49.998+00	f	\N	\N	Categoría	categoria-z7m6	\N	\N	\N	\N	\N	str
1289	2024-05-18 15:31:50.012+00	2024-05-18 15:31:50.012+00	f	\N	\N	Descripción	descripcion-e716	\N	\N	\N	\N	\N	str
1290	2024-05-18 15:31:50.025+00	2024-05-18 15:31:50.025+00	f	\N	\N	Asignado	asignado-umrs	\N	\N	\N	\N	\N	str
1291	2024-05-18 15:31:50.036+00	2024-05-18 15:31:50.036+00	f	\N	\N	Modificado	modificado-ti2x	\N	\N	\N	\N	\N	str
1292	2024-05-18 15:31:50.048+00	2024-05-18 15:31:50.048+00	f	\N	\N	Codificado	codificado-8ylx	\N	\N	\N	\N	\N	str
1293	2024-05-18 15:31:50.059+00	2024-05-18 15:31:50.059+00	f	\N	\N	Monto certificado	monto-certificado-ey31	\N	\N	\N	\N	\N	str
1294	2024-05-18 15:31:50.069+00	2024-05-18 15:31:50.069+00	f	\N	\N	Comprometido	comprometido-mfrh	\N	\N	\N	\N	\N	str
1295	2024-05-18 15:31:50.08+00	2024-05-18 15:31:50.08+00	f	\N	\N	Devengado	devengado-skgx	\N	\N	\N	\N	\N	str
1296	2024-05-18 15:31:50.09+00	2024-05-18 15:31:50.09+00	f	\N	\N	Pagado	pagado-1sgi	\N	\N	\N	\N	\N	str
1297	2024-05-18 15:31:50.101+00	2024-05-18 15:31:50.101+00	f	\N	\N	Saldo por comprometer	saldo-por-comprometer-7u4b	\N	\N	\N	\N	\N	str
1298	2024-05-18 15:31:50.11+00	2024-05-18 15:31:50.11+00	f	\N	\N	Saldo por devengar	saldo-por-devengar-lxdi	\N	\N	\N	\N	\N	str
1299	2024-05-18 15:31:50.119+00	2024-05-18 15:31:50.119+00	f	\N	\N	Saldo por pagar	saldo-por-pagar-29yj	\N	\N	\N	\N	\N	str
1300	2024-05-18 15:31:50.13+00	2024-05-18 15:31:50.13+00	f	\N	\N	Porcentaje de ejecución	porcentaje-de-ejecucion-2v7w	\N	\N	\N	\N	\N	str
1301	2024-05-18 15:31:50.149+00	2024-05-18 15:31:50.149+00	f	\N	\N	No.	no-1mq1	\N	\N	\N	\N	\N	str
1302	2024-05-18 15:31:50.157+00	2024-05-18 15:31:50.157+00	f	\N	\N	RUC / Número Identificación de la empresa o persona contratista	ruc-numero-identificacion-de-la-empresa-o-persona-contratista	\N	\N	\N	\N	\N	str
1303	2024-05-18 15:31:50.165+00	2024-05-18 15:31:50.165+00	f	\N	\N	Número de contrato / código del proceso de contratación fallido o incumplido	numero-de-contrato-codigo-del-proceso-de-contratacion-fallido-o-incumplido	\N	\N	\N	\N	\N	str
1304	2024-05-18 15:31:50.173+00	2024-05-18 15:31:50.173+00	f	\N	\N	Monto del contrato incumplido	monto-del-contrato-incumplido	\N	\N	\N	\N	\N	str
1305	2024-05-18 15:31:50.18+00	2024-05-18 15:31:50.18+00	f	\N	\N	Fecha desde	fecha-desde	\N	\N	\N	\N	\N	str
1306	2024-05-18 15:31:50.188+00	2024-05-18 15:31:50.188+00	f	\N	\N	Fecha hasta	fecha-hasta	\N	\N	\N	\N	\N	str
1307	2024-05-18 15:31:50.206+00	2024-05-18 15:31:50.206+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN	fecha-actualizacion-de-la-informacion-vy0i	\N	\N	\N	\N	\N	str
1308	2024-05-18 15:31:50.217+00	2024-05-18 15:31:50.217+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN	periodicidad-de-actualizacion-de-la-informacion-9msu	\N	\N	\N	\N	\N	str
1309	2024-05-18 15:31:50.229+00	2024-05-18 15:31:50.229+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN	unidad-poseedora-de-la-informacion-3b6t	\N	\N	\N	\N	\N	str
1310	2024-05-18 15:31:50.24+00	2024-05-18 15:31:50.24+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	persona-responsable-de-la-unidad-poseedora-de-la-informacion-wqpb	\N	\N	\N	\N	\N	str
1311	2024-05-18 15:31:50.25+00	2024-05-18 15:31:50.25+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-mqy0	\N	\N	\N	\N	\N	str
1312	2024-05-18 15:31:50.26+00	2024-05-18 15:31:50.26+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-2354	\N	\N	\N	\N	\N	str
1313	2024-05-18 15:31:50.27+00	2024-05-18 15:31:50.27+00	f	\N	\N	LICENCIA	licencia-44w7	\N	\N	\N	\N	\N	str
1314	2024-05-18 15:31:50.279+00	2024-05-18 15:31:50.279+00	f	\N	\N	ENLACE PARA CONSULTA DE PROVEEDORES INCUMPLIDOS Y ADJUDICATARIOS FALLIDOS DEL SISTEMA OFICIAL DE CONTRATACIÓN PÚBLICA	enlace-para-consulta-de-proveedores-incumplidos-y-adjudicatarios-fallidos-del-sistema-oficial-de-contratacion-publica	\N	\N	\N	\N	\N	str
1315	2024-05-18 15:31:50.298+00	2024-05-18 15:31:50.298+00	f	\N	\N	Institución	institucion-v4s3	\N	\N	\N	\N	\N	str
1316	2024-05-18 15:31:50.31+00	2024-05-18 15:31:50.31+00	f	\N	\N	Descripción	descripcion-h22u	\N	\N	\N	\N	\N	str
1317	2024-05-18 15:31:50.321+00	2024-05-18 15:31:50.321+00	f	\N	\N	Nombre del campo	nombre-del-campo-fw5v	\N	\N	\N	\N	\N	str
1318	2024-05-18 15:31:50.333+00	2024-05-18 15:31:50.333+00	f	\N	\N	No.	no-lxi8	\N	\N	\N	\N	\N	str
1319	2024-05-18 15:31:50.345+00	2024-05-18 15:31:50.345+00	f	\N	\N	RUC / Número Identificación de la empresa o persona contratista	ruc-numero-identificacion-de-la-empresa-o-persona-contratista-7e8k	\N	\N	\N	\N	\N	str
1320	2024-05-18 15:31:50.356+00	2024-05-18 15:31:50.356+00	f	\N	\N	Número de contrato / código del proceso de contratación fallido o incumplido	numero-de-contrato-codigo-del-proceso-de-contratacion-fallido-o-incumplido-x863	\N	\N	\N	\N	\N	str
1321	2024-05-18 15:31:50.366+00	2024-05-18 15:31:50.366+00	f	\N	\N	Monto del contrato incumplido	monto-del-contrato-incumplido-rz4k	\N	\N	\N	\N	\N	str
1322	2024-05-18 15:31:50.377+00	2024-05-18 15:31:50.377+00	f	\N	\N	Fecha desde	fecha-desde-jjln	\N	\N	\N	\N	\N	str
1323	2024-05-18 15:31:50.387+00	2024-05-18 15:31:50.387+00	f	\N	\N	Fecha hasta	fecha-hasta-24or	\N	\N	\N	\N	\N	str
1324	2024-05-18 15:31:50.41+00	2024-05-18 15:31:50.41+00	f	\N	\N	Código	codigo-njx1	\N	\N	\N	\N	\N	str
1325	2024-05-18 15:31:50.421+00	2024-05-18 15:31:50.421+00	f	\N	\N	Tipo	tipo-o5e4	\N	\N	\N	\N	\N	str
1326	2024-05-18 15:31:50.431+00	2024-05-18 15:31:50.431+00	f	\N	\N	Concesionario o Empresa	concesionario-o-empresa	\N	\N	\N	\N	\N	str
1327	2024-05-18 15:31:50.44+00	2024-05-18 15:31:50.44+00	f	\N	\N	Fase	fase	\N	\N	\N	\N	\N	str
1328	2024-05-18 15:31:50.448+00	2024-05-18 15:31:50.448+00	f	\N	\N	Recurso	recurso	\N	\N	\N	\N	\N	str
1329	2024-05-18 15:31:50.457+00	2024-05-18 15:31:50.457+00	f	\N	\N	Forma o Método	forma-o-metodo	\N	\N	\N	\N	\N	str
1330	2024-05-18 15:31:50.467+00	2024-05-18 15:31:50.467+00	f	\N	\N	Estado	estado-8rj3	\N	\N	\N	\N	\N	str
1331	2024-05-18 15:31:50.476+00	2024-05-18 15:31:50.476+00	f	\N	\N	Fecha de Otorgamiento	fecha-de-otorgamiento	\N	\N	\N	\N	\N	str
1332	2024-05-18 15:31:50.485+00	2024-05-18 15:31:50.485+00	f	\N	\N	Monto de Concesión o Contrato	monto-de-concesion-o-contrato	\N	\N	\N	\N	\N	str
1333	2024-05-18 15:31:50.494+00	2024-05-18 15:31:50.494+00	f	\N	\N	Superficie	superficie	\N	\N	\N	\N	\N	str
1334	2024-05-18 15:31:50.502+00	2024-05-18 15:31:50.502+00	f	\N	\N	Plazo	plazo	\N	\N	\N	\N	\N	str
1335	2024-05-18 15:31:50.511+00	2024-05-18 15:31:50.511+00	f	\N	\N	Destino de Recursos	destino-de-recursos	\N	\N	\N	\N	\N	str
1336	2024-05-18 15:31:50.52+00	2024-05-18 15:31:50.52+00	f	\N	\N	Provincia	provincia-c4dm	\N	\N	\N	\N	\N	str
1337	2024-05-18 15:31:50.531+00	2024-05-18 15:31:50.531+00	f	\N	\N	Cantón	canton-m1jd	\N	\N	\N	\N	\N	str
1338	2024-05-18 15:31:50.542+00	2024-05-18 15:31:50.542+00	f	\N	\N	Parroquia	parroquia-nkg5	\N	\N	\N	\N	\N	str
1339	2024-05-18 15:31:50.56+00	2024-05-18 15:31:50.561+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-ygn0	\N	\N	\N	\N	\N	str
1340	2024-05-18 15:31:50.573+00	2024-05-18 15:31:50.573+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-ex0y	\N	\N	\N	\N	\N	str
1341	2024-05-18 15:31:50.583+00	2024-05-18 15:31:50.583+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-8i9a	\N	\N	\N	\N	\N	str
1342	2024-05-18 15:31:50.595+00	2024-05-18 15:31:50.595+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-ydli	\N	\N	\N	\N	\N	str
1343	2024-05-18 15:31:50.607+00	2024-05-18 15:31:50.607+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-k3i7	\N	\N	\N	\N	\N	str
1344	2024-05-18 15:31:50.618+00	2024-05-18 15:31:50.618+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-rwyq	\N	\N	\N	\N	\N	str
1345	2024-05-18 15:31:50.631+00	2024-05-18 15:31:50.631+00	f	\N	\N	LICENCIA	licencia-xiqg	\N	\N	\N	\N	\N	str
1346	2024-05-18 15:31:50.65+00	2024-05-18 15:31:50.65+00	f	\N	\N	Institución	institucion-oa9b	\N	\N	\N	\N	\N	str
1347	2024-05-18 15:31:50.662+00	2024-05-18 15:31:50.662+00	f	\N	\N	Descripción	descripcion-pp2s	\N	\N	\N	\N	\N	str
1348	2024-05-18 15:31:50.675+00	2024-05-18 15:31:50.675+00	f	\N	\N	Nombre del campo	nombre-del-campo-05e5	\N	\N	\N	\N	\N	str
1349	2024-05-18 15:31:50.686+00	2024-05-18 15:31:50.686+00	f	\N	\N	Código	codigo-451y	\N	\N	\N	\N	\N	str
1350	2024-05-18 15:31:50.699+00	2024-05-18 15:31:50.699+00	f	\N	\N	Tipo	tipo-dqv5	\N	\N	\N	\N	\N	str
1351	2024-05-18 15:31:50.709+00	2024-05-18 15:31:50.709+00	f	\N	\N	Concesionario o Empresa	concesionario-o-empresa-0u35	\N	\N	\N	\N	\N	str
1352	2024-05-18 15:31:50.721+00	2024-05-18 15:31:50.721+00	f	\N	\N	Fase	fase-kfsp	\N	\N	\N	\N	\N	str
1353	2024-05-18 15:31:50.731+00	2024-05-18 15:31:50.731+00	f	\N	\N	Recurso	recurso-pmy6	\N	\N	\N	\N	\N	str
1354	2024-05-18 15:31:50.742+00	2024-05-18 15:31:50.742+00	f	\N	\N	Forma o Método	forma-o-metodo-b1dh	\N	\N	\N	\N	\N	str
1355	2024-05-18 15:31:50.752+00	2024-05-18 15:31:50.752+00	f	\N	\N	Estado	estado-h46s	\N	\N	\N	\N	\N	str
1356	2024-05-18 15:31:50.764+00	2024-05-18 15:31:50.764+00	f	\N	\N	Fecha de Otorgamiento	fecha-de-otorgamiento-shx3	\N	\N	\N	\N	\N	str
1357	2024-05-18 15:31:50.778+00	2024-05-18 15:31:50.778+00	f	\N	\N	Monto de Concesión o Contrato	monto-de-concesion-o-contrato-x7su	\N	\N	\N	\N	\N	str
1358	2024-05-18 15:31:50.79+00	2024-05-18 15:31:50.79+00	f	\N	\N	Superficie	superficie-rlll	\N	\N	\N	\N	\N	str
1359	2024-05-18 15:31:50.802+00	2024-05-18 15:31:50.802+00	f	\N	\N	Plazo	plazo-g1be	\N	\N	\N	\N	\N	str
1360	2024-05-18 15:31:50.814+00	2024-05-18 15:31:50.814+00	f	\N	\N	Destino de Recursos	destino-de-recursos-iqhd	\N	\N	\N	\N	\N	str
1361	2024-05-18 15:31:50.827+00	2024-05-18 15:31:50.827+00	f	\N	\N	Provincia	provincia-h6jb	\N	\N	\N	\N	\N	str
1362	2024-05-18 15:31:50.838+00	2024-05-18 15:31:50.838+00	f	\N	\N	Cantón	canton-t3oz	\N	\N	\N	\N	\N	str
1363	2024-05-18 15:31:50.849+00	2024-05-18 15:31:50.849+00	f	\N	\N	Parroquia	parroquia-f5pe	\N	\N	\N	\N	\N	str
1364	2024-05-18 15:31:50.867+00	2024-05-18 15:31:50.867+00	f	\N	\N	Código	codigo-i1n7	\N	\N	\N	\N	\N	str
1365	2024-05-18 15:31:50.878+00	2024-05-18 15:31:50.878+00	f	\N	\N	Tipo	tipo-vctv	\N	\N	\N	\N	\N	str
1366	2024-05-18 15:31:50.888+00	2024-05-18 15:31:50.888+00	f	\N	\N	Concesionario o Empresa	concesionario-o-empresa-74kv	\N	\N	\N	\N	\N	str
1367	2024-05-18 15:31:50.898+00	2024-05-18 15:31:50.898+00	f	\N	\N	Fecha del pago	fecha-del-pago	\N	\N	\N	\N	\N	str
1368	2024-05-18 15:31:50.91+00	2024-05-18 15:31:50.91+00	f	\N	\N	Monto	monto-36eq	\N	\N	\N	\N	\N	str
1369	2024-05-18 15:31:50.919+00	2024-05-18 15:31:50.919+00	f	\N	\N	Concepto	concepto	\N	\N	\N	\N	\N	str
1370	2024-05-18 15:31:50.929+00	2024-05-18 15:31:50.929+00	f	\N	\N	Beneficiario	beneficiario	\N	\N	\N	\N	\N	str
1371	2024-05-18 15:31:50.94+00	2024-05-18 15:31:50.94+00	f	\N	\N	Detalle	detalle-5sg3	\N	\N	\N	\N	\N	str
1372	2024-05-18 15:31:50.959+00	2024-05-18 15:31:50.959+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-n3ze	\N	\N	\N	\N	\N	str
1373	2024-05-18 15:31:50.972+00	2024-05-18 15:31:50.972+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-d4gf	\N	\N	\N	\N	\N	str
1374	2024-05-18 15:31:50.983+00	2024-05-18 15:31:50.983+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-rcjr	\N	\N	\N	\N	\N	str
1375	2024-05-18 15:31:50.994+00	2024-05-18 15:31:50.994+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-5uj2	\N	\N	\N	\N	\N	str
1376	2024-05-18 15:31:51.007+00	2024-05-18 15:31:51.007+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-nzwx	\N	\N	\N	\N	\N	str
1377	2024-05-18 15:31:51.019+00	2024-05-18 15:31:51.02+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-5adw	\N	\N	\N	\N	\N	str
1378	2024-05-18 15:31:51.031+00	2024-05-18 15:31:51.031+00	f	\N	\N	LICENCIA	licencia-0hxw	\N	\N	\N	\N	\N	str
1379	2024-05-18 15:31:51.052+00	2024-05-18 15:31:51.052+00	f	\N	\N	Institución	institucion-nbiq	\N	\N	\N	\N	\N	str
1380	2024-05-18 15:31:51.062+00	2024-05-18 15:31:51.062+00	f	\N	\N	Descripción	descripcion-bpbb	\N	\N	\N	\N	\N	str
1381	2024-05-18 15:31:51.072+00	2024-05-18 15:31:51.072+00	f	\N	\N	Nombre del campo	nombre-del-campo-zw8c	\N	\N	\N	\N	\N	str
1382	2024-05-18 15:31:51.083+00	2024-05-18 15:31:51.083+00	f	\N	\N	Código	codigo-37js	\N	\N	\N	\N	\N	str
1383	2024-05-18 15:31:51.095+00	2024-05-18 15:31:51.095+00	f	\N	\N	Tipo	tipo-dsjz	\N	\N	\N	\N	\N	str
1384	2024-05-18 15:31:51.105+00	2024-05-18 15:31:51.105+00	f	\N	\N	Concesionario o Empresa	concesionario-o-empresa-7pm5	\N	\N	\N	\N	\N	str
1385	2024-05-18 15:31:51.116+00	2024-05-18 15:31:51.116+00	f	\N	\N	Fecha del pago	fecha-del-pago-ycd8	\N	\N	\N	\N	\N	str
1386	2024-05-18 15:31:51.129+00	2024-05-18 15:31:51.129+00	f	\N	\N	Monto	monto-i3c4	\N	\N	\N	\N	\N	str
1387	2024-05-18 15:31:51.14+00	2024-05-18 15:31:51.14+00	f	\N	\N	Concepto	concepto-r6a4	\N	\N	\N	\N	\N	str
1388	2024-05-18 15:31:51.151+00	2024-05-18 15:31:51.151+00	f	\N	\N	Beneficiario	beneficiario-85co	\N	\N	\N	\N	\N	str
1389	2024-05-18 15:31:51.162+00	2024-05-18 15:31:51.162+00	f	\N	\N	Detalle	detalle-pmp6	\N	\N	\N	\N	\N	str
1390	2024-05-18 15:31:51.179+00	2024-05-18 15:31:51.179+00	f	\N	\N	Código	codigo-pier	\N	\N	\N	\N	\N	str
1391	2024-05-18 15:31:51.193+00	2024-05-18 15:31:51.193+00	f	\N	\N	Tipo	tipo-5m3k	\N	\N	\N	\N	\N	str
1392	2024-05-18 15:31:51.204+00	2024-05-18 15:31:51.204+00	f	\N	\N	Concesionario o Empresa	concesionario-o-empresa-50cn	\N	\N	\N	\N	\N	str
1393	2024-05-18 15:31:51.214+00	2024-05-18 15:31:51.214+00	f	\N	\N	Rubro	rubro	\N	\N	\N	\N	\N	str
1394	2024-05-18 15:31:51.224+00	2024-05-18 15:31:51.224+00	f	\N	\N	Valor	valor	\N	\N	\N	\N	\N	str
1395	2024-05-18 15:31:51.243+00	2024-05-18 15:31:51.243+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-5jkf	\N	\N	\N	\N	\N	str
1396	2024-05-18 15:31:51.253+00	2024-05-18 15:31:51.253+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-vbzp	\N	\N	\N	\N	\N	str
1397	2024-05-18 15:31:51.264+00	2024-05-18 15:31:51.264+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-1kmx	\N	\N	\N	\N	\N	str
1398	2024-05-18 15:31:51.274+00	2024-05-18 15:31:51.274+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-lrwt	\N	\N	\N	\N	\N	str
1399	2024-05-18 15:31:51.284+00	2024-05-18 15:31:51.284+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-35uv	\N	\N	\N	\N	\N	str
1400	2024-05-18 15:31:51.294+00	2024-05-18 15:31:51.294+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-ppdb	\N	\N	\N	\N	\N	str
1401	2024-05-18 15:31:51.308+00	2024-05-18 15:31:51.308+00	f	\N	\N	LICENCIA	licencia-yhfj	\N	\N	\N	\N	\N	str
1402	2024-05-18 15:31:51.329+00	2024-05-18 15:31:51.329+00	f	\N	\N	Institución	institucion-bwue	\N	\N	\N	\N	\N	str
1403	2024-05-18 15:31:51.342+00	2024-05-18 15:31:51.342+00	f	\N	\N	Descripción	descripcion-p2xc	\N	\N	\N	\N	\N	str
1404	2024-05-18 15:31:51.354+00	2024-05-18 15:31:51.354+00	f	\N	\N	Nombre del campo	nombre-del-campo-pi3j	\N	\N	\N	\N	\N	str
1405	2024-05-18 15:31:51.367+00	2024-05-18 15:31:51.367+00	f	\N	\N	Código	codigo-paez	\N	\N	\N	\N	\N	str
1406	2024-05-18 15:31:51.378+00	2024-05-18 15:31:51.378+00	f	\N	\N	Tipo	tipo-6adc	\N	\N	\N	\N	\N	str
1407	2024-05-18 15:31:51.391+00	2024-05-18 15:31:51.391+00	f	\N	\N	Concesionario o Empresa	concesionario-o-empresa-ivry	\N	\N	\N	\N	\N	str
1408	2024-05-18 15:31:51.404+00	2024-05-18 15:31:51.404+00	f	\N	\N	Rubro	rubro-w8gr	\N	\N	\N	\N	\N	str
1409	2024-05-18 15:31:51.416+00	2024-05-18 15:31:51.416+00	f	\N	\N	Valor	valor-zkry	\N	\N	\N	\N	\N	str
1410	2024-05-18 15:31:51.448+00	2024-05-18 15:31:51.448+00	f	\N	\N	Nombre de Empresa Pública	nombre-de-empresa-publica	\N	\N	\N	\N	\N	str
1411	2024-05-18 15:31:51.469+00	2024-05-18 15:31:51.469+00	f	\N	\N	Fecha	fecha-qu2u	\N	\N	\N	\N	\N	str
1412	2024-05-18 15:31:51.489+00	2024-05-18 15:31:51.489+00	f	\N	\N	Nombre de Informe	nombre-de-informe-lvw3	\N	\N	\N	\N	\N	str
1413	2024-05-18 15:31:51.51+00	2024-05-18 15:31:51.51+00	f	\N	\N	Enlace a Informe	enlace-a-informe-ftdg	\N	\N	\N	\N	\N	str
1414	2024-05-18 15:31:51.544+00	2024-05-18 15:31:51.544+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-ix3r	\N	\N	\N	\N	\N	str
1415	2024-05-18 15:31:51.564+00	2024-05-18 15:31:51.564+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-2u5i	\N	\N	\N	\N	\N	str
1416	2024-05-18 15:31:51.584+00	2024-05-18 15:31:51.584+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-jr3i	\N	\N	\N	\N	\N	str
1417	2024-05-18 15:31:51.608+00	2024-05-18 15:31:51.608+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-3ruz	\N	\N	\N	\N	\N	str
1418	2024-05-18 15:31:51.621+00	2024-05-18 15:31:51.621+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-p5h9	\N	\N	\N	\N	\N	str
1419	2024-05-18 15:31:51.632+00	2024-05-18 15:31:51.632+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-9dv3	\N	\N	\N	\N	\N	str
1420	2024-05-18 15:31:51.643+00	2024-05-18 15:31:51.643+00	f	\N	\N	LICENCIA	licencia-w7tl	\N	\N	\N	\N	\N	str
1421	2024-05-18 15:31:51.658+00	2024-05-18 15:31:51.658+00	f	\N	\N	Institución	institucion-022b	\N	\N	\N	\N	\N	str
1422	2024-05-18 15:31:51.665+00	2024-05-18 15:31:51.665+00	f	\N	\N	Descripción	descripcion-c888	\N	\N	\N	\N	\N	str
1423	2024-05-18 15:31:51.675+00	2024-05-18 15:31:51.675+00	f	\N	\N	Nombre del campo	nombre-del-campo-2mdy	\N	\N	\N	\N	\N	str
1424	2024-05-18 15:31:51.687+00	2024-05-18 15:31:51.687+00	f	\N	\N	Nombre de Empresa Pública	nombre-de-empresa-publica-twrn	\N	\N	\N	\N	\N	str
1425	2024-05-18 15:31:51.697+00	2024-05-18 15:31:51.697+00	f	\N	\N	Fecha	fecha-gwyw	\N	\N	\N	\N	\N	str
1426	2024-05-18 15:31:51.708+00	2024-05-18 15:31:51.708+00	f	\N	\N	Nombre de Informe	nombre-de-informe-f2hg	\N	\N	\N	\N	\N	str
1427	2024-05-18 15:31:51.718+00	2024-05-18 15:31:51.718+00	f	\N	\N	Enlace a Informe	enlace-a-informe-io4f	\N	\N	\N	\N	\N	str
1428	2024-05-18 15:31:51.735+00	2024-05-18 15:31:51.735+00	f	\N	\N	Fecha	fecha-dlf2	\N	\N	\N	\N	\N	str
1429	2024-05-18 15:31:51.743+00	2024-05-18 15:31:51.743+00	f	\N	\N	Empresa Pública	empresa-publica	\N	\N	\N	\N	\N	str
1430	2024-05-18 15:31:51.753+00	2024-05-18 15:31:51.753+00	f	\N	\N	Tipo	tipo-he45	\N	\N	\N	\N	\N	str
1431	2024-05-18 15:31:51.763+00	2024-05-18 15:31:51.763+00	f	\N	\N	Título	titulo-dvey	\N	\N	\N	\N	\N	str
1432	2024-05-18 15:31:51.773+00	2024-05-18 15:31:51.773+00	f	\N	\N	Enlace Acta	enlace-acta-uhgb	\N	\N	\N	\N	\N	str
1433	2024-05-18 15:31:51.791+00	2024-05-18 15:31:51.791+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-u8uv	\N	\N	\N	\N	\N	str
1434	2024-05-18 15:31:51.799+00	2024-05-18 15:31:51.799+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-5eoh	\N	\N	\N	\N	\N	str
1435	2024-05-18 15:31:51.809+00	2024-05-18 15:31:51.809+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-pkmu	\N	\N	\N	\N	\N	str
1436	2024-05-18 15:31:51.82+00	2024-05-18 15:31:51.82+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-yf0h	\N	\N	\N	\N	\N	str
1437	2024-05-18 15:31:51.833+00	2024-05-18 15:31:51.833+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-twc8	\N	\N	\N	\N	\N	str
1438	2024-05-18 15:31:51.847+00	2024-05-18 15:31:51.847+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-gg5s	\N	\N	\N	\N	\N	str
1439	2024-05-18 15:31:51.861+00	2024-05-18 15:31:51.861+00	f	\N	\N	LICENCIA	licencia-0316	\N	\N	\N	\N	\N	str
1440	2024-05-18 15:31:51.881+00	2024-05-18 15:31:51.881+00	f	\N	\N	Institución	institucion-cg7y	\N	\N	\N	\N	\N	str
1441	2024-05-18 15:31:51.897+00	2024-05-18 15:31:51.897+00	f	\N	\N	Descripción	descripcion-023v	\N	\N	\N	\N	\N	str
1442	2024-05-18 15:31:51.909+00	2024-05-18 15:31:51.909+00	f	\N	\N	Nombre del campo	nombre-del-campo-6y4m	\N	\N	\N	\N	\N	str
1443	2024-05-18 15:31:51.925+00	2024-05-18 15:31:51.925+00	f	\N	\N	Fecha	fecha-b8yf	\N	\N	\N	\N	\N	str
1444	2024-05-18 15:31:51.936+00	2024-05-18 15:31:51.936+00	f	\N	\N	Empresa Pública	empresa-publica-hx4q	\N	\N	\N	\N	\N	str
1445	2024-05-18 15:31:51.947+00	2024-05-18 15:31:51.947+00	f	\N	\N	Tipo	tipo-6zbn	\N	\N	\N	\N	\N	str
1446	2024-05-18 15:31:51.957+00	2024-05-18 15:31:51.957+00	f	\N	\N	Título	titulo-5xi6	\N	\N	\N	\N	\N	str
1447	2024-05-18 15:31:51.967+00	2024-05-18 15:31:51.967+00	f	\N	\N	Enlace Acta	enlace-acta-mqod	\N	\N	\N	\N	\N	str
1448	2024-05-18 15:31:51.983+00	2024-05-18 15:31:51.983+00	f	\N	\N	Fecha	fecha-f6lu	\N	\N	\N	\N	\N	str
1449	2024-05-18 15:31:51.994+00	2024-05-18 15:31:51.994+00	f	\N	\N	Empresa Pública	empresa-publica-922o	\N	\N	\N	\N	\N	str
1450	2024-05-18 15:31:52.003+00	2024-05-18 15:31:52.003+00	f	\N	\N	Persona natural o jurídica que solicita	persona-natural-o-juridica-que-solicita	\N	\N	\N	\N	\N	str
1451	2024-05-18 15:31:52.014+00	2024-05-18 15:31:52.014+00	f	\N	\N	Tipo	tipo-hnju	\N	\N	\N	\N	\N	str
1452	2024-05-18 15:31:52.024+00	2024-05-18 15:31:52.024+00	f	\N	\N	Número	numero	\N	\N	\N	\N	\N	str
1453	2024-05-18 15:31:52.034+00	2024-05-18 15:31:52.034+00	f	\N	\N	Detalle	detalle-cu4r	\N	\N	\N	\N	\N	str
1454	2024-05-18 15:31:52.045+00	2024-05-18 15:31:52.045+00	f	\N	\N	Estado	estado-sdim	\N	\N	\N	\N	\N	str
1455	2024-05-18 15:31:52.056+00	2024-05-18 15:31:52.056+00	f	\N	\N	Fecha de resolución	fecha-de-resolucion-b2e3	\N	\N	\N	\N	\N	str
1456	2024-05-18 15:31:52.068+00	2024-05-18 15:31:52.068+00	f	\N	\N	Enlace Documentación	enlace-documentacion	\N	\N	\N	\N	\N	str
1457	2024-05-18 15:31:52.087+00	2024-05-18 15:31:52.087+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-ctci	\N	\N	\N	\N	\N	str
1458	2024-05-18 15:31:52.098+00	2024-05-18 15:31:52.098+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-abk0	\N	\N	\N	\N	\N	str
1459	2024-05-18 15:31:52.11+00	2024-05-18 15:31:52.11+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-en2z	\N	\N	\N	\N	\N	str
1460	2024-05-18 15:31:52.119+00	2024-05-18 15:31:52.119+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-ar62	\N	\N	\N	\N	\N	str
1461	2024-05-18 15:31:52.129+00	2024-05-18 15:31:52.13+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-ccxr	\N	\N	\N	\N	\N	str
1462	2024-05-18 15:31:52.14+00	2024-05-18 15:31:52.14+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-kcc8	\N	\N	\N	\N	\N	str
1463	2024-05-18 15:31:52.151+00	2024-05-18 15:31:52.151+00	f	\N	\N	LICENCIA	licencia-dv5p	\N	\N	\N	\N	\N	str
1464	2024-05-18 15:31:52.168+00	2024-05-18 15:31:52.168+00	f	\N	\N	Institución	institucion-bu3m	\N	\N	\N	\N	\N	str
1465	2024-05-18 15:31:52.178+00	2024-05-18 15:31:52.178+00	f	\N	\N	Descripción	descripcion-vyrz	\N	\N	\N	\N	\N	str
1466	2024-05-18 15:31:52.189+00	2024-05-18 15:31:52.189+00	f	\N	\N	Nombre del campo	nombre-del-campo-exbq	\N	\N	\N	\N	\N	str
1467	2024-05-18 15:31:52.199+00	2024-05-18 15:31:52.199+00	f	\N	\N	Fecha	fecha-t975	\N	\N	\N	\N	\N	str
1468	2024-05-18 15:31:52.211+00	2024-05-18 15:31:52.211+00	f	\N	\N	Empresa Pública	empresa-publica-h2m3	\N	\N	\N	\N	\N	str
1469	2024-05-18 15:31:52.221+00	2024-05-18 15:31:52.221+00	f	\N	\N	Persona natural o jurídica que solicita	persona-natural-o-juridica-que-solicita-c68x	\N	\N	\N	\N	\N	str
1470	2024-05-18 15:31:52.232+00	2024-05-18 15:31:52.232+00	f	\N	\N	Tipo	tipo-d4oa	\N	\N	\N	\N	\N	str
1471	2024-05-18 15:31:52.243+00	2024-05-18 15:31:52.243+00	f	\N	\N	Número	numero-vnvr	\N	\N	\N	\N	\N	str
1472	2024-05-18 15:31:52.254+00	2024-05-18 15:31:52.254+00	f	\N	\N	Detalle	detalle-tspo	\N	\N	\N	\N	\N	str
1473	2024-05-18 15:31:52.264+00	2024-05-18 15:31:52.264+00	f	\N	\N	Estado	estado-nfjj	\N	\N	\N	\N	\N	str
1474	2024-05-18 15:31:52.276+00	2024-05-18 15:31:52.276+00	f	\N	\N	Fecha de resolución	fecha-de-resolucion-pkq9	\N	\N	\N	\N	\N	str
1475	2024-05-18 15:31:52.286+00	2024-05-18 15:31:52.286+00	f	\N	\N	Enlace Documentación	enlace-documentacion-6o1o	\N	\N	\N	\N	\N	str
1476	2024-05-18 15:31:52.307+00	2024-05-18 15:31:52.307+00	f	\N	\N	Nombres y apellidos	nombres-y-apellidos-el46	\N	\N	\N	\N	\N	str
1477	2024-05-18 15:31:52.318+00	2024-05-18 15:31:52.318+00	f	\N	\N	Puesto institucional	puesto-institucional-1fvm	\N	\N	\N	\N	\N	str
1478	2024-05-18 15:31:52.329+00	2024-05-18 15:31:52.329+00	f	\N	\N	Tipo	tipo-tvee	\N	\N	\N	\N	\N	str
1479	2024-05-18 15:31:52.337+00	2024-05-18 15:31:52.337+00	f	\N	\N	Fecha de inicio del viaje	fecha-de-inicio-del-viaje	\N	\N	\N	\N	\N	str
1480	2024-05-18 15:31:52.346+00	2024-05-18 15:31:52.346+00	f	\N	\N	Fecha de fin del viaje	fecha-de-fin-del-viaje	\N	\N	\N	\N	\N	str
1481	2024-05-18 15:31:52.355+00	2024-05-18 15:31:52.355+00	f	\N	\N	Motivo del viaje	motivo-del-viaje	\N	\N	\N	\N	\N	str
1482	2024-05-18 15:31:52.364+00	2024-05-18 15:31:52.364+00	f	\N	\N	Valor del viático	valor-del-viatico	\N	\N	\N	\N	\N	str
1483	2024-05-18 15:31:52.373+00	2024-05-18 15:31:52.373+00	f	\N	\N	Enlace para descargar el informe y justificativos	enlace-para-descargar-el-informe-y-justificativos	\N	\N	\N	\N	\N	str
1484	2024-05-18 15:31:52.391+00	2024-05-18 15:31:52.391+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN	fecha-actualizacion-de-la-informacion-u3qj	\N	\N	\N	\N	\N	str
1485	2024-05-18 15:31:52.401+00	2024-05-18 15:31:52.401+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN	periodicidad-de-actualizacion-de-la-informacion-8c56	\N	\N	\N	\N	\N	str
1486	2024-05-18 15:31:52.412+00	2024-05-18 15:31:52.412+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN	unidad-poseedora-de-la-informacion-xmh4	\N	\N	\N	\N	\N	str
1716	2024-07-01 04:38:57.986+00	2024-07-01 04:38:57.986+00	f	\N	\N	Cuenta	cuenta-kkub	\N	\N	\N	\N	\N	str
1487	2024-05-18 15:31:52.423+00	2024-05-18 15:31:52.423+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	persona-responsable-de-la-unidad-poseedora-de-la-informacion-z7e1	\N	\N	\N	\N	\N	str
1488	2024-05-18 15:31:52.434+00	2024-05-18 15:31:52.434+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-j9wc	\N	\N	\N	\N	\N	str
1489	2024-05-18 15:31:52.446+00	2024-05-18 15:31:52.446+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-5917	\N	\N	\N	\N	\N	str
1490	2024-05-18 15:31:52.458+00	2024-05-18 15:31:52.458+00	f	\N	\N	LICENCIA	licencia-ugyf	\N	\N	\N	\N	\N	str
1491	2024-05-18 15:31:52.468+00	2024-05-18 15:31:52.468+00	f	\N	\N	ENLACE PARA DESCARGAR EL REPORTE CONSOLIDADO DE GASTOS DE VIÁTICOS NACIONALES E INTERNACIONALES	enlace-para-descargar-el-reporte-consolidado-de-gastos-de-viaticos-nacionales-e-internacionales	\N	\N	\N	\N	\N	str
1492	2024-05-18 15:31:52.487+00	2024-05-18 15:31:52.487+00	f	\N	\N	Institución	institucion-vusb	\N	\N	\N	\N	\N	str
1493	2024-05-18 15:31:52.498+00	2024-05-18 15:31:52.498+00	f	\N	\N	Descripción	descripcion-73q8	\N	\N	\N	\N	\N	str
1494	2024-05-18 15:31:52.51+00	2024-05-18 15:31:52.51+00	f	\N	\N	Nombre del campo	nombre-del-campo-n275	\N	\N	\N	\N	\N	str
1495	2024-05-18 15:31:52.52+00	2024-05-18 15:31:52.52+00	f	\N	\N	Nombres y Apellidos	nombres-y-apellidos-64j0	\N	\N	\N	\N	\N	str
1496	2024-05-18 15:31:52.531+00	2024-05-18 15:31:52.531+00	f	\N	\N	Puesto Institucional	puesto-institucional-xi98	\N	\N	\N	\N	\N	str
1497	2024-05-18 15:31:52.544+00	2024-05-18 15:31:52.544+00	f	\N	\N	Tipo	tipo-gl28	\N	\N	\N	\N	\N	str
1498	2024-05-18 15:31:52.555+00	2024-05-18 15:31:52.555+00	f	\N	\N	Fecha de inicio del viaje	fecha-de-inicio-del-viaje-vulm	\N	\N	\N	\N	\N	str
1499	2024-05-18 15:31:52.567+00	2024-05-18 15:31:52.567+00	f	\N	\N	Fecha de fin del viaje	fecha-de-fin-del-viaje-b0ln	\N	\N	\N	\N	\N	str
1500	2024-05-18 15:31:52.58+00	2024-05-18 15:31:52.58+00	f	\N	\N	Motivo del viaje	motivo-del-viaje-xxdl	\N	\N	\N	\N	\N	str
1501	2024-05-18 15:31:52.593+00	2024-05-18 15:31:52.593+00	f	\N	\N	Valor del viático	valor-del-viatico-1mqw	\N	\N	\N	\N	\N	str
1502	2024-05-18 15:31:52.604+00	2024-05-18 15:31:52.604+00	f	\N	\N	Enlace para descargar el informe y justificativo	enlace-para-descargar-el-informe-y-justificativo	\N	\N	\N	\N	\N	str
1503	2024-05-18 15:31:52.628+00	2024-05-18 15:31:52.628+00	f	\N	\N	Nombres y Apellidos	nombres-y-apellidos-j2to	\N	\N	\N	\N	\N	str
1504	2024-05-18 15:31:52.64+00	2024-05-18 15:31:52.64+00	f	\N	\N	Puesto institucional	puesto-institucional-f9xa	\N	\N	\N	\N	\N	str
1505	2024-05-18 15:31:52.652+00	2024-05-18 15:31:52.652+00	f	\N	\N	Asunto	asunto-khrr	\N	\N	\N	\N	\N	str
1506	2024-05-18 15:31:52.663+00	2024-05-18 15:31:52.663+00	f	\N	\N	Fecha de la audiencia/ reunión	fecha-de-la-audiencia-reunion	\N	\N	\N	\N	\N	str
1507	2024-05-18 15:31:52.675+00	2024-05-18 15:31:52.675+00	f	\N	\N	Modalidad	modalidad	\N	\N	\N	\N	\N	str
1508	2024-05-18 15:31:52.685+00	2024-05-18 15:31:52.685+00	f	\N	\N	Lugar	lugar	\N	\N	\N	\N	\N	str
1509	2024-05-18 15:31:52.696+00	2024-05-18 15:31:52.696+00	f	\N	\N	Descripción de la audiencia/reunión	descripcion-de-la-audienciareunion	\N	\N	\N	\N	\N	str
1510	2024-05-18 15:31:52.732+00	2024-05-18 15:31:52.732+00	f	\N	\N	Duración	duracion	\N	\N	\N	\N	\N	str
1511	2024-05-18 15:31:52.758+00	2024-05-18 15:31:52.758+00	f	\N	\N	Nomnre de persona (s) externa (s)	nomnre-de-persona-s-externa-s	\N	\N	\N	\N	\N	str
1512	2024-05-18 15:31:52.79+00	2024-05-18 15:31:52.79+00	f	\N	\N	Institución externa	institucion-externa	\N	\N	\N	\N	\N	str
1513	2024-05-18 15:31:52.799+00	2024-05-18 15:31:52.799+00	f	\N	\N	Enlace para descargar el registro de asistencia de las personas que participaron en la reunión o audiencia	enlace-para-descargar-el-registro-de-asistencia-de-las-personas-que-participaron-en-la-reunion-o-audiencia	\N	\N	\N	\N	\N	str
1514	2024-05-18 15:31:52.82+00	2024-05-18 15:31:52.82+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-1r7k	\N	\N	\N	\N	\N	str
1515	2024-05-18 15:31:52.831+00	2024-05-18 15:31:52.831+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-ba7e	\N	\N	\N	\N	\N	str
1516	2024-05-18 15:31:52.841+00	2024-05-18 15:31:52.841+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-b4sc	\N	\N	\N	\N	\N	str
1517	2024-05-18 15:31:52.852+00	2024-05-18 15:31:52.852+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-m4ev	\N	\N	\N	\N	\N	str
1518	2024-05-18 15:31:52.862+00	2024-05-18 15:31:52.862+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-w2fl	\N	\N	\N	\N	\N	str
1519	2024-05-18 15:31:52.872+00	2024-05-18 15:31:52.872+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-o25r	\N	\N	\N	\N	\N	str
1520	2024-05-18 15:31:52.881+00	2024-05-18 15:31:52.881+00	f	\N	\N	LICENCIA	licencia-w0kc	\N	\N	\N	\N	\N	str
1521	2024-05-18 15:31:52.897+00	2024-05-18 15:31:52.897+00	f	\N	\N	Institución	institucion-j45b	\N	\N	\N	\N	\N	str
1522	2024-05-18 15:31:52.907+00	2024-05-18 15:31:52.907+00	f	\N	\N	Descripción	descripcion-wh8m	\N	\N	\N	\N	\N	str
1523	2024-05-18 15:31:52.917+00	2024-05-18 15:31:52.917+00	f	\N	\N	Nombre del campo	nombre-del-campo-1l6w	\N	\N	\N	\N	\N	str
1524	2024-05-18 15:31:52.928+00	2024-05-18 15:31:52.928+00	f	\N	\N	Nombres y Apellidos	nombres-y-apellidos-rwmw	\N	\N	\N	\N	\N	str
1525	2024-05-18 15:31:52.938+00	2024-05-18 15:31:52.938+00	f	\N	\N	Puesto institucional	puesto-institucional-wwwt	\N	\N	\N	\N	\N	str
1526	2024-05-18 15:31:52.948+00	2024-05-18 15:31:52.948+00	f	\N	\N	Asunto	asunto-ssc4	\N	\N	\N	\N	\N	str
1527	2024-05-18 15:31:52.956+00	2024-05-18 15:31:52.956+00	f	\N	\N	Fecha de la reunión	fecha-de-la-reunion	\N	\N	\N	\N	\N	str
1528	2024-05-18 15:31:52.966+00	2024-05-18 15:31:52.966+00	f	\N	\N	Modalidad	modalidad-0t9w	\N	\N	\N	\N	\N	str
1529	2024-05-18 15:31:52.976+00	2024-05-18 15:31:52.976+00	f	\N	\N	Lugar	lugar-8nh7	\N	\N	\N	\N	\N	str
1530	2024-05-18 15:31:52.984+00	2024-05-18 15:31:52.984+00	f	\N	\N	Descripción de la reunión	descripcion-de-la-reunion	\N	\N	\N	\N	\N	str
1531	2024-05-18 15:31:52.993+00	2024-05-18 15:31:52.993+00	f	\N	\N	Duración de la reunión	duracion-de-la-reunion	\N	\N	\N	\N	\N	str
1532	2024-05-18 15:31:53.001+00	2024-05-18 15:31:53.001+00	f	\N	\N	Persona/as externa	personaas-externa	\N	\N	\N	\N	\N	str
1533	2024-05-18 15:31:53.012+00	2024-05-18 15:31:53.012+00	f	\N	\N	Institución externa	institucion-externa-71y3	\N	\N	\N	\N	\N	str
1534	2024-05-18 15:31:53.02+00	2024-05-18 15:31:53.02+00	f	\N	\N	Enlace para descargar el registro de asistencia de las personas que participaron en las reuniones o audiencias	enlace-para-descargar-el-registro-de-asistencia-de-las-personas-que-participaron-en-las-reuniones-o-audiencias	\N	\N	\N	\N	\N	str
1535	2024-05-18 15:31:53.039+00	2024-05-18 15:31:53.039+00	f	\N	\N	Grupo específico	grupo-especifico	\N	\N	\N	\N	\N	str
1536	2024-05-18 15:31:53.048+00	2024-05-18 15:31:53.048+00	f	\N	\N	Nombre de política pública	nombre-de-politica-publica	\N	\N	\N	\N	\N	str
1537	2024-05-18 15:31:53.06+00	2024-05-18 15:31:53.06+00	f	\N	\N	Fase	fase-3d6y	\N	\N	\N	\N	\N	str
1538	2024-05-18 15:31:53.07+00	2024-05-18 15:31:53.07+00	f	\N	\N	Fecha	fecha-6noe	\N	\N	\N	\N	\N	str
1539	2024-05-18 15:31:53.08+00	2024-05-18 15:31:53.08+00	f	\N	\N	Enlace a informe	enlace-a-informe-iz14	\N	\N	\N	\N	\N	str
1540	2024-05-18 15:31:53.105+00	2024-05-18 15:31:53.105+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN	fecha-actualizacion-de-la-informacion-9bqx	\N	\N	\N	\N	\N	str
1541	2024-05-18 15:31:53.119+00	2024-05-18 15:31:53.119+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN	periodicidad-de-actualizacion-de-la-informacion-e9kv	\N	\N	\N	\N	\N	str
1542	2024-05-18 15:31:53.134+00	2024-05-18 15:31:53.134+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN	unidad-poseedora-de-la-informacion-ys6m	\N	\N	\N	\N	\N	str
1543	2024-05-18 15:31:53.149+00	2024-05-18 15:31:53.149+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	persona-responsable-de-la-unidad-poseedora-de-la-informacion-x5ub	\N	\N	\N	\N	\N	str
1544	2024-05-18 15:31:53.161+00	2024-05-18 15:31:53.161+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-pk2j	\N	\N	\N	\N	\N	str
1717	2024-07-01 04:38:57.995+00	2024-07-01 04:38:57.995+00	f	\N	\N	Código Subcuenta	codigo-subcuenta-1yej	\N	\N	\N	\N	\N	str
1545	2024-05-18 15:31:53.174+00	2024-05-18 15:31:53.174+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-h8in	\N	\N	\N	\N	\N	str
1546	2024-05-18 15:31:53.187+00	2024-05-18 15:31:53.187+00	f	\N	\N	LICENCIA	licencia-37au	\N	\N	\N	\N	\N	str
1547	2024-05-18 15:31:53.205+00	2024-05-18 15:31:53.205+00	f	\N	\N	ENLACE PARA DESCARGAR LAS ACCCIONES Y BUENAS PRÁCTICAS DE ACTORES SOCIALES E INTERINSTITUCIONALES QUE VIGILAN EL CUMPLIMIENTO DE LA POLÍTICA PÚBLICA	enlace-para-descargar-las-accciones-y-buenas-practicas-de-actores-sociales-e-interinstitucionales-que-vigilan-el-cumplimiento-de-la-politica-publica	\N	\N	\N	\N	\N	str
1548	2024-05-18 15:31:53.224+00	2024-05-18 15:31:53.224+00	f	\N	\N	Institución	institucion-j1i3	\N	\N	\N	\N	\N	str
1549	2024-05-18 15:31:53.235+00	2024-05-18 15:31:53.235+00	f	\N	\N	Descripción	descripcion-5848	\N	\N	\N	\N	\N	str
1550	2024-05-18 15:31:53.248+00	2024-05-18 15:31:53.249+00	f	\N	\N	Nombre del campo	nombre-del-campo-v0yd	\N	\N	\N	\N	\N	str
1551	2024-05-18 15:31:53.262+00	2024-05-18 15:31:53.262+00	f	\N	\N	Grupo específico	grupo-especifico-ke4i	\N	\N	\N	\N	\N	str
1552	2024-05-18 15:31:53.274+00	2024-05-18 15:31:53.274+00	f	\N	\N	Nombre de política pública	nombre-de-politica-publica-cva3	\N	\N	\N	\N	\N	str
1553	2024-05-18 15:31:53.285+00	2024-05-18 15:31:53.285+00	f	\N	\N	Fase	fase-964v	\N	\N	\N	\N	\N	str
1554	2024-05-18 15:31:53.297+00	2024-05-18 15:31:53.297+00	f	\N	\N	Fecha	fecha-9k72	\N	\N	\N	\N	\N	str
1555	2024-05-18 15:31:53.312+00	2024-05-18 15:31:53.312+00	f	\N	\N	Enlace a informe	enlace-a-informe-pwzo	\N	\N	\N	\N	\N	str
1556	2024-05-18 15:31:53.333+00	2024-05-18 15:31:53.333+00	f	\N	\N	Tipo de Contrato	tipo-de-contrato	\N	\N	\N	\N	\N	str
1557	2024-05-18 15:31:53.344+00	2024-05-18 15:31:53.344+00	f	\N	\N	Objeto 	objeto-g9ww	\N	\N	\N	\N	\N	str
1558	2024-05-18 15:31:53.353+00	2024-05-18 15:31:53.353+00	f	\N	\N	Fecha de suscripción o renovación	fecha-de-suscripcion-o-renovacion	\N	\N	\N	\N	\N	str
1559	2024-05-18 15:31:53.361+00	2024-05-18 15:31:53.361+00	f	\N	\N	Nombre Deudor	nombre-deudor	\N	\N	\N	\N	\N	str
1560	2024-05-18 15:31:53.372+00	2024-05-18 15:31:53.372+00	f	\N	\N	Nombre Acreedor	nombre-acreedor	\N	\N	\N	\N	\N	str
1561	2024-05-18 15:31:53.382+00	2024-05-18 15:31:53.382+00	f	\N	\N	Nombre Ejecutor	nombre-ejecutor	\N	\N	\N	\N	\N	str
1562	2024-05-18 15:31:53.394+00	2024-05-18 15:31:53.394+00	f	\N	\N	Tasa de Interés (%)	tasa-de-interes	\N	\N	\N	\N	\N	str
1563	2024-05-18 15:31:53.407+00	2024-05-18 15:31:53.407+00	f	\N	\N	Plazo	plazo-5sxf	\N	\N	\N	\N	\N	str
1564	2024-05-18 15:31:53.417+00	2024-05-18 15:31:53.417+00	f	\N	\N	Fondos con los que se cancelará la obligación crediticia	fondos-con-los-que-se-cancelara-la-obligacion-crediticia	\N	\N	\N	\N	\N	str
1565	2024-05-18 15:31:53.426+00	2024-05-18 15:31:53.426+00	f	\N	\N	Enlace para descargar el contrato de crédito externo o interno	enlace-para-descargar-el-contrato-de-credito-externo-o-interno	\N	\N	\N	\N	\N	str
1566	2024-05-18 15:31:53.435+00	2024-05-18 15:31:53.435+00	f	\N	\N	Monto del préstamo o contrato	monto-del-prestamo-o-contrato	\N	\N	\N	\N	\N	str
1567	2024-05-18 15:31:53.445+00	2024-05-18 15:31:53.445+00	f	\N	\N	Desembolsos efectuados	desembolsos-efectuados	\N	\N	\N	\N	\N	str
1568	2024-05-18 15:31:53.453+00	2024-05-18 15:31:53.453+00	f	\N	\N	Desembolsos por efectuar	desembolsos-por-efectuar	\N	\N	\N	\N	\N	str
1569	2024-05-18 15:31:53.47+00	2024-05-18 15:31:53.47+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN	fecha-actualizacion-de-la-informacion-hdge	\N	\N	\N	\N	\N	str
1570	2024-05-18 15:31:53.482+00	2024-05-18 15:31:53.482+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN	periodicidad-de-actualizacion-de-la-informacion-zptv	\N	\N	\N	\N	\N	str
1571	2024-05-18 15:31:53.494+00	2024-05-18 15:31:53.494+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN	unidad-poseedora-de-la-informacion-a0kq	\N	\N	\N	\N	\N	str
1572	2024-05-18 15:31:53.505+00	2024-05-18 15:31:53.505+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	persona-responsable-de-la-unidad-poseedora-de-la-informacion-6tdg	\N	\N	\N	\N	\N	str
1573	2024-05-18 15:31:53.517+00	2024-05-18 15:31:53.517+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-vf7g	\N	\N	\N	\N	\N	str
1574	2024-05-18 15:31:53.528+00	2024-05-18 15:31:53.528+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-sz43	\N	\N	\N	\N	\N	str
1575	2024-05-18 15:31:53.537+00	2024-05-18 15:31:53.537+00	f	\N	\N	LICENCIA	licencia-75ak	\N	\N	\N	\N	\N	str
1576	2024-05-18 15:31:53.55+00	2024-05-18 15:31:53.55+00	f	\N	\N	Institución	institucion-gx43	\N	\N	\N	\N	\N	str
1577	2024-05-18 15:31:53.559+00	2024-05-18 15:31:53.559+00	f	\N	\N	Descripción	descripcion-o9v2	\N	\N	\N	\N	\N	str
1578	2024-05-18 15:31:53.569+00	2024-05-18 15:31:53.569+00	f	\N	\N	Nombre del campo	nombre-del-campo-ixn3	\N	\N	\N	\N	\N	str
1579	2024-05-18 15:31:53.578+00	2024-05-18 15:31:53.579+00	f	\N	\N	Tipo de Contrato	tipo-de-contrato-fjt9	\N	\N	\N	\N	\N	str
1580	2024-05-18 15:31:53.587+00	2024-05-18 15:31:53.587+00	f	\N	\N	Objeto 	objeto-25ev	\N	\N	\N	\N	\N	str
1581	2024-05-18 15:31:53.597+00	2024-05-18 15:31:53.597+00	f	\N	\N	Fecha de suscripción o renovación	fecha-de-suscripcion-o-renovacion-18pj	\N	\N	\N	\N	\N	str
1582	2024-05-18 15:31:53.604+00	2024-05-18 15:31:53.604+00	f	\N	\N	Nombre del deudor	nombre-del-deudor	\N	\N	\N	\N	\N	str
1583	2024-05-18 15:31:53.613+00	2024-05-18 15:31:53.613+00	f	\N	\N	Nombre del acreedor	nombre-del-acreedor	\N	\N	\N	\N	\N	str
1584	2024-05-18 15:31:53.62+00	2024-05-18 15:31:53.62+00	f	\N	\N	Nombre del ejecutor	nombre-del-ejecutor	\N	\N	\N	\N	\N	str
1585	2024-05-18 15:31:53.631+00	2024-05-18 15:31:53.631+00	f	\N	\N	Tasa de Interés (%)	tasa-de-interes-shb1	\N	\N	\N	\N	\N	str
1586	2024-05-18 15:31:53.641+00	2024-05-18 15:31:53.641+00	f	\N	\N	Plazo	plazo-kwpo	\N	\N	\N	\N	\N	str
1587	2024-05-18 15:31:53.651+00	2024-05-18 15:31:53.651+00	f	\N	\N	Fondos con los que se cancelará la obligación crediticia	fondos-con-los-que-se-cancelara-la-obligacion-crediticia-z4jz	\N	\N	\N	\N	\N	str
1588	2024-05-18 15:31:53.664+00	2024-05-18 15:31:53.664+00	f	\N	\N	Enlace para descargar el contrato de crédito externo o interno	enlace-para-descargar-el-contrato-de-credito-externo-o-interno-wxiu	\N	\N	\N	\N	\N	str
1589	2024-05-18 15:31:53.673+00	2024-05-18 15:31:53.673+00	f	\N	\N	Monto del préstamo o contrato	monto-del-prestamo-o-contrato-nawe	\N	\N	\N	\N	\N	str
1590	2024-05-18 15:31:53.684+00	2024-05-18 15:31:53.684+00	f	\N	\N	Desembolsos efectuados	desembolsos-efectuados-19rk	\N	\N	\N	\N	\N	str
1591	2024-05-18 15:31:53.695+00	2024-05-18 15:31:53.695+00	f	\N	\N	Desembolsos por efectuar	desembolsos-por-efectuar-kq3p	\N	\N	\N	\N	\N	str
1592	2024-05-18 15:31:53.716+00	2024-05-18 15:31:53.716+00	f	\N	\N	Denominación del servicio público que se brinda	denominacion-del-servicio-publico-que-se-brinda-wepf	\N	\N	\N	\N	\N	str
1593	2024-05-18 15:31:53.727+00	2024-05-18 15:31:53.727+00	f	\N	\N	Enlace para acceder al reporte del servicio	enlace-para-acceder-al-reporte-del-servicio-jwfj	\N	\N	\N	\N	\N	str
1594	2024-05-18 15:31:53.742+00	2024-05-18 15:31:53.742+00	f	\N	\N	Número de personas que acceden mensualmente al servicio institucional	numero-de-personas-que-acceden-mensualmente-al-servicio-institucional-nik9	\N	\N	\N	\N	\N	str
1595	2024-05-18 15:31:53.754+00	2024-05-18 15:31:53.754+00	f	\N	\N	Enlace para descargar el formulario o formato del servicio (impreso) / Correo electrónico para solicitar el servicio	enlace-para-descargar-el-formulario-o-formato-del-servicio-impreso-correo-electronico-para-solicitar-el-servicio-r5sg	\N	\N	\N	\N	\N	str
1596	2024-05-18 15:31:53.766+00	2024-05-18 15:31:53.766+00	f	\N	\N	Enlace para el servicio por internet (en línea)	enlace-para-el-servicio-por-internet-en-linea-17o2	\N	\N	\N	\N	\N	str
1597	2024-05-18 15:31:53.776+00	2024-05-18 15:31:53.776+00	f	\N	\N	Porcentaje de satisfacción sobre el uso del servicio	porcentaje-de-satisfaccion-sobre-el-uso-del-servicio-3mx7	\N	\N	\N	\N	\N	str
1598	2024-05-18 15:31:53.794+00	2024-05-18 15:31:53.794+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN	fecha-actualizacion-de-la-informacion-ifs2	\N	\N	\N	\N	\N	str
1599	2024-05-18 15:31:53.805+00	2024-05-18 15:31:53.805+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN	periodicidad-de-actualizacion-de-la-informacion-3te6	\N	\N	\N	\N	\N	str
1600	2024-05-18 15:31:53.816+00	2024-05-18 15:31:53.816+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACION	unidad-poseedora-de-la-informacion-kf0j	\N	\N	\N	\N	\N	str
1601	2024-05-18 15:31:53.827+00	2024-05-18 15:31:53.827+00	f	\N	\N	PERSONAL RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	personal-responsable-de-la-unidad-poseedora-de-la-informacion-we32	\N	\N	\N	\N	\N	str
1602	2024-05-18 15:31:53.838+00	2024-05-18 15:31:53.838+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-1pq6	\N	\N	\N	\N	\N	str
1603	2024-05-18 15:31:53.85+00	2024-05-18 15:31:53.85+00	f	\N	\N	NÚMERO TELEFÓNICO DEL O LA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	numero-telefonico-del-o-la-responsable-de-la-unidad-poseedora-de-la-informacion-s9iu	\N	\N	\N	\N	\N	str
1604	2024-05-18 15:31:53.862+00	2024-05-18 15:31:53.862+00	f	\N	\N	ENLACE A PORTAL ÚNICO DE TRÁMITES CIUDADANOS	enlace-a-portal-unico-de-tramites-ciudadanos-z1io	\N	\N	\N	\N	\N	str
1605	2024-05-18 15:31:53.875+00	2024-05-18 15:31:53.875+00	f	\N	\N	LICENCIA	licencia-pg6t	\N	\N	\N	\N	\N	str
1606	2024-05-18 15:31:53.893+00	2024-05-18 15:31:53.893+00	f	\N	\N	Institución	institucion-dq4n	\N	\N	\N	\N	\N	str
1607	2024-05-18 15:31:53.905+00	2024-05-18 15:31:53.905+00	f	\N	\N	Descripción 	descripcion-wllv	\N	\N	\N	\N	\N	str
1608	2024-05-18 15:31:53.916+00	2024-05-18 15:31:53.916+00	f	\N	\N	Nombre del Campo	nombre-del-campo-43d7	\N	\N	\N	\N	\N	str
1609	2024-05-18 15:31:53.926+00	2024-05-18 15:31:53.926+00	f	\N	\N	Denominación del servicio público que se brinda	denominacion-del-servicio-publico-que-se-brinda-tirj	\N	\N	\N	\N	\N	str
1610	2024-05-18 15:31:53.939+00	2024-05-18 15:31:53.939+00	f	\N	\N	Enlace para acceder al reporte del servicio	enlace-para-acceder-al-reporte-del-servicio-frwg	\N	\N	\N	\N	\N	str
1611	2024-05-18 15:31:53.949+00	2024-05-18 15:31:53.949+00	f	\N	\N	Número de personas que acceden mensualmente al servicio institucional	numero-de-personas-que-acceden-mensualmente-al-servicio-institucional-h40k	\N	\N	\N	\N	\N	str
1612	2024-05-18 15:31:53.96+00	2024-05-18 15:31:53.96+00	f	\N	\N	Enlace para descargar el formulario o formato del servicio (impreso) / Correo electrónico para solicitar el servicio	enlace-para-descargar-el-formulario-o-formato-del-servicio-impreso-correo-electronico-para-solicitar-el-servicio-r9ly	\N	\N	\N	\N	\N	str
1613	2024-05-18 15:31:53.969+00	2024-05-18 15:31:53.969+00	f	\N	\N	Enlace para el servicio por internet (en línea)	enlace-para-el-servicio-por-internet-en-linea-8agd	\N	\N	\N	\N	\N	str
1614	2024-05-18 15:31:53.98+00	2024-05-18 15:31:53.98+00	f	\N	\N	Porcentaje de satisfacción sobre el uso del servicio	porcentaje-de-satisfaccion-sobre-el-uso-del-servicio-acfb	\N	\N	\N	\N	\N	str
1615	2024-05-18 15:31:53.999+00	2024-05-18 15:31:53.999+00	f	\N	\N	Nombre y Apellido	nombre-y-apellido	\N	\N	\N	\N	\N	str
1616	2024-05-18 15:31:54.01+00	2024-05-18 15:31:54.01+00	f	\N	\N	Puesto Institucional 	puesto-institucional-3ejp	\N	\N	\N	\N	\N	str
1617	2024-05-18 15:31:54.021+00	2024-05-18 15:31:54.021+00	f	\N	\N	Fecha de inicio	fecha-de-inicio	\N	\N	\N	\N	\N	str
1618	2024-05-18 15:31:54.031+00	2024-05-18 15:31:54.031+00	f	\N	\N	Fecha de fin	fecha-de-fin	\N	\N	\N	\N	\N	str
1619	2024-05-18 15:31:54.045+00	2024-05-18 15:31:54.045+00	f	\N	\N	Lugar	lugar-sh6l	\N	\N	\N	\N	\N	str
1620	2024-05-18 15:31:54.056+00	2024-05-18 15:31:54.056+00	f	\N	\N	Tipo	tipo-8eyk	\N	\N	\N	\N	\N	str
1621	2024-05-18 15:31:54.074+00	2024-05-18 15:31:54.074+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN	fecha-actualizacion-de-la-informacion-fb3t	\N	\N	\N	\N	\N	str
1622	2024-05-18 15:31:54.086+00	2024-05-18 15:31:54.086+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN	periodicidad-de-actualizacion-de-la-informacion-8hi0	\N	\N	\N	\N	\N	str
1623	2024-05-18 15:31:54.096+00	2024-05-18 15:31:54.096+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACION	unidad-poseedora-de-la-informacion-a1ru	\N	\N	\N	\N	\N	str
1624	2024-05-18 15:31:54.106+00	2024-05-18 15:31:54.106+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	persona-responsable-de-la-unidad-poseedora-de-la-informacion-i3nm	\N	\N	\N	\N	\N	str
1625	2024-05-18 15:31:54.118+00	2024-05-18 15:31:54.118+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-eay6	\N	\N	\N	\N	\N	str
1626	2024-05-18 15:31:54.131+00	2024-05-18 15:31:54.131+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-nxk0	\N	\N	\N	\N	\N	str
1627	2024-05-18 15:31:54.14+00	2024-05-18 15:31:54.141+00	f	\N	\N	LICENCIA	licencia-jqjv	\N	\N	\N	\N	\N	str
1628	2024-05-18 15:31:54.155+00	2024-05-18 15:31:54.155+00	f	\N	\N	 		\N	\N	\N	\N	\N	str
1629	2024-05-18 15:31:54.166+00	2024-05-18 15:31:54.166+00	f	\N	\N	Descripción	descripcion-u3uw	\N	\N	\N	\N	\N	str
1630	2024-05-18 15:31:54.177+00	2024-05-18 15:31:54.177+00	f	\N	\N	Nombre del Campo	nombre-del-campo-8sr4	\N	\N	\N	\N	\N	str
1631	2024-05-18 15:31:54.187+00	2024-05-18 15:31:54.187+00	f	\N	\N	Nombre y Apellido	nombre-y-apellido-m2pz	\N	\N	\N	\N	\N	str
1632	2024-05-18 15:31:54.197+00	2024-05-18 15:31:54.197+00	f	\N	\N	Puesto Institucional	puesto-institucional-l62c	\N	\N	\N	\N	\N	str
1633	2024-05-18 15:31:54.207+00	2024-05-18 15:31:54.207+00	f	\N	\N	Fecha de inicio	fecha-de-inicio-vi0k	\N	\N	\N	\N	\N	str
1634	2024-05-18 15:31:54.217+00	2024-05-18 15:31:54.217+00	f	\N	\N	Fecha de fin	fecha-de-fin-tn1e	\N	\N	\N	\N	\N	str
1635	2024-05-18 15:31:54.228+00	2024-05-18 15:31:54.228+00	f	\N	\N	Lugar	lugar-99y3	\N	\N	\N	\N	\N	str
1636	2024-05-18 15:31:54.239+00	2024-05-18 15:31:54.239+00	f	\N	\N	Tipo	tipo-d0u7	\N	\N	\N	\N	\N	str
1637	2024-05-18 15:31:54.257+00	2024-05-18 15:31:54.257+00	f	\N	\N	Información relevante	informacion-relevante	\N	\N	\N	\N	\N	str
1638	2024-05-18 15:31:54.265+00	2024-05-18 15:31:54.265+00	f	\N	\N	Enlace para descargar	enlace-para-descargar	\N	\N	\N	\N	\N	str
1639	2024-05-18 15:31:54.283+00	2024-05-18 15:31:54.283+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-k156	\N	\N	\N	\N	\N	str
1640	2024-05-18 15:31:54.294+00	2024-05-18 15:31:54.294+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-tfm3	\N	\N	\N	\N	\N	str
1641	2024-05-18 15:31:54.305+00	2024-05-18 15:31:54.305+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-20ng	\N	\N	\N	\N	\N	str
1642	2024-05-18 15:31:54.317+00	2024-05-18 15:31:54.317+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-9vdi	\N	\N	\N	\N	\N	str
1643	2024-05-18 15:31:54.328+00	2024-05-18 15:31:54.328+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-d1oi	\N	\N	\N	\N	\N	str
1644	2024-05-18 15:31:54.341+00	2024-05-18 15:31:54.341+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-xmfo	\N	\N	\N	\N	\N	str
1645	2024-05-18 15:31:54.354+00	2024-05-18 15:31:54.354+00	f	\N	\N	LICENCIA	licencia-fiag	\N	\N	\N	\N	\N	str
1646	2024-05-18 15:31:54.375+00	2024-05-18 15:31:54.375+00	f	\N	\N	Institución	institucion-19f3	\N	\N	\N	\N	\N	str
1647	2024-05-18 15:31:54.387+00	2024-05-18 15:31:54.387+00	f	\N	\N	Descripción	descripcion-j687	\N	\N	\N	\N	\N	str
1648	2024-05-18 15:31:54.4+00	2024-05-18 15:31:54.4+00	f	\N	\N	Nombre del campo	nombre-del-campo-cgzq	\N	\N	\N	\N	\N	str
1649	2024-05-18 15:31:54.413+00	2024-05-18 15:31:54.413+00	f	\N	\N	Información relevante	informacion-relevante-dvbx	\N	\N	\N	\N	\N	str
1650	2024-05-18 15:31:54.423+00	2024-05-18 15:31:54.423+00	f	\N	\N	Enlace para descargar	enlace-para-descargar-93t0	\N	\N	\N	\N	\N	str
1651	2024-05-18 15:31:54.439+00	2024-05-18 15:31:54.439+00	f	\N	\N	Fecha	fecha-dlbg	\N	\N	\N	\N	\N	str
1652	2024-05-18 15:31:54.447+00	2024-05-18 15:31:54.447+00	f	\N	\N	Nombre 	nombre	\N	\N	\N	\N	\N	str
1653	2024-05-18 15:31:54.454+00	2024-05-18 15:31:54.454+00	f	\N	\N	Enlace	enlace-aylc	\N	\N	\N	\N	\N	str
1654	2024-05-18 15:31:54.468+00	2024-05-18 15:31:54.468+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-idai	\N	\N	\N	\N	\N	str
1655	2024-05-18 15:31:54.478+00	2024-05-18 15:31:54.478+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-w9pg	\N	\N	\N	\N	\N	str
1656	2024-05-18 15:31:54.488+00	2024-05-18 15:31:54.488+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-1w1n	\N	\N	\N	\N	\N	str
1657	2024-05-18 15:31:54.498+00	2024-05-18 15:31:54.498+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-c8r8	\N	\N	\N	\N	\N	str
1658	2024-05-18 15:31:54.508+00	2024-05-18 15:31:54.508+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-2w9k	\N	\N	\N	\N	\N	str
1659	2024-05-18 15:31:54.518+00	2024-05-18 15:31:54.518+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-zbcf	\N	\N	\N	\N	\N	str
1660	2024-05-18 15:31:54.529+00	2024-05-18 15:31:54.529+00	f	\N	\N	LICENCIA	licencia-754s	\N	\N	\N	\N	\N	str
1661	2024-05-18 15:31:54.545+00	2024-05-18 15:31:54.546+00	f	\N	\N	Institución	institucion-7xyo	\N	\N	\N	\N	\N	str
1662	2024-05-18 15:31:54.556+00	2024-05-18 15:31:54.556+00	f	\N	\N	Descripción	descripcion-blhw	\N	\N	\N	\N	\N	str
1663	2024-05-18 15:31:54.566+00	2024-05-18 15:31:54.566+00	f	\N	\N	Nombre del campo	nombre-del-campo-xzyg	\N	\N	\N	\N	\N	str
1664	2024-05-18 15:31:54.576+00	2024-05-18 15:31:54.576+00	f	\N	\N	Fecha	fecha-9d0y	\N	\N	\N	\N	\N	str
1665	2024-05-18 15:31:54.586+00	2024-05-18 15:31:54.586+00	f	\N	\N	Nombre 	nombre-samo	\N	\N	\N	\N	\N	str
1666	2024-05-18 15:31:54.595+00	2024-05-18 15:31:54.595+00	f	\N	\N	Enlace	enlace-5eis	\N	\N	\N	\N	\N	str
1667	2024-05-18 15:33:24.913+00	2024-05-18 15:33:24.913+00	f	\N	\N	Nombre de entidad 	nombre-de-entidad-r4e4	\N	\N	\N	\N	\N	str
1668	2024-05-18 15:33:24.927+00	2024-05-18 15:33:24.927+00	f	\N	\N	Temática de la información	tematica-de-la-informacion	\N	\N	\N	\N	\N	str
1669	2024-05-18 15:33:24.937+00	2024-05-18 15:33:24.937+00	f	\N	\N	Fecha de publicación de la información 	fecha-de-publicacion-de-la-informacion	\N	\N	\N	\N	\N	str
1670	2024-05-18 15:33:24.948+00	2024-05-18 15:33:24.948+00	f	\N	\N	Enlace  a archivo que contiene la información 	enlace-a-archivo-que-contiene-la-informacion	\N	\N	\N	\N	\N	str
1671	2024-05-18 15:33:24.967+00	2024-05-18 15:33:24.967+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-psm2	\N	\N	\N	\N	\N	str
1672	2024-05-18 15:33:24.98+00	2024-05-18 15:33:24.98+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-4xv3	\N	\N	\N	\N	\N	str
1673	2024-05-18 15:33:24.999+00	2024-05-18 15:33:24.999+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-okzx	\N	\N	\N	\N	\N	str
1674	2024-05-18 15:33:25.012+00	2024-05-18 15:33:25.012+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-hf1q	\N	\N	\N	\N	\N	str
1675	2024-05-18 15:33:25.027+00	2024-05-18 15:33:25.027+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-3yp2	\N	\N	\N	\N	\N	str
1676	2024-05-18 15:33:25.041+00	2024-05-18 15:33:25.041+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-5e7q	\N	\N	\N	\N	\N	str
1677	2024-05-18 15:33:25.053+00	2024-05-18 15:33:25.053+00	f	\N	\N	LICENCIA	licencia-5b49	\N	\N	\N	\N	\N	str
1678	2024-05-18 15:33:25.073+00	2024-05-18 15:33:25.073+00	f	\N	\N	Institución	institucion-v0tc	\N	\N	\N	\N	\N	str
1679	2024-05-18 15:33:25.084+00	2024-05-18 15:33:25.084+00	f	\N	\N	Descripción	descripcion-mq62	\N	\N	\N	\N	\N	str
1680	2024-05-18 15:33:25.096+00	2024-05-18 15:33:25.096+00	f	\N	\N	Nombre del campo	nombre-del-campo-obvi	\N	\N	\N	\N	\N	str
1681	2024-05-18 15:33:25.107+00	2024-05-18 15:33:25.107+00	f	\N	\N	Nombre de entidad 	nombre-de-entidad-zsgh	\N	\N	\N	\N	\N	str
1682	2024-05-18 15:33:25.118+00	2024-05-18 15:33:25.118+00	f	\N	\N	Temática de la información	tematica-de-la-informacion-6mb1	\N	\N	\N	\N	\N	str
1683	2024-05-18 15:33:25.128+00	2024-05-18 15:33:25.128+00	f	\N	\N	Fecha de publicación de la información 	fecha-de-publicacion-de-la-informacion-slzs	\N	\N	\N	\N	\N	str
1684	2024-05-18 15:33:25.141+00	2024-05-18 15:33:25.141+00	f	\N	\N	Enlace a archivo que contiene la información 	enlace-a-archivo-que-contiene-la-informacion-bhle	\N	\N	\N	\N	\N	str
1685	2024-05-18 15:33:25.16+00	2024-05-18 15:33:25.16+00	f	\N	\N	Nombre de entidad 	nombre-de-entidad-496g	\N	\N	\N	\N	\N	str
1686	2024-05-18 15:33:25.168+00	2024-05-18 15:33:25.168+00	f	\N	\N	Fecha en la que se realizó espacio de colaboración	fecha-en-la-que-se-realizo-espacio-de-colaboracion	\N	\N	\N	\N	\N	str
1687	2024-05-18 15:33:25.176+00	2024-05-18 15:33:25.176+00	f	\N	\N	Modalidad del espacio de colaboración	modalidad-del-espacio-de-colaboracion	\N	\N	\N	\N	\N	str
1688	2024-05-18 15:33:25.184+00	2024-05-18 15:33:25.184+00	f	\N	\N	Lugar o plataforma en la que se realizó espacio de colaboración 	lugar-o-plataforma-en-la-que-se-realizo-espacio-de-colaboracion	\N	\N	\N	\N	\N	str
1689	2024-05-18 15:33:25.191+00	2024-05-18 15:33:25.191+00	f	\N	\N	Persona u organización proponente del espacio de colaboración	persona-u-organizacion-proponente-del-espacio-de-colaboracion	\N	\N	\N	\N	\N	str
1690	2024-05-18 15:33:25.199+00	2024-05-18 15:33:25.199+00	f	\N	\N	Enlace al archivo de avances o resultados del espacio de colaboración	enlace-al-archivo-de-avances-o-resultados-del-espacio-de-colaboracion	\N	\N	\N	\N	\N	str
1691	2024-05-18 15:33:25.215+00	2024-05-18 15:33:25.215+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-w3ns	\N	\N	\N	\N	\N	str
1692	2024-05-18 15:33:25.225+00	2024-05-18 15:33:25.225+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-u3as	\N	\N	\N	\N	\N	str
1693	2024-05-18 15:33:25.235+00	2024-05-18 15:33:25.235+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-qwxu	\N	\N	\N	\N	\N	str
1694	2024-05-18 15:33:25.246+00	2024-05-18 15:33:25.246+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-p8te	\N	\N	\N	\N	\N	str
1695	2024-05-18 15:33:25.257+00	2024-05-18 15:33:25.257+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-5a8m	\N	\N	\N	\N	\N	str
1696	2024-05-18 15:33:25.267+00	2024-05-18 15:33:25.267+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-des9	\N	\N	\N	\N	\N	str
1697	2024-05-18 15:33:25.278+00	2024-05-18 15:33:25.278+00	f	\N	\N	LICENCIA	licencia-etn0	\N	\N	\N	\N	\N	str
1698	2024-05-18 15:33:25.295+00	2024-05-18 15:33:25.295+00	f	\N	\N	Institución	institucion-a0ex	\N	\N	\N	\N	\N	str
1699	2024-05-18 15:33:25.305+00	2024-05-18 15:33:25.305+00	f	\N	\N	Descripción	descripcion-lf7u	\N	\N	\N	\N	\N	str
1700	2024-05-18 15:33:25.315+00	2024-05-18 15:33:25.315+00	f	\N	\N	Nombre del campo	nombre-del-campo-cpe4	\N	\N	\N	\N	\N	str
1701	2024-05-18 15:33:25.326+00	2024-05-18 15:33:25.326+00	f	\N	\N	Nombre de entidad 	nombre-de-entidad-tz8c	\N	\N	\N	\N	\N	str
1702	2024-05-18 15:33:25.336+00	2024-05-18 15:33:25.336+00	f	\N	\N	Fecha en la que se realizó espacio de colaboración	fecha-en-la-que-se-realizo-espacio-de-colaboracion-oqgx	\N	\N	\N	\N	\N	str
1703	2024-05-18 15:33:25.346+00	2024-05-18 15:33:25.346+00	f	\N	\N	Modalidad del espacio de colaboración	modalidad-del-espacio-de-colaboracion-de34	\N	\N	\N	\N	\N	str
1704	2024-05-18 15:33:25.356+00	2024-05-18 15:33:25.356+00	f	\N	\N	Lugar o plataforma en la que se realizó espacio de colaboración 	lugar-o-plataforma-en-la-que-se-realizo-espacio-de-colaboracion-ik8c	\N	\N	\N	\N	\N	str
1705	2024-05-18 15:33:25.366+00	2024-05-18 15:33:25.366+00	f	\N	\N	Persona u organización proponente del espacio de colaboración	persona-u-organizacion-proponente-del-espacio-de-colaboracion-4v46	\N	\N	\N	\N	\N	str
1706	2024-05-18 15:33:25.376+00	2024-05-18 15:33:25.376+00	f	\N	\N	Enlace al archivo de avances o resultados del espacio de colaboración	enlace-al-archivo-de-avances-o-resultados-del-espacio-de-colaboracion-8jxv	\N	\N	\N	\N	\N	str
1707	2024-07-01 04:38:57.885+00	2024-07-01 04:38:57.885+00	f	\N	\N	Organización Política o Alianza	organizacion-politica-o-alianza-aiqg	\N	\N	\N	\N	\N	str
1708	2024-07-01 04:38:57.906+00	2024-07-01 04:38:57.906+00	f	\N	\N	Proceso Electoral	proceso-electoral-y9r4	\N	\N	\N	\N	\N	str
1709	2024-07-01 04:38:57.919+00	2024-07-01 04:38:57.919+00	f	\N	\N	Mes	mes-lbfp	\N	\N	\N	\N	\N	str
1710	2024-07-01 04:38:57.932+00	2024-07-01 04:38:57.932+00	f	\N	\N	Dignidad	dignidad-cr6n	\N	\N	\N	\N	\N	str
1711	2024-07-01 04:38:57.939+00	2024-07-01 04:38:57.939+00	f	\N	\N	Provincia	provincia-70zt	\N	\N	\N	\N	\N	str
1712	2024-07-01 04:38:57.948+00	2024-07-01 04:38:57.948+00	f	\N	\N	Circunscripción	circunscripcion-3c69	\N	\N	\N	\N	\N	str
1713	2024-07-01 04:38:57.957+00	2024-07-01 04:38:57.957+00	f	\N	\N	Cantón	canton-s94b	\N	\N	\N	\N	\N	str
1714	2024-07-01 04:38:57.966+00	2024-07-01 04:38:57.966+00	f	\N	\N	Parroquia	parroquia-tkio	\N	\N	\N	\N	\N	str
1715	2024-07-01 04:38:57.975+00	2024-07-01 04:38:57.975+00	f	\N	\N	Código Cuenta	codigo-cuenta-6ohs	\N	\N	\N	\N	\N	str
1718	2024-07-01 04:38:58.003+00	2024-07-01 04:38:58.003+00	f	\N	\N	Subcuenta	subcuenta-gs4o	\N	\N	\N	\N	\N	str
1719	2024-07-01 04:38:58.014+00	2024-07-01 04:38:58.014+00	f	\N	\N	Fecha Comprobante de Venta	fecha-comprobante-de-venta-36k2	\N	\N	\N	\N	\N	str
1720	2024-07-01 04:38:58.025+00	2024-07-01 04:38:58.025+00	f	\N	\N	Nro. Comprobante de Venta	nro-comprobante-de-venta-et74	\N	\N	\N	\N	\N	str
1721	2024-07-01 04:38:58.033+00	2024-07-01 04:38:58.033+00	f	\N	\N	Nro. RUC del Proveedor	nro-ruc-del-proveedor-sxkg	\N	\N	\N	\N	\N	str
1722	2024-07-01 04:38:58.04+00	2024-07-01 04:38:58.04+00	f	\N	\N	Nombre del Proveedor	nombre-del-proveedor-i1bo	\N	\N	\N	\N	\N	str
1723	2024-07-01 04:38:58.049+00	2024-07-01 04:38:58.049+00	f	\N	\N	Descripción del Gasto	descripcion-del-gasto-8zkt	\N	\N	\N	\N	\N	str
1724	2024-07-01 04:38:58.057+00	2024-07-01 04:38:58.057+00	f	\N	\N	Subtotal	subtotal-bix8	\N	\N	\N	\N	\N	str
1725	2024-07-01 04:38:58.064+00	2024-07-01 04:38:58.064+00	f	\N	\N	IVA	iva-c3jh	\N	\N	\N	\N	\N	str
1726	2024-07-01 04:38:58.071+00	2024-07-01 04:38:58.071+00	f	\N	\N	Total	total-rvdm	\N	\N	\N	\N	\N	str
1727	2024-07-01 04:38:58.086+00	2024-07-01 04:38:58.086+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-5rj0	\N	\N	\N	\N	\N	str
1728	2024-07-01 04:38:58.094+00	2024-07-01 04:38:58.094+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-fjrt	\N	\N	\N	\N	\N	str
1729	2024-07-01 04:38:58.101+00	2024-07-01 04:38:58.101+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-z9kc	\N	\N	\N	\N	\N	str
1730	2024-07-01 04:38:58.107+00	2024-07-01 04:38:58.107+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-z5hi	\N	\N	\N	\N	\N	str
1731	2024-07-01 04:38:58.116+00	2024-07-01 04:38:58.116+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-mbil	\N	\N	\N	\N	\N	str
1732	2024-07-01 04:38:58.124+00	2024-07-01 04:38:58.124+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-kjp8	\N	\N	\N	\N	\N	str
1733	2024-07-01 04:38:58.132+00	2024-07-01 04:38:58.132+00	f	\N	\N	LICENCIA	licencia-ycrb	\N	\N	\N	\N	\N	str
1734	2024-07-01 04:38:58.146+00	2024-07-01 04:38:58.146+00	f	\N	\N	Institución	institucion-my9w	\N	\N	\N	\N	\N	str
1735	2024-07-01 04:38:58.154+00	2024-07-01 04:38:58.154+00	f	\N	\N	Descripción	descripcion-mtha	\N	\N	\N	\N	\N	str
1736	2024-07-01 04:38:58.162+00	2024-07-01 04:38:58.162+00	f	\N	\N	Nombre del campo	nombre-del-campo-cypw	\N	\N	\N	\N	\N	str
1737	2024-07-01 04:38:58.168+00	2024-07-01 04:38:58.168+00	f	\N	\N	Organización Política o Alianza	organizacion-politica-o-alianza-e61r	\N	\N	\N	\N	\N	str
1738	2024-07-01 04:38:58.175+00	2024-07-01 04:38:58.175+00	f	\N	\N	Proceso Electoral	proceso-electoral-56rg	\N	\N	\N	\N	\N	str
1739	2024-07-01 04:38:58.183+00	2024-07-01 04:38:58.183+00	f	\N	\N	Mes	mes-vi6z	\N	\N	\N	\N	\N	str
1740	2024-07-01 04:38:58.19+00	2024-07-01 04:38:58.19+00	f	\N	\N	Dignidad	dignidad-cf1e	\N	\N	\N	\N	\N	str
1741	2024-07-01 04:38:58.196+00	2024-07-01 04:38:58.196+00	f	\N	\N	Provincia	provincia-aq53	\N	\N	\N	\N	\N	str
1742	2024-07-01 04:38:58.203+00	2024-07-01 04:38:58.203+00	f	\N	\N	Circunscripción	circunscripcion-o8l6	\N	\N	\N	\N	\N	str
1743	2024-07-01 04:38:58.21+00	2024-07-01 04:38:58.21+00	f	\N	\N	Cantón	canton-bojf	\N	\N	\N	\N	\N	str
1744	2024-07-01 04:38:58.218+00	2024-07-01 04:38:58.218+00	f	\N	\N	Parroquia	parroquia-mb28	\N	\N	\N	\N	\N	str
1745	2024-07-01 04:38:58.227+00	2024-07-01 04:38:58.227+00	f	\N	\N	Código Cuenta	codigo-cuenta-x9bj	\N	\N	\N	\N	\N	str
1746	2024-07-01 04:38:58.234+00	2024-07-01 04:38:58.234+00	f	\N	\N	Cuenta	cuenta-xkw6	\N	\N	\N	\N	\N	str
1747	2024-07-01 04:38:58.241+00	2024-07-01 04:38:58.241+00	f	\N	\N	Código Subcuenta	codigo-subcuenta-zflp	\N	\N	\N	\N	\N	str
1748	2024-07-01 04:38:58.248+00	2024-07-01 04:38:58.248+00	f	\N	\N	Fecha Comprobante de Venta	fecha-comprobante-de-venta-3rlt	\N	\N	\N	\N	\N	str
1749	2024-07-01 04:38:58.256+00	2024-07-01 04:38:58.256+00	f	\N	\N	Nro. Comprobante de Venta	nro-comprobante-de-venta-d12b	\N	\N	\N	\N	\N	str
1750	2024-07-01 04:38:58.264+00	2024-07-01 04:38:58.264+00	f	\N	\N	Nro. RUC del Proveedor	nro-ruc-del-proveedor-oxso	\N	\N	\N	\N	\N	str
1751	2024-07-01 04:38:58.27+00	2024-07-01 04:38:58.27+00	f	\N	\N	Nombre del Proveedor	nombre-del-proveedor-k1ht	\N	\N	\N	\N	\N	str
1752	2024-07-01 04:38:58.277+00	2024-07-01 04:38:58.277+00	f	\N	\N	Descripción del Gasto	descripcion-del-gasto-n5cp	\N	\N	\N	\N	\N	str
1753	2024-07-01 04:38:58.286+00	2024-07-01 04:38:58.286+00	f	\N	\N	Subtotal	subtotal-j8fl	\N	\N	\N	\N	\N	str
1754	2024-07-01 04:38:58.293+00	2024-07-01 04:38:58.293+00	f	\N	\N	IVA	iva-nld1	\N	\N	\N	\N	\N	str
1755	2024-07-01 04:38:58.3+00	2024-07-01 04:38:58.3+00	f	\N	\N	Total	total-43e5	\N	\N	\N	\N	\N	str
1756	2024-07-01 04:38:58.316+00	2024-07-01 04:38:58.316+00	f	\N	\N	Nombre de Entidad	nombre-de-entidad-4t7z	\N	\N	\N	\N	\N	str
1757	2024-07-01 04:38:58.325+00	2024-07-01 04:38:58.325+00	f	\N	\N	Fecha	fecha-aj7m	\N	\N	\N	\N	\N	str
1758	2024-07-01 04:38:58.332+00	2024-07-01 04:38:58.332+00	f	\N	\N	Nombre de Informe	nombre-de-informe-0wy4	\N	\N	\N	\N	\N	str
1759	2024-07-01 04:38:58.34+00	2024-07-01 04:38:58.34+00	f	\N	\N	Enlace a Informe	enlace-a-informe-zjgk	\N	\N	\N	\N	\N	str
1760	2024-07-01 04:38:58.355+00	2024-07-01 04:38:58.355+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-dyfl	\N	\N	\N	\N	\N	str
1761	2024-07-01 04:38:58.364+00	2024-07-01 04:38:58.364+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-47mk	\N	\N	\N	\N	\N	str
1762	2024-07-01 04:38:58.371+00	2024-07-01 04:38:58.371+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-vre2	\N	\N	\N	\N	\N	str
1763	2024-07-01 04:38:58.38+00	2024-07-01 04:38:58.38+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-wbz0	\N	\N	\N	\N	\N	str
1764	2024-07-01 04:38:58.389+00	2024-07-01 04:38:58.389+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-br0m	\N	\N	\N	\N	\N	str
1765	2024-07-01 04:38:58.403+00	2024-07-01 04:38:58.403+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-csdw	\N	\N	\N	\N	\N	str
1766	2024-07-01 04:38:58.412+00	2024-07-01 04:38:58.412+00	f	\N	\N	LICENCIA	licencia-gr13	\N	\N	\N	\N	\N	str
1767	2024-07-01 04:38:58.426+00	2024-07-01 04:38:58.426+00	f	\N	\N	Institución	institucion-eusr	\N	\N	\N	\N	\N	str
1768	2024-07-01 04:38:58.433+00	2024-07-01 04:38:58.434+00	f	\N	\N	Descripción	descripcion-947x	\N	\N	\N	\N	\N	str
1769	2024-07-01 04:38:58.44+00	2024-07-01 04:38:58.44+00	f	\N	\N	Nombre del campo	nombre-del-campo-dt3c	\N	\N	\N	\N	\N	str
1770	2024-07-01 04:38:58.449+00	2024-07-01 04:38:58.449+00	f	\N	\N	Nombre de Entidad	nombre-de-entidad-xjki	\N	\N	\N	\N	\N	str
1771	2024-07-01 04:38:58.457+00	2024-07-01 04:38:58.457+00	f	\N	\N	Fecha	fecha-abuo	\N	\N	\N	\N	\N	str
1772	2024-07-01 04:38:58.464+00	2024-07-01 04:38:58.464+00	f	\N	\N	Nombre de Informe	nombre-de-informe-518i	\N	\N	\N	\N	\N	str
1773	2024-07-01 04:38:58.471+00	2024-07-01 04:38:58.471+00	f	\N	\N	Enlace a Informe	enlace-a-informe-jtfs	\N	\N	\N	\N	\N	str
1774	2024-07-01 04:38:58.489+00	2024-07-01 04:38:58.489+00	f	\N	\N	Nombre de Entidad 	nombre-de-entidad-5ql8	\N	\N	\N	\N	\N	str
1775	2024-07-01 04:38:58.496+00	2024-07-01 04:38:58.496+00	f	\N	\N	Número de Resolución o Informe	numero-de-resolucion-o-informe-d5q8	\N	\N	\N	\N	\N	str
1776	2024-07-01 04:38:58.503+00	2024-07-01 04:38:58.503+00	f	\N	\N	Fecha	fecha-6rgn	\N	\N	\N	\N	\N	str
1777	2024-07-01 04:38:58.509+00	2024-07-01 04:38:58.509+00	f	\N	\N	Descripción	descripcion-7rmv	\N	\N	\N	\N	\N	str
1778	2024-07-01 04:38:58.518+00	2024-07-01 04:38:58.518+00	f	\N	\N	Enlace 	enlace-xwjp	\N	\N	\N	\N	\N	str
1779	2024-07-01 04:38:58.53+00	2024-07-01 04:38:58.53+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-yuty	\N	\N	\N	\N	\N	str
1780	2024-07-01 04:38:58.537+00	2024-07-01 04:38:58.537+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-0f6r	\N	\N	\N	\N	\N	str
1781	2024-07-01 04:38:58.546+00	2024-07-01 04:38:58.546+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-it5v	\N	\N	\N	\N	\N	str
1782	2024-07-01 04:38:58.558+00	2024-07-01 04:38:58.558+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-ii3b	\N	\N	\N	\N	\N	str
1905	2024-07-01 04:38:59.61+00	2024-07-01 04:38:59.61+00	f	\N	\N	LICENCIA	licencia-7jqe	\N	\N	\N	\N	\N	str
1783	2024-07-01 04:38:58.565+00	2024-07-01 04:38:58.565+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-htu8	\N	\N	\N	\N	\N	str
1784	2024-07-01 04:38:58.572+00	2024-07-01 04:38:58.572+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-8bev	\N	\N	\N	\N	\N	str
1785	2024-07-01 04:38:58.581+00	2024-07-01 04:38:58.581+00	f	\N	\N	LICENCIA	licencia-i9uj	\N	\N	\N	\N	\N	str
1786	2024-07-01 04:38:58.595+00	2024-07-01 04:38:58.595+00	f	\N	\N	Institución	institucion-4587	\N	\N	\N	\N	\N	str
1787	2024-07-01 04:38:58.603+00	2024-07-01 04:38:58.603+00	f	\N	\N	Descripción	descripcion-9z4b	\N	\N	\N	\N	\N	str
1788	2024-07-01 04:38:58.611+00	2024-07-01 04:38:58.611+00	f	\N	\N	Nombre del campo	nombre-del-campo-1jxx	\N	\N	\N	\N	\N	str
1789	2024-07-01 04:38:58.62+00	2024-07-01 04:38:58.62+00	f	\N	\N	Nombre de Entidad 	nombre-de-entidad-3cti	\N	\N	\N	\N	\N	str
1790	2024-07-01 04:38:58.628+00	2024-07-01 04:38:58.628+00	f	\N	\N	Número de Resolución o Informe	numero-de-resolucion-o-informe-2v01	\N	\N	\N	\N	\N	str
1791	2024-07-01 04:38:58.636+00	2024-07-01 04:38:58.636+00	f	\N	\N	Fecha	fecha-cmv0	\N	\N	\N	\N	\N	str
1792	2024-07-01 04:38:58.644+00	2024-07-01 04:38:58.644+00	f	\N	\N	Descripción	descripcion-t3x0	\N	\N	\N	\N	\N	str
1793	2024-07-01 04:38:58.653+00	2024-07-01 04:38:58.653+00	f	\N	\N	Enlace 	enlace-p9j4	\N	\N	\N	\N	\N	str
1794	2024-07-01 04:38:58.669+00	2024-07-01 04:38:58.669+00	f	\N	\N	Nombre de Entidad 	nombre-de-entidad-7w45	\N	\N	\N	\N	\N	str
1795	2024-07-01 04:38:58.678+00	2024-07-01 04:38:58.679+00	f	\N	\N	Número de Resolución o Informe	numero-de-resolucion-o-informe-cpuq	\N	\N	\N	\N	\N	str
1796	2024-07-01 04:38:58.688+00	2024-07-01 04:38:58.688+00	f	\N	\N	Fecha	fecha-73k2	\N	\N	\N	\N	\N	str
1797	2024-07-01 04:38:58.696+00	2024-07-01 04:38:58.696+00	f	\N	\N	Descripción	descripcion-sv81	\N	\N	\N	\N	\N	str
1798	2024-07-01 04:38:58.703+00	2024-07-01 04:38:58.703+00	f	\N	\N	Enlace 	enlace-3exb	\N	\N	\N	\N	\N	str
1799	2024-07-01 04:38:58.717+00	2024-07-01 04:38:58.717+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-62pl	\N	\N	\N	\N	\N	str
1800	2024-07-01 04:38:58.725+00	2024-07-01 04:38:58.725+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-d4ox	\N	\N	\N	\N	\N	str
1801	2024-07-01 04:38:58.733+00	2024-07-01 04:38:58.733+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-6tmv	\N	\N	\N	\N	\N	str
1802	2024-07-01 04:38:58.742+00	2024-07-01 04:38:58.742+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-zw4l	\N	\N	\N	\N	\N	str
1803	2024-07-01 04:38:58.752+00	2024-07-01 04:38:58.752+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-zht3	\N	\N	\N	\N	\N	str
1804	2024-07-01 04:38:58.76+00	2024-07-01 04:38:58.76+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-p4lp	\N	\N	\N	\N	\N	str
1805	2024-07-01 04:38:58.766+00	2024-07-01 04:38:58.766+00	f	\N	\N	LICENCIA	licencia-smgx	\N	\N	\N	\N	\N	str
1806	2024-07-01 04:38:58.778+00	2024-07-01 04:38:58.778+00	f	\N	\N	Institución	institucion-ebck	\N	\N	\N	\N	\N	str
1807	2024-07-01 04:38:58.786+00	2024-07-01 04:38:58.786+00	f	\N	\N	Descripción	descripcion-4u73	\N	\N	\N	\N	\N	str
1808	2024-07-01 04:38:58.793+00	2024-07-01 04:38:58.793+00	f	\N	\N	Nombre del campo	nombre-del-campo-v5mw	\N	\N	\N	\N	\N	str
1809	2024-07-01 04:38:58.8+00	2024-07-01 04:38:58.8+00	f	\N	\N	Nombre de Entidad 	nombre-de-entidad-dzxg	\N	\N	\N	\N	\N	str
1810	2024-07-01 04:38:58.806+00	2024-07-01 04:38:58.806+00	f	\N	\N	Número de Resolución o Informe	numero-de-resolucion-o-informe-pyiq	\N	\N	\N	\N	\N	str
1811	2024-07-01 04:38:58.815+00	2024-07-01 04:38:58.815+00	f	\N	\N	Fecha	fecha-qo3o	\N	\N	\N	\N	\N	str
1812	2024-07-01 04:38:58.823+00	2024-07-01 04:38:58.823+00	f	\N	\N	Descripción	descripcion-0yk8	\N	\N	\N	\N	\N	str
1813	2024-07-01 04:38:58.831+00	2024-07-01 04:38:58.831+00	f	\N	\N	Enlace 	enlace-xu46	\N	\N	\N	\N	\N	str
1814	2024-07-01 04:38:58.843+00	2024-07-01 04:38:58.843+00	f	\N	\N	Nombre de Entidad 	nombre-de-entidad-vlds	\N	\N	\N	\N	\N	str
1815	2024-07-01 04:38:58.851+00	2024-07-01 04:38:58.851+00	f	\N	\N	Número de Resolución o Informe	numero-de-resolucion-o-informe-wsr0	\N	\N	\N	\N	\N	str
1816	2024-07-01 04:38:58.857+00	2024-07-01 04:38:58.857+00	f	\N	\N	Fecha	fecha-ffhz	\N	\N	\N	\N	\N	str
1817	2024-07-01 04:38:58.864+00	2024-07-01 04:38:58.864+00	f	\N	\N	Descripción	descripcion-xndr	\N	\N	\N	\N	\N	str
1818	2024-07-01 04:38:58.87+00	2024-07-01 04:38:58.871+00	f	\N	\N	Enlace 	enlace-fp9y	\N	\N	\N	\N	\N	str
1819	2024-07-01 04:38:58.884+00	2024-07-01 04:38:58.884+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-0sq1	\N	\N	\N	\N	\N	str
1820	2024-07-01 04:38:58.892+00	2024-07-01 04:38:58.892+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-1chq	\N	\N	\N	\N	\N	str
1821	2024-07-01 04:38:58.898+00	2024-07-01 04:38:58.898+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-6b0q	\N	\N	\N	\N	\N	str
1822	2024-07-01 04:38:58.904+00	2024-07-01 04:38:58.904+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-5s55	\N	\N	\N	\N	\N	str
1823	2024-07-01 04:38:58.912+00	2024-07-01 04:38:58.912+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-wgqa	\N	\N	\N	\N	\N	str
1824	2024-07-01 04:38:58.921+00	2024-07-01 04:38:58.921+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-h9gx	\N	\N	\N	\N	\N	str
1825	2024-07-01 04:38:58.93+00	2024-07-01 04:38:58.93+00	f	\N	\N	LICENCIA	licencia-5tr0	\N	\N	\N	\N	\N	str
1826	2024-07-01 04:38:58.943+00	2024-07-01 04:38:58.943+00	f	\N	\N	Institución	institucion-2qoe	\N	\N	\N	\N	\N	str
1827	2024-07-01 04:38:58.951+00	2024-07-01 04:38:58.951+00	f	\N	\N	Descripción	descripcion-5ixc	\N	\N	\N	\N	\N	str
1828	2024-07-01 04:38:58.96+00	2024-07-01 04:38:58.96+00	f	\N	\N	Nombre del campo	nombre-del-campo-u5i6	\N	\N	\N	\N	\N	str
1829	2024-07-01 04:38:58.967+00	2024-07-01 04:38:58.967+00	f	\N	\N	Nombre de Entidad 	nombre-de-entidad-e4g1	\N	\N	\N	\N	\N	str
1830	2024-07-01 04:38:58.98+00	2024-07-01 04:38:58.98+00	f	\N	\N	Número de Resolución o Informe	numero-de-resolucion-o-informe-ynlm	\N	\N	\N	\N	\N	str
1831	2024-07-01 04:38:58.989+00	2024-07-01 04:38:58.989+00	f	\N	\N	Fecha	fecha-kkcf	\N	\N	\N	\N	\N	str
1832	2024-07-01 04:38:58.997+00	2024-07-01 04:38:58.997+00	f	\N	\N	Descripción	descripcion-dt6q	\N	\N	\N	\N	\N	str
1833	2024-07-01 04:38:59.004+00	2024-07-01 04:38:59.004+00	f	\N	\N	Enlace 	enlace-5gg3	\N	\N	\N	\N	\N	str
1834	2024-07-01 04:38:59.018+00	2024-07-01 04:38:59.018+00	f	\N	\N	Nombre de Entidad 	nombre-de-entidad-bvu9	\N	\N	\N	\N	\N	str
1835	2024-07-01 04:38:59.027+00	2024-07-01 04:38:59.027+00	f	\N	\N	Número de Resolución o Informe	numero-de-resolucion-o-informe-sn5h	\N	\N	\N	\N	\N	str
1836	2024-07-01 04:38:59.034+00	2024-07-01 04:38:59.034+00	f	\N	\N	Fecha	fecha-lqvv	\N	\N	\N	\N	\N	str
1837	2024-07-01 04:38:59.042+00	2024-07-01 04:38:59.042+00	f	\N	\N	Descripción	descripcion-bffl	\N	\N	\N	\N	\N	str
1838	2024-07-01 04:38:59.051+00	2024-07-01 04:38:59.051+00	f	\N	\N	Enlace 	enlace-q7zc	\N	\N	\N	\N	\N	str
1839	2024-07-01 04:38:59.065+00	2024-07-01 04:38:59.065+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-8p9z	\N	\N	\N	\N	\N	str
1840	2024-07-01 04:38:59.074+00	2024-07-01 04:38:59.074+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-jnon	\N	\N	\N	\N	\N	str
1841	2024-07-01 04:38:59.087+00	2024-07-01 04:38:59.087+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-ad5t	\N	\N	\N	\N	\N	str
1842	2024-07-01 04:38:59.095+00	2024-07-01 04:38:59.095+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-c4xf	\N	\N	\N	\N	\N	str
1843	2024-07-01 04:38:59.102+00	2024-07-01 04:38:59.102+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-gnvy	\N	\N	\N	\N	\N	str
1844	2024-07-01 04:38:59.109+00	2024-07-01 04:38:59.109+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-rlig	\N	\N	\N	\N	\N	str
1845	2024-07-01 04:38:59.119+00	2024-07-01 04:38:59.119+00	f	\N	\N	LICENCIA	licencia-nbmh	\N	\N	\N	\N	\N	str
1846	2024-07-01 04:38:59.132+00	2024-07-01 04:38:59.132+00	f	\N	\N	Institución	institucion-sd90	\N	\N	\N	\N	\N	str
1847	2024-07-01 04:38:59.139+00	2024-07-01 04:38:59.139+00	f	\N	\N	Descripción	descripcion-wg3l	\N	\N	\N	\N	\N	str
1848	2024-07-01 04:38:59.149+00	2024-07-01 04:38:59.149+00	f	\N	\N	Nombre del campo	nombre-del-campo-t49x	\N	\N	\N	\N	\N	str
1849	2024-07-01 04:38:59.158+00	2024-07-01 04:38:59.158+00	f	\N	\N	Nombre de Entidad 	nombre-de-entidad-awfg	\N	\N	\N	\N	\N	str
1850	2024-07-01 04:38:59.166+00	2024-07-01 04:38:59.166+00	f	\N	\N	Número de Resolución o Informe	numero-de-resolucion-o-informe-rgcw	\N	\N	\N	\N	\N	str
1851	2024-07-01 04:38:59.173+00	2024-07-01 04:38:59.173+00	f	\N	\N	Fecha	fecha-8pbf	\N	\N	\N	\N	\N	str
1852	2024-07-01 04:38:59.183+00	2024-07-01 04:38:59.183+00	f	\N	\N	Descripción	descripcion-6p9g	\N	\N	\N	\N	\N	str
1853	2024-07-01 04:38:59.191+00	2024-07-01 04:38:59.191+00	f	\N	\N	Enlace 	enlace-ksrp	\N	\N	\N	\N	\N	str
1854	2024-07-01 04:38:59.203+00	2024-07-01 04:38:59.203+00	f	\N	\N	Nombre de Entidad 	nombre-de-entidad-4ygz	\N	\N	\N	\N	\N	str
1855	2024-07-01 04:38:59.211+00	2024-07-01 04:38:59.211+00	f	\N	\N	Número de Resolución o Informe	numero-de-resolucion-o-informe-4ae1	\N	\N	\N	\N	\N	str
1856	2024-07-01 04:38:59.22+00	2024-07-01 04:38:59.22+00	f	\N	\N	Fecha	fecha-dhz2	\N	\N	\N	\N	\N	str
1857	2024-07-01 04:38:59.228+00	2024-07-01 04:38:59.228+00	f	\N	\N	Descripción	descripcion-4tm1	\N	\N	\N	\N	\N	str
1858	2024-07-01 04:38:59.235+00	2024-07-01 04:38:59.235+00	f	\N	\N	Enlace 	enlace-p91n	\N	\N	\N	\N	\N	str
1859	2024-07-01 04:38:59.246+00	2024-07-01 04:38:59.246+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-eug8	\N	\N	\N	\N	\N	str
1860	2024-07-01 04:38:59.254+00	2024-07-01 04:38:59.254+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-x1eu	\N	\N	\N	\N	\N	str
1861	2024-07-01 04:38:59.261+00	2024-07-01 04:38:59.261+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-ps12	\N	\N	\N	\N	\N	str
1862	2024-07-01 04:38:59.267+00	2024-07-01 04:38:59.267+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-jp9r	\N	\N	\N	\N	\N	str
1863	2024-07-01 04:38:59.273+00	2024-07-01 04:38:59.273+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-6r2i	\N	\N	\N	\N	\N	str
1864	2024-07-01 04:38:59.281+00	2024-07-01 04:38:59.281+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-en3p	\N	\N	\N	\N	\N	str
1865	2024-07-01 04:38:59.288+00	2024-07-01 04:38:59.288+00	f	\N	\N	LICENCIA	licencia-9jme	\N	\N	\N	\N	\N	str
1866	2024-07-01 04:38:59.298+00	2024-07-01 04:38:59.298+00	f	\N	\N	Institución	institucion-6mmq	\N	\N	\N	\N	\N	str
1867	2024-07-01 04:38:59.304+00	2024-07-01 04:38:59.304+00	f	\N	\N	Descripción	descripcion-otmk	\N	\N	\N	\N	\N	str
1868	2024-07-01 04:38:59.31+00	2024-07-01 04:38:59.31+00	f	\N	\N	Nombre del campo	nombre-del-campo-r4qs	\N	\N	\N	\N	\N	str
1869	2024-07-01 04:38:59.319+00	2024-07-01 04:38:59.319+00	f	\N	\N	Nombre de Entidad 	nombre-de-entidad-crme	\N	\N	\N	\N	\N	str
1870	2024-07-01 04:38:59.327+00	2024-07-01 04:38:59.327+00	f	\N	\N	Número de Resolución o Informe	numero-de-resolucion-o-informe-vtjm	\N	\N	\N	\N	\N	str
1871	2024-07-01 04:38:59.333+00	2024-07-01 04:38:59.333+00	f	\N	\N	Fecha	fecha-zemg	\N	\N	\N	\N	\N	str
1872	2024-07-01 04:38:59.339+00	2024-07-01 04:38:59.339+00	f	\N	\N	Descripción	descripcion-v1xl	\N	\N	\N	\N	\N	str
1873	2024-07-01 04:38:59.348+00	2024-07-01 04:38:59.348+00	f	\N	\N	Enlace 	enlace-2sol	\N	\N	\N	\N	\N	str
1874	2024-07-01 04:38:59.36+00	2024-07-01 04:38:59.36+00	f	\N	\N	Nombre de Entidad 	nombre-de-entidad-gri3	\N	\N	\N	\N	\N	str
1875	2024-07-01 04:38:59.367+00	2024-07-01 04:38:59.367+00	f	\N	\N	Número de Resolución o Informe	numero-de-resolucion-o-informe-e17o	\N	\N	\N	\N	\N	str
1876	2024-07-01 04:38:59.373+00	2024-07-01 04:38:59.373+00	f	\N	\N	Fecha	fecha-8mw2	\N	\N	\N	\N	\N	str
1877	2024-07-01 04:38:59.381+00	2024-07-01 04:38:59.381+00	f	\N	\N	Descripción	descripcion-ljsh	\N	\N	\N	\N	\N	str
1878	2024-07-01 04:38:59.388+00	2024-07-01 04:38:59.388+00	f	\N	\N	Enlace 	enlace-jo01	\N	\N	\N	\N	\N	str
1879	2024-07-01 04:38:59.4+00	2024-07-01 04:38:59.4+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-f2wu	\N	\N	\N	\N	\N	str
1880	2024-07-01 04:38:59.407+00	2024-07-01 04:38:59.407+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-zusu	\N	\N	\N	\N	\N	str
1881	2024-07-01 04:38:59.415+00	2024-07-01 04:38:59.415+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-rhoj	\N	\N	\N	\N	\N	str
1882	2024-07-01 04:38:59.423+00	2024-07-01 04:38:59.423+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-5ok2	\N	\N	\N	\N	\N	str
1883	2024-07-01 04:38:59.43+00	2024-07-01 04:38:59.43+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-2vvz	\N	\N	\N	\N	\N	str
1884	2024-07-01 04:38:59.437+00	2024-07-01 04:38:59.437+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-0wv2	\N	\N	\N	\N	\N	str
1885	2024-07-01 04:38:59.443+00	2024-07-01 04:38:59.443+00	f	\N	\N	LICENCIA	licencia-lsub	\N	\N	\N	\N	\N	str
1886	2024-07-01 04:38:59.455+00	2024-07-01 04:38:59.455+00	f	\N	\N	Institución	institucion-v0uc	\N	\N	\N	\N	\N	str
1887	2024-07-01 04:38:59.462+00	2024-07-01 04:38:59.462+00	f	\N	\N	Descripción	descripcion-lqoq	\N	\N	\N	\N	\N	str
1888	2024-07-01 04:38:59.47+00	2024-07-01 04:38:59.47+00	f	\N	\N	Nombre del campo	nombre-del-campo-axxs	\N	\N	\N	\N	\N	str
1889	2024-07-01 04:38:59.479+00	2024-07-01 04:38:59.479+00	f	\N	\N	Nombre de Entidad 	nombre-de-entidad-w2z2	\N	\N	\N	\N	\N	str
1890	2024-07-01 04:38:59.487+00	2024-07-01 04:38:59.487+00	f	\N	\N	Número de Resolución o Informe	numero-de-resolucion-o-informe-fks2	\N	\N	\N	\N	\N	str
1891	2024-07-01 04:38:59.494+00	2024-07-01 04:38:59.494+00	f	\N	\N	Fecha	fecha-dctq	\N	\N	\N	\N	\N	str
1892	2024-07-01 04:38:59.5+00	2024-07-01 04:38:59.5+00	f	\N	\N	Descripción	descripcion-kva1	\N	\N	\N	\N	\N	str
1893	2024-07-01 04:38:59.506+00	2024-07-01 04:38:59.506+00	f	\N	\N	Enlace 	enlace-31jv	\N	\N	\N	\N	\N	str
1894	2024-07-01 04:38:59.519+00	2024-07-01 04:38:59.519+00	f	\N	\N	Nombre de Entidad 	nombre-de-entidad-kllp	\N	\N	\N	\N	\N	str
1895	2024-07-01 04:38:59.527+00	2024-07-01 04:38:59.527+00	f	\N	\N	Número de Resolución o Informe	numero-de-resolucion-o-informe-p29m	\N	\N	\N	\N	\N	str
1896	2024-07-01 04:38:59.534+00	2024-07-01 04:38:59.534+00	f	\N	\N	Fecha	fecha-5rdm	\N	\N	\N	\N	\N	str
1897	2024-07-01 04:38:59.541+00	2024-07-01 04:38:59.541+00	f	\N	\N	Descripción	descripcion-xq4y	\N	\N	\N	\N	\N	str
1898	2024-07-01 04:38:59.55+00	2024-07-01 04:38:59.55+00	f	\N	\N	Enlace 	enlace-8hqj	\N	\N	\N	\N	\N	str
1899	2024-07-01 04:38:59.563+00	2024-07-01 04:38:59.563+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-xwn2	\N	\N	\N	\N	\N	str
1900	2024-07-01 04:38:59.569+00	2024-07-01 04:38:59.569+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-t0f6	\N	\N	\N	\N	\N	str
1901	2024-07-01 04:38:59.578+00	2024-07-01 04:38:59.578+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-ecsh	\N	\N	\N	\N	\N	str
1902	2024-07-01 04:38:59.587+00	2024-07-01 04:38:59.587+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-zjfp	\N	\N	\N	\N	\N	str
1903	2024-07-01 04:38:59.595+00	2024-07-01 04:38:59.595+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-bod8	\N	\N	\N	\N	\N	str
1904	2024-07-01 04:38:59.602+00	2024-07-01 04:38:59.602+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-yr90	\N	\N	\N	\N	\N	str
1906	2024-07-01 04:38:59.624+00	2024-07-01 04:38:59.624+00	f	\N	\N	Institución	institucion-37lj	\N	\N	\N	\N	\N	str
1907	2024-07-01 04:38:59.631+00	2024-07-01 04:38:59.631+00	f	\N	\N	Descripción	descripcion-vy8u	\N	\N	\N	\N	\N	str
1908	2024-07-01 04:38:59.637+00	2024-07-01 04:38:59.637+00	f	\N	\N	Nombre del campo	nombre-del-campo-vd35	\N	\N	\N	\N	\N	str
1909	2024-07-01 04:38:59.643+00	2024-07-01 04:38:59.643+00	f	\N	\N	Nombre de Entidad 	nombre-de-entidad-dl9e	\N	\N	\N	\N	\N	str
1910	2024-07-01 04:38:59.656+00	2024-07-01 04:38:59.656+00	f	\N	\N	Número de Resolución o Informe	numero-de-resolucion-o-informe-6ifq	\N	\N	\N	\N	\N	str
1911	2024-07-01 04:38:59.663+00	2024-07-01 04:38:59.663+00	f	\N	\N	Fecha	fecha-rfay	\N	\N	\N	\N	\N	str
1912	2024-07-01 04:38:59.67+00	2024-07-01 04:38:59.67+00	f	\N	\N	Descripción	descripcion-cwau	\N	\N	\N	\N	\N	str
1913	2024-07-01 04:38:59.679+00	2024-07-01 04:38:59.679+00	f	\N	\N	Enlace 	enlace-lmw2	\N	\N	\N	\N	\N	str
1914	2024-07-01 04:38:59.693+00	2024-07-01 04:38:59.693+00	f	\N	\N	Nombre de Entidad 	nombre-de-entidad-hb11	\N	\N	\N	\N	\N	str
1915	2024-07-01 04:38:59.699+00	2024-07-01 04:38:59.699+00	f	\N	\N	Número de Resolución o Informe	numero-de-resolucion-o-informe-byt6	\N	\N	\N	\N	\N	str
1916	2024-07-01 04:38:59.706+00	2024-07-01 04:38:59.706+00	f	\N	\N	Fecha	fecha-ctg3	\N	\N	\N	\N	\N	str
1917	2024-07-01 04:38:59.715+00	2024-07-01 04:38:59.715+00	f	\N	\N	Descripción	descripcion-rmg8	\N	\N	\N	\N	\N	str
1918	2024-07-01 04:38:59.723+00	2024-07-01 04:38:59.723+00	f	\N	\N	Enlace 	enlace-2a4p	\N	\N	\N	\N	\N	str
1919	2024-07-01 04:38:59.736+00	2024-07-01 04:38:59.736+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-yi8l	\N	\N	\N	\N	\N	str
1920	2024-07-01 04:38:59.745+00	2024-07-01 04:38:59.745+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-py0j	\N	\N	\N	\N	\N	str
1921	2024-07-01 04:38:59.754+00	2024-07-01 04:38:59.754+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-wq3e	\N	\N	\N	\N	\N	str
1922	2024-07-01 04:38:59.764+00	2024-07-01 04:38:59.764+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-3onc	\N	\N	\N	\N	\N	str
1923	2024-07-01 04:38:59.772+00	2024-07-01 04:38:59.772+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-uyad	\N	\N	\N	\N	\N	str
1924	2024-07-01 04:38:59.781+00	2024-07-01 04:38:59.781+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-nzpw	\N	\N	\N	\N	\N	str
1925	2024-07-01 04:38:59.791+00	2024-07-01 04:38:59.791+00	f	\N	\N	LICENCIA	licencia-ybb3	\N	\N	\N	\N	\N	str
1926	2024-07-01 04:38:59.803+00	2024-07-01 04:38:59.803+00	f	\N	\N	Institución	institucion-r53r	\N	\N	\N	\N	\N	str
1927	2024-07-01 04:38:59.812+00	2024-07-01 04:38:59.812+00	f	\N	\N	Descripción	descripcion-a7b0	\N	\N	\N	\N	\N	str
1928	2024-07-01 04:38:59.82+00	2024-07-01 04:38:59.821+00	f	\N	\N	Nombre del campo	nombre-del-campo-vh1u	\N	\N	\N	\N	\N	str
1929	2024-07-01 04:38:59.829+00	2024-07-01 04:38:59.829+00	f	\N	\N	Nombre de Entidad 	nombre-de-entidad-mfom	\N	\N	\N	\N	\N	str
1930	2024-07-01 04:38:59.836+00	2024-07-01 04:38:59.836+00	f	\N	\N	Número de Resolución o Informe	numero-de-resolucion-o-informe-coen	\N	\N	\N	\N	\N	str
1931	2024-07-01 04:38:59.845+00	2024-07-01 04:38:59.845+00	f	\N	\N	Fecha	fecha-gqgl	\N	\N	\N	\N	\N	str
1932	2024-07-01 04:38:59.853+00	2024-07-01 04:38:59.853+00	f	\N	\N	Descripción	descripcion-3z8v	\N	\N	\N	\N	\N	str
1933	2024-07-01 04:38:59.86+00	2024-07-01 04:38:59.86+00	f	\N	\N	Enlace 	enlace-u489	\N	\N	\N	\N	\N	str
1934	2024-07-01 04:38:59.874+00	2024-07-01 04:38:59.874+00	f	\N	\N	EJERCICIO	ejercicio-llpl	\N	\N	\N	\N	\N	str
1935	2024-07-01 04:38:59.883+00	2024-07-01 04:38:59.883+00	f	\N	\N	ID_SECTORIAL	id_sectorial-6po0	\N	\N	\N	\N	\N	str
1936	2024-07-01 04:38:59.892+00	2024-07-01 04:38:59.892+00	f	\N	\N	SECTORIAL	sectorial-69mh	\N	\N	\N	\N	\N	str
1937	2024-07-01 04:38:59.899+00	2024-07-01 04:38:59.899+00	f	\N	\N	ID_GRUPO	id_grupo-fp3l	\N	\N	\N	\N	\N	str
1938	2024-07-01 04:38:59.907+00	2024-07-01 04:38:59.907+00	f	\N	\N	GRUPO	grupo-qox7	\N	\N	\N	\N	\N	str
1939	2024-07-01 04:38:59.917+00	2024-07-01 04:38:59.917+00	f	\N	\N	CODIFICADO	codificado-5cu0	\N	\N	\N	\N	\N	str
1940	2024-07-01 04:38:59.926+00	2024-07-01 04:38:59.926+00	f	\N	\N	PROFORMA	proforma-0pft	\N	\N	\N	\N	\N	str
1941	2024-07-01 04:38:59.942+00	2024-07-01 04:38:59.942+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-82mh	\N	\N	\N	\N	\N	str
1942	2024-07-01 04:38:59.951+00	2024-07-01 04:38:59.951+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-ocwk	\N	\N	\N	\N	\N	str
1943	2024-07-01 04:38:59.961+00	2024-07-01 04:38:59.961+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-tshc	\N	\N	\N	\N	\N	str
1944	2024-07-01 04:38:59.97+00	2024-07-01 04:38:59.97+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-xwek	\N	\N	\N	\N	\N	str
1945	2024-07-01 04:38:59.98+00	2024-07-01 04:38:59.98+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-ee72	\N	\N	\N	\N	\N	str
1946	2024-07-01 04:38:59.99+00	2024-07-01 04:38:59.99+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-iti5	\N	\N	\N	\N	\N	str
1947	2024-07-01 04:39:00+00	2024-07-01 04:39:00+00	f	\N	\N	LICENCIA	licencia-eewy	\N	\N	\N	\N	\N	str
1948	2024-07-01 04:39:00.042+00	2024-07-01 04:39:00.042+00	f	\N	\N	ENLACE PARA DIRECCIONAR A LA PROFORMA DEL PRESUPUESTO GENERAL DEL ESTADO 	enlace-para-direccionar-a-la-proforma-del-presupuesto-general-del-estado-alwm	\N	\N	\N	\N	\N	str
1949	2024-07-01 04:39:00.06+00	2024-07-01 04:39:00.06+00	f	\N	\N	Institución	institucion-rtzs	\N	\N	\N	\N	\N	str
1950	2024-07-01 04:39:00.07+00	2024-07-01 04:39:00.07+00	f	\N	\N	Descripción	descripcion-gk0b	\N	\N	\N	\N	\N	str
1951	2024-07-01 04:39:00.082+00	2024-07-01 04:39:00.082+00	f	\N	\N	Nombre del campo	nombre-del-campo-zqwe	\N	\N	\N	\N	\N	str
1952	2024-07-01 04:39:00.09+00	2024-07-01 04:39:00.09+00	f	\N	\N	EJERCICIO	ejercicio-xanw	\N	\N	\N	\N	\N	str
1953	2024-07-01 04:39:00.098+00	2024-07-01 04:39:00.098+00	f	\N	\N	ID_SECTORIAL	id_sectorial-np6y	\N	\N	\N	\N	\N	str
1954	2024-07-01 04:39:00.119+00	2024-07-01 04:39:00.119+00	f	\N	\N	SECTORIAL	sectorial-gu0m	\N	\N	\N	\N	\N	str
1955	2024-07-01 04:39:00.128+00	2024-07-01 04:39:00.129+00	f	\N	\N	ID_GRUPO	id_grupo-r0d4	\N	\N	\N	\N	\N	str
1956	2024-07-01 04:39:00.137+00	2024-07-01 04:39:00.137+00	f	\N	\N	GRUPO	grupo-779q	\N	\N	\N	\N	\N	str
1957	2024-07-01 04:39:00.145+00	2024-07-01 04:39:00.145+00	f	\N	\N	CODIFICADO	codificado-b8eo	\N	\N	\N	\N	\N	str
1958	2024-07-01 04:39:00.153+00	2024-07-01 04:39:00.153+00	f	\N	\N	PROFORMA	proforma-wx3x	\N	\N	\N	\N	\N	str
1959	2024-07-01 04:39:00.168+00	2024-07-01 04:39:00.168+00	f	\N	\N	EJERCICIO	ejercicio-9vdv	\N	\N	\N	\N	\N	str
1960	2024-07-01 04:39:00.177+00	2024-07-01 04:39:00.177+00	f	\N	\N	MES	mes-zwg3	\N	\N	\N	\N	\N	str
1961	2024-07-01 04:39:00.187+00	2024-07-01 04:39:00.187+00	f	\N	\N	SECTOR	sector-qobs	\N	\N	\N	\N	\N	str
1962	2024-07-01 04:39:00.196+00	2024-07-01 04:39:00.196+00	f	\N	\N	NOMBRE SECTOR	nombre-sector-ln77	\N	\N	\N	\N	\N	str
1963	2024-07-01 04:39:00.204+00	2024-07-01 04:39:00.205+00	f	\N	\N	CODIGO UDAF	codigo-udaf-jk6q	\N	\N	\N	\N	\N	str
1964	2024-07-01 04:39:00.213+00	2024-07-01 04:39:00.213+00	f	\N	\N	NOMBRE ENTIDAD	nombre-entidad-e2bl	\N	\N	\N	\N	\N	str
1965	2024-07-01 04:39:00.223+00	2024-07-01 04:39:00.223+00	f	\N	\N	CODIGO EOD	codigo-eod-jz3a	\N	\N	\N	\N	\N	str
1966	2024-07-01 04:39:00.233+00	2024-07-01 04:39:00.233+00	f	\N	\N	NOMBRE EOD	nombre-eod-zfba	\N	\N	\N	\N	\N	str
1967	2024-07-01 04:39:00.24+00	2024-07-01 04:39:00.24+00	f	\N	\N	GRUPO GASTO	grupo-gasto-xlv3	\N	\N	\N	\N	\N	str
1968	2024-07-01 04:39:00.249+00	2024-07-01 04:39:00.249+00	f	\N	\N	NOMBRE GRUPO	nombre-grupo-v4pf	\N	\N	\N	\N	\N	str
1969	2024-07-01 04:39:00.26+00	2024-07-01 04:39:00.26+00	f	\N	\N	TIPO PRESUPUESTO	tipo-presupuesto-8lh8	\N	\N	\N	\N	\N	str
1970	2024-07-01 04:39:00.27+00	2024-07-01 04:39:00.27+00	f	\N	\N	ITEM	item-rumc	\N	\N	\N	\N	\N	str
1971	2024-07-01 04:39:00.279+00	2024-07-01 04:39:00.28+00	f	\N	\N	NOMBRE ITEM	nombre-item-ji8u	\N	\N	\N	\N	\N	str
1972	2024-07-01 04:39:00.29+00	2024-07-01 04:39:00.29+00	f	\N	\N	INICIAL	inicial-y5ds	\N	\N	\N	\N	\N	str
1973	2024-07-01 04:39:00.301+00	2024-07-01 04:39:00.301+00	f	\N	\N	CODIFICADO	codificado-2lzq	\N	\N	\N	\N	\N	str
1974	2024-07-01 04:39:00.31+00	2024-07-01 04:39:00.31+00	f	\N	\N	COMPROMETIDO	comprometido-tyb7	\N	\N	\N	\N	\N	str
1975	2024-07-01 04:39:00.32+00	2024-07-01 04:39:00.32+00	f	\N	\N	DEVENGADO	devengado-elnu	\N	\N	\N	\N	\N	str
1976	2024-07-01 04:39:00.332+00	2024-07-01 04:39:00.332+00	f	\N	\N	PAGADO	pagado-xnh7	\N	\N	\N	\N	\N	str
1977	2024-07-01 04:39:00.347+00	2024-07-01 04:39:00.347+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-kfr0	\N	\N	\N	\N	\N	str
1978	2024-07-01 04:39:00.356+00	2024-07-01 04:39:00.356+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-ffjn	\N	\N	\N	\N	\N	str
1979	2024-07-01 04:39:00.366+00	2024-07-01 04:39:00.366+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-6ejb	\N	\N	\N	\N	\N	str
1980	2024-07-01 04:39:00.375+00	2024-07-01 04:39:00.375+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-djle	\N	\N	\N	\N	\N	str
1981	2024-07-01 04:39:00.385+00	2024-07-01 04:39:00.385+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-odoo	\N	\N	\N	\N	\N	str
1982	2024-07-01 04:39:00.395+00	2024-07-01 04:39:00.395+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-8u8e	\N	\N	\N	\N	\N	str
1983	2024-07-01 04:39:00.403+00	2024-07-01 04:39:00.403+00	f	\N	\N	LICENCIA	licencia-32gp	\N	\N	\N	\N	\N	str
1984	2024-07-01 04:39:00.412+00	2024-07-01 04:39:00.412+00	f	\N	\N	ENLACE PARA DIRECCIONAR A LA EJECUCIÓN DEL PRESUPUESTO GENERAL DEL ESTADO 	enlace-para-direccionar-a-la-ejecucion-del-presupuesto-general-del-estado-d3mj	\N	\N	\N	\N	\N	str
1985	2024-07-01 04:39:00.428+00	2024-07-01 04:39:00.428+00	f	\N	\N	Institución	institucion-ux87	\N	\N	\N	\N	\N	str
1986	2024-07-01 04:39:00.436+00	2024-07-01 04:39:00.436+00	f	\N	\N	Descripción	descripcion-xif1	\N	\N	\N	\N	\N	str
1987	2024-07-01 04:39:00.444+00	2024-07-01 04:39:00.444+00	f	\N	\N	Nombre del campo	nombre-del-campo-o9n6	\N	\N	\N	\N	\N	str
1988	2024-07-01 04:39:00.453+00	2024-07-01 04:39:00.453+00	f	\N	\N	Ejercicio	ejercicio-6smk	\N	\N	\N	\N	\N	str
1989	2024-07-01 04:39:00.464+00	2024-07-01 04:39:00.464+00	f	\N	\N	Mes	mes-d1mm	\N	\N	\N	\N	\N	str
1990	2024-07-01 04:39:00.472+00	2024-07-01 04:39:00.472+00	f	\N	\N	Sector	sector-6jwc	\N	\N	\N	\N	\N	str
1991	2024-07-01 04:39:00.481+00	2024-07-01 04:39:00.481+00	f	\N	\N	Nombre Sector	nombre-sector-1u6a	\N	\N	\N	\N	\N	str
1992	2024-07-01 04:39:00.491+00	2024-07-01 04:39:00.491+00	f	\N	\N	Código UDAF	codigo-udaf-qf0p	\N	\N	\N	\N	\N	str
1993	2024-07-01 04:39:00.5+00	2024-07-01 04:39:00.5+00	f	\N	\N	Nombre Entidad	nombre-entidad-i50l	\N	\N	\N	\N	\N	str
1994	2024-07-01 04:39:00.511+00	2024-07-01 04:39:00.511+00	f	\N	\N	Código EOD	codigo-eod-ulrq	\N	\N	\N	\N	\N	str
1995	2024-07-01 04:39:00.521+00	2024-07-01 04:39:00.521+00	f	\N	\N	Nombre EOD	nombre-eod-gecm	\N	\N	\N	\N	\N	str
1996	2024-07-01 04:39:00.532+00	2024-07-01 04:39:00.532+00	f	\N	\N	Grupo Gasto	grupo-gasto-7cel	\N	\N	\N	\N	\N	str
1997	2024-07-01 04:39:00.54+00	2024-07-01 04:39:00.54+00	f	\N	\N	Nombre Grupo	nombre-grupo-tly1	\N	\N	\N	\N	\N	str
1998	2024-07-01 04:39:00.549+00	2024-07-01 04:39:00.55+00	f	\N	\N	Tipo Presupuesto	tipo-presupuesto-m84c	\N	\N	\N	\N	\N	str
1999	2024-07-01 04:39:00.559+00	2024-07-01 04:39:00.559+00	f	\N	\N	Item	item-vofv	\N	\N	\N	\N	\N	str
2000	2024-07-01 04:39:00.568+00	2024-07-01 04:39:00.568+00	f	\N	\N	Nombre Item	nombre-item-y040	\N	\N	\N	\N	\N	str
2001	2024-07-01 04:39:00.576+00	2024-07-01 04:39:00.577+00	f	\N	\N	Inicial	inicial-i4jg	\N	\N	\N	\N	\N	str
2002	2024-07-01 04:39:00.586+00	2024-07-01 04:39:00.586+00	f	\N	\N	Codificado	codificado-dfb4	\N	\N	\N	\N	\N	str
2003	2024-07-01 04:39:00.595+00	2024-07-01 04:39:00.595+00	f	\N	\N	Comprometido	comprometido-6mfj	\N	\N	\N	\N	\N	str
2004	2024-07-01 04:39:00.603+00	2024-07-01 04:39:00.603+00	f	\N	\N	Devengado	devengado-2y88	\N	\N	\N	\N	\N	str
2005	2024-07-01 04:39:00.612+00	2024-07-01 04:39:00.612+00	f	\N	\N	Pagado	pagado-u1yo	\N	\N	\N	\N	\N	str
2006	2024-07-01 04:39:00.628+00	2024-07-01 04:39:00.629+00	f	\N	\N	AÑO	ano-yegd	\N	\N	\N	\N	\N	str
2007	2024-07-01 04:39:00.638+00	2024-07-01 04:39:00.638+00	f	\N	\N	SECTORIAL	sectorial-iznc	\N	\N	\N	\N	\N	str
2008	2024-07-01 04:39:00.646+00	2024-07-01 04:39:00.646+00	f	\N	\N	GRUPO	grupo-uyeq	\N	\N	\N	\N	\N	str
2009	2024-07-01 04:39:00.655+00	2024-07-01 04:39:00.655+00	f	\N	\N	CODIFICADO	codificado-dojx	\N	\N	\N	\N	\N	str
2010	2024-07-01 04:39:00.664+00	2024-07-01 04:39:00.664+00	f	\N	\N	DEVENGADO	devengado-41vs	\N	\N	\N	\N	\N	str
2011	2024-07-01 04:39:00.678+00	2024-07-01 04:39:00.678+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-gxek	\N	\N	\N	\N	\N	str
2012	2024-07-01 04:39:00.686+00	2024-07-01 04:39:00.686+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-g4xn	\N	\N	\N	\N	\N	str
2013	2024-07-01 04:39:00.697+00	2024-07-01 04:39:00.697+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-rygc	\N	\N	\N	\N	\N	str
2014	2024-07-01 04:39:00.705+00	2024-07-01 04:39:00.705+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-rs6l	\N	\N	\N	\N	\N	str
2015	2024-07-01 04:39:00.714+00	2024-07-01 04:39:00.714+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-8rkb	\N	\N	\N	\N	\N	str
2016	2024-07-01 04:39:00.723+00	2024-07-01 04:39:00.723+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-59s3	\N	\N	\N	\N	\N	str
2017	2024-07-01 04:39:00.733+00	2024-07-01 04:39:00.733+00	f	\N	\N	LICENCIA	licencia-2cx8	\N	\N	\N	\N	\N	str
2018	2024-07-01 04:39:00.74+00	2024-07-01 04:39:00.74+00	f	\N	\N	ENLACE PARA DIRECCIONAR AL PRESUPUESTO HISTÓRICO	enlace-para-direccionar-al-presupuesto-historico-t5nj	\N	\N	\N	\N	\N	str
2019	2024-07-01 04:39:00.757+00	2024-07-01 04:39:00.757+00	f	\N	\N	Institución	institucion-n4y4	\N	\N	\N	\N	\N	str
2020	2024-07-01 04:39:00.768+00	2024-07-01 04:39:00.769+00	f	\N	\N	Descripción	descripcion-x0ps	\N	\N	\N	\N	\N	str
2021	2024-07-01 04:39:00.778+00	2024-07-01 04:39:00.779+00	f	\N	\N	Nombre del campo	nombre-del-campo-arnv	\N	\N	\N	\N	\N	str
2022	2024-07-01 04:39:00.792+00	2024-07-01 04:39:00.792+00	f	\N	\N	AÑO	ano-w2x7	\N	\N	\N	\N	\N	str
2023	2024-07-01 04:39:00.802+00	2024-07-01 04:39:00.802+00	f	\N	\N	SECTORIAL	sectorial-fi4i	\N	\N	\N	\N	\N	str
2024	2024-07-01 04:39:00.811+00	2024-07-01 04:39:00.811+00	f	\N	\N	GRUPO	grupo-u3ob	\N	\N	\N	\N	\N	str
2025	2024-07-01 04:39:00.823+00	2024-07-01 04:39:00.823+00	f	\N	\N	CODIFICADO	codificado-v4gb	\N	\N	\N	\N	\N	str
2026	2024-07-01 04:39:00.834+00	2024-07-01 04:39:00.834+00	f	\N	\N	DEVENGADO	devengado-4l9e	\N	\N	\N	\N	\N	str
2027	2024-07-01 04:39:00.851+00	2024-07-01 04:39:00.851+00	f	\N	\N	EJERCICIO	ejercicio-ad9b	\N	\N	\N	\N	\N	str
2028	2024-07-01 04:39:00.863+00	2024-07-01 04:39:00.863+00	f	\N	\N	GRUPO	grupo-asnl	\N	\N	\N	\N	\N	str
2029	2024-07-01 04:39:00.872+00	2024-07-01 04:39:00.872+00	f	\N	\N	ID CUENTA	id-cuenta-0ioy	\N	\N	\N	\N	\N	str
2030	2024-07-01 04:39:00.884+00	2024-07-01 04:39:00.884+00	f	\N	\N	SUBGRUPO	subgrupo-ulx0	\N	\N	\N	\N	\N	str
2031	2024-07-01 04:39:00.898+00	2024-07-01 04:39:00.898+00	f	\N	\N	DENOMINACIÓN	denominacion-2zdd	\N	\N	\N	\N	\N	str
2032	2024-07-01 04:39:00.907+00	2024-07-01 04:39:00.907+00	f	\N	\N	TOTAL	total-7q52	\N	\N	\N	\N	\N	str
2033	2024-07-01 04:39:00.927+00	2024-07-01 04:39:00.927+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-31x5	\N	\N	\N	\N	\N	str
2034	2024-07-01 04:39:00.94+00	2024-07-01 04:39:00.94+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-2kq4	\N	\N	\N	\N	\N	str
2035	2024-07-01 04:39:00.952+00	2024-07-01 04:39:00.952+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-8am4	\N	\N	\N	\N	\N	str
2036	2024-07-01 04:39:00.965+00	2024-07-01 04:39:00.965+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-03vt	\N	\N	\N	\N	\N	str
2037	2024-07-01 04:39:00.975+00	2024-07-01 04:39:00.975+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-3po0	\N	\N	\N	\N	\N	str
2038	2024-07-01 04:39:00.987+00	2024-07-01 04:39:00.987+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-p1wz	\N	\N	\N	\N	\N	str
2039	2024-07-01 04:39:00.998+00	2024-07-01 04:39:00.998+00	f	\N	\N	LICENCIA	licencia-zjtj	\N	\N	\N	\N	\N	str
2168	2024-07-01 04:39:02.232+00	2024-07-01 04:39:02.232+00	f	\N	\N	Nombre del campo	nombre-del-campo-fxxx	\N	\N	\N	\N	\N	str
2040	2024-07-01 04:39:01.007+00	2024-07-01 04:39:01.007+00	f	\N	\N	ENLACE PARA DIRECCIONAR AL ESTADO DE SITUACIÓN FINANCIERA 	enlace-para-direccionar-al-estado-de-situacion-financiera-9czd	\N	\N	\N	\N	\N	str
2041	2024-07-01 04:39:01.03+00	2024-07-01 04:39:01.03+00	f	\N	\N	Institución	institucion-9tgl	\N	\N	\N	\N	\N	str
2042	2024-07-01 04:39:01.041+00	2024-07-01 04:39:01.041+00	f	\N	\N	Descripción	descripcion-r8ya	\N	\N	\N	\N	\N	str
2043	2024-07-01 04:39:01.053+00	2024-07-01 04:39:01.053+00	f	\N	\N	Nombre del campo	nombre-del-campo-j7jk	\N	\N	\N	\N	\N	str
2044	2024-07-01 04:39:01.064+00	2024-07-01 04:39:01.065+00	f	\N	\N	EJERCICIO	ejercicio-rzq8	\N	\N	\N	\N	\N	str
2045	2024-07-01 04:39:01.073+00	2024-07-01 04:39:01.073+00	f	\N	\N	GRUPO	grupo-3sc1	\N	\N	\N	\N	\N	str
2046	2024-07-01 04:39:01.084+00	2024-07-01 04:39:01.084+00	f	\N	\N	ID CUENTA	id-cuenta-z8ws	\N	\N	\N	\N	\N	str
2047	2024-07-01 04:39:01.094+00	2024-07-01 04:39:01.094+00	f	\N	\N	SUBGRUPO	subgrupo-cwfm	\N	\N	\N	\N	\N	str
2048	2024-07-01 04:39:01.102+00	2024-07-01 04:39:01.102+00	f	\N	\N	DENOMINACIÓN	denominacion-flqw	\N	\N	\N	\N	\N	str
2049	2024-07-01 04:39:01.111+00	2024-07-01 04:39:01.111+00	f	\N	\N	TOTAL	total-c0s8	\N	\N	\N	\N	\N	str
2050	2024-07-01 04:39:01.13+00	2024-07-01 04:39:01.13+00	f	\N	\N	Fecha	fecha-hmnw	\N	\N	\N	\N	\N	str
2051	2024-07-01 04:39:01.138+00	2024-07-01 04:39:01.138+00	f	\N	\N	GAD o Entidad	gad-o-entidad-3kjz	\N	\N	\N	\N	\N	str
2052	2024-07-01 04:39:01.146+00	2024-07-01 04:39:01.146+00	f	\N	\N	Tipo	tipo-nnc5	\N	\N	\N	\N	\N	str
2053	2024-07-01 04:39:01.156+00	2024-07-01 04:39:01.156+00	f	\N	\N	Título	titulo-uej9	\N	\N	\N	\N	\N	str
2054	2024-07-01 04:39:01.166+00	2024-07-01 04:39:01.166+00	f	\N	\N	Enlace 	enlace-g3ls	\N	\N	\N	\N	\N	str
2055	2024-07-01 04:39:01.179+00	2024-07-01 04:39:01.179+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN	fecha-actualizacion-de-la-informacion-twpa	\N	\N	\N	\N	\N	str
2056	2024-07-01 04:39:01.188+00	2024-07-01 04:39:01.188+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN	periodicidad-de-actualizacion-de-la-informacion-8pcj	\N	\N	\N	\N	\N	str
2057	2024-07-01 04:39:01.197+00	2024-07-01 04:39:01.197+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN	unidad-poseedora-de-la-informacion-qh2r	\N	\N	\N	\N	\N	str
2058	2024-07-01 04:39:01.205+00	2024-07-01 04:39:01.205+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	persona-responsable-de-la-unidad-poseedora-de-la-informacion-6hxz	\N	\N	\N	\N	\N	str
2059	2024-07-01 04:39:01.213+00	2024-07-01 04:39:01.213+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-d4v8	\N	\N	\N	\N	\N	str
2060	2024-07-01 04:39:01.223+00	2024-07-01 04:39:01.223+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-2wm9	\N	\N	\N	\N	\N	str
2061	2024-07-01 04:39:01.233+00	2024-07-01 04:39:01.233+00	f	\N	\N	LICENCIA	licencia-lok3	\N	\N	\N	\N	\N	str
2062	2024-07-01 04:39:01.245+00	2024-07-01 04:39:01.245+00	f	\N	\N	Institución	institucion-2797	\N	\N	\N	\N	\N	str
2063	2024-07-01 04:39:01.254+00	2024-07-01 04:39:01.254+00	f	\N	\N	Descripción	descripcion-baa2	\N	\N	\N	\N	\N	str
2064	2024-07-01 04:39:01.262+00	2024-07-01 04:39:01.262+00	f	\N	\N	Nombre del campo	nombre-del-campo-q1tt	\N	\N	\N	\N	\N	str
2065	2024-07-01 04:39:01.27+00	2024-07-01 04:39:01.27+00	f	\N	\N	Fecha	fecha-gg7w	\N	\N	\N	\N	\N	str
2066	2024-07-01 04:39:01.28+00	2024-07-01 04:39:01.28+00	f	\N	\N	GAD o Entidad	gad-o-entidad-cegn	\N	\N	\N	\N	\N	str
2067	2024-07-01 04:39:01.29+00	2024-07-01 04:39:01.29+00	f	\N	\N	Tipo	tipo-73kz	\N	\N	\N	\N	\N	str
2068	2024-07-01 04:39:01.298+00	2024-07-01 04:39:01.298+00	f	\N	\N	Título	titulo-8d8u	\N	\N	\N	\N	\N	str
2069	2024-07-01 04:39:01.305+00	2024-07-01 04:39:01.305+00	f	\N	\N	Enlace 	enlace-nqo3	\N	\N	\N	\N	\N	str
2070	2024-07-01 04:39:01.321+00	2024-07-01 04:39:01.321+00	f	\N	\N	Fecha	fecha-ty3w	\N	\N	\N	\N	\N	str
2071	2024-07-01 04:39:01.331+00	2024-07-01 04:39:01.331+00	f	\N	\N	GAD o Entidad	gad-o-entidad-suex	\N	\N	\N	\N	\N	str
2072	2024-07-01 04:39:01.339+00	2024-07-01 04:39:01.339+00	f	\N	\N	Tipo	tipo-q3vz	\N	\N	\N	\N	\N	str
2073	2024-07-01 04:39:01.347+00	2024-07-01 04:39:01.347+00	f	\N	\N	Título	titulo-k2i0	\N	\N	\N	\N	\N	str
2074	2024-07-01 04:39:01.357+00	2024-07-01 04:39:01.357+00	f	\N	\N	Enlace	enlace-htjl	\N	\N	\N	\N	\N	str
2075	2024-07-01 04:39:01.372+00	2024-07-01 04:39:01.372+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN	fecha-actualizacion-de-la-informacion-rqzc	\N	\N	\N	\N	\N	str
2076	2024-07-01 04:39:01.381+00	2024-07-01 04:39:01.381+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN	periodicidad-de-actualizacion-de-la-informacion-npa8	\N	\N	\N	\N	\N	str
2077	2024-07-01 04:39:01.391+00	2024-07-01 04:39:01.391+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN	unidad-poseedora-de-la-informacion-l5dy	\N	\N	\N	\N	\N	str
2078	2024-07-01 04:39:01.4+00	2024-07-01 04:39:01.4+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	persona-responsable-de-la-unidad-poseedora-de-la-informacion-jfeu	\N	\N	\N	\N	\N	str
2079	2024-07-01 04:39:01.408+00	2024-07-01 04:39:01.408+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-eijr	\N	\N	\N	\N	\N	str
2080	2024-07-01 04:39:01.419+00	2024-07-01 04:39:01.419+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-fdk5	\N	\N	\N	\N	\N	str
2081	2024-07-01 04:39:01.43+00	2024-07-01 04:39:01.43+00	f	\N	\N	LICENCIA	licencia-fg3v	\N	\N	\N	\N	\N	str
2082	2024-07-01 04:39:01.445+00	2024-07-01 04:39:01.445+00	f	\N	\N	Institución	institucion-yaqd	\N	\N	\N	\N	\N	str
2083	2024-07-01 04:39:01.456+00	2024-07-01 04:39:01.456+00	f	\N	\N	Descripción	descripcion-lqzh	\N	\N	\N	\N	\N	str
2084	2024-07-01 04:39:01.467+00	2024-07-01 04:39:01.467+00	f	\N	\N	Nombre del campo	nombre-del-campo-xbjs	\N	\N	\N	\N	\N	str
2085	2024-07-01 04:39:01.476+00	2024-07-01 04:39:01.476+00	f	\N	\N	Fecha	fecha-o7jg	\N	\N	\N	\N	\N	str
2086	2024-07-01 04:39:01.488+00	2024-07-01 04:39:01.488+00	f	\N	\N	GAD o Entidad	gad-o-entidad-gbva	\N	\N	\N	\N	\N	str
2087	2024-07-01 04:39:01.499+00	2024-07-01 04:39:01.499+00	f	\N	\N	Tipo	tipo-z1by	\N	\N	\N	\N	\N	str
2088	2024-07-01 04:39:01.508+00	2024-07-01 04:39:01.508+00	f	\N	\N	Título	titulo-ivn8	\N	\N	\N	\N	\N	str
2089	2024-07-01 04:39:01.517+00	2024-07-01 04:39:01.517+00	f	\N	\N	Enlace Acta	enlace-acta-v9iv	\N	\N	\N	\N	\N	str
2090	2024-07-01 04:39:01.535+00	2024-07-01 04:39:01.535+00	f	\N	\N	Número de Proceso	numero-de-proceso-zyhb	\N	\N	\N	\N	\N	str
2091	2024-07-01 04:39:01.544+00	2024-07-01 04:39:01.544+00	f	\N	\N	Fecha de ingreso	fecha-de-ingreso-6n6z	\N	\N	\N	\N	\N	str
2092	2024-07-01 04:39:01.553+00	2024-07-01 04:39:01.553+00	f	\N	\N	Materia	materia-02b6	\N	\N	\N	\N	\N	str
2093	2024-07-01 04:39:01.562+00	2024-07-01 04:39:01.562+00	f	\N	\N	Delito o Asunto	delito-o-asunto-shgz	\N	\N	\N	\N	\N	str
2094	2024-07-01 04:39:01.569+00	2024-07-01 04:39:01.569+00	f	\N	\N	Tipo de acción	tipo-de-accion-ze72	\N	\N	\N	\N	\N	str
2095	2024-07-01 04:39:01.578+00	2024-07-01 04:39:01.578+00	f	\N	\N	Provincia	provincia-sbhq	\N	\N	\N	\N	\N	str
2096	2024-07-01 04:39:01.588+00	2024-07-01 04:39:01.588+00	f	\N	\N	Cantón	canton-u3ei	\N	\N	\N	\N	\N	str
2097	2024-07-01 04:39:01.597+00	2024-07-01 04:39:01.597+00	f	\N	\N	Dependencia Jurisdiccional	dependencia-jurisdiccional-myv2	\N	\N	\N	\N	\N	str
2098	2024-07-01 04:39:01.605+00	2024-07-01 04:39:01.605+00	f	\N	\N	Estado	estado-toyi	\N	\N	\N	\N	\N	str
2099	2024-07-01 04:39:01.611+00	2024-07-01 04:39:01.611+00	f	\N	\N	Resumen de Sentencia	resumen-de-sentencia-ii1j	\N	\N	\N	\N	\N	str
2100	2024-07-01 04:39:01.621+00	2024-07-01 04:39:01.621+00	f	\N	\N	Enlace al Texto Íntegro del Proceso y Sentencia	enlace-al-texto-integro-del-proceso-y-sentencia-6dgd	\N	\N	\N	\N	\N	str
2101	2024-07-01 04:39:01.634+00	2024-07-01 04:39:01.634+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN	fecha-actualizacion-de-la-informacion-0uq7	\N	\N	\N	\N	\N	str
2102	2024-07-01 04:39:01.641+00	2024-07-01 04:39:01.641+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN	periodicidad-de-actualizacion-de-la-informacion-l27v	\N	\N	\N	\N	\N	str
2103	2024-07-01 04:39:01.649+00	2024-07-01 04:39:01.649+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN	unidad-poseedora-de-la-informacion-hx5i	\N	\N	\N	\N	\N	str
2104	2024-07-01 04:39:01.657+00	2024-07-01 04:39:01.657+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	persona-responsable-de-la-unidad-poseedora-de-la-informacion-ui7h	\N	\N	\N	\N	\N	str
2105	2024-07-01 04:39:01.665+00	2024-07-01 04:39:01.665+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-t42z	\N	\N	\N	\N	\N	str
2418	2024-07-01 04:39:04.406+00	2024-07-01 04:39:04.406+00	f	\N	\N	Asistencia	asistencia-ja6q	\N	\N	\N	\N	\N	str
2106	2024-07-01 04:39:01.672+00	2024-07-01 04:39:01.672+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-0hc4	\N	\N	\N	\N	\N	str
2107	2024-07-01 04:39:01.679+00	2024-07-01 04:39:01.679+00	f	\N	\N	LICENCIA	licencia-f48r	\N	\N	\N	\N	\N	str
2108	2024-07-01 04:39:01.689+00	2024-07-01 04:39:01.69+00	f	\N	\N	ENLACE A CONSULTAS DE PROCESOS JUDICIALES ELECTRÓNICOS E-SATJE	enlace-a-consultas-de-procesos-judiciales-electronicos-e-satje-vt8x	\N	\N	\N	\N	\N	str
2109	2024-07-01 04:39:01.701+00	2024-07-01 04:39:01.701+00	f	\N	\N	Institución	institucion-ew5c	\N	\N	\N	\N	\N	str
2110	2024-07-01 04:39:01.708+00	2024-07-01 04:39:01.708+00	f	\N	\N	Descripción	descripcion-0fy8	\N	\N	\N	\N	\N	str
2111	2024-07-01 04:39:01.717+00	2024-07-01 04:39:01.717+00	f	\N	\N	Nombre del campo	nombre-del-campo-2ibb	\N	\N	\N	\N	\N	str
2112	2024-07-01 04:39:01.726+00	2024-07-01 04:39:01.726+00	f	\N	\N	Número de Proceso	numero-de-proceso-wgtl	\N	\N	\N	\N	\N	str
2113	2024-07-01 04:39:01.734+00	2024-07-01 04:39:01.734+00	f	\N	\N	Fecha de ingreso	fecha-de-ingreso-rwlg	\N	\N	\N	\N	\N	str
2114	2024-07-01 04:39:01.742+00	2024-07-01 04:39:01.742+00	f	\N	\N	Materia	materia-qwj9	\N	\N	\N	\N	\N	str
2115	2024-07-01 04:39:01.75+00	2024-07-01 04:39:01.75+00	f	\N	\N	Delito o Asunto	delito-o-asunto-u074	\N	\N	\N	\N	\N	str
2116	2024-07-01 04:39:01.759+00	2024-07-01 04:39:01.759+00	f	\N	\N	Tipo de acción	tipo-de-accion-2rpe	\N	\N	\N	\N	\N	str
2117	2024-07-01 04:39:01.767+00	2024-07-01 04:39:01.767+00	f	\N	\N	Provincia	provincia-s35j	\N	\N	\N	\N	\N	str
2118	2024-07-01 04:39:01.774+00	2024-07-01 04:39:01.774+00	f	\N	\N	Cantón	canton-lnaq	\N	\N	\N	\N	\N	str
2119	2024-07-01 04:39:01.783+00	2024-07-01 04:39:01.783+00	f	\N	\N	Dependencia Jurisdiccional	dependencia-jurisdiccional-sh2p	\N	\N	\N	\N	\N	str
2120	2024-07-01 04:39:01.792+00	2024-07-01 04:39:01.792+00	f	\N	\N	Estado	estado-5lba	\N	\N	\N	\N	\N	str
2121	2024-07-01 04:39:01.8+00	2024-07-01 04:39:01.8+00	f	\N	\N	Resumen de Sentencia	resumen-de-sentencia-k8cc	\N	\N	\N	\N	\N	str
2122	2024-07-01 04:39:01.807+00	2024-07-01 04:39:01.807+00	f	\N	\N	Enlace al Texto Íntegro del Proceso y Sentencia	enlace-al-texto-integro-del-proceso-y-sentencia-lq82	\N	\N	\N	\N	\N	str
2123	2024-07-01 04:39:01.824+00	2024-07-01 04:39:01.824+00	f	\N	\N	Número de causa	numero-de-causa-q8ym	\N	\N	\N	\N	\N	str
2124	2024-07-01 04:39:01.832+00	2024-07-01 04:39:01.832+00	f	\N	\N	Año	ano-yoge	\N	\N	\N	\N	\N	str
2125	2024-07-01 04:39:01.839+00	2024-07-01 04:39:01.839+00	f	\N	\N	Fecha	fecha-vfqb	\N	\N	\N	\N	\N	str
2126	2024-07-01 04:39:01.846+00	2024-07-01 04:39:01.846+00	f	\N	\N	Provincia	provincia-1adh	\N	\N	\N	\N	\N	str
2127	2024-07-01 04:39:01.855+00	2024-07-01 04:39:01.855+00	f	\N	\N	Accionante	accionante-9q23	\N	\N	\N	\N	\N	str
2128	2024-07-01 04:39:01.863+00	2024-07-01 04:39:01.863+00	f	\N	\N	Accionado	accionado-g6fu	\N	\N	\N	\N	\N	str
2129	2024-07-01 04:39:01.87+00	2024-07-01 04:39:01.87+00	f	\N	\N	Tipo de Causa	tipo-de-causa-zmeh	\N	\N	\N	\N	\N	str
2130	2024-07-01 04:39:01.877+00	2024-07-01 04:39:01.877+00	f	\N	\N	Organización Política	organizacion-politica-dj0m	\N	\N	\N	\N	\N	str
2131	2024-07-01 04:39:01.886+00	2024-07-01 04:39:01.886+00	f	\N	\N	Enlace a Sentencia	enlace-a-sentencia-cvd0	\N	\N	\N	\N	\N	str
2132	2024-07-01 04:39:01.9+00	2024-07-01 04:39:01.9+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-aqff	\N	\N	\N	\N	\N	str
2133	2024-07-01 04:39:01.907+00	2024-07-01 04:39:01.907+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-550x	\N	\N	\N	\N	\N	str
2134	2024-07-01 04:39:01.915+00	2024-07-01 04:39:01.915+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-cy1l	\N	\N	\N	\N	\N	str
2135	2024-07-01 04:39:01.923+00	2024-07-01 04:39:01.923+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-ctom	\N	\N	\N	\N	\N	str
2136	2024-07-01 04:39:01.931+00	2024-07-01 04:39:01.931+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-4d5x	\N	\N	\N	\N	\N	str
2137	2024-07-01 04:39:01.938+00	2024-07-01 04:39:01.938+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-ta9i	\N	\N	\N	\N	\N	str
2138	2024-07-01 04:39:01.946+00	2024-07-01 04:39:01.946+00	f	\N	\N	LICENCIA	licencia-diy2	\N	\N	\N	\N	\N	str
2139	2024-07-01 04:39:01.959+00	2024-07-01 04:39:01.959+00	f	\N	\N	Institución	institucion-6ltw	\N	\N	\N	\N	\N	str
2140	2024-07-01 04:39:01.966+00	2024-07-01 04:39:01.966+00	f	\N	\N	Descripción	descripcion-vs4e	\N	\N	\N	\N	\N	str
2141	2024-07-01 04:39:01.973+00	2024-07-01 04:39:01.973+00	f	\N	\N	Nombre del campo	nombre-del-campo-h6qh	\N	\N	\N	\N	\N	str
2142	2024-07-01 04:39:01.981+00	2024-07-01 04:39:01.981+00	f	\N	\N	Número de Causa	numero-de-causa-lwjt	\N	\N	\N	\N	\N	str
2143	2024-07-01 04:39:01.99+00	2024-07-01 04:39:01.99+00	f	\N	\N	Año	ano-vy8e	\N	\N	\N	\N	\N	str
2144	2024-07-01 04:39:01.998+00	2024-07-01 04:39:01.998+00	f	\N	\N	Fecha	fecha-ciun	\N	\N	\N	\N	\N	str
2145	2024-07-01 04:39:02.005+00	2024-07-01 04:39:02.005+00	f	\N	\N	Provincia	provincia-h2w5	\N	\N	\N	\N	\N	str
2146	2024-07-01 04:39:02.013+00	2024-07-01 04:39:02.013+00	f	\N	\N	Accionante	accionante-bjq3	\N	\N	\N	\N	\N	str
2147	2024-07-01 04:39:02.023+00	2024-07-01 04:39:02.023+00	f	\N	\N	Accionado	accionado-lxag	\N	\N	\N	\N	\N	str
2148	2024-07-01 04:39:02.032+00	2024-07-01 04:39:02.032+00	f	\N	\N	Tipo de causa	tipo-de-causa-8ojy	\N	\N	\N	\N	\N	str
2149	2024-07-01 04:39:02.04+00	2024-07-01 04:39:02.04+00	f	\N	\N	Organización Política	organizacion-politica-wbnk	\N	\N	\N	\N	\N	str
2150	2024-07-01 04:39:02.048+00	2024-07-01 04:39:02.048+00	f	\N	\N	Enlace a Sentencia	enlace-a-sentencia-i0x0	\N	\N	\N	\N	\N	str
2151	2024-07-01 04:39:02.066+00	2024-07-01 04:39:02.067+00	f	\N	\N	Organización política, candidato/a	organizacion-politica-candidatoa-0ao2	\N	\N	\N	\N	\N	str
2152	2024-07-01 04:39:02.075+00	2024-07-01 04:39:02.075+00	f	\N	\N	Proceso Electoral	proceso-electoral-42v3	\N	\N	\N	\N	\N	str
2153	2024-07-01 04:39:02.085+00	2024-07-01 04:39:02.085+00	f	\N	\N	Dignidad	dignidad-7y8h	\N	\N	\N	\N	\N	str
2154	2024-07-01 04:39:02.095+00	2024-07-01 04:39:02.095+00	f	\N	\N	Monto recibido	monto-recibido-6ccg	\N	\N	\N	\N	\N	str
2155	2024-07-01 04:39:02.104+00	2024-07-01 04:39:02.104+00	f	\N	\N	Monto gastado	monto-gastado-j3ct	\N	\N	\N	\N	\N	str
2156	2024-07-01 04:39:02.12+00	2024-07-01 04:39:02.12+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-gbki	\N	\N	\N	\N	\N	str
2157	2024-07-01 04:39:02.13+00	2024-07-01 04:39:02.13+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-934e	\N	\N	\N	\N	\N	str
2158	2024-07-01 04:39:02.139+00	2024-07-01 04:39:02.139+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-waac	\N	\N	\N	\N	\N	str
2159	2024-07-01 04:39:02.148+00	2024-07-01 04:39:02.148+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-yvku	\N	\N	\N	\N	\N	str
2160	2024-07-01 04:39:02.158+00	2024-07-01 04:39:02.158+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-y3q7	\N	\N	\N	\N	\N	str
2161	2024-07-01 04:39:02.168+00	2024-07-01 04:39:02.168+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-y6nf	\N	\N	\N	\N	\N	str
2162	2024-07-01 04:39:02.177+00	2024-07-01 04:39:02.177+00	f	\N	\N	LICENCIA	licencia-e3fl	\N	\N	\N	\N	\N	str
2163	2024-07-01 04:39:02.187+00	2024-07-01 04:39:02.187+00	f	\N	\N	Enlace para direccionar a los planes de trabajo de las candidatas y candidatos a las distintas elecciones	enlace-para-direccionar-a-los-planes-de-trabajo-de-las-candidatas-y-candidatos-a-las-distintas-elecciones-y7q0	\N	\N	\N	\N	\N	str
2164	2024-07-01 04:39:02.196+00	2024-07-01 04:39:02.196+00	f	\N	\N	Enlace para direccionar a los resultados de los procesos electorales	enlace-para-direccionar-a-los-resultados-de-los-procesos-electorales-lcma	\N	\N	\N	\N	\N	str
2165	2024-07-01 04:39:02.202+00	2024-07-01 04:39:02.202+00	f	\N	\N	Enlace para direccionar a las actas de cada junta y recinto electoral 	enlace-para-direccionar-a-las-actas-de-cada-junta-y-recinto-electoral-brba	\N	\N	\N	\N	\N	str
2166	2024-07-01 04:39:02.215+00	2024-07-01 04:39:02.215+00	f	\N	\N	Institución	institucion-5t7k	\N	\N	\N	\N	\N	str
2167	2024-07-01 04:39:02.223+00	2024-07-01 04:39:02.223+00	f	\N	\N	Descripción	descripcion-idkw	\N	\N	\N	\N	\N	str
2169	2024-07-01 04:39:02.239+00	2024-07-01 04:39:02.239+00	f	\N	\N	Organización política, candidato/a	organizacion-politica-candidatoa-kzgl	\N	\N	\N	\N	\N	str
2170	2024-07-01 04:39:02.247+00	2024-07-01 04:39:02.247+00	f	\N	\N	Proceso Electoral	proceso-electoral-ircz	\N	\N	\N	\N	\N	str
2171	2024-07-01 04:39:02.257+00	2024-07-01 04:39:02.257+00	f	\N	\N	Dignidad	dignidad-q640	\N	\N	\N	\N	\N	str
2172	2024-07-01 04:39:02.266+00	2024-07-01 04:39:02.266+00	f	\N	\N	Monto recibido	monto-recibido-t0nw	\N	\N	\N	\N	\N	str
2173	2024-07-01 04:39:02.272+00	2024-07-01 04:39:02.272+00	f	\N	\N	Monto gastado	monto-gastado-e9mh	\N	\N	\N	\N	\N	str
2174	2024-07-01 04:39:02.287+00	2024-07-01 04:39:02.287+00	f	\N	\N	Organización Política o Alianza	organizacion-politica-o-alianza-0e9f	\N	\N	\N	\N	\N	str
2175	2024-07-01 04:39:02.296+00	2024-07-01 04:39:02.296+00	f	\N	\N	Proceso Electoral	proceso-electoral-8rg1	\N	\N	\N	\N	\N	str
2176	2024-07-01 04:39:02.303+00	2024-07-01 04:39:02.303+00	f	\N	\N	Mes	mes-vh5a	\N	\N	\N	\N	\N	str
2177	2024-07-01 04:39:02.31+00	2024-07-01 04:39:02.31+00	f	\N	\N	Dignidad	dignidad-ef84	\N	\N	\N	\N	\N	str
2178	2024-07-01 04:39:02.319+00	2024-07-01 04:39:02.319+00	f	\N	\N	Provincia	provincia-f7ov	\N	\N	\N	\N	\N	str
2179	2024-07-01 04:39:02.329+00	2024-07-01 04:39:02.329+00	f	\N	\N	Circunscripción	circunscripcion-g8a3	\N	\N	\N	\N	\N	str
2180	2024-07-01 04:39:02.336+00	2024-07-01 04:39:02.336+00	f	\N	\N	Cantón	canton-32nw	\N	\N	\N	\N	\N	str
2181	2024-07-01 04:39:02.344+00	2024-07-01 04:39:02.344+00	f	\N	\N	Parroquia	parroquia-j0k8	\N	\N	\N	\N	\N	str
2182	2024-07-01 04:39:02.353+00	2024-07-01 04:39:02.353+00	f	\N	\N	Código Cuenta	codigo-cuenta-9ukl	\N	\N	\N	\N	\N	str
2183	2024-07-01 04:39:02.362+00	2024-07-01 04:39:02.362+00	f	\N	\N	Cuenta	cuenta-gv9q	\N	\N	\N	\N	\N	str
2184	2024-07-01 04:39:02.37+00	2024-07-01 04:39:02.37+00	f	\N	\N	Código Subcuenta	codigo-subcuenta-40wx	\N	\N	\N	\N	\N	str
2185	2024-07-01 04:39:02.377+00	2024-07-01 04:39:02.377+00	f	\N	\N	Subcuenta	subcuenta-6oou	\N	\N	\N	\N	\N	str
2186	2024-07-01 04:39:02.387+00	2024-07-01 04:39:02.387+00	f	\N	\N	Fecha Comprobante de Venta	fecha-comprobante-de-venta-6rjr	\N	\N	\N	\N	\N	str
2187	2024-07-01 04:39:02.395+00	2024-07-01 04:39:02.395+00	f	\N	\N	Nro. Comprobante de Venta	nro-comprobante-de-venta-qnt9	\N	\N	\N	\N	\N	str
2188	2024-07-01 04:39:02.402+00	2024-07-01 04:39:02.403+00	f	\N	\N	Nro. RUC del Proveedor	nro-ruc-del-proveedor-7cug	\N	\N	\N	\N	\N	str
2189	2024-07-01 04:39:02.409+00	2024-07-01 04:39:02.409+00	f	\N	\N	Nombre del Proveedor	nombre-del-proveedor-or7b	\N	\N	\N	\N	\N	str
2190	2024-07-01 04:39:02.418+00	2024-07-01 04:39:02.418+00	f	\N	\N	Descripción del Gasto	descripcion-del-gasto-j0f1	\N	\N	\N	\N	\N	str
2191	2024-07-01 04:39:02.426+00	2024-07-01 04:39:02.426+00	f	\N	\N	Subtotal	subtotal-loks	\N	\N	\N	\N	\N	str
2192	2024-07-01 04:39:02.433+00	2024-07-01 04:39:02.433+00	f	\N	\N	IVA	iva-a21z	\N	\N	\N	\N	\N	str
2193	2024-07-01 04:39:02.439+00	2024-07-01 04:39:02.439+00	f	\N	\N	Total	total-tiyr	\N	\N	\N	\N	\N	str
2194	2024-07-01 04:39:02.453+00	2024-07-01 04:39:02.453+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-baxa	\N	\N	\N	\N	\N	str
2195	2024-07-01 04:39:02.463+00	2024-07-01 04:39:02.463+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-vkqu	\N	\N	\N	\N	\N	str
2196	2024-07-01 04:39:02.471+00	2024-07-01 04:39:02.471+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-kzy1	\N	\N	\N	\N	\N	str
2197	2024-07-01 04:39:02.479+00	2024-07-01 04:39:02.479+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-m5er	\N	\N	\N	\N	\N	str
2198	2024-07-01 04:39:02.489+00	2024-07-01 04:39:02.49+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-cf4f	\N	\N	\N	\N	\N	str
2199	2024-07-01 04:39:02.5+00	2024-07-01 04:39:02.5+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-pfaw	\N	\N	\N	\N	\N	str
2200	2024-07-01 04:39:02.508+00	2024-07-01 04:39:02.508+00	f	\N	\N	LICENCIA	licencia-sy09	\N	\N	\N	\N	\N	str
2201	2024-07-01 04:39:02.518+00	2024-07-01 04:39:02.518+00	f	\N	\N	Enlace para direccionar a los planes de trabajo de las candidatas y candidatos a las distintas elecciones	enlace-para-direccionar-a-los-planes-de-trabajo-de-las-candidatas-y-candidatos-a-las-distintas-elecciones-4n06	\N	\N	\N	\N	\N	str
2202	2024-07-01 04:39:02.528+00	2024-07-01 04:39:02.528+00	f	\N	\N	Enlace para direccionar a los resultados de los procesos electorales	enlace-para-direccionar-a-los-resultados-de-los-procesos-electorales-23vz	\N	\N	\N	\N	\N	str
2203	2024-07-01 04:39:02.536+00	2024-07-01 04:39:02.536+00	f	\N	\N	Enlace para direccionar a las actas de cada junta y recinto electoral 	enlace-para-direccionar-a-las-actas-de-cada-junta-y-recinto-electoral-mqgf	\N	\N	\N	\N	\N	str
2204	2024-07-01 04:39:02.552+00	2024-07-01 04:39:02.552+00	f	\N	\N	Institución	institucion-xemb	\N	\N	\N	\N	\N	str
2205	2024-07-01 04:39:02.567+00	2024-07-01 04:39:02.567+00	f	\N	\N	Descripción	descripcion-2xjf	\N	\N	\N	\N	\N	str
2206	2024-07-01 04:39:02.58+00	2024-07-01 04:39:02.58+00	f	\N	\N	Nombre del campo	nombre-del-campo-c5pd	\N	\N	\N	\N	\N	str
2207	2024-07-01 04:39:02.595+00	2024-07-01 04:39:02.595+00	f	\N	\N	Organización Política o Alianza	organizacion-politica-o-alianza-x1du	\N	\N	\N	\N	\N	str
2208	2024-07-01 04:39:02.604+00	2024-07-01 04:39:02.604+00	f	\N	\N	Proceso Electoral	proceso-electoral-tozq	\N	\N	\N	\N	\N	str
2209	2024-07-01 04:39:02.618+00	2024-07-01 04:39:02.618+00	f	\N	\N	Mes	mes-i8l3	\N	\N	\N	\N	\N	str
2210	2024-07-01 04:39:02.63+00	2024-07-01 04:39:02.63+00	f	\N	\N	Dignidad	dignidad-wx7p	\N	\N	\N	\N	\N	str
2211	2024-07-01 04:39:02.639+00	2024-07-01 04:39:02.64+00	f	\N	\N	Provincia	provincia-w7j4	\N	\N	\N	\N	\N	str
2212	2024-07-01 04:39:02.65+00	2024-07-01 04:39:02.65+00	f	\N	\N	Circunscripción	circunscripcion-r3gp	\N	\N	\N	\N	\N	str
2213	2024-07-01 04:39:02.662+00	2024-07-01 04:39:02.662+00	f	\N	\N	Cantón	canton-evvk	\N	\N	\N	\N	\N	str
2214	2024-07-01 04:39:02.673+00	2024-07-01 04:39:02.673+00	f	\N	\N	Parroquia	parroquia-hjq6	\N	\N	\N	\N	\N	str
2215	2024-07-01 04:39:02.684+00	2024-07-01 04:39:02.684+00	f	\N	\N	Código Cuenta	codigo-cuenta-9eu7	\N	\N	\N	\N	\N	str
2216	2024-07-01 04:39:02.697+00	2024-07-01 04:39:02.697+00	f	\N	\N	Cuenta	cuenta-qdyu	\N	\N	\N	\N	\N	str
2217	2024-07-01 04:39:02.706+00	2024-07-01 04:39:02.706+00	f	\N	\N	Código Subcuenta	codigo-subcuenta-yf1r	\N	\N	\N	\N	\N	str
2218	2024-07-01 04:39:02.718+00	2024-07-01 04:39:02.718+00	f	\N	\N	Subcuenta	subcuenta-u4p4	\N	\N	\N	\N	\N	str
2219	2024-07-01 04:39:02.728+00	2024-07-01 04:39:02.728+00	f	\N	\N	Fecha Comprobante de Venta	fecha-comprobante-de-venta-lsx1	\N	\N	\N	\N	\N	str
2220	2024-07-01 04:39:02.737+00	2024-07-01 04:39:02.737+00	f	\N	\N	Nro. Comprobante de Venta	nro-comprobante-de-venta-o3wy	\N	\N	\N	\N	\N	str
2221	2024-07-01 04:39:02.745+00	2024-07-01 04:39:02.745+00	f	\N	\N	Nro. RUC del Proveedor	nro-ruc-del-proveedor-ck1j	\N	\N	\N	\N	\N	str
2222	2024-07-01 04:39:02.755+00	2024-07-01 04:39:02.755+00	f	\N	\N	Nombre del Proveedor	nombre-del-proveedor-jkzm	\N	\N	\N	\N	\N	str
2223	2024-07-01 04:39:02.765+00	2024-07-01 04:39:02.765+00	f	\N	\N	Descripción del Gasto	descripcion-del-gasto-tnnu	\N	\N	\N	\N	\N	str
2224	2024-07-01 04:39:02.773+00	2024-07-01 04:39:02.773+00	f	\N	\N	Subtotal	subtotal-v7py	\N	\N	\N	\N	\N	str
2225	2024-07-01 04:39:02.783+00	2024-07-01 04:39:02.783+00	f	\N	\N	IVA	iva-zzf4	\N	\N	\N	\N	\N	str
2226	2024-07-01 04:39:02.795+00	2024-07-01 04:39:02.795+00	f	\N	\N	Total	total-hfm5	\N	\N	\N	\N	\N	str
2227	2024-07-01 04:39:02.809+00	2024-07-01 04:39:02.809+00	f	\N	\N	Proceso Electoral	proceso-electoral-xxr6	\N	\N	\N	\N	\N	str
2228	2024-07-01 04:39:02.82+00	2024-07-01 04:39:02.82+00	f	\N	\N	Provincia	provincia-hq47	\N	\N	\N	\N	\N	str
2229	2024-07-01 04:39:02.827+00	2024-07-01 04:39:02.827+00	f	\N	\N	Cantón	canton-hgwt	\N	\N	\N	\N	\N	str
2230	2024-07-01 04:39:02.835+00	2024-07-01 04:39:02.835+00	f	\N	\N	Circunscripción	circunscripcion-5n1f	\N	\N	\N	\N	\N	str
2231	2024-07-01 04:39:02.844+00	2024-07-01 04:39:02.844+00	f	\N	\N	Parroquia	parroquia-hl3j	\N	\N	\N	\N	\N	str
2232	2024-07-01 04:39:02.851+00	2024-07-01 04:39:02.851+00	f	\N	\N	Zona	zona-utso	\N	\N	\N	\N	\N	str
2233	2024-07-01 04:39:02.859+00	2024-07-01 04:39:02.859+00	f	\N	\N	Junta	junta-larl	\N	\N	\N	\N	\N	str
2234	2024-07-01 04:39:02.867+00	2024-07-01 04:39:02.867+00	f	\N	\N	Dignidad	dignidad-xfti	\N	\N	\N	\N	\N	str
2235	2024-07-01 04:39:02.878+00	2024-07-01 04:39:02.878+00	f	\N	\N	Enlace al Acta	enlace-al-acta-36j0	\N	\N	\N	\N	\N	str
2236	2024-07-01 04:39:02.892+00	2024-07-01 04:39:02.892+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-k91v	\N	\N	\N	\N	\N	str
2237	2024-07-01 04:39:02.899+00	2024-07-01 04:39:02.899+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-msfa	\N	\N	\N	\N	\N	str
2238	2024-07-01 04:39:02.908+00	2024-07-01 04:39:02.908+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-zo6u	\N	\N	\N	\N	\N	str
2239	2024-07-01 04:39:02.916+00	2024-07-01 04:39:02.916+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-kz1s	\N	\N	\N	\N	\N	str
2240	2024-07-01 04:39:02.922+00	2024-07-01 04:39:02.922+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-6vxp	\N	\N	\N	\N	\N	str
2241	2024-07-01 04:39:02.928+00	2024-07-01 04:39:02.928+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-7ly7	\N	\N	\N	\N	\N	str
2242	2024-07-01 04:39:02.935+00	2024-07-01 04:39:02.935+00	f	\N	\N	LICENCIA	licencia-4vdn	\N	\N	\N	\N	\N	str
2243	2024-07-01 04:39:02.943+00	2024-07-01 04:39:02.943+00	f	\N	\N	Enlace para direccionar a los planes de trabajo de las candidatas y candidatos a las distintas elecciones	enlace-para-direccionar-a-los-planes-de-trabajo-de-las-candidatas-y-candidatos-a-las-distintas-elecciones-3xa8	\N	\N	\N	\N	\N	str
2244	2024-07-01 04:39:02.949+00	2024-07-01 04:39:02.949+00	f	\N	\N	Enlace para direccionar a los resultados de los procesos electorales	enlace-para-direccionar-a-los-resultados-de-los-procesos-electorales-cfs3	\N	\N	\N	\N	\N	str
2245	2024-07-01 04:39:02.956+00	2024-07-01 04:39:02.956+00	f	\N	\N	Enlace para direccionar a las actas de cada junta y recinto electoral 	enlace-para-direccionar-a-las-actas-de-cada-junta-y-recinto-electoral-arxj	\N	\N	\N	\N	\N	str
2246	2024-07-01 04:39:02.968+00	2024-07-01 04:39:02.968+00	f	\N	\N	Institución	institucion-ji8l	\N	\N	\N	\N	\N	str
2247	2024-07-01 04:39:02.976+00	2024-07-01 04:39:02.976+00	f	\N	\N	Descripción	descripcion-nd00	\N	\N	\N	\N	\N	str
2248	2024-07-01 04:39:02.984+00	2024-07-01 04:39:02.984+00	f	\N	\N	Nombre del campo	nombre-del-campo-hjpq	\N	\N	\N	\N	\N	str
2249	2024-07-01 04:39:02.99+00	2024-07-01 04:39:02.99+00	f	\N	\N	Proceso Electoral	proceso-electoral-b6q8	\N	\N	\N	\N	\N	str
2250	2024-07-01 04:39:02.997+00	2024-07-01 04:39:02.997+00	f	\N	\N	Provincia	provincia-y5eh	\N	\N	\N	\N	\N	str
2251	2024-07-01 04:39:03.006+00	2024-07-01 04:39:03.006+00	f	\N	\N	Cantón	canton-ackz	\N	\N	\N	\N	\N	str
2252	2024-07-01 04:39:03.013+00	2024-07-01 04:39:03.013+00	f	\N	\N	Circunscripción	circunscripcion-gbde	\N	\N	\N	\N	\N	str
2253	2024-07-01 04:39:03.02+00	2024-07-01 04:39:03.02+00	f	\N	\N	Parroquia	parroquia-pxqd	\N	\N	\N	\N	\N	str
2254	2024-07-01 04:39:03.026+00	2024-07-01 04:39:03.026+00	f	\N	\N	Zona	zona-767v	\N	\N	\N	\N	\N	str
2255	2024-07-01 04:39:03.032+00	2024-07-01 04:39:03.032+00	f	\N	\N	Junta	junta-zi51	\N	\N	\N	\N	\N	str
2256	2024-07-01 04:39:03.04+00	2024-07-01 04:39:03.04+00	f	\N	\N	Dignidad	dignidad-xnun	\N	\N	\N	\N	\N	str
2257	2024-07-01 04:39:03.047+00	2024-07-01 04:39:03.047+00	f	\N	\N	Enlace al Acta	enlace-al-acta-u0e4	\N	\N	\N	\N	\N	str
2258	2024-07-01 04:39:03.057+00	2024-07-01 04:39:03.057+00	f	\N	\N	Proceso Electoral	proceso-electoral-qjlv	\N	\N	\N	\N	\N	str
2259	2024-07-01 04:39:03.064+00	2024-07-01 04:39:03.064+00	f	\N	\N	Dignidad	dignidad-09i5	\N	\N	\N	\N	\N	str
2260	2024-07-01 04:39:03.071+00	2024-07-01 04:39:03.071+00	f	\N	\N	Candidato, Candidata o Partido	candidato-candidata-o-partido-szxp	\N	\N	\N	\N	\N	str
2261	2024-07-01 04:39:03.078+00	2024-07-01 04:39:03.078+00	f	\N	\N	Organización Política o Alianza	organizacion-politica-o-alianza-ktbv	\N	\N	\N	\N	\N	str
2262	2024-07-01 04:39:03.085+00	2024-07-01 04:39:03.085+00	f	\N	\N	Enlace a Plan de Trabajo	enlace-a-plan-de-trabajo-thff	\N	\N	\N	\N	\N	str
2263	2024-07-01 04:39:03.097+00	2024-07-01 04:39:03.097+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-l6pq	\N	\N	\N	\N	\N	str
2264	2024-07-01 04:39:03.105+00	2024-07-01 04:39:03.105+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-nipl	\N	\N	\N	\N	\N	str
2265	2024-07-01 04:39:03.112+00	2024-07-01 04:39:03.112+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-mcbs	\N	\N	\N	\N	\N	str
2266	2024-07-01 04:39:03.119+00	2024-07-01 04:39:03.119+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-n8ua	\N	\N	\N	\N	\N	str
2267	2024-07-01 04:39:03.126+00	2024-07-01 04:39:03.126+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-7ey4	\N	\N	\N	\N	\N	str
2268	2024-07-01 04:39:03.132+00	2024-07-01 04:39:03.132+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-uuip	\N	\N	\N	\N	\N	str
2269	2024-07-01 04:39:03.139+00	2024-07-01 04:39:03.139+00	f	\N	\N	LICENCIA	licencia-cjnr	\N	\N	\N	\N	\N	str
2270	2024-07-01 04:39:03.146+00	2024-07-01 04:39:03.146+00	f	\N	\N	Enlace para direccionar a los planes de trabajo de las candidatas y candidatos a las distintas elecciones	enlace-para-direccionar-a-los-planes-de-trabajo-de-las-candidatas-y-candidatos-a-las-distintas-elecciones-9e85	\N	\N	\N	\N	\N	str
2271	2024-07-01 04:39:03.151+00	2024-07-01 04:39:03.151+00	f	\N	\N	Enlace para direccionar a los resultados de los procesos electorales	enlace-para-direccionar-a-los-resultados-de-los-procesos-electorales-ba73	\N	\N	\N	\N	\N	str
2272	2024-07-01 04:39:03.157+00	2024-07-01 04:39:03.157+00	f	\N	\N	Enlace para direccionar a las actas de cada junta y recinto electoral 	enlace-para-direccionar-a-las-actas-de-cada-junta-y-recinto-electoral-78vx	\N	\N	\N	\N	\N	str
2273	2024-07-01 04:39:03.167+00	2024-07-01 04:39:03.167+00	f	\N	\N	Institución	institucion-e9wf	\N	\N	\N	\N	\N	str
2274	2024-07-01 04:39:03.176+00	2024-07-01 04:39:03.176+00	f	\N	\N	Descripción	descripcion-vo5l	\N	\N	\N	\N	\N	str
2275	2024-07-01 04:39:03.184+00	2024-07-01 04:39:03.184+00	f	\N	\N	Nombre del campo	nombre-del-campo-7rwq	\N	\N	\N	\N	\N	str
2276	2024-07-01 04:39:03.191+00	2024-07-01 04:39:03.191+00	f	\N	\N	Proceso Electoral	proceso-electoral-vm15	\N	\N	\N	\N	\N	str
2277	2024-07-01 04:39:03.199+00	2024-07-01 04:39:03.199+00	f	\N	\N	Dignidad	dignidad-7bkz	\N	\N	\N	\N	\N	str
2278	2024-07-01 04:39:03.209+00	2024-07-01 04:39:03.209+00	f	\N	\N	Candidato, Candidata o Partido	candidato-candidata-o-partido-i8io	\N	\N	\N	\N	\N	str
2279	2024-07-01 04:39:03.217+00	2024-07-01 04:39:03.217+00	f	\N	\N	Organización Política o Alianza	organizacion-politica-o-alianza-1al3	\N	\N	\N	\N	\N	str
2280	2024-07-01 04:39:03.224+00	2024-07-01 04:39:03.224+00	f	\N	\N	Enlace a Plan de Trabajo	enlace-a-plan-de-trabajo-9nws	\N	\N	\N	\N	\N	str
2281	2024-07-01 04:39:03.237+00	2024-07-01 04:39:03.237+00	f	\N	\N	Proceso Electoral	proceso-electoral-bzww	\N	\N	\N	\N	\N	str
2282	2024-07-01 04:39:03.246+00	2024-07-01 04:39:03.246+00	f	\N	\N	Provincia	provincia-rh11	\N	\N	\N	\N	\N	str
2283	2024-07-01 04:39:03.253+00	2024-07-01 04:39:03.253+00	f	\N	\N	Cantón	canton-zuv1	\N	\N	\N	\N	\N	str
2284	2024-07-01 04:39:03.26+00	2024-07-01 04:39:03.26+00	f	\N	\N	Circunscripción	circunscripcion-7k54	\N	\N	\N	\N	\N	str
2285	2024-07-01 04:39:03.269+00	2024-07-01 04:39:03.269+00	f	\N	\N	Parroquia	parroquia-p67g	\N	\N	\N	\N	\N	str
2286	2024-07-01 04:39:03.278+00	2024-07-01 04:39:03.278+00	f	\N	\N	Zona	zona-ckgz	\N	\N	\N	\N	\N	str
2287	2024-07-01 04:39:03.286+00	2024-07-01 04:39:03.286+00	f	\N	\N	Junta	junta-1vo3	\N	\N	\N	\N	\N	str
2288	2024-07-01 04:39:03.292+00	2024-07-01 04:39:03.292+00	f	\N	\N	Dignidad	dignidad-oub9	\N	\N	\N	\N	\N	str
2289	2024-07-01 04:39:03.299+00	2024-07-01 04:39:03.299+00	f	\N	\N	Candidato, Candidata, Organización Política o Alianza, Votos Nulos o Blancos	candidato-candidata-organizacion-politica-o-alianza-votos-nulos-o-blancos-e1qx	\N	\N	\N	\N	\N	str
2290	2024-07-01 04:39:03.308+00	2024-07-01 04:39:03.308+00	f	\N	\N	Organización Política o Alianza, Votos Nulos o Blancos	organizacion-politica-o-alianza-votos-nulos-o-blancos-ktib	\N	\N	\N	\N	\N	str
2291	2024-07-01 04:39:03.316+00	2024-07-01 04:39:03.316+00	f	\N	\N	Votos	votos-fop9	\N	\N	\N	\N	\N	str
2292	2024-07-01 04:39:03.328+00	2024-07-01 04:39:03.328+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-kbsc	\N	\N	\N	\N	\N	str
2293	2024-07-01 04:39:03.336+00	2024-07-01 04:39:03.336+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-higo	\N	\N	\N	\N	\N	str
2294	2024-07-01 04:39:03.344+00	2024-07-01 04:39:03.344+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-pwsy	\N	\N	\N	\N	\N	str
2419	2024-07-01 04:39:04.414+00	2024-07-01 04:39:04.414+00	f	\N	\N	Enlace al acta	enlace-al-acta-d2qa	\N	\N	\N	\N	\N	str
2295	2024-07-01 04:39:03.351+00	2024-07-01 04:39:03.351+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-yy3p	\N	\N	\N	\N	\N	str
2296	2024-07-01 04:39:03.359+00	2024-07-01 04:39:03.359+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-ro8a	\N	\N	\N	\N	\N	str
2297	2024-07-01 04:39:03.366+00	2024-07-01 04:39:03.366+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-79zy	\N	\N	\N	\N	\N	str
2298	2024-07-01 04:39:03.374+00	2024-07-01 04:39:03.374+00	f	\N	\N	LICENCIA	licencia-z54y	\N	\N	\N	\N	\N	str
2299	2024-07-01 04:39:03.381+00	2024-07-01 04:39:03.381+00	f	\N	\N	Enlace para direccionar a los planes de trabajo de las candidatas y candidatos a las distintas elecciones	enlace-para-direccionar-a-los-planes-de-trabajo-de-las-candidatas-y-candidatos-a-las-distintas-elecciones-g6x2	\N	\N	\N	\N	\N	str
2300	2024-07-01 04:39:03.387+00	2024-07-01 04:39:03.387+00	f	\N	\N	Enlace para direccionar a los resultados de los procesos electorales	enlace-para-direccionar-a-los-resultados-de-los-procesos-electorales-w0s9	\N	\N	\N	\N	\N	str
2301	2024-07-01 04:39:03.394+00	2024-07-01 04:39:03.394+00	f	\N	\N	Enlace para direccionar a las actas de cada junta y recinto electoral 	enlace-para-direccionar-a-las-actas-de-cada-junta-y-recinto-electoral-bav0	\N	\N	\N	\N	\N	str
2302	2024-07-01 04:39:03.407+00	2024-07-01 04:39:03.407+00	f	\N	\N	Institución	institucion-6juf	\N	\N	\N	\N	\N	str
2303	2024-07-01 04:39:03.416+00	2024-07-01 04:39:03.416+00	f	\N	\N	Descripción	descripcion-cye0	\N	\N	\N	\N	\N	str
2304	2024-07-01 04:39:03.422+00	2024-07-01 04:39:03.422+00	f	\N	\N	Nombre del campo	nombre-del-campo-p73s	\N	\N	\N	\N	\N	str
2305	2024-07-01 04:39:03.428+00	2024-07-01 04:39:03.428+00	f	\N	\N	Proceso Electoral	proceso-electoral-u8om	\N	\N	\N	\N	\N	str
2306	2024-07-01 04:39:03.436+00	2024-07-01 04:39:03.436+00	f	\N	\N	Provincia	provincia-1ghh	\N	\N	\N	\N	\N	str
2307	2024-07-01 04:39:03.443+00	2024-07-01 04:39:03.443+00	f	\N	\N	Cantón	canton-zv35	\N	\N	\N	\N	\N	str
2308	2024-07-01 04:39:03.449+00	2024-07-01 04:39:03.449+00	f	\N	\N	Circunscripción	circunscripcion-bxls	\N	\N	\N	\N	\N	str
2309	2024-07-01 04:39:03.455+00	2024-07-01 04:39:03.455+00	f	\N	\N	Parroquia	parroquia-kwe4	\N	\N	\N	\N	\N	str
2310	2024-07-01 04:39:03.462+00	2024-07-01 04:39:03.462+00	f	\N	\N	Zona	zona-9q9e	\N	\N	\N	\N	\N	str
2311	2024-07-01 04:39:03.469+00	2024-07-01 04:39:03.469+00	f	\N	\N	Junta	junta-wsh6	\N	\N	\N	\N	\N	str
2312	2024-07-01 04:39:03.477+00	2024-07-01 04:39:03.477+00	f	\N	\N	Dignidad	dignidad-7sc5	\N	\N	\N	\N	\N	str
2313	2024-07-01 04:39:03.484+00	2024-07-01 04:39:03.484+00	f	\N	\N	Candidato, Candidata, Organización Política o Alianza, Votos Nulos o Blancos	candidato-candidata-organizacion-politica-o-alianza-votos-nulos-o-blancos-kuym	\N	\N	\N	\N	\N	str
2314	2024-07-01 04:39:03.49+00	2024-07-01 04:39:03.49+00	f	\N	\N	Organización Política o Alianza, Votos Nulos o Blancos	organizacion-politica-o-alianza-votos-nulos-o-blancos-6nss	\N	\N	\N	\N	\N	str
2315	2024-07-01 04:39:03.496+00	2024-07-01 04:39:03.496+00	f	\N	\N	Votos	votos-4wop	\N	\N	\N	\N	\N	str
2316	2024-07-01 04:39:03.511+00	2024-07-01 04:39:03.511+00	f	\N	\N	Número de Sentencia o Dictamen	numero-de-sentencia-o-dictamen-cvjz	\N	\N	\N	\N	\N	str
2317	2024-07-01 04:39:03.518+00	2024-07-01 04:39:03.518+00	f	\N	\N	Fecha	fecha-ihlu	\N	\N	\N	\N	\N	str
2318	2024-07-01 04:39:03.524+00	2024-07-01 04:39:03.524+00	f	\N	\N	Tipo de Acción	tipo-de-accion-pgot	\N	\N	\N	\N	\N	str
2319	2024-07-01 04:39:03.531+00	2024-07-01 04:39:03.531+00	f	\N	\N	Materia	materia-2v20	\N	\N	\N	\N	\N	str
2320	2024-07-01 04:39:03.54+00	2024-07-01 04:39:03.54+00	f	\N	\N	Decisión resumen	decision-resumen-7uzp	\N	\N	\N	\N	\N	str
2321	2024-07-01 04:39:03.547+00	2024-07-01 04:39:03.547+00	f	\N	\N	Enlace al Texto Íntegro de la Sentencia	enlace-al-texto-integro-de-la-sentencia-nftm	\N	\N	\N	\N	\N	str
2322	2024-07-01 04:39:03.557+00	2024-07-01 04:39:03.557+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-uwlm	\N	\N	\N	\N	\N	str
2323	2024-07-01 04:39:03.565+00	2024-07-01 04:39:03.565+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-v5xr	\N	\N	\N	\N	\N	str
2324	2024-07-01 04:39:03.575+00	2024-07-01 04:39:03.575+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-hdpw	\N	\N	\N	\N	\N	str
2325	2024-07-01 04:39:03.583+00	2024-07-01 04:39:03.583+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-43sx	\N	\N	\N	\N	\N	str
2326	2024-07-01 04:39:03.591+00	2024-07-01 04:39:03.591+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-k0ci	\N	\N	\N	\N	\N	str
2327	2024-07-01 04:39:03.599+00	2024-07-01 04:39:03.599+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-whyw	\N	\N	\N	\N	\N	str
2328	2024-07-01 04:39:03.609+00	2024-07-01 04:39:03.609+00	f	\N	\N	LICENCIA	licencia-aq3x	\N	\N	\N	\N	\N	str
2329	2024-07-01 04:39:03.619+00	2024-07-01 04:39:03.619+00	f	\N	\N	ENLACE QUE DIRECCIONA AL SISTEMA DE GESTIÓN DE ACCIONES CONSTITUCIONALES 	enlace-que-direcciona-al-sistema-de-gestion-de-acciones-constitucionales-ccer	\N	\N	\N	\N	\N	str
2330	2024-07-01 04:39:03.634+00	2024-07-01 04:39:03.634+00	f	\N	\N	Institución	institucion-3wmg	\N	\N	\N	\N	\N	str
2331	2024-07-01 04:39:03.644+00	2024-07-01 04:39:03.644+00	f	\N	\N	Descripción	descripcion-dbrd	\N	\N	\N	\N	\N	str
2332	2024-07-01 04:39:03.653+00	2024-07-01 04:39:03.653+00	f	\N	\N	Nombre del campo	nombre-del-campo-5t4i	\N	\N	\N	\N	\N	str
2333	2024-07-01 04:39:03.661+00	2024-07-01 04:39:03.661+00	f	\N	\N	Número de Sentencia o Dictamen	numero-de-sentencia-o-dictamen-hwcv	\N	\N	\N	\N	\N	str
2334	2024-07-01 04:39:03.671+00	2024-07-01 04:39:03.671+00	f	\N	\N	Fecha	fecha-6faw	\N	\N	\N	\N	\N	str
2335	2024-07-01 04:39:03.681+00	2024-07-01 04:39:03.681+00	f	\N	\N	Tipo de Acción	tipo-de-accion-etap	\N	\N	\N	\N	\N	str
2336	2024-07-01 04:39:03.69+00	2024-07-01 04:39:03.69+00	f	\N	\N	Materia	materia-fih6	\N	\N	\N	\N	\N	str
2337	2024-07-01 04:39:03.7+00	2024-07-01 04:39:03.7+00	f	\N	\N	Decisión resumen	decision-resumen-gg6g	\N	\N	\N	\N	\N	str
2338	2024-07-01 04:39:03.71+00	2024-07-01 04:39:03.71+00	f	\N	\N	Enlace al Texto Íntegro de la Sentencia	enlace-al-texto-integro-de-la-sentencia-74m1	\N	\N	\N	\N	\N	str
2339	2024-07-01 04:39:03.728+00	2024-07-01 04:39:03.728+00	f	\N	\N	Código	codigo-ixl0	\N	\N	\N	\N	\N	str
2340	2024-07-01 04:39:03.738+00	2024-07-01 04:39:03.738+00	f	\N	\N	Fecha de Presentación	fecha-de-presentacion-g9tj	\N	\N	\N	\N	\N	str
2341	2024-07-01 04:39:03.749+00	2024-07-01 04:39:03.749+00	f	\N	\N	Tipo 	tipo-2vj6	\N	\N	\N	\N	\N	str
2342	2024-07-01 04:39:03.758+00	2024-07-01 04:39:03.758+00	f	\N	\N	Proyecto, enmienda o reforma constitucional	proyecto-enmienda-o-reforma-constitucional-cpka	\N	\N	\N	\N	\N	str
2343	2024-07-01 04:39:03.768+00	2024-07-01 04:39:03.768+00	f	\N	\N	Proponente(s)	proponentes-qo60	\N	\N	\N	\N	\N	str
2344	2024-07-01 04:39:03.777+00	2024-07-01 04:39:03.777+00	f	\N	\N	Comisión	comision-jsob	\N	\N	\N	\N	\N	str
2345	2024-07-01 04:39:03.786+00	2024-07-01 04:39:03.786+00	f	\N	\N	Estado	estado-puv3	\N	\N	\N	\N	\N	str
2346	2024-07-01 04:39:03.793+00	2024-07-01 04:39:03.793+00	f	\N	\N	Enlace a proyecto de ley documentos e informes	enlace-a-proyecto-de-ley-documentos-e-informes-y90y	\N	\N	\N	\N	\N	str
2347	2024-07-01 04:39:03.808+00	2024-07-01 04:39:03.808+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-g1lb	\N	\N	\N	\N	\N	str
2348	2024-07-01 04:39:03.816+00	2024-07-01 04:39:03.816+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-vqch	\N	\N	\N	\N	\N	str
2349	2024-07-01 04:39:03.824+00	2024-07-01 04:39:03.824+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-qee3	\N	\N	\N	\N	\N	str
2350	2024-07-01 04:39:03.832+00	2024-07-01 04:39:03.832+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-gw5g	\N	\N	\N	\N	\N	str
2351	2024-07-01 04:39:03.842+00	2024-07-01 04:39:03.842+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-7wcb	\N	\N	\N	\N	\N	str
2420	2024-07-01 04:39:04.425+00	2024-07-01 04:39:04.425+00	f	\N	\N	No. Sesión	no-sesion-hidt	\N	\N	\N	\N	\N	str
2352	2024-07-01 04:39:03.85+00	2024-07-01 04:39:03.85+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-ahcm	\N	\N	\N	\N	\N	str
2353	2024-07-01 04:39:03.857+00	2024-07-01 04:39:03.857+00	f	\N	\N	LICENCIA	licencia-s6k4	\N	\N	\N	\N	\N	str
2354	2024-07-01 04:39:03.872+00	2024-07-01 04:39:03.872+00	f	\N	\N	Institución	institucion-6wle	\N	\N	\N	\N	\N	str
2355	2024-07-01 04:39:03.881+00	2024-07-01 04:39:03.881+00	f	\N	\N	Descripción	descripcion-ml4c	\N	\N	\N	\N	\N	str
2356	2024-07-01 04:39:03.891+00	2024-07-01 04:39:03.891+00	f	\N	\N	Nombre del campo	nombre-del-campo-sp7h	\N	\N	\N	\N	\N	str
2357	2024-07-01 04:39:03.898+00	2024-07-01 04:39:03.898+00	f	\N	\N	Código	codigo-kfej	\N	\N	\N	\N	\N	str
2358	2024-07-01 04:39:03.906+00	2024-07-01 04:39:03.906+00	f	\N	\N	Fecha de Presentación	fecha-de-presentacion-6dy2	\N	\N	\N	\N	\N	str
2359	2024-07-01 04:39:03.914+00	2024-07-01 04:39:03.914+00	f	\N	\N	Tipo	tipo-dpkw	\N	\N	\N	\N	\N	str
2360	2024-07-01 04:39:03.921+00	2024-07-01 04:39:03.921+00	f	\N	\N	Proyecto, enmienda o reforma constitucional	proyecto-enmienda-o-reforma-constitucional-txkl	\N	\N	\N	\N	\N	str
2361	2024-07-01 04:39:03.928+00	2024-07-01 04:39:03.928+00	f	\N	\N	Proponente(s)	proponentes-hf8g	\N	\N	\N	\N	\N	str
2362	2024-07-01 04:39:03.936+00	2024-07-01 04:39:03.936+00	f	\N	\N	Comisión	comision-hw9m	\N	\N	\N	\N	\N	str
2363	2024-07-01 04:39:03.945+00	2024-07-01 04:39:03.945+00	f	\N	\N	Estado	estado-vidc	\N	\N	\N	\N	\N	str
2364	2024-07-01 04:39:03.953+00	2024-07-01 04:39:03.953+00	f	\N	\N	Enlace a proyecto de ley, documentos e informes	enlace-a-proyecto-de-ley-documentos-e-informes-og91	\N	\N	\N	\N	\N	str
2365	2024-07-01 04:39:03.964+00	2024-07-01 04:39:03.964+00	f	\N	\N	Código	codigo-2c05	\N	\N	\N	\N	\N	str
2366	2024-07-01 04:39:03.973+00	2024-07-01 04:39:03.973+00	f	\N	\N	Fecha de Presentación	fecha-de-presentacion-76gv	\N	\N	\N	\N	\N	str
2367	2024-07-01 04:39:03.981+00	2024-07-01 04:39:03.981+00	f	\N	\N	Proyecto	proyecto-fetm	\N	\N	\N	\N	\N	str
2368	2024-07-01 04:39:03.988+00	2024-07-01 04:39:03.988+00	f	\N	\N	Comisión Especializada Permanente u Ocasional	comision-especializada-permanente-u-ocasional-8kb4	\N	\N	\N	\N	\N	str
2369	2024-07-01 04:39:03.995+00	2024-07-01 04:39:03.995+00	f	\N	\N	Fecha de socialización	fecha-de-socializacion-zml8	\N	\N	\N	\N	\N	str
2370	2024-07-01 04:39:04.004+00	2024-07-01 04:39:04.004+00	f	\N	\N	Provincia	provincia-tcu4	\N	\N	\N	\N	\N	str
2371	2024-07-01 04:39:04.012+00	2024-07-01 04:39:04.012+00	f	\N	\N	Cantón	canton-lntm	\N	\N	\N	\N	\N	str
2372	2024-07-01 04:39:04.019+00	2024-07-01 04:39:04.019+00	f	\N	\N	Temática abordada	tematica-abordada-s69u	\N	\N	\N	\N	\N	str
2373	2024-07-01 04:39:04.026+00	2024-07-01 04:39:04.026+00	f	\N	\N	Público objetivo	publico-objetivo-omsq	\N	\N	\N	\N	\N	str
2374	2024-07-01 04:39:04.035+00	2024-07-01 04:39:04.035+00	f	\N	\N	Enlace a documentos de socialización	enlace-a-documentos-de-socializacion-emxb	\N	\N	\N	\N	\N	str
2375	2024-07-01 04:39:04.049+00	2024-07-01 04:39:04.049+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-hl3i	\N	\N	\N	\N	\N	str
2376	2024-07-01 04:39:04.056+00	2024-07-01 04:39:04.056+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-h09g	\N	\N	\N	\N	\N	str
2377	2024-07-01 04:39:04.064+00	2024-07-01 04:39:04.064+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-ueic	\N	\N	\N	\N	\N	str
2378	2024-07-01 04:39:04.073+00	2024-07-01 04:39:04.073+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-c2l3	\N	\N	\N	\N	\N	str
2379	2024-07-01 04:39:04.081+00	2024-07-01 04:39:04.081+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-ga0u	\N	\N	\N	\N	\N	str
2380	2024-07-01 04:39:04.089+00	2024-07-01 04:39:04.089+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-kwuj	\N	\N	\N	\N	\N	str
2381	2024-07-01 04:39:04.096+00	2024-07-01 04:39:04.096+00	f	\N	\N	LICENCIA	licencia-qugg	\N	\N	\N	\N	\N	str
2382	2024-07-01 04:39:04.109+00	2024-07-01 04:39:04.109+00	f	\N	\N	Institución	institucion-ye07	\N	\N	\N	\N	\N	str
2383	2024-07-01 04:39:04.117+00	2024-07-01 04:39:04.117+00	f	\N	\N	Descripción	descripcion-4zkr	\N	\N	\N	\N	\N	str
2384	2024-07-01 04:39:04.123+00	2024-07-01 04:39:04.123+00	f	\N	\N	Nombre del campo	nombre-del-campo-jd1e	\N	\N	\N	\N	\N	str
2385	2024-07-01 04:39:04.13+00	2024-07-01 04:39:04.13+00	f	\N	\N	Código	codigo-fwrg	\N	\N	\N	\N	\N	str
2386	2024-07-01 04:39:04.139+00	2024-07-01 04:39:04.139+00	f	\N	\N	Fecha de Presentación	fecha-de-presentacion-7btf	\N	\N	\N	\N	\N	str
2387	2024-07-01 04:39:04.145+00	2024-07-01 04:39:04.145+00	f	\N	\N	Proyecto	proyecto-xvgi	\N	\N	\N	\N	\N	str
2388	2024-07-01 04:39:04.152+00	2024-07-01 04:39:04.152+00	f	\N	\N	Comisión	comision-2uwe	\N	\N	\N	\N	\N	str
2389	2024-07-01 04:39:04.158+00	2024-07-01 04:39:04.158+00	f	\N	\N	Fecha de socialización	fecha-de-socializacion-wuv4	\N	\N	\N	\N	\N	str
2390	2024-07-01 04:39:04.164+00	2024-07-01 04:39:04.164+00	f	\N	\N	Provincia	provincia-nz8v	\N	\N	\N	\N	\N	str
2391	2024-07-01 04:39:04.173+00	2024-07-01 04:39:04.173+00	f	\N	\N	Cantón	canton-4q9u	\N	\N	\N	\N	\N	str
2392	2024-07-01 04:39:04.18+00	2024-07-01 04:39:04.18+00	f	\N	\N	Temática abordada	tematica-abordada-n6tx	\N	\N	\N	\N	\N	str
2393	2024-07-01 04:39:04.187+00	2024-07-01 04:39:04.187+00	f	\N	\N	Público objetivo	publico-objetivo-ity0	\N	\N	\N	\N	\N	str
2394	2024-07-01 04:39:04.193+00	2024-07-01 04:39:04.193+00	f	\N	\N	Enlace a documentos de socialización	enlace-a-documentos-de-socializacion-mddp	\N	\N	\N	\N	\N	str
2395	2024-07-01 04:39:04.205+00	2024-07-01 04:39:04.205+00	f	\N	\N	No. Sesión	no-sesion-wxcb	\N	\N	\N	\N	\N	str
2396	2024-07-01 04:39:04.213+00	2024-07-01 04:39:04.213+00	f	\N	\N	Tipo	tipo-vl57	\N	\N	\N	\N	\N	str
2397	2024-07-01 04:39:04.221+00	2024-07-01 04:39:04.221+00	f	\N	\N	Pleno o nombre de la comisión	pleno-o-nombre-de-la-comision-9ffz	\N	\N	\N	\N	\N	str
2398	2024-07-01 04:39:04.227+00	2024-07-01 04:39:04.227+00	f	\N	\N	Fecha	fecha-agi8	\N	\N	\N	\N	\N	str
2399	2024-07-01 04:39:04.236+00	2024-07-01 04:39:04.236+00	f	\N	\N	Hora	hora-9x0u	\N	\N	\N	\N	\N	str
2400	2024-07-01 04:39:04.244+00	2024-07-01 04:39:04.244+00	f	\N	\N	Asambleísta	asambleista-8pnw	\N	\N	\N	\N	\N	str
2401	2024-07-01 04:39:04.252+00	2024-07-01 04:39:04.252+00	f	\N	\N	Asistencia	asistencia-2xs1	\N	\N	\N	\N	\N	str
2402	2024-07-01 04:39:04.26+00	2024-07-01 04:39:04.26+00	f	\N	\N	Enlace Acta	enlace-acta-rc5w	\N	\N	\N	\N	\N	str
2403	2024-07-01 04:39:04.275+00	2024-07-01 04:39:04.275+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-olke	\N	\N	\N	\N	\N	str
2404	2024-07-01 04:39:04.283+00	2024-07-01 04:39:04.283+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-xh7n	\N	\N	\N	\N	\N	str
2405	2024-07-01 04:39:04.291+00	2024-07-01 04:39:04.291+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-3s4q	\N	\N	\N	\N	\N	str
2406	2024-07-01 04:39:04.298+00	2024-07-01 04:39:04.298+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-8vxm	\N	\N	\N	\N	\N	str
2407	2024-07-01 04:39:04.307+00	2024-07-01 04:39:04.307+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-lo1c	\N	\N	\N	\N	\N	str
2408	2024-07-01 04:39:04.315+00	2024-07-01 04:39:04.315+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-17i1	\N	\N	\N	\N	\N	str
2409	2024-07-01 04:39:04.322+00	2024-07-01 04:39:04.322+00	f	\N	\N	LICENCIA	licencia-m2e0	\N	\N	\N	\N	\N	str
2410	2024-07-01 04:39:04.336+00	2024-07-01 04:39:04.336+00	f	\N	\N	Institución	institucion-nwgi	\N	\N	\N	\N	\N	str
2411	2024-07-01 04:39:04.346+00	2024-07-01 04:39:04.346+00	f	\N	\N	Descripción	descripcion-zk0k	\N	\N	\N	\N	\N	str
2412	2024-07-01 04:39:04.355+00	2024-07-01 04:39:04.355+00	f	\N	\N	Nombre del campo	nombre-del-campo-y6s9	\N	\N	\N	\N	\N	str
2413	2024-07-01 04:39:04.362+00	2024-07-01 04:39:04.362+00	f	\N	\N	No. Sesión	no-sesion-eivj	\N	\N	\N	\N	\N	str
2414	2024-07-01 04:39:04.372+00	2024-07-01 04:39:04.372+00	f	\N	\N	Tipo	tipo-xrqk	\N	\N	\N	\N	\N	str
2415	2024-07-01 04:39:04.381+00	2024-07-01 04:39:04.381+00	f	\N	\N	Pleno o nombre de la comisión	pleno-o-nombre-de-la-comision-oc34	\N	\N	\N	\N	\N	str
2416	2024-07-01 04:39:04.389+00	2024-07-01 04:39:04.389+00	f	\N	\N	Fecha	fecha-4cxq	\N	\N	\N	\N	\N	str
2417	2024-07-01 04:39:04.398+00	2024-07-01 04:39:04.398+00	f	\N	\N	Hora	hora-do5t	\N	\N	\N	\N	\N	str
2421	2024-07-01 04:39:04.433+00	2024-07-01 04:39:04.433+00	f	\N	\N	Tipo	tipo-7vgr	\N	\N	\N	\N	\N	str
2422	2024-07-01 04:39:04.441+00	2024-07-01 04:39:04.441+00	f	\N	\N	Pleno o nombre de la comisión	pleno-o-nombre-de-la-comision-91hz	\N	\N	\N	\N	\N	str
2423	2024-07-01 04:39:04.448+00	2024-07-01 04:39:04.448+00	f	\N	\N	Fecha	fecha-1fjo	\N	\N	\N	\N	\N	str
2424	2024-07-01 04:39:04.455+00	2024-07-01 04:39:04.455+00	f	\N	\N	Hora	hora-oucx	\N	\N	\N	\N	\N	str
2425	2024-07-01 04:39:04.462+00	2024-07-01 04:39:04.462+00	f	\N	\N	Moción	mocion-g3fu	\N	\N	\N	\N	\N	str
2426	2024-07-01 04:39:04.471+00	2024-07-01 04:39:04.471+00	f	\N	\N	Proponente	proponente-96dl	\N	\N	\N	\N	\N	str
2427	2024-07-01 04:39:04.48+00	2024-07-01 04:39:04.48+00	f	\N	\N	Asambleísta	asambleista-uv16	\N	\N	\N	\N	\N	str
2428	2024-07-01 04:39:04.487+00	2024-07-01 04:39:04.487+00	f	\N	\N	Voto	voto-lx0d	\N	\N	\N	\N	\N	str
2429	2024-07-01 04:39:04.5+00	2024-07-01 04:39:04.5+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-8nnw	\N	\N	\N	\N	\N	str
2430	2024-07-01 04:39:04.509+00	2024-07-01 04:39:04.509+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-ejz2	\N	\N	\N	\N	\N	str
2431	2024-07-01 04:39:04.517+00	2024-07-01 04:39:04.517+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-c6yi	\N	\N	\N	\N	\N	str
2432	2024-07-01 04:39:04.524+00	2024-07-01 04:39:04.524+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-e0j7	\N	\N	\N	\N	\N	str
2433	2024-07-01 04:39:04.532+00	2024-07-01 04:39:04.532+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-w5s4	\N	\N	\N	\N	\N	str
2434	2024-07-01 04:39:04.541+00	2024-07-01 04:39:04.541+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-c1v1	\N	\N	\N	\N	\N	str
2435	2024-07-01 04:39:04.548+00	2024-07-01 04:39:04.548+00	f	\N	\N	LICENCIA	licencia-hq4h	\N	\N	\N	\N	\N	str
2436	2024-07-01 04:39:04.56+00	2024-07-01 04:39:04.56+00	f	\N	\N	Institución	institucion-sh9y	\N	\N	\N	\N	\N	str
2437	2024-07-01 04:39:04.568+00	2024-07-01 04:39:04.568+00	f	\N	\N	Descripción	descripcion-pz2c	\N	\N	\N	\N	\N	str
2438	2024-07-01 04:39:04.576+00	2024-07-01 04:39:04.576+00	f	\N	\N	Nombre del campo	nombre-del-campo-1fkr	\N	\N	\N	\N	\N	str
2439	2024-07-01 04:39:04.583+00	2024-07-01 04:39:04.583+00	f	\N	\N	No. Sesión	no-sesion-ysq9	\N	\N	\N	\N	\N	str
2440	2024-07-01 04:39:04.59+00	2024-07-01 04:39:04.59+00	f	\N	\N	Tipo	tipo-4048	\N	\N	\N	\N	\N	str
2441	2024-07-01 04:39:04.596+00	2024-07-01 04:39:04.596+00	f	\N	\N	Pleno o nombre de la comisión	pleno-o-nombre-de-la-comision-v43b	\N	\N	\N	\N	\N	str
2442	2024-07-01 04:39:04.604+00	2024-07-01 04:39:04.604+00	f	\N	\N	Fecha	fecha-9dsq	\N	\N	\N	\N	\N	str
2443	2024-07-01 04:39:04.612+00	2024-07-01 04:39:04.612+00	f	\N	\N	Hora	hora-32g5	\N	\N	\N	\N	\N	str
2444	2024-07-01 04:39:04.62+00	2024-07-01 04:39:04.62+00	f	\N	\N	Moción	mocion-ect1	\N	\N	\N	\N	\N	str
2445	2024-07-01 04:39:04.626+00	2024-07-01 04:39:04.626+00	f	\N	\N	Proponente	proponente-jkv9	\N	\N	\N	\N	\N	str
2446	2024-07-01 04:39:04.633+00	2024-07-01 04:39:04.633+00	f	\N	\N	Asambleísta	asambleista-91dh	\N	\N	\N	\N	\N	str
2447	2024-07-01 04:39:04.641+00	2024-07-01 04:39:04.641+00	f	\N	\N	Voto	voto-ov8z	\N	\N	\N	\N	\N	str
2448	2024-07-01 04:39:04.653+00	2024-07-01 04:39:04.653+00	f	\N	\N	Institución	institucion-ups9	\N	\N	\N	\N	\N	str
2449	2024-07-01 04:39:04.659+00	2024-07-01 04:39:04.659+00	f	\N	\N	Asunto	asunto-588n	\N	\N	\N	\N	\N	str
2450	2024-07-01 04:39:04.666+00	2024-07-01 04:39:04.666+00	f	\N	\N	Asambleísta	asambleista-xrwq	\N	\N	\N	\N	\N	str
2451	2024-07-01 04:39:04.674+00	2024-07-01 04:39:04.674+00	f	\N	\N	Fecha Solicitud	fecha-solicitud-f1z2	\N	\N	\N	\N	\N	str
2452	2024-07-01 04:39:04.681+00	2024-07-01 04:39:04.681+00	f	\N	\N	DTS Solicitud	dts-solicitud-tu14	\N	\N	\N	\N	\N	str
2453	2024-07-01 04:39:04.687+00	2024-07-01 04:39:04.687+00	f	\N	\N	Fecha respuesta	fecha-respuesta-697w	\N	\N	\N	\N	\N	str
2454	2024-07-01 04:39:04.694+00	2024-07-01 04:39:04.694+00	f	\N	\N	No. Oficio Respuesta	no-oficio-respuesta-9mci	\N	\N	\N	\N	\N	str
2455	2024-07-01 04:39:04.701+00	2024-07-01 04:39:04.701+00	f	\N	\N	Enlace a documentos	enlace-a-documentos-wo3z	\N	\N	\N	\N	\N	str
2456	2024-07-01 04:39:04.716+00	2024-07-01 04:39:04.716+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-oimx	\N	\N	\N	\N	\N	str
2457	2024-07-01 04:39:04.723+00	2024-07-01 04:39:04.723+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-r9kd	\N	\N	\N	\N	\N	str
2458	2024-07-01 04:39:04.729+00	2024-07-01 04:39:04.729+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-377v	\N	\N	\N	\N	\N	str
2459	2024-07-01 04:39:04.736+00	2024-07-01 04:39:04.737+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-p9z3	\N	\N	\N	\N	\N	str
2460	2024-07-01 04:39:04.744+00	2024-07-01 04:39:04.744+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-3w1t	\N	\N	\N	\N	\N	str
2461	2024-07-01 04:39:04.752+00	2024-07-01 04:39:04.752+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-x6vz	\N	\N	\N	\N	\N	str
2462	2024-07-01 04:39:04.758+00	2024-07-01 04:39:04.758+00	f	\N	\N	LICENCIA	licencia-56lj	\N	\N	\N	\N	\N	str
2463	2024-07-01 04:39:04.772+00	2024-07-01 04:39:04.772+00	f	\N	\N	Institución	institucion-13pd	\N	\N	\N	\N	\N	str
2464	2024-07-01 04:39:04.781+00	2024-07-01 04:39:04.781+00	f	\N	\N	Descripción	descripcion-blmc	\N	\N	\N	\N	\N	str
2465	2024-07-01 04:39:04.79+00	2024-07-01 04:39:04.79+00	f	\N	\N	Nombre del campo	nombre-del-campo-se6c	\N	\N	\N	\N	\N	str
2466	2024-07-01 04:39:04.799+00	2024-07-01 04:39:04.799+00	f	\N	\N	Institución	institucion-spgq	\N	\N	\N	\N	\N	str
2467	2024-07-01 04:39:04.812+00	2024-07-01 04:39:04.812+00	f	\N	\N	Asunto	asunto-bk7e	\N	\N	\N	\N	\N	str
2468	2024-07-01 04:39:04.825+00	2024-07-01 04:39:04.825+00	f	\N	\N	Asambleísta	asambleista-1g4s	\N	\N	\N	\N	\N	str
2469	2024-07-01 04:39:04.836+00	2024-07-01 04:39:04.836+00	f	\N	\N	Fecha Solicitud	fecha-solicitud-0sw4	\N	\N	\N	\N	\N	str
2470	2024-07-01 04:39:04.845+00	2024-07-01 04:39:04.845+00	f	\N	\N	DTS Solicitud	dts-solicitud-ydph	\N	\N	\N	\N	\N	str
2471	2024-07-01 04:39:04.853+00	2024-07-01 04:39:04.853+00	f	\N	\N	Fecha respuesta	fecha-respuesta-1ujj	\N	\N	\N	\N	\N	str
2472	2024-07-01 04:39:04.861+00	2024-07-01 04:39:04.861+00	f	\N	\N	No. Oficio Respuesta	no-oficio-respuesta-l47s	\N	\N	\N	\N	\N	str
2473	2024-07-01 04:39:04.871+00	2024-07-01 04:39:04.871+00	f	\N	\N	Enlace a documentos	enlace-a-documentos-nxzt	\N	\N	\N	\N	\N	str
2474	2024-07-01 04:39:04.887+00	2024-07-01 04:39:04.887+00	f	\N	\N	Código	codigo-apst	\N	\N	\N	\N	\N	str
2475	2024-07-01 04:39:04.895+00	2024-07-01 04:39:04.895+00	f	\N	\N	Fecha de solicitud	fecha-de-solicitud-6wq1	\N	\N	\N	\N	\N	str
2476	2024-07-01 04:39:04.906+00	2024-07-01 04:39:04.906+00	f	\N	\N	Persona enjuiciada	persona-enjuiciada-nzfj	\N	\N	\N	\N	\N	str
2477	2024-07-01 04:39:04.916+00	2024-07-01 04:39:04.916+00	f	\N	\N	Solicitante (s)	solicitante-s-gcl0	\N	\N	\N	\N	\N	str
2478	2024-07-01 04:39:04.924+00	2024-07-01 04:39:04.924+00	f	\N	\N	Institución de la persona enjuiciada	institucion-de-la-persona-enjuiciada-yj0a	\N	\N	\N	\N	\N	str
2479	2024-07-01 04:39:04.933+00	2024-07-01 04:39:04.933+00	f	\N	\N	Fecha de resolución	fecha-de-resolucion-dr58	\N	\N	\N	\N	\N	str
2480	2024-07-01 04:39:04.945+00	2024-07-01 04:39:04.945+00	f	\N	\N	Estado	estado-b4o3	\N	\N	\N	\N	\N	str
2481	2024-07-01 04:39:04.955+00	2024-07-01 04:39:04.955+00	f	\N	\N	Documento o resolución	documento-o-resolucion-d5by	\N	\N	\N	\N	\N	str
2482	2024-07-01 04:39:04.963+00	2024-07-01 04:39:04.963+00	f	\N	\N	Enlace a documento	enlace-a-documento-ngt7	\N	\N	\N	\N	\N	str
2483	2024-07-01 04:39:04.98+00	2024-07-01 04:39:04.98+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-31hc	\N	\N	\N	\N	\N	str
2484	2024-07-01 04:39:04.988+00	2024-07-01 04:39:04.989+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-nceb	\N	\N	\N	\N	\N	str
2485	2024-07-01 04:39:04.997+00	2024-07-01 04:39:04.997+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-4jn3	\N	\N	\N	\N	\N	str
2486	2024-07-01 04:39:05.007+00	2024-07-01 04:39:05.007+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-2a2p	\N	\N	\N	\N	\N	str
2681	2024-07-01 04:39:06.834+00	2024-07-01 04:39:06.834+00	f	\N	\N	LICENCIA	licencia-p0hw	\N	\N	\N	\N	\N	str
2487	2024-07-01 04:39:05.016+00	2024-07-01 04:39:05.016+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-e0vv	\N	\N	\N	\N	\N	str
2488	2024-07-01 04:39:05.024+00	2024-07-01 04:39:05.024+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-oq6m	\N	\N	\N	\N	\N	str
2489	2024-07-01 04:39:05.032+00	2024-07-01 04:39:05.032+00	f	\N	\N	LICENCIA	licencia-qomi	\N	\N	\N	\N	\N	str
2490	2024-07-01 04:39:05.048+00	2024-07-01 04:39:05.048+00	f	\N	\N	Institución	institucion-prnz	\N	\N	\N	\N	\N	str
2491	2024-07-01 04:39:05.057+00	2024-07-01 04:39:05.057+00	f	\N	\N	Descripción	descripcion-4hqq	\N	\N	\N	\N	\N	str
2492	2024-07-01 04:39:05.066+00	2024-07-01 04:39:05.066+00	f	\N	\N	Nombre del campo	nombre-del-campo-m6gv	\N	\N	\N	\N	\N	str
2493	2024-07-01 04:39:05.077+00	2024-07-01 04:39:05.077+00	f	\N	\N	Código del trámite	codigo-del-tramite-jxci	\N	\N	\N	\N	\N	str
2494	2024-07-01 04:39:05.087+00	2024-07-01 04:39:05.087+00	f	\N	\N	Fecha de solicitud	fecha-de-solicitud-do40	\N	\N	\N	\N	\N	str
2495	2024-07-01 04:39:05.095+00	2024-07-01 04:39:05.095+00	f	\N	\N	Persona enjuiciada	persona-enjuiciada-knuf	\N	\N	\N	\N	\N	str
2496	2024-07-01 04:39:05.106+00	2024-07-01 04:39:05.106+00	f	\N	\N	Solicitante (s)	solicitante-s-61b6	\N	\N	\N	\N	\N	str
2497	2024-07-01 04:39:05.115+00	2024-07-01 04:39:05.115+00	f	\N	\N	Institución de la persona enjuiciada	institucion-de-la-persona-enjuiciada-wufc	\N	\N	\N	\N	\N	str
2498	2024-07-01 04:39:05.124+00	2024-07-01 04:39:05.124+00	f	\N	\N	Fecha de la resolución	fecha-de-la-resolucion-6qua	\N	\N	\N	\N	\N	str
2499	2024-07-01 04:39:05.134+00	2024-07-01 04:39:05.134+00	f	\N	\N	Estado	estado-in8d	\N	\N	\N	\N	\N	str
2500	2024-07-01 04:39:05.144+00	2024-07-01 04:39:05.144+00	f	\N	\N	Documento o resolución	documento-o-resolucion-bzlv	\N	\N	\N	\N	\N	str
2501	2024-07-01 04:39:05.154+00	2024-07-01 04:39:05.154+00	f	\N	\N	Enlace a documento	enlace-a-documento-k24u	\N	\N	\N	\N	\N	str
2502	2024-07-01 04:39:05.168+00	2024-07-01 04:39:05.168+00	f	\N	\N	Fecha	fecha-1ag4	\N	\N	\N	\N	\N	str
2503	2024-07-01 04:39:05.18+00	2024-07-01 04:39:05.18+00	f	\N	\N	Entidad	entidad-01l1	\N	\N	\N	\N	\N	str
2504	2024-07-01 04:39:05.189+00	2024-07-01 04:39:05.189+00	f	\N	\N	Tipo	tipo-t4ty	\N	\N	\N	\N	\N	str
2505	2024-07-01 04:39:05.197+00	2024-07-01 04:39:05.197+00	f	\N	\N	Detalle	detalle-hd48	\N	\N	\N	\N	\N	str
2506	2024-07-01 04:39:05.207+00	2024-07-01 04:39:05.207+00	f	\N	\N	Enlace a documento	enlace-a-documento-rall	\N	\N	\N	\N	\N	str
2507	2024-07-01 04:39:05.222+00	2024-07-01 04:39:05.222+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-ztsr	\N	\N	\N	\N	\N	str
2508	2024-07-01 04:39:05.23+00	2024-07-01 04:39:05.23+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-54v2	\N	\N	\N	\N	\N	str
2509	2024-07-01 04:39:05.24+00	2024-07-01 04:39:05.24+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-wtfs	\N	\N	\N	\N	\N	str
2510	2024-07-01 04:39:05.251+00	2024-07-01 04:39:05.251+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-5kki	\N	\N	\N	\N	\N	str
2511	2024-07-01 04:39:05.258+00	2024-07-01 04:39:05.258+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-y313	\N	\N	\N	\N	\N	str
2512	2024-07-01 04:39:05.27+00	2024-07-01 04:39:05.27+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-saci	\N	\N	\N	\N	\N	str
2513	2024-07-01 04:39:05.28+00	2024-07-01 04:39:05.28+00	f	\N	\N	LICENCIA	licencia-jh7k	\N	\N	\N	\N	\N	str
2514	2024-07-01 04:39:05.297+00	2024-07-01 04:39:05.297+00	f	\N	\N	Institución	institucion-kfwv	\N	\N	\N	\N	\N	str
2515	2024-07-01 04:39:05.307+00	2024-07-01 04:39:05.307+00	f	\N	\N	Descripción	descripcion-y5z0	\N	\N	\N	\N	\N	str
2516	2024-07-01 04:39:05.317+00	2024-07-01 04:39:05.317+00	f	\N	\N	Nombre del campo	nombre-del-campo-fcpm	\N	\N	\N	\N	\N	str
2517	2024-07-01 04:39:05.325+00	2024-07-01 04:39:05.325+00	f	\N	\N	Fecha	fecha-tku0	\N	\N	\N	\N	\N	str
2518	2024-07-01 04:39:05.333+00	2024-07-01 04:39:05.333+00	f	\N	\N	Entidad	entidad-ow6m	\N	\N	\N	\N	\N	str
2519	2024-07-01 04:39:05.343+00	2024-07-01 04:39:05.343+00	f	\N	\N	Tipo	tipo-4o8j	\N	\N	\N	\N	\N	str
2520	2024-07-01 04:39:05.352+00	2024-07-01 04:39:05.352+00	f	\N	\N	Detalle	detalle-vpzz	\N	\N	\N	\N	\N	str
2521	2024-07-01 04:39:05.36+00	2024-07-01 04:39:05.36+00	f	\N	\N	Enlace a documento	enlace-a-documento-o3c4	\N	\N	\N	\N	\N	str
2522	2024-07-01 04:39:05.377+00	2024-07-01 04:39:05.377+00	f	\N	\N	Fecha	fecha-z3ur	\N	\N	\N	\N	\N	str
2523	2024-07-01 04:39:05.386+00	2024-07-01 04:39:05.386+00	f	\N	\N	Asambleísta	asambleista-5qq6	\N	\N	\N	\N	\N	str
2524	2024-07-01 04:39:05.395+00	2024-07-01 04:39:05.395+00	f	\N	\N	Principal o suplente	principal-o-suplente-1tdq	\N	\N	\N	\N	\N	str
2525	2024-07-01 04:39:05.404+00	2024-07-01 04:39:05.404+00	f	\N	\N	Período de funciones	periodo-de-funciones-1l6y	\N	\N	\N	\N	\N	str
2526	2024-07-01 04:39:05.414+00	2024-07-01 04:39:05.414+00	f	\N	\N	Enlace a declaración	enlace-a-declaracion-75a8	\N	\N	\N	\N	\N	str
2527	2024-07-01 04:39:05.429+00	2024-07-01 04:39:05.429+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-vbvx	\N	\N	\N	\N	\N	str
2528	2024-07-01 04:39:05.441+00	2024-07-01 04:39:05.441+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-zckw	\N	\N	\N	\N	\N	str
2529	2024-07-01 04:39:05.451+00	2024-07-01 04:39:05.451+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-2bet	\N	\N	\N	\N	\N	str
2530	2024-07-01 04:39:05.459+00	2024-07-01 04:39:05.459+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-a78m	\N	\N	\N	\N	\N	str
2531	2024-07-01 04:39:05.469+00	2024-07-01 04:39:05.469+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-9t2s	\N	\N	\N	\N	\N	str
2532	2024-07-01 04:39:05.479+00	2024-07-01 04:39:05.479+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-s3vj	\N	\N	\N	\N	\N	str
2533	2024-07-01 04:39:05.489+00	2024-07-01 04:39:05.489+00	f	\N	\N	LICENCIA	licencia-ntgy	\N	\N	\N	\N	\N	str
2534	2024-07-01 04:39:05.504+00	2024-07-01 04:39:05.504+00	f	\N	\N	Institución	institucion-fcrx	\N	\N	\N	\N	\N	str
2535	2024-07-01 04:39:05.513+00	2024-07-01 04:39:05.513+00	f	\N	\N	Descripción	descripcion-m34o	\N	\N	\N	\N	\N	str
2536	2024-07-01 04:39:05.521+00	2024-07-01 04:39:05.521+00	f	\N	\N	Nombre del campo	nombre-del-campo-799z	\N	\N	\N	\N	\N	str
2537	2024-07-01 04:39:05.528+00	2024-07-01 04:39:05.528+00	f	\N	\N	Fecha	fecha-at6j	\N	\N	\N	\N	\N	str
2538	2024-07-01 04:39:05.536+00	2024-07-01 04:39:05.536+00	f	\N	\N	Asambleísta	asambleista-yg9j	\N	\N	\N	\N	\N	str
2539	2024-07-01 04:39:05.544+00	2024-07-01 04:39:05.544+00	f	\N	\N	Principal o suplente	principal-o-suplente-yefq	\N	\N	\N	\N	\N	str
2540	2024-07-01 04:39:05.552+00	2024-07-01 04:39:05.552+00	f	\N	\N	Período de funciones	periodo-de-funciones-grj8	\N	\N	\N	\N	\N	str
2541	2024-07-01 04:39:05.559+00	2024-07-01 04:39:05.559+00	f	\N	\N	Enlace a declaración	enlace-a-declaracion-6x15	\N	\N	\N	\N	\N	str
2542	2024-07-01 04:39:05.576+00	2024-07-01 04:39:05.576+00	f	\N	\N	Código	codigo-cpvd	\N	\N	\N	\N	\N	str
2543	2024-07-01 04:39:05.584+00	2024-07-01 04:39:05.584+00	f	\N	\N	Tipo	tipo-pcj0	\N	\N	\N	\N	\N	str
2544	2024-07-01 04:39:05.591+00	2024-07-01 04:39:05.591+00	f	\N	\N	Concesionario o Empresa	concesionario-o-empresa-hbv5	\N	\N	\N	\N	\N	str
2545	2024-07-01 04:39:05.598+00	2024-07-01 04:39:05.598+00	f	\N	\N	Fase	fase-mbaz	\N	\N	\N	\N	\N	str
2546	2024-07-01 04:39:05.607+00	2024-07-01 04:39:05.607+00	f	\N	\N	Recurso	recurso-s6py	\N	\N	\N	\N	\N	str
2547	2024-07-01 04:39:05.615+00	2024-07-01 04:39:05.615+00	f	\N	\N	Forma o Método	forma-o-metodo-mauv	\N	\N	\N	\N	\N	str
2548	2024-07-01 04:39:05.622+00	2024-07-01 04:39:05.622+00	f	\N	\N	Estado	estado-24wh	\N	\N	\N	\N	\N	str
2549	2024-07-01 04:39:05.629+00	2024-07-01 04:39:05.629+00	f	\N	\N	Fecha de Otorgamiento	fecha-de-otorgamiento-knt1	\N	\N	\N	\N	\N	str
2550	2024-07-01 04:39:05.638+00	2024-07-01 04:39:05.638+00	f	\N	\N	Monto de Concesión o Contrato	monto-de-concesion-o-contrato-onjd	\N	\N	\N	\N	\N	str
2551	2024-07-01 04:39:05.647+00	2024-07-01 04:39:05.647+00	f	\N	\N	Superficie	superficie-fdbk	\N	\N	\N	\N	\N	str
2552	2024-07-01 04:39:05.655+00	2024-07-01 04:39:05.655+00	f	\N	\N	Plazo	plazo-z8uc	\N	\N	\N	\N	\N	str
2553	2024-07-01 04:39:05.662+00	2024-07-01 04:39:05.662+00	f	\N	\N	Destino de Recursos	destino-de-recursos-uhhf	\N	\N	\N	\N	\N	str
2554	2024-07-01 04:39:05.671+00	2024-07-01 04:39:05.671+00	f	\N	\N	Provincia	provincia-d10z	\N	\N	\N	\N	\N	str
2555	2024-07-01 04:39:05.68+00	2024-07-01 04:39:05.68+00	f	\N	\N	Cantón	canton-gkzd	\N	\N	\N	\N	\N	str
2556	2024-07-01 04:39:05.688+00	2024-07-01 04:39:05.688+00	f	\N	\N	Parroquia	parroquia-w9tb	\N	\N	\N	\N	\N	str
2557	2024-07-01 04:39:05.702+00	2024-07-01 04:39:05.702+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-m0y4	\N	\N	\N	\N	\N	str
2558	2024-07-01 04:39:05.711+00	2024-07-01 04:39:05.711+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-ibo5	\N	\N	\N	\N	\N	str
2559	2024-07-01 04:39:05.719+00	2024-07-01 04:39:05.719+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-fhg9	\N	\N	\N	\N	\N	str
2560	2024-07-01 04:39:05.726+00	2024-07-01 04:39:05.726+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-d09z	\N	\N	\N	\N	\N	str
2561	2024-07-01 04:39:05.735+00	2024-07-01 04:39:05.735+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-sk5b	\N	\N	\N	\N	\N	str
2562	2024-07-01 04:39:05.744+00	2024-07-01 04:39:05.744+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-4jto	\N	\N	\N	\N	\N	str
2563	2024-07-01 04:39:05.752+00	2024-07-01 04:39:05.752+00	f	\N	\N	LICENCIA	licencia-f56y	\N	\N	\N	\N	\N	str
2564	2024-07-01 04:39:05.766+00	2024-07-01 04:39:05.766+00	f	\N	\N	Institución	institucion-49bg	\N	\N	\N	\N	\N	str
2565	2024-07-01 04:39:05.773+00	2024-07-01 04:39:05.773+00	f	\N	\N	Descripción	descripcion-3idx	\N	\N	\N	\N	\N	str
2566	2024-07-01 04:39:05.783+00	2024-07-01 04:39:05.783+00	f	\N	\N	Nombre del campo	nombre-del-campo-e5xs	\N	\N	\N	\N	\N	str
2567	2024-07-01 04:39:05.791+00	2024-07-01 04:39:05.791+00	f	\N	\N	Código	codigo-0trn	\N	\N	\N	\N	\N	str
2568	2024-07-01 04:39:05.798+00	2024-07-01 04:39:05.798+00	f	\N	\N	Tipo	tipo-3pzf	\N	\N	\N	\N	\N	str
2569	2024-07-01 04:39:05.808+00	2024-07-01 04:39:05.808+00	f	\N	\N	Concesionario o Empresa	concesionario-o-empresa-74dv	\N	\N	\N	\N	\N	str
2570	2024-07-01 04:39:05.815+00	2024-07-01 04:39:05.815+00	f	\N	\N	Fase	fase-dd0b	\N	\N	\N	\N	\N	str
2571	2024-07-01 04:39:05.824+00	2024-07-01 04:39:05.824+00	f	\N	\N	Recurso	recurso-soml	\N	\N	\N	\N	\N	str
2572	2024-07-01 04:39:05.83+00	2024-07-01 04:39:05.83+00	f	\N	\N	Forma o Método	forma-o-metodo-2nea	\N	\N	\N	\N	\N	str
2573	2024-07-01 04:39:05.842+00	2024-07-01 04:39:05.842+00	f	\N	\N	Estado	estado-ktwf	\N	\N	\N	\N	\N	str
2574	2024-07-01 04:39:05.85+00	2024-07-01 04:39:05.85+00	f	\N	\N	Fecha de Otorgamiento	fecha-de-otorgamiento-muix	\N	\N	\N	\N	\N	str
2575	2024-07-01 04:39:05.858+00	2024-07-01 04:39:05.858+00	f	\N	\N	Monto de Concesión o Contrato	monto-de-concesion-o-contrato-u1cj	\N	\N	\N	\N	\N	str
2576	2024-07-01 04:39:05.866+00	2024-07-01 04:39:05.866+00	f	\N	\N	Superficie	superficie-4m5j	\N	\N	\N	\N	\N	str
2577	2024-07-01 04:39:05.876+00	2024-07-01 04:39:05.876+00	f	\N	\N	Plazo	plazo-tjs5	\N	\N	\N	\N	\N	str
2578	2024-07-01 04:39:05.884+00	2024-07-01 04:39:05.884+00	f	\N	\N	Destino de Recursos	destino-de-recursos-v6c9	\N	\N	\N	\N	\N	str
2579	2024-07-01 04:39:05.892+00	2024-07-01 04:39:05.892+00	f	\N	\N	Provincia	provincia-w6uq	\N	\N	\N	\N	\N	str
2580	2024-07-01 04:39:05.9+00	2024-07-01 04:39:05.9+00	f	\N	\N	Cantón	canton-jb3a	\N	\N	\N	\N	\N	str
2581	2024-07-01 04:39:05.909+00	2024-07-01 04:39:05.909+00	f	\N	\N	Parroquia	parroquia-r3fm	\N	\N	\N	\N	\N	str
2582	2024-07-01 04:39:05.924+00	2024-07-01 04:39:05.924+00	f	\N	\N	Código	codigo-gr6r	\N	\N	\N	\N	\N	str
2583	2024-07-01 04:39:05.933+00	2024-07-01 04:39:05.933+00	f	\N	\N	Tipo	tipo-vr6k	\N	\N	\N	\N	\N	str
2584	2024-07-01 04:39:05.944+00	2024-07-01 04:39:05.944+00	f	\N	\N	Concesionario o Empresa	concesionario-o-empresa-064b	\N	\N	\N	\N	\N	str
2585	2024-07-01 04:39:05.953+00	2024-07-01 04:39:05.953+00	f	\N	\N	Fecha del pago	fecha-del-pago-z6pz	\N	\N	\N	\N	\N	str
2586	2024-07-01 04:39:05.961+00	2024-07-01 04:39:05.961+00	f	\N	\N	Monto	monto-fric	\N	\N	\N	\N	\N	str
2587	2024-07-01 04:39:05.972+00	2024-07-01 04:39:05.972+00	f	\N	\N	Concepto	concepto-6ihk	\N	\N	\N	\N	\N	str
2588	2024-07-01 04:39:05.98+00	2024-07-01 04:39:05.98+00	f	\N	\N	Beneficiario	beneficiario-4tt6	\N	\N	\N	\N	\N	str
2589	2024-07-01 04:39:05.99+00	2024-07-01 04:39:05.99+00	f	\N	\N	Detalle	detalle-u7tb	\N	\N	\N	\N	\N	str
2590	2024-07-01 04:39:06.005+00	2024-07-01 04:39:06.005+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-ex43	\N	\N	\N	\N	\N	str
2591	2024-07-01 04:39:06.015+00	2024-07-01 04:39:06.015+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-0xmk	\N	\N	\N	\N	\N	str
2592	2024-07-01 04:39:06.023+00	2024-07-01 04:39:06.023+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-df7m	\N	\N	\N	\N	\N	str
2593	2024-07-01 04:39:06.029+00	2024-07-01 04:39:06.029+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-v1rj	\N	\N	\N	\N	\N	str
2594	2024-07-01 04:39:06.038+00	2024-07-01 04:39:06.038+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-jr6k	\N	\N	\N	\N	\N	str
2595	2024-07-01 04:39:06.046+00	2024-07-01 04:39:06.047+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-ibmh	\N	\N	\N	\N	\N	str
2596	2024-07-01 04:39:06.055+00	2024-07-01 04:39:06.055+00	f	\N	\N	LICENCIA	licencia-w0vd	\N	\N	\N	\N	\N	str
2597	2024-07-01 04:39:06.068+00	2024-07-01 04:39:06.068+00	f	\N	\N	Institución	institucion-vawn	\N	\N	\N	\N	\N	str
2598	2024-07-01 04:39:06.076+00	2024-07-01 04:39:06.076+00	f	\N	\N	Descripción	descripcion-wyqd	\N	\N	\N	\N	\N	str
2599	2024-07-01 04:39:06.084+00	2024-07-01 04:39:06.084+00	f	\N	\N	Nombre del campo	nombre-del-campo-o5d4	\N	\N	\N	\N	\N	str
2600	2024-07-01 04:39:06.09+00	2024-07-01 04:39:06.09+00	f	\N	\N	Código	codigo-2e1x	\N	\N	\N	\N	\N	str
2601	2024-07-01 04:39:06.098+00	2024-07-01 04:39:06.098+00	f	\N	\N	Tipo	tipo-j2nj	\N	\N	\N	\N	\N	str
2602	2024-07-01 04:39:06.106+00	2024-07-01 04:39:06.106+00	f	\N	\N	Concesionario o Empresa	concesionario-o-empresa-nq6n	\N	\N	\N	\N	\N	str
2603	2024-07-01 04:39:06.114+00	2024-07-01 04:39:06.114+00	f	\N	\N	Fecha del pago	fecha-del-pago-nbmf	\N	\N	\N	\N	\N	str
2604	2024-07-01 04:39:06.122+00	2024-07-01 04:39:06.122+00	f	\N	\N	Monto	monto-zenf	\N	\N	\N	\N	\N	str
2605	2024-07-01 04:39:06.13+00	2024-07-01 04:39:06.13+00	f	\N	\N	Concepto	concepto-uk8n	\N	\N	\N	\N	\N	str
2606	2024-07-01 04:39:06.138+00	2024-07-01 04:39:06.138+00	f	\N	\N	Beneficiario	beneficiario-8npu	\N	\N	\N	\N	\N	str
2607	2024-07-01 04:39:06.146+00	2024-07-01 04:39:06.146+00	f	\N	\N	Detalle	detalle-7cjl	\N	\N	\N	\N	\N	str
2608	2024-07-01 04:39:06.158+00	2024-07-01 04:39:06.158+00	f	\N	\N	Código	codigo-gsei	\N	\N	\N	\N	\N	str
2609	2024-07-01 04:39:06.164+00	2024-07-01 04:39:06.164+00	f	\N	\N	Tipo	tipo-els9	\N	\N	\N	\N	\N	str
2610	2024-07-01 04:39:06.174+00	2024-07-01 04:39:06.174+00	f	\N	\N	Concesionario o Empresa	concesionario-o-empresa-lyu1	\N	\N	\N	\N	\N	str
2611	2024-07-01 04:39:06.182+00	2024-07-01 04:39:06.182+00	f	\N	\N	Rubro	rubro-u9dk	\N	\N	\N	\N	\N	str
2612	2024-07-01 04:39:06.189+00	2024-07-01 04:39:06.189+00	f	\N	\N	Valor	valor-d9rx	\N	\N	\N	\N	\N	str
2613	2024-07-01 04:39:06.201+00	2024-07-01 04:39:06.201+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-2ob9	\N	\N	\N	\N	\N	str
2614	2024-07-01 04:39:06.209+00	2024-07-01 04:39:06.209+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-v8rz	\N	\N	\N	\N	\N	str
2615	2024-07-01 04:39:06.218+00	2024-07-01 04:39:06.218+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-r2td	\N	\N	\N	\N	\N	str
2616	2024-07-01 04:39:06.225+00	2024-07-01 04:39:06.225+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-hllu	\N	\N	\N	\N	\N	str
2617	2024-07-01 04:39:06.233+00	2024-07-01 04:39:06.233+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-g68k	\N	\N	\N	\N	\N	str
2682	2024-07-01 04:39:06.847+00	2024-07-01 04:39:06.847+00	f	\N	\N	Institución	institucion-9irc	\N	\N	\N	\N	\N	str
2683	2024-07-01 04:39:06.854+00	2024-07-01 04:39:06.854+00	f	\N	\N	Descripción	descripcion-mgoo	\N	\N	\N	\N	\N	str
2618	2024-07-01 04:39:06.243+00	2024-07-01 04:39:06.243+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-82sj	\N	\N	\N	\N	\N	str
2619	2024-07-01 04:39:06.251+00	2024-07-01 04:39:06.251+00	f	\N	\N	LICENCIA	licencia-jdgp	\N	\N	\N	\N	\N	str
2620	2024-07-01 04:39:06.262+00	2024-07-01 04:39:06.262+00	f	\N	\N	Institución	institucion-oshn	\N	\N	\N	\N	\N	str
2621	2024-07-01 04:39:06.269+00	2024-07-01 04:39:06.269+00	f	\N	\N	Descripción	descripcion-obtl	\N	\N	\N	\N	\N	str
2622	2024-07-01 04:39:06.279+00	2024-07-01 04:39:06.279+00	f	\N	\N	Nombre del campo	nombre-del-campo-8of4	\N	\N	\N	\N	\N	str
2623	2024-07-01 04:39:06.287+00	2024-07-01 04:39:06.287+00	f	\N	\N	Código	codigo-k5j0	\N	\N	\N	\N	\N	str
2624	2024-07-01 04:39:06.294+00	2024-07-01 04:39:06.294+00	f	\N	\N	Tipo	tipo-cytp	\N	\N	\N	\N	\N	str
2625	2024-07-01 04:39:06.302+00	2024-07-01 04:39:06.302+00	f	\N	\N	Concesionario o Empresa	concesionario-o-empresa-a858	\N	\N	\N	\N	\N	str
2626	2024-07-01 04:39:06.311+00	2024-07-01 04:39:06.311+00	f	\N	\N	Rubro	rubro-qmtl	\N	\N	\N	\N	\N	str
2627	2024-07-01 04:39:06.32+00	2024-07-01 04:39:06.32+00	f	\N	\N	Valor	valor-sal0	\N	\N	\N	\N	\N	str
2628	2024-07-01 04:39:06.337+00	2024-07-01 04:39:06.337+00	f	\N	\N	Nombre de Empresa Pública	nombre-de-empresa-publica-in8y	\N	\N	\N	\N	\N	str
2629	2024-07-01 04:39:06.347+00	2024-07-01 04:39:06.347+00	f	\N	\N	Fecha	fecha-x6tg	\N	\N	\N	\N	\N	str
2630	2024-07-01 04:39:06.355+00	2024-07-01 04:39:06.355+00	f	\N	\N	Nombre de Informe	nombre-de-informe-736y	\N	\N	\N	\N	\N	str
2631	2024-07-01 04:39:06.362+00	2024-07-01 04:39:06.362+00	f	\N	\N	Enlace a Informe	enlace-a-informe-gn5i	\N	\N	\N	\N	\N	str
2632	2024-07-01 04:39:06.376+00	2024-07-01 04:39:06.376+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-q01v	\N	\N	\N	\N	\N	str
2633	2024-07-01 04:39:06.385+00	2024-07-01 04:39:06.385+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-ds4e	\N	\N	\N	\N	\N	str
2634	2024-07-01 04:39:06.392+00	2024-07-01 04:39:06.392+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-hws1	\N	\N	\N	\N	\N	str
2635	2024-07-01 04:39:06.399+00	2024-07-01 04:39:06.399+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-snjr	\N	\N	\N	\N	\N	str
2636	2024-07-01 04:39:06.407+00	2024-07-01 04:39:06.407+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-4vat	\N	\N	\N	\N	\N	str
2637	2024-07-01 04:39:06.415+00	2024-07-01 04:39:06.415+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-3klv	\N	\N	\N	\N	\N	str
2638	2024-07-01 04:39:06.423+00	2024-07-01 04:39:06.423+00	f	\N	\N	LICENCIA	licencia-9pre	\N	\N	\N	\N	\N	str
2639	2024-07-01 04:39:06.435+00	2024-07-01 04:39:06.435+00	f	\N	\N	Institución	institucion-18zl	\N	\N	\N	\N	\N	str
2640	2024-07-01 04:39:06.445+00	2024-07-01 04:39:06.445+00	f	\N	\N	Descripción	descripcion-aqgq	\N	\N	\N	\N	\N	str
2641	2024-07-01 04:39:06.453+00	2024-07-01 04:39:06.453+00	f	\N	\N	Nombre del campo	nombre-del-campo-a07o	\N	\N	\N	\N	\N	str
2642	2024-07-01 04:39:06.461+00	2024-07-01 04:39:06.461+00	f	\N	\N	Nombre de Empresa Pública	nombre-de-empresa-publica-at1p	\N	\N	\N	\N	\N	str
2643	2024-07-01 04:39:06.472+00	2024-07-01 04:39:06.472+00	f	\N	\N	Fecha	fecha-7ezi	\N	\N	\N	\N	\N	str
2644	2024-07-01 04:39:06.482+00	2024-07-01 04:39:06.482+00	f	\N	\N	Nombre de Informe	nombre-de-informe-xjry	\N	\N	\N	\N	\N	str
2645	2024-07-01 04:39:06.491+00	2024-07-01 04:39:06.491+00	f	\N	\N	Enlace a Informe	enlace-a-informe-e1nc	\N	\N	\N	\N	\N	str
2646	2024-07-01 04:39:06.507+00	2024-07-01 04:39:06.507+00	f	\N	\N	Fecha	fecha-u61i	\N	\N	\N	\N	\N	str
2647	2024-07-01 04:39:06.516+00	2024-07-01 04:39:06.516+00	f	\N	\N	Empresa Pública	empresa-publica-jijg	\N	\N	\N	\N	\N	str
2648	2024-07-01 04:39:06.524+00	2024-07-01 04:39:06.524+00	f	\N	\N	Tipo	tipo-tmdh	\N	\N	\N	\N	\N	str
2649	2024-07-01 04:39:06.533+00	2024-07-01 04:39:06.533+00	f	\N	\N	Título	titulo-q1zb	\N	\N	\N	\N	\N	str
2650	2024-07-01 04:39:06.545+00	2024-07-01 04:39:06.545+00	f	\N	\N	Enlace Acta	enlace-acta-xh2c	\N	\N	\N	\N	\N	str
2651	2024-07-01 04:39:06.559+00	2024-07-01 04:39:06.559+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-ezp7	\N	\N	\N	\N	\N	str
2652	2024-07-01 04:39:06.568+00	2024-07-01 04:39:06.568+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-1jis	\N	\N	\N	\N	\N	str
2653	2024-07-01 04:39:06.578+00	2024-07-01 04:39:06.578+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-4gag	\N	\N	\N	\N	\N	str
2654	2024-07-01 04:39:06.588+00	2024-07-01 04:39:06.588+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-3ag5	\N	\N	\N	\N	\N	str
2655	2024-07-01 04:39:06.596+00	2024-07-01 04:39:06.596+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-isw3	\N	\N	\N	\N	\N	str
2656	2024-07-01 04:39:06.606+00	2024-07-01 04:39:06.606+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-u3l0	\N	\N	\N	\N	\N	str
2657	2024-07-01 04:39:06.616+00	2024-07-01 04:39:06.616+00	f	\N	\N	LICENCIA	licencia-w9xo	\N	\N	\N	\N	\N	str
2658	2024-07-01 04:39:06.631+00	2024-07-01 04:39:06.631+00	f	\N	\N	Institución	institucion-hv4b	\N	\N	\N	\N	\N	str
2659	2024-07-01 04:39:06.644+00	2024-07-01 04:39:06.644+00	f	\N	\N	Descripción	descripcion-9519	\N	\N	\N	\N	\N	str
2660	2024-07-01 04:39:06.653+00	2024-07-01 04:39:06.653+00	f	\N	\N	Nombre del campo	nombre-del-campo-kvcj	\N	\N	\N	\N	\N	str
2661	2024-07-01 04:39:06.662+00	2024-07-01 04:39:06.662+00	f	\N	\N	Fecha	fecha-s15f	\N	\N	\N	\N	\N	str
2662	2024-07-01 04:39:06.672+00	2024-07-01 04:39:06.672+00	f	\N	\N	Empresa Pública	empresa-publica-e0wj	\N	\N	\N	\N	\N	str
2663	2024-07-01 04:39:06.682+00	2024-07-01 04:39:06.682+00	f	\N	\N	Tipo	tipo-m8fu	\N	\N	\N	\N	\N	str
2664	2024-07-01 04:39:06.692+00	2024-07-01 04:39:06.692+00	f	\N	\N	Título	titulo-d97g	\N	\N	\N	\N	\N	str
2665	2024-07-01 04:39:06.699+00	2024-07-01 04:39:06.699+00	f	\N	\N	Enlace Acta	enlace-acta-m7di	\N	\N	\N	\N	\N	str
2666	2024-07-01 04:39:06.714+00	2024-07-01 04:39:06.714+00	f	\N	\N	Fecha	fecha-j5wp	\N	\N	\N	\N	\N	str
2667	2024-07-01 04:39:06.723+00	2024-07-01 04:39:06.723+00	f	\N	\N	Empresa Pública	empresa-publica-ctub	\N	\N	\N	\N	\N	str
2668	2024-07-01 04:39:06.73+00	2024-07-01 04:39:06.73+00	f	\N	\N	Persona natural o jurídica que solicita	persona-natural-o-juridica-que-solicita-i503	\N	\N	\N	\N	\N	str
2669	2024-07-01 04:39:06.74+00	2024-07-01 04:39:06.74+00	f	\N	\N	Tipo	tipo-qkbz	\N	\N	\N	\N	\N	str
2670	2024-07-01 04:39:06.747+00	2024-07-01 04:39:06.747+00	f	\N	\N	Número	numero-kpsz	\N	\N	\N	\N	\N	str
2671	2024-07-01 04:39:06.755+00	2024-07-01 04:39:06.755+00	f	\N	\N	Detalle	detalle-uhiq	\N	\N	\N	\N	\N	str
2672	2024-07-01 04:39:06.761+00	2024-07-01 04:39:06.761+00	f	\N	\N	Estado	estado-lm0q	\N	\N	\N	\N	\N	str
2673	2024-07-01 04:39:06.77+00	2024-07-01 04:39:06.77+00	f	\N	\N	Fecha de resolución	fecha-de-resolucion-7186	\N	\N	\N	\N	\N	str
2674	2024-07-01 04:39:06.778+00	2024-07-01 04:39:06.778+00	f	\N	\N	Enlace Documentación	enlace-documentacion-p2d3	\N	\N	\N	\N	\N	str
2675	2024-07-01 04:39:06.79+00	2024-07-01 04:39:06.79+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-tu9b	\N	\N	\N	\N	\N	str
2676	2024-07-01 04:39:06.796+00	2024-07-01 04:39:06.796+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-0chy	\N	\N	\N	\N	\N	str
2677	2024-07-01 04:39:06.804+00	2024-07-01 04:39:06.804+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-kvzl	\N	\N	\N	\N	\N	str
2678	2024-07-01 04:39:06.812+00	2024-07-01 04:39:06.812+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-1wgl	\N	\N	\N	\N	\N	str
2679	2024-07-01 04:39:06.82+00	2024-07-01 04:39:06.82+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-338y	\N	\N	\N	\N	\N	str
2680	2024-07-01 04:39:06.826+00	2024-07-01 04:39:06.826+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-1urc	\N	\N	\N	\N	\N	str
2684	2024-07-01 04:39:06.86+00	2024-07-01 04:39:06.86+00	f	\N	\N	Nombre del campo	nombre-del-campo-bjw4	\N	\N	\N	\N	\N	str
2685	2024-07-01 04:39:06.868+00	2024-07-01 04:39:06.868+00	f	\N	\N	Fecha	fecha-6hwn	\N	\N	\N	\N	\N	str
2686	2024-07-01 04:39:06.876+00	2024-07-01 04:39:06.876+00	f	\N	\N	Empresa Pública	empresa-publica-4fxm	\N	\N	\N	\N	\N	str
2687	2024-07-01 04:39:06.884+00	2024-07-01 04:39:06.884+00	f	\N	\N	Persona natural o jurídica que solicita	persona-natural-o-juridica-que-solicita-jgir	\N	\N	\N	\N	\N	str
2688	2024-07-01 04:39:06.89+00	2024-07-01 04:39:06.891+00	f	\N	\N	Tipo	tipo-teat	\N	\N	\N	\N	\N	str
2689	2024-07-01 04:39:06.897+00	2024-07-01 04:39:06.897+00	f	\N	\N	Número	numero-fx8w	\N	\N	\N	\N	\N	str
2690	2024-07-01 04:39:06.905+00	2024-07-01 04:39:06.905+00	f	\N	\N	Detalle	detalle-xido	\N	\N	\N	\N	\N	str
2691	2024-07-01 04:39:06.913+00	2024-07-01 04:39:06.913+00	f	\N	\N	Estado	estado-abqw	\N	\N	\N	\N	\N	str
2692	2024-07-01 04:39:06.92+00	2024-07-01 04:39:06.92+00	f	\N	\N	Fecha de resolución	fecha-de-resolucion-9nl5	\N	\N	\N	\N	\N	str
2693	2024-07-01 04:39:06.927+00	2024-07-01 04:39:06.927+00	f	\N	\N	Enlace Documentación	enlace-documentacion-kw5u	\N	\N	\N	\N	\N	str
2694	2024-07-01 04:39:06.943+00	2024-07-01 04:39:06.943+00	f	\N	\N	Tipo de Contrato	tipo-de-contrato-98qp	\N	\N	\N	\N	\N	str
2695	2024-07-01 04:39:06.95+00	2024-07-01 04:39:06.95+00	f	\N	\N	Objeto 	objeto-74qh	\N	\N	\N	\N	\N	str
2696	2024-07-01 04:39:06.956+00	2024-07-01 04:39:06.956+00	f	\N	\N	Fecha de suscripción o renovación	fecha-de-suscripcion-o-renovacion-wl9v	\N	\N	\N	\N	\N	str
2697	2024-07-01 04:39:06.962+00	2024-07-01 04:39:06.962+00	f	\N	\N	Nombre Deudor	nombre-deudor-llaw	\N	\N	\N	\N	\N	str
2698	2024-07-01 04:39:06.971+00	2024-07-01 04:39:06.971+00	f	\N	\N	Nombre Acreedor	nombre-acreedor-h3cw	\N	\N	\N	\N	\N	str
2699	2024-07-01 04:39:06.978+00	2024-07-01 04:39:06.978+00	f	\N	\N	Nombre Ejecutor	nombre-ejecutor-uncd	\N	\N	\N	\N	\N	str
2700	2024-07-01 04:39:06.985+00	2024-07-01 04:39:06.985+00	f	\N	\N	Tasa de Interés - %	tasa-de-interes-6vv8	\N	\N	\N	\N	\N	str
2701	2024-07-01 04:39:06.991+00	2024-07-01 04:39:06.991+00	f	\N	\N	Plazo	plazo-6o39	\N	\N	\N	\N	\N	str
2702	2024-07-01 04:39:06.997+00	2024-07-01 04:39:06.997+00	f	\N	\N	Fondos con los que se cancelará la obligación crediticia	fondos-con-los-que-se-cancelara-la-obligacion-crediticia-k0tb	\N	\N	\N	\N	\N	str
2703	2024-07-01 04:39:07.005+00	2024-07-01 04:39:07.005+00	f	\N	\N	Enlace para descargar el contrato de crédito externo o interno	enlace-para-descargar-el-contrato-de-credito-externo-o-interno-dj9z	\N	\N	\N	\N	\N	str
2704	2024-07-01 04:39:07.012+00	2024-07-01 04:39:07.012+00	f	\N	\N	Monto del préstamo o contrato	monto-del-prestamo-o-contrato-hvwr	\N	\N	\N	\N	\N	str
2705	2024-07-01 04:39:07.019+00	2024-07-01 04:39:07.019+00	f	\N	\N	Desembolsos efectuados	desembolsos-efectuados-8xty	\N	\N	\N	\N	\N	str
2706	2024-07-01 04:39:07.025+00	2024-07-01 04:39:07.025+00	f	\N	\N	Desembolsos por efectuar	desembolsos-por-efectuar-e2xj	\N	\N	\N	\N	\N	str
2707	2024-07-01 04:39:07.036+00	2024-07-01 04:39:07.036+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN	fecha-actualizacion-de-la-informacion-8god	\N	\N	\N	\N	\N	str
2708	2024-07-01 04:39:07.044+00	2024-07-01 04:39:07.044+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN	periodicidad-de-actualizacion-de-la-informacion-xqix	\N	\N	\N	\N	\N	str
2709	2024-07-01 04:39:07.051+00	2024-07-01 04:39:07.051+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN	unidad-poseedora-de-la-informacion-6p8m	\N	\N	\N	\N	\N	str
2710	2024-07-01 04:39:07.058+00	2024-07-01 04:39:07.058+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	persona-responsable-de-la-unidad-poseedora-de-la-informacion-p2zc	\N	\N	\N	\N	\N	str
2711	2024-07-01 04:39:07.063+00	2024-07-01 04:39:07.063+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-bsfd	\N	\N	\N	\N	\N	str
2712	2024-07-01 04:39:07.07+00	2024-07-01 04:39:07.07+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-4t85	\N	\N	\N	\N	\N	str
2713	2024-07-01 04:39:07.077+00	2024-07-01 04:39:07.077+00	f	\N	\N	LICENCIA	licencia-2tvf	\N	\N	\N	\N	\N	str
2714	2024-07-01 04:39:07.087+00	2024-07-01 04:39:07.087+00	f	\N	\N	Institución	institucion-4byo	\N	\N	\N	\N	\N	str
2715	2024-07-01 04:39:07.092+00	2024-07-01 04:39:07.092+00	f	\N	\N	Descripción	descripcion-yu3v	\N	\N	\N	\N	\N	str
2716	2024-07-01 04:39:07.097+00	2024-07-01 04:39:07.097+00	f	\N	\N	Nombre del campo	nombre-del-campo-dqfy	\N	\N	\N	\N	\N	str
2717	2024-07-01 04:39:07.104+00	2024-07-01 04:39:07.104+00	f	\N	\N	Tipo de Contrato	tipo-de-contrato-0orh	\N	\N	\N	\N	\N	str
2718	2024-07-01 04:39:07.111+00	2024-07-01 04:39:07.111+00	f	\N	\N	Objeto 	objeto-6lbo	\N	\N	\N	\N	\N	str
2719	2024-07-01 04:39:07.119+00	2024-07-01 04:39:07.119+00	f	\N	\N	Fecha de suscripción o renovación	fecha-de-suscripcion-o-renovacion-0u9q	\N	\N	\N	\N	\N	str
2720	2024-07-01 04:39:07.125+00	2024-07-01 04:39:07.125+00	f	\N	\N	Nombre del deudor	nombre-del-deudor-3g87	\N	\N	\N	\N	\N	str
2721	2024-07-01 04:39:07.131+00	2024-07-01 04:39:07.131+00	f	\N	\N	Nombre del acreedor	nombre-del-acreedor-gxni	\N	\N	\N	\N	\N	str
2722	2024-07-01 04:39:07.14+00	2024-07-01 04:39:07.14+00	f	\N	\N	Nombre del ejecutor	nombre-del-ejecutor-u26w	\N	\N	\N	\N	\N	str
2723	2024-07-01 04:39:07.148+00	2024-07-01 04:39:07.148+00	f	\N	\N	Tasa de Interés - %	tasa-de-interes-ti73	\N	\N	\N	\N	\N	str
2724	2024-07-01 04:39:07.155+00	2024-07-01 04:39:07.155+00	f	\N	\N	Plazo	plazo-ey3t	\N	\N	\N	\N	\N	str
2725	2024-07-01 04:39:07.162+00	2024-07-01 04:39:07.162+00	f	\N	\N	Fondos con los que se cancelará la obligación crediticia	fondos-con-los-que-se-cancelara-la-obligacion-crediticia-hdu4	\N	\N	\N	\N	\N	str
2726	2024-07-01 04:39:07.17+00	2024-07-01 04:39:07.17+00	f	\N	\N	Enlace para descargar el contrato de crédito externo o interno	enlace-para-descargar-el-contrato-de-credito-externo-o-interno-3rid	\N	\N	\N	\N	\N	str
2727	2024-07-01 04:39:07.178+00	2024-07-01 04:39:07.178+00	f	\N	\N	Monto del préstamo o contrato	monto-del-prestamo-o-contrato-fwzl	\N	\N	\N	\N	\N	str
2728	2024-07-01 04:39:07.185+00	2024-07-01 04:39:07.185+00	f	\N	\N	Desembolsos efectuados	desembolsos-efectuados-w3ye	\N	\N	\N	\N	\N	str
2729	2024-07-01 04:39:07.193+00	2024-07-01 04:39:07.193+00	f	\N	\N	Desembolsos por efectuar	desembolsos-por-efectuar-80dk	\N	\N	\N	\N	\N	str
2730	2024-07-01 04:39:07.206+00	2024-07-01 04:39:07.206+00	f	\N	\N	FECHA DE PUBLICACIÓN	fecha-de-publicacion-1nb5	\N	\N	\N	\N	\N	str
2731	2024-07-01 04:39:07.212+00	2024-07-01 04:39:07.212+00	f	\N	\N	CÓDIGO DEL PROCESO	codigo-del-proceso-mv3u	\N	\N	\N	\N	\N	str
2732	2024-07-01 04:39:07.218+00	2024-07-01 04:39:07.218+00	f	\N	\N	TIPO DE PROCESO	tipo-de-proceso-tjr3	\N	\N	\N	\N	\N	str
2733	2024-07-01 04:39:07.225+00	2024-07-01 04:39:07.225+00	f	\N	\N	OBJETO DEL PROCESO	objeto-del-proceso-az3c	\N	\N	\N	\N	\N	str
2734	2024-07-01 04:39:07.23+00	2024-07-01 04:39:07.23+00	f	\N	\N	PRESUPUESTO REFERENCIAL - USD	presupuesto-referencial-usd-ymb1	\N	\N	\N	\N	\N	str
2735	2024-07-01 04:39:07.239+00	2024-07-01 04:39:07.239+00	f	\N	\N	PARTIDA PRESUPUESTARIA	partida-presupuestaria-mm43	\N	\N	\N	\N	\N	str
2736	2024-07-01 04:39:07.246+00	2024-07-01 04:39:07.246+00	f	\N	\N	MONTO DE LA ADJUDICACIÓN - USD	monto-de-la-adjudicacion-usd-cdhj	\N	\N	\N	\N	\N	str
2737	2024-07-01 04:39:07.253+00	2024-07-01 04:39:07.253+00	f	\N	\N	ETAPA DE LA CONTRATACIÓN	etapa-de-la-contratacion-z5hu	\N	\N	\N	\N	\N	str
2738	2024-07-01 04:39:07.26+00	2024-07-01 04:39:07.26+00	f	\N	\N	IDENTIFICACIÓN DEL CONTRATISTA	identificacion-del-contratista-59m7	\N	\N	\N	\N	\N	str
2739	2024-07-01 04:39:07.268+00	2024-07-01 04:39:07.268+00	f	\N	\N	LINK PARA DESCARGAR EL PROCESO DE CONTRATACIÓN DESDE EL PORTAL DE COMPRAS PÚBLICAS	link-para-descargar-el-proceso-de-contratacion-desde-el-portal-de-compras-publicas-qjhm	\N	\N	\N	\N	\N	str
2740	2024-07-01 04:39:07.282+00	2024-07-01 04:39:07.282+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-m6n6	\N	\N	\N	\N	\N	str
2741	2024-07-01 04:39:07.289+00	2024-07-01 04:39:07.289+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-htpa	\N	\N	\N	\N	\N	str
2742	2024-07-01 04:39:07.297+00	2024-07-01 04:39:07.297+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-zu3z	\N	\N	\N	\N	\N	str
2743	2024-07-01 04:39:07.305+00	2024-07-01 04:39:07.305+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-8o10	\N	\N	\N	\N	\N	str
2744	2024-07-01 04:39:07.312+00	2024-07-01 04:39:07.312+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-gxyd	\N	\N	\N	\N	\N	str
2745	2024-07-01 04:39:07.319+00	2024-07-01 04:39:07.319+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-yv0n	\N	\N	\N	\N	\N	str
2746	2024-07-01 04:39:07.327+00	2024-07-01 04:39:07.327+00	f	\N	\N	Enlace para la búsqueda de procesos de contratación desde el Sistema Oficial de Contratación Pública	enlace-para-la-busqueda-de-procesos-de-contratacion-desde-el-sistema-oficial-de-contratacion-publica-qzcn	\N	\N	\N	\N	\N	str
2747	2024-07-01 04:39:07.336+00	2024-07-01 04:39:07.336+00	f	\N	\N	LICENCIA 	licencia-c0tz	\N	\N	\N	\N	\N	str
2748	2024-07-01 04:39:07.349+00	2024-07-01 04:39:07.35+00	f	\N	\N	Institución	institucion-j6r9	\N	\N	\N	\N	\N	str
2749	2024-07-01 04:39:07.357+00	2024-07-01 04:39:07.357+00	f	\N	\N	Descripción	descripcion-u1ih	\N	\N	\N	\N	\N	str
2750	2024-07-01 04:39:07.363+00	2024-07-01 04:39:07.363+00	f	\N	\N	Nombre del campo	nombre-del-campo-ygnr	\N	\N	\N	\N	\N	str
2751	2024-07-01 04:39:07.371+00	2024-07-01 04:39:07.371+00	f	\N	\N	Fecha de publicación	fecha-de-publicacion-rggi	\N	\N	\N	\N	\N	str
2752	2024-07-01 04:39:07.378+00	2024-07-01 04:39:07.378+00	f	\N	\N	Código del proceso	codigo-del-proceso-vn6s	\N	\N	\N	\N	\N	str
2753	2024-07-01 04:39:07.385+00	2024-07-01 04:39:07.385+00	f	\N	\N	Tipo de proceso	tipo-de-proceso-i9yq	\N	\N	\N	\N	\N	str
2754	2024-07-01 04:39:07.391+00	2024-07-01 04:39:07.391+00	f	\N	\N	Objeto del proceso	objeto-del-proceso-l82r	\N	\N	\N	\N	\N	str
2755	2024-07-01 04:39:07.397+00	2024-07-01 04:39:07.397+00	f	\N	\N	Presupuesto referencial - USD	presupuesto-referencial-usd-x5x9	\N	\N	\N	\N	\N	str
2756	2024-07-01 04:39:07.405+00	2024-07-01 04:39:07.405+00	f	\N	\N	Partida presupuestaria	partida-presupuestaria-91cx	\N	\N	\N	\N	\N	str
2757	2024-07-01 04:39:07.412+00	2024-07-01 04:39:07.412+00	f	\N	\N	Monto de la adjudicación - USD	monto-de-la-adjudicacion-usd-3d6y	\N	\N	\N	\N	\N	str
2758	2024-07-01 04:39:07.419+00	2024-07-01 04:39:07.419+00	f	\N	\N	Etapa de la contratación	etapa-de-la-contratacion-oav6	\N	\N	\N	\N	\N	str
2759	2024-07-01 04:39:07.426+00	2024-07-01 04:39:07.426+00	f	\N	\N	Identificación del contratista	identificacion-del-contratista-j3uf	\N	\N	\N	\N	\N	str
2760	2024-07-01 04:39:07.431+00	2024-07-01 04:39:07.431+00	f	\N	\N	Link para descargar el proceso de contratación desde el portal de comprass públicas	link-para-descargar-el-proceso-de-contratacion-desde-el-portal-de-comprass-publicas-p23n	\N	\N	\N	\N	\N	str
2761	2024-07-01 04:39:07.445+00	2024-07-01 04:39:07.445+00	f	\N	\N	Grupo específico	grupo-especifico-uhab	\N	\N	\N	\N	\N	str
2762	2024-07-01 04:39:07.452+00	2024-07-01 04:39:07.452+00	f	\N	\N	Nombre de política pública	nombre-de-politica-publica-43pl	\N	\N	\N	\N	\N	str
2763	2024-07-01 04:39:07.458+00	2024-07-01 04:39:07.458+00	f	\N	\N	Fase	fase-hnox	\N	\N	\N	\N	\N	str
2764	2024-07-01 04:39:07.463+00	2024-07-01 04:39:07.463+00	f	\N	\N	Fecha	fecha-x5s3	\N	\N	\N	\N	\N	str
2765	2024-07-01 04:39:07.472+00	2024-07-01 04:39:07.472+00	f	\N	\N	Enlace a informe	enlace-a-informe-p4mo	\N	\N	\N	\N	\N	str
2766	2024-07-01 04:39:07.485+00	2024-07-01 04:39:07.485+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN	fecha-actualizacion-de-la-informacion-0395	\N	\N	\N	\N	\N	str
2767	2024-07-01 04:39:07.492+00	2024-07-01 04:39:07.492+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN	periodicidad-de-actualizacion-de-la-informacion-q4ka	\N	\N	\N	\N	\N	str
2768	2024-07-01 04:39:07.5+00	2024-07-01 04:39:07.5+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN	unidad-poseedora-de-la-informacion-6r9q	\N	\N	\N	\N	\N	str
2769	2024-07-01 04:39:07.509+00	2024-07-01 04:39:07.509+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	persona-responsable-de-la-unidad-poseedora-de-la-informacion-n7j5	\N	\N	\N	\N	\N	str
2770	2024-07-01 04:39:07.517+00	2024-07-01 04:39:07.517+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-7ams	\N	\N	\N	\N	\N	str
2771	2024-07-01 04:39:07.525+00	2024-07-01 04:39:07.525+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-elu8	\N	\N	\N	\N	\N	str
2772	2024-07-01 04:39:07.531+00	2024-07-01 04:39:07.531+00	f	\N	\N	LICENCIA	licencia-ntew	\N	\N	\N	\N	\N	str
2773	2024-07-01 04:39:07.541+00	2024-07-01 04:39:07.541+00	f	\N	\N	ENLACE PARA DESCARGAR LAS ACCCIONES Y BUENAS PRÁCTICAS DE ACTORES SOCIALES E INTERINSTITUCIONALES QUE VIGILAN EL CUMPLIMIENTO DE LA POLÍTICA PÚBLICA	enlace-para-descargar-las-accciones-y-buenas-practicas-de-actores-sociales-e-interinstitucionales-que-vigilan-el-cumplimiento-de-la-politica-publica-hfpy	\N	\N	\N	\N	\N	str
2774	2024-07-01 04:39:07.552+00	2024-07-01 04:39:07.552+00	f	\N	\N	Institución	institucion-lo0l	\N	\N	\N	\N	\N	str
2775	2024-07-01 04:39:07.559+00	2024-07-01 04:39:07.559+00	f	\N	\N	Descripción	descripcion-4njv	\N	\N	\N	\N	\N	str
2776	2024-07-01 04:39:07.565+00	2024-07-01 04:39:07.565+00	f	\N	\N	Nombre del campo	nombre-del-campo-twvo	\N	\N	\N	\N	\N	str
2777	2024-07-01 04:39:07.574+00	2024-07-01 04:39:07.574+00	f	\N	\N	Grupo específico	grupo-especifico-fu93	\N	\N	\N	\N	\N	str
2778	2024-07-01 04:39:07.581+00	2024-07-01 04:39:07.581+00	f	\N	\N	Nombre de política pública	nombre-de-politica-publica-jdag	\N	\N	\N	\N	\N	str
2779	2024-07-01 04:39:07.588+00	2024-07-01 04:39:07.588+00	f	\N	\N	Fase	fase-dtdv	\N	\N	\N	\N	\N	str
2780	2024-07-01 04:39:07.594+00	2024-07-01 04:39:07.594+00	f	\N	\N	Fecha	fecha-zrnd	\N	\N	\N	\N	\N	str
2781	2024-07-01 04:39:07.6+00	2024-07-01 04:39:07.601+00	f	\N	\N	Enlace a informe	enlace-a-informe-1n7l	\N	\N	\N	\N	\N	str
2782	2024-07-01 04:39:07.615+00	2024-07-01 04:39:07.615+00	f	\N	\N	Unidad	unidad-8qor	\N	\N	\N	\N	\N	str
2783	2024-07-01 04:39:07.623+00	2024-07-01 04:39:07.623+00	f	\N	\N	Objetivo	objetivo-v8o4	\N	\N	\N	\N	\N	str
2784	2024-07-01 04:39:07.629+00	2024-07-01 04:39:07.629+00	f	\N	\N	Indicador	indicador-a1cg	\N	\N	\N	\N	\N	str
2785	2024-07-01 04:39:07.638+00	2024-07-01 04:39:07.638+00	f	\N	\N	Meta cuantificable	meta-cuantificable-0zxi	\N	\N	\N	\N	\N	str
2786	2024-07-01 04:39:07.644+00	2024-07-01 04:39:07.644+00	f	\N	\N	Enlace al sistema de gestión de planificación para verificación de los indicadores y metas cuantificables 	enlace-al-sistema-de-gestion-de-planificacion-para-verificacion-de-los-indicadores-y-metas-cuantificables	\N	\N	\N	\N	\N	str
2787	2024-07-01 04:39:07.657+00	2024-07-01 04:39:07.657+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-hwtd	\N	\N	\N	\N	\N	str
2788	2024-07-01 04:39:07.664+00	2024-07-01 04:39:07.664+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-2imu	\N	\N	\N	\N	\N	str
2789	2024-07-01 04:39:07.674+00	2024-07-01 04:39:07.674+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-s0uw	\N	\N	\N	\N	\N	str
2790	2024-07-01 04:39:07.682+00	2024-07-01 04:39:07.682+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-q3x7	\N	\N	\N	\N	\N	str
2791	2024-07-01 04:39:07.689+00	2024-07-01 04:39:07.689+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-9f2g	\N	\N	\N	\N	\N	str
2792	2024-07-01 04:39:07.697+00	2024-07-01 04:39:07.697+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-jaui	\N	\N	\N	\N	\N	str
2793	2024-07-01 04:39:07.706+00	2024-07-01 04:39:07.706+00	f	\N	\N	LICENCIA	licencia-yeif	\N	\N	\N	\N	\N	str
2794	2024-07-01 04:39:07.719+00	2024-07-01 04:39:07.719+00	f	\N	\N	Institución	institucion-mp6b	\N	\N	\N	\N	\N	str
2795	2024-07-01 04:39:07.726+00	2024-07-01 04:39:07.726+00	f	\N	\N	Descripción	descripcion-mr73	\N	\N	\N	\N	\N	str
2796	2024-07-01 04:39:07.734+00	2024-07-01 04:39:07.734+00	f	\N	\N	Nombre del campo	nombre-del-campo-fhux	\N	\N	\N	\N	\N	str
2797	2024-07-01 04:39:07.744+00	2024-07-01 04:39:07.744+00	f	\N	\N	Unidad	unidad-gpi4	\N	\N	\N	\N	\N	str
2798	2024-07-01 04:39:07.752+00	2024-07-01 04:39:07.752+00	f	\N	\N	Objetivo	objetivo-8yih	\N	\N	\N	\N	\N	str
2799	2024-07-01 04:39:07.759+00	2024-07-01 04:39:07.759+00	f	\N	\N	Indicador	indicador-yj3o	\N	\N	\N	\N	\N	str
2800	2024-07-01 04:39:07.768+00	2024-07-01 04:39:07.768+00	f	\N	\N	Meta cuantificable	meta-cuantificable-ez4o	\N	\N	\N	\N	\N	str
2801	2024-07-01 04:39:07.779+00	2024-07-01 04:39:07.78+00	f	\N	\N	Enlace al sistema de gestión de planificación para verificación de los indicadores y metas cuantificables 	enlace-al-sistema-de-gestion-de-planificacion-para-verificacion-de-los-indicadores-y-metas-cuantificables-wofm	\N	\N	\N	\N	\N	str
2802	2024-07-01 04:39:07.796+00	2024-07-01 04:39:07.796+00	f	\N	\N	Nombre del Plan o Programa	nombre-del-plan-o-programa-hpby	\N	\N	\N	\N	\N	str
2803	2024-07-01 04:39:07.805+00	2024-07-01 04:39:07.805+00	f	\N	\N	Período	periodo-vf1x	\N	\N	\N	\N	\N	str
2804	2024-07-01 04:39:07.817+00	2024-07-01 04:39:07.817+00	f	\N	\N	Monto	monto-5wfb	\N	\N	\N	\N	\N	str
2805	2024-07-01 04:39:07.827+00	2024-07-01 04:39:07.827+00	f	\N	\N	Enlace al Plan o Programa	enlace-al-plan-o-programa-jhgv	\N	\N	\N	\N	\N	str
2806	2024-07-01 04:39:07.835+00	2024-07-01 04:39:07.835+00	f	\N	\N	Enlace al estado 	enlace-al-estado-wb5a	\N	\N	\N	\N	\N	str
2807	2024-07-01 04:39:07.849+00	2024-07-01 04:39:07.849+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN	fecha-actualizacion-de-la-informacion-ac8e	\N	\N	\N	\N	\N	str
2808	2024-07-01 04:39:07.859+00	2024-07-01 04:39:07.859+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN	periodicidad-de-actualizacion-de-la-informacion-fmh3	\N	\N	\N	\N	\N	str
2809	2024-07-01 04:39:07.867+00	2024-07-01 04:39:07.867+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN	unidad-poseedora-de-la-informacion-slyx	\N	\N	\N	\N	\N	str
2810	2024-07-01 04:39:07.877+00	2024-07-01 04:39:07.877+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	persona-responsable-de-la-unidad-poseedora-de-la-informacion-fqq2	\N	\N	\N	\N	\N	str
2811	2024-07-01 04:39:07.885+00	2024-07-01 04:39:07.885+00	f	\N	\N	CORREO ELECTRÓNICO DEL O LA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	correo-electronico-del-o-la-responsable-de-la-unidad-poseedora-de-la-informacion-p6zq	\N	\N	\N	\N	\N	str
2812	2024-07-01 04:39:07.892+00	2024-07-01 04:39:07.892+00	f	\N	\N	NÚMERO TELEFÓNICO DEL O LA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	numero-telefonico-del-o-la-responsable-de-la-unidad-poseedora-de-la-informacion-kizr	\N	\N	\N	\N	\N	str
2813	2024-07-01 04:39:07.898+00	2024-07-01 04:39:07.898+00	f	\N	\N	LICENCIA	licencia-9550	\N	\N	\N	\N	\N	str
2814	2024-07-01 04:39:07.913+00	2024-07-01 04:39:07.913+00	f	\N	\N	Institución	institucion-ldsb	\N	\N	\N	\N	\N	str
2815	2024-07-01 04:39:07.921+00	2024-07-01 04:39:07.921+00	f	\N	\N	Descripción	descripcion-0y32	\N	\N	\N	\N	\N	str
2816	2024-07-01 04:39:07.927+00	2024-07-01 04:39:07.927+00	f	\N	\N	Nombre del campo	nombre-del-campo-3f8y	\N	\N	\N	\N	\N	str
2817	2024-07-01 04:39:07.935+00	2024-07-01 04:39:07.935+00	f	\N	\N	Nombre del Plan o Programa	nombre-del-plan-o-programa-6zha	\N	\N	\N	\N	\N	str
2818	2024-07-01 04:39:07.944+00	2024-07-01 04:39:07.944+00	f	\N	\N	Período	periodo-kycz	\N	\N	\N	\N	\N	str
2819	2024-07-01 04:39:07.952+00	2024-07-01 04:39:07.952+00	f	\N	\N	Monto	monto-iv09	\N	\N	\N	\N	\N	str
2820	2024-07-01 04:39:07.958+00	2024-07-01 04:39:07.958+00	f	\N	\N	Enlace al Plan o Programa	enlace-al-plan-o-programa-r7qk	\N	\N	\N	\N	\N	str
2821	2024-07-01 04:39:07.964+00	2024-07-01 04:39:07.964+00	f	\N	\N	Enlace al estado 	enlace-al-estado-9di0	\N	\N	\N	\N	\N	str
2822	2024-07-01 04:39:07.98+00	2024-07-01 04:39:07.98+00	f	\N	\N	Información relevante	informacion-relevante-5sno	\N	\N	\N	\N	\N	str
2823	2024-07-01 04:39:07.987+00	2024-07-01 04:39:07.987+00	f	\N	\N	Enlace para descargar	enlace-para-descargar-n2tb	\N	\N	\N	\N	\N	str
2824	2024-07-01 04:39:07.997+00	2024-07-01 04:39:07.997+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-pxk8	\N	\N	\N	\N	\N	str
2825	2024-07-01 04:39:08.006+00	2024-07-01 04:39:08.006+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-2zmt	\N	\N	\N	\N	\N	str
2826	2024-07-01 04:39:08.013+00	2024-07-01 04:39:08.013+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-81en	\N	\N	\N	\N	\N	str
2827	2024-07-01 04:39:08.02+00	2024-07-01 04:39:08.02+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-nvh3	\N	\N	\N	\N	\N	str
2828	2024-07-01 04:39:08.028+00	2024-07-01 04:39:08.028+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-ptwn	\N	\N	\N	\N	\N	str
2829	2024-07-01 04:39:08.036+00	2024-07-01 04:39:08.036+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-dkya	\N	\N	\N	\N	\N	str
2830	2024-07-01 04:39:08.045+00	2024-07-01 04:39:08.045+00	f	\N	\N	LICENCIA	licencia-9xum	\N	\N	\N	\N	\N	str
2831	2024-07-01 04:39:08.057+00	2024-07-01 04:39:08.057+00	f	\N	\N	Institución	institucion-f2f1	\N	\N	\N	\N	\N	str
2832	2024-07-01 04:39:08.064+00	2024-07-01 04:39:08.064+00	f	\N	\N	Descripción	descripcion-k527	\N	\N	\N	\N	\N	str
2833	2024-07-01 04:39:08.074+00	2024-07-01 04:39:08.074+00	f	\N	\N	Nombre del campo	nombre-del-campo-aglq	\N	\N	\N	\N	\N	str
2834	2024-07-01 04:39:08.082+00	2024-07-01 04:39:08.083+00	f	\N	\N	Información relevante	informacion-relevante-2lao	\N	\N	\N	\N	\N	str
2835	2024-07-01 04:39:08.091+00	2024-07-01 04:39:08.091+00	f	\N	\N	Enlace para descargar	enlace-para-descargar-oq13	\N	\N	\N	\N	\N	str
2836	2024-07-01 04:39:08.106+00	2024-07-01 04:39:08.106+00	f	\N	\N	TIPO	tipo-cygt	\N	\N	\N	\N	\N	str
2837	2024-07-01 04:39:08.114+00	2024-07-01 04:39:08.114+00	f	\N	\N	DESCRIPCIÓN	descripcion-yvoz	\N	\N	\N	\N	\N	str
2838	2024-07-01 04:39:08.124+00	2024-07-01 04:39:08.124+00	f	\N	\N	ENLACE 	enlace-zwxn	\N	\N	\N	\N	\N	str
2839	2024-07-01 04:39:08.137+00	2024-07-01 04:39:08.137+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-63wp	\N	\N	\N	\N	\N	str
2840	2024-07-01 04:39:08.147+00	2024-07-01 04:39:08.147+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-e2rc	\N	\N	\N	\N	\N	str
2841	2024-07-01 04:39:08.156+00	2024-07-01 04:39:08.156+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-dcq7	\N	\N	\N	\N	\N	str
2842	2024-07-01 04:39:08.164+00	2024-07-01 04:39:08.164+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-b683	\N	\N	\N	\N	\N	str
2843	2024-07-01 04:39:08.175+00	2024-07-01 04:39:08.175+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-cc2z	\N	\N	\N	\N	\N	str
2844	2024-07-01 04:39:08.183+00	2024-07-01 04:39:08.183+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-1n7d	\N	\N	\N	\N	\N	str
2845	2024-07-01 04:39:08.193+00	2024-07-01 04:39:08.193+00	f	\N	\N	LICENCIA	licencia-dv2s	\N	\N	\N	\N	\N	str
2846	2024-07-01 04:39:08.209+00	2024-07-01 04:39:08.209+00	f	\N	\N	Institución	institucion-0kos	\N	\N	\N	\N	\N	str
2847	2024-07-01 04:39:08.219+00	2024-07-01 04:39:08.219+00	f	\N	\N	Descripción	descripcion-5jr4	\N	\N	\N	\N	\N	str
2848	2024-07-01 04:39:08.227+00	2024-07-01 04:39:08.227+00	f	\N	\N	Nombre del campo	nombre-del-campo-iiih	\N	\N	\N	\N	\N	str
2849	2024-07-01 04:39:08.236+00	2024-07-01 04:39:08.236+00	f	\N	\N	Tipo	tipo-zt91	\N	\N	\N	\N	\N	str
2850	2024-07-01 04:39:08.245+00	2024-07-01 04:39:08.246+00	f	\N	\N	Descripcion	descripcion-cxoy	\N	\N	\N	\N	\N	str
2851	2024-07-01 04:39:08.255+00	2024-07-01 04:39:08.255+00	f	\N	\N	Enlace	enlace-7e74	\N	\N	\N	\N	\N	str
2852	2024-07-01 04:39:08.271+00	2024-07-01 04:39:08.271+00	f	\N	\N	Apellidos y Nombres	apellidos-y-nombres	\N	\N	\N	\N	\N	str
2853	2024-07-01 04:39:08.28+00	2024-07-01 04:39:08.28+00	f	\N	\N	Puesto institucional	puesto-institucional-brna	\N	\N	\N	\N	\N	str
2854	2024-07-01 04:39:08.288+00	2024-07-01 04:39:08.288+00	f	\N	\N	Asunto	asunto-cudc	\N	\N	\N	\N	\N	str
2855	2024-07-01 04:39:08.294+00	2024-07-01 04:39:08.294+00	f	\N	\N	Fecha de la audiencia o reunión	fecha-de-la-audiencia-o-reunion	\N	\N	\N	\N	\N	str
2856	2024-07-01 04:39:08.304+00	2024-07-01 04:39:08.304+00	f	\N	\N	Modalidad	modalidad-inwx	\N	\N	\N	\N	\N	str
2857	2024-07-01 04:39:08.314+00	2024-07-01 04:39:08.314+00	f	\N	\N	Lugar	lugar-refm	\N	\N	\N	\N	\N	str
2858	2024-07-01 04:39:08.321+00	2024-07-01 04:39:08.321+00	f	\N	\N	Descripción de la audiencia o reunión	descripcion-de-la-audiencia-o-reunion	\N	\N	\N	\N	\N	str
2859	2024-07-01 04:39:08.328+00	2024-07-01 04:39:08.328+00	f	\N	\N	Duración	duracion-dnjb	\N	\N	\N	\N	\N	str
2860	2024-07-01 04:39:08.339+00	2024-07-01 04:39:08.339+00	f	\N	\N	Nombre de personas externas	nombre-de-personas-externas	\N	\N	\N	\N	\N	str
2861	2024-07-01 04:39:08.35+00	2024-07-01 04:39:08.35+00	f	\N	\N	Institución externa	institucion-externa-qj79	\N	\N	\N	\N	\N	str
2862	2024-07-01 04:39:08.362+00	2024-07-01 04:39:08.362+00	f	\N	\N	Enlace para descargar el registro de asistencia de las personas que participaron en la reunión o audiencia	enlace-para-descargar-el-registro-de-asistencia-de-las-personas-que-participaron-en-la-reunion-o-audiencia-pdj8	\N	\N	\N	\N	\N	str
2863	2024-07-01 04:39:08.382+00	2024-07-01 04:39:08.382+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-q7wv	\N	\N	\N	\N	\N	str
2864	2024-07-01 04:39:08.394+00	2024-07-01 04:39:08.394+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-xj6m	\N	\N	\N	\N	\N	str
2865	2024-07-01 04:39:08.404+00	2024-07-01 04:39:08.404+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-o1p5	\N	\N	\N	\N	\N	str
2866	2024-07-01 04:39:08.415+00	2024-07-01 04:39:08.415+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-9pap	\N	\N	\N	\N	\N	str
2867	2024-07-01 04:39:08.424+00	2024-07-01 04:39:08.424+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-v5v7	\N	\N	\N	\N	\N	str
2868	2024-07-01 04:39:08.433+00	2024-07-01 04:39:08.433+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-5q4b	\N	\N	\N	\N	\N	str
2869	2024-07-01 04:39:08.442+00	2024-07-01 04:39:08.442+00	f	\N	\N	LICENCIA	licencia-9wkt	\N	\N	\N	\N	\N	str
2870	2024-07-01 04:39:08.456+00	2024-07-01 04:39:08.456+00	f	\N	\N	Institución	institucion-fhph	\N	\N	\N	\N	\N	str
2871	2024-07-01 04:39:08.463+00	2024-07-01 04:39:08.463+00	f	\N	\N	Descripción	descripcion-78pg	\N	\N	\N	\N	\N	str
2872	2024-07-01 04:39:08.472+00	2024-07-01 04:39:08.472+00	f	\N	\N	Nombre del campo	nombre-del-campo-tf0s	\N	\N	\N	\N	\N	str
2873	2024-07-01 04:39:08.481+00	2024-07-01 04:39:08.481+00	f	\N	\N	Apellidos y Nombres	apellidos-y-nombres-eu8l	\N	\N	\N	\N	\N	str
2874	2024-07-01 04:39:08.489+00	2024-07-01 04:39:08.489+00	f	\N	\N	Puesto institucional	puesto-institucional-aeua	\N	\N	\N	\N	\N	str
2875	2024-07-01 04:39:08.496+00	2024-07-01 04:39:08.497+00	f	\N	\N	Asunto	asunto-hey5	\N	\N	\N	\N	\N	str
2876	2024-07-01 04:39:08.506+00	2024-07-01 04:39:08.506+00	f	\N	\N	Fecha de la audiencia o reunión	fecha-de-la-audiencia-o-reunion-yim5	\N	\N	\N	\N	\N	str
2877	2024-07-01 04:39:08.514+00	2024-07-01 04:39:08.514+00	f	\N	\N	Modalidad	modalidad-har0	\N	\N	\N	\N	\N	str
2878	2024-07-01 04:39:08.522+00	2024-07-01 04:39:08.522+00	f	\N	\N	Lugar	lugar-hk47	\N	\N	\N	\N	\N	str
2879	2024-07-01 04:39:08.528+00	2024-07-01 04:39:08.528+00	f	\N	\N	Descripción de la audiencia o reunión	descripcion-de-la-audiencia-o-reunion-br2c	\N	\N	\N	\N	\N	str
2880	2024-07-01 04:39:08.535+00	2024-07-01 04:39:08.535+00	f	\N	\N	Duración de la reunión	duracion-de-la-reunion-wgf2	\N	\N	\N	\N	\N	str
2881	2024-07-01 04:39:08.544+00	2024-07-01 04:39:08.544+00	f	\N	\N	Nombre de personas externas	nombre-de-personas-externas-cjdc	\N	\N	\N	\N	\N	str
2882	2024-07-01 04:39:08.551+00	2024-07-01 04:39:08.551+00	f	\N	\N	Institución externa	institucion-externa-jffn	\N	\N	\N	\N	\N	str
2883	2024-07-01 04:39:08.558+00	2024-07-01 04:39:08.558+00	f	\N	\N	Enlace para descargar el registro de asistencia de las personas que participaron en las reuniones o audiencias	enlace-para-descargar-el-registro-de-asistencia-de-las-personas-que-participaron-en-las-reuniones-o-audiencias-sl2a	\N	\N	\N	\N	\N	str
2884	2024-07-01 04:39:08.574+00	2024-07-01 04:39:08.574+00	f	\N	\N	Nombre del mecanismo 	nombre-del-mecanismo-6nhb	\N	\N	\N	\N	\N	str
2885	2024-07-01 04:39:08.582+00	2024-07-01 04:39:08.582+00	f	\N	\N	Número de certificado	numero-de-certificado-6jrq	\N	\N	\N	\N	\N	str
2886	2024-07-01 04:39:08.59+00	2024-07-01 04:39:08.59+00	f	\N	\N	Período	periodo-4ftg	\N	\N	\N	\N	\N	str
2887	2024-07-01 04:39:08.596+00	2024-07-01 04:39:08.596+00	f	\N	\N	Enlace	enlace-2tiu	\N	\N	\N	\N	\N	str
2888	2024-07-01 04:39:08.613+00	2024-07-01 04:39:08.613+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN	fecha-actualizacion-de-la-informacion-hcyy	\N	\N	\N	\N	\N	str
2889	2024-07-01 04:39:08.623+00	2024-07-01 04:39:08.623+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN	periodicidad-de-actualizacion-de-la-informacion-ka89	\N	\N	\N	\N	\N	str
2890	2024-07-01 04:39:08.63+00	2024-07-01 04:39:08.63+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN	unidad-poseedora-de-la-informacion-ojf4	\N	\N	\N	\N	\N	str
2891	2024-07-01 04:39:08.64+00	2024-07-01 04:39:08.64+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	persona-responsable-de-la-unidad-poseedora-de-la-informacion-azmj	\N	\N	\N	\N	\N	str
2892	2024-07-01 04:39:08.65+00	2024-07-01 04:39:08.65+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-aobb	\N	\N	\N	\N	\N	str
2893	2024-07-01 04:39:08.659+00	2024-07-01 04:39:08.659+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-ed6c	\N	\N	\N	\N	\N	str
2894	2024-07-01 04:39:08.666+00	2024-07-01 04:39:08.666+00	f	\N	\N	LICENCIA	licencia-ggfx	\N	\N	\N	\N	\N	str
2895	2024-07-01 04:39:08.676+00	2024-07-01 04:39:08.676+00	f	\N	\N	ENLACE PARA LA DESCARGA DE OTROS MECANISMOS DE RENDICIÓN DE CUENTAS	enlace-para-la-descarga-de-otros-mecanismos-de-rendicion-de-cuentas-wm50	\N	\N	\N	\N	\N	str
2896	2024-07-01 04:39:08.689+00	2024-07-01 04:39:08.689+00	f	\N	\N	Institución	institucion-d78z	\N	\N	\N	\N	\N	str
2897	2024-07-01 04:39:08.696+00	2024-07-01 04:39:08.696+00	f	\N	\N	Descripción	descripcion-42ze	\N	\N	\N	\N	\N	str
2898	2024-07-01 04:39:08.704+00	2024-07-01 04:39:08.704+00	f	\N	\N	Nombre del campo	nombre-del-campo-p7ks	\N	\N	\N	\N	\N	str
2899	2024-07-01 04:39:08.717+00	2024-07-01 04:39:08.717+00	f	\N	\N	Nombre del mecanismo	nombre-del-mecanismo-5v3t	\N	\N	\N	\N	\N	str
2900	2024-07-01 04:39:08.729+00	2024-07-01 04:39:08.729+00	f	\N	\N	Número de certificado	numero-de-certificado-hpuy	\N	\N	\N	\N	\N	str
2901	2024-07-01 04:39:08.74+00	2024-07-01 04:39:08.74+00	f	\N	\N	Período	periodo-2g28	\N	\N	\N	\N	\N	str
2902	2024-07-01 04:39:08.751+00	2024-07-01 04:39:08.751+00	f	\N	\N	Enlace	enlace-5p9z	\N	\N	\N	\N	\N	str
2903	2024-07-01 04:39:08.77+00	2024-07-01 04:39:08.77+00	f	\N	\N	Cuenta	cuenta-9zh1	\N	\N	\N	\N	\N	str
2904	2024-07-01 04:39:08.781+00	2024-07-01 04:39:08.781+00	f	\N	\N	Categoría	categoria-e11t	\N	\N	\N	\N	\N	str
2905	2024-07-01 04:39:08.792+00	2024-07-01 04:39:08.792+00	f	\N	\N	Descripción	descripcion-moef	\N	\N	\N	\N	\N	str
2906	2024-07-01 04:39:08.8+00	2024-07-01 04:39:08.8+00	f	\N	\N	Asignado	asignado-wucn	\N	\N	\N	\N	\N	str
2907	2024-07-01 04:39:08.812+00	2024-07-01 04:39:08.812+00	f	\N	\N	Modificado	modificado-durk	\N	\N	\N	\N	\N	str
2908	2024-07-01 04:39:08.821+00	2024-07-01 04:39:08.821+00	f	\N	\N	Codificado	codificado-us2x	\N	\N	\N	\N	\N	str
2909	2024-07-01 04:39:08.83+00	2024-07-01 04:39:08.83+00	f	\N	\N	Monto certificado	monto-certificado-jr9y	\N	\N	\N	\N	\N	str
2910	2024-07-01 04:39:08.841+00	2024-07-01 04:39:08.841+00	f	\N	\N	Comprometido	comprometido-s5q5	\N	\N	\N	\N	\N	str
2911	2024-07-01 04:39:08.853+00	2024-07-01 04:39:08.853+00	f	\N	\N	Devengado	devengado-aovt	\N	\N	\N	\N	\N	str
2912	2024-07-01 04:39:08.863+00	2024-07-01 04:39:08.863+00	f	\N	\N	Pagado	pagado-iu0s	\N	\N	\N	\N	\N	str
2913	2024-07-01 04:39:08.875+00	2024-07-01 04:39:08.875+00	f	\N	\N	Saldo por comprometer	saldo-por-comprometer-7274	\N	\N	\N	\N	\N	str
2914	2024-07-01 04:39:08.887+00	2024-07-01 04:39:08.887+00	f	\N	\N	Saldo por devengar	saldo-por-devengar-mrh8	\N	\N	\N	\N	\N	str
2915	2024-07-01 04:39:08.896+00	2024-07-01 04:39:08.896+00	f	\N	\N	Saldo por pagar	saldo-por-pagar-qoa4	\N	\N	\N	\N	\N	str
2916	2024-07-01 04:39:08.907+00	2024-07-01 04:39:08.907+00	f	\N	\N	Porcentaje de ejecución	porcentaje-de-ejecucion-lq48	\N	\N	\N	\N	\N	str
2917	2024-07-01 04:39:08.926+00	2024-07-01 04:39:08.926+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN	fecha-actualizacion-de-la-informacion-4bbf	\N	\N	\N	\N	\N	str
2918	2024-07-01 04:39:08.939+00	2024-07-01 04:39:08.939+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN	periodicidad-de-actualizacion-de-la-informacion-i673	\N	\N	\N	\N	\N	str
2919	2024-07-01 04:39:08.951+00	2024-07-01 04:39:08.951+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN	unidad-poseedora-de-la-informacion-0deu	\N	\N	\N	\N	\N	str
2920	2024-07-01 04:39:08.961+00	2024-07-01 04:39:08.961+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	persona-responsable-de-la-unidad-poseedora-de-la-informacion-9cvg	\N	\N	\N	\N	\N	str
2921	2024-07-01 04:39:08.973+00	2024-07-01 04:39:08.973+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-xn6y	\N	\N	\N	\N	\N	str
2922	2024-07-01 04:39:08.985+00	2024-07-01 04:39:08.985+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-x8si	\N	\N	\N	\N	\N	str
2923	2024-07-01 04:39:08.994+00	2024-07-01 04:39:08.995+00	f	\N	\N	LICENCIA	licencia-kaxd	\N	\N	\N	\N	\N	str
2924	2024-07-01 04:39:09.014+00	2024-07-01 04:39:09.014+00	f	\N	\N	Institución	institucion-wcmb	\N	\N	\N	\N	\N	str
2925	2024-07-01 04:39:09.026+00	2024-07-01 04:39:09.026+00	f	\N	\N	Descripción	descripcion-cg92	\N	\N	\N	\N	\N	str
2926	2024-07-01 04:39:09.038+00	2024-07-01 04:39:09.038+00	f	\N	\N	Nombre del campo	nombre-del-campo-qrsw	\N	\N	\N	\N	\N	str
2927	2024-07-01 04:39:09.048+00	2024-07-01 04:39:09.048+00	f	\N	\N	Cuenta	cuenta-0waz	\N	\N	\N	\N	\N	str
2928	2024-07-01 04:39:09.058+00	2024-07-01 04:39:09.058+00	f	\N	\N	Categoría	categoria-qn7o	\N	\N	\N	\N	\N	str
2929	2024-07-01 04:39:09.066+00	2024-07-01 04:39:09.066+00	f	\N	\N	Descripción	descripcion-fdeg	\N	\N	\N	\N	\N	str
2930	2024-07-01 04:39:09.077+00	2024-07-01 04:39:09.077+00	f	\N	\N	Asignado	asignado-j0dz	\N	\N	\N	\N	\N	str
2931	2024-07-01 04:39:09.088+00	2024-07-01 04:39:09.088+00	f	\N	\N	Modificado	modificado-7m8f	\N	\N	\N	\N	\N	str
2932	2024-07-01 04:39:09.097+00	2024-07-01 04:39:09.097+00	f	\N	\N	Codificado	codificado-war2	\N	\N	\N	\N	\N	str
2933	2024-07-01 04:39:09.107+00	2024-07-01 04:39:09.107+00	f	\N	\N	Monto certificado	monto-certificado-tvi0	\N	\N	\N	\N	\N	str
2934	2024-07-01 04:39:09.118+00	2024-07-01 04:39:09.118+00	f	\N	\N	Comprometido	comprometido-20o5	\N	\N	\N	\N	\N	str
2935	2024-07-01 04:39:09.127+00	2024-07-01 04:39:09.127+00	f	\N	\N	Devengado	devengado-a0s2	\N	\N	\N	\N	\N	str
2936	2024-07-01 04:39:09.137+00	2024-07-01 04:39:09.137+00	f	\N	\N	Pagado	pagado-wr3n	\N	\N	\N	\N	\N	str
2937	2024-07-01 04:39:09.15+00	2024-07-01 04:39:09.15+00	f	\N	\N	Saldo por comprometer	saldo-por-comprometer-azec	\N	\N	\N	\N	\N	str
2938	2024-07-01 04:39:09.16+00	2024-07-01 04:39:09.16+00	f	\N	\N	Saldo por devengar	saldo-por-devengar-7v9a	\N	\N	\N	\N	\N	str
2939	2024-07-01 04:39:09.171+00	2024-07-01 04:39:09.171+00	f	\N	\N	Saldo por pagar	saldo-por-pagar-tht8	\N	\N	\N	\N	\N	str
2940	2024-07-01 04:39:09.183+00	2024-07-01 04:39:09.183+00	f	\N	\N	Porcentaje de ejecución	porcentaje-de-ejecucion-2grj	\N	\N	\N	\N	\N	str
2941	2024-07-01 04:39:09.201+00	2024-07-01 04:39:09.201+00	f	\N	\N	No.	no-xtvc	\N	\N	\N	\N	\N	str
2942	2024-07-01 04:39:09.213+00	2024-07-01 04:39:09.213+00	f	\N	\N	Número del informe 	numero-del-informe-mp9g	\N	\N	\N	\N	\N	str
2943	2024-07-01 04:39:09.223+00	2024-07-01 04:39:09.223+00	f	\N	\N	Tipo de examen	tipo-de-examen-83b8	\N	\N	\N	\N	\N	str
2944	2024-07-01 04:39:09.234+00	2024-07-01 04:39:09.234+00	f	\N	\N	Nombre del examen	nombre-del-examen-uviz	\N	\N	\N	\N	\N	str
2945	2024-07-01 04:39:09.245+00	2024-07-01 04:39:09.245+00	f	\N	\N	Período analizado	periodo-analizado-6luw	\N	\N	\N	\N	\N	str
2946	2024-07-01 04:39:09.256+00	2024-07-01 04:39:09.256+00	f	\N	\N	Área o proceso auditado	area-o-proceso-auditado-5ups	\N	\N	\N	\N	\N	str
2947	2024-07-01 04:39:09.265+00	2024-07-01 04:39:09.265+00	f	\N	\N	Enlace para descargar el informe específico	enlace-para-descargar-el-informe-especifico-x3kg	\N	\N	\N	\N	\N	str
2948	2024-07-01 04:39:09.277+00	2024-07-01 04:39:09.277+00	f	\N	\N	Enlace para descargar el reporte de seguimiento al cumplimiento de recomendaciones del informe de auditoría	enlace-para-descargar-el-reporte-de-seguimiento-al-cumplimiento-de-recomendaciones-del-informe-de-auditoria-72pu	\N	\N	\N	\N	\N	str
2949	2024-07-01 04:39:09.293+00	2024-07-01 04:39:09.293+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-8w0e	\N	\N	\N	\N	\N	str
2950	2024-07-01 04:39:09.301+00	2024-07-01 04:39:09.301+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-kwbx	\N	\N	\N	\N	\N	str
2951	2024-07-01 04:39:09.313+00	2024-07-01 04:39:09.313+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-4mo1	\N	\N	\N	\N	\N	str
2952	2024-07-01 04:39:09.324+00	2024-07-01 04:39:09.324+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-zahr	\N	\N	\N	\N	\N	str
2953	2024-07-01 04:39:09.334+00	2024-07-01 04:39:09.334+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-zphy	\N	\N	\N	\N	\N	str
2954	2024-07-01 04:39:09.346+00	2024-07-01 04:39:09.346+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-7sai	\N	\N	\N	\N	\N	str
2955	2024-07-01 04:39:09.357+00	2024-07-01 04:39:09.357+00	f	\N	\N	Enlace al sitio web de la Contraloría General del Estado para consulta de informes aprobados	enlace-al-sitio-web-de-la-contraloria-general-del-estado-para-consulta-de-informes-aprobados-w7tb	\N	\N	\N	\N	\N	str
2956	2024-07-01 04:39:09.366+00	2024-07-01 04:39:09.366+00	f	\N	\N	LICENCIA	licencia-g3yw	\N	\N	\N	\N	\N	str
2957	2024-07-01 04:39:09.384+00	2024-07-01 04:39:09.384+00	f	\N	\N	Institución	institucion-k9vl	\N	\N	\N	\N	\N	str
2958	2024-07-01 04:39:09.392+00	2024-07-01 04:39:09.392+00	f	\N	\N	Descripción	descripcion-xixy	\N	\N	\N	\N	\N	str
2959	2024-07-01 04:39:09.4+00	2024-07-01 04:39:09.4+00	f	\N	\N	Nombre del campo	nombre-del-campo-mdfe	\N	\N	\N	\N	\N	str
2960	2024-07-01 04:39:09.41+00	2024-07-01 04:39:09.41+00	f	\N	\N	No	no-92gh	\N	\N	\N	\N	\N	str
2961	2024-07-01 04:39:09.419+00	2024-07-01 04:39:09.419+00	f	\N	\N	Número del informe	numero-del-informe-8jwr	\N	\N	\N	\N	\N	str
2962	2024-07-01 04:39:09.427+00	2024-07-01 04:39:09.427+00	f	\N	\N	Tipo de examen	tipo-de-examen-qxki	\N	\N	\N	\N	\N	str
2963	2024-07-01 04:39:09.435+00	2024-07-01 04:39:09.435+00	f	\N	\N	Nombre del examen	nombre-del-examen-jlwy	\N	\N	\N	\N	\N	str
2964	2024-07-01 04:39:09.445+00	2024-07-01 04:39:09.445+00	f	\N	\N	Período analizado	periodo-analizado-liuk	\N	\N	\N	\N	\N	str
2965	2024-07-01 04:39:09.454+00	2024-07-01 04:39:09.454+00	f	\N	\N	Área o proceso auditado	area-o-proceso-auditado-3bwg	\N	\N	\N	\N	\N	str
2966	2024-07-01 04:39:09.461+00	2024-07-01 04:39:09.461+00	f	\N	\N	Enlace para descargar el informe específico	enlace-para-descargar-el-informe-especifico-ko9a	\N	\N	\N	\N	\N	str
2967	2024-07-01 04:39:09.469+00	2024-07-01 04:39:09.469+00	f	\N	\N	Enlace para descargar el reporte de seguimiento al cumplimiento de recomendaciones del informe de auditoría	enlace-para-descargar-el-reporte-de-seguimiento-al-cumplimiento-de-recomendaciones-del-informe-de-auditoria-y8kj	\N	\N	\N	\N	\N	str
2968	2024-07-01 04:39:09.486+00	2024-07-01 04:39:09.486+00	f	\N	\N	No.	no-qfum	\N	\N	\N	\N	\N	str
2969	2024-07-01 04:39:09.494+00	2024-07-01 04:39:09.494+00	f	\N	\N	Apellidos y Nombres	apellidos-y-nombres-gj8a	\N	\N	\N	\N	\N	str
2970	2024-07-01 04:39:09.501+00	2024-07-01 04:39:09.501+00	f	\N	\N	Puesto Institucional	puesto-institucional-tpgb	\N	\N	\N	\N	\N	str
2971	2024-07-01 04:39:09.512+00	2024-07-01 04:39:09.512+00	f	\N	\N	Unidad a la que pertenece	unidad-a-la-que-pertenece-z012	\N	\N	\N	\N	\N	str
2972	2024-07-01 04:39:09.522+00	2024-07-01 04:39:09.522+00	f	\N	\N	Dirección institucional	direccion-institucional-tuvl	\N	\N	\N	\N	\N	str
2973	2024-07-01 04:39:09.53+00	2024-07-01 04:39:09.53+00	f	\N	\N	Ciudad en la que labora	ciudad-en-la-que-labora-fjmo	\N	\N	\N	\N	\N	str
2974	2024-07-01 04:39:09.539+00	2024-07-01 04:39:09.539+00	f	\N	\N	Teléfono institucional	telefono-institucional-95gp	\N	\N	\N	\N	\N	str
2975	2024-07-01 04:39:09.547+00	2024-07-01 04:39:09.547+00	f	\N	\N	Extensión telefónica	extension-telefonica-9pe3	\N	\N	\N	\N	\N	str
2976	2024-07-01 04:39:09.558+00	2024-07-01 04:39:09.558+00	f	\N	\N	Correo Electrónico institucional	correo-electronico-institucional-t0o9	\N	\N	\N	\N	\N	str
2977	2024-07-01 04:39:09.572+00	2024-07-01 04:39:09.572+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN	fecha-actualizacion-de-la-informacion-v4b6	\N	\N	\N	\N	\N	str
2978	2024-07-01 04:39:09.582+00	2024-07-01 04:39:09.582+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN	periodicidad-de-actualizacion-de-la-informacion-7ep5	\N	\N	\N	\N	\N	str
2979	2024-07-01 04:39:09.59+00	2024-07-01 04:39:09.59+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACION	unidad-poseedora-de-la-informacion-dk87	\N	\N	\N	\N	\N	str
2980	2024-07-01 04:39:09.597+00	2024-07-01 04:39:09.597+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	persona-responsable-de-la-unidad-poseedora-de-la-informacion-13qj	\N	\N	\N	\N	\N	str
2981	2024-07-01 04:39:09.608+00	2024-07-01 04:39:09.608+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-c1ri	\N	\N	\N	\N	\N	str
2982	2024-07-01 04:39:09.618+00	2024-07-01 04:39:09.618+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-d7hc	\N	\N	\N	\N	\N	str
2983	2024-07-01 04:39:09.626+00	2024-07-01 04:39:09.626+00	f	\N	\N	LICENCIA	licencia-mpat	\N	\N	\N	\N	\N	str
2984	2024-07-01 04:39:09.642+00	2024-07-01 04:39:09.642+00	f	\N	\N	Institución	institucion-ugzy	\N	\N	\N	\N	\N	str
2985	2024-07-01 04:39:09.651+00	2024-07-01 04:39:09.651+00	f	\N	\N	Descripción	descripcion-plfc	\N	\N	\N	\N	\N	str
2986	2024-07-01 04:39:09.659+00	2024-07-01 04:39:09.659+00	f	\N	\N	Nombre del campo	nombre-del-campo-qclq	\N	\N	\N	\N	\N	str
2987	2024-07-01 04:39:09.667+00	2024-07-01 04:39:09.667+00	f	\N	\N	No.	no-54a9	\N	\N	\N	\N	\N	str
2988	2024-07-01 04:39:09.678+00	2024-07-01 04:39:09.678+00	f	\N	\N	Apellidos y Nombres 	apellidos-y-nombres-ggko	\N	\N	\N	\N	\N	str
2989	2024-07-01 04:39:09.688+00	2024-07-01 04:39:09.688+00	f	\N	\N	Puesto Institucional	puesto-institucional-2u7q	\N	\N	\N	\N	\N	str
2990	2024-07-01 04:39:09.697+00	2024-07-01 04:39:09.697+00	f	\N	\N	Unidad a la que pertenece	unidad-a-la-que-pertenece-t48w	\N	\N	\N	\N	\N	str
2991	2024-07-01 04:39:09.707+00	2024-07-01 04:39:09.707+00	f	\N	\N	Dirección institucional	direccion-institucional-z3eq	\N	\N	\N	\N	\N	str
2992	2024-07-01 04:39:09.717+00	2024-07-01 04:39:09.717+00	f	\N	\N	Ciudad en la que labora	ciudad-en-la-que-labora-665g	\N	\N	\N	\N	\N	str
2993	2024-07-01 04:39:09.727+00	2024-07-01 04:39:09.727+00	f	\N	\N	Teléfono institucional	telefono-institucional-m2kw	\N	\N	\N	\N	\N	str
2994	2024-07-01 04:39:09.737+00	2024-07-01 04:39:09.737+00	f	\N	\N	Extensión telefónica	extension-telefonica-ygvk	\N	\N	\N	\N	\N	str
2995	2024-07-01 04:39:09.747+00	2024-07-01 04:39:09.747+00	f	\N	\N	Correo Electrónico institucional	correo-electronico-institucional-htyh	\N	\N	\N	\N	\N	str
2996	2024-07-01 04:39:09.765+00	2024-07-01 04:39:09.765+00	f	\N	\N	Denominación del servicio público que se brinda	denominacion-del-servicio-publico-que-se-brinda-jzwz	\N	\N	\N	\N	\N	str
2997	2024-07-01 04:39:09.775+00	2024-07-01 04:39:09.775+00	f	\N	\N	Enlace para acceder al reporte del servicio	enlace-para-acceder-al-reporte-del-servicio-xiln	\N	\N	\N	\N	\N	str
2998	2024-07-01 04:39:09.784+00	2024-07-01 04:39:09.784+00	f	\N	\N	Número de personas que acceden mensualmente al servicio institucional	numero-de-personas-que-acceden-mensualmente-al-servicio-institucional-ukgj	\N	\N	\N	\N	\N	str
2999	2024-07-01 04:39:09.792+00	2024-07-01 04:39:09.792+00	f	\N	\N	Enlace para descargar el formulario o formato del servicio - Correo electronico para solicitar el servicio	enlace-para-descargar-el-formulario-o-formato-del-servicio-correo-electronico-para-solicitar-el-servicio	\N	\N	\N	\N	\N	str
3000	2024-07-01 04:39:09.8+00	2024-07-01 04:39:09.8+00	f	\N	\N	Enlace para el servicio por internet en línea	enlace-para-el-servicio-por-internet-en-linea-jewe	\N	\N	\N	\N	\N	str
3001	2024-07-01 04:39:09.811+00	2024-07-01 04:39:09.811+00	f	\N	\N	Porcentaje de satisfacción sobre el uso del servicio	porcentaje-de-satisfaccion-sobre-el-uso-del-servicio-soyv	\N	\N	\N	\N	\N	str
3002	2024-07-01 04:39:09.826+00	2024-07-01 04:39:09.826+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN	fecha-actualizacion-de-la-informacion-6p1l	\N	\N	\N	\N	\N	str
3003	2024-07-01 04:39:09.833+00	2024-07-01 04:39:09.833+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN	periodicidad-de-actualizacion-de-la-informacion-xwnb	\N	\N	\N	\N	\N	str
3004	2024-07-01 04:39:09.844+00	2024-07-01 04:39:09.844+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACION	unidad-poseedora-de-la-informacion-gsn6	\N	\N	\N	\N	\N	str
3005	2024-07-01 04:39:09.853+00	2024-07-01 04:39:09.853+00	f	\N	\N	PERSONAL RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	personal-responsable-de-la-unidad-poseedora-de-la-informacion-a1zk	\N	\N	\N	\N	\N	str
3006	2024-07-01 04:39:09.861+00	2024-07-01 04:39:09.861+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-81bu	\N	\N	\N	\N	\N	str
3007	2024-07-01 04:39:09.869+00	2024-07-01 04:39:09.869+00	f	\N	\N	NÚMERO TELEFÓNICO DEL O LA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	numero-telefonico-del-o-la-responsable-de-la-unidad-poseedora-de-la-informacion-h8v9	\N	\N	\N	\N	\N	str
3008	2024-07-01 04:39:09.88+00	2024-07-01 04:39:09.88+00	f	\N	\N	ENLACE A PORTAL ÚNICO DE TRÁMITES CIUDADANOS	enlace-a-portal-unico-de-tramites-ciudadanos-c45c	\N	\N	\N	\N	\N	str
3009	2024-07-01 04:39:09.889+00	2024-07-01 04:39:09.889+00	f	\N	\N	LICENCIA	licencia-pd0p	\N	\N	\N	\N	\N	str
3010	2024-07-01 04:39:09.902+00	2024-07-01 04:39:09.902+00	f	\N	\N	Institución	institucion-d0qe	\N	\N	\N	\N	\N	str
3011	2024-07-01 04:39:09.912+00	2024-07-01 04:39:09.912+00	f	\N	\N	Descripción 	descripcion-rb3h	\N	\N	\N	\N	\N	str
3012	2024-07-01 04:39:09.921+00	2024-07-01 04:39:09.921+00	f	\N	\N	Nombre del Campo	nombre-del-campo-5rf3	\N	\N	\N	\N	\N	str
3013	2024-07-01 04:39:09.931+00	2024-07-01 04:39:09.931+00	f	\N	\N	Denominación del servicio público que se brinda	denominacion-del-servicio-publico-que-se-brinda-ozgu	\N	\N	\N	\N	\N	str
3014	2024-07-01 04:39:09.943+00	2024-07-01 04:39:09.943+00	f	\N	\N	Enlace para acceder al reporte del servicio	enlace-para-acceder-al-reporte-del-servicio-prda	\N	\N	\N	\N	\N	str
3015	2024-07-01 04:39:09.954+00	2024-07-01 04:39:09.954+00	f	\N	\N	Número de personas que acceden mensualmente al servicio institucional	numero-de-personas-que-acceden-mensualmente-al-servicio-institucional-lk5d	\N	\N	\N	\N	\N	str
3016	2024-07-01 04:39:09.966+00	2024-07-01 04:39:09.966+00	f	\N	\N	Enlace para descargar el formulario o formato del servicio - Correo electronico para solicitar el servicio	enlace-para-descargar-el-formulario-o-formato-del-servicio-correo-electronico-para-solicitar-el-servicio-pce9	\N	\N	\N	\N	\N	str
3017	2024-07-01 04:39:09.978+00	2024-07-01 04:39:09.978+00	f	\N	\N	Enlace para el servicio por internet (en línea)	enlace-para-el-servicio-por-internet-en-linea-rmvn	\N	\N	\N	\N	\N	str
3018	2024-07-01 04:39:09.988+00	2024-07-01 04:39:09.988+00	f	\N	\N	Porcentaje de satisfacción sobre el uso del servicio	porcentaje-de-satisfaccion-sobre-el-uso-del-servicio-wp7u	\N	\N	\N	\N	\N	str
3019	2024-07-01 04:39:10.005+00	2024-07-01 04:39:10.005+00	f	\N	\N	Apellidos y Nombres	apellidos-y-nombres-wgxx	\N	\N	\N	\N	\N	str
3020	2024-07-01 04:39:10.016+00	2024-07-01 04:39:10.016+00	f	\N	\N	Puesto Institucional 	puesto-institucional-klqe	\N	\N	\N	\N	\N	str
3021	2024-07-01 04:39:10.026+00	2024-07-01 04:39:10.026+00	f	\N	\N	Fecha de inicio	fecha-de-inicio-10sf	\N	\N	\N	\N	\N	str
3022	2024-07-01 04:39:10.034+00	2024-07-01 04:39:10.034+00	f	\N	\N	Fecha de fin	fecha-de-fin-h0jx	\N	\N	\N	\N	\N	str
3023	2024-07-01 04:39:10.046+00	2024-07-01 04:39:10.046+00	f	\N	\N	Lugar	lugar-xa5r	\N	\N	\N	\N	\N	str
3024	2024-07-01 04:39:10.057+00	2024-07-01 04:39:10.057+00	f	\N	\N	Tipo	tipo-5k4m	\N	\N	\N	\N	\N	str
3025	2024-07-01 04:39:10.075+00	2024-07-01 04:39:10.075+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN	fecha-actualizacion-de-la-informacion-5gjm	\N	\N	\N	\N	\N	str
3026	2024-07-01 04:39:10.086+00	2024-07-01 04:39:10.086+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN	periodicidad-de-actualizacion-de-la-informacion-pp7j	\N	\N	\N	\N	\N	str
3027	2024-07-01 04:39:10.095+00	2024-07-01 04:39:10.095+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACION	unidad-poseedora-de-la-informacion-nz9o	\N	\N	\N	\N	\N	str
3028	2024-07-01 04:39:10.104+00	2024-07-01 04:39:10.104+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	persona-responsable-de-la-unidad-poseedora-de-la-informacion-93sn	\N	\N	\N	\N	\N	str
3029	2024-07-01 04:39:10.114+00	2024-07-01 04:39:10.114+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-yc76	\N	\N	\N	\N	\N	str
3030	2024-07-01 04:39:10.123+00	2024-07-01 04:39:10.123+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-5mzk	\N	\N	\N	\N	\N	str
3031	2024-07-01 04:39:10.13+00	2024-07-01 04:39:10.13+00	f	\N	\N	LICENCIA	licencia-vwam	\N	\N	\N	\N	\N	str
3032	2024-07-01 04:39:10.145+00	2024-07-01 04:39:10.145+00	f	\N	\N	Institución	institucion-60po	\N	\N	\N	\N	\N	str
3033	2024-07-01 04:39:10.154+00	2024-07-01 04:39:10.154+00	f	\N	\N	Descripción	descripcion-nh0a	\N	\N	\N	\N	\N	str
3034	2024-07-01 04:39:10.161+00	2024-07-01 04:39:10.161+00	f	\N	\N	Nombre del Campo	nombre-del-campo-p3sg	\N	\N	\N	\N	\N	str
3035	2024-07-01 04:39:10.169+00	2024-07-01 04:39:10.169+00	f	\N	\N	Apellidos y Nombres	apellidos-y-nombres-yvyx	\N	\N	\N	\N	\N	str
3036	2024-07-01 04:39:10.18+00	2024-07-01 04:39:10.18+00	f	\N	\N	Puesto Institucional	puesto-institucional-c4b3	\N	\N	\N	\N	\N	str
3037	2024-07-01 04:39:10.187+00	2024-07-01 04:39:10.187+00	f	\N	\N	Fecha de inicio	fecha-de-inicio-az1x	\N	\N	\N	\N	\N	str
3038	2024-07-01 04:39:10.195+00	2024-07-01 04:39:10.195+00	f	\N	\N	Fecha de fin	fecha-de-fin-m5rm	\N	\N	\N	\N	\N	str
3039	2024-07-01 04:39:10.203+00	2024-07-01 04:39:10.203+00	f	\N	\N	Lugar	lugar-gqqs	\N	\N	\N	\N	\N	str
3040	2024-07-01 04:39:10.214+00	2024-07-01 04:39:10.214+00	f	\N	\N	Tipo	tipo-s59j	\N	\N	\N	\N	\N	str
3041	2024-07-01 04:39:10.229+00	2024-07-01 04:39:10.229+00	f	\N	\N	Tipo	tipo-nmua	\N	\N	\N	\N	\N	str
3042	2024-07-01 04:39:10.237+00	2024-07-01 04:39:10.237+00	f	\N	\N	Fecha de suscripción	fecha-de-suscripcion-vyjx	\N	\N	\N	\N	\N	str
3043	2024-07-01 04:39:10.249+00	2024-07-01 04:39:10.249+00	f	\N	\N	Objeto	objeto-vlvw	\N	\N	\N	\N	\N	str
3044	2024-07-01 04:39:10.256+00	2024-07-01 04:39:10.256+00	f	\N	\N	Nombre de la organización - persona natural o persona jurídica	nombre-de-la-organizacion-persona-natural-o-persona-juridica	\N	\N	\N	\N	\N	str
3045	2024-07-01 04:39:10.266+00	2024-07-01 04:39:10.266+00	f	\N	\N	Plazo de duración	plazo-de-duracion-rizl	\N	\N	\N	\N	\N	str
3046	2024-07-01 04:39:10.278+00	2024-07-01 04:39:10.278+00	f	\N	\N	Enlace para descargar el convenio	enlace-para-descargar-el-convenio-657b	\N	\N	\N	\N	\N	str
3047	2024-07-01 04:39:10.293+00	2024-07-01 04:39:10.293+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN	fecha-actualizacion-de-la-informacion-optz	\N	\N	\N	\N	\N	str
3048	2024-07-01 04:39:10.301+00	2024-07-01 04:39:10.301+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN	periodicidad-de-actualizacion-de-la-informacion-ysk3	\N	\N	\N	\N	\N	str
3049	2024-07-01 04:39:10.312+00	2024-07-01 04:39:10.312+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN	unidad-poseedora-de-la-informacion-ao00	\N	\N	\N	\N	\N	str
3050	2024-07-01 04:39:10.321+00	2024-07-01 04:39:10.321+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	persona-responsable-de-la-unidad-poseedora-de-la-informacion-59m5	\N	\N	\N	\N	\N	str
3051	2024-07-01 04:39:10.328+00	2024-07-01 04:39:10.328+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-gob1	\N	\N	\N	\N	\N	str
3052	2024-07-01 04:39:10.337+00	2024-07-01 04:39:10.337+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-00dc	\N	\N	\N	\N	\N	str
3053	2024-07-01 04:39:10.346+00	2024-07-01 04:39:10.346+00	f	\N	\N	LICENCIA	licencia-jsk7	\N	\N	\N	\N	\N	str
3054	2024-07-01 04:39:10.361+00	2024-07-01 04:39:10.361+00	f	\N	\N	Institución	institucion-1fgb	\N	\N	\N	\N	\N	str
3055	2024-07-01 04:39:10.37+00	2024-07-01 04:39:10.37+00	f	\N	\N	Descripción	descripcion-8l3c	\N	\N	\N	\N	\N	str
3056	2024-07-01 04:39:10.381+00	2024-07-01 04:39:10.381+00	f	\N	\N	Nombre del campo	nombre-del-campo-0m05	\N	\N	\N	\N	\N	str
3057	2024-07-01 04:39:10.389+00	2024-07-01 04:39:10.389+00	f	\N	\N	Tipo	tipo-hfu4	\N	\N	\N	\N	\N	str
3058	2024-07-01 04:39:10.396+00	2024-07-01 04:39:10.396+00	f	\N	\N	Fecha de suscripción	fecha-de-suscripcion-f0fx	\N	\N	\N	\N	\N	str
3059	2024-07-01 04:39:10.405+00	2024-07-01 04:39:10.405+00	f	\N	\N	Objeto del convenio	objeto-del-convenio-lwkp	\N	\N	\N	\N	\N	str
3060	2024-07-01 04:39:10.415+00	2024-07-01 04:39:10.415+00	f	\N	\N	Nombre de la organización - persona natural o persona jurídica	nombre-de-la-organizacion-persona-natural-o-persona-juridica-vabs	\N	\N	\N	\N	\N	str
3061	2024-07-01 04:39:10.425+00	2024-07-01 04:39:10.425+00	f	\N	\N	Plazo de duración	plazo-de-duracion-cu45	\N	\N	\N	\N	\N	str
3062	2024-07-01 04:39:10.433+00	2024-07-01 04:39:10.433+00	f	\N	\N	Enlace para descargar el convenio	enlace-para-descargar-el-convenio-pj4s	\N	\N	\N	\N	\N	str
3063	2024-07-01 04:39:10.454+00	2024-07-01 04:39:10.454+00	f	\N	\N	Nivel superior	nivel-superior-le70	\N	\N	\N	\N	\N	str
3064	2024-07-01 04:39:10.464+00	2024-07-01 04:39:10.464+00	f	\N	\N	Unidad	unidad-jof4	\N	\N	\N	\N	\N	str
3065	2024-07-01 04:39:10.473+00	2024-07-01 04:39:10.473+00	f	\N	\N	Nivel de los Procesos de la Estructura Orgánica Funcional	nivel-de-los-procesos-de-la-estructura-organica-funcional	\N	\N	\N	\N	\N	str
3066	2024-07-01 04:39:10.497+00	2024-07-01 04:39:10.497+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-w3p9	\N	\N	\N	\N	\N	str
3067	2024-07-01 04:39:10.512+00	2024-07-01 04:39:10.512+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-enjj	\N	\N	\N	\N	\N	str
3068	2024-07-01 04:39:10.524+00	2024-07-01 04:39:10.524+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-y4pz	\N	\N	\N	\N	\N	str
3069	2024-07-01 04:39:10.533+00	2024-07-01 04:39:10.533+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-04vr	\N	\N	\N	\N	\N	str
3070	2024-07-01 04:39:10.544+00	2024-07-01 04:39:10.544+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-lzth	\N	\N	\N	\N	\N	str
3071	2024-07-01 04:39:10.554+00	2024-07-01 04:39:10.554+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-pjls	\N	\N	\N	\N	\N	str
3072	2024-07-01 04:39:10.564+00	2024-07-01 04:39:10.564+00	f	\N	\N	LICENCIA	licencia-ml14	\N	\N	\N	\N	\N	str
3073	2024-07-01 04:39:10.574+00	2024-07-01 04:39:10.574+00	f	\N	\N	ENLACE PARA CONSULTAR EL ORGANIGRAMA ESTRUCTURAL	enlace-para-consultar-el-organigrama-estructural-d8ou	\N	\N	\N	\N	\N	str
3074	2024-07-01 04:39:10.592+00	2024-07-01 04:39:10.592+00	f	\N	\N	Institución	institucion-ceds	\N	\N	\N	\N	\N	str
3075	2024-07-01 04:39:10.6+00	2024-07-01 04:39:10.6+00	f	\N	\N	Descripción	descripcion-cwan	\N	\N	\N	\N	\N	str
3076	2024-07-01 04:39:10.614+00	2024-07-01 04:39:10.614+00	f	\N	\N	Nombre del campo	nombre-del-campo-hy4w	\N	\N	\N	\N	\N	str
3077	2024-07-01 04:39:10.624+00	2024-07-01 04:39:10.624+00	f	\N	\N	Nivel superior	nivel-superior-6mkm	\N	\N	\N	\N	\N	str
3078	2024-07-01 04:39:10.633+00	2024-07-01 04:39:10.633+00	f	\N	\N	Unidad	unidad-ozkm	\N	\N	\N	\N	\N	str
3079	2024-07-01 04:39:10.645+00	2024-07-01 04:39:10.645+00	f	\N	\N	Nivel de los Procesos de la Estructura Organica Funcional	nivel-de-los-procesos-de-la-estructura-organica-funcional-0siy	\N	\N	\N	\N	\N	str
3080	2024-07-01 04:39:10.664+00	2024-07-01 04:39:10.664+00	f	\N	\N	Tema 	tema-rqy3	\N	\N	\N	\N	\N	str
3081	2024-07-01 04:39:10.68+00	2024-07-01 04:39:10.68+00	f	\N	\N	Número de requerimientos	numero-de-requerimientos-u4gl	\N	\N	\N	\N	\N	str
3082	2024-07-01 04:39:10.692+00	2024-07-01 04:39:10.692+00	f	\N	\N	Enlace para descargar el detalle de la información solicitada frecuentemente	enlace-para-descargar-el-detalle-de-la-informacion-solicitada-frecuentemente-x26q	\N	\N	\N	\N	\N	str
3083	2024-07-01 04:39:10.705+00	2024-07-01 04:39:10.705+00	f	\N	\N	Enlace para descargar la solicitud de información complementaria que haya sido solicitada recurrentemente	enlace-para-descargar-la-solicitud-de-informacion-complementaria-que-haya-sido-solicitada-recurrentemente-oqam	\N	\N	\N	\N	\N	str
3084	2024-07-01 04:39:10.737+00	2024-07-01 04:39:10.737+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN	fecha-actualizacion-de-la-informacion-y7dg	\N	\N	\N	\N	\N	str
3085	2024-07-01 04:39:10.759+00	2024-07-01 04:39:10.759+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN	periodicidad-de-actualizacion-de-la-informacion-vozi	\N	\N	\N	\N	\N	str
3086	2024-07-01 04:39:10.77+00	2024-07-01 04:39:10.77+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN	unidad-poseedora-de-la-informacion-prry	\N	\N	\N	\N	\N	str
3087	2024-07-01 04:39:10.787+00	2024-07-01 04:39:10.787+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	persona-responsable-de-la-unidad-poseedora-de-la-informacion-xa6q	\N	\N	\N	\N	\N	str
3088	2024-07-01 04:39:10.798+00	2024-07-01 04:39:10.798+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-bgtu	\N	\N	\N	\N	\N	str
3089	2024-07-01 04:39:10.813+00	2024-07-01 04:39:10.813+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-psh8	\N	\N	\N	\N	\N	str
3090	2024-07-01 04:39:10.825+00	2024-07-01 04:39:10.825+00	f	\N	\N	LICENCIA	licencia-t5d0	\N	\N	\N	\N	\N	str
3091	2024-07-01 04:39:10.841+00	2024-07-01 04:39:10.841+00	f	\N	\N	Institución	institucion-bdr4	\N	\N	\N	\N	\N	str
3092	2024-07-01 04:39:10.853+00	2024-07-01 04:39:10.853+00	f	\N	\N	Descripción	descripcion-355x	\N	\N	\N	\N	\N	str
3093	2024-07-01 04:39:10.866+00	2024-07-01 04:39:10.866+00	f	\N	\N	Nombre del campo	nombre-del-campo-b6dw	\N	\N	\N	\N	\N	str
3094	2024-07-01 04:39:10.881+00	2024-07-01 04:39:10.881+00	f	\N	\N	Tema	tema-wf0a	\N	\N	\N	\N	\N	str
3095	2024-07-01 04:39:10.891+00	2024-07-01 04:39:10.891+00	f	\N	\N	Número de requerimientos	numero-de-requerimientos-obnt	\N	\N	\N	\N	\N	str
3096	2024-07-01 04:39:10.898+00	2024-07-01 04:39:10.898+00	f	\N	\N	Enlace para descargar el detalle de la información solicitada frecuentemente	enlace-para-descargar-el-detalle-de-la-informacion-solicitada-frecuentemente-ju6o	\N	\N	\N	\N	\N	str
3097	2024-07-01 04:39:10.907+00	2024-07-01 04:39:10.907+00	f	\N	\N	Enlace para descargar la solicitud de información complementaria que haya sido solicitada recurrentemente	enlace-para-descargar-la-solicitud-de-informacion-complementaria-que-haya-sido-solicitada-recurrentemente-o9z6	\N	\N	\N	\N	\N	str
3098	2024-07-01 04:39:10.926+00	2024-07-01 04:39:10.926+00	f	\N	\N	Apellidos y Nombres	apellidos-y-nombres-ijsd	\N	\N	\N	\N	\N	str
3099	2024-07-01 04:39:10.932+00	2024-07-01 04:39:10.932+00	f	\N	\N	Denominación del puesto	denominacion-del-puesto-hrur	\N	\N	\N	\N	\N	str
3100	2024-07-01 04:39:10.941+00	2024-07-01 04:39:10.941+00	f	\N	\N	Responsabilidad LOTAIP	responsabilidad-lotaip-gvas	\N	\N	\N	\N	\N	str
3101	2024-07-01 04:39:10.951+00	2024-07-01 04:39:10.951+00	f	\N	\N	Dirección de la oficina	direccion-de-la-oficina-flwq	\N	\N	\N	\N	\N	str
3102	2024-07-01 04:39:10.965+00	2024-07-01 04:39:10.965+00	f	\N	\N	Número telefónico	numero-telefonico-qiv4	\N	\N	\N	\N	\N	str
3103	2024-07-01 04:39:10.974+00	2024-07-01 04:39:10.974+00	f	\N	\N	Extensión telefónica	extension-telefonica-crvm	\N	\N	\N	\N	\N	str
3104	2024-07-01 04:39:10.982+00	2024-07-01 04:39:10.982+00	f	\N	\N	Correo electrónico	correo-electronico-tkv5	\N	\N	\N	\N	\N	str
3105	2024-07-01 04:39:10.995+00	2024-07-01 04:39:10.995+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-840d	\N	\N	\N	\N	\N	str
3106	2024-07-01 04:39:11.005+00	2024-07-01 04:39:11.005+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-z3j5	\N	\N	\N	\N	\N	str
3107	2024-07-01 04:39:11.014+00	2024-07-01 04:39:11.014+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-frm9	\N	\N	\N	\N	\N	str
3108	2024-07-01 04:39:11.025+00	2024-07-01 04:39:11.025+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-e1dt	\N	\N	\N	\N	\N	str
3109	2024-07-01 04:39:11.035+00	2024-07-01 04:39:11.035+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-px94	\N	\N	\N	\N	\N	str
3110	2024-07-01 04:39:11.045+00	2024-07-01 04:39:11.045+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-gc61	\N	\N	\N	\N	\N	str
3111	2024-07-01 04:39:11.054+00	2024-07-01 04:39:11.054+00	f	\N	\N	Enlace para descargar el acuerdo o resolución de creación del comité de transparencia        	enlace-para-descargar-el-acuerdo-o-resolucion-de-creacion-del-comite-de-transparencia-xllk	\N	\N	\N	\N	\N	str
3112	2024-07-01 04:39:11.063+00	2024-07-01 04:39:11.063+00	f	\N	\N	Enlace para descargar el acuerdo o resolución para delegar el manejo de las solicitudes de acceso a la información pública en territorio        	enlace-para-descargar-el-acuerdo-o-resolucion-para-delegar-el-manejo-de-las-solicitudes-de-acceso-a-la-informacion-publica-en-territorio-3hxx	\N	\N	\N	\N	\N	str
3113	2024-07-01 04:39:11.073+00	2024-07-01 04:39:11.073+00	f	\N	\N	Enlace para la recepción de solicitudes de acceso a la información pública por vía electrónica        	enlace-para-la-recepcion-de-solicitudes-de-acceso-a-la-informacion-publica-por-via-electronica-abk0	\N	\N	\N	\N	\N	str
3114	2024-07-01 04:39:11.082+00	2024-07-01 04:39:11.082+00	f	\N	\N	Enlace para descargar el listado de responsables de atender las solicitudes de acceso a la información en las delegaciones provinciales 	enlace-para-descargar-el-listado-de-responsables-de-atender-las-solicitudes-de-acceso-a-la-informacion-en-las-delegaciones-provinciales-q3yl	\N	\N	\N	\N	\N	str
3115	2024-07-01 04:39:11.092+00	2024-07-01 04:39:11.092+00	f	\N	\N	LICENCIA	licencia-aasg	\N	\N	\N	\N	\N	str
3116	2024-07-01 04:39:11.105+00	2024-07-01 04:39:11.105+00	f	\N	\N	Institución	institucion-risg	\N	\N	\N	\N	\N	str
3117	2024-07-01 04:39:11.119+00	2024-07-01 04:39:11.119+00	f	\N	\N	Descripción	descripcion-ceti	\N	\N	\N	\N	\N	str
3118	2024-07-01 04:39:11.13+00	2024-07-01 04:39:11.13+00	f	\N	\N	Nombre del Campo	nombre-del-campo-1h89	\N	\N	\N	\N	\N	str
3119	2024-07-01 04:39:11.144+00	2024-07-01 04:39:11.144+00	f	\N	\N	Apellidos y Nombres	apellidos-y-nombres-2ozp	\N	\N	\N	\N	\N	str
3120	2024-07-01 04:39:11.166+00	2024-07-01 04:39:11.166+00	f	\N	\N	Denominación del puesto	denominacion-del-puesto-n7tv	\N	\N	\N	\N	\N	str
3121	2024-07-01 04:39:11.179+00	2024-07-01 04:39:11.179+00	f	\N	\N	Responsabilidad LOTAIP	responsabilidad-lotaip-ky8g	\N	\N	\N	\N	\N	str
3122	2024-07-01 04:39:11.201+00	2024-07-01 04:39:11.201+00	f	\N	\N	Dirección de la oficina	direccion-de-la-oficina-xexf	\N	\N	\N	\N	\N	str
3123	2024-07-01 04:39:11.215+00	2024-07-01 04:39:11.215+00	f	\N	\N	Número telefónico	numero-telefonico-w6v3	\N	\N	\N	\N	\N	str
3124	2024-07-01 04:39:11.24+00	2024-07-01 04:39:11.24+00	f	\N	\N	Extensión telefónica	extension-telefonica-zrlc	\N	\N	\N	\N	\N	str
3125	2024-07-01 04:39:11.255+00	2024-07-01 04:39:11.255+00	f	\N	\N	Correo electrónico	correo-electronico-obgl	\N	\N	\N	\N	\N	str
3126	2024-07-01 04:39:11.28+00	2024-07-01 04:39:11.28+00	f	\N	\N	Denominación de la organización sindical	denominacion-de-la-organizacion-sindical-50ca	\N	\N	\N	\N	\N	str
3127	2024-07-01 04:39:11.315+00	2024-07-01 04:39:11.315+00	f	\N	\N	Fecha de suscripción del contrato 	fecha-de-suscripcion-del-contrato-igjw	\N	\N	\N	\N	\N	str
3128	2024-07-01 04:39:11.327+00	2024-07-01 04:39:11.327+00	f	\N	\N	Enlace para descargar el contrato colectivo original	enlace-para-descargar-el-contrato-colectivo-original-ypoj	\N	\N	\N	\N	\N	str
3129	2024-07-01 04:39:11.338+00	2024-07-01 04:39:11.338+00	f	\N	\N	Fecha de la última reforma o revisión 	fecha-de-la-ultima-reforma-o-revision-qdgv	\N	\N	\N	\N	\N	str
3130	2024-07-01 04:39:11.351+00	2024-07-01 04:39:11.351+00	f	\N	\N	Enlace para descargar todas las reformas completas del contrato colectivo 	enlace-para-descargar-todas-las-reformas-completas-del-contrato-colectivo-04gw	\N	\N	\N	\N	\N	str
3131	2024-07-01 04:39:11.381+00	2024-07-01 04:39:11.381+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-jua8	\N	\N	\N	\N	\N	str
3132	2024-07-01 04:39:11.399+00	2024-07-01 04:39:11.399+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-2waf	\N	\N	\N	\N	\N	str
3133	2024-07-01 04:39:11.415+00	2024-07-01 04:39:11.415+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-acmq	\N	\N	\N	\N	\N	str
3134	2024-07-01 04:39:11.428+00	2024-07-01 04:39:11.428+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-uo98	\N	\N	\N	\N	\N	str
3135	2024-07-01 04:39:11.441+00	2024-07-01 04:39:11.441+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-z200	\N	\N	\N	\N	\N	str
3136	2024-07-01 04:39:11.459+00	2024-07-01 04:39:11.459+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-qj19	\N	\N	\N	\N	\N	str
3137	2024-07-01 04:39:11.473+00	2024-07-01 04:39:11.473+00	f	\N	\N	LICENCIA	licencia-2pa8	\N	\N	\N	\N	\N	str
3138	2024-07-01 04:39:11.492+00	2024-07-01 04:39:11.493+00	f	\N	\N	Institución	institucion-muhk	\N	\N	\N	\N	\N	str
3139	2024-07-01 04:39:11.503+00	2024-07-01 04:39:11.503+00	f	\N	\N	Descripción	descripcion-bn8p	\N	\N	\N	\N	\N	str
3140	2024-07-01 04:39:11.516+00	2024-07-01 04:39:11.516+00	f	\N	\N	Nombre del campo	nombre-del-campo-skf9	\N	\N	\N	\N	\N	str
3141	2024-07-01 04:39:11.528+00	2024-07-01 04:39:11.528+00	f	\N	\N	Denominación de la organización sindical	denominacion-de-la-organizacion-sindical-ovdj	\N	\N	\N	\N	\N	str
3142	2024-07-01 04:39:11.544+00	2024-07-01 04:39:11.544+00	f	\N	\N	Fecha de suscripción del contrato	fecha-de-suscripcion-del-contrato-wmfl	\N	\N	\N	\N	\N	str
3143	2024-07-01 04:39:11.558+00	2024-07-01 04:39:11.558+00	f	\N	\N	Enlace para descargar el contrato colectivo original	enlace-para-descargar-el-contrato-colectivo-original-nwjt	\N	\N	\N	\N	\N	str
3144	2024-07-01 04:39:11.568+00	2024-07-01 04:39:11.568+00	f	\N	\N	Fecha de la última reforma o revisión 	fecha-de-la-ultima-reforma-o-revision-hc3t	\N	\N	\N	\N	\N	str
3201	2024-07-01 04:39:12.248+00	2024-07-01 04:39:12.248+00	f	\N	\N	Nombre del campo	nombre-del-campo-2oi3	\N	\N	\N	\N	\N	str
3145	2024-07-01 04:39:11.582+00	2024-07-01 04:39:11.582+00	f	\N	\N	Enlace para descargar todas las reformas completas del contrato colectivo 	enlace-para-descargar-todas-las-reformas-completas-del-contrato-colectivo-h8nd	\N	\N	\N	\N	\N	str
3146	2024-07-01 04:39:11.605+00	2024-07-01 04:39:11.605+00	f	\N	\N	Apellidos y Nombres	apellidos-y-nombres-raqa	\N	\N	\N	\N	\N	str
3147	2024-07-01 04:39:11.616+00	2024-07-01 04:39:11.616+00	f	\N	\N	Puesto institucional	puesto-institucional-b8t7	\N	\N	\N	\N	\N	str
3148	2024-07-01 04:39:11.631+00	2024-07-01 04:39:11.631+00	f	\N	\N	Tipo	tipo-r4vz	\N	\N	\N	\N	\N	str
3149	2024-07-01 04:39:11.642+00	2024-07-01 04:39:11.643+00	f	\N	\N	Fecha de inicio del viaje	fecha-de-inicio-del-viaje-sbqv	\N	\N	\N	\N	\N	str
3150	2024-07-01 04:39:11.654+00	2024-07-01 04:39:11.654+00	f	\N	\N	Fecha de fin del viaje	fecha-de-fin-del-viaje-gr5h	\N	\N	\N	\N	\N	str
3151	2024-07-01 04:39:11.664+00	2024-07-01 04:39:11.664+00	f	\N	\N	Motivo del viaje	motivo-del-viaje-ifwx	\N	\N	\N	\N	\N	str
3152	2024-07-01 04:39:11.676+00	2024-07-01 04:39:11.676+00	f	\N	\N	Valor del viático	valor-del-viatico-v8qp	\N	\N	\N	\N	\N	str
3153	2024-07-01 04:39:11.688+00	2024-07-01 04:39:11.688+00	f	\N	\N	Enlace para descargar el informe y justificativos	enlace-para-descargar-el-informe-y-justificativos-0o4f	\N	\N	\N	\N	\N	str
3154	2024-07-01 04:39:11.703+00	2024-07-01 04:39:11.704+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN	fecha-actualizacion-de-la-informacion-nvfk	\N	\N	\N	\N	\N	str
3155	2024-07-01 04:39:11.715+00	2024-07-01 04:39:11.715+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN	periodicidad-de-actualizacion-de-la-informacion-f1b0	\N	\N	\N	\N	\N	str
3156	2024-07-01 04:39:11.725+00	2024-07-01 04:39:11.725+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN	unidad-poseedora-de-la-informacion-tlu3	\N	\N	\N	\N	\N	str
3157	2024-07-01 04:39:11.736+00	2024-07-01 04:39:11.736+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	persona-responsable-de-la-unidad-poseedora-de-la-informacion-reff	\N	\N	\N	\N	\N	str
3158	2024-07-01 04:39:11.749+00	2024-07-01 04:39:11.749+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-d5r3	\N	\N	\N	\N	\N	str
3159	2024-07-01 04:39:11.76+00	2024-07-01 04:39:11.76+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-53d1	\N	\N	\N	\N	\N	str
3160	2024-07-01 04:39:11.769+00	2024-07-01 04:39:11.769+00	f	\N	\N	LICENCIA	licencia-m1v9	\N	\N	\N	\N	\N	str
3161	2024-07-01 04:39:11.781+00	2024-07-01 04:39:11.781+00	f	\N	\N	ENLACE PARA DESCARGAR EL REPORTE CONSOLIDADO DE GASTOS DE VIÁTICOS NACIONALES E INTERNACIONALES	enlace-para-descargar-el-reporte-consolidado-de-gastos-de-viaticos-nacionales-e-internacionales-edbk	\N	\N	\N	\N	\N	str
3162	2024-07-01 04:39:11.798+00	2024-07-01 04:39:11.798+00	f	\N	\N	Institución	institucion-614b	\N	\N	\N	\N	\N	str
3163	2024-07-01 04:39:11.807+00	2024-07-01 04:39:11.808+00	f	\N	\N	Descripción	descripcion-q6dk	\N	\N	\N	\N	\N	str
3164	2024-07-01 04:39:11.818+00	2024-07-01 04:39:11.818+00	f	\N	\N	Nombre del campo	nombre-del-campo-g2ll	\N	\N	\N	\N	\N	str
3165	2024-07-01 04:39:11.827+00	2024-07-01 04:39:11.827+00	f	\N	\N	Apellidos y Nombres	apellidos-y-nombres-sio2	\N	\N	\N	\N	\N	str
3166	2024-07-01 04:39:11.835+00	2024-07-01 04:39:11.835+00	f	\N	\N	Puesto Institucional	puesto-institucional-c0ey	\N	\N	\N	\N	\N	str
3167	2024-07-01 04:39:11.845+00	2024-07-01 04:39:11.845+00	f	\N	\N	Tipo	tipo-p5az	\N	\N	\N	\N	\N	str
3168	2024-07-01 04:39:11.854+00	2024-07-01 04:39:11.854+00	f	\N	\N	Fecha de inicio del viaje	fecha-de-inicio-del-viaje-8q36	\N	\N	\N	\N	\N	str
3169	2024-07-01 04:39:11.863+00	2024-07-01 04:39:11.863+00	f	\N	\N	Fecha de fin del viaje	fecha-de-fin-del-viaje-k5t9	\N	\N	\N	\N	\N	str
3170	2024-07-01 04:39:11.871+00	2024-07-01 04:39:11.871+00	f	\N	\N	Motivo del viaje	motivo-del-viaje-ijlj	\N	\N	\N	\N	\N	str
3171	2024-07-01 04:39:11.883+00	2024-07-01 04:39:11.883+00	f	\N	\N	Valor del viático	valor-del-viatico-89mw	\N	\N	\N	\N	\N	str
3172	2024-07-01 04:39:11.892+00	2024-07-01 04:39:11.893+00	f	\N	\N	Enlace para descargar el informe y justificativo	enlace-para-descargar-el-informe-y-justificativo-vx4a	\N	\N	\N	\N	\N	str
3173	2024-07-01 04:39:11.912+00	2024-07-01 04:39:11.912+00	f	\N	\N	Accion afirmativa	accion-afirmativa-i59h	\N	\N	\N	\N	\N	str
3174	2024-07-01 04:39:11.922+00	2024-07-01 04:39:11.922+00	f	\N	\N	No. de personas con acciones afirmativas	no-de-personas-con-acciones-afirmativas-wa2d	\N	\N	\N	\N	\N	str
3175	2024-07-01 04:39:11.938+00	2024-07-01 04:39:11.938+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN	fecha-actualizacion-de-la-informacion-ob5z	\N	\N	\N	\N	\N	str
3176	2024-07-01 04:39:11.95+00	2024-07-01 04:39:11.95+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN	periodicidad-de-actualizacion-de-la-informacion-b1cp	\N	\N	\N	\N	\N	str
3177	2024-07-01 04:39:11.961+00	2024-07-01 04:39:11.961+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN	unidad-poseedora-de-la-informacion-jktx	\N	\N	\N	\N	\N	str
3178	2024-07-01 04:39:11.971+00	2024-07-01 04:39:11.971+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	persona-responsable-de-la-unidad-poseedora-de-la-informacion-09x1	\N	\N	\N	\N	\N	str
3179	2024-07-01 04:39:11.983+00	2024-07-01 04:39:11.983+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-02kc	\N	\N	\N	\N	\N	str
3180	2024-07-01 04:39:11.994+00	2024-07-01 04:39:11.994+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-oc4e	\N	\N	\N	\N	\N	str
3181	2024-07-01 04:39:12.003+00	2024-07-01 04:39:12.003+00	f	\N	\N	LICENCIA	licencia-xxao	\N	\N	\N	\N	\N	str
3182	2024-07-01 04:39:12.022+00	2024-07-01 04:39:12.022+00	f	\N	\N	Institución	institucion-pd2g	\N	\N	\N	\N	\N	str
3183	2024-07-01 04:39:12.031+00	2024-07-01 04:39:12.031+00	f	\N	\N	Descripción	descripcion-6drk	\N	\N	\N	\N	\N	str
3184	2024-07-01 04:39:12.041+00	2024-07-01 04:39:12.041+00	f	\N	\N	Nombre del campo	nombre-del-campo-ehxn	\N	\N	\N	\N	\N	str
3185	2024-07-01 04:39:12.052+00	2024-07-01 04:39:12.052+00	f	\N	\N	Accion afirmativa	accion-afirmativa-qcvv	\N	\N	\N	\N	\N	str
3186	2024-07-01 04:39:12.067+00	2024-07-01 04:39:12.067+00	f	\N	\N	No. de personas con acciones afirmativas	no-de-personas-con-acciones-afirmativas-38zd	\N	\N	\N	\N	\N	str
3187	2024-07-01 04:39:12.091+00	2024-07-01 04:39:12.091+00	f	\N	\N	Fecha 	fecha-mkbm	\N	\N	\N	\N	\N	str
3188	2024-07-01 04:39:12.107+00	2024-07-01 04:39:12.107+00	f	\N	\N	Descripción	descripcion-ftrc	\N	\N	\N	\N	\N	str
3189	2024-07-01 04:39:12.119+00	2024-07-01 04:39:12.119+00	f	\N	\N	Ocasión o motivo	ocasion-o-motivo-t13e	\N	\N	\N	\N	\N	str
3190	2024-07-01 04:39:12.129+00	2024-07-01 04:39:12.129+00	f	\N	\N	Persona natural o jurídica 	persona-natural-o-juridica-v9vm	\N	\N	\N	\N	\N	str
3191	2024-07-01 04:39:12.138+00	2024-07-01 04:39:12.138+00	f	\N	\N	Enlace para descargar el documento mediante el cual se oficializa el regalo o donativo	enlace-para-descargar-el-documento-mediante-el-cual-se-oficializa-el-regalo-o-donativo-zj23	\N	\N	\N	\N	\N	str
3192	2024-07-01 04:39:12.155+00	2024-07-01 04:39:12.155+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-wff5	\N	\N	\N	\N	\N	str
3193	2024-07-01 04:39:12.164+00	2024-07-01 04:39:12.164+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-xbmo	\N	\N	\N	\N	\N	str
3194	2024-07-01 04:39:12.174+00	2024-07-01 04:39:12.174+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-22q5	\N	\N	\N	\N	\N	str
3195	2024-07-01 04:39:12.186+00	2024-07-01 04:39:12.186+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-fwaf	\N	\N	\N	\N	\N	str
3196	2024-07-01 04:39:12.196+00	2024-07-01 04:39:12.196+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-by99	\N	\N	\N	\N	\N	str
3197	2024-07-01 04:39:12.205+00	2024-07-01 04:39:12.205+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-ndxs	\N	\N	\N	\N	\N	str
3198	2024-07-01 04:39:12.216+00	2024-07-01 04:39:12.216+00	f	\N	\N	LICENCIA	licencia-j2hr	\N	\N	\N	\N	\N	str
3199	2024-07-01 04:39:12.231+00	2024-07-01 04:39:12.231+00	f	\N	\N	Institución	institucion-m3of	\N	\N	\N	\N	\N	str
3200	2024-07-01 04:39:12.238+00	2024-07-01 04:39:12.238+00	f	\N	\N	Descripción	descripcion-oxvv	\N	\N	\N	\N	\N	str
3202	2024-07-01 04:39:12.256+00	2024-07-01 04:39:12.256+00	f	\N	\N	Fecha 	fecha-080d	\N	\N	\N	\N	\N	str
3203	2024-07-01 04:39:12.264+00	2024-07-01 04:39:12.264+00	f	\N	\N	Descripción 	descripcion-hahd	\N	\N	\N	\N	\N	str
3204	2024-07-01 04:39:12.27+00	2024-07-01 04:39:12.27+00	f	\N	\N	Motivo 	motivo-gesg	\N	\N	\N	\N	\N	str
3205	2024-07-01 04:39:12.28+00	2024-07-01 04:39:12.28+00	f	\N	\N	Persona natural o jurídica 	persona-natural-o-juridica-22q0	\N	\N	\N	\N	\N	str
3206	2024-07-01 04:39:12.287+00	2024-07-01 04:39:12.287+00	f	\N	\N	Enlace para descargar el documento mediante el cual se oficializa el regalo o donativo	enlace-para-descargar-el-documento-mediante-el-cual-se-oficializa-el-regalo-o-donativo-2qfa	\N	\N	\N	\N	\N	str
3207	2024-07-01 04:39:12.302+00	2024-07-01 04:39:12.302+00	f	\N	\N	Tema	tema-vjhy	\N	\N	\N	\N	\N	str
3208	2024-07-01 04:39:12.311+00	2024-07-01 04:39:12.311+00	f	\N	\N	Número de Resolución	numero-de-resolucion-mln6	\N	\N	\N	\N	\N	str
3209	2024-07-01 04:39:12.318+00	2024-07-01 04:39:12.318+00	f	\N	\N	Fecha de la clasificación de la información reservada	fecha-de-la-clasificacion-de-la-informacion-reservada-ioyv	\N	\N	\N	\N	\N	str
3210	2024-07-01 04:39:12.327+00	2024-07-01 04:39:12.327+00	f	\N	\N	Período de vigencia de la clasificación de la reserva	periodo-de-vigencia-de-la-clasificacion-de-la-reserva-dl1w	\N	\N	\N	\N	\N	str
3211	2024-07-01 04:39:12.335+00	2024-07-01 04:39:12.335+00	f	\N	\N	Enlace para descargar la resolución de clasificación de información reservada	enlace-para-descargar-la-resolucion-de-clasificacion-de-informacion-reservada-ts6l	\N	\N	\N	\N	\N	str
3212	2024-07-01 04:39:12.35+00	2024-07-01 04:39:12.35+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN	fecha-actualizacion-de-la-informacion-9d9f	\N	\N	\N	\N	\N	str
3213	2024-07-01 04:39:12.36+00	2024-07-01 04:39:12.36+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN	periodicidad-de-actualizacion-de-la-informacion-sv2t	\N	\N	\N	\N	\N	str
3214	2024-07-01 04:39:12.368+00	2024-07-01 04:39:12.368+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN	unidad-poseedora-de-la-informacion-lc8e	\N	\N	\N	\N	\N	str
3215	2024-07-01 04:39:12.38+00	2024-07-01 04:39:12.38+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	persona-responsable-de-la-unidad-poseedora-de-la-informacion-zs6g	\N	\N	\N	\N	\N	str
3216	2024-07-01 04:39:12.389+00	2024-07-01 04:39:12.389+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-s885	\N	\N	\N	\N	\N	str
3217	2024-07-01 04:39:12.397+00	2024-07-01 04:39:12.397+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-5u9m	\N	\N	\N	\N	\N	str
3218	2024-07-01 04:39:12.406+00	2024-07-01 04:39:12.406+00	f	\N	\N	LICENCIA	licencia-rkkc	\N	\N	\N	\N	\N	str
3219	2024-07-01 04:39:12.422+00	2024-07-01 04:39:12.422+00	f	\N	\N	ENLACE PARA DESCARGAR EL LISTADO ÍNDICE DE INFORMACIÓN RESERVADA - CERTIFICADO DE CUMPLIMIENTO 	enlace-para-descargar-el-listado-indice-de-informacion-reservada-certificado-de-cumplimiento-0rmv	\N	\N	\N	\N	\N	str
3220	2024-07-01 04:39:12.436+00	2024-07-01 04:39:12.436+00	f	\N	\N	ENLACE PARA DESCARGAR EL LISTADO ÍNDICE DE INFORMACIÓN RESERVADA - REPORTE DEL LITERAL C) (SISTEMA DE LA DEFENSORÍA DEL PUEBLO DE ECUADOR)	enlace-para-descargar-el-listado-indice-de-informacion-reservada-reporte-del-literal-c-sistema-de-la-defensoria-del-pueblo-de-ecuador-7hz3	\N	\N	\N	\N	\N	str
3221	2024-07-01 04:39:12.46+00	2024-07-01 04:39:12.46+00	f	\N	\N	Institución	institucion-teoe	\N	\N	\N	\N	\N	str
3222	2024-07-01 04:39:12.477+00	2024-07-01 04:39:12.477+00	f	\N	\N	Descripción	descripcion-73t6	\N	\N	\N	\N	\N	str
3223	2024-07-01 04:39:12.491+00	2024-07-01 04:39:12.491+00	f	\N	\N	Nombre del campo	nombre-del-campo-0fv2	\N	\N	\N	\N	\N	str
3224	2024-07-01 04:39:12.503+00	2024-07-01 04:39:12.503+00	f	\N	\N	Tema	tema-l8kr	\N	\N	\N	\N	\N	str
3225	2024-07-01 04:39:12.517+00	2024-07-01 04:39:12.517+00	f	\N	\N	Número de resolución	numero-de-resolucion-neqa	\N	\N	\N	\N	\N	str
3226	2024-07-01 04:39:12.529+00	2024-07-01 04:39:12.529+00	f	\N	\N	Fecha de la clasificación de la información reservada	fecha-de-la-clasificacion-de-la-informacion-reservada-egyp	\N	\N	\N	\N	\N	str
3227	2024-07-01 04:39:12.539+00	2024-07-01 04:39:12.539+00	f	\N	\N	Período de vigencia de la clasificación de la reserva	periodo-de-vigencia-de-la-clasificacion-de-la-reserva-md62	\N	\N	\N	\N	\N	str
3228	2024-07-01 04:39:12.553+00	2024-07-01 04:39:12.553+00	f	\N	\N	Enlace para descargar la resolución de clasificación de información reservada	enlace-para-descargar-la-resolucion-de-clasificacion-de-informacion-reservada-vvkn	\N	\N	\N	\N	\N	str
3229	2024-07-01 04:42:30.122+00	2024-07-01 04:42:30.122+00	f	\N	\N	Nombre de entidad 	nombre-de-entidad-c0jq	\N	\N	\N	\N	\N	str
3230	2024-07-01 04:42:30.132+00	2024-07-01 04:42:30.132+00	f	\N	\N	Temática de la información	tematica-de-la-informacion-7l3s	\N	\N	\N	\N	\N	str
3231	2024-07-01 04:42:30.14+00	2024-07-01 04:42:30.14+00	f	\N	\N	Fecha de publicación de la información 	fecha-de-publicacion-de-la-informacion-k9ba	\N	\N	\N	\N	\N	str
3232	2024-07-01 04:42:30.148+00	2024-07-01 04:42:30.148+00	f	\N	\N	Enlace  a archivo que contiene la información 	enlace-a-archivo-que-contiene-la-informacion-bwgh	\N	\N	\N	\N	\N	str
3233	2024-07-01 04:42:30.159+00	2024-07-01 04:42:30.159+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-6my9	\N	\N	\N	\N	\N	str
3234	2024-07-01 04:42:30.165+00	2024-07-01 04:42:30.165+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-yu50	\N	\N	\N	\N	\N	str
3235	2024-07-01 04:42:30.172+00	2024-07-01 04:42:30.172+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-3qog	\N	\N	\N	\N	\N	str
3236	2024-07-01 04:42:30.179+00	2024-07-01 04:42:30.179+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-r4kw	\N	\N	\N	\N	\N	str
3237	2024-07-01 04:42:30.187+00	2024-07-01 04:42:30.187+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-iui4	\N	\N	\N	\N	\N	str
3238	2024-07-01 04:42:30.194+00	2024-07-01 04:42:30.194+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-01rp	\N	\N	\N	\N	\N	str
3239	2024-07-01 04:42:30.2+00	2024-07-01 04:42:30.2+00	f	\N	\N	LICENCIA	licencia-vzf9	\N	\N	\N	\N	\N	str
3240	2024-07-01 04:42:30.213+00	2024-07-01 04:42:30.213+00	f	\N	\N	Institución	institucion-umtb	\N	\N	\N	\N	\N	str
3241	2024-07-01 04:42:30.22+00	2024-07-01 04:42:30.22+00	f	\N	\N	Descripción	descripcion-zzwz	\N	\N	\N	\N	\N	str
3242	2024-07-01 04:42:30.226+00	2024-07-01 04:42:30.226+00	f	\N	\N	Nombre del campo	nombre-del-campo-0beb	\N	\N	\N	\N	\N	str
3243	2024-07-01 04:42:30.231+00	2024-07-01 04:42:30.231+00	f	\N	\N	Nombre de entidad 	nombre-de-entidad-67qy	\N	\N	\N	\N	\N	str
3244	2024-07-01 04:42:30.237+00	2024-07-01 04:42:30.237+00	f	\N	\N	Temática de la información	tematica-de-la-informacion-akd5	\N	\N	\N	\N	\N	str
3245	2024-07-01 04:42:30.245+00	2024-07-01 04:42:30.245+00	f	\N	\N	Fecha de publicación de la información 	fecha-de-publicacion-de-la-informacion-g4rq	\N	\N	\N	\N	\N	str
3246	2024-07-01 04:42:30.252+00	2024-07-01 04:42:30.252+00	f	\N	\N	Enlace a archivo que contiene la información 	enlace-a-archivo-que-contiene-la-informacion-ncwc	\N	\N	\N	\N	\N	str
3247	2024-07-01 04:42:30.267+00	2024-07-01 04:42:30.267+00	f	\N	\N	Nombre de entidad 	nombre-de-entidad-2av3	\N	\N	\N	\N	\N	str
3248	2024-07-01 04:42:30.276+00	2024-07-01 04:42:30.276+00	f	\N	\N	Fecha en la que se realizó espacio de colaboración	fecha-en-la-que-se-realizo-espacio-de-colaboracion-u28a	\N	\N	\N	\N	\N	str
3249	2024-07-01 04:42:30.285+00	2024-07-01 04:42:30.285+00	f	\N	\N	Modalidad del espacio de colaboración	modalidad-del-espacio-de-colaboracion-xw38	\N	\N	\N	\N	\N	str
3250	2024-07-01 04:42:30.293+00	2024-07-01 04:42:30.293+00	f	\N	\N	Lugar o plataforma en la que se realizó espacio de colaboración 	lugar-o-plataforma-en-la-que-se-realizo-espacio-de-colaboracion-mvy7	\N	\N	\N	\N	\N	str
3251	2024-07-01 04:42:30.3+00	2024-07-01 04:42:30.3+00	f	\N	\N	Persona u organización proponente del espacio de colaboración	persona-u-organizacion-proponente-del-espacio-de-colaboracion-owg6	\N	\N	\N	\N	\N	str
3252	2024-07-01 04:42:30.308+00	2024-07-01 04:42:30.308+00	f	\N	\N	Enlace al archivo de avances o resultados del espacio de colaboración	enlace-al-archivo-de-avances-o-resultados-del-espacio-de-colaboracion-y9o8	\N	\N	\N	\N	\N	str
3253	2024-07-01 04:42:30.323+00	2024-07-01 04:42:30.323+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-yoc7	\N	\N	\N	\N	\N	str
3254	2024-07-01 04:42:30.33+00	2024-07-01 04:42:30.33+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-n1z7	\N	\N	\N	\N	\N	str
3255	2024-07-01 04:42:30.339+00	2024-07-01 04:42:30.339+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-nmsc	\N	\N	\N	\N	\N	str
3256	2024-07-01 04:42:30.347+00	2024-07-01 04:42:30.347+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-ndnj	\N	\N	\N	\N	\N	str
3257	2024-07-01 04:42:30.355+00	2024-07-01 04:42:30.355+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-cgf1	\N	\N	\N	\N	\N	str
3258	2024-07-01 04:42:30.361+00	2024-07-01 04:42:30.361+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-ydx8	\N	\N	\N	\N	\N	str
3259	2024-07-01 04:42:30.37+00	2024-07-01 04:42:30.37+00	f	\N	\N	LICENCIA	licencia-gozm	\N	\N	\N	\N	\N	str
3260	2024-07-01 04:42:30.384+00	2024-07-01 04:42:30.384+00	f	\N	\N	Institución	institucion-e5e0	\N	\N	\N	\N	\N	str
3261	2024-07-01 04:42:30.391+00	2024-07-01 04:42:30.391+00	f	\N	\N	Descripción	descripcion-sg8k	\N	\N	\N	\N	\N	str
3262	2024-07-01 04:42:30.398+00	2024-07-01 04:42:30.398+00	f	\N	\N	Nombre del campo	nombre-del-campo-qa0s	\N	\N	\N	\N	\N	str
3263	2024-07-01 04:42:30.407+00	2024-07-01 04:42:30.407+00	f	\N	\N	Nombre de entidad 	nombre-de-entidad-qwhr	\N	\N	\N	\N	\N	str
3264	2024-07-01 04:42:30.416+00	2024-07-01 04:42:30.416+00	f	\N	\N	Fecha en la que se realizó espacio de colaboración	fecha-en-la-que-se-realizo-espacio-de-colaboracion-yi6b	\N	\N	\N	\N	\N	str
3265	2024-07-01 04:42:30.425+00	2024-07-01 04:42:30.425+00	f	\N	\N	Modalidad del espacio de colaboración	modalidad-del-espacio-de-colaboracion-59oa	\N	\N	\N	\N	\N	str
3266	2024-07-01 04:42:30.433+00	2024-07-01 04:42:30.433+00	f	\N	\N	Lugar o plataforma en la que se realizó espacio de colaboración 	lugar-o-plataforma-en-la-que-se-realizo-espacio-de-colaboracion-te19	\N	\N	\N	\N	\N	str
3267	2024-07-01 04:42:30.441+00	2024-07-01 04:42:30.441+00	f	\N	\N	Persona u organización proponente del espacio de colaboración	persona-u-organizacion-proponente-del-espacio-de-colaboracion-72ja	\N	\N	\N	\N	\N	str
3268	2024-07-01 04:42:30.45+00	2024-07-01 04:42:30.45+00	f	\N	\N	Enlace al archivo de avances o resultados del espacio de colaboración	enlace-al-archivo-de-avances-o-resultados-del-espacio-de-colaboracion-1142	\N	\N	\N	\N	\N	str
3269	2024-07-21 12:54:47.84+00	2024-07-21 12:54:47.84+00	f	\N	\N	Nombre de entidad 	nombre-de-entidad-ja9t	\N	\N	\N	\N	\N	str
3270	2024-07-21 12:54:47.856+00	2024-07-21 12:54:47.856+00	f	\N	\N	Temática de la información	tematica-de-la-informacion-xb9n	\N	\N	\N	\N	\N	str
3271	2024-07-21 12:54:47.864+00	2024-07-21 12:54:47.864+00	f	\N	\N	Fecha de publicación de la información 	fecha-de-publicacion-de-la-informacion-f1qp	\N	\N	\N	\N	\N	str
3272	2024-07-21 12:54:47.873+00	2024-07-21 12:54:47.873+00	f	\N	\N	Enlace  a archivo que contiene la información 	enlace-a-archivo-que-contiene-la-informacion-zfr2	\N	\N	\N	\N	\N	str
3273	2024-07-21 12:54:47.886+00	2024-07-21 12:54:47.886+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-7i10	\N	\N	\N	\N	\N	str
3274	2024-07-21 12:54:47.893+00	2024-07-21 12:54:47.893+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-cgk5	\N	\N	\N	\N	\N	str
3275	2024-07-21 12:54:47.902+00	2024-07-21 12:54:47.902+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-7zes	\N	\N	\N	\N	\N	str
3276	2024-07-21 12:54:47.91+00	2024-07-21 12:54:47.91+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-51s1	\N	\N	\N	\N	\N	str
3277	2024-07-21 12:54:47.919+00	2024-07-21 12:54:47.919+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-i503	\N	\N	\N	\N	\N	str
3278	2024-07-21 12:54:47.928+00	2024-07-21 12:54:47.928+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-fwhm	\N	\N	\N	\N	\N	str
3279	2024-07-21 12:54:47.938+00	2024-07-21 12:54:47.938+00	f	\N	\N	LICENCIA	licencia-5mi8	\N	\N	\N	\N	\N	str
3280	2024-07-21 12:54:47.952+00	2024-07-21 12:54:47.952+00	f	\N	\N	Institución	institucion-fvp1	\N	\N	\N	\N	\N	str
3281	2024-07-21 12:54:47.962+00	2024-07-21 12:54:47.962+00	f	\N	\N	Descripción	descripcion-5sge	\N	\N	\N	\N	\N	str
3282	2024-07-21 12:54:47.971+00	2024-07-21 12:54:47.971+00	f	\N	\N	Nombre del campo	nombre-del-campo-tkvg	\N	\N	\N	\N	\N	str
3283	2024-07-21 12:54:47.982+00	2024-07-21 12:54:47.982+00	f	\N	\N	Nombre de entidad 	nombre-de-entidad-vdy6	\N	\N	\N	\N	\N	str
3284	2024-07-21 12:54:47.991+00	2024-07-21 12:54:47.991+00	f	\N	\N	Temática de la información	tematica-de-la-informacion-37y7	\N	\N	\N	\N	\N	str
3285	2024-07-21 12:54:48.002+00	2024-07-21 12:54:48.002+00	f	\N	\N	Fecha de publicación de la información 	fecha-de-publicacion-de-la-informacion-s3up	\N	\N	\N	\N	\N	str
3286	2024-07-21 12:54:48.009+00	2024-07-21 12:54:48.009+00	f	\N	\N	Enlace a archivo que contiene la información 	enlace-a-archivo-que-contiene-la-informacion-ibjo	\N	\N	\N	\N	\N	str
3287	2024-07-21 12:54:48.025+00	2024-07-21 12:54:48.025+00	f	\N	\N	Nombre de entidad 	nombre-de-entidad-4nwc	\N	\N	\N	\N	\N	str
3288	2024-07-21 12:54:48.033+00	2024-07-21 12:54:48.033+00	f	\N	\N	Fecha en la que se realizó espacio de colaboración	fecha-en-la-que-se-realizo-espacio-de-colaboracion-ku70	\N	\N	\N	\N	\N	str
3289	2024-07-21 12:54:48.041+00	2024-07-21 12:54:48.041+00	f	\N	\N	Modalidad del espacio de colaboración	modalidad-del-espacio-de-colaboracion-wzeh	\N	\N	\N	\N	\N	str
3290	2024-07-21 12:54:48.048+00	2024-07-21 12:54:48.048+00	f	\N	\N	Lugar o plataforma en la que se realizó espacio de colaboración 	lugar-o-plataforma-en-la-que-se-realizo-espacio-de-colaboracion-wwz7	\N	\N	\N	\N	\N	str
3291	2024-07-21 12:54:48.056+00	2024-07-21 12:54:48.056+00	f	\N	\N	Persona u organización proponente del espacio de colaboración	persona-u-organizacion-proponente-del-espacio-de-colaboracion-vf52	\N	\N	\N	\N	\N	str
3292	2024-07-21 12:54:48.067+00	2024-07-21 12:54:48.067+00	f	\N	\N	Enlace al archivo de avances o resultados del espacio de colaboración	enlace-al-archivo-de-avances-o-resultados-del-espacio-de-colaboracion-ceei	\N	\N	\N	\N	\N	str
3293	2024-07-21 12:54:48.081+00	2024-07-21 12:54:48.081+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-rfa0	\N	\N	\N	\N	\N	str
3294	2024-07-21 12:54:48.089+00	2024-07-21 12:54:48.089+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-u7x7	\N	\N	\N	\N	\N	str
3295	2024-07-21 12:54:48.095+00	2024-07-21 12:54:48.096+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-5g83	\N	\N	\N	\N	\N	str
3296	2024-07-21 12:54:48.102+00	2024-07-21 12:54:48.102+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-137h	\N	\N	\N	\N	\N	str
3297	2024-07-21 12:54:48.108+00	2024-07-21 12:54:48.108+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-n7un	\N	\N	\N	\N	\N	str
3298	2024-07-21 12:54:48.114+00	2024-07-21 12:54:48.114+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-78i9	\N	\N	\N	\N	\N	str
3299	2024-07-21 12:54:48.121+00	2024-07-21 12:54:48.121+00	f	\N	\N	LICENCIA	licencia-pvtu	\N	\N	\N	\N	\N	str
3300	2024-07-21 12:54:48.132+00	2024-07-21 12:54:48.132+00	f	\N	\N	Institución	institucion-mll8	\N	\N	\N	\N	\N	str
3301	2024-07-21 12:54:48.139+00	2024-07-21 12:54:48.139+00	f	\N	\N	Descripción	descripcion-dlbh	\N	\N	\N	\N	\N	str
3302	2024-07-21 12:54:48.146+00	2024-07-21 12:54:48.146+00	f	\N	\N	Nombre del campo	nombre-del-campo-ajj2	\N	\N	\N	\N	\N	str
3303	2024-07-21 12:54:48.153+00	2024-07-21 12:54:48.153+00	f	\N	\N	Nombre de entidad 	nombre-de-entidad-xmko	\N	\N	\N	\N	\N	str
3429	2024-07-21 12:56:04.746+00	2024-07-21 12:56:04.746+00	f	\N	\N	Enlace 	enlace-50ky	\N	\N	\N	\N	\N	str
3304	2024-07-21 12:54:48.161+00	2024-07-21 12:54:48.161+00	f	\N	\N	Fecha en la que se realizó espacio de colaboración	fecha-en-la-que-se-realizo-espacio-de-colaboracion-wde2	\N	\N	\N	\N	\N	str
3305	2024-07-21 12:54:48.17+00	2024-07-21 12:54:48.17+00	f	\N	\N	Modalidad del espacio de colaboración	modalidad-del-espacio-de-colaboracion-78fh	\N	\N	\N	\N	\N	str
3306	2024-07-21 12:54:48.179+00	2024-07-21 12:54:48.179+00	f	\N	\N	Lugar o plataforma en la que se realizó espacio de colaboración 	lugar-o-plataforma-en-la-que-se-realizo-espacio-de-colaboracion-a3zk	\N	\N	\N	\N	\N	str
3307	2024-07-21 12:54:48.186+00	2024-07-21 12:54:48.186+00	f	\N	\N	Persona u organización proponente del espacio de colaboración	persona-u-organizacion-proponente-del-espacio-de-colaboracion-asmo	\N	\N	\N	\N	\N	str
3308	2024-07-21 12:54:48.193+00	2024-07-21 12:54:48.193+00	f	\N	\N	Enlace al archivo de avances o resultados del espacio de colaboración	enlace-al-archivo-de-avances-o-resultados-del-espacio-de-colaboracion-2tbc	\N	\N	\N	\N	\N	str
3309	2024-07-21 12:54:48.206+00	2024-07-21 12:54:48.206+00	f	\N	\N	Numeración	numeracion-uw3y	\N	\N	\N	\N	\N	str
3310	2024-07-21 12:54:48.213+00	2024-07-21 12:54:48.213+00	f	\N	\N	Puesto Institucional 	puesto-institucional-79cm	\N	\N	\N	\N	\N	str
3311	2024-07-21 12:54:48.22+00	2024-07-21 12:54:48.22+00	f	\N	\N	Régimen laboral al que pertenece 	regimen-laboral-al-que-pertenece-5x0g	\N	\N	\N	\N	\N	str
3312	2024-07-21 12:54:48.227+00	2024-07-21 12:54:48.227+00	f	\N	\N	Número de partida presupuestaria	numero-de-partida-presupuestaria-ffeu	\N	\N	\N	\N	\N	str
3313	2024-07-21 12:54:48.234+00	2024-07-21 12:54:48.234+00	f	\N	\N	Grado jerárquico o escala al que pertenece el puesto	grado-jerarquico-o-escala-al-que-pertenece-el-puesto-qtbz	\N	\N	\N	\N	\N	str
3314	2024-07-21 12:54:48.243+00	2024-07-21 12:54:48.243+00	f	\N	\N	Remuneración mensual unificada	remuneracion-mensual-unificada-c4pd	\N	\N	\N	\N	\N	str
3315	2024-07-21 12:54:48.249+00	2024-07-21 12:54:48.249+00	f	\N	\N	Remuneración unificada (anual)	remuneracion-unificada-anual-fah0	\N	\N	\N	\N	\N	str
3316	2024-07-21 12:54:48.257+00	2024-07-21 12:54:48.257+00	f	\N	\N	Décimo Tercera Remuneración	decimo-tercera-remuneracion-ed5n	\N	\N	\N	\N	\N	str
3317	2024-07-21 12:54:48.265+00	2024-07-21 12:54:48.265+00	f	\N	\N	Décima Cuarta Remuneración	decima-cuarta-remuneracion-28vw	\N	\N	\N	\N	\N	str
3318	2024-07-21 12:54:48.273+00	2024-07-21 12:54:48.273+00	f	\N	\N	Horas suplementarias y extraordinarias	horas-suplementarias-y-extraordinarias-z6rm	\N	\N	\N	\N	\N	str
3319	2024-07-21 12:54:48.281+00	2024-07-21 12:54:48.281+00	f	\N	\N	Encargos y subrogaciones	encargos-y-subrogaciones-8yx2	\N	\N	\N	\N	\N	str
3320	2024-07-21 12:54:48.288+00	2024-07-21 12:54:48.289+00	f	\N	\N	Total ingresos adicionales	total-ingresos-adicionales-aofk	\N	\N	\N	\N	\N	str
3321	2024-07-21 12:54:48.298+00	2024-07-21 12:54:48.298+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN	fecha-actualizacion-de-la-informacion-h32t	\N	\N	\N	\N	\N	str
3322	2024-07-21 12:54:48.305+00	2024-07-21 12:54:48.305+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN	periodicidad-de-actualizacion-de-la-informacion-k1dc	\N	\N	\N	\N	\N	str
3323	2024-07-21 12:54:48.313+00	2024-07-21 12:54:48.313+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACION	unidad-poseedora-de-la-informacion-j6t7	\N	\N	\N	\N	\N	str
3324	2024-07-21 12:54:48.322+00	2024-07-21 12:54:48.322+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	persona-responsable-de-la-unidad-poseedora-de-la-informacion-3qqa	\N	\N	\N	\N	\N	str
3325	2024-07-21 12:54:48.333+00	2024-07-21 12:54:48.333+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-tpqi	\N	\N	\N	\N	\N	str
3326	2024-07-21 12:54:48.341+00	2024-07-21 12:54:48.341+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-26tt	\N	\N	\N	\N	\N	str
3327	2024-07-21 12:54:48.351+00	2024-07-21 12:54:48.351+00	f	\N	\N	LICENCIA	licencia-qm1f	\N	\N	\N	\N	\N	str
3328	2024-07-21 12:54:48.366+00	2024-07-21 12:54:48.366+00	f	\N	\N	Institución	institucion-1np4	\N	\N	\N	\N	\N	str
3329	2024-07-21 12:54:48.377+00	2024-07-21 12:54:48.377+00	f	\N	\N	Descripción	descripcion-4y32	\N	\N	\N	\N	\N	str
3330	2024-07-21 12:54:48.388+00	2024-07-21 12:54:48.388+00	f	\N	\N	Nombre del Campo	nombre-del-campo-tt5u	\N	\N	\N	\N	\N	str
3331	2024-07-21 12:54:48.396+00	2024-07-21 12:54:48.396+00	f	\N	\N	Numeración	numeracion-93m7	\N	\N	\N	\N	\N	str
3332	2024-07-21 12:54:48.404+00	2024-07-21 12:54:48.404+00	f	\N	\N	Puesto Institucional 	puesto-institucional-2gix	\N	\N	\N	\N	\N	str
3333	2024-07-21 12:54:48.413+00	2024-07-21 12:54:48.413+00	f	\N	\N	Régimen laboral al que pertenece 	regimen-laboral-al-que-pertenece-mtcl	\N	\N	\N	\N	\N	str
3334	2024-07-21 12:54:48.42+00	2024-07-21 12:54:48.42+00	f	\N	\N	Número de partida presupuestaria	numero-de-partida-presupuestaria-nnrh	\N	\N	\N	\N	\N	str
3335	2024-07-21 12:54:48.427+00	2024-07-21 12:54:48.427+00	f	\N	\N	Grado jerárquico o escala al que pertenece el puesto	grado-jerarquico-o-escala-al-que-pertenece-el-puesto-ui37	\N	\N	\N	\N	\N	str
3336	2024-07-21 12:54:48.436+00	2024-07-21 12:54:48.436+00	f	\N	\N	Remuneración mensual unificada	remuneracion-mensual-unificada-g3la	\N	\N	\N	\N	\N	str
3337	2024-07-21 12:54:48.45+00	2024-07-21 12:54:48.45+00	f	\N	\N	Remuneración unificada (anual)	remuneracion-unificada-anual-69b0	\N	\N	\N	\N	\N	str
3338	2024-07-21 12:54:48.459+00	2024-07-21 12:54:48.459+00	f	\N	\N	Décimo Tercera Remuneración	decimo-tercera-remuneracion-cr46	\N	\N	\N	\N	\N	str
3339	2024-07-21 12:54:48.466+00	2024-07-21 12:54:48.467+00	f	\N	\N	Décima Cuarta Remuneración	decima-cuarta-remuneracion-wrgv	\N	\N	\N	\N	\N	str
3340	2024-07-21 12:54:48.475+00	2024-07-21 12:54:48.476+00	f	\N	\N	Horas suplementarias y extraordinarias	horas-suplementarias-y-extraordinarias-tyxe	\N	\N	\N	\N	\N	str
3341	2024-07-21 12:54:48.483+00	2024-07-21 12:54:48.483+00	f	\N	\N	Encargos y subrogaciones	encargos-y-subrogaciones-2rgf	\N	\N	\N	\N	\N	str
3342	2024-07-21 12:54:48.489+00	2024-07-21 12:54:48.489+00	f	\N	\N	Total ingresos adicionales	total-ingresos-adicionales-duyi	\N	\N	\N	\N	\N	str
3343	2024-07-21 12:56:04.132+00	2024-07-21 12:56:04.132+00	f	\N	\N	Organización Política o Alianza	organizacion-politica-o-alianza-2ze4	\N	\N	\N	\N	\N	str
3344	2024-07-21 12:56:04.141+00	2024-07-21 12:56:04.141+00	f	\N	\N	Proceso Electoral	proceso-electoral-cszs	\N	\N	\N	\N	\N	str
3345	2024-07-21 12:56:04.148+00	2024-07-21 12:56:04.148+00	f	\N	\N	Mes	mes-mufu	\N	\N	\N	\N	\N	str
3346	2024-07-21 12:56:04.153+00	2024-07-21 12:56:04.154+00	f	\N	\N	Dignidad	dignidad-wgmk	\N	\N	\N	\N	\N	str
3347	2024-07-21 12:56:04.159+00	2024-07-21 12:56:04.159+00	f	\N	\N	Provincia	provincia-v92q	\N	\N	\N	\N	\N	str
3348	2024-07-21 12:56:04.166+00	2024-07-21 12:56:04.166+00	f	\N	\N	Circunscripción	circunscripcion-789o	\N	\N	\N	\N	\N	str
3349	2024-07-21 12:56:04.173+00	2024-07-21 12:56:04.173+00	f	\N	\N	Cantón	canton-09gk	\N	\N	\N	\N	\N	str
3350	2024-07-21 12:56:04.179+00	2024-07-21 12:56:04.18+00	f	\N	\N	Parroquia	parroquia-7svy	\N	\N	\N	\N	\N	str
3351	2024-07-21 12:56:04.185+00	2024-07-21 12:56:04.185+00	f	\N	\N	Código Cuenta	codigo-cuenta-4drd	\N	\N	\N	\N	\N	str
3352	2024-07-21 12:56:04.192+00	2024-07-21 12:56:04.192+00	f	\N	\N	Cuenta	cuenta-i1br	\N	\N	\N	\N	\N	str
3353	2024-07-21 12:56:04.198+00	2024-07-21 12:56:04.198+00	f	\N	\N	Código Subcuenta	codigo-subcuenta-jh1u	\N	\N	\N	\N	\N	str
3354	2024-07-21 12:56:04.205+00	2024-07-21 12:56:04.205+00	f	\N	\N	Subcuenta	subcuenta-rhel	\N	\N	\N	\N	\N	str
3355	2024-07-21 12:56:04.211+00	2024-07-21 12:56:04.211+00	f	\N	\N	Fecha Comprobante de Venta	fecha-comprobante-de-venta-187s	\N	\N	\N	\N	\N	str
3356	2024-07-21 12:56:04.217+00	2024-07-21 12:56:04.217+00	f	\N	\N	Nro. Comprobante de Venta	nro-comprobante-de-venta-krqp	\N	\N	\N	\N	\N	str
3357	2024-07-21 12:56:04.223+00	2024-07-21 12:56:04.223+00	f	\N	\N	Nro. RUC del Proveedor	nro-ruc-del-proveedor-wlxm	\N	\N	\N	\N	\N	str
3358	2024-07-21 12:56:04.229+00	2024-07-21 12:56:04.229+00	f	\N	\N	Nombre del Proveedor	nombre-del-proveedor-dh12	\N	\N	\N	\N	\N	str
3359	2024-07-21 12:56:04.235+00	2024-07-21 12:56:04.235+00	f	\N	\N	Descripción del Gasto	descripcion-del-gasto-ooi6	\N	\N	\N	\N	\N	str
3360	2024-07-21 12:56:04.241+00	2024-07-21 12:56:04.241+00	f	\N	\N	Subtotal	subtotal-4kmb	\N	\N	\N	\N	\N	str
3361	2024-07-21 12:56:04.248+00	2024-07-21 12:56:04.248+00	f	\N	\N	IVA	iva-47gr	\N	\N	\N	\N	\N	str
3362	2024-07-21 12:56:04.256+00	2024-07-21 12:56:04.256+00	f	\N	\N	Total	total-frok	\N	\N	\N	\N	\N	str
3363	2024-07-21 12:56:04.267+00	2024-07-21 12:56:04.267+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-0ysc	\N	\N	\N	\N	\N	str
3364	2024-07-21 12:56:04.273+00	2024-07-21 12:56:04.273+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-oq6r	\N	\N	\N	\N	\N	str
3365	2024-07-21 12:56:04.279+00	2024-07-21 12:56:04.279+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-bnu3	\N	\N	\N	\N	\N	str
3366	2024-07-21 12:56:04.285+00	2024-07-21 12:56:04.285+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-hpu7	\N	\N	\N	\N	\N	str
3367	2024-07-21 12:56:04.291+00	2024-07-21 12:56:04.291+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-88ll	\N	\N	\N	\N	\N	str
3368	2024-07-21 12:56:04.298+00	2024-07-21 12:56:04.298+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-b4m8	\N	\N	\N	\N	\N	str
3369	2024-07-21 12:56:04.304+00	2024-07-21 12:56:04.304+00	f	\N	\N	LICENCIA	licencia-nqsk	\N	\N	\N	\N	\N	str
3370	2024-07-21 12:56:04.315+00	2024-07-21 12:56:04.315+00	f	\N	\N	Institución	institucion-zxrl	\N	\N	\N	\N	\N	str
3371	2024-07-21 12:56:04.322+00	2024-07-21 12:56:04.322+00	f	\N	\N	Descripción	descripcion-augi	\N	\N	\N	\N	\N	str
3372	2024-07-21 12:56:04.328+00	2024-07-21 12:56:04.328+00	f	\N	\N	Nombre del campo	nombre-del-campo-gxwb	\N	\N	\N	\N	\N	str
3373	2024-07-21 12:56:04.334+00	2024-07-21 12:56:04.334+00	f	\N	\N	Organización Política o Alianza	organizacion-politica-o-alianza-dmpr	\N	\N	\N	\N	\N	str
3374	2024-07-21 12:56:04.34+00	2024-07-21 12:56:04.34+00	f	\N	\N	Proceso Electoral	proceso-electoral-7yza	\N	\N	\N	\N	\N	str
3375	2024-07-21 12:56:04.346+00	2024-07-21 12:56:04.346+00	f	\N	\N	Mes	mes-ei9n	\N	\N	\N	\N	\N	str
3376	2024-07-21 12:56:04.352+00	2024-07-21 12:56:04.352+00	f	\N	\N	Dignidad	dignidad-k2ie	\N	\N	\N	\N	\N	str
3377	2024-07-21 12:56:04.358+00	2024-07-21 12:56:04.358+00	f	\N	\N	Provincia	provincia-hbpa	\N	\N	\N	\N	\N	str
3378	2024-07-21 12:56:04.364+00	2024-07-21 12:56:04.364+00	f	\N	\N	Circunscripción	circunscripcion-pqii	\N	\N	\N	\N	\N	str
3379	2024-07-21 12:56:04.37+00	2024-07-21 12:56:04.37+00	f	\N	\N	Cantón	canton-8v7r	\N	\N	\N	\N	\N	str
3380	2024-07-21 12:56:04.376+00	2024-07-21 12:56:04.376+00	f	\N	\N	Parroquia	parroquia-ikl2	\N	\N	\N	\N	\N	str
3381	2024-07-21 12:56:04.383+00	2024-07-21 12:56:04.383+00	f	\N	\N	Código Cuenta	codigo-cuenta-fkpw	\N	\N	\N	\N	\N	str
3382	2024-07-21 12:56:04.388+00	2024-07-21 12:56:04.388+00	f	\N	\N	Cuenta	cuenta-np9g	\N	\N	\N	\N	\N	str
3383	2024-07-21 12:56:04.394+00	2024-07-21 12:56:04.394+00	f	\N	\N	Código Subcuenta	codigo-subcuenta-kei5	\N	\N	\N	\N	\N	str
3384	2024-07-21 12:56:04.401+00	2024-07-21 12:56:04.401+00	f	\N	\N	Fecha Comprobante de Venta	fecha-comprobante-de-venta-yfca	\N	\N	\N	\N	\N	str
3385	2024-07-21 12:56:04.408+00	2024-07-21 12:56:04.408+00	f	\N	\N	Nro. Comprobante de Venta	nro-comprobante-de-venta-5anm	\N	\N	\N	\N	\N	str
3386	2024-07-21 12:56:04.415+00	2024-07-21 12:56:04.415+00	f	\N	\N	Nro. RUC del Proveedor	nro-ruc-del-proveedor-t1n8	\N	\N	\N	\N	\N	str
3387	2024-07-21 12:56:04.421+00	2024-07-21 12:56:04.421+00	f	\N	\N	Nombre del Proveedor	nombre-del-proveedor-d63u	\N	\N	\N	\N	\N	str
3388	2024-07-21 12:56:04.433+00	2024-07-21 12:56:04.433+00	f	\N	\N	Descripción del Gasto	descripcion-del-gasto-qzv2	\N	\N	\N	\N	\N	str
3389	2024-07-21 12:56:04.468+00	2024-07-21 12:56:04.468+00	f	\N	\N	Subtotal	subtotal-wixv	\N	\N	\N	\N	\N	str
3390	2024-07-21 12:56:04.483+00	2024-07-21 12:56:04.483+00	f	\N	\N	IVA	iva-nlqu	\N	\N	\N	\N	\N	str
3391	2024-07-21 12:56:04.489+00	2024-07-21 12:56:04.489+00	f	\N	\N	Total	total-zumi	\N	\N	\N	\N	\N	str
3392	2024-07-21 12:56:04.506+00	2024-07-21 12:56:04.506+00	f	\N	\N	Nombre de Entidad	nombre-de-entidad-5fz4	\N	\N	\N	\N	\N	str
3393	2024-07-21 12:56:04.514+00	2024-07-21 12:56:04.514+00	f	\N	\N	Fecha	fecha-uorm	\N	\N	\N	\N	\N	str
3394	2024-07-21 12:56:04.522+00	2024-07-21 12:56:04.522+00	f	\N	\N	Nombre de Informe	nombre-de-informe-vlud	\N	\N	\N	\N	\N	str
3395	2024-07-21 12:56:04.529+00	2024-07-21 12:56:04.529+00	f	\N	\N	Enlace a Informe	enlace-a-informe-tacr	\N	\N	\N	\N	\N	str
3396	2024-07-21 12:56:04.54+00	2024-07-21 12:56:04.541+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-eqch	\N	\N	\N	\N	\N	str
3397	2024-07-21 12:56:04.548+00	2024-07-21 12:56:04.548+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-852k	\N	\N	\N	\N	\N	str
3398	2024-07-21 12:56:04.553+00	2024-07-21 12:56:04.553+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-uc4p	\N	\N	\N	\N	\N	str
3399	2024-07-21 12:56:04.558+00	2024-07-21 12:56:04.558+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-8jyy	\N	\N	\N	\N	\N	str
3400	2024-07-21 12:56:04.564+00	2024-07-21 12:56:04.564+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-hhgj	\N	\N	\N	\N	\N	str
3401	2024-07-21 12:56:04.569+00	2024-07-21 12:56:04.569+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-cr9i	\N	\N	\N	\N	\N	str
3402	2024-07-21 12:56:04.575+00	2024-07-21 12:56:04.575+00	f	\N	\N	LICENCIA	licencia-683q	\N	\N	\N	\N	\N	str
3403	2024-07-21 12:56:04.585+00	2024-07-21 12:56:04.585+00	f	\N	\N	Institución	institucion-n0db	\N	\N	\N	\N	\N	str
3404	2024-07-21 12:56:04.591+00	2024-07-21 12:56:04.591+00	f	\N	\N	Descripción	descripcion-pkxz	\N	\N	\N	\N	\N	str
3405	2024-07-21 12:56:04.598+00	2024-07-21 12:56:04.598+00	f	\N	\N	Nombre del campo	nombre-del-campo-iaj6	\N	\N	\N	\N	\N	str
3406	2024-07-21 12:56:04.604+00	2024-07-21 12:56:04.604+00	f	\N	\N	Nombre de Entidad	nombre-de-entidad-z7e7	\N	\N	\N	\N	\N	str
3407	2024-07-21 12:56:04.61+00	2024-07-21 12:56:04.61+00	f	\N	\N	Fecha	fecha-ptci	\N	\N	\N	\N	\N	str
3408	2024-07-21 12:56:04.618+00	2024-07-21 12:56:04.618+00	f	\N	\N	Nombre de Informe	nombre-de-informe-x3to	\N	\N	\N	\N	\N	str
3409	2024-07-21 12:56:04.624+00	2024-07-21 12:56:04.624+00	f	\N	\N	Enlace a Informe	enlace-a-informe-nm8d	\N	\N	\N	\N	\N	str
3410	2024-07-21 12:56:04.635+00	2024-07-21 12:56:04.635+00	f	\N	\N	Nombre de Entidad 	nombre-de-entidad-83dm	\N	\N	\N	\N	\N	str
3411	2024-07-21 12:56:04.64+00	2024-07-21 12:56:04.64+00	f	\N	\N	Número de Resolución o Informe	numero-de-resolucion-o-informe-ru2a	\N	\N	\N	\N	\N	str
3412	2024-07-21 12:56:04.646+00	2024-07-21 12:56:04.646+00	f	\N	\N	Fecha	fecha-8msf	\N	\N	\N	\N	\N	str
3413	2024-07-21 12:56:04.652+00	2024-07-21 12:56:04.652+00	f	\N	\N	Descripción	descripcion-131y	\N	\N	\N	\N	\N	str
3414	2024-07-21 12:56:04.657+00	2024-07-21 12:56:04.657+00	f	\N	\N	Enlace 	enlace-e6op	\N	\N	\N	\N	\N	str
3415	2024-07-21 12:56:04.667+00	2024-07-21 12:56:04.667+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-g9c3	\N	\N	\N	\N	\N	str
3416	2024-07-21 12:56:04.672+00	2024-07-21 12:56:04.672+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-kv5w	\N	\N	\N	\N	\N	str
3417	2024-07-21 12:56:04.677+00	2024-07-21 12:56:04.677+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-s2ak	\N	\N	\N	\N	\N	str
3418	2024-07-21 12:56:04.682+00	2024-07-21 12:56:04.682+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-syxx	\N	\N	\N	\N	\N	str
3419	2024-07-21 12:56:04.686+00	2024-07-21 12:56:04.686+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-g7ck	\N	\N	\N	\N	\N	str
3420	2024-07-21 12:56:04.69+00	2024-07-21 12:56:04.69+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-oi0d	\N	\N	\N	\N	\N	str
3421	2024-07-21 12:56:04.696+00	2024-07-21 12:56:04.696+00	f	\N	\N	LICENCIA	licencia-eg3k	\N	\N	\N	\N	\N	str
3422	2024-07-21 12:56:04.702+00	2024-07-21 12:56:04.702+00	f	\N	\N	Institución	institucion-p5ps	\N	\N	\N	\N	\N	str
3423	2024-07-21 12:56:04.706+00	2024-07-21 12:56:04.706+00	f	\N	\N	Descripción	descripcion-woi3	\N	\N	\N	\N	\N	str
3424	2024-07-21 12:56:04.711+00	2024-07-21 12:56:04.711+00	f	\N	\N	Nombre del campo	nombre-del-campo-jzto	\N	\N	\N	\N	\N	str
3425	2024-07-21 12:56:04.718+00	2024-07-21 12:56:04.718+00	f	\N	\N	Nombre de Entidad 	nombre-de-entidad-kmoi	\N	\N	\N	\N	\N	str
3426	2024-07-21 12:56:04.725+00	2024-07-21 12:56:04.725+00	f	\N	\N	Número de Resolución o Informe	numero-de-resolucion-o-informe-z3zn	\N	\N	\N	\N	\N	str
3427	2024-07-21 12:56:04.733+00	2024-07-21 12:56:04.733+00	f	\N	\N	Fecha	fecha-rgov	\N	\N	\N	\N	\N	str
3428	2024-07-21 12:56:04.739+00	2024-07-21 12:56:04.739+00	f	\N	\N	Descripción	descripcion-ae3b	\N	\N	\N	\N	\N	str
3430	2024-07-21 12:56:04.759+00	2024-07-21 12:56:04.759+00	f	\N	\N	EJERCICIO	ejercicio-fnpf	\N	\N	\N	\N	\N	str
3431	2024-07-21 12:56:04.766+00	2024-07-21 12:56:04.766+00	f	\N	\N	ID_SECTORIAL	id_sectorial-3ptb	\N	\N	\N	\N	\N	str
3432	2024-07-21 12:56:04.772+00	2024-07-21 12:56:04.772+00	f	\N	\N	SECTORIAL	sectorial-306y	\N	\N	\N	\N	\N	str
3433	2024-07-21 12:56:04.78+00	2024-07-21 12:56:04.78+00	f	\N	\N	ID_GRUPO	id_grupo-i38p	\N	\N	\N	\N	\N	str
3434	2024-07-21 12:56:04.786+00	2024-07-21 12:56:04.786+00	f	\N	\N	GRUPO	grupo-gxmz	\N	\N	\N	\N	\N	str
3435	2024-07-21 12:56:04.793+00	2024-07-21 12:56:04.793+00	f	\N	\N	CODIFICADO	codificado-2yyx	\N	\N	\N	\N	\N	str
3436	2024-07-21 12:56:04.799+00	2024-07-21 12:56:04.799+00	f	\N	\N	PROFORMA	proforma-4yym	\N	\N	\N	\N	\N	str
3437	2024-07-21 12:56:04.808+00	2024-07-21 12:56:04.808+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-v1zs	\N	\N	\N	\N	\N	str
3438	2024-07-21 12:56:04.813+00	2024-07-21 12:56:04.813+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-ckqa	\N	\N	\N	\N	\N	str
3439	2024-07-21 12:56:04.817+00	2024-07-21 12:56:04.817+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-cgcn	\N	\N	\N	\N	\N	str
3440	2024-07-21 12:56:04.821+00	2024-07-21 12:56:04.821+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-j2dn	\N	\N	\N	\N	\N	str
3441	2024-07-21 12:56:04.825+00	2024-07-21 12:56:04.825+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-wwpg	\N	\N	\N	\N	\N	str
3442	2024-07-21 12:56:04.831+00	2024-07-21 12:56:04.831+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-7fp8	\N	\N	\N	\N	\N	str
3443	2024-07-21 12:56:04.834+00	2024-07-21 12:56:04.834+00	f	\N	\N	LICENCIA	licencia-p4o7	\N	\N	\N	\N	\N	str
3444	2024-07-21 12:56:04.838+00	2024-07-21 12:56:04.838+00	f	\N	\N	ENLACE PARA DIRECCIONAR A LA PROFORMA DEL PRESUPUESTO GENERAL DEL ESTADO 	enlace-para-direccionar-a-la-proforma-del-presupuesto-general-del-estado-jxjb	\N	\N	\N	\N	\N	str
3445	2024-07-21 12:56:04.847+00	2024-07-21 12:56:04.847+00	f	\N	\N	Institución	institucion-ewb8	\N	\N	\N	\N	\N	str
3446	2024-07-21 12:56:04.852+00	2024-07-21 12:56:04.852+00	f	\N	\N	Descripción	descripcion-am1w	\N	\N	\N	\N	\N	str
3447	2024-07-21 12:56:04.857+00	2024-07-21 12:56:04.857+00	f	\N	\N	Nombre del campo	nombre-del-campo-7k5h	\N	\N	\N	\N	\N	str
3448	2024-07-21 12:56:04.863+00	2024-07-21 12:56:04.863+00	f	\N	\N	EJERCICIO	ejercicio-4v1c	\N	\N	\N	\N	\N	str
3449	2024-07-21 12:56:04.868+00	2024-07-21 12:56:04.868+00	f	\N	\N	ID_SECTORIAL	id_sectorial-rcxh	\N	\N	\N	\N	\N	str
3450	2024-07-21 12:56:04.872+00	2024-07-21 12:56:04.872+00	f	\N	\N	SECTORIAL	sectorial-at9f	\N	\N	\N	\N	\N	str
3451	2024-07-21 12:56:04.877+00	2024-07-21 12:56:04.877+00	f	\N	\N	ID_GRUPO	id_grupo-eahu	\N	\N	\N	\N	\N	str
3452	2024-07-21 12:56:04.884+00	2024-07-21 12:56:04.884+00	f	\N	\N	GRUPO	grupo-jr21	\N	\N	\N	\N	\N	str
3453	2024-07-21 12:56:04.889+00	2024-07-21 12:56:04.889+00	f	\N	\N	CODIFICADO	codificado-zl0a	\N	\N	\N	\N	\N	str
3454	2024-07-21 12:56:04.895+00	2024-07-21 12:56:04.895+00	f	\N	\N	PROFORMA	proforma-y1nq	\N	\N	\N	\N	\N	str
3455	2024-07-21 12:56:04.906+00	2024-07-21 12:56:04.906+00	f	\N	\N	Fecha	fecha-fto8	\N	\N	\N	\N	\N	str
3456	2024-07-21 12:56:04.911+00	2024-07-21 12:56:04.911+00	f	\N	\N	GAD o Entidad	gad-o-entidad-1xvc	\N	\N	\N	\N	\N	str
3457	2024-07-21 12:56:04.918+00	2024-07-21 12:56:04.918+00	f	\N	\N	Tipo	tipo-0wr5	\N	\N	\N	\N	\N	str
3458	2024-07-21 12:56:04.925+00	2024-07-21 12:56:04.925+00	f	\N	\N	Título	titulo-5jr3	\N	\N	\N	\N	\N	str
3459	2024-07-21 12:56:04.933+00	2024-07-21 12:56:04.933+00	f	\N	\N	Enlace 	enlace-09zu	\N	\N	\N	\N	\N	str
3460	2024-07-21 12:56:04.948+00	2024-07-21 12:56:04.948+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN	fecha-actualizacion-de-la-informacion-lw0l	\N	\N	\N	\N	\N	str
3461	2024-07-21 12:56:04.955+00	2024-07-21 12:56:04.955+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN	periodicidad-de-actualizacion-de-la-informacion-6tp4	\N	\N	\N	\N	\N	str
3462	2024-07-21 12:56:04.962+00	2024-07-21 12:56:04.962+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN	unidad-poseedora-de-la-informacion-bny6	\N	\N	\N	\N	\N	str
3463	2024-07-21 12:56:04.969+00	2024-07-21 12:56:04.969+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	persona-responsable-de-la-unidad-poseedora-de-la-informacion-a8id	\N	\N	\N	\N	\N	str
3464	2024-07-21 12:56:04.975+00	2024-07-21 12:56:04.975+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-jxuw	\N	\N	\N	\N	\N	str
3465	2024-07-21 12:56:04.982+00	2024-07-21 12:56:04.982+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-pkqs	\N	\N	\N	\N	\N	str
3466	2024-07-21 12:56:04.988+00	2024-07-21 12:56:04.988+00	f	\N	\N	LICENCIA	licencia-uzzo	\N	\N	\N	\N	\N	str
3467	2024-07-21 12:56:05.001+00	2024-07-21 12:56:05.001+00	f	\N	\N	Institución	institucion-rtjx	\N	\N	\N	\N	\N	str
3468	2024-07-21 12:56:05.008+00	2024-07-21 12:56:05.008+00	f	\N	\N	Descripción	descripcion-or9j	\N	\N	\N	\N	\N	str
3469	2024-07-21 12:56:05.015+00	2024-07-21 12:56:05.015+00	f	\N	\N	Nombre del campo	nombre-del-campo-w475	\N	\N	\N	\N	\N	str
3470	2024-07-21 12:56:05.021+00	2024-07-21 12:56:05.021+00	f	\N	\N	Fecha	fecha-9fd0	\N	\N	\N	\N	\N	str
3471	2024-07-21 12:56:05.028+00	2024-07-21 12:56:05.028+00	f	\N	\N	GAD o Entidad	gad-o-entidad-pvij	\N	\N	\N	\N	\N	str
3472	2024-07-21 12:56:05.034+00	2024-07-21 12:56:05.034+00	f	\N	\N	Tipo	tipo-nask	\N	\N	\N	\N	\N	str
3473	2024-07-21 12:56:05.039+00	2024-07-21 12:56:05.039+00	f	\N	\N	Título	titulo-vspv	\N	\N	\N	\N	\N	str
3474	2024-07-21 12:56:05.046+00	2024-07-21 12:56:05.046+00	f	\N	\N	Enlace 	enlace-lq8w	\N	\N	\N	\N	\N	str
3475	2024-07-21 12:56:05.057+00	2024-07-21 12:56:05.057+00	f	\N	\N	Número de Proceso	numero-de-proceso-c9e4	\N	\N	\N	\N	\N	str
3476	2024-07-21 12:56:05.063+00	2024-07-21 12:56:05.064+00	f	\N	\N	Fecha de ingreso	fecha-de-ingreso-nyd0	\N	\N	\N	\N	\N	str
3477	2024-07-21 12:56:05.069+00	2024-07-21 12:56:05.069+00	f	\N	\N	Materia	materia-abxm	\N	\N	\N	\N	\N	str
3478	2024-07-21 12:56:05.074+00	2024-07-21 12:56:05.074+00	f	\N	\N	Delito o Asunto	delito-o-asunto-4wt1	\N	\N	\N	\N	\N	str
3479	2024-07-21 12:56:05.08+00	2024-07-21 12:56:05.08+00	f	\N	\N	Tipo de acción	tipo-de-accion-trmm	\N	\N	\N	\N	\N	str
3480	2024-07-21 12:56:05.086+00	2024-07-21 12:56:05.086+00	f	\N	\N	Provincia	provincia-jp3q	\N	\N	\N	\N	\N	str
3481	2024-07-21 12:56:05.092+00	2024-07-21 12:56:05.092+00	f	\N	\N	Cantón	canton-nphk	\N	\N	\N	\N	\N	str
3482	2024-07-21 12:56:05.098+00	2024-07-21 12:56:05.098+00	f	\N	\N	Dependencia Jurisdiccional	dependencia-jurisdiccional-newn	\N	\N	\N	\N	\N	str
3483	2024-07-21 12:56:05.104+00	2024-07-21 12:56:05.104+00	f	\N	\N	Estado	estado-ka4a	\N	\N	\N	\N	\N	str
3484	2024-07-21 12:56:05.109+00	2024-07-21 12:56:05.109+00	f	\N	\N	Resumen de Sentencia	resumen-de-sentencia-qubu	\N	\N	\N	\N	\N	str
3485	2024-07-21 12:56:05.116+00	2024-07-21 12:56:05.116+00	f	\N	\N	Enlace al Texto Íntegro del Proceso y Sentencia	enlace-al-texto-integro-del-proceso-y-sentencia-laet	\N	\N	\N	\N	\N	str
3486	2024-07-21 12:56:05.125+00	2024-07-21 12:56:05.125+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN	fecha-actualizacion-de-la-informacion-8f4q	\N	\N	\N	\N	\N	str
3487	2024-07-21 12:56:05.131+00	2024-07-21 12:56:05.131+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN	periodicidad-de-actualizacion-de-la-informacion-ck14	\N	\N	\N	\N	\N	str
3488	2024-07-21 12:56:05.137+00	2024-07-21 12:56:05.137+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN	unidad-poseedora-de-la-informacion-rv7i	\N	\N	\N	\N	\N	str
3489	2024-07-21 12:56:05.142+00	2024-07-21 12:56:05.142+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	persona-responsable-de-la-unidad-poseedora-de-la-informacion-aeks	\N	\N	\N	\N	\N	str
3490	2024-07-21 12:56:05.148+00	2024-07-21 12:56:05.148+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-jaqz	\N	\N	\N	\N	\N	str
3491	2024-07-21 12:56:05.154+00	2024-07-21 12:56:05.154+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-97q8	\N	\N	\N	\N	\N	str
3492	2024-07-21 12:56:05.159+00	2024-07-21 12:56:05.159+00	f	\N	\N	LICENCIA	licencia-ulse	\N	\N	\N	\N	\N	str
3556	2024-07-21 12:56:05.702+00	2024-07-21 12:56:05.702+00	f	\N	\N	Dignidad	dignidad-9ofs	\N	\N	\N	\N	\N	str
3493	2024-07-21 12:56:05.166+00	2024-07-21 12:56:05.166+00	f	\N	\N	ENLACE A CONSULTAS DE PROCESOS JUDICIALES ELECTRÓNICOS E-SATJE	enlace-a-consultas-de-procesos-judiciales-electronicos-e-satje-bqd2	\N	\N	\N	\N	\N	str
3494	2024-07-21 12:56:05.176+00	2024-07-21 12:56:05.176+00	f	\N	\N	Institución	institucion-zbnj	\N	\N	\N	\N	\N	str
3495	2024-07-21 12:56:05.183+00	2024-07-21 12:56:05.183+00	f	\N	\N	Descripción	descripcion-tfig	\N	\N	\N	\N	\N	str
3496	2024-07-21 12:56:05.189+00	2024-07-21 12:56:05.189+00	f	\N	\N	Nombre del campo	nombre-del-campo-iy1s	\N	\N	\N	\N	\N	str
3497	2024-07-21 12:56:05.195+00	2024-07-21 12:56:05.195+00	f	\N	\N	Número de Proceso	numero-de-proceso-jq5u	\N	\N	\N	\N	\N	str
3498	2024-07-21 12:56:05.202+00	2024-07-21 12:56:05.202+00	f	\N	\N	Fecha de ingreso	fecha-de-ingreso-hta6	\N	\N	\N	\N	\N	str
3499	2024-07-21 12:56:05.207+00	2024-07-21 12:56:05.207+00	f	\N	\N	Materia	materia-9064	\N	\N	\N	\N	\N	str
3500	2024-07-21 12:56:05.214+00	2024-07-21 12:56:05.214+00	f	\N	\N	Delito o Asunto	delito-o-asunto-n22s	\N	\N	\N	\N	\N	str
3501	2024-07-21 12:56:05.219+00	2024-07-21 12:56:05.219+00	f	\N	\N	Tipo de acción	tipo-de-accion-9k31	\N	\N	\N	\N	\N	str
3502	2024-07-21 12:56:05.224+00	2024-07-21 12:56:05.224+00	f	\N	\N	Provincia	provincia-3cvs	\N	\N	\N	\N	\N	str
3503	2024-07-21 12:56:05.231+00	2024-07-21 12:56:05.231+00	f	\N	\N	Cantón	canton-0dlk	\N	\N	\N	\N	\N	str
3504	2024-07-21 12:56:05.238+00	2024-07-21 12:56:05.238+00	f	\N	\N	Dependencia Jurisdiccional	dependencia-jurisdiccional-lvf0	\N	\N	\N	\N	\N	str
3505	2024-07-21 12:56:05.246+00	2024-07-21 12:56:05.246+00	f	\N	\N	Estado	estado-3l23	\N	\N	\N	\N	\N	str
3506	2024-07-21 12:56:05.254+00	2024-07-21 12:56:05.254+00	f	\N	\N	Resumen de Sentencia	resumen-de-sentencia-wejd	\N	\N	\N	\N	\N	str
3507	2024-07-21 12:56:05.261+00	2024-07-21 12:56:05.261+00	f	\N	\N	Enlace al Texto Íntegro del Proceso y Sentencia	enlace-al-texto-integro-del-proceso-y-sentencia-og6o	\N	\N	\N	\N	\N	str
3508	2024-07-21 12:56:05.276+00	2024-07-21 12:56:05.276+00	f	\N	\N	Número de causa	numero-de-causa-6b4k	\N	\N	\N	\N	\N	str
3509	2024-07-21 12:56:05.284+00	2024-07-21 12:56:05.284+00	f	\N	\N	Año	ano-gdb1	\N	\N	\N	\N	\N	str
3510	2024-07-21 12:56:05.296+00	2024-07-21 12:56:05.296+00	f	\N	\N	Fecha	fecha-8bvv	\N	\N	\N	\N	\N	str
3511	2024-07-21 12:56:05.305+00	2024-07-21 12:56:05.305+00	f	\N	\N	Provincia	provincia-9f74	\N	\N	\N	\N	\N	str
3512	2024-07-21 12:56:05.314+00	2024-07-21 12:56:05.314+00	f	\N	\N	Accionante	accionante-gc96	\N	\N	\N	\N	\N	str
3513	2024-07-21 12:56:05.324+00	2024-07-21 12:56:05.324+00	f	\N	\N	Accionado	accionado-3yam	\N	\N	\N	\N	\N	str
3514	2024-07-21 12:56:05.333+00	2024-07-21 12:56:05.333+00	f	\N	\N	Tipo de Causa	tipo-de-causa-fg8p	\N	\N	\N	\N	\N	str
3515	2024-07-21 12:56:05.341+00	2024-07-21 12:56:05.341+00	f	\N	\N	Organización Política	organizacion-politica-0h6e	\N	\N	\N	\N	\N	str
3516	2024-07-21 12:56:05.348+00	2024-07-21 12:56:05.348+00	f	\N	\N	Enlace a Sentencia	enlace-a-sentencia-5op1	\N	\N	\N	\N	\N	str
3517	2024-07-21 12:56:05.361+00	2024-07-21 12:56:05.361+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-xbrm	\N	\N	\N	\N	\N	str
3518	2024-07-21 12:56:05.368+00	2024-07-21 12:56:05.368+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-qjru	\N	\N	\N	\N	\N	str
3519	2024-07-21 12:56:05.376+00	2024-07-21 12:56:05.376+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-ud0f	\N	\N	\N	\N	\N	str
3520	2024-07-21 12:56:05.384+00	2024-07-21 12:56:05.384+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-3i28	\N	\N	\N	\N	\N	str
3521	2024-07-21 12:56:05.396+00	2024-07-21 12:56:05.396+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-wp03	\N	\N	\N	\N	\N	str
3522	2024-07-21 12:56:05.406+00	2024-07-21 12:56:05.406+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-afbf	\N	\N	\N	\N	\N	str
3523	2024-07-21 12:56:05.421+00	2024-07-21 12:56:05.421+00	f	\N	\N	LICENCIA	licencia-nr7n	\N	\N	\N	\N	\N	str
3524	2024-07-21 12:56:05.44+00	2024-07-21 12:56:05.44+00	f	\N	\N	Institución	institucion-nsbz	\N	\N	\N	\N	\N	str
3525	2024-07-21 12:56:05.448+00	2024-07-21 12:56:05.448+00	f	\N	\N	Descripción	descripcion-riw8	\N	\N	\N	\N	\N	str
3526	2024-07-21 12:56:05.456+00	2024-07-21 12:56:05.456+00	f	\N	\N	Nombre del campo	nombre-del-campo-hl6t	\N	\N	\N	\N	\N	str
3527	2024-07-21 12:56:05.464+00	2024-07-21 12:56:05.464+00	f	\N	\N	Número de Causa	numero-de-causa-eep0	\N	\N	\N	\N	\N	str
3528	2024-07-21 12:56:05.471+00	2024-07-21 12:56:05.471+00	f	\N	\N	Año	ano-eg7p	\N	\N	\N	\N	\N	str
3529	2024-07-21 12:56:05.478+00	2024-07-21 12:56:05.478+00	f	\N	\N	Fecha	fecha-7myw	\N	\N	\N	\N	\N	str
3530	2024-07-21 12:56:05.485+00	2024-07-21 12:56:05.485+00	f	\N	\N	Provincia	provincia-9r5j	\N	\N	\N	\N	\N	str
3531	2024-07-21 12:56:05.493+00	2024-07-21 12:56:05.493+00	f	\N	\N	Accionante	accionante-s6rq	\N	\N	\N	\N	\N	str
3532	2024-07-21 12:56:05.502+00	2024-07-21 12:56:05.502+00	f	\N	\N	Accionado	accionado-rgse	\N	\N	\N	\N	\N	str
3533	2024-07-21 12:56:05.51+00	2024-07-21 12:56:05.51+00	f	\N	\N	Tipo de causa	tipo-de-causa-zl1f	\N	\N	\N	\N	\N	str
3534	2024-07-21 12:56:05.519+00	2024-07-21 12:56:05.519+00	f	\N	\N	Organización Política	organizacion-politica-0fu8	\N	\N	\N	\N	\N	str
3535	2024-07-21 12:56:05.526+00	2024-07-21 12:56:05.526+00	f	\N	\N	Enlace a Sentencia	enlace-a-sentencia-20j6	\N	\N	\N	\N	\N	str
3536	2024-07-21 12:56:05.541+00	2024-07-21 12:56:05.541+00	f	\N	\N	Organización política, candidato/a	organizacion-politica-candidatoa-8d8a	\N	\N	\N	\N	\N	str
3537	2024-07-21 12:56:05.549+00	2024-07-21 12:56:05.549+00	f	\N	\N	Proceso Electoral	proceso-electoral-u4ao	\N	\N	\N	\N	\N	str
3538	2024-07-21 12:56:05.557+00	2024-07-21 12:56:05.557+00	f	\N	\N	Dignidad	dignidad-6qp6	\N	\N	\N	\N	\N	str
3539	2024-07-21 12:56:05.564+00	2024-07-21 12:56:05.564+00	f	\N	\N	Monto recibido	monto-recibido-ym4k	\N	\N	\N	\N	\N	str
3540	2024-07-21 12:56:05.572+00	2024-07-21 12:56:05.572+00	f	\N	\N	Monto gastado	monto-gastado-rj5i	\N	\N	\N	\N	\N	str
3541	2024-07-21 12:56:05.586+00	2024-07-21 12:56:05.586+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-nonk	\N	\N	\N	\N	\N	str
3542	2024-07-21 12:56:05.594+00	2024-07-21 12:56:05.594+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-z243	\N	\N	\N	\N	\N	str
3543	2024-07-21 12:56:05.601+00	2024-07-21 12:56:05.602+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-9h2z	\N	\N	\N	\N	\N	str
3544	2024-07-21 12:56:05.608+00	2024-07-21 12:56:05.608+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-0vph	\N	\N	\N	\N	\N	str
3545	2024-07-21 12:56:05.618+00	2024-07-21 12:56:05.618+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-lju0	\N	\N	\N	\N	\N	str
3546	2024-07-21 12:56:05.625+00	2024-07-21 12:56:05.625+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-ufqa	\N	\N	\N	\N	\N	str
3547	2024-07-21 12:56:05.633+00	2024-07-21 12:56:05.633+00	f	\N	\N	LICENCIA	licencia-69pc	\N	\N	\N	\N	\N	str
3548	2024-07-21 12:56:05.64+00	2024-07-21 12:56:05.64+00	f	\N	\N	Enlace para direccionar a los planes de trabajo de las candidatas y candidatos a las distintas elecciones	enlace-para-direccionar-a-los-planes-de-trabajo-de-las-candidatas-y-candidatos-a-las-distintas-elecciones-m229	\N	\N	\N	\N	\N	str
3549	2024-07-21 12:56:05.647+00	2024-07-21 12:56:05.647+00	f	\N	\N	Enlace para direccionar a los resultados de los procesos electorales	enlace-para-direccionar-a-los-resultados-de-los-procesos-electorales-1fz7	\N	\N	\N	\N	\N	str
3550	2024-07-21 12:56:05.654+00	2024-07-21 12:56:05.654+00	f	\N	\N	Enlace para direccionar a las actas de cada junta y recinto electoral 	enlace-para-direccionar-a-las-actas-de-cada-junta-y-recinto-electoral-eqcf	\N	\N	\N	\N	\N	str
3551	2024-07-21 12:56:05.664+00	2024-07-21 12:56:05.664+00	f	\N	\N	Institución	institucion-ujxj	\N	\N	\N	\N	\N	str
3552	2024-07-21 12:56:05.671+00	2024-07-21 12:56:05.671+00	f	\N	\N	Descripción	descripcion-xxhf	\N	\N	\N	\N	\N	str
3553	2024-07-21 12:56:05.678+00	2024-07-21 12:56:05.678+00	f	\N	\N	Nombre del campo	nombre-del-campo-nwu8	\N	\N	\N	\N	\N	str
3554	2024-07-21 12:56:05.685+00	2024-07-21 12:56:05.685+00	f	\N	\N	Organización política, candidato/a	organizacion-politica-candidatoa-i4s7	\N	\N	\N	\N	\N	str
3555	2024-07-21 12:56:05.693+00	2024-07-21 12:56:05.693+00	f	\N	\N	Proceso Electoral	proceso-electoral-d2az	\N	\N	\N	\N	\N	str
3557	2024-07-21 12:56:05.71+00	2024-07-21 12:56:05.71+00	f	\N	\N	Monto recibido	monto-recibido-33sr	\N	\N	\N	\N	\N	str
3558	2024-07-21 12:56:05.718+00	2024-07-21 12:56:05.718+00	f	\N	\N	Monto gastado	monto-gastado-tp1o	\N	\N	\N	\N	\N	str
3559	2024-07-21 12:56:05.732+00	2024-07-21 12:56:05.732+00	f	\N	\N	Número de Sentencia o Dictamen	numero-de-sentencia-o-dictamen-6k0m	\N	\N	\N	\N	\N	str
3560	2024-07-21 12:56:05.737+00	2024-07-21 12:56:05.737+00	f	\N	\N	Fecha	fecha-aw1q	\N	\N	\N	\N	\N	str
3561	2024-07-21 12:56:05.743+00	2024-07-21 12:56:05.743+00	f	\N	\N	Tipo de Acción	tipo-de-accion-fi10	\N	\N	\N	\N	\N	str
3562	2024-07-21 12:56:05.749+00	2024-07-21 12:56:05.749+00	f	\N	\N	Materia	materia-th43	\N	\N	\N	\N	\N	str
3563	2024-07-21 12:56:05.753+00	2024-07-21 12:56:05.753+00	f	\N	\N	Decisión resumen	decision-resumen-0pjt	\N	\N	\N	\N	\N	str
3564	2024-07-21 12:56:05.758+00	2024-07-21 12:56:05.758+00	f	\N	\N	Enlace al Texto Íntegro de la Sentencia	enlace-al-texto-integro-de-la-sentencia-0h3z	\N	\N	\N	\N	\N	str
3565	2024-07-21 12:56:05.766+00	2024-07-21 12:56:05.766+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-nm56	\N	\N	\N	\N	\N	str
3566	2024-07-21 12:56:05.771+00	2024-07-21 12:56:05.771+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-e1qg	\N	\N	\N	\N	\N	str
3567	2024-07-21 12:56:05.775+00	2024-07-21 12:56:05.775+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-6guw	\N	\N	\N	\N	\N	str
3568	2024-07-21 12:56:05.78+00	2024-07-21 12:56:05.78+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-olld	\N	\N	\N	\N	\N	str
3569	2024-07-21 12:56:05.785+00	2024-07-21 12:56:05.785+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-v37y	\N	\N	\N	\N	\N	str
3570	2024-07-21 12:56:05.79+00	2024-07-21 12:56:05.79+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-h8yn	\N	\N	\N	\N	\N	str
3571	2024-07-21 12:56:05.794+00	2024-07-21 12:56:05.794+00	f	\N	\N	LICENCIA	licencia-k1t7	\N	\N	\N	\N	\N	str
3572	2024-07-21 12:56:05.799+00	2024-07-21 12:56:05.799+00	f	\N	\N	ENLACE QUE DIRECCIONA AL SISTEMA DE GESTIÓN DE ACCIONES CONSTITUCIONALES 	enlace-que-direcciona-al-sistema-de-gestion-de-acciones-constitucionales-a016	\N	\N	\N	\N	\N	str
3573	2024-07-21 12:56:05.807+00	2024-07-21 12:56:05.807+00	f	\N	\N	Institución	institucion-aarm	\N	\N	\N	\N	\N	str
3574	2024-07-21 12:56:05.812+00	2024-07-21 12:56:05.812+00	f	\N	\N	Descripción	descripcion-ed05	\N	\N	\N	\N	\N	str
3575	2024-07-21 12:56:05.817+00	2024-07-21 12:56:05.817+00	f	\N	\N	Nombre del campo	nombre-del-campo-a0m1	\N	\N	\N	\N	\N	str
3576	2024-07-21 12:56:05.822+00	2024-07-21 12:56:05.822+00	f	\N	\N	Número de Sentencia o Dictamen	numero-de-sentencia-o-dictamen-eq6e	\N	\N	\N	\N	\N	str
3577	2024-07-21 12:56:05.826+00	2024-07-21 12:56:05.827+00	f	\N	\N	Fecha	fecha-tg4h	\N	\N	\N	\N	\N	str
3578	2024-07-21 12:56:05.832+00	2024-07-21 12:56:05.832+00	f	\N	\N	Tipo de Acción	tipo-de-accion-3n2t	\N	\N	\N	\N	\N	str
3579	2024-07-21 12:56:05.836+00	2024-07-21 12:56:05.836+00	f	\N	\N	Materia	materia-f0ft	\N	\N	\N	\N	\N	str
3580	2024-07-21 12:56:05.84+00	2024-07-21 12:56:05.84+00	f	\N	\N	Decisión resumen	decision-resumen-1ee0	\N	\N	\N	\N	\N	str
3581	2024-07-21 12:56:05.844+00	2024-07-21 12:56:05.844+00	f	\N	\N	Enlace al Texto Íntegro de la Sentencia	enlace-al-texto-integro-de-la-sentencia-z7ef	\N	\N	\N	\N	\N	str
3582	2024-07-21 12:56:05.855+00	2024-07-21 12:56:05.855+00	f	\N	\N	Código	codigo-i3s6	\N	\N	\N	\N	\N	str
3583	2024-07-21 12:56:05.859+00	2024-07-21 12:56:05.859+00	f	\N	\N	Fecha de Presentación	fecha-de-presentacion-yy8j	\N	\N	\N	\N	\N	str
3584	2024-07-21 12:56:05.866+00	2024-07-21 12:56:05.866+00	f	\N	\N	Tipo 	tipo-dfgl	\N	\N	\N	\N	\N	str
3585	2024-07-21 12:56:05.87+00	2024-07-21 12:56:05.87+00	f	\N	\N	Proyecto, enmienda o reforma constitucional	proyecto-enmienda-o-reforma-constitucional-a7ma	\N	\N	\N	\N	\N	str
3586	2024-07-21 12:56:05.875+00	2024-07-21 12:56:05.875+00	f	\N	\N	Proponente(s)	proponentes-2hu3	\N	\N	\N	\N	\N	str
3587	2024-07-21 12:56:05.881+00	2024-07-21 12:56:05.881+00	f	\N	\N	Comisión	comision-p00m	\N	\N	\N	\N	\N	str
3588	2024-07-21 12:56:05.887+00	2024-07-21 12:56:05.887+00	f	\N	\N	Estado	estado-qyib	\N	\N	\N	\N	\N	str
3589	2024-07-21 12:56:05.892+00	2024-07-21 12:56:05.892+00	f	\N	\N	Enlace a proyecto de ley documentos e informes	enlace-a-proyecto-de-ley-documentos-e-informes-1q18	\N	\N	\N	\N	\N	str
3590	2024-07-21 12:56:05.901+00	2024-07-21 12:56:05.901+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-41zh	\N	\N	\N	\N	\N	str
3591	2024-07-21 12:56:05.906+00	2024-07-21 12:56:05.906+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-n05v	\N	\N	\N	\N	\N	str
3592	2024-07-21 12:56:05.91+00	2024-07-21 12:56:05.91+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-o99l	\N	\N	\N	\N	\N	str
3593	2024-07-21 12:56:05.915+00	2024-07-21 12:56:05.915+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-m6r3	\N	\N	\N	\N	\N	str
3594	2024-07-21 12:56:05.92+00	2024-07-21 12:56:05.92+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-4wyf	\N	\N	\N	\N	\N	str
3595	2024-07-21 12:56:05.925+00	2024-07-21 12:56:05.925+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-pw20	\N	\N	\N	\N	\N	str
3596	2024-07-21 12:56:05.929+00	2024-07-21 12:56:05.929+00	f	\N	\N	LICENCIA	licencia-6hh2	\N	\N	\N	\N	\N	str
3597	2024-07-21 12:56:05.938+00	2024-07-21 12:56:05.938+00	f	\N	\N	Institución	institucion-oix0	\N	\N	\N	\N	\N	str
3598	2024-07-21 12:56:05.943+00	2024-07-21 12:56:05.943+00	f	\N	\N	Descripción	descripcion-gx87	\N	\N	\N	\N	\N	str
3599	2024-07-21 12:56:05.949+00	2024-07-21 12:56:05.949+00	f	\N	\N	Nombre del campo	nombre-del-campo-x2ga	\N	\N	\N	\N	\N	str
3600	2024-07-21 12:56:05.955+00	2024-07-21 12:56:05.955+00	f	\N	\N	Código	codigo-qap7	\N	\N	\N	\N	\N	str
3601	2024-07-21 12:56:05.961+00	2024-07-21 12:56:05.961+00	f	\N	\N	Fecha de Presentación	fecha-de-presentacion-3zr8	\N	\N	\N	\N	\N	str
3602	2024-07-21 12:56:05.968+00	2024-07-21 12:56:05.968+00	f	\N	\N	Tipo	tipo-1vde	\N	\N	\N	\N	\N	str
3603	2024-07-21 12:56:05.973+00	2024-07-21 12:56:05.973+00	f	\N	\N	Proyecto, enmienda o reforma constitucional	proyecto-enmienda-o-reforma-constitucional-57rz	\N	\N	\N	\N	\N	str
3604	2024-07-21 12:56:05.977+00	2024-07-21 12:56:05.977+00	f	\N	\N	Proponente(s)	proponentes-aepy	\N	\N	\N	\N	\N	str
3605	2024-07-21 12:56:05.982+00	2024-07-21 12:56:05.982+00	f	\N	\N	Comisión	comision-s5si	\N	\N	\N	\N	\N	str
3606	2024-07-21 12:56:05.987+00	2024-07-21 12:56:05.987+00	f	\N	\N	Estado	estado-djpt	\N	\N	\N	\N	\N	str
3607	2024-07-21 12:56:05.992+00	2024-07-21 12:56:05.992+00	f	\N	\N	Enlace a proyecto de ley, documentos e informes	enlace-a-proyecto-de-ley-documentos-e-informes-pip3	\N	\N	\N	\N	\N	str
3608	2024-07-21 12:56:06.003+00	2024-07-21 12:56:06.003+00	f	\N	\N	Código	codigo-mwyu	\N	\N	\N	\N	\N	str
3609	2024-07-21 12:56:06.009+00	2024-07-21 12:56:06.009+00	f	\N	\N	Tipo	tipo-zogw	\N	\N	\N	\N	\N	str
3610	2024-07-21 12:56:06.015+00	2024-07-21 12:56:06.015+00	f	\N	\N	Concesionario o Empresa	concesionario-o-empresa-tkqg	\N	\N	\N	\N	\N	str
3611	2024-07-21 12:56:06.021+00	2024-07-21 12:56:06.021+00	f	\N	\N	Fase	fase-ys80	\N	\N	\N	\N	\N	str
3612	2024-07-21 12:56:06.027+00	2024-07-21 12:56:06.027+00	f	\N	\N	Recurso	recurso-c1us	\N	\N	\N	\N	\N	str
3613	2024-07-21 12:56:06.033+00	2024-07-21 12:56:06.033+00	f	\N	\N	Forma o Método	forma-o-metodo-5k6b	\N	\N	\N	\N	\N	str
3614	2024-07-21 12:56:06.039+00	2024-07-21 12:56:06.039+00	f	\N	\N	Estado	estado-nqmf	\N	\N	\N	\N	\N	str
3615	2024-07-21 12:56:06.045+00	2024-07-21 12:56:06.045+00	f	\N	\N	Fecha de Otorgamiento	fecha-de-otorgamiento-0lsv	\N	\N	\N	\N	\N	str
3616	2024-07-21 12:56:06.052+00	2024-07-21 12:56:06.052+00	f	\N	\N	Monto de Concesión o Contrato	monto-de-concesion-o-contrato-pynt	\N	\N	\N	\N	\N	str
3617	2024-07-21 12:56:06.059+00	2024-07-21 12:56:06.059+00	f	\N	\N	Superficie	superficie-2bgb	\N	\N	\N	\N	\N	str
3618	2024-07-21 12:56:06.066+00	2024-07-21 12:56:06.066+00	f	\N	\N	Plazo	plazo-6qw0	\N	\N	\N	\N	\N	str
3619	2024-07-21 12:56:06.071+00	2024-07-21 12:56:06.071+00	f	\N	\N	Destino de Recursos	destino-de-recursos-r6z4	\N	\N	\N	\N	\N	str
3620	2024-07-21 12:56:06.076+00	2024-07-21 12:56:06.076+00	f	\N	\N	Provincia	provincia-6fno	\N	\N	\N	\N	\N	str
3621	2024-07-21 12:56:06.081+00	2024-07-21 12:56:06.081+00	f	\N	\N	Cantón	canton-lzm8	\N	\N	\N	\N	\N	str
3622	2024-07-21 12:56:06.086+00	2024-07-21 12:56:06.086+00	f	\N	\N	Parroquia	parroquia-sn3m	\N	\N	\N	\N	\N	str
3623	2024-07-21 12:56:06.094+00	2024-07-21 12:56:06.094+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-6u0r	\N	\N	\N	\N	\N	str
3624	2024-07-21 12:56:06.1+00	2024-07-21 12:56:06.1+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-qkme	\N	\N	\N	\N	\N	str
3625	2024-07-21 12:56:06.105+00	2024-07-21 12:56:06.105+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-fhw6	\N	\N	\N	\N	\N	str
3626	2024-07-21 12:56:06.111+00	2024-07-21 12:56:06.111+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-xg2s	\N	\N	\N	\N	\N	str
3627	2024-07-21 12:56:06.117+00	2024-07-21 12:56:06.117+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-iagp	\N	\N	\N	\N	\N	str
3628	2024-07-21 12:56:06.121+00	2024-07-21 12:56:06.121+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-ixrs	\N	\N	\N	\N	\N	str
3629	2024-07-21 12:56:06.126+00	2024-07-21 12:56:06.126+00	f	\N	\N	LICENCIA	licencia-lw9l	\N	\N	\N	\N	\N	str
3630	2024-07-21 12:56:06.135+00	2024-07-21 12:56:06.135+00	f	\N	\N	Institución	institucion-wzsz	\N	\N	\N	\N	\N	str
3631	2024-07-21 12:56:06.139+00	2024-07-21 12:56:06.139+00	f	\N	\N	Descripción	descripcion-zcm6	\N	\N	\N	\N	\N	str
3632	2024-07-21 12:56:06.144+00	2024-07-21 12:56:06.144+00	f	\N	\N	Nombre del campo	nombre-del-campo-z7j4	\N	\N	\N	\N	\N	str
3633	2024-07-21 12:56:06.15+00	2024-07-21 12:56:06.15+00	f	\N	\N	Código	codigo-liel	\N	\N	\N	\N	\N	str
3634	2024-07-21 12:56:06.155+00	2024-07-21 12:56:06.155+00	f	\N	\N	Tipo	tipo-wfa7	\N	\N	\N	\N	\N	str
3635	2024-07-21 12:56:06.16+00	2024-07-21 12:56:06.16+00	f	\N	\N	Concesionario o Empresa	concesionario-o-empresa-6yhk	\N	\N	\N	\N	\N	str
3636	2024-07-21 12:56:06.165+00	2024-07-21 12:56:06.165+00	f	\N	\N	Fase	fase-ykff	\N	\N	\N	\N	\N	str
3637	2024-07-21 12:56:06.171+00	2024-07-21 12:56:06.171+00	f	\N	\N	Recurso	recurso-s13j	\N	\N	\N	\N	\N	str
3638	2024-07-21 12:56:06.176+00	2024-07-21 12:56:06.176+00	f	\N	\N	Forma o Método	forma-o-metodo-9ihh	\N	\N	\N	\N	\N	str
3639	2024-07-21 12:56:06.181+00	2024-07-21 12:56:06.181+00	f	\N	\N	Estado	estado-1ohz	\N	\N	\N	\N	\N	str
3640	2024-07-21 12:56:06.186+00	2024-07-21 12:56:06.186+00	f	\N	\N	Fecha de Otorgamiento	fecha-de-otorgamiento-0ejd	\N	\N	\N	\N	\N	str
3641	2024-07-21 12:56:06.191+00	2024-07-21 12:56:06.191+00	f	\N	\N	Monto de Concesión o Contrato	monto-de-concesion-o-contrato-jiij	\N	\N	\N	\N	\N	str
3642	2024-07-21 12:56:06.196+00	2024-07-21 12:56:06.196+00	f	\N	\N	Superficie	superficie-rgav	\N	\N	\N	\N	\N	str
3643	2024-07-21 12:56:06.201+00	2024-07-21 12:56:06.201+00	f	\N	\N	Plazo	plazo-1a17	\N	\N	\N	\N	\N	str
3644	2024-07-21 12:56:06.206+00	2024-07-21 12:56:06.206+00	f	\N	\N	Destino de Recursos	destino-de-recursos-vaz5	\N	\N	\N	\N	\N	str
3645	2024-07-21 12:56:06.21+00	2024-07-21 12:56:06.21+00	f	\N	\N	Provincia	provincia-mq6s	\N	\N	\N	\N	\N	str
3646	2024-07-21 12:56:06.215+00	2024-07-21 12:56:06.215+00	f	\N	\N	Cantón	canton-mak9	\N	\N	\N	\N	\N	str
3647	2024-07-21 12:56:06.221+00	2024-07-21 12:56:06.221+00	f	\N	\N	Parroquia	parroquia-2v6p	\N	\N	\N	\N	\N	str
3648	2024-07-21 12:56:06.229+00	2024-07-21 12:56:06.229+00	f	\N	\N	Nombre de Empresa Pública	nombre-de-empresa-publica-jmae	\N	\N	\N	\N	\N	str
3649	2024-07-21 12:56:06.235+00	2024-07-21 12:56:06.235+00	f	\N	\N	Fecha	fecha-i9uj	\N	\N	\N	\N	\N	str
3650	2024-07-21 12:56:06.24+00	2024-07-21 12:56:06.24+00	f	\N	\N	Nombre de Informe	nombre-de-informe-ts4x	\N	\N	\N	\N	\N	str
3651	2024-07-21 12:56:06.245+00	2024-07-21 12:56:06.245+00	f	\N	\N	Enlace a Informe	enlace-a-informe-kl4n	\N	\N	\N	\N	\N	str
3652	2024-07-21 12:56:06.254+00	2024-07-21 12:56:06.254+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-muez	\N	\N	\N	\N	\N	str
3653	2024-07-21 12:56:06.259+00	2024-07-21 12:56:06.259+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-ag2v	\N	\N	\N	\N	\N	str
3654	2024-07-21 12:56:06.264+00	2024-07-21 12:56:06.264+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-g08q	\N	\N	\N	\N	\N	str
3655	2024-07-21 12:56:06.269+00	2024-07-21 12:56:06.269+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-z1c0	\N	\N	\N	\N	\N	str
3656	2024-07-21 12:56:06.274+00	2024-07-21 12:56:06.274+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-tdvt	\N	\N	\N	\N	\N	str
3657	2024-07-21 12:56:06.28+00	2024-07-21 12:56:06.28+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-hqgo	\N	\N	\N	\N	\N	str
3658	2024-07-21 12:56:06.286+00	2024-07-21 12:56:06.286+00	f	\N	\N	LICENCIA	licencia-jygj	\N	\N	\N	\N	\N	str
3659	2024-07-21 12:56:06.294+00	2024-07-21 12:56:06.294+00	f	\N	\N	Institución	institucion-i4cb	\N	\N	\N	\N	\N	str
3660	2024-07-21 12:56:06.301+00	2024-07-21 12:56:06.301+00	f	\N	\N	Descripción	descripcion-hb2q	\N	\N	\N	\N	\N	str
3661	2024-07-21 12:56:06.306+00	2024-07-21 12:56:06.306+00	f	\N	\N	Nombre del campo	nombre-del-campo-8ey3	\N	\N	\N	\N	\N	str
3662	2024-07-21 12:56:06.311+00	2024-07-21 12:56:06.311+00	f	\N	\N	Nombre de Empresa Pública	nombre-de-empresa-publica-6zhm	\N	\N	\N	\N	\N	str
3663	2024-07-21 12:56:06.317+00	2024-07-21 12:56:06.317+00	f	\N	\N	Fecha	fecha-apvc	\N	\N	\N	\N	\N	str
3664	2024-07-21 12:56:06.322+00	2024-07-21 12:56:06.322+00	f	\N	\N	Nombre de Informe	nombre-de-informe-5mvj	\N	\N	\N	\N	\N	str
3665	2024-07-21 12:56:06.327+00	2024-07-21 12:56:06.327+00	f	\N	\N	Enlace a Informe	enlace-a-informe-7vv7	\N	\N	\N	\N	\N	str
3666	2024-07-21 12:56:06.339+00	2024-07-21 12:56:06.339+00	f	\N	\N	Tipo de Contrato	tipo-de-contrato-f56d	\N	\N	\N	\N	\N	str
3667	2024-07-21 12:56:06.345+00	2024-07-21 12:56:06.345+00	f	\N	\N	Objeto 	objeto-4v5r	\N	\N	\N	\N	\N	str
3668	2024-07-21 12:56:06.351+00	2024-07-21 12:56:06.351+00	f	\N	\N	Fecha de suscripción o renovación	fecha-de-suscripcion-o-renovacion-beyk	\N	\N	\N	\N	\N	str
3669	2024-07-21 12:56:06.357+00	2024-07-21 12:56:06.357+00	f	\N	\N	Nombre Deudor	nombre-deudor-k0hk	\N	\N	\N	\N	\N	str
3670	2024-07-21 12:56:06.363+00	2024-07-21 12:56:06.363+00	f	\N	\N	Nombre Acreedor	nombre-acreedor-nroe	\N	\N	\N	\N	\N	str
3671	2024-07-21 12:56:06.368+00	2024-07-21 12:56:06.368+00	f	\N	\N	Nombre Ejecutor	nombre-ejecutor-w1sv	\N	\N	\N	\N	\N	str
3672	2024-07-21 12:56:06.373+00	2024-07-21 12:56:06.373+00	f	\N	\N	Tasa de Interés - %	tasa-de-interes-knbf	\N	\N	\N	\N	\N	str
3673	2024-07-21 12:56:06.381+00	2024-07-21 12:56:06.381+00	f	\N	\N	Plazo	plazo-13hi	\N	\N	\N	\N	\N	str
3674	2024-07-21 12:56:06.387+00	2024-07-21 12:56:06.387+00	f	\N	\N	Fondos con los que se cancelará la obligación crediticia	fondos-con-los-que-se-cancelara-la-obligacion-crediticia-q1kt	\N	\N	\N	\N	\N	str
3675	2024-07-21 12:56:06.392+00	2024-07-21 12:56:06.392+00	f	\N	\N	Enlace para descargar el contrato de crédito externo o interno	enlace-para-descargar-el-contrato-de-credito-externo-o-interno-6jrn	\N	\N	\N	\N	\N	str
3676	2024-07-21 12:56:06.398+00	2024-07-21 12:56:06.398+00	f	\N	\N	Monto del préstamo o contrato	monto-del-prestamo-o-contrato-upip	\N	\N	\N	\N	\N	str
3677	2024-07-21 12:56:06.405+00	2024-07-21 12:56:06.405+00	f	\N	\N	Desembolsos efectuados	desembolsos-efectuados-vjrx	\N	\N	\N	\N	\N	str
3678	2024-07-21 12:56:06.41+00	2024-07-21 12:56:06.41+00	f	\N	\N	Desembolsos por efectuar	desembolsos-por-efectuar-rzhl	\N	\N	\N	\N	\N	str
3679	2024-07-21 12:56:06.419+00	2024-07-21 12:56:06.419+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN	fecha-actualizacion-de-la-informacion-ejqw	\N	\N	\N	\N	\N	str
3680	2024-07-21 12:56:06.426+00	2024-07-21 12:56:06.426+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN	periodicidad-de-actualizacion-de-la-informacion-ldbz	\N	\N	\N	\N	\N	str
3681	2024-07-21 12:56:06.432+00	2024-07-21 12:56:06.432+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN	unidad-poseedora-de-la-informacion-raxd	\N	\N	\N	\N	\N	str
3682	2024-07-21 12:56:06.439+00	2024-07-21 12:56:06.439+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	persona-responsable-de-la-unidad-poseedora-de-la-informacion-412c	\N	\N	\N	\N	\N	str
3683	2024-07-21 12:56:06.445+00	2024-07-21 12:56:06.445+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-usn3	\N	\N	\N	\N	\N	str
3684	2024-07-21 12:56:06.451+00	2024-07-21 12:56:06.451+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-8q6t	\N	\N	\N	\N	\N	str
3685	2024-07-21 12:56:06.457+00	2024-07-21 12:56:06.457+00	f	\N	\N	LICENCIA	licencia-rs91	\N	\N	\N	\N	\N	str
3686	2024-07-21 12:56:06.466+00	2024-07-21 12:56:06.466+00	f	\N	\N	Institución	institucion-uu18	\N	\N	\N	\N	\N	str
3687	2024-07-21 12:56:06.471+00	2024-07-21 12:56:06.471+00	f	\N	\N	Descripción	descripcion-q1ok	\N	\N	\N	\N	\N	str
3688	2024-07-21 12:56:06.477+00	2024-07-21 12:56:06.477+00	f	\N	\N	Nombre del campo	nombre-del-campo-u157	\N	\N	\N	\N	\N	str
3689	2024-07-21 12:56:06.482+00	2024-07-21 12:56:06.482+00	f	\N	\N	Tipo de Contrato	tipo-de-contrato-m1gc	\N	\N	\N	\N	\N	str
3690	2024-07-21 12:56:06.488+00	2024-07-21 12:56:06.488+00	f	\N	\N	Objeto 	objeto-pq77	\N	\N	\N	\N	\N	str
3691	2024-07-21 12:56:06.493+00	2024-07-21 12:56:06.493+00	f	\N	\N	Fecha de suscripción o renovación	fecha-de-suscripcion-o-renovacion-pzz6	\N	\N	\N	\N	\N	str
3692	2024-07-21 12:56:06.499+00	2024-07-21 12:56:06.499+00	f	\N	\N	Nombre del deudor	nombre-del-deudor-4gti	\N	\N	\N	\N	\N	str
3693	2024-07-21 12:56:06.505+00	2024-07-21 12:56:06.505+00	f	\N	\N	Nombre del acreedor	nombre-del-acreedor-nfcu	\N	\N	\N	\N	\N	str
3694	2024-07-21 12:56:06.51+00	2024-07-21 12:56:06.51+00	f	\N	\N	Nombre del ejecutor	nombre-del-ejecutor-06c3	\N	\N	\N	\N	\N	str
3695	2024-07-21 12:56:06.517+00	2024-07-21 12:56:06.517+00	f	\N	\N	Tasa de Interés - %	tasa-de-interes-vxdo	\N	\N	\N	\N	\N	str
3696	2024-07-21 12:56:06.522+00	2024-07-21 12:56:06.522+00	f	\N	\N	Plazo	plazo-hcc7	\N	\N	\N	\N	\N	str
3697	2024-07-21 12:56:06.527+00	2024-07-21 12:56:06.527+00	f	\N	\N	Fondos con los que se cancelará la obligación crediticia	fondos-con-los-que-se-cancelara-la-obligacion-crediticia-v8ty	\N	\N	\N	\N	\N	str
3698	2024-07-21 12:56:06.533+00	2024-07-21 12:56:06.533+00	f	\N	\N	Enlace para descargar el contrato de crédito externo o interno	enlace-para-descargar-el-contrato-de-credito-externo-o-interno-wv8q	\N	\N	\N	\N	\N	str
3699	2024-07-21 12:56:06.539+00	2024-07-21 12:56:06.539+00	f	\N	\N	Monto del préstamo o contrato	monto-del-prestamo-o-contrato-jp72	\N	\N	\N	\N	\N	str
3700	2024-07-21 12:56:06.544+00	2024-07-21 12:56:06.544+00	f	\N	\N	Desembolsos efectuados	desembolsos-efectuados-c1h5	\N	\N	\N	\N	\N	str
3701	2024-07-21 12:56:06.551+00	2024-07-21 12:56:06.551+00	f	\N	\N	Desembolsos por efectuar	desembolsos-por-efectuar-1cjw	\N	\N	\N	\N	\N	str
3702	2024-07-21 12:56:06.561+00	2024-07-21 12:56:06.561+00	f	\N	\N	FECHA DE PUBLICACIÓN	fecha-de-publicacion-4vaz	\N	\N	\N	\N	\N	str
3703	2024-07-21 12:56:06.567+00	2024-07-21 12:56:06.567+00	f	\N	\N	CÓDIGO DEL PROCESO	codigo-del-proceso-4fov	\N	\N	\N	\N	\N	str
3704	2024-07-21 12:56:06.573+00	2024-07-21 12:56:06.573+00	f	\N	\N	TIPO DE PROCESO	tipo-de-proceso-6rl1	\N	\N	\N	\N	\N	str
3705	2024-07-21 12:56:06.578+00	2024-07-21 12:56:06.578+00	f	\N	\N	OBJETO DEL PROCESO	objeto-del-proceso-scuf	\N	\N	\N	\N	\N	str
3706	2024-07-21 12:56:06.583+00	2024-07-21 12:56:06.583+00	f	\N	\N	PRESUPUESTO REFERENCIAL - USD	presupuesto-referencial-usd-l7cl	\N	\N	\N	\N	\N	str
3707	2024-07-21 12:56:06.589+00	2024-07-21 12:56:06.589+00	f	\N	\N	PARTIDA PRESUPUESTARIA	partida-presupuestaria-5x62	\N	\N	\N	\N	\N	str
3708	2024-07-21 12:56:06.594+00	2024-07-21 12:56:06.594+00	f	\N	\N	MONTO DE LA ADJUDICACIÓN - USD	monto-de-la-adjudicacion-usd-qwb4	\N	\N	\N	\N	\N	str
3709	2024-07-21 12:56:06.6+00	2024-07-21 12:56:06.6+00	f	\N	\N	ETAPA DE LA CONTRATACIÓN	etapa-de-la-contratacion-4gw2	\N	\N	\N	\N	\N	str
3710	2024-07-21 12:56:06.606+00	2024-07-21 12:56:06.606+00	f	\N	\N	IDENTIFICACIÓN DEL CONTRATISTA	identificacion-del-contratista-8o8d	\N	\N	\N	\N	\N	str
3711	2024-07-21 12:56:06.612+00	2024-07-21 12:56:06.612+00	f	\N	\N	LINK PARA DESCARGAR EL PROCESO DE CONTRATACIÓN DESDE EL PORTAL DE COMPRAS PÚBLICAS	link-para-descargar-el-proceso-de-contratacion-desde-el-portal-de-compras-publicas-i5b4	\N	\N	\N	\N	\N	str
3712	2024-07-21 12:56:06.621+00	2024-07-21 12:56:06.621+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-npky	\N	\N	\N	\N	\N	str
3713	2024-07-21 12:56:06.626+00	2024-07-21 12:56:06.626+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-tamf	\N	\N	\N	\N	\N	str
3714	2024-07-21 12:56:06.632+00	2024-07-21 12:56:06.632+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-osmt	\N	\N	\N	\N	\N	str
3715	2024-07-21 12:56:06.638+00	2024-07-21 12:56:06.638+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-uk39	\N	\N	\N	\N	\N	str
3716	2024-07-21 12:56:06.644+00	2024-07-21 12:56:06.644+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-qmp0	\N	\N	\N	\N	\N	str
3717	2024-07-21 12:56:06.65+00	2024-07-21 12:56:06.65+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-djnt	\N	\N	\N	\N	\N	str
3718	2024-07-21 12:56:06.655+00	2024-07-21 12:56:06.655+00	f	\N	\N	Enlace para la búsqueda de procesos de contratación desde el Sistema Oficial de Contratación Pública	enlace-para-la-busqueda-de-procesos-de-contratacion-desde-el-sistema-oficial-de-contratacion-publica-ol0s	\N	\N	\N	\N	\N	str
3719	2024-07-21 12:56:06.661+00	2024-07-21 12:56:06.661+00	f	\N	\N	LICENCIA 	licencia-bvt8	\N	\N	\N	\N	\N	str
3720	2024-07-21 12:56:06.669+00	2024-07-21 12:56:06.669+00	f	\N	\N	Institución	institucion-2sx9	\N	\N	\N	\N	\N	str
3721	2024-07-21 12:56:06.675+00	2024-07-21 12:56:06.675+00	f	\N	\N	Descripción	descripcion-jwl9	\N	\N	\N	\N	\N	str
3722	2024-07-21 12:56:06.682+00	2024-07-21 12:56:06.682+00	f	\N	\N	Nombre del campo	nombre-del-campo-vs4t	\N	\N	\N	\N	\N	str
3723	2024-07-21 12:56:06.688+00	2024-07-21 12:56:06.688+00	f	\N	\N	Fecha de publicación	fecha-de-publicacion-kib5	\N	\N	\N	\N	\N	str
3724	2024-07-21 12:56:06.694+00	2024-07-21 12:56:06.694+00	f	\N	\N	Código del proceso	codigo-del-proceso-xfk1	\N	\N	\N	\N	\N	str
3725	2024-07-21 12:56:06.701+00	2024-07-21 12:56:06.701+00	f	\N	\N	Tipo de proceso	tipo-de-proceso-tdoi	\N	\N	\N	\N	\N	str
3726	2024-07-21 12:56:06.707+00	2024-07-21 12:56:06.707+00	f	\N	\N	Objeto del proceso	objeto-del-proceso-gobb	\N	\N	\N	\N	\N	str
3727	2024-07-21 12:56:06.714+00	2024-07-21 12:56:06.714+00	f	\N	\N	Presupuesto referencial - USD	presupuesto-referencial-usd-pro8	\N	\N	\N	\N	\N	str
3728	2024-07-21 12:56:06.722+00	2024-07-21 12:56:06.722+00	f	\N	\N	Partida presupuestaria	partida-presupuestaria-dnw5	\N	\N	\N	\N	\N	str
3729	2024-07-21 12:56:06.73+00	2024-07-21 12:56:06.73+00	f	\N	\N	Monto de la adjudicación - USD	monto-de-la-adjudicacion-usd-24bq	\N	\N	\N	\N	\N	str
3730	2024-07-21 12:56:06.738+00	2024-07-21 12:56:06.738+00	f	\N	\N	Etapa de la contratación	etapa-de-la-contratacion-icoz	\N	\N	\N	\N	\N	str
3731	2024-07-21 12:56:06.745+00	2024-07-21 12:56:06.745+00	f	\N	\N	Identificación del contratista	identificacion-del-contratista-4yo8	\N	\N	\N	\N	\N	str
3732	2024-07-21 12:56:06.753+00	2024-07-21 12:56:06.753+00	f	\N	\N	Link para descargar el proceso de contratación desde el portal de comprass públicas	link-para-descargar-el-proceso-de-contratacion-desde-el-portal-de-comprass-publicas-g33g	\N	\N	\N	\N	\N	str
3733	2024-07-21 12:56:06.769+00	2024-07-21 12:56:06.769+00	f	\N	\N	Grupo específico	grupo-especifico-w8qz	\N	\N	\N	\N	\N	str
3734	2024-07-21 12:56:06.776+00	2024-07-21 12:56:06.776+00	f	\N	\N	Nombre de política pública	nombre-de-politica-publica-9eo6	\N	\N	\N	\N	\N	str
3735	2024-07-21 12:56:06.783+00	2024-07-21 12:56:06.783+00	f	\N	\N	Fase	fase-h8sn	\N	\N	\N	\N	\N	str
3736	2024-07-21 12:56:06.791+00	2024-07-21 12:56:06.791+00	f	\N	\N	Fecha	fecha-881j	\N	\N	\N	\N	\N	str
3737	2024-07-21 12:56:06.799+00	2024-07-21 12:56:06.799+00	f	\N	\N	Enlace a informe	enlace-a-informe-vgle	\N	\N	\N	\N	\N	str
3738	2024-07-21 12:56:06.811+00	2024-07-21 12:56:06.811+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN	fecha-actualizacion-de-la-informacion-e65v	\N	\N	\N	\N	\N	str
3739	2024-07-21 12:56:06.819+00	2024-07-21 12:56:06.819+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN	periodicidad-de-actualizacion-de-la-informacion-coq3	\N	\N	\N	\N	\N	str
3740	2024-07-21 12:56:06.828+00	2024-07-21 12:56:06.829+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN	unidad-poseedora-de-la-informacion-p0hr	\N	\N	\N	\N	\N	str
3741	2024-07-21 12:56:06.837+00	2024-07-21 12:56:06.837+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	persona-responsable-de-la-unidad-poseedora-de-la-informacion-kwba	\N	\N	\N	\N	\N	str
3858	2024-07-21 12:56:07.575+00	2024-07-21 12:56:07.575+00	f	\N	\N	Período	periodo-9pbs	\N	\N	\N	\N	\N	str
3859	2024-07-21 12:56:07.58+00	2024-07-21 12:56:07.58+00	f	\N	\N	Enlace	enlace-puvu	\N	\N	\N	\N	\N	str
3742	2024-07-21 12:56:06.845+00	2024-07-21 12:56:06.845+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-17kh	\N	\N	\N	\N	\N	str
3743	2024-07-21 12:56:06.853+00	2024-07-21 12:56:06.853+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-g87h	\N	\N	\N	\N	\N	str
3744	2024-07-21 12:56:06.861+00	2024-07-21 12:56:06.861+00	f	\N	\N	LICENCIA	licencia-ap95	\N	\N	\N	\N	\N	str
3745	2024-07-21 12:56:06.869+00	2024-07-21 12:56:06.869+00	f	\N	\N	ENLACE PARA DESCARGAR LAS ACCCIONES Y BUENAS PRÁCTICAS DE ACTORES SOCIALES E INTERINSTITUCIONALES QUE VIGILAN EL CUMPLIMIENTO DE LA POLÍTICA PÚBLICA	enlace-para-descargar-las-accciones-y-buenas-practicas-de-actores-sociales-e-interinstitucionales-que-vigilan-el-cumplimiento-de-la-politica-publica-d6uh	\N	\N	\N	\N	\N	str
3746	2024-07-21 12:56:06.879+00	2024-07-21 12:56:06.879+00	f	\N	\N	Institución	institucion-cdgl	\N	\N	\N	\N	\N	str
3747	2024-07-21 12:56:06.885+00	2024-07-21 12:56:06.885+00	f	\N	\N	Descripción	descripcion-87z9	\N	\N	\N	\N	\N	str
3748	2024-07-21 12:56:06.891+00	2024-07-21 12:56:06.891+00	f	\N	\N	Nombre del campo	nombre-del-campo-3qaq	\N	\N	\N	\N	\N	str
3749	2024-07-21 12:56:06.897+00	2024-07-21 12:56:06.897+00	f	\N	\N	Grupo específico	grupo-especifico-7n4i	\N	\N	\N	\N	\N	str
3750	2024-07-21 12:56:06.903+00	2024-07-21 12:56:06.903+00	f	\N	\N	Nombre de política pública	nombre-de-politica-publica-mimc	\N	\N	\N	\N	\N	str
3751	2024-07-21 12:56:06.909+00	2024-07-21 12:56:06.909+00	f	\N	\N	Fase	fase-mfos	\N	\N	\N	\N	\N	str
3752	2024-07-21 12:56:06.914+00	2024-07-21 12:56:06.914+00	f	\N	\N	Fecha	fecha-rmch	\N	\N	\N	\N	\N	str
3753	2024-07-21 12:56:06.92+00	2024-07-21 12:56:06.92+00	f	\N	\N	Enlace a informe	enlace-a-informe-xpmm	\N	\N	\N	\N	\N	str
3754	2024-07-21 12:56:06.93+00	2024-07-21 12:56:06.93+00	f	\N	\N	Unidad	unidad-okv2	\N	\N	\N	\N	\N	str
3755	2024-07-21 12:56:06.936+00	2024-07-21 12:56:06.936+00	f	\N	\N	Objetivo	objetivo-hv6t	\N	\N	\N	\N	\N	str
3756	2024-07-21 12:56:06.941+00	2024-07-21 12:56:06.941+00	f	\N	\N	Indicador	indicador-lpl1	\N	\N	\N	\N	\N	str
3757	2024-07-21 12:56:06.947+00	2024-07-21 12:56:06.947+00	f	\N	\N	Meta cuantificable	meta-cuantificable-ye87	\N	\N	\N	\N	\N	str
3758	2024-07-21 12:56:06.953+00	2024-07-21 12:56:06.953+00	f	\N	\N	Enlace al sistema de gestión de planificación para verificación de los indicadores y metas cuantificables 	enlace-al-sistema-de-gestion-de-planificacion-para-verificacion-de-los-indicadores-y-metas-cuantificables-zys0	\N	\N	\N	\N	\N	str
3759	2024-07-21 12:56:06.962+00	2024-07-21 12:56:06.962+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-2vyq	\N	\N	\N	\N	\N	str
3760	2024-07-21 12:56:06.967+00	2024-07-21 12:56:06.967+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-k765	\N	\N	\N	\N	\N	str
3761	2024-07-21 12:56:06.973+00	2024-07-21 12:56:06.973+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-kp8c	\N	\N	\N	\N	\N	str
3762	2024-07-21 12:56:06.978+00	2024-07-21 12:56:06.978+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-wzu9	\N	\N	\N	\N	\N	str
3763	2024-07-21 12:56:06.983+00	2024-07-21 12:56:06.983+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-gf96	\N	\N	\N	\N	\N	str
3764	2024-07-21 12:56:06.988+00	2024-07-21 12:56:06.988+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-0qnn	\N	\N	\N	\N	\N	str
3765	2024-07-21 12:56:06.993+00	2024-07-21 12:56:06.993+00	f	\N	\N	LICENCIA	licencia-ejxk	\N	\N	\N	\N	\N	str
3766	2024-07-21 12:56:07.002+00	2024-07-21 12:56:07.002+00	f	\N	\N	Institución	institucion-k6bp	\N	\N	\N	\N	\N	str
3767	2024-07-21 12:56:07.007+00	2024-07-21 12:56:07.007+00	f	\N	\N	Descripción	descripcion-bud1	\N	\N	\N	\N	\N	str
3768	2024-07-21 12:56:07.012+00	2024-07-21 12:56:07.012+00	f	\N	\N	Nombre del campo	nombre-del-campo-h1th	\N	\N	\N	\N	\N	str
3769	2024-07-21 12:56:07.018+00	2024-07-21 12:56:07.018+00	f	\N	\N	Unidad	unidad-2l42	\N	\N	\N	\N	\N	str
3770	2024-07-21 12:56:07.022+00	2024-07-21 12:56:07.022+00	f	\N	\N	Objetivo	objetivo-0ocl	\N	\N	\N	\N	\N	str
3771	2024-07-21 12:56:07.028+00	2024-07-21 12:56:07.028+00	f	\N	\N	Indicador	indicador-kw8n	\N	\N	\N	\N	\N	str
3772	2024-07-21 12:56:07.034+00	2024-07-21 12:56:07.034+00	f	\N	\N	Meta cuantificable	meta-cuantificable-9hys	\N	\N	\N	\N	\N	str
3773	2024-07-21 12:56:07.041+00	2024-07-21 12:56:07.041+00	f	\N	\N	Enlace al sistema de gestión de planificación para verificación de los indicadores y metas cuantificables 	enlace-al-sistema-de-gestion-de-planificacion-para-verificacion-de-los-indicadores-y-metas-cuantificables-860r	\N	\N	\N	\N	\N	str
3774	2024-07-21 12:56:07.052+00	2024-07-21 12:56:07.052+00	f	\N	\N	Nombre del Plan o Programa	nombre-del-plan-o-programa-wgxm	\N	\N	\N	\N	\N	str
3775	2024-07-21 12:56:07.056+00	2024-07-21 12:56:07.056+00	f	\N	\N	Período	periodo-5jiv	\N	\N	\N	\N	\N	str
3776	2024-07-21 12:56:07.061+00	2024-07-21 12:56:07.061+00	f	\N	\N	Monto	monto-8k2l	\N	\N	\N	\N	\N	str
3777	2024-07-21 12:56:07.067+00	2024-07-21 12:56:07.067+00	f	\N	\N	Enlace al Plan o Programa	enlace-al-plan-o-programa-jh6c	\N	\N	\N	\N	\N	str
3778	2024-07-21 12:56:07.071+00	2024-07-21 12:56:07.071+00	f	\N	\N	Enlace al estado 	enlace-al-estado-es42	\N	\N	\N	\N	\N	str
3779	2024-07-21 12:56:07.08+00	2024-07-21 12:56:07.08+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN	fecha-actualizacion-de-la-informacion-u5qv	\N	\N	\N	\N	\N	str
3780	2024-07-21 12:56:07.087+00	2024-07-21 12:56:07.087+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN	periodicidad-de-actualizacion-de-la-informacion-gotz	\N	\N	\N	\N	\N	str
3781	2024-07-21 12:56:07.092+00	2024-07-21 12:56:07.092+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN	unidad-poseedora-de-la-informacion-su7y	\N	\N	\N	\N	\N	str
3782	2024-07-21 12:56:07.097+00	2024-07-21 12:56:07.097+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	persona-responsable-de-la-unidad-poseedora-de-la-informacion-i6x4	\N	\N	\N	\N	\N	str
3783	2024-07-21 12:56:07.104+00	2024-07-21 12:56:07.104+00	f	\N	\N	CORREO ELECTRÓNICO DEL O LA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	correo-electronico-del-o-la-responsable-de-la-unidad-poseedora-de-la-informacion-43em	\N	\N	\N	\N	\N	str
3784	2024-07-21 12:56:07.11+00	2024-07-21 12:56:07.11+00	f	\N	\N	NÚMERO TELEFÓNICO DEL O LA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	numero-telefonico-del-o-la-responsable-de-la-unidad-poseedora-de-la-informacion-otux	\N	\N	\N	\N	\N	str
3785	2024-07-21 12:56:07.116+00	2024-07-21 12:56:07.116+00	f	\N	\N	LICENCIA	licencia-fyql	\N	\N	\N	\N	\N	str
3786	2024-07-21 12:56:07.126+00	2024-07-21 12:56:07.126+00	f	\N	\N	Institución	institucion-o4uk	\N	\N	\N	\N	\N	str
3787	2024-07-21 12:56:07.132+00	2024-07-21 12:56:07.132+00	f	\N	\N	Descripción	descripcion-fe9k	\N	\N	\N	\N	\N	str
3788	2024-07-21 12:56:07.138+00	2024-07-21 12:56:07.138+00	f	\N	\N	Nombre del campo	nombre-del-campo-yv15	\N	\N	\N	\N	\N	str
3789	2024-07-21 12:56:07.144+00	2024-07-21 12:56:07.144+00	f	\N	\N	Nombre del Plan o Programa	nombre-del-plan-o-programa-wjv9	\N	\N	\N	\N	\N	str
3790	2024-07-21 12:56:07.151+00	2024-07-21 12:56:07.151+00	f	\N	\N	Período	periodo-lhsu	\N	\N	\N	\N	\N	str
3791	2024-07-21 12:56:07.156+00	2024-07-21 12:56:07.157+00	f	\N	\N	Monto	monto-rko6	\N	\N	\N	\N	\N	str
3792	2024-07-21 12:56:07.162+00	2024-07-21 12:56:07.162+00	f	\N	\N	Enlace al Plan o Programa	enlace-al-plan-o-programa-t148	\N	\N	\N	\N	\N	str
3793	2024-07-21 12:56:07.168+00	2024-07-21 12:56:07.168+00	f	\N	\N	Enlace al estado 	enlace-al-estado-v0c4	\N	\N	\N	\N	\N	str
3794	2024-07-21 12:56:07.181+00	2024-07-21 12:56:07.181+00	f	\N	\N	Información relevante	informacion-relevante-z6qt	\N	\N	\N	\N	\N	str
3795	2024-07-21 12:56:07.186+00	2024-07-21 12:56:07.186+00	f	\N	\N	Enlace para descargar	enlace-para-descargar-5gel	\N	\N	\N	\N	\N	str
3796	2024-07-21 12:56:07.196+00	2024-07-21 12:56:07.196+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-98o9	\N	\N	\N	\N	\N	str
3797	2024-07-21 12:56:07.202+00	2024-07-21 12:56:07.202+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-82qk	\N	\N	\N	\N	\N	str
3798	2024-07-21 12:56:07.207+00	2024-07-21 12:56:07.207+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-uucv	\N	\N	\N	\N	\N	str
3860	2024-07-21 12:56:07.59+00	2024-07-21 12:56:07.59+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN	fecha-actualizacion-de-la-informacion-v7jr	\N	\N	\N	\N	\N	str
3799	2024-07-21 12:56:07.214+00	2024-07-21 12:56:07.214+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-97c4	\N	\N	\N	\N	\N	str
3800	2024-07-21 12:56:07.22+00	2024-07-21 12:56:07.22+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-izch	\N	\N	\N	\N	\N	str
3801	2024-07-21 12:56:07.228+00	2024-07-21 12:56:07.228+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-qjqz	\N	\N	\N	\N	\N	str
3802	2024-07-21 12:56:07.237+00	2024-07-21 12:56:07.237+00	f	\N	\N	LICENCIA	licencia-wsts	\N	\N	\N	\N	\N	str
3803	2024-07-21 12:56:07.249+00	2024-07-21 12:56:07.249+00	f	\N	\N	Institución	institucion-odog	\N	\N	\N	\N	\N	str
3804	2024-07-21 12:56:07.254+00	2024-07-21 12:56:07.254+00	f	\N	\N	Descripción	descripcion-c6qf	\N	\N	\N	\N	\N	str
3805	2024-07-21 12:56:07.259+00	2024-07-21 12:56:07.259+00	f	\N	\N	Nombre del campo	nombre-del-campo-ktp9	\N	\N	\N	\N	\N	str
3806	2024-07-21 12:56:07.265+00	2024-07-21 12:56:07.265+00	f	\N	\N	Información relevante	informacion-relevante-5qe2	\N	\N	\N	\N	\N	str
3807	2024-07-21 12:56:07.27+00	2024-07-21 12:56:07.27+00	f	\N	\N	Enlace para descargar	enlace-para-descargar-p60v	\N	\N	\N	\N	\N	str
3808	2024-07-21 12:56:07.279+00	2024-07-21 12:56:07.279+00	f	\N	\N	TIPO	tipo-rxdt	\N	\N	\N	\N	\N	str
3809	2024-07-21 12:56:07.285+00	2024-07-21 12:56:07.285+00	f	\N	\N	DESCRIPCIÓN	descripcion-bjre	\N	\N	\N	\N	\N	str
3810	2024-07-21 12:56:07.29+00	2024-07-21 12:56:07.29+00	f	\N	\N	ENLACE 	enlace-jwo3	\N	\N	\N	\N	\N	str
3811	2024-07-21 12:56:07.298+00	2024-07-21 12:56:07.298+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-ii0y	\N	\N	\N	\N	\N	str
3812	2024-07-21 12:56:07.302+00	2024-07-21 12:56:07.302+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-mfd0	\N	\N	\N	\N	\N	str
3813	2024-07-21 12:56:07.306+00	2024-07-21 12:56:07.306+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-7xmo	\N	\N	\N	\N	\N	str
3814	2024-07-21 12:56:07.311+00	2024-07-21 12:56:07.311+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-znjh	\N	\N	\N	\N	\N	str
3815	2024-07-21 12:56:07.316+00	2024-07-21 12:56:07.316+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-8h6t	\N	\N	\N	\N	\N	str
3816	2024-07-21 12:56:07.321+00	2024-07-21 12:56:07.321+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-mta9	\N	\N	\N	\N	\N	str
3817	2024-07-21 12:56:07.326+00	2024-07-21 12:56:07.326+00	f	\N	\N	LICENCIA	licencia-sa5k	\N	\N	\N	\N	\N	str
3818	2024-07-21 12:56:07.336+00	2024-07-21 12:56:07.336+00	f	\N	\N	Institución	institucion-v0pa	\N	\N	\N	\N	\N	str
3819	2024-07-21 12:56:07.342+00	2024-07-21 12:56:07.342+00	f	\N	\N	Descripción	descripcion-vuas	\N	\N	\N	\N	\N	str
3820	2024-07-21 12:56:07.349+00	2024-07-21 12:56:07.349+00	f	\N	\N	Nombre del campo	nombre-del-campo-7kio	\N	\N	\N	\N	\N	str
3821	2024-07-21 12:56:07.354+00	2024-07-21 12:56:07.354+00	f	\N	\N	Tipo	tipo-yjgw	\N	\N	\N	\N	\N	str
3822	2024-07-21 12:56:07.359+00	2024-07-21 12:56:07.359+00	f	\N	\N	Descripcion	descripcion-nwg4	\N	\N	\N	\N	\N	str
3823	2024-07-21 12:56:07.366+00	2024-07-21 12:56:07.366+00	f	\N	\N	Enlace	enlace-fnaw	\N	\N	\N	\N	\N	str
3824	2024-07-21 12:56:07.376+00	2024-07-21 12:56:07.376+00	f	\N	\N	Apellidos y Nombres	apellidos-y-nombres-u9z9	\N	\N	\N	\N	\N	str
3825	2024-07-21 12:56:07.381+00	2024-07-21 12:56:07.381+00	f	\N	\N	Puesto institucional	puesto-institucional-2iqw	\N	\N	\N	\N	\N	str
3826	2024-07-21 12:56:07.386+00	2024-07-21 12:56:07.386+00	f	\N	\N	Asunto	asunto-0s2x	\N	\N	\N	\N	\N	str
3827	2024-07-21 12:56:07.39+00	2024-07-21 12:56:07.39+00	f	\N	\N	Fecha de la audiencia o reunión	fecha-de-la-audiencia-o-reunion-a4kt	\N	\N	\N	\N	\N	str
3828	2024-07-21 12:56:07.395+00	2024-07-21 12:56:07.395+00	f	\N	\N	Modalidad	modalidad-yb54	\N	\N	\N	\N	\N	str
3829	2024-07-21 12:56:07.401+00	2024-07-21 12:56:07.401+00	f	\N	\N	Lugar	lugar-fn7n	\N	\N	\N	\N	\N	str
3830	2024-07-21 12:56:07.407+00	2024-07-21 12:56:07.407+00	f	\N	\N	Descripción de la audiencia o reunión	descripcion-de-la-audiencia-o-reunion-e8wf	\N	\N	\N	\N	\N	str
3831	2024-07-21 12:56:07.412+00	2024-07-21 12:56:07.412+00	f	\N	\N	Duración	duracion-zyk3	\N	\N	\N	\N	\N	str
3832	2024-07-21 12:56:07.419+00	2024-07-21 12:56:07.419+00	f	\N	\N	Nombre de personas externas	nombre-de-personas-externas-0pqf	\N	\N	\N	\N	\N	str
3833	2024-07-21 12:56:07.424+00	2024-07-21 12:56:07.424+00	f	\N	\N	Institución externa	institucion-externa-biz8	\N	\N	\N	\N	\N	str
3834	2024-07-21 12:56:07.43+00	2024-07-21 12:56:07.43+00	f	\N	\N	Enlace para descargar el registro de asistencia de las personas que participaron en la reunión o audiencia	enlace-para-descargar-el-registro-de-asistencia-de-las-personas-que-participaron-en-la-reunion-o-audiencia-qloh	\N	\N	\N	\N	\N	str
3835	2024-07-21 12:56:07.44+00	2024-07-21 12:56:07.44+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-0d8p	\N	\N	\N	\N	\N	str
3836	2024-07-21 12:56:07.445+00	2024-07-21 12:56:07.445+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-wubq	\N	\N	\N	\N	\N	str
3837	2024-07-21 12:56:07.452+00	2024-07-21 12:56:07.452+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-ptn6	\N	\N	\N	\N	\N	str
3838	2024-07-21 12:56:07.458+00	2024-07-21 12:56:07.458+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-g0ve	\N	\N	\N	\N	\N	str
3839	2024-07-21 12:56:07.466+00	2024-07-21 12:56:07.466+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-vzdu	\N	\N	\N	\N	\N	str
3840	2024-07-21 12:56:07.471+00	2024-07-21 12:56:07.471+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-9wu0	\N	\N	\N	\N	\N	str
3841	2024-07-21 12:56:07.476+00	2024-07-21 12:56:07.476+00	f	\N	\N	LICENCIA	licencia-9y3a	\N	\N	\N	\N	\N	str
3842	2024-07-21 12:56:07.486+00	2024-07-21 12:56:07.486+00	f	\N	\N	Institución	institucion-kyud	\N	\N	\N	\N	\N	str
3843	2024-07-21 12:56:07.49+00	2024-07-21 12:56:07.49+00	f	\N	\N	Descripción	descripcion-klem	\N	\N	\N	\N	\N	str
3844	2024-07-21 12:56:07.495+00	2024-07-21 12:56:07.495+00	f	\N	\N	Nombre del campo	nombre-del-campo-b8z9	\N	\N	\N	\N	\N	str
3845	2024-07-21 12:56:07.502+00	2024-07-21 12:56:07.502+00	f	\N	\N	Apellidos y Nombres	apellidos-y-nombres-xg23	\N	\N	\N	\N	\N	str
3846	2024-07-21 12:56:07.507+00	2024-07-21 12:56:07.507+00	f	\N	\N	Puesto institucional	puesto-institucional-7ws0	\N	\N	\N	\N	\N	str
3847	2024-07-21 12:56:07.511+00	2024-07-21 12:56:07.511+00	f	\N	\N	Asunto	asunto-e2bs	\N	\N	\N	\N	\N	str
3848	2024-07-21 12:56:07.518+00	2024-07-21 12:56:07.518+00	f	\N	\N	Fecha de la audiencia o reunión	fecha-de-la-audiencia-o-reunion-g8ej	\N	\N	\N	\N	\N	str
3849	2024-07-21 12:56:07.522+00	2024-07-21 12:56:07.522+00	f	\N	\N	Modalidad	modalidad-02fe	\N	\N	\N	\N	\N	str
3850	2024-07-21 12:56:07.527+00	2024-07-21 12:56:07.527+00	f	\N	\N	Lugar	lugar-zkyx	\N	\N	\N	\N	\N	str
3851	2024-07-21 12:56:07.534+00	2024-07-21 12:56:07.534+00	f	\N	\N	Descripción de la audiencia o reunión	descripcion-de-la-audiencia-o-reunion-e442	\N	\N	\N	\N	\N	str
3852	2024-07-21 12:56:07.539+00	2024-07-21 12:56:07.539+00	f	\N	\N	Duración de la reunión	duracion-de-la-reunion-97f5	\N	\N	\N	\N	\N	str
3853	2024-07-21 12:56:07.544+00	2024-07-21 12:56:07.544+00	f	\N	\N	Nombre de personas externas	nombre-de-personas-externas-zmr8	\N	\N	\N	\N	\N	str
3854	2024-07-21 12:56:07.551+00	2024-07-21 12:56:07.551+00	f	\N	\N	Institución externa	institucion-externa-dzyr	\N	\N	\N	\N	\N	str
3855	2024-07-21 12:56:07.555+00	2024-07-21 12:56:07.555+00	f	\N	\N	Enlace para descargar el registro de asistencia de las personas que participaron en las reuniones o audiencias	enlace-para-descargar-el-registro-de-asistencia-de-las-personas-que-participaron-en-las-reuniones-o-audiencias-33lh	\N	\N	\N	\N	\N	str
3856	2024-07-21 12:56:07.566+00	2024-07-21 12:56:07.566+00	f	\N	\N	Nombre del mecanismo 	nombre-del-mecanismo-f5h5	\N	\N	\N	\N	\N	str
3857	2024-07-21 12:56:07.571+00	2024-07-21 12:56:07.571+00	f	\N	\N	Número de certificado	numero-de-certificado-xmv5	\N	\N	\N	\N	\N	str
3861	2024-07-21 12:56:07.596+00	2024-07-21 12:56:07.596+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN	periodicidad-de-actualizacion-de-la-informacion-m77h	\N	\N	\N	\N	\N	str
3862	2024-07-21 12:56:07.602+00	2024-07-21 12:56:07.602+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN	unidad-poseedora-de-la-informacion-ojoa	\N	\N	\N	\N	\N	str
3863	2024-07-21 12:56:07.608+00	2024-07-21 12:56:07.608+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	persona-responsable-de-la-unidad-poseedora-de-la-informacion-9hfl	\N	\N	\N	\N	\N	str
3864	2024-07-21 12:56:07.613+00	2024-07-21 12:56:07.614+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-5p8p	\N	\N	\N	\N	\N	str
3865	2024-07-21 12:56:07.62+00	2024-07-21 12:56:07.62+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-tx83	\N	\N	\N	\N	\N	str
3866	2024-07-21 12:56:07.625+00	2024-07-21 12:56:07.625+00	f	\N	\N	LICENCIA	licencia-pje8	\N	\N	\N	\N	\N	str
3867	2024-07-21 12:56:07.631+00	2024-07-21 12:56:07.631+00	f	\N	\N	ENLACE PARA LA DESCARGA DE OTROS MECANISMOS DE RENDICIÓN DE CUENTAS	enlace-para-la-descarga-de-otros-mecanismos-de-rendicion-de-cuentas-9ljh	\N	\N	\N	\N	\N	str
3868	2024-07-21 12:56:07.64+00	2024-07-21 12:56:07.64+00	f	\N	\N	Institución	institucion-xgkk	\N	\N	\N	\N	\N	str
3869	2024-07-21 12:56:07.645+00	2024-07-21 12:56:07.645+00	f	\N	\N	Descripción	descripcion-57g8	\N	\N	\N	\N	\N	str
3870	2024-07-21 12:56:07.651+00	2024-07-21 12:56:07.651+00	f	\N	\N	Nombre del campo	nombre-del-campo-shwq	\N	\N	\N	\N	\N	str
3871	2024-07-21 12:56:07.657+00	2024-07-21 12:56:07.657+00	f	\N	\N	Nombre del mecanismo	nombre-del-mecanismo-g3jg	\N	\N	\N	\N	\N	str
3872	2024-07-21 12:56:07.662+00	2024-07-21 12:56:07.662+00	f	\N	\N	Número de certificado	numero-de-certificado-ihx4	\N	\N	\N	\N	\N	str
3873	2024-07-21 12:56:07.668+00	2024-07-21 12:56:07.668+00	f	\N	\N	Período	periodo-bt06	\N	\N	\N	\N	\N	str
3874	2024-07-21 12:56:07.673+00	2024-07-21 12:56:07.673+00	f	\N	\N	Enlace	enlace-ft20	\N	\N	\N	\N	\N	str
3875	2024-07-21 12:56:07.685+00	2024-07-21 12:56:07.685+00	f	\N	\N	Cuenta	cuenta-0uzg	\N	\N	\N	\N	\N	str
3876	2024-07-21 12:56:07.69+00	2024-07-21 12:56:07.69+00	f	\N	\N	Categoría	categoria-nun5	\N	\N	\N	\N	\N	str
3877	2024-07-21 12:56:07.695+00	2024-07-21 12:56:07.695+00	f	\N	\N	Descripción	descripcion-k85v	\N	\N	\N	\N	\N	str
3878	2024-07-21 12:56:07.701+00	2024-07-21 12:56:07.701+00	f	\N	\N	Asignado	asignado-6abb	\N	\N	\N	\N	\N	str
3879	2024-07-21 12:56:07.706+00	2024-07-21 12:56:07.706+00	f	\N	\N	Modificado	modificado-b1aw	\N	\N	\N	\N	\N	str
3880	2024-07-21 12:56:07.71+00	2024-07-21 12:56:07.71+00	f	\N	\N	Codificado	codificado-13zz	\N	\N	\N	\N	\N	str
3881	2024-07-21 12:56:07.717+00	2024-07-21 12:56:07.717+00	f	\N	\N	Monto certificado	monto-certificado-cl3a	\N	\N	\N	\N	\N	str
3882	2024-07-21 12:56:07.723+00	2024-07-21 12:56:07.723+00	f	\N	\N	Comprometido	comprometido-2rsy	\N	\N	\N	\N	\N	str
3883	2024-07-21 12:56:07.727+00	2024-07-21 12:56:07.727+00	f	\N	\N	Devengado	devengado-d24y	\N	\N	\N	\N	\N	str
3884	2024-07-21 12:56:07.734+00	2024-07-21 12:56:07.734+00	f	\N	\N	Pagado	pagado-mkh6	\N	\N	\N	\N	\N	str
3885	2024-07-21 12:56:07.739+00	2024-07-21 12:56:07.739+00	f	\N	\N	Saldo por comprometer	saldo-por-comprometer-zoz4	\N	\N	\N	\N	\N	str
3886	2024-07-21 12:56:07.744+00	2024-07-21 12:56:07.744+00	f	\N	\N	Saldo por devengar	saldo-por-devengar-df50	\N	\N	\N	\N	\N	str
3887	2024-07-21 12:56:07.751+00	2024-07-21 12:56:07.751+00	f	\N	\N	Saldo por pagar	saldo-por-pagar-estw	\N	\N	\N	\N	\N	str
3888	2024-07-21 12:56:07.756+00	2024-07-21 12:56:07.756+00	f	\N	\N	Porcentaje de ejecución	porcentaje-de-ejecucion-ew56	\N	\N	\N	\N	\N	str
3889	2024-07-21 12:56:07.767+00	2024-07-21 12:56:07.767+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN	fecha-actualizacion-de-la-informacion-47t0	\N	\N	\N	\N	\N	str
3890	2024-07-21 12:56:07.772+00	2024-07-21 12:56:07.772+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN	periodicidad-de-actualizacion-de-la-informacion-ft77	\N	\N	\N	\N	\N	str
3891	2024-07-21 12:56:07.779+00	2024-07-21 12:56:07.779+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN	unidad-poseedora-de-la-informacion-9iw9	\N	\N	\N	\N	\N	str
3892	2024-07-21 12:56:07.786+00	2024-07-21 12:56:07.786+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	persona-responsable-de-la-unidad-poseedora-de-la-informacion-lu35	\N	\N	\N	\N	\N	str
3893	2024-07-21 12:56:07.792+00	2024-07-21 12:56:07.792+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-s7lb	\N	\N	\N	\N	\N	str
3894	2024-07-21 12:56:07.799+00	2024-07-21 12:56:07.799+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-wqvw	\N	\N	\N	\N	\N	str
3895	2024-07-21 12:56:07.805+00	2024-07-21 12:56:07.805+00	f	\N	\N	LICENCIA	licencia-fws4	\N	\N	\N	\N	\N	str
3896	2024-07-21 12:56:07.817+00	2024-07-21 12:56:07.817+00	f	\N	\N	Institución	institucion-jcf2	\N	\N	\N	\N	\N	str
3897	2024-07-21 12:56:07.823+00	2024-07-21 12:56:07.823+00	f	\N	\N	Descripción	descripcion-nuy6	\N	\N	\N	\N	\N	str
3898	2024-07-21 12:56:07.829+00	2024-07-21 12:56:07.829+00	f	\N	\N	Nombre del campo	nombre-del-campo-wync	\N	\N	\N	\N	\N	str
3899	2024-07-21 12:56:07.838+00	2024-07-21 12:56:07.838+00	f	\N	\N	Cuenta	cuenta-eo2k	\N	\N	\N	\N	\N	str
3900	2024-07-21 12:56:07.843+00	2024-07-21 12:56:07.843+00	f	\N	\N	Categoría	categoria-vnxz	\N	\N	\N	\N	\N	str
3901	2024-07-21 12:56:07.85+00	2024-07-21 12:56:07.85+00	f	\N	\N	Descripción	descripcion-cov7	\N	\N	\N	\N	\N	str
3902	2024-07-21 12:56:07.855+00	2024-07-21 12:56:07.855+00	f	\N	\N	Asignado	asignado-dgqd	\N	\N	\N	\N	\N	str
3903	2024-07-21 12:56:07.86+00	2024-07-21 12:56:07.86+00	f	\N	\N	Modificado	modificado-t5id	\N	\N	\N	\N	\N	str
3904	2024-07-21 12:56:07.866+00	2024-07-21 12:56:07.866+00	f	\N	\N	Codificado	codificado-aoof	\N	\N	\N	\N	\N	str
3905	2024-07-21 12:56:07.871+00	2024-07-21 12:56:07.871+00	f	\N	\N	Monto certificado	monto-certificado-sj2x	\N	\N	\N	\N	\N	str
3906	2024-07-21 12:56:07.876+00	2024-07-21 12:56:07.876+00	f	\N	\N	Comprometido	comprometido-t2fy	\N	\N	\N	\N	\N	str
3907	2024-07-21 12:56:07.882+00	2024-07-21 12:56:07.882+00	f	\N	\N	Devengado	devengado-255z	\N	\N	\N	\N	\N	str
3908	2024-07-21 12:56:07.888+00	2024-07-21 12:56:07.888+00	f	\N	\N	Pagado	pagado-dpeg	\N	\N	\N	\N	\N	str
3909	2024-07-21 12:56:07.894+00	2024-07-21 12:56:07.894+00	f	\N	\N	Saldo por comprometer	saldo-por-comprometer-si8n	\N	\N	\N	\N	\N	str
3910	2024-07-21 12:56:07.903+00	2024-07-21 12:56:07.903+00	f	\N	\N	Saldo por devengar	saldo-por-devengar-kc98	\N	\N	\N	\N	\N	str
3911	2024-07-21 12:56:07.91+00	2024-07-21 12:56:07.911+00	f	\N	\N	Saldo por pagar	saldo-por-pagar-l7kq	\N	\N	\N	\N	\N	str
3912	2024-07-21 12:56:07.918+00	2024-07-21 12:56:07.918+00	f	\N	\N	Porcentaje de ejecución	porcentaje-de-ejecucion-slam	\N	\N	\N	\N	\N	str
3913	2024-07-21 12:56:07.933+00	2024-07-21 12:56:07.933+00	f	\N	\N	No.	no-8e7s	\N	\N	\N	\N	\N	str
3914	2024-07-21 12:56:07.94+00	2024-07-21 12:56:07.94+00	f	\N	\N	Número del informe 	numero-del-informe-djhx	\N	\N	\N	\N	\N	str
3915	2024-07-21 12:56:07.947+00	2024-07-21 12:56:07.947+00	f	\N	\N	Tipo de examen	tipo-de-examen-cg8w	\N	\N	\N	\N	\N	str
3916	2024-07-21 12:56:07.954+00	2024-07-21 12:56:07.954+00	f	\N	\N	Nombre del examen	nombre-del-examen-0bdq	\N	\N	\N	\N	\N	str
3917	2024-07-21 12:56:07.961+00	2024-07-21 12:56:07.961+00	f	\N	\N	Período analizado	periodo-analizado-ujx4	\N	\N	\N	\N	\N	str
3918	2024-07-21 12:56:07.969+00	2024-07-21 12:56:07.969+00	f	\N	\N	Área o proceso auditado	area-o-proceso-auditado-w2t4	\N	\N	\N	\N	\N	str
3919	2024-07-21 12:56:07.977+00	2024-07-21 12:56:07.977+00	f	\N	\N	Enlace para descargar el informe específico	enlace-para-descargar-el-informe-especifico-4h77	\N	\N	\N	\N	\N	str
3920	2024-07-21 12:56:07.986+00	2024-07-21 12:56:07.986+00	f	\N	\N	Enlace para descargar el reporte de seguimiento al cumplimiento de recomendaciones del informe de auditoría	enlace-para-descargar-el-reporte-de-seguimiento-al-cumplimiento-de-recomendaciones-del-informe-de-auditoria-c3ql	\N	\N	\N	\N	\N	str
3921	2024-07-21 12:56:08+00	2024-07-21 12:56:08+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-m9g4	\N	\N	\N	\N	\N	str
3922	2024-07-21 12:56:08.008+00	2024-07-21 12:56:08.008+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-g1ei	\N	\N	\N	\N	\N	str
3923	2024-07-21 12:56:08.017+00	2024-07-21 12:56:08.017+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-nz9s	\N	\N	\N	\N	\N	str
3924	2024-07-21 12:56:08.024+00	2024-07-21 12:56:08.024+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-mq0v	\N	\N	\N	\N	\N	str
3925	2024-07-21 12:56:08.032+00	2024-07-21 12:56:08.032+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-1xpn	\N	\N	\N	\N	\N	str
3926	2024-07-21 12:56:08.04+00	2024-07-21 12:56:08.04+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-brlu	\N	\N	\N	\N	\N	str
3927	2024-07-21 12:56:08.048+00	2024-07-21 12:56:08.048+00	f	\N	\N	Enlace al sitio web de la Contraloría General del Estado para consulta de informes aprobados	enlace-al-sitio-web-de-la-contraloria-general-del-estado-para-consulta-de-informes-aprobados-x49r	\N	\N	\N	\N	\N	str
3928	2024-07-21 12:56:08.054+00	2024-07-21 12:56:08.054+00	f	\N	\N	LICENCIA	licencia-t7xp	\N	\N	\N	\N	\N	str
3929	2024-07-21 12:56:08.064+00	2024-07-21 12:56:08.064+00	f	\N	\N	Institución	institucion-b70g	\N	\N	\N	\N	\N	str
3930	2024-07-21 12:56:08.071+00	2024-07-21 12:56:08.071+00	f	\N	\N	Descripción	descripcion-5io8	\N	\N	\N	\N	\N	str
3931	2024-07-21 12:56:08.077+00	2024-07-21 12:56:08.077+00	f	\N	\N	Nombre del campo	nombre-del-campo-xy65	\N	\N	\N	\N	\N	str
3932	2024-07-21 12:56:08.083+00	2024-07-21 12:56:08.083+00	f	\N	\N	No	no-xglw	\N	\N	\N	\N	\N	str
3933	2024-07-21 12:56:08.089+00	2024-07-21 12:56:08.089+00	f	\N	\N	Número del informe	numero-del-informe-hy3y	\N	\N	\N	\N	\N	str
3934	2024-07-21 12:56:08.095+00	2024-07-21 12:56:08.095+00	f	\N	\N	Tipo de examen	tipo-de-examen-u9m9	\N	\N	\N	\N	\N	str
3935	2024-07-21 12:56:08.102+00	2024-07-21 12:56:08.102+00	f	\N	\N	Nombre del examen	nombre-del-examen-grji	\N	\N	\N	\N	\N	str
3936	2024-07-21 12:56:08.107+00	2024-07-21 12:56:08.107+00	f	\N	\N	Período analizado	periodo-analizado-vntb	\N	\N	\N	\N	\N	str
3937	2024-07-21 12:56:08.113+00	2024-07-21 12:56:08.113+00	f	\N	\N	Área o proceso auditado	area-o-proceso-auditado-yixm	\N	\N	\N	\N	\N	str
3938	2024-07-21 12:56:08.12+00	2024-07-21 12:56:08.12+00	f	\N	\N	Enlace para descargar el informe específico	enlace-para-descargar-el-informe-especifico-8jfs	\N	\N	\N	\N	\N	str
3939	2024-07-21 12:56:08.126+00	2024-07-21 12:56:08.126+00	f	\N	\N	Enlace para descargar el reporte de seguimiento al cumplimiento de recomendaciones del informe de auditoría	enlace-para-descargar-el-reporte-de-seguimiento-al-cumplimiento-de-recomendaciones-del-informe-de-auditoria-crcz	\N	\N	\N	\N	\N	str
3940	2024-07-21 12:56:08.138+00	2024-07-21 12:56:08.138+00	f	\N	\N	No.	no-a524	\N	\N	\N	\N	\N	str
3941	2024-07-21 12:56:08.145+00	2024-07-21 12:56:08.145+00	f	\N	\N	Apellidos y Nombres	apellidos-y-nombres-gqm7	\N	\N	\N	\N	\N	str
3942	2024-07-21 12:56:08.152+00	2024-07-21 12:56:08.152+00	f	\N	\N	Puesto Institucional	puesto-institucional-1d6f	\N	\N	\N	\N	\N	str
3943	2024-07-21 12:56:08.159+00	2024-07-21 12:56:08.159+00	f	\N	\N	Unidad a la que pertenece	unidad-a-la-que-pertenece-j98z	\N	\N	\N	\N	\N	str
3944	2024-07-21 12:56:08.167+00	2024-07-21 12:56:08.167+00	f	\N	\N	Dirección institucional	direccion-institucional-4lpo	\N	\N	\N	\N	\N	str
3945	2024-07-21 12:56:08.176+00	2024-07-21 12:56:08.176+00	f	\N	\N	Ciudad en la que labora	ciudad-en-la-que-labora-bsr1	\N	\N	\N	\N	\N	str
3946	2024-07-21 12:56:08.183+00	2024-07-21 12:56:08.183+00	f	\N	\N	Teléfono institucional	telefono-institucional-rnwb	\N	\N	\N	\N	\N	str
3947	2024-07-21 12:56:08.191+00	2024-07-21 12:56:08.191+00	f	\N	\N	Extensión telefónica	extension-telefonica-t4rt	\N	\N	\N	\N	\N	str
3948	2024-07-21 12:56:08.198+00	2024-07-21 12:56:08.198+00	f	\N	\N	Correo Electrónico institucional	correo-electronico-institucional-r0q4	\N	\N	\N	\N	\N	str
3949	2024-07-21 12:56:08.21+00	2024-07-21 12:56:08.21+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN	fecha-actualizacion-de-la-informacion-4ek2	\N	\N	\N	\N	\N	str
3950	2024-07-21 12:56:08.217+00	2024-07-21 12:56:08.217+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN	periodicidad-de-actualizacion-de-la-informacion-qd0f	\N	\N	\N	\N	\N	str
3951	2024-07-21 12:56:08.223+00	2024-07-21 12:56:08.223+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACION	unidad-poseedora-de-la-informacion-y7vq	\N	\N	\N	\N	\N	str
3952	2024-07-21 12:56:08.229+00	2024-07-21 12:56:08.229+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	persona-responsable-de-la-unidad-poseedora-de-la-informacion-qh3t	\N	\N	\N	\N	\N	str
3953	2024-07-21 12:56:08.235+00	2024-07-21 12:56:08.235+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-ofi9	\N	\N	\N	\N	\N	str
3954	2024-07-21 12:56:08.241+00	2024-07-21 12:56:08.241+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-rziq	\N	\N	\N	\N	\N	str
3955	2024-07-21 12:56:08.247+00	2024-07-21 12:56:08.247+00	f	\N	\N	LICENCIA	licencia-oy9e	\N	\N	\N	\N	\N	str
3956	2024-07-21 12:56:08.257+00	2024-07-21 12:56:08.257+00	f	\N	\N	Institución	institucion-eago	\N	\N	\N	\N	\N	str
3957	2024-07-21 12:56:08.263+00	2024-07-21 12:56:08.263+00	f	\N	\N	Descripción	descripcion-4cyu	\N	\N	\N	\N	\N	str
3958	2024-07-21 12:56:08.269+00	2024-07-21 12:56:08.269+00	f	\N	\N	Nombre del campo	nombre-del-campo-6yqp	\N	\N	\N	\N	\N	str
3959	2024-07-21 12:56:08.275+00	2024-07-21 12:56:08.275+00	f	\N	\N	No.	no-ewah	\N	\N	\N	\N	\N	str
3960	2024-07-21 12:56:08.281+00	2024-07-21 12:56:08.281+00	f	\N	\N	Apellidos y Nombres 	apellidos-y-nombres-l1ia	\N	\N	\N	\N	\N	str
3961	2024-07-21 12:56:08.287+00	2024-07-21 12:56:08.287+00	f	\N	\N	Puesto Institucional	puesto-institucional-t0sh	\N	\N	\N	\N	\N	str
3962	2024-07-21 12:56:08.293+00	2024-07-21 12:56:08.293+00	f	\N	\N	Unidad a la que pertenece	unidad-a-la-que-pertenece-tolf	\N	\N	\N	\N	\N	str
3963	2024-07-21 12:56:08.299+00	2024-07-21 12:56:08.299+00	f	\N	\N	Dirección institucional	direccion-institucional-7ciu	\N	\N	\N	\N	\N	str
3964	2024-07-21 12:56:08.305+00	2024-07-21 12:56:08.305+00	f	\N	\N	Ciudad en la que labora	ciudad-en-la-que-labora-my6m	\N	\N	\N	\N	\N	str
3965	2024-07-21 12:56:08.311+00	2024-07-21 12:56:08.311+00	f	\N	\N	Teléfono institucional	telefono-institucional-1v0z	\N	\N	\N	\N	\N	str
3966	2024-07-21 12:56:08.317+00	2024-07-21 12:56:08.317+00	f	\N	\N	Extensión telefónica	extension-telefonica-5x54	\N	\N	\N	\N	\N	str
3967	2024-07-21 12:56:08.323+00	2024-07-21 12:56:08.324+00	f	\N	\N	Correo Electrónico institucional	correo-electronico-institucional-v0ix	\N	\N	\N	\N	\N	str
3968	2024-07-21 12:56:08.336+00	2024-07-21 12:56:08.336+00	f	\N	\N	Denominación del servicio público que se brinda	denominacion-del-servicio-publico-que-se-brinda-f2b0	\N	\N	\N	\N	\N	str
3969	2024-07-21 12:56:08.343+00	2024-07-21 12:56:08.343+00	f	\N	\N	Enlace para acceder al reporte del servicio	enlace-para-acceder-al-reporte-del-servicio-14e7	\N	\N	\N	\N	\N	str
3970	2024-07-21 12:56:08.35+00	2024-07-21 12:56:08.35+00	f	\N	\N	Número de personas que acceden mensualmente al servicio institucional	numero-de-personas-que-acceden-mensualmente-al-servicio-institucional-gj78	\N	\N	\N	\N	\N	str
3971	2024-07-21 12:56:08.357+00	2024-07-21 12:56:08.357+00	f	\N	\N	Enlace para descargar el formulario o formato del servicio - Correo electronico para solicitar el servicio	enlace-para-descargar-el-formulario-o-formato-del-servicio-correo-electronico-para-solicitar-el-servicio-f80i	\N	\N	\N	\N	\N	str
3972	2024-07-21 12:56:08.363+00	2024-07-21 12:56:08.363+00	f	\N	\N	Enlace para el servicio por internet en línea	enlace-para-el-servicio-por-internet-en-linea-9wvm	\N	\N	\N	\N	\N	str
3973	2024-07-21 12:56:08.369+00	2024-07-21 12:56:08.369+00	f	\N	\N	Porcentaje de satisfacción sobre el uso del servicio	porcentaje-de-satisfaccion-sobre-el-uso-del-servicio-lfwv	\N	\N	\N	\N	\N	str
3974	2024-07-21 12:56:08.383+00	2024-07-21 12:56:08.383+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN	fecha-actualizacion-de-la-informacion-hw4r	\N	\N	\N	\N	\N	str
3975	2024-07-21 12:56:08.39+00	2024-07-21 12:56:08.39+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN	periodicidad-de-actualizacion-de-la-informacion-gxd1	\N	\N	\N	\N	\N	str
3976	2024-07-21 12:56:08.434+00	2024-07-21 12:56:08.434+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACION	unidad-poseedora-de-la-informacion-q0vs	\N	\N	\N	\N	\N	str
3977	2024-07-21 12:56:08.444+00	2024-07-21 12:56:08.444+00	f	\N	\N	PERSONAL RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	personal-responsable-de-la-unidad-poseedora-de-la-informacion-bhzq	\N	\N	\N	\N	\N	str
3978	2024-07-21 12:56:08.452+00	2024-07-21 12:56:08.452+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-q662	\N	\N	\N	\N	\N	str
4038	2024-07-21 12:56:08.861+00	2024-07-21 12:56:08.861+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-449m	\N	\N	\N	\N	\N	str
3979	2024-07-21 12:56:08.464+00	2024-07-21 12:56:08.464+00	f	\N	\N	NÚMERO TELEFÓNICO DEL O LA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	numero-telefonico-del-o-la-responsable-de-la-unidad-poseedora-de-la-informacion-9584	\N	\N	\N	\N	\N	str
3980	2024-07-21 12:56:08.47+00	2024-07-21 12:56:08.47+00	f	\N	\N	ENLACE A PORTAL ÚNICO DE TRÁMITES CIUDADANOS	enlace-a-portal-unico-de-tramites-ciudadanos-0758	\N	\N	\N	\N	\N	str
3981	2024-07-21 12:56:08.476+00	2024-07-21 12:56:08.476+00	f	\N	\N	LICENCIA	licencia-zk2m	\N	\N	\N	\N	\N	str
3982	2024-07-21 12:56:08.488+00	2024-07-21 12:56:08.488+00	f	\N	\N	Institución	institucion-tvpa	\N	\N	\N	\N	\N	str
3983	2024-07-21 12:56:08.494+00	2024-07-21 12:56:08.494+00	f	\N	\N	Descripción 	descripcion-0z7o	\N	\N	\N	\N	\N	str
3984	2024-07-21 12:56:08.501+00	2024-07-21 12:56:08.501+00	f	\N	\N	Nombre del Campo	nombre-del-campo-zxj8	\N	\N	\N	\N	\N	str
3985	2024-07-21 12:56:08.508+00	2024-07-21 12:56:08.508+00	f	\N	\N	Denominación del servicio público que se brinda	denominacion-del-servicio-publico-que-se-brinda-obuz	\N	\N	\N	\N	\N	str
3986	2024-07-21 12:56:08.514+00	2024-07-21 12:56:08.514+00	f	\N	\N	Enlace para acceder al reporte del servicio	enlace-para-acceder-al-reporte-del-servicio-6n5t	\N	\N	\N	\N	\N	str
3987	2024-07-21 12:56:08.52+00	2024-07-21 12:56:08.52+00	f	\N	\N	Número de personas que acceden mensualmente al servicio institucional	numero-de-personas-que-acceden-mensualmente-al-servicio-institucional-a01a	\N	\N	\N	\N	\N	str
3988	2024-07-21 12:56:08.527+00	2024-07-21 12:56:08.527+00	f	\N	\N	Enlace para descargar el formulario o formato del servicio - Correo electronico para solicitar el servicio	enlace-para-descargar-el-formulario-o-formato-del-servicio-correo-electronico-para-solicitar-el-servicio-sz4f	\N	\N	\N	\N	\N	str
3989	2024-07-21 12:56:08.533+00	2024-07-21 12:56:08.533+00	f	\N	\N	Enlace para el servicio por internet (en línea)	enlace-para-el-servicio-por-internet-en-linea-xwbp	\N	\N	\N	\N	\N	str
3990	2024-07-21 12:56:08.539+00	2024-07-21 12:56:08.539+00	f	\N	\N	Porcentaje de satisfacción sobre el uso del servicio	porcentaje-de-satisfaccion-sobre-el-uso-del-servicio-14fb	\N	\N	\N	\N	\N	str
3991	2024-07-21 12:56:08.552+00	2024-07-21 12:56:08.552+00	f	\N	\N	Apellidos y Nombres	apellidos-y-nombres-4cni	\N	\N	\N	\N	\N	str
3992	2024-07-21 12:56:08.557+00	2024-07-21 12:56:08.557+00	f	\N	\N	Puesto Institucional 	puesto-institucional-r2v9	\N	\N	\N	\N	\N	str
3993	2024-07-21 12:56:08.562+00	2024-07-21 12:56:08.562+00	f	\N	\N	Fecha de inicio	fecha-de-inicio-awj5	\N	\N	\N	\N	\N	str
3994	2024-07-21 12:56:08.569+00	2024-07-21 12:56:08.569+00	f	\N	\N	Fecha de fin	fecha-de-fin-ar8y	\N	\N	\N	\N	\N	str
3995	2024-07-21 12:56:08.575+00	2024-07-21 12:56:08.575+00	f	\N	\N	Lugar	lugar-ujk1	\N	\N	\N	\N	\N	str
3996	2024-07-21 12:56:08.582+00	2024-07-21 12:56:08.582+00	f	\N	\N	Tipo	tipo-av4k	\N	\N	\N	\N	\N	str
3997	2024-07-21 12:56:08.594+00	2024-07-21 12:56:08.594+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN	fecha-actualizacion-de-la-informacion-7zhk	\N	\N	\N	\N	\N	str
3998	2024-07-21 12:56:08.6+00	2024-07-21 12:56:08.6+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN	periodicidad-de-actualizacion-de-la-informacion-o78c	\N	\N	\N	\N	\N	str
3999	2024-07-21 12:56:08.606+00	2024-07-21 12:56:08.606+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACION	unidad-poseedora-de-la-informacion-eayt	\N	\N	\N	\N	\N	str
4000	2024-07-21 12:56:08.612+00	2024-07-21 12:56:08.612+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	persona-responsable-de-la-unidad-poseedora-de-la-informacion-iapr	\N	\N	\N	\N	\N	str
4001	2024-07-21 12:56:08.618+00	2024-07-21 12:56:08.619+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-w6si	\N	\N	\N	\N	\N	str
4002	2024-07-21 12:56:08.626+00	2024-07-21 12:56:08.626+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-i7gw	\N	\N	\N	\N	\N	str
4003	2024-07-21 12:56:08.633+00	2024-07-21 12:56:08.633+00	f	\N	\N	LICENCIA	licencia-eg78	\N	\N	\N	\N	\N	str
4004	2024-07-21 12:56:08.643+00	2024-07-21 12:56:08.643+00	f	\N	\N	Institución	institucion-6kgj	\N	\N	\N	\N	\N	str
4005	2024-07-21 12:56:08.65+00	2024-07-21 12:56:08.65+00	f	\N	\N	Descripción	descripcion-drq2	\N	\N	\N	\N	\N	str
4006	2024-07-21 12:56:08.658+00	2024-07-21 12:56:08.658+00	f	\N	\N	Nombre del Campo	nombre-del-campo-cwhc	\N	\N	\N	\N	\N	str
4007	2024-07-21 12:56:08.665+00	2024-07-21 12:56:08.665+00	f	\N	\N	Apellidos y Nombres	apellidos-y-nombres-fms2	\N	\N	\N	\N	\N	str
4008	2024-07-21 12:56:08.673+00	2024-07-21 12:56:08.673+00	f	\N	\N	Puesto Institucional	puesto-institucional-kdzp	\N	\N	\N	\N	\N	str
4009	2024-07-21 12:56:08.681+00	2024-07-21 12:56:08.681+00	f	\N	\N	Fecha de inicio	fecha-de-inicio-eb3t	\N	\N	\N	\N	\N	str
4010	2024-07-21 12:56:08.689+00	2024-07-21 12:56:08.689+00	f	\N	\N	Fecha de fin	fecha-de-fin-g8bb	\N	\N	\N	\N	\N	str
4011	2024-07-21 12:56:08.697+00	2024-07-21 12:56:08.697+00	f	\N	\N	Lugar	lugar-mhpu	\N	\N	\N	\N	\N	str
4012	2024-07-21 12:56:08.708+00	2024-07-21 12:56:08.708+00	f	\N	\N	Tipo	tipo-ejfl	\N	\N	\N	\N	\N	str
4013	2024-07-21 12:56:08.72+00	2024-07-21 12:56:08.72+00	f	\N	\N	Tipo	tipo-nqmv	\N	\N	\N	\N	\N	str
4014	2024-07-21 12:56:08.727+00	2024-07-21 12:56:08.727+00	f	\N	\N	Fecha de suscripción	fecha-de-suscripcion-2z5v	\N	\N	\N	\N	\N	str
4015	2024-07-21 12:56:08.733+00	2024-07-21 12:56:08.733+00	f	\N	\N	Objeto	objeto-3wfa	\N	\N	\N	\N	\N	str
4016	2024-07-21 12:56:08.741+00	2024-07-21 12:56:08.741+00	f	\N	\N	Nombre de la organización - persona natural o persona jurídica	nombre-de-la-organizacion-persona-natural-o-persona-juridica-v2as	\N	\N	\N	\N	\N	str
4017	2024-07-21 12:56:08.746+00	2024-07-21 12:56:08.746+00	f	\N	\N	Plazo de duración	plazo-de-duracion-lbzq	\N	\N	\N	\N	\N	str
4018	2024-07-21 12:56:08.753+00	2024-07-21 12:56:08.753+00	f	\N	\N	Enlace para descargar el convenio	enlace-para-descargar-el-convenio-kuk1	\N	\N	\N	\N	\N	str
4019	2024-07-21 12:56:08.762+00	2024-07-21 12:56:08.762+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN	fecha-actualizacion-de-la-informacion-fvx2	\N	\N	\N	\N	\N	str
4020	2024-07-21 12:56:08.767+00	2024-07-21 12:56:08.767+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN	periodicidad-de-actualizacion-de-la-informacion-a92b	\N	\N	\N	\N	\N	str
4021	2024-07-21 12:56:08.772+00	2024-07-21 12:56:08.772+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN	unidad-poseedora-de-la-informacion-qtdb	\N	\N	\N	\N	\N	str
4022	2024-07-21 12:56:08.777+00	2024-07-21 12:56:08.777+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	persona-responsable-de-la-unidad-poseedora-de-la-informacion-01ih	\N	\N	\N	\N	\N	str
4023	2024-07-21 12:56:08.781+00	2024-07-21 12:56:08.781+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-wrl7	\N	\N	\N	\N	\N	str
4024	2024-07-21 12:56:08.786+00	2024-07-21 12:56:08.786+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-8nse	\N	\N	\N	\N	\N	str
4025	2024-07-21 12:56:08.79+00	2024-07-21 12:56:08.79+00	f	\N	\N	LICENCIA	licencia-2283	\N	\N	\N	\N	\N	str
4026	2024-07-21 12:56:08.797+00	2024-07-21 12:56:08.797+00	f	\N	\N	Institución	institucion-35dc	\N	\N	\N	\N	\N	str
4027	2024-07-21 12:56:08.803+00	2024-07-21 12:56:08.803+00	f	\N	\N	Descripción	descripcion-guff	\N	\N	\N	\N	\N	str
4028	2024-07-21 12:56:08.807+00	2024-07-21 12:56:08.807+00	f	\N	\N	Nombre del campo	nombre-del-campo-ereh	\N	\N	\N	\N	\N	str
4029	2024-07-21 12:56:08.811+00	2024-07-21 12:56:08.811+00	f	\N	\N	Tipo	tipo-hvtm	\N	\N	\N	\N	\N	str
4030	2024-07-21 12:56:08.816+00	2024-07-21 12:56:08.816+00	f	\N	\N	Fecha de suscripción	fecha-de-suscripcion-e0ng	\N	\N	\N	\N	\N	str
4031	2024-07-21 12:56:08.82+00	2024-07-21 12:56:08.82+00	f	\N	\N	Objeto del convenio	objeto-del-convenio-m13a	\N	\N	\N	\N	\N	str
4032	2024-07-21 12:56:08.825+00	2024-07-21 12:56:08.825+00	f	\N	\N	Nombre de la organización - persona natural o persona jurídica	nombre-de-la-organizacion-persona-natural-o-persona-juridica-vvmf	\N	\N	\N	\N	\N	str
4033	2024-07-21 12:56:08.829+00	2024-07-21 12:56:08.829+00	f	\N	\N	Plazo de duración	plazo-de-duracion-z3q3	\N	\N	\N	\N	\N	str
4034	2024-07-21 12:56:08.834+00	2024-07-21 12:56:08.834+00	f	\N	\N	Enlace para descargar el convenio	enlace-para-descargar-el-convenio-rmr7	\N	\N	\N	\N	\N	str
4035	2024-07-21 12:56:08.843+00	2024-07-21 12:56:08.843+00	f	\N	\N	Nivel superior	nivel-superior-ne8g	\N	\N	\N	\N	\N	str
4036	2024-07-21 12:56:08.848+00	2024-07-21 12:56:08.848+00	f	\N	\N	Unidad	unidad-iit0	\N	\N	\N	\N	\N	str
4037	2024-07-21 12:56:08.853+00	2024-07-21 12:56:08.853+00	f	\N	\N	Nivel de los Procesos de la Estructura Orgánica Funcional	nivel-de-los-procesos-de-la-estructura-organica-funcional-mu5m	\N	\N	\N	\N	\N	str
4039	2024-07-21 12:56:08.867+00	2024-07-21 12:56:08.867+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-3kbg	\N	\N	\N	\N	\N	str
4040	2024-07-21 12:56:08.871+00	2024-07-21 12:56:08.871+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-gbbt	\N	\N	\N	\N	\N	str
4041	2024-07-21 12:56:08.876+00	2024-07-21 12:56:08.876+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-p0cz	\N	\N	\N	\N	\N	str
4042	2024-07-21 12:56:08.881+00	2024-07-21 12:56:08.881+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-ela1	\N	\N	\N	\N	\N	str
4043	2024-07-21 12:56:08.887+00	2024-07-21 12:56:08.887+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-hl7g	\N	\N	\N	\N	\N	str
4044	2024-07-21 12:56:08.892+00	2024-07-21 12:56:08.892+00	f	\N	\N	LICENCIA	licencia-aycr	\N	\N	\N	\N	\N	str
4045	2024-07-21 12:56:08.899+00	2024-07-21 12:56:08.899+00	f	\N	\N	ENLACE PARA CONSULTAR EL ORGANIGRAMA ESTRUCTURAL	enlace-para-consultar-el-organigrama-estructural-9ja6	\N	\N	\N	\N	\N	str
4046	2024-07-21 12:56:08.909+00	2024-07-21 12:56:08.909+00	f	\N	\N	Institución	institucion-8qbv	\N	\N	\N	\N	\N	str
4047	2024-07-21 12:56:08.915+00	2024-07-21 12:56:08.915+00	f	\N	\N	Descripción	descripcion-snu0	\N	\N	\N	\N	\N	str
4048	2024-07-21 12:56:08.921+00	2024-07-21 12:56:08.921+00	f	\N	\N	Nombre del campo	nombre-del-campo-uqop	\N	\N	\N	\N	\N	str
4049	2024-07-21 12:56:08.928+00	2024-07-21 12:56:08.928+00	f	\N	\N	Nivel superior	nivel-superior-ngxt	\N	\N	\N	\N	\N	str
4050	2024-07-21 12:56:08.937+00	2024-07-21 12:56:08.937+00	f	\N	\N	Unidad	unidad-y3bz	\N	\N	\N	\N	\N	str
4051	2024-07-21 12:56:08.946+00	2024-07-21 12:56:08.946+00	f	\N	\N	Nivel de los Procesos de la Estructura Organica Funcional	nivel-de-los-procesos-de-la-estructura-organica-funcional-2xd2	\N	\N	\N	\N	\N	str
4052	2024-07-21 12:56:08.962+00	2024-07-21 12:56:08.962+00	f	\N	\N	Tema 	tema-3pws	\N	\N	\N	\N	\N	str
4053	2024-07-21 12:56:08.969+00	2024-07-21 12:56:08.969+00	f	\N	\N	Número de requerimientos	numero-de-requerimientos-6xwn	\N	\N	\N	\N	\N	str
4054	2024-07-21 12:56:08.977+00	2024-07-21 12:56:08.977+00	f	\N	\N	Enlace para descargar el detalle de la información solicitada frecuentemente	enlace-para-descargar-el-detalle-de-la-informacion-solicitada-frecuentemente-tmew	\N	\N	\N	\N	\N	str
4055	2024-07-21 12:56:08.987+00	2024-07-21 12:56:08.987+00	f	\N	\N	Enlace para descargar la solicitud de información complementaria que haya sido solicitada recurrentemente	enlace-para-descargar-la-solicitud-de-informacion-complementaria-que-haya-sido-solicitada-recurrentemente-iv2u	\N	\N	\N	\N	\N	str
4056	2024-07-21 12:56:08.998+00	2024-07-21 12:56:08.998+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN	fecha-actualizacion-de-la-informacion-6jl2	\N	\N	\N	\N	\N	str
4057	2024-07-21 12:56:09.005+00	2024-07-21 12:56:09.005+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN	periodicidad-de-actualizacion-de-la-informacion-6bdg	\N	\N	\N	\N	\N	str
4058	2024-07-21 12:56:09.013+00	2024-07-21 12:56:09.013+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN	unidad-poseedora-de-la-informacion-de5s	\N	\N	\N	\N	\N	str
4059	2024-07-21 12:56:09.02+00	2024-07-21 12:56:09.02+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	persona-responsable-de-la-unidad-poseedora-de-la-informacion-6sot	\N	\N	\N	\N	\N	str
4060	2024-07-21 12:56:09.026+00	2024-07-21 12:56:09.026+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-4luk	\N	\N	\N	\N	\N	str
4061	2024-07-21 12:56:09.033+00	2024-07-21 12:56:09.033+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-35er	\N	\N	\N	\N	\N	str
4062	2024-07-21 12:56:09.04+00	2024-07-21 12:56:09.04+00	f	\N	\N	LICENCIA	licencia-brou	\N	\N	\N	\N	\N	str
4063	2024-07-21 12:56:09.053+00	2024-07-21 12:56:09.053+00	f	\N	\N	Institución	institucion-9z5x	\N	\N	\N	\N	\N	str
4064	2024-07-21 12:56:09.058+00	2024-07-21 12:56:09.058+00	f	\N	\N	Descripción	descripcion-vw0v	\N	\N	\N	\N	\N	str
4065	2024-07-21 12:56:09.064+00	2024-07-21 12:56:09.064+00	f	\N	\N	Nombre del campo	nombre-del-campo-9tra	\N	\N	\N	\N	\N	str
4066	2024-07-21 12:56:09.069+00	2024-07-21 12:56:09.07+00	f	\N	\N	Tema	tema-wxm3	\N	\N	\N	\N	\N	str
4067	2024-07-21 12:56:09.075+00	2024-07-21 12:56:09.075+00	f	\N	\N	Número de requerimientos	numero-de-requerimientos-t23u	\N	\N	\N	\N	\N	str
4068	2024-07-21 12:56:09.081+00	2024-07-21 12:56:09.081+00	f	\N	\N	Enlace para descargar el detalle de la información solicitada frecuentemente	enlace-para-descargar-el-detalle-de-la-informacion-solicitada-frecuentemente-ckmv	\N	\N	\N	\N	\N	str
4069	2024-07-21 12:56:09.087+00	2024-07-21 12:56:09.087+00	f	\N	\N	Enlace para descargar la solicitud de información complementaria que haya sido solicitada recurrentemente	enlace-para-descargar-la-solicitud-de-informacion-complementaria-que-haya-sido-solicitada-recurrentemente-f15s	\N	\N	\N	\N	\N	str
4070	2024-07-21 12:56:09.097+00	2024-07-21 12:56:09.097+00	f	\N	\N	Apellidos y Nombres	apellidos-y-nombres-9ye8	\N	\N	\N	\N	\N	str
4071	2024-07-21 12:56:09.102+00	2024-07-21 12:56:09.102+00	f	\N	\N	Denominación del puesto	denominacion-del-puesto-siqm	\N	\N	\N	\N	\N	str
4072	2024-07-21 12:56:09.107+00	2024-07-21 12:56:09.107+00	f	\N	\N	Responsabilidad LOTAIP	responsabilidad-lotaip-kokm	\N	\N	\N	\N	\N	str
4073	2024-07-21 12:56:09.112+00	2024-07-21 12:56:09.112+00	f	\N	\N	Dirección de la oficina	direccion-de-la-oficina-sct1	\N	\N	\N	\N	\N	str
4074	2024-07-21 12:56:09.116+00	2024-07-21 12:56:09.116+00	f	\N	\N	Número telefónico	numero-telefonico-5oal	\N	\N	\N	\N	\N	str
4075	2024-07-21 12:56:09.121+00	2024-07-21 12:56:09.121+00	f	\N	\N	Extensión telefónica	extension-telefonica-qvwn	\N	\N	\N	\N	\N	str
4076	2024-07-21 12:56:09.126+00	2024-07-21 12:56:09.126+00	f	\N	\N	Correo electrónico	correo-electronico-nfh7	\N	\N	\N	\N	\N	str
4077	2024-07-21 12:56:09.135+00	2024-07-21 12:56:09.135+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-amnb	\N	\N	\N	\N	\N	str
4078	2024-07-21 12:56:09.14+00	2024-07-21 12:56:09.14+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-tk96	\N	\N	\N	\N	\N	str
4079	2024-07-21 12:56:09.144+00	2024-07-21 12:56:09.144+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-5hig	\N	\N	\N	\N	\N	str
4080	2024-07-21 12:56:09.15+00	2024-07-21 12:56:09.15+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-eerh	\N	\N	\N	\N	\N	str
4081	2024-07-21 12:56:09.156+00	2024-07-21 12:56:09.156+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-prlw	\N	\N	\N	\N	\N	str
4082	2024-07-21 12:56:09.161+00	2024-07-21 12:56:09.161+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-7yla	\N	\N	\N	\N	\N	str
4083	2024-07-21 12:56:09.166+00	2024-07-21 12:56:09.166+00	f	\N	\N	Enlace para descargar el acuerdo o resolución de creación del comité de transparencia        	enlace-para-descargar-el-acuerdo-o-resolucion-de-creacion-del-comite-de-transparencia-qk8p	\N	\N	\N	\N	\N	str
4084	2024-07-21 12:56:09.172+00	2024-07-21 12:56:09.172+00	f	\N	\N	Enlace para descargar el acuerdo o resolución para delegar el manejo de las solicitudes de acceso a la información pública en territorio        	enlace-para-descargar-el-acuerdo-o-resolucion-para-delegar-el-manejo-de-las-solicitudes-de-acceso-a-la-informacion-publica-en-territorio-f1h6	\N	\N	\N	\N	\N	str
4085	2024-07-21 12:56:09.177+00	2024-07-21 12:56:09.177+00	f	\N	\N	Enlace para la recepción de solicitudes de acceso a la información pública por vía electrónica        	enlace-para-la-recepcion-de-solicitudes-de-acceso-a-la-informacion-publica-por-via-electronica-1j0x	\N	\N	\N	\N	\N	str
4142	2024-07-21 12:56:09.577+00	2024-07-21 12:56:09.577+00	f	\N	\N	Motivo del viaje	motivo-del-viaje-csd7	\N	\N	\N	\N	\N	str
4143	2024-07-21 12:56:09.584+00	2024-07-21 12:56:09.584+00	f	\N	\N	Valor del viático	valor-del-viatico-l7rp	\N	\N	\N	\N	\N	str
4196	2024-07-21 12:56:09.94+00	2024-07-21 12:56:09.94+00	f	\N	\N	Tema	tema-wuo9	\N	\N	\N	\N	\N	str
4086	2024-07-21 12:56:09.18+00	2024-07-21 12:56:09.18+00	f	\N	\N	Enlace para descargar el listado de responsables de atender las solicitudes de acceso a la información en las delegaciones provinciales 	enlace-para-descargar-el-listado-de-responsables-de-atender-las-solicitudes-de-acceso-a-la-informacion-en-las-delegaciones-provinciales-uoo9	\N	\N	\N	\N	\N	str
4087	2024-07-21 12:56:09.186+00	2024-07-21 12:56:09.186+00	f	\N	\N	LICENCIA	licencia-snpj	\N	\N	\N	\N	\N	str
4088	2024-07-21 12:56:09.195+00	2024-07-21 12:56:09.195+00	f	\N	\N	Institución	institucion-hdo8	\N	\N	\N	\N	\N	str
4089	2024-07-21 12:56:09.201+00	2024-07-21 12:56:09.201+00	f	\N	\N	Descripción	descripcion-xrru	\N	\N	\N	\N	\N	str
4090	2024-07-21 12:56:09.206+00	2024-07-21 12:56:09.206+00	f	\N	\N	Nombre del Campo	nombre-del-campo-szsd	\N	\N	\N	\N	\N	str
4091	2024-07-21 12:56:09.212+00	2024-07-21 12:56:09.212+00	f	\N	\N	Apellidos y Nombres	apellidos-y-nombres-073p	\N	\N	\N	\N	\N	str
4092	2024-07-21 12:56:09.218+00	2024-07-21 12:56:09.218+00	f	\N	\N	Denominación del puesto	denominacion-del-puesto-kpqi	\N	\N	\N	\N	\N	str
4093	2024-07-21 12:56:09.225+00	2024-07-21 12:56:09.225+00	f	\N	\N	Responsabilidad LOTAIP	responsabilidad-lotaip-1hbw	\N	\N	\N	\N	\N	str
4094	2024-07-21 12:56:09.232+00	2024-07-21 12:56:09.232+00	f	\N	\N	Dirección de la oficina	direccion-de-la-oficina-cefv	\N	\N	\N	\N	\N	str
4095	2024-07-21 12:56:09.239+00	2024-07-21 12:56:09.239+00	f	\N	\N	Número telefónico	numero-telefonico-ubiy	\N	\N	\N	\N	\N	str
4096	2024-07-21 12:56:09.245+00	2024-07-21 12:56:09.245+00	f	\N	\N	Extensión telefónica	extension-telefonica-yx27	\N	\N	\N	\N	\N	str
4097	2024-07-21 12:56:09.253+00	2024-07-21 12:56:09.253+00	f	\N	\N	Correo electrónico	correo-electronico-ko1i	\N	\N	\N	\N	\N	str
4098	2024-07-21 12:56:09.269+00	2024-07-21 12:56:09.269+00	f	\N	\N	Denominación de la organización sindical	denominacion-de-la-organizacion-sindical-ezzb	\N	\N	\N	\N	\N	str
4099	2024-07-21 12:56:09.277+00	2024-07-21 12:56:09.277+00	f	\N	\N	Fecha de suscripción del contrato 	fecha-de-suscripcion-del-contrato-52jz	\N	\N	\N	\N	\N	str
4100	2024-07-21 12:56:09.286+00	2024-07-21 12:56:09.286+00	f	\N	\N	Enlace para descargar el contrato colectivo original	enlace-para-descargar-el-contrato-colectivo-original-exn2	\N	\N	\N	\N	\N	str
4101	2024-07-21 12:56:09.294+00	2024-07-21 12:56:09.294+00	f	\N	\N	Fecha de la última reforma o revisión 	fecha-de-la-ultima-reforma-o-revision-zqsc	\N	\N	\N	\N	\N	str
4102	2024-07-21 12:56:09.302+00	2024-07-21 12:56:09.302+00	f	\N	\N	Enlace para descargar todas las reformas completas del contrato colectivo 	enlace-para-descargar-todas-las-reformas-completas-del-contrato-colectivo-8123	\N	\N	\N	\N	\N	str
4103	2024-07-21 12:56:09.318+00	2024-07-21 12:56:09.318+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-qbfy	\N	\N	\N	\N	\N	str
4104	2024-07-21 12:56:09.327+00	2024-07-21 12:56:09.327+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-p6w5	\N	\N	\N	\N	\N	str
4105	2024-07-21 12:56:09.335+00	2024-07-21 12:56:09.335+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-ej3k	\N	\N	\N	\N	\N	str
4106	2024-07-21 12:56:09.343+00	2024-07-21 12:56:09.343+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-0hve	\N	\N	\N	\N	\N	str
4107	2024-07-21 12:56:09.35+00	2024-07-21 12:56:09.35+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-ravi	\N	\N	\N	\N	\N	str
4108	2024-07-21 12:56:09.356+00	2024-07-21 12:56:09.356+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-ltfp	\N	\N	\N	\N	\N	str
4109	2024-07-21 12:56:09.362+00	2024-07-21 12:56:09.362+00	f	\N	\N	LICENCIA	licencia-7f1u	\N	\N	\N	\N	\N	str
4110	2024-07-21 12:56:09.372+00	2024-07-21 12:56:09.372+00	f	\N	\N	Institución	institucion-cfte	\N	\N	\N	\N	\N	str
4111	2024-07-21 12:56:09.378+00	2024-07-21 12:56:09.378+00	f	\N	\N	Descripción	descripcion-03zh	\N	\N	\N	\N	\N	str
4112	2024-07-21 12:56:09.383+00	2024-07-21 12:56:09.383+00	f	\N	\N	Nombre del campo	nombre-del-campo-sio8	\N	\N	\N	\N	\N	str
4113	2024-07-21 12:56:09.39+00	2024-07-21 12:56:09.39+00	f	\N	\N	Denominación de la organización sindical	denominacion-de-la-organizacion-sindical-kxw9	\N	\N	\N	\N	\N	str
4114	2024-07-21 12:56:09.396+00	2024-07-21 12:56:09.396+00	f	\N	\N	Fecha de suscripción del contrato	fecha-de-suscripcion-del-contrato-qjxh	\N	\N	\N	\N	\N	str
4115	2024-07-21 12:56:09.402+00	2024-07-21 12:56:09.402+00	f	\N	\N	Enlace para descargar el contrato colectivo original	enlace-para-descargar-el-contrato-colectivo-original-fuuz	\N	\N	\N	\N	\N	str
4116	2024-07-21 12:56:09.408+00	2024-07-21 12:56:09.408+00	f	\N	\N	Fecha de la última reforma o revisión 	fecha-de-la-ultima-reforma-o-revision-xao6	\N	\N	\N	\N	\N	str
4117	2024-07-21 12:56:09.413+00	2024-07-21 12:56:09.413+00	f	\N	\N	Enlace para descargar todas las reformas completas del contrato colectivo 	enlace-para-descargar-todas-las-reformas-completas-del-contrato-colectivo-h80a	\N	\N	\N	\N	\N	str
4118	2024-07-21 12:56:09.425+00	2024-07-21 12:56:09.425+00	f	\N	\N	Apellidos y Nombres	apellidos-y-nombres-wbo4	\N	\N	\N	\N	\N	str
4119	2024-07-21 12:56:09.43+00	2024-07-21 12:56:09.43+00	f	\N	\N	Puesto institucional	puesto-institucional-73tm	\N	\N	\N	\N	\N	str
4120	2024-07-21 12:56:09.436+00	2024-07-21 12:56:09.436+00	f	\N	\N	Tipo	tipo-75ua	\N	\N	\N	\N	\N	str
4121	2024-07-21 12:56:09.442+00	2024-07-21 12:56:09.442+00	f	\N	\N	Fecha de inicio del viaje	fecha-de-inicio-del-viaje-unc4	\N	\N	\N	\N	\N	str
4122	2024-07-21 12:56:09.448+00	2024-07-21 12:56:09.448+00	f	\N	\N	Fecha de fin del viaje	fecha-de-fin-del-viaje-edbs	\N	\N	\N	\N	\N	str
4123	2024-07-21 12:56:09.455+00	2024-07-21 12:56:09.455+00	f	\N	\N	Motivo del viaje	motivo-del-viaje-6o4w	\N	\N	\N	\N	\N	str
4124	2024-07-21 12:56:09.46+00	2024-07-21 12:56:09.46+00	f	\N	\N	Valor del viático	valor-del-viatico-a3c4	\N	\N	\N	\N	\N	str
4125	2024-07-21 12:56:09.466+00	2024-07-21 12:56:09.466+00	f	\N	\N	Enlace para descargar el informe y justificativos	enlace-para-descargar-el-informe-y-justificativos-qikd	\N	\N	\N	\N	\N	str
4126	2024-07-21 12:56:09.476+00	2024-07-21 12:56:09.476+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN	fecha-actualizacion-de-la-informacion-rcqe	\N	\N	\N	\N	\N	str
4127	2024-07-21 12:56:09.482+00	2024-07-21 12:56:09.482+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN	periodicidad-de-actualizacion-de-la-informacion-3ijo	\N	\N	\N	\N	\N	str
4128	2024-07-21 12:56:09.488+00	2024-07-21 12:56:09.488+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN	unidad-poseedora-de-la-informacion-kicj	\N	\N	\N	\N	\N	str
4129	2024-07-21 12:56:09.494+00	2024-07-21 12:56:09.494+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	persona-responsable-de-la-unidad-poseedora-de-la-informacion-fdyf	\N	\N	\N	\N	\N	str
4130	2024-07-21 12:56:09.5+00	2024-07-21 12:56:09.5+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-mgy5	\N	\N	\N	\N	\N	str
4131	2024-07-21 12:56:09.506+00	2024-07-21 12:56:09.506+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-s8ac	\N	\N	\N	\N	\N	str
4132	2024-07-21 12:56:09.512+00	2024-07-21 12:56:09.512+00	f	\N	\N	LICENCIA	licencia-n7c2	\N	\N	\N	\N	\N	str
4133	2024-07-21 12:56:09.518+00	2024-07-21 12:56:09.518+00	f	\N	\N	ENLACE PARA DESCARGAR EL REPORTE CONSOLIDADO DE GASTOS DE VIÁTICOS NACIONALES E INTERNACIONALES	enlace-para-descargar-el-reporte-consolidado-de-gastos-de-viaticos-nacionales-e-internacionales-2hx7	\N	\N	\N	\N	\N	str
4134	2024-07-21 12:56:09.527+00	2024-07-21 12:56:09.527+00	f	\N	\N	Institución	institucion-dt7g	\N	\N	\N	\N	\N	str
4135	2024-07-21 12:56:09.533+00	2024-07-21 12:56:09.533+00	f	\N	\N	Descripción	descripcion-36ap	\N	\N	\N	\N	\N	str
4136	2024-07-21 12:56:09.54+00	2024-07-21 12:56:09.54+00	f	\N	\N	Nombre del campo	nombre-del-campo-nqur	\N	\N	\N	\N	\N	str
4137	2024-07-21 12:56:09.546+00	2024-07-21 12:56:09.546+00	f	\N	\N	Apellidos y Nombres	apellidos-y-nombres-pz63	\N	\N	\N	\N	\N	str
4138	2024-07-21 12:56:09.552+00	2024-07-21 12:56:09.552+00	f	\N	\N	Puesto Institucional	puesto-institucional-xp8n	\N	\N	\N	\N	\N	str
4139	2024-07-21 12:56:09.558+00	2024-07-21 12:56:09.558+00	f	\N	\N	Tipo	tipo-ffwi	\N	\N	\N	\N	\N	str
4140	2024-07-21 12:56:09.565+00	2024-07-21 12:56:09.565+00	f	\N	\N	Fecha de inicio del viaje	fecha-de-inicio-del-viaje-9nc8	\N	\N	\N	\N	\N	str
4141	2024-07-21 12:56:09.571+00	2024-07-21 12:56:09.571+00	f	\N	\N	Fecha de fin del viaje	fecha-de-fin-del-viaje-kvt8	\N	\N	\N	\N	\N	str
4144	2024-07-21 12:56:09.59+00	2024-07-21 12:56:09.59+00	f	\N	\N	Enlace para descargar el informe y justificativo	enlace-para-descargar-el-informe-y-justificativo-60f5	\N	\N	\N	\N	\N	str
4145	2024-07-21 12:56:09.604+00	2024-07-21 12:56:09.604+00	f	\N	\N	Accion afirmativa	accion-afirmativa-cdph	\N	\N	\N	\N	\N	str
4146	2024-07-21 12:56:09.612+00	2024-07-21 12:56:09.612+00	f	\N	\N	No. de personas con acciones afirmativas	no-de-personas-con-acciones-afirmativas-mhvw	\N	\N	\N	\N	\N	str
4147	2024-07-21 12:56:09.623+00	2024-07-21 12:56:09.623+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN	fecha-actualizacion-de-la-informacion-aexl	\N	\N	\N	\N	\N	str
4148	2024-07-21 12:56:09.629+00	2024-07-21 12:56:09.629+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN	periodicidad-de-actualizacion-de-la-informacion-q196	\N	\N	\N	\N	\N	str
4149	2024-07-21 12:56:09.635+00	2024-07-21 12:56:09.635+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN	unidad-poseedora-de-la-informacion-6eoy	\N	\N	\N	\N	\N	str
4150	2024-07-21 12:56:09.644+00	2024-07-21 12:56:09.644+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	persona-responsable-de-la-unidad-poseedora-de-la-informacion-brnq	\N	\N	\N	\N	\N	str
4151	2024-07-21 12:56:09.651+00	2024-07-21 12:56:09.651+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-ukuc	\N	\N	\N	\N	\N	str
4152	2024-07-21 12:56:09.657+00	2024-07-21 12:56:09.657+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-vd6o	\N	\N	\N	\N	\N	str
4153	2024-07-21 12:56:09.662+00	2024-07-21 12:56:09.662+00	f	\N	\N	LICENCIA	licencia-pre1	\N	\N	\N	\N	\N	str
4154	2024-07-21 12:56:09.672+00	2024-07-21 12:56:09.672+00	f	\N	\N	Institución	institucion-xnkh	\N	\N	\N	\N	\N	str
4155	2024-07-21 12:56:09.677+00	2024-07-21 12:56:09.677+00	f	\N	\N	Descripción	descripcion-f3r5	\N	\N	\N	\N	\N	str
4156	2024-07-21 12:56:09.683+00	2024-07-21 12:56:09.683+00	f	\N	\N	Nombre del campo	nombre-del-campo-z6vg	\N	\N	\N	\N	\N	str
4157	2024-07-21 12:56:09.689+00	2024-07-21 12:56:09.689+00	f	\N	\N	Accion afirmativa	accion-afirmativa-ewlj	\N	\N	\N	\N	\N	str
4158	2024-07-21 12:56:09.695+00	2024-07-21 12:56:09.695+00	f	\N	\N	No. de personas con acciones afirmativas	no-de-personas-con-acciones-afirmativas-w63j	\N	\N	\N	\N	\N	str
4159	2024-07-21 12:56:09.707+00	2024-07-21 12:56:09.707+00	f	\N	\N	Fecha 	fecha-vu9c	\N	\N	\N	\N	\N	str
4160	2024-07-21 12:56:09.712+00	2024-07-21 12:56:09.712+00	f	\N	\N	Descripción	descripcion-zgoc	\N	\N	\N	\N	\N	str
4161	2024-07-21 12:56:09.718+00	2024-07-21 12:56:09.718+00	f	\N	\N	Ocasión o motivo	ocasion-o-motivo-680z	\N	\N	\N	\N	\N	str
4162	2024-07-21 12:56:09.723+00	2024-07-21 12:56:09.723+00	f	\N	\N	Persona natural o jurídica 	persona-natural-o-juridica-d1n7	\N	\N	\N	\N	\N	str
4163	2024-07-21 12:56:09.729+00	2024-07-21 12:56:09.729+00	f	\N	\N	Enlace para descargar el documento mediante el cual se oficializa el regalo o donativo	enlace-para-descargar-el-documento-mediante-el-cual-se-oficializa-el-regalo-o-donativo-rn5f	\N	\N	\N	\N	\N	str
4164	2024-07-21 12:56:09.738+00	2024-07-21 12:56:09.738+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN:	fecha-actualizacion-de-la-informacion-cpzk	\N	\N	\N	\N	\N	str
4165	2024-07-21 12:56:09.744+00	2024-07-21 12:56:09.744+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN:	periodicidad-de-actualizacion-de-la-informacion-uvdu	\N	\N	\N	\N	\N	str
4166	2024-07-21 12:56:09.75+00	2024-07-21 12:56:09.75+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN:	unidad-poseedora-de-la-informacion-bdbv	\N	\N	\N	\N	\N	str
4167	2024-07-21 12:56:09.755+00	2024-07-21 12:56:09.755+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	persona-responsable-de-la-unidad-poseedora-de-la-informacion-jkw2	\N	\N	\N	\N	\N	str
4168	2024-07-21 12:56:09.761+00	2024-07-21 12:56:09.761+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-5av6	\N	\N	\N	\N	\N	str
4169	2024-07-21 12:56:09.767+00	2024-07-21 12:56:09.767+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN:	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-yll4	\N	\N	\N	\N	\N	str
4170	2024-07-21 12:56:09.773+00	2024-07-21 12:56:09.773+00	f	\N	\N	LICENCIA	licencia-5tws	\N	\N	\N	\N	\N	str
4171	2024-07-21 12:56:09.782+00	2024-07-21 12:56:09.782+00	f	\N	\N	Institución	institucion-y3m4	\N	\N	\N	\N	\N	str
4172	2024-07-21 12:56:09.789+00	2024-07-21 12:56:09.789+00	f	\N	\N	Descripción	descripcion-hyjb	\N	\N	\N	\N	\N	str
4173	2024-07-21 12:56:09.795+00	2024-07-21 12:56:09.795+00	f	\N	\N	Nombre del campo	nombre-del-campo-7dmo	\N	\N	\N	\N	\N	str
4174	2024-07-21 12:56:09.802+00	2024-07-21 12:56:09.802+00	f	\N	\N	Fecha 	fecha-tleq	\N	\N	\N	\N	\N	str
4175	2024-07-21 12:56:09.808+00	2024-07-21 12:56:09.808+00	f	\N	\N	Descripción 	descripcion-8zt4	\N	\N	\N	\N	\N	str
4176	2024-07-21 12:56:09.813+00	2024-07-21 12:56:09.813+00	f	\N	\N	Motivo 	motivo-hvcw	\N	\N	\N	\N	\N	str
4177	2024-07-21 12:56:09.82+00	2024-07-21 12:56:09.82+00	f	\N	\N	Persona natural o jurídica 	persona-natural-o-juridica-6ocr	\N	\N	\N	\N	\N	str
4178	2024-07-21 12:56:09.826+00	2024-07-21 12:56:09.826+00	f	\N	\N	Enlace para descargar el documento mediante el cual se oficializa el regalo o donativo	enlace-para-descargar-el-documento-mediante-el-cual-se-oficializa-el-regalo-o-donativo-g0d4	\N	\N	\N	\N	\N	str
4179	2024-07-21 12:56:09.837+00	2024-07-21 12:56:09.837+00	f	\N	\N	Tema	tema-an2c	\N	\N	\N	\N	\N	str
4180	2024-07-21 12:56:09.843+00	2024-07-21 12:56:09.843+00	f	\N	\N	Número de Resolución	numero-de-resolucion-e867	\N	\N	\N	\N	\N	str
4181	2024-07-21 12:56:09.849+00	2024-07-21 12:56:09.849+00	f	\N	\N	Fecha de la clasificación de la información reservada	fecha-de-la-clasificacion-de-la-informacion-reservada-i3f1	\N	\N	\N	\N	\N	str
4182	2024-07-21 12:56:09.856+00	2024-07-21 12:56:09.856+00	f	\N	\N	Período de vigencia de la clasificación de la reserva	periodo-de-vigencia-de-la-clasificacion-de-la-reserva-sbzh	\N	\N	\N	\N	\N	str
4183	2024-07-21 12:56:09.862+00	2024-07-21 12:56:09.862+00	f	\N	\N	Enlace para descargar la resolución de clasificación de información reservada	enlace-para-descargar-la-resolucion-de-clasificacion-de-informacion-reservada-6t7t	\N	\N	\N	\N	\N	str
4184	2024-07-21 12:56:09.873+00	2024-07-21 12:56:09.873+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN	fecha-actualizacion-de-la-informacion-y5eh	\N	\N	\N	\N	\N	str
4185	2024-07-21 12:56:09.879+00	2024-07-21 12:56:09.879+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN	periodicidad-de-actualizacion-de-la-informacion-ctf5	\N	\N	\N	\N	\N	str
4186	2024-07-21 12:56:09.885+00	2024-07-21 12:56:09.885+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN	unidad-poseedora-de-la-informacion-odcf	\N	\N	\N	\N	\N	str
4187	2024-07-21 12:56:09.891+00	2024-07-21 12:56:09.891+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	persona-responsable-de-la-unidad-poseedora-de-la-informacion-xjwc	\N	\N	\N	\N	\N	str
4188	2024-07-21 12:56:09.896+00	2024-07-21 12:56:09.896+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-tzpv	\N	\N	\N	\N	\N	str
4189	2024-07-21 12:56:09.901+00	2024-07-21 12:56:09.901+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-wtib	\N	\N	\N	\N	\N	str
4190	2024-07-21 12:56:09.907+00	2024-07-21 12:56:09.907+00	f	\N	\N	LICENCIA	licencia-1mbu	\N	\N	\N	\N	\N	str
4191	2024-07-21 12:56:09.912+00	2024-07-21 12:56:09.912+00	f	\N	\N	ENLACE PARA DESCARGAR EL LISTADO ÍNDICE DE INFORMACIÓN RESERVADA - CERTIFICADO DE CUMPLIMIENTO 	enlace-para-descargar-el-listado-indice-de-informacion-reservada-certificado-de-cumplimiento-d3a3	\N	\N	\N	\N	\N	str
4192	2024-07-21 12:56:09.917+00	2024-07-21 12:56:09.917+00	f	\N	\N	ENLACE PARA DESCARGAR EL LISTADO ÍNDICE DE INFORMACIÓN RESERVADA - REPORTE DEL LITERAL C) (SISTEMA DE LA DEFENSORÍA DEL PUEBLO DE ECUADOR)	enlace-para-descargar-el-listado-indice-de-informacion-reservada-reporte-del-literal-c-sistema-de-la-defensoria-del-pueblo-de-ecuador-0gqq	\N	\N	\N	\N	\N	str
4193	2024-07-21 12:56:09.925+00	2024-07-21 12:56:09.925+00	f	\N	\N	Institución	institucion-mrkm	\N	\N	\N	\N	\N	str
4194	2024-07-21 12:56:09.929+00	2024-07-21 12:56:09.929+00	f	\N	\N	Descripción	descripcion-vfva	\N	\N	\N	\N	\N	str
4195	2024-07-21 12:56:09.935+00	2024-07-21 12:56:09.935+00	f	\N	\N	Nombre del campo	nombre-del-campo-y55u	\N	\N	\N	\N	\N	str
4197	2024-07-21 12:56:09.944+00	2024-07-21 12:56:09.944+00	f	\N	\N	Número de resolución	numero-de-resolucion-abxu	\N	\N	\N	\N	\N	str
4198	2024-07-21 12:56:09.948+00	2024-07-21 12:56:09.948+00	f	\N	\N	Fecha de la clasificación de la información reservada	fecha-de-la-clasificacion-de-la-informacion-reservada-14v2	\N	\N	\N	\N	\N	str
4199	2024-07-21 12:56:09.953+00	2024-07-21 12:56:09.953+00	f	\N	\N	Período de vigencia de la clasificación de la reserva	periodo-de-vigencia-de-la-clasificacion-de-la-reserva-wdq6	\N	\N	\N	\N	\N	str
4200	2024-07-21 12:56:09.957+00	2024-07-21 12:56:09.957+00	f	\N	\N	Enlace para descargar la resolución de clasificación de información reservada	enlace-para-descargar-la-resolucion-de-clasificacion-de-informacion-reservada-szf1	\N	\N	\N	\N	\N	str
4201	2024-07-21 12:56:09.967+00	2024-07-21 12:56:09.967+00	f	\N	\N	No.	no-on55	\N	\N	\N	\N	\N	str
4202	2024-07-21 12:56:09.972+00	2024-07-21 12:56:09.972+00	f	\N	\N	RUC / Número Identificación de la empresa o persona contratista	ruc-numero-identificacion-de-la-empresa-o-persona-contratista-5ijy	\N	\N	\N	\N	\N	str
4203	2024-07-21 12:56:09.977+00	2024-07-21 12:56:09.977+00	f	\N	\N	Número de contrato / código del proceso de contratación fallido o incumplido	numero-de-contrato-codigo-del-proceso-de-contratacion-fallido-o-incumplido-uk1e	\N	\N	\N	\N	\N	str
4204	2024-07-21 12:56:09.982+00	2024-07-21 12:56:09.982+00	f	\N	\N	Monto del contrato incumplido	monto-del-contrato-incumplido-8kob	\N	\N	\N	\N	\N	str
4205	2024-07-21 12:56:09.987+00	2024-07-21 12:56:09.987+00	f	\N	\N	Fecha desde	fecha-desde-0p7k	\N	\N	\N	\N	\N	str
4206	2024-07-21 12:56:09.992+00	2024-07-21 12:56:09.992+00	f	\N	\N	Fecha hasta	fecha-hasta-fs40	\N	\N	\N	\N	\N	str
4207	2024-07-21 12:56:10.001+00	2024-07-21 12:56:10.001+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN	fecha-actualizacion-de-la-informacion-ib31	\N	\N	\N	\N	\N	str
4208	2024-07-21 12:56:10.007+00	2024-07-21 12:56:10.007+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN	periodicidad-de-actualizacion-de-la-informacion-w6yr	\N	\N	\N	\N	\N	str
4209	2024-07-21 12:56:10.012+00	2024-07-21 12:56:10.012+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACIÓN	unidad-poseedora-de-la-informacion-1f82	\N	\N	\N	\N	\N	str
4210	2024-07-21 12:56:10.017+00	2024-07-21 12:56:10.017+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	persona-responsable-de-la-unidad-poseedora-de-la-informacion-homy	\N	\N	\N	\N	\N	str
4211	2024-07-21 12:56:10.021+00	2024-07-21 12:56:10.021+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-1bk0	\N	\N	\N	\N	\N	str
4212	2024-07-21 12:56:10.025+00	2024-07-21 12:56:10.025+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-va4a	\N	\N	\N	\N	\N	str
4213	2024-07-21 12:56:10.03+00	2024-07-21 12:56:10.03+00	f	\N	\N	LICENCIA	licencia-lzum	\N	\N	\N	\N	\N	str
4214	2024-07-21 12:56:10.036+00	2024-07-21 12:56:10.036+00	f	\N	\N	ENLACE PARA CONSULTA DE PROVEEDORES INCUMPLIDOS Y ADJUDICATARIOS FALLIDOS DEL SISTEMA OFICIAL DE CONTRATACIÓN PÚBLICA	enlace-para-consulta-de-proveedores-incumplidos-y-adjudicatarios-fallidos-del-sistema-oficial-de-contratacion-publica-te1g	\N	\N	\N	\N	\N	str
4215	2024-07-21 12:56:10.047+00	2024-07-21 12:56:10.047+00	f	\N	\N	Institución	institucion-626d	\N	\N	\N	\N	\N	str
4216	2024-07-21 12:56:10.052+00	2024-07-21 12:56:10.052+00	f	\N	\N	Descripción	descripcion-bd97	\N	\N	\N	\N	\N	str
4217	2024-07-21 12:56:10.057+00	2024-07-21 12:56:10.057+00	f	\N	\N	Nombre del campo	nombre-del-campo-ioez	\N	\N	\N	\N	\N	str
4218	2024-07-21 12:56:10.062+00	2024-07-21 12:56:10.062+00	f	\N	\N	No.	no-45hu	\N	\N	\N	\N	\N	str
4219	2024-07-21 12:56:10.066+00	2024-07-21 12:56:10.066+00	f	\N	\N	RUC / Número Identificación de la empresa o persona contratista	ruc-numero-identificacion-de-la-empresa-o-persona-contratista-m3f0	\N	\N	\N	\N	\N	str
4220	2024-07-21 12:56:10.07+00	2024-07-21 12:56:10.07+00	f	\N	\N	Número de contrato / código del proceso de contratación fallido o incumplido	numero-de-contrato-codigo-del-proceso-de-contratacion-fallido-o-incumplido-aw9j	\N	\N	\N	\N	\N	str
4221	2024-07-21 12:56:10.074+00	2024-07-21 12:56:10.074+00	f	\N	\N	Monto del contrato incumplido	monto-del-contrato-incumplido-nzbt	\N	\N	\N	\N	\N	str
4222	2024-07-21 12:56:10.08+00	2024-07-21 12:56:10.08+00	f	\N	\N	Fecha desde	fecha-desde-vpy4	\N	\N	\N	\N	\N	str
4223	2024-07-21 12:56:10.086+00	2024-07-21 12:56:10.086+00	f	\N	\N	Fecha hasta	fecha-hasta-4eje	\N	\N	\N	\N	\N	str
4224	2024-07-21 12:56:10.094+00	2024-07-21 12:56:10.094+00	f	\N	\N	Numeración	numeracion-vhs6	\N	\N	\N	\N	\N	str
4225	2024-07-21 12:56:10.099+00	2024-07-21 12:56:10.099+00	f	\N	\N	Puesto Institucional 	puesto-institucional-f0lq	\N	\N	\N	\N	\N	str
4226	2024-07-21 12:56:10.104+00	2024-07-21 12:56:10.104+00	f	\N	\N	Régimen laboral al que pertenece 	regimen-laboral-al-que-pertenece-5oxs	\N	\N	\N	\N	\N	str
4227	2024-07-21 12:56:10.11+00	2024-07-21 12:56:10.11+00	f	\N	\N	Número de partida presupuestaria	numero-de-partida-presupuestaria-7k3g	\N	\N	\N	\N	\N	str
4228	2024-07-21 12:56:10.116+00	2024-07-21 12:56:10.116+00	f	\N	\N	Grado jerárquico o escala al que pertenece el puesto	grado-jerarquico-o-escala-al-que-pertenece-el-puesto-76ri	\N	\N	\N	\N	\N	str
4229	2024-07-21 12:56:10.121+00	2024-07-21 12:56:10.121+00	f	\N	\N	Remuneración mensual unificada	remuneracion-mensual-unificada-37zz	\N	\N	\N	\N	\N	str
4230	2024-07-21 12:56:10.125+00	2024-07-21 12:56:10.125+00	f	\N	\N	Remuneración unificada (anual)	remuneracion-unificada-anual-1td9	\N	\N	\N	\N	\N	str
4231	2024-07-21 12:56:10.13+00	2024-07-21 12:56:10.13+00	f	\N	\N	Décimo Tercera Remuneración	decimo-tercera-remuneracion-87ca	\N	\N	\N	\N	\N	str
4232	2024-07-21 12:56:10.135+00	2024-07-21 12:56:10.135+00	f	\N	\N	Décima Cuarta Remuneración	decima-cuarta-remuneracion-cmvw	\N	\N	\N	\N	\N	str
4233	2024-07-21 12:56:10.14+00	2024-07-21 12:56:10.14+00	f	\N	\N	Horas suplementarias y extraordinarias	horas-suplementarias-y-extraordinarias-pfdr	\N	\N	\N	\N	\N	str
4234	2024-07-21 12:56:10.144+00	2024-07-21 12:56:10.144+00	f	\N	\N	Encargos y subrogaciones	encargos-y-subrogaciones-5qn2	\N	\N	\N	\N	\N	str
4235	2024-07-21 12:56:10.149+00	2024-07-21 12:56:10.149+00	f	\N	\N	Total ingresos adicionales	total-ingresos-adicionales-ib1t	\N	\N	\N	\N	\N	str
4236	2024-07-21 12:56:10.158+00	2024-07-21 12:56:10.158+00	f	\N	\N	FECHA ACTUALIZACIÓN DE LA INFORMACIÓN	fecha-actualizacion-de-la-informacion-vgf2	\N	\N	\N	\N	\N	str
4237	2024-07-21 12:56:10.163+00	2024-07-21 12:56:10.163+00	f	\N	\N	PERIODICIDAD DE ACTUALIZACIÓN DE LA INFORMACIÓN	periodicidad-de-actualizacion-de-la-informacion-y51k	\N	\N	\N	\N	\N	str
4238	2024-07-21 12:56:10.168+00	2024-07-21 12:56:10.168+00	f	\N	\N	UNIDAD POSEEDORA DE LA INFORMACION	unidad-poseedora-de-la-informacion-zpcj	\N	\N	\N	\N	\N	str
4239	2024-07-21 12:56:10.173+00	2024-07-21 12:56:10.173+00	f	\N	\N	PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	persona-responsable-de-la-unidad-poseedora-de-la-informacion-u98q	\N	\N	\N	\N	\N	str
4240	2024-07-21 12:56:10.178+00	2024-07-21 12:56:10.178+00	f	\N	\N	CORREO ELECTRÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	correo-electronico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-tfia	\N	\N	\N	\N	\N	str
4241	2024-07-21 12:56:10.183+00	2024-07-21 12:56:10.183+00	f	\N	\N	NÚMERO TELEFÓNICO DE LA PERSONA RESPONSABLE DE LA UNIDAD POSEEDORA DE LA INFORMACIÓN	numero-telefonico-de-la-persona-responsable-de-la-unidad-poseedora-de-la-informacion-vw4c	\N	\N	\N	\N	\N	str
4242	2024-07-21 12:56:10.189+00	2024-07-21 12:56:10.189+00	f	\N	\N	LICENCIA	licencia-uvrc	\N	\N	\N	\N	\N	str
4243	2024-07-21 12:56:10.2+00	2024-07-21 12:56:10.2+00	f	\N	\N	Institución	institucion-ttro	\N	\N	\N	\N	\N	str
4244	2024-07-21 12:56:10.205+00	2024-07-21 12:56:10.205+00	f	\N	\N	Descripción	descripcion-gk10	\N	\N	\N	\N	\N	str
4245	2024-07-21 12:56:10.21+00	2024-07-21 12:56:10.21+00	f	\N	\N	Nombre del Campo	nombre-del-campo-p1ol	\N	\N	\N	\N	\N	str
4246	2024-07-21 12:56:10.214+00	2024-07-21 12:56:10.214+00	f	\N	\N	Numeración	numeracion-m0ht	\N	\N	\N	\N	\N	str
4247	2024-07-21 12:56:10.22+00	2024-07-21 12:56:10.22+00	f	\N	\N	Puesto Institucional 	puesto-institucional-g85p	\N	\N	\N	\N	\N	str
4248	2024-07-21 12:56:10.227+00	2024-07-21 12:56:10.227+00	f	\N	\N	Régimen laboral al que pertenece 	regimen-laboral-al-que-pertenece-2uyw	\N	\N	\N	\N	\N	str
4249	2024-07-21 12:56:10.231+00	2024-07-21 12:56:10.231+00	f	\N	\N	Número de partida presupuestaria	numero-de-partida-presupuestaria-7xp4	\N	\N	\N	\N	\N	str
4250	2024-07-21 12:56:10.238+00	2024-07-21 12:56:10.238+00	f	\N	\N	Grado jerárquico o escala al que pertenece el puesto	grado-jerarquico-o-escala-al-que-pertenece-el-puesto-op0j	\N	\N	\N	\N	\N	str
4251	2024-07-21 12:56:10.244+00	2024-07-21 12:56:10.244+00	f	\N	\N	Remuneración mensual unificada	remuneracion-mensual-unificada-f19s	\N	\N	\N	\N	\N	str
4252	2024-07-21 12:56:10.25+00	2024-07-21 12:56:10.25+00	f	\N	\N	Remuneración unificada (anual)	remuneracion-unificada-anual-7qh4	\N	\N	\N	\N	\N	str
4253	2024-07-21 12:56:10.255+00	2024-07-21 12:56:10.255+00	f	\N	\N	Décimo Tercera Remuneración	decimo-tercera-remuneracion-m9bg	\N	\N	\N	\N	\N	str
4254	2024-07-21 12:56:10.261+00	2024-07-21 12:56:10.261+00	f	\N	\N	Décima Cuarta Remuneración	decima-cuarta-remuneracion-zkcu	\N	\N	\N	\N	\N	str
4255	2024-07-21 12:56:10.266+00	2024-07-21 12:56:10.266+00	f	\N	\N	Horas suplementarias y extraordinarias	horas-suplementarias-y-extraordinarias-plwq	\N	\N	\N	\N	\N	str
4256	2024-07-21 12:56:10.272+00	2024-07-21 12:56:10.272+00	f	\N	\N	Encargos y subrogaciones	encargos-y-subrogaciones-9tsb	\N	\N	\N	\N	\N	str
4257	2024-07-21 12:56:10.277+00	2024-07-21 12:56:10.277+00	f	\N	\N	Total ingresos adicionales	total-ingresos-adicionales-0rmf	\N	\N	\N	\N	\N	str
\.


--
-- Data for Name: entity_app_establishmentnumeral; Type: TABLE DATA; Schema: public; Owner: auth_user
--


--
-- Data for Name: entity_app_extension; Type: TABLE DATA; Schema: public; Owner: auth_user
--

COPY public.entity_app_extension (id, created_at, updated_at, deleted, deleted_at, ip, is_active, status, expiry_date, motive, solicity_id, user_id, user_created_id, user_deleted_id, user_updated_id) FROM stdin;
\.


--
-- Data for Name: entity_app_extension_attachments; Type: TABLE DATA; Schema: public; Owner: auth_user
--

COPY public.entity_app_extension_attachments (id, extension_id, attachment_id) FROM stdin;
\.


--
-- Data for Name: entity_app_extension_files; Type: TABLE DATA; Schema: public; Owner: auth_user
--

COPY public.entity_app_extension_files (id, extension_id, filepublication_id) FROM stdin;
\.


--
-- Data for Name: entity_app_filepublication; Type: TABLE DATA; Schema: public; Owner: auth_user
--

--
-- Data for Name: entity_app_numeral; Type: TABLE DATA; Schema: public; Owner: auth_user
--

COPY public.entity_app_numeral (id, created_at, updated_at, deleted, deleted_at, ip, name, description, parent_id, user_created_id, user_deleted_id, user_updated_id, is_default, type_transparency) FROM stdin;
83	2024-07-21 12:54:47.816+00	2024-07-21 12:54:47.816+00	f	\N	\N	Transparencia focalizada	Transparencia focalizada	\N	\N	\N	\N	t	F
84	2024-07-21 12:54:48.014+00	2024-07-21 12:54:48.014+00	f	\N	\N	Transparencia colaborativa	Transparencia colaborativa	\N	\N	\N	\N	t	C
86	2024-07-21 12:56:04.116+00	2024-07-21 12:56:04.116+00	f	\N	\N	Art. 28  Partidos Politicos y Organizaciones Politicas	Art  Partidos Politicos y Organizaciones Politicas	\N	\N	\N	\N	f	A
87	2024-07-21 12:56:04.494+00	2024-07-21 12:56:04.494+00	f	\N	\N	Art. 30 Informacion Publica IESS	Art Informacion Publica IESS	\N	\N	\N	\N	f	A
88	2024-07-21 12:56:04.628+00	2024-07-21 12:56:04.628+00	f	\N	\N	Art. 23 Funcion_de_Transparencia_y_Control_Social	Art Funcion_de_Transparencia_y_Control_Social	\N	\N	\N	\N	f	A
89	2024-07-21 12:56:04.751+00	2024-07-21 12:56:04.751+00	f	\N	\N	Art. 20 Ministerio de Economía y Finanzas	Art Ministerio de Economía y Finanzas	\N	\N	\N	\N	f	A
90	2024-07-21 12:56:04.899+00	2024-07-21 12:56:04.899+00	f	\N	\N	Art. 24 Gobiernos Autónomos Descentralizados	Art Gobiernos Autónomos Descentralizados	\N	\N	\N	\N	f	A
91	2024-07-21 12:56:05.05+00	2024-07-21 12:56:05.05+00	f	\N	\N	Art. 22 Consejo de la Judicatura	Art Consejo de la Judicatura	\N	\N	\N	\N	f	A
92	2024-07-21 12:56:05.266+00	2024-07-21 12:56:05.266+00	f	\N	\N	Art. 27 Tribunal Contencioso Electoral	Art Tribunal Contencioso Electoral	\N	\N	\N	\N	f	A
93	2024-07-21 12:56:05.532+00	2024-07-21 12:56:05.532+00	f	\N	\N	Art. 27 Consejo Nacional Electoral	Art Consejo Nacional Electoral	\N	\N	\N	\N	f	A
94	2024-07-21 12:56:05.723+00	2024-07-21 12:56:05.723+00	f	\N	\N	Art. 22 Corte Constitucional	Art Corte Constitucional	\N	\N	\N	\N	f	A
95	2024-07-21 12:56:05.849+00	2024-07-21 12:56:05.849+00	f	\N	\N	Art. 26 Asamblea Nacional	Art Asamblea Nacional	\N	\N	\N	\N	f	A
96	2024-07-21 12:56:05.995+00	2024-07-21 12:56:05.995+00	f	\N	\N	Art. 21 Ministerio de Energia y Minas	Art Ministerio de Energia y Minas	\N	\N	\N	\N	f	A
97	2024-07-21 12:56:06.224+00	2024-07-21 12:56:06.224+00	f	\N	\N	Art. 29 Informacion Publica Empresas Publicas	Art Informacion Publica Empresas Publicas	\N	\N	\N	\N	f	A
98	2024-07-21 12:56:06.332+00	2024-07-21 12:56:06.332+00	f	\N	\N	Numeral 11	Contratos de credito externos o internos	\N	\N	\N	\N	t	A
99	2024-07-21 12:56:06.554+00	2024-07-21 12:56:06.554+00	f	\N	\N	Numeral 8	Procesos de contratación publica	\N	\N	\N	\N	t	A
100	2024-07-21 12:56:06.758+00	2024-07-21 12:56:06.758+00	f	\N	\N	Numeral 21	Politicas publicas o informacion grupo especifico	\N	\N	\N	\N	t	A
101	2024-07-21 12:56:06.923+00	2024-07-21 13:00:30.324+00	f	\N	\N	Numeral 1.3	Metas y Objetivos	\N	\N	\N	\N	t	A
102	2024-07-21 12:56:07.044+00	2024-07-21 12:56:07.044+00	f	\N	\N	Numeral 10	Planes y programas	\N	\N	\N	\N	t	A
103	2024-07-21 12:56:07.172+00	2024-07-21 12:56:07.172+00	f	\N	\N	Numeral 24	Informacion relevante para el ejercicio de derechos ODS	\N	\N	\N	\N	t	A
104	2024-07-21 12:56:07.273+00	2024-07-21 13:00:11.948+00	f	\N	\N	Numeral 1.2	Base Legal-regulaciones-procedimientos internos	\N	\N	\N	\N	t	A
105	2024-07-21 12:56:07.37+00	2024-07-21 12:56:07.37+00	f	\N	\N	Numeral 17	Audiencias y reuniones autoridades	\N	\N	\N	\N	t	A
106	2024-07-21 12:56:07.559+00	2024-07-21 12:56:07.559+00	f	\N	\N	Numeral 12	Mecanismos rendicion cuentas	\N	\N	\N	\N	t	A
107	2024-07-21 12:56:07.677+00	2024-07-21 12:56:07.677+00	f	\N	\N	Numeral 6	Presupuesto de la institucion	\N	\N	\N	\N	t	A
108	2024-07-21 12:56:07.923+00	2024-07-21 12:56:07.923+00	f	\N	\N	Numeral 7	Resultados de las auditorias internas y gubernamentales	\N	\N	\N	\N	t	A
109	2024-07-21 12:56:08.13+00	2024-07-21 12:56:08.13+00	f	\N	\N	Numeral 2	Directorio y distributivo personal de la entidad	\N	\N	\N	\N	t	A
110	2024-07-21 12:56:08.328+00	2024-07-21 13:01:21.086+00	f	\N	\N	Numeral 5-22	Servicios formularios formatos tramites	\N	\N	\N	\N	t	A
111	2024-07-21 12:56:08.544+00	2024-07-21 12:56:08.544+00	f	\N	\N	Numeral 4	Detalle Licencia y comisiones	\N	\N	\N	\N	t	A
112	2024-07-21 12:56:08.712+00	2024-07-21 12:56:08.712+00	f	\N	\N	Numeral 18	Detalle de convenios nacionales e internacionales	\N	\N	\N	\N	t	A
113	2024-07-21 12:56:08.837+00	2024-07-21 12:59:35.277+00	f	\N	\N	Numeral 1.1	Estructura orgánica	\N	\N	\N	\N	t	A
114	2024-07-21 12:56:08.951+00	2024-07-21 12:56:08.951+00	f	\N	\N	Numeral 20	Registro de activos de informacion frecuente y complementaria	\N	\N	\N	\N	t	A
115	2024-07-21 12:56:09.091+00	2024-07-21 12:56:09.091+00	f	\N	\N	Numeral 14	Responsables del acceso de informacion publica	\N	\N	\N	\N	t	A
116	2024-07-21 12:56:09.258+00	2024-07-21 12:56:09.258+00	f	\N	\N	Numeral 15	Texto integro de los contratos colectivos vigentes y reformas	\N	\N	\N	\N	t	A
117	2024-07-21 12:56:09.417+00	2024-07-21 12:56:09.417+00	f	\N	\N	Numeral 13	Viaticos informes de trabajo y justificativos de movilización	\N	\N	\N	\N	t	A
118	2024-07-21 12:56:09.594+00	2024-07-21 12:56:09.594+00	f	\N	\N	Numeral 23	Detalle personas servidoras publicas con acciones afirmativas	\N	\N	\N	\N	t	A
119	2024-07-21 12:56:09.699+00	2024-07-21 12:56:09.699+00	f	\N	\N	Numeral 19	Detalle donativos oficiales y protocolares	\N	\N	\N	\N	t	A
120	2024-07-21 12:56:09.829+00	2024-07-21 12:56:09.829+00	f	\N	\N	Numeral 16	Índice información reservada	\N	\N	\N	\N	t	A
121	2024-07-21 12:56:09.96+00	2024-07-21 12:56:09.96+00	f	\N	\N	Numeral 9	Listado de empresas y personas que han incumplido contratos	\N	\N	\N	\N	t	A
122	2024-07-21 12:56:10.089+00	2024-07-21 12:56:10.089+00	f	\N	\N	Numeral 3	Remuneraciones ingresos adicionales	\N	\N	\N	\N	t	A
\.


--
-- Data for Name: entity_app_numeral_templates; Type: TABLE DATA; Schema: public; Owner: auth_user
--

COPY public.entity_app_numeral_templates (id, numeral_id, templatefile_id) FROM stdin;
1	83	400
2	83	401
3	83	399
4	84	402
5	84	403
6	84	404
7	86	408
8	86	409
9	86	410
10	87	411
11	87	412
12	87	413
13	88	416
14	88	414
15	88	415
16	89	417
17	89	418
18	89	419
19	90	420
20	90	421
21	90	422
22	91	424
23	91	425
24	91	423
25	92	426
26	92	427
27	92	428
28	93	429
29	93	430
30	93	431
31	94	432
32	94	433
33	94	434
34	95	435
35	95	436
36	95	437
37	96	440
38	96	438
39	96	439
40	97	441
41	97	442
42	97	443
43	98	444
44	98	445
45	98	446
46	99	448
47	99	449
48	99	447
49	100	450
50	100	451
51	100	452
52	101	453
53	101	454
54	101	455
55	102	456
56	102	457
57	102	458
58	103	459
59	103	460
60	103	461
61	104	464
62	104	462
63	104	463
64	105	465
65	105	466
66	105	467
67	106	468
68	106	469
69	106	470
70	107	472
71	107	473
72	107	471
73	108	474
74	108	475
75	108	476
76	109	477
77	109	478
78	109	479
79	110	480
80	110	481
81	110	482
82	111	483
83	111	484
84	111	485
85	112	488
86	112	486
87	112	487
88	113	489
89	113	490
90	113	491
91	114	492
92	114	493
93	114	494
94	115	496
95	115	497
96	115	495
97	116	498
98	116	499
99	116	500
100	117	501
101	117	502
102	117	503
103	118	504
104	118	505
105	118	506
106	119	507
107	119	508
108	119	509
109	120	512
110	120	510
111	120	511
112	121	513
113	121	514
114	121	515
115	122	516
116	122	517
117	122	518
\.


--
-- Data for Name: entity_app_publication; Type: TABLE DATA; Schema: public; Owner: auth_user
--

COPY public.entity_app_publication (id, created_at, updated_at, deleted, deleted_at, ip, name, description, is_active, establishment_id, user_created_id, user_deleted_id, user_updated_id, type_publication_id, slug, notes) FROM stdin;
\.


--
-- Data for Name: entity_app_publication_attachment; Type: TABLE DATA; Schema: public; Owner: auth_user
--

COPY public.entity_app_publication_attachment (id, publication_id, attachment_id) FROM stdin;
\.


--
-- Data for Name: entity_app_publication_file_publication; Type: TABLE DATA; Schema: public; Owner: auth_user
--

COPY public.entity_app_publication_file_publication (id, publication_id, filepublication_id) FROM stdin;
\.


--
-- Data for Name: entity_app_publication_tag; Type: TABLE DATA; Schema: public; Owner: auth_user
--

COPY public.entity_app_publication_tag (id, publication_id, tag_id) FROM stdin;
\.


--
-- Data for Name: entity_app_publication_type_format; Type: TABLE DATA; Schema: public; Owner: auth_user
--

COPY public.entity_app_publication_type_format (id, publication_id, typeformats_id) FROM stdin;
\.


--
-- Data for Name: entity_app_solicity; Type: TABLE DATA; Schema: public; Owner: auth_user
--


--
-- Data for Name: entity_app_templatefile; Type: TABLE DATA; Schema: public; Owner: auth_user
--

--
-- Data for Name: entity_app_templatefile_columns; Type: TABLE DATA; Schema: public; Owner: auth_user
--

COPY public.entity_app_templatefile_columns (id, templatefile_id, columnfile_id) FROM stdin;
1	399	3272
2	399	3269
3	399	3270
4	399	3271
5	400	3273
6	400	3274
7	400	3275
8	400	3276
9	400	3277
10	400	3278
11	400	3279
12	401	3280
13	401	3281
14	401	3282
15	401	3283
16	401	3284
17	401	3285
18	401	3286
19	402	3287
20	402	3288
21	402	3289
22	402	3290
23	402	3291
24	402	3292
25	403	3296
26	403	3297
27	403	3298
28	403	3299
29	403	3293
30	403	3294
31	403	3295
32	404	3300
33	404	3301
34	404	3302
35	404	3303
36	404	3304
37	404	3305
38	404	3306
39	404	3307
40	404	3308
41	405	3309
42	405	3310
43	405	3311
44	405	3312
45	405	3313
46	405	3314
47	405	3315
48	405	3316
49	405	3317
50	405	3318
51	405	3319
52	405	3320
53	406	3321
54	406	3322
55	406	3323
56	406	3324
57	406	3325
58	406	3326
59	406	3327
60	407	3328
61	407	3329
62	407	3330
63	407	3331
64	407	3332
65	407	3333
66	407	3334
67	407	3335
68	407	3336
69	407	3337
70	407	3338
71	407	3339
72	407	3340
73	407	3341
74	407	3342
75	408	3343
76	408	3344
77	408	3345
78	408	3346
79	408	3347
80	408	3348
81	408	3349
82	408	3350
83	408	3351
84	408	3352
85	408	3353
86	408	3354
87	408	3355
88	408	3356
89	408	3357
90	408	3358
91	408	3359
92	408	3360
93	408	3361
94	408	3362
95	409	3363
96	409	3364
97	409	3365
98	409	3366
99	409	3367
100	409	3368
101	409	3369
102	410	3370
103	410	3371
104	410	3372
105	410	3373
106	410	3374
107	410	3375
108	410	3376
109	410	3377
110	410	3378
111	410	3379
112	410	3380
113	410	3381
114	410	3382
115	410	3383
116	410	3384
117	410	3385
118	410	3386
119	410	3387
120	410	3388
121	410	3389
122	410	3390
123	410	3391
124	411	3392
125	411	3393
126	411	3394
127	411	3395
128	412	3396
129	412	3397
130	412	3398
131	412	3399
132	412	3400
133	412	3401
134	412	3402
135	413	3403
136	413	3404
137	413	3405
138	413	3406
139	413	3407
140	413	3408
141	413	3409
142	414	3410
143	414	3411
144	414	3412
145	414	3413
146	414	3414
147	415	3415
148	415	3416
149	415	3417
150	415	3418
151	415	3419
152	415	3420
153	415	3421
154	416	3424
155	416	3425
156	416	3426
157	416	3427
158	416	3428
159	416	3429
160	416	3422
161	416	3423
162	417	3430
163	417	3431
164	417	3432
165	417	3433
166	417	3434
167	417	3435
168	417	3436
169	418	3437
170	418	3438
171	418	3439
172	418	3440
173	418	3441
174	418	3442
175	418	3443
176	418	3444
177	419	3445
178	419	3446
179	419	3447
180	419	3448
181	419	3449
182	419	3450
183	419	3451
184	419	3452
185	419	3453
186	419	3454
187	420	3456
188	420	3457
189	420	3458
190	420	3459
191	420	3455
192	421	3460
193	421	3461
194	421	3462
195	421	3463
196	421	3464
197	421	3465
198	421	3466
199	422	3467
200	422	3468
201	422	3469
202	422	3470
203	422	3471
204	422	3472
205	422	3473
206	422	3474
207	423	3475
208	423	3476
209	423	3477
210	423	3478
211	423	3479
212	423	3480
213	423	3481
214	423	3482
215	423	3483
216	423	3484
217	423	3485
218	424	3488
219	424	3489
220	424	3490
221	424	3491
222	424	3492
223	424	3493
224	424	3486
225	424	3487
226	425	3494
227	425	3495
228	425	3496
229	425	3497
230	425	3498
231	425	3499
232	425	3500
233	425	3501
234	425	3502
235	425	3503
236	425	3504
237	425	3505
238	425	3506
239	425	3507
240	426	3508
241	426	3509
242	426	3510
243	426	3511
244	426	3512
245	426	3513
246	426	3514
247	426	3515
248	426	3516
249	427	3520
250	427	3521
251	427	3522
252	427	3523
253	427	3517
254	427	3518
255	427	3519
256	428	3524
257	428	3525
258	428	3526
259	428	3527
260	428	3528
261	428	3529
262	428	3530
263	428	3531
264	428	3532
265	428	3533
266	428	3534
267	428	3535
268	429	3536
269	429	3537
270	429	3538
271	429	3539
272	429	3540
273	430	3541
274	430	3542
275	430	3543
276	430	3544
277	430	3545
278	430	3546
279	430	3547
280	430	3548
281	430	3549
282	430	3550
283	431	3552
284	431	3553
285	431	3554
286	431	3555
287	431	3556
288	431	3557
289	431	3558
290	431	3551
291	432	3559
292	432	3560
293	432	3561
294	432	3562
295	432	3563
296	432	3564
297	433	3565
298	433	3566
299	433	3567
300	433	3568
301	433	3569
302	433	3570
303	433	3571
304	433	3572
305	434	3573
306	434	3574
307	434	3575
308	434	3576
309	434	3577
310	434	3578
311	434	3579
312	434	3580
313	434	3581
314	435	3584
315	435	3585
316	435	3586
317	435	3587
318	435	3588
319	435	3589
320	435	3582
321	435	3583
322	436	3590
323	436	3591
324	436	3592
325	436	3593
326	436	3594
327	436	3595
328	436	3596
329	437	3597
330	437	3598
331	437	3599
332	437	3600
333	437	3601
334	437	3602
335	437	3603
336	437	3604
337	437	3605
338	437	3606
339	437	3607
340	438	3616
341	438	3617
342	438	3618
343	438	3619
344	438	3620
345	438	3621
346	438	3622
347	438	3608
348	438	3609
349	438	3610
350	438	3611
351	438	3612
352	438	3613
353	438	3614
354	438	3615
355	439	3623
356	439	3624
357	439	3625
358	439	3626
359	439	3627
360	439	3628
361	439	3629
362	440	3630
363	440	3631
364	440	3632
365	440	3633
366	440	3634
367	440	3635
368	440	3636
369	440	3637
370	440	3638
371	440	3639
372	440	3640
373	440	3641
374	440	3642
375	440	3643
376	440	3644
377	440	3645
378	440	3646
379	440	3647
380	441	3648
381	441	3649
382	441	3650
383	441	3651
384	442	3652
385	442	3653
386	442	3654
387	442	3655
388	442	3656
389	442	3657
390	442	3658
391	443	3659
392	443	3660
393	443	3661
394	443	3662
395	443	3663
396	443	3664
397	443	3665
398	444	3666
399	444	3667
400	444	3668
401	444	3669
402	444	3670
403	444	3671
404	444	3672
405	444	3673
406	444	3674
407	444	3675
408	444	3676
409	444	3677
410	444	3678
411	445	3680
412	445	3681
413	445	3682
414	445	3683
415	445	3684
416	445	3685
417	445	3679
418	446	3686
419	446	3687
420	446	3688
421	446	3689
422	446	3690
423	446	3691
424	446	3692
425	446	3693
426	446	3694
427	446	3695
428	446	3696
429	446	3697
430	446	3698
431	446	3699
432	446	3700
433	446	3701
434	447	3702
435	447	3703
436	447	3704
437	447	3705
438	447	3706
439	447	3707
440	447	3708
441	447	3709
442	447	3710
443	447	3711
444	448	3712
445	448	3713
446	448	3714
447	448	3715
448	448	3716
449	448	3717
450	448	3718
451	448	3719
452	449	3720
453	449	3721
454	449	3722
455	449	3723
456	449	3724
457	449	3725
458	449	3726
459	449	3727
460	449	3728
461	449	3729
462	449	3730
463	449	3731
464	449	3732
465	450	3733
466	450	3734
467	450	3735
468	450	3736
469	450	3737
470	451	3744
471	451	3745
472	451	3738
473	451	3739
474	451	3740
475	451	3741
476	451	3742
477	451	3743
478	452	3746
479	452	3747
480	452	3748
481	452	3749
482	452	3750
483	452	3751
484	452	3752
485	452	3753
486	453	3754
487	453	3755
488	453	3756
489	453	3757
490	453	3758
491	454	3759
492	454	3760
493	454	3761
494	454	3762
495	454	3763
496	454	3764
497	454	3765
498	455	3766
499	455	3767
500	455	3768
501	455	3769
502	455	3770
503	455	3771
504	455	3772
505	455	3773
506	456	3776
507	456	3777
508	456	3778
509	456	3774
510	456	3775
511	457	3779
512	457	3780
513	457	3781
514	457	3782
515	457	3783
516	457	3784
517	457	3785
518	458	3786
519	458	3787
520	458	3788
521	458	3789
522	458	3790
523	458	3791
524	458	3792
525	458	3793
526	459	3794
527	459	3795
528	460	3796
529	460	3797
530	460	3798
531	460	3799
532	460	3800
533	460	3801
534	460	3802
535	461	3803
536	461	3804
537	461	3805
538	461	3806
539	461	3807
540	462	3808
541	462	3809
542	462	3810
543	463	3811
544	463	3812
545	463	3813
546	463	3814
547	463	3815
548	463	3816
549	463	3817
550	464	3818
551	464	3819
552	464	3820
553	464	3821
554	464	3822
555	464	3823
556	465	3824
557	465	3825
558	465	3826
559	465	3827
560	465	3828
561	465	3829
562	465	3830
563	465	3831
564	465	3832
565	465	3833
566	465	3834
567	466	3840
568	466	3841
569	466	3835
570	466	3836
571	466	3837
572	466	3838
573	466	3839
574	467	3842
575	467	3843
576	467	3844
577	467	3845
578	467	3846
579	467	3847
580	467	3848
581	467	3849
582	467	3850
583	467	3851
584	467	3852
585	467	3853
586	467	3854
587	467	3855
588	468	3856
589	468	3857
590	468	3858
591	468	3859
592	469	3860
593	469	3861
594	469	3862
595	469	3863
596	469	3864
597	469	3865
598	469	3866
599	469	3867
600	470	3872
601	470	3873
602	470	3874
603	470	3868
604	470	3869
605	470	3870
606	470	3871
607	471	3875
608	471	3876
609	471	3877
610	471	3878
611	471	3879
612	471	3880
613	471	3881
614	471	3882
615	471	3883
616	471	3884
617	471	3885
618	471	3886
619	471	3887
620	471	3888
621	472	3889
622	472	3890
623	472	3891
624	472	3892
625	472	3893
626	472	3894
627	472	3895
628	473	3904
629	473	3905
630	473	3906
631	473	3907
632	473	3908
633	473	3909
634	473	3910
635	473	3911
636	473	3912
637	473	3896
638	473	3897
639	473	3898
640	473	3899
641	473	3900
642	473	3901
643	473	3902
644	473	3903
645	474	3913
646	474	3914
647	474	3915
648	474	3916
649	474	3917
650	474	3918
651	474	3919
652	474	3920
653	475	3921
654	475	3922
655	475	3923
656	475	3924
657	475	3925
658	475	3926
659	475	3927
660	475	3928
661	476	3936
662	476	3937
663	476	3938
664	476	3939
665	476	3929
666	476	3930
667	476	3931
668	476	3932
669	476	3933
670	476	3934
671	476	3935
672	477	3940
673	477	3941
674	477	3942
675	477	3943
676	477	3944
677	477	3945
678	477	3946
679	477	3947
680	477	3948
681	478	3949
682	478	3950
683	478	3951
684	478	3952
685	478	3953
686	478	3954
687	478	3955
688	479	3956
689	479	3957
690	479	3958
691	479	3959
692	479	3960
693	479	3961
694	479	3962
695	479	3963
696	479	3964
697	479	3965
698	479	3966
699	479	3967
700	480	3968
701	480	3969
702	480	3970
703	480	3971
704	480	3972
705	480	3973
706	481	3974
707	481	3975
708	481	3976
709	481	3977
710	481	3978
711	481	3979
712	481	3980
713	481	3981
714	482	3982
715	482	3983
716	482	3984
717	482	3985
718	482	3986
719	482	3987
720	482	3988
721	482	3989
722	482	3990
723	483	3991
724	483	3992
725	483	3993
726	483	3994
727	483	3995
728	483	3996
729	484	4000
730	484	4001
731	484	4002
732	484	4003
733	484	3997
734	484	3998
735	484	3999
736	485	4004
737	485	4005
738	485	4006
739	485	4007
740	485	4008
741	485	4009
742	485	4010
743	485	4011
744	485	4012
745	486	4013
746	486	4014
747	486	4015
748	486	4016
749	486	4017
750	486	4018
751	487	4019
752	487	4020
753	487	4021
754	487	4022
755	487	4023
756	487	4024
757	487	4025
758	488	4032
759	488	4033
760	488	4034
761	488	4026
762	488	4027
763	488	4028
764	488	4029
765	488	4030
766	488	4031
767	489	4035
768	489	4036
769	489	4037
770	490	4038
771	490	4039
772	490	4040
773	490	4041
774	490	4042
775	490	4043
776	490	4044
777	490	4045
778	491	4046
779	491	4047
780	491	4048
781	491	4049
782	491	4050
783	491	4051
784	492	4052
785	492	4053
786	492	4054
787	492	4055
788	493	4056
789	493	4057
790	493	4058
791	493	4059
792	493	4060
793	493	4061
794	493	4062
795	494	4064
796	494	4065
797	494	4066
798	494	4067
799	494	4068
800	494	4069
801	494	4063
802	495	4070
803	495	4071
804	495	4072
805	495	4073
806	495	4074
807	495	4075
808	495	4076
809	496	4077
810	496	4078
811	496	4079
812	496	4080
813	496	4081
814	496	4082
815	496	4083
816	496	4084
817	496	4085
818	496	4086
819	496	4087
820	497	4096
821	497	4097
822	497	4088
823	497	4089
824	497	4090
825	497	4091
826	497	4092
827	497	4093
828	497	4094
829	497	4095
830	498	4098
831	498	4099
832	498	4100
833	498	4101
834	498	4102
835	499	4103
836	499	4104
837	499	4105
838	499	4106
839	499	4107
840	499	4108
841	499	4109
842	500	4110
843	500	4111
844	500	4112
845	500	4113
846	500	4114
847	500	4115
848	500	4116
849	500	4117
850	501	4118
851	501	4119
852	501	4120
853	501	4121
854	501	4122
855	501	4123
856	501	4124
857	501	4125
858	502	4128
859	502	4129
860	502	4130
861	502	4131
862	502	4132
863	502	4133
864	502	4126
865	502	4127
866	503	4134
867	503	4135
868	503	4136
869	503	4137
870	503	4138
871	503	4139
872	503	4140
873	503	4141
874	503	4142
875	503	4143
876	503	4144
877	504	4145
878	504	4146
879	505	4147
880	505	4148
881	505	4149
882	505	4150
883	505	4151
884	505	4152
885	505	4153
886	506	4154
887	506	4155
888	506	4156
889	506	4157
890	506	4158
891	507	4160
892	507	4161
893	507	4162
894	507	4163
895	507	4159
896	508	4164
897	508	4165
898	508	4166
899	508	4167
900	508	4168
901	508	4169
902	508	4170
903	509	4171
904	509	4172
905	509	4173
906	509	4174
907	509	4175
908	509	4176
909	509	4177
910	509	4178
911	510	4179
912	510	4180
913	510	4181
914	510	4182
915	510	4183
916	511	4192
917	511	4184
918	511	4185
919	511	4186
920	511	4187
921	511	4188
922	511	4189
923	511	4190
924	511	4191
925	512	4193
926	512	4194
927	512	4195
928	512	4196
929	512	4197
930	512	4198
931	512	4199
932	512	4200
933	513	4201
934	513	4202
935	513	4203
936	513	4204
937	513	4205
938	513	4206
939	514	4207
940	514	4208
941	514	4209
942	514	4210
943	514	4211
944	514	4212
945	514	4213
946	514	4214
947	515	4215
948	515	4216
949	515	4217
950	515	4218
951	515	4219
952	515	4220
953	515	4221
954	515	4222
955	515	4223
956	516	4224
957	516	4225
958	516	4226
959	516	4227
960	516	4228
961	516	4229
962	516	4230
963	516	4231
964	516	4232
965	516	4233
966	516	4234
967	516	4235
968	517	4236
969	517	4237
970	517	4238
971	517	4239
972	517	4240
973	517	4241
974	517	4242
975	518	4256
976	518	4257
977	518	4243
978	518	4244
979	518	4245
980	518	4246
981	518	4247
982	518	4248
983	518	4249
984	518	4250
985	518	4251
986	518	4252
987	518	4253
988	518	4254
989	518	4255
\.


--
-- Data for Name: entity_app_timelinesolicity; Type: TABLE DATA; Schema: public; Owner: auth_user
--

--
-- Data for Name: entity_app_transparencyactive; Type: TABLE DATA; Schema: public; Owner: auth_user
--


--
-- Data for Name: entity_app_typeformats; Type: TABLE DATA; Schema: public; Owner: auth_user
--

COPY public.entity_app_typeformats (id, created_at, updated_at, deleted, deleted_at, ip, name, description, user_created_id, user_deleted_id, user_updated_id) FROM stdin;
\.


--
-- Data for Name: entity_app_typepublication; Type: TABLE DATA; Schema: public; Owner: auth_user
--

COPY public.entity_app_typepublication (id, created_at, updated_at, deleted, deleted_at, ip, name, description, is_active, user_created_id, user_deleted_id, user_updated_id, code) FROM stdin;
\.


--
-- Name: activity_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.activity_log_id_seq', 1, false);


--
-- Name: app_admin_accesstoinformation_establishment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.app_admin_accesstoinformation_establishment_id_seq', 113, true);


--
-- Name: app_admin_accesstoinformation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.app_admin_accesstoinformation_id_seq', 113, true);


--
-- Name: app_admin_configuration_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.app_admin_configuration_id_seq', 5, true);


--
-- Name: app_admin_email_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.app_admin_email_id_seq', 1123, true);


--
-- Name: app_admin_establishment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.app_admin_establishment_id_seq', 113, true);


--
-- Name: app_admin_formfields_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.app_admin_formfields_id_seq', 50, true);


--
-- Name: app_admin_frequentlyaskedquestions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.app_admin_frequentlyaskedquestions_id_seq', 7, true);


--
-- Name: app_admin_functionorganization_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.app_admin_functionorganization_id_seq', 24, true);


--
-- Name: app_admin_lawenforcement_establishment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.app_admin_lawenforcement_establishment_id_seq', 13, true);


--
-- Name: app_admin_lawenforcement_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.app_admin_lawenforcement_id_seq', 13, true);


--
-- Name: app_admin_normativedocument_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.app_admin_normativedocument_id_seq', 7, true);


--
-- Name: app_admin_pedagogyarea_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.app_admin_pedagogyarea_id_seq', 1, true);


--
-- Name: app_admin_tutorialvideo_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.app_admin_tutorialvideo_id_seq', 7, true);


--
-- Name: app_admin_typeinstitution_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.app_admin_typeinstitution_id_seq', 168, true);


--
-- Name: app_admin_typeorganization_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.app_admin_typeorganization_id_seq', 5, true);


--
-- Name: app_admin_userestablishment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.app_admin_userestablishment_id_seq', 48, true);


--
-- Name: auth_group_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.auth_group_id_seq', 6, true);


--
-- Name: auth_group_permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.auth_group_permissions_id_seq', 127, true);


--
-- Name: auth_permission_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.auth_permission_id_seq', 232, true);


--
-- Name: auth_person_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.auth_person_id_seq', 130, true);


--
-- Name: auth_user_groups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.auth_user_groups_id_seq', 142, true);


--
-- Name: auth_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.auth_user_id_seq', 133, true);


--
-- Name: auth_user_user_permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.auth_user_user_permissions_id_seq', 1, false);


--
-- Name: django_admin_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.django_admin_log_id_seq', 1, false);


--
-- Name: django_celery_beat_clockedschedule_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.django_celery_beat_clockedschedule_id_seq', 1, false);


--
-- Name: django_celery_beat_crontabschedule_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.django_celery_beat_crontabschedule_id_seq', 1, false);


--
-- Name: django_celery_beat_intervalschedule_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.django_celery_beat_intervalschedule_id_seq', 1, false);


--
-- Name: django_celery_beat_periodictask_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.django_celery_beat_periodictask_id_seq', 1, false);


--
-- Name: django_celery_beat_solarschedule_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.django_celery_beat_solarschedule_id_seq', 1, false);


--
-- Name: django_content_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.django_content_type_id_seq', 52, true);


--
-- Name: django_migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.django_migrations_id_seq', 98, true);


--
-- Name: django_rest_passwordreset_resetpasswordtoken_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.django_rest_passwordreset_resetpasswordtoken_id_seq', 3, true);


--
-- Name: entity_app_attachment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.entity_app_attachment_id_seq', 1, false);


--
-- Name: entity_app_category_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.entity_app_category_id_seq', 1, false);


--
-- Name: entity_app_columnfile_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.entity_app_columnfile_id_seq', 4257, true);


--
-- Name: entity_app_establishmentnumeral_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.entity_app_establishmentnumeral_id_seq', 2835, true);


--
-- Name: entity_app_extension_attachments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.entity_app_extension_attachments_id_seq', 1, false);


--
-- Name: entity_app_extension_files_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.entity_app_extension_files_id_seq', 1, false);


--
-- Name: entity_app_extension_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.entity_app_extension_id_seq', 1, false);


--
-- Name: entity_app_filepublication_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.entity_app_filepublication_id_seq', 304, true);


--
-- Name: entity_app_insistency_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.entity_app_insistency_id_seq', 8, true);


--
-- Name: entity_app_numeral_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.entity_app_numeral_id_seq', 122, true);


--
-- Name: entity_app_numeral_templates_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.entity_app_numeral_templates_id_seq', 117, true);


--
-- Name: entity_app_publication_attachment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.entity_app_publication_attachment_id_seq', 1, false);


--
-- Name: entity_app_publication_file_publication_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.entity_app_publication_file_publication_id_seq', 1, false);


--
-- Name: entity_app_publication_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.entity_app_publication_id_seq', 1, false);


--
-- Name: entity_app_publication_tag_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.entity_app_publication_tag_id_seq', 1, false);


--
-- Name: entity_app_publication_type_format_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.entity_app_publication_type_format_id_seq', 1, false);


--
-- Name: entity_app_solicity_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.entity_app_solicity_id_seq', 50, true);


--
-- Name: entity_app_solicityresponse_attachments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.entity_app_solicityresponse_attachments_id_seq', 1, false);


--
-- Name: entity_app_solicityresponse_files_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.entity_app_solicityresponse_files_id_seq', 4, true);


--
-- Name: entity_app_solicityresponse_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.entity_app_solicityresponse_id_seq', 8, true);


--
-- Name: entity_app_tag_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.entity_app_tag_id_seq', 1, false);


--
-- Name: entity_app_templatefile_columns_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.entity_app_templatefile_columns_id_seq', 989, true);


--
-- Name: entity_app_templatefile_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.entity_app_templatefile_id_seq', 518, true);


--
-- Name: entity_app_timelinesolicity_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.entity_app_timelinesolicity_id_seq', 110, true);


--
-- Name: entity_app_transparencyactive_files_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.entity_app_transparencyactive_files_id_seq', 288, true);


--
-- Name: entity_app_transparencyactive_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.entity_app_transparencyactive_id_seq', 44, true);


--
-- Name: entity_app_transparencycolab_files_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.entity_app_transparencycolab_files_id_seq', 3, true);


--
-- Name: entity_app_transparencycolab_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.entity_app_transparencycolab_id_seq', 1, true);


--
-- Name: entity_app_transparencyfocal_files_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.entity_app_transparencyfocal_files_id_seq', 6, true);


--
-- Name: entity_app_transparencyfocal_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.entity_app_transparencyfocal_id_seq', 2, true);


--
-- Name: entity_app_typeformats_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.entity_app_typeformats_id_seq', 1, false);


--
-- Name: entity_app_typepublication_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_user
--

SELECT pg_catalog.setval('public.entity_app_typepublication_id_seq', 1, false);


--
-- Name: activity_log activity_log_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.activity_log
    ADD CONSTRAINT activity_log_pkey PRIMARY KEY (id);


--
-- Name: app_admin_accesstoinformation_establishment app_admin_accesstoinform_accesstoinformation_id_e_ae4a705d_uniq; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_accesstoinformation_establishment
    ADD CONSTRAINT app_admin_accesstoinform_accesstoinformation_id_e_ae4a705d_uniq UNIQUE (accesstoinformation_id, establishment_id);


--
-- Name: app_admin_accesstoinformation_establishment app_admin_accesstoinformation_establishment_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_accesstoinformation_establishment
    ADD CONSTRAINT app_admin_accesstoinformation_establishment_pkey PRIMARY KEY (id);


--
-- Name: app_admin_accesstoinformation app_admin_accesstoinformation_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_accesstoinformation
    ADD CONSTRAINT app_admin_accesstoinformation_pkey PRIMARY KEY (id);


--
-- Name: app_admin_configuration app_admin_configuration_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_configuration
    ADD CONSTRAINT app_admin_configuration_pkey PRIMARY KEY (id);


--
-- Name: app_admin_email app_admin_email_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_email
    ADD CONSTRAINT app_admin_email_pkey PRIMARY KEY (id);


--
-- Name: app_admin_establishment app_admin_establishment_code_ffc22b72_uniq; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_establishment
    ADD CONSTRAINT app_admin_establishment_code_ffc22b72_uniq UNIQUE (code);


--
-- Name: app_admin_establishment app_admin_establishment_identification_key; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_establishment
    ADD CONSTRAINT app_admin_establishment_identification_key UNIQUE (identification);


--
-- Name: app_admin_establishment app_admin_establishment_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_establishment
    ADD CONSTRAINT app_admin_establishment_pkey PRIMARY KEY (id);


--
-- Name: app_admin_establishment app_admin_establishment_slug_key; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_establishment
    ADD CONSTRAINT app_admin_establishment_slug_key UNIQUE (slug);


--
-- Name: app_admin_formfields app_admin_formfields_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_formfields
    ADD CONSTRAINT app_admin_formfields_pkey PRIMARY KEY (id);


--
-- Name: app_admin_frequentlyaskedquestions app_admin_frequentlyaskedquestions_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_frequentlyaskedquestions
    ADD CONSTRAINT app_admin_frequentlyaskedquestions_pkey PRIMARY KEY (id);


--
-- Name: app_admin_functionorganization app_admin_functionorganization_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_functionorganization
    ADD CONSTRAINT app_admin_functionorganization_pkey PRIMARY KEY (id);


--
-- Name: app_admin_lawenforcement_establishment app_admin_lawenforcement_establishment_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_lawenforcement_establishment
    ADD CONSTRAINT app_admin_lawenforcement_establishment_pkey PRIMARY KEY (id);


--
-- Name: app_admin_lawenforcement_establishment app_admin_lawenforcement_lawenforcement_id_establ_eb316632_uniq; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_lawenforcement_establishment
    ADD CONSTRAINT app_admin_lawenforcement_lawenforcement_id_establ_eb316632_uniq UNIQUE (lawenforcement_id, establishment_id);


--
-- Name: app_admin_lawenforcement app_admin_lawenforcement_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_lawenforcement
    ADD CONSTRAINT app_admin_lawenforcement_pkey PRIMARY KEY (id);


--
-- Name: app_admin_normativedocument app_admin_normativedocument_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_normativedocument
    ADD CONSTRAINT app_admin_normativedocument_pkey PRIMARY KEY (id);


--
-- Name: app_admin_pedagogyarea app_admin_pedagogyarea_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_pedagogyarea
    ADD CONSTRAINT app_admin_pedagogyarea_pkey PRIMARY KEY (id);


--
-- Name: app_admin_tutorialvideo app_admin_tutorialvideo_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_tutorialvideo
    ADD CONSTRAINT app_admin_tutorialvideo_pkey PRIMARY KEY (id);


--
-- Name: app_admin_typeinstitution app_admin_typeinstitution_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_typeinstitution
    ADD CONSTRAINT app_admin_typeinstitution_pkey PRIMARY KEY (id);


--
-- Name: app_admin_typeorganization app_admin_typeorganization_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_typeorganization
    ADD CONSTRAINT app_admin_typeorganization_pkey PRIMARY KEY (id);


--
-- Name: app_admin_userestablishment app_admin_userestablishment_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_userestablishment
    ADD CONSTRAINT app_admin_userestablishment_pkey PRIMARY KEY (id);


--
-- Name: auth_group auth_group_name_key; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.auth_group
    ADD CONSTRAINT auth_group_name_key UNIQUE (name);


--
-- Name: auth_group_permissions auth_group_permissions_group_id_permission_id_0cd325b0_uniq; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_group_id_permission_id_0cd325b0_uniq UNIQUE (group_id, permission_id);


--
-- Name: auth_group_permissions auth_group_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_pkey PRIMARY KEY (id);


--
-- Name: auth_group auth_group_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.auth_group
    ADD CONSTRAINT auth_group_pkey PRIMARY KEY (id);


--
-- Name: auth_permission auth_permission_content_type_id_codename_01ab375a_uniq; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_content_type_id_codename_01ab375a_uniq UNIQUE (content_type_id, codename);


--
-- Name: auth_permission auth_permission_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_pkey PRIMARY KEY (id);


--
-- Name: auth_person auth_person_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.auth_person
    ADD CONSTRAINT auth_person_pkey PRIMARY KEY (id);


--
-- Name: auth_person auth_person_user_id_key; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.auth_person
    ADD CONSTRAINT auth_person_user_id_key UNIQUE (user_id);


--
-- Name: auth_user_groups auth_user_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.auth_user_groups
    ADD CONSTRAINT auth_user_groups_pkey PRIMARY KEY (id);


--
-- Name: auth_user_groups auth_user_groups_user_id_group_id_94350c0c_uniq; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.auth_user_groups
    ADD CONSTRAINT auth_user_groups_user_id_group_id_94350c0c_uniq UNIQUE (user_id, group_id);


--
-- Name: auth_user auth_user_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.auth_user
    ADD CONSTRAINT auth_user_pkey PRIMARY KEY (id);


--
-- Name: auth_user_user_permissions auth_user_user_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permissions_pkey PRIMARY KEY (id);


--
-- Name: auth_user_user_permissions auth_user_user_permissions_user_id_permission_id_14a6b632_uniq; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permissions_user_id_permission_id_14a6b632_uniq UNIQUE (user_id, permission_id);


--
-- Name: auth_user auth_user_username_key; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.auth_user
    ADD CONSTRAINT auth_user_username_key UNIQUE (username);


--
-- Name: django_admin_log django_admin_log_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_pkey PRIMARY KEY (id);


--
-- Name: django_celery_beat_clockedschedule django_celery_beat_clockedschedule_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.django_celery_beat_clockedschedule
    ADD CONSTRAINT django_celery_beat_clockedschedule_pkey PRIMARY KEY (id);


--
-- Name: django_celery_beat_crontabschedule django_celery_beat_crontabschedule_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.django_celery_beat_crontabschedule
    ADD CONSTRAINT django_celery_beat_crontabschedule_pkey PRIMARY KEY (id);


--
-- Name: django_celery_beat_intervalschedule django_celery_beat_intervalschedule_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.django_celery_beat_intervalschedule
    ADD CONSTRAINT django_celery_beat_intervalschedule_pkey PRIMARY KEY (id);


--
-- Name: django_celery_beat_periodictask django_celery_beat_periodictask_name_key; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.django_celery_beat_periodictask
    ADD CONSTRAINT django_celery_beat_periodictask_name_key UNIQUE (name);


--
-- Name: django_celery_beat_periodictask django_celery_beat_periodictask_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.django_celery_beat_periodictask
    ADD CONSTRAINT django_celery_beat_periodictask_pkey PRIMARY KEY (id);


--
-- Name: django_celery_beat_periodictasks django_celery_beat_periodictasks_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.django_celery_beat_periodictasks
    ADD CONSTRAINT django_celery_beat_periodictasks_pkey PRIMARY KEY (ident);


--
-- Name: django_celery_beat_solarschedule django_celery_beat_solar_event_latitude_longitude_ba64999a_uniq; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.django_celery_beat_solarschedule
    ADD CONSTRAINT django_celery_beat_solar_event_latitude_longitude_ba64999a_uniq UNIQUE (event, latitude, longitude);


--
-- Name: django_celery_beat_solarschedule django_celery_beat_solarschedule_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.django_celery_beat_solarschedule
    ADD CONSTRAINT django_celery_beat_solarschedule_pkey PRIMARY KEY (id);


--
-- Name: django_content_type django_content_type_app_label_model_76bd3d3b_uniq; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.django_content_type
    ADD CONSTRAINT django_content_type_app_label_model_76bd3d3b_uniq UNIQUE (app_label, model);


--
-- Name: django_content_type django_content_type_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.django_content_type
    ADD CONSTRAINT django_content_type_pkey PRIMARY KEY (id);


--
-- Name: django_migrations django_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.django_migrations
    ADD CONSTRAINT django_migrations_pkey PRIMARY KEY (id);


--
-- Name: django_rest_passwordreset_resetpasswordtoken django_rest_passwordreset_resetpasswordtoken_key_f1b65873_uniq; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.django_rest_passwordreset_resetpasswordtoken
    ADD CONSTRAINT django_rest_passwordreset_resetpasswordtoken_key_f1b65873_uniq UNIQUE (key);


--
-- Name: django_rest_passwordreset_resetpasswordtoken django_rest_passwordreset_resetpasswordtoken_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.django_rest_passwordreset_resetpasswordtoken
    ADD CONSTRAINT django_rest_passwordreset_resetpasswordtoken_pkey PRIMARY KEY (id);


--
-- Name: django_session django_session_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.django_session
    ADD CONSTRAINT django_session_pkey PRIMARY KEY (session_key);


--
-- Name: entity_app_attachment entity_app_attachment_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_attachment
    ADD CONSTRAINT entity_app_attachment_pkey PRIMARY KEY (id);


--
-- Name: entity_app_category entity_app_category_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_category
    ADD CONSTRAINT entity_app_category_pkey PRIMARY KEY (id);


--
-- Name: entity_app_columnfile entity_app_columnfile_code_key; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_columnfile
    ADD CONSTRAINT entity_app_columnfile_code_key UNIQUE (code);


--
-- Name: entity_app_columnfile entity_app_columnfile_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_columnfile
    ADD CONSTRAINT entity_app_columnfile_pkey PRIMARY KEY (id);


--
-- Name: entity_app_establishmentnumeral entity_app_establishment_establishment_id_numeral_ac26d92a_uniq; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_establishmentnumeral
    ADD CONSTRAINT entity_app_establishment_establishment_id_numeral_ac26d92a_uniq UNIQUE (establishment_id, numeral_id);


--
-- Name: entity_app_establishmentnumeral entity_app_establishmentnumeral_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_establishmentnumeral
    ADD CONSTRAINT entity_app_establishmentnumeral_pkey PRIMARY KEY (id);


--
-- Name: entity_app_extension_attachments entity_app_extension_att_extension_id_attachment__c6e8e989_uniq; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_extension_attachments
    ADD CONSTRAINT entity_app_extension_att_extension_id_attachment__c6e8e989_uniq UNIQUE (extension_id, attachment_id);


--
-- Name: entity_app_extension_attachments entity_app_extension_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_extension_attachments
    ADD CONSTRAINT entity_app_extension_attachments_pkey PRIMARY KEY (id);


--
-- Name: entity_app_extension_files entity_app_extension_fil_extension_id_filepublica_bf4772ae_uniq; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_extension_files
    ADD CONSTRAINT entity_app_extension_fil_extension_id_filepublica_bf4772ae_uniq UNIQUE (extension_id, filepublication_id);


--
-- Name: entity_app_extension_files entity_app_extension_files_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_extension_files
    ADD CONSTRAINT entity_app_extension_files_pkey PRIMARY KEY (id);


--
-- Name: entity_app_extension entity_app_extension_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_extension
    ADD CONSTRAINT entity_app_extension_pkey PRIMARY KEY (id);


--
-- Name: entity_app_filepublication entity_app_filepublication_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_filepublication
    ADD CONSTRAINT entity_app_filepublication_pkey PRIMARY KEY (id);


--
-- Name: entity_app_insistency entity_app_insistency_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_insistency
    ADD CONSTRAINT entity_app_insistency_pkey PRIMARY KEY (id);


--
-- Name: entity_app_numeral entity_app_numeral_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_numeral
    ADD CONSTRAINT entity_app_numeral_pkey PRIMARY KEY (id);


--
-- Name: entity_app_numeral_templates entity_app_numeral_templ_numeral_id_templatefile__73dbc7b4_uniq; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_numeral_templates
    ADD CONSTRAINT entity_app_numeral_templ_numeral_id_templatefile__73dbc7b4_uniq UNIQUE (numeral_id, templatefile_id);


--
-- Name: entity_app_numeral_templates entity_app_numeral_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_numeral_templates
    ADD CONSTRAINT entity_app_numeral_templates_pkey PRIMARY KEY (id);


--
-- Name: entity_app_publication_attachment entity_app_publication_a_publication_id_attachmen_1b0f7b69_uniq; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_publication_attachment
    ADD CONSTRAINT entity_app_publication_a_publication_id_attachmen_1b0f7b69_uniq UNIQUE (publication_id, attachment_id);


--
-- Name: entity_app_publication_attachment entity_app_publication_attachment_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_publication_attachment
    ADD CONSTRAINT entity_app_publication_attachment_pkey PRIMARY KEY (id);


--
-- Name: entity_app_publication_file_publication entity_app_publication_f_publication_id_filepubli_5ee03506_uniq; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_publication_file_publication
    ADD CONSTRAINT entity_app_publication_f_publication_id_filepubli_5ee03506_uniq UNIQUE (publication_id, filepublication_id);


--
-- Name: entity_app_publication_file_publication entity_app_publication_file_publication_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_publication_file_publication
    ADD CONSTRAINT entity_app_publication_file_publication_pkey PRIMARY KEY (id);


--
-- Name: entity_app_publication entity_app_publication_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_publication
    ADD CONSTRAINT entity_app_publication_pkey PRIMARY KEY (id);


--
-- Name: entity_app_publication entity_app_publication_slug_key; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_publication
    ADD CONSTRAINT entity_app_publication_slug_key UNIQUE (slug);


--
-- Name: entity_app_publication_type_format entity_app_publication_t_publication_id_typeforma_dfc257fc_uniq; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_publication_type_format
    ADD CONSTRAINT entity_app_publication_t_publication_id_typeforma_dfc257fc_uniq UNIQUE (publication_id, typeformats_id);


--
-- Name: entity_app_publication_tag entity_app_publication_tag_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_publication_tag
    ADD CONSTRAINT entity_app_publication_tag_pkey PRIMARY KEY (id);


--
-- Name: entity_app_publication_tag entity_app_publication_tag_publication_id_tag_id_d5c7812b_uniq; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_publication_tag
    ADD CONSTRAINT entity_app_publication_tag_publication_id_tag_id_d5c7812b_uniq UNIQUE (publication_id, tag_id);


--
-- Name: entity_app_publication_type_format entity_app_publication_type_format_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_publication_type_format
    ADD CONSTRAINT entity_app_publication_type_format_pkey PRIMARY KEY (id);


--
-- Name: entity_app_solicity entity_app_solicity_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_solicity
    ADD CONSTRAINT entity_app_solicity_pkey PRIMARY KEY (id);


--
-- Name: entity_app_solicityresponse_attachments entity_app_solicityrespo_solicityresponse_id_atta_d31696c4_uniq; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_solicityresponse_attachments
    ADD CONSTRAINT entity_app_solicityrespo_solicityresponse_id_atta_d31696c4_uniq UNIQUE (solicityresponse_id, attachment_id);


--
-- Name: entity_app_solicityresponse_files entity_app_solicityrespo_solicityresponse_id_file_ce021f0d_uniq; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_solicityresponse_files
    ADD CONSTRAINT entity_app_solicityrespo_solicityresponse_id_file_ce021f0d_uniq UNIQUE (solicityresponse_id, filepublication_id);


--
-- Name: entity_app_solicityresponse_attachments entity_app_solicityresponse_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_solicityresponse_attachments
    ADD CONSTRAINT entity_app_solicityresponse_attachments_pkey PRIMARY KEY (id);


--
-- Name: entity_app_solicityresponse_files entity_app_solicityresponse_files_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_solicityresponse_files
    ADD CONSTRAINT entity_app_solicityresponse_files_pkey PRIMARY KEY (id);


--
-- Name: entity_app_solicityresponse entity_app_solicityresponse_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_solicityresponse
    ADD CONSTRAINT entity_app_solicityresponse_pkey PRIMARY KEY (id);


--
-- Name: entity_app_tag entity_app_tag_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_tag
    ADD CONSTRAINT entity_app_tag_pkey PRIMARY KEY (id);


--
-- Name: entity_app_templatefile_columns entity_app_templatefile__templatefile_id_columnfi_f050728e_uniq; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_templatefile_columns
    ADD CONSTRAINT entity_app_templatefile__templatefile_id_columnfi_f050728e_uniq UNIQUE (templatefile_id, columnfile_id);


--
-- Name: entity_app_templatefile entity_app_templatefile_code_key; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_templatefile
    ADD CONSTRAINT entity_app_templatefile_code_key UNIQUE (code);


--
-- Name: entity_app_templatefile_columns entity_app_templatefile_columns_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_templatefile_columns
    ADD CONSTRAINT entity_app_templatefile_columns_pkey PRIMARY KEY (id);


--
-- Name: entity_app_templatefile entity_app_templatefile_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_templatefile
    ADD CONSTRAINT entity_app_templatefile_pkey PRIMARY KEY (id);


--
-- Name: entity_app_timelinesolicity entity_app_timelinesolicity_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_timelinesolicity
    ADD CONSTRAINT entity_app_timelinesolicity_pkey PRIMARY KEY (id);


--
-- Name: entity_app_transparencyactive entity_app_transparencya_establishment_id_numeral_cb54d24d_uniq; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_transparencyactive
    ADD CONSTRAINT entity_app_transparencya_establishment_id_numeral_cb54d24d_uniq UNIQUE (establishment_id, numeral_id, month, year);


--
-- Name: entity_app_transparencyactive_files entity_app_transparencya_transparencyactive_id_fi_4e6b86f8_uniq; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_transparencyactive_files
    ADD CONSTRAINT entity_app_transparencya_transparencyactive_id_fi_4e6b86f8_uniq UNIQUE (transparencyactive_id, filepublication_id);


--
-- Name: entity_app_transparencyactive_files entity_app_transparencyactive_files_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_transparencyactive_files
    ADD CONSTRAINT entity_app_transparencyactive_files_pkey PRIMARY KEY (id);


--
-- Name: entity_app_transparencyactive entity_app_transparencyactive_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_transparencyactive
    ADD CONSTRAINT entity_app_transparencyactive_pkey PRIMARY KEY (id);


--
-- Name: entity_app_transparencyactive entity_app_transparencyactive_slug_key; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_transparencyactive
    ADD CONSTRAINT entity_app_transparencyactive_slug_key UNIQUE (slug);


--
-- Name: entity_app_transparencycolab_files entity_app_transparencyc_transparencycolab_id_fil_bed7be9b_uniq; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_transparencycolab_files
    ADD CONSTRAINT entity_app_transparencyc_transparencycolab_id_fil_bed7be9b_uniq UNIQUE (transparencycolab_id, filepublication_id);


--
-- Name: entity_app_transparencycolab_files entity_app_transparencycolab_files_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_transparencycolab_files
    ADD CONSTRAINT entity_app_transparencycolab_files_pkey PRIMARY KEY (id);


--
-- Name: entity_app_transparencycolab entity_app_transparencycolab_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_transparencycolab
    ADD CONSTRAINT entity_app_transparencycolab_pkey PRIMARY KEY (id);


--
-- Name: entity_app_transparencycolab entity_app_transparencycolab_slug_key; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_transparencycolab
    ADD CONSTRAINT entity_app_transparencycolab_slug_key UNIQUE (slug);


--
-- Name: entity_app_transparencyfocal_files entity_app_transparencyf_transparencyfocal_id_fil_e0d33d8f_uniq; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_transparencyfocal_files
    ADD CONSTRAINT entity_app_transparencyf_transparencyfocal_id_fil_e0d33d8f_uniq UNIQUE (transparencyfocal_id, filepublication_id);


--
-- Name: entity_app_transparencyfocal_files entity_app_transparencyfocal_files_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_transparencyfocal_files
    ADD CONSTRAINT entity_app_transparencyfocal_files_pkey PRIMARY KEY (id);


--
-- Name: entity_app_transparencyfocal entity_app_transparencyfocal_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_transparencyfocal
    ADD CONSTRAINT entity_app_transparencyfocal_pkey PRIMARY KEY (id);


--
-- Name: entity_app_transparencyfocal entity_app_transparencyfocal_slug_key; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_transparencyfocal
    ADD CONSTRAINT entity_app_transparencyfocal_slug_key UNIQUE (slug);


--
-- Name: entity_app_typeformats entity_app_typeformats_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_typeformats
    ADD CONSTRAINT entity_app_typeformats_pkey PRIMARY KEY (id);


--
-- Name: entity_app_typepublication entity_app_typepublication_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_typepublication
    ADD CONSTRAINT entity_app_typepublication_pkey PRIMARY KEY (id);


--
-- Name: activity_log_user_created_id_c1016fbc; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX activity_log_user_created_id_c1016fbc ON public.activity_log USING btree (user_created_id);


--
-- Name: activity_log_user_deleted_id_20653c23; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX activity_log_user_deleted_id_20653c23 ON public.activity_log USING btree (user_deleted_id);


--
-- Name: activity_log_user_id_f1e09264; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX activity_log_user_id_f1e09264 ON public.activity_log USING btree (user_id);


--
-- Name: activity_log_user_updated_id_61004408; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX activity_log_user_updated_id_61004408 ON public.activity_log USING btree (user_updated_id);


--
-- Name: app_admin_accesstoinformat_accesstoinformation_id_617f481c; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX app_admin_accesstoinformat_accesstoinformation_id_617f481c ON public.app_admin_accesstoinformation_establishment USING btree (accesstoinformation_id);


--
-- Name: app_admin_accesstoinformat_establishment_id_804c84a0; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX app_admin_accesstoinformat_establishment_id_804c84a0 ON public.app_admin_accesstoinformation_establishment USING btree (establishment_id);


--
-- Name: app_admin_accesstoinformation_user_created_id_1186aec6; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX app_admin_accesstoinformation_user_created_id_1186aec6 ON public.app_admin_accesstoinformation USING btree (user_created_id);


--
-- Name: app_admin_accesstoinformation_user_deleted_id_3aa70809; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX app_admin_accesstoinformation_user_deleted_id_3aa70809 ON public.app_admin_accesstoinformation USING btree (user_deleted_id);


--
-- Name: app_admin_accesstoinformation_user_updated_id_3a28d470; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX app_admin_accesstoinformation_user_updated_id_3a28d470 ON public.app_admin_accesstoinformation USING btree (user_updated_id);


--
-- Name: app_admin_configuration_user_created_id_53e5f321; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX app_admin_configuration_user_created_id_53e5f321 ON public.app_admin_configuration USING btree (user_created_id);


--
-- Name: app_admin_configuration_user_deleted_id_8e71c71e; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX app_admin_configuration_user_deleted_id_8e71c71e ON public.app_admin_configuration USING btree (user_deleted_id);


--
-- Name: app_admin_configuration_user_updated_id_80ff2deb; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX app_admin_configuration_user_updated_id_80ff2deb ON public.app_admin_configuration USING btree (user_updated_id);


--
-- Name: app_admin_email_user_created_id_c68cc37b; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX app_admin_email_user_created_id_c68cc37b ON public.app_admin_email USING btree (user_created_id);


--
-- Name: app_admin_email_user_deleted_id_65d9893d; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX app_admin_email_user_deleted_id_65d9893d ON public.app_admin_email USING btree (user_deleted_id);


--
-- Name: app_admin_email_user_updated_id_90ffa4b2; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX app_admin_email_user_updated_id_90ffa4b2 ON public.app_admin_email USING btree (user_updated_id);


--
-- Name: app_admin_establishment_code_ffc22b72_like; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX app_admin_establishment_code_ffc22b72_like ON public.app_admin_establishment USING btree (code varchar_pattern_ops);


--
-- Name: app_admin_establishment_function_organization_id_db4e6f14; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX app_admin_establishment_function_organization_id_db4e6f14 ON public.app_admin_establishment USING btree (function_organization_id);


--
-- Name: app_admin_establishment_identification_b2bc0179_like; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX app_admin_establishment_identification_b2bc0179_like ON public.app_admin_establishment USING btree (identification varchar_pattern_ops);


--
-- Name: app_admin_establishment_slug_db13a5f1_like; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX app_admin_establishment_slug_db13a5f1_like ON public.app_admin_establishment USING btree (slug varchar_pattern_ops);


--
-- Name: app_admin_establishment_type_institution_id_53d2c03a; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX app_admin_establishment_type_institution_id_53d2c03a ON public.app_admin_establishment USING btree (type_institution_id);


--
-- Name: app_admin_establishment_type_organization_id_81b0f49a; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX app_admin_establishment_type_organization_id_81b0f49a ON public.app_admin_establishment USING btree (type_organization_id);


--
-- Name: app_admin_establishment_user_created_id_1bbdf6ce; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX app_admin_establishment_user_created_id_1bbdf6ce ON public.app_admin_establishment USING btree (user_created_id);


--
-- Name: app_admin_establishment_user_deleted_id_21e9a202; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX app_admin_establishment_user_deleted_id_21e9a202 ON public.app_admin_establishment USING btree (user_deleted_id);


--
-- Name: app_admin_establishment_user_updated_id_4a3ef19d; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX app_admin_establishment_user_updated_id_4a3ef19d ON public.app_admin_establishment USING btree (user_updated_id);


--
-- Name: app_admin_formfields_content_type_id_8b9da3f1; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX app_admin_formfields_content_type_id_8b9da3f1 ON public.app_admin_formfields USING btree (content_type_id);


--
-- Name: app_admin_formfields_user_created_id_fbf6f550; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX app_admin_formfields_user_created_id_fbf6f550 ON public.app_admin_formfields USING btree (user_created_id);


--
-- Name: app_admin_formfields_user_deleted_id_01e9b60d; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX app_admin_formfields_user_deleted_id_01e9b60d ON public.app_admin_formfields USING btree (user_deleted_id);


--
-- Name: app_admin_formfields_user_updated_id_545660f1; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX app_admin_formfields_user_updated_id_545660f1 ON public.app_admin_formfields USING btree (user_updated_id);


--
-- Name: app_admin_frequentlyaskedquestions_pedagogy_area_id_2baf9462; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX app_admin_frequentlyaskedquestions_pedagogy_area_id_2baf9462 ON public.app_admin_frequentlyaskedquestions USING btree (pedagogy_area_id);


--
-- Name: app_admin_frequentlyaskedquestions_user_created_id_ecb218e3; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX app_admin_frequentlyaskedquestions_user_created_id_ecb218e3 ON public.app_admin_frequentlyaskedquestions USING btree (user_created_id);


--
-- Name: app_admin_frequentlyaskedquestions_user_deleted_id_e7e61107; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX app_admin_frequentlyaskedquestions_user_deleted_id_e7e61107 ON public.app_admin_frequentlyaskedquestions USING btree (user_deleted_id);


--
-- Name: app_admin_frequentlyaskedquestions_user_updated_id_e89dd228; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX app_admin_frequentlyaskedquestions_user_updated_id_e89dd228 ON public.app_admin_frequentlyaskedquestions USING btree (user_updated_id);


--
-- Name: app_admin_functionorganization_user_created_id_b96aecc1; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX app_admin_functionorganization_user_created_id_b96aecc1 ON public.app_admin_functionorganization USING btree (user_created_id);


--
-- Name: app_admin_functionorganization_user_deleted_id_b349ceeb; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX app_admin_functionorganization_user_deleted_id_b349ceeb ON public.app_admin_functionorganization USING btree (user_deleted_id);


--
-- Name: app_admin_functionorganization_user_updated_id_52fcbc54; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX app_admin_functionorganization_user_updated_id_52fcbc54 ON public.app_admin_functionorganization USING btree (user_updated_id);


--
-- Name: app_admin_lawenforcement_e_establishment_id_86274a9a; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX app_admin_lawenforcement_e_establishment_id_86274a9a ON public.app_admin_lawenforcement_establishment USING btree (establishment_id);


--
-- Name: app_admin_lawenforcement_e_lawenforcement_id_d933c1fc; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX app_admin_lawenforcement_e_lawenforcement_id_d933c1fc ON public.app_admin_lawenforcement_establishment USING btree (lawenforcement_id);


--
-- Name: app_admin_lawenforcement_user_created_id_e132fbab; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX app_admin_lawenforcement_user_created_id_e132fbab ON public.app_admin_lawenforcement USING btree (user_created_id);


--
-- Name: app_admin_lawenforcement_user_deleted_id_acd10682; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX app_admin_lawenforcement_user_deleted_id_acd10682 ON public.app_admin_lawenforcement USING btree (user_deleted_id);


--
-- Name: app_admin_lawenforcement_user_updated_id_bb043648; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX app_admin_lawenforcement_user_updated_id_bb043648 ON public.app_admin_lawenforcement USING btree (user_updated_id);


--
-- Name: app_admin_normativedocument_pedagogy_area_id_4edb267c; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX app_admin_normativedocument_pedagogy_area_id_4edb267c ON public.app_admin_normativedocument USING btree (pedagogy_area_id);


--
-- Name: app_admin_normativedocument_user_created_id_3356e257; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX app_admin_normativedocument_user_created_id_3356e257 ON public.app_admin_normativedocument USING btree (user_created_id);


--
-- Name: app_admin_normativedocument_user_deleted_id_9b2664c1; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX app_admin_normativedocument_user_deleted_id_9b2664c1 ON public.app_admin_normativedocument USING btree (user_deleted_id);


--
-- Name: app_admin_normativedocument_user_updated_id_7df8442b; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX app_admin_normativedocument_user_updated_id_7df8442b ON public.app_admin_normativedocument USING btree (user_updated_id);


--
-- Name: app_admin_pedagogyarea_user_created_id_552f1ea8; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX app_admin_pedagogyarea_user_created_id_552f1ea8 ON public.app_admin_pedagogyarea USING btree (user_created_id);


--
-- Name: app_admin_pedagogyarea_user_deleted_id_c25bd2b8; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX app_admin_pedagogyarea_user_deleted_id_c25bd2b8 ON public.app_admin_pedagogyarea USING btree (user_deleted_id);


--
-- Name: app_admin_pedagogyarea_user_updated_id_947c92b9; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX app_admin_pedagogyarea_user_updated_id_947c92b9 ON public.app_admin_pedagogyarea USING btree (user_updated_id);


--
-- Name: app_admin_tutorialvideo_pedagogy_area_id_8d068ecb; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX app_admin_tutorialvideo_pedagogy_area_id_8d068ecb ON public.app_admin_tutorialvideo USING btree (pedagogy_area_id);


--
-- Name: app_admin_tutorialvideo_user_created_id_e74b5c9f; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX app_admin_tutorialvideo_user_created_id_e74b5c9f ON public.app_admin_tutorialvideo USING btree (user_created_id);


--
-- Name: app_admin_tutorialvideo_user_deleted_id_30f1dede; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX app_admin_tutorialvideo_user_deleted_id_30f1dede ON public.app_admin_tutorialvideo USING btree (user_deleted_id);


--
-- Name: app_admin_tutorialvideo_user_updated_id_f63aa4ef; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX app_admin_tutorialvideo_user_updated_id_f63aa4ef ON public.app_admin_tutorialvideo USING btree (user_updated_id);


--
-- Name: app_admin_typeinstitution_user_created_id_ea0412d7; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX app_admin_typeinstitution_user_created_id_ea0412d7 ON public.app_admin_typeinstitution USING btree (user_created_id);


--
-- Name: app_admin_typeinstitution_user_deleted_id_5fdb6911; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX app_admin_typeinstitution_user_deleted_id_5fdb6911 ON public.app_admin_typeinstitution USING btree (user_deleted_id);


--
-- Name: app_admin_typeinstitution_user_updated_id_0c0e17d6; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX app_admin_typeinstitution_user_updated_id_0c0e17d6 ON public.app_admin_typeinstitution USING btree (user_updated_id);


--
-- Name: app_admin_typeorganization_user_created_id_1fc7fd3d; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX app_admin_typeorganization_user_created_id_1fc7fd3d ON public.app_admin_typeorganization USING btree (user_created_id);


--
-- Name: app_admin_typeorganization_user_deleted_id_c79b53da; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX app_admin_typeorganization_user_deleted_id_c79b53da ON public.app_admin_typeorganization USING btree (user_deleted_id);


--
-- Name: app_admin_typeorganization_user_updated_id_f7a8a8c0; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX app_admin_typeorganization_user_updated_id_f7a8a8c0 ON public.app_admin_typeorganization USING btree (user_updated_id);


--
-- Name: app_admin_userestablishment_establishment_id_58f527b6; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX app_admin_userestablishment_establishment_id_58f527b6 ON public.app_admin_userestablishment USING btree (establishment_id);


--
-- Name: app_admin_userestablishment_user_created_id_d68598ec; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX app_admin_userestablishment_user_created_id_d68598ec ON public.app_admin_userestablishment USING btree (user_created_id);


--
-- Name: app_admin_userestablishment_user_deleted_id_15ec6a6f; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX app_admin_userestablishment_user_deleted_id_15ec6a6f ON public.app_admin_userestablishment USING btree (user_deleted_id);


--
-- Name: app_admin_userestablishment_user_id_dc55e09d; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX app_admin_userestablishment_user_id_dc55e09d ON public.app_admin_userestablishment USING btree (user_id);


--
-- Name: app_admin_userestablishment_user_updated_id_11c0edc4; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX app_admin_userestablishment_user_updated_id_11c0edc4 ON public.app_admin_userestablishment USING btree (user_updated_id);


--
-- Name: auth_group_name_a6ea08ec_like; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX auth_group_name_a6ea08ec_like ON public.auth_group USING btree (name varchar_pattern_ops);


--
-- Name: auth_group_permissions_group_id_b120cbf9; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX auth_group_permissions_group_id_b120cbf9 ON public.auth_group_permissions USING btree (group_id);


--
-- Name: auth_group_permissions_permission_id_84c5c92e; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX auth_group_permissions_permission_id_84c5c92e ON public.auth_group_permissions USING btree (permission_id);


--
-- Name: auth_permission_content_type_id_2f476e4b; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX auth_permission_content_type_id_2f476e4b ON public.auth_permission USING btree (content_type_id);


--
-- Name: auth_user_groups_group_id_97559544; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX auth_user_groups_group_id_97559544 ON public.auth_user_groups USING btree (group_id);


--
-- Name: auth_user_groups_user_id_6a12ed8b; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX auth_user_groups_user_id_6a12ed8b ON public.auth_user_groups USING btree (user_id);


--
-- Name: auth_user_user_permissions_permission_id_1fbb5f2c; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX auth_user_user_permissions_permission_id_1fbb5f2c ON public.auth_user_user_permissions USING btree (permission_id);


--
-- Name: auth_user_user_permissions_user_id_a95ead1b; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX auth_user_user_permissions_user_id_a95ead1b ON public.auth_user_user_permissions USING btree (user_id);


--
-- Name: auth_user_username_6821ab7c_like; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX auth_user_username_6821ab7c_like ON public.auth_user USING btree (username varchar_pattern_ops);


--
-- Name: django_admin_log_content_type_id_c4bce8eb; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX django_admin_log_content_type_id_c4bce8eb ON public.django_admin_log USING btree (content_type_id);


--
-- Name: django_admin_log_user_id_c564eba6; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX django_admin_log_user_id_c564eba6 ON public.django_admin_log USING btree (user_id);


--
-- Name: django_celery_beat_periodictask_clocked_id_47a69f82; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX django_celery_beat_periodictask_clocked_id_47a69f82 ON public.django_celery_beat_periodictask USING btree (clocked_id);


--
-- Name: django_celery_beat_periodictask_crontab_id_d3cba168; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX django_celery_beat_periodictask_crontab_id_d3cba168 ON public.django_celery_beat_periodictask USING btree (crontab_id);


--
-- Name: django_celery_beat_periodictask_interval_id_a8ca27da; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX django_celery_beat_periodictask_interval_id_a8ca27da ON public.django_celery_beat_periodictask USING btree (interval_id);


--
-- Name: django_celery_beat_periodictask_name_265a36b7_like; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX django_celery_beat_periodictask_name_265a36b7_like ON public.django_celery_beat_periodictask USING btree (name varchar_pattern_ops);


--
-- Name: django_celery_beat_periodictask_solar_id_a87ce72c; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX django_celery_beat_periodictask_solar_id_a87ce72c ON public.django_celery_beat_periodictask USING btree (solar_id);


--
-- Name: django_rest_passwordreset_resetpasswordtoken_key_f1b65873_like; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX django_rest_passwordreset_resetpasswordtoken_key_f1b65873_like ON public.django_rest_passwordreset_resetpasswordtoken USING btree (key varchar_pattern_ops);


--
-- Name: django_rest_passwordreset_resetpasswordtoken_user_id_e8015b11; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX django_rest_passwordreset_resetpasswordtoken_user_id_e8015b11 ON public.django_rest_passwordreset_resetpasswordtoken USING btree (user_id);


--
-- Name: django_session_expire_date_a5c62663; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX django_session_expire_date_a5c62663 ON public.django_session USING btree (expire_date);


--
-- Name: django_session_session_key_c0390e0f_like; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX django_session_session_key_c0390e0f_like ON public.django_session USING btree (session_key varchar_pattern_ops);


--
-- Name: entity_app_attachment_user_created_id_3b9758cc; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_attachment_user_created_id_3b9758cc ON public.entity_app_attachment USING btree (user_created_id);


--
-- Name: entity_app_attachment_user_deleted_id_a8efc8c4; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_attachment_user_deleted_id_a8efc8c4 ON public.entity_app_attachment USING btree (user_deleted_id);


--
-- Name: entity_app_attachment_user_updated_id_10a7c758; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_attachment_user_updated_id_10a7c758 ON public.entity_app_attachment USING btree (user_updated_id);


--
-- Name: entity_app_category_user_created_id_62e3975b; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_category_user_created_id_62e3975b ON public.entity_app_category USING btree (user_created_id);


--
-- Name: entity_app_category_user_deleted_id_c3b4ba36; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_category_user_deleted_id_c3b4ba36 ON public.entity_app_category USING btree (user_deleted_id);


--
-- Name: entity_app_category_user_updated_id_7f4ab1ab; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_category_user_updated_id_7f4ab1ab ON public.entity_app_category USING btree (user_updated_id);


--
-- Name: entity_app_columnfile_code_aa422eaf_like; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_columnfile_code_aa422eaf_like ON public.entity_app_columnfile USING btree (code varchar_pattern_ops);


--
-- Name: entity_app_columnfile_user_created_id_1dd846eb; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_columnfile_user_created_id_1dd846eb ON public.entity_app_columnfile USING btree (user_created_id);


--
-- Name: entity_app_columnfile_user_deleted_id_1031ab60; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_columnfile_user_deleted_id_1031ab60 ON public.entity_app_columnfile USING btree (user_deleted_id);


--
-- Name: entity_app_columnfile_user_updated_id_86012f79; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_columnfile_user_updated_id_86012f79 ON public.entity_app_columnfile USING btree (user_updated_id);


--
-- Name: entity_app_establishmentnumeral_establishment_id_fd6f1ee0; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_establishmentnumeral_establishment_id_fd6f1ee0 ON public.entity_app_establishmentnumeral USING btree (establishment_id);


--
-- Name: entity_app_establishmentnumeral_numeral_id_d2cad215; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_establishmentnumeral_numeral_id_d2cad215 ON public.entity_app_establishmentnumeral USING btree (numeral_id);


--
-- Name: entity_app_establishmentnumeral_user_created_id_7b2ada2b; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_establishmentnumeral_user_created_id_7b2ada2b ON public.entity_app_establishmentnumeral USING btree (user_created_id);


--
-- Name: entity_app_establishmentnumeral_user_deleted_id_abae09c0; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_establishmentnumeral_user_deleted_id_abae09c0 ON public.entity_app_establishmentnumeral USING btree (user_deleted_id);


--
-- Name: entity_app_establishmentnumeral_user_updated_id_216289ef; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_establishmentnumeral_user_updated_id_216289ef ON public.entity_app_establishmentnumeral USING btree (user_updated_id);


--
-- Name: entity_app_extension_attachments_attachment_id_92177150; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_extension_attachments_attachment_id_92177150 ON public.entity_app_extension_attachments USING btree (attachment_id);


--
-- Name: entity_app_extension_attachments_extension_id_a244fc1f; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_extension_attachments_extension_id_a244fc1f ON public.entity_app_extension_attachments USING btree (extension_id);


--
-- Name: entity_app_extension_files_extension_id_efc29bd0; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_extension_files_extension_id_efc29bd0 ON public.entity_app_extension_files USING btree (extension_id);


--
-- Name: entity_app_extension_files_filepublication_id_42df2e33; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_extension_files_filepublication_id_42df2e33 ON public.entity_app_extension_files USING btree (filepublication_id);


--
-- Name: entity_app_extension_solicity_id_bab0ca00; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_extension_solicity_id_bab0ca00 ON public.entity_app_extension USING btree (solicity_id);


--
-- Name: entity_app_extension_user_created_id_2c38f474; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_extension_user_created_id_2c38f474 ON public.entity_app_extension USING btree (user_created_id);


--
-- Name: entity_app_extension_user_deleted_id_efd60648; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_extension_user_deleted_id_efd60648 ON public.entity_app_extension USING btree (user_deleted_id);


--
-- Name: entity_app_extension_user_id_539ef5eb; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_extension_user_id_539ef5eb ON public.entity_app_extension USING btree (user_id);


--
-- Name: entity_app_extension_user_updated_id_29fcf860; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_extension_user_updated_id_29fcf860 ON public.entity_app_extension USING btree (user_updated_id);


--
-- Name: entity_app_filepublication_file_join_id_bebed421; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_filepublication_file_join_id_bebed421 ON public.entity_app_filepublication USING btree (file_join_id);


--
-- Name: entity_app_filepublication_user_created_id_a584b80a; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_filepublication_user_created_id_a584b80a ON public.entity_app_filepublication USING btree (user_created_id);


--
-- Name: entity_app_filepublication_user_deleted_id_1d8ec76a; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_filepublication_user_deleted_id_1d8ec76a ON public.entity_app_filepublication USING btree (user_deleted_id);


--
-- Name: entity_app_filepublication_user_updated_id_0a7b143e; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_filepublication_user_updated_id_0a7b143e ON public.entity_app_filepublication USING btree (user_updated_id);


--
-- Name: entity_app_insistency_solicity_id_a090c8fc; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_insistency_solicity_id_a090c8fc ON public.entity_app_insistency USING btree (solicity_id);


--
-- Name: entity_app_insistency_user_created_id_db654e99; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_insistency_user_created_id_db654e99 ON public.entity_app_insistency USING btree (user_created_id);


--
-- Name: entity_app_insistency_user_deleted_id_0340e042; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_insistency_user_deleted_id_0340e042 ON public.entity_app_insistency USING btree (user_deleted_id);


--
-- Name: entity_app_insistency_user_id_d0084a9c; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_insistency_user_id_d0084a9c ON public.entity_app_insistency USING btree (user_id);


--
-- Name: entity_app_insistency_user_updated_id_256c8a55; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_insistency_user_updated_id_256c8a55 ON public.entity_app_insistency USING btree (user_updated_id);


--
-- Name: entity_app_numeral_parent_id_93dad9ac; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_numeral_parent_id_93dad9ac ON public.entity_app_numeral USING btree (parent_id);


--
-- Name: entity_app_numeral_templates_numeral_id_62f516fe; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_numeral_templates_numeral_id_62f516fe ON public.entity_app_numeral_templates USING btree (numeral_id);


--
-- Name: entity_app_numeral_templates_templatefile_id_b787b8bd; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_numeral_templates_templatefile_id_b787b8bd ON public.entity_app_numeral_templates USING btree (templatefile_id);


--
-- Name: entity_app_numeral_user_created_id_93e0fbe3; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_numeral_user_created_id_93e0fbe3 ON public.entity_app_numeral USING btree (user_created_id);


--
-- Name: entity_app_numeral_user_deleted_id_8dace8d8; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_numeral_user_deleted_id_8dace8d8 ON public.entity_app_numeral USING btree (user_deleted_id);


--
-- Name: entity_app_numeral_user_updated_id_cca905d0; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_numeral_user_updated_id_cca905d0 ON public.entity_app_numeral USING btree (user_updated_id);


--
-- Name: entity_app_publication_attachment_attachment_id_d33e90b1; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_publication_attachment_attachment_id_d33e90b1 ON public.entity_app_publication_attachment USING btree (attachment_id);


--
-- Name: entity_app_publication_attachment_publication_id_254266e8; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_publication_attachment_publication_id_254266e8 ON public.entity_app_publication_attachment USING btree (publication_id);


--
-- Name: entity_app_publication_establishment_id_f3547f24; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_publication_establishment_id_f3547f24 ON public.entity_app_publication USING btree (establishment_id);


--
-- Name: entity_app_publication_fil_filepublication_id_0ab45231; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_publication_fil_filepublication_id_0ab45231 ON public.entity_app_publication_file_publication USING btree (filepublication_id);


--
-- Name: entity_app_publication_file_publication_publication_id_534a4b55; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_publication_file_publication_publication_id_534a4b55 ON public.entity_app_publication_file_publication USING btree (publication_id);


--
-- Name: entity_app_publication_slug_5aee9457_like; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_publication_slug_5aee9457_like ON public.entity_app_publication USING btree (slug varchar_pattern_ops);


--
-- Name: entity_app_publication_tag_publication_id_0bae7f85; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_publication_tag_publication_id_0bae7f85 ON public.entity_app_publication_tag USING btree (publication_id);


--
-- Name: entity_app_publication_tag_tag_id_1d5cf14f; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_publication_tag_tag_id_1d5cf14f ON public.entity_app_publication_tag USING btree (tag_id);


--
-- Name: entity_app_publication_type_format_publication_id_6e9df01c; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_publication_type_format_publication_id_6e9df01c ON public.entity_app_publication_type_format USING btree (publication_id);


--
-- Name: entity_app_publication_type_format_typeformats_id_5ad36c83; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_publication_type_format_typeformats_id_5ad36c83 ON public.entity_app_publication_type_format USING btree (typeformats_id);


--
-- Name: entity_app_publication_type_publication_id_8a8fa38e; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_publication_type_publication_id_8a8fa38e ON public.entity_app_publication USING btree (type_publication_id);


--
-- Name: entity_app_publication_user_created_id_cd19511f; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_publication_user_created_id_cd19511f ON public.entity_app_publication USING btree (user_created_id);


--
-- Name: entity_app_publication_user_deleted_id_a5a02053; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_publication_user_deleted_id_a5a02053 ON public.entity_app_publication USING btree (user_deleted_id);


--
-- Name: entity_app_publication_user_updated_id_b334d726; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_publication_user_updated_id_b334d726 ON public.entity_app_publication USING btree (user_updated_id);


--
-- Name: entity_app_solicity_establishment_id_7ada1889; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_solicity_establishment_id_7ada1889 ON public.entity_app_solicity USING btree (establishment_id);


--
-- Name: entity_app_solicity_user_created_id_e88004b0; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_solicity_user_created_id_e88004b0 ON public.entity_app_solicity USING btree (user_created_id);


--
-- Name: entity_app_solicity_user_deleted_id_855011d8; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_solicity_user_deleted_id_855011d8 ON public.entity_app_solicity USING btree (user_deleted_id);


--
-- Name: entity_app_solicity_user_updated_id_2698e8d2; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_solicity_user_updated_id_2698e8d2 ON public.entity_app_solicity USING btree (user_updated_id);


--
-- Name: entity_app_solicityrespons_solicityresponse_id_7fd9a1a3; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_solicityrespons_solicityresponse_id_7fd9a1a3 ON public.entity_app_solicityresponse_attachments USING btree (solicityresponse_id);


--
-- Name: entity_app_solicityresponse_attachments_attachment_id_6529fcba; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_solicityresponse_attachments_attachment_id_6529fcba ON public.entity_app_solicityresponse_attachments USING btree (attachment_id);


--
-- Name: entity_app_solicityresponse_files_filepublication_id_56b125a6; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_solicityresponse_files_filepublication_id_56b125a6 ON public.entity_app_solicityresponse_files USING btree (filepublication_id);


--
-- Name: entity_app_solicityresponse_files_solicityresponse_id_6e0cf387; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_solicityresponse_files_solicityresponse_id_6e0cf387 ON public.entity_app_solicityresponse_files USING btree (solicityresponse_id);


--
-- Name: entity_app_solicityresponse_solicity_id_e94c81cc; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_solicityresponse_solicity_id_e94c81cc ON public.entity_app_solicityresponse USING btree (solicity_id);


--
-- Name: entity_app_solicityresponse_user_created_id_8efd31ea; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_solicityresponse_user_created_id_8efd31ea ON public.entity_app_solicityresponse USING btree (user_created_id);


--
-- Name: entity_app_solicityresponse_user_deleted_id_16252b37; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_solicityresponse_user_deleted_id_16252b37 ON public.entity_app_solicityresponse USING btree (user_deleted_id);


--
-- Name: entity_app_solicityresponse_user_id_fa352fbb; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_solicityresponse_user_id_fa352fbb ON public.entity_app_solicityresponse USING btree (user_id);


--
-- Name: entity_app_solicityresponse_user_updated_id_3db17ce0; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_solicityresponse_user_updated_id_3db17ce0 ON public.entity_app_solicityresponse USING btree (user_updated_id);


--
-- Name: entity_app_tag_user_created_id_e644ebc8; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_tag_user_created_id_e644ebc8 ON public.entity_app_tag USING btree (user_created_id);


--
-- Name: entity_app_tag_user_deleted_id_37e69e4a; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_tag_user_deleted_id_37e69e4a ON public.entity_app_tag USING btree (user_deleted_id);


--
-- Name: entity_app_tag_user_updated_id_0ec99bea; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_tag_user_updated_id_0ec99bea ON public.entity_app_tag USING btree (user_updated_id);


--
-- Name: entity_app_templatefile_code_645c960e_like; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_templatefile_code_645c960e_like ON public.entity_app_templatefile USING btree (code varchar_pattern_ops);


--
-- Name: entity_app_templatefile_columns_columnfile_id_9a4a6d69; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_templatefile_columns_columnfile_id_9a4a6d69 ON public.entity_app_templatefile_columns USING btree (columnfile_id);


--
-- Name: entity_app_templatefile_columns_templatefile_id_2482b2ec; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_templatefile_columns_templatefile_id_2482b2ec ON public.entity_app_templatefile_columns USING btree (templatefile_id);


--
-- Name: entity_app_templatefile_user_created_id_a607439f; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_templatefile_user_created_id_a607439f ON public.entity_app_templatefile USING btree (user_created_id);


--
-- Name: entity_app_templatefile_user_deleted_id_f208d194; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_templatefile_user_deleted_id_f208d194 ON public.entity_app_templatefile USING btree (user_deleted_id);


--
-- Name: entity_app_templatefile_user_updated_id_ed690196; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_templatefile_user_updated_id_ed690196 ON public.entity_app_templatefile USING btree (user_updated_id);


--
-- Name: entity_app_timelinesolicity_solicity_id_fe3193af; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_timelinesolicity_solicity_id_fe3193af ON public.entity_app_timelinesolicity USING btree (solicity_id);


--
-- Name: entity_app_timelinesolicity_user_created_id_40e77587; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_timelinesolicity_user_created_id_40e77587 ON public.entity_app_timelinesolicity USING btree (user_created_id);


--
-- Name: entity_app_timelinesolicity_user_deleted_id_7b79d033; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_timelinesolicity_user_deleted_id_7b79d033 ON public.entity_app_timelinesolicity USING btree (user_deleted_id);


--
-- Name: entity_app_timelinesolicity_user_updated_id_f85451ac; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_timelinesolicity_user_updated_id_f85451ac ON public.entity_app_timelinesolicity USING btree (user_updated_id);


--
-- Name: entity_app_transparencyact_transparencyactive_id_236ffd1b; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_transparencyact_transparencyactive_id_236ffd1b ON public.entity_app_transparencyactive_files USING btree (transparencyactive_id);


--
-- Name: entity_app_transparencyactive_establishment_id_c476b716; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_transparencyactive_establishment_id_c476b716 ON public.entity_app_transparencyactive USING btree (establishment_id);


--
-- Name: entity_app_transparencyactive_files_filepublication_id_993b2a12; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_transparencyactive_files_filepublication_id_993b2a12 ON public.entity_app_transparencyactive_files USING btree (filepublication_id);


--
-- Name: entity_app_transparencyactive_numeral_id_16316f23; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_transparencyactive_numeral_id_16316f23 ON public.entity_app_transparencyactive USING btree (numeral_id);


--
-- Name: entity_app_transparencyactive_slug_71a5378e_like; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_transparencyactive_slug_71a5378e_like ON public.entity_app_transparencyactive USING btree (slug varchar_pattern_ops);


--
-- Name: entity_app_transparencyactive_user_created_id_a261b22a; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_transparencyactive_user_created_id_a261b22a ON public.entity_app_transparencyactive USING btree (user_created_id);


--
-- Name: entity_app_transparencyactive_user_deleted_id_07a399f7; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_transparencyactive_user_deleted_id_07a399f7 ON public.entity_app_transparencyactive USING btree (user_deleted_id);


--
-- Name: entity_app_transparencyactive_user_updated_id_ade90e38; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_transparencyactive_user_updated_id_ade90e38 ON public.entity_app_transparencyactive USING btree (user_updated_id);


--
-- Name: entity_app_transparencycol_transparencycolab_id_6975b0b6; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_transparencycol_transparencycolab_id_6975b0b6 ON public.entity_app_transparencycolab_files USING btree (transparencycolab_id);


--
-- Name: entity_app_transparencycolab_establishment_id_5000d5a3; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_transparencycolab_establishment_id_5000d5a3 ON public.entity_app_transparencycolab USING btree (establishment_id);


--
-- Name: entity_app_transparencycolab_files_filepublication_id_ee7fc3cc; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_transparencycolab_files_filepublication_id_ee7fc3cc ON public.entity_app_transparencycolab_files USING btree (filepublication_id);


--
-- Name: entity_app_transparencycolab_numeral_id_817fb940; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_transparencycolab_numeral_id_817fb940 ON public.entity_app_transparencycolab USING btree (numeral_id);


--
-- Name: entity_app_transparencycolab_slug_7a080e76_like; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_transparencycolab_slug_7a080e76_like ON public.entity_app_transparencycolab USING btree (slug varchar_pattern_ops);


--
-- Name: entity_app_transparencycolab_user_created_id_fcda3c6b; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_transparencycolab_user_created_id_fcda3c6b ON public.entity_app_transparencycolab USING btree (user_created_id);


--
-- Name: entity_app_transparencycolab_user_deleted_id_8f718658; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_transparencycolab_user_deleted_id_8f718658 ON public.entity_app_transparencycolab USING btree (user_deleted_id);


--
-- Name: entity_app_transparencycolab_user_updated_id_dc8a26e3; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_transparencycolab_user_updated_id_dc8a26e3 ON public.entity_app_transparencycolab USING btree (user_updated_id);


--
-- Name: entity_app_transparencyfoc_transparencyfocal_id_b0b3735a; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_transparencyfoc_transparencyfocal_id_b0b3735a ON public.entity_app_transparencyfocal_files USING btree (transparencyfocal_id);


--
-- Name: entity_app_transparencyfocal_establishment_id_c4f1debd; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_transparencyfocal_establishment_id_c4f1debd ON public.entity_app_transparencyfocal USING btree (establishment_id);


--
-- Name: entity_app_transparencyfocal_files_filepublication_id_e30a2fd4; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_transparencyfocal_files_filepublication_id_e30a2fd4 ON public.entity_app_transparencyfocal_files USING btree (filepublication_id);


--
-- Name: entity_app_transparencyfocal_numeral_id_0a552fb2; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_transparencyfocal_numeral_id_0a552fb2 ON public.entity_app_transparencyfocal USING btree (numeral_id);


--
-- Name: entity_app_transparencyfocal_slug_5c0dcffb_like; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_transparencyfocal_slug_5c0dcffb_like ON public.entity_app_transparencyfocal USING btree (slug varchar_pattern_ops);


--
-- Name: entity_app_transparencyfocal_user_created_id_a856316c; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_transparencyfocal_user_created_id_a856316c ON public.entity_app_transparencyfocal USING btree (user_created_id);


--
-- Name: entity_app_transparencyfocal_user_deleted_id_a88ab97d; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_transparencyfocal_user_deleted_id_a88ab97d ON public.entity_app_transparencyfocal USING btree (user_deleted_id);


--
-- Name: entity_app_transparencyfocal_user_updated_id_2e96e6de; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_transparencyfocal_user_updated_id_2e96e6de ON public.entity_app_transparencyfocal USING btree (user_updated_id);


--
-- Name: entity_app_typeformats_user_created_id_06347f66; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_typeformats_user_created_id_06347f66 ON public.entity_app_typeformats USING btree (user_created_id);


--
-- Name: entity_app_typeformats_user_deleted_id_fe386807; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_typeformats_user_deleted_id_fe386807 ON public.entity_app_typeformats USING btree (user_deleted_id);


--
-- Name: entity_app_typeformats_user_updated_id_180dd406; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_typeformats_user_updated_id_180dd406 ON public.entity_app_typeformats USING btree (user_updated_id);


--
-- Name: entity_app_typepublication_user_created_id_888766e6; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_typepublication_user_created_id_888766e6 ON public.entity_app_typepublication USING btree (user_created_id);


--
-- Name: entity_app_typepublication_user_deleted_id_c2703c31; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_typepublication_user_deleted_id_c2703c31 ON public.entity_app_typepublication USING btree (user_deleted_id);


--
-- Name: entity_app_typepublication_user_updated_id_db8da2c9; Type: INDEX; Schema: public; Owner: auth_user
--

CREATE INDEX entity_app_typepublication_user_updated_id_db8da2c9 ON public.entity_app_typepublication USING btree (user_updated_id);


--
-- Name: activity_log activity_log_user_created_id_c1016fbc_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.activity_log
    ADD CONSTRAINT activity_log_user_created_id_c1016fbc_fk_auth_user_id FOREIGN KEY (user_created_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: activity_log activity_log_user_deleted_id_20653c23_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.activity_log
    ADD CONSTRAINT activity_log_user_deleted_id_20653c23_fk_auth_user_id FOREIGN KEY (user_deleted_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: activity_log activity_log_user_id_f1e09264_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.activity_log
    ADD CONSTRAINT activity_log_user_id_f1e09264_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: activity_log activity_log_user_updated_id_61004408_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.activity_log
    ADD CONSTRAINT activity_log_user_updated_id_61004408_fk_auth_user_id FOREIGN KEY (user_updated_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: app_admin_accesstoinformation_establishment app_admin_accesstoin_accesstoinformation__617f481c_fk_app_admin; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_accesstoinformation_establishment
    ADD CONSTRAINT app_admin_accesstoin_accesstoinformation__617f481c_fk_app_admin FOREIGN KEY (accesstoinformation_id) REFERENCES public.app_admin_accesstoinformation(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: app_admin_accesstoinformation_establishment app_admin_accesstoin_establishment_id_804c84a0_fk_app_admin; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_accesstoinformation_establishment
    ADD CONSTRAINT app_admin_accesstoin_establishment_id_804c84a0_fk_app_admin FOREIGN KEY (establishment_id) REFERENCES public.app_admin_establishment(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: app_admin_accesstoinformation app_admin_accesstoin_user_created_id_1186aec6_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_accesstoinformation
    ADD CONSTRAINT app_admin_accesstoin_user_created_id_1186aec6_fk_auth_user FOREIGN KEY (user_created_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: app_admin_accesstoinformation app_admin_accesstoin_user_deleted_id_3aa70809_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_accesstoinformation
    ADD CONSTRAINT app_admin_accesstoin_user_deleted_id_3aa70809_fk_auth_user FOREIGN KEY (user_deleted_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: app_admin_accesstoinformation app_admin_accesstoin_user_updated_id_3a28d470_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_accesstoinformation
    ADD CONSTRAINT app_admin_accesstoin_user_updated_id_3a28d470_fk_auth_user FOREIGN KEY (user_updated_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: app_admin_configuration app_admin_configurat_user_created_id_53e5f321_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_configuration
    ADD CONSTRAINT app_admin_configurat_user_created_id_53e5f321_fk_auth_user FOREIGN KEY (user_created_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: app_admin_configuration app_admin_configurat_user_deleted_id_8e71c71e_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_configuration
    ADD CONSTRAINT app_admin_configurat_user_deleted_id_8e71c71e_fk_auth_user FOREIGN KEY (user_deleted_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: app_admin_configuration app_admin_configurat_user_updated_id_80ff2deb_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_configuration
    ADD CONSTRAINT app_admin_configurat_user_updated_id_80ff2deb_fk_auth_user FOREIGN KEY (user_updated_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: app_admin_email app_admin_email_user_created_id_c68cc37b_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_email
    ADD CONSTRAINT app_admin_email_user_created_id_c68cc37b_fk_auth_user_id FOREIGN KEY (user_created_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: app_admin_email app_admin_email_user_deleted_id_65d9893d_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_email
    ADD CONSTRAINT app_admin_email_user_deleted_id_65d9893d_fk_auth_user_id FOREIGN KEY (user_deleted_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: app_admin_email app_admin_email_user_updated_id_90ffa4b2_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_email
    ADD CONSTRAINT app_admin_email_user_updated_id_90ffa4b2_fk_auth_user_id FOREIGN KEY (user_updated_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: app_admin_establishment app_admin_establishm_function_organizatio_db4e6f14_fk_app_admin; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_establishment
    ADD CONSTRAINT app_admin_establishm_function_organizatio_db4e6f14_fk_app_admin FOREIGN KEY (function_organization_id) REFERENCES public.app_admin_functionorganization(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: app_admin_establishment app_admin_establishm_type_institution_id_53d2c03a_fk_app_admin; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_establishment
    ADD CONSTRAINT app_admin_establishm_type_institution_id_53d2c03a_fk_app_admin FOREIGN KEY (type_institution_id) REFERENCES public.app_admin_typeinstitution(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: app_admin_establishment app_admin_establishm_type_organization_id_81b0f49a_fk_app_admin; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_establishment
    ADD CONSTRAINT app_admin_establishm_type_organization_id_81b0f49a_fk_app_admin FOREIGN KEY (type_organization_id) REFERENCES public.app_admin_typeorganization(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: app_admin_establishment app_admin_establishm_user_created_id_1bbdf6ce_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_establishment
    ADD CONSTRAINT app_admin_establishm_user_created_id_1bbdf6ce_fk_auth_user FOREIGN KEY (user_created_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: app_admin_establishment app_admin_establishm_user_deleted_id_21e9a202_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_establishment
    ADD CONSTRAINT app_admin_establishm_user_deleted_id_21e9a202_fk_auth_user FOREIGN KEY (user_deleted_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: app_admin_establishment app_admin_establishm_user_updated_id_4a3ef19d_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_establishment
    ADD CONSTRAINT app_admin_establishm_user_updated_id_4a3ef19d_fk_auth_user FOREIGN KEY (user_updated_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: app_admin_formfields app_admin_formfields_content_type_id_8b9da3f1_fk_django_co; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_formfields
    ADD CONSTRAINT app_admin_formfields_content_type_id_8b9da3f1_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: app_admin_formfields app_admin_formfields_user_created_id_fbf6f550_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_formfields
    ADD CONSTRAINT app_admin_formfields_user_created_id_fbf6f550_fk_auth_user_id FOREIGN KEY (user_created_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: app_admin_formfields app_admin_formfields_user_deleted_id_01e9b60d_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_formfields
    ADD CONSTRAINT app_admin_formfields_user_deleted_id_01e9b60d_fk_auth_user_id FOREIGN KEY (user_deleted_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: app_admin_formfields app_admin_formfields_user_updated_id_545660f1_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_formfields
    ADD CONSTRAINT app_admin_formfields_user_updated_id_545660f1_fk_auth_user_id FOREIGN KEY (user_updated_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: app_admin_frequentlyaskedquestions app_admin_frequently_pedagogy_area_id_2baf9462_fk_app_admin; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_frequentlyaskedquestions
    ADD CONSTRAINT app_admin_frequently_pedagogy_area_id_2baf9462_fk_app_admin FOREIGN KEY (pedagogy_area_id) REFERENCES public.app_admin_pedagogyarea(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: app_admin_frequentlyaskedquestions app_admin_frequently_user_created_id_ecb218e3_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_frequentlyaskedquestions
    ADD CONSTRAINT app_admin_frequently_user_created_id_ecb218e3_fk_auth_user FOREIGN KEY (user_created_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: app_admin_frequentlyaskedquestions app_admin_frequently_user_deleted_id_e7e61107_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_frequentlyaskedquestions
    ADD CONSTRAINT app_admin_frequently_user_deleted_id_e7e61107_fk_auth_user FOREIGN KEY (user_deleted_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: app_admin_frequentlyaskedquestions app_admin_frequently_user_updated_id_e89dd228_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_frequentlyaskedquestions
    ADD CONSTRAINT app_admin_frequently_user_updated_id_e89dd228_fk_auth_user FOREIGN KEY (user_updated_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: app_admin_functionorganization app_admin_functionor_user_created_id_b96aecc1_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_functionorganization
    ADD CONSTRAINT app_admin_functionor_user_created_id_b96aecc1_fk_auth_user FOREIGN KEY (user_created_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: app_admin_functionorganization app_admin_functionor_user_deleted_id_b349ceeb_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_functionorganization
    ADD CONSTRAINT app_admin_functionor_user_deleted_id_b349ceeb_fk_auth_user FOREIGN KEY (user_deleted_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: app_admin_functionorganization app_admin_functionor_user_updated_id_52fcbc54_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_functionorganization
    ADD CONSTRAINT app_admin_functionor_user_updated_id_52fcbc54_fk_auth_user FOREIGN KEY (user_updated_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: app_admin_lawenforcement_establishment app_admin_lawenforce_establishment_id_86274a9a_fk_app_admin; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_lawenforcement_establishment
    ADD CONSTRAINT app_admin_lawenforce_establishment_id_86274a9a_fk_app_admin FOREIGN KEY (establishment_id) REFERENCES public.app_admin_establishment(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: app_admin_lawenforcement_establishment app_admin_lawenforce_lawenforcement_id_d933c1fc_fk_app_admin; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_lawenforcement_establishment
    ADD CONSTRAINT app_admin_lawenforce_lawenforcement_id_d933c1fc_fk_app_admin FOREIGN KEY (lawenforcement_id) REFERENCES public.app_admin_lawenforcement(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: app_admin_lawenforcement app_admin_lawenforce_user_created_id_e132fbab_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_lawenforcement
    ADD CONSTRAINT app_admin_lawenforce_user_created_id_e132fbab_fk_auth_user FOREIGN KEY (user_created_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: app_admin_lawenforcement app_admin_lawenforce_user_deleted_id_acd10682_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_lawenforcement
    ADD CONSTRAINT app_admin_lawenforce_user_deleted_id_acd10682_fk_auth_user FOREIGN KEY (user_deleted_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: app_admin_lawenforcement app_admin_lawenforce_user_updated_id_bb043648_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_lawenforcement
    ADD CONSTRAINT app_admin_lawenforce_user_updated_id_bb043648_fk_auth_user FOREIGN KEY (user_updated_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: app_admin_normativedocument app_admin_normatived_pedagogy_area_id_4edb267c_fk_app_admin; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_normativedocument
    ADD CONSTRAINT app_admin_normatived_pedagogy_area_id_4edb267c_fk_app_admin FOREIGN KEY (pedagogy_area_id) REFERENCES public.app_admin_pedagogyarea(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: app_admin_normativedocument app_admin_normatived_user_created_id_3356e257_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_normativedocument
    ADD CONSTRAINT app_admin_normatived_user_created_id_3356e257_fk_auth_user FOREIGN KEY (user_created_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: app_admin_normativedocument app_admin_normatived_user_deleted_id_9b2664c1_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_normativedocument
    ADD CONSTRAINT app_admin_normatived_user_deleted_id_9b2664c1_fk_auth_user FOREIGN KEY (user_deleted_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: app_admin_normativedocument app_admin_normatived_user_updated_id_7df8442b_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_normativedocument
    ADD CONSTRAINT app_admin_normatived_user_updated_id_7df8442b_fk_auth_user FOREIGN KEY (user_updated_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: app_admin_pedagogyarea app_admin_pedagogyarea_user_created_id_552f1ea8_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_pedagogyarea
    ADD CONSTRAINT app_admin_pedagogyarea_user_created_id_552f1ea8_fk_auth_user_id FOREIGN KEY (user_created_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: app_admin_pedagogyarea app_admin_pedagogyarea_user_deleted_id_c25bd2b8_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_pedagogyarea
    ADD CONSTRAINT app_admin_pedagogyarea_user_deleted_id_c25bd2b8_fk_auth_user_id FOREIGN KEY (user_deleted_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: app_admin_pedagogyarea app_admin_pedagogyarea_user_updated_id_947c92b9_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_pedagogyarea
    ADD CONSTRAINT app_admin_pedagogyarea_user_updated_id_947c92b9_fk_auth_user_id FOREIGN KEY (user_updated_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: app_admin_tutorialvideo app_admin_tutorialvi_pedagogy_area_id_8d068ecb_fk_app_admin; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_tutorialvideo
    ADD CONSTRAINT app_admin_tutorialvi_pedagogy_area_id_8d068ecb_fk_app_admin FOREIGN KEY (pedagogy_area_id) REFERENCES public.app_admin_pedagogyarea(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: app_admin_tutorialvideo app_admin_tutorialvi_user_created_id_e74b5c9f_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_tutorialvideo
    ADD CONSTRAINT app_admin_tutorialvi_user_created_id_e74b5c9f_fk_auth_user FOREIGN KEY (user_created_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: app_admin_tutorialvideo app_admin_tutorialvi_user_deleted_id_30f1dede_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_tutorialvideo
    ADD CONSTRAINT app_admin_tutorialvi_user_deleted_id_30f1dede_fk_auth_user FOREIGN KEY (user_deleted_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: app_admin_tutorialvideo app_admin_tutorialvi_user_updated_id_f63aa4ef_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_tutorialvideo
    ADD CONSTRAINT app_admin_tutorialvi_user_updated_id_f63aa4ef_fk_auth_user FOREIGN KEY (user_updated_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: app_admin_typeinstitution app_admin_typeinstit_user_created_id_ea0412d7_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_typeinstitution
    ADD CONSTRAINT app_admin_typeinstit_user_created_id_ea0412d7_fk_auth_user FOREIGN KEY (user_created_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: app_admin_typeinstitution app_admin_typeinstit_user_deleted_id_5fdb6911_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_typeinstitution
    ADD CONSTRAINT app_admin_typeinstit_user_deleted_id_5fdb6911_fk_auth_user FOREIGN KEY (user_deleted_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: app_admin_typeinstitution app_admin_typeinstit_user_updated_id_0c0e17d6_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_typeinstitution
    ADD CONSTRAINT app_admin_typeinstit_user_updated_id_0c0e17d6_fk_auth_user FOREIGN KEY (user_updated_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: app_admin_typeorganization app_admin_typeorgani_user_created_id_1fc7fd3d_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_typeorganization
    ADD CONSTRAINT app_admin_typeorgani_user_created_id_1fc7fd3d_fk_auth_user FOREIGN KEY (user_created_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: app_admin_typeorganization app_admin_typeorgani_user_deleted_id_c79b53da_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_typeorganization
    ADD CONSTRAINT app_admin_typeorgani_user_deleted_id_c79b53da_fk_auth_user FOREIGN KEY (user_deleted_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: app_admin_typeorganization app_admin_typeorgani_user_updated_id_f7a8a8c0_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_typeorganization
    ADD CONSTRAINT app_admin_typeorgani_user_updated_id_f7a8a8c0_fk_auth_user FOREIGN KEY (user_updated_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: app_admin_userestablishment app_admin_userestabl_establishment_id_58f527b6_fk_app_admin; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_userestablishment
    ADD CONSTRAINT app_admin_userestabl_establishment_id_58f527b6_fk_app_admin FOREIGN KEY (establishment_id) REFERENCES public.app_admin_establishment(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: app_admin_userestablishment app_admin_userestabl_user_created_id_d68598ec_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_userestablishment
    ADD CONSTRAINT app_admin_userestabl_user_created_id_d68598ec_fk_auth_user FOREIGN KEY (user_created_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: app_admin_userestablishment app_admin_userestabl_user_deleted_id_15ec6a6f_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_userestablishment
    ADD CONSTRAINT app_admin_userestabl_user_deleted_id_15ec6a6f_fk_auth_user FOREIGN KEY (user_deleted_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: app_admin_userestablishment app_admin_userestabl_user_updated_id_11c0edc4_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_userestablishment
    ADD CONSTRAINT app_admin_userestabl_user_updated_id_11c0edc4_fk_auth_user FOREIGN KEY (user_updated_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: app_admin_userestablishment app_admin_userestablishment_user_id_dc55e09d_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.app_admin_userestablishment
    ADD CONSTRAINT app_admin_userestablishment_user_id_dc55e09d_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_group_permissions auth_group_permissio_permission_id_84c5c92e_fk_auth_perm; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissio_permission_id_84c5c92e_fk_auth_perm FOREIGN KEY (permission_id) REFERENCES public.auth_permission(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_group_permissions auth_group_permissions_group_id_b120cbf9_fk_auth_group_id; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_group_id_b120cbf9_fk_auth_group_id FOREIGN KEY (group_id) REFERENCES public.auth_group(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_permission auth_permission_content_type_id_2f476e4b_fk_django_co; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_content_type_id_2f476e4b_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_person auth_person_user_id_be86705a_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.auth_person
    ADD CONSTRAINT auth_person_user_id_be86705a_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_user_groups auth_user_groups_group_id_97559544_fk_auth_group_id; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.auth_user_groups
    ADD CONSTRAINT auth_user_groups_group_id_97559544_fk_auth_group_id FOREIGN KEY (group_id) REFERENCES public.auth_group(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_user_groups auth_user_groups_user_id_6a12ed8b_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.auth_user_groups
    ADD CONSTRAINT auth_user_groups_user_id_6a12ed8b_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_user_user_permissions auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm FOREIGN KEY (permission_id) REFERENCES public.auth_permission(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_user_user_permissions auth_user_user_permissions_user_id_a95ead1b_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permissions_user_id_a95ead1b_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: django_admin_log django_admin_log_content_type_id_c4bce8eb_fk_django_co; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_content_type_id_c4bce8eb_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: django_admin_log django_admin_log_user_id_c564eba6_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_user_id_c564eba6_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: django_celery_beat_periodictask django_celery_beat_p_clocked_id_47a69f82_fk_django_ce; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.django_celery_beat_periodictask
    ADD CONSTRAINT django_celery_beat_p_clocked_id_47a69f82_fk_django_ce FOREIGN KEY (clocked_id) REFERENCES public.django_celery_beat_clockedschedule(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: django_celery_beat_periodictask django_celery_beat_p_crontab_id_d3cba168_fk_django_ce; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.django_celery_beat_periodictask
    ADD CONSTRAINT django_celery_beat_p_crontab_id_d3cba168_fk_django_ce FOREIGN KEY (crontab_id) REFERENCES public.django_celery_beat_crontabschedule(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: django_celery_beat_periodictask django_celery_beat_p_interval_id_a8ca27da_fk_django_ce; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.django_celery_beat_periodictask
    ADD CONSTRAINT django_celery_beat_p_interval_id_a8ca27da_fk_django_ce FOREIGN KEY (interval_id) REFERENCES public.django_celery_beat_intervalschedule(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: django_celery_beat_periodictask django_celery_beat_p_solar_id_a87ce72c_fk_django_ce; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.django_celery_beat_periodictask
    ADD CONSTRAINT django_celery_beat_p_solar_id_a87ce72c_fk_django_ce FOREIGN KEY (solar_id) REFERENCES public.django_celery_beat_solarschedule(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: django_rest_passwordreset_resetpasswordtoken django_rest_password_user_id_e8015b11_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.django_rest_passwordreset_resetpasswordtoken
    ADD CONSTRAINT django_rest_password_user_id_e8015b11_fk_auth_user FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_attachment entity_app_attachment_user_created_id_3b9758cc_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_attachment
    ADD CONSTRAINT entity_app_attachment_user_created_id_3b9758cc_fk_auth_user_id FOREIGN KEY (user_created_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_attachment entity_app_attachment_user_deleted_id_a8efc8c4_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_attachment
    ADD CONSTRAINT entity_app_attachment_user_deleted_id_a8efc8c4_fk_auth_user_id FOREIGN KEY (user_deleted_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_attachment entity_app_attachment_user_updated_id_10a7c758_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_attachment
    ADD CONSTRAINT entity_app_attachment_user_updated_id_10a7c758_fk_auth_user_id FOREIGN KEY (user_updated_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_category entity_app_category_user_created_id_62e3975b_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_category
    ADD CONSTRAINT entity_app_category_user_created_id_62e3975b_fk_auth_user_id FOREIGN KEY (user_created_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_category entity_app_category_user_deleted_id_c3b4ba36_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_category
    ADD CONSTRAINT entity_app_category_user_deleted_id_c3b4ba36_fk_auth_user_id FOREIGN KEY (user_deleted_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_category entity_app_category_user_updated_id_7f4ab1ab_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_category
    ADD CONSTRAINT entity_app_category_user_updated_id_7f4ab1ab_fk_auth_user_id FOREIGN KEY (user_updated_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_columnfile entity_app_columnfile_user_created_id_1dd846eb_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_columnfile
    ADD CONSTRAINT entity_app_columnfile_user_created_id_1dd846eb_fk_auth_user_id FOREIGN KEY (user_created_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_columnfile entity_app_columnfile_user_deleted_id_1031ab60_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_columnfile
    ADD CONSTRAINT entity_app_columnfile_user_deleted_id_1031ab60_fk_auth_user_id FOREIGN KEY (user_deleted_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_columnfile entity_app_columnfile_user_updated_id_86012f79_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_columnfile
    ADD CONSTRAINT entity_app_columnfile_user_updated_id_86012f79_fk_auth_user_id FOREIGN KEY (user_updated_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_establishmentnumeral entity_app_establish_establishment_id_fd6f1ee0_fk_app_admin; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_establishmentnumeral
    ADD CONSTRAINT entity_app_establish_establishment_id_fd6f1ee0_fk_app_admin FOREIGN KEY (establishment_id) REFERENCES public.app_admin_establishment(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_establishmentnumeral entity_app_establish_numeral_id_d2cad215_fk_entity_ap; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_establishmentnumeral
    ADD CONSTRAINT entity_app_establish_numeral_id_d2cad215_fk_entity_ap FOREIGN KEY (numeral_id) REFERENCES public.entity_app_numeral(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_establishmentnumeral entity_app_establish_user_created_id_7b2ada2b_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_establishmentnumeral
    ADD CONSTRAINT entity_app_establish_user_created_id_7b2ada2b_fk_auth_user FOREIGN KEY (user_created_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_establishmentnumeral entity_app_establish_user_deleted_id_abae09c0_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_establishmentnumeral
    ADD CONSTRAINT entity_app_establish_user_deleted_id_abae09c0_fk_auth_user FOREIGN KEY (user_deleted_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_establishmentnumeral entity_app_establish_user_updated_id_216289ef_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_establishmentnumeral
    ADD CONSTRAINT entity_app_establish_user_updated_id_216289ef_fk_auth_user FOREIGN KEY (user_updated_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_extension_attachments entity_app_extension_attachment_id_92177150_fk_entity_ap; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_extension_attachments
    ADD CONSTRAINT entity_app_extension_attachment_id_92177150_fk_entity_ap FOREIGN KEY (attachment_id) REFERENCES public.entity_app_attachment(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_extension_attachments entity_app_extension_extension_id_a244fc1f_fk_entity_ap; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_extension_attachments
    ADD CONSTRAINT entity_app_extension_extension_id_a244fc1f_fk_entity_ap FOREIGN KEY (extension_id) REFERENCES public.entity_app_extension(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_extension_files entity_app_extension_extension_id_efc29bd0_fk_entity_ap; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_extension_files
    ADD CONSTRAINT entity_app_extension_extension_id_efc29bd0_fk_entity_ap FOREIGN KEY (extension_id) REFERENCES public.entity_app_extension(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_extension_files entity_app_extension_filepublication_id_42df2e33_fk_entity_ap; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_extension_files
    ADD CONSTRAINT entity_app_extension_filepublication_id_42df2e33_fk_entity_ap FOREIGN KEY (filepublication_id) REFERENCES public.entity_app_filepublication(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_extension entity_app_extension_solicity_id_bab0ca00_fk_entity_ap; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_extension
    ADD CONSTRAINT entity_app_extension_solicity_id_bab0ca00_fk_entity_ap FOREIGN KEY (solicity_id) REFERENCES public.entity_app_solicity(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_extension entity_app_extension_user_created_id_2c38f474_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_extension
    ADD CONSTRAINT entity_app_extension_user_created_id_2c38f474_fk_auth_user_id FOREIGN KEY (user_created_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_extension entity_app_extension_user_deleted_id_efd60648_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_extension
    ADD CONSTRAINT entity_app_extension_user_deleted_id_efd60648_fk_auth_user_id FOREIGN KEY (user_deleted_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_extension entity_app_extension_user_id_539ef5eb_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_extension
    ADD CONSTRAINT entity_app_extension_user_id_539ef5eb_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_extension entity_app_extension_user_updated_id_29fcf860_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_extension
    ADD CONSTRAINT entity_app_extension_user_updated_id_29fcf860_fk_auth_user_id FOREIGN KEY (user_updated_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_filepublication entity_app_filepubli_file_join_id_bebed421_fk_entity_ap; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_filepublication
    ADD CONSTRAINT entity_app_filepubli_file_join_id_bebed421_fk_entity_ap FOREIGN KEY (file_join_id) REFERENCES public.entity_app_filepublication(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_filepublication entity_app_filepubli_user_created_id_a584b80a_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_filepublication
    ADD CONSTRAINT entity_app_filepubli_user_created_id_a584b80a_fk_auth_user FOREIGN KEY (user_created_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_filepublication entity_app_filepubli_user_deleted_id_1d8ec76a_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_filepublication
    ADD CONSTRAINT entity_app_filepubli_user_deleted_id_1d8ec76a_fk_auth_user FOREIGN KEY (user_deleted_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_filepublication entity_app_filepubli_user_updated_id_0a7b143e_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_filepublication
    ADD CONSTRAINT entity_app_filepubli_user_updated_id_0a7b143e_fk_auth_user FOREIGN KEY (user_updated_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_insistency entity_app_insistenc_solicity_id_a090c8fc_fk_entity_ap; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_insistency
    ADD CONSTRAINT entity_app_insistenc_solicity_id_a090c8fc_fk_entity_ap FOREIGN KEY (solicity_id) REFERENCES public.entity_app_solicity(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_insistency entity_app_insistency_user_created_id_db654e99_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_insistency
    ADD CONSTRAINT entity_app_insistency_user_created_id_db654e99_fk_auth_user_id FOREIGN KEY (user_created_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_insistency entity_app_insistency_user_deleted_id_0340e042_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_insistency
    ADD CONSTRAINT entity_app_insistency_user_deleted_id_0340e042_fk_auth_user_id FOREIGN KEY (user_deleted_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_insistency entity_app_insistency_user_id_d0084a9c_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_insistency
    ADD CONSTRAINT entity_app_insistency_user_id_d0084a9c_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_insistency entity_app_insistency_user_updated_id_256c8a55_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_insistency
    ADD CONSTRAINT entity_app_insistency_user_updated_id_256c8a55_fk_auth_user_id FOREIGN KEY (user_updated_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_numeral entity_app_numeral_parent_id_93dad9ac_fk_entity_app_numeral_id; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_numeral
    ADD CONSTRAINT entity_app_numeral_parent_id_93dad9ac_fk_entity_app_numeral_id FOREIGN KEY (parent_id) REFERENCES public.entity_app_numeral(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_numeral_templates entity_app_numeral_t_numeral_id_62f516fe_fk_entity_ap; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_numeral_templates
    ADD CONSTRAINT entity_app_numeral_t_numeral_id_62f516fe_fk_entity_ap FOREIGN KEY (numeral_id) REFERENCES public.entity_app_numeral(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_numeral_templates entity_app_numeral_t_templatefile_id_b787b8bd_fk_entity_ap; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_numeral_templates
    ADD CONSTRAINT entity_app_numeral_t_templatefile_id_b787b8bd_fk_entity_ap FOREIGN KEY (templatefile_id) REFERENCES public.entity_app_templatefile(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_numeral entity_app_numeral_user_created_id_93e0fbe3_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_numeral
    ADD CONSTRAINT entity_app_numeral_user_created_id_93e0fbe3_fk_auth_user_id FOREIGN KEY (user_created_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_numeral entity_app_numeral_user_deleted_id_8dace8d8_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_numeral
    ADD CONSTRAINT entity_app_numeral_user_deleted_id_8dace8d8_fk_auth_user_id FOREIGN KEY (user_deleted_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_numeral entity_app_numeral_user_updated_id_cca905d0_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_numeral
    ADD CONSTRAINT entity_app_numeral_user_updated_id_cca905d0_fk_auth_user_id FOREIGN KEY (user_updated_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_publication_attachment entity_app_publicati_attachment_id_d33e90b1_fk_entity_ap; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_publication_attachment
    ADD CONSTRAINT entity_app_publicati_attachment_id_d33e90b1_fk_entity_ap FOREIGN KEY (attachment_id) REFERENCES public.entity_app_attachment(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_publication entity_app_publicati_establishment_id_f3547f24_fk_app_admin; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_publication
    ADD CONSTRAINT entity_app_publicati_establishment_id_f3547f24_fk_app_admin FOREIGN KEY (establishment_id) REFERENCES public.app_admin_establishment(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_publication_file_publication entity_app_publicati_filepublication_id_0ab45231_fk_entity_ap; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_publication_file_publication
    ADD CONSTRAINT entity_app_publicati_filepublication_id_0ab45231_fk_entity_ap FOREIGN KEY (filepublication_id) REFERENCES public.entity_app_filepublication(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_publication_tag entity_app_publicati_publication_id_0bae7f85_fk_entity_ap; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_publication_tag
    ADD CONSTRAINT entity_app_publicati_publication_id_0bae7f85_fk_entity_ap FOREIGN KEY (publication_id) REFERENCES public.entity_app_publication(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_publication_attachment entity_app_publicati_publication_id_254266e8_fk_entity_ap; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_publication_attachment
    ADD CONSTRAINT entity_app_publicati_publication_id_254266e8_fk_entity_ap FOREIGN KEY (publication_id) REFERENCES public.entity_app_publication(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_publication_file_publication entity_app_publicati_publication_id_534a4b55_fk_entity_ap; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_publication_file_publication
    ADD CONSTRAINT entity_app_publicati_publication_id_534a4b55_fk_entity_ap FOREIGN KEY (publication_id) REFERENCES public.entity_app_publication(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_publication_type_format entity_app_publicati_publication_id_6e9df01c_fk_entity_ap; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_publication_type_format
    ADD CONSTRAINT entity_app_publicati_publication_id_6e9df01c_fk_entity_ap FOREIGN KEY (publication_id) REFERENCES public.entity_app_publication(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_publication entity_app_publicati_type_publication_id_8a8fa38e_fk_entity_ap; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_publication
    ADD CONSTRAINT entity_app_publicati_type_publication_id_8a8fa38e_fk_entity_ap FOREIGN KEY (type_publication_id) REFERENCES public.entity_app_typepublication(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_publication_type_format entity_app_publicati_typeformats_id_5ad36c83_fk_entity_ap; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_publication_type_format
    ADD CONSTRAINT entity_app_publicati_typeformats_id_5ad36c83_fk_entity_ap FOREIGN KEY (typeformats_id) REFERENCES public.entity_app_typeformats(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_publication_tag entity_app_publication_tag_tag_id_1d5cf14f_fk_entity_app_tag_id; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_publication_tag
    ADD CONSTRAINT entity_app_publication_tag_tag_id_1d5cf14f_fk_entity_app_tag_id FOREIGN KEY (tag_id) REFERENCES public.entity_app_tag(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_publication entity_app_publication_user_created_id_cd19511f_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_publication
    ADD CONSTRAINT entity_app_publication_user_created_id_cd19511f_fk_auth_user_id FOREIGN KEY (user_created_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_publication entity_app_publication_user_deleted_id_a5a02053_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_publication
    ADD CONSTRAINT entity_app_publication_user_deleted_id_a5a02053_fk_auth_user_id FOREIGN KEY (user_deleted_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_publication entity_app_publication_user_updated_id_b334d726_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_publication
    ADD CONSTRAINT entity_app_publication_user_updated_id_b334d726_fk_auth_user_id FOREIGN KEY (user_updated_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_solicity entity_app_solicity_establishment_id_7ada1889_fk_app_admin; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_solicity
    ADD CONSTRAINT entity_app_solicity_establishment_id_7ada1889_fk_app_admin FOREIGN KEY (establishment_id) REFERENCES public.app_admin_establishment(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_solicity entity_app_solicity_user_created_id_e88004b0_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_solicity
    ADD CONSTRAINT entity_app_solicity_user_created_id_e88004b0_fk_auth_user_id FOREIGN KEY (user_created_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_solicity entity_app_solicity_user_deleted_id_855011d8_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_solicity
    ADD CONSTRAINT entity_app_solicity_user_deleted_id_855011d8_fk_auth_user_id FOREIGN KEY (user_deleted_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_solicity entity_app_solicity_user_updated_id_2698e8d2_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_solicity
    ADD CONSTRAINT entity_app_solicity_user_updated_id_2698e8d2_fk_auth_user_id FOREIGN KEY (user_updated_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_solicityresponse_attachments entity_app_solicityr_attachment_id_6529fcba_fk_entity_ap; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_solicityresponse_attachments
    ADD CONSTRAINT entity_app_solicityr_attachment_id_6529fcba_fk_entity_ap FOREIGN KEY (attachment_id) REFERENCES public.entity_app_attachment(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_solicityresponse_files entity_app_solicityr_filepublication_id_56b125a6_fk_entity_ap; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_solicityresponse_files
    ADD CONSTRAINT entity_app_solicityr_filepublication_id_56b125a6_fk_entity_ap FOREIGN KEY (filepublication_id) REFERENCES public.entity_app_filepublication(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_solicityresponse entity_app_solicityr_solicity_id_e94c81cc_fk_entity_ap; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_solicityresponse
    ADD CONSTRAINT entity_app_solicityr_solicity_id_e94c81cc_fk_entity_ap FOREIGN KEY (solicity_id) REFERENCES public.entity_app_solicity(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_solicityresponse_files entity_app_solicityr_solicityresponse_id_6e0cf387_fk_entity_ap; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_solicityresponse_files
    ADD CONSTRAINT entity_app_solicityr_solicityresponse_id_6e0cf387_fk_entity_ap FOREIGN KEY (solicityresponse_id) REFERENCES public.entity_app_solicityresponse(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_solicityresponse_attachments entity_app_solicityr_solicityresponse_id_7fd9a1a3_fk_entity_ap; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_solicityresponse_attachments
    ADD CONSTRAINT entity_app_solicityr_solicityresponse_id_7fd9a1a3_fk_entity_ap FOREIGN KEY (solicityresponse_id) REFERENCES public.entity_app_solicityresponse(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_solicityresponse entity_app_solicityr_user_created_id_8efd31ea_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_solicityresponse
    ADD CONSTRAINT entity_app_solicityr_user_created_id_8efd31ea_fk_auth_user FOREIGN KEY (user_created_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_solicityresponse entity_app_solicityr_user_deleted_id_16252b37_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_solicityresponse
    ADD CONSTRAINT entity_app_solicityr_user_deleted_id_16252b37_fk_auth_user FOREIGN KEY (user_deleted_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_solicityresponse entity_app_solicityr_user_updated_id_3db17ce0_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_solicityresponse
    ADD CONSTRAINT entity_app_solicityr_user_updated_id_3db17ce0_fk_auth_user FOREIGN KEY (user_updated_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_solicityresponse entity_app_solicityresponse_user_id_fa352fbb_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_solicityresponse
    ADD CONSTRAINT entity_app_solicityresponse_user_id_fa352fbb_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_tag entity_app_tag_user_created_id_e644ebc8_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_tag
    ADD CONSTRAINT entity_app_tag_user_created_id_e644ebc8_fk_auth_user_id FOREIGN KEY (user_created_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_tag entity_app_tag_user_deleted_id_37e69e4a_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_tag
    ADD CONSTRAINT entity_app_tag_user_deleted_id_37e69e4a_fk_auth_user_id FOREIGN KEY (user_deleted_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_tag entity_app_tag_user_updated_id_0ec99bea_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_tag
    ADD CONSTRAINT entity_app_tag_user_updated_id_0ec99bea_fk_auth_user_id FOREIGN KEY (user_updated_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_templatefile_columns entity_app_templatef_columnfile_id_9a4a6d69_fk_entity_ap; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_templatefile_columns
    ADD CONSTRAINT entity_app_templatef_columnfile_id_9a4a6d69_fk_entity_ap FOREIGN KEY (columnfile_id) REFERENCES public.entity_app_columnfile(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_templatefile_columns entity_app_templatef_templatefile_id_2482b2ec_fk_entity_ap; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_templatefile_columns
    ADD CONSTRAINT entity_app_templatef_templatefile_id_2482b2ec_fk_entity_ap FOREIGN KEY (templatefile_id) REFERENCES public.entity_app_templatefile(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_templatefile entity_app_templatef_user_created_id_a607439f_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_templatefile
    ADD CONSTRAINT entity_app_templatef_user_created_id_a607439f_fk_auth_user FOREIGN KEY (user_created_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_templatefile entity_app_templatef_user_deleted_id_f208d194_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_templatefile
    ADD CONSTRAINT entity_app_templatef_user_deleted_id_f208d194_fk_auth_user FOREIGN KEY (user_deleted_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_templatefile entity_app_templatef_user_updated_id_ed690196_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_templatefile
    ADD CONSTRAINT entity_app_templatef_user_updated_id_ed690196_fk_auth_user FOREIGN KEY (user_updated_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_timelinesolicity entity_app_timelines_solicity_id_fe3193af_fk_entity_ap; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_timelinesolicity
    ADD CONSTRAINT entity_app_timelines_solicity_id_fe3193af_fk_entity_ap FOREIGN KEY (solicity_id) REFERENCES public.entity_app_solicity(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_timelinesolicity entity_app_timelines_user_created_id_40e77587_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_timelinesolicity
    ADD CONSTRAINT entity_app_timelines_user_created_id_40e77587_fk_auth_user FOREIGN KEY (user_created_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_timelinesolicity entity_app_timelines_user_deleted_id_7b79d033_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_timelinesolicity
    ADD CONSTRAINT entity_app_timelines_user_deleted_id_7b79d033_fk_auth_user FOREIGN KEY (user_deleted_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_timelinesolicity entity_app_timelines_user_updated_id_f85451ac_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_timelinesolicity
    ADD CONSTRAINT entity_app_timelines_user_updated_id_f85451ac_fk_auth_user FOREIGN KEY (user_updated_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_transparencycolab entity_app_transpare_establishment_id_5000d5a3_fk_app_admin; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_transparencycolab
    ADD CONSTRAINT entity_app_transpare_establishment_id_5000d5a3_fk_app_admin FOREIGN KEY (establishment_id) REFERENCES public.app_admin_establishment(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_transparencyactive entity_app_transpare_establishment_id_c476b716_fk_app_admin; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_transparencyactive
    ADD CONSTRAINT entity_app_transpare_establishment_id_c476b716_fk_app_admin FOREIGN KEY (establishment_id) REFERENCES public.app_admin_establishment(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_transparencyfocal entity_app_transpare_establishment_id_c4f1debd_fk_app_admin; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_transparencyfocal
    ADD CONSTRAINT entity_app_transpare_establishment_id_c4f1debd_fk_app_admin FOREIGN KEY (establishment_id) REFERENCES public.app_admin_establishment(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_transparencyactive_files entity_app_transpare_filepublication_id_993b2a12_fk_entity_ap; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_transparencyactive_files
    ADD CONSTRAINT entity_app_transpare_filepublication_id_993b2a12_fk_entity_ap FOREIGN KEY (filepublication_id) REFERENCES public.entity_app_filepublication(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_transparencyfocal_files entity_app_transpare_filepublication_id_e30a2fd4_fk_entity_ap; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_transparencyfocal_files
    ADD CONSTRAINT entity_app_transpare_filepublication_id_e30a2fd4_fk_entity_ap FOREIGN KEY (filepublication_id) REFERENCES public.entity_app_filepublication(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_transparencycolab_files entity_app_transpare_filepublication_id_ee7fc3cc_fk_entity_ap; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_transparencycolab_files
    ADD CONSTRAINT entity_app_transpare_filepublication_id_ee7fc3cc_fk_entity_ap FOREIGN KEY (filepublication_id) REFERENCES public.entity_app_filepublication(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_transparencyfocal entity_app_transpare_numeral_id_0a552fb2_fk_entity_ap; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_transparencyfocal
    ADD CONSTRAINT entity_app_transpare_numeral_id_0a552fb2_fk_entity_ap FOREIGN KEY (numeral_id) REFERENCES public.entity_app_numeral(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_transparencyactive entity_app_transpare_numeral_id_16316f23_fk_entity_ap; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_transparencyactive
    ADD CONSTRAINT entity_app_transpare_numeral_id_16316f23_fk_entity_ap FOREIGN KEY (numeral_id) REFERENCES public.entity_app_numeral(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_transparencycolab entity_app_transpare_numeral_id_817fb940_fk_entity_ap; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_transparencycolab
    ADD CONSTRAINT entity_app_transpare_numeral_id_817fb940_fk_entity_ap FOREIGN KEY (numeral_id) REFERENCES public.entity_app_numeral(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_transparencyactive_files entity_app_transpare_transparencyactive_i_236ffd1b_fk_entity_ap; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_transparencyactive_files
    ADD CONSTRAINT entity_app_transpare_transparencyactive_i_236ffd1b_fk_entity_ap FOREIGN KEY (transparencyactive_id) REFERENCES public.entity_app_transparencyactive(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_transparencycolab_files entity_app_transpare_transparencycolab_id_6975b0b6_fk_entity_ap; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_transparencycolab_files
    ADD CONSTRAINT entity_app_transpare_transparencycolab_id_6975b0b6_fk_entity_ap FOREIGN KEY (transparencycolab_id) REFERENCES public.entity_app_transparencycolab(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_transparencyfocal_files entity_app_transpare_transparencyfocal_id_b0b3735a_fk_entity_ap; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_transparencyfocal_files
    ADD CONSTRAINT entity_app_transpare_transparencyfocal_id_b0b3735a_fk_entity_ap FOREIGN KEY (transparencyfocal_id) REFERENCES public.entity_app_transparencyfocal(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_transparencyactive entity_app_transpare_user_created_id_a261b22a_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_transparencyactive
    ADD CONSTRAINT entity_app_transpare_user_created_id_a261b22a_fk_auth_user FOREIGN KEY (user_created_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_transparencyfocal entity_app_transpare_user_created_id_a856316c_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_transparencyfocal
    ADD CONSTRAINT entity_app_transpare_user_created_id_a856316c_fk_auth_user FOREIGN KEY (user_created_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_transparencycolab entity_app_transpare_user_created_id_fcda3c6b_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_transparencycolab
    ADD CONSTRAINT entity_app_transpare_user_created_id_fcda3c6b_fk_auth_user FOREIGN KEY (user_created_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_transparencyactive entity_app_transpare_user_deleted_id_07a399f7_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_transparencyactive
    ADD CONSTRAINT entity_app_transpare_user_deleted_id_07a399f7_fk_auth_user FOREIGN KEY (user_deleted_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_transparencycolab entity_app_transpare_user_deleted_id_8f718658_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_transparencycolab
    ADD CONSTRAINT entity_app_transpare_user_deleted_id_8f718658_fk_auth_user FOREIGN KEY (user_deleted_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_transparencyfocal entity_app_transpare_user_deleted_id_a88ab97d_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_transparencyfocal
    ADD CONSTRAINT entity_app_transpare_user_deleted_id_a88ab97d_fk_auth_user FOREIGN KEY (user_deleted_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_transparencyfocal entity_app_transpare_user_updated_id_2e96e6de_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_transparencyfocal
    ADD CONSTRAINT entity_app_transpare_user_updated_id_2e96e6de_fk_auth_user FOREIGN KEY (user_updated_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_transparencyactive entity_app_transpare_user_updated_id_ade90e38_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_transparencyactive
    ADD CONSTRAINT entity_app_transpare_user_updated_id_ade90e38_fk_auth_user FOREIGN KEY (user_updated_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_transparencycolab entity_app_transpare_user_updated_id_dc8a26e3_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_transparencycolab
    ADD CONSTRAINT entity_app_transpare_user_updated_id_dc8a26e3_fk_auth_user FOREIGN KEY (user_updated_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_typeformats entity_app_typeformats_user_created_id_06347f66_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_typeformats
    ADD CONSTRAINT entity_app_typeformats_user_created_id_06347f66_fk_auth_user_id FOREIGN KEY (user_created_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_typeformats entity_app_typeformats_user_deleted_id_fe386807_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_typeformats
    ADD CONSTRAINT entity_app_typeformats_user_deleted_id_fe386807_fk_auth_user_id FOREIGN KEY (user_deleted_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_typeformats entity_app_typeformats_user_updated_id_180dd406_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_typeformats
    ADD CONSTRAINT entity_app_typeformats_user_updated_id_180dd406_fk_auth_user_id FOREIGN KEY (user_updated_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_typepublication entity_app_typepubli_user_created_id_888766e6_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_typepublication
    ADD CONSTRAINT entity_app_typepubli_user_created_id_888766e6_fk_auth_user FOREIGN KEY (user_created_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_typepublication entity_app_typepubli_user_deleted_id_c2703c31_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_typepublication
    ADD CONSTRAINT entity_app_typepubli_user_deleted_id_c2703c31_fk_auth_user FOREIGN KEY (user_deleted_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_app_typepublication entity_app_typepubli_user_updated_id_db8da2c9_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: auth_user
--

ALTER TABLE ONLY public.entity_app_typepublication
    ADD CONSTRAINT entity_app_typepubli_user_updated_id_db8da2c9_fk_auth_user FOREIGN KEY (user_updated_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- PostgreSQL database dump complete
--

