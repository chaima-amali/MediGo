import 'package:frontend/data/databases/db_helper.dart';
import 'package:frontend/data/databases/db_reservation.dart';
import 'package:frontend/data/models/reservation.dart';
import 'package:sqflite/sqflite.dart';

class ReservationRepository {
  Future<Database> get _database async => await DBHelper.getDatabase();

  Future<int> createReservation(Reservation reservation) async {
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

  Future<int> updateReservationStatus(int reservationId, String status) async {
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
