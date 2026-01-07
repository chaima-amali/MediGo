"""
User API Routes - CRUD operations for users
Demonstrates interaction with existing database
"""

from flask import Blueprint, request, jsonify
from pydantic import ValidationError
from app.core.database import execute_query, execute_insert, execute_update
from app.models.user import User
from app.schemas.user import UserCreate, UserUpdate
from app.supabase_client import supabase

bp = Blueprint('users', __name__)

@bp.route('/users', methods=['GET'])
def get_users():
    """
    Get all users or filter by query parameters
    Query params:
        - email: Filter by email
        - premium: Filter by premium status
    """
    email = request.args.get('email')
    premium = request.args.get('premium')
    
    # Build query based on filters
    query = "SELECT * FROM users WHERE 1=1"
    params = []
    
    if email:
        query += " AND email = ?"
        params.append(email)
    
    if premium:
        query += " AND premium = ?"
        params.append(premium)
    
    try:
        rows = execute_query(query, params)
        users = [User.from_db_row(row).to_dict() for row in rows]
        
        return jsonify({
            'count': len(users),
            'users': users
        }), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@bp.route('/users/<int:user_id>', methods=['GET'])
def get_user(user_id):
    """Get user by ID - checks Supabase first, then local database"""
    try:
        # Try Supabase first
        if supabase:
            try:
                response = supabase.table('users').select('*').eq('user_id', user_id).execute()
                
                if response.data and len(response.data) > 0:
                    print(f"✅ User {user_id} found in Supabase")
                    return jsonify(response.data[0]), 200
                else:
                    print(f"⚠️  User {user_id} not found in Supabase, checking local database...")
                    
            except Exception as supabase_error:
                print(f"⚠️  Supabase query failed: {supabase_error}")
                print("📍 Falling back to local database...")
        
        # Fallback to local database
        rows = execute_query(
            "SELECT * FROM users WHERE user_id = ?",
            (user_id,)
        )
        
        if not rows:
            return jsonify({'error': 'User not found'}), 404
        
        user = User.from_db_row(rows[0])
        print(f"✅ User {user_id} found in local database")
        return jsonify(user.to_dict()), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@bp.route('/users', methods=['POST'])
def create_user():
    """
    Create a new user
    Request body should match UserCreate schema
    """
    try:
        # Validate request data
        user_data = UserCreate(**request.json)
        
        # Insert into database
        query = """
            INSERT INTO users (name, email, phone, password, gender, dob, 
                            latitude, longitude, location_name, premium)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """
        params = (
            user_data.name,
            user_data.email,
            user_data.phone,
            user_data.password,
            user_data.gender,
            user_data.dob,
            user_data.latitude,
            user_data.longitude,
            user_data.location_name,
            user_data.premium
        )
        
        user_id = execute_insert(query, params)
        
        # Fetch and return created user
        rows = execute_query("SELECT * FROM users WHERE user_id = ?", (user_id,))
        user = User.from_db_row(rows[0])
        
        return jsonify(user.to_dict()), 201
        
    except ValidationError as e:
        return jsonify({'error': 'Validation error', 'details': e.errors()}), 400
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@bp.route('/users/<int:user_id>', methods=['PUT'])
def update_user(user_id):
    """Update user information"""
    try:
        # Validate request data
        update_data = UserUpdate(**request.json)
        
        # Get fields to update (exclude unset fields)
        update_dict = update_data.model_dump(exclude_unset=True)
        
        if not update_dict:
            return jsonify({'error': 'No fields to update'}), 400
        
        # Try Supabase first
        if supabase:
            try:
                # Check if user exists in Supabase
                existing = supabase.table('users').select('*').eq('user_id', user_id).execute()
                
                if existing.data and len(existing.data) > 0:
                    # Update in Supabase
                    print(f"📝 Updating user {user_id} in Supabase with data: {update_dict}")
                    response = supabase.table('users').update(update_dict).eq('user_id', user_id).execute()
                    
                    print(f"📊 Supabase response: {response}")
                    print(f"📊 Response data: {response.data}")
                    
                    if response.data and len(response.data) > 0:
                        print(f"✅ User {user_id} updated in Supabase")
                        return jsonify(response.data[0]), 200
                    else:
                        print(f"❌ Supabase update returned no data")
                        return jsonify({'error': 'Failed to update user in Supabase', 'details': str(response)}), 500
                else:
                    # User not found in Supabase, try local database
                    print(f"⚠️  User {user_id} not found in Supabase, checking local database...")
                    
            except Exception as supabase_error:
                print(f"⚠️  Supabase update failed: {supabase_error}")
                print("📍 Falling back to local database...")
        
        # Fallback to local SQLite database
        # Build dynamic UPDATE query
        fields = []
        params = []
        
        for field, value in update_dict.items():
            fields.append(f"{field} = ?")
            params.append(value)
        
        params.append(user_id)
        query = f"UPDATE users SET {', '.join(fields)} WHERE user_id = ?"
        
        affected = execute_update(query, params)
        
        if affected == 0:
            return jsonify({'error': 'User not found'}), 404
        
        # Fetch and return updated user
        rows = execute_query("SELECT * FROM users WHERE user_id = ?", (user_id,))
        user = User.from_db_row(rows[0])
        
        print(f"✅ User {user_id} updated in local database")
        return jsonify(user.to_dict()), 200
        
    except ValidationError as e:
        return jsonify({'error': 'Validation error', 'details': e.errors()}), 400
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@bp.route('/users/<int:user_id>', methods=['DELETE'])
def delete_user(user_id):
    """Delete user"""
    try:
        affected = execute_update(
            "DELETE FROM users WHERE user_id = ?",
            (user_id,)
        )
        
        if affected == 0:
            return jsonify({'error': 'User not found'}), 404
        
        return jsonify({'message': 'User deleted successfully'}), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500
