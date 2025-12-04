class DBOccurrencePlanTable {
  static String table = 'occurrence_plan';
  static String sql_code = '''
    CREATE TABLE occurrence_plan (
      occurrence_id INTEGER PRIMARY KEY AUTOINCREMENT,
      plan_id INTEGER,
      day_of_week TEXT,
      time TEXT,
      interval_value INTEGER,
      interval_unit TEXT
    )
  ''';
}