"""
Authentication API Routes - User registration and login with Supabase
Handles both Supabase (remote) and SQLite (local) authentication
"""

from flask import Blueprint, request, jsonify
from pydantic import ValidationError
from app.supabase_client import supabase
from app.core.database import execute_query, execute_insert
from app.models.user import User
from app.schemas.user import UserCreate
import hashlib

bp = Blueprint('auth', __name__)


def hash_password(password: str) -> str:
    """Hash password using SHA256"""
    return hashlib.sha256(password.encode()).hexdigest()


@bp.route('/auth/register', methods=['POST'])
def register():
    """
    Register a new user
    Tries Supabase first, falls back to local SQLite if Supabase is unavailable
    
    Request body:
    {
        "name": "John Doe",
        "email": "john@example.com",
        "phone": "1234567890",
        "password": "password123",
        "gender": "male",
        "dob": "1990-01-01",
        "latitude": 40.7128,
        "longitude": -74.0060,
        "location_name": "New York",
        "premium": "false"
    }
    
    Returns:
    {
        "success": true,
        "user": {...},
        "source": "remote|local",
        "message": "User registered successfully"
    }
    """
    try:
        # Validate request data
        user_data = UserCreate(**request.json)
        
        # Validation: Check required fields are not empty
        if not user_data.name or not user_data.name.strip():
            return jsonify({'success': False, 'error': 'Name is required'}), 400
        
        if not user_data.email or not user_data.email.strip():
            return jsonify({'success': False, 'error': 'Email is required'}), 400
        
        if not user_data.phone or not user_data.phone.strip():
            return jsonify({'success': False, 'error': 'Phone number is required'}), 400
        
        if not user_data.password or not user_data.password.strip():
            return jsonify({'success': False, 'error': 'Password is required'}), 400
        
        if not user_data.gender or not user_data.gender.strip():
            return jsonify({'success': False, 'error': 'Gender is required'}), 400
        
        if not user_data.dob or not user_data.dob.strip():
            return jsonify({'success': False, 'error': 'Date of birth is required'}), 400
        
        # Email validation
        import re
        email_pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
        if not re.match(email_pattern, user_data.email):
            return jsonify({'success': False, 'error': 'Invalid email format'}), 400
        
        # Phone validation (must start with 05, 06, or 07 followed by 8 digits)
        phone_pattern = r'^0[567]\d{8}$'
        if not re.match(phone_pattern, user_data.phone):
            return jsonify({
                'success': False, 
                'error': 'Invalid phone number. Must start with 05, 06, or 07 followed by 8 digits'
            }), 400
        
        # Try Supabase first
        if supabase:
            try:
                # Check if email exists in Supabase
                existing = supabase.table('users').select('*').eq('email', user_data.email).execute()
                
                if existing.data and len(existing.data) > 0:
                    return jsonify({
                        'success': False,
                        'error': 'Email already registered'
                    }), 409
                
                # Check if phone exists in Supabase
                existing_phone = supabase.table('users').select('*').eq('phone', user_data.phone).execute()
                
                if existing_phone.data and len(existing_phone.data) > 0:
                    return jsonify({
                        'success': False,
                        'error': 'Phone number already registered'
                    }), 409
                
                # Hash password
                hashed_password = hash_password(user_data.password)
                
                # Insert into Supabase
                new_user = {
                    'name': user_data.name,
                    'email': user_data.email,
                    'phone': user_data.phone,
                    'password': hashed_password,
                    'gender': user_data.gender,
                    'dob': user_data.dob,
                    'latitude': user_data.latitude,
                    'longitude': user_data.longitude,
                    'location_name': user_data.location_name,
                    'premium': user_data.premium
                }
                
                response = supabase.table('users').insert(new_user).execute()
                
                if response.data and len(response.data) > 0:
                    user = response.data[0]
                    # Remove password from response
                    user.pop('password', None)
                    
                    return jsonify({
                        'success': True,
                        'user': user,
                        'source': 'remote',
                        'message': 'User registered successfully on remote database'
                    }), 201
                    
            except Exception as supabase_error:
                print(f"⚠️  Supabase registration failed: {supabase_error}")
                print("📍 Falling back to local database")
        
        # Fallback to local SQLite
        # Check if email exists locally
        local_user = execute_query(
            "SELECT * FROM users WHERE email = ?",
            (user_data.email,)
        )
        
        if local_user:
            return jsonify({
                'success': False,
                'error': 'Email already registered'
            }), 409
        
        # Check if phone exists locally
        local_phone = execute_query(
            "SELECT * FROM users WHERE phone = ?",
            (user_data.phone,)
        )
        
        if local_phone:
            return jsonify({
                'success': False,
                'error': 'Phone number already registered'
            }), 409
        
        # Hash password
        hashed_password = hash_password(user_data.password)
        
        # Insert into local database
        query = """
            INSERT INTO users (name, email, phone, password, gender, dob, 
                            latitude, longitude, location_name, premium)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """
        params = (
            user_data.name,
            user_data.email,
            user_data.phone,
            hashed_password,
            user_data.gender,
            user_data.dob,
            user_data.latitude,
            user_data.longitude,
            user_data.location_name,
            user_data.premium
        )
        
        user_id = execute_insert(query, params)
        
        # Fetch created user
        rows = execute_query("SELECT * FROM users WHERE user_id = ?", (user_id,))
        
        if rows:
            user_dict = dict(rows[0])
            # Remove password from response
            user_dict.pop('password', None)
            
            return jsonify({
                'success': True,
                'user': user_dict,
                'source': 'local',
                'message': 'User registered successfully on local database'
            }), 201
        else:
            return jsonify({
                'success': False,
                'error': 'Failed to create user'
            }), 500
        
    except ValidationError as e:
        return jsonify({
            'success': False,
            'error': 'Validation error',
            'details': e.errors()
        }), 400
    except Exception as e:
        print(f"❌ Registration error: {e}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500


@bp.route('/auth/login', methods=['POST'])
def login():
    """
    Login user with email and password
    Tries Supabase first, falls back to local SQLite if unavailable
    
    Request body:
    {
        "email": "john@example.com",
        "password": "password123"
    }
    
    Returns:
    {
        "success": true,
        "user": {...},
        "source": "remote|local",
        "message": "Login successful"
    }
    """
    try:
        data = request.json
        email = data.get('email')
        password = data.get('password')
        
        if not email or not password:
            return jsonify({
                'success': False,
                'error': 'Email and password are required'
            }), 400
        
        # Hash password for comparison
        hashed_password = hash_password(password)
        
        # Try Supabase first
        if supabase:
            try:
                # Query user by email and password
                response = supabase.table('users').select('*').eq('email', email).eq('password', hashed_password).execute()
                
                if response.data and len(response.data) > 0:
                    user = response.data[0]
                    # Remove password from response
                    user.pop('password', None)
                    
                    return jsonify({
                        'success': True,
                        'user': user,
                        'source': 'remote',
                        'message': 'Login successful from remote database'
                    }), 200
                else:
                    # Check if email exists
                    email_check = supabase.table('users').select('*').eq('email', email).execute()
                    if email_check.data and len(email_check.data) > 0:
                        return jsonify({
                            'success': False,
                            'error': 'Invalid password'
                        }), 401
                    
            except Exception as supabase_error:
                print(f"⚠️  Supabase login failed: {supabase_error}")
                print("📍 Falling back to local database")
        
        # Fallback to local SQLite
        rows = execute_query(
            "SELECT * FROM users WHERE email = ? AND password = ?",
            (email, hashed_password)
        )
        
        if rows:
            user_dict = dict(rows[0])
            # Remove password from response
            user_dict.pop('password', None)
            
            return jsonify({
                'success': True,
                'user': user_dict,
                'source': 'local',
                'message': 'Login successful from local database'
            }), 200
        else:
            # Check if email exists
            email_check = execute_query(
                "SELECT * FROM users WHERE email = ?",
                (email,)
            )
            if email_check:
                return jsonify({
                    'success': False,
                    'error': 'Invalid password'
                }), 401
            else:
                return jsonify({
                    'success': False,
                    'error': 'User not found'
                }), 404
        
    except Exception as e:
        print(f"❌ Login error: {e}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500


@bp.route('/auth/verify', methods=['POST'])
def verify_user():
    """
    Verify if user exists and credentials are valid
    
    Request body:
    {
        "email": "john@example.com"
    }
    
    Returns:
    {
        "success": true,
        "exists": true,
        "source": "remote|local"
    }
    """
    try:
        data = request.json
        email = data.get('email')
        
        if not email:
            return jsonify({
                'success': False,
                'error': 'Email is required'
            }), 400
        
        # Try Supabase first
        if supabase:
            try:
                response = supabase.table('users').select('user_id').eq('email', email).execute()
                
                if response.data and len(response.data) > 0:
                    return jsonify({
                        'success': True,
                        'exists': True,
                        'source': 'remote'
                    }), 200
                    
            except Exception as supabase_error:
                print(f"⚠️  Supabase verify failed: {supabase_error}")
        
        # Check local database
        rows = execute_query(
            "SELECT user_id FROM users WHERE email = ?",
            (email,)
        )
        
        if rows:
            return jsonify({
                'success': True,
                'exists': True,
                'source': 'local'
            }), 200
        else:
            return jsonify({
                'success': True,
                'exists': False
            }), 200
        
    except Exception as e:
        print(f"❌ Verify error: {e}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500
