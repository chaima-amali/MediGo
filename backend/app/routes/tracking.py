"""
Medicine Tracking API Routes - Medicine tracking operations with Supabase
Handles medicine tracking, plans, occurrences with remote/local fallback
"""

from flask import Blueprint, request, jsonify
from pydantic import ValidationError, BaseModel
from app.supabase_client import supabase
from app.core.database import execute_query, execute_insert, execute_update
from datetime import datetime
from typing import Optional, List

bp = Blueprint('tracking', __name__)


# =====================================================
# SCHEMAS
# =====================================================

class MedicineTrackingCreate(BaseModel):
    """Schema for creating medicine tracking entry"""
    user_id: int
    name: str
    type: Optional[str] = None
    dosage: Optional[str] = None


class MedicinePlanCreate(BaseModel):
    """Schema for creating medicine plan"""
    medicine_track_id: int
    user_id: int
    importance: Optional[str] = None
    start_date: str
    end_date: Optional[str] = None
    frequency_type: str  # daily, weekly, monthly, custom
    interval_days: Optional[int] = None
    weekdays: Optional[str] = None  # JSON string of weekdays
    month_days: Optional[str] = None  # JSON string of month days
    custom_dates: Optional[str] = None  # JSON string of custom dates


class OccurrencePlanCreate(BaseModel):
    """Schema for creating occurrence plan"""
    plan_id: int
    date: str
    time: str
    day_of_week: Optional[str] = None
    is_taken: int = 0


class DosageCheckCreate(BaseModel):
    """Schema for creating dosage check"""
    plan_id: int
    dose_date: str
    dose_time: str
    status: str  # pending, taken, missed, skipped
    taken_at: Optional[str] = None


class MedicationIntakeCreate(BaseModel):
    """Schema for logging medication intake"""
    occurrence_id: int
    medicine_track_id: int
    scheduled_date: str
    scheduled_time: str
    actual_time: Optional[str] = None
    status: str  # taken, missed, skipped
    dosage: Optional[str] = None
    notes: Optional[str] = None


# =====================================================
# MEDICINE TRACKING ROUTES
# =====================================================

@bp.route('/tracking/medicines', methods=['POST'])
def add_medicine():
    """
    Add a new medicine to user's tracking list
    Works with both Supabase and local database
    """
    try:
        medicine_data = MedicineTrackingCreate(**request.json)
        
        # Try Supabase first
        if supabase:
            try:
                new_medicine = {
                    'user_id': medicine_data.user_id,
                    'name': medicine_data.name,
                    'type': medicine_data.type,
                    'dosage': medicine_data.dosage
                }
                
                print(f"📤 [Backend] Attempting Supabase insert: {new_medicine}")
                response = supabase.table('medicine_tracking').insert(new_medicine).execute()
                print(f"📤 [Backend] Supabase response: {response}")
                
                if response.data and len(response.data) > 0:
                    print(f"✅ [Backend] Supabase insert successful")
                    return jsonify({
                        'success': True,
                        'medicine': response.data[0],
                        'source': 'remote'
                    }), 201
                    
            except Exception as supabase_error:
                print(f"⚠️  [Backend] Supabase add medicine failed: {str(supabase_error)}")
                print(f"⚠️  [Backend] Error type: {type(supabase_error)}")
                # Continue to fallback without re-raising
        
        # Fallback to local database
        print(f"📍 [Backend] Falling back to local database for user_id={medicine_data.user_id}, name={medicine_data.name}")
        query = """
            INSERT INTO medicine_tracking (user_id, name, type, dosage)
            VALUES (?, ?, ?, ?)
        """
        params = (medicine_data.user_id, medicine_data.name, medicine_data.type, medicine_data.dosage)
        medicine_id = execute_insert(query, params)
        print(f"✅ [Backend] Local insert successful, medicine_id={medicine_id}")
        
        rows = execute_query(
            "SELECT * FROM medicine_tracking WHERE medicine_track_id = ?",
            (medicine_id,)
        )
        
        if rows:
            return jsonify({
                'success': True,
                'medicine': dict(rows[0]),
                'source': 'local'
            }), 201
        else:
            return jsonify({'success': False, 'error': 'Failed to retrieve inserted medicine'}), 500
            
    except ValidationError as e:
        print(f"❌ [Backend] Validation error: {e.errors()}")
        return jsonify({'success': False, 'error': 'Validation error', 'details': e.errors()}), 400
    except Exception as e:
        print(f"❌ [Backend] Unexpected error: {str(e)}")
        import traceback
        traceback.print_exc()
        return jsonify({'success': False, 'error': str(e)}), 500


