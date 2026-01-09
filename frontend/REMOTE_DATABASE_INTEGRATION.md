# Remote Database Integration - Frontend Updates

## Overview

Updated all medicine tracking repositories to use remote Supabase database first, with automatic fallback to local SQLite database. This ensures the app works seamlessly online and offline.

## Pattern: Remote-First with Local Fallback

All repository methods follow this pattern:

1. **Try Remote API**: Attempt to communicate with Flask backend → Supabase
2. **Catch Errors**: If network/server fails, catch the exception
3. **Fallback to Local**: Use SQLite database for offline functionality
4. **Sync Both**: When remote succeeds, also update local for consistency

## Files Created

### 1. `lib/data/services/api/tracking_api_service.dart` ✨ NEW

Complete API service for medicine tracking operations:

**Medicine Tracking Methods:**

- `addMedicine()` - Add new medicine to tracking
- `getMedicines()` - Get all medicines for a user
- `getMedicineDetail()` - Get specific medicine details
- `updateMedicine()` - Update medicine tracking entry
- `deleteMedicine()` - Delete medicine and all associated data

**Medicine Plans Methods:**

- `createMedicinePlan()` - Create medication schedule
- `getMedicinePlan()` - Get specific plan
- `getUserPlans()` - Get all plans for a user
- `updateMedicinePlan()` - Update plan
- `deleteMedicinePlan()` - Delete plan

**Occurrences Methods:**

- `createOccurrence()` - Create single dose instance
- `createOccurrencesBatch()` - Create multiple doses efficiently
- `getPlanOccurrences()` - Get occurrences for a plan
- `getOccurrencesByDate()` - Get all doses for a specific date
- `updateOccurrence()` - Update occurrence (mark as taken)
- `deleteOccurrence()` - Delete occurrence

**Dosage Checks Methods:**

- `createDosageCheck()` - Create daily dosage check
- `getDosageChecksByDate()` - Get checks for a date
- `updateDosageCheck()` - Update check status

**Medication Intake Logs Methods:**

- `logMedicationIntake()` - Log when medicine is actually taken
- `getMedicineIntakeLogs()` - Get intake history for a medicine

## Files Updated

### 2. `lib/data/repositories/medicine_repository.dart` 🔄 UPDATED

**New Import:**

```dart
import '../services/api/tracking_api_service.dart';
import 'dart:convert';
```

**Updated Methods:**

#### `saveMedicine()` - Remote-First Medicine Creation

**Before:** Only saved to local SQLite
**Now:**

1. ✅ Creates medicine in remote database (Supabase)
2. ✅ Creates plan in remote database
3. ✅ Creates all occurrences in batch (efficient)
4. ✅ Saves to local as backup
5. ❌ Falls back to local-only if remote fails

**Key Changes:**

- Converts plan dates to ISO format for API
- Encodes arrays (weekdays, monthDays) as JSON strings
- Batch creates occurrences for performance
- Prints detailed logs for debugging

#### `updateMedicineTracking()` - Remote-First Medicine Update

**Before:** Only updated local SQLite
**Now:**

1. ✅ Updates medicine in remote database
2. ✅ Updates local database for consistency
3. ❌ Falls back to local-only if remote fails

#### `updateMedicinePlan()` - Remote-First Plan Update

**Before:** Only updated local SQLite
**Now:**

1. ✅ Updates plan in remote database
2. ✅ Updates local database for consistency
3. ❌ Falls back to local-only if remote fails

#### `deleteMedicinePlan()` - Remote-First Deletion

**Before:** Only deleted from local SQLite
**Now:**

1. ✅ Deletes plan from remote database (cascade deletes occurrences)
2. ✅ Deletes from local database for consistency
3. ❌ Falls back to local-only if remote fails

### 3. `lib/data/repositories/occurrence_repository.dart` 🔄 UPDATED

**New Import:**

```dart
import 'package:frontend/data/services/api/tracking_api_service.dart';
```

**Updated Methods:**

#### `getOccurrencesByDate()` - Remote-First Fetch

**Before:** Only queried local SQLite
**Now:**

1. ✅ Fetches from remote database first
2. ✅ Converts remote data to Occurrence models
3. ✅ Handles nested medicine data from backend joins
4. ✅ Syncs data to local for offline access
5. ❌ Falls back to local query if remote fails

**Key Changes:**

