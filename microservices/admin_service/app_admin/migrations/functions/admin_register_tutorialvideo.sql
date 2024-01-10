CREATE OR REPLACE FUNCTION admin_register_tutorial_video(
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

    -- Insertar el tutorial video con el id de la pedagogy area obtenido
    INSERT INTO public.app_admin_tutorialvideo (
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
            'tutorial_video', jsonb_build_object(
                'id', tv.id,
                'created_at', tv.created_at,
                'updated_at', tv.updated_at,
                'deleted', tv.deleted,
                'deleted_at', tv.deleted_at,
                'title', tv.title,
                'description', tv.description,
                'url', tv.url,
                'is_active', tv.is_active,
                'pedagogy_area_id', tv.pedagogy_area_id,
                'user_created_id', tv.user_created_id,
                'user_deleted_id', tv.user_deleted_id,
                'user_updated_id', tv.user_updated_id
            )
        )
        FROM public.app_admin_pedagogyarea pa
        JOIN public.app_admin_tutorialvideo tv ON pa.id = tv.pedagogy_area_id
        WHERE pa.id = result.id
    );
END;
$$ LANGUAGE plpgsql;
