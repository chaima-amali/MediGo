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