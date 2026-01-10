"""Check FCM token for the current user"""
from app import create_app
from app.supabase_client import supabase

app = create_app()

with app.app_context():
    print("\n" + "="*60)
    print("🔍 CHECKING FCM TOKENS")
    print("="*60)
    
    if supabase:
        try:
            # Get all users with their FCM tokens
            response = supabase.table('users')\
                .select('user_id, name, email, fcm_token, notifications_enabled')\
                .execute()
            
            if response.data:
                print(f"\n✅ Found {len(response.data)} users:\n")
                for user in response.data:
                    user_id = user.get('user_id')
                    name = user.get('name') or 'N/A'
                    email = user.get('email') or 'N/A'
                    token = user.get('fcm_token')
                    enabled = user.get('notifications_enabled', True)
                    
                    print(f"User ID: {user_id}")
                    print(f"  Name: {name}")
                    print(f"  Email: {email}")
                    print(f"  Notifications: {'✅ Enabled' if enabled else '❌ Disabled'}")
                    print(f"  FCM Token: {'✅ Present' if token else '❌ Missing'}")
                    if token:
                        print(f"    Token: {token[:60]}...")
                    print()
            else:
                print("\n❌ No users found")
        except Exception as e:
            print(f"\n❌ Error: {e}")
    
    print("="*60)
    print("💡 CHECKLIST:")
    print("="*60)
    print("1. ✓ User must have a valid FCM token")
    print("2. ✓ Notifications must be enabled")
    print("3. ✓ App must have notification permissions")
    print("4. ✓ App must be running or in background")
    print("="*60)
