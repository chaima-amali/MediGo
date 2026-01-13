# MediGo Backend - Network Setup Script
# Run this script AS ADMINISTRATOR to configure firewall and port forwarding

Write-Host "🔧 MediGo Backend Network Configuration" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Check if running as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "❌ ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "`nRight-click PowerShell and select 'Run as Administrator', then run this script again.`n" -ForegroundColor Yellow
    pause
    exit 1
}

Write-Host "✅ Running as Administrator`n" -ForegroundColor Green

# Get current IP address
$ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -notlike "*Loopback*" -and $_.IPAddress -notlike "169.254.*"} | Select-Object -First 1).IPAddress
Write-Host "📡 Your IP Address: $ip" -ForegroundColor Cyan
Write-Host "   (Use this IP in your Flutter app)`n" -ForegroundColor Gray

# Remove existing rules if they exist
Write-Host "🧹 Cleaning up old firewall rules..." -ForegroundColor Yellow
netsh advfirewall firewall delete rule name="MediGo Backend Flask" 2>&1 | Out-Null
netsh advfirewall firewall delete rule name="MediGo Backend Flask Out" 2>&1 | Out-Null
Write-Host "✅ Cleanup complete`n" -ForegroundColor Green

# Add firewall rules for Flask (port 5000)
Write-Host "🔥 Configuring Windows Firewall..." -ForegroundColor Yellow
Write-Host "   Adding inbound rule for port 5000..." -ForegroundColor Gray
$result1 = netsh advfirewall firewall add rule name="MediGo Backend Flask" dir=in action=allow protocol=TCP localport=5000
if ($LASTEXITCODE -eq 0) {
    Write-Host "   ✅ Inbound rule added" -ForegroundColor Green
} else {
    Write-Host "   ❌ Failed to add inbound rule" -ForegroundColor Red
}

Write-Host "   Adding outbound rule for port 5000..." -ForegroundColor Gray
$result2 = netsh advfirewall firewall add rule name="MediGo Backend Flask Out" dir=out action=allow protocol=TCP localport=5000
if ($LASTEXITCODE -eq 0) {
    Write-Host "   ✅ Outbound rule added`n" -ForegroundColor Green
} else {
    Write-Host "   ❌ Failed to add outbound rule`n" -ForegroundColor Red
}

# Configure port forwarding (if needed)
Write-Host "🔌 Port Forwarding Configuration" -ForegroundColor Yellow
Write-Host "   Port 5000 is now open for connections" -ForegroundColor Green
Write-Host "   Your phone can connect to: http://${ip}:5000`n" -ForegroundColor Cyan

# Display connection instructions
Write-Host "📱 PHONE CONNECTION INSTRUCTIONS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Make sure your phone is on the SAME Wi-Fi network" -ForegroundColor White
Write-Host "   Wi-Fi name: " -NoNewline -ForegroundColor Gray
Write-Host (Get-NetConnectionProfile | Where-Object {$_.IPv4Connectivity -eq "Internet"} | Select-Object -First 1).Name -ForegroundColor Yellow
Write-Host ""
Write-Host "2. Update Flutter config (already done):" -ForegroundColor White
Write-Host "   File: frontend\lib\config\environment.dart" -ForegroundColor Gray
Write-Host "   URL: " -NoNewline -ForegroundColor Gray
Write-Host "http://${ip}:5000/api" -ForegroundColor Yellow
Write-Host ""
Write-Host "3. Test connection from phone browser:" -ForegroundColor White
Write-Host "   Open: " -NoNewline -ForegroundColor Gray
Write-Host "http://${ip}:5000/" -ForegroundColor Yellow
Write-Host "   Should see: 'Welcome to MediGo Backend API'" -ForegroundColor Gray
Write-Host ""
Write-Host "4. If connection fails, check:" -ForegroundColor White
Write-Host "   - Both devices on same Wi-Fi" -ForegroundColor Gray
Write-Host "   - Backend server is running" -ForegroundColor Gray
Write-Host "   - Try disabling antivirus temporarily" -ForegroundColor Gray
Write-Host ""

Write-Host "✅ Network configuration complete!`n" -ForegroundColor Green

Write-Host "🚀 NEXT STEPS:" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "1. Start the backend server:" -ForegroundColor White
Write-Host "   cd backend" -ForegroundColor Gray
Write-Host "   python main.py" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Test from this PC:" -ForegroundColor White
Write-Host "   Open browser: http://127.0.0.1:5000/" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Test from phone browser:" -ForegroundColor White
Write-Host "   Open browser: http://${ip}:5000/" -ForegroundColor Gray
Write-Host ""
Write-Host "4. Run Flutter app:" -ForegroundColor White
Write-Host "   cd frontend" -ForegroundColor Gray
Write-Host "   flutter run" -ForegroundColor Gray
Write-Host ""

pause
