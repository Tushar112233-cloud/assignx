-- ============================================================================
-- Migration: 005_expert_bookings
-- Description: Create expert booking and review tables
-- Author: AssignX Team
-- Date: 2026-01-17
-- ============================================================================

-- ============================================================================
-- BOOKING STATUS ENUM
-- ============================================================================

DO $$ BEGIN
  CREATE TYPE expert_booking_status AS ENUM (
    'pending',        -- Awaiting expert confirmation
    'confirmed',      -- Expert confirmed, awaiting session
    'in_progress',    -- Session is currently happening
    'completed',      -- Session completed successfully
    'cancelled',      -- Cancelled by user or expert
    'rejected',       -- Rejected by expert
    'no_show',        -- User didn't show up
    'rescheduled'     -- Moved to a different time
  );
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

-- ============================================================================
-- PAYMENT STATUS ENUM
-- ============================================================================

DO $$ BEGIN
  CREATE TYPE expert_payment_status AS ENUM (
    'pending',
    'authorized',
    'captured',
    'refunded',
    'partially_refunded',
    'failed'
  );
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

-- ============================================================================
-- EXPERT BOOKINGS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS expert_bookings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_number VARCHAR(20) UNIQUE NOT NULL, -- Human-readable booking ID

  -- Parties
  expert_id UUID NOT NULL REFERENCES experts(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,

  -- Session details
  topic VARCHAR(255) NOT NULL, -- What the user wants to discuss
  description TEXT, -- Detailed description
  category expert_category,

  -- Scheduling
  scheduled_start TIMESTAMPTZ NOT NULL,
  scheduled_end TIMESTAMPTZ NOT NULL,
  actual_start TIMESTAMPTZ,
  actual_end TIMESTAMPTZ,
  duration_minutes INTEGER NOT NULL,
  timezone VARCHAR(50) DEFAULT 'Asia/Kolkata',

  -- Meeting
  meeting_platform VARCHAR(50), -- google_meet, zoom, whatsapp, etc.
  meeting_link TEXT,
  meeting_id VARCHAR(255),
  meeting_password VARCHAR(100),

  -- Pricing
  hourly_rate DECIMAL(10, 2) NOT NULL,
  session_amount DECIMAL(10, 2) NOT NULL, -- Total session cost
  platform_fee DECIMAL(10, 2) DEFAULT 0, -- AssignX commission
  tax_amount DECIMAL(10, 2) DEFAULT 0,
  discount_amount DECIMAL(10, 2) DEFAULT 0,
  coupon_code VARCHAR(50),
  total_amount DECIMAL(10, 2) NOT NULL, -- Final amount charged
  currency VARCHAR(3) DEFAULT 'INR',

  -- Payment
  payment_status expert_payment_status DEFAULT 'pending',
  payment_id VARCHAR(255), -- Razorpay payment ID
  payment_order_id VARCHAR(255), -- Razorpay order ID
  payment_method VARCHAR(50), -- wallet, razorpay, etc.
  paid_at TIMESTAMPTZ,
  refund_id VARCHAR(255),
  refund_amount DECIMAL(10, 2),
  refunded_at TIMESTAMPTZ,

  -- Status
  status expert_booking_status DEFAULT 'pending',
  cancelled_by UUID REFERENCES profiles(id),
  cancellation_reason TEXT,
  cancelled_at TIMESTAMPTZ,
  rejection_reason TEXT,

  -- Ratings (populated after completion)
  user_rating INTEGER CHECK (user_rating >= 1 AND user_rating <= 5),
  user_review TEXT,
  expert_rating INTEGER CHECK (expert_rating >= 1 AND expert_rating <= 5),
  expert_feedback TEXT,

  -- Rescheduling
  rescheduled_from UUID REFERENCES expert_bookings(id),
  reschedule_count INTEGER DEFAULT 0,
  max_reschedules INTEGER DEFAULT 2,

  -- Communication
  pre_session_notes TEXT, -- Notes from user before session
  post_session_notes TEXT, -- Notes from expert after session

  -- Reminders
  reminder_sent_24h BOOLEAN DEFAULT FALSE,
  reminder_sent_1h BOOLEAN DEFAULT FALSE,

  -- Metadata
  metadata JSONB DEFAULT '{}',

  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- EXPERT REVIEWS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS expert_reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  expert_id UUID NOT NULL REFERENCES experts(id) ON DELETE CASCADE,
  booking_id UUID NOT NULL REFERENCES expert_bookings(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,

  -- Rating breakdown
  overall_rating INTEGER NOT NULL CHECK (overall_rating >= 1 AND overall_rating <= 5),
  knowledge_rating INTEGER CHECK (knowledge_rating >= 1 AND knowledge_rating <= 5),
  communication_rating INTEGER CHECK (communication_rating >= 1 AND communication_rating <= 5),
  helpfulness_rating INTEGER CHECK (helpfulness_rating >= 1 AND helpfulness_rating <= 5),
  punctuality_rating INTEGER CHECK (punctuality_rating >= 1 AND punctuality_rating <= 5),

  -- Review content
  review_title VARCHAR(255),
  review_text TEXT,

  -- Expert response
  expert_response TEXT,
  responded_at TIMESTAMPTZ,

  -- Visibility
  is_public BOOLEAN DEFAULT TRUE,
  is_verified BOOLEAN DEFAULT TRUE, -- Verified purchase
  is_featured BOOLEAN DEFAULT FALSE,

  -- Moderation
  is_flagged BOOLEAN DEFAULT FALSE,
  flag_reason VARCHAR(255),
  is_hidden BOOLEAN DEFAULT FALSE,

  -- Helpful votes
  helpful_count INTEGER DEFAULT 0,
  not_helpful_count INTEGER DEFAULT 0,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  -- One review per booking
  CONSTRAINT unique_booking_review UNIQUE (booking_id)
);

-- ============================================================================
-- REVIEW VOTES TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS expert_review_votes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  review_id UUID NOT NULL REFERENCES expert_reviews(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  is_helpful BOOLEAN NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),

  CONSTRAINT unique_review_vote UNIQUE (review_id, user_id)
);

