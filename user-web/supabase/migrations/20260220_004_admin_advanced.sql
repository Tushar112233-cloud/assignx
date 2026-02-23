-- Admin Advanced Migration
-- Learning resources table, analytics RPCs, college stats, RLS

-- Create learning_resources table
CREATE TABLE IF NOT EXISTS learning_resources (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  content_type TEXT NOT NULL DEFAULT 'article', -- article, video, pdf, link
  content_url TEXT,
  thumbnail_url TEXT,
  category TEXT,
  tags TEXT[] DEFAULT '{}',
  target_audience TEXT[] DEFAULT '{}', -- student, professional, business, doer, supervisor
  is_active BOOLEAN DEFAULT true,
  is_featured BOOLEAN DEFAULT false,
  view_count INT DEFAULT 0,
  created_by UUID REFERENCES admins(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_learning_resources_category ON learning_resources(category);
CREATE INDEX idx_learning_resources_is_active ON learning_resources(is_active);

-- RLS for learning_resources
ALTER TABLE learning_resources ENABLE ROW LEVEL SECURITY;

-- Admins: full access
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'admins_manage_learning_resources') THEN
    CREATE POLICY admins_manage_learning_resources ON learning_resources FOR ALL
    USING (EXISTS (SELECT 1 FROM admins WHERE profile_id = auth.uid()));
  END IF;

  -- Authenticated users: read active resources
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'users_read_active_learning_resources') THEN
    CREATE POLICY users_read_active_learning_resources ON learning_resources FOR SELECT
    USING (is_active = true AND auth.uid() IS NOT NULL);
  END IF;
END $$;

GRANT SELECT ON learning_resources TO authenticated;

-- RPC: Admin get analytics overview
CREATE OR REPLACE FUNCTION admin_get_analytics_overview(p_period TEXT DEFAULT '30d')
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  result JSON;
  date_from TIMESTAMPTZ;
  prev_date_from TIMESTAMPTZ;
  days_back INT;
BEGIN
  days_back := CASE
    WHEN p_period = '7d' THEN 7
    WHEN p_period = '30d' THEN 30
    WHEN p_period = '90d' THEN 90
    ELSE 30
  END;

  date_from := NOW() - (days_back || ' days')::interval;
  prev_date_from := date_from - (days_back || ' days')::interval;

  SELECT json_build_object(
    'user_growth', json_build_object(
      'current_period', (SELECT COUNT(*) FROM profiles WHERE created_at >= date_from),
      'previous_period', (SELECT COUNT(*) FROM profiles WHERE created_at >= prev_date_from AND created_at < date_from),
      'total', (SELECT COUNT(*) FROM profiles)
    ),
    'revenue_trend', json_build_object(
      'current_period', COALESCE(
        (SELECT SUM(amount) FROM wallet_transactions WHERE transaction_type = 'project_payment' AND status = 'completed' AND created_at >= date_from),
        0
      ),
      'previous_period', COALESCE(
        (SELECT SUM(amount) FROM wallet_transactions WHERE transaction_type = 'project_payment' AND status = 'completed' AND created_at >= prev_date_from AND created_at < date_from),
        0
      )
    ),
    'project_completion_rate', COALESCE(
      (SELECT ROUND(
        (COUNT(*) FILTER (WHERE status = 'completed')::decimal / NULLIF(COUNT(*), 0)) * 100, 1
      ) FROM projects WHERE created_at >= date_from),
      0
    ),
    'avg_project_duration_days', COALESCE(
      (SELECT AVG(EXTRACT(EPOCH FROM (updated_at - created_at)) / 86400)
       FROM projects WHERE status = 'completed' AND created_at >= date_from),
      0
    ),
    'top_subjects', (
      SELECT COALESCE(json_agg(row_to_json(s)), '[]'::json)
      FROM (
        SELECT sub.name as subject, COUNT(*) as count
        FROM projects pr
        LEFT JOIN subjects sub ON sub.id = pr.subject_id
        WHERE pr.created_at >= date_from AND pr.subject_id IS NOT NULL
        GROUP BY sub.name
        ORDER BY count DESC
        LIMIT 5
      ) s
    ),
    'user_type_distribution', json_build_object(
      'student', (SELECT COUNT(*) FROM profiles WHERE user_type = 'student'),
      'professional', (SELECT COUNT(*) FROM profiles WHERE user_type = 'professional'),
      'business', (SELECT COUNT(*) FROM profiles WHERE user_type = 'business'),
      'supervisor', (SELECT COUNT(*) FROM profiles WHERE user_type = 'supervisor'),
      'doer', (SELECT COUNT(*) FROM profiles WHERE user_type = 'doer')
    )
  ) INTO result;

  RETURN result;
END;
$$;

-- RPC: Admin get college/university stats
CREATE OR REPLACE FUNCTION admin_get_college_stats()
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_build_object(
    'total_universities', (SELECT COUNT(*) FROM universities WHERE is_active = true),
    'total_students_with_university', (SELECT COUNT(*) FROM students WHERE university_id IS NOT NULL),
    'universities', (
      SELECT COALESCE(json_agg(row_to_json(c)), '[]'::json)
      FROM (
        SELECT
          u.id as university_id,
          u.name as university_name,
          u.short_name,
          u.city,
          u.state,
          COUNT(s.id) as student_count
        FROM universities u
        LEFT JOIN students s ON s.university_id = u.id
        WHERE u.is_active = true
        GROUP BY u.id, u.name, u.short_name, u.city, u.state
        ORDER BY student_count DESC
      ) c
    )
  ) INTO result;

  RETURN result;
END;
$$;
