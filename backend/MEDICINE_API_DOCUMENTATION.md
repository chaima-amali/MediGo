# MediGo Backend - Medicine Tracking API Documentation

## Overview

This backend provides comprehensive Flask API routes for medicine tracking, adherence monitoring, and statistics, with automatic fallback from Supabase (remote) to SQLite (local).

## New API Routes

### 🔹 Medicine Tracking Routes (`/api/tracking`)

#### 1. Add Medicine to Tracking

```http
POST /api/tracking/medicines
```

**Request Body:**

```json
{
  "user_id": 1,
  "name": "Paracetamol",
  "type": "Tablet",
  "dosage": "500mg"
}
```

**Response:**

```json
{
  "success": true,
  "medicine": {
    "medicine_track_id": 1,
    "user_id": 1,
    "name": "Paracetamol",
    "type": "Tablet",
    "dosage": "500mg",
    "created_at": "2024-01-09T10:30:00Z"
  },
  "source": "remote"
}
```

#### 2. Get User's Medicines

```http
GET /api/tracking/medicines/{user_id}
```

**Response:**

```json
{
  "success": true,
  "count": 3,
  "medicines": [...],
  "source": "remote"
}
```

#### 3. Get Medicine Detail

```http
GET /api/tracking/medicines/detail/{medicine_track_id}
```

#### 4. Update Medicine

```http
PUT /api/tracking/medicines/{medicine_track_id}
```

**Request Body:**

```json
{
  "name": "Updated Medicine Name",
  "dosage": "750mg"
}
```

#### 5. Delete Medicine

```http
DELETE /api/tracking/medicines/{medicine_track_id}
```

**Note:** This will cascade delete all associated plans and occurrences.

---

### 🔹 Medicine Plan Routes (`/api/tracking/plans`)

#### 1. Create Medicine Plan

```http
POST /api/tracking/plans
```

**Request Body:**

```json
{
  "medicine_track_id": 1,
  "user_id": 1,
  "importance": "high",
  "start_date": "2024-01-09",
  "end_date": "2024-02-09",
  "frequency_type": "daily",
  "interval_days": null,
  "weekdays": null,
  "month_days": null,
  "custom_dates": null
}
```

**Frequency Types:**

- `daily` - Every day
- `weekly` - Specific days of week (use `weekdays` as JSON array: `["Monday", "Wednesday", "Friday"]`)
- `monthly` - Specific days of month (use `month_days` as JSON array: `[1, 15, 30]`)
- `custom` - Custom dates (use `custom_dates` as JSON array: `["2024-01-15", "2024-01-20"]`)
- `interval` - Every N days (use `interval_days`: 2, 3, etc.)

#### 2. Get Medicine Plan

```http
GET /api/tracking/plans/{plan_id}
```

#### 3. Get User's Plans

```http
GET /api/tracking/plans/user/{user_id}
```

#### 4. Update Plan

```http
PUT /api/tracking/plans/{plan_id}
```

#### 5. Delete Plan

```http
DELETE /api/tracking/plans/{plan_id}
```

---

### 🔹 Occurrence Plan Routes (`/api/tracking/occurrences`)

#### 1. Create Single Occurrence

```http
POST /api/tracking/occurrences
```

**Request Body:**

```json
{
  "plan_id": 1,
  "date": "2024-01-09",
  "time": "08:00",
  "day_of_week": "Monday",
  "is_taken": 0
}
```

#### 2. Create Multiple Occurrences (Batch)

```http
POST /api/tracking/occurrences/batch
```

**Request Body:**

```json
{
  "occurrences": [
    {
      "plan_id": 1,
      "date": "2024-01-09",
      "time": "08:00",
      "is_taken": 0
    },
    {
      "plan_id": 1,
      "date": "2024-01-09",
      "time": "14:00",
      "is_taken": 0
    }
  ]
}
```

#### 3. Get Plan Occurrences

```http
GET /api/tracking/occurrences/plan/{plan_id}?date=2024-01-09
```

**Query Parameters:**

- `date` (optional) - Filter by specific date

#### 4. Get Occurrences by Date

```http
GET /api/tracking/occurrences/date/{date}?user_id=1
```

**Query Parameters:**

- `user_id` (required) - User ID

**Response:**

