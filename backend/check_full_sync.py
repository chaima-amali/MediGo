"""Check if plans and occurrences are syncing for recent medicines"""
from app import create_app
from app.supabase_client import supabase
import sqlite3

app = create_app()

with app.app_context():
    print("\n" + "="*60)
    print("🔍 CHECKING PLANS & OCCURRENCES FOR RECENT MEDICINES")
    print("="*60)
    
    # Get latest medicine from local
    conn = sqlite3.connect('medigo.db')
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()
    
    cursor.execute('''
        SELECT medicine_track_id, user_id, name
        FROM medicine_tracking
        ORDER BY medicine_track_id DESC
        LIMIT 3
    ''')
    
    recent_meds = cursor.fetchall()
    
    for med in recent_meds:
        med_id = med['medicine_track_id']
        user_id = med['user_id']
        name = med['name']
        
        print(f"\n📦 Medicine: {name} (ID: {med_id}, User: {user_id})")
        print("-" * 60)
        
        # Check local plans
        cursor.execute('''
            SELECT plan_id, start_date, frequency_type
            FROM medicine_plan
            WHERE medicine_track_id = ?
        ''', (med_id,))
        
        local_plans = cursor.fetchall()
        print(f"  LOCAL: {len(local_plans)} plan(s)")
        
        if local_plans:
            for plan in local_plans:
                plan_id = plan['plan_id']
                print(f"    Plan {plan_id}: {plan['frequency_type']} from {plan['start_date']}")
                
                # Check occurrences for this plan
                cursor.execute('''
                    SELECT COUNT(*) as count
                    FROM occurrence_plan
                    WHERE plan_id = ?
                ''', (plan_id,))
                
                occ_count = cursor.fetchone()['count']
                print(f"      → {occ_count} occurrence(s)")
        
        # Check Supabase plans
        if supabase:
            try:
                response = supabase.table('medicine_plan')\
                    .select('plan_id, start_date, frequency_type')\
                    .eq('medicine_track_id', med_id)\
                    .execute()
                
                print(f"  SUPABASE: {len(response.data) if response.data else 0} plan(s)")
                
                if response.data:
                    for plan in response.data:
                        plan_id = plan['plan_id']
                        print(f"    Plan {plan_id}: {plan['frequency_type']} from {plan['start_date']}")
                        
                        # Check occurrences
                        occ_resp = supabase.table('occurrence_plan')\
                            .select('id')\
                            .eq('plan_id', plan_id)\
                            .execute()
                        
                        occ_count = len(occ_resp.data) if occ_resp.data else 0
                        print(f"      → {occ_count} occurrence(s)")
            except Exception as e:
                print(f"  SUPABASE: ❌ Error: {e}")
    
    conn.close()
    
    print("\n" + "="*60)
    print("💡 COMMON ISSUES:")
    print("="*60)
    print("1. Medicine exists but NO PLANS:")
    print("   → You created the medicine but didn't set a schedule")
    print("\n2. Plans exist but NO OCCURRENCES:")
    print("   → Plan creation failed due to FK errors (already fixed)")
    print("\n3. Plans/Occurrences in LOCAL but not SUPABASE:")
    print("   → Need to run sync or check for FK errors")
    print("="*60)
