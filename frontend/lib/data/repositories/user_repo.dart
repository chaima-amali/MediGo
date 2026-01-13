import 'package:sqflite/sqflite.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../databases/db_helper.dart';
import '../databases/db_user.dart';
import '../models/user.dart';
import '../services/api/user_api_service.dart';

class UserRepository {
  final UserApiService _apiService = UserApiService();

  // Get database instance
  Future<Database> get _db async => await DBHelper.getDatabase();

  // CREATE - Insert a new user
  Future<int> insertUser(User user) async {
    final db = await _db;
    final userData = user.toMap();
    print('💾 Inserting user data: $userData');

    final userId = await db.insert(
      DBUserTable.table,
      userData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print('✅ User inserted with ID: $userId');
    return userId;
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
    final userData = user.toMap();

    // Try to update with all fields
    try {
      return await db.update(
        DBUserTable.table,
        userData,
        where: 'user_id = ?',
        whereArgs: [user.userId],
      );
    } catch (e) {
      // If location_name column doesn't exist (old database), try without it
      if (e.toString().contains('location_name')) {
        print('⚠️ Updating without location_name column (old database schema)');
        userData.remove('location_name');
        return await db.update(
          DBUserTable.table,
          userData,
          where: 'user_id = ?',
          whereArgs: [user.userId],
        );
      }
      rethrow;
    }
  }

  // UPDATE - Update user location
  Future<int> updateUserLocation(
    int userId,
    double latitude,
    double longitude, {
    String? locationName,
  }) async {
    final db = await _db;
    final updateData = {
      'latitude': latitude,
      'longitude': longitude,
      if (locationName != null) 'location_name': locationName,
    };
    return await db.update(
      DBUserTable.table,
      updateData,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // UPDATE - Update user premium status (Remote-first)
  Future<int> updateUserPremium(int userId, bool premium) async {
    try {
      // Check internet connection
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        print('☁️ Updating premium status remotely...');

        final response = await _apiService.updateUserPremium(userId, premium);

        if (response['success'] == true && response['user'] != null) {
          print('✅ Premium status updated remotely');

          // Sync to local database
          final db = await _db;
          final result = await db.update(
            DBUserTable.table,
            {'premium': premium ? 1 : 0},
            where: 'user_id = ?',
            whereArgs: [userId],
          );
          print('💾 Premium status synced to local DB');
          return result;
        }
      }
    } catch (e) {
      print('❌ Remote premium update failed: $e');
    }

    // Fallback to local update only
    print('💾 Updating premium status locally only...');
    final db = await _db;
    return await db.update(
      DBUserTable.table,
      {'premium': premium ? 1 : 0},
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
    print('🔍 Checking if email exists: $email');
    final List<Map<String, dynamic>> maps = await db.query(
      DBUserTable.table,
      where: 'email = ?',
      whereArgs: [email],
    );
    print('📊 Found ${maps.length} users with email: $email');
    if (maps.isNotEmpty) {
      print('👤 Existing user data: ${maps.first}');
    }
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

    // Hash the provided password to compare with stored hash
    final hashedPassword = sha256.convert(utf8.encode(password)).toString();

    print('🔐 Authenticating: email=$email, password=$password');
    print('🔒 Hashed password: $hashedPassword');

    final List<Map<String, dynamic>> maps = await db.query(
      DBUserTable.table,
      where: 'email = ? AND password = ?',
      whereArgs: [email, hashedPassword],
    );
    print('📊 Authentication query returned ${maps.length} results');

    if (maps.isEmpty) {
      print('❌ No user found with provided credentials');
      return null;
    }
    print('✅ Authentication successful');
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
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM ${DBUserTable.table}',
    );
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

  // DELETE - Delete user by phone
  Future<int> deleteUserByPhone(String phone) async {
    final db = await _db;
    print('🗑️ Deleting user with phone: $phone');
    final count = await db.delete(
      DBUserTable.table,
      where: 'phone = ?',
      whereArgs: [phone],
    );
    print('✅ Deleted $count user(s) with phone: $phone');
    return count;
  }
}
