# Firebase Setup Instructions for MediGo

## Android Setup

### 1. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project named "MediGo"
3. Enable Google Analytics (optional)

### 2. Add Android App
1. Click "Add app" → Select Android
2. Package name: `com.example.frontend` (or your actual package name)
3. Download `google-services.json`
4. Place it in `android/app/` directory

### 3. Add Firebase SDK
Already added to `build.gradle` files. Verify:

In `android/build.gradle`:
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

In `android/app/build.gradle`:
```gradle
apply plugin: 'com.google.gms.google-services'
```

### 4. Enable Firebase Services
In Firebase Console:
- **Authentication**: Enable Email/Password
- **Cloud Firestore**: Create database (start in test mode)
- **Cloud Messaging**: No additional setup needed
- **Crashlytics**: Enable in console

---

## iOS Setup

### 1. Add iOS App
1. In Firebase Console, add iOS app
2. Bundle ID: `com.example.frontend` (match Xcode)
3. Download `GoogleService-Info.plist`
4. Add to `ios/Runner/` in Xcode

### 2. Update Podfile
File: `ios/Podfile`
```ruby
platform :ios, '13.0'
```

### 3. Install Pods
```bash
cd ios
pod install
```

---

## Verify Setup

Run the app and check console for:
```
✅ Firebase initialized successfully
✅ Crashlytics initialized
✅ FCM initialized successfully
```

## Test FCM

Send a test notification from Firebase Console:
1. Go to Cloud Messaging
2. Send your first message
3. Target: Your app
4. Check device receives notification

---

## Environment Variables

Copy `.env.example` to `.env` and fill in:
```
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=your-anon-key
FLASK_BASE_URL=http://your-server:5000/api
```

## Supabase Setup

### 1. Create Supabase Project
1. Go to [Supabase](https://supabase.com/)
2. Create new project
3. Copy URL and anon key to `.env`

### 2. Create Tables
Run SQL in Supabase SQL Editor:

```sql
-- Users table
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  name TEXT,
  phone TEXT,
  age INTEGER,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Medicines table
CREATE TABLE medicines (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id),
  name TEXT NOT NULL,
  dosage TEXT,
  frequency TEXT,
  start_date DATE,
  end_date DATE,
  active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE medicines ENABLE ROW LEVEL SECURITY;

-- Create policies (adjust as needed)
CREATE POLICY "Users can view own data" ON users
  FOR SELECT USING (auth.uid()::text = id::text);

CREATE POLICY "Users can view own medicines" ON medicines
  FOR SELECT USING (user_id::text = auth.uid()::text);
```

### 3. Enable Realtime
Go to Database → Replication → Enable for tables

---

## Flask Backend Setup

### 1. Install Python Dependencies
```bash
cd backend
pip install -r requirements.txt
```

### 2. Configure Environment
Copy `.env.example` to `.env`:
```
DATABASE_URL=sqlite:///medigo.db
SECRET_KEY=your-secret-key
```

### 3. Run Backend
```bash
python app.py
```

Backend runs on `http://localhost:5000`

### 4. Test API
```bash
curl http://localhost:5000/api/health
```

Expected: `{"status":"healthy","timestamp":"..."}`

---

## Next Steps

1. ✅ Run `flutter pub get` to install dependencies
2. ✅ Set up Firebase (follow above)
3. ✅ Configure Supabase
4. ✅ Start Flask backend
5. ✅ Update environment variables
6. ✅ Run the app: `flutter run`
7. ✅ Run tests: `flutter test`
8. ✅ Build for release

## Distribution

### Internal Testing
- Android: Use Firebase App Distribution
- iOS: Use TestFlight

### Production
- Android: Google Play Console
- iOS: App Store Connect
