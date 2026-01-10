"""Check recent medicine additions in local vs remote"""
from app import create_app
from app.supabase_client import supabase
import sqlite3

app = create_app()

with app.app_context():
    print("\n" + "="*60)
    print("📊 MEDICINE TRACKING - LOCAL vs REMOTE")
    print("="*60)
    
    # Check local DB
    print("\n💾 LOCAL DATABASE (last 5 medicines):")
    print("-" * 60)
    conn = sqlite3.connect('medigo.db')
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()
    
    cursor.execute('''
        SELECT medicine_track_id, user_id, name, type, dosage, created_at
        FROM medicine_tracking
        ORDER BY medicine_track_id DESC
        LIMIT 5
    ''')
    
    local_rows = cursor.fetchall()
    if local_rows:
        for row in local_rows:
            print(f"  ID: {row['medicine_track_id']:4d} | User: {row['user_id']:3d} | {row['name']} ({row['type']}) | Created: {row['created_at']}")
    else:
        print("  No medicines found")
    
    conn.close()
    
    # Check Supabase
    if supabase:
        print("\n🌐 SUPABASE (last 5 medicines):")
        print("-" * 60)
        try:
            response = supabase.table('medicine_tracking')\
                .select('medicine_track_id, user_id, name, type, dosage, created_at')\
                .order('medicine_track_id', desc=True)\
                .limit(5)\
                .execute()
            
            if response.data:
                for med in response.data:
                    print(f"  ID: {med['medicine_track_id']:4d} | User: {med['user_id']:3d} | {med['name']} ({med['type']}) | Created: {med['created_at']}")
            else:
                print("  No medicines found")
        except Exception as e:
            print(f"  ❌ Error: {e}")
    
    print("\n" + "="*60)
    print("💡 DIAGNOSIS:")
    print("="*60)
    print("If medicines appear in LOCAL but not SUPABASE:")
    print("  → Backend is falling back to local DB")
    print("  → Check backend logs for Supabase errors")
    print("  → User ID mapping might be incorrect")
    print("\nIf medicines appear in BOTH:")
    print("  → Everything is working correctly")
    print("="*60)
