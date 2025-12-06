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