@bp.route('/tracking/medicines/<int:user_id>', methods=['GET'])

def get_user_medicines(user_id):
    """
    Get all medicines for a specific user
    """
    try:
        # Try Supabase first
        if supabase:
            try:
                response = supabase.table('medicine_tracking')\
                    .select('*')\
                    .eq('user_id', user_id)\
                    .execute()
                
                if response.data is not None:
                    return jsonify({
                        'success': True,
                        'count': len(response.data),
                        'medicines': response.data,
                        'source': 'remote'
                    }), 200
                    
            except Exception as supabase_error:
                print(f"⚠️  Supabase get medicines failed: {supabase_error}")
        
        # Fallback to local database
        rows = execute_query(
            "SELECT * FROM medicine_tracking WHERE user_id = ?",
            (user_id,)
        )
        
        medicines = [dict(row) for row in rows]
        return jsonify({
            'success': True,
            'count': len(medicines),
            'medicines': medicines,
            'source': 'local'
        }), 200
        
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@bp.route('/tracking/medicines/detail/<int:medicine_track_id>', methods=['GET'])
def get_medicine_detail(medicine_track_id):
    """
    Get specific medicine details by medicine_track_id
    """
    try:
        # Try Supabase first
        if supabase:
            try:
                response = supabase.table('medicine_tracking')\
                    .select('*')\
                    .eq('medicine_track_id', medicine_track_id)\
                    .execute()
                
                if response.data and len(response.data) > 0:
                    return jsonify({
                        'success': True,
                        'medicine': response.data[0],
                        'source': 'remote'
                    }), 200
                    
            except Exception as supabase_error:
                print(f"⚠️  Supabase get medicine detail failed: {supabase_error}")
        
        # Fallback to local database
        rows = execute_query(
            "SELECT * FROM medicine_tracking WHERE medicine_track_id = ?",
            (medicine_track_id,)
        )
        
        if rows:
            return jsonify({
                'success': True,
                'medicine': dict(rows[0]),
                'source': 'local'
            }), 200
        else:
            return jsonify({'success': False, 'error': 'Medicine not found'}), 404
            
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@bp.route('/tracking/medicines/<int:medicine_track_id>', methods=['PUT'])
def update_medicine(medicine_track_id):
    """
    Update medicine tracking entry
    """
    try:
        update_data = request.json
        
        # Try Supabase first
        if supabase:
            try:
                response = supabase.table('medicine_tracking')\
                    .update(update_data)\
                    .eq('medicine_track_id', medicine_track_id)\
                    .execute()
                
                if response.data and len(response.data) > 0:
                    return jsonify({
                        'success': True,
                        'medicine': response.data[0],
                        'source': 'remote'
                    }), 200
                    
            except Exception as supabase_error:
                print(f"⚠️  Supabase update medicine failed: {supabase_error}")
        
        # Fallback to local database
        fields = []
        params = []
        
        for key, value in update_data.items():
            fields.append(f"{key} = ?")
            params.append(value)
        
        if not fields:
            return jsonify({'success': False, 'error': 'No fields to update'}), 400
        
        params.append(medicine_track_id)
        query = f"UPDATE medicine_tracking SET {', '.join(fields)} WHERE medicine_track_id = ?"
        
        affected = execute_update(query, params)
        
        if affected == 0:
            return jsonify({'success': False, 'error': 'Medicine not found'}), 404
        
        rows = execute_query(
            "SELECT * FROM medicine_tracking WHERE medicine_track_id = ?",
            (medicine_track_id,)
        )
        
        return jsonify({
            'success': True,
            'medicine': dict(rows[0]),
            'source': 'local'
        }), 200
        
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@bp.route('/tracking/medicines/<int:medicine_track_id>', methods=['DELETE'])
def delete_medicine(medicine_track_id):
    """
    Delete medicine and all associated plans, occurrences, and logs
    """
    try:
        # Try Supabase first
        if supabase:
            try:
                # Supabase will cascade delete due to foreign key constraints
                response = supabase.table('medicine_tracking')\
                    .delete()\
                    .eq('medicine_track_id', medicine_track_id)\
                    .execute()
                
                return jsonify({
                    'success': True,
                    'message': 'Medicine deleted successfully',
                    'source': 'remote'
                }), 200
                    
            except Exception as supabase_error:
                print(f"⚠️  Supabase delete medicine failed: {supabase_error}")
        
        # Fallback to local database
        affected = execute_update(
            "DELETE FROM medicine_tracking WHERE medicine_track_id = ?",
            (medicine_track_id,)
        )
        
        if affected == 0:
            return jsonify({'success': False, 'error': 'Medicine not found'}), 404
        
        return jsonify({
            'success': True,
            'message': 'Medicine deleted successfully',
            'source': 'local'
        }), 200
        
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


