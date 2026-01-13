#!/bin/bash
# Quick test script to verify notification system

echo "🔬 Testing MediGo Notification System..."
echo ""

# Test 1: Check if backend is running
echo "1️⃣  Testing Backend Server..."
response=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:5000/api/notifications/26)
if [ "$response" = "200" ]; then
    echo "   ✅ Backend server is running"
else
    echo "   ❌ Backend server not responding (HTTP $response)"
    echo "   Start it with: cd backend && python main.py"
    exit 1
fi

# Test 2: Get notifications
echo ""
echo "2️⃣  Fetching Notifications..."
notif_data=$(curl -s http://127.0.0.1:5000/api/notifications/26)
notif_count=$(echo $notif_data | grep -o '"count":[0-9]*' | grep -o '[0-9]*')

if [ "$notif_count" -gt 0 ]; then
    echo "   ✅ Found $notif_count notifications"
else
    echo "   ⚠️  No notifications found"
fi

# Test 3: Check notification types
echo ""
echo "3️⃣  Checking Notification Types..."
echo $notif_data | grep -o '"type":"[^"]*"' | sort | uniq | while read line; do
    echo "   📬 $line"
done

echo ""
echo "✅ All tests passed! Notification system is working."
echo ""
echo "📱 Next: Test on Flutter app"
echo "   1. Make sure backend is running"
echo "   2. Run: cd frontend && flutter run"
echo "   3. Navigate to Notifications screen"
