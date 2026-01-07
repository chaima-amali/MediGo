# API Services - Feature-Based Organization

This directory contains feature-based API services for better code organization and maintainability.

## 📁 Structure

```
api/
├── api_client.dart                  # Base HTTP client (GET, POST, PUT, DELETE)
├── auth_api_service.dart            # Authentication endpoints
├── user_api_service.dart            # User CRUD operations
├── medicine_api_service.dart        # Medicine management
├── pharmacy_api_service.dart        # Pharmacy search
├── reservation_api_service.dart     # Reservation management
├── medication_log_api_service.dart  # Medication logging
├── statistics_api_service.dart      # Statistics & analytics
└── sync_api_service.dart            # Data synchronization
```

## 🎯 Benefits

### 1. **Separation of Concerns**
Each feature has its own service file, making it easier to:
- Find specific functionality
- Understand what each service does
- Maintain and update features independently

### 2. **Better Code Organization**
- No more giant monolithic API service file
- Clear boundaries between different features
- Easier to navigate and understand

### 3. **Improved Maintainability**
- Changes to one feature don't affect others
- Easier to test individual features
- Simpler debugging

### 4. **Scalability**
- Easy to add new features
- Simple to extend existing features
- Clear pattern for future development

## 💡 Usage

### Option 1: Use Feature-Specific Services (Recommended for New Code)

```dart
import 'package:frontend/data/services/api/auth_api_service.dart';
import 'package:frontend/data/services/api/medicine_api_service.dart';

// Initialize
final authService = AuthApiService();
final medicineService = MedicineApiService();

// Use
await authService.login(email, password);
await medicineService.getMedicines(userId);
```

### Option 2: Use Unified API Service (Backward Compatible)

```dart
import 'package:frontend/data/services/api_service.dart';

final api = ApiService();
api.initialize();

// Access feature-specific services
await api.auth.login(email, password);
await api.medicines.getMedicines(userId);
await api.pharmacies.searchPharmacies(lat: 40.7, lng: -74.0);

// Or use backward-compatible methods
await api.login(email, password);
await api.getMedicines(userId);
```

## 📚 Services Overview

### 1. ApiClient
**Purpose**: Base HTTP client with generic methods  
**Methods**:
- `get()` - GET requests
- `post()` - POST requests
- `put()` - PUT requests
- `delete()` - DELETE requests
- `setAuthToken()` - Set auth token
- `clearAuthToken()` - Clear auth token

### 2. AuthApiService
**Purpose**: User authentication  
**Methods**:
- `register()` - Register new user
- `login()` - Login user
- `verifyUser()` - Check if user exists
- `setAuthToken()` - Set auth token
- `clearAuthToken()` - Clear auth token

### 3. UserApiService
**Purpose**: User management  
**Methods**:
- `createUser()` - Create new user
- `getUser()` - Get user by ID
- `updateUser()` - Update user info
- `updateFCMToken()` - Update push notification token

### 4. MedicineApiService
**Purpose**: Medicine management  
**Methods**:
- `getMedicines()` - Get all medicines
- `createMedicine()` - Add new medicine
- `updateMedicine()` - Update medicine
- `deleteMedicine()` - Delete medicine

### 5. PharmacyApiService
**Purpose**: Pharmacy search and info  
**Methods**:
- `searchPharmacies()` - Search pharmacies by location
- `getPharmacy()` - Get pharmacy details

### 6. ReservationApiService
**Purpose**: Medicine reservations  
**Methods**:
- `createReservation()` - Create reservation
- `getReservations()` - Get user reservations
- `updateReservationStatus()` - Update status

### 7. MedicationLogApiService
**Purpose**: Medication intake tracking  
**Methods**:
- `logMedicationIntake()` - Log medication taken
- `getMedicationLogs()` - Get medication history

### 8. StatisticsApiService
**Purpose**: Analytics and statistics  
**Methods**:
- `getAdherenceStats()` - Get adherence statistics

### 9. SyncApiService
**Purpose**: Data synchronization  
**Methods**:
- `syncData()` - Sync local and remote data

## 🔄 Migration Guide

### For Existing Code

**No changes required!** The main `ApiService` maintains backward compatibility with all existing methods.

### For New Code

Use the feature-specific approach:

**Before:**
```dart
final api = ApiService();
await api.login(email, password);
await api.getMedicines(userId);
```

**After (Recommended):**
```dart
final api = ApiService();
await api.auth.login(email, password);
await api.medicines.getMedicines(userId);
```

## 🛠️ Adding New Features

To add a new feature:

1. Create a new service file in `api/` directory
2. Follow the naming convention: `feature_api_service.dart`
3. Import and use `ApiClient` for HTTP requests
4. Add the service to main `ApiService` class
5. Update this README

**Example:**

```dart
// notification_api_service.dart
import 'api_client.dart';

class NotificationApiService {
  final ApiClient _client = ApiClient();

  Future<List<dynamic>> getNotifications(int userId) async {
    final response = await _client.get(
      '/notifications',
      queryParameters: {'user_id': userId},
    );
    return response.data as List<dynamic>;
  }
}

// In api_service.dart
late final NotificationApiService notifications = NotificationApiService();
```

## 🧪 Testing

Each service can be tested independently:

```dart
// auth_api_service_test.dart
void main() {
  test('Login should return user data', () async {
    final authService = AuthApiService();
    final result = await authService.login('test@example.com', 'password');
    expect(result['success'], true);
  });
}
```

## 📖 Best Practices

1. **Use feature-specific services** for new code
2. **Keep services focused** - one service per feature
3. **Document all methods** with clear comments
4. **Handle errors** appropriately in each service
5. **Test services** independently

## 🔗 Related Files

- `../api_service.dart` - Main unified API service
- `../../repositories/` - Repository layer for data management
- `../../models/` - Data models
- `../../../logic/cubits/` - Business logic layer

## 📝 Notes

- All services use the same `ApiClient` instance
- Authentication token is shared across all services
- Error handling is centralized in `ApiClient`
- Services are lightweight and focused on API communication only