-- ============================================================================
-- WHATSAPP NOTIFICATIONS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS whatsapp_notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Target
  profile_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
  phone_number VARCHAR(20) NOT NULL,

  -- Message
  template_name VARCHAR(100) NOT NULL, -- WhatsApp template name
  template_params JSONB DEFAULT '{}', -- Template variables
  message_text TEXT, -- Rendered message (for logging)

  -- Related entity
  booking_id UUID REFERENCES expert_bookings(id) ON DELETE SET NULL,
  entity_type VARCHAR(50), -- 'booking', 'expert', 'campus_post', etc.
  entity_id UUID,

  -- Status
  status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'sent', 'delivered', 'read', 'failed')),
  provider VARCHAR(50), -- twilio, gupshup, etc.
  provider_message_id VARCHAR(255),
  error_message TEXT,

  -- Timestamps
  scheduled_at TIMESTAMPTZ,
  sent_at TIMESTAMPTZ,
  delivered_at TIMESTAMPTZ,
  read_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- BOOKING NUMBER GENERATION
-- ============================================================================

CREATE OR REPLACE FUNCTION generate_booking_number()
RETURNS TRIGGER AS $$
DECLARE
  v_year VARCHAR(2);
  v_month VARCHAR(2);
  v_sequence INTEGER;
  v_booking_number VARCHAR(20);
BEGIN
  -- Format: BK-YYMM-XXXXX (e.g., BK-2601-00001)
  v_year := to_char(NOW(), 'YY');
  v_month := to_char(NOW(), 'MM');

  -- Get next sequence for this month
  SELECT COALESCE(MAX(
    CAST(SUBSTRING(booking_number FROM 9 FOR 5) AS INTEGER)
  ), 0) + 1
  INTO v_sequence
  FROM expert_bookings
  WHERE booking_number LIKE 'BK-' || v_year || v_month || '-%';

  v_booking_number := 'BK-' || v_year || v_month || '-' || LPAD(v_sequence::TEXT, 5, '0');

  NEW.booking_number := v_booking_number;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_generate_booking_number ON expert_bookings;