- Properly maps backend response structure
- Handles `medicine_tracking` and `medicine_plan` nested objects
- New `_syncOccurrencesToLocal()` helper method

#### `updateOccurrenceTaken()` - Remote-First Status Update

**Before:** Only updated local SQLite
**Now:**

1. ✅ Updates occurrence in remote database
2. ✅ Updates local database for consistency
3. ❌ Falls back to local-only if remote fails

#### `deleteOccurrence()` - Remote-First Deletion

**Before:** Only deleted from local SQLite
**Now:**

1. ✅ Deletes from remote database
2. ✅ Deletes from local database for consistency
3. ❌ Falls back to local-only if remote fails

### 4. `lib/data/repositories/daily_dosage_repository.dart` 🔄 UPDATED

**New Import:**

```dart
import 'package:frontend/data/services/api/tracking_api_service.dart';
```

**Updated Methods:**

#### `insertOrUpdateCheck()` - Remote-First Dosage Tracking

**Before:** Only saved to local SQLite
**Now:**

1. ✅ Creates/updates check in remote database
2. ✅ Always saves to local for offline access
3. ❌ Continues with local-only if remote fails

**Key Changes:**

- Formats dates to ISO strings for API
- Handles nullable planId gracefully
- Always updates local even if remote succeeds

### 5. `lib/data/services/api/statistics_api_service.dart` 🔄 UPDATED

**New Methods:**

- `getStatisticsOverview()` - Overall user statistics
- `getMedicineStatistics()` - Per-medicine statistics
- `getDailyStatistics()` - Daily adherence data
- `getWeeklyStatistics()` - Weekly adherence trends
- `getMonthlyStatistics()` - Monthly adherence trends
- `getAdherenceTrend()` - 30-day adherence graph data

**Backward Compatibility:**

- `getAdherenceStats()` now calls `getStatisticsOverview()`

### 6. `lib/data/services/api_service.dart` 🔄 UPDATED

**New Service:**

```dart
late final TrackingApiService tracking = TrackingApiService();
```

**Usage Example:**

```dart
// Access tracking API methods
await api.tracking.addMedicine(userId: 1, name: 'Aspirin', type: 'Tablet');
await api.tracking.createMedicinePlan(...);
await api.tracking.getOccurrencesByDate('2024-01-09', userId);
```

## Backend Endpoints Used

All repositories now communicate with these Flask backend endpoints:

### Medicine Tracking

- `POST /api/tracking/medicines` - Add medicine
- `GET /api/tracking/medicines/{user_id}` - Get user medicines
- `GET /api/tracking/medicines/detail/{id}` - Get medicine detail
- `PUT /api/tracking/medicines/{id}` - Update medicine
- `DELETE /api/tracking/medicines/{id}` - Delete medicine

### Medicine Plans

- `POST /api/tracking/plans` - Create plan
- `GET /api/tracking/plans/{plan_id}` - Get plan
- `GET /api/tracking/plans/user/{user_id}` - Get user plans
- `PUT /api/tracking/plans/{plan_id}` - Update plan
- `DELETE /api/tracking/plans/{plan_id}` - Delete plan

### Occurrences

- `POST /api/tracking/occurrences` - Create occurrence
- `POST /api/tracking/occurrences/batch` - Create multiple occurrences
- `GET /api/tracking/occurrences/date/{date}?user_id={id}` - Get by date
- `PUT /api/tracking/occurrences/{id}` - Update occurrence
- `DELETE /api/tracking/occurrences/{id}` - Delete occurrence

### Statistics

- `GET /api/statistics/overview/{user_id}` - Overall statistics
- `GET /api/statistics/medicine/{id}` - Medicine statistics
- `GET /api/statistics/daily/{user_id}` - Daily statistics
- `GET /api/statistics/weekly/{user_id}` - Weekly statistics
- `GET /api/statistics/monthly/{user_id}` - Monthly statistics
- `GET /api/statistics/adherence-trend/{user_id}` - Adherence trend

## How It Works

### Example: Adding a Medicine

**User Flow:**

1. User fills out "Add Medicine" form in app
2. User taps "Save" button
3. App calls `MedicineRepository.saveMedicine()`

**What Happens:**

