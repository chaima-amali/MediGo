# Flutter App Testing with Backend API

This guide explains how to test your Flutter app connected to the Flask backend.

## Prerequisites
✅ Backend server running on http://172.20.10.4:5000
✅ Phone/emulator on same WiFi network
✅ Flutter environment configured

## What Was Updated

### 1. Backend Connection (`frontend/lib/config/environment.dart`)
```dart
flaskBaseUrl = 'http://172.20.10.4:5000/api'
```
Updated to current PC IP address for mobile testing.

### 2. New API Service (`frontend/lib/data/services/api/medicine_search_api_service.dart`)
Created new service to connect to backend's medicine search endpoints:
- `searchMedicines(query)` - Search medicines with pharmacy availability
- `notifyMe(userId, medicineName)` - Record notify-me requests
- `createReservation(...)` - Create reservations (premium only)
- `getUserReservations(userId)` - Get user's reservations
- `getSearchHistory(userId)` - Get search history
- `checkPremiumStatus(userId)` - Check if user is premium

### 3. Updated Search Logic (`frontend/lib/logic/cubits/medicine_search_cubit.dart`)
- **BEFORE**: Used local SQLite database queries
- **AFTER**: Uses Flask backend API via `MedicineSearchApiService`
- All searches now fetch **remote Supabase data** through backend

### 4. Updated Main App (`frontend/lib/main.dart`)
Simplified MedicineSearchCubit initialization to use API service.

## Testing Steps

### Step 1: Check Backend Status
In your PowerShell terminal where Flask is running, verify:
```
 * Running on http://172.20.10.4:5000
```

### Step 2: Run Flutter App
Open a new terminal and run:
```bash
cd frontend
flutter run
```

Choose your device:
- **Android Phone**: Make sure USB debugging is enabled
- **iOS Device**: Make sure device is trusted
- **Emulator**: Start emulator first

### Step 3: Test Medicine Search

#### Test Case 1: Search for Medicine (Found)
1. In Flutter app, navigate to **Search Medicines** screen
2. Type: **"clarithromycin"**
3. **Expected Result**: 
   - Loading indicator appears
   - Backend terminal shows: `POST /api/search/medicines`
   - Results show pharmacies with the medicine
   - Each pharmacy shows: name, price, stock, location

#### Test Case 2: Search for Medicine (Not Found)
1. Search for: **"nonexistent-medicine"**
2. **Expected Result**:
   - "No pharmacies found with this medicine in stock" message
   - Backend logs the search

#### Test Case 3: Create Reservation (Premium User)
**Using Test User ID 26 (premium user)**:
1. Find a medicine with stock
2. Tap on a pharmacy result
3. Select quantity
4. Tap **"Reserve"** button
5. **Expected Result**:
   - Backend terminal shows: `POST /api/reservations`
   - Success message: "Reservation created"
   - Reservation appears in user's reservation list

#### Test Case 4: Verify Backend Communication
Watch the **Flask terminal** while testing. You should see:
```
[API Request] POST /api/search/medicines - User: None, Search: clarithromycin
✅ [SEARCH] Found 4 pharmacies with clarithromycin
172.20.10.4 - - [timestamp] "POST /api/search/medicines HTTP/1.1" 200 -
```

## Debugging

### Problem 1: "Connection Failed" Error
**Symptoms**: Flutter shows "Connection failed. Check if backend is running."

**Solutions**:
1. Verify Flask is running: http://172.20.10.4:5000/api/health
2. Check same WiFi:
   - PC: Connected to WiFi
   - Phone: Connected to SAME WiFi network
3. Test in mobile browser first: http://172.20.10.4:5000/mobile
4. Check firewall:
   ```powershell
   # Allow Flask through Windows Firewall
   netsh advfirewall firewall add rule name="Flask" dir=in action=allow protocol=TCP localport=5000
   ```

### Problem 2: IP Address Changed
If your PC's IP changed (e.g., after reboot):

