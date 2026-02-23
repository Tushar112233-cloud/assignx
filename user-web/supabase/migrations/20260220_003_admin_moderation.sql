-- Admin Moderation RPCs Migration
-- Flagged content, content moderation, expert applications, supervisor/doer overviews

-- RPC: Admin get flagged content
CREATE OR REPLACE FUNCTION admin_get_flagged_content(
  p_content_type TEXT DEFAULT NULL,
  p_status TEXT DEFAULT NULL,
  p_page INT DEFAULT 1,
  p_per_page INT DEFAULT 20
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

  -- Build unified result from multiple content types
  CREATE TEMP TABLE IF NOT EXISTS flagged_items (
    id UUID,
    content_type TEXT,
    content TEXT,
    title TEXT,
    reported_by_id UUID,
    reported_by_name TEXT,
    flagged_at TIMESTAMPTZ,
    status TEXT
  ) ON COMMIT DROP;

  DELETE FROM flagged_items;

  -- Flagged campus posts
  IF p_content_type IS NULL OR p_content_type = 'campus_posts' THEN
    INSERT INTO flagged_items (id, content_type, content, title, reported_by_id, reported_by_name, flagged_at, status)
    SELECT
      cp.id,
      'campus_posts',
      cp.content,
      cp.title,
      cp.flagged_by,
      fp.full_name,
      cp.flagged_at,
      cp.status
    FROM campus_posts cp
    LEFT JOIN profiles fp ON fp.id = cp.flagged_by
    WHERE cp.is_flagged = true
      AND (p_status IS NULL OR cp.status = p_status);
  END IF;

  -- Marketplace listing reports
  IF p_content_type IS NULL OR p_content_type = 'listings' THEN
    INSERT INTO flagged_items (id, content_type, content, title, reported_by_id, reported_by_name, flagged_at, status)
    SELECT
      lr.id,
      'listings',
      lr.details,
      lr.reason,
      lr.reporter_id,
      rp.full_name,
      lr.created_at,
      lr.status
    FROM listing_reports lr
    LEFT JOIN profiles rp ON rp.id = lr.reporter_id
    WHERE (p_status IS NULL OR lr.status = p_status);
  END IF;

  -- Chat moderation logs (content violations)
  IF p_content_type IS NULL OR p_content_type = 'moderation' THEN
    INSERT INTO flagged_items (id, content_type, content, title, reported_by_id, reported_by_name, flagged_at, status)
    SELECT
      ml.id,
      'moderation',
      ml.original_content,
      ml.action_taken,
      ml.user_id,
      mp.full_name,
      ml.created_at,
      ml.severity
    FROM moderation_logs ml
    LEFT JOIN profiles mp ON mp.id = ml.user_id
    WHERE (p_status IS NULL OR ml.severity = p_status);
  END IF;

  -- Flagged chat messages
  IF p_content_type IS NULL OR p_content_type = 'chat' THEN
    INSERT INTO flagged_items (id, content_type, content, title, reported_by_id, reported_by_name, flagged_at, status)
    SELECT
      cm.id,
      'chat',
      cm.content,
      cm.flagged_reason,
      cm.sender_id,
      sp.full_name,
      cm.created_at,
      CASE WHEN cm.is_deleted THEN 'removed' ELSE 'pending' END
    FROM chat_messages cm
    LEFT JOIN profiles sp ON sp.id = cm.sender_id
    WHERE cm.is_flagged = true
      AND (p_status IS NULL OR
        CASE WHEN cm.is_deleted THEN 'removed' ELSE 'pending' END = p_status);
  END IF;

  -- Flagged doer reviews
  IF p_content_type IS NULL OR p_content_type = 'reviews' THEN
    INSERT INTO flagged_items (id, content_type, content, title, reported_by_id, reported_by_name, flagged_at, status)
    SELECT
      dr.id,
      'reviews',
      dr.review_text,
      dr.flag_reason,
      dr.reviewer_id,
      rp.full_name,
      dr.created_at,
      CASE WHEN dr.is_public = false THEN 'hidden' ELSE 'pending' END
    FROM doer_reviews dr
    LEFT JOIN profiles rp ON rp.id = dr.reviewer_id
    WHERE dr.is_flagged = true
      AND (p_status IS NULL OR
        CASE WHEN dr.is_public = false THEN 'hidden' ELSE 'pending' END = p_status);
  END IF;

  -- Flagged doers
  IF p_content_type IS NULL OR p_content_type = 'doers' THEN
    INSERT INTO flagged_items (id, content_type, content, title, reported_by_id, reported_by_name, flagged_at, status)
    SELECT
      d.id,
      'doers',
      d.bio,
      d.flag_reason,
      d.flagged_by,
      dfp.full_name,
      d.flagged_at,
      CASE WHEN d.is_activated = false THEN 'deactivated' ELSE 'pending' END
    FROM doers d
    LEFT JOIN profiles dfp ON dfp.id = d.flagged_by
    WHERE d.is_flagged = true
      AND (p_status IS NULL OR
        CASE WHEN d.is_activated = false THEN 'deactivated' ELSE 'pending' END = p_status);
  END IF;

  SELECT COUNT(*) INTO total_count FROM flagged_items;

  SELECT json_build_object(
    'data', COALESCE(json_agg(row_to_json(t)), '[]'::json),
    'total', total_count,
    'page', p_page,
    'per_page', p_per_page,
    'total_pages', CEIL(total_count::float / p_per_page)
  ) INTO result
  FROM (
    SELECT * FROM flagged_items
    ORDER BY flagged_at DESC
    LIMIT p_per_page OFFSET offset_val
  ) t;

  RETURN result;
END;
$$;

-- RPC: Admin moderate content
CREATE OR REPLACE FUNCTION admin_moderate_content(
  p_content_type TEXT,
  p_content_id UUID,
  p_action TEXT,
  p_reason TEXT,
  p_admin_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  result JSON;
BEGIN
  -- Validate action
  IF p_action NOT IN ('approve', 'remove', 'warn') THEN
    RETURN json_build_object('success', false, 'error', 'Invalid action. Must be approve, remove, or warn');
  END IF;

  -- Handle campus posts
  IF p_content_type = 'campus_posts' THEN
    IF p_action = 'approve' THEN
      UPDATE campus_posts SET is_flagged = false, is_hidden = false, status = 'active', updated_at = NOW()
      WHERE id = p_content_id;
    ELSIF p_action = 'remove' THEN
      UPDATE campus_posts SET is_hidden = true, status = 'deleted', updated_at = NOW()
      WHERE id = p_content_id;
    ELSIF p_action = 'warn' THEN
      UPDATE campus_posts SET is_flagged = false, updated_at = NOW()
      WHERE id = p_content_id;
    END IF;

  -- Handle listing reports
  ELSIF p_content_type = 'listings' THEN
    IF p_action = 'approve' THEN
      UPDATE listing_reports SET status = 'dismissed', reviewed_by = (
        SELECT profile_id FROM admins WHERE id = p_admin_id
      ), reviewed_at = NOW()
      WHERE id = p_content_id;
    ELSIF p_action = 'remove' THEN
      UPDATE listing_reports SET status = 'resolved', reviewed_by = (
        SELECT profile_id FROM admins WHERE id = p_admin_id
      ), reviewed_at = NOW()
      WHERE id = p_content_id;
    END IF;

  -- Handle chat moderation logs
  ELSIF p_content_type = 'moderation' THEN
    UPDATE moderation_logs SET action_taken = p_action, updated_at = NOW()
    WHERE id = p_content_id;

  -- Handle flagged chat messages
  ELSIF p_content_type = 'chat' THEN
    IF p_action = 'approve' THEN
      UPDATE chat_messages SET is_flagged = false WHERE id = p_content_id;
    ELSIF p_action = 'remove' THEN
      UPDATE chat_messages SET is_flagged = false, is_deleted = true, deleted_at = NOW() WHERE id = p_content_id;
    ELSIF p_action = 'warn' THEN
      UPDATE chat_messages SET is_flagged = false WHERE id = p_content_id;
    END IF;

  -- Handle flagged doer reviews
  ELSIF p_content_type = 'reviews' THEN
    IF p_action = 'approve' THEN
      UPDATE doer_reviews SET is_flagged = false, updated_at = NOW() WHERE id = p_content_id;
    ELSIF p_action = 'remove' THEN
      UPDATE doer_reviews SET is_flagged = false, is_public = false, updated_at = NOW() WHERE id = p_content_id;
    ELSIF p_action = 'warn' THEN
      UPDATE doer_reviews SET is_flagged = false, updated_at = NOW() WHERE id = p_content_id;
    END IF;

  -- Handle flagged doers
  ELSIF p_content_type = 'doers' THEN
    IF p_action = 'approve' THEN
      UPDATE doers SET is_flagged = false, flag_reason = NULL, flagged_at = NULL, flagged_by = NULL, updated_at = NOW()
      WHERE id = p_content_id;
    ELSIF p_action = 'remove' THEN
      UPDATE doers SET is_flagged = false, is_activated = false, updated_at = NOW()
      WHERE id = p_content_id;
    ELSIF p_action = 'warn' THEN
      UPDATE doers SET is_flagged = false, flag_reason = NULL, flagged_at = NULL, flagged_by = NULL, updated_at = NOW()
      WHERE id = p_content_id;
    END IF;
  ELSE
    RETURN json_build_object('success', false, 'error', 'Invalid content type. Must be campus_posts, listings, moderation, chat, reviews, or doers');
  END IF;

  -- Log to admin audit
  INSERT INTO admin_audit_logs (admin_id, action, target_type, target_id, details)
  VALUES (
    p_admin_id,
    'moderate_content',
    p_content_type,
    p_content_id,
    json_build_object('action', p_action, 'reason', p_reason)::jsonb
  );

  RETURN json_build_object('success', true, 'action', p_action, 'content_type', p_content_type);
END;
$$;

-- RPC: Admin get doer applications (activation status)
CREATE OR REPLACE FUNCTION admin_get_doer_applications(
  p_status TEXT DEFAULT NULL,
  p_page INT DEFAULT 1,
  p_per_page INT DEFAULT 20
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
  FROM doers d
  JOIN doer_activation da ON da.doer_id = d.id
  WHERE (p_status IS NULL OR
    CASE
      WHEN p_status = 'activated' THEN da.is_fully_activated = true
      WHEN p_status = 'pending' THEN da.is_fully_activated = false OR da.is_fully_activated IS NULL
      ELSE true
    END);

  SELECT json_build_object(
    'data', COALESCE(json_agg(row_to_json(t)), '[]'::json),
    'total', total_count,
    'page', p_page,
    'per_page', p_per_page,
    'total_pages', CEIL(total_count::float / p_per_page)
  ) INTO result
  FROM (
    SELECT
      d.id as doer_id,
      d.profile_id,
      p.full_name,
      p.email,
      p.avatar_url,
      d.qualification,
      d.experience_level,
      d.university_name,
      d.bio,
      d.is_activated,
      d.average_rating,
      d.total_reviews,
      d.total_projects_completed,
      da.is_fully_activated,
      da.training_completed,
      da.quiz_passed,
      da.bank_details_added,
      da.activated_at,
      d.created_at
    FROM doers d
    JOIN doer_activation da ON da.doer_id = d.id
    JOIN profiles p ON p.id = d.profile_id
    WHERE (p_status IS NULL OR
      CASE
        WHEN p_status = 'activated' THEN da.is_fully_activated = true
        WHEN p_status = 'pending' THEN da.is_fully_activated = false OR da.is_fully_activated IS NULL
        ELSE true
      END)
    ORDER BY d.created_at DESC
    LIMIT p_per_page OFFSET offset_val
  ) t;

  RETURN result;
END;
$$;

-- RPC: Admin get supervisor overview
CREATE OR REPLACE FUNCTION admin_get_supervisor_overview(
  p_page INT DEFAULT 1,
  p_per_page INT DEFAULT 20
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
  FROM profiles WHERE user_type = 'supervisor';

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
      p.is_active,
      p.created_at,
      s.id as supervisor_id,
      s.qualification,
      s.years_of_experience,
      s.is_activated as supervisor_activated,
      COALESCE(s.average_rating, 0) as avg_rating,
      COALESCE(s.total_reviews, 0) as total_reviews,
      COALESCE(s.total_projects_managed, 0) as total_managed,
      COALESCE(s.total_earnings, 0) as total_earnings,
      COUNT(pr.id) as total_projects,
      COUNT(pr.id) FILTER (WHERE pr.status = 'completed') as completed_projects,
      COUNT(pr.id) FILTER (WHERE pr.status NOT IN ('completed', 'cancelled', 'refunded', 'draft')) as active_projects,
      CASE
        WHEN COUNT(pr.id) > 0
        THEN ROUND((COUNT(pr.id) FILTER (WHERE pr.status = 'completed')::decimal / COUNT(pr.id)) * 100, 1)
        ELSE 0
      END as completion_rate
    FROM profiles p
    LEFT JOIN supervisors s ON s.profile_id = p.id
    LEFT JOIN projects pr ON pr.supervisor_id = s.id
    WHERE p.user_type = 'supervisor'
    GROUP BY p.id, p.full_name, p.email, p.avatar_url, p.is_active, p.created_at,
             s.id, s.qualification, s.years_of_experience, s.is_activated,
             s.average_rating, s.total_reviews, s.total_projects_managed, s.total_earnings
    ORDER BY total_projects DESC
    LIMIT p_per_page OFFSET offset_val
  ) t;

  RETURN result;
END;
$$;

-- RPC: Admin get doer overview
CREATE OR REPLACE FUNCTION admin_get_doer_overview(
  p_page INT DEFAULT 1,
  p_per_page INT DEFAULT 20
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
  FROM profiles WHERE user_type = 'doer';

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
      p.is_active,
      p.created_at,
      d.id as doer_id,
      d.experience_level,
      d.qualification,
      d.is_activated as doer_activated,
      COALESCE(d.average_rating, 0) as avg_rating,
      COALESCE(d.total_reviews, 0) as total_reviews,
      COALESCE(d.total_projects_completed, 0) as completed_tasks,
      COALESCE(d.total_earnings, 0) as total_earnings,
      COALESCE(d.success_rate, 0) as completion_rate,
      COUNT(pr.id) as total_tasks,
      COUNT(pr.id) FILTER (WHERE pr.status NOT IN ('completed', 'cancelled', 'refunded', 'draft')) as active_tasks
    FROM profiles p
    LEFT JOIN doers d ON d.profile_id = p.id
    LEFT JOIN projects pr ON pr.doer_id = d.id
    WHERE p.user_type = 'doer'
    GROUP BY p.id, p.full_name, p.email, p.avatar_url, p.is_active, p.created_at,
             d.id, d.experience_level, d.qualification, d.is_activated,
             d.average_rating, d.total_reviews, d.total_projects_completed,
             d.total_earnings, d.success_rate
    ORDER BY total_tasks DESC
    LIMIT p_per_page OFFSET offset_val
  ) t;

  RETURN result;
END;
$$;
