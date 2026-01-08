# Medicine Search & Reservation System - Backend API

## 🎯 Overview

Production-ready backend implementation for medicine search and reservation system with Supabase integration. All data is queried remotely from PostgreSQL via Supabase SDK.

## ✨ Features

- **Remote Medicine Search**: Case-insensitive partial matching with pharmacy availability
- **Notify Me**: Track medicine searches that return no results
- **Premium Reservations**: Reserve medicines (premium users only)
- **Stock Validation**: Real-time stock checking
- **Error Handling**: Comprehensive error responses with appropriate HTTP status codes

## 🏗️ Architecture

```
backend/
├── app/
│   ├── services/
│   │   └── medicine_search_service.py  # Business logic
│   ├── routes/
│   │   └── medicine_search.py          # API endpoints
│   ├── models/
│   │   └── search_history.py           # Data models
│   └── schemas/
│       └── search_history.py           # Request/response validation
```

## 📡 API Endpoints

### 1. Search Medicines

Search for medicines with pharmacy availability.

**Endpoint**: `POST /api/search/medicines`

**Request**:
```json
{
  "search_query": "aspirin"
}
```

**Response** (200 OK):
```json
{
  "success": true,
  "count": 2,
  "results": [
    {
      "medicine_id": 1,
      "name": "Aspirin 500mg",
      "generic_name": "Acetylsalicylic acid",
      "dosage": "500mg",
      "form": "tablet",
      "manufacturer": "Bayer",
      "description": "Pain reliever and anti-inflammatory",
      "requires_prescription": 0,
      "availability": [
        {
          "pharmacy_medicine_id": 10,
          "pharmacy_id": 5,
          "pharmacy_name": "HealthPlus Pharmacy",
          "address": "123 Main St",
          "phone": "555-0100",
          "latitude": 40.7128,
          "longitude": -74.0060,
          "opening_hours": "9AM-9PM",
          "rating": 4.5,
          "price": 12.50,
          "stock": 100
        }
      ]
    }
  ]
}
```

**Error Response** (400 Bad Request):
```json
{
  "success": false,
  "error": "Validation error",
  "details": [...]
}
```

---

### 2. Notify Me (Medicine Not Found)

Store notification request when medicine is not found.

**Endpoint**: `POST /api/search/notify-me`

**Request**:
```json
{
  "user_id": 123,
  "medicine_name": "Rare Medicine X"
}
```

**Response** (201 Created):
```json
{
  "success": true,
  "message": "You will be notified when 'Rare Medicine X' becomes available",
  "record_id": 456
}
```

---

### 3. Create Reservation (Premium Only)

Reserve a medicine at a specific pharmacy.

**Endpoint**: `POST /api/reservations`

**Request**:
```json
{
  "user_id": 123,
  "medicine_id": 456,
  "pharmacy_id": 789,
  "medicine_name": "Aspirin 500mg",
  "quantity": 2
}
```

**Response** (201 Created):
```json
{
  "success": true,
  "message": "Reservation created successfully",
  "reservation_id": 999,
  "status": "PENDING",
  "created_at": "2026-01-08T10:30:00"
}
```

**Error Responses**:

**Non-Premium User** (403 Forbidden):
```json
{
  "success": false,
  "error": "Reservation feature is only available for premium users. Please upgrade to premium.",
  "error_code": "PREMIUM_REQUIRED"
}
```

**Insufficient Stock** (409 Conflict):
```json
{
  "success": false,
  "error": "Insufficient stock. Available: 1, Requested: 2",
  "error_code": "INSUFFICIENT_STOCK"
}
```

**Medicine Not Available** (404 Not Found):
```json
{
  "success": false,
  "error": "Medicine not available at this pharmacy",
  "error_code": "NOT_AVAILABLE"
}
```

---

### 4. Get User Reservations

Retrieve all reservations for a user.

**Endpoint**: `GET /api/reservations/user/{user_id}`

**Response** (200 OK):
```json
{
  "success": true,
  "count": 3,
  "reservations": [
    {
      "reservation_id": 999,
      "medicine_name": "Aspirin 500mg",
      "quantity": 2,
      "status": "PENDING",
      "created_at": "2026-01-08T10:30:00",
      "pharmacy": {
        "name": "HealthPlus Pharmacy",
        "address": "123 Main St",
        "phone": "555-0100"
      }
    }
  ]
}
```

---

### 5. Get Search History

Retrieve search history for a user.

**Endpoint**: `GET /api/search/history/{user_id}`

**Response** (200 OK):
```json
{
  "success": true,
  "count": 5,
  "history": [
    {
      "id": 123,
      "medicine_name": "Aspirin",
      "searched_at": "2026-01-08T10:30:00",
      "notify_restock": 0
    }
  ]
}
```

---

### 6. Check Premium Status

Check if a user has premium status.

**Endpoint**: `GET /api/user/{user_id}/premium-status`

**Response** (200 OK):
```json
{
  "success": true,
  "user_id": 123,
  "is_premium": true
}
```

---

## 🔐 Database Schema

### Tables Used

#### `medicine`
- Stores medicine catalog
- Fields: `medicine_id`, `name`, `generic_name`, `dosage`, `form`, `manufacturer`, `description`, `requires_prescription`

