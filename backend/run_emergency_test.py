import requests
import time

print("Waiting for backend to be ready...")
for i in range(10):
    try:
        response = requests.get("http://localhost:5000/api/health", timeout=2)
        if response.status_code == 200:
            print(f"✅ Backend is ready!")
            break
    except:
        pass
    time.sleep(1)
    print(f"  Attempt {i+1}/10...")
else:
    print("❌ Backend not responding")
    exit(1)

# Now run the emergency test
print("\n" + "="*60)
exec(open('emergency_test.py').read())
