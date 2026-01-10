import traceback
from app.supabase_client import supabase

print('SUPABASE_CLIENT_INITIALIZED=', supabase is not None)

try:
    res = supabase.table('users').select('user_id').limit(1).execute()
    print('RESPONSE_TYPE:', type(res))
    # print full repr safely
    try:
        print('REPR:', repr(res))
    except Exception:
        pass
    try:
        data = getattr(res, 'data', None)
        print('DATA:', data)
    except Exception as e:
        print('DATA_READ_ERROR:', e)
except Exception as e:
    print('EXCEPTION:', e)
    traceback.print_exc()
