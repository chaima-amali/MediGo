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
    
    from app.routes import users, medicines, auth, pharmacies, reservations, medicine_search_history
    
    # Root endpoint
    @app.route('/')
    def home():
        return jsonify({
            'message': 'Welcome to MediGo Backend API',
            'version': '1.0.0',
            'docs': 'http://localhost:5000/docs'
        })
    
    # API endpoints
    app.register_blueprint(auth.bp, url_prefix='/api')
    app.register_blueprint(users.bp, url_prefix='/api')
    app.register_blueprint(medicines.bp, url_prefix='/api')
    app.register_blueprint(pharmacies.pharmacies_bp, url_prefix='/api/pharmacies')
    app.register_blueprint(reservations.bp, url_prefix='/api')
    app.register_blueprint(medicine_search_history.bp, url_prefix='/api')

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
                },
                "put": {
                    "tags": ["Users"],
                    "summary": "Update user profile",
                    "parameters": [{
                        "name": "user_id",
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
                                        "name": {"type": "string", "example": "John Doe"},
                                        "email": {"type": "string", "example": "john@example.com"},
                                        "phone": {"type": "string", "example": "1234567890"},
                                        "gender": {"type": "string", "example": "male"},
                                        "dob": {"type": "string", "example": "1990-01-01"},
                                        "location_name": {"type": "string", "example": "Mahelma"}
                                    }
                                }
                            }
                        }
                    },
                    "responses": {
                        "200": {"description": "User updated successfully"},
                        "404": {"description": "User not found"}
                    }
                },
                "delete": {
                    "tags": ["Users"],
                    "summary": "Delete user",
                    "parameters": [{
                        "name": "user_id",
                        "in": "path",
                        "required": True,
                        "schema": {"type": "integer"}
                    }],
                    "responses": {
                        "200": {"description": "User deleted successfully"},
                        "404": {"description": "User not found"}
                    }
                }
            },
            "/api/users/{user_id}/premium": {
                "put": {
                    "tags": ["Users"],
                    "summary": "Update user premium status",
                    "parameters": [{
                        "name": "user_id",
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
                                    "required": ["premium"],
                                    "properties": {
                                        "premium": {"type": "boolean", "example": True}
                                    }
                                }
                            }
                        }
                    },
                    "responses": {
                        "200": {"description": "Premium status updated successfully"},
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
                },
                "post": {
                    "tags": ["Medicines"],
                    "summary": "Add new medicine",
                    "requestBody": {
                        "required": True,
                        "content": {
                            "application/json": {
                                "schema": {
                                    "type": "object",
                                    "required": ["name", "category", "dosage_form"],
                                    "properties": {
                                        "name": {"type": "string", "example": "Paracetamol"},
                                        "category": {"type": "string", "example": "Pain Relief"},
                                        "dosage_form": {"type": "string", "example": "Tablet"},
                                        "active_ingredient": {"type": "string", "example": "Paracetamol 500mg"}
                                    }
                                }
                            }
                        }
                    },
                    "responses": {
                        "201": {"description": "Medicine created successfully"},
                        "400": {"description": "Invalid data"}
                    }
                }
            },
            "/api/medicines/search": {
                "get": {
                    "tags": ["Medicines"],
                    "summary": "Search medicines by name",
                    "parameters": [{
                        "name": "query",
                        "in": "query",
                        "required": True,
                        "schema": {"type": "string"},
                        "description": "Search query for medicine name"
                    }],
                    "responses": {
                        "200": {"description": "Search results"},
                        "400": {"description": "Query parameter required"}
                    }
                }
            },
            "/api/medicines/{medicine_id}": {
                "get": {
                    "tags": ["Medicines"],
                    "summary": "Get medicine by ID",
                    "parameters": [{
                        "name": "medicine_id",
                        "in": "path",
                        "required": True,
                        "schema": {"type": "integer"}
                    }],
                    "responses": {
                        "200": {"description": "Medicine details"},
                        "404": {"description": "Medicine not found"}
                    }
                },
                "put": {
                    "tags": ["Medicines"],
                    "summary": "Update medicine",
                    "parameters": [{
                        "name": "medicine_id",
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
                                        "name": {"type": "string"},
                                        "category": {"type": "string"},
                                        "dosage_form": {"type": "string"},
                                        "active_ingredient": {"type": "string"}
                                    }
                                }
                            }
                        }
                    },
                    "responses": {
                        "200": {"description": "Medicine updated successfully"},
                        "404": {"description": "Medicine not found"}
                    }
                },
                "delete": {
                    "tags": ["Medicines"],
                    "summary": "Delete medicine",
                    "parameters": [{
                        "name": "medicine_id",
                        "in": "path",
                        "required": True,
                        "schema": {"type": "integer"}
                    }],
                    "responses": {
                        "200": {"description": "Medicine deleted successfully"},
                        "404": {"description": "Medicine not found"}
                    }
                }
            },
            "/api/reservations": {
                "post": {
                    "tags": ["Reservations"],
                    "summary": "Create a new reservation",
                    "requestBody": {
                        "required": True,
                        "content": {
                            "application/json": {
                                "schema": {
                                    "type": "object",
                                    "required": ["user_id", "pharmacy_id", "medicine_id", "quantity"],
                                    "properties": {
                                        "user_id": {"type": "integer", "example": 1},
                                        "pharmacy_id": {"type": "integer", "example": 1},
                                        "medicine_id": {"type": "integer", "example": 1},
                                        "quantity": {"type": "integer", "example": 2}
                                    }
                                }
                            }
                        }
                    },
                    "responses": {
                        "201": {"description": "Reservation created successfully"},
                        "400": {"description": "Invalid data"}
                    }
                }
            },
            "/api/reservations/{user_id}": {
                "get": {
                    "tags": ["Reservations"],
                    "summary": "Get user reservations",
                    "parameters": [{
                        "name": "user_id",
                        "in": "path",
                        "required": True,
                        "schema": {"type": "integer"}
                    }],
                    "responses": {
                        "200": {"description": "List of reservations"},
                        "404": {"description": "User not found"}
                    }
                }
            },
            "/api/reservations/{reservation_id}": {
                "patch": {
                    "tags": ["Reservations"],
                    "summary": "Update reservation status",
                    "parameters": [{
                        "name": "reservation_id",
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
                                    "required": ["status"],
                                    "properties": {
                                        "status": {"type": "string", "example": "confirmed", "enum": ["pending", "confirmed", "cancelled"]}
                                    }
                                }
                            }
                        }
                    },
                    "responses": {
                        "200": {"description": "Reservation status updated"},
                        "404": {"description": "Reservation not found"}
                    }
                }
            },
            "/api/medicine-search-history": {
                "post": {
                    "tags": ["Medicine Search History"],
                    "summary": "Save medicine search history",
                    "requestBody": {
                        "required": True,
                        "content": {
                            "application/json": {
                                "schema": {
                                    "type": "object",
                                    "required": ["user_id", "medicine_id"],
                                    "properties": {
                                        "user_id": {"type": "integer", "example": 1},
                                        "medicine_id": {"type": "integer", "example": 1}
                                    }
                                }
                            }
                        }
                    },
                    "responses": {
                        "201": {"description": "Search history saved"},
                        "400": {"description": "Invalid data"}
                    }
                }
            },
            "/api/medicine-search-history/{user_id}": {
                "get": {
                    "tags": ["Medicine Search History"],
                    "summary": "Get user search history",
                    "parameters": [{
                        "name": "user_id",
                        "in": "path",
                        "required": True,
                        "schema": {"type": "integer"}
                    }],
                    "responses": {
                        "200": {"description": "List of search history"},
                        "404": {"description": "User not found"}
                    }
                }
            },
            "/api/pharmacies/all": {
                "get": {
                    "tags": ["Pharmacies"],
                    "summary": "Get all pharmacies",
                    "parameters": [
                        {
                            "name": "user_lat",
                            "in": "query",
                            "required": False,
                            "schema": {"type": "number"},
                            "description": "User latitude for distance calculation"
                        },
                        {
                            "name": "user_lon",
                            "in": "query",
                            "required": False,
                            "schema": {"type": "number"},
                            "description": "User longitude for distance calculation"
                        }
                    ],
                    "responses": {
                        "200": {"description": "List of all pharmacies"}
                    }
                }
            },
            "/api/pharmacies/search": {
                "get": {
                    "tags": ["Pharmacies"],
                    "summary": "Search pharmacies by name",
                    "parameters": [
                        {
                            "name": "q",
                            "in": "query",
                            "required": True,
                            "schema": {"type": "string"},
                            "description": "Search query"
                        }
                    ],
                    "responses": {
                        "200": {"description": "Search results"},
                        "400": {"description": "Query parameter required"}
                    }
                }
            },
            "/api/pharmacies/{pharmacy_id}": {
                "get": {
                    "tags": ["Pharmacies"],
                    "summary": "Get pharmacy by ID",
                    "parameters": [
                        {
                            "name": "pharmacy_id",
                            "in": "path",
                            "required": True,
                            "schema": {"type": "integer"}
                        }
                    ],
                    "responses": {
                        "200": {"description": "Pharmacy details"},
                        "404": {"description": "Pharmacy not found"}
                    }
                }
            },
            "/api/pharmacies/nearby": {
                "get": {
                    "tags": ["Pharmacies"],
                    "summary": "Get nearby pharmacies",
                    "parameters": [
                        {
                            "name": "lat",
                            "in": "query",
                            "required": True,
                            "schema": {"type": "number"},
                            "description": "User latitude"
                        },
                        {
                            "name": "lon",
                            "in": "query",
                            "required": True,
                            "schema": {"type": "number"},
                            "description": "User longitude"
                        },
                        {
                            "name": "radius",
                            "in": "query",
                            "required": False,
                            "schema": {"type": "number", "default": 10},
                            "description": "Search radius in km"
                        },
                        {
                            "name": "limit",
                            "in": "query",
                            "required": False,
                            "schema": {"type": "integer", "default": 10},
                            "description": "Max results"
                        }
                    ],
                    "responses": {
                        "200": {"description": "Nearby pharmacies"},
                        "400": {"description": "Invalid parameters"}
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
