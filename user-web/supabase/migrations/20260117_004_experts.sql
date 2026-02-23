-- ============================================================================
-- Migration: 004_experts
-- Description: Create experts table for 1:1 consultation feature
-- Author: AssignX Team
-- Date: 2026-01-17
-- ============================================================================

-- ============================================================================
-- EXPERT CATEGORIES ENUM
-- ============================================================================

DO $$ BEGIN
  CREATE TYPE expert_category AS ENUM (
    'academic',           -- Academic tutoring, subject help
    'career',             -- Career counseling, resume review
    'research',           -- Research guidance, thesis help
    'technology',         -- Tech mentorship, coding help
    'entrepreneurship',   -- Startup advice, business mentorship
    'finance',            -- Financial planning, investment advice
    'mental_health',      -- Counseling, stress management
    'fitness',            -- Health and fitness coaching
    'language',           -- Language learning, communication
    'arts',               -- Creative arts, design mentorship
    'law',                -- Legal advice, guidance
    'other'               -- Other specializations
  );
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

-- ============================================================================
-- EXPERT VERIFICATION STATUS ENUM
-- ============================================================================

DO $$ BEGIN
  CREATE TYPE expert_verification_status AS ENUM (
    'pending',
    'under_review',
    'verified',
    'rejected',
    'suspended'
  );
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

-- ============================================================================
-- EXPERTS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS experts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,

  -- Professional info
  headline VARCHAR(255) NOT NULL, -- Short tagline/title
  designation VARCHAR(255) NOT NULL, -- Current position
  organization VARCHAR(255), -- Current company/university
  bio TEXT, -- Detailed description

  -- Categories and skills
  category expert_category NOT NULL,
  specializations TEXT[] NOT NULL DEFAULT '{}', -- Array of specific skills
  languages TEXT[] DEFAULT ARRAY['English'], -- Languages spoken

  -- Pricing
  hourly_rate DECIMAL(10, 2) NOT NULL,
  currency VARCHAR(3) DEFAULT 'INR',
  session_duration INTEGER DEFAULT 30, -- Default session length in minutes
  min_session_duration INTEGER DEFAULT 15,
  max_session_duration INTEGER DEFAULT 120,

  -- Contact methods
  google_meet_link VARCHAR(500),
  zoom_link VARCHAR(500),
  whatsapp_number VARCHAR(20),
  calendly_link VARCHAR(500),
  custom_booking_link VARCHAR(500),
  preferred_platform VARCHAR(50) DEFAULT 'google_meet', -- Preferred meeting platform

  -- Availability
  availability JSONB DEFAULT '{
    "timezone": "Asia/Kolkata",
    "slots": {
      "monday": [],
      "tuesday": [],
      "wednesday": [],
      "thursday": [],
      "friday": [],
      "saturday": [],
      "sunday": []
    }
  }',
  is_instant_booking BOOLEAN DEFAULT FALSE, -- Allows instant bookings
  advance_booking_days INTEGER DEFAULT 7, -- How far in advance can book
  buffer_time_minutes INTEGER DEFAULT 15, -- Buffer between sessions

  -- Verification
  verification_status expert_verification_status DEFAULT 'pending',
  verified_at TIMESTAMPTZ,
  verified_by UUID REFERENCES admins(id),
  verification_notes TEXT,
  identity_verified BOOLEAN DEFAULT FALSE,
  credentials_verified BOOLEAN DEFAULT FALSE,

  -- Documents
  resume_url TEXT,
  linkedin_url VARCHAR(500),
  portfolio_url VARCHAR(500),
  certificate_urls TEXT[] DEFAULT '{}',

  -- Stats (denormalized for performance)
  rating DECIMAL(3, 2) DEFAULT 0 CHECK (rating >= 0 AND rating <= 5),
  total_reviews INTEGER DEFAULT 0,
  total_sessions INTEGER DEFAULT 0,
  total_earnings DECIMAL(12, 2) DEFAULT 0,
  completed_sessions INTEGER DEFAULT 0,
  cancelled_sessions INTEGER DEFAULT 0,
  response_time_hours DECIMAL(5, 2), -- Average response time

  -- Status
  is_active BOOLEAN DEFAULT TRUE,
  is_featured BOOLEAN DEFAULT FALSE,
  is_accepting_bookings BOOLEAN DEFAULT TRUE,

  -- Metadata
  metadata JSONB DEFAULT '{}',

  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  -- Ensure one expert profile per user
  CONSTRAINT unique_expert_user UNIQUE (user_id)
);

