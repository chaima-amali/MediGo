class DBMedicineFindTable {
 static String table = 'medicine_find';
 static String sql_code = '''
 CREATE TABLE medicine_find (
 medicine_find_id INTEGER PRIMARY KEY AUTOINCREMENT,
 user_id INTEGER,
 name TEXT,
 timestamp TEXT
 )
 ''';
 }