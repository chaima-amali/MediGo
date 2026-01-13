import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:frontend/data/services/api_service.dart';

@GenerateMocks([Dio])
import 'api_service_test.mocks.dart';

void main() {
  late ApiService apiService;

  setUp(() {
    apiService = ApiService();
  });

  group('ApiService', () {
    test('should initialize successfully', () {
      expect(() => apiService.initialize(), returnsNormally);
    });

    test('should have auth service available', () {
      apiService.initialize();
      expect(apiService.auth, isNotNull);
    });

    test('should have users service available', () {
      apiService.initialize();
      expect(apiService.users, isNotNull);
    });

    test('should have medicines service available', () {
      apiService.initialize();
      expect(apiService.medicines, isNotNull);
    });

    test('should have pharmacies service available', () {
      apiService.initialize();
      expect(apiService.pharmacies, isNotNull);
    });

    test('should have reservations service available', () {
      apiService.initialize();
      expect(apiService.reservations, isNotNull);
    });

    test('should have medicationLogs service available', () {
      apiService.initialize();
      expect(apiService.medicationLogs, isNotNull);
    });

    test('should have statistics service available', () {
      apiService.initialize();
      expect(apiService.statistics, isNotNull);
    });

    test('should have sync service available', () {
      apiService.initialize();
      expect(apiService.sync, isNotNull);
    });

    test('should return singleton instance', () {
      final instance1 = ApiService();
      final instance2 = ApiService();
      expect(instance1, same(instance2));
    });

    group('Authentication Token Management', () {
      test('should set auth token', () {
        apiService.initialize();
        expect(() => apiService.setAuthToken('test-token'), returnsNormally);
      });

      test('should clear auth token', () {
        apiService.initialize();
        apiService.setAuthToken('test-token');
        expect(() => apiService.clearAuthToken(), returnsNormally);
      });
    });

    group('Backward Compatibility Methods', () {
      test('register method should exist', () {
        apiService.initialize();
        expect(apiService.register, isA<Function>());
      });

      test('login method should exist', () {
        apiService.initialize();
        expect(apiService.login, isA<Function>());
      });

      test('verifyUser method should exist', () {
        apiService.initialize();
        expect(apiService.verifyUser, isA<Function>());
      });

      test('createUser method should exist', () {
        apiService.initialize();
        expect(apiService.createUser, isA<Function>());
      });

      test('getUser method should exist', () {
        apiService.initialize();
        expect(apiService.getUser, isA<Function>());
      });

      test('updateUser method should exist', () {
        apiService.initialize();
        expect(apiService.updateUser, isA<Function>());
      });

      test('updateFCMToken method should exist', () {
        apiService.initialize();
        expect(apiService.updateFCMToken, isA<Function>());
      });

      test('getMedicines method should exist', () {
        apiService.initialize();
        expect(apiService.getMedicines, isA<Function>());
      });

      test('createMedicine method should exist', () {
        apiService.initialize();
        expect(apiService.createMedicine, isA<Function>());
      });

      test('updateMedicine method should exist', () {
        apiService.initialize();
        expect(apiService.updateMedicine, isA<Function>());
      });

      test('deleteMedicine method should exist', () {
        apiService.initialize();
        expect(apiService.deleteMedicine, isA<Function>());
      });

      test('createReservation method should exist', () {
        apiService.initialize();
        expect(apiService.createReservation, isA<Function>());
      });

      test('getReservations method should exist', () {
        apiService.initialize();
        expect(apiService.getReservations, isA<Function>());
      });

      test('updateReservationStatus method should exist', () {
        apiService.initialize();
        expect(apiService.updateReservationStatus, isA<Function>());
      });

      test('logMedicationIntake method should exist', () {
        apiService.initialize();
        expect(apiService.logMedicationIntake, isA<Function>());
      });
    });
  });
}