CREATE TRIGGER trigger_generate_booking_number
  BEFORE INSERT ON expert_bookings
  FOR EACH ROW
  WHEN (NEW.booking_number IS NULL)
  EXECUTE FUNCTION generate_booking_number();

-- ============================================================================
-- INDEXES
-- ============================================================================

-- Booking indexes
CREATE INDEX IF NOT EXISTS idx_expert_bookings_expert_id ON expert_bookings(expert_id);
CREATE INDEX IF NOT EXISTS idx_expert_bookings_user_id ON expert_bookings(user_id);
CREATE INDEX IF NOT EXISTS idx_expert_bookings_status ON expert_bookings(status);
CREATE INDEX IF NOT EXISTS idx_expert_bookings_scheduled ON expert_bookings(scheduled_start);
CREATE INDEX IF NOT EXISTS idx_expert_bookings_booking_number ON expert_bookings(booking_number);

-- Composite index for expert schedule queries
CREATE INDEX IF NOT EXISTS idx_expert_bookings_schedule ON expert_bookings(expert_id, scheduled_start, status)
  WHERE status IN ('pending', 'confirmed', 'in_progress');

-- User bookings query
CREATE INDEX IF NOT EXISTS idx_expert_bookings_user_status ON expert_bookings(user_id, status, scheduled_start DESC);

-- Review indexes
CREATE INDEX IF NOT EXISTS idx_expert_reviews_expert_id ON expert_reviews(expert_id);
CREATE INDEX IF NOT EXISTS idx_expert_reviews_user_id ON expert_reviews(user_id);
CREATE INDEX IF NOT EXISTS idx_expert_reviews_booking_id ON expert_reviews(booking_id);
CREATE INDEX IF NOT EXISTS idx_expert_reviews_rating ON expert_reviews(expert_id, overall_rating DESC)
  WHERE is_public = TRUE AND is_hidden = FALSE;

-- Review votes indexes
CREATE INDEX IF NOT EXISTS idx_expert_review_votes_review_id ON expert_review_votes(review_id);

-- WhatsApp notification indexes
CREATE INDEX IF NOT EXISTS idx_whatsapp_notifications_status ON whatsapp_notifications(status);
CREATE INDEX IF NOT EXISTS idx_whatsapp_notifications_booking_id ON whatsapp_notifications(booking_id);
CREATE INDEX IF NOT EXISTS idx_whatsapp_notifications_scheduled ON whatsapp_notifications(scheduled_at)
  WHERE status = 'pending';

-- ============================================================================
-- TRIGGERS
-- ============================================================================

-- Trigger: Update expert stats on booking completion
CREATE OR REPLACE FUNCTION update_expert_stats_on_booking()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'completed' AND OLD.status != 'completed' THEN
    UPDATE experts
    SET
      total_sessions = total_sessions + 1,
      completed_sessions = completed_sessions + 1,
      total_earnings = total_earnings + NEW.session_amount
    WHERE id = NEW.expert_id;
  ELSIF NEW.status = 'cancelled' AND OLD.status NOT IN ('cancelled', 'rejected') THEN
    UPDATE experts
    SET cancelled_sessions = cancelled_sessions + 1
    WHERE id = NEW.expert_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_expert_stats_on_booking ON expert_bookings;
CREATE TRIGGER trigger_update_expert_stats_on_booking
  AFTER UPDATE ON expert_bookings
  FOR EACH ROW
  EXECUTE FUNCTION update_expert_stats_on_booking();

-- Trigger: Update expert rating on review
CREATE OR REPLACE FUNCTION update_expert_rating_on_review()
RETURNS TRIGGER AS $$
DECLARE
  v_avg_rating DECIMAL(3, 2);
  v_total_reviews INTEGER;
