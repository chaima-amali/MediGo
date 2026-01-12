import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/data/models/medicine_tracking.dart';
import 'package:frontend/data/models/medicine_plan.dart';

void main() {
  group('MedicineTracking Model', () {
    final testTracking = MedicineTracking(
      id: 1,
      userId: 1,
      name: 'Aspirin',
      type: 'Tablet',
      dosage: 100.0,
      unit: 'mg',
    );

    test('should create MedicineTracking with required fields', () {
      expect(testTracking.id, 1);
      expect(testTracking.userId, 1);
      expect(testTracking.name, 'Aspirin');
      expect(testTracking.type, 'Tablet');
      expect(testTracking.dosage, 100.0);
      expect(testTracking.unit, 'mg');
    });

    test('should convert to Map correctly', () {
      final map = testTracking.toMap();

      expect(map['medicine_track_id'], 1);
      expect(map['user_id'], 1);
      expect(map['name'], 'Aspirin');
      expect(map['type'], 'Tablet');
      expect(map['dosage'], 100.0);
      expect(map['unit'], 'mg');
    });

    test('should create from Map correctly', () {
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
      expect(tracking.userId, 1);
      expect(tracking.name, 'Aspirin');
      expect(tracking.type, 'Tablet');
      expect(tracking.dosage, 100.0);
      expect(tracking.unit, 'mg');
    });

    test('should handle numeric dosage from Map', () {
      final map = {
        'medicine_track_id': 1,
        'user_id': 1,
        'name': 'Aspirin',
        'type': 'Tablet',
        'dosage': 100,
        'unit': 'mg',
      };

      final tracking = MedicineTracking.fromMap(map);

      expect(tracking.dosage, 100.0);
    });

    test('should handle string dosage from Map', () {
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

    test('should handle invalid dosage gracefully', () {
      final map = {
        'medicine_track_id': 1,
        'user_id': 1,
        'name': 'Aspirin',
        'type': 'Tablet',
        'dosage': 'invalid',
        'unit': 'mg',
      };

      final tracking = MedicineTracking.fromMap(map);

      expect(tracking.dosage, 0.0);
    });

    test('should handle alternative id field names', () {
      final map = {
        'id': 1,
        'user_id': 1,
        'name': 'Aspirin',
        'type': 'Tablet',
        'dosage': 100.0,
        'unit': 'mg',
      };

      final tracking = MedicineTracking.fromMap(map);

      expect(tracking.id, 1);
    });
  });

  group('MedicinePlan Model', () {
    final testPlan = MedicinePlan(
      id: 1,
      trackingId: 1,
      userId: 1,
      importance: 'high',
      startDate: DateTime(2024, 1, 1),
      endDate: DateTime(2024, 12, 31),
      frequencyType: 'daily',
    );

    test('should create MedicinePlan with required fields', () {
      expect(testPlan.id, 1);
      expect(testPlan.trackingId, 1);
      expect(testPlan.userId, 1);
      expect(testPlan.importance, 'high');
      expect(testPlan.startDate, DateTime(2024, 1, 1));
      expect(testPlan.endDate, DateTime(2024, 12, 31));
      expect(testPlan.frequencyType, 'daily');
    });

    test('should handle optional fields', () {
      final planWithIntervals = testPlan.copyWith(
        intervalDays: 3,
        weekdays: ['Monday', 'Wednesday', 'Friday'],
        monthDays: [1, 15, 30],
      );

      expect(planWithIntervals.intervalDays, 3);
      expect(planWithIntervals.weekdays, ['Monday', 'Wednesday', 'Friday']);
      expect(planWithIntervals.monthDays, [1, 15, 30]);
    });

    test('should copy with updated values', () {
      final updatedPlan = testPlan.copyWith(
        importance: 'critical',
        frequencyType: 'weekly',
      );

      expect(updatedPlan.importance, 'critical');
      expect(updatedPlan.frequencyType, 'weekly');
      expect(updatedPlan.id, 1);
      expect(updatedPlan.trackingId, 1);
    });

    test('should handle different frequency types', () {
      final frequencyTypes = ['daily', 'weekly', 'monthly', 'custom'];

      for (var frequency in frequencyTypes) {
        final plan = testPlan.copyWith(frequencyType: frequency);
        expect(plan.frequencyType, frequency);
      }
    });

    test('should handle different importance levels', () {
      final importanceLevels = ['low', 'medium', 'high', 'critical'];

      for (var importance in importanceLevels) {
        final plan = testPlan.copyWith(importance: importance);
        expect(plan.importance, importance);
      }
    });

    test('should handle date ranges correctly', () {
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 12, 31);

      final plan = MedicinePlan(
        id: 1,
        trackingId: 1,
        userId: 1,
        importance: 'high',
        startDate: startDate,
        endDate: endDate,
        frequencyType: 'daily',
      );

      expect(plan.endDate!.isAfter(plan.startDate), true);
      final duration = plan.endDate!.difference(plan.startDate);
      expect(duration.inDays, greaterThan(0));
    });
  });

  group('Medicine Integration Tests', () {
    test('should link tracking and plan correctly', () {
      final tracking = MedicineTracking(
        id: 1,
        userId: 1,
        name: 'Aspirin',
        type: 'Tablet',
        dosage: 100.0,
        unit: 'mg',
      );

      final plan = MedicinePlan(
        id: 1,
        trackingId: tracking.id!,
        userId: tracking.userId,
        importance: 'high',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        frequencyType: 'daily',
      );

      expect(plan.trackingId, tracking.id);
      expect(plan.userId, tracking.userId);
    });

    test('should validate medicine data consistency', () {
      final tracking = MedicineTracking(
        id: 1,
        userId: 1,
        name: 'Aspirin',
        type: 'Tablet',
        dosage: 100.0,
        unit: 'mg',
      );

      expect(tracking.name, isNotEmpty);
      expect(tracking.type, isNotEmpty);
      expect(tracking.dosage, greaterThan(0));
      expect(tracking.unit, isNotEmpty);
    });
  });
}
