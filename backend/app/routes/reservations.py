"""
Reservation API Routes - Handle medicine reservations
"""

from flask import Blueprint, request, jsonify
from app.supabase_client import supabase
from app.core.database import execute_query, execute_insert

bp = Blueprint('reservations', __name__)

@bp.route('/reservations', methods=['POST'])
def create_reservation():
    """
    Create a new reservation
    
    Request body:
    {
        "user_id": 1,
        "pharmacy_id": 1,
        "medicine_name": "Paracetamol 500mg",
        "day": "2026-01-15",
        "time": "14:00",
        "quantity": 2,
        "is_premium": true
    }
    
    Returns:
    {
        "success": true,
        "reservation": {...},
        "source": "remote|local",
        "message": "Reservation created successfully"
    }
    """
    try:
        data = request.json
        
        # Validate required fields
        required_fields = ['user_id', 'pharmacy_id', 'medicine_name', 'day', 'time', 'quantity']
        for field in required_fields:
            if field not in data:
                return jsonify({
                    'success': False,
                    'error': f'Missing required field: {field}'
                }), 400
        
        user_id = data['user_id']
        pharmacy_id = data['pharmacy_id']
        medicine_name = data['medicine_name']
        day = data['day']
        time = data['time']
        quantity = data.get('quantity', 1)
        is_premium = data.get('is_premium', False)
        
        print(f"📝 Creating reservation for user {user_id} (premium: {is_premium})")
        
        # Prepare reservation data - only include medicine_find_id if it's valid
        reservation_data = {
            'user_id': user_id,
            'pharmacy_id': pharmacy_id,
            'medicine_name': medicine_name,
            'day': day,
            'time': time,
            'quantity': quantity,
            'status': 'pending'
        }
        
        # Only add medicine_find_id if it exists and is not 0
        medicine_find_id = data.get('medicine_find_id')
        if medicine_find_id and medicine_find_id != 0:
            reservation_data['medicine_find_id'] = medicine_find_id
        
        # Only use Supabase for premium users (no local fallback for backend)
        if is_premium:
            if not supabase:
                return jsonify({
                    'success': False,
                    'error': 'Supabase not configured'
                }), 500
                
            try:
                print(f"🔄 Attempting to insert into Supabase: {reservation_data}")
                response = supabase.table('reservation').insert(reservation_data).execute()
                
                print(f"📊 Supabase response: {response}")
                
                if response.data:
                    reservation = response.data[0]
                    print(f"✅ Reservation created in Supabase: {reservation['reservation_id']}")
                    
                    return jsonify({
                        'success': True,
                        'reservation': reservation,
                        'source': 'remote',
                        'message': 'Reservation created successfully'
                    }), 201
                else:
                    print(f"⚠️  No data returned from Supabase")
                    return jsonify({
                        'success': False,
                        'error': 'Failed to create reservation in Supabase'
                    }), 500
                    
            except Exception as supabase_error:
                print(f"❌ Supabase reservation failed: {supabase_error}")
                print(f"📋 Error type: {type(supabase_error).__name__}")
                import traceback
                print(f"📍 Full traceback:\n{traceback.format_exc()}")
                return jsonify({
                    'success': False,
                    'error': f'Supabase error: {str(supabase_error)}'
                }), 500
        else:
            # For non-premium users, return error (they should only save locally on frontend)
            return jsonify({
                'success': False,
                'error': 'Premium subscription required for remote reservations'
            }), 403
            
    except Exception as e:
        print(f"❌ Reservation error: {e}")
        import traceback
        traceback.print_exc()
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500


@bp.route('/reservations/<int:user_id>', methods=['GET'])
def get_user_reservations(user_id):
    """Get all reservations for a user"""
    try:
        print(f"📋 Fetching reservations for user {user_id}")
        
        # Try Supabase first
        if supabase:
            try:
                response = supabase.table('reservation') \
                    .select('*') \
                    .eq('user_id', user_id) \
                    .order('created_at', desc=True) \
                    .execute()
                
                if response.data:
                    print(f"✅ Found {len(response.data)} reservations from Supabase")
                    return jsonify({
                        'success': True,
                        'reservations': response.data,
                        'source': 'remote'
                    }), 200
            except Exception as supabase_error:
                print(f"⚠️  Supabase fetch failed: {supabase_error}")
        
        # Fallback to local
        rows = execute_query(
            "SELECT * FROM reservation WHERE user_id = ? ORDER BY created_at DESC",
            (user_id,)
        )
        
        reservations = [dict(row) for row in rows]
        
        return jsonify({
            'success': True,
            'reservations': reservations,
            'source': 'local'
        }), 200
        
    except Exception as e:
        print(f"❌ Error fetching reservations: {e}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500


@bp.route('/reservations/<int:reservation_id>', methods=['PATCH'])
def update_reservation_status(reservation_id):
    """
    Update reservation status
    
    Request body:
    {
        "status": "confirmed",
        "user_id": 1
    }
    
    Returns:
    {
        "success": true,
        "reservation": {...},
        "message": "Status updated successfully"
    }
    """
    try:
        data = request.json
        
        if 'status' not in data:
            return jsonify({
                'success': False,
                'error': 'Missing required field: status'
            }), 400
        
        status = data['status']
        user_id = data.get('user_id')
        
        print(f"🔄 Updating reservation {reservation_id} status to: {status}")
        
        if not supabase:
            return jsonify({
                'success': False,
                'error': 'Supabase not configured'
            }), 500
        
        # Update in Supabase
        try:
            response = supabase.table('reservation').update({
                'status': status
            }).eq('reservation_id', reservation_id).execute()
            
            if response.data:
                reservation = response.data[0]
                print(f"✅ Reservation {reservation_id} status updated to: {status}")
                
                return jsonify({
                    'success': True,
                    'reservation': reservation,
                    'message': 'Status updated successfully'
                }), 200
            else:
                return jsonify({
                    'success': False,
                    'error': 'Reservation not found'
                }), 404
                
        except Exception as supabase_error:
            print(f"❌ Supabase update failed: {supabase_error}")
            import traceback
            print(f"📍 Full traceback:\n{traceback.format_exc()}")
            return jsonify({
                'success': False,
                'error': f'Supabase error: {str(supabase_error)}'
            }), 500
            
    except Exception as e:
        print(f"❌ Update status error: {e}")
        import traceback
        traceback.print_exc()
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500
