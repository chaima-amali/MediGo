## Quick Notification Troubleshooting Guide

### Issue: Reservation notifications not showing in app

### ✅ What We Fixed:

1. **Extended notification grouping** - Added "Earlier" group for notifications older than 2 days
2. **Added debug logging** - Track notification fetching in console

### 🔍 Debugging Steps:

#### 1. Check Backend API (Working ✅)
```powershell
# Test API endpoint
$data = Invoke-WebRequest "http://172.20.10.4:5000/api/notifications/26" -UseBasicParsing | ConvertFrom-Json
Write-Host "Notifications found: $($data.count)"
```

**Result:** 6 notifications found for user 26

#### 2. Check Flutter App Console
When you run the Flutter app, watch for these debug messages:

```
🔍 Fetching notifications for user X...
✅ Fetched 6 notifications from API
   📬 Notification 7: reservation_reminder_1hour - 2026-01-10...
   📬 Notification 6: reservation_reminder_1hour - 2026-01-10...
📊 Grouped into X groups:
   - Today: 0 notifications
   - Yesterday: 0 notifications
   - 2 days ago: 0 notifications
   - Earlier: 6 notifications
```

#### 3. Verify User ID in App
Make sure you're logged in as **user ID 26** (the user with notifications).

Check in app:
- Login screen
- Profile screen should show user ID or email
- Or check debug console for "Fetching notifications for user X"

### 🚀 Test Now:

1. **Stop any running Flutter app**
2. **Run Flutter app:**
   ```bash
   cd frontend
   flutter run
   ```

3. **Watch console output** for debug messages

4. **In app:**
   - Login as user 26
   - Navigate to Notifications screen
   - Should see notifications under "Earlier" group

### 🔧 If Still Not Working:

#### Check 1: Network Connection
```dart
// In Flutter console, should see:
📝 Fetching notifications for user 26
✅ Notifications response: 200
```

If you see connection errors:
- Backend not running
- Wrong IP address in environment.dart
- Phone not on same Wi-Fi

#### Check 2: User ID Mismatch
```dart
// Console should show:
🔍 Fetching notifications for user 26...
```

If different user ID appears:
- You're logged in as different user
- Login as user with ID 26
- Or check which user has notifications in Supabase

#### Check 3: Empty Response
```dart
// Console should show:
✅ Fetched 6 notifications from API
```

If shows 0 notifications:
- Wrong user ID
- Notifications might have been deleted
- Check backend logs

### 📝 Expected Behavior Now:

**Notification Groups:**
- **Today:** Empty (no new notifications today)
- **Yesterday:** Empty
- **2 days ago:** Empty
- **Earlier:** 6 reservation reminders (from Jan 10)

**Notification Details:**
- Type: `reservation_reminder_1hour`
- Title: "Reservation Reminder"
- Message: "Reminder: Your reservation for Aspirin 300mg is in 1 hour at..."
- Created: Jan 10, 2026

### 🎯 Key Changes Made:

**File: `frontend/lib/logic/cubits/notifications_cubit.dart`**

1. Added "Earlier" group for old notifications:
```dart
final Map<String, List<NotificationItem>> groups = {
  'Today': [],
  'Yesterday': [],
  '2 days ago': [],
  'Earlier': [], // NEW - shows all older notifications
};
```

2. Added debug logging to track:
   - How many notifications fetched
   - Each notification's type and date
   - How many in each group

### ✅ Run the App Now!

The notifications should appear in the "Earlier" section since they're from 3 days ago (Jan 10).

If you want to test with TODAY's notifications, create a new reservation and the background job will create a notification when it's 1 hour before the reservation time.
