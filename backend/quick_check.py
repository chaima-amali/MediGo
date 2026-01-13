from dotenv import load_dotenv
import os
from supabase import create_client

load_dotenv()
url = os.getenv("SUPABASE_URL")
key = os.getenv("SUPABASE_KEY")
supabase = create_client(url, key)

print("Latest medicines:")
result = supabase.table("medicine_tracking").select("*").order("medicine_track_id", desc=True).limit(3).execute()
for r in result.data:
    print(f"  ID: {r['medicine_track_id']}, User: {r['user_id']}, Name: {r['name']}")

print("\nLatest plans:")
result = supabase.table("medicine_plan").select("*").order("plan_id", desc=True).limit(3).execute()
for r in result.data:
    print(f"  Plan ID: {r['plan_id']}, Medicine ID: {r['medicine_track_id']}")

print("\nLatest occurrences:")
result = supabase.table("occurrence_plan").select("*").order("id", desc=True).limit(5).execute()
for r in result.data:
    print(f"  ID: {r['id']}, Plan: {r['plan_id']}, Date: {r['date']}, Time: {r['time']}")
