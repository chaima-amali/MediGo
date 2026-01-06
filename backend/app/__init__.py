"""
Flask Application Factory
Initializes and configures the Flask app with all extensions and routes
"""

from flask import Flask, jsonify
from flask_cors import CORS
from app.core.config import settings
from app.core.database import init_db

def create_app():
    """Create and configure Flask application"""
    
    app = Flask(__name__)
    
    # Load configuration
    app.config.from_object(settings)
    
    # Enable CORS for Flutter app
    CORS(app, resources={r"/api/*": {"origins": "*"}})
    
    # Initialize database
    init_db(app)
    
    # Register routes
    register_routes(app)
    
    # Register error handlers
    register_error_handlers(app)
    
    return app

def register_routes(app):
    """Register all API route blueprints"""
    
    from app.routes import health, users, medicines
    
    # Health check and info endpoints
    app.register_blueprint(health.bp)
    
    # API endpoints
    app.register_blueprint(users.bp, url_prefix='/api')
    app.register_blueprint(medicines.bp, url_prefix='/api')
    
    # TODO: Add more route blueprints here as you expand
    # app.register_blueprint(pharmacies.bp, url_prefix='/api')
    # app.register_blueprint(reservations.bp, url_prefix='/api')

def register_error_handlers(app):
    """Register global error handlers"""
    
    @app.errorhandler(404)
    def not_found(error):
        return jsonify({'error': 'Resource not found'}), 404
    
    @app.errorhandler(500)
    def internal_error(error):
        return jsonify({'error': 'Internal server error'}), 500
    
    @app.errorhandler(400)
    def bad_request(error):
        return jsonify({'error': 'Bad request'}), 400
