CREATE TABLE reminders (
    reminder_id VARCHAR(36) PRIMARY KEY,
    user_medicine_id VARCHAR(36) NOT NULL,
    reminder_time TIME NOT NULL,
    is_enabled BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (user_medicine_id) REFERENCES user_medicines(user_medicine_id) ON DELETE CASCADE
);