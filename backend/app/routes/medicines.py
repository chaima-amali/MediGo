"""
Medicine Tracking API Routes - CRUD operations
Example of interacting with medicine_tracking table
"""

from flask import Blueprint, request, jsonify
from pydantic import ValidationError
from app.core.database import execute_query, execute_insert, execute_update
from app.models.medicine import MedicineTracking
from app.schemas.medicine import MedicineTrackingCreate, MedicineTrackingUpdate

bp = Blueprint('medicines', __name__)

@bp.route('/medicines', methods=['GET'])
def get_medicines():
    """
    Get all medicine tracking entries
    Query params:
        - user_id: Filter by user ID
    """
    user_id = request.args.get('user_id', type=int)
    
    query = "SELECT * FROM medicine_tracking WHERE 1=1"
    params = []
    
    if user_id:
        query += " AND user_id = ?"
        params.append(user_id)
    
    try:
        rows = execute_query(query, params)
        medicines = [MedicineTracking.from_db_row(row).to_dict() for row in rows]
        
        return jsonify({
            'count': len(medicines),
            'medicines': medicines
        }), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@bp.route('/medicines/<int:medicine_id>', methods=['GET'])
def get_medicine(medicine_id):
    """Get medicine by ID"""
    try:
        rows = execute_query(
            "SELECT * FROM medicine_tracking WHERE medicine_track_id = ?",
            (medicine_id,)
        )
        
        if not rows:
            return jsonify({'error': 'Medicine not found'}), 404
        
        medicine = MedicineTracking.from_db_row(rows[0])
        return jsonify(medicine.to_dict()), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@bp.route('/medicines', methods=['POST'])
def create_medicine():
    """Create new medicine tracking entry"""
    try:
        # Validate request data
        medicine_data = MedicineTrackingCreate(**request.json)
        
        # Insert into database
        query = """
            INSERT INTO medicine_tracking (user_id, name, type, dosage)
            VALUES (?, ?, ?, ?)
        """
        params = (
            medicine_data.user_id,
            medicine_data.name,
            medicine_data.type,
            medicine_data.dosage
        )
        
        medicine_id = execute_insert(query, params)
        
        # Fetch and return created medicine
        rows = execute_query(
            "SELECT * FROM medicine_tracking WHERE medicine_track_id = ?",
            (medicine_id,)
        )
        medicine = MedicineTracking.from_db_row(rows[0])
        
        return jsonify(medicine.to_dict()), 201
        
    except ValidationError as e:
        return jsonify({'error': 'Validation error', 'details': e.errors()}), 400
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@bp.route('/medicines/<int:medicine_id>', methods=['PUT'])
def update_medicine(medicine_id):
    """Update medicine tracking entry"""
    try:
        # Validate request data
        update_data = MedicineTrackingUpdate(**request.json)
        
        # Build dynamic UPDATE query
        fields = []
        params = []
        
        for field, value in update_data.model_dump(exclude_unset=True).items():
            fields.append(f"{field} = ?")
            params.append(value)
        
        if not fields:
            return jsonify({'error': 'No fields to update'}), 400
        
        params.append(medicine_id)
        query = f"UPDATE medicine_tracking SET {', '.join(fields)} WHERE medicine_track_id = ?"
        
        affected = execute_update(query, params)
        
        if affected == 0:
            return jsonify({'error': 'Medicine not found'}), 404
        
        # Fetch and return updated medicine
        rows = execute_query(
            "SELECT * FROM medicine_tracking WHERE medicine_track_id = ?",
            (medicine_id,)
        )
        medicine = MedicineTracking.from_db_row(rows[0])
        
        return jsonify(medicine.to_dict()), 200
        
    except ValidationError as e:
        return jsonify({'error': 'Validation error', 'details': e.errors()}), 400
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@bp.route('/medicines/<int:medicine_id>', methods=['DELETE'])
def delete_medicine(medicine_id):
    """Delete medicine tracking entry"""
    try:
        affected = execute_update(
            "DELETE FROM medicine_tracking WHERE medicine_track_id = ?",
            (medicine_id,)
        )
        
        if affected == 0:
            return jsonify({'error': 'Medicine not found'}), 404
        
        return jsonify({'message': 'Medicine deleted successfully'}), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500
