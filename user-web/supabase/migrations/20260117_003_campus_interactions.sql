-- ============================================================================
-- Migration: 003_campus_interactions
-- Description: Create campus interaction tables (likes, comments, saves)
-- Author: AssignX Team
-- Date: 2026-01-17
-- ============================================================================

-- ============================================================================
-- CAMPUS POST LIKES TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS campus_post_likes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID NOT NULL REFERENCES campus_posts(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),

  -- Ensure one like per user per post
  CONSTRAINT unique_post_like UNIQUE (post_id, user_id)
);

-- ============================================================================
-- CAMPUS POST COMMENTS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS campus_post_comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID NOT NULL REFERENCES campus_posts(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  parent_id UUID REFERENCES campus_post_comments(id) ON DELETE CASCADE, -- For nested replies

  content TEXT NOT NULL,
  is_anonymous BOOLEAN DEFAULT FALSE,

  -- Engagement
  likes_count INTEGER DEFAULT 0,
  replies_count INTEGER DEFAULT 0,

  -- Moderation
  is_flagged BOOLEAN DEFAULT FALSE,
  flag_reason VARCHAR(255),
  is_hidden BOOLEAN DEFAULT FALSE,
  is_edited BOOLEAN DEFAULT FALSE,
  edited_at TIMESTAMPTZ,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- CAMPUS COMMENT LIKES TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS campus_comment_likes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  comment_id UUID NOT NULL REFERENCES campus_post_comments(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),

  -- Ensure one like per user per comment
  CONSTRAINT unique_comment_like UNIQUE (comment_id, user_id)
);

-- ============================================================================
-- CAMPUS SAVED POSTS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS campus_saved_posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID NOT NULL REFERENCES campus_posts(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  collection_name VARCHAR(100) DEFAULT 'default', -- Allow organizing saves
  notes TEXT, -- User's private notes about the post
  created_at TIMESTAMPTZ DEFAULT NOW(),

  -- Ensure one save per user per post per collection
  CONSTRAINT unique_saved_post UNIQUE (post_id, user_id, collection_name)
);

-- ============================================================================
-- CAMPUS POST VIEWS TABLE (for analytics)
-- ============================================================================

CREATE TABLE IF NOT EXISTS campus_post_views (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID NOT NULL REFERENCES campus_posts(id) ON DELETE CASCADE,
  user_id UUID REFERENCES profiles(id) ON DELETE SET NULL, -- Can be null for anonymous views
  viewed_at TIMESTAMPTZ DEFAULT NOW(),
  view_duration_seconds INTEGER, -- How long user viewed the post
  source VARCHAR(50), -- 'feed', 'search', 'direct', 'notification'

  -- Only track unique views per day per user
  CONSTRAINT unique_daily_view UNIQUE (post_id, user_id, (viewed_at::date))
);

-- ============================================================================
-- CAMPUS POST REPORTS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS campus_post_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID REFERENCES campus_posts(id) ON DELETE CASCADE,
  comment_id UUID REFERENCES campus_post_comments(id) ON DELETE CASCADE,
  reporter_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,

  reason VARCHAR(50) NOT NULL CHECK (reason IN (
    'spam', 'inappropriate', 'harassment', 'hate_speech',
    'misinformation', 'scam', 'off_topic', 'other'
  )),
  description TEXT,

  -- Resolution
  status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'reviewed', 'resolved', 'dismissed')),
  reviewed_by UUID REFERENCES admins(id),
  reviewed_at TIMESTAMPTZ,
  resolution_notes TEXT,
  action_taken VARCHAR(50), -- 'none', 'warning', 'post_hidden', 'user_warned', 'user_banned'

  created_at TIMESTAMPTZ DEFAULT NOW(),

  -- Either post_id or comment_id must be set
  CONSTRAINT report_target CHECK (post_id IS NOT NULL OR comment_id IS NOT NULL)
);

-- ============================================================================
-- INDEXES
-- ============================================================================

-- Post likes indexes
CREATE INDEX IF NOT EXISTS idx_campus_post_likes_post_id ON campus_post_likes(post_id);
CREATE INDEX IF NOT EXISTS idx_campus_post_likes_user_id ON campus_post_likes(user_id);

