class DBPharmacyMedicineTable {
 static String table = 'pharmacy_medicine';
 static String sql_code = '''
 CREATE TABLE pharmacy_medicine (
 id INTEGER PRIMARY KEY AUTOINCREMENT,
 pharmacy_id INTEGER,
 medicine_find_id INTEGER,
 price REAL,
 stock INTEGER
 )
 ''';
 }
