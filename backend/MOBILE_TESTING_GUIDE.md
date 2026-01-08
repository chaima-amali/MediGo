# 📱 Test Backend API on Your Phone

## Step 1: Find Your Computer's IP Address

Run this command in PowerShell:

```powershell
ipconfig | Select-String "IPv4"
```

Or use this simple script:

```powershell
# Run: .\get_ip.ps1
$ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -like '*Wi-Fi*' -or $_.InterfaceAlias -like '*Ethernet*' -and $_.IPAddress -notlike '169.*'}).IPAddress
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "📱 YOUR COMPUTER'S IP ADDRESS" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "IP Address: $ip" -ForegroundColor Green
Write-Host ""
Write-Host "Use this URL on your phone:" -ForegroundColor Yellow
Write-Host "http://${ip}:5000" -ForegroundColor White
Write-Host ""
Write-Host "Mobile test page:" -ForegroundColor Yellow
Write-Host "http://${ip}:5000/mobile" -ForegroundColor White
Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
```

**Quick way:**
- Look for your WiFi IP (usually starts with 192.168.x.x or 10.x.x.x)

---

## Step 2: Make Sure Server is Running

The server should already be running and show:
```
* Running on all addresses (0.0.0.0)
* Running on http://127.0.0.1:5000
* Running on http://172.20.10.4:5000  ← YOUR IP
```

If server is not running:
```powershell
cd C:\Users\j\OneDrive\Desktop\MediGo_new\backend
python main.py
```

---

## Step 3: Connect Phone to Same WiFi

⚠️ **IMPORTANT**: Your phone must be on the **SAME WiFi network** as your computer!

Check:
- Computer WiFi: [Your WiFi Name]
- Phone WiFi: [Must be the same]

---

## Step 4: Access from Phone

### Option A: Mobile Test Page (Recommended)
1. Open phone browser (Chrome/Safari)
2. Type: `http://YOUR_IP:5000/mobile`
   - Example: `http://192.168.1.100:5000/mobile`
3. Tap "Change Server URL" and enter: `http://YOUR_IP:5000/api`
4. Test all features with the buttons

### Option B: Direct API Endpoints
Test in phone browser:
- Health: `http://YOUR_IP:5000/api/health`
- Users: `http://YOUR_IP:5000/api/users`
- Premium: `http://YOUR_IP:5000/api/user/26/premium-status`

---

## Step 5: Troubleshooting

### ❌ "Can't connect" or "Connection refused"

**1. Check Firewall:**
```powershell
# Allow Python through Windows Firewall
New-NetFirewallRule -DisplayName "Python Flask" -Direction Inbound -Program "C:\Users\j\anaconda3\python.exe" -Action Allow
```

**2. Check if port 5000 is open:**
```powershell
netstat -an | Select-String "5000"
```
Should show: `0.0.0.0:5000` or `*:5000`

**3. Try disabling Windows Firewall temporarily:**
- Settings → Windows Security → Firewall → Turn off (for testing only)

**4. Verify same network:**
- Computer IP starts with: `192.168.x.x`
- Phone IP should start with same: `192.168.x.x`

### ❌ "Connection timeout"

- Restart the Flask server
- Make sure antivirus isn't blocking
- Try using your computer's name instead: `http://YOUR-PC-NAME:5000/mobile`

---

## Quick Test Commands

### On Computer (PowerShell):
```powershell
# Get your IP
ipconfig | Select-String "IPv4"

# Test server locally
Invoke-WebRequest http://localhost:5000/api/health

# See who's connecting
# (Watch the terminal running Flask - it shows incoming requests)
```

### On Phone (Browser):
1. Go to: `http://YOUR_IP:5000/mobile`
2. Tap "Test Connection"
3. If green "Connected ✓" → Success! 🎉
4. If red "Disconnected ✗" → Check troubleshooting above

---

## Expected Results

### ✅ When working correctly:

**On Phone Screen:**
```
Connected ✓

Health Check: 
{
  "status": "healthy",
  "database": "connected",
  "supabase": "connected"
}
```

**In Computer Terminal:**
```
192.168.1.xxx - - [08/Jan/2026 19:30:15] "GET /api/health HTTP/1.1" 200 -
```
(This shows your phone's IP making requests!)

---

## Full Test Flow on Phone

1. **Open mobile test page**
   - `http://YOUR_IP:5000/mobile`

2. **Test Connection**
   - Tap "Test Connection" button
   - Should show green "Connected ✓"

3. **Search Medicine**
   - Enter: "clarithromycin"
   - Tap "Search"
   - Should show results with pharmacy availability

4. **Check Premium Status**
   - User ID: 26
   - Tap "Check Status"
   - Should show: `"is_premium": true`

5. **Create Reservation**
   - Use pre-filled values (User: 26, Medicine: 138, Pharmacy: 1)
   - Tap "Create Reservation"
   - Should succeed if user is premium!

---

## Security Note

⚠️ This setup is for **LOCAL TESTING ONLY** on your home network.

For production:
- Use HTTPS
- Add authentication
- Deploy to proper server
- Don't expose to public internet

---

## Quick Reference

### Your Info (from earlier inspection):
- **Premium User ID:** 26 (test12@gmail.com)
- **Medicine IDs:** 138, 139, 140, 141, 142
- **Pharmacy IDs:** 1, 3, 4, 5
- **Search terms:** clarithromycin, doxycycline, metronidazole

### Server URLs:
- **Health:** `http://YOUR_IP:5000/api/health`
- **Mobile Test:** `http://YOUR_IP:5000/mobile`
- **API Base:** `http://YOUR_IP:5000/api`

---

## Next Steps

Once phone testing works:
1. ✅ Test all features (search, reserve, notify)
2. ✅ Verify data in Supabase dashboard
3. ✅ Test error cases (non-premium user, etc.)
4. 🚀 Ready to integrate with Flutter app!

---

**Ready to test!** 📱
Follow Step 1 first to get your IP address!