-- Post comments indexes
CREATE INDEX IF NOT EXISTS idx_campus_post_comments_post_id ON campus_post_comments(post_id);
CREATE INDEX IF NOT EXISTS idx_campus_post_comments_user_id ON campus_post_comments(user_id);
CREATE INDEX IF NOT EXISTS idx_campus_post_comments_parent_id ON campus_post_comments(parent_id) WHERE parent_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_campus_post_comments_created_at ON campus_post_comments(post_id, created_at DESC);

-- Comment likes indexes
CREATE INDEX IF NOT EXISTS idx_campus_comment_likes_comment_id ON campus_comment_likes(comment_id);
CREATE INDEX IF NOT EXISTS idx_campus_comment_likes_user_id ON campus_comment_likes(user_id);

-- Saved posts indexes
CREATE INDEX IF NOT EXISTS idx_campus_saved_posts_user_id ON campus_saved_posts(user_id);
CREATE INDEX IF NOT EXISTS idx_campus_saved_posts_post_id ON campus_saved_posts(post_id);

-- Views indexes
CREATE INDEX IF NOT EXISTS idx_campus_post_views_post_id ON campus_post_views(post_id);
CREATE INDEX IF NOT EXISTS idx_campus_post_views_date ON campus_post_views(viewed_at);

-- Reports indexes
CREATE INDEX IF NOT EXISTS idx_campus_post_reports_status ON campus_post_reports(status) WHERE status = 'pending';
CREATE INDEX IF NOT EXISTS idx_campus_post_reports_post_id ON campus_post_reports(post_id) WHERE post_id IS NOT NULL;

-- ============================================================================
-- TRIGGERS: Update counts on likes/comments
-- ============================================================================

-- Trigger: Update likes_count on campus_posts
CREATE OR REPLACE FUNCTION update_campus_post_likes_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE campus_posts SET likes_count = likes_count + 1 WHERE id = NEW.post_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE campus_posts SET likes_count = GREATEST(0, likes_count - 1) WHERE id = OLD.post_id;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_campus_post_likes_count ON campus_post_likes;
CREATE TRIGGER trigger_update_campus_post_likes_count
  AFTER INSERT OR DELETE ON campus_post_likes
  FOR EACH ROW
  EXECUTE FUNCTION update_campus_post_likes_count();

-- Trigger: Update comments_count on campus_posts
CREATE OR REPLACE FUNCTION update_campus_post_comments_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE campus_posts SET comments_count = comments_count + 1 WHERE id = NEW.post_id;
    -- Update parent comment replies count
    IF NEW.parent_id IS NOT NULL THEN
      UPDATE campus_post_comments SET replies_count = replies_count + 1 WHERE id = NEW.parent_id;
    END IF;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE campus_posts SET comments_count = GREATEST(0, comments_count - 1) WHERE id = OLD.post_id;
    IF OLD.parent_id IS NOT NULL THEN
      UPDATE campus_post_comments SET replies_count = GREATEST(0, replies_count - 1) WHERE id = OLD.parent_id;
    END IF;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_campus_post_comments_count ON campus_post_comments;
CREATE TRIGGER trigger_update_campus_post_comments_count
  AFTER INSERT OR DELETE ON campus_post_comments
  FOR EACH ROW
  EXECUTE FUNCTION update_campus_post_comments_count();

-- Trigger: Update saves_count on campus_posts
CREATE OR REPLACE FUNCTION update_campus_post_saves_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE campus_posts SET saves_count = saves_count + 1 WHERE id = NEW.post_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE campus_posts SET saves_count = GREATEST(0, saves_count - 1) WHERE id = OLD.post_id;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_campus_post_saves_count ON campus_saved_posts;
CREATE TRIGGER trigger_update_campus_post_saves_count
  AFTER INSERT OR DELETE ON campus_saved_posts
  FOR EACH ROW
  EXECUTE FUNCTION update_campus_post_saves_count();

-- Trigger: Update views_count on campus_posts
CREATE OR REPLACE FUNCTION update_campus_post_views_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE campus_posts SET views_count = views_count + 1 WHERE id = NEW.post_id;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_campus_post_views_count ON campus_post_views;
CREATE TRIGGER trigger_update_campus_post_views_count
  AFTER INSERT ON campus_post_views
  FOR EACH ROW
  EXECUTE FUNCTION update_campus_post_views_count();

