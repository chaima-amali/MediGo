# Firebase Medicine Reminder Setup Guide

## 🎯 Overview

Your app will now send automatic push notifications to users when it's time to take their medicine. The backend checks every minute for upcoming doses and sends reminders 5 minutes before the scheduled time.

---

## 📋 Step-by-Step Setup

### **1. Install Backend Dependencies**

```bash
cd backend
pip install firebase-admin==6.5.0 APScheduler==3.10.4
```

Or install all from requirements.txt:

```bash
pip install -r requirements.txt
```

---

### **2. Get Firebase Service Account Key**

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your **MediGo** project
3. Click the **gear icon** ⚙️ → **Project Settings**
4. Go to **Service Accounts** tab
5. Click **"Generate new private key"**
6. Download the JSON file
7. **Rename it to**: `firebase-service-account.json`
8. **Move it to**: `backend/firebase-service-account.json` (same level as `main.py`)

**⚠️ IMPORTANT**: Add to `.gitignore`:

```
firebase-service-account.json
```

---

### **3. Update Supabase Database (Add notification table if missing)**

Your database should already have the `notification` table. If not, run this SQL in Supabase:

```sql
CREATE TABLE IF NOT EXISTS notification (
    notification_id SERIAL PRIMARY KEY,
    occurrence_id INTEGER REFERENCES occurrence_plan(id) ON DELETE CASCADE,
    sent_at TIMESTAMP DEFAULT NOW(),
    is_sent INTEGER DEFAULT 0,
    notification_type VARCHAR(50) DEFAULT 'medicine_reminder'
);

CREATE INDEX idx_notification_occurrence ON notification(occurrence_id);
CREATE INDEX idx_notification_sent ON notification(is_sent);
```

Also ensure `users` table has `fcm_token` column:

```sql
ALTER TABLE users ADD COLUMN IF NOT EXISTS fcm_token TEXT;
```

---

### **4. Update Flutter App to Send FCM Token**

The app should already handle FCM. You just need to ensure the token is sent to the backend when the user logs in.

**Update `lib/data/services/api/user_api_service.dart`:**

Add method to update FCM token:

```dart
/// Update user's FCM token
Future<void> updateFCMToken(int userId, String fcmToken) async {
  final response = await _client.put(
    '/users/$userId/fcm-token',
    data: {'fcm_token': fcmToken},
  );
}
```

**Update `lib/logic/cubits/user_cubit.dart`:**

After successful login, send FCM token:

```dart
// In login() method, after successful login:
try {
  final fcmToken = await FirebaseMessaging.instance.getToken();
  if (fcmToken != null) {
    await _apiService.users.updateFCMToken(userId, fcmToken);
    print('✅ FCM token sent to backend');
  }
} catch (e) {
  print('⚠️ Failed to send FCM token: $e');
}
```

---

### **5. Configure Android Notification Channel**

**File**: `android/app/src/main/AndroidManifest.xml`

Add inside `<application>` tag:

```xml
<meta-data
    android:name="com.google.firebase.messaging.default_notification_channel_id"
    android:value="medicine_reminders" />
```

**File**: `lib/main.dart`

Create notification channel on app startup:

```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> setupNotificationChannel() async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'medicine_reminders',
    'Medicine Reminders',
    description: 'Notifications for medicine intake reminders',
    importance: Importance.high,
    enableVibration: true,
    playSound: true,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

// Call in main():
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await setupNotificationChannel();
  runApp(MyApp());
}
```

---

### **6. Handle Notification Taps (Navigate to Tracking Screen)**

**File**: `lib/main.dart`

```dart
// Listen for notification taps
FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  print('Notification tapped: ${message.data}');

  if (message.data['type'] == 'medicine_reminder') {
    // Navigate to tracking screen
    final occurrenceId = int.tryParse(message.data['occurrence_id'] ?? '');
    if (occurrenceId != null) {
      // Use your navigation logic
      Navigator.pushNamed(context, '/tracking');
    }
  }
});
```

---

### **7. Start Backend Server**

```bash
cd backend
python main.py
```

