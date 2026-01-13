"""
MediGo Backend - Main Application Entry Point
Run this file to start the Flask server
"""

from app import create_app
from app.core.config import settings

# Create Flask app instance
app = create_app()

if __name__ == '__main__':
    print(f"🚀 Starting {settings.APP_NAME}")
    print(f"📍 Environment: {settings.ENVIRONMENT}")
    print(f"🗄️  Database: {settings.DATABASE_PATH}")
    print(f"🌐 Server running on http://localhost:{settings.PORT}")
    
    app.run(
        host='0.0.0.0',
        port=settings.PORT,
        debug=settings.DEBUG
    )