BEGIN
  IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
    SELECT AVG(overall_rating), COUNT(*)
    INTO v_avg_rating, v_total_reviews
    FROM expert_reviews
    WHERE expert_id = NEW.expert_id
      AND is_public = TRUE
      AND is_hidden = FALSE;

    UPDATE experts
    SET rating = COALESCE(v_avg_rating, 0),
        total_reviews = COALESCE(v_total_reviews, 0)
    WHERE id = NEW.expert_id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_expert_rating_on_review ON expert_reviews;
CREATE TRIGGER trigger_update_expert_rating_on_review
  AFTER INSERT OR UPDATE ON expert_reviews
  FOR EACH ROW
  EXECUTE FUNCTION update_expert_rating_on_review();

-- Trigger: Update review helpful counts
CREATE OR REPLACE FUNCTION update_review_helpful_counts()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    IF NEW.is_helpful THEN
      UPDATE expert_reviews SET helpful_count = helpful_count + 1 WHERE id = NEW.review_id;
    ELSE
      UPDATE expert_reviews SET not_helpful_count = not_helpful_count + 1 WHERE id = NEW.review_id;
    END IF;
  ELSIF TG_OP = 'DELETE' THEN
    IF OLD.is_helpful THEN
      UPDATE expert_reviews SET helpful_count = GREATEST(0, helpful_count - 1) WHERE id = OLD.review_id;
    ELSE
      UPDATE expert_reviews SET not_helpful_count = GREATEST(0, not_helpful_count - 1) WHERE id = OLD.review_id;
    END IF;
  ELSIF TG_OP = 'UPDATE' AND OLD.is_helpful != NEW.is_helpful THEN
    IF NEW.is_helpful THEN
      UPDATE expert_reviews
      SET helpful_count = helpful_count + 1,
          not_helpful_count = GREATEST(0, not_helpful_count - 1)
      WHERE id = NEW.review_id;
    ELSE
      UPDATE expert_reviews
      SET helpful_count = GREATEST(0, helpful_count - 1),
          not_helpful_count = not_helpful_count + 1
      WHERE id = NEW.review_id;
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_review_helpful_counts ON expert_review_votes;
CREATE TRIGGER trigger_update_review_helpful_counts
  AFTER INSERT OR UPDATE OR DELETE ON expert_review_votes
  FOR EACH ROW
  EXECUTE FUNCTION update_review_helpful_counts();

-- Trigger: Update timestamps
CREATE OR REPLACE FUNCTION update_expert_bookings_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_expert_bookings_updated_at ON expert_bookings;
CREATE TRIGGER trigger_expert_bookings_updated_at
  BEFORE UPDATE ON expert_bookings
  FOR EACH ROW
  EXECUTE FUNCTION update_expert_bookings_updated_at();

DROP TRIGGER IF EXISTS trigger_expert_reviews_updated_at ON expert_reviews;
CREATE TRIGGER trigger_expert_reviews_updated_at
  BEFORE UPDATE ON expert_reviews
  FOR EACH ROW
  EXECUTE FUNCTION update_expert_bookings_updated_at();

-- ============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================================

-- Bookings RLS
ALTER TABLE expert_bookings ENABLE ROW LEVEL SECURITY;

CREATE POLICY expert_bookings_select_policy ON expert_bookings
  FOR SELECT
  USING (
    user_id = auth.uid() -- User can see their bookings
    OR EXISTS (SELECT 1 FROM experts WHERE experts.id = expert_id AND experts.user_id = auth.uid()) -- Expert sees their bookings
    OR EXISTS (SELECT 1 FROM admins WHERE admins.profile_id = auth.uid())
  );

CREATE POLICY expert_bookings_insert_policy ON expert_bookings
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY expert_bookings_update_policy ON expert_bookings
  FOR UPDATE
  USING (
    user_id = auth.uid()
    OR EXISTS (SELECT 1 FROM experts WHERE experts.id = expert_id AND experts.user_id = auth.uid())
    OR EXISTS (SELECT 1 FROM admins WHERE admins.profile_id = auth.uid())
  );

-- Reviews RLS
ALTER TABLE expert_reviews ENABLE ROW LEVEL SECURITY;

