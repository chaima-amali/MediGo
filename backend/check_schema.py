#!/usr/bin/env python3
"""Check the local database schema for medicine_plan table."""

import sqlite3
from pathlib import Path

db_path = Path(__file__).parent / "medigo.db"

if not db_path.exists():
    print(f"❌ Database not found at: {db_path}")
    exit(1)

conn = sqlite3.connect(db_path)

print("=" * 60)
print("MEDICINE_PLAN TABLE SCHEMA")
print("=" * 60)
cursor = conn.execute("PRAGMA table_info(medicine_plan)")
rows = cursor.fetchall()
for row in rows:
    print(f"  {row[1]:20} {row[2]:15} {'NOT NULL' if row[3] else ''} {'PK' if row[5] else ''}")

conn.close()
