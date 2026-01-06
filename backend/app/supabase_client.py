"""
Supabase Client - Cloud database integration

Example usage:
    from app.supabase_client import supabase
    
    # Query data
    response = supabase.table('user').select('*').execute()
    
    # Insert data
    data = {'name': 'John', 'email': 'john@example.com'}
    response = supabase.table('user').insert(data).execute()
    
    # Update data
    response = supabase.table('user').update({'name': 'Jane'}).eq('id', 1).execute()
    
    # Delete data
    response = supabase.table('user').delete().eq('id', 1).execute()
"""

from supabase import create_client, Client
from app.core.config import settings

# Initialize Supabase client
supabase: Client = None

def init_supabase():
    """Initialize Supabase client"""
    global supabase
    
    if not settings.SUPABASE_URL or not settings.SUPABASE_KEY:
        print("⚠️  Supabase credentials not configured")
        return None
    
    try:
        supabase = create_client(settings.SUPABASE_URL, settings.SUPABASE_KEY)
        print("✅ Supabase client initialized")
        return supabase
    except Exception as e:
        print(f"❌ Failed to initialize Supabase: {e}")
        return None

# Call this in app/__init__.py when ready to use Supabase
# supabase = init_supabase()