1. Find new IP:
   ```powershell
   .\backend\get_ip.ps1
   ```

2. Update Flutter config:
   ```dart
   // frontend/lib/config/environment.dart
   flaskBaseUrl = 'http://NEW_IP_HERE:5000/api'
   ```

3. Hot restart Flutter app:
   ```bash
   # In Flutter terminal, press 'R' for hot restart
   R
   ```

### Problem 3: Data Not Showing
**Check Supabase data exists**:
```bash
cd backend
python inspect_supabase_data.py
```

Should show:
- ✅ Premium users found (at least user ID 26)
- ✅ Medicines found (IDs 138-142)
- ✅ Pharmacies found (IDs 1, 3, 4, 5)

### Problem 4: Build Errors
If you see import errors:
```bash
cd frontend
flutter pub get
flutter clean
flutter pub get
```

## API Response Format

### Search Medicines Response
```json
{
  "success": true,
  "message": "Found 4 pharmacies with clarithromycin",
  "data": [
    {
      "medicine_id": 138,
      "medicine_name": "Clarithromycin",
      "generic_name": "Clarithromycin",
      "dosage": "500mg",
      "form": "Tablet",
      "pharmacy_id": 1,
      "pharmacy_name": "City Pharmacy",
      "latitude": 33.5731,
      "longitude": -7.5898,
      "phone": "+212522445566",
      "opening_hours": "Mon-Fri: 9AM-8PM",
      "rating": 4.8,
      "price": 45.50,
      "stock": 50
    }
  ]
}
```

### Create Reservation Response
```json
{
  "success": true,
  "message": "Reservation created successfully",
  "data": {
    "reservation_id": 123,
    "user_id": 26,
    "medicine_id": 138,
    "pharmacy_id": 1,
    "quantity": 2,
    "status": "pending",
    "created_at": "2024-01-15T10:30:00"
  }
}
```

## Test Data Reference

### Premium Test User
- **User ID**: 26
- **Email**: test12@gmail.com
- **Premium Status**: True
- **Can**: Create reservations

### Test Medicines (Available in Supabase)
- **ID 138**: Clarithromycin 500mg Tablet
- **ID 139**: Doxycycline 100mg Capsule  
- **ID 140**: Metronidazole 500mg Tablet
- **ID 141**: Amoxicillin 500mg Capsule
- **ID 142**: Azithromycin 250mg Tablet

### Test Pharmacies
- **ID 1**: City Pharmacy (Casablanca) - Rating: 4.8
- **ID 3**: Green Cross Pharmacy (Rabat) - Rating: 4.5
- **ID 4**: Health Plus (Marrakech) - Rating: 4.2
- **ID 5**: Care Pharmacy (Fes) - Rating: 4.0

## Success Indicators

✅ **Backend Terminal Shows**:
- Incoming POST requests to /api/search/medicines
- SQL queries executing
- 200 status codes

✅ **Flutter App Shows**:
- Search results with pharmacy details
- Medicine information (name, dosage, form)
- Pharmacy information (name, location, rating)
- Stock and price for each pharmacy

✅ **Network Flow**:
Flutter App → HTTP Request → Flask Backend → Supabase Query → Response → Flutter Display

## Next Steps

After successful testing:
1. ✅ Verify all search functionality works
2. ✅ Test reservation creation (premium user)
3. ✅ Check search history recording
4. ✅ Test "Notify Me" feature
5. 🚀 Deploy to production with environment variables

## Troubleshooting Commands

```bash
# Restart Flutter app (hot restart)
cd frontend
flutter run
# Then press 'R' in terminal

# Check Flutter logs
flutter logs

# Clean build if needed
flutter clean
flutter pub get

# Restart backend
# In backend terminal: Ctrl+C
python main.py
```

## Support

If issues persist:
1. Check both terminals (Flask and Flutter) for error messages
2. Test backend directly: http://172.20.10.4:5000/mobile
3. Verify test data exists: `python backend/inspect_supabase_data.py`
4. Check network connectivity between devices
