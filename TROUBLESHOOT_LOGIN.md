# Test Backend Login

## Quick Test

Open your browser or use PowerShell to test the backend login:

### Using PowerShell:
```powershell
$body = @{
    email = "test1@gmail.com"
    password = "12345678"
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://172.20.10.4:5000/api/auth/login" `
    -Method POST `
    -ContentType "application/json" `
    -Body $body
```

### Using Browser (http://172.20.10.4:5000/mobile):
Open browser dev tools (F12), go to Console tab, and run:
```javascript
fetch('http://172.20.10.4:5000/api/auth/login', {
  method: 'POST',
  headers: {'Content-Type': 'application/json'},
  body: JSON.stringify({
    email: 'test1@gmail.com',
    password: '12345678'
  })
})
.then(r => r.json())
.then(d => console.log('Login result:', d))
.catch(e => console.error('Error:', e));
```

## Check User in Supabase

Let's verify the user exists and check the password:

```powershell
cd backend
python -c "from app.supabase_client import supabase; import hashlib; email='test1@gmail.com'; password='12345678'; hashed=hashlib.sha256(password.encode()).hexdigest(); result=supabase.table('users').select('*').eq('email', email).execute(); print(f'User found: {len(result.data)} users'); print(f'User data: {result.data}'); print(f'Hashed password: {hashed}'); print(f'Matches: {result.data[0][\"password\"] == hashed if result.data else False}')"
```

## Common Issues

### Issue 1: Password Mismatch
The password in Supabase must be **SHA256 hashed**. If you created the user manually in Supabase, make sure you hashed the password:

```python
import hashlib
password = "12345678"
hashed = hashlib.sha256(password.encode()).hexdigest()
print(hashed)  # This is what should be in Supabase
```

### Issue 2: API Client Not Initialized
Check Flutter logs for API client initialization:
```
✅ API Client initialized: http://172.20.10.4:5000/api
```

### Issue 3: Wrong Base URL
The Flutter app might be using the wrong URL. Check [environment.dart](frontend/lib/config/environment.dart):
- Should be: `http://172.20.10.4:5000/api`
- NOT: `http://172.20.10.4:5000` (missing /api)
- NOT: `http://10.66.113.125:5000/api` (old IP)

### Issue 4: Network Error
If Flutter can't reach backend:
1. Make sure Flask is running
2. Make sure phone is on same WiFi
3. Test in browser first: http://172.20.10.4:5000/mobile

## Debug Steps

1. **Check Backend is Running**:
   ```
   ✅ Backend should show: * Running on http://172.20.10.4:5000
   ```

2. **Check User Exists in Supabase**:
   ```bash
   cd backend
   python inspect_supabase_data.py
   ```

3. **Test API Directly** (browser):
   - Open: http://172.20.10.4:5000/mobile
   - Use the test interface to try login

4. **Check Flutter Logs**:
   Look for:
   ```
   🔐 Attempting remote login via API...
   ✅ Remote login successful
   ```
   
   Or error messages:
   ```
   ❌ Remote login error: <error message>
   ```

5. **Watch Backend Terminal**:
   When you try to login from Flutter, you should see:
   ```
   POST /api/auth/login HTTP/1.1" 200 -
   ```

## Solution: Test Login with Correct Password

If the user exists but login fails, the password is likely wrong or not hashed correctly.

### Get the correct hashed password:
```powershell
cd backend
python -c "import hashlib; print(hashlib.sha256('12345678'.encode()).hexdigest())"
```

### Update in Supabase:
1. Go to your Supabase dashboard
2. Find the `users` table
3. Find user with email `test1@gmail.com`
4. Update the `password` column with the hashed value from above

OR create a test user with backend API:
```javascript
// In browser console at http://172.20.10.4:5000/mobile
fetch('http://172.20.10.4:5000/api/auth/register', {
  method: 'POST',
  headers: {'Content-Type': 'application/json'},
  body: JSON.stringify({
    name: 'Test User',
    email: 'testuser@gmail.com',
    phone: '0612345678',
    password: '12345678',
    gender: 'male',
    dob: '1990-01-01',
    latitude: 33.5731,
    longitude: -7.5898,
    location_name: 'Casablanca',
    premium: false
  })
})
.then(r => r.json())
.then(d => console.log('Register result:', d));
```

Then login with:
- Email: testuser@gmail.com  
- Password: 12345678
