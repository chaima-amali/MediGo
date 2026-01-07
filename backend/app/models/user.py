"""
User Model - Represents the 'user' table in the database
Matches your existing database schema exactly
"""

from typing import Optional
from datetime import datetime

class User:
    """
    User model matching existing database table
    
    Database Schema:
        user_id INTEGER PRIMARY KEY AUTOINCREMENT
        name TEXT
        email TEXT
        phone TEXT
        password TEXT
        gender TEXT
        dob TEXT
        latitude REAL
        longitude REAL
        location_name TEXT
        premium TEXT
    """
    
    def __init__(
        self,
        user_id: Optional[int] = None,
        name: Optional[str] = None,
        email: Optional[str] = None,
        phone: Optional[str] = None,
        password: Optional[str] = None,
        gender: Optional[str] = None,
        dob: Optional[str] = None,
        latitude: Optional[float] = None,
        longitude: Optional[float] = None,
        location_name: Optional[str] = None,
        premium: Optional[str] = None
    ):
        self.user_id = user_id
        self.name = name
        self.email = email
        self.phone = phone
        self.password = password
        self.gender = gender
        self.dob = dob
        self.latitude = latitude
        self.longitude = longitude
        self.location_name = location_name
        self.premium = premium
    
    @classmethod
    def from_db_row(cls, row):
        """Create User instance from database row"""
        if row is None:
            return None
        return cls(
            user_id=row['user_id'],
            name=row.get('name'),
            email=row.get('email'),
            phone=row.get('phone'),
            password=row.get('password'),
            gender=row.get('gender'),
            dob=row.get('dob'),
            latitude=row.get('latitude'),
            longitude=row.get('longitude'),
            location_name=row.get('location_name'),
            premium=row.get('premium')
        )
    
    def to_dict(self, include_password=False):
        """Convert to dictionary for JSON response"""
        data = {
            'user_id': self.user_id,
            'name': self.name,
            'email': self.email,
            'phone': self.phone,
            'gender': self.gender,
            'dob': self.dob,
            'latitude': self.latitude,
            'longitude': self.longitude,
            'location_name': self.location_name,
            'premium': self.premium
        }
        
        if include_password:
            data['password'] = self.password
        
        return data
