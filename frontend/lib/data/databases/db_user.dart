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
 premium TEXT
 )
 ''';
 }