# =====================================================
# MEDICINE PLAN ROUTES
# =====================================================

@bp.route('/tracking/plans', methods=['POST'])
def create_medicine_plan():
    """
    Create a medicine plan (schedule) for a tracked medicine
    """
    try:
        plan_data = MedicinePlanCreate(**request.json)
        
        # Try Supabase first
        if supabase:
            try:
                new_plan = {
                    'medicine_track_id': plan_data.medicine_track_id,
                    'user_id': plan_data.user_id,
                    'importance': plan_data.importance,
                    'start_date': plan_data.start_date,
                    'end_date': plan_data.end_date,
                    'frequency_type': plan_data.frequency_type,
                    'interval_days': plan_data.interval_days,
                    'weekdays': plan_data.weekdays,
                    'month_days': plan_data.month_days,
                    'custom_dates': plan_data.custom_dates
                }
                
                response = supabase.table('medicine_plan').insert(new_plan).execute()
                
                if response.data and len(response.data) > 0:
                    return jsonify({
                        'success': True,
                        'plan': response.data[0],
                        'source': 'remote'
                    }), 201
                    
            except Exception as supabase_error:
                print(f"⚠️  Supabase create plan failed: {supabase_error}")
        
        # Fallback to local database
        query = """
            INSERT INTO medicine_plan (medicine_track_id, user_id, importance, start_date, 
                                      end_date, frequency_type, interval_days, weekdays, 
                                      month_days, custom_dates)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """
        params = (
            plan_data.medicine_track_id, plan_data.user_id, plan_data.importance,
            plan_data.start_date, plan_data.end_date, plan_data.frequency_type,
            plan_data.interval_days, plan_data.weekdays, plan_data.month_days,
            plan_data.custom_dates
        )
        
        plan_id = execute_insert(query, params)
        
        rows = execute_query("SELECT * FROM medicine_plan WHERE plan_id = ?", (plan_id,))
        
        if rows:
            return jsonify({
                'success': True,
                'plan': dict(rows[0]),
                'source': 'local'
            }), 201
            
    except ValidationError as e:
        return jsonify({'success': False, 'error': 'Validation error', 'details': e.errors()}), 400
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@bp.route('/tracking/plans/<int:plan_id>', methods=['GET'])
def get_medicine_plan(plan_id):
    """
    Get specific medicine plan
    """
    try:
        # Try Supabase first
        if supabase:
            try:
                response = supabase.table('medicine_plan')\
                    .select('*, medicine_tracking(*)')\
                    .eq('plan_id', plan_id)\
                    .execute()
                
                if response.data and len(response.data) > 0:
                    return jsonify({
                        'success': True,
                        'plan': response.data[0],
                        'source': 'remote'
                    }), 200
                    
            except Exception as supabase_error:
                print(f"⚠️  Supabase get plan failed: {supabase_error}")
        
        # Fallback to local database
        rows = execute_query(
            """
            SELECT mp.*, mt.name, mt.type, mt.dosage
            FROM medicine_plan mp
            LEFT JOIN medicine_tracking mt ON mp.medicine_track_id = mt.medicine_track_id
            WHERE mp.plan_id = ?
            """,
            (plan_id,)
        )
        
        if rows:
            return jsonify({
                'success': True,
                'plan': dict(rows[0]),
                'source': 'local'
            }), 200
        else:
            return jsonify({'success': False, 'error': 'Plan not found'}), 404
            
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@bp.route('/tracking/plans/user/<int:user_id>', methods=['GET'])
def get_user_plans(user_id):
    """
    Get all medicine plans for a user
    """
    try:
        # Try Supabase first
        if supabase:
            try:
                response = supabase.table('medicine_plan')\
                    .select('*, medicine_tracking(*)')\
                    .eq('user_id', user_id)\
                    .execute()
                
                if response.data is not None:
                    return jsonify({
                        'success': True,
                        'count': len(response.data),
                        'plans': response.data,
                        'source': 'remote'
                    }), 200
                    
            except Exception as supabase_error:
                print(f"⚠️  Supabase get user plans failed: {supabase_error}")
        
        # Fallback to local database
        rows = execute_query(
            """
            SELECT mp.*, mt.name, mt.type, mt.dosage
            FROM medicine_plan mp
            LEFT JOIN medicine_tracking mt ON mp.medicine_track_id = mt.medicine_track_id
            WHERE mp.user_id = ?
            """,
            (user_id,)
        )
        
        plans = [dict(row) for row in rows]
        return jsonify({
            'success': True,
            'count': len(plans),
            'plans': plans,
            'source': 'local'
        }), 200
        
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@bp.route('/tracking/plans/<int:plan_id>', methods=['PUT'])
def update_medicine_plan(plan_id):
    """
    Update medicine plan
    """
    try:
        update_data = request.json
        
        # Try Supabase first
        if supabase:
            try:
                response = supabase.table('medicine_plan')\
                    .update(update_data)\
                    .eq('plan_id', plan_id)\
                    .execute()
                
                if response.data and len(response.data) > 0:
                    return jsonify({
                        'success': True,
                        'plan': response.data[0],
                        'source': 'remote'
                    }), 200
                    
            except Exception as supabase_error:
                print(f"⚠️  Supabase update plan failed: {supabase_error}")
        
        # Fallback to local database
        fields = []
        params = []
        
        for key, value in update_data.items():
            fields.append(f"{key} = ?")
            params.append(value)
        
        if not fields:
            return jsonify({'success': False, 'error': 'No fields to update'}), 400
        
        params.append(plan_id)
        query = f"UPDATE medicine_plan SET {', '.join(fields)} WHERE plan_id = ?"
        
        affected = execute_update(query, params)
        
        if affected == 0:
            return jsonify({'success': False, 'error': 'Plan not found'}), 404
        
        rows = execute_query("SELECT * FROM medicine_plan WHERE plan_id = ?", (plan_id,))
        
        return jsonify({
            'success': True,
            'plan': dict(rows[0]),
            'source': 'local'
        }), 200
        
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@bp.route('/tracking/plans/<int:plan_id>', methods=['DELETE'])
def delete_medicine_plan(plan_id):
    """
    Delete medicine plan and all associated occurrences
    """
    try:
        # Try Supabase first
        if supabase:
            try:
                response = supabase.table('medicine_plan')\
                    .delete()\
                    .eq('plan_id', plan_id)\
                    .execute()
                
                return jsonify({
                    'success': True,
                    'message': 'Plan deleted successfully',
                    'source': 'remote'
                }), 200
                    
            except Exception as supabase_error:
                print(f"⚠️  Supabase delete plan failed: {supabase_error}")
        
        # Fallback to local database
        affected = execute_update(
            "DELETE FROM medicine_plan WHERE plan_id = ?",
            (plan_id,)
        )
        
        if affected == 0:
            return jsonify({'success': False, 'error': 'Plan not found'}), 404
        
        return jsonify({
            'success': True,
            'message': 'Plan deleted successfully',
            'source': 'local'
        }), 200
        
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


