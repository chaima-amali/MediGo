# Medicine Search API - PowerShell Test Script
# Run this to test all API endpoints

$baseUrl = "http://localhost:5000"

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "🧪 Medicine Search & Reservation API Tests (PowerShell)" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

# Test 1: Health Check
Write-Host "`n✅ Testing Health Check..." -ForegroundColor Green
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/health" -Method Get
    Write-Host "Status: $($response.status)" -ForegroundColor White
    Write-Host ($response | ConvertTo-Json -Depth 5)
} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
}

# Test 2: Root Endpoint
Write-Host "`n✅ Testing Root Endpoint..." -ForegroundColor Green
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/" -Method Get
    Write-Host "API Name: $($response.name)" -ForegroundColor White
    Write-Host ($response | ConvertTo-Json -Depth 5)
} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
}

# Test 3: Medicine Search
Write-Host "`n🔍 Testing Medicine Search..." -ForegroundColor Green
try {
    $body = @{
        search_query = "aspirin"
    } | ConvertTo-Json

    $response = Invoke-RestMethod -Uri "$baseUrl/api/search/medicines" `
        -Method Post `
        -ContentType "application/json" `
        -Body $body
    
    Write-Host "Success: $($response.success)" -ForegroundColor White
    Write-Host "Results Count: $($response.count)" -ForegroundColor White
    Write-Host ($response | ConvertTo-Json -Depth 10)
} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $errorBody = $reader.ReadToEnd()
        Write-Host "Error Details: $errorBody" -ForegroundColor Yellow
    }
}

# Test 4: Check Premium Status
Write-Host "`n👑 Testing Premium Status Check..." -ForegroundColor Green
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/user/1/premium-status" -Method Get
    Write-Host "User ID: $($response.user_id)" -ForegroundColor White
    Write-Host "Is Premium: $($response.is_premium)" -ForegroundColor White
    Write-Host ($response | ConvertTo-Json -Depth 5)
} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $errorBody = $reader.ReadToEnd()
        Write-Host "Error Details: $errorBody" -ForegroundColor Yellow
    }
}

# Test 5: Notify Me
Write-Host "`n📬 Testing Notify Me..." -ForegroundColor Green
try {
    $body = @{
        user_id = 1
        medicine_name = "Test Medicine Not Found"
    } | ConvertTo-Json

    $response = Invoke-RestMethod -Uri "$baseUrl/api/search/notify-me" `
        -Method Post `
        -ContentType "application/json" `
        -Body $body
    
    Write-Host "Success: $($response.success)" -ForegroundColor White
    Write-Host "Message: $($response.message)" -ForegroundColor White
} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $errorBody = $reader.ReadToEnd()
        Write-Host "Error Details: $errorBody" -ForegroundColor Yellow
    }
}

Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host "✅ Tests Complete!" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
