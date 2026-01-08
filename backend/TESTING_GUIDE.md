# 🧪 Remote Supabase Testing Guide

## Step 1: Verify Supabase Connection

1. **Check if server is running** - Look for this message:
   ```
   ✅ Supabase client initialized successfully
   📡 Connected to: https://oubdfkmmmjrvyfroqcoy.supabase.co
   ```

2. **Test health endpoint** in browser:
   ```
   http://localhost:5000/api/health
   ```
   
   Expected response:
   ```json
   {
     "status": "healthy",
     "database": "connected",
     "supabase": "connected"
   }
   ```

---

## Step 2: Find Your Existing User ID

### Option A: Using Supabase Dashboard
1. Go to https://supabase.com/dashboard
2. Select your project
3. Go to **Table Editor** → **users** table
4. Find a user and note their `user_id` and `premium` status

### Option B: Using API
Open in browser:
```
http://localhost:5000/api/users
```

This will list all users. Find one with `premium: "yes"` or `premium: "true"`

**Note the user_id** - you'll need it for testing!

---

## Step 3: Test Premium Status

Replace `{user_id}` with the actual user ID from Step 2:

**Browser URL:**
```
http://localhost:5000/api/user/{user_id}/premium-status
```

**Example:**
```
http://localhost:5000/api/user/1/premium-status
```

**Expected Response:**
```json
{
  "success": true,
  "user_id": 1,
  "is_premium": true
}
```

---

## Step 4: Test Medicine Search (Remote Data)

### Using the HTML Test Page:

1. Open: `C:\Users\j\OneDrive\Desktop\MediGo_new\backend\test_api.html`

2. In the **Search Medicines** section:
   - Enter a medicine name (try: "aspirin", "paracetamol", "ibuprofen")
   - Click **Search**

3. Check the response:
   - If medicines found → You'll see medicine details with pharmacy availability
   - If no medicines found → Response will have empty results array

### What to Look For:
```json
{
  "success": true,
  "count": 2,
  "results": [
    {
      "medicine_id": 1,
      "name": "Aspirin 500mg",
      "availability": [
        {
          "pharmacy_id": 5,
          "pharmacy_name": "HealthPlus Pharmacy",
          "price": 12.50,
          "stock": 100
        }
      ]
    }
  ]
}
```

---

## Step 5: Test "Notify Me" (When Medicine Not Found)

### Using HTML Test Page:

1. In the **Notify Me** section:
   - Enter your `user_id` (from Step 2)
   - Enter a medicine name that doesn't exist: "Rare Medicine XYZ"
   - Click **Request Notification**

2. Expected response:
```json
{
  "success": true,
  "message": "You will be notified when 'Rare Medicine XYZ' becomes available",
  "record_id": 456
}
```

3. **Verify in Supabase Dashboard:**
   - Go to **medicine_search_history** table
   - You should see a new record with:
     - `user_id`: your user id
     - `medicine_name`: "Rare Medicine XYZ"
     - `notify_restock`: 1

---

## Step 6: Test Reservation (Premium Only)

### Prerequisites:
- You need a **premium user** (premium = 'yes')
- You need actual medicine and pharmacy IDs from your Supabase

### Find Medicine & Pharmacy IDs:

**Check your Supabase tables:**
1. **medicine** table → note a `medicine_id`
2. **pharmacy** table → note a `pharmacy_id`
3. **pharmacy_medicine** table → ensure this medicine is available at this pharmacy with `stock > 0`

### Using HTML Test Page:

1. In the **Create Reservation** section:
   - User ID: `{your_premium_user_id}`
   - Medicine ID: `{actual_medicine_id}`
   - Pharmacy ID: `{actual_pharmacy_id}`
   - Medicine Name: `{actual_medicine_name}`
   - Quantity: 1
   - Click **Create Reservation**

2. **Success Response:**
```json
{
  "success": true,
  "message": "Reservation created successfully",
  "reservation_id": 999,
  "status": "PENDING"
}
```

3. **Verify in Supabase Dashboard:**
   - Go to **reservation** table
   - You should see a new record

---

## Step 7: Complete Test Flow

### Scenario: User searches, doesn't find, requests notification, then reserves when available

1. **Search for medicine:**
   - Use test page → Search "aspirin"
   - Note if any results found

2. **If no results:**
   - Click "Notify Me" with your user_id
   - Check `medicine_search_history` table in Supabase

3. **If results found:**
   - Note the medicine_id and pharmacy_id
   - Try to create a reservation
   - Check `reservation` table in Supabase

4. **Check search history:**
   - Browser: `http://localhost:5000/api/search/history/{user_id}`
   - Should show all your searches

5. **Check reservations:**
   - Browser: `http://localhost:5000/api/reservations/user/{user_id}`
   - Should show all your reservations

