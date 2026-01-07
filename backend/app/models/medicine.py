"""
Medicine Tracking Model - Represents the 'medicine_tracking' table
Matches your existing database schema
"""

from typing import Optional

class MedicineTracking:
    """
    Medicine Tracking model matching existing database table
    
    Database Schema:
        medicine_track_id INTEGER PRIMARY KEY AUTOINCREMENT
        user_id INTEGER
        name TEXT
        type TEXT
        dosage TEXT
    """
    
    def __init__(
        self,
        medicine_track_id: Optional[int] = None,
        user_id: Optional[int] = None,
        name: Optional[str] = None,
        type: Optional[str] = None,
        dosage: Optional[str] = None
    ):
        self.medicine_track_id = medicine_track_id
        self.user_id = user_id
        self.name = name
        self.type = type
        self.dosage = dosage
    
    @classmethod
    def from_db_row(cls, row):
        """Create MedicineTracking instance from database row"""
        if row is None:
            return None
        return cls(
            medicine_track_id=row['medicine_track_id'],
            user_id=row.get('user_id'),
            name=row.get('name'),
            type=row.get('type'),
            dosage=row.get('dosage')
        )
    
    def to_dict(self):
        """Convert to dictionary for JSON response"""
        return {
            'medicine_track_id': self.medicine_track_id,
            'user_id': self.user_id,
            'name': self.name,
            'type': self.type,
            'dosage': self.dosage
        }
