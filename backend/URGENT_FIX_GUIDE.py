"""
=============================================================================
 🚨 URGENT FIX: GET NOTIFICATIONS WORKING NOW 🚨
=============================================================================

PROBLEM IDENTIFIED:
✅ Backend is running correctly
✅ Scheduler is working
✅ Database structure is correct
❌ FCM tokens are EXPIRED - Firebase can't reach your device

SOLUTION - Follow these steps EXACTLY:
=============================================================================

STEP 1: RESTART THE APP TO GET FRESH FCM TOKEN
-----------------------------------------------
1. Close the MediGo app COMPLETELY:
   - On Android: Swipe app away from recent apps
   - On iOS: Double-tap home, swipe app away
   
2. Reopen the MediGo app

3. Login again (this will register a new FCM token)

4. Wait 5 seconds for the token to register


STEP 2: VERIFY TOKEN IS REGISTERED
-----------------------------------------------
Run this command:
   python verify_token.py

If it says "✅ Token registered", continue to Step 3.
If not, repeat Step 1.


STEP 3: ADD A MEDICINE WITH NOTIFICATION TIME
-----------------------------------------------
1. In the app, click "Add Medicine"

2. Enter:
   - Name: "Test Medicine"
   - Type: Any
   - Dosage: "1 tablet"
   
3. Set the time to 2-3 minutes from NOW

4. IMPORTANT: Set frequency to "Daily"

5. Save the medicine


STEP 4: WAIT FOR NOTIFICATION
-----------------------------------------------
1. Lock your phone or put app in background

2. Wait for the scheduled time

3. You should receive a notification!


TROUBLESHOOTING:
=============================================================================

If notification doesn't arrive:
1. Check backend logs for errors
2. Run: python check_scheduler.py
3. Verify your phone has internet connection
4. Check phone notification settings for MediGo app

If medicines disappear on refresh:
- This is a separate issue being fixed
- The notification should still work even if UI has issues

=============================================================================
"""

print(__doc__)

# Create verification script
with open('verify_token.py', 'w') as f:
    f.write('''from dotenv import load_dotenv
import os
from supabase import create_client

load_dotenv()
url = os.getenv("SUPABASE_URL")
key = os.getenv("SUPABASE_KEY")
supabase = create_client(url, key)

users_with_tokens = supabase.table('users').select('user_id, email, fcm_token').not_.is_('fcm_token', 'null').execute()

if users_with_tokens.data:
    print("✅ FCM TOKENS REGISTERED:")
    for u in users_with_tokens.data:
        print(f"   User {u['user_id']} ({u.get('email', 'unknown')}): {u['fcm_token'][:30]}...")
    print("\\n✅ Ready to receive notifications!")
else:
    print("❌ NO FCM TOKENS FOUND")
    print("   Please restart the app and login")
''')

# Create scheduler check script  
with open('check_scheduler.py', 'w') as f:
    f.write('''from dotenv import load_dotenv
import os
from supabase import create_client
from datetime import datetime, timedelta

load_dotenv()
url = os.getenv("SUPABASE_URL")
key = os.getenv("SUPABASE_KEY")
supabase = create_client(url, key)

now = datetime.now()
window_start = (now + timedelta(minutes=1)).strftime("%Y-%m-%d %H:%M:%S")
window_end = (now + timedelta(minutes=5)).strftime("%Y-%m-%d %H:%M:%S")

print(f"Checking for occurrences between {window_start} and {window_end}...")

result = supabase.table('occurrence_plan').select('*').execute()
upcoming = []
for occ in result.data:
    occ_datetime_str = f"{occ['date']} {occ['time']}:00"
    try:
        occ_dt = datetime.strptime(occ_datetime_str, "%Y-%m-%d %H:%M:%S")
        if window_start <= occ_datetime_str <= window_end and occ['is_taken'] == 0:
            upcoming.append(occ)
    except:
        pass

if upcoming:
    print(f"\\n✅ Found {len(upcoming)} upcoming occurrences:")
    for occ in upcoming:
        print(f"   ID {occ['id']}: {occ['date']} at {occ['time']}")
else:
    print("\\n⚠️  No upcoming occurrences found in the next 5 minutes")
    print("   Add a medicine with time 2-3 minutes from now")
''')

print("\n✅ Helper scripts created:")
print("   - verify_token.py: Check if FCM token is registered")
print("   - check_scheduler.py: Check if scheduler will find your medicine")
