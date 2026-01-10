#!/usr/bin/env python3
"""Check foreign key constraints on medicine_plan table."""

import sqlite3
from pathlib import Path

db_path = Path(__file__).parent / "medigo.db"

if not db_path.exists():
    print(f"❌ Database not found at: {db_path}")
    exit(1)

conn = sqlite3.connect(db_path)

print("=" * 60)
print("MEDICINE_PLAN FOREIGN KEYS")
print("=" * 60)
cursor = conn.execute("PRAGMA foreign_key_list(medicine_plan)")
rows = cursor.fetchall()
if rows:
    for row in rows:
        print(f"  Column: {row[3]} -> {row[2]}.{row[4]}")
else:
    print("  (no foreign keys)")

print("\n" + "=" * 60)
print("MEDICINE_TRACKING TABLE")
print("=" * 60)
cursor = conn.execute("SELECT medicine_track_id, user_id, name FROM medicine_tracking")
rows = cursor.fetchall()
if rows:
    for row in rows:
        print(f"  ID: {row[0]}, User: {row[1]}, Name: {row[2]}")
else:
    print("  (empty)")

# Try to manually insert a test plan to see the actual error
print("\n" + "=" * 60)
print("TEST: Manually insert a medicine_plan")
print("=" * 60)
try:
    cursor = conn.execute("""
        INSERT INTO medicine_plan (
            plan_id, medicine_track_id, user_id, importance, 
            start_date, end_date, frequency_type, interval_days,
            weekdays, month_days, custom_dates
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    """, (999, 907, 1, "primary", "2026-01-10", "2026-02-10", "daily", 1, None, None, None))
    conn.commit()
    print("  ✅ Insert successful!")
    
    # Now check if it's there
    cursor = conn.execute("SELECT * FROM medicine_plan WHERE plan_id = 999")
    row = cursor.fetchone()
    if row:
        print(f"  ✅ Verified: Plan ID {row[0]} exists")
    
    # Clean up
    conn.execute("DELETE FROM medicine_plan WHERE plan_id = 999")
    conn.commit()
except Exception as e:
    print(f"  ❌ Insert failed: {e}")

conn.close()
