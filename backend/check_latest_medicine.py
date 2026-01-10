#!/usr/bin/env python3
"""Check the latest medicines added to Supabase."""

import os
from dotenv import load_dotenv
from supabase import create_client

load_dotenv()

url = os.getenv("SUPABASE_URL")
key = os.getenv("SUPABASE_KEY")
supabase = create_client(url, key)

print("=" * 60)
print("LATEST MEDICINES IN SUPABASE")
print("=" * 60)

# Check medicine_tracking
result = supabase.table("medicine_tracking").select("*").order("medicine_track_id", desc=True).limit(5).execute()
if result.data:
    print("\nMedicine Tracking:")
    for row in result.data:
        print(f"  ID: {row['medicine_track_id']}, User: {row['user_id']}, Name: {row['name']}, Type: {row['type']}")
else:
    print("\nNo medicines found")

# Check medicine_plan
result = supabase.table("medicine_plan").select("*").order("plan_id", desc=True).limit(5).execute()
if result.data:
    print("\nMedicine Plans:")
    for row in result.data:
        print(f"  Plan ID: {row['plan_id']}, Medicine ID: {row['medicine_track_id']}, User: {row['user_id']}, Start: {row.get('start_date')}")
else:
    print("\nNo plans found")

# Check occurrence_plan
result = supabase.table("occurrence_plan").select("*").order("id", desc=True).limit(10).execute()
if result.data:
    print("\nOccurrence Plans:")
    for row in result.data:
        print(f"  ID: {row['id']}, Plan ID: {row['plan_id']}, Date: {row['date']}, Time: {row['time']}, Taken: {row['is_taken']}")
else:
    print("\nNo occurrences found")

print("\n" + "=" * 60)
