"""
Notification routes for retrieving user notifications
"""
from flask import Blueprint, request, jsonify
from app.supabase_client import supabase

notifications_bp = Blueprint('notifications', __name__)


@notifications_bp.route('/api/notifications/<int:user_id>', methods=['GET'])
def get_user_notifications(user_id):
    """
    Get all notifications for a specific user
    Query parameters:
    - type: Filter by notification type (optional)
    - is_read: Filter by read status (0 or 1, optional)
    - limit: Maximum number of notifications to return (default: 50)
    """
    try:
        if not supabase:
            return jsonify({
                'success': False,
                'error': 'Database not configured'
            }), 500
        
        # Build query
        query = supabase.table('notification').select('*').eq('user_id', user_id)
        
        # Apply filters from query parameters
        notification_type = request.args.get('type')
        if notification_type:
            query = query.eq('type', notification_type)
        
        is_read = request.args.get('is_read')
        if is_read is not None:
            query = query.eq('is_read', int(is_read))
        
        # Apply limit
        limit = request.args.get('limit', 50)
        query = query.limit(int(limit))
        
        # Order by created_at descending (newest first)
        query = query.order('created_at', desc=True)
        
        # Execute query
        response = query.execute()
        
        return jsonify({
            'success': True,
            'notifications': response.data,
            'count': len(response.data)
        }), 200
        
    except Exception as e:
        print(f"❌ Error fetching notifications: {e}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500


@notifications_bp.route('/api/notifications/<int:notification_id>/mark-read', methods=['PUT'])
def mark_notification_read(notification_id):
    """
    Mark a notification as read
    """
    try:
        if not supabase:
            return jsonify({
                'success': False,
                'error': 'Database not configured'
            }), 500
        
        # Update notification
        response = supabase.table('notification')\
            .update({'is_read': 1})\
            .eq('notification_id', notification_id)\
            .execute()
        
        return jsonify({
            'success': True,
            'message': 'Notification marked as read'
        }), 200
        
    except Exception as e:
        print(f"❌ Error marking notification as read: {e}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500


@notifications_bp.route('/api/notifications/mark-all-read/<int:user_id>', methods=['PUT'])
def mark_all_notifications_read(user_id):
    """
    Mark all notifications for a user as read
    """
    try:
        if not supabase:
            return jsonify({
                'success': False,
                'error': 'Database not configured'
            }), 500
        
        # Update all user's notifications
        response = supabase.table('notification')\
            .update({'is_read': 1})\
            .eq('user_id', user_id)\
            .eq('is_read', 0)\
            .execute()
        
        return jsonify({
            'success': True,
            'message': 'All notifications marked as read'
        }), 200
        
    except Exception as e:
        print(f"❌ Error marking all notifications as read: {e}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500
