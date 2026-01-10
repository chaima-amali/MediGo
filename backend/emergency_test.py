"""
Emergency test: Add a medicine end-to-end and verify notification setup.
This will bypass any app issues and test the backend directly.
"""
import requests
import json
from datetime import datetime, timedelta

BASE_URL = "http://localhost:5000"
USER_ID = 53  # Your user ID

# Current time + 2 minutes for testing
now = datetime.now()
test_time = now + timedelta(minutes=2)
time_str = test_time.strftime("%H:%M")
date_str = now.strftime("%Y-%m-%d")

print(f"=== EMERGENCY TEST: Creating medicine for notification ===")
print(f"Current time: {now.strftime('%H:%M:%S')}")
print(f"Target time: {time_str}")
print(f"Date: {date_str}\n")

# Step 1: Create medicine
print("Step 1: Creating medicine...")
response = requests.post(
    f"{BASE_URL}/api/tracking/medicines",
    json={
        "user_id": USER_ID,
        "name": "URGENT_TEST_MED",
        "type": "Tablet",
        "dosage": "1 tablet"
    }
)
print(f"Status: {response.status_code}")
print(f"Response: {json.dumps(response.json(), indent=2)}\n")

if response.status_code != 200 and response.status_code != 201:
    print(f"❌ FAILED at Step 1: {response.text}")
    exit(1)

medicine_data = response.json()
medicine_id = medicine_data.get('medicine', {}).get('medicine_track_id') or medicine_data.get('medicine_track_id')
print(f"✅ Medicine created with ID: {medicine_id}\n")

# Step 2: Create medicine plan
print("Step 2: Creating medicine plan...")
response = requests.post(
    f"{BASE_URL}/api/tracking/plans",
    json={
        "medicine_track_id": medicine_id,
        "user_id": USER_ID,
        "importance": "primary",
        "start_date": date_str,
        "end_date": (now + timedelta(days=7)).strftime("%Y-%m-%d"),
        "frequency_type": "daily",
        "interval_days": 1
    }
)
print(f"Status: {response.status_code}")
print(f"Response: {json.dumps(response.json(), indent=2)}\n")

if response.status_code != 200 and response.status_code != 201:
    print(f"❌ FAILED at Step 2: {response.text}")
    exit(1)

plan_data = response.json()
plan_id = plan_data.get('plan_id') or plan_data.get('id')
print(f"✅ Plan created with ID: {plan_id}\n")

# Step 3: Create occurrence for TODAY at target time
print("Step 3: Creating occurrence...")
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
print(f"Response: {json.dumps(response.json(), indent=2)}\n")

if response.status_code != 200 and response.status_code != 201:
    print(f"❌ FAILED at Step 3: {response.text}")
    exit(1)

print("✅ SUCCESS! Medicine, plan, and occurrence created.")
print(f"\n📱 Notification should fire at {time_str}")
print(f"⏰ That's in approximately {(test_time - now).seconds // 60} minutes and {(test_time - now).seconds % 60} seconds")
print(f"\nMake sure:")
print(f"1. Your device has a valid FCM token")
print(f"2. The app is closed or in background")
print(f"3. Notifications are enabled")
print(f"\nWait for the notification at {time_str}!")
