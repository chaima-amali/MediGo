
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