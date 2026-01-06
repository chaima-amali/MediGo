"""
User API Routes - CRUD operations for users
Demonstrates interaction with existing database
"""

from flask import Blueprint, request, jsonify
from pydantic import ValidationError
from app.core.database import execute_query, execute_insert, execute_update
from app.models.user import User
from app.schemas.user import UserCreate, UserUpdate

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
    query = "SELECT * FROM user WHERE 1=1"
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
    """Get user by ID"""
    try:
        rows = execute_query(
            "SELECT * FROM user WHERE user_id = ?",
            (user_id,)
        )
        
        if not rows:
            return jsonify({'error': 'User not found'}), 404
        
        user = User.from_db_row(rows[0])
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
            INSERT INTO user (name, email, phone, password, gender, dob, 
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
        rows = execute_query("SELECT * FROM user WHERE user_id = ?", (user_id,))
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
        
        # Build dynamic UPDATE query
        fields = []
        params = []
        
        for field, value in update_data.model_dump(exclude_unset=True).items():
            fields.append(f"{field} = ?")
            params.append(value)
        
        if not fields:
            return jsonify({'error': 'No fields to update'}), 400
        
        params.append(user_id)
        query = f"UPDATE user SET {', '.join(fields)} WHERE user_id = ?"
        
        affected = execute_update(query, params)
        
        if affected == 0:
            return jsonify({'error': 'User not found'}), 404
        
        # Fetch and return updated user
        rows = execute_query("SELECT * FROM user WHERE user_id = ?", (user_id,))
        user = User.from_db_row(rows[0])
        
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
            "DELETE FROM user WHERE user_id = ?",
            (user_id,)
        )
        
        if affected == 0:
            return jsonify({'error': 'User not found'}), 404
        
        return jsonify({'message': 'User deleted successfully'}), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500
