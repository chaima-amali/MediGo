"""Sync local medicine_plan and occurrence_plan rows to Supabase.

Run with: python backend/sync_local_plans_occurrences.py

This script:
- Finds local `medicine_plan` rows.
- Maps local users to Supabase users by email (creates remote user if missing).
- Maps local `medicine_tracking` to remote `medicine_tracking` by name+user (creates if missing).
- Inserts remote `medicine_plan` and associated `occurrence_plan` rows when missing.
"""
import sqlite3
import sys
from app.core.config import settings
from app.supabase_client import supabase

DB_PATH = settings.DATABASE_PATH


def get_local_plans(conn):
    cur = conn.execute("SELECT * FROM medicine_plan")
    return cur.fetchall()


def get_local_medicine(conn, medicine_track_id):
    cur = conn.execute("SELECT * FROM medicine_tracking WHERE medicine_track_id = ?", (medicine_track_id,))
    return cur.fetchone()


def get_local_user(conn, user_id):
    cur = conn.execute("SELECT * FROM users WHERE user_id = ?", (user_id,))
    return cur.fetchone()


def get_local_occurrences(conn, local_plan_id):
    cur = conn.execute("SELECT * FROM occurrence_plan WHERE plan_id = ?", (local_plan_id,))
    return cur.fetchall()


def find_or_create_remote_user(email, name=None):
    try:
        resp = supabase.table('users').select('user_id,email').eq('email', email).execute()
        if resp.data and len(resp.data) > 0:
            return resp.data[0]['user_id']
    except Exception as e:
        print(f"⚠️ Supabase lookup user failed for {email}: {e}")

    # create minimal remote user
    try:
        create = supabase.table('users').insert({'email': email, 'name': name}).execute()
        if create.data and len(create.data) > 0:
            return create.data[0].get('user_id')
    except Exception as e:
        print(f"⚠️ Supabase create user failed for {email}: {e}")
    return None


def find_or_create_remote_medicine(remote_user_id, local_med):
    try:
        resp = supabase.table('medicine_tracking').select('medicine_track_id').eq('user_id', remote_user_id).eq('name', local_med['name']).execute()
        if resp.data and len(resp.data) > 0:
            return resp.data[0].get('medicine_track_id')
    except Exception as e:
        print(f"⚠️ Supabase lookup medicine failed: {e}")

    payload = {
        'user_id': remote_user_id,
        'name': local_med.get('name'),
        'type': local_med.get('type'),
        'dosage': local_med.get('dosage')
    }
    try:
        create = supabase.table('medicine_tracking').insert(payload).execute()
        if create.data and len(create.data) > 0:
            return create.data[0].get('medicine_track_id')
    except Exception as e:
        print(f"⚠️ Supabase create medicine failed: {e}")
    return None


def find_remote_plan(remote_med_id, start_date):
    try:
        resp = supabase.table('medicine_plan').select('plan_id').eq('medicine_track_id', remote_med_id).eq('start_date', start_date).execute()
        if resp.data and len(resp.data) > 0:
            return resp.data[0].get('plan_id')
    except Exception as e:
        pass
    return None


def create_remote_plan(remote_med_id, remote_user_id, local_plan):
    payload = {
        'medicine_track_id': remote_med_id,
        'user_id': remote_user_id,
        'importance': local_plan.get('importance'),
        'start_date': local_plan.get('start_date'),
        'end_date': local_plan.get('end_date'),
        'frequency_type': local_plan.get('frequency_type'),
        'interval_days': local_plan.get('interval_days'),
        'weekdays': local_plan.get('weekdays'),
        'month_days': local_plan.get('month_days'),
        'custom_dates': local_plan.get('custom_dates')
    }
    try:
        resp = supabase.table('medicine_plan').insert(payload).execute()
        if resp.data and len(resp.data) > 0:
            return resp.data[0].get('plan_id')
    except Exception as e:
        print(f"⚠️ Supabase create plan failed: {e}")
    return None


def create_remote_occurrence(remote_plan_id, occ):
    payload = {
        'plan_id': remote_plan_id,
        'date': occ.get('date'),
        'time': occ.get('time'),
        'is_taken': occ.get('is_taken', 0),
        'day_of_week': occ.get('day_of_week'),
        'interval_value': occ.get('interval_value'),
        'interval_unit': occ.get('interval_unit')
    }
    try:
        resp = supabase.table('occurrence_plan').insert(payload).execute()
        return resp
    except Exception as e:
        print(f"⚠️ Supabase create occurrence failed: {e}")
        return None


def main():
    if not supabase:
        print("Supabase client not initialized. Aborting.")
        sys.exit(1)

    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row

    plans = get_local_plans(conn)
    if not plans:
        print("No local plans found.")
        return

    inserted_plans = 0
    inserted_occ = 0

    for lp in plans:
        lp = dict(lp)
        local_user = get_local_user(conn, lp['user_id'])
        if not local_user:
            print(f"Skipping plan {lp['plan_id']}: local user {lp['user_id']} not found")
            continue

        # sqlite3.Row does not support dict.get, convert to dict
        local_user = dict(local_user)

        email = local_user.get('email')
        remote_user_id = find_or_create_remote_user(email, local_user.get('name'))
        if not remote_user_id:
            print(f"Skipping plan {lp['plan_id']}: remote user not found/created for {email}")
            continue

        local_med = get_local_medicine(conn, lp['medicine_track_id'])
        if not local_med:
            print(f"Skipping plan {lp['plan_id']}: local medicine {lp['medicine_track_id']} not found")
            continue

        local_med = dict(local_med)
        remote_med_id = find_or_create_remote_medicine(remote_user_id, local_med)
        if not remote_med_id:
            print(f"Skipping plan {lp['plan_id']}: remote medicine not found/created")
            continue

        # avoid duplicates: try to find remote plan with same medicine_track_id and start_date
        remote_plan_id = find_remote_plan(remote_med_id, lp.get('start_date'))
        if not remote_plan_id:
            remote_plan_id = create_remote_plan(remote_med_id, remote_user_id, lp)

        if remote_plan_id:
            inserted_plans += 1
            occs = get_local_occurrences(conn, lp['plan_id'])
            for occ in occs:
                occ = dict(occ)
                # attempt to create remote occurrence
                resp = create_remote_occurrence(remote_plan_id, occ)
                if resp and getattr(resp, 'data', None):
                    inserted_occ += 1

    print(f"Done. plans_inserted={inserted_plans}, occurrences_inserted={inserted_occ}")


if __name__ == '__main__':
    main()
