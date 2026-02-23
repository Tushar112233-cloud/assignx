-- Admin Foundation Migration
-- Add email and is_active to admins table (if not exist)
-- Create admin_audit_logs table
-- Create RPC functions for dashboard stats
-- Create admin RLS policies

-- Add email column to admins (for credential login)
ALTER TABLE admins ADD COLUMN IF NOT EXISTS email TEXT UNIQUE;
ALTER TABLE admins ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;

-- Admin audit logs table
CREATE TABLE IF NOT EXISTS admin_audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  admin_id UUID NOT NULL REFERENCES admins(id),
  action TEXT NOT NULL,
  target_type TEXT,
  target_id UUID,
  details JSONB,
  ip_address INET,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_admin_audit_logs_admin_id ON admin_audit_logs(admin_id);
CREATE INDEX idx_admin_audit_logs_created_at ON admin_audit_logs(created_at DESC);

-- RPC: Get admin dashboard stats
CREATE OR REPLACE FUNCTION get_admin_dashboard_stats()
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_build_object(
    'total_users', (SELECT COUNT(*) FROM profiles),
    'active_projects', (SELECT COUNT(*) FROM projects WHERE status NOT IN ('completed', 'cancelled', 'refunded', 'draft')),
    'total_revenue', (SELECT COALESCE(SUM(amount), 0) FROM wallet_transactions WHERE transaction_type = 'project_payment' AND status = 'completed'),
    'pending_tickets', (SELECT COUNT(*) FROM support_tickets WHERE status IN ('open', 'in_progress')),
    'new_users_today', (SELECT COUNT(*) FROM profiles WHERE created_at >= CURRENT_DATE),
    'new_users_week', (SELECT COUNT(*) FROM profiles WHERE created_at >= CURRENT_DATE - INTERVAL '7 days'),
    'new_users_month', (SELECT COUNT(*) FROM profiles WHERE created_at >= CURRENT_DATE - INTERVAL '30 days'),
    'total_supervisors', (SELECT COUNT(*) FROM profiles WHERE user_type = 'supervisor'),
    'total_doers', (SELECT COUNT(*) FROM profiles WHERE user_type = 'doer'),
    'total_wallet_balance', (SELECT COALESCE(SUM(balance), 0) FROM wallets)
  ) INTO result;
  RETURN result;
END;
$$;

-- RPC: Get user growth chart data
CREATE OR REPLACE FUNCTION get_user_growth_chart_data(period TEXT DEFAULT '30d')
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  result JSON;
  days_back INT;
BEGIN
  days_back := CASE
    WHEN period = '7d' THEN 7
    WHEN period = '30d' THEN 30
    WHEN period = '90d' THEN 90
    ELSE 30
  END;

  SELECT json_agg(row_to_json(t)) INTO result
  FROM (
    SELECT
      d::date as date,
      COUNT(*) FILTER (WHERE p.user_type = 'student') as students,
      COUNT(*) FILTER (WHERE p.user_type = 'professional') as professionals,
      COUNT(*) FILTER (WHERE p.user_type = 'business') as businesses,
      COUNT(*) FILTER (WHERE p.user_type = 'supervisor') as supervisors,
      COUNT(*) FILTER (WHERE p.user_type = 'doer') as doers,
      COUNT(*) as total
    FROM generate_series(
      CURRENT_DATE - (days_back || ' days')::interval,
      CURRENT_DATE,
      '1 day'::interval
    ) d
    LEFT JOIN profiles p ON p.created_at::date = d::date
    GROUP BY d::date
    ORDER BY d::date
  ) t;
  RETURN result;
END;
$$;

-- RPC: Get revenue chart data
CREATE OR REPLACE FUNCTION get_revenue_chart_data(period TEXT DEFAULT '30d')
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  result JSON;
  days_back INT;
BEGIN
  days_back := CASE
    WHEN period = '7d' THEN 7
    WHEN period = '30d' THEN 30
    WHEN period = '90d' THEN 90
    ELSE 30
  END;

  SELECT json_agg(row_to_json(t)) INTO result
  FROM (
    SELECT
      d::date as date,
      COALESCE(SUM(wt.amount) FILTER (WHERE wt.transaction_type = 'project_payment'), 0) as revenue,
      COALESCE(SUM(wt.amount) FILTER (WHERE wt.transaction_type = 'refund'), 0) as refunds
    FROM generate_series(
      CURRENT_DATE - (days_back || ' days')::interval,
      CURRENT_DATE,
      '1 day'::interval
    ) d
    LEFT JOIN wallet_transactions wt ON wt.created_at::date = d::date AND wt.status = 'completed'
    GROUP BY d::date
    ORDER BY d::date
  ) t;
  RETURN result;
END;
$$;

