class DBOccurrencePlanTable {
  static String table = 'occurrence_plan';
  static String sql_code = '''
    CREATE TABLE occurrence_plan (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      plan_id INTEGER,
      date TEXT,
      time TEXT,
      is_taken INTEGER DEFAULT 0,
      day_of_week TEXT,
      interval_value INTEGER,
      interval_unit TEXT
    )
  ''';
}

 