-- Trigger: Update comment likes_count
CREATE OR REPLACE FUNCTION update_campus_comment_likes_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE campus_post_comments SET likes_count = likes_count + 1 WHERE id = NEW.comment_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE campus_post_comments SET likes_count = GREATEST(0, likes_count - 1) WHERE id = OLD.comment_id;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_campus_comment_likes_count ON campus_comment_likes;
CREATE TRIGGER trigger_update_campus_comment_likes_count
  AFTER INSERT OR DELETE ON campus_comment_likes
  FOR EACH ROW
  EXECUTE FUNCTION update_campus_comment_likes_count();

-- Trigger: Update comments updated_at
CREATE OR REPLACE FUNCTION update_campus_comments_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  IF OLD.content != NEW.content THEN
    NEW.is_edited = TRUE;
    NEW.edited_at = NOW();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_campus_comments_updated_at ON campus_post_comments;
CREATE TRIGGER trigger_campus_comments_updated_at
  BEFORE UPDATE ON campus_post_comments
  FOR EACH ROW
  EXECUTE FUNCTION update_campus_comments_updated_at();

-- ============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================================

-- Post Likes RLS
ALTER TABLE campus_post_likes ENABLE ROW LEVEL SECURITY;

CREATE POLICY campus_post_likes_select_policy ON campus_post_likes
  FOR SELECT USING (TRUE);

CREATE POLICY campus_post_likes_insert_policy ON campus_post_likes
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY campus_post_likes_delete_policy ON campus_post_likes
  FOR DELETE USING (auth.uid() = user_id);

-- Comments RLS
ALTER TABLE campus_post_comments ENABLE ROW LEVEL SECURITY;

CREATE POLICY campus_post_comments_select_policy ON campus_post_comments
  FOR SELECT USING (is_hidden = FALSE OR user_id = auth.uid());

CREATE POLICY campus_post_comments_insert_policy ON campus_post_comments
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY campus_post_comments_update_policy ON campus_post_comments
  FOR UPDATE USING (auth.uid() = user_id OR EXISTS (SELECT 1 FROM admins WHERE admins.profile_id = auth.uid()));

CREATE POLICY campus_post_comments_delete_policy ON campus_post_comments
  FOR DELETE USING (auth.uid() = user_id OR EXISTS (SELECT 1 FROM admins WHERE admins.profile_id = auth.uid()));

-- Comment Likes RLS
ALTER TABLE campus_comment_likes ENABLE ROW LEVEL SECURITY;

CREATE POLICY campus_comment_likes_select_policy ON campus_comment_likes
  FOR SELECT USING (TRUE);

CREATE POLICY campus_comment_likes_insert_policy ON campus_comment_likes
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY campus_comment_likes_delete_policy ON campus_comment_likes
  FOR DELETE USING (auth.uid() = user_id);

-- Saved Posts RLS
ALTER TABLE campus_saved_posts ENABLE ROW LEVEL SECURITY;

CREATE POLICY campus_saved_posts_select_policy ON campus_saved_posts
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY campus_saved_posts_insert_policy ON campus_saved_posts
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY campus_saved_posts_delete_policy ON campus_saved_posts
  FOR DELETE USING (auth.uid() = user_id);

-- Views RLS (insert only for tracking)
ALTER TABLE campus_post_views ENABLE ROW LEVEL SECURITY;

CREATE POLICY campus_post_views_insert_policy ON campus_post_views
  FOR INSERT WITH CHECK (TRUE);

CREATE POLICY campus_post_views_select_policy ON campus_post_views
  FOR SELECT USING (EXISTS (SELECT 1 FROM admins WHERE admins.profile_id = auth.uid()));

-- Reports RLS
ALTER TABLE campus_post_reports ENABLE ROW LEVEL SECURITY;

CREATE POLICY campus_post_reports_insert_policy ON campus_post_reports
  FOR INSERT WITH CHECK (auth.uid() = reporter_id);

CREATE POLICY campus_post_reports_select_policy ON campus_post_reports
  FOR SELECT USING (
    auth.uid() = reporter_id
    OR EXISTS (SELECT 1 FROM admins WHERE admins.profile_id = auth.uid())
  );

CREATE POLICY campus_post_reports_update_policy ON campus_post_reports
  FOR UPDATE USING (EXISTS (SELECT 1 FROM admins WHERE admins.profile_id = auth.uid()));

-- ============================================================================
-- FUNCTIONS
-- ============================================================================

-- Function: Toggle post like
CREATE OR REPLACE FUNCTION toggle_campus_post_like(p_post_id UUID)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_id UUID;
  v_liked BOOLEAN;
