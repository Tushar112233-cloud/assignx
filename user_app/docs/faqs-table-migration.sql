-- FAQs Table Migration for Supabase
-- Run this migration to create the FAQs table in your Supabase project

-- Create the faqs table
CREATE TABLE IF NOT EXISTS public.faqs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    question TEXT NOT NULL,
    answer TEXT NOT NULL,
    category TEXT NOT NULL DEFAULT 'general',
    order_index INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Add a check constraint for valid categories
ALTER TABLE public.faqs
ADD CONSTRAINT faqs_category_check
CHECK (category IN ('general', 'payment', 'project', 'account', 'technical'));

-- Create an index on category for faster filtering
CREATE INDEX IF NOT EXISTS idx_faqs_category ON public.faqs(category);

-- Create an index on is_active and order_index for sorted queries
CREATE INDEX IF NOT EXISTS idx_faqs_active_order ON public.faqs(is_active, order_index);

-- Enable Row Level Security
ALTER TABLE public.faqs ENABLE ROW LEVEL SECURITY;

-- Create policy: Anyone can read active FAQs (no auth required)
CREATE POLICY "Anyone can read active FAQs"
ON public.faqs
FOR SELECT
USING (is_active = true);

-- Create policy: Only service role can insert/update/delete
-- (Use admin panel or service role key for management)
CREATE POLICY "Service role can manage FAQs"
ON public.faqs
FOR ALL
TO service_role
USING (true)
WITH CHECK (true);

-- Create a function to auto-update updated_at
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for auto-updating updated_at
DROP TRIGGER IF EXISTS faqs_updated_at ON public.faqs;
CREATE TRIGGER faqs_updated_at
    BEFORE UPDATE ON public.faqs
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Insert sample FAQs
INSERT INTO public.faqs (question, answer, category, order_index, is_active) VALUES
(
    'How does AssignX work?',
    'AssignX connects you with expert professionals who can help with your projects. Simply submit your requirements, receive a quote, and track progress in real-time.',
    'general',
    1,
    true
),
(
    'How long does it take to get a quote?',
    'You''ll typically receive a quote within 2-4 hours during business hours. For urgent requests, we prioritize faster responses.',
    'general',
    2,
    true
),
(
    'Is my information secure?',
    'Yes, all your data is encrypted and stored securely. We never share your personal information with third parties.',
    'general',
    3,
    true
),
(
    'What payment methods are accepted?',
    'We accept UPI, credit/debit cards, net banking, and wallet payments through Razorpay.',
    'payment',
    1,
    true
),
(
    'How do I get a refund?',
    'If you''re not satisfied with the work, you can request a refund within 7 days of delivery. Please contact support for assistance.',
    'payment',
    2,
    true
),
(
    'What happens if the payment fails?',
    'If your payment fails, please try again with a different payment method. If the issue persists, contact our support team and we''ll help resolve it.',
    'payment',
    3,
    true
),
(
    'Can I request revisions?',
    'Yes, you can request changes during the review period. Our experts will work with you until you''re satisfied.',
    'project',
    1,
    true
),
(
    'How do I track my project progress?',
    'You can track your project progress in real-time through the Projects section. Each project shows its current status, timeline, and deliverables.',
    'project',
    2,
    true
),
(
    'What file formats are supported?',
    'We support most common file formats including PDF, DOCX, DOC, TXT, PPTX, XLSX, and image formats (JPG, PNG). If you have a specific format requirement, please mention it in your project brief.',
    'project',
    3,
    true
),
(
    'How do I update my profile?',
    'Go to Profile > Edit Profile to update your personal information, profile picture, and contact details.',
    'account',
    1,
    true
),
(
    'How do I change my password?',
    'Go to Settings > Account and select "Change Password". You''ll receive a password reset link to your registered email.',
    'account',
    2,
    true
),
(
    'Can I delete my account?',
    'Yes, you can request account deletion by contacting support. Please note that this action is irreversible and all your data will be permanently deleted.',
    'account',
    3,
    true
),
(
    'The app is not loading properly. What should I do?',
    'Try these steps: 1) Check your internet connection, 2) Force close and restart the app, 3) Clear the app cache in your device settings, 4) Update to the latest version. If the issue persists, contact support.',
    'technical',
    1,
    true
),
(
    'I''m having trouble uploading files. What should I do?',
    'Ensure your file size is under 10MB and in a supported format. Check your internet connection and try again. If the problem continues, try uploading from the web version or contact support.',
    'technical',
    2,
    true
),
(
    'Why am I not receiving notifications?',
    'Check that notifications are enabled for AssignX in your device settings. Also verify that "Do Not Disturb" mode is turned off. If issues persist, try reinstalling the app.',
    'technical',
    3,
    true
);

-- Grant permissions
GRANT SELECT ON public.faqs TO anon;
GRANT SELECT ON public.faqs TO authenticated;
GRANT ALL ON public.faqs TO service_role;

-- Comment on table
COMMENT ON TABLE public.faqs IS 'Frequently Asked Questions for the Help & Support section';
COMMENT ON COLUMN public.faqs.category IS 'FAQ category: general, payment, project, account, technical';
COMMENT ON COLUMN public.faqs.order_index IS 'Display order within category (lower numbers appear first)';
COMMENT ON COLUMN public.faqs.is_active IS 'Whether the FAQ is visible to users';
