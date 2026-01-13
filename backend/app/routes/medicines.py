"""
Medicine Tracking API Routes - CRUD operations
Example of interacting with medicine_tracking table
"""

from flask import Blueprint, request, jsonify
from pydantic import ValidationError
from app.core.database import execute_query, execute_insert, execute_update
from app.models.medicine import MedicineTracking
from app.schemas.medicine import MedicineTrackingCreate, MedicineTrackingUpdate
from app.supabase_client import supabase

bp = Blueprint('medicines', __name__)

@bp.route('/medicines/search', methods=['GET'])
def search_medicines():
    """
    Search medicines and return pharmacies that have them in stock
    
    Query params:
        - q: Search query (searches medicine name, generic_name)
        - limit: Max results (default: 20, max: 100)
    
    Returns:
        {
            "success": true,
            "count": 10,
            "medicines": [
                {
                    "pharmacy_id": 1,
                    "pharmacy_name": "Care Pharmacy",
                    "medicine_name": "Paracetamol 500mg",
                    "price": 5.50,
                    "stock": 100,
                    "latitude": 40.7128,
                    "longitude": -74.0060,
                    "phone": "123-456-7890",
                    "rating": 4.5
                }
            ],
            "source": "remote|local"
        }
    """
    try:
        query = request.args.get('q', '').strip()
        limit = min(int(request.args.get('limit', 20)), 100)
        
        if not query:
            return jsonify({
                'success': False,
                'error': 'Search query is required'
            }), 400
        
        # Try Supabase first
        if supabase:
            try:
                print(f"🔍 Searching Supabase for: {query}")
                search_pattern = f"%{query}%"
                
                # Query pharmacy_medicine with joins to get all needed data
                response = supabase.table('pharmacy_medicine') \
                    .select('id, price, stock, pharmacy:pharmacy_id(pharmacy_id, name, latitude, longitude, phone, rating, opening_hours), medicine:medicine_id(medicine_id, name, dosage, generic_name)') \
                    .gt('stock', 0) \
                    .limit(200) \
                    .execute()
                
                print(f"✅ Got {len(response.data) if response.data else 0} inventory items from Supabase")
                
                if not response.data:
                    return jsonify({
                        'success': True,
                        'count': 0,
                        'medicines': [],
                        'source': 'remote'
                    }), 200
                
                # Filter by medicine name/generic_name (case-insensitive)
                results = []
                query_lower = query.lower()
                
                for item in response.data:
                    medicine = item.get('medicine')
                    pharmacy = item.get('pharmacy')
                    
                    if medicine and pharmacy:
                        medicine_name = medicine.get('name', '').lower()
                        generic_name = medicine.get('generic_name', '').lower() if medicine.get('generic_name') else ''
                        
                        # Check if query matches medicine name or generic name
                        if query_lower in medicine_name or query_lower in generic_name:
                            medicine_display_name = medicine.get('name', '')
                            # Don't append dosage since it's likely already in the name
                            
                            results.append({
                                'pharmacy_id': pharmacy.get('pharmacy_id'),
                                'pharmacy_name': pharmacy.get('name'),
                                'medicine_name': medicine_display_name.strip(),
                                'price': float(item.get('price', 0)),
                                'stock': int(item.get('stock', 0)),
                                'latitude': pharmacy.get('latitude'),
                                'longitude': pharmacy.get('longitude'),
                                'phone': pharmacy.get('phone'),
                                'rating': pharmacy.get('rating'),
                                'opening_hours': pharmacy.get('opening_hours'),
                            })
                            
                            if len(results) >= limit:
                                break
                
                print(f"✅ Filtered to {len(results)} matching pharmacies")
                
                return jsonify({
                    'success': True,
                    'count': len(results),
                    'medicines': results,
                    'source': 'remote'
                }), 200
                
            except Exception as supabase_error:
                print(f"⚠️  Supabase search failed: {supabase_error}")
                import traceback
                traceback.print_exc()
                print("📍 Falling back to local database")
        
        # Fallback to local SQLite
        local_query = """
            SELECT 
                pm.id,
                pm.pharmacy_id,
                p.name as pharmacy_name,
                m.name || ' ' || COALESCE(m.dosage, '') as medicine_name,
                pm.price,
                pm.stock,
                p.latitude,
                p.longitude,
                p.phone,
                p.rating,
                p.opening_hours
            FROM pharmacy_medicine pm
            JOIN pharmacy p ON pm.pharmacy_id = p.pharmacy_id
            JOIN medicine m ON pm.medicine_id = m.medicine_id
            WHERE (m.name LIKE ? OR m.generic_name LIKE ?)
            AND pm.stock > 0
            LIMIT ?
        """
        search_param = f"%{query}%"
        rows = execute_query(local_query, (search_param, search_param, limit))
        
        medicines = []
        for row in rows:
            med_dict = dict(row)
            medicines.append(med_dict)
        
        return jsonify({
            'success': True,
            'count': len(medicines),
            'medicines': medicines,
            'source': 'local'
        }), 200
        
    except Exception as e:
        print(f"❌ Search error: {e}")
        import traceback
        traceback.print_exc()
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500


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
