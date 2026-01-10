#!/usr/bin/env python3
"""Check backend logs for recent API calls."""

import subprocess
import sys

# Check if backend is running and show recent output
print("Checking for recent backend activity...")
print("=" * 60)

# Just check the Supabase database directly without triggering reload
import os
import sys
sys.path.insert(0, os.path.dirname(__file__))

from dotenv import load_dotenv
from supabase import create_client

load_dotenv()
url = os.getenv("SUPABASE_URL")
key = os.getenv("SUPABASE_KEY")

if not url or not key:
    print("❌ Missing Supabase credentials")
    sys.exit(1)

# Don't import app - just connect directly
supabase = create_client(url, key)

print("Latest medicines in Supabase:")
result = supabase.table("medicine_tracking").select("*").order("medicine_track_id", desc=True).limit(3).execute()
if result.data:
    for r in result.data:
        print(f"  ID: {r['medicine_track_id']}, User: {r['user_id']}, Name: {r['name']}")
else:
    print("  (none)")

print("\nLatest plans in Supabase:")
result = supabase.table("medicine_plan").select("*").order("plan_id", desc=True).limit(3).execute()
if result.data:
    for r in result.data:
        print(f"  Plan ID: {r['plan_id']}, Medicine ID: {r['medicine_track_id']}")
else:
    print("  (none)")

print("\nLatest occurrences in Supabase:")
result = supabase.table("occurrence_plan").select("*").order("id", desc=True).limit(5).execute()
if result.data:
    for r in result.data:
        print(f"  ID: {r['id']}, Plan: {r['plan_id']}, Date: {r['date']}, Time: {r['time']}")
else:
    print("  (none)")
