 class DBReservationTable {
 static String table = 'reservation';
 static String sql_code = '''
 CREATE TABLE reservation (
 reservation_id INTEGER PRIMARY KEY AUTOINCREMENT,
 medicine_find_id INTEGER,
 user_id INTEGER,
 day TEXT,
 time TEXT,
 quantity INTEGER,
 status TEXT
 )
 ''';
 }
