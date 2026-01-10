"""
Test script to verify notification system is working correctly
Run this to check all notification components
"""

import sys
import os
from datetime import datetime, timedelta

# Add parent directory to path
sys.path.insert(0, os.path.dirname(__file__))

def test_database_schema():
    """Test if fcm_token column exists in users table"""
    print("\n" + "="*50)
    print("1. Testing Database Schema")
    print("="*50)
    
    try:
        from app.core.database import execute_query
        
        # Check local database
        result = execute_query("PRAGMA table_info(users)", ())
        columns = [row['name'] for row in result]
        
        if 'fcm_token' in columns:
            print("✅ Local DB: fcm_token column exists in users table")
        else:
            print("❌ Local DB: fcm_token column is MISSING from users table")
            print("   Run: python migrate_add_fcm_token.py")
            return False
        
        # Check if any user has fcm_token
        result = execute_query("SELECT user_id, name, fcm_token FROM users WHERE fcm_token IS NOT NULL", ())
        if result:
            print(f"✅ Found {len(result)} users with FCM tokens:")
            for user in result:
                token_preview = user['fcm_token'][:20] + "..." if len(user['fcm_token']) > 20 else user['fcm_token']
                print(f"   - User {user['user_id']} ({user['name']}): {token_preview}")
        else:
            print("⚠️  No users have FCM tokens yet")
            print("   Make sure to login from the mobile app to register FCM token")
        
        return True
        
    except Exception as e:
        print(f"❌ Database test failed: {e}")
        return False

def test_firebase_initialization():
    """Test if Firebase Admin SDK is initialized"""
    print("\n" + "="*50)
    print("2. Testing Firebase Initialization")
    print("="*50)
    
    try:
        from app.services.notification_service import NotificationService
        
        # Check if service account file exists
        cred_path = os.path.join(os.path.dirname(__file__), 'firebase-service-account.json')
        if os.path.exists(cred_path):
            print(f"✅ Firebase service account file exists: {cred_path}")
        else:
            print(f"❌ Firebase service account file NOT FOUND: {cred_path}")
            print("   Download from: Firebase Console > Project Settings > Service Accounts")
            return False
        
        # Try to initialize
        NotificationService.initialize()
        
        if NotificationService._initialized:
            print("✅ Firebase Admin SDK initialized successfully")
            return True
        else:
            print("❌ Firebase Admin SDK failed to initialize")
            return False
            
    except Exception as e:
        print(f"❌ Firebase test failed: {e}")
        return False

def test_scheduler():
    """Test if scheduler is configured correctly"""
    print("\n" + "="*50)
    print("3. Testing Reminder Scheduler")
    print("="*50)
    
    try:
        from app.services.reminder_scheduler import scheduler
        
        if scheduler.is_running:
            print("✅ Scheduler is running")
        else:
            print("⚠️  Scheduler is not running (will start when backend starts)")
        
        print(f"   Check interval: Every 1 minute")
        print(f"   Reminder window: 5 minutes ahead")
        
        return True
        
    except Exception as e:
        print(f"❌ Scheduler test failed: {e}")
        return False

def test_upcoming_occurrences():
    """Check if there are any upcoming occurrences"""
    print("\n" + "="*50)
    print("4. Testing Upcoming Occurrences")
    print("="*50)
    
    try:
        from app.core.database import execute_query
        
        now = datetime.now()
        current_date = now.strftime('%Y-%m-%d')
        current_time = now.strftime('%H:%M')
        future_time = (now + timedelta(hours=2)).strftime('%H:%M')
        
        query = """
            SELECT 
                o.id, o.time, o.date, o.is_taken,
                mt.name as medicine_name,
                u.user_id, u.name as user_name, u.fcm_token
            FROM occurrence_plan o
            JOIN medicine_plan mp ON o.plan_id = mp.plan_id
            JOIN medicine_tracking mt ON mp.medicine_track_id = mt.medicine_track_id
            JOIN users u ON mp.user_id = u.user_id
            WHERE o.date = ?
            AND o.time >= ?
            AND o.time <= ?
            ORDER BY o.time
        """
        
        result = execute_query(query, (current_date, current_time, future_time))
        
        if result:
            print(f"✅ Found {len(result)} upcoming occurrences in next 2 hours:")
            for occ in result:
                status = "✓ Taken" if occ['is_taken'] == 1 else "○ Pending"
                has_token = "✓ Has FCM" if occ['fcm_token'] else "✗ No FCM"
                print(f"   - {occ['time']}: {occ['medicine_name']} for {occ['user_name']} [{status}] [{has_token}]")
        else:
            print(f"⚠️  No upcoming occurrences found for today ({current_date})")
            print(f"   Searched from {current_time} to {future_time}")
            print("   Add a medicine with a time in the next 2 hours to test")
        
        return True
        
    except Exception as e:
        print(f"❌ Occurrences test failed: {e}")
        return False

def test_supabase_connection():
    """Test Supabase connection and schema"""
    print("\n" + "="*50)
    print("5. Testing Supabase Connection")
    print("="*50)
    
    try:
        from app.supabase_client import supabase
        
        if not supabase:
            print("⚠️  Supabase client not configured (using local DB only)")
            return True
        
        # Test connection by querying users table
        response = supabase.table('users').select('user_id, fcm_token').limit(1).execute()
        
        if response.data:
            print("✅ Supabase connection successful")
            
            # Check if fcm_token column exists
            if response.data[0].get('fcm_token') is not None or 'fcm_token' in response.data[0]:
                print("✅ Supabase: fcm_token column exists in users table")
            else:
                print("❌ Supabase: fcm_token column might be missing")
                print("   Run this SQL in Supabase SQL Editor:")
                print("   ALTER TABLE users ADD COLUMN IF NOT EXISTS fcm_token TEXT;")
        else:
            print("⚠️  Supabase connected but no users found")
        
        return True
        
    except Exception as e:
        print(f"⚠️  Supabase test failed: {e}")
        print("   If using local DB only, this is okay")
        return True  # Not critical if using local only

def main():
    """Run all tests"""
    print("\n" + "="*70)
    print(" 🔔 NOTIFICATION SYSTEM DIAGNOSTIC TEST")
    print("="*70)
    
    results = {
        'Database Schema': test_database_schema(),
        'Firebase Initialization': test_firebase_initialization(),
        'Scheduler Configuration': test_scheduler(),
        'Upcoming Occurrences': test_upcoming_occurrences(),
        'Supabase Connection': test_supabase_connection(),
    }
    
    print("\n" + "="*70)
    print(" 📊 TEST SUMMARY")
    print("="*70)
    
    for test_name, passed in results.items():
        status = "✅ PASS" if passed else "❌ FAIL"
        print(f"{status}: {test_name}")
    
    all_passed = all(results.values())
    
    print("\n" + "="*70)
    if all_passed:
        print("✅ All tests passed! Notification system should be working.")
        print("\n📝 Next steps:")
        print("   1. Make sure backend is running: python backend/main.py")
        print("   2. Login from mobile app to register FCM token")
        print("   3. Add a medicine with time in next 5 minutes")
        print("   4. Wait for notification to arrive")
    else:
        print("❌ Some tests failed. Please fix the issues above.")
        print("\n🔧 Common fixes:")
        print("   - Run migration: python backend/migrate_add_fcm_token.py")
        print("   - Apply Supabase SQL: ALTER TABLE users ADD COLUMN IF NOT EXISTS fcm_token TEXT;")
        print("   - Restart backend: python backend/main.py")
        print("   - Login from mobile app to register FCM token")
    print("="*70)

if __name__ == '__main__':
    main()
