-- ============================================================================
-- Migration: 002_campus_posts
-- Description: Create campus posts table for the Campus Pulse feature
-- Author: AssignX Team
-- Date: 2026-01-17
-- ============================================================================

-- ============================================================================
-- CAMPUS POST CATEGORIES ENUM
-- ============================================================================

DO $$ BEGIN
  CREATE TYPE campus_post_category AS ENUM (
    'events',           -- College events, fests, seminars
    'opportunities',    -- Internships, jobs, research positions
    'resources',        -- Study materials, notes, tutorials
    'lost_found',       -- Lost and found items
    'marketplace',      -- Buy/sell/rent items
    'housing',          -- PG, hostel, flat sharing
    'rides',            -- Carpooling, ride sharing
    'study_groups',     -- Study groups, project partners
    'clubs',            -- Club activities, registrations
    'announcements',    -- Official announcements
    'discussions',      -- General discussions
    'questions'         -- Academic questions, help
  );
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

-- ============================================================================
-- CAMPUS POSTS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS campus_posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Author info
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  college_id UUID REFERENCES colleges(id) ON DELETE SET NULL,

  -- Post content
  category campus_post_category NOT NULL,
  title VARCHAR(255) NOT NULL,
  content TEXT,
  images TEXT[] DEFAULT '{}', -- Array of image URLs

  -- Post metadata
  is_admin_post BOOLEAN DEFAULT FALSE,
  is_pinned BOOLEAN DEFAULT FALSE,
  is_anonymous BOOLEAN DEFAULT FALSE,

  -- Location (for lost_found, housing, etc.)
  location VARCHAR(255),
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8),

  -- For events
  event_date TIMESTAMPTZ,
  event_end_date TIMESTAMPTZ,
  event_venue VARCHAR(255),
  event_link VARCHAR(500), -- Registration or event link

  -- For opportunities
  deadline TIMESTAMPTZ,
  apply_link VARCHAR(500),
  company_name VARCHAR(255),

  -- For marketplace
  price DECIMAL(10, 2),
  is_negotiable BOOLEAN DEFAULT FALSE,
  condition VARCHAR(50), -- new, like_new, good, fair

  -- Engagement stats (denormalized for performance)
  likes_count INTEGER DEFAULT 0,
  comments_count INTEGER DEFAULT 0,
  saves_count INTEGER DEFAULT 0,
  views_count INTEGER DEFAULT 0,
  shares_count INTEGER DEFAULT 0,

  -- Moderation
  is_flagged BOOLEAN DEFAULT FALSE,
  flag_reason VARCHAR(255),
  flagged_at TIMESTAMPTZ,
  flagged_by UUID REFERENCES profiles(id),
  is_hidden BOOLEAN DEFAULT FALSE,
  hidden_reason VARCHAR(255),

  -- Status
  status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('draft', 'active', 'closed', 'archived', 'deleted')),
  expires_at TIMESTAMPTZ,

  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- INDEXES
-- ============================================================================

-- Primary query indexes
CREATE INDEX IF NOT EXISTS idx_campus_posts_college_id ON campus_posts(college_id) WHERE college_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_campus_posts_user_id ON campus_posts(user_id);
CREATE INDEX IF NOT EXISTS idx_campus_posts_category ON campus_posts(category);
CREATE INDEX IF NOT EXISTS idx_campus_posts_status ON campus_posts(status) WHERE status = 'active';

-- Composite index for feed queries
CREATE INDEX IF NOT EXISTS idx_campus_posts_feed ON campus_posts(college_id, category, status, created_at DESC)
  WHERE status = 'active' AND is_hidden = FALSE;

-- Index for pinned posts
CREATE INDEX IF NOT EXISTS idx_campus_posts_pinned ON campus_posts(college_id, is_pinned, created_at DESC)
  WHERE is_pinned = TRUE AND status = 'active';

-- Index for event date queries
CREATE INDEX IF NOT EXISTS idx_campus_posts_event_date ON campus_posts(event_date)
  WHERE category = 'events' AND status = 'active';

-- Index for deadline queries
CREATE INDEX IF NOT EXISTS idx_campus_posts_deadline ON campus_posts(deadline)
  WHERE deadline IS NOT NULL AND status = 'active';

-- Full text search on title and content
CREATE INDEX IF NOT EXISTS idx_campus_posts_search ON campus_posts
  USING gin(to_tsvector('english', coalesce(title, '') || ' ' || coalesce(content, '')));

-- ============================================================================
-- TRIGGER: Auto-update updated_at
-- ============================================================================

CREATE OR REPLACE FUNCTION update_campus_posts_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_campus_posts_updated_at ON campus_posts;
CREATE TRIGGER trigger_campus_posts_updated_at
  BEFORE UPDATE ON campus_posts
  FOR EACH ROW
  EXECUTE FUNCTION update_campus_posts_updated_at();

