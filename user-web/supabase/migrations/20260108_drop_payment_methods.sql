-- ============================================================================
-- Drop Payment Methods Table
-- ============================================================================
-- This migration removes the payment_methods table as the feature has been
-- removed from the application.
-- ============================================================================

-- Drop the payment_methods table if it exists
DROP TABLE IF EXISTS payment_methods CASCADE;

-- Drop any related indexes if they exist
DROP INDEX IF EXISTS idx_payment_methods_profile_id;
DROP INDEX IF EXISTS idx_payment_methods_is_default;

-- Remove any related policies if they exist
-- (Policies are automatically dropped with the table)

COMMENT ON SCHEMA public IS 'Removed payment_methods table - feature deprecated';
