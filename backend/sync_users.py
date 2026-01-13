"""
Sync local users to Supabase
Run this after adding fcm_token column to Supabase to sync any local-only users
"""

import sys
import os

# Add parent directory to path
sys.path.insert(0, os.path.dirname(__file__))

from app import create_app
from app.core.database import execute_query
from app.supabase_client import supabase

def sync_users():
    """Sync local users to Supabase"""
    print("\n" + "="*70)
    print(" 👥 SYNCING LOCAL USERS TO SUPABASE")
    print("="*70)
    
    if not supabase:
        print("❌ Supabase client not available")
        return
    
    # Create Flask app context
    app = create_app()
    
    with app.app_context():
        try:
            # Get all local users
            local_users = execute_query("SELECT * FROM users", ())
            print(f"\n📊 Found {len(local_users)} users in local database")
            
            synced = 0
            skipped = 0
            errors = []
            
            for user in local_users:
                user_dict = dict(user)
                email = user_dict.get('email')
                user_id = user_dict.get('user_id')
                
                try:
                    # Check if user exists in Supabase
                    response = supabase.table('users').select('user_id, email').eq('email', email).execute()
                    
                    if response.data and len(response.data) > 0:
                        # User exists - update if needed
                        remote_user_id = response.data[0]['user_id']
                        print(f"⚠️  User {email} exists in Supabase (remote ID: {remote_user_id}, local ID: {user_id})")
                        
                        # Update local user_id to match remote
                        if remote_user_id != user_id:
                            print(f"   Updating local user_id from {user_id} to {remote_user_id}")
                            execute_query(
                                "UPDATE users SET user_id = ? WHERE email = ?",
                                (remote_user_id, email)
                            )
                            
                            # Also update medicine_tracking references
                            execute_query(
                                "UPDATE medicine_tracking SET user_id = ? WHERE user_id = ?",
                                (remote_user_id, user_id)
                            )
                            
                            # Update medicine_plan references
                            execute_query(
                                "UPDATE medicine_plan SET user_id = ? WHERE user_id = ?",
                                (remote_user_id, user_id)
                            )
                        
                        skipped += 1
                    else:
                        # User doesn't exist - insert to Supabase
                        new_user = {
                            'name': user_dict.get('name'),
                            'email': user_dict.get('email'),
                            'phone': user_dict.get('phone'),
                            'password': user_dict.get('password'),
                            'gender': user_dict.get('gender'),
                            'dob': user_dict.get('dob'),
                            'latitude': user_dict.get('latitude'),
                            'longitude': user_dict.get('longitude'),
                            'location_name': user_dict.get('location_name'),
                            'premium': user_dict.get('premium'),
                            'fcm_token': user_dict.get('fcm_token')
                        }
                        
                        # Remove None values
                        new_user = {k: v for k, v in new_user.items() if v is not None}
                        
                        response = supabase.table('users').insert(new_user).execute()
                        
                        if response.data and len(response.data) > 0:
                            remote_user_id = response.data[0]['user_id']
                            print(f"✅ Synced user {email} to Supabase (ID: {remote_user_id})")
                            
                            # Update local user_id to match remote
                            if remote_user_id != user_id:
                                execute_query(
                                    "UPDATE users SET user_id = ? WHERE email = ?",
                                    (remote_user_id, email)
                                )
                                
                                # Update medicine_tracking references
                                execute_query(
                                    "UPDATE medicine_tracking SET user_id = ? WHERE user_id = ?",
                                    (remote_user_id, user_id)
                                )
                                
                                # Update medicine_plan references
                                execute_query(
                                    "UPDATE medicine_plan SET user_id = ? WHERE user_id = ?",
                                    (remote_user_id, user_id)
                                )
                            
                            synced += 1
                        
                except Exception as e:
                    error_msg = f"User {email}: {str(e)}"
                    errors.append(error_msg)
                    print(f"❌ {error_msg}")
            
            print("\n" + "="*70)
            print(" 📊 SYNC SUMMARY")
            print("="*70)
            print(f"✅ Synced: {synced}")
            print(f"⚠️  Already exists: {skipped}")
            print(f"❌ Errors: {len(errors)}")
            
            if errors:
                print("\nErrors:")
                for error in errors:
                    print(f"  - {error}")
            
            print("\n💡 Next steps:")
            print("   1. Verify users in Supabase dashboard")
            print("   2. Try adding a medicine from the app")
            print("   3. Check if it appears in Supabase")
            print("="*70)
            
        except Exception as e:
            print(f"❌ Sync failed: {e}")
            import traceback
            traceback.print_exc()

if __name__ == '__main__':
    sync_users()
