"""
Medicine Search API Routes - Remote search & reservation system
Handles medicine search, notify-me, and premium reservations
"""

from flask import Blueprint, request, jsonify
from pydantic import ValidationError
import asyncio
from functools import wraps

from app.services.medicine_search_service import MedicineSearchService
from app.schemas.search_history import (
    MedicineSearchRequest,
    NotifyMeRequest,
    ReservationCreateRequest
)

bp = Blueprint('medicine_search', __name__)


def async_route(f):
    """Decorator to handle async route functions"""
    @wraps(f)
    def wrapper(*args, **kwargs):
        return asyncio.run(f(*args, **kwargs))
    return wrapper


@bp.route('/search/medicines', methods=['POST'])
@async_route
async def search_medicines():
    """
    Search medicines by name with availability from pharmacies
    
    Request Body:
        {
            "search_query": "aspirin"
        }
    
    Response:
        {
            "success": true,
            "count": 2,
            "results": [
                {
                    "medicine_id": 1,
                    "name": "Aspirin 500mg",
                    "generic_name": "Acetylsalicylic acid",
                    "availability": [
                        {
                            "pharmacy_id": 5,
                            "pharmacy_name": "HealthPlus Pharmacy",
                            "price": 12.50,
                            "stock": 100,
                            "address": "123 Main St"
                        }
                    ]
                }
            ]
        }
    """
    try:
        # Validate request
        search_request = MedicineSearchRequest(**request.json)
        
        # Initialize service
        service = MedicineSearchService()
        
        # Perform search
        results = await service.search_medicines(search_request.search_query)
        
        return jsonify({
            'success': True,
            'count': len(results),
            'results': results
        }), 200
        
    except ValidationError as e:
        return jsonify({
            'success': False,
            'error': 'Validation error',
            'details': e.errors()
        }), 400
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500


@bp.route('/search/notify-me', methods=['POST'])
@async_route
async def notify_me():
    """
    Record that a user wants to be notified when a medicine becomes available
    Used when search returns no results
    
    Request Body:
        {
            "user_id": 123,
            "medicine_name": "Rare Medicine X"
        }
    
    Response:
        {
            "success": true,
            "message": "You will be notified when 'Rare Medicine X' becomes available",
            "record_id": 456
        }
    """
    try:
        # Validate request
        notify_request = NotifyMeRequest(**request.json)
        
        # Initialize service
        service = MedicineSearchService()
        
        # Record search not found
        result = await service.record_search_not_found(
            user_id=notify_request.user_id,
            medicine_name=notify_request.medicine_name
        )
        
        return jsonify({
            'success': True,
            'message': result['message'],
            'record_id': result['record'].get('id')
        }), 201
        
    except ValidationError as e:
        return jsonify({
            'success': False,
            'error': 'Validation error',
            'details': e.errors()
        }), 400
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500


@bp.route('/reservations', methods=['POST'])
@async_route
async def create_reservation():
    """
    Create a medicine reservation (Premium users only)
    Validates user premium status and stock availability
    
    Request Body:
        {
            "user_id": 123,
            "medicine_id": 456,
            "pharmacy_id": 789,
            "medicine_name": "Aspirin 500mg",
            "quantity": 2
        }
    
    Response (Success):
        {
            "success": true,
            "message": "Reservation created successfully",
            "reservation_id": 999,
            "status": "PENDING"
        }
    
    Response (Not Premium):
        {
            "success": false,
            "error": "Reservation feature is only available for premium users. Please upgrade to premium."
        }
    
    Response (Insufficient Stock):
        {
            "success": false,
            "error": "Insufficient stock. Available: 1, Requested: 2"
        }
    """
    try:
        # Validate request
        reservation_request = ReservationCreateRequest(**request.json)
        
        # Initialize service
        service = MedicineSearchService()
        
        # Create reservation
        result = await service.create_reservation(
            user_id=reservation_request.user_id,
            medicine_id=reservation_request.medicine_id,
            pharmacy_id=reservation_request.pharmacy_id,
            medicine_name=reservation_request.medicine_name,
            quantity=reservation_request.quantity
        )
        
        reservation = result['reservation']
        
        return jsonify({
            'success': True,
            'message': result['message'],
            'reservation_id': reservation.get('reservation_id'),
            'status': reservation.get('status'),
            'created_at': reservation.get('created_at')
        }), 201
        
    except ValidationError as e:
        return jsonify({
            'success': False,
            'error': 'Validation error',
            'details': e.errors()
        }), 400
    except Exception as e:
        error_message = str(e)
        
        # Handle specific error cases with appropriate status codes
        if 'premium' in error_message.lower():
            return jsonify({
                'success': False,
                'error': error_message,
                'error_code': 'PREMIUM_REQUIRED'
            }), 403  # Forbidden
        elif 'insufficient stock' in error_message.lower():
            return jsonify({
                'success': False,
                'error': error_message,
                'error_code': 'INSUFFICIENT_STOCK'
            }), 409  # Conflict
        elif 'not available' in error_message.lower():
            return jsonify({
                'success': False,
                'error': error_message,
                'error_code': 'NOT_AVAILABLE'
            }), 404  # Not Found
        else:
            return jsonify({
                'success': False,
                'error': error_message
            }), 500


@bp.route('/reservations/user/<int:user_id>', methods=['GET'])
@async_route
async def get_user_reservations(user_id):
    """
    Get all reservations for a specific user
    
    Path Parameters:
        user_id: ID of the user
    
    Response:
        {
            "success": true,
            "count": 3,
            "reservations": [
                {
                    "reservation_id": 999,
                    "medicine_name": "Aspirin 500mg",
                    "quantity": 2,
                    "status": "PENDING",
                    "pharmacy_name": "HealthPlus Pharmacy",
                    "created_at": "2026-01-08T10:30:00"
                }
            ]
        }
    """
    try:
        # Initialize service
        service = MedicineSearchService()
        
        # Fetch reservations
        reservations = await service.get_user_reservations(user_id)
        
        return jsonify({
            'success': True,
            'count': len(reservations),
            'reservations': reservations
        }), 200
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500


@bp.route('/search/history/<int:user_id>', methods=['GET'])
@async_route
async def get_search_history(user_id):
    """
    Get search history for a specific user
    
    Path Parameters:
        user_id: ID of the user
    
    Response:
        {
            "success": true,
            "count": 5,
            "history": [
                {
                    "id": 123,
                    "medicine_name": "Aspirin",
                    "searched_at": "2026-01-08T10:30:00",
                    "notify_restock": 0
                }
            ]
        }
    """
    try:
        # Initialize service
        service = MedicineSearchService()
        
        # Fetch search history
        history = await service.get_search_history(user_id)
        
        return jsonify({
            'success': True,
            'count': len(history),
            'history': history
        }), 200
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500


@bp.route('/user/<int:user_id>/premium-status', methods=['GET'])
@async_route
async def check_premium_status(user_id):
    """
    Check if a user has premium status
    
    Path Parameters:
        user_id: ID of the user
    
    Response:
        {
            "success": true,
            "user_id": 123,
            "is_premium": true
        }
    """
    try:
        # Initialize service
        service = MedicineSearchService()
        
        # Check premium status
        is_premium = await service.check_user_premium_status(user_id)
        
        return jsonify({
            'success': True,
            'user_id': user_id,
            'is_premium': is_premium
        }), 200
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500
