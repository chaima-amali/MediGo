"""
Comprehensive test script for the notification system
Tests backend, Supabase integration, and API endpoints
"""

import sys
import requests
from datetime import datetime
from app.supabase_client import supabase


def print_header(title):
    """Print a formatted header"""
    print("\n" + "=" * 60)
    print(f"  {title}")
    print("=" * 60)


def test_supabase_connection():
    """Test 1: Check Supabase connection"""
    print_header("TEST 1: Supabase Connection")
    
    if not supabase:
        print("❌ Supabase client not initialized")
        return False
    
    print("✅ Supabase client initialized")
    return True


def test_notification_table():
    """Test 2: Check notification table structure"""
    print_header("TEST 2: Notification Table Structure")
    
    try:
        # Try to query the notification table
        response = supabase.table('notification').select('*').limit(1).execute()
        print("✅ Notification table exists and is accessible")
        
        if response.data:
            print(f"   Sample notification fields: {list(response.data[0].keys())}")
        return True
        
    except Exception as e:
        print(f"❌ Error accessing notification table: {e}")
        return False


def test_existing_notifications():
    """Test 3: Check for existing reservation notifications"""
    print_header("TEST 3: Existing Reservation Notifications")
    
    try:
        response = supabase.table('notification')\
            .select('*')\
            .like('type', 'reservation_reminder%')\
            .execute()
        
        if response.data:
            print(f"✅ Found {len(response.data)} reservation notifications")
            
            # Show details of first 3
            for i, notif in enumerate(response.data[:3], 1):
                print(f"\n   📬 Notification {i}:")
                print(f"      ID: {notif['notification_id']}")
                print(f"      User ID: {notif['user_id']}")
                print(f"      Type: {notif['type']}")
                print(f"      Message: {notif['message']}")
                print(f"      Read: {'Yes' if notif['is_read'] else 'No'}")
        else:
            print("⚠️  No reservation notifications found")
        
        return True
        
    except Exception as e:
        print(f"❌ Error querying notifications: {e}")
        return False


def test_api_endpoint(user_id=26):
    """Test 4: Test API endpoint"""
    print_header(f"TEST 4: API Endpoint (User {user_id})")
    
    base_url = "http://127.0.0.1:5000"
    endpoint = f"{base_url}/api/notifications/{user_id}"
    
    try:
        response = requests.get(endpoint, timeout=5)
        
        if response.status_code == 200:
            data = response.json()
            
            if data.get('success'):
                notifications = data.get('notifications', [])
                count = len(notifications)
                print(f"✅ API endpoint working correctly")
                print(f"   Returned {count} notifications")
                
                if count > 0:
                    print(f"\n   Sample notification:")
                    first = notifications[0]
                    print(f"      ID: {first.get('notification_id')}")
                    print(f"      Title: {first.get('title')}")
                    print(f"      Message: {first.get('message')}")
                    print(f"      Type: {first.get('type')}")
                
                return True
            else:
                print(f"❌ API returned success=False: {data}")
                return False
        else:
            print(f"❌ API returned status code: {response.status_code}")
            print(f"   Response: {response.text}")
            return False
            
    except requests.exceptions.ConnectionError:
        print("❌ Could not connect to Flask server")
        print("   Make sure the server is running on http://127.0.0.1:5000")
        return False
    except Exception as e:
        print(f"❌ Error testing API endpoint: {e}")
        return False


def test_reservation_data():
    """Test 5: Check reservation data"""
    print_header("TEST 5: Reservation Data")
    
    try:
        response = supabase.table('reservation')\
            .select('*, users!reservation_user_id_fkey(user_id, premium)')\
            .eq('status', 'pending')\
            .limit(5)\
            .execute()
        
        if not response.data:
            print("⚠️  No pending reservations found")
            print("   This is normal if no reservations are scheduled")
            return True
        
        print(f"✅ Found {len(response.data)} pending reservations")
        
        for i, res in enumerate(response.data[:3], 1):
            user_data = res.get('users', {})
            is_premium = user_data.get('premium', False) if user_data else False
            
            print(f"\n   📅 Reservation {i}:")
            print(f"      ID: {res['reservation_id']}")
            print(f"      User ID: {res['user_id']}")
            print(f"      Premium: {is_premium}")
            print(f"      Medicine: {res.get('medicine_name')}")
            print(f"      Date: {res.get('day')} at {res.get('time')}")
        
        return True
        
    except Exception as e:
        print(f"❌ Error querying reservations: {e}")
        return False


def test_users_table():
    """Test 6: Check users table"""
    print_header("TEST 6: Users Table")
    
    try:
        response = supabase.table('users')\
            .select('user_id, name, premium')\
            .limit(5)\
            .execute()
        
        if response.data:
            print(f"✅ Users table accessible")
            print(f"   Found {len(response.data)} users (showing first 5)")
            
            premium_count = sum(1 for u in response.data if u.get('premium'))
            print(f"   Premium users: {premium_count}/{len(response.data)}")
        else:
            print("⚠️  No users found")
        
        return True
        
    except Exception as e:
        print(f"❌ Error accessing users table: {e}")
        return False


def run_all_tests():
    """Run all tests"""
    print("\n" + "🔬" * 30)
    print("   MEDIGO NOTIFICATION SYSTEM TEST SUITE")
    print("🔬" * 30)
    
    tests = [
        ("Supabase Connection", test_supabase_connection),
        ("Notification Table", test_notification_table),
        ("Existing Notifications", test_existing_notifications),
        ("Users Table", test_users_table),
        ("Reservation Data", test_reservation_data),
        ("API Endpoint", test_api_endpoint),
    ]
    
    results = []
    for name, test_func in tests:
        try:
            result = test_func()
            results.append((name, result))
        except Exception as e:
            print(f"\n❌ Test '{name}' crashed: {e}")
            results.append((name, False))
    
    # Summary
    print_header("TEST SUMMARY")
    passed = sum(1 for _, result in results if result)
    total = len(results)
    
    for name, result in results:
        status = "✅ PASS" if result else "❌ FAIL"
        print(f"   {status} - {name}")
    
    print(f"\n   Total: {passed}/{total} tests passed")
    
    if passed == total:
        print("\n   🎉 All tests passed! Notification system is working correctly.")
    else:
        print("\n   ⚠️  Some tests failed. Please review the errors above.")
    
    return passed == total


if __name__ == "__main__":
    success = run_all_tests()
    sys.exit(0 if success else 1)
