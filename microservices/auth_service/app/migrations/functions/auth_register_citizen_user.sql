-- PostgreSQL Example
CREATE OR REPLACE FUNCTION auth_register_citizen_user(
    p_username VARCHAR,
    p_email VARCHAR,
    p_password VARCHAR,
    p_first_name VARCHAR,
    p_last_name VARCHAR,
    p_identification VARCHAR,
    p_phone VARCHAR,
    p_city VARCHAR,
    p_race VARCHAR,
    p_disability BOOLEAN,
    p_age_range VARCHAR,
    p_province VARCHAR,
	p_gender VARCHAR,
    p_accept_terms BOOLEAN
) RETURNS JSONB AS $$
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
END $$ LANGUAGE plpgsql;
