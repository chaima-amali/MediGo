import 'package:sqflite/sqflite.dart';
import '../databases/db_helper.dart';
import '../databases/db_user.dart';
import '../models/user.dart';

class UserRepository {
  // Get database instance
  Future<Database> get _db async => await DBHelper.getDatabase();

  // CREATE - Insert a new user
  Future<int> insertUser(User user) async {
    final db = await _db;
    return await db.insert(
      DBUserTable.table,
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // READ - Get user by ID
  Future<User?> getUserById(int userId) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      DBUserTable.table,
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  // READ - Get user by email
  Future<User?> getUserByEmail(String email) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      DBUserTable.table,
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  // READ - Get user by phone
  Future<User?> getUserByPhone(String phone) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      DBUserTable.table,
      where: 'phone = ?',
      whereArgs: [phone],
    );

    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  // READ - Get all users
  Future<List<User>> getAllUsers() async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(DBUserTable.table);
    
    return List.generate(maps.length, (i) {
      return User.fromMap(maps[i]);
    });
  }

  // UPDATE - Update user information
  Future<int> updateUser(User user) async {
    final db = await _db;
    return await db.update(
      DBUserTable.table,
      user.toMap(),
      where: 'user_id = ?',
      whereArgs: [user.userId],
    );
  }

  // UPDATE - Update user location
  Future<int> updateUserLocation(int userId, double latitude, double longitude) async {
    final db = await _db;
    return await db.update(
      DBUserTable.table,
      {'latitude': latitude, 'longitude': longitude},
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // UPDATE - Update user premium status
  Future<int> updateUserPremium(int userId, String premium) async {
    final db = await _db;
    return await db.update(
      DBUserTable.table,
      {'premium': premium},
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // DELETE - Delete user by ID
  Future<int> deleteUser(int userId) async {
    final db = await _db;
    return await db.delete(
      DBUserTable.table,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // CHECK - Check if email exists
  Future<bool> emailExists(String email) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      DBUserTable.table,
      where: 'email = ?',
      whereArgs: [email],
    );
    return maps.isNotEmpty;
  }

  // CHECK - Check if phone exists
  Future<bool> phoneExists(String phone) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      DBUserTable.table,
      where: 'phone = ?',
      whereArgs: [phone],
    );
    return maps.isNotEmpty;
  }

  // AUTHENTICATION - Verify user credentials
  Future<User?> authenticateUser(String email, String password) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      DBUserTable.table,
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  // UTILITY - Get premium users
  Future<List<User>> getPremiumUsers() async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      DBUserTable.table,
      where: 'premium = ?',
      whereArgs: ['true'],
    );
    
    return List.generate(maps.length, (i) {
      return User.fromMap(maps[i]);
    });
  }

  // UTILITY - Count total users
  Future<int> getUserCount() async {
    final db = await _db;
    final result = await db.rawQuery('SELECT COUNT(*) FROM ${DBUserTable.table}');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // UTILITY - Clear all users (for testing)
  Future<int> deleteAllUsers() async {
    final db = await _db;
    return await db.delete(DBUserTable.table);
  }

  // DELETE - Delete user by email
  Future<int> deleteUserByEmail(String email) async {
    final db = await _db;
    return await db.delete(
      DBUserTable.table,
      where: 'email = ?',
      whereArgs: [email],
    );
  }

  // DELETE - Delete user by ID
  Future<int> deleteUserById(int userId) async {
    final db = await _db;
    return await db.delete(
      DBUserTable.table,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }
}
