"""
Medicine Search History API Routes
"""

from flask import Blueprint, request, jsonify
from app.supabase_client import supabase
from datetime import datetime

bp = Blueprint('medicine_search_history', __name__)

@bp.route('/medicine-search-history', methods=['POST'])
def create_search_history():
    """
    Save medicine search history with notification preference
    
    Request body:
    {
        "user_id": 1,
        "medicine_name": "Paracetamol 500mg",
        "notify_restock": true
    }
    
    Returns:
    {
        "success": true,
        "history": {...},
        "message": "Search history saved"
    }
    """
    try:
        data = request.json
        
        # Validate required fields
        if 'user_id' not in data or 'medicine_name' not in data:
            return jsonify({
                'success': False,
                'error': 'Missing required fields: user_id, medicine_name'
            }), 400
        
        user_id = data['user_id']
        medicine_name = data['medicine_name']
        notify_restock = data.get('notify_restock', False)
        
        if not supabase:
            return jsonify({
                'success': False,
                'error': 'Supabase not configured'
            }), 500
        
        print(f"📝 Saving search history for user {user_id}: {medicine_name} (notify: {notify_restock})")
        
        # Check if already exists
        existing = supabase.table('medicine_search_history').select('*').eq('user_id', user_id).eq('medicine_name', medicine_name).execute()
        
        if existing.data and len(existing.data) > 0:
            # Update existing record
            print(f"🔄 Updating existing search history ID: {existing.data[0]['id']}")
            response = supabase.table('medicine_search_history').update({
                'notify_restock': 1 if notify_restock else 0,
                'searched_at': datetime.utcnow().isoformat()
            }).eq('id', existing.data[0]['id']).execute()
        else:
            # Insert new record
            print(f"➕ Creating new search history")
            response = supabase.table('medicine_search_history').insert({
                'user_id': user_id,
                'medicine_name': medicine_name,
                'notify_restock': 1 if notify_restock else 0,
                'searched_at': datetime.utcnow().isoformat()
            }).execute()
        
        if response.data:
            history = response.data[0]
            print(f"✅ Search history saved: ID {history['id']}")
            
            return jsonify({
                'success': True,
                'history': history,
                'message': 'Search history saved successfully'
            }), 201
        else:
            return jsonify({
                'success': False,
                'error': 'Failed to save search history'
            }), 500
            
    except Exception as e:
        print(f"❌ Search history error: {e}")
        import traceback
        print(f"📍 Full traceback:\n{traceback.format_exc()}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500


@bp.route('/medicine-search-history/<int:user_id>', methods=['GET'])
def get_user_search_history(user_id):
    """
    Get all search history for a user with restock notifications enabled
    """
    try:
        if not supabase:
            return jsonify({
                'success': False,
                'error': 'Supabase not configured'
            }), 500
        
        response = supabase.table('medicine_search_history').select('*').eq('user_id', user_id).eq('notify_restock', 1).order('searched_at', desc=True).execute()
        
        return jsonify({
            'success': True,
            'history': response.data
        }), 200
        
    except Exception as e:
        print(f"❌ Get search history error: {e}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500
