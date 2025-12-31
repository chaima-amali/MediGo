# MediGo Backend API

Flask-based REST API for MediGo medication management application.

## Features

- 🔐 User management
- 💊 Medicine CRUD operations
- 🏥 Pharmacy search and inventory
- 📋 Reservation system
- 📊 Medication tracking and statistics
- 🔄 Data synchronization with mobile app
- 🔔 FCM token management

## Tech Stack

- **Framework**: Flask 3.1.0
- **ORM**: SQLAlchemy 2.0
- **Database**: SQLite (development) / PostgreSQL (production)
- **CORS**: Flask-CORS
- **Authentication**: Firebase Admin (optional)

## Quick Start

### 1. Install Dependencies

```bash
pip install -r requirements.txt
```

### 2. Configure Environment

```bash
cp .env.example .env
```

Edit `.env`:
```env
DATABASE_URL=sqlite:///medigo.db
SECRET_KEY=your-super-secret-key-change-this
FLASK_ENV=development
```

### 3. Run the Server

```bash
python app.py
```

Server runs on `http://localhost:5000`

### 4. Verify

```bash
curl http://localhost:5000/api/health
```

Expected response:
```json
{
  "status": "healthy",
  "timestamp": "2025-12-31T12:00:00"
}
```

## API Endpoints

### Health Check
- `GET /api/health` - Server health status

### Users
- `POST /api/users` - Create user
- `GET /api/users/<id>` - Get user by ID
- `PUT /api/users/<id>` - Update user
- `POST /api/users/<id>/fcm-token` - Update FCM token

### Medicines
- `GET /api/medicines?user_id=<id>` - Get user's medicines
- `POST /api/medicines` - Create medicine
- `PUT /api/medicines/<id>` - Update medicine
- `DELETE /api/medicines/<id>` - Delete medicine

### Pharmacies
- `GET /api/pharmacies/search?lat=<lat>&lng=<lng>&medicine=<name>` - Search pharmacies
- `GET /api/pharmacies/<id>` - Get pharmacy details

### Reservations
- `GET /api/reservations?user_id=<id>` - Get user's reservations
- `POST /api/reservations` - Create reservation
- `PUT /api/reservations/<id>/status` - Update reservation status

### Medication Logs
- `GET /api/medication-logs?user_id=<id>&start_date=<date>&end_date=<date>` - Get logs
- `POST /api/medication-logs` - Log medication intake

### Statistics
- `GET /api/statistics/adherence?user_id=<id>&period=<week|month>` - Get adherence stats

### Sync
- `POST /api/sync` - Sync data from mobile app

## Database Models

### User
```python
{
  "id": int,
  "name": str,
  "email": str,
  "phone": str,
  "age": int,
  "fcm_token": str,
  "created_at": datetime,
  "updated_at": datetime
}
```

### Medicine
```python
{
  "id": int,
  "user_id": int,
  "name": str,
  "dosage": str,
  "frequency": str,
  "start_date": date,
  "end_date": date,
  "notes": str,
  "active": bool,
  "created_at": datetime,
  "updated_at": datetime
}
```

### Pharmacy
```python
{
  "id": int,
  "name": str,
  "address": str,
  "phone": str,
  "latitude": float,
  "longitude": float,
  "rating": float,
  "is_24h": bool,
  "created_at": datetime
}
```

### Reservation
```python
{
  "id": int,
  "user_id": int,
  "pharmacy_id": int,
  "medicine_name": str,
  "quantity": int,
  "status": str,  # pending, confirmed, ready, completed, cancelled
  "reservation_date": datetime,
  "pickup_date": datetime,
  "notes": str,
  "created_at": datetime,
  "updated_at": datetime
}
```

## Development

### Run in Debug Mode
```bash
export FLASK_ENV=development
python app.py
```

### Database Migrations

The database is automatically created on first run. To reset:
```bash
rm medigo.db
python app.py
```

### Add Sample Data

```bash
curl -X POST http://localhost:5000/api/users \
  -H "Content-Type: application/json" \
  -d '{"name":"John Doe","email":"john@example.com","phone":"1234567890","age":30}'
```

## Production Deployment

### Using Heroku

```bash
# Login to Heroku
heroku login

# Create app
heroku create medigo-api

# Set environment variables
heroku config:set DATABASE_URL=your_postgresql_url
heroku config:set SECRET_KEY=your_secret_key

# Deploy
git push heroku main
```

### Using Docker

```dockerfile
# Dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

EXPOSE 5000

CMD ["gunicorn", "-b", "0.0.0.0:5000", "app:app"]
```

Build and run:
```bash
docker build -t medigo-backend .
docker run -p 5000:5000 -e DATABASE_URL=sqlite:///medigo.db medigo-backend
```

### Using Gunicorn (Production Server)

```bash
gunicorn -w 4 -b 0.0.0.0:5000 app:app
```

## Testing

### Test Health Endpoint
```bash
curl http://localhost:5000/api/health
```

### Test Create User
```bash
curl -X POST http://localhost:5000/api/users \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com"}'
```

### Test Get Medicines
```bash
curl http://localhost:5000/api/medicines?user_id=1
```

## Security Considerations

1. **Change SECRET_KEY**: Use a strong random key in production
2. **Use PostgreSQL**: SQLite is not recommended for production
3. **Enable HTTPS**: Use SSL certificates
4. **Rate Limiting**: Add rate limiting for API endpoints
5. **Authentication**: Implement JWT or Firebase Auth
6. **Input Validation**: Validate all user inputs
7. **CORS**: Configure CORS for specific domains only

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| DATABASE_URL | Database connection string | sqlite:///medigo.db |
| SECRET_KEY | Flask secret key | your-secret-key-here |
| FLASK_ENV | Environment (development/production) | development |
| FIREBASE_CREDENTIALS_PATH | Path to Firebase credentials JSON | - |

## Troubleshooting

### "ModuleNotFoundError"
```bash
pip install -r requirements.txt
```

### "Database locked"
SQLite issue - switch to PostgreSQL for production

### "CORS error"
Check CORS configuration in `app.py`

## Contributing

1. Create feature branch
2. Make changes
3. Test thoroughly
4. Submit pull request

## License

MIT License - See LICENSE file for details
