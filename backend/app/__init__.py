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
    
    # Start reminder scheduler for medicine notifications
    try:
        from app.services.reminder_scheduler import scheduler
        scheduler.app = app  # Set Flask app context for scheduler
        scheduler.start()
        print('✅ Medicine reminder scheduler started')
    except Exception as e:
        print(f'⚠️  Failed to start reminder scheduler: {e}')
    
    return app

def register_routes(app):
    """Register all API route blueprints"""
    
    from app.routes import users, medicines, auth, tracking, statistics
    
    # API endpoints
    app.register_blueprint(auth.bp, url_prefix='/api')
    app.register_blueprint(users.bp, url_prefix='/api')
    app.register_blueprint(medicines.bp, url_prefix='/api')
    app.register_blueprint(tracking.bp, url_prefix='/api')
    app.register_blueprint(statistics.bp, url_prefix='/api')
    
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
            },
            "/api/tracking/medicines": {
                "post": {
                    "tags": ["Medicine Tracking"],
                    "summary": "Add a new medicine to tracking",
                    "requestBody": {
                        "required": True,
                        "content": {
                            "application/json": {
                                "schema": {
                                    "type": "object",
                                    "required": ["user_id", "name"],
                                    "properties": {
                                        "user_id": {"type": "integer", "example": 1},
                                        "name": {"type": "string", "example": "Aspirin"},
                                        "type": {"type": "string", "example": "Tablet"},
                                        "dosage": {"type": "string", "example": "100mg"}
                                    }
                                }
                            }
                        }
                    },
                    "responses": {
                        "201": {"description": "Medicine created successfully"},
                        "400": {"description": "Validation error"}
                    }
                }
            },
            "/api/tracking/medicines/{user_id}": {
                "get": {
                    "tags": ["Medicine Tracking"],
                    "summary": "Get all medicines for a user",
                    "parameters": [{
                        "name": "user_id",
                        "in": "path",
                        "required": True,
                        "schema": {"type": "integer"}
                    }],
                    "responses": {
                        "200": {"description": "List of user medicines"}
                    }
                }
            },
            "/api/tracking/plans": {
                "post": {
                    "tags": ["Medicine Plans"],
                    "summary": "Create a medicine plan (schedule)",
                    "requestBody": {
                        "required": True,
                        "content": {
                            "application/json": {
                                "schema": {
                                    "type": "object",
                                    "required": ["medicine_track_id", "user_id", "start_date", "frequency_type"],
                                    "properties": {
                                        "medicine_track_id": {"type": "integer"},
                                        "user_id": {"type": "integer"},
                                        "importance": {"type": "string"},
                                        "start_date": {"type": "string", "format": "date"},
                                        "end_date": {"type": "string", "format": "date"},
                                        "frequency_type": {"type": "string", "enum": ["daily", "weekly", "monthly", "interval", "custom"]}
                                    }
                                }
                            }
                        }
                    },
                    "responses": {
                        "201": {"description": "Plan created successfully"}
                    }
                }
            },
            "/api/tracking/plans/user/{user_id}": {
                "get": {
                    "tags": ["Medicine Plans"],
                    "summary": "Get all plans for a user",
                    "parameters": [{
                        "name": "user_id",
                        "in": "path",
                        "required": True,
                        "schema": {"type": "integer"}
                    }],
                    "responses": {
                        "200": {"description": "List of user plans"}
                    }
                }
            },
            "/api/tracking/occurrences/date/{date}": {
                "get": {
                    "tags": ["Occurrences"],
                    "summary": "Get all occurrences for a specific date",
                    "parameters": [
                        {
                            "name": "date",
                            "in": "path",
                            "required": True,
                            "schema": {"type": "string", "format": "date"},
                            "example": "2024-01-09"
                        },
                        {
                            "name": "user_id",
                            "in": "query",
                            "required": True,
                            "schema": {"type": "integer"}
                        }
                    ],
                    "responses": {
                        "200": {"description": "List of occurrences for the date"}
                    }
                }
            },
            "/api/tracking/occurrences/{occurrence_id}": {
                "put": {
                    "tags": ["Occurrences"],
                    "summary": "Update occurrence (mark as taken)",
                    "parameters": [{
                        "name": "occurrence_id",
                        "in": "path",
                        "required": True,
                        "schema": {"type": "integer"}
                    }],
                    "requestBody": {
                        "required": True,
                        "content": {
                            "application/json": {
                                "schema": {
                                    "type": "object",
                                    "properties": {
                                        "is_taken": {"type": "integer", "example": 1}
                                    }
                                }
                            }
                        }
                    },
                    "responses": {
                        "200": {"description": "Occurrence updated"}
                    }
                }
            },
            "/api/tracking/occurrences/batch": {
                "post": {
                    "tags": ["Occurrences"],
                    "summary": "Create multiple occurrences at once",
                    "requestBody": {
                        "required": True,
                        "content": {
                            "application/json": {
                                "schema": {
                                    "type": "object",
                                    "properties": {
                                        "occurrences": {
                                            "type": "array",
                                            "items": {
                                                "type": "object",
                                                "properties": {
                                                    "plan_id": {"type": "integer"},
                                                    "date": {"type": "string", "format": "date"},
                                                    "time": {"type": "string"},
                                                    "is_taken": {"type": "integer"}
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    },
                    "responses": {
                        "201": {"description": "Occurrences created"}
                    }
                }
            },
            "/api/statistics/overview/{user_id}": {
                "get": {
                    "tags": ["Statistics"],
                    "summary": "Get overall statistics for a user",
                    "parameters": [
                        {
                            "name": "user_id",
                            "in": "path",
                            "required": True,
                            "schema": {"type": "integer"}
                        },
                        {
                            "name": "period",
                            "in": "query",
                            "required": False,
                            "schema": {"type": "string", "enum": ["week", "month", "year", "all"]}
                        }
                    ],
                    "responses": {
                        "200": {"description": "Statistics overview"}
                    }
                }
            },
            "/api/statistics/daily/{user_id}": {
                "get": {
                    "tags": ["Statistics"],
                    "summary": "Get daily statistics",
                    "parameters": [{
                        "name": "user_id",
                        "in": "path",
                        "required": True,
                        "schema": {"type": "integer"}
                    }],
                    "responses": {
                        "200": {"description": "Daily statistics"}
                    }
                }
            },
            "/api/statistics/weekly/{user_id}": {
                "get": {
                    "tags": ["Statistics"],
                    "summary": "Get weekly statistics",
                    "parameters": [{
                        "name": "user_id",
                        "in": "path",
                        "required": True,
                        "schema": {"type": "integer"}
                    }],
                    "responses": {
                        "200": {"description": "Weekly statistics"}
                    }
                }
            },
            "/api/statistics/adherence-trend/{user_id}": {
                "get": {
                    "tags": ["Statistics"],
                    "summary": "Get 30-day adherence trend",
                    "parameters": [{
                        "name": "user_id",
                        "in": "path",
                        "required": True,
                        "schema": {"type": "integer"}
                    }],
                    "responses": {
                        "200": {"description": "Adherence trend data"}
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
