"""
Health Check and Info Routes
"""

from flask import Blueprint, jsonify
from datetime import datetime
from app.core.config import settings

bp = Blueprint('health', __name__)

@bp.route('/', methods=['GET'])
def root():
    """Root endpoint - Welcome message"""
    return jsonify({
        'message': f'Welcome to {settings.APP_NAME}',
        'version': settings.VERSION,
        'status': 'running',
        'timestamp': datetime.utcnow().isoformat()
    })

@bp.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint for monitoring"""
    return jsonify({
        'status': 'healthy',
        'environment': settings.ENVIRONMENT,
        'database': settings.DATABASE_PATH,
        'timestamp': datetime.utcnow().isoformat()
    })

@bp.route('/api', methods=['GET'])
def api_info():
    """API information and available endpoints"""
    return jsonify({
        'name': settings.APP_NAME,
        'version': settings.VERSION,
        'endpoints': {
            'health': '/health',
            'users': '/api/users',
            'medicines': '/api/medicines'
        },
        'documentation': 'See README.md for full API documentation'
    })
