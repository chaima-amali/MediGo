# Reservation Reminder Notifications - Integration Guide

## Summary

✅ **BACKEND COMPLETED:**
1. Background job runs every 30 minutes checking for upcoming reservations
2. Creates notifications 1 hour or 1 day before reservation time
3. Only sends to premium users
4. Stores notifications in Supabase `notification` table
5. New API endpoints created to fetch notifications

## What's Working

- ✅ Background scheduler running
- ✅ Notifications being created in Supabase database (6 notifications created for user_id: 26)
- ✅ API endpoint created: `GET /api/notifications/{user_id}`
- ✅ Time parsing fixed (handles AM/PM format like "12:37 AM")

## Current Issue

The Flutter app is NOT showing these notifications because:
- The app currently only loads medicine reminders from **local SQLite database**
- It does NOT fetch reservation reminders from **Supabase**

## Backend API Endpoints Created

### 1. Get User Notifications
```
GET /api/notifications/<user_id>
```

**Example:**
```
GET http://localhost:5000/api/notifications/26
```

**Query Parameters** (optional):
- `type`: Filter by notification type (e.g., "reservation_reminder_1hour")
- `is_read`: Filter by read status (0 or 1)
- `limit`: Max number of notifications (default: 50)

**Response:**
```json
{
  "success": true,
  "notifications": [
    {
      "notification_id": 2,
      "user_id": 26,
      "reservation_id": 11,
      "datetime": "2026-01-10T22:54:00.609375+00:00",
      "title": "Reservation Reminder",
      "message": "Reminder: Your reservation for Aspirin 300mg is in 1 hour at 12:37 AM",
      "type": "reservation_reminder_1hour",
      "is_read": 0,
      "created_at": "2026-01-10T22:54:00.609375+00:00"
    }
  ],
  "count": 6
}
```

### 2. Mark Notification as Read
```
PUT /api/notifications/<notification_id>/mark-read
```

### 3. Mark All Notifications as Read
```
PUT /api/notifications/mark-all-read/<user_id>
```

## What You Need to Do in Flutter

### Step 1: Create Notification API Service

Create a new file: `lib/data/services/notification_api_service.dart`

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationApiService {
  final String baseUrl = 'http://localhost:5000/api'; // Change to your backend URL
  
  /// Fetch all notifications for a user from Supabase
  Future<List<Map<String, dynamic>>> getUserNotifications(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications/$userId'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return List<Map<String, dynamic>>.from(data['notifications']);
        }
      }
      return [];
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }
  
  /// Mark a notification as read
  Future<bool> markAsRead(int notificationId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/notifications/$notificationId/mark-read'),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }
}
```

### Step 2: Update NotificationsCubit

Modify `lib/logic/cubits/notifications_cubit.dart` to fetch both:
1. Local medicine reminders (from SQLite)
2. Reservation reminders (from Supabase via API)

```dart
import 'package:frontend/data/services/notification_api_service.dart';
// ... other imports

class NotificationsCubit extends Cubit<NotificationsState> {
  final OccurrenceRepository _repository;
  final NotificationApiService _apiService = NotificationApiService();

  NotificationsCubit(this._repository) : super(NotificationsState());

  Future<void> loadNotifications() async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // 1. Get local medicine reminders
      final List<NotificationItem> allNotifications = [];

      for (int i = 0; i < 3; i++) {
        final date = today.subtract(Duration(days: i));
        final occurrences = await _repository.getOccurrencesByDate(date);

        for (final occurrence in occurrences) {
          final notification = NotificationItem(
            occurrenceId: occurrence.id ?? 0,
            medicineName: occurrence.medicineName ?? 'Medicine',
            time: occurrence.time,
            date: occurrence.date,
            isTaken: occurrence.isTaken == 1,
            importance: occurrence.importance,
          );

          if (notification.isPast) {
            allNotifications.add(notification);
          }
        }
      }

      // 2. Get reservation reminders from Supabase
      // TODO: Get actual user_id from your auth system
      final userId = 26; // Replace with actual logged-in user ID
      final reservationNotifs = await _apiService.getUserNotifications(userId);
      
      // Convert Supabase notifications to NotificationItem format
      for (final notif in reservationNotifs) {
        // You may need to create a new notification type or adapt the existing one
        // to handle reservation reminders differently
        
        // Example: Convert reservation notification to display format
        allNotifications.add(NotificationItem(
          occurrenceId: notif['notification_id'],
          medicineName: _extractMedicineName(notif['message']),
          time: notif['datetime'], 
          date: DateTime.parse(notif['created_at']),
          isTaken: notif['is_read'] == 1,
          importance: 'high', // Reservation reminders are important
        ));
      }

      // Group notifications by day
      final grouped = _groupNotificationsByDay(allNotifications);

      emit(state.copyWith(groupedNotifications: grouped, isLoading: false));
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Failed to load notifications: $e',
        ),
      );
    }
  }
  
  String _extractMedicineName(String message) {
    // Extract medicine name from message like:
    // "Reminder: Your reservation for Aspirin 300mg is in 1 hour at 12:37 AM"
    final match = RegExp(r'for (.+?) is').firstMatch(message);
    return match?.group(1) ?? 'Medicine';
  }

  // ... rest of your existing code
}
```

### Step 3: Update NotificationItem Model (if needed)

You might need to extend the `NotificationItem` model to support both types:

```dart
class NotificationItem {
  final int occurrenceId;
  final String medicineName;
  final String time;
  final DateTime date;
  final bool isTaken;
  final String importance;
  final String? type; // Add this to distinguish notification types
  final String? fullMessage; // Add this for reservation messages
  
  // ... constructor and methods
}
```

### Step 4: Test

1. Make sure backend is running: `cd backend && python main.py`
2. Run your Flutter app
3. Navigate to the notifications page
4. You should now see both:
   - Medicine reminders (from local DB)
   - Reservation reminders (from Supabase) showing "Your reservation for Aspirin 300mg is in 1 hour"

## Notification Types in Database

- `reservation_reminder_1hour` - Sent 0.5-1.5 hours before reservation
- `reservation_reminder_1day` - Sent 23-25 hours before reservation

## Backend Job Schedule

- Runs every **30 minutes** automatically
- Can be manually triggered: `POST /api/admin/test-reminders`

## Files Modified/Created

### Backend:
- ✅ `backend/app/jobs/reservation_reminders.py` - Background job logic
- ✅ `backend/app/routes/notifications.py` - New API endpoints
- ✅ `backend/app/__init__.py` - Registered notifications blueprint
- ✅ `backend/requirements.txt` - Added APScheduler==3.10.4

### Frontend (TODO):
- ⏳ `lib/data/services/notification_api_service.dart` - Create this file
- ⏳ `lib/logic/cubits/notifications_cubit.dart` - Update to fetch from API
- ⏳ `lib/data/models/notification_item.dart` - Extend model (if needed)

## Next Steps

1. Create the `notification_api_service.dart` file
2. Update `notifications_cubit.dart` to call the API
3. Update the UI to handle both notification types
4. Test with your existing reservations (you already have 6 waiting!)
5. Consider adding push notifications (Firebase Cloud Messaging) in the future

## Notes

- The backend is configured to use your actual Supabase database
- Notifications are already in the database (check yourself!)
- The background job will keep creating new notifications automatically
- Only **premium users** receive notifications
- Notifications won't be duplicated (checks before creating)