---

## Step 8: Test Non-Premium User (Error Handling)

1. Find a **non-premium user** in Supabase (premium = 'no' or NULL)

2. Try to create reservation with non-premium user_id

3. **Expected Error Response:**
```json
{
  "success": false,
  "error": "Reservation feature is only available for premium users. Please upgrade to premium.",
  "error_code": "PREMIUM_REQUIRED"
}
```

---

## Step 9: Test Insufficient Stock (Error Handling)

1. In test page, try to reserve:
   - Quantity: 999999 (very large number)
   - Use valid medicine/pharmacy IDs

2. **Expected Error Response:**
```json
{
  "success": false,
  "error": "Insufficient stock. Available: 10, Requested: 999999",
  "error_code": "INSUFFICIENT_STOCK"
}
```

---

## Quick Test Checklist

### ✅ Connection Tests
- [ ] Server starts successfully
- [ ] Supabase connection confirmed
- [ ] Health endpoint returns success

### ✅ Read Operations (GET)
- [ ] Get user premium status
- [ ] Get search history
- [ ] Get user reservations

### ✅ Write Operations (POST)
- [ ] Search medicines (reads from Supabase)
- [ ] Notify me (writes to Supabase)
- [ ] Create reservation (writes to Supabase)

### ✅ Business Logic
- [ ] Premium validation works
- [ ] Stock validation works
- [ ] Search returns actual data from Supabase
- [ ] Records are created in Supabase tables

### ✅ Error Handling
- [ ] Non-premium user blocked from reservations
- [ ] Insufficient stock detected
- [ ] Invalid user_id handled
- [ ] Missing medicine handled

---

## Expected Supabase Tables to Check

After testing, verify these tables have new data:

1. **medicine_search_history**
   - Check for your searches
   - Look for `notify_restock = 1` entries

2. **reservation**
   - Check for your reservations
   - Verify `status = 'PENDING'`

3. **users** (should already exist)
   - Verify your user_id exists
   - Check premium status

4. **medicine** (should already exist)
   - Verify medicines exist for searching

5. **pharmacy** (should already exist)
   - Verify pharmacies exist

6. **pharmacy_medicine** (should already exist)
   - Verify medicine-pharmacy relationships
   - Check stock values

---

## Troubleshooting

### "No results found" when searching:
- Check if `medicine` table has data in Supabase
- Try different search terms
- Check if medicine names in DB match your search

### "User not found" error:
- Verify user_id exists in `users` table
- Check exact ID number

### "Medicine not available at this pharmacy":
- Check `pharmacy_medicine` table
- Verify medicine_id and pharmacy_id combination exists
- Verify `stock > 0`

### "Premium required" error:
- Check `users.premium` field in Supabase
- Update to 'yes' or 'true' or '1' or 'active'

---

## Quick SQL Queries for Supabase SQL Editor

### Check if you have test data:
```sql
-- Check users
SELECT user_id, name, email, premium FROM users LIMIT 5;

-- Check medicines
SELECT medicine_id, name, generic_name FROM medicine LIMIT 5;

-- Check pharmacies
SELECT pharmacy_id, name, address FROM pharmacy LIMIT 5;

-- Check medicine availability
SELECT 
  pm.id,
  m.name as medicine_name,
  p.name as pharmacy_name,
  pm.price,
  pm.stock
FROM pharmacy_medicine pm
JOIN medicine m ON pm.medicine_id = m.medicine_id
JOIN pharmacy p ON pm.pharmacy_id = p.pharmacy_id
WHERE pm.stock > 0
LIMIT 5;
```

### Make a user premium:
```sql
UPDATE users 
SET premium = 'yes' 
WHERE user_id = 1;  -- Replace with your user_id
```

### Check your test records:
```sql
-- Your search history
SELECT * FROM medicine_search_history 
WHERE user_id = 1  -- Replace with your user_id
ORDER BY searched_at DESC;

-- Your reservations
SELECT * FROM reservation 
WHERE user_id = 1  -- Replace with your user_id
ORDER BY created_at DESC;
```

---

## Success Criteria

Your app works remotely if:

✅ **All searches query Supabase** (not local data)
✅ **New records appear in Supabase tables**
✅ **Premium validation works from Supabase user table**
✅ **Stock checking works from Supabase pharmacy_medicine table**
✅ **No hardcoded or mock data used**
✅ **All errors handled gracefully**

---

## Next Steps After Testing

Once all tests pass:
1. Document any issues found
2. Test with Flutter frontend
3. Deploy to production
4. Set up monitoring/logging

---

**Ready to test!** 🚀

Start with the HTML test page (`test_api.html`) - it's the easiest way to test all endpoints interactively!
