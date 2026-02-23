-- ============================================================================
-- FULL MIGRATION SCRIPT FOR ASSIGNX
-- Run this in Supabase SQL Editor: https://supabase.com/dashboard/project/eowrlcwcqrpavpfspcza/sql
-- ============================================================================

-- ============================================================================
-- PART 1: COLLEGES TABLE
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS colleges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  short_name VARCHAR(50),
  domain VARCHAR(255),
  logo_url TEXT,
  city VARCHAR(100),
  state VARCHAR(100),
  country VARCHAR(100) DEFAULT 'India',
  address TEXT,
  website VARCHAR(500),
  established_year INTEGER,
  college_type VARCHAR(50) CHECK (college_type IN ('university', 'college', 'institute', 'autonomous')),
  is_verified BOOLEAN DEFAULT TRUE,
  is_active BOOLEAN DEFAULT TRUE,
  total_students INTEGER DEFAULT 0,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_colleges_domain ON colleges(domain) WHERE domain IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_colleges_city ON colleges(city);
CREATE INDEX IF NOT EXISTS idx_colleges_state ON colleges(state);

-- Seed colleges
INSERT INTO colleges (name, short_name, domain, city, state, country, college_type, is_verified) VALUES
('Indian Institute of Technology Bombay', 'IIT-B', 'iitb.ac.in', 'Mumbai', 'Maharashtra', 'India', 'institute', TRUE),
('Indian Institute of Technology Delhi', 'IIT-D', 'iitd.ac.in', 'New Delhi', 'Delhi', 'India', 'institute', TRUE),
('Indian Institute of Technology Madras', 'IIT-M', 'iitm.ac.in', 'Chennai', 'Tamil Nadu', 'India', 'institute', TRUE),
('BITS Pilani', 'BITS-P', 'pilani.bits-pilani.ac.in', 'Pilani', 'Rajasthan', 'India', 'institute', TRUE),
('Delhi University', 'DU', 'du.ac.in', 'New Delhi', 'Delhi', 'India', 'university', TRUE),
('VIT Vellore', 'VIT', 'vit.ac.in', 'Vellore', 'Tamil Nadu', 'India', 'institute', TRUE),
('SRM Institute', 'SRM', 'srmist.edu.in', 'Chennai', 'Tamil Nadu', 'India', 'institute', TRUE),
('Manipal Academy', 'MAHE', 'manipal.edu', 'Manipal', 'Karnataka', 'India', 'university', TRUE),
('Christ University', 'Christ', 'christuniversity.in', 'Bangalore', 'Karnataka', 'India', 'university', TRUE)
ON CONFLICT DO NOTHING;

ALTER TABLE colleges ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS colleges_select_policy ON colleges;
CREATE POLICY colleges_select_policy ON colleges FOR SELECT USING (is_active = TRUE AND is_verified = TRUE);

GRANT SELECT ON colleges TO authenticated;
GRANT SELECT ON colleges TO anon;

-- ============================================================================
-- PART 2: CAMPUS POSTS
-- ============================================================================

DO $$ BEGIN
  CREATE TYPE campus_post_category AS ENUM (
    'events', 'opportunities', 'resources', 'lost_found', 'marketplace',
    'housing', 'rides', 'study_groups', 'clubs', 'announcements', 'discussions', 'questions'
  );
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

CREATE TABLE IF NOT EXISTS campus_posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  college_id UUID REFERENCES colleges(id) ON DELETE SET NULL,
  category campus_post_category NOT NULL,
  title VARCHAR(255) NOT NULL,
  content TEXT,
  images TEXT[] DEFAULT '{}',
  is_admin_post BOOLEAN DEFAULT FALSE,
  is_pinned BOOLEAN DEFAULT FALSE,
  location VARCHAR(255),
  event_date TIMESTAMPTZ,
  event_venue VARCHAR(255),
  deadline TIMESTAMPTZ,
  price DECIMAL(10, 2),
  likes_count INTEGER DEFAULT 0,
  comments_count INTEGER DEFAULT 0,
  saves_count INTEGER DEFAULT 0,
  views_count INTEGER DEFAULT 0,
  is_flagged BOOLEAN DEFAULT FALSE,
  is_hidden BOOLEAN DEFAULT FALSE,
  status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('draft', 'active', 'closed', 'archived', 'deleted')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_campus_posts_college_id ON campus_posts(college_id);
CREATE INDEX IF NOT EXISTS idx_campus_posts_category ON campus_posts(category);
CREATE INDEX IF NOT EXISTS idx_campus_posts_status ON campus_posts(status) WHERE status = 'active';

