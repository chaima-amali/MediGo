from dotenv import load_dotenv
import os
from supabase import create_client
from datetime import datetime

load_dotenv()
url = os.getenv("SUPABASE_URL")
key = os.getenv("SUPABASE_KEY")
supabase = create_client(url, key)

print("Checking occurrences around 21:31...")
print("=" * 60)

# Get occurrences for today with time around 21:31
today = datetime.now().strftime('%Y-%m-%d')
result = supabase.table('occurrence_plan').select('*').eq('date', today).execute()

found_21_31 = []
for occ in result.data:
    if '21:31' in occ['time'] or '21:30' in occ['time'] or '21:32' in occ['time']:
        found_21_31.append(occ)

if found_21_31:
    print(f"\n✅ Found {len(found_21_31)} occurrence(s) around 21:31:")
    for o in found_21_31:
        taken = "TAKEN" if o['is_taken'] == 1 else "PENDING"
        print(f"  ID {o['id']}: Plan {o['plan_id']}, {o['date']} at {o['time']} - {taken}")
else:
    print("\n❌ No occurrences found for 21:31")
    print("\nAll today's occurrences:")
    for o in result.data[-10:]:
        print(f"  ID {o['id']}: Plan {o['plan_id']}, {o['time']}")

# Check FCM token
print("\n" + "=" * 60)
print("Checking FCM token for user 75...")
user_result = supabase.table('users').select('user_id, fcm_token').eq('user_id', 75).execute()
if user_result.data and user_result.data[0].get('fcm_token'):
    token = user_result.data[0]['fcm_token']
    print(f"✅ FCM token exists: {token[:30]}...")
else:
    print("❌ No FCM token found!")
