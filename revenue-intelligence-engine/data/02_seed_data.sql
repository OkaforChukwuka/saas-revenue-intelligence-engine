INSERT INTO public.sales_reps (full_name, region, hire_date, quota_amount)
SELECT 
    'Rep ' || gs,
    (ARRAY['North America','Europe','APAC','Africa'])[floor(random()*4+1)],
    CURRENT_DATE - (random()*1000)::INT,
    (random()*500000 + 200000)::NUMERIC(12,2)
FROM generate_series(1,15) gs;


INSERT INTO public.opportunities (
    account_id,
    rep_id,
    deal_value,
    probability_percent,
    status,
    expected_close_date
)
SELECT
    (random()*119 + 1)::INT,
    (random()*14 + 1)::INT,
    (random()*100000 + 10000)::NUMERIC(14,2),
    (random()*100)::INT,
    (ARRAY['open','won','lost'])[floor(random()*3+1)],
    CURRENT_DATE + (random()*180)::INT
FROM generate_series(1,320);


INSERT INTO public.activity_types (name)
VALUES ('Call'),('Email'),('Demo'),('Meeting');


INSERT INTO public.activities (
    opportunity_id,
    rep_id,
    activity_type_id,
    activity_date
)
SELECT
    (random()*319 + 1)::INT,
    (random()*14 + 1)::INT,
    (random()*3 + 1)::INT,
    NOW() - (random()*90 || ' days')::INTERVAL
FROM generate_series(1,1200);