class DBMedicinePlanTable {
  static String table = 'medicine_plan';
  static String sql_code = '''
	CREATE TABLE medicine_plan (
		plan_id INTEGER PRIMARY KEY AUTOINCREMENT,
		medicine_track_id INTEGER,
		user_id INTEGER,
		importance TEXT,
		start_date TEXT,
		end_date TEXT,
		frequency_type TEXT,
		interval_days INTEGER,
		weekdays TEXT,
		month_days TEXT,
		custom_dates TEXT
	)
	''';
}
