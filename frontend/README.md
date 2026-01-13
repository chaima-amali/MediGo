# MediGo

A comprehensive smart medicine reminder and availability tracking mobile application with reports, pharmacy integration, and medicine search capabilities. Built with Flutter for cross-platform mobile development and Python Flask for the backend.

## 📋 Table of Contents
- [Features](#features)
- [Technologies Used](#technologies-used)
- [Project Structure](#project-structure)
- [Backend Setup](#backend-setup)
- [Frontend Setup](#frontend-setup)
- [Running Tests](#running-tests)
- [Features Implemented](#features-implemented)
- [Architecture](#architecture)

## ✨ Features

- **User Authentication & Profile Management**: Secure registration, login, and profile management with local and remote database synchronization
- **Medicine Tracking**: Track medications with detailed information including dosage, frequency, and duration
- **Smart Reminders**: Push notifications for medicine intake schedules using Firebase Cloud Messaging
- **Pharmacy Integration**: Search for nearby pharmacies and check medicine availability
- **Medicine Reservation**: Reserve medicines at pharmacies for pickup
- **Reports & Analytics**: Generate PDF reports of medication history and adherence statistics
- **Medication Logs**: Track medicine intake history with timestamps
- **Offline-First Architecture**: Full offline support with automatic synchronization when online
- **Premium Features**: Enhanced features for premium users
- **Location Services**: Find nearby pharmacies based on user location

## 🛠️ Technologies Used

### Frontend (Mobile App)
- **Flutter SDK**: ^3.9.0 - Cross-platform mobile framework
- **Dart**: Programming language
- **State Management**: 
  - flutter_bloc ^9.1.1 - BLoC/Cubit pattern for state management
  - equatable ^2.0.5 - Value equality for states
- **Database**: 
  - sqflite - Local SQLite database
- **Networking**: 
  - http - REST API communication
- **Firebase**: 
  - firebase_core - Firebase initialization
  - firebase_messaging - Push notifications
  - firebase_crashlytics - Crash reporting
- **Maps & Location**:
  - google_maps_flutter - Map integration
  - geolocator - GPS location services
  - geocoding - Address lookup
- **Notifications**:
  - flutter_local_notifications - Local notifications
  - workmanager - Background task scheduling
- **UI/UX**:
  - fl_chart - Charts and graphs
  - animations - Custom animations
  - shared_preferences - Local storage
- **PDF Generation**: printing - Generate PDF reports
- **Testing**: 
  - flutter_test - Widget testing
  - bloc_test ^10.0.0 - BLoC testing
  - mockito ^5.4.4 - Mocking framework
  - build_runner ^2.4.13 - Code generation

### Backend (API Server)
- **Flask**: Python web framework for building REST APIs
- **Python**: 3.8+
- **Database**: 
  - Supabase (PostgreSQL) - Cloud database
  - SQLAlchemy - ORM
- **Authentication**: JWT tokens
- **Firebase Admin SDK**: Server-side Firebase integration for notifications
- **Flask-CORS**: Cross-origin resource sharing support

## 📁 Project Structure

```
MediGo/
├── frontend/                 # Flutter mobile application
│   ├── lib/
│   │   ├── config/          # App configuration
│   │   ├── controllers/     # State controllers
│   │   ├── data/
│   │   │   ├── models/      # Data models
│   │   │   ├── repositories/# Data repositories
│   │   │   └── services/    # API and sync services
│   │   ├── logic/
│   │   │   └── cubits/      # BLoC cubits for state management
│   │   ├── presentation/    # UI screens and widgets
│   │   ├── l10n/           # Localization files
│   │   └── main.dart        # App entry point
│   ├── test/                # Unit and widget tests
│   ├── android/             # Android-specific files
│   ├── ios/                 # iOS-specific files
│   └── pubspec.yaml         # Flutter dependencies
│
├── backend/                 # Flask backend server
│   ├── app/
│   │   ├── core/           # Core configurations
│   │   ├── models/         # Database models
│   │   ├── routes/         # API endpoints
│   │   ├── schemas/        # Request/Response schemas
│   │   └── services/       # Business logic services
│   ├── main.py             # Flask application entry
│   ├── requirements.txt    # Python dependencies
│   └── firebase-service-account.json  # Firebase credentials
│
└── README.md               # This file
```

## 🚀 Backend Setup

### Prerequisites
- Python 3.8 or higher
- pip (Python package manager)
- Supabase account (for cloud database)
- Firebase project (for notifications)

### Installation Steps

1. **Navigate to backend directory**:
   ```
   cd backend
   ```

2. **Create and activate virtual environment**:
   ```
   # Windows
   python -m venv medigo
   medigo\Scripts\activate

   # macOS/Linux
   python3 -m venv medigo
   source medigo/bin/activate
   ```

3. **Install dependencies**:
   ```
   pip install -r requirements.txt
   ```

4. **Configure environment variables**:
   - Set up Supabase connection in `app/supabase_client.py`
   - Add Firebase service account JSON file as `firebase-service-account.json`

5. **Initialize database**:
   ```
   python init_local_db.py
   ```

### Running the Backend

```bash
# Make sure virtual environment is activated
# Start the Flask server
python main.py

# Server will run on http://localhost:5000
```

The backend provides RESTful API endpoints for:
- User authentication and management
- Medicine tracking (CRUD operations)
- Pharmacy search and reservations
- Medication logs
- Statistics and analytics
- Push notification management

## 📱 Frontend Setup

### Prerequisites
- Flutter SDK 3.9.0 or higher
- Android Studio / Xcode (for mobile development)
- Firebase project configured
- Android SDK / iOS SDK

### Installation Steps

1. **Navigate to frontend directory**:
   ```
   cd frontend
   ```

2. **Install Flutter dependencies**:
   ```
   flutter pub get
   ```

3. **Configure Firebase**:
   - Add `google-services.json` to `android/app/` (for Android)
   - Add `GoogleService-Info.plist` to `ios/Runner/` (for iOS)
   - Update `firebase_options.dart` with your Firebase configuration

4. **Update API endpoint**:
   - Open `lib/data/services/api_service.dart`
   - Update the base URL to point to your backend server

5. **Generate mock files** (for testing):
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

### Running the Frontend

```
# Run on connected device/emulator
flutter run

# Run in debug mode
flutter run --debug

# Run in release mode
flutter run --release

# Run on specific device
flutter run -d <device_id>

# List available devices
flutter devices
```

### Building the App

```
# Build Android APK
flutter build apk

# Build Android App Bundle
flutter build appbundle

# Build iOS
flutter build ios
```

## 🧪 Running Tests

### Frontend Tests

```
cd frontend

# Run all tests
flutter test

# Run specific test file
flutter test test/unit_tests.dart
flutter test test/cubits/medicine_cubit_test.dart
flutter test test/cubits/user_cubit_test.dart

# Run with coverage
flutter test --coverage

# Run tests verbosely
flutter test --verbose
```

**Test Coverage Includes**:
- **Unit Tests**: Model validation, data conversion, utility functions (22 tests)
- **Cubit Tests**: State management for User and Medicine operations (16+ tests)
- **Service Tests**: API service initialization and methods (27 tests)
- **Repository Tests**: Data repository operations (10+ tests)
- **Integration Tests**: End-to-end user flows

### Backend Tests

```
cd backend

# Run backend tests
python test_routes.py
python test_auth.py
python test_notifications.py
```

## 🎯 Features Implemented

### Core Functionality
✅ **User Management**
- User registration with email/phone validation
- Secure login with password hashing
- Profile management (update personal info, location)
- Session management with SharedPreferences
- Remote and local database synchronization

✅ **Medicine Tracking**
- Add/Edit/Delete medicine entries
- Medicine details: name, dosage, frequency, duration, side effects
- Medicine images/photos
- Categorization (pill, syrup, injection, etc.)
- Before/after meal settings
- Start and end dates

✅ **Reminders & Notifications**
- Firebase Cloud Messaging integration
- Local notification scheduling
- Background notification handling
- Customizable reminder times
- Notification sound and vibration

✅ **Pharmacy Features**
- Search pharmacies by location
- Google Maps integration
- Medicine availability checking
- Reserve medicines for pickup
- Pharmacy contact information
- Distance calculation

✅ **Reports & Analytics**
- PDF report generation
- Medicine intake statistics
- Adherence tracking
- Visual charts (fl_chart)
- Export and share reports

✅ **Medication Logs**
- Track taken/missed medications
- Timestamp tracking
- History view
- Log statistics

✅ **Offline Support**
- SQLite local database
- Automatic sync when online
- Conflict resolution
- Queue pending operations
- Connectivity monitoring

✅ **Premium Features**
- Premium user status
- Enhanced analytics
- Additional storage
- Priority support

### Technical Implementation
✅ **Architecture Patterns**
- BLoC/Cubit state management
- Repository pattern for data access
- Service layer for business logic
- Dependency injection
- Clean architecture principles

✅ **Data Synchronization**
- Offline-first approach
- Remote-first with local fallback
- Bi-directional sync
- Conflict resolution strategies

✅ **Error Handling**
- Comprehensive try-catch blocks
- User-friendly error messages
- Crash reporting (Firebase Crashlytics)
- Logging and debugging

✅ **Testing**
- Unit tests for models and utilities
- BLoC tests for state management
- Mock objects with Mockito
- Integration tests
- 75+ tests implemented

## 🏗️ Architecture

### Frontend Architecture
- **Presentation Layer**: UI screens and widgets
- **Logic Layer**: BLoC cubits for state management
- **Data Layer**: Repositories and data sources
- **Service Layer**: API client and sync services

### State Management Flow
```
User Action → Cubit → Repository → API Service/Local DB
                ↓
            State Update
                ↓
            UI Rebuild
```

### Data Flow
```
Remote (Supabase) ←→ Backend API ←→ Mobile App ←→ Local SQLite
                                          ↓
                                    State Management (BLoC)
                                          ↓
                                         UI
```

### Backend Architecture
- **API Layer**: Flask routes and endpoints
- **Service Layer**: Business logic and validation
- **Data Layer**: Supabase/PostgreSQL database
- **External Services**: Firebase for notifications

## 📝 API Documentation

The backend server runs on `http://localhost:5000`

Main API endpoints:
- `/api/auth/*` - Authentication endpoints
- `/api/users/*` - User management
- `/api/medicines/*` - Medicine CRUD
- `/api/pharmacies/*` - Pharmacy search
- `/api/reservations/*` - Medicine reservations
- `/api/medication-logs/*` - Intake logging
- `/api/statistics/*` - Analytics data

## 👥 Contributors

- Development Team: 
    -Amali Chaima
    -Zaibak Douaa
    -Naas Serine

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🔮 Future Enhancements

- [ ] Integration with healthcare providers
- [ ] Medicine interaction warnings
- [ ] Voice reminders
- [ ] Multi-language support
- [ ] Apple Health/Google Fit integration
- [ ] Prescription scanning (OCR)
- [ ] Telemedicine integration
- [ ] Insurance integration

## 📞 Support

For issues, questions, or contributions, please refer to the project documentation or contact the development team.
