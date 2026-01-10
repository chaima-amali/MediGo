"""
Clean up database - Delete all medicines and users
WARNING: This will delete ALL data!
"""
from app import create_app
from app.supabase_client import supabase
import sqlite3

app = create_app()

with app.app_context():
    print("\n" + "="*80)
    print("⚠️  DATABASE CLEANUP - DELETE ALL DATA")
    print("="*80)
    
    response = input("\n❗ This will DELETE ALL medicines, plans, occurrences, and users!\n   Type 'YES' to confirm: ")
    
    if response != 'YES':
        print("\n❌ Cleanup cancelled")
        exit()
    
    print("\n🗑️  Starting cleanup...")
    
    # Clean Supabase
    if supabase:
        print("\n🌐 Cleaning Supabase...")
        try:
            # Delete occurrences first (has FK to medicine_plan)
            print("   Deleting occurrences...")
            supabase.table('occurrence_plan').delete().neq('id', 0).execute()
            
            # Delete daily dosage checks
            print("   Deleting daily dosage checks...")
            supabase.table('daily_dosage_checking').delete().neq('dc_id', 0).execute()
            
            # Delete medication intake logs
            print("   Deleting medication intake logs...")
            supabase.table('medication_intake_log').delete().neq('log_id', 0).execute()
            
            # Delete medicine plans
            print("   Deleting medicine plans...")
            supabase.table('medicine_plan').delete().neq('plan_id', 0).execute()
            
            # Delete medicine tracking
            print("   Deleting medicines...")
            supabase.table('medicine_tracking').delete().neq('medicine_track_id', 0).execute()
            
            # Delete notifications
            print("   Deleting notifications...")
            supabase.table('notification').delete().neq('notification_id', 0).execute()
            
            print("   ✅ Supabase cleaned")
            
        except Exception as e:
            print(f"   ⚠️  Supabase cleanup error: {e}")
    
    # Clean local DB
    print("\n💾 Cleaning local database...")
    conn = sqlite3.connect('medigo.db')
    cursor = conn.cursor()
    
    try:
        # Delete in order respecting foreign keys
        cursor.execute('DELETE FROM medication_intake_log')
        cursor.execute('DELETE FROM daily_dosage_checking')
        cursor.execute('DELETE FROM occurrence_plan')
        cursor.execute('DELETE FROM medicine_plan')
        cursor.execute('DELETE FROM medicine_tracking')
        cursor.execute('DELETE FROM notification')
        
        conn.commit()
        print("   ✅ Local database cleaned")
        
    except Exception as e:
        conn.rollback()
        print(f"   ⚠️  Local cleanup error: {e}")
    finally:
        conn.close()
    
    print("\n" + "="*80)
    print("✅ CLEANUP COMPLETE")
    print("="*80)
    print("\n💡 Next steps:")
    print("1. Restart backend: python main.py")
    print("2. Open your app and register/login")
    print("3. Add a new medicine with time 2-3 minutes from now")
    print("4. Watch for notifications!")
    print("="*80)
