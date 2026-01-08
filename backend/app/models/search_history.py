"""
Search History Models
Represents medicine_search_history and reservation tables
"""

from typing import Optional
from datetime import datetime


class SearchHistory:
    """
    Search History model for medicine_search_history table
    
    Database Schema:
        id BIGSERIAL PRIMARY KEY
        user_id BIGINT NOT NULL
        medicine_name TEXT NOT NULL
        searched_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        notify_restock INTEGER DEFAULT 0
    """
    
    def __init__(
        self,
        id: Optional[int] = None,
        user_id: Optional[int] = None,
        medicine_name: Optional[str] = None,
        searched_at: Optional[str] = None,
        notify_restock: int = 0
    ):
        self.id = id
        self.user_id = user_id
        self.medicine_name = medicine_name
        self.searched_at = searched_at or datetime.utcnow().isoformat()
        self.notify_restock = notify_restock
    
    @classmethod
    def from_db_row(cls, row):
        """Create SearchHistory instance from database row"""
        if row is None:
            return None
        return cls(
            id=row.get('id'),
            user_id=row.get('user_id'),
            medicine_name=row.get('medicine_name'),
            searched_at=row.get('searched_at'),
            notify_restock=row.get('notify_restock', 0)
        )
    
    def to_dict(self):
        """Convert to dictionary for JSON response"""
        return {
            'id': self.id,
            'user_id': self.user_id,
            'medicine_name': self.medicine_name,
            'searched_at': self.searched_at,
            'notify_restock': self.notify_restock
        }


class Reservation:
    """
    Reservation model for reservation table
    
    Database Schema:
        reservation_id BIGSERIAL PRIMARY KEY
        medicine_find_id BIGINT
        user_id BIGINT
        pharmacy_id BIGINT
        medicine_name TEXT
        day TEXT
        time TEXT
        quantity INTEGER
        status TEXT
        created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
    """
    
    def __init__(
        self,
        reservation_id: Optional[int] = None,
        medicine_find_id: Optional[int] = None,
        user_id: Optional[int] = None,
        pharmacy_id: Optional[int] = None,
        medicine_name: Optional[str] = None,
        day: Optional[str] = None,
        time: Optional[str] = None,
        quantity: int = 1,
        status: str = 'PENDING',
        created_at: Optional[str] = None
    ):
        self.reservation_id = reservation_id
        self.medicine_find_id = medicine_find_id
        self.user_id = user_id
        self.pharmacy_id = pharmacy_id
        self.medicine_name = medicine_name
        self.day = day
        self.time = time
        self.quantity = quantity
        self.status = status
        self.created_at = created_at or datetime.utcnow().isoformat()
    
    @classmethod
    def from_db_row(cls, row):
        """Create Reservation instance from database row"""
        if row is None:
            return None
        return cls(
            reservation_id=row.get('reservation_id'),
            medicine_find_id=row.get('medicine_find_id'),
            user_id=row.get('user_id'),
            pharmacy_id=row.get('pharmacy_id'),
            medicine_name=row.get('medicine_name'),
            day=row.get('day'),
            time=row.get('time'),
            quantity=row.get('quantity', 1),
            status=row.get('status', 'PENDING'),
            created_at=row.get('created_at')
        )
    
    def to_dict(self):
        """Convert to dictionary for JSON response"""
        return {
            'reservation_id': self.reservation_id,
            'medicine_find_id': self.medicine_find_id,
            'user_id': self.user_id,
            'pharmacy_id': self.pharmacy_id,
            'medicine_name': self.medicine_name,
            'day': self.day,
            'time': self.time,
            'quantity': self.quantity,
            'status': self.status,
            'created_at': self.created_at
        }


class Pharmacy:
    """
    Pharmacy model for pharmacy table
    
    Database Schema:
        pharmacy_id BIGSERIAL PRIMARY KEY
        name TEXT NOT NULL
        latitude REAL
        longitude REAL
        phone TEXT
        opening_hours TEXT
        rating REAL
        image_url TEXT
        address TEXT
    """
    
    def __init__(
        self,
        pharmacy_id: Optional[int] = None,
        name: Optional[str] = None,
        latitude: Optional[float] = None,
        longitude: Optional[float] = None,
        phone: Optional[str] = None,
        opening_hours: Optional[str] = None,
        rating: Optional[float] = None,
        image_url: Optional[str] = None,
        address: Optional[str] = None
    ):
        self.pharmacy_id = pharmacy_id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.phone = phone
        self.opening_hours = opening_hours
        self.rating = rating
        self.image_url = image_url
        self.address = address
    
    @classmethod
    def from_db_row(cls, row):
        """Create Pharmacy instance from database row"""
        if row is None:
            return None
        return cls(
            pharmacy_id=row.get('pharmacy_id'),
            name=row.get('name'),
            latitude=row.get('latitude'),
            longitude=row.get('longitude'),
            phone=row.get('phone'),
            opening_hours=row.get('opening_hours'),
            rating=row.get('rating'),
            image_url=row.get('image_url'),
            address=row.get('address')
        )
    
    def to_dict(self):
        """Convert to dictionary for JSON response"""
        return {
            'pharmacy_id': self.pharmacy_id,
            'name': self.name,
            'latitude': self.latitude,
            'longitude': self.longitude,
            'phone': self.phone,
            'opening_hours': self.opening_hours,
            'rating': self.rating,
            'image_url': self.image_url,
            'address': self.address
        }
