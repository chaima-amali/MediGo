"""
Check notifications in database
"""
from app.supabase_client import supabase

result = supabase.table('notification').select('*').eq('type', 'reservation_reminder_1hour').execute()

print(f"\n✅ Found {len(result.data)} notifications with type 'reservation_reminder_1hour':\n")
for n in result.data:
    print(f"  📬 Notification ID: {n['notification_id']}")
    print(f"     User ID: {n['user_id']}")
    print(f"     Reservation ID: {n['reservation_id']}")
    print(f"     Title: {n['title']}")
    print(f"     Message: {n['message']}")
    print(f"     Created: {n.get('created_at', n.get('datetime'))}")
    print(f"     Read: {'Yes' if n['is_read'] else 'No'}")
    print()
