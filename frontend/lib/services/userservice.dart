// lib/services/userservice.dart
import '../data/models/user.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  User? _currentUser;

  // Method to set current user after login
  void setCurrentUser(User user) {
    _currentUser = user;
  }

  // Get current user (returns null if not logged in)
  User? getCurrentUser() {
    return _currentUser;
  }

  // Get user with default location if current user is null
  User getUserWithDefaultLocation() {
    return _currentUser ?? User(
      userId: 1,
      name: 'Guest User',
      email: 'guest@example.com',
      phone: '+213555123456',
      password: '',
      gender: 'M',
      dob: '1990-01-01',
      latitude: 36.7538, // Default Algiers coordinates
      longitude: 3.0588,
      premium: 'no',
    );
  }

  // Update user location
  void updateUserLocation(double lat, double lng) {
    if (_currentUser != null) {
      // Create updated user with new location
      _currentUser = User(
        userId: _currentUser!.userId,
        name: _currentUser!.name,
        email: _currentUser!.email,
        phone: _currentUser!.phone,
        password: _currentUser!.password,
        gender: _currentUser!.gender,
        dob: _currentUser!.dob,
        latitude: lat,
        longitude: lng,
        premium: _currentUser!.premium,
      );
    }
  }
}