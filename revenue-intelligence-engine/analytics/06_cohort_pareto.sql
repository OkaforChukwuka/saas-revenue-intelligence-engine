WITH cohort_base AS (
    SELECT 
        account_id,
        date_trunc('month', MIN(start_date)) AS cohort_month
    FROM public.subscriptions
    GROUP BY account_id
)
SELECT * FROM cohort_base
LIMIT 10;

WITH cohort_base AS (
    SELECT 
        account_id,
        date_trunc('month', MIN(start_date)) AS cohort_month
    FROM public.subscriptions
    GROUP BY account_id
)
SELECT 
    cb.cohort_month,
    rs.snapshot_month,
    SUM(rs.mrr) AS cohort_mrr
FROM cohort_base cb
JOIN public.revenue_snapshots rs 
    ON rs.account_id = cb.account_id
GROUP BY cb.cohort_month, rs.snapshot_month
ORDER BY cb.cohort_month, rs.snapshot_month;

WITH cohort_base AS (
    SELECT 
        account_id,
        date_trunc('month', MIN(start_date)) AS cohort_month
    FROM public.subscriptions
    GROUP BY account_id
)
SELECT 
    cb.cohort_month,
    COUNT(*) FILTER (WHERE a.status = 'active') 
        AS active_accounts,
    COUNT(*) AS total_accounts,
    ROUND(
        COUNT(*) FILTER (WHERE a.status = 'active')::DECIMAL 
        / COUNT(*) * 100,
        2
    ) AS retention_percent
FROM cohort_base cb
JOIN public.accounts a ON a.account_id = cb.account_id
GROUP BY cb.cohort_month
ORDER BY cb.cohort_month;