# =====================================================
# OCCURRENCE PLAN ROUTES
# =====================================================

@bp.route('/tracking/occurrences', methods=['POST'])
def create_occurrence():
    """
    Create occurrence plan (specific dose instance)
    """
    try:
        occurrence_data = OccurrencePlanCreate(**request.json)
        
        # Try Supabase first
        if supabase:
            try:
                new_occurrence = {
                    'plan_id': occurrence_data.plan_id,
                    'date': occurrence_data.date,
                    'time': occurrence_data.time,
                    'day_of_week': occurrence_data.day_of_week,
                    'is_taken': occurrence_data.is_taken
                }
                
                response = supabase.table('occurrence_plan').insert(new_occurrence).execute()
                
                if response.data and len(response.data) > 0:
                    # Also create a corresponding daily dosage check for this occurrence
                    try:
                        occ = response.data[0]
                        new_check = {
                            'plan_id': occ.get('plan_id'),
                            'dose_date': occ.get('date'),
                            'dose_time': occ.get('time'),
                            'status': 'pending',
                            'taken_at': None
                        }
                        supabase.table('daily_dosage_checking').insert(new_check).execute()
                    except Exception as _:
                        print('⚠️  Failed to create daily_dosage_checking in Supabase (continuing)')

                    return jsonify({
                        'success': True,
                        'occurrence': response.data[0],
                        'source': 'remote'
                    }), 201
                    
            except Exception as supabase_error:
                print(f"⚠️  Supabase create occurrence failed: {supabase_error}")
        
        # Fallback to local database
        query = """
            INSERT INTO occurrence_plan (plan_id, date, time, day_of_week, is_taken)
            VALUES (?, ?, ?, ?, ?)
        """
        params = (
            occurrence_data.plan_id, occurrence_data.date, occurrence_data.time,
            occurrence_data.day_of_week, occurrence_data.is_taken
        )
        
        occurrence_id = execute_insert(query, params)
        
        rows = execute_query("SELECT * FROM occurrence_plan WHERE id = ?", (occurrence_id,))
        
        if rows:
            # Create corresponding daily dosage check in local DB
            try:
                execute_insert(
                    """
                    INSERT INTO daily_dosage_checking (plan_id, dose_date, dose_time, status, taken_at)
                    VALUES (?, ?, ?, ?, ?)
                    """,
                    (
                        occurrence_data.plan_id,
                        occurrence_data.date,
                        occurrence_data.time,
                        'pending',
                        None,
                    ),
                )
            except Exception:
                print('⚠️  Failed to create local daily_dosage_checking (continuing)')
            return jsonify({
                'success': True,
                'occurrence': dict(rows[0]),
                'source': 'local'
            }), 201
            
    except ValidationError as e:
        return jsonify({'success': False, 'error': 'Validation error', 'details': e.errors()}), 400
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@bp.route('/tracking/occurrences/batch', methods=['POST'])
def create_occurrences_batch():
    """
    Create multiple occurrences at once (for efficiency)
    Request body: {"occurrences": [{plan_id, date, time, ...}, ...]}
    """
    try:
        occurrences_data = request.json.get('occurrences', [])
        
        if not occurrences_data:
            return jsonify({'success': False, 'error': 'No occurrences provided'}), 400
        
        # Try Supabase first
        if supabase:
            try:
                response = supabase.table('occurrence_plan').insert(occurrences_data).execute()
                
                if response.data:
                    # Also create daily dosage checks for each created occurrence
                    try:
                        checks = []
                        for occ in response.data:
                            checks.append({
                                'plan_id': occ.get('plan_id'),
                                'dose_date': occ.get('date'),
                                'dose_time': occ.get('time'),
                                'status': 'pending',
                                'taken_at': None
                            })
                        if checks:
                            supabase.table('daily_dosage_checking').insert(checks).execute()
                    except Exception:
                        print('⚠️  Failed to create batch daily_dosage_checking in Supabase (continuing)')

                    return jsonify({
                        'success': True,
                        'count': len(response.data),
                        'occurrences': response.data,
                        'source': 'remote'
                    }), 201
                    
            except Exception as supabase_error:
                print(f"⚠️  Supabase batch create occurrences failed: {supabase_error}")
        
        # Fallback to local database
        inserted_ids = []
        for occ in occurrences_data:
            query = """
                INSERT INTO occurrence_plan (plan_id, date, time, day_of_week, is_taken)
                VALUES (?, ?, ?, ?, ?)
            """
            params = (
                occ.get('plan_id'), occ.get('date'), occ.get('time'),
                occ.get('day_of_week'), occ.get('is_taken', 0)
            )
            occ_id = execute_insert(query, params)
            inserted_ids.append(occ_id)
            # create local daily dosage check for each inserted occurrence
            try:
                execute_insert(
                    """
                    INSERT INTO daily_dosage_checking (plan_id, dose_date, dose_time, status, taken_at)
                    VALUES (?, ?, ?, ?, ?)
                    """,
                    (
                        occ.get('plan_id'),
                        occ.get('date'),
                        occ.get('time'),
                        'pending',
                        None,
                    ),
                )
            except Exception:
                print('⚠️  Failed to create local daily_dosage_checking for an occurrence (continuing)')
        
        return jsonify({
            'success': True,
            'count': len(inserted_ids),
            'occurrence_ids': inserted_ids,
            'source': 'local'
        }), 201
        
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@bp.route('/tracking/occurrences/plan/<int:plan_id>', methods=['GET'])
def get_plan_occurrences(plan_id):
    """
    Get all occurrences for a specific plan
    """
    try:
        # Optional query params for filtering
        date = request.args.get('date')
        
        # Try Supabase first
        if supabase:
            try:
                query = supabase.table('occurrence_plan')\
                    .select('*')\
                    .eq('plan_id', plan_id)
                
                if date:
                    query = query.eq('date', date)
                
                response = query.order('date', desc=False)\
                    .order('time', desc=False)\
                    .execute()
                
                if response.data is not None:
                    return jsonify({
                        'success': True,
                        'count': len(response.data),
                        'occurrences': response.data,
                        'source': 'remote'
                    }), 200
                    
            except Exception as supabase_error:
                print(f"⚠️  Supabase get occurrences failed: {supabase_error}")
        
        # Fallback to local database
        query = "SELECT * FROM occurrence_plan WHERE plan_id = ?"
        params = [plan_id]
        
        if date:
            query += " AND date = ?"
            params.append(date)
        
        query += " ORDER BY date, time"
        
        rows = execute_query(query, params)
        occurrences = [dict(row) for row in rows]
        
        return jsonify({
            'success': True,
            'count': len(occurrences),
            'occurrences': occurrences,
            'source': 'local'
        }), 200
        
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@bp.route('/tracking/occurrences/date/<date>', methods=['GET'])
def get_occurrences_by_date(date):
    """
    Get all occurrences for a specific date across all plans for a user
    Query param: user_id (required)
    """
    try:
        user_id = request.args.get('user_id', type=int)
        
        if not user_id:
            return jsonify({'success': False, 'error': 'user_id is required'}), 400
        
        # Try Supabase first
        if supabase:
            try:
                response = supabase.table('occurrence_plan')\
                    .select('*, medicine_plan!inner(*, medicine_tracking(*))')\
                    .eq('date', date)\
                    .eq('medicine_plan.user_id', user_id)\
                    .order('time', desc=False)\
                    .execute()
                
                if response.data is not None:
                    return jsonify({
                        'success': True,
                        'date': date,
                        'count': len(response.data),
                        'occurrences': response.data,
                        'source': 'remote'
                    }), 200
                    
            except Exception as supabase_error:
                print(f"⚠️  Supabase get occurrences by date failed: {supabase_error}")
        
        # Fallback to local database
        rows = execute_query(
            """
            SELECT op.*, mp.*, mt.name, mt.type, mt.dosage
            FROM occurrence_plan op
            JOIN medicine_plan mp ON op.plan_id = mp.plan_id
            JOIN medicine_tracking mt ON mp.medicine_track_id = mt.medicine_track_id
            WHERE op.date = ? AND mp.user_id = ?
            ORDER BY op.time
            """,
            (date, user_id)
        )
        
        occurrences = [dict(row) for row in rows]
        
        return jsonify({
            'success': True,
            'date': date,
            'count': len(occurrences),
            'occurrences': occurrences,
            'source': 'local'
        }), 200
        
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@bp.route('/tracking/occurrences/<int:occurrence_id>', methods=['PUT'])
def update_occurrence(occurrence_id):
    """
    Update occurrence (e.g., mark as taken)
    """
    try:
        update_data = request.json
        
        # Try Supabase first
        if supabase:
            try:
                response = supabase.table('occurrence_plan')\
                    .update(update_data)\
                    .eq('id', occurrence_id)\
                    .execute()
                
                if response.data and len(response.data) > 0:
                    return jsonify({
                        'success': True,
                        'occurrence': response.data[0],
                        'source': 'remote'
                    }), 200
                    
            except Exception as supabase_error:
                print(f"⚠️  Supabase update occurrence failed: {supabase_error}")
        
        # Fallback to local database
        fields = []
        params = []
        
        for key, value in update_data.items():
            fields.append(f"{key} = ?")
            params.append(value)
        
        if not fields:
            return jsonify({'success': False, 'error': 'No fields to update'}), 400
        
        params.append(occurrence_id)
        query = f"UPDATE occurrence_plan SET {', '.join(fields)} WHERE id = ?"
        
        affected = execute_update(query, params)
        
        if affected == 0:
            return jsonify({'success': False, 'error': 'Occurrence not found'}), 404
        
        rows = execute_query("SELECT * FROM occurrence_plan WHERE id = ?", (occurrence_id,))
        
        return jsonify({
            'success': True,
            'occurrence': dict(rows[0]),
            'source': 'local'
        }), 200
        
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@bp.route('/tracking/occurrences/<int:occurrence_id>', methods=['DELETE'])
def delete_occurrence(occurrence_id):
    """
    Delete specific occurrence
    """
    try:
        # Try Supabase first
        if supabase:
            try:
                response = supabase.table('occurrence_plan')\
                    .delete()\
                    .eq('id', occurrence_id)\
                    .execute()
                
                return jsonify({
                    'success': True,
                    'message': 'Occurrence deleted successfully',
                    'source': 'remote'
                }), 200
                    
            except Exception as supabase_error:
                print(f"⚠️  Supabase delete occurrence failed: {supabase_error}")
        
        # Fallback to local database
        affected = execute_update(
            "DELETE FROM occurrence_plan WHERE id = ?",
            (occurrence_id,)
        )
        
        if affected == 0:
            return jsonify({'success': False, 'error': 'Occurrence not found'}), 404
        
        return jsonify({
            'success': True,
            'message': 'Occurrence deleted successfully',
            'source': 'local'
        }), 200
        
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


