# MediGo - Quick Start Guide

## 🚀 Get Started in 5 Minutes

### 1. Install Dependencies
```bash
cd frontend
flutter pub get
```

### 2. Set Up Firebase (Required)

#### Download Configuration Files
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select/Create "MediGo" project
3. Download `google-services.json` (Android) → Place in `android/app/`
4. Download `GoogleService-Info.plist` (iOS) → Place in `ios/Runner/`

### 3. Configure Environment (Optional for now)
```bash
# Frontend
cd frontend
cp .env.example .env
# Edit .env with your actual values (can skip for local testing)
```

### 4. Run the App
```bash
cd frontend
flutter run
```

The app will run with:
- ✅ Local SQLite database (works offline)
- ✅ Firebase services (FCM, Crashlytics)
- ⚠️ Remote sync disabled (until backend is configured)

---

## 🔧 Full Setup (For Production)

### Backend Setup

#### 1. Flask Backend
```bash
cd backend
pip install -r requirements.txt
cp .env.example .env
python app.py
```
Backend runs on `http://localhost:5000`

#### 2. Supabase Setup
1. Create project at [supabase.com](https://supabase.com)
2. Run SQL from `backend/supabase_schema.sql`
3. Copy URL and anon key to `frontend/.env`

### Frontend Configuration

Update `frontend/.env`:
```env
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=your-anon-key
FLASK_BASE_URL=http://localhost:5000/api
IS_PRODUCTION=false
```

### Initialize Background Jobs
Background jobs will auto-start when you run the app. They handle:
- 🔄 Data sync every 30 minutes
- 💊 Medication reminders every 15 minutes
- 💾 Daily database backups
- 🗑️ Weekly cleanup

---

## 📱 Testing

### Run Unit Tests
```bash
cd frontend
dart run build_runner build  # First time only
flutter test
```

### Run Integration Tests
```bash
cd frontend
flutter test integration_test/app_test.dart
```

### Test Backend API
```bash
curl http://localhost:5000/api/health
# Expected: {"status":"healthy","timestamp":"..."}
```

---

## 🔍 Verify Everything Works

### Check Console Output
When you run the app, you should see:
```
✅ Firebase initialized successfully
✅ Crashlytics initialized
✅ Database initialized successfully
✅ Supabase initialized successfully
✅ API Service initialized successfully
✅ FCM initialized successfully
✅ Background jobs initialized
```

### Test Features
1. **Offline Mode**: Disable network → Add medicine → Works!
2. **Notifications**: Send test FCM from Firebase Console
3. **Sync**: Enable network → Data syncs automatically
4. **Background Jobs**: Wait 30 min → Check sync happened

---

## 📚 Architecture Overview

```
┌─────────────────────────────────────────────────┐
│              MediGo Flutter App                  │
├─────────────────────────────────────────────────┤
│                                                  │
│  ┌──────────────┐  ┌──────────────┐            │
│  │   UI Layer   │  │  BloC/Cubit  │            │
│  │  (Screens)   │◄─┤State Mgmt(12)│            │
│  └──────────────┘  └──────────────┘            │
│          ▲                 ▲                     │
│          │                 │                     │
│  ┌───────┴─────────────────┴──────────┐        │
│  │        Repositories Layer           │        │
│  └─────────────────────────────────────┘        │
│          ▲                 ▲                     │
│          │                 │                     │
│  ┌───────┴──────┐  ┌──────┴───────────┐        │
│  │Local Database│  │  Remote Services  │        │
│  │   (SQLite)   │  │- Supabase         │        │
│  │              │  │- Flask API        │        │
│  │              │  │- Firebase         │        │
│  └──────────────┘  └───────────────────┘        │
│          ▲                 ▲                     │
│          └─────────┬───────┘                     │
│              ┌─────┴──────┐                     │
│              │ Sync Service│                     │
│              └────────────┘                      │
│                                                  │
│  Background Jobs: Sync, Reminders, Backup       │
└─────────────────────────────────────────────────┘
```

### Data Flow
1. **User Action** → UI → Cubit
2. **Cubit** → Repository → Local DB (instant save)
3. **Sync Service** → Checks connectivity
4. **If Online** → Push to remote (Firebase/Supabase/Flask)
5. **Background Jobs** → Periodic sync every 30 min

---

## 🛠️ Common Issues

### "Firebase not initialized"
**Solution**: Add Firebase config files (`google-services.json`, `GoogleService-Info.plist`)

### "Supabase connection failed"
**Solution**: Check `.env` file has correct `SUPABASE_URL` and `SUPABASE_ANON_KEY`

### "Backend API unreachable"
**Solution**: 
1. Check Flask backend is running: `python backend/app.py`
2. Verify `FLASK_BASE_URL` in `.env`

### Tests failing
**Solution**: Generate mocks first: `dart run build_runner build`

---

## 📊 Submission Checklist

Ready to submit? Verify all requirements:

- [x] ✅ Firebase Cloud Messaging integrated
- [x] ✅ Firebase Crashlytics integrated
- [x] ✅ Custom Backend implemented (Flask + Supabase)
- [x] ✅ BloC/Cubit State Management (12 Cubits)
- [x] ✅ Background Jobs (4 periodic tasks)
- [x] ✅ Fully localized (Arabic, English, French)
- [ ] ⏳ App distributed (Setup ready, need to upload)
- [x] ✅ Unit testing implemented
- [x] ✅ Integration testing implemented
- [ ] ⏳ User testing (App ready, need testers)

---

## 🎯 Next Steps

1. **For Local Development**: You're all set! Just run `flutter run`

2. **For Production**:
   - Set up Supabase project
   - Deploy Flask backend (Heroku/AWS)
   - Configure environment variables
   - Build release: `flutter build apk --release`

3. **For Submission**:
   - Distribute to beta testers (Firebase App Distribution)
   - Collect user feedback (Google Forms)
   - Complete testing documentation

---

## 📖 Documentation

- [SETUP_INSTRUCTIONS.md](SETUP_INSTRUCTIONS.md) - Detailed setup guide
- [REMOTE_DATABASE_IMPLEMENTATION.md](REMOTE_DATABASE_IMPLEMENTATION.md) - Implementation checklist
- [README.md](README.md) - Project overview

## 🆘 Need Help?

Check these files for detailed information:
- Firebase setup issues → [SETUP_INSTRUCTIONS.md](SETUP_INSTRUCTIONS.md#firebase-setup)
- Backend API → [backend/app.py](backend/app.py)
- Sync logic → [frontend/lib/data/services/sync_service.dart](frontend/lib/data/services/sync_service.dart)
- Database schema → [backend/supabase_schema.sql](backend/supabase_schema.sql)
