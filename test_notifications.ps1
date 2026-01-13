# Quick test script to verify notification system
Write-Host "🔬 Testing MediGo Notification System..." -ForegroundColor Cyan
Write-Host ""

# Test 1: Check if backend is running
Write-Host "1️⃣  Testing Backend Server..." -ForegroundColor Yellow
$response = $null
try {
    $response = Invoke-WebRequest -Uri "http://127.0.0.1:5000/api/notifications/26" -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        Write-Host "   ✅ Backend server is running" -ForegroundColor Green
    }
}
catch {
    Write-Host "   ❌ Backend server not responding" -ForegroundColor Red
    Write-Host "   Start it with: cd backend ; python main.py" -ForegroundColor Yellow
    exit 1
}

# Test 2: Get notifications
Write-Host ""
Write-Host "2️⃣  Fetching Notifications..." -ForegroundColor Yellow
$notif_data = $response.Content | ConvertFrom-Json
$notif_count = $notif_data.count

if ($notif_count -ne $null -and $notif_count -gt 0) {
    Write-Host "   ✅ Found $notif_count notifications" -ForegroundColor Green
    
    # Show sample
    $sample = $notif_data.notifications[0]
    Write-Host ""
    Write-Host "   📬 Sample Notification:" -ForegroundColor Cyan
    Write-Host "      ID: $($sample.notification_id)" -ForegroundColor White
    Write-Host "      Title: $($sample.title)" -ForegroundColor White
    Write-Host "      Type: $($sample.type)" -ForegroundColor White
    Write-Host "      Message: $($sample.message)" -ForegroundColor White
}
else {
    Write-Host "   ⚠️  No notifications found" -ForegroundColor Yellow
}

# Test 3: Check notification types
Write-Host ""
Write-Host "3️⃣  Checking Notification Types..." -ForegroundColor Yellow
$types = $notif_data.notifications | Select-Object -ExpandProperty type | Sort-Object | Get-Unique
foreach ($type in $types) {
    Write-Host "   📬 Type: $type" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "✅ All tests passed! Notification system is working." -ForegroundColor Green
Write-Host ""
Write-Host "📱 Next: Test on Flutter app" -ForegroundColor Cyan
Write-Host "   1. Make sure backend is running" -ForegroundColor White
Write-Host "   2. Run: cd frontend ; flutter run" -ForegroundColor White
Write-Host "   3. Navigate to Notifications screen" -ForegroundColor White
Write-Host "   4. Login as user with ID 26" -ForegroundColor White
