# Quick test from PC to verify phone can connect
Write-Host "`n🧪 Testing Backend Connection..." -ForegroundColor Cyan
Write-Host "====================================`n" -ForegroundColor Cyan

$ip = "172.20.10.4"
$port = "5000"

Write-Host "Testing URLs your phone will use:`n" -ForegroundColor Yellow

# Test 1: Root endpoint
Write-Host "1️⃣  Testing: http://${ip}:${port}/" -ForegroundColor White
try {
    $response1 = Invoke-WebRequest -Uri "http://${ip}:${port}/" -UseBasicParsing -TimeoutSec 5
    if ($response1.StatusCode -eq 200) {
        Write-Host "   ✅ SUCCESS - Backend reachable" -ForegroundColor Green
    }
} catch {
    Write-Host "   ❌ FAILED - Cannot reach backend" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 2: Notifications API
Write-Host "`n2️⃣  Testing: http://${ip}:${port}/api/notifications/26" -ForegroundColor White
try {
    $response2 = Invoke-WebRequest -Uri "http://${ip}:${port}/api/notifications/26" -UseBasicParsing -TimeoutSec 5
    $data = $response2.Content | ConvertFrom-Json
    if ($response2.StatusCode -eq 200 -and $data.success) {
        Write-Host "   ✅ SUCCESS - API working" -ForegroundColor Green
        Write-Host "   📬 Found $($data.count) notifications" -ForegroundColor Cyan
    }
} catch {
    Write-Host "   ❌ FAILED - API not responding" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n====================================`n" -ForegroundColor Cyan

Write-Host "📱 NOW TEST FROM YOUR PHONE:" -ForegroundColor Yellow
Write-Host "`n1. Connect phone to same Wi-Fi" -ForegroundColor White
Write-Host "2. Open phone browser" -ForegroundColor White
Write-Host "3. Go to: " -NoNewline -ForegroundColor White
Write-Host "http://${ip}:${port}/" -ForegroundColor Cyan
Write-Host "4. Should see: 'Welcome to MediGo Backend API'" -ForegroundColor White

Write-Host "`n✅ If phone can access the URL above, Flutter app will work!`n" -ForegroundColor Green
