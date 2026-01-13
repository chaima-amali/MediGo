"""
Background job for sending reservation reminder notifications
Runs periodically to check upcoming reservations and notify premium users
"""

import sys
from datetime import datetime, timedelta
from app.supabase_client import supabase


def check_and_send_reservation_reminders():
    """
    Check for upcoming reservations and send reminder notifications
    - Runs every 30 minutes
    - Checks for reservations 1 day or 1 hour before the scheduled time
    - Only sends to premium users
    - Only for pending reservations (not confirmed yet)
    """
    try:
        print("🔔 Running reservation reminder job...", flush=True)
        sys.stdout.flush()
        
        if not supabase:
            print("⚠️  Supabase not configured, skipping reminder job", flush=True)
            return
        
        # Get current time
        now = datetime.now()
        
        # Calculate time windows
        one_day_from_now = now + timedelta(days=1)
        one_hour_from_now = now + timedelta(hours=1)
        
        # Format for comparison
        one_day_date = one_day_from_now.strftime('%Y-%m-%d')
        one_day_time = one_day_from_now.strftime('%H:%M')
        one_hour_date = one_hour_from_now.strftime('%Y-%m-%d')
        one_hour_time = one_hour_from_now.strftime('%H:%M')
        
        print(f"📅 Checking for reservations at {one_day_date} {one_day_time} (1 day) and {one_hour_date} {one_hour_time} (1 hour)")
        
        # Get all pending reservations with user premium status
        # Query reservations and join with users table
        try:
            reservations_response = supabase.table('reservation')\
                .select('*, users!reservation_user_id_fkey(user_id, premium)')\
                .eq('status', 'pending')\
                .execute()
        except Exception as query_error:
            print(f"⚠️  First query attempt failed, trying alternative: {query_error}")
            # Try without explicit foreign key name
            try:
                reservations_response = supabase.table('reservation')\
                    .select('*')\
                    .eq('status', 'pending')\
                    .execute()
                
                # Manually fetch user data for each reservation
                if reservations_response.data:
                    for reservation in reservations_response.data:
                        user_response = supabase.table('users')\
                            .select('user_id, premium')\
                            .eq('user_id', reservation['user_id'])\
                            .execute()
                        if user_response.data:
                            reservation['users'] = user_response.data[0]
            except Exception as fallback_error:
                print(f"❌ Fallback query also failed: {fallback_error}")
                return
        
        if not reservations_response.data:
            print("✅ No pending reservations found")
            return
        
        print(f"📋 Found {len(reservations_response.data)} pending reservations")
        
        notifications_created = 0
        
        for reservation in reservations_response.data:
            print(f"\n🔍 Processing reservation {reservation.get('reservation_id')}")
            print(f"   User ID: {reservation.get('user_id')}")
            print(f"   Medicine: {reservation.get('medicine_name')}")
            print(f"   Date: {reservation.get('day')} at {reservation.get('time')}")
            
            # Skip non-premium users
            user_data = reservation.get('users', {})
            if not user_data:
                print(f"   ⚠️  No user data found, skipping")
                continue
                
            is_premium = user_data.get('premium', False)
            print(f"   Premium status: {is_premium}")
            
            if not is_premium:
                print(f"   ⏭️  User is not premium, skipping")
                continue
            
            user_id = reservation['user_id']
            reservation_id = reservation['reservation_id']
            medicine_name = reservation.get('medicine_name', 'your medicine')
            reservation_date = reservation['day']
            reservation_time = reservation['time']
            
            # Parse reservation datetime
            try:
                # Try AM/PM format first (e.g., "2:00 AM", "12:33 PM")
                try:
                    reservation_datetime = datetime.strptime(
                        f"{reservation_date} {reservation_time}",
                        '%Y-%m-%d %I:%M %p'
                    )
                except ValueError:
                    # Fallback to 24-hour format (e.g., "14:30", "02:00")
                    reservation_datetime = datetime.strptime(
                        f"{reservation_date} {reservation_time}",
                        '%Y-%m-%d %H:%M'
                    )
            except Exception as parse_error:
                print(f"⚠️  Could not parse datetime for reservation {reservation_id}: {parse_error}")
                continue
            
            # Calculate time difference
            time_diff = reservation_datetime - now
            hours_until = time_diff.total_seconds() / 3600
            
            print(f"   ⏱️  Time until reservation: {hours_until:.2f} hours")
            
            notification_type = None
            notification_message = None
            
            # Check if within 1 day window (23-25 hours)
            if 23 <= hours_until <= 25:
                notification_type = 'reservation_reminder_1day'
                notification_message = f"Reminder: Your reservation for {medicine_name} is tomorrow at {reservation_time}"
                print(f"   ✅ Matches 1-day reminder window")
            # Check if within 1 hour window (0.5-1.5 hours)
            elif 0.5 <= hours_until <= 1.5:
                notification_type = 'reservation_reminder_1hour'
                notification_message = f"Reminder: Your reservation for {medicine_name} is in 1 hour at {reservation_time}"
                print(f"   ✅ Matches 1-hour reminder window")
            else:
                print(f"   ⏭️  Not within reminder window (needs 0.5-1.5h or 23-25h)")
                continue
            
            if notification_type and notification_message:
                # Check if notification already sent
                existing_notification = supabase.table('notification')\
                    .select('notification_id')\
                    .eq('reservation_id', reservation_id)\
                    .eq('type', notification_type)\
                    .execute()
                
                if existing_notification.data and len(existing_notification.data) > 0:
                    print(f"⏭️  Notification already sent for reservation {reservation_id}")
                    continue
                
                # Create notification
                notification_data = {
                    'user_id': user_id,
                    'reservation_id': reservation_id,
                    'datetime': now.isoformat(),
                    'title': 'Reservation Reminder',
                    'message': notification_message,
                    'type': notification_type,
                    'is_read': 0
                }
                
                try:
                    supabase.table('notification').insert(notification_data).execute()
                    notifications_created += 1
                    print(f"✅ Created {notification_type} notification for user {user_id}, reservation {reservation_id}")
                except Exception as insert_error:
                    print(f"❌ Failed to create notification: {insert_error}")
        
        print(f"🎉 Reminder job completed: {notifications_created} notifications created")
        
    except Exception as e:
        print(f"❌ Error in reservation reminder job: {e}")
        import traceback
        traceback.print_exc()


if __name__ == "__main__":
    # For testing purposes
    check_and_send_reservation_reminders()