CREATE POLICY expert_reviews_select_policy ON expert_reviews
  FOR SELECT
  USING (
    is_public = TRUE AND is_hidden = FALSE
    OR user_id = auth.uid()
    OR EXISTS (SELECT 1 FROM experts WHERE experts.id = expert_id AND experts.user_id = auth.uid())
    OR EXISTS (SELECT 1 FROM admins WHERE admins.profile_id = auth.uid())
  );

CREATE POLICY expert_reviews_insert_policy ON expert_reviews
  FOR INSERT
  WITH CHECK (
    auth.uid() = user_id
    AND EXISTS (
      SELECT 1 FROM expert_bookings
      WHERE expert_bookings.id = booking_id
        AND expert_bookings.user_id = auth.uid()
        AND expert_bookings.status = 'completed'
    )
  );

CREATE POLICY expert_reviews_update_policy ON expert_reviews
  FOR UPDATE
  USING (
    user_id = auth.uid()
    OR EXISTS (SELECT 1 FROM experts WHERE experts.id = expert_id AND experts.user_id = auth.uid()) -- Expert can respond
    OR EXISTS (SELECT 1 FROM admins WHERE admins.profile_id = auth.uid())
  );

-- Review votes RLS
ALTER TABLE expert_review_votes ENABLE ROW LEVEL SECURITY;

CREATE POLICY expert_review_votes_select_policy ON expert_review_votes
  FOR SELECT USING (TRUE);

CREATE POLICY expert_review_votes_insert_policy ON expert_review_votes
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY expert_review_votes_update_policy ON expert_review_votes
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY expert_review_votes_delete_policy ON expert_review_votes
  FOR DELETE USING (auth.uid() = user_id);

-- WhatsApp notifications RLS (admin only read, system insert)
ALTER TABLE whatsapp_notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY whatsapp_notifications_select_policy ON whatsapp_notifications
  FOR SELECT
  USING (
    profile_id = auth.uid()
    OR EXISTS (SELECT 1 FROM admins WHERE admins.profile_id = auth.uid())
  );

-- ============================================================================
-- FUNCTIONS
-- ============================================================================

