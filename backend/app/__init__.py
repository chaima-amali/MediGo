"""
Flask Application Factory
Initializes and configures the Flask app with all extensions and routes
"""

from flask import Flask, jsonify
from flask_cors import CORS
from flask_swagger_ui import get_swaggerui_blueprint
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
    
    # Register Swagger UI
    register_swagger(app)
    
    # Register error handlers
    register_error_handlers(app)
    
    return app

def register_routes(app):
    """Register all API route blueprints"""
    
    from flask import send_from_directory
    import os
    from app.routes import users, medicines, auth, medicine_search
    
    # Root endpoint
    @app.route('/')
    def index():
        return jsonify({
            'name': 'MediGo Backend API',
            'version': '1.0.0',
            'status': 'running',
            'endpoints': {
                'health': '/api/health',
                'swagger': '/docs',
                'mobile_test': '/mobile',
                'search': '/api/search/medicines',
                'reservations': '/api/reservations',
                'auth': '/api/auth/login'
            }
        })
    
    # Health check endpoint
    @app.route('/api/health')
    def health_check():
        return jsonify({
            'status': 'healthy',
            'database': 'connected',
            'supabase': 'connected'
        })
    
    # Mobile test page
    @app.route('/mobile')
    def mobile_test():
        return send_from_directory(os.path.dirname(os.path.dirname(__file__)), 'mobile_test.html')
    
    # API endpoints
    app.register_blueprint(auth.bp, url_prefix='/api')
    app.register_blueprint(users.bp, url_prefix='/api')
    app.register_blueprint(medicines.bp, url_prefix='/api')
    app.register_blueprint(medicine_search.bp, url_prefix='/api')
    
    # TODO: Add more route blueprints here as you expand
    # app.register_blueprint(pharmacies.bp, url_prefix='/api')
    # app.register_blueprint(reservations.bp, url_prefix='/api')

def register_swagger(app):
    """Register Swagger UI for API documentation"""
    
    SWAGGER_URL = '/docs'
    API_URL = '/static/swagger.json'
    
    swaggerui_blueprint = get_swaggerui_blueprint(
        SWAGGER_URL,
        API_URL,
        config={'app_name': "MediGo API"}
    )
    
    app.register_blueprint(swaggerui_blueprint, url_prefix=SWAGGER_URL)
    
    # Serve swagger.json
    @app.route('/static/swagger.json')
    def swagger_json():
        return jsonify(get_swagger_spec())

def get_swagger_spec():
    """Generate OpenAPI/Swagger specification"""
    return {
        "openapi": "3.0.0",
        "info": {
            "title": "MediGo Backend API",
            "version": "1.0.0",
            "description": "API documentation for MediGo - Medicine tracking and pharmacy locator app"
        },
        "servers": [
            {"url": "http://localhost:5000", "description": "Development server"},
            {"url": "http://10.250.176.125:5000", "description": "Network server"}
        ],
        "paths": {
            "/api/auth/register": {
                "post": {
                    "tags": ["Authentication"],
                    "summary": "Register a new user",
                    "requestBody": {
                        "required": True,
                        "content": {
                            "application/json": {
                                "schema": {
                                    "type": "object",
                                    "required": ["name", "email", "phone", "password", "gender", "dob"],
                                    "properties": {
                                        "name": {"type": "string", "example": "John Doe"},
                                        "email": {"type": "string", "example": "john@example.com"},
                                        "phone": {"type": "string", "example": "1234567890"},
                                        "password": {"type": "string", "example": "password123"},
                                        "gender": {"type": "string", "example": "male"},
                                        "dob": {"type": "string", "example": "1990-01-01"},
                                        "latitude": {"type": "number", "example": 36.686},
                                        "longitude": {"type": "number", "example": 2.864},
                                        "location_name": {"type": "string", "example": "Mahelma"},
                                        "premium": {"type": "string", "example": "false"}
                                    }
                                }
                            }
                        }
                    },
                    "responses": {
                        "200": {"description": "User registered successfully"},
                        "409": {"description": "Email or phone already exists"},
                        "500": {"description": "Server error"}
                    }
                }
            },
            "/api/auth/login": {
                "post": {
                    "tags": ["Authentication"],
                    "summary": "Login user",
                    "requestBody": {
                        "required": True,
                        "content": {
                            "application/json": {
                                "schema": {
                                    "type": "object",
                                    "required": ["email", "password"],
                                    "properties": {
                                        "email": {"type": "string", "example": "john@example.com"},
                                        "password": {"type": "string", "example": "password123"}
                                    }
                                }
                            }
                        }
                    },
                    "responses": {
                        "200": {"description": "Login successful"},
                        "401": {"description": "Invalid credentials"},
                        "500": {"description": "Server error"}
                    }
                }
            },
            "/api/users": {
                "get": {
                    "tags": ["Users"],
                    "summary": "Get all users",
                    "responses": {
                        "200": {"description": "List of users"}
                    }
                }
            },
            "/api/users/{user_id}": {
                "get": {
                    "tags": ["Users"],
                    "summary": "Get user by ID",
                    "parameters": [{
                        "name": "user_id",
                        "in": "path",
                        "required": True,
                        "schema": {"type": "integer"}
                    }],
                    "responses": {
                        "200": {"description": "User details"},
                        "404": {"description": "User not found"}
                    }
                }
            },
            "/api/medicines": {
                "get": {
                    "tags": ["Medicines"],
                    "summary": "Get all medicines",
                    "responses": {
                        "200": {"description": "List of medicines"}
                    }
                }
            }
        }
    }

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
