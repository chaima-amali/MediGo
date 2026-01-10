"""Clear all expired FCM tokens so users can re-register"""
from dotenv import load_dotenv
import os
from supabase import create_client

load_dotenv()
url = os.getenv("SUPABASE_URL")
key = os.getenv("SUPABASE_KEY")
supabase = create_client(url, key)

print("Clearing all expired FCM tokens...")

# Clear all FCM tokens
result = supabase.table('users').update({'fcm_token': None}).not_.is_('fcm_token', 'null').execute()

print(f"✅ Cleared {len(result.data)} FCM tokens")
print("\nUsers must now:")
print("1. Close the MediGo app COMPLETELY (swipe away from recent apps)")
print("2. Reopen the app")
print("3. Login")
print("4. The app will automatically register a fresh FCM token")
