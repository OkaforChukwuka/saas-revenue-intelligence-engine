SELECT 
    SUM(deal_value * (probability_percent / 100.0)) AS weighted_pipeline_value
FROM public.opportunities
WHERE status = 'open';

WITH rep_stats AS (
    SELECT 
        rep_id,
        COUNT(*) FILTER (WHERE status = 'won')::DECIMAL /
        NULLIF(COUNT(*),0) AS win_rate
    FROM public.opportunities
    GROUP BY rep_id
)
SELECT 
    sr.full_name,
    SUM(o.deal_value * rs.win_rate) AS win_rate_forecast
FROM public.opportunities o
JOIN rep_stats rs ON o.rep_id = rs.rep_id
JOIN public.sales_reps sr ON sr.rep_id = o.rep_id
WHERE o.status = 'open'
GROUP BY sr.full_name
ORDER BY win_rate_forecast DESC;

