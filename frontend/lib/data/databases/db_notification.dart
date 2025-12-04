 class DBNotificationTable {
 static String table = 'notification';
 static String sql_code = '''
 CREATE TABLE notification (
 notification_id INTEGER PRIMARY KEY AUTOINCREMENT,
 user_id INTEGER,
 plan_id INTEGER,
 reservation_id INTEGER,
 medicine_find_id INTEGER,
 dc_id INTEGER,
 datetime TEXT,
 title TEXT,
 message TEXT,
 type TEXT,
 is_read INTEGER,
 created_at TEXT
 )
 ''';
 }