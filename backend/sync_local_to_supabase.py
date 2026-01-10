"""Sync local medicine_tracking rows to Supabase.

Run this from the project root with the virtualenv active:

    python backend/sync_local_to_supabase.py

What it does:
- For each local user in the SQLite DB, try to find a Supabase user by email.
- If found, insert each local `medicine_tracking` row for that local user into Supabase
  using the remote `user_id` (does not modify the local DB).
- Prints summary and errors. Safe: it will not delete or overwrite local rows.
"""
import sqlite3
import sys
from app.core.config import settings
from app.supabase_client import supabase


DB_PATH = settings.DATABASE_PATH


def get_local_users(conn):
    cur = conn.execute("SELECT user_id, name, email FROM users")
    return cur.fetchall()


def get_local_medicines_for_user(conn, local_user_id):
    cur = conn.execute(
        "SELECT medicine_track_id, user_id, name, type, dosage, created_at FROM medicine_tracking WHERE user_id = ?",
        (local_user_id,)
    )
    return cur.fetchall()


def find_remote_user_by_email(email):
    try:
        resp = supabase.table('users').select('user_id,email').eq('email', email).execute()
        if resp.data and len(resp.data) > 0:
            return resp.data[0]['user_id']
    except Exception as e:
        print(f"⚠️  Supabase user lookup failed for {email}: {e}")
    return None


def insert_medicine_remote(remote_user_id, med):
    new_medicine = {
        'user_id': remote_user_id,
        'name': med['name'],
        'type': med.get('type'),
        'dosage': med.get('dosage')
    }
    try:
        # Idempotent: check if a medicine with same user_id+name already exists
        try:
            existing = supabase.table('medicine_tracking')\
                .select('medicine_track_id')\
                .eq('user_id', remote_user_id)\
                .eq('name', med['name'])\
                .limit(1)\
                .execute()
            if existing.data and len(existing.data) > 0:
                return {'already_exists': True, 'medicine': existing.data[0]}
        except Exception as e:
            print(f"⚠️  Supabase pre-insert lookup failed for medicine '{med['name']}' user={remote_user_id}: {e}")

        resp = supabase.table('medicine_tracking').insert(new_medicine).execute()
        return resp
    except Exception as e:
        return e


def main():
    if not supabase:
        print("Supabase client not initialized. Aborting.")
        sys.exit(1)

    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row

    # Ensure local table has columns to track remote mapping
    try:
        cur = conn.execute("PRAGMA table_info(medicine_tracking)")
        cols = [r[1] for r in cur.fetchall()]
        if 'remote_id' not in cols:
            try:
                conn.execute("ALTER TABLE medicine_tracking ADD COLUMN remote_id INTEGER")
                print("Added column medicine_tracking.remote_id")
            except Exception as e:
                print(f"⚠️  Could not add remote_id column: {e}")
        if 'synced' not in cols:
            try:
                conn.execute("ALTER TABLE medicine_tracking ADD COLUMN synced INTEGER DEFAULT 0")
                print("Added column medicine_tracking.synced")
            except Exception as e:
                print(f"⚠️  Could not add synced column: {e}")
        conn.commit()
    except Exception as e:
        print(f"⚠️  Failed to ensure medicine_tracking schema: {e}")

    users = get_local_users(conn)
    if not users:
        print("No local users found.")
        return

    total_inserted = 0
    total_failed = 0

    for u in users:
        local_user_id = u['user_id']
        email = u['email']
        print(f"\n--- Processing local user {local_user_id} ({email}) ---")

        remote_id = None
        if email:
            remote_id = find_remote_user_by_email(email)

        if not remote_id:
            print(f"No remote user found for email={email}. Skipping this user.")
            continue

        meds = get_local_medicines_for_user(conn, local_user_id)
        if not meds:
            print("No local medicines to sync for this user.")
            continue

        for med in meds:
            med = dict(med)
            # Skip if already marked as synced
            if med.get('synced') == 1 or (med.get('remote_id') is not None and med.get('remote_id') != 0):
                print(f"Skipping already-synced local medicine {med['medicine_track_id']} (remote_id={med.get('remote_id')})")
                continue
            print(f"Syncing local medicine {med['medicine_track_id']} -> remote user_id={remote_id}")
            resp = insert_medicine_remote(remote_id, med)
            if isinstance(resp, Exception):
                print(f"Failed to insert: {resp}")
                total_failed += 1
            else:
                # resp may be APIResponse; inspect .data
                try:
                    # handle already_exists marker
                    if isinstance(resp, dict) and resp.get('already_exists'):
                        inserted = True
                        remote_row = resp.get('medicine')
                    else:
                        inserted = resp.data and len(resp.data) > 0
                except Exception:
                    inserted = False

                if inserted:
                    total_inserted += 1
                    # determine remote id
                    try:
                        if isinstance(resp, dict) and resp.get('already_exists'):
                            remote_id_row = remote_row
                        else:
                            remote_id_row = resp.data[0]
                        remote_medicine_id = remote_id_row.get('medicine_track_id') or remote_id_row.get('id')
                    except Exception:
                        remote_medicine_id = None

                    print(f"Inserted/Found remote id: {remote_id_row}")

                    # Mark local row as synced and store remote_id when available
                    try:
                        if remote_medicine_id is not None:
                            conn.execute(
                                "UPDATE medicine_tracking SET remote_id = ?, synced = 1 WHERE medicine_track_id = ?",
                                (remote_medicine_id, med['medicine_track_id'])
                            )
                        else:
                            conn.execute(
                                "UPDATE medicine_tracking SET synced = 1 WHERE medicine_track_id = ?",
                                (med['medicine_track_id'],)
                            )
                        conn.commit()
                        print(f"Marked local medicine {med['medicine_track_id']} as synced (remote_id={remote_medicine_id})")
                    except Exception as e:
                        print(f"⚠️  Failed to mark local medicine as synced: {e}")
                else:
                    total_failed += 1
                    print(f"Insert response: {resp}")

    print(f"\nDone. inserted={total_inserted}, failed={total_failed}")


if __name__ == '__main__':
    main()
