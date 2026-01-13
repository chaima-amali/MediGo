"""
Core package initialization
Exports configuration and database utilities
"""

from app.core.config import settings
from app.core.database import get_db, execute_query, execute_insert, execute_update

__all__ = ['settings', 'get_db', 'execute_query', 'execute_insert', 'execute_update']
