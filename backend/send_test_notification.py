"""
MANUAL NOTIFICATION TEST - Send a test notification RIGHT NOW
This bypasses everything and directly sends a Firebase notification
"""
import sys
import os
from datetime import datetime
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Import Firebase Admin SDK directly
import firebase_admin
from firebase_admin import credentials, messaging
from supabase import create_client

# Initialize Supabase
url = os.getenv("SUPABASE_URL")
key = os.getenv("SUPABASE_KEY")
supabase = create_client(url, key)

# Initialize Firebase
try:
    firebase_admin.get_app()
except ValueError:
    cred = credentials.Certificate('firebase-service-account.json')
    firebase_admin.initialize_app(cred)

print("="*60)
print("MANUAL NOTIFICATION TEST")
print("="*60)

# First, list all users
print("\n0. Checking all users in database...")
all_users = supabase.table('users').select('user_id, email, fcm_token').execute()
print(f"Found {len(all_users.data)} users:")
for u in all_users.data:
    token_preview = u.get('fcm_token', '')
    if token_preview:
        token_preview = token_preview[:20] + "..."
    else:
        token_preview = "(no token)"
    print(f"  User {u['user_id']}: {u.get('email', 'no email')} - Token: {token_preview}")

# Get user 53's FCM token
print("\n1. Fetching FCM token for first user with token...")
users_with_tokens = [u for u in all_users.data if u.get('fcm_token')]
if not users_with_tokens:
    print("❌ No users have FCM tokens!")
    print("   Please open the app and login to register an FCM token")
    exit(1)

user = users_with_tokens[0]
user_id = user['user_id']
fcm_token = user['fcm_token']

print(f"✅ Found FCM token for user {user_id}: {fcm_token[:20]}...")

# Send test notification
print("\n2. Sending test notification...")

try:
    message = messaging.Message(
        notification=messaging.Notification(
            title=f"💊 Time to take TEST MEDICINE",
            body=f"Dose: 1 tablet at {datetime.now().strftime('%H:%M')}"
        ),
        token=fcm_token
    )
    
    response = messaging.send(message)
    print(f"✅ Notification sent! Message ID: {response}")
    success = True
except Exception as e:
    print(f"❌ Error sending notification: {e}")
    success = False

if success:
    print("\n" + "="*60)
    print("✅ NOTIFICATION SENT SUCCESSFULLY!")
    print("="*60)
    print("Check your device NOW - you should receive the notification!")
else:
    print("\n" + "="*60)
    print("❌ NOTIFICATION FAILED TO SEND")
    print("="*60)
    print("Possible reasons:")
    print("1. FCM token is expired - restart the app")
    print("2. Device is offline")
    print("3. Firebase credentials are incorrect")
