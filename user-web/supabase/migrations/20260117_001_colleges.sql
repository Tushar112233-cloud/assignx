-- ============================================================================
-- Migration: 001_colleges
-- Description: Create colleges table for campus verification
-- Author: AssignX Team
-- Date: 2026-01-17
-- ============================================================================

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- COLLEGES TABLE
-- Stores information about verified colleges/universities
-- ============================================================================

CREATE TABLE IF NOT EXISTS colleges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  short_name VARCHAR(50), -- e.g., "IIT-B", "BITS"
  domain VARCHAR(255), -- e.g., "stanford.edu", "iitb.ac.in"
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
  total_students INTEGER DEFAULT 0, -- Cached count of verified students
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- INDEXES
-- ============================================================================

-- Index for domain lookup (for email verification)
CREATE INDEX IF NOT EXISTS idx_colleges_domain ON colleges(domain) WHERE domain IS NOT NULL;

-- Index for location-based queries
CREATE INDEX IF NOT EXISTS idx_colleges_city ON colleges(city);
CREATE INDEX IF NOT EXISTS idx_colleges_state ON colleges(state);
CREATE INDEX IF NOT EXISTS idx_colleges_country ON colleges(country);

-- Index for active/verified colleges
CREATE INDEX IF NOT EXISTS idx_colleges_active_verified ON colleges(is_active, is_verified) WHERE is_active = TRUE AND is_verified = TRUE;

-- Full text search index for college name
CREATE INDEX IF NOT EXISTS idx_colleges_name_search ON colleges USING gin(to_tsvector('english', name));

-- ============================================================================
-- TRIGGER: Auto-update updated_at
-- ============================================================================

CREATE OR REPLACE FUNCTION update_colleges_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_colleges_updated_at ON colleges;
CREATE TRIGGER trigger_colleges_updated_at
  BEFORE UPDATE ON colleges
  FOR EACH ROW
  EXECUTE FUNCTION update_colleges_updated_at();

-- ============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================================

ALTER TABLE colleges ENABLE ROW LEVEL SECURITY;

-- Policy: Everyone can read active, verified colleges
CREATE POLICY colleges_select_policy ON colleges
  FOR SELECT
  USING (is_active = TRUE AND is_verified = TRUE);

-- Policy: Only admins can insert/update/delete colleges
CREATE POLICY colleges_admin_insert_policy ON colleges
  FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM admins
      WHERE admins.profile_id = auth.uid()
    )
  );

CREATE POLICY colleges_admin_update_policy ON colleges
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM admins
      WHERE admins.profile_id = auth.uid()
    )
  );

CREATE POLICY colleges_admin_delete_policy ON colleges
  FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM admins
      WHERE admins.profile_id = auth.uid()
    )
  );

-- ============================================================================
-- SEED DATA: Indian Colleges
-- ============================================================================

INSERT INTO colleges (name, short_name, domain, city, state, country, college_type, is_verified) VALUES
-- IITs
('Indian Institute of Technology Bombay', 'IIT-B', 'iitb.ac.in', 'Mumbai', 'Maharashtra', 'India', 'institute', TRUE),
('Indian Institute of Technology Delhi', 'IIT-D', 'iitd.ac.in', 'New Delhi', 'Delhi', 'India', 'institute', TRUE),
('Indian Institute of Technology Madras', 'IIT-M', 'iitm.ac.in', 'Chennai', 'Tamil Nadu', 'India', 'institute', TRUE),
('Indian Institute of Technology Kanpur', 'IIT-K', 'iitk.ac.in', 'Kanpur', 'Uttar Pradesh', 'India', 'institute', TRUE),
('Indian Institute of Technology Kharagpur', 'IIT-KGP', 'iitkgp.ac.in', 'Kharagpur', 'West Bengal', 'India', 'institute', TRUE),
('Indian Institute of Technology Roorkee', 'IIT-R', 'iitr.ac.in', 'Roorkee', 'Uttarakhand', 'India', 'institute', TRUE),
('Indian Institute of Technology Guwahati', 'IIT-G', 'iitg.ac.in', 'Guwahati', 'Assam', 'India', 'institute', TRUE),
('Indian Institute of Technology Hyderabad', 'IIT-H', 'iith.ac.in', 'Hyderabad', 'Telangana', 'India', 'institute', TRUE),

-- NITs
('National Institute of Technology Trichy', 'NIT-T', 'nitt.edu', 'Tiruchirappalli', 'Tamil Nadu', 'India', 'institute', TRUE),
('National Institute of Technology Warangal', 'NIT-W', 'nitw.ac.in', 'Warangal', 'Telangana', 'India', 'institute', TRUE),
('National Institute of Technology Surathkal', 'NITK', 'nitk.edu.in', 'Mangalore', 'Karnataka', 'India', 'institute', TRUE),

-- BITS
('BITS Pilani', 'BITS-P', 'pilani.bits-pilani.ac.in', 'Pilani', 'Rajasthan', 'India', 'institute', TRUE),
('BITS Goa', 'BITS-G', 'goa.bits-pilani.ac.in', 'Goa', 'Goa', 'India', 'institute', TRUE),
('BITS Hyderabad', 'BITS-H', 'hyderabad.bits-pilani.ac.in', 'Hyderabad', 'Telangana', 'India', 'institute', TRUE),

-- Other Major Universities
('Delhi University', 'DU', 'du.ac.in', 'New Delhi', 'Delhi', 'India', 'university', TRUE),
('Jawaharlal Nehru University', 'JNU', 'jnu.ac.in', 'New Delhi', 'Delhi', 'India', 'university', TRUE),
('University of Mumbai', 'MU', 'mu.ac.in', 'Mumbai', 'Maharashtra', 'India', 'university', TRUE),
('Anna University', 'AU', 'annauniv.edu', 'Chennai', 'Tamil Nadu', 'India', 'university', TRUE),
('VIT Vellore', 'VIT', 'vit.ac.in', 'Vellore', 'Tamil Nadu', 'India', 'institute', TRUE),
('SRM Institute', 'SRM', 'srmist.edu.in', 'Chennai', 'Tamil Nadu', 'India', 'institute', TRUE),
('Manipal Academy', 'MAHE', 'manipal.edu', 'Manipal', 'Karnataka', 'India', 'university', TRUE),
('Amity University', 'Amity', 'amity.edu', 'Noida', 'Uttar Pradesh', 'India', 'university', TRUE),
('Christ University', 'Christ', 'christuniversity.in', 'Bangalore', 'Karnataka', 'India', 'university', TRUE),
('Symbiosis International University', 'SIU', 'siu.edu.in', 'Pune', 'Maharashtra', 'India', 'university', TRUE)
ON CONFLICT DO NOTHING;

-- ============================================================================
-- COMMENTS
-- ============================================================================

COMMENT ON TABLE colleges IS 'Stores verified college/university information for campus verification';
COMMENT ON COLUMN colleges.domain IS 'Email domain for college verification (e.g., iitb.ac.in)';
COMMENT ON COLUMN colleges.short_name IS 'Short/abbreviated name of the college';
COMMENT ON COLUMN colleges.total_students IS 'Cached count of verified students from this college';
COMMENT ON COLUMN colleges.metadata IS 'Additional college data like departments, courses, etc.';

-- Grant permissions
GRANT SELECT ON colleges TO authenticated;
GRANT SELECT ON colleges TO anon;
