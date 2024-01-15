
CREATE OR REPLACE FUNCTION admin_register_pedagogy_area(
    preguntas ASKED_QUESTION[],
    tutoriales TUTORIAL[],
    normativas NORMATIVE[],
    user_insert INTEGER
) RETURNS JSONB AS $$
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
$$ LANGUAGE plpgsql;
