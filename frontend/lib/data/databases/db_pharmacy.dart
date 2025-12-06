 class DBPharmacyTable {
 static String table = 'pharmacy';
 static String sql_code = '''
 CREATE TABLE pharmacy (
 pharmacy_id INTEGER PRIMARY KEY AUTOINCREMENT,
 name TEXT,
 latitude REAL,
 longitude REAL,
 phone TEXT,
 opening_hours TEXT,
 rating REAL
 ) ''';
 }