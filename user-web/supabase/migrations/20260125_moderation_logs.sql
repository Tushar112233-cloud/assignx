-- Migration: Create moderation_logs table for content moderation
-- Description: Stores chat content moderation violations for tracking and rate limiting

-- Create the moderation_logs table
CREATE TABLE IF NOT EXISTS moderation_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    project_id UUID REFERENCES projects(id) ON DELETE SET NULL,
    chat_id UUID REFERENCES chat_messages(id) ON DELETE SET NULL,
    original_content TEXT NOT NULL,
    sanitized_content TEXT NOT NULL,
    violation_types TEXT[] NOT NULL DEFAULT '{}',
    violation_count INTEGER NOT NULL DEFAULT 0,
    severity TEXT NOT NULL DEFAULT 'low' CHECK (severity IN ('low', 'medium', 'high')),
    action_taken TEXT NOT NULL DEFAULT 'blocked' CHECK (action_taken IN ('blocked', 'warned', 'flagged')),
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create indexes for efficient querying
CREATE INDEX IF NOT EXISTS idx_moderation_logs_user_id ON moderation_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_moderation_logs_project_id ON moderation_logs(project_id);
CREATE INDEX IF NOT EXISTS idx_moderation_logs_created_at ON moderation_logs(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_moderation_logs_severity ON moderation_logs(severity);
CREATE INDEX IF NOT EXISTS idx_moderation_logs_user_created ON moderation_logs(user_id, created_at DESC);

-- Create index for violation types array search
CREATE INDEX IF NOT EXISTS idx_moderation_logs_violation_types ON moderation_logs USING GIN(violation_types);

-- Add updated_at trigger
CREATE OR REPLACE FUNCTION update_moderation_logs_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_moderation_logs_updated_at ON moderation_logs;
CREATE TRIGGER trigger_moderation_logs_updated_at
    BEFORE UPDATE ON moderation_logs
    FOR EACH ROW
    EXECUTE FUNCTION update_moderation_logs_updated_at();

-- Enable Row Level Security
ALTER TABLE moderation_logs ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view their own moderation logs
CREATE POLICY "Users can view own moderation logs"
    ON moderation_logs
    FOR SELECT
    USING (auth.uid() = user_id);

-- Policy: Service role can do everything (for backend operations)
CREATE POLICY "Service role full access"
    ON moderation_logs
    FOR ALL
    USING (auth.jwt() ->> 'role' = 'service_role');

-- Policy: Authenticated users can insert their own logs
CREATE POLICY "Users can insert own moderation logs"
    ON moderation_logs
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Grant permissions
GRANT SELECT ON moderation_logs TO authenticated;
GRANT INSERT ON moderation_logs TO authenticated;

-- Add comment for documentation
COMMENT ON TABLE moderation_logs IS 'Stores content moderation violations for chat messages to track and rate limit users who attempt to share personal information';
COMMENT ON COLUMN moderation_logs.user_id IS 'The user who attempted to send the violating message';
COMMENT ON COLUMN moderation_logs.project_id IS 'Optional project context for the message';
COMMENT ON COLUMN moderation_logs.chat_id IS 'Optional chat/conversation ID';
COMMENT ON COLUMN moderation_logs.original_content IS 'The original message content (for admin review)';
COMMENT ON COLUMN moderation_logs.sanitized_content IS 'The message with personal info redacted';
COMMENT ON COLUMN moderation_logs.violation_types IS 'Array of violation types detected (phone, email, social_media, etc.)';
COMMENT ON COLUMN moderation_logs.violation_count IS 'Number of violations detected in the message';
COMMENT ON COLUMN moderation_logs.severity IS 'Severity level: low (1 violation), medium (2-3), high (4+)';
COMMENT ON COLUMN moderation_logs.action_taken IS 'Action taken: blocked, warned, or flagged';
COMMENT ON COLUMN moderation_logs.metadata IS 'Additional metadata including violation details';
