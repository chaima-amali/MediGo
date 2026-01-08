"""
Quick Supabase Data Inspector
Run this to find IDs for testing (user_id, medicine_id, pharmacy_id)
"""

import asyncio
from app.supabase_client import get_supabase

def inspect_supabase_data():
    """Inspect Supabase tables to find test data"""
    
    print("=" * 60)
    print("🔍 SUPABASE DATA INSPECTOR")
    print("=" * 60)
    
    supabase = get_supabase()
    
    if not supabase:
        print("❌ Supabase not connected!")
        return
    
    print("\n✅ Connected to Supabase\n")
    
    # Check Users
    print("-" * 60)
    print("👥 USERS (First 5)")
    print("-" * 60)
    try:
        response = supabase.table('users').select('user_id, name, email, premium').limit(5).execute()
        if response.data:
            for user in response.data:
                premium_emoji = "👑" if user.get('premium') in ['yes', 'true', '1', 'active'] else "👤"
                print(f"{premium_emoji} ID: {user.get('user_id')} | {user.get('name')} | {user.get('email')} | Premium: {user.get('premium')}")
        else:
            print("⚠️  No users found")
    except Exception as e:
        print(f"❌ Error: {e}")
    
    # Check Medicines
    print("\n" + "-" * 60)
    print("💊 MEDICINES (First 5)")
    print("-" * 60)
    try:
        response = supabase.table('medicine').select('medicine_id, name, generic_name, dosage').limit(5).execute()
        if response.data:
            for med in response.data:
                print(f"💊 ID: {med.get('medicine_id')} | {med.get('name')} | {med.get('generic_name')} | {med.get('dosage')}")
        else:
            print("⚠️  No medicines found")
    except Exception as e:
        print(f"❌ Error: {e}")
    
    # Check Pharmacies
    print("\n" + "-" * 60)
    print("🏥 PHARMACIES (First 5)")
    print("-" * 60)
    try:
        response = supabase.table('pharmacy').select('pharmacy_id, name, address, phone').limit(5).execute()
        if response.data:
            for pharmacy in response.data:
                print(f"🏥 ID: {pharmacy.get('pharmacy_id')} | {pharmacy.get('name')} | {pharmacy.get('address')}")
        else:
            print("⚠️  No pharmacies found")
    except Exception as e:
        print(f"❌ Error: {e}")
    
    # Check Medicine Availability
    print("\n" + "-" * 60)
    print("📦 MEDICINE AVAILABILITY (Stock > 0, First 5)")
    print("-" * 60)
    try:
        response = supabase.table('pharmacy_medicine').select('''
            id,
            medicine_id,
            pharmacy_id,
            price,
            stock,
            medicine:medicine_id (name),
            pharmacy:pharmacy_id (name)
        ''').gt('stock', 0).limit(5).execute()
        
        if response.data:
            for item in response.data:
                medicine_name = item.get('medicine', {}).get('name', 'Unknown')
                pharmacy_name = item.get('pharmacy', {}).get('name', 'Unknown')
                print(f"📦 Medicine ID: {item.get('medicine_id')} ({medicine_name})")
                print(f"   Pharmacy ID: {item.get('pharmacy_id')} ({pharmacy_name})")
                print(f"   Price: ${item.get('price')} | Stock: {item.get('stock')}")
                print()
        else:
            print("⚠️  No medicine availability found (stock > 0)")
    except Exception as e:
        print(f"❌ Error: {e}")
    
    # Test Recommendation
    print("\n" + "=" * 60)
    print("💡 TESTING RECOMMENDATIONS")
    print("=" * 60)
    
    # Find premium users
    try:
        response = supabase.table('users').select('user_id, name, premium').execute()
        premium_users = [u for u in response.data if u.get('premium', '').lower() in ['yes', 'true', '1', 'active']]
        
        if premium_users:
            print("\n✅ Premium users found for testing reservations:")
            for user in premium_users[:3]:
                print(f"   👑 User ID: {user.get('user_id')} ({user.get('name')})")
        else:
            print("\n⚠️  No premium users found!")
            print("   Run this SQL in Supabase to make user premium:")
            print("   UPDATE users SET premium = 'yes' WHERE user_id = 1;")
    except Exception as e:
        print(f"❌ Error checking premium users: {e}")
    
    # Check for searchable medicines
    try:
        response = supabase.table('medicine').select('name').limit(3).execute()
        if response.data:
            print("\n✅ Example medicine names to search:")
            for med in response.data:
                name = med.get('name', '')
                if name:
                    # Extract first word for easy searching
                    first_word = name.split()[0] if ' ' in name else name
                    print(f"   🔍 Try searching: '{first_word.lower()}'")
    except Exception as e:
        pass
    
    print("\n" + "=" * 60)
    print("🎯 QUICK TEST COMMANDS")
    print("=" * 60)
    print("\n1. Open test page: test_api.html")
    print("2. Or use browser URLs:")
    print("   http://localhost:5000/api/health")
    print("   http://localhost:5000/api/user/1/premium-status")
    print("   http://localhost:5000/api/users")
    print("\n" + "=" * 60)

if __name__ == "__main__":
    inspect_supabase_data()