You should see:

```
✅ Firebase Admin SDK initialized successfully
✅ Medicine reminder scheduler started
✅ Reminder scheduler started
 * Running on http://127.0.0.1:5000
```

---

## 🧪 Testing

### **Test 1: Add a Medicine with Near-Future Time**

1. Open your Flutter app
2. Add a medicine scheduled for **5 minutes from now**
3. Wait 5 minutes
4. You should receive a push notification! 📱

### **Test 2: Check Backend Logs**

Watch the backend terminal for:

```
🔍 Checking for medicine reminders at 2024-01-09 14:25:00
📤 Sending 1 medicine reminders
✅ Notification sent successfully: projects/.../messages/...
```

### **Test 3: Manual Test via Firebase Console**

1. Go to Firebase Console → Cloud Messaging
2. Click "Send test message"
3. Paste your device FCM token
4. Send - you should receive it

---

## 📊 How It Works

```
Backend Scheduler (every 1 minute)
       ↓
Check database for occurrences in next 5 minutes
       ↓
Filter: is_taken = 0 AND has FCM token
       ↓
Send Firebase Cloud Message
       ↓
User receives notification
       ↓
User taps → Opens app → Navigates to tracking
       ↓
User marks medicine as taken
```

---

## 🔧 Troubleshooting

### **Issue: "Firebase service account file not found"**

- **Solution**: Make sure `firebase-service-account.json` is in the `backend/` folder

### **Issue: "No notifications received"**

- Check if user has FCM token saved (query `users` table)
- Check backend logs for errors
- Verify medicine is scheduled within the next 5 minutes
- Ensure medicine is **not already taken** (`is_taken = 0`)

### **Issue: "Notifications received but app doesn't open"**

- Check `FirebaseMessaging.onMessageOpenedApp` handler is set up
- Verify `click_action` in notification data

### **Issue: "Multiple notifications for same medicine"**

- Check `notification` table - should record sent notifications
- Scheduler checks `is_sent = 1` to avoid duplicates

---

## ⚙️ Customization

### **Change Reminder Time (currently 5 minutes before)**

**File**: `backend/app/services/reminder_scheduler.py`

```python
# Line 52: Change 5 to your preferred minutes
reminder_time = now + timedelta(minutes=5)  # Change to 10, 15, etc.
```

### **Change Check Frequency (currently every 1 minute)**

**File**: `backend/app/services/reminder_scheduler.py`

```python
# Line 26: Change interval
trigger=IntervalTrigger(minutes=1),  # Change to 5, 10, etc.
```

### **Customize Notification Message**

**File**: `backend/app/services/notification_service.py`

```python
# Line 48-50: Edit title and body
title='💊 Medicine Reminder',
body=f"Time to take {medicine_name} ({dosage}) at {time}",
```

---

## 📝 API Endpoints Added

### `PUT /api/users/{user_id}/fcm-token`

Update user's FCM token

**Request:**

```json
{
  "fcm_token": "user_device_token_from_firebase"
}
```

**Response:**

```json
{
  "success": true,
  "message": "FCM token updated successfully",
  "source": "remote"
}
```

---

## ✅ Checklist

- [ ] Installed `firebase-admin` and `APScheduler`
- [ ] Downloaded Firebase service account JSON
- [ ] Placed `firebase-service-account.json` in `backend/` folder
- [ ] Added `fcm_token` column to `users` table
- [ ] Created `notification` table in Supabase
- [ ] Updated Flutter to send FCM token on login
- [ ] Created Android notification channel
- [ ] Added notification tap handler
- [ ] Started backend server
- [ ] Tested with near-future medicine time
- [ ] Received notification successfully! 🎉

---

## 🚀 You're All Set!

Your users will now receive automatic reminders when it's time to take their medicine. The system handles both remote (Supabase) and local (SQLite) databases, ensuring notifications work even during development.

**Next Steps:**

- Deploy backend to production server
- Set up proper Firebase Cloud Messaging quotas
- Add notification preferences (allow users to customize reminder time)
- Add snooze functionality
