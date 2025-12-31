import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend/config/environment.dart';

/// Supabase Service for real-time database and authentication
class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  SupabaseClient? _client;
  SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase not initialized. Call initialize() first.');
    }
    return _client!;
  }

  /// Initialize Supabase
  Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: Environment.supabaseUrl,
        anonKey: Environment.supabaseAnonKey,
        debug: kDebugMode,
      );

      _client = Supabase.instance.client;
      debugPrint('✅ Supabase initialized successfully');

      // Set up auth state listener
      _setupAuthListener();
    } catch (e) {
      debugPrint('❌ Supabase initialization error: $e');
      rethrow;
    }
  }

  /// Set up authentication state listener
  void _setupAuthListener() {
    client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        debugPrint('👤 User authenticated: ${session.user.id}');
      } else {
        debugPrint('👤 User signed out');
      }
    });
  }

  // ============ AUTHENTICATION ============

  /// Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? userData,
  }) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: userData,
      );
      debugPrint('✅ User signed up: ${response.user?.id}');
      return response;
    } catch (e) {
      debugPrint('❌ Sign up error: $e');
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      debugPrint('✅ User signed in: ${response.user?.id}');
      return response;
    } catch (e) {
      debugPrint('❌ Sign in error: $e');
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await client.auth.signOut();
      debugPrint('✅ User signed out');
    } catch (e) {
      debugPrint('❌ Sign out error: $e');
      rethrow;
    }
  }

  /// Get current user
  User? getCurrentUser() {
    return client.auth.currentUser;
  }

  /// Check if user is authenticated
  bool isAuthenticated() {
    return client.auth.currentUser != null;
  }

  // ============ DATABASE OPERATIONS ============

  /// Generic query method
  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? select,
    Map<String, dynamic>? filters,
    String? orderBy,
    bool ascending = true,
    int? limit,
  }) async {
    try {
      var query = client.from(table).select(select ?? '*');

      if (filters != null) {
        filters.forEach((key, value) {
          query = query.eq(key, value);
        });
      }

      if (orderBy != null) {
        query = query.order(orderBy, ascending: ascending);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('❌ Query error on $table: $e');
      rethrow;
    }
  }

  /// Insert data
  Future<List<Map<String, dynamic>>> insert(
    String table,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await client.from(table).insert(data).select();
      debugPrint('✅ Inserted into $table');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('❌ Insert error on $table: $e');
      rethrow;
    }
  }

  /// Update data
  Future<List<Map<String, dynamic>>> update(
    String table,
    Map<String, dynamic> data, {
    required Map<String, dynamic> filters,
  }) async {
    try {
      var query = client.from(table).update(data);

      filters.forEach((key, value) {
        query = query.eq(key, value);
      });

      final response = await query.select();
      debugPrint('✅ Updated $table');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('❌ Update error on $table: $e');
      rethrow;
    }
  }

  /// Delete data
  Future<void> delete(
    String table, {
    required Map<String, dynamic> filters,
  }) async {
    try {
      var query = client.from(table).delete();

      filters.forEach((key, value) {
        query = query.eq(key, value);
      });

      await query;
      debugPrint('✅ Deleted from $table');
    } catch (e) {
      debugPrint('❌ Delete error on $table: $e');
      rethrow;
    }
  }

  // ============ REAL-TIME SUBSCRIPTIONS ============

  /// Subscribe to real-time changes
  RealtimeChannel subscribe(
    String table, {
    required void Function(PostgresChangePayload) onInsert,
    required void Function(PostgresChangePayload) onUpdate,
    required void Function(PostgresChangePayload) onDelete,
  }) {
    final channel = client
        .channel('public:$table')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: table,
          callback: onInsert,
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: table,
          callback: onUpdate,
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: table,
          callback: onDelete,
        )
        .subscribe();

    debugPrint('📡 Subscribed to real-time updates on $table');
    return channel;
  }

  /// Unsubscribe from channel
  Future<void> unsubscribe(RealtimeChannel channel) async {
    await client.removeChannel(channel);
    debugPrint('📡 Unsubscribed from channel');
  }

  // ============ STORAGE ============

  /// Upload file to storage
  Future<String> uploadFile(
    String bucket,
    String path,
    List<int> fileBytes, {
    Map<String, String>? headers,
  }) async {
    try {
      final response = await client.storage
          .from(bucket)
          .uploadBinary(
            path,
            fileBytes,
            fileOptions: FileOptions(
              upsert: true,
              contentType: headers?['content-type'],
            ),
          );

      final url = client.storage.from(bucket).getPublicUrl(path);
      debugPrint('✅ File uploaded: $url');
      return url;
    } catch (e) {
      debugPrint('❌ File upload error: $e');
      rethrow;
    }
  }

  /// Download file from storage
  Future<List<int>> downloadFile(String bucket, String path) async {
    try {
      final response = await client.storage.from(bucket).download(path);
      debugPrint('✅ File downloaded from $bucket/$path');
      return response;
    } catch (e) {
      debugPrint('❌ File download error: $e');
      rethrow;
    }
  }

  /// Delete file from storage
  Future<void> deleteFile(String bucket, List<String> paths) async {
    try {
      await client.storage.from(bucket).remove(paths);
      debugPrint('✅ Files deleted from $bucket');
    } catch (e) {
      debugPrint('❌ File delete error: $e');
      rethrow;
    }
  }

  /// Get public URL for file
  String getPublicUrl(String bucket, String path) {
    return client.storage.from(bucket).getPublicUrl(path);
  }
}