-- ============================================================================
-- EXPERT EDUCATION TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS expert_education (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  expert_id UUID NOT NULL REFERENCES experts(id) ON DELETE CASCADE,

  institution VARCHAR(255) NOT NULL,
  degree VARCHAR(255) NOT NULL,
  field_of_study VARCHAR(255),
  start_year INTEGER,
  end_year INTEGER,
  is_current BOOLEAN DEFAULT FALSE,
  description TEXT,

  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- EXPERT EXPERIENCE TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS expert_experience (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  expert_id UUID NOT NULL REFERENCES experts(id) ON DELETE CASCADE,

  company VARCHAR(255) NOT NULL,
  title VARCHAR(255) NOT NULL,
  location VARCHAR(255),
  start_date DATE,
  end_date DATE,
  is_current BOOLEAN DEFAULT FALSE,
  description TEXT,

  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- EXPERT ACHIEVEMENTS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS expert_achievements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  expert_id UUID NOT NULL REFERENCES experts(id) ON DELETE CASCADE,

  title VARCHAR(255) NOT NULL,
  issuer VARCHAR(255),
  date_received DATE,
  description TEXT,
  proof_url TEXT,

  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- INDEXES
-- ============================================================================

-- Main lookup indexes
CREATE INDEX IF NOT EXISTS idx_experts_user_id ON experts(user_id);
CREATE INDEX IF NOT EXISTS idx_experts_category ON experts(category);
CREATE INDEX IF NOT EXISTS idx_experts_verification_status ON experts(verification_status);

-- Search/filter indexes
CREATE INDEX IF NOT EXISTS idx_experts_active_verified ON experts(is_active, verification_status)
  WHERE is_active = TRUE AND verification_status = 'verified';

CREATE INDEX IF NOT EXISTS idx_experts_rating ON experts(rating DESC)
  WHERE is_active = TRUE AND verification_status = 'verified';

CREATE INDEX IF NOT EXISTS idx_experts_hourly_rate ON experts(hourly_rate)
  WHERE is_active = TRUE AND verification_status = 'verified';

CREATE INDEX IF NOT EXISTS idx_experts_featured ON experts(is_featured, rating DESC)
  WHERE is_featured = TRUE AND is_active = TRUE;

-- Full text search on headline, bio, specializations
CREATE INDEX IF NOT EXISTS idx_experts_search ON experts
  USING gin(to_tsvector('english', coalesce(headline, '') || ' ' || coalesce(bio, '') || ' ' || array_to_string(specializations, ' ')));

-- Specializations array search
CREATE INDEX IF NOT EXISTS idx_experts_specializations ON experts USING gin(specializations);

-- Education indexes
CREATE INDEX IF NOT EXISTS idx_expert_education_expert_id ON expert_education(expert_id);

-- Experience indexes
CREATE INDEX IF NOT EXISTS idx_expert_experience_expert_id ON expert_experience(expert_id);

-- Achievements indexes
CREATE INDEX IF NOT EXISTS idx_expert_achievements_expert_id ON expert_achievements(expert_id);

-- ============================================================================
-- TRIGGER: Auto-update updated_at
-- ============================================================================

CREATE OR REPLACE FUNCTION update_experts_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_experts_updated_at ON experts;
CREATE TRIGGER trigger_experts_updated_at
  BEFORE UPDATE ON experts
  FOR EACH ROW
  EXECUTE FUNCTION update_experts_updated_at();

-- ============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================================

ALTER TABLE experts ENABLE ROW LEVEL SECURITY;

-- Policy: Everyone can view active, verified experts
CREATE POLICY experts_select_policy ON experts
  FOR SELECT
  USING (
    (is_active = TRUE AND verification_status = 'verified')
    OR user_id = auth.uid() -- Users can see their own profile
    OR EXISTS (SELECT 1 FROM admins WHERE admins.profile_id = auth.uid())
  );

-- Policy: Authenticated users can create their expert profile
CREATE POLICY experts_insert_policy ON experts
  FOR INSERT
  WITH CHECK (
    auth.uid() IS NOT NULL
    AND user_id = auth.uid()
  );

-- Policy: Experts can update their own profile, admins can update any
CREATE POLICY experts_update_policy ON experts
  FOR UPDATE
  USING (
    user_id = auth.uid()
    OR EXISTS (SELECT 1 FROM admins WHERE admins.profile_id = auth.uid())
  );

-- Policy: Only admins can delete expert profiles
CREATE POLICY experts_delete_policy ON experts
  FOR DELETE
  USING (EXISTS (SELECT 1 FROM admins WHERE admins.profile_id = auth.uid()));

-- Education RLS
ALTER TABLE expert_education ENABLE ROW LEVEL SECURITY;

CREATE POLICY expert_education_select_policy ON expert_education
  FOR SELECT USING (TRUE);

CREATE POLICY expert_education_insert_policy ON expert_education
  FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM experts WHERE experts.id = expert_id AND experts.user_id = auth.uid())
  );

