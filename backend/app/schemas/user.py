"""
User API Schemas - Request/Response validation using Pydantic
"""

from pydantic import BaseModel, EmailStr, Field, field_validator
from typing import Optional, Union

class UserCreate(BaseModel):
    """Schema for creating a new user"""
    name: str = Field(..., min_length=2, max_length=100)
    email: EmailStr
    phone: Optional[str] = Field(None, pattern=r'^0[567]\d{8}$', max_length=20)
    password: Optional[str] = Field(None, min_length=6, max_length=128)
    gender: Optional[str] = Field(None, pattern='^(male|female|Male|Female)$')
    dob: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    location_name: Optional[str] = None
    premium: Optional[Union[str, int, bool]] = 'false'
    fcm_token: Optional[str] = None
    notifications_enabled: Optional[bool] = True
    
    @field_validator('premium')
    @classmethod
    def normalize_premium(cls, v):
        """Convert premium to string 'true' or 'false'"""
        if v is None:
            return 'false'
        if isinstance(v, bool):
            return 'true' if v else 'false'
        if isinstance(v, int):
            return 'true' if v == 1 else 'false'
        if isinstance(v, str):
            return v.lower()
        return 'false'
    
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
                "location_name": "New York, NY",
                "fcm_token": "fcm_token_here",
                "notifications_enabled": True
            }
        }

class UserUpdate(BaseModel):
    """Schema for updating user information"""
    name: Optional[str] = Field(None, min_length=2, max_length=100)
    email: Optional[EmailStr] = None
    phone: Optional[str] = Field(None, pattern=r'^0[567]\d{8}$', max_length=20)
    gender: Optional[str] = None
    dob: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    location_name: Optional[str] = None
    premium: Optional[Union[str, int, bool]] = None
    fcm_token: Optional[str] = None
    notifications_enabled: Optional[bool] = None
    
    @field_validator('premium')
    @classmethod
    def normalize_premium(cls, v):
        """Convert premium to string 'true' or 'false'"""
        if v is None:
            return None
        if isinstance(v, bool):
            return 'true' if v else 'false'
        if isinstance(v, int):
            return 'true' if v == 1 else 'false'
        if isinstance(v, str):
            return v.lower()
        return None

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
    fcm_token: Optional[str]
    notifications_enabled: Optional[bool]
    
    class Config:
        from_attributes = True
