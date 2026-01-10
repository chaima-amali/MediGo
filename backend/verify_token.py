from dotenv import load_dotenv
import os
from supabase import create_client

load_dotenv()
url = os.getenv("SUPABASE_URL")
key = os.getenv("SUPABASE_KEY")
supabase = create_client(url, key)

users_with_tokens = supabase.table('users').select('user_id, email, fcm_token').not_.is_('fcm_token', 'null').execute()

if users_with_tokens.data:
    print("SUCCESS: FCM TOKENS REGISTERED:")
    for u in users_with_tokens.data:
        print(f"   User {u['user_id']} ({u.get('email', 'unknown')}): {u['fcm_token'][:30]}...")
    print("\nReady to receive notifications!")
else:
    print("ERROR: NO FCM TOKENS FOUND")
    print("   Please restart the app and login")
