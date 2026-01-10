#!/usr/bin/env python3
"""Check what's actually in the local SQLite database."""

import sqlite3
from pathlib import Path

# Find the local database
db_path = Path(__file__).parent / "medigo.db"

if not db_path.exists():
    print(f"❌ Database not found at: {db_path}")
    exit(1)

print(f"📂 Database location: {db_path}\n")

conn = sqlite3.connect(db_path)
conn.row_factory = sqlite3.Row

# Check medicine_tracking
print("=" * 60)
print("MEDICINE_TRACKING TABLE")
print("=" * 60)
cursor = conn.execute("SELECT * FROM medicine_tracking ORDER BY medicine_track_id DESC LIMIT 10")
rows = cursor.fetchall()
if rows:
    for row in rows:
        print(f"  ID: {row['medicine_track_id']}, User: {row['user_id']}, Name: {row['name']}, Type: {row['type']}")
else:
    print("  (empty)")

# Check medicine_plan
print("\n" + "=" * 60)
print("MEDICINE_PLAN TABLE")
print("=" * 60)
cursor = conn.execute("SELECT * FROM medicine_plan ORDER BY plan_id DESC LIMIT 10")
rows = cursor.fetchall()
if rows:
    for row in rows:
        print(f"  Plan ID: {row['plan_id']}, Medicine ID: {row['medicine_track_id']}, User: {row['user_id']}")
else:
    print("  (empty)")

# Check occurrence_plan
print("\n" + "=" * 60)
print("OCCURRENCE_PLAN TABLE")
print("=" * 60)
cursor = conn.execute("SELECT * FROM occurrence_plan ORDER BY id DESC LIMIT 10")
rows = cursor.fetchall()
if rows:
    for row in rows:
        print(f"  ID: {row['id']}, Plan ID: {row['plan_id']}, Date: {row['date']}, Time: {row['time']}, Taken: {row['is_taken']}")
else:
    print("  (empty)")

# Check the JOIN query that the frontend uses
print("\n" + "=" * 60)
print("FRONTEND QUERY SIMULATION (with JOINs)")
print("=" * 60)
cursor = conn.execute("""
    SELECT o.*, mt.name AS medicine_name, mp.importance AS importance
    FROM occurrence_plan o
    LEFT JOIN medicine_plan mp ON o.plan_id = mp.plan_id
    LEFT JOIN medicine_tracking mt ON mp.medicine_track_id = mt.medicine_track_id
    ORDER BY o.date DESC, o.time DESC
    LIMIT 10
""")
rows = cursor.fetchall()
if rows:
    for row in rows:
        print(f"  Occurrence ID: {row['id']}, Medicine: {row['medicine_name']}, Date: {row['date']}, Time: {row['time']}")
else:
    print("  (empty or no matching JOINs)")

conn.close()
print("\n✅ Check complete")
