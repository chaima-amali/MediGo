-- =====================================================
-- FINAL SUPABASE MIGRATION
-- Run this in Supabase SQL Editor to fix all issues
-- =====================================================

-- 1. Add notifications_enabled column to users table
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS notifications_enabled BOOLEAN DEFAULT true;

-- Update existing users to have notifications enabled
UPDATE users 
SET notifications_enabled = true 
WHERE notifications_enabled IS NULL;

-- 2. Fix notification table - add missing columns for medicine reminders
ALTER TABLE notification
ADD COLUMN IF NOT EXISTS occurrence_id BIGINT,
ADD COLUMN IF NOT EXISTS sent_at TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS is_sent INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS notification_type TEXT;

-- Add foreign key constraint for occurrence_id
ALTER TABLE notification
ADD CONSTRAINT IF NOT EXISTS fk_notification_occurrence 
FOREIGN KEY (occurrence_id) REFERENCES occurrence_plan(id) ON DELETE CASCADE;

-- 3. Create index for faster notification queries
CREATE INDEX IF NOT EXISTS idx_notification_occurrence_id ON notification(occurrence_id);
CREATE INDEX IF NOT EXISTS idx_notification_type ON notification(notification_type);
CREATE INDEX IF NOT EXISTS idx_notification_is_sent ON notification(is_sent);

-- 4. Verify the changes
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'notification'
ORDER BY ordinal_position;

SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'users'
AND column_name IN ('fcm_token', 'notifications_enabled')
ORDER BY ordinal_position;

-- =====================================================
-- SUMMARY OF CHANGES:
-- =====================================================
-- ✅ Added notifications_enabled to users table
-- ✅ Added occurrence_id to notification table
-- ✅ Added sent_at to notification table  
-- ✅ Added is_sent to notification table
-- ✅ Added notification_type to notification table
-- ✅ Added foreign key constraint
-- ✅ Added performance indexes
-- =====================================================
