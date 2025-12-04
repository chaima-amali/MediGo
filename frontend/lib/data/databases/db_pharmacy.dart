 class DBPharmacyTable {
 static String table = 'pharmacy';
 static String sql_code = '''
 CREATE TABLE pharmacy (
 pharmacy_id INTEGER PRIMARY KEY AUTOINCREMENT,
 name TEXT,
 location TEXT,
 phone TEXT,
 opening_hours TEXT,
 rating REAL
 ) ''';
 }