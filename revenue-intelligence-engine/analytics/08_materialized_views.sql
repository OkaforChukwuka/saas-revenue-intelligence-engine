CREATE MATERIALIZED VIEW public.mv_monthly_revenue AS
SELECT 
    snapshot_month,
    SUM(mrr) AS total_mrr,
    SUM(arr) AS total_arr
FROM public.revenue_snapshots
GROUP BY snapshot_month
ORDER BY snapshot_month;