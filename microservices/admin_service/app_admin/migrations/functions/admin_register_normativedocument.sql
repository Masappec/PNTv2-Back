CREATE OR REPLACE FUNCTION admin_register_normative_document(
    title VARCHAR(255),
    description TEXT,
    url VARCHAR(255),
    user_insert INT
) RETURNS JSONB AS $$
DECLARE
    result JSONB;
BEGIN
    -- Insertar la nueva pedagogy area
    INSERT INTO public.app_admin_pedagogyarea (
        created_at, updated_at, deleted, deleted_at, published, user_created_id, user_deleted_id, user_updated_id)
    VALUES (current_timestamp, current_timestamp, false, null, true, user_insert, null, user_insert)
    RETURNING * INTO result;

    -- Insertar el documento normativo con el id de la pedagogy area obtenido
    INSERT INTO public.app_admin_normativedocument (
        created_at, updated_at, deleted, deleted_at, title, description, url, is_active, pedagogy_area_id, user_created_id, user_deleted_id, user_updated_id)
    VALUES (current_timestamp, current_timestamp, false, null, title, description, url, true, result.id, user_insert, null, user_insert)
    RETURNING * INTO result;

    -- Devolver el resultado JSONB con el join de las dos tablas
    RETURN (
        SELECT jsonb_build_object(
            'pedagogy_area', jsonb_build_object(
                'id', pa.id,
                'created_at', pa.created_at,
                'updated_at', pa.updated_at,
                'deleted', pa.deleted,
                'deleted_at', pa.deleted_at,
                'published', pa.published,
                'user_created_id', pa.user_created_id,
                'user_deleted_id', pa.user_deleted_id,
                'user_updated_id', pa.user_updated_id
            ),
            'normative_document', jsonb_build_object(
                'id', nd.id,
                'created_at', nd.created_at,
                'updated_at', nd.updated_at,
                'deleted', nd.deleted,
                'deleted_at', nd.deleted_at,
                'title', nd.title,
                'description', nd.description,
                'url', nd.url,
                'is_active', nd.is_active,
                'pedagogy_area_id', nd.pedagogy_area_id,
                'user_created_id', nd.user_created_id,
                'user_deleted_id', nd.user_deleted_id,
                'user_updated_id', nd.user_updated_id
            )
        )
        FROM public.app_admin_pedagogyarea pa
        JOIN public.app_admin_normativedocument nd ON pa.id = nd.pedagogy_area_id
        WHERE pa.id = result.id
    );
END;
$$ LANGUAGE plpgsql;
