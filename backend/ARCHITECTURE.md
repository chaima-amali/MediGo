# System Architecture & Flow Diagrams

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                         MEDICINE SEARCH SYSTEM                       │
└─────────────────────────────────────────────────────────────────────┘

┌──────────────┐         ┌──────────────┐         ┌──────────────┐
│              │         │              │         │              │
│   Flutter    │◄───────►│   Backend    │◄───────►│   Supabase   │
│   Frontend   │  HTTP   │     API      │  SDK    │  PostgreSQL  │
│              │         │   (Flask)    │         │              │
└──────────────┘         └──────────────┘         └──────────────┘
                                │
                                │
                    ┌───────────┴───────────┐
                    │                       │
              ┌─────▼─────┐           ┌────▼────┐
              │  Search   │           │Reserve  │
              │  Service  │           │ Service │
              └───────────┘           └─────────┘
```

---

## 🔄 Medicine Search Flow

```
┌─────────┐
│  User   │
│ Enters  │
│ Search  │
└────┬────┘
     │
     ▼
┌─────────────────────┐
│ POST /api/search/   │
│     medicines       │
└────┬────────────────┘
     │
     ▼
┌─────────────────────────┐
│ MedicineSearchService   │
│  .search_medicines()    │
└────┬────────────────────┘
     │
     ├─► Query: medicine table
     │   WHERE name ILIKE '%query%'
     │
     ├─► For each medicine:
     │   Query: pharmacy_medicine
     │   JOIN pharmacy
     │   WHERE stock > 0
     │
     ▼
┌─────────────────────────┐
│  Return Results:        │
│  - Medicine info        │
│  - Pharmacy details     │
│  - Price & Stock        │
└─────────────────────────┘
```

---

## 📬 Notify Me Flow

```
┌─────────┐
│  User   │
│Searches │
│ No      │
│Results  │
└────┬────┘
     │
     ▼
┌─────────────────────┐
│ Clicks "Notify Me"  │
└────┬────────────────┘
     │
     ▼
┌─────────────────────┐
│ POST /api/search/   │
│     notify-me       │
└────┬────────────────┘
     │
     ▼
┌──────────────────────────────┐
│ MedicineSearchService        │
│ .record_search_not_found()   │
└────┬─────────────────────────┘
     │
     ▼
┌──────────────────────────────┐
│ INSERT INTO                  │
│ medicine_search_history      │
│ SET notify_restock = 1       │
└────┬─────────────────────────┘
     │
     ▼
┌─────────────────────┐
│ Return confirmation │
│ "You will be        │
│ notified..."        │
└─────────────────────┘
```

---

## 🎫 Reservation Flow (Premium Only)

```
┌─────────┐
│  User   │
│ Tries   │
│Reserve  │
└────┬────┘
     │
     ▼
┌─────────────────────┐
│ POST /api/          │
│   reservations      │
└────┬────────────────┘
     │
     ▼
┌────────────────────────────┐
│ Step 1: Check Premium      │
│ Query: users.premium       │
└────┬───────────────────────┘
     │
     ├─► Not Premium? ──► Return 403 Error
     │                    "Premium required"
     │
     ▼
┌────────────────────────────┐
│ Step 2: Check Stock        │
│ Query: pharmacy_medicine   │
└────┬───────────────────────┘
     │
     ├─► Stock < quantity? ──► Return 409 Error
     │                         "Insufficient stock"
     │
     ▼
┌────────────────────────────┐
│ Step 3: Create Records     │
│ INSERT INTO:               │
│ - medicine_search_history  │
│ - reservation              │
└────┬───────────────────────┘
     │
     ▼
┌─────────────────────┐
│ Return success      │
│ reservation_id      │
└─────────────────────┘
```

---

## 🗄️ Database Schema Relationships

```
┌──────────────┐
│    users     │
│──────────────│
│ user_id (PK) │
│ premium      │◄─────┐
└──────────────┘      │
                      │
┌──────────────┐      │       ┌──────────────────────┐
│   medicine   │      │       │ medicine_search_     │
│──────────────│      │       │      history         │
│medicine_id PK│◄─────┼───────│──────────────────────│
│ name         │      │       │ id (PK)              │
│ dosage       │      └───────│ user_id (FK)         │
└──────┬───────┘              │ medicine_name        │
       │                      │ notify_restock       │
       │                      └──────────────────────┘
       │
       │
       ▼
┌──────────────────┐         ┌──────────────┐
│pharmacy_medicine │         │   pharmacy   │
│──────────────────│         │──────────────│
│ id (PK)          │         │pharmacy_id PK│
│ pharmacy_id (FK) │────────►│ name         │
│ medicine_id (FK) │         │ address      │
│ price            │         │ phone        │
│ stock            │         └──────────────┘
└──────────────────┘
       ▲
       │
       │
