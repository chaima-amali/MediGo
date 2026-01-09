"""
Migration: Add notifications_enabled column to users table
"""
import sqlite3
import os

def migrate():
    # Path to local database
    db_path = os.path.join(os.path.dirname(__file__), 'medigo.db')
    
    if not os.path.exists(db_path):
        print(f'❌ Database file not found at: {db_path}')
        return
    
    try:
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()
        
        # Check if column already exists
        cursor.execute("PRAGMA table_info(users)")
        columns = [col[1] for col in cursor.fetchall()]
        
        if 'notifications_enabled' in columns:
            print('✅ Column notifications_enabled already exists')
        else:
            # Add notifications_enabled column (INTEGER for SQLite, default 1 = enabled)
            cursor.execute('ALTER TABLE users ADD COLUMN notifications_enabled INTEGER DEFAULT 1')
            conn.commit()
            print('✅ Added notifications_enabled column to users table')
        
        conn.close()
        print('\n✅ Local database migration complete!')
        
    except Exception as e:
        print(f'❌ Migration failed: {e}')
        return
    
    # Print instructions for Supabase
    print('\n' + '='*60)
    print('📋 SUPABASE MIGRATION INSTRUCTIONS')
    print('='*60)
    print('\nRun this SQL in Supabase SQL Editor:')
    print('\n' + '-'*60)
    print('''
-- Add notifications_enabled column to users table
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS notifications_enabled BOOLEAN DEFAULT true;

-- Update existing users to have notifications enabled by default
UPDATE users 
SET notifications_enabled = true 
WHERE notifications_enabled IS NULL;
    ''')
    print('-'*60)
    print('\n✅ After running the SQL above, the migration will be complete!\n')

if __name__ == '__main__':
    migrate()
