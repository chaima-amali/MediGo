// Pharmacy inventory - which medicines each pharmacy has
class DBPharmacyMedicineTable {
  static String table = 'pharmacy_medicine';
  static String sql_code = '''
  CREATE TABLE pharmacy_medicine (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    pharmacy_id INTEGER NOT NULL,
    medicine_id INTEGER NOT NULL,
    price REAL NOT NULL,
    stock INTEGER DEFAULT 0,
    last_updated TEXT,
    FOREIGN KEY (pharmacy_id) REFERENCES pharmacy(pharmacy_id),
    FOREIGN KEY (medicine_id) REFERENCES medicine(medicine_id)
  )
  ''';
}
