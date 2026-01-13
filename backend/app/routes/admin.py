"""
Admin/Test routes for managing background jobs
"""

from flask import Blueprint, jsonify
from app.jobs.reservation_reminders import check_and_send_reservation_reminders

bp = Blueprint('admin', __name__)

@bp.route('/admin/test-reminders', methods=['POST'])
def trigger_reminder_job():
    """
    Manually trigger the reservation reminder job for testing
    
    Returns:
    {
        "success": true,
        "message": "Reminder job triggered successfully"
    }
    """
    try:
        print("🔧 Manually triggering reminder job...")
        check_and_send_reservation_reminders()
        
        return jsonify({
            'success': True,
            'message': 'Reminder job triggered successfully'
        }), 200
        
    except Exception as e:
        print(f"❌ Error triggering reminder job: {e}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500
