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