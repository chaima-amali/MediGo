"""
Database Connection and Session Management
Handles SQLite database connections using SQLAlchemy
"""

import sqlite3
from flask import g
from contextlib import contextmanager
from app.core.config import settings

# Database connection management

def get_db_connection():
    """
    Get SQLite database connection
    Uses Flask's g object to store connection per request
    """
    if 'db' not in g:
        g.db = sqlite3.connect(
            settings.DATABASE_PATH,
            detect_types=sqlite3.PARSE_DECLTYPES
        )
        # Return rows as dictionaries
        g.db.row_factory = sqlite3.Row
    return g.db

def close_db_connection(e=None):
    """Close database connection at end of request"""
    db = g.pop('db', None)
    if db is not None:
        db.close()

def init_db(app):
    """Initialize database with Flask app"""
    # Register teardown function to close connections
    app.teardown_appcontext(close_db_connection)
    
    print(f"✅ Database initialized: {settings.DATABASE_PATH}")

@contextmanager
def get_db():
    """
    Context manager for database operations
    Usage:
        with get_db() as db:
            cursor = db.execute("SELECT * FROM users")
            results = cursor.fetchall()
    """
    db = get_db_connection()
    try:
        yield db
        db.commit()
    except Exception as e:
        db.rollback()
        raise e

def execute_query(query, params=None):
    """
    Execute a database query and return results
    
    Args:
        query: SQL query string
        params: Query parameters (optional)
    
    Returns:
        List of rows as dictionaries
    """
    db = get_db_connection()
    cursor = db.execute(query, params or ())
    columns = [description[0] for description in cursor.description] if cursor.description else []
    results = [dict(zip(columns, row)) for row in cursor.fetchall()]
    return results

def execute_insert(query, params=None):
    """
    Execute an INSERT query and return the last inserted row ID
    
    Args:
        query: SQL INSERT query
        params: Query parameters
    
    Returns:
        Last inserted row ID
    """
    db = get_db_connection()
    cursor = db.execute(query, params or ())
    db.commit()
    return cursor.lastrowid

def execute_update(query, params=None):
    """
    Execute an UPDATE or DELETE query
    
    Args:
        query: SQL UPDATE/DELETE query
        params: Query parameters
    
    Returns:
        Number of affected rows
    """
    db = get_db_connection()
    cursor = db.execute(query, params or ())
    db.commit()
    return cursor.rowcount
