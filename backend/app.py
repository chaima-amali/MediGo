"""
MediGo Flask Backend API
Provides RESTful endpoints for medication management, pharmacies, and reservations
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Initialize Flask app
app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = os.getenv('DATABASE_URL', 'sqlite:///medigo.db')
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['SECRET_KEY'] = os.getenv('SECRET_KEY', 'your-secret-key-here')

# Initialize extensions
CORS(app)
db = SQLAlchemy(app)

# ============ DATABASE MODELS ============

class User(db.Model):
    __tablename__ = 'users'
    
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    phone = db.Column(db.String(20))
    age = db.Column(db.Integer)
    fcm_token = db.Column(db.String(255))
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    medicines = db.relationship('Medicine', backref='user', lazy=True, cascade='all, delete-orphan')
    reservations = db.relationship('Reservation', backref='user', lazy=True, cascade='all, delete-orphan')
    
    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'email': self.email,
            'phone': self.phone,
            'age': self.age,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None,
        }

class Medicine(db.Model):
    __tablename__ = 'medicines'
    
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    name = db.Column(db.String(200), nullable=False)
    dosage = db.Column(db.String(100))
    frequency = db.Column(db.String(50))
    start_date = db.Column(db.Date)
    end_date = db.Column(db.Date)
    notes = db.Column(db.Text)
    active = db.Column(db.Boolean, default=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    def to_dict(self):
        return {
            'id': self.id,
            'user_id': self.user_id,
            'name': self.name,
            'dosage': self.dosage,
            'frequency': self.frequency,
            'start_date': self.start_date.isoformat() if self.start_date else None,
            'end_date': self.end_date.isoformat() if self.end_date else None,
            'notes': self.notes,
            'active': self.active,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None,
        }

class Pharmacy(db.Model):
    __tablename__ = 'pharmacies'
    
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(200), nullable=False)
    address = db.Column(db.String(300))
    phone = db.Column(db.String(20))
    latitude = db.Column(db.Float)
    longitude = db.Column(db.Float)
    rating = db.Column(db.Float, default=0.0)
    is_24h = db.Column(db.Boolean, default=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    inventory = db.relationship('PharmacyInventory', backref='pharmacy', lazy=True)
    
    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'address': self.address,
            'phone': self.phone,
            'latitude': self.latitude,
            'longitude': self.longitude,
            'rating': self.rating,
            'is_24h': self.is_24h,
            'created_at': self.created_at.isoformat() if self.created_at else None,
        }

class PharmacyInventory(db.Model):
    __tablename__ = 'pharmacy_inventory'
    
    id = db.Column(db.Integer, primary_key=True)
    pharmacy_id = db.Column(db.Integer, db.ForeignKey('pharmacies.id'), nullable=False)
    medicine_name = db.Column(db.String(200), nullable=False)
    price = db.Column(db.Float)
    stock_quantity = db.Column(db.Integer, default=0)
    available = db.Column(db.Boolean, default=True)
    
    def to_dict(self):
        return {
            'id': self.id,
            'pharmacy_id': self.pharmacy_id,
            'medicine_name': self.medicine_name,
            'price': self.price,
            'stock_quantity': self.stock_quantity,
            'available': self.available,
        }

class Reservation(db.Model):
    __tablename__ = 'reservations'
    
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    pharmacy_id = db.Column(db.Integer, db.ForeignKey('pharmacies.id'), nullable=False)
    medicine_name = db.Column(db.String(200), nullable=False)
    quantity = db.Column(db.Integer, default=1)
    status = db.Column(db.String(50), default='pending')  # pending, confirmed, ready, completed, cancelled
    reservation_date = db.Column(db.DateTime, default=datetime.utcnow)
    pickup_date = db.Column(db.DateTime)
    notes = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    pharmacy = db.relationship('Pharmacy', backref='reservations')
    
    def to_dict(self):
        return {
            'id': self.id,
            'user_id': self.user_id,
            'pharmacy_id': self.pharmacy_id,
            'pharmacy': self.pharmacy.to_dict() if self.pharmacy else None,
            'medicine_name': self.medicine_name,
            'quantity': self.quantity,
            'status': self.status,
            'reservation_date': self.reservation_date.isoformat() if self.reservation_date else None,
            'pickup_date': self.pickup_date.isoformat() if self.pickup_date else None,
            'notes': self.notes,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None,
        }

class MedicationLog(db.Model):
    __tablename__ = 'medication_logs'
    
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    medicine_id = db.Column(db.Integer, db.ForeignKey('medicines.id'))
    medicine_name = db.Column(db.String(200))
    taken_at = db.Column(db.DateTime, default=datetime.utcnow)
    status = db.Column(db.String(50))  # taken, missed, skipped
    notes = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    def to_dict(self):
        return {
            'id': self.id,
            'user_id': self.user_id,
            'medicine_id': self.medicine_id,
            'medicine_name': self.medicine_name,
            'taken_at': self.taken_at.isoformat() if self.taken_at else None,
            'status': self.status,
            'notes': self.notes,
            'created_at': self.created_at.isoformat() if self.created_at else None,
        }

# ============ API ENDPOINTS ============

@app.route('/api/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({'status': 'healthy', 'timestamp': datetime.utcnow().isoformat()})

# ===== USER ENDPOINTS =====

@app.route('/api/users', methods=['POST'])
def create_user():
    """Create a new user"""
    data = request.json
    user = User(
        name=data['name'],
        email=data['email'],
        phone=data.get('phone'),
        age=data.get('age')
    )
    db.session.add(user)
    db.session.commit()
    return jsonify(user.to_dict()), 201

@app.route('/api/users/<int:user_id>', methods=['GET'])
def get_user(user_id):
    """Get user by ID"""
    user = User.query.get_or_404(user_id)
    return jsonify(user.to_dict())

@app.route('/api/users/<int:user_id>', methods=['PUT'])
def update_user(user_id):
    """Update user"""
    user = User.query.get_or_404(user_id)
    data = request.json
    
    user.name = data.get('name', user.name)
    user.email = data.get('email', user.email)
    user.phone = data.get('phone', user.phone)
    user.age = data.get('age', user.age)
    
    db.session.commit()
    return jsonify(user.to_dict())

@app.route('/api/users/<int:user_id>/fcm-token', methods=['POST'])
def update_fcm_token(user_id):
    """Update user FCM token"""
    user = User.query.get_or_404(user_id)
    data = request.json
    user.fcm_token = data['token']
    db.session.commit()
    return jsonify({'message': 'FCM token updated'})

# ===== MEDICINE ENDPOINTS =====

@app.route('/api/medicines', methods=['GET'])
def get_medicines():
    """Get medicines for a user"""
    user_id = request.args.get('user_id', type=int)
    if user_id:
        medicines = Medicine.query.filter_by(user_id=user_id).all()
    else:
        medicines = Medicine.query.all()
    return jsonify([m.to_dict() for m in medicines])

@app.route('/api/medicines', methods=['POST'])
def create_medicine():
    """Create a new medicine"""
    data = request.json
    medicine = Medicine(
        user_id=data['user_id'],
        name=data['name'],
        dosage=data.get('dosage'),
        frequency=data.get('frequency'),
        start_date=datetime.fromisoformat(data['start_date']) if data.get('start_date') else None,
        end_date=datetime.fromisoformat(data['end_date']) if data.get('end_date') else None,
        notes=data.get('notes'),
        active=data.get('active', True)
    )
    db.session.add(medicine)
    db.session.commit()
    return jsonify(medicine.to_dict()), 201

@app.route('/api/medicines/<int:medicine_id>', methods=['PUT'])
def update_medicine(medicine_id):
    """Update medicine"""
    medicine = Medicine.query.get_or_404(medicine_id)
    data = request.json
    
    medicine.name = data.get('name', medicine.name)
    medicine.dosage = data.get('dosage', medicine.dosage)
    medicine.frequency = data.get('frequency', medicine.frequency)
    medicine.notes = data.get('notes', medicine.notes)
    medicine.active = data.get('active', medicine.active)
    
    db.session.commit()
    return jsonify(medicine.to_dict())

@app.route('/api/medicines/<int:medicine_id>', methods=['DELETE'])
def delete_medicine(medicine_id):
    """Delete medicine"""
    medicine = Medicine.query.get_or_404(medicine_id)
    db.session.delete(medicine)
    db.session.commit()
    return jsonify({'message': 'Medicine deleted'}), 204

# ===== PHARMACY ENDPOINTS =====

@app.route('/api/pharmacies/search', methods=['GET'])
def search_pharmacies():
    """Search pharmacies"""
    lat = request.args.get('lat', type=float)
    lng = request.args.get('lng', type=float)
    medicine = request.args.get('medicine')
    
    # TODO: Implement geospatial search with distance calculation
    pharmacies = Pharmacy.query.all()
    
    if medicine:
        # Filter by medicine availability
        pharmacy_ids = db.session.query(PharmacyInventory.pharmacy_id).filter(
            PharmacyInventory.medicine_name.ilike(f'%{medicine}%'),
            PharmacyInventory.available == True
        ).distinct()
        pharmacies = [p for p in pharmacies if p.id in [pid[0] for pid in pharmacy_ids]]
    
    return jsonify([p.to_dict() for p in pharmacies])

@app.route('/api/pharmacies/<int:pharmacy_id>', methods=['GET'])
def get_pharmacy(pharmacy_id):
    """Get pharmacy by ID"""
    pharmacy = Pharmacy.query.get_or_404(pharmacy_id)
    result = pharmacy.to_dict()
    result['inventory'] = [inv.to_dict() for inv in pharmacy.inventory]
    return jsonify(result)

# ===== RESERVATION ENDPOINTS =====

@app.route('/api/reservations', methods=['GET'])
def get_reservations():
    """Get reservations for a user"""
    user_id = request.args.get('user_id', type=int)
    if user_id:
        reservations = Reservation.query.filter_by(user_id=user_id).all()
    else:
        reservations = Reservation.query.all()
    return jsonify([r.to_dict() for r in reservations])

@app.route('/api/reservations', methods=['POST'])
def create_reservation():
    """Create a new reservation"""
    data = request.json
    reservation = Reservation(
        user_id=data['user_id'],
        pharmacy_id=data['pharmacy_id'],
        medicine_name=data['medicine_name'],
        quantity=data.get('quantity', 1),
        notes=data.get('notes')
    )
    db.session.add(reservation)
    db.session.commit()
    
    # TODO: Send FCM notification to user
    
    return jsonify(reservation.to_dict()), 201

@app.route('/api/reservations/<int:reservation_id>/status', methods=['PUT'])
def update_reservation_status(reservation_id):
    """Update reservation status"""
    reservation = Reservation.query.get_or_404(reservation_id)
    data = request.json
    reservation.status = data['status']
    db.session.commit()
    
    # TODO: Send FCM notification to user
    
    return jsonify(reservation.to_dict())

# ===== MEDICATION LOG ENDPOINTS =====

@app.route('/api/medication-logs', methods=['GET'])
def get_medication_logs():
    """Get medication logs"""
    user_id = request.args.get('user_id', type=int)
    start_date = request.args.get('start_date')
    end_date = request.args.get('end_date')
    
    query = MedicationLog.query
    if user_id:
        query = query.filter_by(user_id=user_id)
    if start_date:
        query = query.filter(MedicationLog.taken_at >= datetime.fromisoformat(start_date))
    if end_date:
        query = query.filter(MedicationLog.taken_at <= datetime.fromisoformat(end_date))
    
    logs = query.all()
    return jsonify([log.to_dict() for log in logs])

@app.route('/api/medication-logs', methods=['POST'])
def log_medication_intake():
    """Log medication intake"""
    data = request.json
    log = MedicationLog(
        user_id=data['user_id'],
        medicine_id=data.get('medicine_id'),
        medicine_name=data['medicine_name'],
        status=data['status'],
        notes=data.get('notes')
    )
    db.session.add(log)
    db.session.commit()
    return jsonify(log.to_dict()), 201

# ===== STATISTICS ENDPOINTS =====

@app.route('/api/statistics/adherence', methods=['GET'])
def get_adherence_stats():
    """Get adherence statistics"""
    user_id = request.args.get('user_id', type=int, default=1)
    period = request.args.get('period', default='week')
    
    # Calculate date range
    end_date = datetime.utcnow()
    if period == 'week':
        start_date = end_date.replace(day=end_date.day-7)
    elif period == 'month':
        start_date = end_date.replace(month=end_date.month-1)
    else:
        start_date = end_date.replace(day=end_date.day-30)
    
    # Query logs
    logs = MedicationLog.query.filter(
        MedicationLog.user_id == user_id,
        MedicationLog.taken_at >= start_date,
        MedicationLog.taken_at <= end_date
    ).all()
    
    # Calculate statistics
    total = len(logs)
    taken = len([l for l in logs if l.status == 'taken'])
    missed = len([l for l in logs if l.status == 'missed'])
    
    return jsonify({
        'total': total,
        'taken': taken,
        'missed': missed,
        'adherence_rate': (taken / total * 100) if total > 0 else 0,
        'period': period,
        'start_date': start_date.isoformat(),
        'end_date': end_date.isoformat(),
    })

# ===== SYNC ENDPOINT =====

@app.route('/api/sync', methods=['POST'])
def sync_data():
    """Sync data from mobile app"""
    data = request.json
    # TODO: Implement comprehensive sync logic
    return jsonify({'message': 'Sync completed', 'timestamp': datetime.utcnow().isoformat()})

# ============ ERROR HANDLERS ============

@app.errorhandler(404)
def not_found(error):
    return jsonify({'error': 'Not found'}), 404

@app.errorhandler(500)
def internal_error(error):
    db.session.rollback()
    return jsonify({'error': 'Internal server error'}), 500

# ============ INITIALIZE DATABASE ============

with app.app_context():
    db.create_all()
    print("✅ Database tables created successfully")

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
