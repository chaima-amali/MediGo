"""Initialize local SQLite database with schema"""
import sqlite3

# SQLite version of the schema (modified from PostgreSQL)
schema = """
-- USERS TABLE
CREATE TABLE IF NOT EXISTS users (
    user_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT,
    email TEXT UNIQUE,
    phone TEXT,
    password TEXT,
    gender TEXT,
    dob TEXT,
    latitude REAL,
    longitude REAL,
    location_name TEXT,
    premium TEXT,
    fcm_token TEXT,
    notifications_enabled INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- MEDICINE TABLE
CREATE TABLE IF NOT EXISTS medicine (
    medicine_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    generic_name TEXT,
    dosage TEXT,
    form TEXT,
    manufacturer TEXT,
    description TEXT,
    requires_prescription INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- MEDICINE TRACKING TABLE
CREATE TABLE IF NOT EXISTS medicine_tracking (
    medicine_track_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    name TEXT,
    type TEXT,
    dosage TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- USER MEDICINES TABLE
CREATE TABLE IF NOT EXISTS user_medicines (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    medicine_id INTEGER NOT NULL,
    medicine_name TEXT,
    dosage TEXT,
    frequency TEXT,
    notes TEXT,
    is_active INTEGER DEFAULT 1,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (medicine_id) REFERENCES medicine(medicine_id) ON DELETE CASCADE
);

-- MEDICINE PLAN TABLE
CREATE TABLE IF NOT EXISTS medicine_plan (
    plan_id INTEGER PRIMARY KEY AUTOINCREMENT,
    medicine_track_id INTEGER,
    user_id INTEGER,
    importance TEXT,
    start_date TEXT,
    end_date TEXT,
    frequency_type TEXT,
    interval_days INTEGER,
    weekdays TEXT,
    month_days TEXT,
    custom_dates TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (medicine_track_id) REFERENCES medicine_tracking(medicine_track_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- OCCURRENCE PLAN TABLE
CREATE TABLE IF NOT EXISTS occurrence_plan (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    plan_id INTEGER,
    date TEXT,
    time TEXT,
    is_taken INTEGER DEFAULT 0,
    day_of_week TEXT,
    interval_value INTEGER,
    interval_unit TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (plan_id) REFERENCES medicine_plan(plan_id) ON DELETE CASCADE
);

-- NOTIFICATION TABLE
CREATE TABLE IF NOT EXISTS notification (
    notification_id INTEGER PRIMARY KEY AUTOINCREMENT,
    occurrence_id INTEGER,
    sent_at TEXT,
    is_sent INTEGER DEFAULT 0,
    notification_type TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (occurrence_id) REFERENCES occurrence_plan(id) ON DELETE CASCADE
);

-- MEDICATION INTAKE LOG TABLE
CREATE TABLE IF NOT EXISTS medication_intake_log (
    log_id INTEGER PRIMARY KEY AUTOINCREMENT,
    occurrence_id INTEGER,
    medicine_track_id INTEGER,
    scheduled_date TEXT,
    scheduled_time TEXT,
    actual_time TEXT,
    status TEXT,
    dosage TEXT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (occurrence_id) REFERENCES occurrence_plan(id) ON DELETE CASCADE,
    FOREIGN KEY (medicine_track_id) REFERENCES medicine_tracking(medicine_track_id) ON DELETE CASCADE
);

-- DAILY DOSAGE CHECKING TABLE
CREATE TABLE IF NOT EXISTS daily_dosage_checking (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    plan_id INTEGER,
    check_date TEXT,
    total_dosage REAL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (plan_id) REFERENCES medicine_plan(plan_id) ON DELETE CASCADE
);
"""

def init_database():
    """Initialize the local SQLite database"""
    conn = sqlite3.connect('medigo.db')
    cursor = conn.cursor()
    
    # Execute schema
    cursor.executescript(schema)
    
    conn.commit()
    conn.close()
    
    print("✅ Local database initialized (users, medicine, medicine_tracking, medicine_plan, occurrence_plan, notification, medication_intake_log, daily_dosage_checking, ...)")

if __name__ == '__main__':
    init_database()
