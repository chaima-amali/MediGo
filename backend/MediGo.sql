CREATE TABLE users (
    user_id VARCHAR(36) PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone_number VARCHAR(20),
    date_of_birth DATE,
    password_hash VARCHAR(255) NOT NULL,
    profile_image_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

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

CREATE TABLE restock_notifications (
    notification_id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    medicine_id VARCHAR(36) NOT NULL,
    pharmacy_id VARCHAR(36),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (medicine_id) REFERENCES medicines(medicine_id),
    FOREIGN KEY (pharmacy_id) REFERENCES pharmacies(pharmacy_id)
);

CREATE TABLE reservations (
    reservation_id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    pharmacy_id VARCHAR(36) NOT NULL,
    medicine_id VARCHAR(36) NOT NULL,
    quantity INT NOT NULL,
    pickup_date DATE NOT NULL,
    pickup_time TIME NOT NULL,
    status VARCHAR(20) DEFAULT 'pending', -- pending, confirmed, completed, cancelled
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (pharmacy_id) REFERENCES pharmacies(pharmacy_id),
    FOREIGN KEY (medicine_id) REFERENCES medicines(medicine_id)
);

CREATE TABLE reminders (
    reminder_id VARCHAR(36) PRIMARY KEY,
    user_medicine_id VARCHAR(36) NOT NULL,
    reminder_time TIME NOT NULL,
    is_enabled BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (user_medicine_id) REFERENCES user_medicines(user_medicine_id) ON DELETE CASCADE
);


CREATE TABLE pharmacy_inventory (
    inventory_id VARCHAR(36) PRIMARY KEY,
    pharmacy_id VARCHAR(36) NOT NULL,
    medicine_id VARCHAR(36) NOT NULL,
    in_stock BIT DEFAULT 1,
    quantity INT,
    price DECIMAL(10, 2),
    last_updated DATETIME2 DEFAULT (SYSUTCDATETIME()),
    FOREIGN KEY (pharmacy_id) REFERENCES pharmacies(pharmacy_id) ON DELETE CASCADE,
    FOREIGN KEY (medicine_id) REFERENCES medicines(medicine_id)
);

CREATE TABLE pharmacies (
    pharmacy_id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address TEXT NOT NULL,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    phone_number VARCHAR(20),
    opening_hours TEXT,
    rating DECIMAL(2, 1),
    total_reviews INT DEFAULT 0,
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE notifications (
    notification_id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    title VARCHAR(100) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50), -- reminder, restock, general
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE medicines (
    medicine_id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    generic_name VARCHAR(100),
    medicine_type VARCHAR(50), -- tablet, capsule, syrup, injection, etc.
    manufacturer VARCHAR(100),
    description TEXT,
    common_dosages VARCHAR(100),
    active_ingredient VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE medicine_intake_log (
    log_id VARCHAR(36) PRIMARY KEY,
    user_medicine_id VARCHAR(36) NOT NULL,
    scheduled_time TIMESTAMP NOT NULL,
    actual_time TIMESTAMP,
    status VARCHAR(20) NOT NULL, -- taken, missed, skipped
    notes TEXT,
    FOREIGN KEY (user_medicine_id) REFERENCES user_medicines(user_medicine_id) ON DELETE CASCADE
);

CREATE TABLE medical_profiles (
    profile_id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    allergies TEXT,
    medical_conditions TEXT,
    blood_type VARCHAR(5),
    emergency_contact_name VARCHAR(100),
    emergency_contact_phone VARCHAR(20),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);