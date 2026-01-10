from dotenv import load_dotenv
import os
from supabase import create_client

load_dotenv()
url = os.getenv("SUPABASE_URL")
key = os.getenv("SUPABASE_KEY")
supabase = create_client(url, key)

print("Checking database for user 75's data...")
print("=" * 60)

# Medicines
medicines = supabase.table('medicine_tracking').select('*').eq('user_id', 75).order('medicine_track_id', desc=True).limit(5).execute()
print(f"\nMedicines for user 75:")
if medicines.data:
    for m in medicines.data:
        print(f"  ID {m['medicine_track_id']}: {m['name']} ({m['type']})")
else:
    print("  NONE - No medicines created!")

# Plans
if medicines.data:
    med_ids = [m['medicine_track_id'] for m in medicines.data]
    plans = supabase.table('medicine_plan').select('*').in_('medicine_track_id', med_ids).order('plan_id', desc=True).execute()
    print(f"\nPlans for these medicines:")
    if plans.data:
        for p in plans.data:
            print(f"  Plan {p['plan_id']}: medicine_id={p['medicine_track_id']}, freq={p['frequency_type']}")
    else:
        print("  NONE - No plans created!")
    
    # Occurrences
    if plans.data:
        plan_ids = [p['plan_id'] for p in plans.data]
        occs = supabase.table('occurrence_plan').select('*').in_('plan_id', plan_ids).order('id', desc=True).limit(10).execute()
        print(f"\nOccurrences for these plans:")
        if occs.data:
            for o in occs.data:
                print(f"  ID {o['id']}: Plan {o['plan_id']}, {o['date']} at {o['time']}")
        else:
            print("  NONE - No occurrences created!")

print("\n" + "=" * 60)
print("DIAGNOSIS:")
if not medicines.data:
    print("❌ MEDICINE NOT SAVED - API call failed or error in Flutter app")
elif medicines.data and not plans.data:
    print("❌ MEDICINE saved but PLAN NOT CREATED - backend error")
elif plans.data and not occs.data:
    print("❌ PLAN saved but OCCURRENCES NOT CREATED - backend error")
else:
    print("✅ Everything saved successfully!")