#### `pharmacy`
- Stores pharmacy information
- Fields: `pharmacy_id`, `name`, `address`, `phone`, `latitude`, `longitude`, `opening_hours`, `rating`

#### `pharmacy_medicine`
- Junction table for medicine availability
- Fields: `id`, `pharmacy_id`, `medicine_id`, `price`, `stock`

#### `medicine_search_history`
- Tracks searches and notify requests
- Fields: `id`, `user_id`, `medicine_name`, `searched_at`, `notify_restock`

#### `reservation`
- Stores medicine reservations
- Fields: `reservation_id`, `user_id`, `pharmacy_id`, `medicine_name`, `quantity`, `status`, `created_at`

#### `users`
- User information with premium status
- Fields: `user_id`, `name`, `email`, `premium`

---

## 🚀 Running the Backend

### Prerequisites

```bash
pip install -r requirements.txt
```

**Required packages**:
- Flask
- supabase (Python SDK)
- pydantic
- flask-cors
- python-dotenv

### Environment Variables

Create `.env` file in `backend/` directory:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your-anon-key
PORT=5000
DEBUG=True
```

### Start Server

```bash
cd backend
python main.py
```

Server will run on `http://localhost:5000`

---

## 🧪 Testing Examples

### Search Medicine

```bash
curl -X POST http://localhost:5000/api/search/medicines \
  -H "Content-Type: application/json" \
  -d '{"search_query": "aspirin"}'
```

### Notify Me

```bash
curl -X POST http://localhost:5000/api/search/notify-me \
  -H "Content-Type: application/json" \
  -d '{"user_id": 123, "medicine_name": "Rare Medicine"}'
```

### Create Reservation

```bash
curl -X POST http://localhost:5000/api/reservations \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": 123,
    "medicine_id": 456,
    "pharmacy_id": 789,
    "medicine_name": "Aspirin 500mg",
    "quantity": 2
  }'
```

---

## 🎯 Key Features Implementation

### ✅ Remote Search
- Uses Supabase `.ilike()` for case-insensitive partial matching
- Joins `medicine`, `pharmacy_medicine`, and `pharmacy` tables
- Returns only in-stock items (`stock > 0`)

### ✅ Notify Me
- Stores search history with `notify_restock = 1`
- Can be used to trigger notifications when stock becomes available

### ✅ Premium Validation
- Checks `users.premium` field before allowing reservations
- Returns `403 Forbidden` for non-premium users with clear message

### ✅ Stock Validation
- Validates available stock before creating reservation
- Returns `409 Conflict` if insufficient stock

### ✅ Error Handling
- Comprehensive error responses with appropriate HTTP status codes
- Structured error messages with error codes
- Validation errors with detailed field-level feedback

---

## 📊 Business Logic Flow

### Medicine Search Flow
1. User submits search query
2. Query Supabase `medicine` table with `ilike` pattern
3. For each medicine, join with `pharmacy_medicine` and `pharmacy`
4. Filter by `stock > 0`
5. Return structured results with availability

### Reservation Flow
1. User requests reservation
2. **Check premium status** → Reject if not premium
3. **Validate stock availability** → Reject if insufficient
4. Create search history record
5. Create reservation record
6. Return success with reservation details

### Notify Me Flow
1. User searches medicine → No results
2. User clicks "Notify Me"
3. Store in `medicine_search_history` with `notify_restock = 1`
4. Return confirmation

---

## 🔒 Security Considerations

- **Authentication**: Assumes user authentication is handled by existing auth system
- **Premium Check**: Remote validation against Supabase user records
- **Input Validation**: Pydantic schemas validate all inputs
- **SQL Injection**: Protected by Supabase SDK (parameterized queries)

---

## 📈 Performance Optimizations

- Single query with joins for medicine search
- Async/await for non-blocking operations
- Efficient use of Supabase filters
- Indexed database columns for fast lookups

---

## 🐛 Error Codes

| Code | Status | Meaning |
|------|--------|---------|
| `PREMIUM_REQUIRED` | 403 | User must have premium subscription |
| `INSUFFICIENT_STOCK` | 409 | Not enough stock for requested quantity |
| `NOT_AVAILABLE` | 404 | Medicine not available at pharmacy |
| `Validation error` | 400 | Invalid request data |

---

## 🎓 Production Deployment Checklist

- [x] Remote data access (no local mocks)
- [x] Async operations
- [x] Error handling with proper status codes
- [x] Input validation with Pydantic
- [x] Premium validation
- [x] Stock validation
- [x] Search history tracking
- [x] Clean code structure
- [ ] Rate limiting (TODO)
- [ ] Logging (TODO)
- [ ] Unit tests (TODO)

---

## 📝 Notes

- All database operations are **remote** via Supabase
- No local data or hardcoded arrays
- Premium logic is **consumed** (not implemented) from existing auth system
- Designed for production deployment
- Optimized Supabase queries with joins
- RESTful API design

---

## 🔗 Related Files

- `medicine_search_service.py` - Core business logic
- `medicine_search.py` - API route handlers
- `search_history.py` (models) - Data models
- `search_history.py` (schemas) - Request/response schemas
- `supabase_schema.sql` - Database schema

---

## 💡 Future Enhancements

- Add pagination for search results
- Implement caching for frequently searched medicines
- Add geolocation-based pharmacy sorting
- Notification system for restock alerts
- Reservation expiration logic
- Analytics and reporting