CREATE POLICY expert_education_update_policy ON expert_education
  FOR UPDATE USING (
    EXISTS (SELECT 1 FROM experts WHERE experts.id = expert_id AND experts.user_id = auth.uid())
  );

CREATE POLICY expert_education_delete_policy ON expert_education
  FOR DELETE USING (
    EXISTS (SELECT 1 FROM experts WHERE experts.id = expert_id AND experts.user_id = auth.uid())
  );

-- Experience RLS
ALTER TABLE expert_experience ENABLE ROW LEVEL SECURITY;

CREATE POLICY expert_experience_select_policy ON expert_experience
  FOR SELECT USING (TRUE);

CREATE POLICY expert_experience_insert_policy ON expert_experience
  FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM experts WHERE experts.id = expert_id AND experts.user_id = auth.uid())
  );

CREATE POLICY expert_experience_update_policy ON expert_experience
  FOR UPDATE USING (
    EXISTS (SELECT 1 FROM experts WHERE experts.id = expert_id AND experts.user_id = auth.uid())
  );

CREATE POLICY expert_experience_delete_policy ON expert_experience
  FOR DELETE USING (
    EXISTS (SELECT 1 FROM experts WHERE experts.id = expert_id AND experts.user_id = auth.uid())
  );

-- Achievements RLS
ALTER TABLE expert_achievements ENABLE ROW LEVEL SECURITY;

CREATE POLICY expert_achievements_select_policy ON expert_achievements
  FOR SELECT USING (TRUE);

CREATE POLICY expert_achievements_insert_policy ON expert_achievements
  FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM experts WHERE experts.id = expert_id AND experts.user_id = auth.uid())
  );

CREATE POLICY expert_achievements_update_policy ON expert_achievements
  FOR UPDATE USING (
    EXISTS (SELECT 1 FROM experts WHERE experts.id = expert_id AND experts.user_id = auth.uid())
  );

CREATE POLICY expert_achievements_delete_policy ON expert_achievements
  FOR DELETE USING (
    EXISTS (SELECT 1 FROM experts WHERE experts.id = expert_id AND experts.user_id = auth.uid())
  );

-- ============================================================================
-- FUNCTIONS
-- ============================================================================

-- Function: Search experts
CREATE OR REPLACE FUNCTION search_experts(
  p_category expert_category DEFAULT NULL,
  p_search_query TEXT DEFAULT NULL,
  p_min_rate DECIMAL DEFAULT NULL,
  p_max_rate DECIMAL DEFAULT NULL,
  p_min_rating DECIMAL DEFAULT NULL,
  p_specializations TEXT[] DEFAULT NULL,
  p_sort_by VARCHAR DEFAULT 'rating', -- 'rating', 'price_low', 'price_high', 'sessions'
  p_limit INTEGER DEFAULT 20,
  p_offset INTEGER DEFAULT 0
)
RETURNS SETOF experts
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM experts
  WHERE
    is_active = TRUE
    AND verification_status = 'verified'
    AND is_accepting_bookings = TRUE
    AND (p_category IS NULL OR category = p_category)
    AND (p_min_rate IS NULL OR hourly_rate >= p_min_rate)
    AND (p_max_rate IS NULL OR hourly_rate <= p_max_rate)
    AND (p_min_rating IS NULL OR rating >= p_min_rating)
    AND (
      p_specializations IS NULL
      OR specializations && p_specializations -- Array overlap
    )
    AND (
      p_search_query IS NULL
      OR to_tsvector('english', coalesce(headline, '') || ' ' || coalesce(bio, '') || ' ' || array_to_string(specializations, ' '))
         @@ plainto_tsquery('english', p_search_query)
    )
  ORDER BY
    CASE WHEN p_sort_by = 'rating' THEN rating END DESC NULLS LAST,
    CASE WHEN p_sort_by = 'price_low' THEN hourly_rate END ASC,
    CASE WHEN p_sort_by = 'price_high' THEN hourly_rate END DESC,
    CASE WHEN p_sort_by = 'sessions' THEN total_sessions END DESC NULLS LAST,
    is_featured DESC,
    created_at DESC
  LIMIT p_limit
  OFFSET p_offset;
