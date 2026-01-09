# Notification System Updates

## What Was Changed

### 1. **Notification Timing - Now Sends Only Twice**

- **Before**: Notifications sent every minute for 5-minute window
- **After**: Notifications sent exactly **twice per medicine**:
  - ⏰ **1 hour before** the scheduled time
  - 💊 **At the exact** scheduled time

### 2. **User Permission Check**

- Backend now checks if user has enabled notifications before sending
- If user disabled notifications in profile, they won't receive any push notifications

### 3. **New Profile Setting**

- Toggle in Profile page to enable/disable notifications
- Syncs with backend immediately when toggled

## Files Modified

### Backend

1. **`reminder_scheduler.py`** - Updated scheduler logic:

   - Checks for two time windows: 1 hour before and at time
   - Prevents duplicate notifications by checking notification type
   - Verifies user's notification preference before sending

2. **`notification_service.py`** - Enhanced notifications:

   - Different messages for "1 hour before" vs "at time" notifications
   - Passes notification timing type to backend

3. **`users.py` (routes)** - New API endpoint:

   - `PUT /users/{user_id}/notification-preference`
   - Allows frontend to update user's notification settings

4. **Database Schema Updates**:

   - `supabase_schema.sql` - Added `notifications_enabled BOOLEAN` column
   - `init_local_db.py` - Added `notifications_enabled INTEGER` column

5. **Migration Script**: `migrate_add_notifications_enabled.py`

### Frontend

1. **`user_api_service.dart`** - New method:

   - `updateNotificationPreference(userId, enabled)`

2. **`api_service.dart`** - Wrapper method added

3. **`profile_page.dart`** - Enhanced notification toggle:
   - Calls backend API when switch is toggled
   - Shows error if update fails
   - Reverts switch on failure

## Setup Instructions

### Step 1: Run Local Database Migration

```bash
cd backend
python migrate_add_notifications_enabled.py
```

### Step 2: Run Supabase Migration

Go to your Supabase SQL Editor and run:

```sql
-- Add notifications_enabled column
ALTER TABLE users
ADD COLUMN IF NOT EXISTS notifications_enabled BOOLEAN DEFAULT true;

-- Set existing users to have notifications enabled
UPDATE users
SET notifications_enabled = true
WHERE notifications_enabled IS NULL;
```

### Step 3: Restart Backend

```bash
cd backend
python main.py
```

The scheduler will automatically use the new notification logic.

### Step 4: Test the System

#### Test 1: One Hour Before Notification

1. Add a medicine with time **1 hour from now** (e.g., if it's 20:00, set time to 21:00)
2. Wait 1 minute
3. You should receive notification: "⏰ **Medicine** is due in 1 hour at 21:00"

#### Test 2: At Time Notification

1. Add a medicine with time **2-3 minutes from now**
2. Wait until that time
3. You should receive notification: "💊 Time to take **Medicine** at 20:03"

#### Test 3: Disable Notifications

1. Go to Profile → Toggle "Notifications" OFF
2. Add a medicine
3. You should **NOT** receive any notifications
4. Toggle notifications back ON to re-enable

## How It Works

### Notification Flow

```
Every Minute:
├── Scheduler checks for occurrences
│
├── Check 1: Occurrences in next 2 minutes (at_time)
│   ├── Get user's FCM token
│   ├── Check if notifications_enabled = true
│   ├── Check if "at_time" notification already sent
│   └── Send notification if all checks pass
│
└── Check 2: Occurrences exactly 1 hour ahead (one_hour_before)
    ├── Get user's FCM token
    ├── Check if notifications_enabled = true
    ├── Check if "one_hour_before" notification already sent
    └── Send notification if all checks pass
```

### Duplicate Prevention

- Each occurrence can have up to 2 notifications in the database:
  - `notification_type = 'one_hour_before'`
  - `notification_type = 'at_time'`
- Scheduler checks both types separately to prevent re-sending

### User Control

- Users can toggle notifications ON/OFF in Profile
- Backend stores preference in `users.notifications_enabled`
- Scheduler respects this setting - no notifications sent if disabled

## Troubleshooting

### "Still receiving notifications every minute"

- Backend might not have restarted - stop and restart `main.py`
- Check if notification records exist in database
- Run: `SELECT * FROM notification WHERE occurrence_id = X;`

### "Not receiving any notifications"

- Check notification toggle is ON in Profile
- Verify FCM token exists: `SELECT fcm_token FROM users WHERE user_id = X;`
- Check backend logs for "📤 Sending X medicine reminders"
- Ensure medicine time is either in next 2 minutes OR exactly 1 hour ahead

### "Only receiving one notification instead of two"

- This is expected if you add medicine close to its time
- For 1 hour before notification, medicine must be added at least 1 hour in advance
- For at-time notification, medicine must be within 2 minutes of current time

## Next Steps

After migration:

1. ✅ Test with medicine 1 hour ahead
2. ✅ Test with medicine in 2 minutes
3. ✅ Toggle notifications OFF and verify no push received
4. ✅ Toggle notifications ON and verify push received
5. ✅ Check notification page syncs with sent notifications

If all tests pass, your notification system is working perfectly! 🎉
