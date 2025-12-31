-- SQL Migration Script: Add sync support to existing tables
-- This adds columns needed for remote database synchronization

-- Add sync columns to user_medicines table
ALTER TABLE user_medicines ADD COLUMN IF NOT EXISTS remote_id INTEGER;
ALTER TABLE user_medicines ADD COLUMN IF NOT EXISTS synced INTEGER DEFAULT 0;
ALTER TABLE user_medicines ADD COLUMN IF NOT EXISTS last_synced TEXT;

-- Add sync columns to reservations table
ALTER TABLE reservations ADD COLUMN IF NOT EXISTS remote_id INTEGER;
ALTER TABLE reservations ADD COLUMN IF NOT EXISTS synced INTEGER DEFAULT 0;
ALTER TABLE reservations ADD COLUMN IF NOT EXISTS last_synced TEXT;

-- Add sync columns to medicine_intake_log table
ALTER TABLE medicine_intake_log ADD COLUMN IF NOT EXISTS remote_id INTEGER;
ALTER TABLE medicine_intake_log ADD COLUMN IF NOT EXISTS synced INTEGER DEFAULT 0;
ALTER TABLE medicine_intake_log ADD COLUMN IF NOT EXISTS last_synced TEXT;

-- Add sync columns to users table
ALTER TABLE users ADD COLUMN IF NOT EXISTS remote_id INTEGER;
ALTER TABLE users ADD COLUMN IF NOT EXISTS synced INTEGER DEFAULT 0;
ALTER TABLE users ADD COLUMN IF NOT EXISTS last_synced TEXT;

-- Add FCM token to users table if not exists
ALTER TABLE users ADD COLUMN IF NOT EXISTS fcm_token TEXT;

-- Create indexes for sync queries
CREATE INDEX IF NOT EXISTS idx_user_medicines_synced ON user_medicines(synced);
CREATE INDEX IF NOT EXISTS idx_user_medicines_remote_id ON user_medicines(remote_id);

CREATE INDEX IF NOT EXISTS idx_reservations_synced ON reservations(synced);
CREATE INDEX IF NOT EXISTS idx_reservations_remote_id ON reservations(remote_id);

CREATE INDEX IF NOT EXISTS idx_medicine_intake_log_synced ON medicine_intake_log(synced);
CREATE INDEX IF NOT EXISTS idx_medicine_intake_log_remote_id ON medicine_intake_log(remote_id);

-- Add updated_at triggers for sync tracking
-- Note: SQLite doesn't support triggers easily, handle in Dart code instead
