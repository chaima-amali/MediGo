"""
Statistics API Routes - Medicine adherence and statistics with Supabase
Provides analytics on medicine taking patterns, adherence rates, and compliance
"""

from flask import Blueprint, request, jsonify
from app.supabase_client import supabase
from app.core.database import execute_query
from datetime import datetime, timedelta
from typing import Dict, List

bp = Blueprint('statistics', __name__)


# =====================================================
# STATISTICS HELPER FUNCTIONS
# =====================================================

def calculate_adherence_rate(taken: int, total: int) -> float:
    """Calculate adherence rate percentage"""
    if total == 0:
        return 0.0
    return round((taken / total) * 100, 2)


def get_date_range(period: str) -> tuple:
    """
    Get start and end dates for a period
    period: 'week', 'month', 'year', 'all'
    """
    today = datetime.now().date()
    
    if period == 'week':
        start_date = (today - timedelta(days=7)).isoformat()
    elif period == 'month':
        start_date = (today - timedelta(days=30)).isoformat()
    elif period == 'year':
        start_date = (today - timedelta(days=365)).isoformat()
    else:  # 'all'
        start_date = '2020-01-01'  # Far past date
    
    end_date = today.isoformat()
    
    return start_date, end_date


# =====================================================
# GENERAL STATISTICS ROUTES
# =====================================================

