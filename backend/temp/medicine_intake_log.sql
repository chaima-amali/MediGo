CREATE TABLE medicine_intake_log (
    log_id VARCHAR(36) PRIMARY KEY,
    user_medicine_id VARCHAR(36) NOT NULL,
    scheduled_time TIMESTAMP NOT NULL,
    actual_time TIMESTAMP,
    status VARCHAR(20) NOT NULL, -- taken, missed, skipped
    notes TEXT,
    FOREIGN KEY (user_medicine_id) REFERENCES user_medicines(user_medicine_id) ON DELETE CASCADE
);