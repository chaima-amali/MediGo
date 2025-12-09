CREATE TABLE user_medicines (
    user_medicine_id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    medicine_id VARCHAR(36) NOT NULL,
    dosage VARCHAR(50) NOT NULL,
    unit VARCHAR(20) NOT NULL, -- mg, ml, pills, etc.
    frequency VARCHAR(50) NOT NULL, -- daily, twice daily, weekly, etc.
    times_per_day INT,
    importance VARCHAR(20), -- high, medium, low
    start_date DATE NOT NULL,
    end_date DATE,
    additional_notes TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (medicine_id) REFERENCES medicines(medicine_id)
);