```json
{
  "success": true,
  "date": "2024-01-09",
  "count": 5,
  "occurrences": [
    {
      "id": 1,
      "plan_id": 1,
      "date": "2024-01-09",
      "time": "08:00",
      "is_taken": 1,
      "medicine_plan": {
        "medicine_tracking": {
          "name": "Paracetamol"
        }
      }
    }
  ],
  "source": "remote"
}
```

#### 5. Update Occurrence (Mark as Taken)

```http
PUT /api/tracking/occurrences/{occurrence_id}
```

**Request Body:**

```json
{
  "is_taken": 1
}
```

#### 6. Delete Occurrence

```http
DELETE /api/tracking/occurrences/{occurrence_id}
```

---

### 🔹 Daily Dosage Checking Routes

#### 1. Create Dosage Check

```http
POST /api/tracking/dosage-checks
```

**Request Body:**

```json
{
  "plan_id": 1,
  "dose_date": "2024-01-09",
  "dose_time": "08:00",
  "status": "taken",
  "taken_at": "2024-01-09T08:05:00Z"
}
```

**Status Values:** `pending`, `taken`, `missed`, `skipped`

#### 2. Get Dosage Checks by Date

```http
GET /api/tracking/dosage-checks/date/{date}?user_id=1
```

#### 3. Update Dosage Check

```http
PUT /api/tracking/dosage-checks/{dc_id}
```

---

### 🔹 Medication Intake Log Routes

#### 1. Log Medication Intake

```http
POST /api/tracking/intake-logs
```

**Request Body:**

```json
{
  "occurrence_id": 1,
  "medicine_track_id": 1,
  "scheduled_date": "2024-01-09",
  "scheduled_time": "08:00",
  "actual_time": "2024-01-09T08:05:00Z",
  "status": "taken",
  "dosage": "500mg",
  "notes": "Taken with food"
}
```

#### 2. Get Medicine Intake Logs

```http
GET /api/tracking/intake-logs/medicine/{medicine_track_id}?start_date=2024-01-01&end_date=2024-01-31
```

**Query Parameters:**

- `start_date` (optional)
- `end_date` (optional)

---

### 📊 Statistics Routes (`/api/statistics`)

#### 1. Get User Statistics Overview

```http
GET /api/statistics/overview/{user_id}?period=month
```

**Query Parameters:**

- `period`: `week`, `month`, `year`, `all` (default: `month`)

**Response:**

```json
{
  "success": true,
  "period": "month",
  "start_date": "2023-12-09",
  "end_date": "2024-01-09",
  "statistics": {
    "total_medicines": 5,
    "total_doses_scheduled": 150,
    "doses_taken": 135,
    "doses_missed": 15,
    "adherence_rate": 90.0,
    "intake_logs": {
      "total": 140,
      "taken": 135,
      "missed": 3,
      "skipped": 2
    }
  },
  "source": "remote"
}
```

#### 2. Get Medicine Statistics

```http
GET /api/statistics/medicine/{medicine_track_id}?period=month
```

**Response:**

```json
{
  "success": true,
  "medicine": {
    "medicine_track_id": 1,
    "name": "Paracetamol"
  },
  "period": "month",
  "statistics": {
    "total_doses_scheduled": 60,
    "doses_taken": 55,
    "doses_missed": 5,
    "adherence_rate": 91.67
  },
  "source": "remote"
}
```

#### 3. Get Daily Statistics

```http
GET /api/statistics/daily/{user_id}?date=2024-01-09
```

**Response:**

```json
{
  "success": true,
  "date": "2024-01-09",
  "statistics": {
    "total_doses_scheduled": 5,
    "doses_taken": 4,
    "doses_missed": 1,
    "adherence_rate": 80.0
  },
  "occurrences": [...]
}
```

#### 4. Get Weekly Statistics

```http
GET /api/statistics/weekly/{user_id}
```

**Response:** Returns last 4 weeks of data with adherence rates.

#### 5. Get Monthly Statistics

```http
GET /api/statistics/monthly/{user_id}
```

**Response:** Returns last 6 months of data with adherence rates.

#### 6. Get Adherence Trend

```http
GET /api/statistics/adherence-trend/{user_id}
```

**Response:** Returns day-by-day adherence for last 30 days.

---

## Database Tables Used

### Primary Tables

