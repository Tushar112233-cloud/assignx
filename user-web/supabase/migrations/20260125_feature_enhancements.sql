-- ============================================
-- AssignX Feature Enhancements Migration
-- Date: 2026-01-25
-- Description: Adds chat presence, message approval, listing reports,
--              saved listings, moderation logs, and profile enhancements
-- ============================================

-- ============================================
-- 1. Chat Presence Tracking
-- ============================================

CREATE TABLE IF NOT EXISTS chat_presence (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  chat_room_id UUID REFERENCES chat_rooms(id) ON DELETE CASCADE,
  is_online BOOLEAN DEFAULT false,
  is_typing BOOLEAN DEFAULT false,
  last_seen TIMESTAMPTZ DEFAULT now(),
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id, chat_room_id)
);

-- Enable RLS
ALTER TABLE chat_presence ENABLE ROW LEVEL SECURITY;

-- Policies for chat_presence
DROP POLICY IF EXISTS "Users can view presence in their chat rooms" ON chat_presence;
CREATE POLICY "Users can view presence in their chat rooms" ON chat_presence
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM chat_participants
      WHERE chat_participants.chat_room_id = chat_presence.chat_room_id
      AND chat_participants.profile_id = auth.uid()
      AND chat_participants.is_active = true
    )
  );

DROP POLICY IF EXISTS "Users can update their own presence" ON chat_presence;
CREATE POLICY "Users can update their own presence" ON chat_presence
  FOR ALL USING (user_id = auth.uid());

-- Grant permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON chat_presence TO authenticated;

-- ============================================
-- 2. Message Approval Fields
-- ============================================

-- Add approval-related columns to chat_messages
ALTER TABLE chat_messages ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'approved';
ALTER TABLE chat_messages ADD COLUMN IF NOT EXISTS approved_by UUID REFERENCES auth.users(id);
ALTER TABLE chat_messages ADD COLUMN IF NOT EXISTS approved_at TIMESTAMPTZ;
ALTER TABLE chat_messages ADD COLUMN IF NOT EXISTS rejection_reason TEXT;

-- Create enum for message status (using DO block to handle if exists)
DO $$ BEGIN
  CREATE TYPE message_approval_status AS ENUM ('pending', 'approved', 'rejected');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

-- ============================================
-- 3. Listing Reports Table
-- ============================================

CREATE TABLE IF NOT EXISTS listing_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  listing_id UUID REFERENCES marketplace_listings(id) ON DELETE CASCADE,
  reporter_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  reason TEXT NOT NULL CHECK (reason IN ('scam', 'inappropriate', 'inaccurate', 'spam', 'other')),
  details TEXT,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'reviewed', 'resolved', 'dismissed')),
  reviewed_by UUID REFERENCES auth.users(id),
  reviewed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Enable RLS
ALTER TABLE listing_reports ENABLE ROW LEVEL SECURITY;

-- Policies for listing_reports
DROP POLICY IF EXISTS "Users can create reports" ON listing_reports;
CREATE POLICY "Users can create reports" ON listing_reports
  FOR INSERT WITH CHECK (reporter_id = auth.uid());

DROP POLICY IF EXISTS "Users can view their own reports" ON listing_reports;
CREATE POLICY "Users can view their own reports" ON listing_reports
  FOR SELECT USING (reporter_id = auth.uid());

DROP POLICY IF EXISTS "Admins can view all reports" ON listing_reports;
CREATE POLICY "Admins can view all reports" ON listing_reports
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.user_type = 'admin'
    )
  );

DROP POLICY IF EXISTS "Admins can update reports" ON listing_reports;
CREATE POLICY "Admins can update reports" ON listing_reports
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.user_type = 'admin'
    )
  );

-- Grant permissions
GRANT SELECT, INSERT ON listing_reports TO authenticated;
GRANT UPDATE ON listing_reports TO authenticated;

-- ============================================
-- 4. Saved Listings Table
-- ============================================

CREATE TABLE IF NOT EXISTS saved_listings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  listing_id UUID REFERENCES marketplace_listings(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id, listing_id)
);

-- Enable RLS
ALTER TABLE saved_listings ENABLE ROW LEVEL SECURITY;

-- Policies for saved_listings
DROP POLICY IF EXISTS "Users can manage their saved listings" ON saved_listings;
CREATE POLICY "Users can manage their saved listings" ON saved_listings
  FOR ALL USING (user_id = auth.uid());

-- Grant permissions
GRANT SELECT, INSERT, DELETE ON saved_listings TO authenticated;

-- ============================================
-- 5. Moderation Logs Table
-- ============================================

CREATE TABLE IF NOT EXISTS moderation_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  content_type TEXT NOT NULL CHECK (content_type IN ('message', 'listing', 'post', 'comment')),
  content_id UUID,
  violation_type TEXT NOT NULL CHECK (violation_type IN ('phone', 'email', 'social_media', 'inappropriate', 'spam')),
  original_content TEXT,
  action_taken TEXT NOT NULL CHECK (action_taken IN ('blocked', 'warned', 'flagged')),
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Enable RLS
ALTER TABLE moderation_logs ENABLE ROW LEVEL SECURITY;

-- Only admins can view moderation logs
DROP POLICY IF EXISTS "Admins can view moderation logs" ON moderation_logs;
CREATE POLICY "Admins can view moderation logs" ON moderation_logs
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.user_type = 'admin'
    )
  );

DROP POLICY IF EXISTS "System can insert moderation logs" ON moderation_logs;
CREATE POLICY "System can insert moderation logs" ON moderation_logs
  FOR INSERT WITH CHECK (true);

-- Grant permissions
GRANT SELECT ON moderation_logs TO authenticated;
GRANT INSERT ON moderation_logs TO authenticated;

