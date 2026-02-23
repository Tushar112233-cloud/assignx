-- ============================================
-- Student-Only Housing Access Migration
-- Date: 2026-01-25
-- Description: Adds RLS policy to restrict housing listings to students only.
--              Non-student users (professionals) cannot view housing posts.
-- ============================================

-- ============================================
-- 1. Drop existing select policy for campus_posts
--    We need to recreate it with the housing restriction
-- ============================================

DROP POLICY IF EXISTS campus_posts_select_policy ON campus_posts;

-- ============================================
-- 2. Create new select policy with housing restriction
--    Housing posts are only visible to students.
--    All other post types are visible to everyone.
-- ============================================

CREATE POLICY campus_posts_select_policy ON campus_posts
  FOR SELECT
  USING (
    -- Users can always see their own posts (regardless of type)
    user_id = auth.uid()
    -- Admins can see all posts
    OR EXISTS (SELECT 1 FROM admins WHERE admins.profile_id = auth.uid())
    -- For active, non-hidden posts:
    OR (
      status = 'active'
      AND is_hidden = FALSE
      AND (
        -- Non-housing posts are visible to everyone
        category != 'housing'
        -- Housing posts are only visible to students
        OR (
          category = 'housing'
          AND EXISTS (
            SELECT 1 FROM profiles
            WHERE profiles.id = auth.uid()
            AND profiles.user_type = 'student'
          )
        )
      )
    )
  );

-- ============================================
-- 3. Create a helper function for checking student status
--    This can be used in queries for additional safety
-- ============================================

CREATE OR REPLACE FUNCTION is_current_user_student()
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
AS $$
  SELECT EXISTS (
    SELECT 1 FROM profiles
    WHERE id = auth.uid()
    AND user_type = 'student'
  );
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION is_current_user_student() TO authenticated;

-- ============================================
-- 4. Create function to get campus posts with housing filtering
--    This ensures server-side filtering even if RLS is bypassed
-- ============================================

CREATE OR REPLACE FUNCTION get_campus_posts_for_user(
  p_college_id UUID DEFAULT NULL,
  p_category campus_post_category DEFAULT NULL,
  p_search_query TEXT DEFAULT NULL,
  p_exclude_housing BOOLEAN DEFAULT FALSE,
  p_limit INTEGER DEFAULT 20,
  p_offset INTEGER DEFAULT 0
)
RETURNS SETOF campus_posts
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_is_student BOOLEAN;
BEGIN
  -- Check if current user is a student
  SELECT EXISTS (
    SELECT 1 FROM profiles
    WHERE id = auth.uid()
    AND user_type = 'student'
  ) INTO v_is_student;

  RETURN QUERY
  SELECT *
  FROM campus_posts
  WHERE
    status = 'active'
    AND is_hidden = FALSE
    AND (p_college_id IS NULL OR college_id = p_college_id)
    AND (p_category IS NULL OR category = p_category)
    -- Exclude housing for non-students or if explicitly requested
    AND (
      category != 'housing'
      OR (v_is_student AND NOT p_exclude_housing)
    )
    AND (
      p_search_query IS NULL
      OR to_tsvector('english', coalesce(title, '') || ' ' || coalesce(content, ''))
         @@ plainto_tsquery('english', p_search_query)
    )
  ORDER BY is_pinned DESC, created_at DESC
  LIMIT p_limit
  OFFSET p_offset;
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION get_campus_posts_for_user TO authenticated;

-- ============================================
-- 5. Add comment explaining the restriction
-- ============================================

COMMENT ON FUNCTION is_current_user_student() IS 'Returns true if the current authenticated user is a student (user_type = ''student'')';
COMMENT ON FUNCTION get_campus_posts_for_user(UUID, campus_post_category, TEXT, BOOLEAN, INTEGER, INTEGER) IS 'Gets campus posts with automatic housing filtering for non-students';

-- ============================================
-- End of migration
-- ============================================