1. **medicine_tracking** - User's tracked medicines
2. **medicine_plan** - Medication schedules
3. **occurrence_plan** - Individual dose instances
4. **daily_dosage_checking** - Daily dose status tracking
5. **medication_intake_log** - Detailed intake logging
6. **notification** - Medication reminders

### Foreign Key Relationships

```
medicine_tracking (user_id → users)
    ↓
medicine_plan (medicine_track_id → medicine_tracking)
    ↓
occurrence_plan (plan_id → medicine_plan)
    ↓
medication_intake_log (occurrence_id → occurrence_plan)
    ↓
daily_dosage_checking (plan_id → medicine_plan)
```

---

## Features

### ✅ Automatic Fallback

- All routes try **Supabase (remote)** first
- Automatically falls back to **SQLite (local)** if Supabase unavailable
- Response includes `"source": "remote"` or `"source": "local"`

### ✅ Cascade Deletion

- Deleting a medicine automatically removes all plans, occurrences, and logs
- Foreign key constraints ensure data integrity

### ✅ Flexible Querying

- Date range filters
- User-specific queries
- Status-based filtering
- Adherence period selection

### ✅ Validation

- Pydantic schemas validate all input data
- Proper error messages for invalid requests
- Type checking on all fields

---

## Usage Example (Flutter/Dart Integration)

```dart
// Add medicine
Future<void> addMedicine() async {
  final response = await http.post(
    Uri.parse('http://your-backend/api/tracking/medicines'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'user_id': 1,
      'name': 'Aspirin',
      'type': 'Tablet',
      'dosage': '100mg'
    }),
  );

  if (response.statusCode == 201) {
    final data = json.decode(response.body);
    print('Medicine added: ${data['medicine']}');
  }
}

// Get today's doses
Future<void> getTodayDoses() async {
  final today = DateTime.now().toIso8601String().split('T')[0];
  final response = await http.get(
    Uri.parse('http://your-backend/api/tracking/occurrences/date/$today?user_id=1'),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    print('Today\'s doses: ${data['count']}');
  }
}

// Mark dose as taken
Future<void> markAsTaken(int occurrenceId) async {
  final response = await http.put(
    Uri.parse('http://your-backend/api/tracking/occurrences/$occurrenceId'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({'is_taken': 1}),
  );

  if (response.statusCode == 200) {
    print('Dose marked as taken');
  }
}

// Get statistics
Future<void> getStatistics() async {
  final response = await http.get(
    Uri.parse('http://your-backend/api/statistics/overview/1?period=month'),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    print('Adherence rate: ${data['statistics']['adherence_rate']}%');
  }
}
```

---

## Testing with cURL

```bash
# Add medicine
curl -X POST http://localhost:5000/api/tracking/medicines \
  -H "Content-Type: application/json" \
  -d '{"user_id":1,"name":"Aspirin","type":"Tablet","dosage":"100mg"}'

# Get user medicines
curl http://localhost:5000/api/tracking/medicines/1

# Create medicine plan
curl -X POST http://localhost:5000/api/tracking/plans \
  -H "Content-Type: application/json" \
  -d '{"medicine_track_id":1,"user_id":1,"start_date":"2024-01-09","frequency_type":"daily"}'

# Get today's occurrences
curl "http://localhost:5000/api/tracking/occurrences/date/2024-01-09?user_id=1"

# Mark occurrence as taken
curl -X PUT http://localhost:5000/api/tracking/occurrences/1 \
  -H "Content-Type: application/json" \
  -d '{"is_taken":1}'

# Get statistics
curl "http://localhost:5000/api/statistics/overview/1?period=month"
```

---

## Error Handling

All endpoints return consistent error format:

```json
{
  "success": false,
  "error": "Error message here"
}
```

Common HTTP Status Codes:

- `200` - Success
- `201` - Created
- `400` - Bad Request (validation error)
- `404` - Not Found
- `409` - Conflict (duplicate)
- `500` - Internal Server Error

---

## Next Steps

To integrate with your Flutter app:

1. Update your `ApiService` class with these new endpoints
2. Create Dart models matching the response schemas
3. Update your repositories to call these endpoints
4. Test both remote (Supabase) and local (SQLite) modes
5. Handle error responses appropriately

All routes work identically whether using Supabase or SQLite!
