from flask import Blueprint, jsonify, request
from app.supabase_client import supabase
from app.core.database import execute_query
import math

pharmacies_bp = Blueprint('pharmacies', __name__)

def calculate_distance(lat1, lon1, lat2, lon2):
    """Calculate distance between two coordinates in km using Haversine formula"""
    R = 6371  # Earth's radius in kilometers
    
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    a = (math.sin(dlat / 2) ** 2 + 
         math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * 
         math.sin(dlon / 2) ** 2)
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    distance = R * c
    
    return distance

@pharmacies_bp.route('/all', methods=['GET'])
def get_all_pharmacies():
    """Get all pharmacies from Supabase"""
    try:
        # Get user location from query params (optional)
        user_lat = request.args.get('user_lat', type=float)
        user_lon = request.args.get('user_lon', type=float)
        
        print(f"📍 Fetching all pharmacies (user location: {user_lat}, {user_lon})")
        
        # Fetch from Supabase
        response = supabase.table('pharmacy').select('*').execute()
        
        if response.data:
            pharmacies = response.data
            
            # Calculate distances if user location provided
            if user_lat and user_lon:
                for pharmacy in pharmacies:
                    if pharmacy.get('latitude') and pharmacy.get('longitude'):
                        distance = calculate_distance(
                            user_lat, user_lon,
                            pharmacy['latitude'], pharmacy['longitude']
                        )
                        pharmacy['distance'] = round(distance, 2)
                    else:
                        pharmacy['distance'] = None
                
                # Sort by distance if available
                pharmacies.sort(key=lambda x: x.get('distance') if x.get('distance') is not None else float('inf'))
            
            print(f"✅ Retrieved {len(pharmacies)} pharmacies from Supabase")
            return jsonify({
                'success': True,
                'pharmacies': pharmacies,
                'source': 'remote'
            }), 200
        else:
            print("❌ No pharmacies found in Supabase")
            return jsonify({
                'success': False,
                'error': 'No pharmacies found'
            }), 404
            
    except Exception as e:
        print(f"❌ Error fetching pharmacies: {str(e)}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@pharmacies_bp.route('/search', methods=['GET'])
def search_pharmacies():
    """Search pharmacies by name"""
    try:
        query = request.args.get('q', '').strip()
        
        if not query:
            return jsonify({
                'success': False,
                'error': 'Search query is required'
            }), 400
        
        print(f"🔍 Searching pharmacies for: {query}")
        
        # Search in Supabase using ilike for case-insensitive search
        response = supabase.table('pharmacy').select('*').ilike('name', f'%{query}%').execute()
        
        if response.data:
            print(f"✅ Found {len(response.data)} pharmacies matching '{query}'")
            return jsonify({
                'success': True,
                'pharmacies': response.data,
                'source': 'remote'
            }), 200
        else:
            print(f"❌ No pharmacies found matching '{query}'")
            return jsonify({
                'success': True,
                'pharmacies': [],
                'source': 'remote'
            }), 200
            
    except Exception as e:
        print(f"❌ Error searching pharmacies: {str(e)}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@pharmacies_bp.route('/<int:pharmacy_id>', methods=['GET'])
def get_pharmacy(pharmacy_id):
    """Get pharmacy by ID"""
    try:
        print(f"📍 Fetching pharmacy {pharmacy_id}")
        
        # Fetch from Supabase
        response = supabase.table('pharmacy').select('*').eq('pharmacy_id', pharmacy_id).execute()
        
        if response.data and len(response.data) > 0:
            print(f"✅ Found pharmacy {pharmacy_id}")
            return jsonify({
                'success': True,
                'pharmacy': response.data[0],
                'source': 'remote'
            }), 200
        else:
            print(f"❌ Pharmacy {pharmacy_id} not found")
            return jsonify({
                'success': False,
                'error': 'Pharmacy not found'
            }), 404
            
    except Exception as e:
        print(f"❌ Error fetching pharmacy: {str(e)}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@pharmacies_bp.route('/nearby', methods=['GET'])
def get_nearby_pharmacies():
    """Get pharmacies near user location"""
    try:
        user_lat = request.args.get('lat', type=float)
        user_lon = request.args.get('lon', type=float)
        radius = request.args.get('radius', default=10, type=float)  # Default 10km
        limit = request.args.get('limit', default=10, type=int)
        
        if not user_lat or not user_lon:
            return jsonify({
                'success': False,
                'error': 'User location (lat, lon) is required'
            }), 400
        
        print(f"📍 Fetching pharmacies near ({user_lat}, {user_lon}) within {radius}km")
        
        # Fetch all pharmacies with coordinates
        response = supabase.table('pharmacy').select('*').not_.is_('latitude', 'null').not_.is_('longitude', 'null').execute()
        
        if response.data:
            # Calculate distances and filter
            nearby_pharmacies = []
            for pharmacy in response.data:
                distance = calculate_distance(
                    user_lat, user_lon,
                    pharmacy['latitude'], pharmacy['longitude']
                )
                
                if distance <= radius:
                    pharmacy['distance'] = round(distance, 2)
                    nearby_pharmacies.append(pharmacy)
            
            # Sort by distance and limit
            nearby_pharmacies.sort(key=lambda x: x['distance'])
            nearby_pharmacies = nearby_pharmacies[:limit]
            
            print(f"✅ Found {len(nearby_pharmacies)} pharmacies within {radius}km")
            return jsonify({
                'success': True,
                'pharmacies': nearby_pharmacies,
                'source': 'remote'
            }), 200
        else:
            print("❌ No pharmacies found")
            return jsonify({
                'success': True,
                'pharmacies': [],
                'source': 'remote'
            }), 200
            
    except Exception as e:
        print(f"❌ Error fetching nearby pharmacies: {str(e)}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500
