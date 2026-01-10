"""Check if recent medicines have plans and occurrences"""
from app import create_app
from app.supabase_client import supabase

app = create_app()

with app.app_context():
    if supabase:
        print("\n" + "="*80)
        print("🔍 CHECKING RECENT MEDICINES → PLANS → OCCURRENCES")
        print("="*80)
        
        try:
            # Get the 5 most recent medicines
            med_response = supabase.table('medicine_tracking')\
                .select('medicine_track_id, user_id, name, created_at')\
                .order('created_at', desc=True)\
                .limit(5)\
                .execute()
            
            if med_response.data:
                for med in med_response.data:
                    med_id = med['medicine_track_id']
                    name = med['name']
                    user_id = med['user_id']
                    created = med['created_at'][:19]
                    
                    print(f"\n📦 Medicine: {name} (ID: {med_id}, User: {user_id})")
                    print(f"   Created: {created}")
                    print("-" * 80)
                    
                    # Check for plans
                    plan_response = supabase.table('medicine_plan')\
                        .select('plan_id, start_date, end_date, frequency_type')\
                        .eq('medicine_track_id', med_id)\
                        .execute()
                    
                    if plan_response.data and len(plan_response.data) > 0:
                        print(f"   ✅ Has {len(plan_response.data)} plan(s):")
                        
                        for plan in plan_response.data:
                            plan_id = plan['plan_id']
                            freq = plan['frequency_type']
                            start = plan['start_date']
                            end = plan.get('end_date', 'ongoing')
                            
                            print(f"      Plan {plan_id}: {freq} from {start} to {end}")
                            
                            # Check for occurrences
                            occ_response = supabase.table('occurrence_plan')\
                                .select('id, date, time')\
                                .eq('plan_id', plan_id)\
                                .order('date')\
                                .limit(5)\
                                .execute()
                            
                            if occ_response.data:
                                print(f"         ✅ {len(occ_response.data)} occurrence(s) (showing first 5):")
                                for occ in occ_response.data[:3]:
                                    print(f"            • {occ['date']} at {occ['time']} (ID: {occ['id']})")
                            else:
                                print(f"         ❌ NO occurrences created")
                    else:
                        print(f"   ❌ NO PLANS created for this medicine")
                        print(f"      → User created medicine but didn't set up a schedule")
                
            # Check today's occurrences specifically
            print("\n" + "="*80)
            print("📅 TODAY'S OCCURRENCES (2026-01-10)")
            print("="*80)
            
            today_response = supabase.table('occurrence_plan')\
                .select('id, plan_id, time, is_taken')\
                .eq('date', '2026-01-10')\
                .order('time')\
                .limit(10)\
                .execute()
            
            if today_response.data:
                print(f"\n✅ Found {len(today_response.data)} occurrence(s) for today:")
                for occ in today_response.data:
                    print(f"   • {occ['time']} - Plan {occ['plan_id']} (ID: {occ['id']}, Taken: {occ['is_taken']})")
            else:
                print("\n❌ No occurrences scheduled for today (2026-01-10)")
                print("\n💡 To test notifications, create a medicine with:")
                print("   Date: 2026-01-10")
                from datetime import datetime, timedelta
                now = datetime.now()
                test_time = (now + timedelta(minutes=2)).strftime('%H:%M')
                print(f"   Time: {test_time} (2 minutes from now)")
                
        except Exception as e:
            print(f"\n❌ Error: {e}")
            import traceback
            traceback.print_exc()
    
    print("\n" + "="*80)
