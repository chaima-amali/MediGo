class DBUserTable {
  static String table = 'user';
  static String sql_code = '''
 CREATE TABLE user (
 user_id INTEGER PRIMARY KEY AUTOINCREMENT,
 name TEXT,
 email TEXT,
 phone TEXT,
 password TEXT,
 gender TEXT,
 dob TEXT,
 latitude REAL,
 longitude REAL,
 location_name TEXT,
 premium INTEGER DEFAULT 0,
 notifications_enabled INTEGER DEFAULT 1,
 fcm_token TEXT
 )
 ''';
}