```dart
// 1. Try remote first
try {
  // Create medicine in Supabase via Flask API
  final medicineResponse = await _apiService.addMedicine(...);

  // Create plan in Supabase
  final planResponse = await _apiService.createMedicinePlan(...);

  // Create all occurrences in batch
  await _apiService.createOccurrencesBatch(...);

  // Also save to local as backup
  await _saveMedicineLocal(...);

  print('✅ Saved to both remote and local!');
  return;

} catch (e) {
  print('⚠️  Remote failed, using local only');
}

// 2. Fallback: Save to local SQLite
await _saveMedicineLocal(...);
```

**Result:**

- ✅ Medicine saved to Supabase (remote)
- ✅ Medicine saved to SQLite (local backup)
- ✅ Works offline (falls back to local)
- ✅ Data persists even if remote fails

## Testing Checklist

### Test Add Medicine Flow

1. ✅ Start backend server: `cd backend && python main.py`
2. ✅ Open app in Flutter
3. ✅ Add a new medicine (e.g., "Aspirin 100mg")
4. ✅ Check backend logs for: `Remote: Medicine created with ID: X`
5. ✅ Check Supabase dashboard → `medicine_tracking` table
6. ✅ Verify medicine appears in app
7. ✅ Stop backend server
8. ✅ Add another medicine (should work offline)
9. ✅ Verify it saves to local SQLite only

### Test Edit Medicine Flow

1. ✅ Edit existing medicine name
2. ✅ Check logs for remote update
3. ✅ Verify Supabase shows updated name
4. ✅ Test offline edit (should work)

### Test Occurrence Tracking

1. ✅ View today's medicines
2. ✅ Check logs for remote fetch
3. ✅ Mark medicine as taken
4. ✅ Verify remote update in Supabase
5. ✅ Test offline marking (should work)

### Test Statistics

1. ✅ View statistics page
2. ✅ Check logs for remote stats fetch
3. ✅ Verify adherence calculations
4. ✅ Test offline stats (uses local data)

## Debugging

### Common Issues

**Issue: "Remote API failed" in logs**

- **Cause:** Backend not running or network issue
- **Solution:** Start backend with `python main.py` in backend directory
- **Impact:** None - app continues with local database

**Issue: Medicine added but not in Supabase**

- **Cause:** Backend route error or database connection issue
- **Check:** Backend terminal for error messages
- **Check:** Supabase dashboard for connection status
- **Solution:** Verify `SUPABASE_URL` and `SUPABASE_KEY` in backend/.env

**Issue: Duplicate medicines after reconnecting**

- **Cause:** Local-only saves not synced to remote
- **Solution:** Implement sync service (future enhancement)

### Useful Logs

```dart
// Medicine saved successfully
✅ Remote: Medicine created with ID: 123
✅ Remote: Plan created with ID: 456
✅ Remote: 60 occurrences created
💾 Saving to local database as backup...
✅ Medicine saved successfully to both remote and local!

// Remote API failed
⚠️  Remote API failed: DioException [connection timeout]
📱 Falling back to local database...
✅ MedicineRepository: Tracking inserted with ID: 1 (local)

// Occurrence marked as taken
🌐 Updating occurrence remotely: ID=789, isTaken=1
✅ Remote: Occurrence updated successfully
```

## Database Tables Affected

### Supabase (Remote)

- `medicine_tracking` - Medicine details
- `medicine_plan` - Medication schedules
- `occurrence_plan` - Individual dose instances
- `daily_dosage_checking` - Daily tracking records
- `medication_intake_log` - Intake history

### SQLite (Local)

- Same tables as above for offline functionality

## Next Steps

### Recommended Enhancements

1. **Sync Service**: Automatically sync local changes when back online
2. **Conflict Resolution**: Handle edits made offline vs online
3. **Background Sync**: Use WorkManager to sync in background
4. **Optimistic Updates**: Show UI changes immediately, sync in background
5. **Retry Logic**: Automatically retry failed remote operations

### Future Features

- Bulk sync all local data to remote
- Pull-to-refresh to get latest remote data
- Sync status indicator in UI
- Manual sync trigger button

## Summary

✅ **All repositories updated** to use remote database first
✅ **Automatic fallback** to local SQLite when offline
✅ **No breaking changes** - app works exactly as before
✅ **Better data persistence** - data saved to cloud
✅ **Multi-device sync** ready (via Supabase)
✅ **Offline functionality** preserved completely

The app now seamlessly works with both remote Supabase and local SQLite databases, providing the best of both worlds: cloud backup and offline functionality!
