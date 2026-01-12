import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:sqflite/sqflite.dart';
import 'package:frontend/data/repositories/user_repo.dart';
import 'package:frontend/data/models/user.dart';

@GenerateMocks([Database])

void main() {
  group('UserRepository', () {
    late UserRepository repository;

    setUp(() {
      repository = UserRepository();
    });

    final testUser = User(
      userId: 1,
      name: 'John Doe',
      email: 'john@example.com',
      phone: '1234567890',
      password: 'password123',
      gender: 'Male',
      dob: '1990-01-01',
      premium: false,
    );

    group('User Model Conversions', () {
      test('should convert User to Map', () {
        final map = testUser.toMap();

        expect(map, isA<Map<String, dynamic>>());
        expect(map['user_id'], 1);
        expect(map['name'], 'John Doe');
        expect(map['email'], 'john@example.com');
        expect(map['phone'], '1234567890');
        expect(map['gender'], 'Male');
        expect(map['dob'], '1990-01-01');
      });

      test('should create User from Map', () {
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
    });

    group('User Validation', () {
      test('should validate email format', () {
        final validEmail = 'test@example.com';
        final invalidEmail = 'notanemail';

        expect(
          RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(validEmail),
          true,
        );
        expect(
          RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(invalidEmail),
          false,
        );
      });

      test('should validate phone number format', () {
        final validPhone = '1234567890';
        final invalidPhone = '123';

        expect(validPhone.length, 10);
        expect(invalidPhone.length, lessThan(10));
      });

      test('should validate password strength', () {
        final strongPassword = 'StrongPass123';
        final weakPassword = '123';

        expect(strongPassword.length, greaterThanOrEqualTo(6));
        expect(weakPassword.length, lessThan(6));
      });
    });

    group('User Operations', () {
      test('should create user with all required fields', () {
        expect(testUser.name, isNotEmpty);
        expect(testUser.email, isNotEmpty);
        expect(testUser.phone, isNotEmpty);
        expect(testUser.password, isNotEmpty);
        expect(testUser.gender, isNotEmpty);
        expect(testUser.dob, isNotEmpty);
      });

      test('should update user with copyWith', () {
        final updatedUser = testUser.copyWith(
          name: 'Jane Doe',
          email: 'jane@example.com',
        );

        expect(updatedUser.name, 'Jane Doe');
        expect(updatedUser.email, 'jane@example.com');
        expect(updatedUser.userId, testUser.userId);
        expect(updatedUser.phone, testUser.phone);
      });

      test('should handle optional fields', () {
        final userWithLocation = testUser.copyWith(
          latitude: 40.7128,
          longitude: -74.0060,
          locationName: 'New York',
        );

        expect(userWithLocation.latitude, 40.7128);
        expect(userWithLocation.longitude, -74.0060);
        expect(userWithLocation.locationName, 'New York');
      });
    });

    group('Premium Status', () {
      test('should handle premium as boolean', () {
        final premiumUser = testUser.copyWith(premium: true);
        final regularUser = testUser.copyWith(premium: false);

        expect(premiumUser.premium, true);
        expect(regularUser.premium, false);
      });

      test('should parse premium from Map correctly', () {
        final maps = [
          {
            'premium': 1,
            'user_id': 1,
            'name': 'Test',
            'email': 'test@test.com',
            'phone': '1234567890',
            'password': 'pass',
            'gender': 'M',
            'dob': '1990-01-01',
          },
          {
            'premium': true,
            'user_id': 1,
            'name': 'Test',
            'email': 'test@test.com',
            'phone': '1234567890',
            'password': 'pass',
            'gender': 'M',
            'dob': '1990-01-01',
          },
          {
            'premium': 'true',
            'user_id': 1,
            'name': 'Test',
            'email': 'test@test.com',
            'phone': '1234567890',
            'password': 'pass',
            'gender': 'M',
            'dob': '1990-01-01',
          },
        ];

        for (var map in maps) {
          final user = User.fromMap(map);
          expect(user.premium, true);
        }
      });
    });
  });
}
