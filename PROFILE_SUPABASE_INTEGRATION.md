# Profile & User Management - Supabase Integration

## ✅ Completed Implementation

### 1. Profile Data Fetching
- **Profile screen now fetches from Supabase** when online
- Falls back to local database when offline
- Automatic sync from Supabase to local DB on every fetch

### 2. Edit Profile
- User can edit: name, phone, gender, date of birth, location
- **Email is read-only** (cannot be changed)
- Updates are sent to Supabase first, then synced to local DB
- Works offline - updates local DB and syncs to Supabase when connection is restored

### 3. Session Management
- On app start, user data is fetched from Supabase (if online)
- Local database is automatically updated with latest data
- Ensures user always has fresh data from the server

### 4. User Data Flow

```
┌─────────────────────────────────────────────────┐
│          App Launch / Profile View              │
└───────────────────┬─────────────────────────────┘
                    │
                    ▼
          ┌─────────────────┐
          │ Check Internet  │
          └────────┬────────┘
                   │
         ┌─────────┴──────────┐
         │                    │
         ▼ Yes                ▼ No
  ┌──────────────┐     ┌─────────────┐
  │ Fetch from   │     │ Load from   │
  │ Supabase     │     │ Local DB    │
  └──────┬───────┘     └──────┬──────┘
         │                    │
         ▼                    │
  ┌──────────────┐            │
  │ Sync to      │            │
  │ Local DB     │            │
  └──────┬───────┘            │
         │                    │
         └────────┬───────────┘
                  │
                  ▼
          ┌─────────────┐
          │ Display in  │
          │ Profile UI  │
          └─────────────┘
```

### 5. Edit Flow

```
┌─────────────────────────────────────────────────┐
│          User Edits Profile                     │
└───────────────────┬─────────────────────────────┘
                    │
                    ▼
          ┌─────────────────┐
          │ Check Internet  │
          └────────┬────────┘
                   │
         ┌─────────┴──────────┐
         │                    │
         ▼ Yes                ▼ No
  ┌──────────────┐     ┌─────────────┐
  │ Update       │     │ Update      │
  │ Supabase     │     │ Local DB    │
  └──────┬───────┘     │ only        │
         │             └──────┬──────┘
         ▼                    │
  ┌──────────────┐            │
  │ Update       │            │
  │ Local DB     │            │
  └──────┬───────┘            │
         │                    │
         └────────┬───────────┘
                  │
                  ▼
          ┌─────────────┐
          │ Reload &    │
          │ Display     │
          └─────────────┘
```

## 📝 Updated Files

### Backend
- `backend/app/routes/users.py` - Fixed table name typo (user → users)

### Frontend
- `frontend/lib/logic/cubits/user_cubit.dart`:
  - ✅ `getUserById()` - Fetches from Supabase first
  - ✅ `updateUser()` - Updates Supabase then local DB
  - ✅ `updateUserPremium()` - Syncs to Supabase after local update
  - ✅ `restoreSession()` - Fetches fresh data from Supabase on app start

## 🔧 How It Works

### Profile Screen (`profile_page.dart`)
- Uses `BlocBuilder<UserCubit, UserState>` to display user data
- Automatically updates when UserCubit emits new state
- Shows user info: name, email, phone, gender, DOB, location, premium status

### Edit Profile Screen (`edit_profile_page.dart`)
- Pre-fills form with current user data
- Email field is **disabled** (read-only)
- On save: calls `context.read<UserCubit>().updateUser(updatedUser)`
- UserCubit handles Supabase update + local sync automatically

### Edit Password Screen (`Edit_password.dart`)
- Verifies old password matches current password
- Updates password using `context.read<UserCubit>().updateUser(updatedUser)`
- Works with same update flow (Supabase + local)

## 🌐 API Endpoints Used

```
GET  /api/users/{userId}     - Fetch user by ID
PUT  /api/users/{userId}     - Update user information
POST /api/auth/register      - Register new user
POST /api/auth/login         - Login user
```

## 📦 Data Sync Strategy

### Online Mode
1. All reads fetch from Supabase
2. All writes update Supabase first
3. Successful writes sync to local DB
4. User always sees server data

### Offline Mode
1. All reads from local DB
2. All writes to local DB
3. On reconnect, changes sync to Supabase
4. User data stays accessible offline

## ✨ Benefits

1. **Always Fresh Data** - Profile shows latest from Supabase
2. **Offline Support** - Local DB fallback when no internet
3. **Automatic Sync** - No manual sync needed
4. **Seamless UX** - User doesn't notice sync happening
5. **Data Consistency** - Single source of truth (Supabase)

## 🔐 Security Notes

- Passwords are stored but not displayed in profile
- Email cannot be changed (prevents account conflicts)
- User ID from Supabase is authoritative
- Local DB is cache/backup only

## 🎯 Next Steps (If Needed)

### Password Update Endpoint (Optional)
If you want a dedicated password change endpoint:

```python
# backend/app/routes/users.py
@bp.route('/users/<int:user_id>/password', methods=['PUT'])
def update_password(user_id):
    data = request.json
    old_password = data.get('old_password')
    new_password = data.get('new_password')
    
    # Verify old password
    user = execute_query("SELECT * FROM users WHERE user_id = ?", (user_id,))
    if not user or user[0]['password'] != old_password:
        return jsonify({'error': 'Invalid old password'}), 401
    
    # Update password
    execute_update(
        "UPDATE users SET password = ? WHERE user_id = ?",
        (new_password, user_id)
    )
    
    return jsonify({'message': 'Password updated successfully'}), 200
```

### Profile Picture Upload (Future Enhancement)
- Add `profile_picture_url` column to users table
- Upload to Supabase Storage
- Store URL in database

## 🧪 Testing

### Test Profile Load
1. Start app with internet connection
2. Check console logs for "☁️ Fetching user from remote..."
3. Verify user data displays correctly
4. Check Supabase dashboard - user should exist

### Test Profile Edit
1. Go to Edit Profile
2. Change name or phone
3. Save changes
4. Check console logs for "☁️ Updating user on remote..."
5. Verify changes in:
   - Profile UI (immediate)
   - Supabase dashboard (within seconds)
   - Local SQLite database

### Test Offline Mode
1. Disable internet on device
2. View profile - should load from local DB
3. Edit profile - should update local DB only
4. Re-enable internet
5. Edit again - should sync to Supabase

## 📊 Current Status

- ✅ Profile fetches from Supabase
- ✅ Edit profile updates Supabase + local
- ✅ Password change works (through updateUser)
- ✅ Session restore from Supabase
- ✅ Offline fallback functional
- ✅ Auto-sync to local DB
- ✅ Email is read-only
- ⏳ Premium upgrade syncs to Supabase

All user management features now work with Supabase! 🎉
