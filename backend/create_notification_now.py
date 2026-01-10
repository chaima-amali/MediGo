"""Create a complete medicine with plan and occurrence FOR RIGHT NOW"""
import requests
from datetime import datetime, timedelta

BASE_URL = "http://localhost:5000"
USER_ID = 75
MEDICINE_ID = 915  # The medicine that was already created

now = datetime.now()
test_time = now + timedelta(minutes=2)
time_str = test_time.strftime("%H:%M")
date_str = now.strftime("%Y-%m-%d")

print(f"Creating plan and occurrence for existing medicine ID {MEDICINE_ID}")
print(f"Current time: {now.strftime('%H:%M:%S')}")
print(f"Notification will fire at: {time_str}\n")

# Step 1: Create plan
print("Step 1: Creating plan...")
response = requests.post(
    f"{BASE_URL}/api/tracking/plans",
    json={
        "medicine_track_id": MEDICINE_ID,
        "user_id": USER_ID,
        "importance": "primary",
        "start_date": date_str,
        "end_date": (now + timedelta(days=7)).strftime("%Y-%m-%d"),
        "frequency_type": "daily",
        "interval_days": 1
    }
)
print(f"Status: {response.status_code}")
print(f"Response: {response.json()}\n")

if response.status_code not in [200, 201]:
    print(f"❌ FAILED: {response.text}")
    exit(1)

plan_data = response.json()
plan_id = plan_data.get('plan', {}).get('plan_id') or plan_data.get('plan_id')
print(f"✅ Plan created: ID {plan_id}\n")

# Step 2: Create occurrence
print("Step 2: Creating occurrence for TODAY...")
response = requests.post(
    f"{BASE_URL}/api/tracking/occurrences/batch",
    json={
        "occurrences": [
            {
                "plan_id": plan_id,
                "date": date_str,
                "time": time_str,
                "is_taken": 0
            }
        ]
    }
)
print(f"Status: {response.status_code}")
print(f"Response: {response.json()}\n")

if response.status_code not in [200, 201]:
    print(f"❌ FAILED: {response.text}")
    exit(1)

print("✅ SUCCESS!")
print(f"\n🎉 Notification will fire at {time_str}")
print(f"That's in {(test_time - now).seconds // 60} minutes and {(test_time - now).seconds % 60} seconds")
print(f"\n📱 Make sure your phone:")
print("1. Has internet connection")
print("2. App is in background or closed")
print("3. Notifications are enabled for MediGo")
