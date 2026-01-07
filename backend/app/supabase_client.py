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

try:
    from supabase import create_client, Client
    SUPABASE_AVAILABLE = True
except ImportError:
    SUPABASE_AVAILABLE = False
    Client = None

from app.core.config import settings

# Initialize Supabase client
supabase: Client = None

def init_supabase():
    """Initialize Supabase client"""
    global supabase
    
    if not SUPABASE_AVAILABLE:
        print("⚠️  Supabase library not installed - using local database only")
        return None
    
    if not settings.SUPABASE_URL or not settings.SUPABASE_KEY:
        print("⚠️  Supabase credentials not configured - using local database only")
        return None
    
    try:
        # Create Supabase client with only required parameters
        supabase = create_client(
            supabase_url=settings.SUPABASE_URL,
            supabase_key=settings.SUPABASE_KEY
        )
        print("✅ Supabase client initialized successfully")
        print(f"📡 Connected to: {settings.SUPABASE_URL}")
        return supabase
    except TypeError as e:
        # Handle API compatibility issues - try legacy initialization
        print(f"⚠️  Trying legacy Supabase initialization...")
        try:
            supabase = create_client(settings.SUPABASE_URL, settings.SUPABASE_KEY)
            print("✅ Supabase client initialized successfully")
            print(f"📡 Connected to: {settings.SUPABASE_URL}")
            return supabase
        except Exception as fallback_error:
            print(f"❌ Failed to initialize Supabase: {fallback_error}")
            print("📍 Falling back to local database only")
            return None
    except Exception as e:
        print(f"❌ Failed to initialize Supabase: {e}")
        print("📍 Falling back to local database only")
        return None

def get_supabase():
    """Get Supabase client instance"""
    return supabase

# Auto-initialize on import
supabase = init_supabase()