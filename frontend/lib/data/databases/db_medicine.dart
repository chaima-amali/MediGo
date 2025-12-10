class DBMedicineTable {
  static String table = 'medicine';
  static String sql_code = '''
  CREATE TABLE medicine (
    medicine_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    generic_name TEXT,
    dosage TEXT,
    form TEXT,
    manufacturer TEXT,
    description TEXT,
    requires_prescription INTEGER DEFAULT 0,
    created_at TEXT
  )
  ''';
}