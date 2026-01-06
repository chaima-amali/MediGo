"""
User API Schemas - Request/Response validation using Pydantic
"""

from pydantic import BaseModel, EmailStr, Field
from typing import Optional

class UserCreate(BaseModel):
    """Schema for creating a new user"""
    name: str = Field(..., min_length=1, max_length=100)
    email: EmailStr
    phone: Optional[str] = Field(None, max_length=20)
    password: Optional[str] = Field(None, min_length=6)
    gender: Optional[str] = Field(None, pattern='^(male|female|other)$')
    dob: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    location_name: Optional[str] = None
    premium: Optional[str] = Field('false', pattern='^(true|false)$')
    
    class Config:
        json_schema_extra = {
            "example": {
                "name": "John Doe",
                "email": "john@example.com",
                "phone": "1234567890",
                "password": "securepass123",
                "gender": "male",
                "latitude": 40.7128,
                "longitude": -74.0060,
                "location_name": "New York, NY"
            }
        }

class UserUpdate(BaseModel):
    """Schema for updating user information"""
    name: Optional[str] = Field(None, min_length=1, max_length=100)
    email: Optional[EmailStr] = None
    phone: Optional[str] = Field(None, max_length=20)
    gender: Optional[str] = None
    dob: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    location_name: Optional[str] = None
    premium: Optional[str] = None

class UserResponse(BaseModel):
    """Schema for user response"""
    user_id: int
    name: Optional[str]
    email: Optional[str]
    phone: Optional[str]
    gender: Optional[str]
    dob: Optional[str]
    latitude: Optional[float]
    longitude: Optional[float]
    location_name: Optional[str]
    premium: Optional[str]
    
    class Config:
        from_attributes = True
