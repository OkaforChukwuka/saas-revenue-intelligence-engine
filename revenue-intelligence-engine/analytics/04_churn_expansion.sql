WITH usage_comparison AS (
    SELECT 
        account_id,
        SUM(CASE WHEN usage_date >= CURRENT_DATE - INTERVAL '30 days'
                 THEN login_count ELSE 0 END) AS last_30_logins,
        SUM(CASE WHEN usage_date BETWEEN CURRENT_DATE - INTERVAL '60 days'
                                   AND CURRENT_DATE - INTERVAL '31 days'
                 THEN login_count ELSE 0 END) AS prev_30_logins
    FROM public.product_usage
    GROUP BY account_id
)
SELECT 
    uc.account_id,
    uc.last_30_logins,
    uc.prev_30_logins,
    (uc.prev_30_logins - uc.last_30_logins) AS drop_amount
FROM usage_comparison uc
JOIN public.subscriptions s ON s.account_id = uc.account_id
WHERE s.status = 'active'
  AND uc.last_30_logins < uc.prev_30_logins
ORDER BY drop_amount DESC
LIMIT 20;

INSERT INTO public.risk_flags (
    account_id,
    risk_type,
    risk_score
)
SELECT 
    uc.account_id,
    'Churn Risk - Usage Decline',
    LEAST(100, (uc.prev_30_logins - uc.last_30_logins))
FROM (
    SELECT 
        account_id,
        SUM(CASE WHEN usage_date >= CURRENT_DATE - INTERVAL '30 days'
                 THEN login_count ELSE 0 END) AS last_30_logins,
        SUM(CASE WHEN usage_date BETWEEN CURRENT_DATE - INTERVAL '60 days'
                                   AND CURRENT_DATE - INTERVAL '31 days'
                 THEN login_count ELSE 0 END) AS prev_30_logins
    FROM public.product_usage
    GROUP BY account_id
) uc
JOIN public.subscriptions s ON s.account_id = uc.account_id
WHERE s.status = 'active'
  AND uc.last_30_logins < uc.prev_30_logins;



SELECT 
    uc.account_id,
    uc.last_30_logins,
    uc.prev_30_logins,
    (uc.last_30_logins - uc.prev_30_logins) AS growth_amount
FROM (
    SELECT 
        account_id,
        SUM(CASE WHEN usage_date >= CURRENT_DATE - INTERVAL '30 days'
                 THEN login_count ELSE 0 END) AS last_30_logins,
        SUM(CASE WHEN usage_date BETWEEN CURRENT_DATE - INTERVAL '60 days'
                                   AND CURRENT_DATE - INTERVAL '31 days'
                 THEN login_count ELSE 0 END) AS prev_30_logins
    FROM public.product_usage
    GROUP BY account_id
) uc
JOIN public.subscriptions s ON s.account_id = uc.account_id
WHERE s.status = 'active'
  AND uc.last_30_logins > uc.prev_30_logins
ORDER BY growth_amount DESC
LIMIT 20;


INSERT INTO public.risk_flags (
    account_id,
    risk_type,
    risk_score
)
SELECT 
    uc.account_id,
    'Expansion Opportunity',
    LEAST(100, (uc.last_30_logins - uc.prev_30_logins))
FROM (
    SELECT 
        account_id,
        SUM(CASE WHEN usage_date >= CURRENT_DATE - INTERVAL '30 days'
                 THEN login_count ELSE 0 END) AS last_30_logins,
        SUM(CASE WHEN usage_date BETWEEN CURRENT_DATE - INTERVAL '60 days'
                                   AND CURRENT_DATE - INTERVAL '31 days'
                 THEN login_count ELSE 0 END) AS prev_30_logins
    FROM public.product_usage
    GROUP BY account_id
) uc
JOIN public.subscriptions s ON s.account_id = uc.account_id
WHERE s.status = 'active'
  AND uc.last_30_logins > uc.prev_30_logins;