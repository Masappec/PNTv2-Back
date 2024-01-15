

CREATE OR REPLACE FUNCTION admin_update_pedagogy_area(
    preguntas ASKED_QUESTION[],
    tutoriales TUTORIAL[],
    normativas NORMATIVE[],
    user_update INTEGER,
    area_pedagogy_id INTEGER
) RETURNS JSONB AS $$
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
$$ LANGUAGE plpgsql;