ALTER TABLE campus_posts ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS campus_posts_select_policy ON campus_posts;
CREATE POLICY campus_posts_select_policy ON campus_posts FOR SELECT
  USING (status = 'active' AND is_hidden = FALSE OR user_id = auth.uid());

DROP POLICY IF EXISTS campus_posts_insert_policy ON campus_posts;
CREATE POLICY campus_posts_insert_policy ON campus_posts FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL AND user_id = auth.uid());

DROP POLICY IF EXISTS campus_posts_update_policy ON campus_posts;
CREATE POLICY campus_posts_update_policy ON campus_posts FOR UPDATE
  USING (user_id = auth.uid());

DROP POLICY IF EXISTS campus_posts_delete_policy ON campus_posts;
CREATE POLICY campus_posts_delete_policy ON campus_posts FOR DELETE
  USING (user_id = auth.uid());

GRANT SELECT, INSERT, UPDATE, DELETE ON campus_posts TO authenticated;

-- ============================================================================
-- PART 3: CAMPUS INTERACTIONS
-- ============================================================================

CREATE TABLE IF NOT EXISTS campus_post_likes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID NOT NULL REFERENCES campus_posts(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT unique_post_like UNIQUE (post_id, user_id)
);

CREATE TABLE IF NOT EXISTS campus_post_comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID NOT NULL REFERENCES campus_posts(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  parent_id UUID REFERENCES campus_post_comments(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  likes_count INTEGER DEFAULT 0,
  is_hidden BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS campus_saved_posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID NOT NULL REFERENCES campus_posts(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT unique_saved_post UNIQUE (post_id, user_id)
);

-- Triggers for counts
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
  FOR EACH ROW EXECUTE FUNCTION update_campus_post_likes_count();

CREATE OR REPLACE FUNCTION update_campus_post_comments_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE campus_posts SET comments_count = comments_count + 1 WHERE id = NEW.post_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE campus_posts SET comments_count = GREATEST(0, comments_count - 1) WHERE id = OLD.post_id;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_campus_post_comments_count ON campus_post_comments;
CREATE TRIGGER trigger_update_campus_post_comments_count
  AFTER INSERT OR DELETE ON campus_post_comments
  FOR EACH ROW EXECUTE FUNCTION update_campus_post_comments_count();

-- RLS for interactions
ALTER TABLE campus_post_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE campus_post_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE campus_saved_posts ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS campus_post_likes_select ON campus_post_likes;
CREATE POLICY campus_post_likes_select ON campus_post_likes FOR SELECT USING (TRUE);
DROP POLICY IF EXISTS campus_post_likes_insert ON campus_post_likes;
CREATE POLICY campus_post_likes_insert ON campus_post_likes FOR INSERT WITH CHECK (auth.uid() = user_id);
DROP POLICY IF EXISTS campus_post_likes_delete ON campus_post_likes;
CREATE POLICY campus_post_likes_delete ON campus_post_likes FOR DELETE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS campus_post_comments_select ON campus_post_comments;
CREATE POLICY campus_post_comments_select ON campus_post_comments FOR SELECT USING (is_hidden = FALSE OR user_id = auth.uid());
DROP POLICY IF EXISTS campus_post_comments_insert ON campus_post_comments;
CREATE POLICY campus_post_comments_insert ON campus_post_comments FOR INSERT WITH CHECK (auth.uid() = user_id);
DROP POLICY IF EXISTS campus_post_comments_update ON campus_post_comments;
CREATE POLICY campus_post_comments_update ON campus_post_comments FOR UPDATE USING (auth.uid() = user_id);
DROP POLICY IF EXISTS campus_post_comments_delete ON campus_post_comments;
CREATE POLICY campus_post_comments_delete ON campus_post_comments FOR DELETE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS campus_saved_posts_select ON campus_saved_posts;
CREATE POLICY campus_saved_posts_select ON campus_saved_posts FOR SELECT USING (auth.uid() = user_id);
DROP POLICY IF EXISTS campus_saved_posts_insert ON campus_saved_posts;
CREATE POLICY campus_saved_posts_insert ON campus_saved_posts FOR INSERT WITH CHECK (auth.uid() = user_id);
DROP POLICY IF EXISTS campus_saved_posts_delete ON campus_saved_posts;
CREATE POLICY campus_saved_posts_delete ON campus_saved_posts FOR DELETE USING (auth.uid() = user_id);

GRANT SELECT, INSERT, DELETE ON campus_post_likes TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON campus_post_comments TO authenticated;
GRANT SELECT, INSERT, DELETE ON campus_saved_posts TO authenticated;

-- ============================================================================
-- PART 4: EXPERTS TABLE
-- ============================================================================

DO $$ BEGIN
  CREATE TYPE expert_category AS ENUM (
    'academic', 'career', 'research', 'technology', 'entrepreneurship',
    'finance', 'mental_health', 'fitness', 'language', 'arts', 'law', 'other'
  );
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE expert_verification_status AS ENUM (
    'pending', 'under_review', 'verified', 'rejected', 'suspended'
  );
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

CREATE TABLE IF NOT EXISTS experts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  headline VARCHAR(255) NOT NULL,
  designation VARCHAR(255) NOT NULL,
  organization VARCHAR(255),
  bio TEXT,
  category expert_category NOT NULL,
  specializations TEXT[] NOT NULL DEFAULT '{}',
  languages TEXT[] DEFAULT ARRAY['English'],
  hourly_rate DECIMAL(10, 2) NOT NULL,
  currency VARCHAR(3) DEFAULT 'INR',
  session_duration INTEGER DEFAULT 30,
  google_meet_link VARCHAR(500),
  whatsapp_number VARCHAR(20),
  availability JSONB DEFAULT '{"timezone": "Asia/Kolkata", "slots": {}}',
  verification_status expert_verification_status DEFAULT 'pending',
  rating DECIMAL(3, 2) DEFAULT 0 CHECK (rating >= 0 AND rating <= 5),
  total_reviews INTEGER DEFAULT 0,
  total_sessions INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  is_accepting_bookings BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT unique_expert_user UNIQUE (user_id)
);

CREATE INDEX IF NOT EXISTS idx_experts_category ON experts(category);
CREATE INDEX IF NOT EXISTS idx_experts_rating ON experts(rating DESC) WHERE is_active = TRUE;

ALTER TABLE experts ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS experts_select_policy ON experts;
CREATE POLICY experts_select_policy ON experts FOR SELECT
  USING ((is_active = TRUE AND verification_status = 'verified') OR user_id = auth.uid());

DROP POLICY IF EXISTS experts_insert_policy ON experts;
CREATE POLICY experts_insert_policy ON experts FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL AND user_id = auth.uid());

