"""Check all medicines in Supabase with user details"""
from app import create_app
from app.supabase_client import supabase

app = create_app()

with app.app_context():
    if supabase:
        print("\n" + "="*80)
        print("🌐 ALL MEDICINES IN SUPABASE")
        print("="*80)
        
        try:
            # Get all medicines with user info
            response = supabase.table('medicine_tracking')\
                .select('medicine_track_id, user_id, name, type, dosage, created_at')\
                .order('created_at', desc=True)\
                .limit(20)\
                .execute()
            
            if response.data:
                print(f"\n✅ Found {len(response.data)} recent medicines:\n")
                print(f"{'ID':<6} {'User':<6} {'Name':<20} {'Type':<12} {'Dosage':<8} {'Created'}")
                print("-" * 80)
                
                for med in response.data:
                    med_id = med['medicine_track_id']
                    user_id = med['user_id']
                    name = med['name'][:18]
                    med_type = med.get('type', 'N/A')[:10]
                    dosage = med.get('dosage', 'N/A')[:6]
                    created = med['created_at'][:19] if med.get('created_at') else 'N/A'
                    
                    print(f"{med_id:<6} {user_id:<6} {name:<20} {med_type:<12} {dosage:<8} {created}")
                
                # Get count of all medicines
                count_response = supabase.table('medicine_tracking')\
                    .select('medicine_track_id', count='exact')\
                    .execute()
                
                total = count_response.count if hasattr(count_response, 'count') else len(response.data)
                print(f"\n📊 Total medicines in Supabase: {total}")
                
                # Check user 57 specifically (the one visible in screenshot)
                print("\n" + "="*80)
                print("🔍 CHECKING USER 57 (from screenshot)")
                print("="*80)
                
                user_57_response = supabase.table('medicine_tracking')\
                    .select('*')\
                    .eq('user_id', 57)\
                    .execute()
                
                if user_57_response.data:
                    print(f"\n✅ User 57 has {len(user_57_response.data)} medicine(s):")
                    for med in user_57_response.data:
                        print(f"  • {med['name']} (ID: {med['medicine_track_id']})")
                else:
                    print("\n❌ User 57 has no medicines")
                
            else:
                print("\n❌ No medicines found in Supabase")
                
        except Exception as e:
            print(f"\n❌ Error: {e}")
            import traceback
            traceback.print_exc()
    
    print("\n" + "="*80)
    print("💡 IN YOUR SUPABASE DASHBOARD:")
    print("="*80)
    print("1. Click on 'Filtered by 1 rule' at the top")
    print("2. Remove the filter or click 'Clear filters'")
    print("3. You should see ALL medicines (not just user 57)")
    print("="*80)
