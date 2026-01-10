"""
Quick check for notification system
"""
from app import create_app
from app.core.database import execute_query
from app.supabase_client import supabase
from datetime import datetime, timedelta

# Create Flask app context
app = create_app()

with app.app_context():
    now = datetime.now()
    current_date = now.strftime('%Y-%m-%d')
    current_time = now.strftime('%H:%M')
    reminder_time = (now + timedelta(minutes=5)).strftime('%H:%M')

    print(f"\n⏰ Current time: {now.strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"📅 Checking for occurrences from {current_time} to {reminder_time}")

    # Check Supabase
    if supabase:
        try:
            print("\n🌐 Checking Supabase...")
            # Fetch occurrences for the date from Supabase, then filter by exact datetimes
            response = supabase.table('occurrence_plan')\
                .select('*, medicine_plan!inner(*, medicine_tracking!inner(*)), users:medicine_plan(user_id)')\
                .eq('date', current_date)\
                .eq('is_taken', 0)\
                .execute()

            print(f"Found {len(response.data) if response.data else 0} occurrences in Supabase (raw)")

            # Filter occurrences by datetime window to avoid string comparison issues
            filtered = []
            try:
                from datetime import datetime as _dt
                window_start = now
                window_end = now + timedelta(minutes=5)
                if response.data:
                    for occ in response.data:
                        occ_date = occ.get('date')
                        occ_time = occ.get('time')
                        try:
                            occ_dt = _dt.strptime(f"{occ_date} {occ_time}", "%Y-%m-%d %H:%M")
                        except Exception:
                            # try seconds format
                            try:
                                occ_dt = _dt.strptime(f"{occ_date} {occ_time}", "%Y-%m-%d %H:%M:%S")
                            except Exception:
                                continue
                        if window_start <= occ_dt <= window_end:
                            filtered.append(occ)

                print(f"Filtered {len(filtered)} occurrences in Supabase within window")

                if filtered:
                    for occ in filtered:
                        user_id = occ['medicine_plan']['user_id']
                        medicine_name = occ['medicine_plan']['medicine_tracking']['name']
                        time = occ['time']
                        # Check if user has FCM token
                        user_resp = supabase.table('users').select('user_id, name, fcm_token').eq('user_id', user_id).execute()
                        has_token = user_resp.data[0].get('fcm_token') if user_resp.data else None
                        print(f"  ✓ {time}: {medicine_name} for user {user_id}")
                        print(f"    FCM Token: {'✅ YES' if has_token else '❌ NO'}")
                        if has_token:
                            print(f"    Token preview: {has_token[:30]}...")
            except Exception as e:
                print(f"⚠️  Supabase post-filter error: {e}")
                        
        except Exception as e:
            print(f"❌ Supabase error: {e}")

    # Check local DB
    print("\n💾 Checking local database...")
    query = """
        SELECT 
            o.id, o.time, o.date, o.is_taken,
            mt.name as medicine_name,
            u.user_id, u.name as user_name, u.fcm_token
        FROM occurrence_plan o
        JOIN medicine_plan mp ON o.plan_id = mp.plan_id
        JOIN medicine_tracking mt ON mp.medicine_track_id = mt.medicine_track_id
        JOIN users u ON mp.user_id = u.user_id
        WHERE o.date = ?
        AND o.is_taken = 0
        AND o.time >= ?
        AND o.time <= ?
    """

    rows = execute_query(query, (current_date, current_time, reminder_time))
    print(f"Found {len(rows)} occurrences in local DB (raw)")

    # Also filter local rows by exact datetime window to avoid format mismatches
    try:
        from datetime import datetime as _dt
        window_start = now
        window_end = now + timedelta(minutes=5)
        filtered_local = []
        for row in rows:
            try:
                occ_dt = _dt.strptime(f"{row['date']} {row['time']}", "%Y-%m-%d %H:%M")
            except Exception:
                try:
                    occ_dt = _dt.strptime(f"{row['date']} {row['time']}", "%Y-%m-%d %H:%M:%S")
                except Exception:
                    continue
            if window_start <= occ_dt <= window_end:
                filtered_local.append(row)

        print(f"Filtered {len(filtered_local)} occurrences in local DB within window")
        if filtered_local:
            for row in filtered_local:
                has_token = row['fcm_token'] is not None
                print(f"  ✓ {row['time']}: {row['medicine_name']} for user {row['user_id']} ({row['user_name']})")
                print(f"    FCM Token: {'✅ YES' if has_token else '❌ NO'}")
                if has_token:
                    print(f"    Token preview: {row['fcm_token'][:30]}...")
    except Exception as e:
        print(f"⚠️ Local post-filter error: {e}")

    print("\n" + "="*60)
    print("💡 DIAGNOSIS:")
    if (response.data if 'response' in dir() and response.data else False) or rows:
        print("✅ Occurrences found - scheduler should send notifications")
        print("\n📋 Next steps:")
        print("1. Check backend terminal logs for notification sending")
        print("2. Look for messages like: '📤 Sending X medicine reminders'")
        print("3. If you see errors, check Firebase service account file")
    else:
        print("❌ No occurrences found in the 5-minute window")
    print("\n📋 To test:")
    print("1. Add a medicine with time in the next 1-5 minutes")
    print("2. Don't mark it as taken")
    print("3. Wait for the notification")
print("="*60)