BEGIN
  v_user_id := auth.uid();

  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  -- Check if already liked
  IF EXISTS (SELECT 1 FROM campus_post_likes WHERE post_id = p_post_id AND user_id = v_user_id) THEN
    -- Unlike
    DELETE FROM campus_post_likes WHERE post_id = p_post_id AND user_id = v_user_id;
    v_liked := FALSE;
  ELSE
    -- Like
    INSERT INTO campus_post_likes (post_id, user_id) VALUES (p_post_id, v_user_id);
    v_liked := TRUE;
  END IF;

  RETURN json_build_object(
    'success', TRUE,
    'liked', v_liked,
    'likes_count', (SELECT likes_count FROM campus_posts WHERE id = p_post_id)
  );
END;
$$;

-- Function: Toggle comment like
CREATE OR REPLACE FUNCTION toggle_campus_comment_like(p_comment_id UUID)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_id UUID;
  v_liked BOOLEAN;
BEGIN
  v_user_id := auth.uid();

  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  IF EXISTS (SELECT 1 FROM campus_comment_likes WHERE comment_id = p_comment_id AND user_id = v_user_id) THEN
    DELETE FROM campus_comment_likes WHERE comment_id = p_comment_id AND user_id = v_user_id;
    v_liked := FALSE;
  ELSE
    INSERT INTO campus_comment_likes (comment_id, user_id) VALUES (p_comment_id, v_user_id);
    v_liked := TRUE;
  END IF;

  RETURN json_build_object(
    'success', TRUE,
    'liked', v_liked,
    'likes_count', (SELECT likes_count FROM campus_post_comments WHERE id = p_comment_id)
  );
END;
$$;

-- Function: Toggle save post
CREATE OR REPLACE FUNCTION toggle_campus_post_save(p_post_id UUID, p_collection VARCHAR DEFAULT 'default')
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_id UUID;
  v_saved BOOLEAN;
BEGIN
  v_user_id := auth.uid();

  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  IF EXISTS (SELECT 1 FROM campus_saved_posts WHERE post_id = p_post_id AND user_id = v_user_id AND collection_name = p_collection) THEN
    DELETE FROM campus_saved_posts WHERE post_id = p_post_id AND user_id = v_user_id AND collection_name = p_collection;
    v_saved := FALSE;
  ELSE
    INSERT INTO campus_saved_posts (post_id, user_id, collection_name) VALUES (p_post_id, v_user_id, p_collection);
    v_saved := TRUE;
  END IF;

  RETURN json_build_object(
    'success', TRUE,
    'saved', v_saved
  );
END;
$$;

-- Function: Record post view
CREATE OR REPLACE FUNCTION record_campus_post_view(p_post_id UUID, p_source VARCHAR DEFAULT 'feed')
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_id UUID;
BEGIN
  v_user_id := auth.uid();

  -- Insert view (constraint will prevent duplicates for same user same day)
  INSERT INTO campus_post_views (post_id, user_id, source)
  VALUES (p_post_id, v_user_id, p_source)
  ON CONFLICT ON CONSTRAINT unique_daily_view DO NOTHING;
END;
$$;

-- ============================================================================
-- COMMENTS
-- ============================================================================

COMMENT ON TABLE campus_post_likes IS 'Tracks likes on campus posts';
COMMENT ON TABLE campus_post_comments IS 'Comments on campus posts with threading support';
COMMENT ON TABLE campus_comment_likes IS 'Tracks likes on comments';
COMMENT ON TABLE campus_saved_posts IS 'User saved/bookmarked posts';
COMMENT ON TABLE campus_post_views IS 'Analytics for post views';
COMMENT ON TABLE campus_post_reports IS 'User reports for moderation';

-- Grant permissions
GRANT SELECT, INSERT, DELETE ON campus_post_likes TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON campus_post_comments TO authenticated;
GRANT SELECT, INSERT, DELETE ON campus_comment_likes TO authenticated;
GRANT SELECT, INSERT, DELETE ON campus_saved_posts TO authenticated;
GRANT INSERT ON campus_post_views TO authenticated;
GRANT SELECT, INSERT ON campus_post_reports TO authenticated;
GRANT EXECUTE ON FUNCTION toggle_campus_post_like TO authenticated;
GRANT EXECUTE ON FUNCTION toggle_campus_comment_like TO authenticated;
GRANT EXECUTE ON FUNCTION toggle_campus_post_save TO authenticated;
GRANT EXECUTE ON FUNCTION record_campus_post_view TO authenticated;