-- ============================================================================
-- TRIGGER: Auto-expire posts
-- ============================================================================

CREATE OR REPLACE FUNCTION auto_expire_campus_posts()
RETURNS TRIGGER AS $$
BEGIN
  -- Auto-close events after event_end_date
  IF NEW.category = 'events' AND NEW.event_end_date IS NOT NULL AND NEW.event_end_date < NOW() THEN
    NEW.status = 'closed';
  END IF;

  -- Auto-close opportunities after deadline
  IF NEW.category = 'opportunities' AND NEW.deadline IS NOT NULL AND NEW.deadline < NOW() THEN
    NEW.status = 'closed';
  END IF;

  -- Auto-expire posts after expires_at
  IF NEW.expires_at IS NOT NULL AND NEW.expires_at < NOW() THEN
    NEW.status = 'archived';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_campus_posts_auto_expire ON campus_posts;
CREATE TRIGGER trigger_campus_posts_auto_expire
  BEFORE UPDATE ON campus_posts
  FOR EACH ROW
  EXECUTE FUNCTION auto_expire_campus_posts();

-- ============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================================

ALTER TABLE campus_posts ENABLE ROW LEVEL SECURITY;

-- Policy: Everyone can read active, non-hidden posts
CREATE POLICY campus_posts_select_policy ON campus_posts
  FOR SELECT
  USING (
    status = 'active' AND is_hidden = FALSE
    OR user_id = auth.uid() -- Users can see their own posts
    OR EXISTS (SELECT 1 FROM admins WHERE admins.profile_id = auth.uid()) -- Admins see all
  );

-- Policy: Authenticated users can create posts
CREATE POLICY campus_posts_insert_policy ON campus_posts
  FOR INSERT
  WITH CHECK (
    auth.uid() IS NOT NULL
    AND user_id = auth.uid()
  );

-- Policy: Users can update their own posts, admins can update any
CREATE POLICY campus_posts_update_policy ON campus_posts
  FOR UPDATE
  USING (
    user_id = auth.uid()
    OR EXISTS (SELECT 1 FROM admins WHERE admins.profile_id = auth.uid())
  );

-- Policy: Users can delete their own posts, admins can delete any
CREATE POLICY campus_posts_delete_policy ON campus_posts
  FOR DELETE
  USING (
    user_id = auth.uid()
    OR EXISTS (SELECT 1 FROM admins WHERE admins.profile_id = auth.uid())
  );

-- ============================================================================
-- FUNCTIONS
-- ============================================================================

-- Function: Search campus posts
CREATE OR REPLACE FUNCTION search_campus_posts(
  p_college_id UUID DEFAULT NULL,
  p_category campus_post_category DEFAULT NULL,
  p_search_query TEXT DEFAULT NULL,
  p_limit INTEGER DEFAULT 20,
  p_offset INTEGER DEFAULT 0
)
RETURNS SETOF campus_posts
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM campus_posts
  WHERE
    status = 'active'
    AND is_hidden = FALSE
    AND (p_college_id IS NULL OR college_id = p_college_id)
    AND (p_category IS NULL OR category = p_category)
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

-- Function: Get trending posts
CREATE OR REPLACE FUNCTION get_trending_campus_posts(
  p_college_id UUID DEFAULT NULL,
  p_limit INTEGER DEFAULT 10
)
RETURNS SETOF campus_posts
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM campus_posts
  WHERE
    status = 'active'
    AND is_hidden = FALSE
    AND created_at > NOW() - INTERVAL '7 days'
    AND (p_college_id IS NULL OR college_id = p_college_id)
  ORDER BY
    (likes_count * 2 + comments_count * 3 + views_count * 0.1) DESC,
    created_at DESC
  LIMIT p_limit;
END;
$$;

-- ============================================================================
-- COMMENTS
-- ============================================================================

COMMENT ON TABLE campus_posts IS 'Campus Pulse posts for college communities';
COMMENT ON COLUMN campus_posts.category IS 'Post category like events, opportunities, lost_found, etc.';
COMMENT ON COLUMN campus_posts.is_anonymous IS 'If true, author name is hidden from other users';
COMMENT ON COLUMN campus_posts.is_pinned IS 'Pinned posts appear at top of the feed';
COMMENT ON COLUMN campus_posts.expires_at IS 'Optional expiration date for auto-archiving';

-- Grant permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON campus_posts TO authenticated;
GRANT EXECUTE ON FUNCTION search_campus_posts TO authenticated;
GRANT EXECUTE ON FUNCTION get_trending_campus_posts TO authenticated;
