class DBMedicineTrackingTable {
 static String table = 'medicine_tracking';
 static String sql_code = '''
 CREATE TABLE medicine_tracking (
 medicine_track_id INTEGER PRIMARY KEY AUTOINCREMENT,
 user_id INTEGER,
 name TEXT,
 type TEXT,
 dosage TEXT
)
 ''';
 }
