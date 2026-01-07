"""
Routes package - Export all API route blueprints
Add new route modules here as you expand the API
"""

from . import auth, users, medicines

# TODO: Import and add new route blueprints
# from app.routes import pharmacies
# from app.routes import reservations
# from app.routes import notifications

__all__ = ['auth', 'users', 'medicines']
