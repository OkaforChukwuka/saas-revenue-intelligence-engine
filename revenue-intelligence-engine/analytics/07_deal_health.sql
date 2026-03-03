CREATE VIEW public.v_deal_health AS
WITH activity_counts AS (
    SELECT 
        opportunity_id,
        COUNT(*) AS activity_count
    FROM public.activities
    GROUP BY opportunity_id
),
stage_duration AS (
    SELECT 
        opportunity_id,
        SUM(EXTRACT(DAY FROM (COALESCE(exited_at, NOW()) - entered_at)))
            AS total_days
    FROM public.opportunity_stage_history
    GROUP BY opportunity_id
)
SELECT 
    o.opportunity_id,
    o.deal_value,
    o.probability_percent,
    COALESCE(ac.activity_count,0) AS activity_count,
    COALESCE(sd.total_days,0) AS total_pipeline_days,
    ROUND(
        (o.probability_percent * 0.5) +
        (LEAST(COALESCE(ac.activity_count,0),20) * 2) -
        (LEAST(COALESCE(sd.total_days,0),60) * 0.5),
        2
    ) AS deal_health_score
FROM public.opportunities o
LEFT JOIN activity_counts ac ON ac.opportunity_id = o.opportunity_id
LEFT JOIN stage_duration sd ON sd.opportunity_id = o.opportunity_id;