# =====================================================
# DAILY DOSAGE CHECKING ROUTES
# =====================================================

@bp.route('/tracking/dosage-checks', methods=['POST'])
def create_dosage_check():
    """
    Create daily dosage check entry
    """
    try:
        dosage_data = DosageCheckCreate(**request.json)
        
        # Try Supabase first
        if supabase:
            try:
                new_check = {
                    'plan_id': dosage_data.plan_id,
                    'dose_date': dosage_data.dose_date,
                    'dose_time': dosage_data.dose_time,
                    'status': dosage_data.status,
                    'taken_at': dosage_data.taken_at
                }
                
                response = supabase.table('daily_dosage_checking').insert(new_check).execute()
                
                if response.data and len(response.data) > 0:
                    return jsonify({
                        'success': True,
                        'dosage_check': response.data[0],
                        'source': 'remote'
                    }), 201
                    
            except Exception as supabase_error:
                print(f"⚠️  Supabase create dosage check failed: {supabase_error}")
        
        # Fallback to local database
        query = """
            INSERT INTO daily_dosage_checking (plan_id, dose_date, dose_time, status, taken_at)
            VALUES (?, ?, ?, ?, ?)
        """
        params = (
            dosage_data.plan_id, dosage_data.dose_date, dosage_data.dose_time,
            dosage_data.status, dosage_data.taken_at
        )
        
        check_id = execute_insert(query, params)
        
        rows = execute_query("SELECT * FROM daily_dosage_checking WHERE dc_id = ?", (check_id,))
        
        if rows:
            return jsonify({
                'success': True,
                'dosage_check': dict(rows[0]),
                'source': 'local'
            }), 201
            
    except ValidationError as e:
        return jsonify({'success': False, 'error': 'Validation error', 'details': e.errors()}), 400
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@bp.route('/tracking/dosage-checks/date/<date>', methods=['GET'])
def get_dosage_checks_by_date(date):
    """
    Get all dosage checks for a specific date and user
    Query param: user_id (required)
    """
    try:
        user_id = request.args.get('user_id', type=int)
        
        if not user_id:
            return jsonify({'success': False, 'error': 'user_id is required'}), 400
        
        # Try Supabase first
        if supabase:
            try:
                response = supabase.table('daily_dosage_checking')\
                    .select('*, medicine_plan!inner(user_id)')\
                    .eq('dose_date', date)\
                    .eq('medicine_plan.user_id', user_id)\
                    .execute()
                
                if response.data is not None:
                    return jsonify({
                        'success': True,
                        'date': date,
                        'count': len(response.data),
                        'dosage_checks': response.data,
                        'source': 'remote'
                    }), 200
                    
            except Exception as supabase_error:
                print(f"⚠️  Supabase get dosage checks failed: {supabase_error}")
        
        # Fallback to local database
        rows = execute_query(
            """
            SELECT dc.*
            FROM daily_dosage_checking dc
            JOIN medicine_plan mp ON dc.plan_id = mp.plan_id
            WHERE dc.dose_date = ? AND mp.user_id = ?
            """,
            (date, user_id)
        )
        
        checks = [dict(row) for row in rows]
        
        return jsonify({
            'success': True,
            'date': date,
            'count': len(checks),
            'dosage_checks': checks,
            'source': 'local'
        }), 200
        
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@bp.route('/tracking/dosage-checks/<int:dc_id>', methods=['PUT'])
def update_dosage_check(dc_id):
    """
    Update dosage check (e.g., update status or taken_at time)
    """
    try:
        update_data = request.json
        
        # Try Supabase first
        if supabase:
            try:
                response = supabase.table('daily_dosage_checking')\
                    .update(update_data)\
                    .eq('dc_id', dc_id)\
                    .execute()
                
                if response.data and len(response.data) > 0:
                    return jsonify({
                        'success': True,
                        'dosage_check': response.data[0],
                        'source': 'remote'
                    }), 200
                    
            except Exception as supabase_error:
                print(f"⚠️  Supabase update dosage check failed: {supabase_error}")
        
        # Fallback to local database
        fields = []
        params = []
        
        for key, value in update_data.items():
            fields.append(f"{key} = ?")
            params.append(value)
        
        if not fields:
            return jsonify({'success': False, 'error': 'No fields to update'}), 400
        
        params.append(dc_id)
        query = f"UPDATE daily_dosage_checking SET {', '.join(fields)} WHERE dc_id = ?"
        
        affected = execute_update(query, params)
        
        if affected == 0:
            return jsonify({'success': False, 'error': 'Dosage check not found'}), 404
        
        rows = execute_query("SELECT * FROM daily_dosage_checking WHERE dc_id = ?", (dc_id,))
        
        return jsonify({
            'success': True,
            'dosage_check': dict(rows[0]),
            'source': 'local'
        }), 200
        
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


