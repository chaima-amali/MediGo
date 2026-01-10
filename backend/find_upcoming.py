"""Find occurrences for users with FCM tokens in the next 10 minutes"""
from app import create_app
from app.supabase_client import supabase
from datetime import datetime, timedelta

app = create_app()

with app.app_context():
    now = datetime.now()
    window_end = now + timedelta(minutes=10)
    
    print("\n" + "="*60)
    print("🔍 SEARCHING FOR UPCOMING OCCURRENCES")
    print("="*60)
    print(f"\n⏰ Current time: {now.strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"🎯 Looking for occurrences between now and {window_end.strftime('%H:%M')}")
    print("\n" + "="*60)
    
    if supabase:
        try:
            # Get today's occurrences
            current_date = now.strftime('%Y-%m-%d')
            response = supabase.table('occurrence_plan')\
                .select('*, medicine_plan!inner(user_id, medicine_tracking(name))')\
                .eq('date', current_date)\
                .eq('is_taken', 0)\
                .execute()
            
            if response.data:
                # Filter for next 10 minutes
                upcoming = []
                for occ in response.data:
                    try:
                        occ_dt = datetime.strptime(f"{occ['date']} {occ['time']}", "%Y-%m-%d %H:%M")
                        if now <= occ_dt <= window_end:
                            upcoming.append((occ_dt, occ))
                    except Exception:
                        pass
                
                if upcoming:
                    upcoming.sort(key=lambda x: x[0])
                    print(f"\n✅ Found {len(upcoming)} upcoming occurrence(s):\n")
                    
                    for occ_dt, occ in upcoming:
                        user_id = occ['medicine_plan']['user_id']
                        med_name = occ['medicine_plan']['medicine_tracking']['name']
                        
                        # Check user's FCM token
                        user_resp = supabase.table('users')\
                            .select('name, email, fcm_token, notifications_enabled')\
                            .eq('user_id', user_id)\
                            .execute()
                        
                        has_token = False
                        user_name = f"User {user_id}"
                        user_email = ""
                        enabled = True
                        
                        if user_resp.data:
                            user_data = user_resp.data[0]
                            has_token = user_data.get('fcm_token') is not None
                            user_name = user_data.get('name') or f"User {user_id}"
                            user_email = user_data.get('email') or ""
                            enabled = user_data.get('notifications_enabled', True)
                        
                        time_diff = (occ_dt - now).total_seconds() / 60
                        
                        print(f"📅 {occ_dt.strftime('%H:%M')} ({time_diff:.1f} min from now)")
                        print(f"   Medicine: {med_name}")
                        print(f"   User: {user_name} ({user_email})")
                        print(f"   User ID: {user_id}")
                        print(f"   FCM Token: {'✅ Present' if has_token else '❌ MISSING'}")
                        print(f"   Notifications: {'✅ Enabled' if enabled else '❌ DISABLED'}")
                        print(f"   Will send: {'✅ YES' if (has_token and enabled) else '❌ NO'}")
                        print()
                else:
                    print(f"\n❌ No occurrences in the next 10 minutes")
                    print(f"\n💡 Create a medicine with time: {(now + timedelta(minutes=2)).strftime('%H:%M')}")
            else:
                print(f"\n❌ No occurrences found on {current_date}")
        
        except Exception as e:
            print(f"\n❌ Error: {e}")
            import traceback
            traceback.print_exc()
    
    print("="*60)
