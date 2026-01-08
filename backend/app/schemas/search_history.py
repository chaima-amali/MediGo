"""
Search History and Reservation Schemas
Pydantic schemas for request/response validation
"""

from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime


class MedicineSearchRequest(BaseModel):
    """Request schema for medicine search"""
    search_query: str = Field(..., min_length=1, description="Medicine name to search for")


class PharmacyAvailability(BaseModel):
    """Schema for pharmacy availability in search results"""
    pharmacy_medicine_id: int
    pharmacy_id: int
    pharmacy_name: Optional[str] = None
    address: Optional[str] = None
    phone: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    opening_hours: Optional[str] = None
    rating: Optional[float] = None
    price: float
    stock: int


class MedicineSearchResult(BaseModel):
    """Schema for medicine search results with availability"""
    medicine_id: int
    name: str
    generic_name: Optional[str] = None
    dosage: Optional[str] = None
    form: Optional[str] = None
    manufacturer: Optional[str] = None
    description: Optional[str] = None
    requires_prescription: int = 0
    availability: List[PharmacyAvailability] = []


class NotifyMeRequest(BaseModel):
    """Request schema for notify-me action when medicine not found"""
    user_id: int = Field(..., gt=0, description="User ID")
    medicine_name: str = Field(..., min_length=1, description="Medicine name not found")


class NotifyMeResponse(BaseModel):
    """Response schema for notify-me action"""
    success: bool
    message: str
    record_id: Optional[int] = None


class ReservationCreateRequest(BaseModel):
    """Request schema for creating a reservation"""
    user_id: int = Field(..., gt=0, description="User ID")
    medicine_id: int = Field(..., gt=0, description="Medicine ID")
    pharmacy_id: int = Field(..., gt=0, description="Pharmacy ID")
    medicine_name: str = Field(..., min_length=1, description="Medicine name")
    quantity: int = Field(default=1, gt=0, description="Quantity to reserve")


class ReservationResponse(BaseModel):
    """Response schema for reservation"""
    success: bool
    message: str
    reservation_id: Optional[int] = None
    status: Optional[str] = None
    created_at: Optional[str] = None


class SearchHistoryResponse(BaseModel):
    """Response schema for search history"""
    id: int
    user_id: int
    medicine_name: str
    searched_at: str
    notify_restock: int


class UserReservationResponse(BaseModel):
    """Response schema for user's reservations with pharmacy details"""
    reservation_id: int
    medicine_name: str
    quantity: int
    status: str
    created_at: str
    pharmacy_name: Optional[str] = None
    pharmacy_address: Optional[str] = None
    pharmacy_phone: Optional[str] = None
