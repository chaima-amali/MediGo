"""Check local and remote occurrences"""
import sqlite3
from app import create_app
from app.supabase_client import supabase

app = create_app()

with app.app_context():
    # Check local DB
    print("\n" + "="*60)
    print("📊 LOCAL DATABASE (medigo.db)")
    print("="*60)
    
    conn = sqlite3.connect('medigo.db')
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()
    
    # Get recent occurrences
    cursor.execute('''
        SELECT 
            o.id, o.plan_id, o.date, o.time, o.is_taken,
            mp.user_id, mt.name as medicine_name
        FROM occurrence_plan o
        JOIN medicine_plan mp ON o.plan_id = mp.plan_id
        JOIN medicine_tracking mt ON mp.medicine_track_id = mt.medicine_track_id
        ORDER BY o.date DESC, o.time DESC
        LIMIT 10
    ''')
    
    rows = cursor.fetchall()
    print(f"\n✅ Found {len(rows)} recent occurrences in LOCAL DB:\n")
    
    for row in rows:
        print(f"  ID={row['id']:4d} | Plan={row['plan_id']:3d} | {row['date']} {row['time']} | User={row['user_id']} | {row['medicine_name']}")
    
    conn.close()
    
    # Check Supabase
    print("\n" + "="*60)
    print("🌐 SUPABASE (Remote)")
    print("="*60)
    
    if supabase:
        try:
            response = supabase.table('occurrence_plan')\
                .select('*, medicine_plan!inner(user_id, medicine_tracking(name))')\
                .order('date', desc=True)\
                .order('time', desc=True)\
                .limit(10)\
                .execute()
            
            if response.data:
                print(f"\n✅ Found {len(response.data)} recent occurrences in SUPABASE:\n")
                for occ in response.data:
                    med_name = occ.get('medicine_plan', {}).get('medicine_tracking', {}).get('name', 'Unknown')
                    user_id = occ.get('medicine_plan', {}).get('user_id', '?')
                    print(f"  ID={occ['id']:4d} | Plan={occ['plan_id']:3d} | {occ['date']} {occ['time']} | User={user_id} | {med_name}")
            else:
                print("\n❌ No occurrences found in SUPABASE")
        except Exception as e:
            print(f"\n❌ Supabase error: {e}")
    
    print("\n" + "="*60)
    print("💡 NEXT STEPS")
    print("="*60)
    print("1. If occurrences are in LOCAL but not SUPABASE:")
    print("   → Run: python sync_local_plans_occurrences.py")
    print("\n2. If occurrences are in SUPABASE but you didn't get notification:")
    print("   → Check your FCM token is valid in the app")
    print("   → Check the time of the occurrence (must be within 2 min window)")
    print("   → Check backend logs for scheduler errors")
    print("\n3. If NO occurrences at all:")
    print("   → Check if the medicine plan was created")
    print("   → Check backend logs when you created the occurrence")
    print("="*60)
