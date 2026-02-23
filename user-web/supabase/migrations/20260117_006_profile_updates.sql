-- ============================================================================
-- Migration: 006_profile_updates
-- Description: Add new columns to profiles table for college verification and tour
-- Author: AssignX Team
-- Date: 2026-01-17
-- ============================================================================

-- ============================================================================
-- ADD NEW COLUMNS TO PROFILES TABLE
-- ============================================================================

-- College verification columns
ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS college_email VARCHAR(255),
ADD COLUMN IF NOT EXISTS is_college_verified BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS college_id UUID REFERENCES colleges(id) ON DELETE SET NULL,
ADD COLUMN IF NOT EXISTS college_verified_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS college_verification_token VARCHAR(100),
ADD COLUMN IF NOT EXISTS college_verification_expires_at TIMESTAMPTZ;

-- App tour/onboarding columns
ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS has_completed_tour BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS tour_completed_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS tour_steps_completed JSONB DEFAULT '[]';

-- Additional profile columns
ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS bio TEXT,
ADD COLUMN IF NOT EXISTS headline VARCHAR(255),
ADD COLUMN IF NOT EXISTS skills TEXT[] DEFAULT '{}',
ADD COLUMN IF NOT EXISTS interests TEXT[] DEFAULT '{}',
ADD COLUMN IF NOT EXISTS social_links JSONB DEFAULT '{}',
ADD COLUMN IF NOT EXISTS notification_preferences JSONB DEFAULT '{
  "email_notifications": true,
  "push_notifications": true,
  "whatsapp_notifications": false,
  "campus_updates": true,
  "expert_reminders": true,
  "marketing_emails": false
}';

-- Profile visibility and privacy
ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS is_profile_public BOOLEAN DEFAULT TRUE,
ADD COLUMN IF NOT EXISTS show_college BOOLEAN DEFAULT TRUE,
ADD COLUMN IF NOT EXISTS show_projects BOOLEAN DEFAULT TRUE,
ADD COLUMN IF NOT EXISTS allow_messages BOOLEAN DEFAULT TRUE;

-- ============================================================================
-- UPDATE USER_TYPE CONSTRAINT
-- ============================================================================

-- First, drop the existing constraint if it exists
ALTER TABLE profiles DROP CONSTRAINT IF EXISTS profiles_user_type_check;

-- Add updated constraint with more user types
ALTER TABLE profiles
ADD CONSTRAINT profiles_user_type_check
CHECK (user_type IN ('student', 'professional', 'expert', 'college_admin', 'admin'));

-- ============================================================================
-- COLLEGE VERIFICATION FUNCTIONS
-- ============================================================================