┌──────────────────┐
│   reservation    │
│──────────────────│
│reservation_id PK │
│ user_id (FK)     │
│ pharmacy_id (FK) │
│ medicine_name    │
│ quantity         │
│ status           │
└──────────────────┘
```

---

## 🔐 Premium Validation Logic

```
┌────────────────────┐
│  Check Premium     │
│  Status            │
└────┬───────────────┘
     │
     ▼
┌─────────────────────────────────┐
│ Query Supabase:                 │
│ SELECT premium FROM users       │
│ WHERE user_id = ?               │
└────┬────────────────────────────┘
     │
     ▼
┌─────────────────────────────────┐
│ premium_status.lower() in:      │
│ ['yes', 'true', '1', 'active']  │
└────┬────────────────────────────┘
     │
     ├─► True  ──► Allow Reservation
     │
     └─► False ──► Return 403
                   "Premium required"
```

---

## 📊 API Response Flow

```
Request
   │
   ▼
┌──────────────────┐
│ Pydantic Schema  │  ← Validate input
│ Validation       │
└────┬─────────────┘
     │ ✅ Valid
     ▼
┌──────────────────┐
│ Service Layer    │  ← Business logic
│ (Async)          │     Premium check
└────┬─────────────┘     Stock check
     │
     ▼
┌──────────────────┐
│ Supabase Query   │  ← Remote database
│ (PostgreSQL)     │
└────┬─────────────┘
     │
     ├─► Success ──► 200/201 + Data
     │
     └─► Error ───► 400/403/404/409/500
                    + Error message
                    + Error code
```

---

## 🎯 Error Handling Flow

```
┌─────────────────┐
│  Exception      │
│  Occurs         │
└────┬────────────┘
     │
     ▼
┌───────────────────────────────┐
│ Check Error Type:             │
└───┬───────────────────────────┘
    │
    ├─► "premium" in message
    │   Return: 403 PREMIUM_REQUIRED
    │
    ├─► "insufficient stock" in message
    │   Return: 409 INSUFFICIENT_STOCK
    │
    ├─► "not available" in message
    │   Return: 404 NOT_AVAILABLE
    │
    ├─► Validation Error
    │   Return: 400 + details
    │
    └─► Other
        Return: 500 + error message
```

---

## 🔄 Service Layer Methods

```
MedicineSearchService
│
├─► search_medicines(query)
│   └─► Returns: List of medicines with availability
│
├─► record_search_not_found(user_id, medicine_name)
│   └─► Returns: Confirmation record
│
├─► check_user_premium_status(user_id)
│   └─► Returns: Boolean (is_premium)
│
├─► create_reservation(user_id, medicine_id, ...)
│   └─► Returns: Reservation record
│
├─► get_user_reservations(user_id)
│   └─► Returns: List of reservations
│
└─► get_search_history(user_id)
    └─► Returns: List of search history
```

---

## 🌐 API Endpoints Map

```
/api
│
├─► /search
│   ├─► POST /medicines         (Search medicines)
│   ├─► POST /notify-me         (Notify me)
│   └─► GET  /history/{id}      (Get history)
│
├─► /reservations
│   ├─► POST /                  (Create reservation)
│   └─► GET  /user/{id}         (Get user reservations)
│
└─► /user/{id}
    └─► GET  /premium-status    (Check premium)
```

---

## 💾 Data Flow Summary

```
Frontend (Flutter)
        ↓
    HTTP Request
        ↓
API Route (Flask Blueprint)
        ↓
Request Validation (Pydantic)
        ↓
Service Layer (Business Logic)
        ↓
Supabase Client (Python SDK)
        ↓
PostgreSQL (Remote Database)
        ↓
Response
        ↓
JSON to Frontend
```

---

## 🎨 Technology Stack

```
┌─────────────────────────────────┐
│         Frontend Layer          │
│    Flutter/Dart (Mobile App)    │
└────────────┬────────────────────┘
             │
             │ HTTP/REST
             │
┌────────────▼────────────────────┐
│        Backend Layer            │
│  Python + Flask + Async         │
│  Pydantic (Validation)          │
│  CORS (Cross-Origin)            │
└────────────┬────────────────────┘
             │
             │ Supabase SDK
             │
┌────────────▼────────────────────┐
│       Database Layer            │
│  Supabase (PostgreSQL)          │
│  Remote, Cloud-hosted           │
└─────────────────────────────────┘
```

---

## ✅ Implementation Checklist

```
✅ Remote Search
   ├─► Case-insensitive matching
   ├─► Pharmacy join queries
   ├─► Stock filtering
   └─► Structured responses

✅ Notify Me
   ├─► Search history tracking
   ├─► Restock flag
   └─► Confirmation message

✅ Premium Reservations
   ├─► Premium validation
   ├─► Stock validation
   ├─► Remote storage
   └─► Error handling

✅ Architecture
   ├─► Service layer
   ├─► Route handlers
   ├─► Models
   ├─► Schemas
   └─► Documentation
```

---

This visual guide helps understand the complete system architecture and data flow! 🎯
