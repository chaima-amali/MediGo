"""
Medicine Search Service - Remote search with Supabase
Handles medicine search, notify-me tracking, and reservations
"""

from typing import List, Dict, Optional
from datetime import datetime
from app.supabase_client import get_supabase


class MedicineSearchService:
    """Service for remote medicine search and availability checking"""
    
    def __init__(self):
        self.supabase = get_supabase()
        if not self.supabase:
            raise RuntimeError("Supabase client not initialized")
    
    async def search_medicines(self, search_query: str) -> List[Dict]:
        """
        Search medicines by name with case-insensitive partial matching
        Returns medicine info with pharmacy availability, price, and stock
        
        Args:
            search_query: Medicine name to search for
            
        Returns:
            List of medicines with availability info from pharmacies
        """
        try:
            # Search medicines with case-insensitive partial matching using ilike
            medicine_response = self.supabase.table('medicine').select(
                'medicine_id, name, generic_name, dosage, form, manufacturer, description, requires_prescription'
            ).ilike('name', f'%{search_query}%').execute()
            
            if not medicine_response.data:
                return []
            
            results = []
            
            # For each medicine, fetch pharmacy availability
            for medicine in medicine_response.data:
                medicine_id = medicine['medicine_id']
                
                # Join pharmacy_medicine with pharmacy to get availability
                availability_response = self.supabase.table('pharmacy_medicine').select(
                    '''
                    id,
                    price,
                    stock,
                    pharmacy_id,
                    pharmacy:pharmacy_id (
                        pharmacy_id,
                        name,
                        address,
                        phone,
                        latitude,
                        longitude,
                        opening_hours,
                        rating
                    )
                    '''
                ).eq('medicine_id', medicine_id).gt('stock', 0).execute()
                
                # Build availability list
                availability = []
                for item in availability_response.data:
                    pharmacy_data = item.get('pharmacy', {})
                    availability.append({
                        'pharmacy_medicine_id': item['id'],
                        'pharmacy_id': item['pharmacy_id'],
                        'pharmacy_name': pharmacy_data.get('name'),
                        'address': pharmacy_data.get('address'),
                        'phone': pharmacy_data.get('phone'),
                        'latitude': pharmacy_data.get('latitude'),
                        'longitude': pharmacy_data.get('longitude'),
                        'opening_hours': pharmacy_data.get('opening_hours'),
                        'rating': pharmacy_data.get('rating'),
                        'price': item['price'],
                        'stock': item['stock']
                    })
                
                results.append({
                    'medicine_id': medicine['medicine_id'],
                    'name': medicine['name'],
                    'generic_name': medicine.get('generic_name'),
                    'dosage': medicine.get('dosage'),
                    'form': medicine.get('form'),
                    'manufacturer': medicine.get('manufacturer'),
                    'description': medicine.get('description'),
                    'requires_prescription': medicine.get('requires_prescription', 0),
                    'availability': availability
                })
            
            return results
            
        except Exception as e:
            raise Exception(f"Medicine search failed: {str(e)}")
    
    async def record_search_not_found(self, user_id: int, medicine_name: str) -> Dict:
        """
        Record when a medicine search returns no results (Notify Me action)
        Stores in medicine_search_history with action type
        
        Args:
            user_id: ID of the user who searched
            medicine_name: Name of the medicine that wasn't found
            
        Returns:
            Created search history record
        """
        try:
            # Insert into medicine_search_history
            response = self.supabase.table('medicine_search_history').insert({
                'user_id': user_id,
                'medicine_name': medicine_name,
                'searched_at': datetime.utcnow().isoformat(),
                'notify_restock': 1  # Flag for notification
            }).execute()
            
            if not response.data:
                raise Exception("Failed to record search history")
            
            return {
                'success': True,
                'message': f'You will be notified when "{medicine_name}" becomes available',
                'record': response.data[0]
            }
            
        except Exception as e:
            raise Exception(f"Failed to record search not found: {str(e)}")
    
    async def check_user_premium_status(self, user_id: int) -> bool:
        """
        Check if user has premium status
        
        Args:
            user_id: ID of the user to check
            
        Returns:
            True if user is premium, False otherwise
        """
        try:
            response = self.supabase.table('users').select('premium').eq('user_id', user_id).execute()
            
            if not response.data:
                raise Exception("User not found")
            
            premium_status = response.data[0].get('premium', '').lower()
            return premium_status in ['yes', 'true', '1', 'active']
            
        except Exception as e:
            raise Exception(f"Failed to check premium status: {str(e)}")
    
    async def create_reservation(
        self,
        user_id: int,
        medicine_id: int,
        pharmacy_id: int,
        medicine_name: str,
        quantity: int = 1
    ) -> Dict:
        """
        Create a medicine reservation (premium users only)
        Validates premium status and stock availability
        
        Args:
            user_id: ID of the user making reservation
            medicine_id: ID of the medicine to reserve
            pharmacy_id: ID of the pharmacy
            medicine_name: Name of the medicine
            quantity: Quantity to reserve (default: 1)
            
        Returns:
            Created reservation record
            
        Raises:
            Exception: If user is not premium or stock unavailable
        """
        try:
            # Check if user is premium
            is_premium = await self.check_user_premium_status(user_id)
            if not is_premium:
                raise Exception("Reservation feature is only available for premium users. Please upgrade to premium.")
            
            # Validate stock availability
            availability_response = self.supabase.table('pharmacy_medicine').select(
                'stock, price'
            ).eq('medicine_id', medicine_id).eq('pharmacy_id', pharmacy_id).execute()
            
            if not availability_response.data:
                raise Exception("Medicine not available at this pharmacy")
            
            stock = availability_response.data[0].get('stock', 0)
            if stock < quantity:
                raise Exception(f"Insufficient stock. Available: {stock}, Requested: {quantity}")
            
            # Record search history for this reservation
            search_history_response = self.supabase.table('medicine_search_history').insert({
                'user_id': user_id,
                'medicine_name': medicine_name,
                'searched_at': datetime.utcnow().isoformat(),
                'notify_restock': 0
            }).execute()
            
            search_history_id = search_history_response.data[0]['id'] if search_history_response.data else None
            
            # Create reservation
            reservation_response = self.supabase.table('reservation').insert({
                'medicine_find_id': search_history_id,
                'user_id': user_id,
                'pharmacy_id': pharmacy_id,
                'medicine_name': medicine_name,
                'quantity': quantity,
                'status': 'PENDING',
                'created_at': datetime.utcnow().isoformat()
            }).execute()
            
            if not reservation_response.data:
                raise Exception("Failed to create reservation")
            
            reservation = reservation_response.data[0]
            
            # Optionally update stock (commented out - depends on business logic)
            # self.supabase.table('pharmacy_medicine').update({
            #     'stock': stock - quantity
            # }).eq('medicine_id', medicine_id).eq('pharmacy_id', pharmacy_id).execute()
            
            return {
                'success': True,
                'message': 'Reservation created successfully',
                'reservation': reservation
            }
            
        except Exception as e:
            raise Exception(f"Reservation failed: {str(e)}")
    
    async def get_user_reservations(self, user_id: int) -> List[Dict]:
        """
        Get all reservations for a user
        
        Args:
            user_id: ID of the user
            
        Returns:
            List of user's reservations
        """
        try:
            response = self.supabase.table('reservation').select(
                '''
                reservation_id,
                medicine_name,
                quantity,
                status,
                created_at,
                pharmacy_id,
                pharmacy:pharmacy_id (
                    name,
                    address,
                    phone
                )
                '''
            ).eq('user_id', user_id).order('created_at', desc=True).execute()
            
            return response.data if response.data else []
            
        except Exception as e:
            raise Exception(f"Failed to fetch reservations: {str(e)}")
    
    async def get_search_history(self, user_id: int) -> List[Dict]:
        """
        Get search history for a user
        
        Args:
            user_id: ID of the user
            
        Returns:
            List of user's search history
        """
        try:
            response = self.supabase.table('medicine_search_history').select(
                'id, medicine_name, searched_at, notify_restock'
            ).eq('user_id', user_id).order('searched_at', desc=True).execute()
            
            return response.data if response.data else []
            
        except Exception as e:
            raise Exception(f"Failed to fetch search history: {str(e)}")
