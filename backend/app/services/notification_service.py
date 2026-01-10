"""
Firebase Cloud Messaging (FCM) Service for Medicine Reminders
Handles sending push notifications to users for medication reminders
"""

import firebase_admin
from firebase_admin import credentials, messaging
import os
from datetime import datetime, timedelta
from typing import Optional, List, Dict
import json


class NotificationService:
    _initialized = False
    
    @classmethod
    def initialize(cls):
        """Initialize Firebase Admin SDK with service account"""
        if cls._initialized:
            return
        
        try:
            # Path to your Firebase service account JSON file
            cred_path = os.path.join(
                os.path.dirname(os.path.dirname(os.path.dirname(__file__))),
                'firebase-service-account.json'
            )
            
            if os.path.exists(cred_path):
                cred = credentials.Certificate(cred_path)
                firebase_admin.initialize_app(cred)
                cls._initialized = True
                print('✅ Firebase Admin SDK initialized successfully')
            else:
                print(f'⚠️  Firebase service account file not found at: {cred_path}')
                print('   Please download it from Firebase Console > Project Settings > Service Accounts')
        except Exception as e:
            print(f'❌ Failed to initialize Firebase Admin SDK: {e}')
    
    @staticmethod
    def send_medicine_reminder(
        fcm_token: str,
        medicine_name: str,
        dosage: str,
        time: str,
        occurrence_id: int,
        plan_id: int,
        notification_timing: str = 'at_time',
    ) -> bool:
        """
        Send a medicine reminder notification to a user
        
        Args:
            fcm_token: User's FCM device token
            medicine_name: Name of the medicine
            dosage: Dosage information
            time: Scheduled time
            occurrence_id: ID of the occurrence
            plan_id: ID of the medicine plan
            notification_timing: Type of notification ('at_time' or 'one_hour_before')
            
        Returns:
            bool: True if notification sent successfully
        """
        try:
            if not NotificationService._initialized:
                NotificationService.initialize()
            
            if not NotificationService._initialized:
                return False
            
            # Customize message based on timing
            if notification_timing == 'one_hour_before':
                title = '⏰ Upcoming Medicine Reminder'
                body = f"{medicine_name} ({dosage}) is due in 1 hour at {time}"
            else:
                title = '💊 Medicine Reminder'
                body = f"Time to take {medicine_name} ({dosage}) at {time}"
            
            # Create notification message
            message = messaging.Message(
                notification=messaging.Notification(
                    title=title,
                    body=body,
                ),
                data={
                    'type': 'medicine_reminder',
                    'medicine_name': medicine_name,
                    'dosage': dosage,
                    'time': time,
                    'occurrence_id': str(occurrence_id),
                    'plan_id': str(plan_id),
                    'notification_timing': notification_timing,
                    'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                },
                android=messaging.AndroidConfig(
                    priority='high',
                    notification=messaging.AndroidNotification(
                        icon='notification_icon',
                        color='#4CAF50',
                        sound='default',
                        channel_id='medicine_reminders',
                    ),
                ),
                apns=messaging.APNSConfig(
                    payload=messaging.APNSPayload(
                        aps=messaging.Aps(
                            sound='default',
                            badge=1,
                        ),
                    ),
                ),
                token=fcm_token,
            )
            
            # Send the message
            response = messaging.send(message)
            print(f'✅ Notification sent successfully: {response}')
            return True
            
        except Exception as e:
            error_msg = str(e)
            print(f'❌ Failed to send notification: {error_msg}')
            
            # If token is invalid, mark it for cleanup
            if 'not found' in error_msg.lower() or 'unregistered' in error_msg.lower():
                print(f'⚠️  Invalid FCM token detected: {fcm_token[:30]}...')
                # Return False so caller knows to clean up
            
            return False
    
    @staticmethod
    def send_bulk_reminders(reminders: List[Dict]) -> Dict[str, int]:
        """
        Send multiple medicine reminders in batch
        
        Args:
            reminders: List of reminder dicts with keys: fcm_token, medicine_name, dosage, time, occurrence_id, plan_id
            
        Returns:
            Dict with success and failure counts
        """
        try:
            if not NotificationService._initialized:
                NotificationService.initialize()
            
            if not NotificationService._initialized:
                return {'success': 0, 'failed': len(reminders)}
            
            messages = []
            for reminder in reminders:
                message = messaging.Message(
                    notification=messaging.Notification(
                        title='💊 Medicine Reminder',
                        body=f"Time to take {reminder['medicine_name']} ({reminder['dosage']}) at {reminder['time']}",
                    ),
                    data={
                        'type': 'medicine_reminder',
                        'medicine_name': reminder['medicine_name'],
                        'dosage': reminder['dosage'],
                        'time': reminder['time'],
                        'occurrence_id': str(reminder['occurrence_id']),
                        'plan_id': str(reminder['plan_id']),
                        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                    },
                    android=messaging.AndroidConfig(
                        priority='high',
                        notification=messaging.AndroidNotification(
                            icon='notification_icon',
                            color='#4CAF50',
                            sound='default',
                            channel_id='medicine_reminders',
                        ),
                    ),
                    token=reminder['fcm_token'],
                )
                messages.append(message)
            
            # Send all messages in batch
            response = messaging.send_all(messages)
            
            print(f'✅ Batch notification sent: {response.success_count} success, {response.failure_count} failed')
            
            return {
                'success': response.success_count,
                'failed': response.failure_count,
            }
            
        except Exception as e:
            print(f'❌ Failed to send batch notifications: {e}')
            return {'success': 0, 'failed': len(reminders)}
    
    @staticmethod
    def send_custom_notification(
        fcm_token: str,
        title: str,
        body: str,
        data: Optional[Dict] = None,
    ) -> bool:
        """Send a custom notification"""
        try:
            if not NotificationService._initialized:
                NotificationService.initialize()
            
            if not NotificationService._initialized:
                return False
            
            message = messaging.Message(
                notification=messaging.Notification(
                    title=title,
                    body=body,
                ),
                data=data or {},
                android=messaging.AndroidConfig(
                    priority='high',
                    notification=messaging.AndroidNotification(
                        sound='default',
                    ),
                ),
                token=fcm_token,
            )
            
            response = messaging.send(message)
            print(f'✅ Custom notification sent: {response}')
            return True
            
        except Exception as e:
            print(f'❌ Failed to send custom notification: {e}')
            return False
