class DBMedicationIntakeLogTable {
  static String table = 'medication_intake_log';
  static String sql_code = '''
    CREATE TABLE medication_intake_log (
      log_id INTEGER PRIMARY KEY AUTOINCREMENT,
      occurrence_id INTEGER,
      medicine_track_id INTEGER,
      scheduled_date TEXT NOT NULL,
      scheduled_time TEXT NOT NULL,
      actual_time TEXT,
      status TEXT NOT NULL,
      dosage TEXT,
      notes TEXT,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (occurrence_id) REFERENCES occurrence_plan(id) ON DELETE CASCADE,
      FOREIGN KEY (medicine_track_id) REFERENCES medicine_tracking(medicine_track_id) ON DELETE CASCADE
    )
  ''';
}
