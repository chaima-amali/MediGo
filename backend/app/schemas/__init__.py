"""
Schemas package - Export all API schemas
Add new schemas here as you expand the API
"""

from app.schemas.user import UserCreate, UserUpdate, UserResponse
from app.schemas.medicine import MedicineTrackingCreate, MedicineTrackingUpdate, MedicineTrackingResponse

# TODO: Add more schemas as needed
# from app.schemas.pharmacy import PharmacyCreate, PharmacyResponse
# from app.schemas.reservation import ReservationCreate, ReservationResponse

__all__ = [
    'UserCreate', 'UserUpdate', 'UserResponse',
    'MedicineTrackingCreate', 'MedicineTrackingUpdate', 'MedicineTrackingResponse'
]
