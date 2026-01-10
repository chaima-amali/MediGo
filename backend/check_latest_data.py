from dotenv import load_dotenv
import os
from supabase import create_client
from datetime import datetime

load_dotenv()
url = os.getenv("SUPABASE_URL")
key = os.getenv("SUPABASE_KEY")
supabase = create_client(url, key)

print("Checking latest data for user 75...")
print("=" * 60)

# Latest medicines
medicines = supabase.table('medicine_tracking').select('*').eq('user_id', 75).order('medicine_track_id', desc=True).limit(3).execute()
print("\nLatest medicines:")
for m in medicines.data:
    print(f"  ID {m['medicine_track_id']}: {m['name']}")

# Latest plans
plans = supabase.table('medicine_plan').select('*').eq('user_id', 75).order('plan_id', desc=True).limit(3).execute()
print("\nLatest plans:")
for p in plans.data:
    print(f"  Plan {p['plan_id']}: medicine_id={p['medicine_track_id']}, {p['start_date']}")

# Latest occurrences (ALL, not just user 75)
occs = supabase.table('occurrence_plan').select('*').order('id', desc=True).limit(10).execute()
print("\nLatest occurrences (last 10):")
today = datetime.now().strftime('%Y-%m-%d')
for o in occs.data:
    marker = " <-- TODAY" if o['date'] == today else ""
    print(f"  ID {o['id']}: Plan {o['plan_id']}, {o['date']} at {o['time']}{marker}")
