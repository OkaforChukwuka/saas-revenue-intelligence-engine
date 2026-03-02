-- ==============================
-- ACCOUNTS
-- ==============================
CREATE TABLE public.accounts (
    account_id SERIAL PRIMARY KEY,
    account_name TEXT NOT NULL,
    industry TEXT,
    company_size INTEGER CHECK (company_size > 0),
    country TEXT,
    status TEXT CHECK (status IN ('prospect','active','churned')) DEFAULT 'prospect',
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_accounts_industry ON public.accounts(industry);
CREATE INDEX idx_accounts_status ON public.accounts(status);

-- ==============================
-- CONTACTS
-- ==============================
CREATE TABLE public.contacts (
    contact_id SERIAL PRIMARY KEY,
    account_id INTEGER REFERENCES public.accounts(account_id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    email TEXT UNIQUE,
    role TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_contacts_account ON public.contacts(account_id);

-- ==============================
-- SALES REPS
-- ==============================
CREATE TABLE public.sales_reps (
    rep_id SERIAL PRIMARY KEY,
    full_name TEXT NOT NULL,
    region TEXT,
    hire_date DATE,
    quota_amount NUMERIC(12,2) CHECK (quota_amount >= 0)
);

-- ==============================
-- OPPORTUNITIES
-- ==============================
CREATE TABLE public.opportunities (
    opportunity_id SERIAL PRIMARY KEY,
    account_id INTEGER REFERENCES public.accounts(account_id) ON DELETE CASCADE,
    rep_id INTEGER REFERENCES public.sales_reps(rep_id),
    deal_value NUMERIC(14,2) CHECK (deal_value >= 0),
    probability_percent INTEGER CHECK (probability_percent BETWEEN 0 AND 100),
    status TEXT CHECK (status IN ('open','won','lost')) DEFAULT 'open',
    created_at TIMESTAMP DEFAULT NOW(),
    expected_close_date DATE
);

CREATE INDEX idx_opportunities_status ON public.opportunities(status);
CREATE INDEX idx_opportunities_rep ON public.opportunities(rep_id);
CREATE INDEX idx_opportunities_close_date ON public.opportunities(expected_close_date);

-- ==============================
-- OPPORTUNITY STAGE HISTORY
-- ==============================
CREATE TABLE public.opportunity_stage_history (
    stage_history_id SERIAL PRIMARY KEY,
    opportunity_id INTEGER REFERENCES public.opportunities(opportunity_id) ON DELETE CASCADE,
    stage_name TEXT NOT NULL,
    entered_at TIMESTAMP DEFAULT NOW(),
    exited_at TIMESTAMP
);

CREATE INDEX idx_stage_opportunity ON public.opportunity_stage_history(opportunity_id);

-- ==============================
-- ACTIVITY TYPES
-- ==============================
CREATE TABLE public.activity_types (
    activity_type_id SERIAL PRIMARY KEY,
    name TEXT UNIQUE NOT NULL
);

-- ==============================
-- ACTIVITIES
-- ==============================
CREATE TABLE public.activities (
    activity_id SERIAL PRIMARY KEY,
    opportunity_id INTEGER REFERENCES public.opportunities(opportunity_id) ON DELETE CASCADE,
    rep_id INTEGER REFERENCES public.sales_reps(rep_id),
    activity_type_id INTEGER REFERENCES public.activity_types(activity_type_id),
    activity_date TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_activities_opportunity ON public.activities(opportunity_id);

-- ==============================
-- SUBSCRIPTIONS
-- ==============================
CREATE TABLE public.subscriptions (
    subscription_id SERIAL PRIMARY KEY,
    account_id INTEGER REFERENCES public.accounts(account_id) ON DELETE CASCADE,
    plan_name TEXT,
    start_date DATE,
    end_date DATE,
    mrr_amount NUMERIC(12,2) CHECK (mrr_amount >= 0),
    status TEXT CHECK (status IN ('active','cancelled')) DEFAULT 'active'
);

CREATE INDEX idx_subscriptions_account ON public.subscriptions(account_id);

-- ==============================
-- INVOICES
-- ==============================
CREATE TABLE public.invoices (
    invoice_id SERIAL PRIMARY KEY,
    subscription_id INTEGER REFERENCES public.subscriptions(subscription_id) ON DELETE CASCADE,
    invoice_date DATE,
    amount_due NUMERIC(12,2) CHECK (amount_due >= 0),
    amount_paid NUMERIC(12,2) DEFAULT 0,
    status TEXT CHECK (status IN ('paid','unpaid','overdue')) DEFAULT 'unpaid'
);

-- ==============================
-- PAYMENTS
-- ==============================
CREATE TABLE public.payments (
    payment_id SERIAL PRIMARY KEY,
    invoice_id INTEGER REFERENCES public.invoices(invoice_id) ON DELETE CASCADE,
    payment_date DATE,
    amount NUMERIC(12,2) CHECK (amount > 0)
);

-- ==============================
-- PRODUCT USAGE
-- ==============================
CREATE TABLE public.product_usage (
    usage_id SERIAL PRIMARY KEY,
    account_id INTEGER REFERENCES public.accounts(account_id) ON DELETE CASCADE,
    usage_date DATE,
    login_count INTEGER CHECK (login_count >= 0),
    feature_usage_count INTEGER CHECK (feature_usage_count >= 0),
    api_calls INTEGER CHECK (api_calls >= 0)
);

CREATE INDEX idx_usage_account ON public.product_usage(account_id);
CREATE INDEX idx_usage_date ON public.product_usage(usage_date);

-- ==============================
-- REVENUE SNAPSHOTS
-- ==============================
CREATE TABLE public.revenue_snapshots (
    snapshot_month DATE,
    account_id INTEGER REFERENCES public.accounts(account_id) ON DELETE CASCADE,
    mrr NUMERIC(12,2),
    arr NUMERIC(14,2),
    is_churned BOOLEAN DEFAULT FALSE,
    is_expanding BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (snapshot_month, account_id)
);

-- ==============================
-- RISK FLAGS
-- ==============================
CREATE TABLE public.risk_flags (
    risk_id SERIAL PRIMARY KEY,
    account_id INTEGER REFERENCES public.accounts(account_id),
    opportunity_id INTEGER REFERENCES public.opportunities(opportunity_id),
    risk_type TEXT,
    risk_score INTEGER CHECK (risk_score BETWEEN 1 AND 100),
    created_at TIMESTAMP DEFAULT NOW()
);

-- ==============================
-- FORECAST RUNS
-- ==============================
CREATE TABLE public.forecast_runs (
    forecast_id SERIAL PRIMARY KEY,
    run_date TIMESTAMP DEFAULT NOW(),
    forecast_type TEXT,
    projected_revenue NUMERIC(14,2),
    notes TEXT
);