-- RPC: Admin get users with pagination
CREATE OR REPLACE FUNCTION admin_get_users(
  p_search TEXT DEFAULT NULL,
  p_user_type TEXT DEFAULT NULL,
  p_status TEXT DEFAULT NULL,
  p_page INT DEFAULT 1,
  p_per_page INT DEFAULT 20,
  p_sort_by TEXT DEFAULT 'created_at',
  p_sort_order TEXT DEFAULT 'desc'
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  result JSON;
  total_count INT;
  offset_val INT;
BEGIN
  offset_val := (p_page - 1) * p_per_page;

  SELECT COUNT(*) INTO total_count
  FROM profiles p
  WHERE (p_search IS NULL OR p.full_name ILIKE '%' || p_search || '%' OR p.email ILIKE '%' || p_search || '%')
    AND (p_user_type IS NULL OR p.user_type = p_user_type)
    AND (p_status IS NULL OR
      CASE WHEN p_status = 'active' THEN p.is_active = true
           WHEN p_status = 'suspended' THEN p.is_active = false
           ELSE true END);

  SELECT json_build_object(
    'data', COALESCE(json_agg(row_to_json(t)), '[]'::json),
    'total', total_count,
    'page', p_page,
    'per_page', p_per_page,
    'total_pages', CEIL(total_count::float / p_per_page)
  ) INTO result
  FROM (
    SELECT
      p.id,
      p.full_name,
      p.email,
      p.avatar_url,
      p.user_type,
      p.is_active,
      p.city,
      p.state,
      p.created_at,
      COALESCE(w.balance, 0) as wallet_balance,
      (SELECT COUNT(*) FROM projects pr WHERE pr.user_id = p.id) as project_count
    FROM profiles p
    LEFT JOIN wallets w ON w.profile_id = p.id
    WHERE (p_search IS NULL OR p.full_name ILIKE '%' || p_search || '%' OR p.email ILIKE '%' || p_search || '%')
      AND (p_user_type IS NULL OR p.user_type = p_user_type)
      AND (p_status IS NULL OR
        CASE WHEN p_status = 'active' THEN p.is_active = true
             WHEN p_status = 'suspended' THEN p.is_active = false
             ELSE true END)
    ORDER BY
      CASE WHEN p_sort_order = 'asc' THEN
        CASE p_sort_by
          WHEN 'full_name' THEN p.full_name
          WHEN 'email' THEN p.email
          WHEN 'created_at' THEN p.created_at::text
          ELSE p.created_at::text
        END
      END ASC NULLS LAST,
      CASE WHEN p_sort_order = 'desc' OR p_sort_order IS NULL THEN
        CASE p_sort_by
          WHEN 'full_name' THEN p.full_name
          WHEN 'email' THEN p.email
          WHEN 'created_at' THEN p.created_at::text
          ELSE p.created_at::text
        END
      END DESC NULLS LAST
    LIMIT p_per_page OFFSET offset_val
  ) t;

  RETURN result;
END;
$$;

-- Admin RLS policies
-- Enable RLS on tables that need admin access
DO $$
BEGIN
  -- Policy for admins to read all profiles
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'admins_read_all_profiles') THEN
    CREATE POLICY admins_read_all_profiles ON profiles FOR SELECT
    USING (EXISTS (SELECT 1 FROM admins WHERE profile_id = auth.uid()));
  END IF;

  -- Policy for admins to update profiles
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'admins_update_profiles') THEN
    CREATE POLICY admins_update_profiles ON profiles FOR UPDATE
    USING (EXISTS (SELECT 1 FROM admins WHERE profile_id = auth.uid()));
  END IF;

  -- Policy for admins to read all projects
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'admins_read_all_projects') THEN
    CREATE POLICY admins_read_all_projects ON projects FOR SELECT
    USING (EXISTS (SELECT 1 FROM admins WHERE profile_id = auth.uid()));
  END IF;

  -- Policy for admins to update projects
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'admins_update_projects') THEN
    CREATE POLICY admins_update_projects ON projects FOR UPDATE
    USING (EXISTS (SELECT 1 FROM admins WHERE profile_id = auth.uid()));
  END IF;

  -- Policy for admins to read wallets
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'admins_read_all_wallets') THEN
    CREATE POLICY admins_read_all_wallets ON wallets FOR SELECT
    USING (EXISTS (SELECT 1 FROM admins WHERE profile_id = auth.uid()));
  END IF;

  -- Policy for admins to read wallet_transactions
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'admins_read_all_wallet_transactions') THEN
    CREATE POLICY admins_read_all_wallet_transactions ON wallet_transactions FOR SELECT
    USING (EXISTS (SELECT 1 FROM admins WHERE profile_id = auth.uid()));
  END IF;

  -- Policy for admins to read/update support_tickets
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'admins_read_all_support_tickets') THEN
    CREATE POLICY admins_read_all_support_tickets ON support_tickets FOR SELECT
    USING (EXISTS (SELECT 1 FROM admins WHERE profile_id = auth.uid()));
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'admins_update_support_tickets') THEN
    CREATE POLICY admins_update_support_tickets ON support_tickets FOR UPDATE
    USING (EXISTS (SELECT 1 FROM admins WHERE profile_id = auth.uid()));
  END IF;

  -- Policy for admins to manage banners
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'admins_manage_banners') THEN
    CREATE POLICY admins_manage_banners ON banners FOR ALL
    USING (EXISTS (SELECT 1 FROM admins WHERE profile_id = auth.uid()));
  END IF;

  -- Policy for admins to manage app_settings
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'admins_manage_app_settings') THEN
    CREATE POLICY admins_manage_app_settings ON app_settings FOR ALL
    USING (EXISTS (SELECT 1 FROM admins WHERE profile_id = auth.uid()));
  END IF;

  -- Policy for admin audit logs
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'admins_manage_audit_logs') THEN
    ALTER TABLE admin_audit_logs ENABLE ROW LEVEL SECURITY;
    CREATE POLICY admins_manage_audit_logs ON admin_audit_logs FOR ALL
    USING (EXISTS (SELECT 1 FROM admins WHERE profile_id = auth.uid()));
  END IF;
END $$;
