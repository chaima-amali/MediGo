# Get Your Computer's IP Address for Mobile Testing
# Run: .\get_ip.ps1

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "📱 FIND YOUR IP ADDRESS FOR MOBILE TESTING" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Get network adapters with IPv4 addresses
$adapters = Get-NetIPAddress -AddressFamily IPv4 | 
    Where-Object {$_.IPAddress -notlike '127.*' -and $_.IPAddress -notlike '169.*'} |
    Select-Object IPAddress, InterfaceAlias

if ($adapters) {
    Write-Host "Found these network connections:" -ForegroundColor Yellow
    Write-Host ""
    
    foreach ($adapter in $adapters) {
        $ip = $adapter.IPAddress
        $name = $adapter.InterfaceAlias
        
        Write-Host "  Network: $name" -ForegroundColor White
        Write-Host "  IP Address: $ip" -ForegroundColor Green
        Write-Host ""
        
        if ($name -like "*Wi-Fi*" -or $name -like "*Ethernet*") {
            Write-Host "  👉 USE THIS ONE! 👈" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "  URLs for your phone:" -ForegroundColor Yellow
            Write-Host "  • Mobile test page: http://${ip}:5000/mobile" -ForegroundColor White
            Write-Host "  • API base URL: http://${ip}:5000/api" -ForegroundColor White
            Write-Host "  • Health check: http://${ip}:5000/api/health" -ForegroundColor White
            Write-Host ""
        }
    }
} else {
    Write-Host "❌ No network connections found!" -ForegroundColor Red
    Write-Host "Make sure you're connected to WiFi or Ethernet" -ForegroundColor Yellow
}

Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📋 NEXT STEPS:" -ForegroundColor Yellow
Write-Host "1. Make sure Flask server is running (python main.py)" -ForegroundColor White
Write-Host "2. Connect your phone to the SAME WiFi network" -ForegroundColor White
Write-Host "3. Open the mobile test URL on your phone" -ForegroundColor White
Write-Host "4. Tap 'Change Server URL' and enter the API URL above" -ForegroundColor White
Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan

# Keep window open
Read-Host "Press Enter to close"
