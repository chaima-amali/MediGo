#!/usr/bin/env python3
"""
Authentication Test Script for MediGo Backend
Tests the authentication endpoints with both remote and local databases
"""

import requests
import json
import time
from datetime import datetime

# Configuration
BASE_URL = "http://localhost:5000/api"
TEST_USER = {
    "name": "Test User",
    "email": f"test_{int(time.time())}@example.com",  # Unique email
    "phone": f"555{int(time.time()) % 10000000}",  # Unique phone
    "password": "TestPassword123",
    "gender": "male",
    "dob": "1990-01-01",
    "latitude": 40.7128,
    "longitude": -74.0060,
    "location_name": "New York",
    "premium": "false"
}


def print_section(title):
    """Print a formatted section header"""
    print("\n" + "=" * 60)
    print(f"  {title}")
    print("=" * 60 + "\n")


def print_result(success, message, data=None):
    """Print test result"""
    status = "✅ PASS" if success else "❌ FAIL"
    print(f"{status}: {message}")
    if data:
        print(f"Response: {json.dumps(data, indent=2)}")
    print()


def test_health_check():
    """Test if backend is running"""
    print_section("1. Health Check")
    try:
        response = requests.get(f"{BASE_URL.replace('/api', '')}/health")
        if response.status_code == 200:
            print_result(True, "Backend is running", response.json())
            return True
        else:
            print_result(False, f"Backend returned status {response.status_code}")
            return False
    except requests.exceptions.ConnectionError:
        print_result(False, "Cannot connect to backend. Is it running?")
        return False
    except Exception as e:
        print_result(False, f"Error: {str(e)}")
        return False


def test_register():
    """Test user registration"""
    print_section("2. User Registration")
    try:
        response = requests.post(
            f"{BASE_URL}/auth/register",
            json=TEST_USER,
            headers={"Content-Type": "application/json"}
        )
        
        data = response.json()
        
        if response.status_code == 201 and data.get('success'):
            source = data.get('source', 'unknown')
            print_result(
                True,
                f"User registered successfully via {source} database",
                data
            )
            return True, data.get('user', {})
        elif response.status_code == 409:
            print_result(
                False,
                "User already exists (this is expected if running multiple times)",
                data
            )
            return False, None
        else:
            print_result(False, f"Registration failed: {data.get('error')}", data)
            return False, None
            
    except Exception as e:
        print_result(False, f"Error: {str(e)}")
        return False, None


def test_login(email, password):
    """Test user login"""
    print_section("3. User Login")
    try:
        response = requests.post(
            f"{BASE_URL}/auth/login",
            json={"email": email, "password": password},
            headers={"Content-Type": "application/json"}
        )
        
        data = response.json()
        
        if response.status_code == 200 and data.get('success'):
            source = data.get('source', 'unknown')
            print_result(
                True,
                f"Login successful via {source} database",
                data
            )
            return True, data.get('user', {})
        else:
            print_result(False, f"Login failed: {data.get('error')}", data)
            return False, None
            
    except Exception as e:
        print_result(False, f"Error: {str(e)}")
        return False, None


def test_verify(email):
    """Test user verification"""
    print_section("4. User Verification")
    try:
        response = requests.post(
            f"{BASE_URL}/auth/verify",
            json={"email": email},
            headers={"Content-Type": "application/json"}
        )
        
        data = response.json()
        
        if response.status_code == 200 and data.get('success'):
            exists = data.get('exists', False)
            source = data.get('source', 'none')
            print_result(
                True,
                f"User {'exists' if exists else 'does not exist'} in {source} database",
                data
            )
            return True
        else:
            print_result(False, f"Verification failed", data)
            return False
            
    except Exception as e:
        print_result(False, f"Error: {str(e)}")
        return False


def test_wrong_password(email):
    """Test login with wrong password"""
    print_section("5. Wrong Password Test")
    try:
        response = requests.post(
            f"{BASE_URL}/auth/login",
            json={"email": email, "password": "WrongPassword123"},
            headers={"Content-Type": "application/json"}
        )
        
        data = response.json()
        
        if response.status_code == 401 and not data.get('success'):
            print_result(
                True,
                "Correctly rejected wrong password",
                data
            )
            return True
        else:
            print_result(
                False,
                "Should have rejected wrong password",
                data
            )
            return False
            
    except Exception as e:
        print_result(False, f"Error: {str(e)}")
        return False


def main():
    """Run all tests"""
    print("\n" + "🔐" * 30)
    print("  MediGo Authentication Test Suite")
    print("🔐" * 30)
    
    # Track results
    results = {
        'total': 0,
        'passed': 0,
        'failed': 0
    }
    
    # Test 1: Health Check
    results['total'] += 1
    if test_health_check():
        results['passed'] += 1
    else:
        results['failed'] += 1
        print("\n❌ Backend is not running. Please start it with: python main.py")
        return
    
    # Test 2: Registration
    results['total'] += 1
    success, user = test_register()
    if success:
        results['passed'] += 1
        email = user.get('email', TEST_USER['email'])
    else:
        results['failed'] += 1
        email = TEST_USER['email']
    
    # Test 3: Login
    results['total'] += 1
    success, _ = test_login(email, TEST_USER['password'])
    if success:
        results['passed'] += 1
    else:
        results['failed'] += 1
    
    # Test 4: Verify
    results['total'] += 1
    if test_verify(email):
        results['passed'] += 1
    else:
        results['failed'] += 1
    
    # Test 5: Wrong Password
    results['total'] += 1
    if test_wrong_password(email):
        results['passed'] += 1
    else:
        results['failed'] += 1
    
    # Print summary
    print_section("Test Summary")
    print(f"Total Tests: {results['total']}")
    print(f"✅ Passed: {results['passed']}")
    print(f"❌ Failed: {results['failed']}")
    print(f"\nSuccess Rate: {(results['passed']/results['total']*100):.1f}%")
    
    if results['failed'] == 0:
        print("\n🎉 All tests passed! Authentication system is working correctly.")
    else:
        print(f"\n⚠️  {results['failed']} test(s) failed. Please check the errors above.")
    
    print("\n" + "=" * 60 + "\n")


if __name__ == "__main__":
    main()