-- Function: Create expert booking
CREATE OR REPLACE FUNCTION create_expert_booking(
  p_expert_id UUID,
  p_topic VARCHAR,
  p_description TEXT,
  p_scheduled_start TIMESTAMPTZ,
  p_duration_minutes INTEGER,
  p_meeting_platform VARCHAR DEFAULT 'google_meet',
  p_payment_method VARCHAR DEFAULT 'razorpay'
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_id UUID;
  v_expert RECORD;
  v_scheduled_end TIMESTAMPTZ;
  v_session_amount DECIMAL(10, 2);
  v_platform_fee DECIMAL(10, 2);
  v_total_amount DECIMAL(10, 2);
  v_booking_id UUID;
  v_booking_number VARCHAR(20);
BEGIN
  v_user_id := auth.uid();

  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  -- Get expert details
  SELECT * INTO v_expert
  FROM experts
  WHERE id = p_expert_id
    AND is_active = TRUE
    AND verification_status = 'verified'
    AND is_accepting_bookings = TRUE;

  IF v_expert IS NULL THEN
    RAISE EXCEPTION 'Expert not available for booking';
  END IF;

  -- Cannot book yourself
  IF v_expert.user_id = v_user_id THEN
    RAISE EXCEPTION 'Cannot book yourself';
  END IF;

  -- Calculate end time
  v_scheduled_end := p_scheduled_start + (p_duration_minutes || ' minutes')::INTERVAL;

  -- Check for conflicting bookings
  IF EXISTS (
    SELECT 1 FROM expert_bookings
    WHERE expert_id = p_expert_id
      AND status IN ('pending', 'confirmed')
      AND (
        (scheduled_start, scheduled_end) OVERLAPS (p_scheduled_start, v_scheduled_end)
      )
  ) THEN
    RAISE EXCEPTION 'Time slot not available';
  END IF;

  -- Calculate pricing
  v_session_amount := (v_expert.hourly_rate / 60) * p_duration_minutes;
  v_platform_fee := v_session_amount * 0.10; -- 10% platform fee
  v_total_amount := v_session_amount + v_platform_fee;

  -- Create booking
  INSERT INTO expert_bookings (
    expert_id,
    user_id,
    topic,
    description,
    category,
    scheduled_start,
    scheduled_end,
    duration_minutes,
    meeting_platform,
    hourly_rate,
    session_amount,
    platform_fee,
    total_amount,
    payment_method,
    status
  ) VALUES (
    p_expert_id,
    v_user_id,
    p_topic,
    p_description,
    v_expert.category,
    p_scheduled_start,
    v_scheduled_end,
    p_duration_minutes,
    p_meeting_platform,
    v_expert.hourly_rate,
    v_session_amount,
    v_platform_fee,
    v_total_amount,
    p_payment_method,
    'pending'
  )
  RETURNING id, booking_number INTO v_booking_id, v_booking_number;

  RETURN json_build_object(
    'success', TRUE,
    'booking_id', v_booking_id,
    'booking_number', v_booking_number,
    'session_amount', v_session_amount,
    'platform_fee', v_platform_fee,
    'total_amount', v_total_amount,
    'currency', v_expert.currency
  );
END;
$$;

-- Function: Cancel booking
CREATE OR REPLACE FUNCTION cancel_expert_booking(
  p_booking_id UUID,
  p_reason TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_id UUID;
  v_booking RECORD;
  v_is_expert BOOLEAN;
  v_refund_eligible BOOLEAN;
BEGIN
  v_user_id := auth.uid();

  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  -- Get booking
  SELECT eb.*, e.user_id as expert_user_id
  INTO v_booking
  FROM expert_bookings eb
  JOIN experts e ON e.id = eb.expert_id
  WHERE eb.id = p_booking_id;

  IF v_booking IS NULL THEN
    RAISE EXCEPTION 'Booking not found';
  END IF;

  -- Check authorization
  v_is_expert := (v_booking.expert_user_id = v_user_id);
  IF NOT (v_booking.user_id = v_user_id OR v_is_expert) THEN
    RAISE EXCEPTION 'Not authorized';
  END IF;

  -- Check if can be cancelled
  IF v_booking.status NOT IN ('pending', 'confirmed') THEN
    RAISE EXCEPTION 'Booking cannot be cancelled in current status';
  END IF;

  -- Determine refund eligibility (more than 24h before session)
  v_refund_eligible := (v_booking.scheduled_start > NOW() + INTERVAL '24 hours');

  -- Update booking
  UPDATE expert_bookings
  SET status = 'cancelled',
      cancelled_by = v_user_id,
      cancellation_reason = p_reason,
      cancelled_at = NOW()
  WHERE id = p_booking_id;

  RETURN json_build_object(
    'success', TRUE,
    'refund_eligible', v_refund_eligible,
    'cancelled_by', CASE WHEN v_is_expert THEN 'expert' ELSE 'user' END
  );
END;
$$;

-- ============================================================================
-- COMMENTS
-- ============================================================================

COMMENT ON TABLE expert_bookings IS 'Bookings for expert consultation sessions';
COMMENT ON COLUMN expert_bookings.booking_number IS 'Human-readable booking reference';
COMMENT ON COLUMN expert_bookings.platform_fee IS 'AssignX commission on the booking';
COMMENT ON COLUMN expert_bookings.reschedule_count IS 'Number of times this booking has been rescheduled';

COMMENT ON TABLE expert_reviews IS 'User reviews for completed expert sessions';
COMMENT ON TABLE expert_review_votes IS 'Helpful/not helpful votes on reviews';
COMMENT ON TABLE whatsapp_notifications IS 'WhatsApp notification queue and logs';

-- Grant permissions
GRANT SELECT, INSERT, UPDATE ON expert_bookings TO authenticated;
GRANT SELECT, INSERT, UPDATE ON expert_reviews TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON expert_review_votes TO authenticated;
GRANT SELECT ON whatsapp_notifications TO authenticated;
GRANT EXECUTE ON FUNCTION create_expert_booking TO authenticated;
GRANT EXECUTE ON FUNCTION cancel_expert_booking TO authenticated;
