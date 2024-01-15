
CREATE OR REPLACE FUNCTION admin_select_pedagogy_area() RETURNS JSONB AS $$
DECLARE
    result JSONB;
BEGIN
    -- Consultar si existe un área de pedagogía
  

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
