"""
Migration script to add fcm_token column to existing users table
Run this script if you already have a database without the fcm_token column
"""
import sqlite3
import os

def migrate_local_db():
    """Add fcm_token column to local SQLite database"""
    db_path = 'medigo.db'
    
    if not os.path.exists(db_path):
        print(f"❌ Database file not found: {db_path}")
        print("   Run init_local_db.py first to create the database")
        return False
    
    try:
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()
        
        # Check if fcm_token column already exists
        cursor.execute("PRAGMA table_info(users)")
        columns = [col[1] for col in cursor.fetchall()]
        
        if 'fcm_token' in columns:
            print("✅ fcm_token column already exists in users table")
            return True
        
        # Add fcm_token column
        cursor.execute("ALTER TABLE users ADD COLUMN fcm_token TEXT")
        conn.commit()
        
        print("✅ Successfully added fcm_token column to users table")
        
        # Verify the column was added
        cursor.execute("PRAGMA table_info(users)")
        columns = [col[1] for col in cursor.fetchall()]
        print(f"📋 Users table columns: {', '.join(columns)}")
        
        conn.close()
        return True
        
    except sqlite3.OperationalError as e:
        if "duplicate column name" in str(e):
            print("✅ fcm_token column already exists")
            return True
        print(f"❌ Error migrating database: {e}")
        return False
    except Exception as e:
        print(f"❌ Unexpected error: {e}")
        return False

def print_supabase_migration():
    """Print SQL command for Supabase migration"""
    print("\n" + "="*60)
    print("📝 SUPABASE MIGRATION INSTRUCTIONS")
    print("="*60)
    print("\nRun this SQL command in your Supabase SQL Editor:")
    print("\n" + "-"*60)
    print("ALTER TABLE users ADD COLUMN IF NOT EXISTS fcm_token TEXT;")
    print("-"*60)
    print("\nThis will add the fcm_token column to your Supabase users table.")
    print("="*60 + "\n")

if __name__ == '__main__':
    print("🔄 Starting database migration...")
    print()
    
    # Migrate local database
    local_success = migrate_local_db()
    
    # Print Supabase instructions
    print_supabase_migration()
    
    if local_success:
        print("✅ Migration completed successfully!")
        print("\n💡 Next steps:")
        print("   1. Run the Supabase SQL command shown above")
        print("   2. Restart your backend server")
        print("   3. Test notifications by adding a medicine with a reminder")
    else:
        print("❌ Migration failed. Please check the error messages above.")