@bp.route('/statistics/overview/<int:user_id>', methods=['GET'])
def get_user_statistics_overview(user_id):
    """
    Get comprehensive statistics overview for a user
    Query params:
        - period: 'week', 'month', 'year', 'all' (default: 'month')
    """
    try:
        period = request.args.get('period', 'month')
        start_date, end_date = get_date_range(period)
        
        # Try Supabase first
        if supabase:
            try:
                # Get total medicines tracked
                medicines_response = supabase.table('medicine_tracking')\
                    .select('medicine_track_id', count='exact')\
                    .eq('user_id', user_id)\
                    .execute()
                
                total_medicines = medicines_response.count if medicines_response.count else 0
                
                # Get occurrences in date range
                occurrences_response = supabase.table('occurrence_plan')\
                    .select('*, medicine_plan!inner(user_id)', count='exact')\
                    .eq('medicine_plan.user_id', user_id)\
                    .gte('date', start_date)\
                    .lte('date', end_date)\
                    .execute()
                
                total_doses = occurrences_response.count if occurrences_response.count else 0
                
                # Count taken doses
                taken_response = supabase.table('occurrence_plan')\
                    .select('id', count='exact')\
                    .eq('medicine_plan.user_id', user_id)\
                    .gte('date', start_date)\
                    .lte('date', end_date)\
                    .eq('is_taken', 1)\
                    .execute()
                
                taken_doses = taken_response.count if taken_response.count else 0
                
                # Get intake logs
                logs_response = supabase.table('medication_intake_log')\
                    .select('*, medicine_tracking!inner(user_id)', count='exact')\
                    .eq('medicine_tracking.user_id', user_id)\
                    .gte('scheduled_date', start_date)\
                    .lte('scheduled_date', end_date)\
                    .execute()
                
                total_logs = logs_response.count if logs_response.count else 0
                
                # Count by status
                taken_logs = sum(1 for log in (logs_response.data or []) if log.get('status') == 'taken')
                missed_logs = sum(1 for log in (logs_response.data or []) if log.get('status') == 'missed')
                skipped_logs = sum(1 for log in (logs_response.data or []) if log.get('status') == 'skipped')
                
                adherence_rate = calculate_adherence_rate(taken_doses, total_doses)
                
                return jsonify({
                    'success': True,
                    'period': period,
                    'start_date': start_date,
                    'end_date': end_date,
                    'statistics': {
                        'total_medicines': total_medicines,
                        'total_doses_scheduled': total_doses,
                        'doses_taken': taken_doses,
                        'doses_missed': total_doses - taken_doses,
                        'adherence_rate': adherence_rate,
                        'intake_logs': {
                            'total': total_logs,
                            'taken': taken_logs,
                            'missed': missed_logs,
                            'skipped': skipped_logs
                        }
                    },
                    'source': 'remote'
                }), 200
                
            except Exception as supabase_error:
                print(f"⚠️  Supabase get statistics failed: {supabase_error}")
        
        # Fallback to local database
        # Get total medicines
        medicine_rows = execute_query(
            "SELECT COUNT(*) as count FROM medicine_tracking WHERE user_id = ?",
            (user_id,)
        )
        total_medicines = medicine_rows[0]['count'] if medicine_rows else 0
        
        # Get occurrences in date range
        occurrence_rows = execute_query(
            """
            SELECT COUNT(*) as count 
            FROM occurrence_plan op
            JOIN medicine_plan mp ON op.plan_id = mp.plan_id
            WHERE mp.user_id = ? AND op.date >= ? AND op.date <= ?
            """,
            (user_id, start_date, end_date)
        )
        total_doses = occurrence_rows[0]['count'] if occurrence_rows else 0
        
        # Count taken doses
        taken_rows = execute_query(
            """
            SELECT COUNT(*) as count 
            FROM occurrence_plan op
            JOIN medicine_plan mp ON op.plan_id = mp.plan_id
            WHERE mp.user_id = ? AND op.date >= ? AND op.date <= ? AND op.is_taken = 1
            """,
            (user_id, start_date, end_date)
        )
        taken_doses = taken_rows[0]['count'] if taken_rows else 0
        
        # Get intake logs
        log_rows = execute_query(
            """
            SELECT status, COUNT(*) as count
            FROM medication_intake_log mil
            JOIN medicine_tracking mt ON mil.medicine_track_id = mt.medicine_track_id
            WHERE mt.user_id = ? AND mil.scheduled_date >= ? AND mil.scheduled_date <= ?
            GROUP BY status
            """,
            (user_id, start_date, end_date)
        )
        
        taken_logs = 0
        missed_logs = 0
        skipped_logs = 0
        
        for row in log_rows:
            if row['status'] == 'taken':
                taken_logs = row['count']
            elif row['status'] == 'missed':
                missed_logs = row['count']
            elif row['status'] == 'skipped':
                skipped_logs = row['count']
        
        total_logs = taken_logs + missed_logs + skipped_logs
        adherence_rate = calculate_adherence_rate(taken_doses, total_doses)
        
        return jsonify({
            'success': True,
            'period': period,
            'start_date': start_date,
            'end_date': end_date,
            'statistics': {
                'total_medicines': total_medicines,
                'total_doses_scheduled': total_doses,
                'doses_taken': taken_doses,
                'doses_missed': total_doses - taken_doses,
                'adherence_rate': adherence_rate,
                'intake_logs': {
                    'total': total_logs,
                    'taken': taken_logs,
                    'missed': missed_logs,
                    'skipped': skipped_logs
                }
            },
            'source': 'local'
        }), 200
        
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@bp.route('/statistics/medicine/<int:medicine_track_id>', methods=['GET'])
def get_medicine_statistics(medicine_track_id):
    """
    Get statistics for a specific medicine
    Query params:
        - period: 'week', 'month', 'year', 'all' (default: 'month')
    """
    try:
        period = request.args.get('period', 'month')
        start_date, end_date = get_date_range(period)
        
        # Try Supabase first
        if supabase:
            try:
                # Get medicine details
                medicine_response = supabase.table('medicine_tracking')\
                    .select('*')\
                    .eq('medicine_track_id', medicine_track_id)\
                    .single()\
                    .execute()
                
                if not medicine_response.data:
                    return jsonify({'success': False, 'error': 'Medicine not found'}), 404
                
                medicine = medicine_response.data
                
                # Get plans for this medicine
                plans_response = supabase.table('medicine_plan')\
                    .select('plan_id')\
                    .eq('medicine_track_id', medicine_track_id)\
                    .execute()
                
                plan_ids = [p['plan_id'] for p in (plans_response.data or [])]
                
                if not plan_ids:
                    return jsonify({
                        'success': True,
                        'medicine': medicine,
                        'statistics': {
                            'total_doses_scheduled': 0,
                            'doses_taken': 0,
                            'doses_missed': 0,
                            'adherence_rate': 0.0
                        },
                        'source': 'remote'
                    }), 200
                
                # Get occurrences for these plans
                occurrences_response = supabase.table('occurrence_plan')\
                    .select('*', count='exact')\
                    .in_('plan_id', plan_ids)\
                    .gte('date', start_date)\
                    .lte('date', end_date)\
                    .execute()
                
                total_doses = occurrences_response.count if occurrences_response.count else 0
                
                # Count taken doses
                taken_response = supabase.table('occurrence_plan')\
                    .select('id', count='exact')\
                    .in_('plan_id', plan_ids)\
                    .gte('date', start_date)\
                    .lte('date', end_date)\
                    .eq('is_taken', 1)\
                    .execute()
                
                taken_doses = taken_response.count if taken_response.count else 0
                
                adherence_rate = calculate_adherence_rate(taken_doses, total_doses)
                
                return jsonify({
                    'success': True,
                    'medicine': medicine,
                    'period': period,
                    'statistics': {
                        'total_doses_scheduled': total_doses,
                        'doses_taken': taken_doses,
                        'doses_missed': total_doses - taken_doses,
                        'adherence_rate': adherence_rate
                    },
                    'source': 'remote'
                }), 200
                
            except Exception as supabase_error:
                print(f"⚠️  Supabase get medicine statistics failed: {supabase_error}")
        
        # Fallback to local database
        medicine_rows = execute_query(
            "SELECT * FROM medicine_tracking WHERE medicine_track_id = ?",
            (medicine_track_id,)
        )
        
        if not medicine_rows:
            return jsonify({'success': False, 'error': 'Medicine not found'}), 404
        
        medicine = dict(medicine_rows[0])
        
        # Get occurrences
        occurrence_rows = execute_query(
            """
            SELECT COUNT(*) as count 
            FROM occurrence_plan op
            JOIN medicine_plan mp ON op.plan_id = mp.plan_id
            WHERE mp.medicine_track_id = ? AND op.date >= ? AND op.date <= ?
            """,
            (medicine_track_id, start_date, end_date)
        )
        total_doses = occurrence_rows[0]['count'] if occurrence_rows else 0
        
        # Count taken doses
        taken_rows = execute_query(
            """
            SELECT COUNT(*) as count 
            FROM occurrence_plan op
            JOIN medicine_plan mp ON op.plan_id = mp.plan_id
            WHERE mp.medicine_track_id = ? AND op.date >= ? AND op.date <= ? AND op.is_taken = 1
            """,
            (medicine_track_id, start_date, end_date)
        )
        taken_doses = taken_rows[0]['count'] if taken_rows else 0
        
        adherence_rate = calculate_adherence_rate(taken_doses, total_doses)
        
        return jsonify({
            'success': True,
            'medicine': medicine,
            'period': period,
            'statistics': {
                'total_doses_scheduled': total_doses,
                'doses_taken': taken_doses,
                'doses_missed': total_doses - taken_doses,
                'adherence_rate': adherence_rate
            },
            'source': 'local'
        }), 200
        
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@bp.route('/statistics/daily/<int:user_id>', methods=['GET'])
def get_daily_statistics(user_id):
    """
    Get daily statistics for a user
    Query params:
        - date: specific date (default: today)
    """
    try:
        date = request.args.get('date', datetime.now().date().isoformat())
        
        # Try Supabase first
        if supabase:
            try:
                # Get occurrences for the date
                occurrences_response = supabase.table('occurrence_plan')\
                    .select('*, medicine_plan!inner(user_id, medicine_tracking(name))')\
                    .eq('medicine_plan.user_id', user_id)\
                    .eq('date', date)\
                    .execute()
                
                occurrences = occurrences_response.data or []
                total_doses = len(occurrences)
                taken_doses = sum(1 for occ in occurrences if occ.get('is_taken') == 1)
                
                adherence_rate = calculate_adherence_rate(taken_doses, total_doses)
                
                return jsonify({
                    'success': True,
                    'date': date,
                    'statistics': {
                        'total_doses_scheduled': total_doses,
                        'doses_taken': taken_doses,
                        'doses_missed': total_doses - taken_doses,
                        'adherence_rate': adherence_rate
                    },
                    'occurrences': occurrences,
                    'source': 'remote'
                }), 200
                
            except Exception as supabase_error:
                print(f"⚠️  Supabase get daily statistics failed: {supabase_error}")
        
        # Fallback to local database
        occurrence_rows = execute_query(
            """
            SELECT op.*, mp.medicine_track_id, mt.name
            FROM occurrence_plan op
            JOIN medicine_plan mp ON op.plan_id = mp.plan_id
            JOIN medicine_tracking mt ON mp.medicine_track_id = mt.medicine_track_id
            WHERE mp.user_id = ? AND op.date = ?
            """,
            (user_id, date)
        )
        
        occurrences = [dict(row) for row in occurrence_rows]
        total_doses = len(occurrences)
        taken_doses = sum(1 for occ in occurrences if occ.get('is_taken') == 1)
        
        adherence_rate = calculate_adherence_rate(taken_doses, total_doses)
        
        return jsonify({
            'success': True,
            'date': date,
            'statistics': {
                'total_doses_scheduled': total_doses,
                'doses_taken': taken_doses,
                'doses_missed': total_doses - taken_doses,
                'adherence_rate': adherence_rate
            },
            'occurrences': occurrences,
            'source': 'local'
        }), 200
        
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@bp.route('/statistics/weekly/<int:user_id>', methods=['GET'])
def get_weekly_statistics(user_id):
    """
    Get week-by-week statistics for a user (last 4 weeks)
    """
    try:
        today = datetime.now().date()
        weeks_data = []
        
        for week_num in range(4):
            week_end = today - timedelta(days=week_num * 7)
            week_start = week_end - timedelta(days=6)
            
            # Try Supabase first
            if supabase:
                try:
                    occurrences_response = supabase.table('occurrence_plan')\
                        .select('is_taken', count='exact')\
                        .eq('medicine_plan.user_id', user_id)\
                        .gte('date', week_start.isoformat())\
                        .lte('date', week_end.isoformat())\
                        .execute()
                    
                    total_doses = occurrences_response.count if occurrences_response.count else 0
                    
                    taken_response = supabase.table('occurrence_plan')\
                        .select('id', count='exact')\
                        .eq('medicine_plan.user_id', user_id)\
                        .gte('date', week_start.isoformat())\
                        .lte('date', week_end.isoformat())\
                        .eq('is_taken', 1)\
                        .execute()
                    
                    taken_doses = taken_response.count if taken_response.count else 0
                    
                except Exception:
                    # Fallback to local
                    occurrence_rows = execute_query(
                        """
                        SELECT COUNT(*) as count 
                        FROM occurrence_plan op
                        JOIN medicine_plan mp ON op.plan_id = mp.plan_id
                        WHERE mp.user_id = ? AND op.date >= ? AND op.date <= ?
                        """,
                        (user_id, week_start.isoformat(), week_end.isoformat())
                    )
                    total_doses = occurrence_rows[0]['count'] if occurrence_rows else 0
                    
                    taken_rows = execute_query(
                        """
                        SELECT COUNT(*) as count 
                        FROM occurrence_plan op
                        JOIN medicine_plan mp ON op.plan_id = mp.plan_id
                        WHERE mp.user_id = ? AND op.date >= ? AND op.date <= ? AND op.is_taken = 1
                        """,
                        (user_id, week_start.isoformat(), week_end.isoformat())
                    )
                    taken_doses = taken_rows[0]['count'] if taken_rows else 0
            else:
                # Local database
                occurrence_rows = execute_query(
                    """
                    SELECT COUNT(*) as count 
                    FROM occurrence_plan op
                    JOIN medicine_plan mp ON op.plan_id = mp.plan_id
                    WHERE mp.user_id = ? AND op.date >= ? AND op.date <= ?
                    """,
                    (user_id, week_start.isoformat(), week_end.isoformat())
                )
                total_doses = occurrence_rows[0]['count'] if occurrence_rows else 0
                
                taken_rows = execute_query(
                    """
                    SELECT COUNT(*) as count 
                    FROM occurrence_plan op
                    JOIN medicine_plan mp ON op.plan_id = mp.plan_id
                    WHERE mp.user_id = ? AND op.date >= ? AND op.date <= ? AND op.is_taken = 1
                    """,
                    (user_id, week_start.isoformat(), week_end.isoformat())
                )
                taken_doses = taken_rows[0]['count'] if taken_rows else 0
            
            adherence_rate = calculate_adherence_rate(taken_doses, total_doses)
            
            weeks_data.append({
                'week_start': week_start.isoformat(),
                'week_end': week_end.isoformat(),
                'week_number': week_num + 1,
                'total_doses': total_doses,
                'taken_doses': taken_doses,
                'missed_doses': total_doses - taken_doses,
                'adherence_rate': adherence_rate
            })
        
        return jsonify({
            'success': True,
            'weeks': weeks_data,
            'source': 'remote' if supabase else 'local'
        }), 200
        
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@bp.route('/statistics/monthly/<int:user_id>', methods=['GET'])
def get_monthly_statistics(user_id):
    """
    Get month-by-month statistics for a user (last 6 months)
    """
    try:
        today = datetime.now().date()
        months_data = []
        
        for month_offset in range(6):
            # Calculate month boundaries
            if month_offset == 0:
                month_end = today
                month_start = today.replace(day=1)
            else:
                temp_date = today.replace(day=1) - timedelta(days=1)
                for _ in range(month_offset - 1):
                    temp_date = temp_date.replace(day=1) - timedelta(days=1)
                month_start = temp_date.replace(day=1)
                # Get last day of month
                next_month = month_start.replace(day=28) + timedelta(days=4)
                month_end = next_month - timedelta(days=next_month.day)
            
            # Try Supabase first
            if supabase:
                try:
                    occurrences_response = supabase.table('occurrence_plan')\
                        .select('is_taken', count='exact')\
                        .eq('medicine_plan.user_id', user_id)\
                        .gte('date', month_start.isoformat())\
                        .lte('date', month_end.isoformat())\
                        .execute()
                    
                    total_doses = occurrences_response.count if occurrences_response.count else 0
                    
                    taken_response = supabase.table('occurrence_plan')\
                        .select('id', count='exact')\
                        .eq('medicine_plan.user_id', user_id)\
                        .gte('date', month_start.isoformat())\
                        .lte('date', month_end.isoformat())\
                        .eq('is_taken', 1)\
                        .execute()
                    
                    taken_doses = taken_response.count if taken_response.count else 0
                    
                except Exception:
                    # Fallback to local
                    occurrence_rows = execute_query(
                        """
                        SELECT COUNT(*) as count 
                        FROM occurrence_plan op
                        JOIN medicine_plan mp ON op.plan_id = mp.plan_id
                        WHERE mp.user_id = ? AND op.date >= ? AND op.date <= ?
                        """,
                        (user_id, month_start.isoformat(), month_end.isoformat())
                    )
                    total_doses = occurrence_rows[0]['count'] if occurrence_rows else 0
                    
                    taken_rows = execute_query(
                        """
                        SELECT COUNT(*) as count 
                        FROM occurrence_plan op
                        JOIN medicine_plan mp ON op.plan_id = mp.plan_id
                        WHERE mp.user_id = ? AND op.date >= ? AND op.date <= ? AND op.is_taken = 1
                        """,
                        (user_id, month_start.isoformat(), month_end.isoformat())
                    )
                    taken_doses = taken_rows[0]['count'] if taken_rows else 0
            else:
                # Local database
                occurrence_rows = execute_query(
                    """
                    SELECT COUNT(*) as count 
                    FROM occurrence_plan op
                    JOIN medicine_plan mp ON op.plan_id = mp.plan_id
                    WHERE mp.user_id = ? AND op.date >= ? AND op.date <= ?
                    """,
                    (user_id, month_start.isoformat(), month_end.isoformat())
                )
                total_doses = occurrence_rows[0]['count'] if occurrence_rows else 0
                
                taken_rows = execute_query(
                    """
                    SELECT COUNT(*) as count 
                    FROM occurrence_plan op
                    JOIN medicine_plan mp ON op.plan_id = mp.plan_id
                    WHERE mp.user_id = ? AND op.date >= ? AND op.date <= ? AND op.is_taken = 1
                    """,
                    (user_id, month_start.isoformat(), month_end.isoformat())
                )
                taken_doses = taken_rows[0]['count'] if taken_rows else 0
            
            adherence_rate = calculate_adherence_rate(taken_doses, total_doses)
            
            months_data.append({
                'month_start': month_start.isoformat(),
                'month_end': month_end.isoformat(),
                'month_name': month_start.strftime('%B %Y'),
                'total_doses': total_doses,
                'taken_doses': taken_doses,
                'missed_doses': total_doses - taken_doses,
                'adherence_rate': adherence_rate
            })
        
        return jsonify({
            'success': True,
            'months': months_data,
            'source': 'remote' if supabase else 'local'
        }), 200
        
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@bp.route('/statistics/adherence-trend/<int:user_id>', methods=['GET'])
def get_adherence_trend(user_id):
    """
    Get adherence trend over last 30 days (day by day)
    """
    try:
        end_date = datetime.now().date()
        start_date = end_date - timedelta(days=29)
        
        daily_stats = []
        
        current_date = start_date
        while current_date <= end_date:
            date_str = current_date.isoformat()
            
            # Try Supabase first
            if supabase:
                try:
                    occurrences_response = supabase.table('occurrence_plan')\
                        .select('is_taken', count='exact')\
                        .eq('medicine_plan.user_id', user_id)\
                        .eq('date', date_str)\
                        .execute()
                    
                    total_doses = occurrences_response.count if occurrences_response.count else 0
                    
                    taken_response = supabase.table('occurrence_plan')\
                        .select('id', count='exact')\
                        .eq('medicine_plan.user_id', user_id)\
                        .eq('date', date_str)\
                        .eq('is_taken', 1)\
                        .execute()
                    
                    taken_doses = taken_response.count if taken_response.count else 0
                    
                except Exception:
                    # Fallback to local
                    occurrence_rows = execute_query(
                        """
                        SELECT COUNT(*) as count 
                        FROM occurrence_plan op
                        JOIN medicine_plan mp ON op.plan_id = mp.plan_id
                        WHERE mp.user_id = ? AND op.date = ?
                        """,
                        (user_id, date_str)
                    )
                    total_doses = occurrence_rows[0]['count'] if occurrence_rows else 0
                    
                    taken_rows = execute_query(
                        """
                        SELECT COUNT(*) as count 
                        FROM occurrence_plan op
                        JOIN medicine_plan mp ON op.plan_id = mp.plan_id
                        WHERE mp.user_id = ? AND op.date = ? AND op.is_taken = 1
                        """,
                        (user_id, date_str)
                    )
                    taken_doses = taken_rows[0]['count'] if taken_rows else 0
            else:
                # Local database
                occurrence_rows = execute_query(
                    """
                    SELECT COUNT(*) as count 
                    FROM occurrence_plan op
                    JOIN medicine_plan mp ON op.plan_id = mp.plan_id
                    WHERE mp.user_id = ? AND op.date = ?
                    """,
                    (user_id, date_str)
                )
                total_doses = occurrence_rows[0]['count'] if occurrence_rows else 0
                
                taken_rows = execute_query(
                    """
                    SELECT COUNT(*) as count 
                    FROM occurrence_plan op
                    JOIN medicine_plan mp ON op.plan_id = mp.plan_id
                    WHERE mp.user_id = ? AND op.date = ? AND op.is_taken = 1
                    """,
                    (user_id, date_str)
                )
                taken_doses = taken_rows[0]['count'] if taken_rows else 0
            
            adherence_rate = calculate_adherence_rate(taken_doses, total_doses)
            
            daily_stats.append({
                'date': date_str,
                'total_doses': total_doses,
                'taken_doses': taken_doses,
                'adherence_rate': adherence_rate
            })
            
            current_date += timedelta(days=1)
        
        return jsonify({
            'success': True,
            'start_date': start_date.isoformat(),
            'end_date': end_date.isoformat(),
            'daily_trend': daily_stats,
            'source': 'remote' if supabase else 'local'
        }), 200
        
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500
