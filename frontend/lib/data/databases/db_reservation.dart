 class DBReservationTable {
 static String table = 'reservation';
 static String sql_code = '''
 CREATE TABLE reservation (
 reservation_id INTEGER PRIMARY KEY AUTOINCREMENT,
 medicine_find_id INTEGER,
 user_id INTEGER,
 pharmacy_id INTEGER,
 medicine_name TEXT,
 day TEXT,
 time TEXT,
 quantity INTEGER,
 status TEXT,
 created_at TEXT
 )
 ''';
 }
