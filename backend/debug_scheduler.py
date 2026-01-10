"""Debug the scheduler to see what it's finding"""
from app import create_app
from app.supabase_client import supabase
from datetime import datetime, timedelta

app = create_app()

with app.app_context():
    now = datetime.now()
    print(f"\n⏰ Current time: {now.strftime('%Y-%m-%d %H:%M:%S')}")
    print("="*60)
    
    # Calculate windows
    current_date = now.strftime('%Y-%m-%d')
    current_time = now.strftime('%H:%M')
    window_end = (now + timedelta(minutes=2)).strftime('%H:%M')
    one_hour_ahead = now + timedelta(hours=1)
    one_hour_date = one_hour_ahead.strftime('%Y-%m-%d')
    one_hour_time = one_hour_ahead.strftime('%H:%M')
    
    print(f"\n🎯 Scheduler windows:")
    print(f"   'At time' window: {current_date} {current_time} to {window_end}")
    print(f"   '1 hour before' check: {one_hour_date} {one_hour_time}")
    print("="*60)
    
    if supabase:
        try:
            # Check today's occurrences
            print(f"\n📅 Checking Supabase for occurrences on {current_date}...")
            response = supabase.table('occurrence_plan')\
                .select('*, medicine_plan!inner(user_id, medicine_tracking(name))')\
                .eq('date', current_date)\
                .eq('is_taken', 0)\
                .execute()
            
            print(f"   Found {len(response.data) if response.data else 0} occurrences on {current_date}")
            
            if response.data:
                print("\n   Details:")
                for occ in response.data[:5]:  # Show first 5
                    med_name = occ.get('medicine_plan', {}).get('medicine_tracking', {}).get('name', 'Unknown')
                    print(f"     • {occ['time']} - {med_name} (ID: {occ['id']}, Plan: {occ['plan_id']})")
                
                # Filter for the actual window
                from datetime import datetime as _dt
                window_start = now
                window_end_dt = now + timedelta(minutes=2)
                filtered = []
                
                for occ in response.data:
                    try:
                        occ_dt = _dt.strptime(f"{occ['date']} {occ['time']}", "%Y-%m-%d %H:%M")
                        if window_start <= occ_dt <= window_end_dt:
                            filtered.append(occ)
                    except Exception:
                        pass
                
                print(f"\n   ✅ {len(filtered)} occurrence(s) within the 2-minute window")
                if filtered:
                    for occ in filtered:
                        med_name = occ.get('medicine_plan', {}).get('medicine_tracking', {}).get('name', 'Unknown')
                        user_id = occ.get('medicine_plan', {}).get('user_id')
                        print(f"     → {occ['time']} - {med_name} (User: {user_id})")
                        
                        # Check if user has FCM token
                        user_resp = supabase.table('users')\
                            .select('fcm_token, notifications_enabled')\
                            .eq('user_id', user_id)\
                            .execute()
                        
                        if user_resp.data:
                            has_token = user_resp.data[0].get('fcm_token') is not None
                            enabled = user_resp.data[0].get('notifications_enabled', True)
                            print(f"        FCM token: {'✅' if has_token else '❌'}")
                            print(f"        Notifications enabled: {'✅' if enabled else '❌'}")
                            if has_token:
                                token = user_resp.data[0].get('fcm_token')
                                print(f"        Token: {token[:40]}...")
            else:
                print(f"\n   ❌ No occurrences found on {current_date}")
                print(f"\n   💡 Your occurrences are scheduled for future dates.")
                print(f"      To test notifications, create a medicine with time:")
                print(f"      → {(now + timedelta(minutes=1)).strftime('%H:%M')} (1 minute from now)")
        
        except Exception as e:
            print(f"\n❌ Error: {e}")
            import traceback
            traceback.print_exc()
    
    print("\n" + "="*60)
