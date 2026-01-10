"""Ensure user 67 exists in Supabase"""
from app import create_app
from app.supabase_client import supabase
import sqlite3

app = create_app()

with app.app_context():
    print("\n" + "="*60)
    print("🔍 CHECKING USER 67")
    print("="*60)
    
    # Check local DB
    conn = sqlite3.connect('medigo.db')
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()
    
    cursor.execute('SELECT * FROM users WHERE user_id = 67')
    local_user = cursor.fetchone()
    
    if local_user:
        print(f"\n✅ LOCAL: User 67 exists")
        print(f"   Name: {local_user['name']}")
        print(f"   Email: {local_user['email']}")
    else:
        print("\n❌ LOCAL: User 67 not found")
    
    conn.close()
    
    # Check Supabase
    if supabase and local_user:
        print(f"\n🔍 Checking Supabase for user {local_user['email']}...")
        
        try:
            response = supabase.table('users')\
                .select('*')\
                .eq('email', local_user['email'])\
                .execute()
            
            if response.data:
                print(f"✅ SUPABASE: User exists (ID: {response.data[0]['user_id']})")
            else:
                print(f"❌ SUPABASE: User NOT found")
                print(f"\n📝 Creating user in Supabase...")
                
                # Create user
                new_user = {
                    'name': local_user['name'],
                    'email': local_user['email'],
                    'phone': local_user['phone'],
                    'gender': local_user.get('gender'),
                    'dob': local_user.get('dob'),
                }
                
                create_resp = supabase.table('users').insert(new_user).execute()
                
                if create_resp.data:
                    print(f"✅ User created with ID: {create_resp.data[0]['user_id']}")
                else:
                    print(f"❌ Failed to create user")
        
        except Exception as e:
            print(f"❌ Error: {e}")
    
    print("\n" + "="*60)
    print("💡 NEXT STEP: FIX FK CONSTRAINT")
    print("="*60)
    print("Run this SQL in Supabase SQL Editor:")
    print()
    print("-- Drop incorrect FK")
    print("ALTER TABLE occurrence_plan DROP CONSTRAINT IF EXISTS fk_occurrence_plan_medicine_plan;")
    print()
    print("-- Recreate correct FK")
    print("ALTER TABLE occurrence_plan ADD CONSTRAINT fk_occurrence_plan_medicine_plan")
    print("FOREIGN KEY (plan_id) REFERENCES medicine_plan(plan_id) ON DELETE CASCADE;")
    print("="*60)
