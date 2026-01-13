"""
Application Configuration Settings
Loads environment variables and defines app-wide settings
"""

import os
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

class Settings:
    """Application settings and configuration"""
    
    # Application
    APP_NAME = "MediGo Backend API"
    VERSION = "1.0.0"
    ENVIRONMENT = os.getenv('FLASK_ENV', 'development')
    DEBUG = ENVIRONMENT == 'development'
    PORT = int(os.getenv('PORT', 5000))
    
    # Database - Using existing SQLite database
    DATABASE_PATH = os.getenv('DATABASE_PATH', 'medigo.db')
    DATABASE_URI = f'sqlite:///{DATABASE_PATH}'
    
    # Security
    SECRET_KEY = os.getenv('SECRET_KEY', 'dev-secret-key-change-in-production')
    
    # CORS
    CORS_ORIGINS = os.getenv('CORS_ORIGINS', '*')
    
    # Supabase (for future integration)
    SUPABASE_URL = os.getenv('SUPABASE_URL', '')
    SUPABASE_KEY = os.getenv('SUPABASE_KEY', '')
    
    # Pagination
    DEFAULT_PAGE_SIZE = 20
    MAX_PAGE_SIZE = 100

# Create settings instance
settings = Settings()