-- Function: Initiate college email verification
CREATE OR REPLACE FUNCTION initiate_college_verification(
  p_college_email VARCHAR
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_id UUID;
  v_college_domain VARCHAR;
  v_college RECORD;
  v_token VARCHAR(100);
BEGIN
  v_user_id := auth.uid();

  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  -- Extract domain from email
  v_college_domain := split_part(p_college_email, '@', 2);

  -- Find college by domain
  SELECT * INTO v_college
  FROM colleges
  WHERE domain = v_college_domain
    AND is_active = TRUE
    AND is_verified = TRUE;

  IF v_college IS NULL THEN
    RAISE EXCEPTION 'College not found for domain: %', v_college_domain;
  END IF;

  -- Generate verification token
  v_token := encode(gen_random_bytes(32), 'hex');

  -- Update profile with pending verification
  UPDATE profiles
  SET college_email = p_college_email,
      college_id = v_college.id,
      college_verification_token = v_token,
      college_verification_expires_at = NOW() + INTERVAL '24 hours',
      is_college_verified = FALSE
  WHERE id = v_user_id;

  -- Log activity
  INSERT INTO activity_logs (
    profile_id,
    action,
    action_category,
    description,
    metadata
  ) VALUES (
    v_user_id,
    'college_verification_initiated',
    'verification',
    'College verification initiated for ' || v_college.name,
    jsonb_build_object(
      'college_id', v_college.id,
      'college_name', v_college.name,
      'college_email', p_college_email
    )
  );

  RETURN json_build_object(
    'success', TRUE,
    'college_id', v_college.id,
    'college_name', v_college.name,
    'verification_token', v_token,
    'expires_at', NOW() + INTERVAL '24 hours'
  );
END;
$$;

-- Function: Verify college email
CREATE OR REPLACE FUNCTION verify_college_email(
  p_token VARCHAR
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_profile RECORD;
  v_college RECORD;
BEGIN
  -- Find profile with this token
  SELECT * INTO v_profile
  FROM profiles
  WHERE college_verification_token = p_token
    AND college_verification_expires_at > NOW();

  IF v_profile IS NULL THEN
    RAISE EXCEPTION 'Invalid or expired verification token';
  END IF;

  -- Get college
  SELECT * INTO v_college FROM colleges WHERE id = v_profile.college_id;

  -- Mark as verified
  UPDATE profiles
  SET is_college_verified = TRUE,
      college_verified_at = NOW(),
      college_verification_token = NULL,
      college_verification_expires_at = NULL
  WHERE id = v_profile.id;

  -- Update college student count
  UPDATE colleges
  SET total_students = total_students + 1
  WHERE id = v_profile.college_id;

  -- Log activity
  INSERT INTO activity_logs (
    profile_id,
    action,
    action_category,
    description,
    metadata
  ) VALUES (
    v_profile.id,
    'college_verified',
    'verification',
    'College email verified for ' || v_college.name,
    jsonb_build_object(
      'college_id', v_college.id,
      'college_name', v_college.name
    )
  );

  RETURN json_build_object(
    'success', TRUE,
    'college_id', v_college.id,
    'college_name', v_college.name
  );
END;
$$;

-- Function: Mark tour as completed
CREATE OR REPLACE FUNCTION complete_app_tour(
  p_tour_steps JSONB DEFAULT '[]'
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_id UUID;
BEGIN
  v_user_id := auth.uid();

  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  UPDATE profiles
  SET has_completed_tour = TRUE,
      tour_completed_at = NOW(),
      tour_steps_completed = p_tour_steps
  WHERE id = v_user_id;

  RETURN json_build_object(
    'success', TRUE,
    'completed_at', NOW()
  );
END;
$$;

-- Function: Update notification preferences
CREATE OR REPLACE FUNCTION update_notification_preferences(
  p_preferences JSONB
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_id UUID;
BEGIN
  v_user_id := auth.uid();

  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  UPDATE profiles
  SET notification_preferences = notification_preferences || p_preferences
  WHERE id = v_user_id;

  RETURN json_build_object(
    'success', TRUE,
    'preferences', (SELECT notification_preferences FROM profiles WHERE id = v_user_id)
  );
END;
$$;

-- ============================================================================
-- INDEXES
-- ============================================================================

-- College verification indexes
CREATE INDEX IF NOT EXISTS idx_profiles_college_id ON profiles(college_id) WHERE college_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_profiles_college_verified ON profiles(is_college_verified) WHERE is_college_verified = TRUE;
CREATE INDEX IF NOT EXISTS idx_profiles_college_email ON profiles(college_email) WHERE college_email IS NOT NULL;

-- Tour completion index
CREATE INDEX IF NOT EXISTS idx_profiles_tour_completed ON profiles(has_completed_tour);

-- Skills search index
CREATE INDEX IF NOT EXISTS idx_profiles_skills ON profiles USING gin(skills) WHERE skills IS NOT NULL;

-- Interests search index
CREATE INDEX IF NOT EXISTS idx_profiles_interests ON profiles USING gin(interests) WHERE interests IS NOT NULL;

-- ============================================================================
-- VIEWS
-- ============================================================================

-- View: Public profile information
CREATE OR REPLACE VIEW public_profiles AS
SELECT
  p.id,
  p.full_name,
  p.avatar_url,
  p.bio,
  p.headline,
  p.skills,
  p.interests,
  p.is_college_verified,
  CASE WHEN p.show_college THEN c.name ELSE NULL END as college_name,
  CASE WHEN p.show_college THEN c.short_name ELSE NULL END as college_short_name,
  p.created_at
FROM profiles p
LEFT JOIN colleges c ON c.id = p.college_id
WHERE p.is_profile_public = TRUE
  AND p.is_active = TRUE
  AND p.deleted_at IS NULL;

-- View: College leaderboard
CREATE OR REPLACE VIEW college_leaderboard AS
SELECT
  c.id,
  c.name,
  c.short_name,
  c.logo_url,
  c.city,
  c.state,
  c.total_students,
  COUNT(DISTINCT cp.id) as total_posts,
  COUNT(DISTINCT e.id) as total_experts
FROM colleges c
LEFT JOIN profiles p ON p.college_id = c.id AND p.is_college_verified = TRUE
LEFT JOIN campus_posts cp ON cp.college_id = c.id AND cp.status = 'active'
LEFT JOIN experts e ON e.user_id = p.id AND e.verification_status = 'verified'
WHERE c.is_active = TRUE AND c.is_verified = TRUE
GROUP BY c.id
ORDER BY c.total_students DESC;

-- ============================================================================
-- RLS UPDATES
-- ============================================================================

-- Allow users to see limited profile info
CREATE POLICY profiles_public_select_policy ON profiles
  FOR SELECT
  USING (
    is_profile_public = TRUE
    OR id = auth.uid()
    OR EXISTS (SELECT 1 FROM admins WHERE admins.profile_id = auth.uid())
  );

-- Grant access to views
GRANT SELECT ON public_profiles TO authenticated;
GRANT SELECT ON public_profiles TO anon;
GRANT SELECT ON college_leaderboard TO authenticated;
GRANT SELECT ON college_leaderboard TO anon;

-- ============================================================================
-- COMMENTS
-- ============================================================================

COMMENT ON COLUMN profiles.college_email IS 'College email used for verification';
COMMENT ON COLUMN profiles.is_college_verified IS 'Whether college email has been verified';
COMMENT ON COLUMN profiles.college_id IS 'Reference to verified college';
COMMENT ON COLUMN profiles.has_completed_tour IS 'Whether user has completed the app tour';
COMMENT ON COLUMN profiles.notification_preferences IS 'JSON object with notification settings';
COMMENT ON COLUMN profiles.social_links IS 'JSON object with social media links';

COMMENT ON VIEW public_profiles IS 'Public profile information for discovery';
COMMENT ON VIEW college_leaderboard IS 'College rankings by student count and activity';

-- Grant function permissions
GRANT EXECUTE ON FUNCTION initiate_college_verification TO authenticated;
GRANT EXECUTE ON FUNCTION verify_college_email TO authenticated;
GRANT EXECUTE ON FUNCTION complete_app_tour TO authenticated;
GRANT EXECUTE ON FUNCTION update_notification_preferences TO authenticated;
