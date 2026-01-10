"""Create plan and occurrence DIRECTLY in Supabase (bypass backend)"""
from dotenv import load_dotenv
import os
from supabase import create_client
from datetime import datetime, timedelta

load_dotenv()
url = os.getenv("SUPABASE_URL")
key = os.getenv("SUPABASE_KEY")
supabase = create_client(url, key)

USER_ID = 75
MEDICINE_ID = 915

now = datetime.now()
test_time = now + timedelta(minutes=2)
time_str = test_time.strftime("%H:%M")
date_str = now.strftime("%Y-%m-%d")

print(f"Creating in Supabase DIRECTLY...")
print(f"Current time: {now.strftime('%H:%M:%S')}")
print(f"Notification time: {time_str}\n")

# Step 1: Create plan in Supabase
print("Step 1: Creating plan in Supabase...")
plan_data = {
    'medicine_track_id': MEDICINE_ID,
    'user_id': USER_ID,
    'importance': 'primary',
    'start_date': date_str,
    'end_date': (now + timedelta(days=7)).strftime("%Y-%m-%d"),
    'frequency_type': 'daily',
    'interval_days': 1
}

try:
    response = supabase.table('medicine_plan').insert(plan_data).execute()
    plan_id = response.data[0]['plan_id']
    print(f"✅ Plan created: ID {plan_id}\n")
except Exception as e:
    print(f"❌ Error creating plan: {e}")
    exit(1)

# Step 2: Create occurrence in Supabase
print("Step 2: Creating occurrence in Supabase...")
occ_data = {
    'plan_id': plan_id,
    'date': date_str,
    'time': time_str,
    'is_taken': 0
}

try:
    response = supabase.table('occurrence_plan').insert(occ_data).execute()
    occ_id = response.data[0]['id']
    print(f"✅ Occurrence created: ID {occ_id}\n")
except Exception as e:
    print(f"❌ Error creating occurrence: {e}")
    exit(1)

print("=" * 60)
print(f"🎉 NOTIFICATION WILL FIRE AT {time_str}")
print(f"That's in {(test_time - now).seconds // 60} minutes!")
print("=" * 60)
print("\n📱 Put your phone in background and wait...")
