"""
Quick Test Script for Medicine Search & Reservation API
Run this to verify the API is working correctly
"""

import requests
import json

BASE_URL = "http://localhost:5000/api"

def test_search_medicines():
    """Test medicine search endpoint"""
    print("\n🔍 Testing Medicine Search...")
    
    response = requests.post(
        f"{BASE_URL}/search/medicines",
        json={"search_query": "aspirin"}
    )
    
    print(f"Status: {response.status_code}")
    print(f"Response: {json.dumps(response.json(), indent=2)}")
    
    return response.json()


def test_notify_me():
    """Test notify-me endpoint"""
    print("\n📬 Testing Notify Me...")
    
    response = requests.post(
        f"{BASE_URL}/search/notify-me",
        json={
            "user_id": 1,
            "medicine_name": "Test Medicine Not Found"
        }
    )
    
    print(f"Status: {response.status_code}")
    print(f"Response: {json.dumps(response.json(), indent=2)}")


def test_premium_status():
    """Test premium status check"""
    print("\n👑 Testing Premium Status Check...")
    
    response = requests.get(f"{BASE_URL}/user/1/premium-status")
    
    print(f"Status: {response.status_code}")
    print(f"Response: {json.dumps(response.json(), indent=2)}")
    
    return response.json()


def test_create_reservation(medicine_id=1, pharmacy_id=1):
    """Test reservation creation"""
    print("\n🎫 Testing Reservation Creation...")
    
    response = requests.post(
        f"{BASE_URL}/reservations",
        json={
            "user_id": 1,
            "medicine_id": medicine_id,
            "pharmacy_id": pharmacy_id,
            "medicine_name": "Test Medicine",
            "quantity": 1
        }
    )
    
    print(f"Status: {response.status_code}")
    print(f"Response: {json.dumps(response.json(), indent=2)}")


def test_get_reservations():
    """Test get user reservations"""
    print("\n📋 Testing Get User Reservations...")
    
    response = requests.get(f"{BASE_URL}/reservations/user/1")
    
    print(f"Status: {response.status_code}")
    print(f"Response: {json.dumps(response.json(), indent=2)}")


def test_search_history():
    """Test get search history"""
    print("\n📜 Testing Search History...")
    
    response = requests.get(f"{BASE_URL}/search/history/1")
    
    print(f"Status: {response.status_code}")
    print(f"Response: {json.dumps(response.json(), indent=2)}")


def run_all_tests():
    """Run all API tests"""
    print("=" * 60)
    print("🧪 Medicine Search & Reservation API Tests")
    print("=" * 60)
    
    try:
        # Test 1: Search medicines
        search_results = test_search_medicines()
        
        # Test 2: Check premium status
        premium_status = test_premium_status()
        
        # Test 3: Notify me
        test_notify_me()
        
        # Test 4: Create reservation (if search returned results)
        if search_results.get('results'):
            medicine = search_results['results'][0]
            if medicine.get('availability'):
                availability = medicine['availability'][0]
                test_create_reservation(
                    medicine_id=medicine['medicine_id'],
                    pharmacy_id=availability['pharmacy_id']
                )
        
        # Test 5: Get reservations
        test_get_reservations()
        
        # Test 6: Get search history
        test_search_history()
        
        print("\n" + "=" * 60)
        print("✅ All tests completed!")
        print("=" * 60)
        
    except requests.exceptions.ConnectionError:
        print("\n❌ Error: Cannot connect to server.")
        print("Make sure the Flask server is running on http://localhost:5000")
    except Exception as e:
        print(f"\n❌ Error: {str(e)}")


if __name__ == "__main__":
    run_all_tests()
