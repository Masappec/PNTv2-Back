
CREATE OR REPLACE FUNCTION admin_select_pedagogy_area() RETURNS JSONB AS $$
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
$$ LANGUAGE plpgsql;
