import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:frontend/data/repositories/user_repo.dart';
import 'package:frontend/data/services/api_service.dart';
import 'package:frontend/data/services/sync_service.dart';
import 'package:frontend/data/models/user.dart';
import 'package:frontend/data/models/medicine_tracking.dart';
import 'package:frontend/data/models/medicine_plan.dart';

// Generate mocks
@GenerateMocks([UserRepository, ApiService, SyncService])
void main() {
  // Run: dart run build_runner build
  // This will generate mock files

  group('Model Tests', () {
    group('User Model', () {
      test('should create User from valid data', () {
        final user = User(
          userId: 1,
          name: 'John Doe',
          email: 'john@example.com',
          phone: '1234567890',
          password: 'password123',
          gender: 'Male',
          dob: '1990-01-01',
          premium: false,
        );

        expect(user.userId, 1);
        expect(user.name, 'John Doe');
        expect(user.email, 'john@example.com');
        expect(user.premium, false);
      });

      test('should convert User to Map correctly', () {
        final user = User(
          userId: 1,
          name: 'John Doe',
          email: 'john@example.com',
          phone: '1234567890',
          password: 'password123',
          gender: 'Male',
          dob: '1990-01-01',
          premium: false,
        );

        final map = user.toMap();

        expect(map['user_id'], 1);
        expect(map['name'], 'John Doe');
        expect(map['email'], 'john@example.com');
      });

      test('should create User from Map correctly', () {
        final map = {
          'user_id': 1,
          'name': 'John Doe',
          'email': 'john@example.com',
          'phone': '1234567890',
          'password': 'password123',
          'gender': 'Male',
          'dob': '1990-01-01',
          'premium': false,
        };

        final user = User.fromMap(map);

        expect(user.userId, 1);
        expect(user.name, 'John Doe');
        expect(user.email, 'john@example.com');
      });

      test('should copy User with updated values', () {
        final user = User(
          userId: 1,
          name: 'John Doe',
          email: 'john@example.com',
          phone: '1234567890',
          password: 'password123',
          gender: 'Male',
          dob: '1990-01-01',
          premium: false,
        );

        final updatedUser = user.copyWith(
          name: 'Jane Doe',
          email: 'jane@example.com',
        );

        expect(updatedUser.name, 'Jane Doe');
        expect(updatedUser.email, 'jane@example.com');
        expect(updatedUser.userId, 1);
        expect(updatedUser.phone, '1234567890');
      });
    });

    group('MedicineTracking Model', () {
      test('should create MedicineTracking from valid data', () {
        final tracking = MedicineTracking(
          id: 1,
          userId: 1,
          name: 'Aspirin',
          type: 'Tablet',
          dosage: 100.0,
          unit: 'mg',
        );

        expect(tracking.id, 1);
        expect(tracking.name, 'Aspirin');
        expect(tracking.type, 'Tablet');
        expect(tracking.dosage, 100.0);
        expect(tracking.unit, 'mg');
      });

      test('should convert MedicineTracking to Map correctly', () {
        final tracking = MedicineTracking(
          id: 1,
          userId: 1,
          name: 'Aspirin',
          type: 'Tablet',
          dosage: 100.0,
          unit: 'mg',
        );

        final map = tracking.toMap();

        expect(map['medicine_track_id'], 1);
        expect(map['name'], 'Aspirin');
        expect(map['type'], 'Tablet');
        expect(map['dosage'], 100.0);
      });

      test('should create MedicineTracking from Map correctly', () {
        final map = {
          'medicine_track_id': 1,
          'user_id': 1,
          'name': 'Aspirin',
          'type': 'Tablet',
          'dosage': 100.0,
          'unit': 'mg',
        };

        final tracking = MedicineTracking.fromMap(map);

        expect(tracking.id, 1);
        expect(tracking.name, 'Aspirin');
        expect(tracking.dosage, 100.0);
      });

      test('should handle string dosage in fromMap', () {
        final map = {
          'medicine_track_id': 1,
          'user_id': 1,
          'name': 'Aspirin',
          'type': 'Tablet',
          'dosage': '100.5',
          'unit': 'mg',
        };

        final tracking = MedicineTracking.fromMap(map);

        expect(tracking.dosage, 100.5);
      });
    });

    group('MedicinePlan Model', () {
      test('should create MedicinePlan from valid data', () {
        final plan = MedicinePlan(
          id: 1,
          trackingId: 1,
          userId: 1,
          importance: 'high',
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 12, 31),
          frequencyType: 'daily',
        );

        expect(plan.id, 1);
        expect(plan.importance, 'high');
        expect(plan.frequencyType, 'daily');
        expect(plan.startDate, DateTime(2024, 1, 1));
      });

      test('should copy MedicinePlan with updated values', () {
        final plan = MedicinePlan(
          id: 1,
          trackingId: 1,
          userId: 1,
          importance: 'high',
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 12, 31),
          frequencyType: 'daily',
        );

        final updatedPlan = plan.copyWith(
          importance: 'critical',
          frequencyType: 'weekly',
        );

        expect(updatedPlan.importance, 'critical');
        expect(updatedPlan.frequencyType, 'weekly');
        expect(updatedPlan.id, 1);
        expect(updatedPlan.trackingId, 1);
      });
    });
  });

  group('Utility Tests', () {
    test('Date formatting should work correctly', () {
      final date = DateTime(2024, 1, 15, 10, 30);
      final formatted = date.toIso8601String();

      expect(formatted, contains('2024-01-15'));
    });

    test('String parsing to double should handle valid numbers', () {
      final value = double.tryParse('123.45');
      expect(value, 123.45);
    });

    test('String parsing to double should return null for invalid input', () {
      final value = double.tryParse('invalid');
      expect(value, null);
    });

    test('List operations should work correctly', () {
      final list = ['08:00', '14:00', '20:00'];

      expect(list.length, 3);
      expect(list.first, '08:00');
      expect(list.last, '20:00');
      expect(list.contains('14:00'), true);
    });

    test('Map operations should work correctly', () {
      final map = {'name': 'Test', 'value': 123};

      expect(map['name'], 'Test');
      expect(map['value'], 123);
      expect(map.containsKey('name'), true);
      expect(map.containsKey('missing'), false);
    });
  });

  group('Data Validation Tests', () {
    test('Email validation should accept valid emails', () {
      final validEmails = [
        'test@example.com',
        'user.name@domain.com',
        'user+tag@example.co.uk',
      ];

      for (var email in validEmails) {
        final isValid = RegExp(
          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
        ).hasMatch(email);
        expect(isValid, true, reason: '$email should be valid');
      }
    });

    test('Email validation should reject invalid emails', () {
      final invalidEmails = [
        'notanemail',
        '@example.com',
        'user@',
        'user @example.com',
      ];

      for (var email in invalidEmails) {
        final isValid = RegExp(
          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
        ).hasMatch(email);
        expect(isValid, false, reason: '$email should be invalid');
      }
    });

    test('Phone number should have valid format', () {
      final validPhones = ['1234567890', '0123456789'];

      for (var phone in validPhones) {
        expect(phone.length, 10);
        expect(RegExp(r'^\d+$').hasMatch(phone), true);
      }
    });

    test('Password should meet minimum requirements', () {
      final validPassword = 'password123';

      expect(validPassword.length, greaterThanOrEqualTo(6));
    });
  });

  group('Edge Cases', () {
    test('should handle null values correctly in User model', () {
      final user = User(
        name: 'Test',
        email: 'test@example.com',
        phone: '1234567890',
        password: 'password',
        gender: 'Male',
        dob: '1990-01-01',
        premium: false,
      );

      expect(user.userId, null);
      expect(user.latitude, null);
      expect(user.longitude, null);
      expect(user.locationName, null);
    });

    test('should handle empty lists correctly', () {
      final List<String> emptyList = [];

      expect(emptyList.isEmpty, true);
      expect(emptyList.length, 0);
    });

    test('should handle empty maps correctly', () {
      final Map<String, dynamic> emptyMap = {};

      expect(emptyMap.isEmpty, true);
      expect(emptyMap.length, 0);
    });
  });
}
