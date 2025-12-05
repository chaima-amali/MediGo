 class DBDailyDosageCheckingTable {
 static String table = 'daily_dosage_checking';
 static String sql_code = '''
 CREATE TABLE daily_dosage_checking (
 dc_id INTEGER PRIMARY KEY AUTOINCREMENT,
 plan_id INTEGER,
 dose_date TEXT,
 dose_time TEXT,
 status TEXT,
 taken_at TEXT
 )
 ''';
 }
