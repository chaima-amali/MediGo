"""
Medicine Reminder Scheduler
Checks for upcoming medicine occurrences and sends notifications
"""

from apscheduler.schedulers.background import BackgroundScheduler
from apscheduler.triggers.interval import IntervalTrigger
from datetime import datetime, timedelta
from app.supabase_client import supabase
from app.core.database import execute_query, execute_insert, execute_update
from app.services.notification_service import NotificationService


class ReminderScheduler:
    def __init__(self, app=None):
        self.scheduler = BackgroundScheduler()
        self.is_running = False
        self.app = app
    
    def start(self):
        """Start the reminder scheduler"""
        if self.is_running:
            return
        
        # Initialize Firebase
        NotificationService.initialize()
        
        # Check for reminders every minute
        self.scheduler.add_job(
            func=self.check_and_send_reminders,
            trigger=IntervalTrigger(minutes=1),
            id='medicine_reminder_job',
            name='Check and send medicine reminders',
            replace_existing=True,
        )
        
        self.scheduler.start()
        self.is_running = True
        print('✅ Reminder scheduler started')
    
    def stop(self):
        """Stop the reminder scheduler"""
        if self.scheduler.running:
            self.scheduler.shutdown()
            self.is_running = False
            print('⏹️  Reminder scheduler stopped')
    
    def check_and_send_reminders(self):
        """
        Check for medicine occurrences that are due soon
        and send notifications to users
        Sends 2 notifications per occurrence:
        1. One hour before the scheduled time
        2. At the exact scheduled time
        """
        try:
            print(f'🔍 Checking for medicine reminders at {datetime.now()}')
            
            # Get current time
            now = datetime.now()
            current_date = now.strftime('%Y-%m-%d')
            current_time = now.strftime('%H:%M')
            
            # Time window for "at time" notifications (current minute only)
            at_time_window = (now + timedelta(minutes=1)).strftime('%H:%M')
            
            # Time for "1 hour before" notifications
            one_hour_ahead = now + timedelta(hours=1)
            one_hour_date = one_hour_ahead.strftime('%Y-%m-%d')
            one_hour_time = one_hour_ahead.strftime('%H:%M')
            
            # Get all occurrences that need reminders
            reminders_to_send = []
            
            # Try Supabase first
            if supabase:
                try:
                    # Fetch occurrences for the dates then filter in Python to avoid string/format issues
                    at_time_response = supabase.table('occurrence_plan')\
                        .select('*, medicine_plan!inner(*, medicine_tracking!inner(*)), users:medicine_plan(user_id)')\
                        .eq('date', current_date)\
                        .eq('is_taken', 0)\
                        .execute()

                    one_hour_response = supabase.table('occurrence_plan')\
                        .select('*, medicine_plan!inner(*, medicine_tracking!inner(*)), users:medicine_plan(user_id)')\
                        .eq('date', one_hour_date)\
                        .eq('is_taken', 0)\
                        .execute()

                    # Post-filter occurrences into the exact windows
                    def _filter_window(data, target_time_str):
                        from datetime import datetime as _dt
                        out = []
                        if not data:
                            return out
                        for occ in data:
                            occ_date = occ.get('date')
                            occ_time = occ.get('time')
                            try:
                                # Parse and extract just HH:MM for comparison
                                try:
                                    occ_dt = _dt.strptime(f"{occ_date} {occ_time}", "%Y-%m-%d %H:%M")
                                except Exception:
                                    occ_dt = _dt.strptime(f"{occ_date} {occ_time}", "%Y-%m-%d %H:%M:%S")
                                
                                # Compare only hour and minute (ignore seconds)
                                if occ_dt.strftime('%H:%M') == target_time_str:
                                    out.append(occ)
                            except Exception:
                                continue
                        return out

                    # Check for exact current time match only
                    at_time_filtered = _filter_window(
                        at_time_response.data if at_time_response and getattr(at_time_response, 'data', None) else [], 
                        current_time
                    )

                    one_hour_dt = one_hour_ahead
                    one_hour_filtered = _filter_window(
                        one_hour_response.data if one_hour_response and getattr(one_hour_response, 'data', None) else [], 
                        one_hour_time
                    )
                    
                    # Process "at time" notifications (filtered)
                    if at_time_filtered:
                        for occ in at_time_filtered:
                            user_id = occ['medicine_plan']['user_id']
                            user_response = supabase.table('users')\
                                .select('fcm_token, notifications_enabled')\
                                .eq('user_id', user_id)\
                                .execute()
                            
                            if user_response.data:
                                user = user_response.data[0]
                                # Check if user has enabled notifications
                                if not user.get('notifications_enabled', True):
                                    continue
                                    
                                if user.get('fcm_token'):
                                    fcm_token = user['fcm_token']
                                    medicine = occ['medicine_plan']['medicine_tracking']
                                    
                                    # Check if "at_time" notification was already sent
                                    notification_check = supabase.table('notification')\
                                        .select('notification_id')\
                                        .eq('occurrence_id', occ['id'])\
                                        .eq('notification_type', 'at_time')\
                                        .eq('is_sent', 1)\
                                        .execute()
                                    
                                    if not notification_check.data:
                                        reminders_to_send.append({
                                            'fcm_token': fcm_token,
                                            'medicine_name': medicine['name'],
                                            'dosage': medicine.get('dosage', ''),
                                            'time': occ['time'],
                                            'occurrence_id': occ['id'],
                                            'plan_id': occ['plan_id'],
                                            'user_id': user_id,
                                            'notification_timing': 'at_time',
                                        })
                    
                    # Process "1 hour before" notifications (filtered)
                    if one_hour_filtered:
                        for occ in one_hour_filtered:
                            user_id = occ['medicine_plan']['user_id']
                            user_response = supabase.table('users')\
                                .select('fcm_token, notifications_enabled')\
                                .eq('user_id', user_id)\
                                .execute()
                            
                            if user_response.data:
                                user = user_response.data[0]
                                # Check if user has enabled notifications
                                if not user.get('notifications_enabled', True):
                                    continue
                                    
                                if user.get('fcm_token'):
                                    fcm_token = user['fcm_token']
                                    medicine = occ['medicine_plan']['medicine_tracking']
                                    
                                    # Check if "one_hour_before" notification was already sent
                                    notification_check = supabase.table('notification')\
                                        .select('notification_id')\
                                        .eq('occurrence_id', occ['id'])\
                                        .eq('notification_type', 'one_hour_before')\
                                        .eq('is_sent', 1)\
                                        .execute()
                                    
                                    if not notification_check.data:
                                        reminders_to_send.append({
                                            'fcm_token': fcm_token,
                                            'medicine_name': medicine['name'],
                                            'dosage': medicine.get('dosage', ''),
                                            'time': occ['time'],
                                            'occurrence_id': occ['id'],
                                            'plan_id': occ['plan_id'],
                                            'user_id': user_id,
                                            'notification_timing': 'one_hour_before',
                                        })
                    
                except Exception as e:
                    print(f'⚠️  Supabase query failed: {e}, trying local database')
            
            # Fallback to local database if Supabase failed or no data
            if not reminders_to_send:
                try:
                    # Wrap database query in Flask application context
                    if self.app:
                        with self.app.app_context():
                            # Query for "at time" notifications
                            at_time_query = """
                                SELECT 
                                    o.id as occurrence_id,
                                    o.plan_id,
                                    o.time,
                                    o.date,
                                    mt.name as medicine_name,
                                    mt.dosage,
                                    mp.user_id,
                                    u.fcm_token,
                                    u.notifications_enabled
                                FROM occurrence_plan o
                                JOIN medicine_plan mp ON o.plan_id = mp.plan_id
                                JOIN medicine_tracking mt ON mp.medicine_track_id = mt.medicine_track_id
                                JOIN users u ON mp.user_id = u.user_id
                                WHERE o.date = ?
                                AND o.is_taken = 0
                                AND o.time >= ?
                                AND o.time <= ?
                                AND u.fcm_token IS NOT NULL
                                AND (u.notifications_enabled IS NULL OR u.notifications_enabled = 1)
                                AND NOT EXISTS (
                                    SELECT 1 FROM notification n
                                    WHERE n.occurrence_id = o.id
                                    AND n.notification_type = 'at_time'
                                    AND n.is_sent = 1
                                )
                            """
                            
                            # Fetch candidate rows for today and post-filter in Python
                            candidate_rows = execute_query(
                                "SELECT o.id as occurrence_id, o.plan_id, o.time, o.date, mt.name as medicine_name, mt.dosage, mp.user_id, u.fcm_token, u.notifications_enabled "
                                "FROM occurrence_plan o JOIN medicine_plan mp ON o.plan_id = mp.plan_id JOIN medicine_tracking mt ON mp.medicine_track_id = mt.medicine_track_id JOIN users u ON mp.user_id = u.user_id "
                                "WHERE o.date = ? AND o.is_taken = 0 AND u.fcm_token IS NOT NULL AND (u.notifications_enabled IS NULL OR u.notifications_enabled = 1)",
                                (current_date,)
                            )

                            # Filter candidates for exact current time match only
                            from datetime import datetime as _dt
                            for row in candidate_rows:
                                try:
                                    try:
                                        occ_dt = _dt.strptime(f"{row['date']} {row['time']}", "%Y-%m-%d %H:%M")
                                    except Exception:
                                        occ_dt = _dt.strptime(f"{row['date']} {row['time']}", "%Y-%m-%d %H:%M:%S")
                                    
                                    # Check if time matches exactly (HH:MM)
                                    if occ_dt.strftime('%H:%M') == current_time:
                                        # Check if notification was already sent
                                        already_sent = execute_query(
                                            "SELECT 1 FROM notification WHERE occurrence_id = ? AND notification_type = 'at_time' AND is_sent = 1",
                                            (row['occurrence_id'],)
                                        )
                                        if not already_sent:
                                            reminders_to_send.append({
                                                'fcm_token': row['fcm_token'],
                                                'medicine_name': row['medicine_name'],
                                                'dosage': row['dosage'] or '',
                                                'time': row['time'],
                                                'occurrence_id': row['occurrence_id'],
                                                'plan_id': row['plan_id'],
                                                'user_id': row['user_id'],
                                                'notification_timing': 'at_time',
                                            })
                                except Exception as e:
                                    continue
                            
                            # Query for "1 hour before" notifications
                            one_hour_query = """
                                SELECT 
                                    o.id as occurrence_id,
                                    o.plan_id,
                                    o.time,
                                    o.date,
                                    mt.name as medicine_name,
                                    mt.dosage,
                                    mp.user_id,
                                    u.fcm_token,
                                    u.notifications_enabled
                                FROM occurrence_plan o
                                JOIN medicine_plan mp ON o.plan_id = mp.plan_id
                                JOIN medicine_tracking mt ON mp.medicine_track_id = mt.medicine_track_id
                                JOIN users u ON mp.user_id = u.user_id
                                WHERE o.date = ?
                                AND o.is_taken = 0
                                AND o.time = ?
                                AND u.fcm_token IS NOT NULL
                                AND (u.notifications_enabled IS NULL OR u.notifications_enabled = 1)
                                AND NOT EXISTS (
                                    SELECT 1 FROM notification n
                                    WHERE n.occurrence_id = o.id
                                    AND n.notification_type = 'one_hour_before'
                                    AND n.is_sent = 1
                                )
                            """
                            
                            # Fetch candidates for one-hour-before and filter
                            candidate_one_hour = execute_query(
                                "SELECT o.id as occurrence_id, o.plan_id, o.time, o.date, mt.name as medicine_name, mt.dosage, mp.user_id, u.fcm_token, u.notifications_enabled "
                                "FROM occurrence_plan o JOIN medicine_plan mp ON o.plan_id = mp.plan_id JOIN medicine_tracking mt ON mp.medicine_track_id = mt.medicine_track_id JOIN users u ON mp.user_id = u.user_id "
                                "WHERE o.date = ? AND o.is_taken = 0 AND u.fcm_token IS NOT NULL AND (u.notifications_enabled IS NULL OR u.notifications_enabled = 1)",
                                (one_hour_date,)
                            )

                            try:
                                for row in candidate_one_hour:
                                    try:
                                        try:
                                            occ_dt = _dt.strptime(f"{row['date']} {row['time']}", "%Y-%m-%d %H:%M")
                                        except Exception:
                                            occ_dt = _dt.strptime(f"{row['date']} {row['time']}", "%Y-%m-%d %H:%M:%S")
                                        
                                        # Check if time matches exactly (HH:MM)
                                        if occ_dt.strftime('%H:%M') == one_hour_time:
                                            # Check if notification was already sent
                                            already_sent = execute_query(
                                                "SELECT 1 FROM notification WHERE occurrence_id = ? AND notification_type = 'one_hour_before' AND is_sent = 1",
                                                (row['occurrence_id'],)
                                            )
                                            if not already_sent:
                                                reminders_to_send.append({
                                                    'fcm_token': row['fcm_token'],
                                                    'medicine_name': row['medicine_name'],
                                                    'dosage': row['dosage'] or '',
                                                    'time': row['time'],
                                                    'occurrence_id': row['occurrence_id'],
                                                    'plan_id': row['plan_id'],
                                                    'user_id': row['user_id'],
                                                    'notification_timing': 'one_hour_before',
                                                })
                                    except Exception:
                                        continue
                            except Exception:
                                pass
                
                except Exception as e:
                    print(f'❌ Local database query failed: {e}')
            
            # Send notifications
            if reminders_to_send:
                print(f'📤 Sending {len(reminders_to_send)} medicine reminders')
                
                success_count = 0
                failed_count = 0
                invalid_tokens = []
                
                for reminder in reminders_to_send:
                    notification_timing = reminder.get('notification_timing', 'at_time')
                    user_id = reminder.get('user_id')
                    fcm_token = reminder['fcm_token']
                    
                    success = NotificationService.send_medicine_reminder(
                        fcm_token=fcm_token,
                        medicine_name=reminder['medicine_name'],
                        dosage=reminder['dosage'],
                        time=reminder['time'],
                        occurrence_id=reminder['occurrence_id'],
                        plan_id=reminder['plan_id'],
                        notification_timing=notification_timing,
                    )
                    
                    if success:
                        success_count += 1
                        # Record notification in database
                        self._record_notification(reminder, notification_timing)
                    else:
                        failed_count += 1
                        # Track invalid token for cleanup
                        invalid_tokens.append((user_id, fcm_token))
                
                print(f'📊 Notification results: {success_count} sent, {failed_count} failed')
                
                # Clean up invalid tokens
                if invalid_tokens:
                    print(f'🧹 Cleaning up {len(invalid_tokens)} invalid FCM tokens')
                    self._cleanup_invalid_tokens(invalid_tokens)
            else:
                print('✓ No reminders to send at this time')
        
        except Exception as e:
            print(f'❌ Error in reminder check: {e}')
    
    def _record_notification(self, reminder: dict, notification_timing: str = 'at_time'):
        """Record that a notification was sent"""
        try:
            notification_data = {
                'occurrence_id': reminder['occurrence_id'],
                'sent_at': datetime.now().isoformat(),
                'is_sent': 1,
                'notification_type': notification_timing,  # 'at_time' or 'one_hour_before'
            }
            
            # Try Supabase first
            if supabase:
                try:
                    supabase.table('notification').insert(notification_data).execute()
                    # Also create a medication_intake_log placeholder for this occurrence
                    try:
                        occ_resp = supabase.table('occurrence_plan').select('*').eq('id', reminder['occurrence_id']).execute()
                        if occ_resp.data and len(occ_resp.data) > 0:
                            occ = occ_resp.data[0]
                            plan_id = occ.get('plan_id')
                            scheduled_date = occ.get('date')
                            scheduled_time = occ.get('time')

                            # get medicine_track_id from medicine_plan
                            mp_resp = supabase.table('medicine_plan').select('medicine_track_id').eq('plan_id', plan_id).execute()
                            medicine_track_id = None
                            if mp_resp.data and len(mp_resp.data) > 0:
                                medicine_track_id = mp_resp.data[0].get('medicine_track_id')

                            dosage = None
                            if medicine_track_id:
                                mt_resp = supabase.table('medicine_tracking').select('dosage').eq('medicine_track_id', medicine_track_id).execute()
                                if mt_resp.data and len(mt_resp.data) > 0:
                                    dosage = mt_resp.data[0].get('dosage')

                            new_log = {
                                'occurrence_id': reminder['occurrence_id'],
                                'medicine_track_id': medicine_track_id,
                                'scheduled_date': scheduled_date,
                                'scheduled_time': scheduled_time,
                                'actual_time': None,
                                'status': 'reminder_sent',
                                'dosage': dosage,
                                'notes': 'Reminder sent by scheduler'
                            }
                            try:
                                supabase.table('medication_intake_log').insert(new_log).execute()
                            except Exception:
                                print('⚠️  Failed to create medication_intake_log in Supabase (continuing)')
                    except Exception:
                        print('⚠️  Failed to fetch occurrence/plan for intake log creation (continuing)')
                    return
                except Exception as e:
                    print(f'⚠️  Failed to record notification in Supabase: {e}')
            
            # Fallback to local
            if self.app:
                with self.app.app_context():
                    query = """
                        INSERT INTO notification (occurrence_id, sent_at, is_sent, notification_type)
                        VALUES (?, ?, ?, ?)
                    """
                    execute_query(
                        query,
                        (
                            reminder['occurrence_id'],
                            notification_data['sent_at'],
                            1,
                            'medicine_reminder',
                        ),
                    )
                    # Also insert a local medication_intake_log placeholder
                    try:
                        # Fetch occurrence and related plan/medicine locally
                        occ_rows = execute_query(
                            "SELECT o.id as occurrence_id, o.plan_id, o.date as scheduled_date, o.time as scheduled_time, mp.medicine_track_id "
                            "FROM occurrence_plan o JOIN medicine_plan mp ON o.plan_id = mp.plan_id WHERE o.id = ?",
                            (reminder['occurrence_id'],)
                        )
                        if occ_rows and len(occ_rows) > 0:
                            r = occ_rows[0]
                            execute_insert(
                                """
                                INSERT INTO medication_intake_log (occurrence_id, medicine_track_id, scheduled_date, scheduled_time, actual_time, status, dosage, notes)
                                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                                """,
                                (
                                    r['occurrence_id'],
                                    r.get('medicine_track_id'),
                                    r.get('scheduled_date'),
                                    r.get('scheduled_time'),
                                    None,
                                    'reminder_sent',
                                    None,
                                    'Reminder sent by scheduler',
                                ),
                            )
                    except Exception:
                        print('⚠️  Failed to create local medication_intake_log (continuing)')
        
        except Exception as e:
            print(f'❌ Failed to record notification: {e}')
    
    def _cleanup_invalid_tokens(self, invalid_tokens: list):
        """Remove invalid FCM tokens from the database"""
        try:
            for user_id, token in invalid_tokens:
                # Try Supabase first
                if supabase:
                    try:
                        supabase.table('users')\
                            .update({'fcm_token': None})\
                            .eq('user_id', user_id)\
                            .execute()
                        print(f'  ✓ Cleared invalid token for user {user_id}')
                    except Exception as e:
                        print(f'  ⚠️  Failed to clear token for user {user_id}: {e}')
                
                # Fallback to local
                if self.app:
                    with self.app.app_context():
                        try:
                            execute_update(
                                "UPDATE users SET fcm_token = NULL WHERE user_id = ?",
                                (user_id,)
                            )
                        except Exception:
                            pass
        except Exception as e:
            print(f'❌ Failed to cleanup invalid tokens: {e}')


# Global scheduler instance
scheduler = ReminderScheduler()
