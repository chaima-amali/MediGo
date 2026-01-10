import sys
import os
sys.dont_write_bytecode = True
os.environ['PYTHONDONTWRITEBYTECODE'] = '1'

from dotenv import load_dotenv
load_dotenv()

# Direct Supabase check without importing app
from supabase import create_client
url = os.getenv("SUPABASE_URL")
key = os.getenv("SUPABASE_KEY")
sb = create_client(url, key)

print("=== CHECKING SUPABASE DATABASE ===\n")

print("Medicines (last 3):")
r = sb.table("medicine_tracking").select("*").order("medicine_track_id", desc=True).limit(3).execute()
for row in r.data:
    print(f"  {row['medicine_track_id']}: {row['name']} (user {row['user_id']})")

print("\nPlans (last 3):")
r = sb.table("medicine_plan").select("*").order("plan_id", desc=True).limit(3).execute()
for row in r.data:
    print(f"  Plan {row['plan_id']}: medicine_id={row['medicine_track_id']}")

print("\nOccurrences (last 5):")
r = sb.table("occurrence_plan").select("*").order("id", desc=True).limit(5).execute()
for row in r.data:
    print(f"  {row['id']}: plan={row['plan_id']}, {row['date']} {row['time']}")

print("\nUsers with FCM tokens:")
r = sb.table("users").select("user_id,fcm_token").not_.is_("fcm_token", "null").execute()
for row in r.data:
    token = row.get('fcm_token', '')
    print(f"  User {row['user_id']}: {token[:20]}..." if token else f"  User {row['user_id']}: (empty)")