# =====================================================
# MEDICATION INTAKE LOG ROUTES
# =====================================================

@bp.route('/tracking/intake-logs', methods=['POST'])
def log_medication_intake():
    """
    Log medication intake (when user actually takes medicine)
    """
    try:
        intake_data = MedicationIntakeCreate(**request.json)
        
        # Try Supabase first
        if supabase:
            try:
                new_log = {
                    'occurrence_id': intake_data.occurrence_id,
                    'medicine_track_id': intake_data.medicine_track_id,
                    'scheduled_date': intake_data.scheduled_date,
                    'scheduled_time': intake_data.scheduled_time,
                    'actual_time': intake_data.actual_time,
                    'status': intake_data.status,
                    'dosage': intake_data.dosage,
                    'notes': intake_data.notes
                }
                
                response = supabase.table('medication_intake_log').insert(new_log).execute()
                
                if response.data and len(response.data) > 0:
                    return jsonify({
                        'success': True,
                        'intake_log': response.data[0],
                        'source': 'remote'
                    }), 201
                    
            except Exception as supabase_error:
                print(f"⚠️  Supabase create intake log failed: {supabase_error}")
        
        # Fallback to local database
        query = """
            INSERT INTO medication_intake_log (occurrence_id, medicine_track_id, scheduled_date,
                                               scheduled_time, actual_time, status, dosage, notes)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """
        params = (
            intake_data.occurrence_id, intake_data.medicine_track_id,
            intake_data.scheduled_date, intake_data.scheduled_time,
            intake_data.actual_time, intake_data.status,
            intake_data.dosage, intake_data.notes
        )
        
        log_id = execute_insert(query, params)
        
        rows = execute_query("SELECT * FROM medication_intake_log WHERE log_id = ?", (log_id,))
        
        if rows:
            return jsonify({
                'success': True,
                'intake_log': dict(rows[0]),
                'source': 'local'
            }), 201
            
    except ValidationError as e:
        return jsonify({'success': False, 'error': 'Validation error', 'details': e.errors()}), 400
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@bp.route('/tracking/intake-logs/medicine/<int:medicine_track_id>', methods=['GET'])
def get_medicine_intake_logs(medicine_track_id):
    """
    Get all intake logs for a specific medicine
    """
    try:
        # Optional date range filters
        start_date = request.args.get('start_date')
        end_date = request.args.get('end_date')
        
        # Try Supabase first
        if supabase:
            try:
                query = supabase.table('medication_intake_log')\
                    .select('*')\
                    .eq('medicine_track_id', medicine_track_id)
                
                if start_date:
                    query = query.gte('scheduled_date', start_date)
                if end_date:
                    query = query.lte('scheduled_date', end_date)
                
                response = query.order('scheduled_date', desc=True)\
                    .order('scheduled_time', desc=True)\
                    .execute()
                
                if response.data is not None:
                    return jsonify({
                        'success': True,
                        'count': len(response.data),
                        'intake_logs': response.data,
                        'source': 'remote'
                    }), 200
                    
            except Exception as supabase_error:
                print(f"⚠️  Supabase get intake logs failed: {supabase_error}")
        
        # Fallback to local database
        query = "SELECT * FROM medication_intake_log WHERE medicine_track_id = ?"
        params = [medicine_track_id]
        
        if start_date:
            query += " AND scheduled_date >= ?"
            params.append(start_date)
        if end_date:
            query += " AND scheduled_date <= ?"
            params.append(end_date)
        
        query += " ORDER BY scheduled_date DESC, scheduled_time DESC"
        
        rows = execute_query(query, params)
        logs = [dict(row) for row in rows]
        
        return jsonify({
            'success': True,
            'count': len(logs),
            'intake_logs': logs,
            'source': 'local'
        }), 200
        
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500