END;
$$;

-- Function: Get expert availability for a date
CREATE OR REPLACE FUNCTION get_expert_availability(
  p_expert_id UUID,
  p_date DATE
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_expert RECORD;
  v_day_name VARCHAR;
  v_slots JSONB;
  v_booked_slots JSONB;
BEGIN
  -- Get expert
  SELECT * INTO v_expert FROM experts WHERE id = p_expert_id;

  IF v_expert IS NULL THEN
    RAISE EXCEPTION 'Expert not found';
  END IF;

  -- Get day name (lowercase)
  v_day_name := lower(to_char(p_date, 'day'));
  v_day_name := trim(v_day_name);

  -- Get available slots for the day
  v_slots := v_expert.availability->'slots'->v_day_name;

  -- Get booked slots for the date
  SELECT jsonb_agg(jsonb_build_object(
    'start_time', scheduled_start::time,
    'end_time', scheduled_end::time
  ))
  INTO v_booked_slots
  FROM expert_bookings
  WHERE expert_id = p_expert_id
    AND scheduled_start::date = p_date
    AND status NOT IN ('cancelled', 'rejected');

  RETURN jsonb_build_object(
    'date', p_date,
    'day', v_day_name,
    'timezone', v_expert.availability->>'timezone',
    'available_slots', COALESCE(v_slots, '[]'::jsonb),
    'booked_slots', COALESCE(v_booked_slots, '[]'::jsonb),
    'session_duration', v_expert.session_duration,
    'buffer_time', v_expert.buffer_time_minutes
  );
END;
$$;

-- ============================================================================
-- COMMENTS
-- ============================================================================

COMMENT ON TABLE experts IS 'Expert profiles for 1:1 consultations';
COMMENT ON COLUMN experts.availability IS 'JSON object with timezone and weekly availability slots';
COMMENT ON COLUMN experts.specializations IS 'Array of specific skills/topics the expert can help with';
COMMENT ON COLUMN experts.is_instant_booking IS 'If true, bookings are automatically confirmed';
COMMENT ON COLUMN experts.buffer_time_minutes IS 'Buffer time between consecutive sessions';

COMMENT ON TABLE expert_education IS 'Educational background of experts';
COMMENT ON TABLE expert_experience IS 'Work experience of experts';
COMMENT ON TABLE expert_achievements IS 'Certifications and achievements of experts';

-- Grant permissions
GRANT SELECT ON experts TO authenticated;
GRANT SELECT ON experts TO anon;
GRANT INSERT, UPDATE ON experts TO authenticated;
GRANT SELECT ON expert_education TO authenticated;
GRANT SELECT ON expert_education TO anon;
GRANT INSERT, UPDATE, DELETE ON expert_education TO authenticated;
GRANT SELECT ON expert_experience TO authenticated;
GRANT SELECT ON expert_experience TO anon;
GRANT INSERT, UPDATE, DELETE ON expert_experience TO authenticated;
GRANT SELECT ON expert_achievements TO authenticated;
GRANT SELECT ON expert_achievements TO anon;
GRANT INSERT, UPDATE, DELETE ON expert_achievements TO authenticated;
GRANT EXECUTE ON FUNCTION search_experts TO authenticated;
GRANT EXECUTE ON FUNCTION search_experts TO anon;
GRANT EXECUTE ON FUNCTION get_expert_availability TO authenticated;
