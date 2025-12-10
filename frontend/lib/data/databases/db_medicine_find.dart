// User search history for restock notifications (premium feature)
class DBMedicineFindTable {
  static String table = 'medicine_search_history';
  static String sql_code = '''
  CREATE TABLE medicine_search_history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    medicine_id INTEGER NOT NULL,
    searched_at TEXT,
    notify_restock INTEGER DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES user(user_id),
    FOREIGN KEY (medicine_id) REFERENCES medicine(medicine_id)
  )
  ''';
}
