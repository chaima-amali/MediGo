"""
Medicine API Schemas - Request/Response validation
"""

from pydantic import BaseModel, Field
from typing import Optional

class MedicineTrackingCreate(BaseModel):
    """Schema for creating medicine tracking entry"""
    user_id: int
    name: str = Field(..., min_length=1)
    type: Optional[str] = None
    dosage: Optional[str] = None
    
    class Config:
        json_schema_extra = {
            "example": {
                "user_id": 1,
                "name": "Paracetamol",
                "type": "Tablet",
                "dosage": "500mg"
            }
        }

class MedicineTrackingUpdate(BaseModel):
    """Schema for updating medicine tracking"""
    name: Optional[str] = None
    type: Optional[str] = None
    dosage: Optional[str] = None

class MedicineTrackingResponse(BaseModel):
    """Schema for medicine tracking response"""
    medicine_track_id: int
    user_id: Optional[int]
    name: Optional[str]
    type: Optional[str]
    dosage: Optional[str]
    
    class Config:
        from_attributes = True