-- ============================================
-- 6. Profile Enhancements
-- ============================================

-- Add account type field
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS account_type TEXT DEFAULT 'student'
  CHECK (account_type IN ('student', 'professional', 'business_owner'));

-- Add verification fields
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS is_verified BOOLEAN DEFAULT false;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS verified_at TIMESTAMPTZ;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS account_badges TEXT[] DEFAULT '{}';

-- ============================================
-- 7. Student-only Housing RLS Policy
-- ============================================

-- Note: This policy adds a restriction for housing listings
-- Students can view all listings, non-students cannot view housing listings
DROP POLICY IF EXISTS "Students can view housing listings" ON marketplace_listings;
CREATE POLICY "Students can view housing listings" ON marketplace_listings
  FOR SELECT USING (
    listing_type != 'housing'
    OR (
      listing_type = 'housing'
      AND EXISTS (
        SELECT 1 FROM profiles
        WHERE profiles.id = auth.uid()
        AND (profiles.account_type = 'student' OR profiles.user_type = 'student')
      )
    )
    OR seller_id = auth.uid()
  );

-- ============================================
-- 8. Indexes for Performance
-- ============================================

CREATE INDEX IF NOT EXISTS idx_chat_presence_room ON chat_presence(chat_room_id);
CREATE INDEX IF NOT EXISTS idx_chat_presence_user ON chat_presence(user_id);
CREATE INDEX IF NOT EXISTS idx_chat_presence_online ON chat_presence(is_online) WHERE is_online = true;
CREATE INDEX IF NOT EXISTS idx_chat_messages_status ON chat_messages(status);
CREATE INDEX IF NOT EXISTS idx_listing_reports_listing ON listing_reports(listing_id);
CREATE INDEX IF NOT EXISTS idx_listing_reports_status ON listing_reports(status);
CREATE INDEX IF NOT EXISTS idx_listing_reports_created ON listing_reports(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_saved_listings_user ON saved_listings(user_id);
CREATE INDEX IF NOT EXISTS idx_saved_listings_listing ON saved_listings(listing_id);
CREATE INDEX IF NOT EXISTS idx_moderation_logs_user ON moderation_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_moderation_logs_content ON moderation_logs(content_type, content_id);
CREATE INDEX IF NOT EXISTS idx_moderation_logs_created ON moderation_logs(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_profiles_account_type ON profiles(account_type);
CREATE INDEX IF NOT EXISTS idx_profiles_verified ON profiles(is_verified) WHERE is_verified = true;

-- ============================================
-- 9. Functions for Real-time Presence
-- ============================================

-- Function to automatically update last_seen timestamp
CREATE OR REPLACE FUNCTION update_presence_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.last_seen = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for presence updates
DROP TRIGGER IF EXISTS presence_timestamp_trigger ON chat_presence;
CREATE TRIGGER presence_timestamp_trigger
  BEFORE UPDATE ON chat_presence
  FOR EACH ROW
  EXECUTE FUNCTION update_presence_timestamp();

-- Function to upsert presence (insert or update)
CREATE OR REPLACE FUNCTION upsert_chat_presence(
  p_user_id UUID,
  p_chat_room_id UUID,
  p_is_online BOOLEAN DEFAULT true,
  p_is_typing BOOLEAN DEFAULT false
)
RETURNS UUID AS $$
DECLARE
  v_id UUID;
BEGIN
  INSERT INTO chat_presence (user_id, chat_room_id, is_online, is_typing, last_seen)
  VALUES (p_user_id, p_chat_room_id, p_is_online, p_is_typing, now())
  ON CONFLICT (user_id, chat_room_id)
  DO UPDATE SET
    is_online = p_is_online,
    is_typing = p_is_typing,
    last_seen = now()
  RETURNING id INTO v_id;

  RETURN v_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 10. Function to Check Housing Access
-- ============================================

CREATE OR REPLACE FUNCTION can_view_housing(p_user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM profiles
    WHERE id = p_user_id
    AND (account_type = 'student' OR user_type = 'student')
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 11. Function to Get Presence for Chat Room
-- ============================================

CREATE OR REPLACE FUNCTION get_chat_room_presence(p_chat_room_id UUID)
RETURNS TABLE (
  user_id UUID,
  full_name VARCHAR,
  avatar_url TEXT,
  is_online BOOLEAN,
  is_typing BOOLEAN,
  last_seen TIMESTAMPTZ
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    cp.user_id,
    p.full_name,
    p.avatar_url,
    cp.is_online,
    cp.is_typing,
    cp.last_seen
  FROM chat_presence cp
  JOIN profiles p ON p.id = cp.user_id
  WHERE cp.chat_room_id = p_chat_room_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 12. Function to Update Saved Listings Count
-- ============================================

CREATE OR REPLACE FUNCTION update_saved_listings_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE marketplace_listings
    SET favorites_count = COALESCE(favorites_count, 0) + 1
    WHERE id = NEW.listing_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE marketplace_listings
    SET favorites_count = GREATEST(0, COALESCE(favorites_count, 0) - 1)
    WHERE id = OLD.listing_id;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Trigger for saved listings count
DROP TRIGGER IF EXISTS trigger_update_saved_listings_count ON saved_listings;
CREATE TRIGGER trigger_update_saved_listings_count
  AFTER INSERT OR DELETE ON saved_listings
  FOR EACH ROW EXECUTE FUNCTION update_saved_listings_count();

-- ============================================
-- 13. Enable Realtime for Presence Table
-- ============================================

-- Enable realtime for chat_presence
ALTER PUBLICATION supabase_realtime ADD TABLE chat_presence;

-- ============================================
-- Migration Complete
-- ============================================

SELECT 'Feature enhancements migration completed successfully!' as status;
