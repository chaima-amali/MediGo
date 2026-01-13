-- =====================================================
-- MediGo Complete Database Schema for Supabase
-- =====================================================

-- =====================================================
-- USERS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS users (
    user_id BIGSERIAL PRIMARY KEY,
    name TEXT,
    email TEXT UNIQUE,
    phone TEXT,
    password TEXT,
    gender TEXT,
    dob TEXT,
    latitude REAL,
    longitude REAL,
    location_name TEXT,
    premium BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- MEDICINE (Master Catalog)
-- =====================================================
CREATE TABLE IF NOT EXISTS medicine (
    medicine_id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    generic_name TEXT,
    dosage TEXT,
    form TEXT,
    manufacturer TEXT,
    description TEXT,
    requires_prescription INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- MEDICINE TRACKING (User's Medicine List)
-- =====================================================
CREATE TABLE IF NOT EXISTS medicine_tracking (
    medicine_track_id BIGSERIAL PRIMARY KEY,
    user_id BIGINT,
    name TEXT,
    type TEXT,
    dosage TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT fk_medicine_tracking_user FOREIGN KEY (user_id) REFERENCES "users"(user_id) ON DELETE CASCADE
);

-- =====================================================
-- USER MEDICINES (User's Personal Medicine Collection)
-- =====================================================
CREATE TABLE IF NOT EXISTS user_medicines (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    medicine_id BIGINT NOT NULL,
    medicine_name TEXT,
    dosage TEXT,
    frequency TEXT,
    notes TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    added_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT fk_user_medicines_user FOREIGN KEY (user_id) REFERENCES "users"(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_user_medicines_medicine FOREIGN KEY (medicine_id) REFERENCES medicine(medicine_id) ON DELETE CASCADE
);

-- =====================================================
-- MEDICINE PLAN (Medication Schedule)
-- =====================================================
CREATE TABLE IF NOT EXISTS medicine_plan (
    plan_id BIGSERIAL PRIMARY KEY,
    medicine_track_id BIGINT,
    user_id BIGINT,
    importance TEXT,
    start_date TEXT,
    end_date TEXT,
    frequency_type TEXT,
    interval_days INTEGER,
    weekdays TEXT,
    month_days TEXT,
    custom_dates TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT fk_medicine_plan_tracking FOREIGN KEY (medicine_track_id) REFERENCES medicine_tracking(medicine_track_id) ON DELETE CASCADE,
    CONSTRAINT fk_medicine_plan_user FOREIGN KEY (user_id) REFERENCES "users"(user_id) ON DELETE CASCADE
);

-- =====================================================
-- OCCURRENCE PLAN (Scheduled Doses)
-- =====================================================
CREATE TABLE IF NOT EXISTS occurrence_plan (
    id BIGSERIAL PRIMARY KEY,
    plan_id BIGINT,
    date TEXT,
    time TEXT,
    is_taken INTEGER DEFAULT 0,
    day_of_week TEXT,
    interval_value INTEGER,
    interval_unit TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT fk_occurrence_plan_medicine_plan FOREIGN KEY (plan_id) REFERENCES medicine_plan(plan_id) ON DELETE CASCADE
);

-- =====================================================
-- MEDICATION INTAKE LOG (Actual Medicine Taking)
-- =====================================================
CREATE TABLE IF NOT EXISTS medication_intake_log (
    log_id BIGSERIAL PRIMARY KEY,
    occurrence_id BIGINT,
    medicine_track_id BIGINT,
    scheduled_date TEXT NOT NULL,
    scheduled_time TEXT NOT NULL,
    actual_time TEXT,
    status TEXT NOT NULL,
    dosage TEXT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT fk_intake_log_occurrence FOREIGN KEY (occurrence_id) REFERENCES occurrence_plan(id) ON DELETE CASCADE,
    CONSTRAINT fk_intake_log_tracking FOREIGN KEY (medicine_track_id) REFERENCES medicine_tracking(medicine_track_id) ON DELETE CASCADE
);

-- =====================================================
-- DAILY DOSAGE CHECKING
-- =====================================================
CREATE TABLE IF NOT EXISTS daily_dosage_checking (
    dc_id BIGSERIAL PRIMARY KEY,
    plan_id BIGINT,
    dose_date TEXT,
    dose_time TEXT,
    status TEXT,
    taken_at TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT fk_daily_dosage_plan FOREIGN KEY (plan_id) REFERENCES medicine_plan(plan_id) ON DELETE CASCADE
);

-- =====================================================
-- PHARMACIES TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS pharmacy (
    pharmacy_id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    latitude REAL,
    longitude REAL,
    phone TEXT,
    opening_hours TEXT,
    rating REAL,
    image_url TEXT,
    address TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- PHARMACY MEDICINE (Pharmacy Inventory)
-- =====================================================
CREATE TABLE IF NOT EXISTS pharmacy_medicine (
    id BIGSERIAL PRIMARY KEY,
    pharmacy_id BIGINT NOT NULL,
    medicine_id BIGINT NOT NULL,
    price REAL NOT NULL,
    stock INTEGER DEFAULT 0,
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT fk_pharmacy_medicine_pharmacy FOREIGN KEY (pharmacy_id) REFERENCES pharmacy(pharmacy_id) ON DELETE CASCADE,
    CONSTRAINT fk_pharmacy_medicine_medicine FOREIGN KEY (medicine_id) REFERENCES medicine(medicine_id) ON DELETE CASCADE
);

-- =====================================================
-- MEDICINE SEARCH HISTORY (Restock Notifications)
-- =====================================================
CREATE TABLE IF NOT EXISTS medicine_search_history (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    medicine_name TEXT NOT NULL,
    searched_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    notify_restock INTEGER DEFAULT 0,
    CONSTRAINT fk_search_history_user FOREIGN KEY (user_id) REFERENCES "user"(user_id) ON DELETE CASCADE
);

-- =====================================================
-- RESTOCK NOTIFICATIONS
-- =====================================================
CREATE TABLE IF NOT EXISTS restock_notifications (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    medicine_id BIGINT NOT NULL,
    pharmacy_id BIGINT NOT NULL,
    medicine_name TEXT NOT NULL,
    pharmacy_name TEXT,
    stock_available INTEGER,
    price REAL,
    is_read BOOLEAN DEFAULT FALSE,
    notified_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT fk_restock_user FOREIGN KEY (user_id) REFERENCES "user"(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_restock_medicine FOREIGN KEY (medicine_id) REFERENCES medicine(medicine_id) ON DELETE CASCADE,
    CONSTRAINT fk_restock_pharmacy FOREIGN KEY (pharmacy_id) REFERENCES pharmacy(pharmacy_id) ON DELETE CASCADE
);

-- =====================================================
-- RESERVATIONS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS reservation (
    reservation_id BIGSERIAL PRIMARY KEY,
    medicine_find_id BIGINT,
    user_id BIGINT,
    pharmacy_id BIGINT,
    medicine_name TEXT,
    day TEXT,
    time TEXT,
    quantity INTEGER,
    status TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT fk_reservation_search FOREIGN KEY (medicine_find_id) REFERENCES medicine_search_history(id) ON DELETE SET NULL,
    CONSTRAINT fk_reservation_user FOREIGN KEY (user_id) REFERENCES "user"(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_reservation_pharmacy FOREIGN KEY (pharmacy_id) REFERENCES pharmacy(pharmacy_id) ON DELETE CASCADE
);

-- =====================================================
-- NOTIFICATIONS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS notification (
    notification_id BIGSERIAL PRIMARY KEY,
    user_id BIGINT,
    plan_id BIGINT,
    reservation_id BIGINT,
    medicine_find_id BIGINT,
    dc_id BIGINT,
    datetime TEXT,
    title TEXT,
    message TEXT,
    type TEXT,
    is_read INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT fk_notification_user FOREIGN KEY (user_id) REFERENCES "user"(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_notification_plan FOREIGN KEY (plan_id) REFERENCES medicine_plan(plan_id) ON DELETE SET NULL,
    CONSTRAINT fk_notification_reservation FOREIGN KEY (reservation_id) REFERENCES reservation(reservation_id) ON DELETE SET NULL,
    CONSTRAINT fk_notification_search FOREIGN KEY (medicine_find_id) REFERENCES medicine_search_history(id) ON DELETE SET NULL,
    CONSTRAINT fk_notification_dosage FOREIGN KEY (dc_id) REFERENCES daily_dosage_checking(dc_id) ON DELETE SET NULL
);

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================

-- User indexes
CREATE INDEX IF NOT EXISTS idx_user_email ON "user"(email);
CREATE INDEX IF NOT EXISTS idx_user_location ON "user"(latitude, longitude);

-- Medicine tracking indexes
CREATE INDEX IF NOT EXISTS idx_medicine_tracking_user_id ON medicine_tracking(user_id);

-- User medicines indexes
CREATE INDEX IF NOT EXISTS idx_user_medicines_user_id ON user_medicines(user_id);
CREATE INDEX IF NOT EXISTS idx_user_medicines_medicine_id ON user_medicines(medicine_id);
CREATE INDEX IF NOT EXISTS idx_user_medicines_is_active ON user_medicines(is_active);

-- Medicine plan indexes
CREATE INDEX IF NOT EXISTS idx_medicine_plan_user_id ON medicine_plan(user_id);
CREATE INDEX IF NOT EXISTS idx_medicine_plan_medicine_track_id ON medicine_plan(medicine_track_id);

-- Occurrence plan indexes
CREATE INDEX IF NOT EXISTS idx_occurrence_plan_plan_id ON occurrence_plan(plan_id);
CREATE INDEX IF NOT EXISTS idx_occurrence_plan_date ON occurrence_plan(date);

-- Medication intake log indexes
CREATE INDEX IF NOT EXISTS idx_medication_intake_log_occurrence_id ON medication_intake_log(occurrence_id);
CREATE INDEX IF NOT EXISTS idx_medication_intake_log_medicine_track_id ON medication_intake_log(medicine_track_id);
CREATE INDEX IF NOT EXISTS idx_medication_intake_log_scheduled_date ON medication_intake_log(scheduled_date);

-- Daily dosage checking indexes
CREATE INDEX IF NOT EXISTS idx_daily_dosage_checking_plan_id ON daily_dosage_checking(plan_id);
CREATE INDEX IF NOT EXISTS idx_daily_dosage_checking_dose_date ON daily_dosage_checking(dose_date);

-- Pharmacy medicine indexes
CREATE INDEX IF NOT EXISTS idx_pharmacy_medicine_pharmacy_id ON pharmacy_medicine(pharmacy_id);
CREATE INDEX IF NOT EXISTS idx_pharmacy_medicine_medicine_id ON pharmacy_medicine(medicine_id);

-- Medicine search history indexes
CREATE INDEX IF NOT EXISTS idx_medicine_search_history_user_id ON medicine_search_history(user_id);
CREATE INDEX IF NOT EXISTS idx_medicine_search_history_notify_restock ON medicine_search_history(notify_restock);

-- Restock notifications indexes
CREATE INDEX IF NOT EXISTS idx_restock_notifications_user_id ON restock_notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_restock_notifications_is_read ON restock_notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_restock_notifications_medicine_id ON restock_notifications(medicine_id);

-- Reservation indexes
CREATE INDEX IF NOT EXISTS idx_reservation_user_id ON reservation(user_id);
CREATE INDEX IF NOT EXISTS idx_reservation_pharmacy_id ON reservation(pharmacy_id);
CREATE INDEX IF NOT EXISTS idx_reservation_status ON reservation(status);

-- Notification indexes
CREATE INDEX IF NOT EXISTS idx_notification_user_id ON notification(user_id);
CREATE INDEX IF NOT EXISTS idx_notification_is_read ON notification(is_read);
CREATE INDEX IF NOT EXISTS idx_notification_type ON notification(type);

-- =====================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- =====================================================

-- Enable RLS on all tables
ALTER TABLE "user" ENABLE ROW LEVEL SECURITY;
ALTER TABLE medicine ENABLE ROW LEVEL SECURITY;
ALTER TABLE medicine_tracking ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_medicines ENABLE ROW LEVEL SECURITY;
ALTER TABLE medicine_plan ENABLE ROW LEVEL SECURITY;
ALTER TABLE occurrence_plan ENABLE ROW LEVEL SECURITY;
ALTER TABLE medication_intake_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_dosage_checking ENABLE ROW LEVEL SECURITY;
ALTER TABLE pharmacy ENABLE ROW LEVEL SECURITY;
ALTER TABLE pharmacy_medicine ENABLE ROW LEVEL SECURITY;
ALTER TABLE medicine_search_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE restock_notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE reservation ENABLE ROW LEVEL SECURITY;
ALTER TABLE notification ENABLE ROW LEVEL SECURITY;

-- User policies (users can only access their own data)
CREATE POLICY "Users can view own profile" ON "user"
    FOR SELECT USING (auth.uid()::text = user_id::text);

CREATE POLICY "Users can update own profile" ON "user"
    FOR UPDATE USING (auth.uid()::text = user_id::text);

-- Medicine tracking policies
CREATE POLICY "Users can view own medicine tracking" ON medicine_tracking
    FOR SELECT USING (auth.uid()::text = user_id::text);

CREATE POLICY "Users can insert own medicine tracking" ON medicine_tracking
    FOR INSERT WITH CHECK (auth.uid()::text = user_id::text);

CREATE POLICY "Users can update own medicine tracking" ON medicine_tracking
    FOR UPDATE USING (auth.uid()::text = user_id::text);

CREATE POLICY "Users can delete own medicine tracking" ON medicine_tracking
    FOR DELETE USING (auth.uid()::text = user_id::text);

-- User medicines policies
CREATE POLICY "Users can view own medicines" ON user_medicines
    FOR SELECT USING (auth.uid()::text = user_id::text);

CREATE POLICY "Users can insert own medicines" ON user_medicines
    FOR INSERT WITH CHECK (auth.uid()::text = user_id::text);

CREATE POLICY "Users can update own medicines" ON user_medicines
    FOR UPDATE USING (auth.uid()::text = user_id::text);

CREATE POLICY "Users can delete own medicines" ON user_medicines
    FOR DELETE USING (auth.uid()::text = user_id::text);

-- Medicine plan policies
CREATE POLICY "Users can view own plans" ON medicine_plan
    FOR SELECT USING (auth.uid()::text = user_id::text);

CREATE POLICY "Users can insert own plans" ON medicine_plan
    FOR INSERT WITH CHECK (auth.uid()::text = user_id::text);

CREATE POLICY "Users can update own plans" ON medicine_plan
    FOR UPDATE USING (auth.uid()::text = user_id::text);

CREATE POLICY "Users can delete own plans" ON medicine_plan
    FOR DELETE USING (auth.uid()::text = user_id::text);

-- Occurrence plan policies
CREATE POLICY "Users can view own occurrences" ON occurrence_plan
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM medicine_plan mp 
            WHERE mp.plan_id = occurrence_plan.plan_id 
            AND auth.uid()::text = mp.user_id::text
        )
    );

-- Medication intake log policies
CREATE POLICY "Users can view own intake logs" ON medication_intake_log
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM medicine_tracking mt 
            WHERE mt.medicine_track_id = medication_intake_log.medicine_track_id 
            AND auth.uid()::text = mt.user_id::text
        )
    );

-- Restock notifications policies
CREATE POLICY "Users can view own restock notifications" ON restock_notifications
    FOR SELECT USING (auth.uid()::text = user_id::text);

CREATE POLICY "Users can update own restock notifications" ON restock_notifications
    FOR UPDATE USING (auth.uid()::text = user_id::text);

-- Reservation policies
CREATE POLICY "Users can view own reservations" ON reservation
    FOR SELECT USING (auth.uid()::text = user_id::text);

CREATE POLICY "Users can create own reservations" ON reservation
    FOR INSERT WITH CHECK (auth.uid()::text = user_id::text);

-- Notification policies
CREATE POLICY "Users can view own notifications" ON notification
    FOR SELECT USING (auth.uid()::text = user_id::text);

CREATE POLICY "Users can update own notifications" ON notification
    FOR UPDATE USING (auth.uid()::text = user_id::text);

-- Public read access for medicines and pharmacies
CREATE POLICY "Anyone can view medicines" ON medicine
    FOR SELECT USING (true);

CREATE POLICY "Anyone can view pharmacies" ON pharmacy
    FOR SELECT USING (true);

CREATE POLICY "Anyone can view pharmacy inventory" ON pharmacy_medicine
    FOR SELECT USING (true);

-- =====================================================
-- SAMPLE DATA (Optional - for testing)
-- =====================================================

-- Insert sample medicines
INSERT INTO medicine (medicine_id, name, generic_name, dosage, form, manufacturer, requires_prescription) VALUES
    (1, 'Panadol', 'Paracetamol', '500mg', 'Tablet', 'GSK', 0),
    (2, 'Aspirin', 'Acetylsalicylic Acid', '100mg', 'Tablet', 'Bayer', 0),
    (3, 'Amoxicillin', 'Amoxicillin', '500mg', 'Capsule', 'Generic', 1),
    (4, 'Ibuprofen', 'Ibuprofen', '200mg', 'Tablet', 'Generic', 0)
ON CONFLICT (medicine_id) DO NOTHING;

-- Insert sample pharmacies
INSERT INTO pharmacy (pharmacy_id, name, latitude, longitude, phone, opening_hours, rating) VALUES
    (1, 'City Pharmacy', 40.7128, -74.0060, '+1234567890', '8:00-22:00', 4.5),
    (2, 'HealthCare Pharmacy', 40.7580, -73.9855, '+1234567891', '24 hours', 4.8)
ON CONFLICT (pharmacy_id) DO NOTHING;

-- Insert sample pharmacy inventory
INSERT INTO pharmacy_medicine (pharmacy_id, medicine_id, price, stock) VALUES
    (1, 1, 5.99, 100),
    (1, 2, 3.49, 50),
    (1, 4, 4.99, 75),
    (2, 1, 5.49, 150),
    (2, 3, 12.99, 30),
    (2, 4, 4.49, 80)
ON CONFLICT (id) DO NOTHING;