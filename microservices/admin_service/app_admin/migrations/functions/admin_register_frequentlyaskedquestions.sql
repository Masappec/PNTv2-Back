
CREATE OR REPLACE FUNCTION admin_register_frequently_asked_questions(
    question_text VARCHAR(255),
    answer_text TEXT,
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

    -- Insertar la pregunta frecuente con el id de la pedagogy area obtenido
    INSERT INTO public.app_admin_frequentlyaskedquestions (
        created_at, updated_at, deleted, deleted_at, question, answer, is_active, pedagogy_area_id, user_created_id, user_deleted_id, user_updated_id)
    VALUES (current_timestamp, current_timestamp, false, null, question_text, answer_text, true, result.id, user_insert, null, user_insert)
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
            'faq', jsonb_build_object(
                'id', faq.id,
                'created_at', faq.created_at,
                'updated_at', faq.updated_at,
                'deleted', faq.deleted,
                'deleted_at', faq.deleted_at,
                'question', faq.question,
                'answer', faq.answer,
                'is_active', faq.is_active,
                'pedagogy_area_id', faq.pedagogy_area_id,
                'user_created_id', faq.user_created_id,
                'user_deleted_id', faq.user_deleted_id,
                'user_updated_id', faq.user_updated_id
            )
        )
        FROM public.app_admin_pedagogyarea pa
        JOIN public.app_admin_frequentlyaskedquestions faq ON pa.id = faq.pedagogy_area_id
        WHERE pa.id = result.id
    );
END;
$$ LANGUAGE plpgsql;
