WITH total_pipeline AS (
    SELECT COUNT(*) AS total_deals
    FROM public.opportunities
),
won_deals AS (
    SELECT COUNT(*) AS won_count
    FROM public.opportunities
    WHERE status = 'won'
)
SELECT 
    w.won_count,
    t.total_deals,
    ROUND((w.won_count::DECIMAL / t.total_deals) * 100, 2) AS overall_conversion_rate_percent
FROM total_pipeline t, won_deals w;


SELECT 
    sr.full_name,
    COUNT(*) FILTER (WHERE o.status = 'won') AS won_deals,
    COUNT(*) AS total_deals,
    ROUND(
        COUNT(*) FILTER (WHERE o.status = 'won')::DECIMAL 
        / NULLIF(COUNT(*),0) * 100,
        2
    ) AS conversion_rate_percent
FROM public.opportunities o
JOIN public.sales_reps sr ON o.rep_id = sr.rep_id
GROUP BY sr.full_name
ORDER BY conversion_rate_percent DESC;


SELECT 
    stage_name,
    ROUND(AVG(
        EXTRACT(DAY FROM (COALESCE(exited_at, NOW()) - entered_at))
    ),2) AS avg_days_in_stage
FROM public.opportunity_stage_history
GROUP BY stage_name
ORDER BY avg_days_in_stage DESC;

SELECT 
    o.opportunity_id,
    o.deal_value,
    SUM(EXTRACT(DAY FROM (COALESCE(osh.exited_at, NOW()) - osh.entered_at))) 
        AS total_pipeline_days
FROM public.opportunity_stage_history osh
JOIN public.opportunities o ON o.opportunity_id = osh.opportunity_id
WHERE o.status = 'open'
GROUP BY o.opportunity_id, o.deal_value
ORDER BY total_pipeline_days DESC
LIMIT 20;


SELECT 
    sr.full_name,
    ROUND(AVG(
        EXTRACT(DAY FROM (COALESCE(osh.exited_at, NOW()) - osh.entered_at))
    ),2) AS avg_stage_duration_days
FROM public.opportunity_stage_history osh
JOIN public.opportunities o ON o.opportunity_id = osh.opportunity_id
JOIN public.sales_reps sr ON o.rep_id = sr.rep_id
GROUP BY sr.full_name
ORDER BY avg_stage_duration_days;