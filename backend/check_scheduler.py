from dotenv import load_dotenv
import os
from supabase import create_client
from datetime import datetime, timedelta

load_dotenv()
url = os.getenv("SUPABASE_URL")
key = os.getenv("SUPABASE_KEY")
supabase = create_client(url, key)

now = datetime.now()
print(f"Current time: {now.strftime('%Y-%m-%d %H:%M:%S')}")

window_start = (now - timedelta(minutes=1))
window_end = (now + timedelta(minutes=60))

print(f"\nChecking for occurrences between:")
print(f"  {window_start.strftime('%Y-%m-%d %H:%M:%S')}")
print(f"  and {window_end.strftime('%Y-%m-%d %H:%M:%S')}")

result = supabase.table('occurrence_plan').select('*').execute()
upcoming = []

for occ in result.data:
    occ_datetime_str = f"{occ['date']} {occ['time']}:00"
    try:
        occ_dt = datetime.strptime(occ_datetime_str, "%Y-%m-%d %H:%M:%S")
        if window_start <= occ_dt <= window_end and occ['is_taken'] == 0:
            upcoming.append((occ, occ_dt))
    except Exception as e:
        pass

if upcoming:
    print(f"\nFound {len(upcoming)} upcoming occurrences:")
    for occ, occ_dt in sorted(upcoming, key=lambda x: x[1]):
        mins_until = int((occ_dt - now).total_seconds() / 60)
        print(f"   ID {occ['id']}: Plan {occ['plan_id']} at {occ['time']} ({mins_until} minutes from now)")
else:
    print("\nNo upcoming occurrences found")
    print("Add a medicine with time 2-3 minutes from now")

# Check FCM tokens
print("\nChecking FCM tokens...")
users_with_tokens = supabase.table('users').select('user_id, fcm_token').not_.is_('fcm_token', 'null').execute()
if users_with_tokens.data:
    print(f"Found {len(users_with_tokens.data)} users with FCM tokens")
else:
    print("WARNING: No users have FCM tokens! Restart the app.")