DROP POLICY IF EXISTS experts_update_policy ON experts;
CREATE POLICY experts_update_policy ON experts FOR UPDATE
  USING (user_id = auth.uid());

GRANT SELECT ON experts TO authenticated;
GRANT SELECT ON experts TO anon;
GRANT INSERT, UPDATE ON experts TO authenticated;

-- ============================================================================
-- PART 5: EXPERT BOOKINGS
-- ============================================================================

DO $$ BEGIN
  CREATE TYPE expert_booking_status AS ENUM (
    'pending', 'confirmed', 'in_progress', 'completed', 'cancelled', 'rejected', 'no_show', 'rescheduled'
  );
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE expert_payment_status AS ENUM (
    'pending', 'authorized', 'captured', 'refunded', 'partially_refunded', 'failed'
  );
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

CREATE TABLE IF NOT EXISTS expert_bookings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_number VARCHAR(20) UNIQUE,
  expert_id UUID NOT NULL REFERENCES experts(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  topic VARCHAR(255) NOT NULL,
  description TEXT,
  scheduled_start TIMESTAMPTZ NOT NULL,
  scheduled_end TIMESTAMPTZ NOT NULL,
  duration_minutes INTEGER NOT NULL,
  meeting_platform VARCHAR(50),
  meeting_link TEXT,
  hourly_rate DECIMAL(10, 2) NOT NULL,
  session_amount DECIMAL(10, 2) NOT NULL,
  platform_fee DECIMAL(10, 2) DEFAULT 0,
  total_amount DECIMAL(10, 2) NOT NULL,
  currency VARCHAR(3) DEFAULT 'INR',
  payment_status expert_payment_status DEFAULT 'pending',
  payment_id VARCHAR(255),
  status expert_booking_status DEFAULT 'pending',
  cancelled_by UUID REFERENCES profiles(id),
  cancellation_reason TEXT,
  cancelled_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Auto-generate booking number
CREATE OR REPLACE FUNCTION generate_booking_number()
RETURNS TRIGGER AS $$
BEGIN
  NEW.booking_number := 'BK-' || to_char(NOW(), 'YYMM') || '-' || LPAD(nextval('booking_seq')::TEXT, 5, '0');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE SEQUENCE IF NOT EXISTS booking_seq START 1;

DROP TRIGGER IF EXISTS trigger_generate_booking_number ON expert_bookings;
CREATE TRIGGER trigger_generate_booking_number
  BEFORE INSERT ON expert_bookings
  FOR EACH ROW WHEN (NEW.booking_number IS NULL)
  EXECUTE FUNCTION generate_booking_number();

CREATE TABLE IF NOT EXISTS expert_reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  expert_id UUID NOT NULL REFERENCES experts(id) ON DELETE CASCADE,
  booking_id UUID NOT NULL REFERENCES expert_bookings(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  overall_rating INTEGER NOT NULL CHECK (overall_rating >= 1 AND overall_rating <= 5),
  review_text TEXT,
  is_public BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT unique_booking_review UNIQUE (booking_id)
);

-- Update expert rating trigger
CREATE OR REPLACE FUNCTION update_expert_rating_on_review()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE experts
  SET rating = (SELECT AVG(overall_rating) FROM expert_reviews WHERE expert_id = NEW.expert_id AND is_public = TRUE),
      total_reviews = (SELECT COUNT(*) FROM expert_reviews WHERE expert_id = NEW.expert_id AND is_public = TRUE)
  WHERE id = NEW.expert_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_expert_rating ON expert_reviews;
CREATE TRIGGER trigger_update_expert_rating
  AFTER INSERT OR UPDATE ON expert_reviews
  FOR EACH ROW EXECUTE FUNCTION update_expert_rating_on_review();

CREATE TABLE IF NOT EXISTS whatsapp_notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
  phone_number VARCHAR(20) NOT NULL,
  template_name VARCHAR(100) NOT NULL,
  template_params JSONB DEFAULT '{}',
  booking_id UUID REFERENCES expert_bookings(id) ON DELETE SET NULL,
  status VARCHAR(20) DEFAULT 'pending',
  sent_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS for bookings
ALTER TABLE expert_bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE expert_reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE whatsapp_notifications ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS expert_bookings_select ON expert_bookings;
CREATE POLICY expert_bookings_select ON expert_bookings FOR SELECT
  USING (user_id = auth.uid() OR EXISTS (SELECT 1 FROM experts WHERE experts.id = expert_id AND experts.user_id = auth.uid()));

DROP POLICY IF EXISTS expert_bookings_insert ON expert_bookings;
CREATE POLICY expert_bookings_insert ON expert_bookings FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS expert_bookings_update ON expert_bookings;
CREATE POLICY expert_bookings_update ON expert_bookings FOR UPDATE
  USING (user_id = auth.uid() OR EXISTS (SELECT 1 FROM experts WHERE experts.id = expert_id AND experts.user_id = auth.uid()));

DROP POLICY IF EXISTS expert_reviews_select ON expert_reviews;
CREATE POLICY expert_reviews_select ON expert_reviews FOR SELECT USING (is_public = TRUE OR user_id = auth.uid());

DROP POLICY IF EXISTS expert_reviews_insert ON expert_reviews;
CREATE POLICY expert_reviews_insert ON expert_reviews FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS whatsapp_notifications_select ON whatsapp_notifications;
CREATE POLICY whatsapp_notifications_select ON whatsapp_notifications FOR SELECT USING (profile_id = auth.uid());

GRANT SELECT, INSERT, UPDATE ON expert_bookings TO authenticated;
GRANT SELECT, INSERT ON expert_reviews TO authenticated;
GRANT SELECT ON whatsapp_notifications TO authenticated;

-- ============================================================================
-- PART 6: PROFILE UPDATES
-- ============================================================================

ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS college_email VARCHAR(255),
ADD COLUMN IF NOT EXISTS is_college_verified BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS college_id UUID REFERENCES colleges(id) ON DELETE SET NULL,
ADD COLUMN IF NOT EXISTS college_verified_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS has_completed_tour BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS tour_completed_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS bio TEXT,
ADD COLUMN IF NOT EXISTS headline VARCHAR(255),
ADD COLUMN IF NOT EXISTS skills TEXT[] DEFAULT '{}',
ADD COLUMN IF NOT EXISTS interests TEXT[] DEFAULT '{}',
ADD COLUMN IF NOT EXISTS social_links JSONB DEFAULT '{}',
ADD COLUMN IF NOT EXISTS notification_preferences JSONB DEFAULT '{"email_notifications": true, "push_notifications": true}',
ADD COLUMN IF NOT EXISTS is_profile_public BOOLEAN DEFAULT TRUE;

CREATE INDEX IF NOT EXISTS idx_profiles_college_id ON profiles(college_id) WHERE college_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_profiles_college_verified ON profiles(is_college_verified) WHERE is_college_verified = TRUE;

-- ============================================================================
-- MIGRATION COMPLETE
-- ============================================================================

SELECT 'Migration completed successfully!' as status;
