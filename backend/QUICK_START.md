# 🚀 Quick Start Guide - Medicine Search & Reservation API

## Start the Backend Server

```bash
cd backend
python main.py
```

Server runs on: **http://localhost:5000**

---

## 📡 API Endpoints Quick Reference

### 1. Search Medicines
```bash
POST /api/search/medicines
Body: {"search_query": "aspirin"}
```

### 2. Notify Me (Not Found)
```bash
POST /api/search/notify-me
Body: {"user_id": 1, "medicine_name": "Rare Medicine"}
```

### 3. Create Reservation (Premium Only)
```bash
POST /api/reservations
Body: {
  "user_id": 1,
  "medicine_id": 1,
  "pharmacy_id": 1,
  "medicine_name": "Aspirin",
  "quantity": 1
}
```

### 4. Get User Reservations
```bash
GET /api/reservations/user/{user_id}
```

### 5. Get Search History
```bash
GET /api/search/history/{user_id}
```

### 6. Check Premium Status
```bash
GET /api/user/{user_id}/premium-status
```

---

## 🧪 Test the API

```bash
python test_medicine_search_api.py
```

---

## 📦 Files Created

```
backend/
├── app/
│   ├── services/
│   │   ├── __init__.py                    ✅ NEW
│   │   └── medicine_search_service.py     ✅ NEW
│   ├── routes/
│   │   └── medicine_search.py             ✅ NEW
│   ├── models/
│   │   └── search_history.py              ✅ NEW
│   └── schemas/
│       └── search_history.py              ✅ NEW
├── MEDICINE_SEARCH_API.md                 ✅ NEW (Full API docs)
├── IMPLEMENTATION_SUMMARY.md              ✅ NEW (Implementation details)
└── test_medicine_search_api.py            ✅ NEW (Test script)
```

---

## ⚡ Key Features

✅ **Remote Search** - Case-insensitive, partial matching  
✅ **Pharmacy Join** - Shows price, stock, location  
✅ **Premium Check** - Validates user subscription  
✅ **Stock Validation** - Checks availability  
✅ **Notify Me** - Tracks unfound medicines  
✅ **Error Handling** - Clear messages, proper HTTP codes  

---

## 🔒 Business Rules

1. **Search** - Anyone can search
2. **Notify Me** - Anyone can request notifications
3. **Reservation** - **Premium users only**
4. **Stock** - Must be available (stock > 0)

---

## 📊 HTTP Status Codes

| Code | Meaning |
|------|---------|
| 200 | Success |
| 201 | Created |
| 400 | Validation error |
| 403 | Premium required |
| 404 | Not found |
| 409 | Insufficient stock |
| 500 | Server error |

---

## 🎯 Response Format

### Success
```json
{
  "success": true,
  "data": {...}
}
```

### Error
```json
{
  "success": false,
  "error": "Error message",
  "error_code": "ERROR_CODE"
}
```

---

## 💾 Database Tables Used

- `medicine` - Medicine catalog
- `pharmacy` - Pharmacy info
- `pharmacy_medicine` - Inventory
- `medicine_search_history` - Search tracking
- `reservation` - Reservations
- `users` - User info (premium status)

---

## 🔧 Environment Setup

Required in `backend/.env`:
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your-anon-key
```

---

## 📖 Full Documentation

- **API Reference**: See [MEDICINE_SEARCH_API.md](MEDICINE_SEARCH_API.md)
- **Implementation**: See [IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md)

---

## ✅ Ready for Production!

All features implemented, tested, and documented. 🎉
