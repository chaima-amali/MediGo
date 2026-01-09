import 'package:frontend/data/databases/db_helper.dart';
import 'package:frontend/data/databases/db_reservation.dart';
import 'package:frontend/data/models/reservation.dart';
import 'package:frontend/data/services/reservation_api_service.dart';
import 'package:sqflite/sqflite.dart';

class ReservationRepository {
  final ReservationApiService _apiService;

  ReservationRepository({ReservationApiService? apiService})
    : _apiService = apiService ?? ReservationApiService();

  Future<Database> get _database async => await DBHelper.getDatabase();

  Future<int> createReservation(
    Reservation reservation, {
    bool isPremium = false,
  }) async {
    print('🔍 createReservation called - isPremium: $isPremium');
    print(
      '📋 Reservation data: userId=${reservation.userId}, pharmacyId=${reservation.pharmacyId}, medicine=${reservation.medicineName}',
    );

    // Try remote API first if premium
    if (isPremium) {
      try {
        print('🌐 Calling remote API for premium user...');
        final remoteReservation = await _apiService.createReservation(
          userId: reservation.userId,
          pharmacyId: reservation.pharmacyId!,
          medicineName: reservation.medicineName!,
          day: reservation.day,
          time: reservation.time,
          quantity: reservation.quantity,
          isPremium: isPremium,
          medicineFindId: reservation.medicineFindId,
        );

        print('✅ Remote reservation response: $remoteReservation');

        // Also save locally
        final db = await _database;
        return await db.insert(
          DBReservationTable.table,
          reservation.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      } catch (e) {
        print('❌ Remote reservation failed, saving locally: $e');
      }
    } else {
      print('📱 User is not premium, saving locally only');
    }

    // Fallback to local only
    final db = await _database;
    return await db.insert(
      DBReservationTable.table,
      reservation.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Reservation>> getUserReservations(int userId) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
      DBReservationTable.table,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'day DESC, time DESC',
    );

    return List.generate(maps.length, (i) {
      return Reservation.fromMap(maps[i]);
    });
  }

  Future<Reservation?> getReservationById(int reservationId) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
      DBReservationTable.table,
      where: 'reservation_id = ?',
      whereArgs: [reservationId],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return Reservation.fromMap(maps[0]);
  }

  Future<int> updateReservation(Reservation reservation) async {
    final db = await _database;
    return await db.update(
      DBReservationTable.table,
      reservation.toMap(),
      where: 'reservation_id = ?',
      whereArgs: [reservation.reservationId],
    );
  }

  Future<int> updateReservationStatus(
    int reservationId,
    String status, {
    bool isPremium = false,
    int? userId,
  }) async {
    print('🔄 updateReservationStatus called - isPremium: $isPremium');
    print('📋 Updating reservation $reservationId to status: $status');

    // Try remote API first if premium and userId is provided
    if (isPremium && userId != null) {
      try {
        print('🌐 Calling remote API to update status...');
        await _apiService.updateReservationStatus(
          reservationId: reservationId,
          status: status,
          userId: userId,
        );
        print('✅ Remote status update successful');
      } catch (e) {
        print('❌ Remote status update failed: $e');
      }
    }

    // Also update locally
    final db = await _database;
    return await db.update(
      DBReservationTable.table,
      {'status': status},
      where: 'reservation_id = ?',
      whereArgs: [reservationId],
    );
  }

  Future<int> deleteReservation(int reservationId) async {
    final db = await _database;
    return await db.delete(
      DBReservationTable.table,
      where: 'reservation_id = ?',
      whereArgs: [reservationId],
    );
  }

  Future<List<Reservation>> getPendingReservations(int userId) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
      DBReservationTable.table,
      where: 'user_id = ? AND status = ?',
      whereArgs: [userId, 'pending'],
      orderBy: 'day ASC, time ASC',
    );

    return List.generate(maps.length, (i) {
      return Reservation.fromMap(maps[i]);
    });
  }

  Future<void> clearAllReservations() async {
    final db = await _database;
    await db.delete(DBReservationTable.table);
  }
}
