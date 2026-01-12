import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user.dart';
import '../../data/repositories/user_repo.dart';
import '../../data/services/api_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// States
abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final User user;

  const UserLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

class UserListLoaded extends UserState {
  final List<User> users;

  const UserListLoaded(this.users);

  @override
  List<Object?> get props => [users];
}

class UserOperationSuccess extends UserState {
  final String message;

  const UserOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class UserError extends UserState {
  final String error;

  const UserError(this.error);

  @override
  List<Object?> get props => [error];
}

class UserAuthenticated extends UserState {
  final User user;

  const UserAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class UserUnauthenticated extends UserState {}

// Cubit
class UserCubit extends Cubit<UserState> {
  final UserRepository userRepository;
  final ApiService _apiService = ApiService();
  final Connectivity _connectivity = Connectivity();

  UserCubit(this.userRepository) : super(UserInitial()) {
    _apiService.initialize();
    restoreSession();
  }

  /// Check if device has internet connection
  Future<bool> _hasConnection() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      return !connectivityResult.contains(ConnectivityResult.none);
    } catch (e) {
      print('⚠️  Failed to check connectivity: $e');
      return false;
    }
  }

  // Register new user (Remote first, then local fallback)
  Future<void> registerUser(User user) async {
    try {
      emit(UserLoading());

      print('📝 Attempting to register user: ${user.email}');

      // Check internet connection
      final hasInternet = await _hasConnection();
      print('🌐 Internet connection: $hasInternet');

      if (hasInternet) {
        try {
          print('☁️ Attempting remote registration...');
          // Try remote registration first
          final response = await _apiService.register(user.toMap());

          if (response['success'] == true) {
            print('✅ Remote registration successful');
            final remoteUser = response['user'];

            // Create User object from remote response
            final registeredUser = User(
              userId: remoteUser['user_id'],
              name: remoteUser['name'],
              email: remoteUser['email'],
              phone: remoteUser['phone'],
              password: user.password, // Keep original password for local sync
              gender: remoteUser['gender'],
              dob: remoteUser['dob'],
              latitude: remoteUser['latitude'],
              longitude: remoteUser['longitude'],
              locationName: remoteUser['location_name'],
              premium: remoteUser['premium'],
            );

            // Save to local database for offline access
            try {
              print('💾 Syncing user to local database...');
              await userRepository.insertUser(registeredUser);
              print('✅ User synced to local database');
            } catch (localError) {
              print('⚠️  Failed to sync to local database: $localError');
              // Continue even if local sync fails
            }

            await _saveUserSession(registeredUser.userId!);
            emit(UserAuthenticated(registeredUser));
            return;
          } else {
            // Remote registration failed, try local
            print('⚠️  Remote registration failed: ${response['error']}');
            emit(UserError(response['error'] ?? 'Registration failed'));
            return;
          }
        } catch (apiError) {
          print('❌ Remote registration error: $apiError');
          print('📍 Falling back to local registration...');
        }
      }

      // Local registration (fallback or no internet)
      print('💾 Attempting local registration...');

      // Check if email already exists locally
      final emailExists = await userRepository.emailExists(user.email);
      print('📧 Email exists check for ${user.email}: $emailExists');
      if (emailExists) {
        print('❌ Registration failed: Email already registered locally');
        emit(const UserError('Email already registered'));
        return;
      }

      // Check if phone already exists locally
      final phoneExists = await userRepository.phoneExists(user.phone);
      print('📱 Phone exists check for ${user.phone}: $phoneExists');
      if (phoneExists) {
        // Delete the old entry (likely from a failed registration attempt)
        print('⚠️ Phone exists from previous attempt, deleting old entry...');
        await userRepository.deleteUserByPhone(user.phone);
        print('✅ Old entry deleted, proceeding with registration');
      }

      // Insert user locally
      print('💾 Inserting user into local database...');
      final userId = await userRepository.insertUser(user);
      print('✅ User inserted locally with ID: $userId');

      // Load the registered user
      final registeredUser = await userRepository.getUserByEmail(user.email);
      if (registeredUser != null) {
        await _saveUserSession(registeredUser.userId!);
        emit(UserAuthenticated(registeredUser));
      } else {
        emit(const UserOperationSuccess('User registered successfully'));
      }
    } catch (e) {
      print('❌ Registration error: $e');
      emit(UserError('Failed to register user: $e'));
    }
  }

  // Login user (Remote first, then local fallback)
  Future<void> loginUser(String email, String password) async {
    try {
      emit(UserLoading());

      print('🔐 Attempting login for: $email');

      // Check internet connection
      final hasInternet = await _hasConnection();
      print('🌐 Internet connection: $hasInternet');

      if (hasInternet) {
        try {
          print('☁️ Attempting remote login...');
          // Try remote login first
          final response = await _apiService.login(email, password);

          if (response['success'] == true) {
            print('✅ Remote login successful');
            final remoteUser = response['user'];

            // Create User object from remote response
            final user = User(
              userId: remoteUser['user_id'], // Changed from 'id' to 'user_id'
              name: remoteUser['name'],
              email: remoteUser['email'],
              phone: remoteUser['phone'],
              password: password, // Store password for local sync
              gender: remoteUser['gender'],
              dob: remoteUser['dob'],
              latitude: remoteUser['latitude'],
              longitude: remoteUser['longitude'],
              locationName: remoteUser['location_name'],
              premium: remoteUser['premium'] == 'false'
                  ? false
                  : (remoteUser['premium'] == 'true'
                        ? true
                        : remoteUser['premium']),
            );

            // Sync to local database
            try {
              print('💾 Syncing user to local database...');
              final localUser = await userRepository.getUserByEmail(email);
              if (localUser == null) {
                // User doesn't exist locally, insert
                await userRepository.insertUser(user);
                print('✅ User synced to local database');
              } else {
                // User exists locally, update
                await userRepository.updateUser(
                  user.copyWith(userId: localUser.userId),
                );
                print('✅ User updated in local database');
              }
            } catch (localError) {
              print('⚠️  Failed to sync to local database: $localError');
            }

            print(
              '📍 User location: Lat=${user.latitude}, Lon=${user.longitude}',
            );
            await _saveUserSession(user.userId!);
            emit(UserAuthenticated(user));
            return;
          } else {
            // Remote login failed
            print('⚠️  Remote login failed: ${response['error']}');
            emit(UserError(response['error'] ?? 'Login failed'));
            return;
          }
        } catch (apiError) {
          print('❌ Remote login error: $apiError');
          print('📍 Falling back to local login...');
        }
      }

      // Local login (fallback or no internet)
      print('💾 Attempting local login...');
      print('🔑 Password provided: ${password.length} characters');

      final user = await userRepository.authenticateUser(email, password);
      if (user != null) {
        print('✅ Local login successful: ${user.name} (ID: ${user.userId})');
        print('📍 User location: Lat=${user.latitude}, Lon=${user.longitude}');
        await _saveUserSession(user.userId!);
        emit(UserAuthenticated(user));

        // Try to sync to remote if user doesn't have a proper remote ID and internet is available
        if (hasInternet && (user.userId == null || user.userId! < 100)) {
          print('🔄 User might be local-only, attempting remote sync...');
          syncLocalUserToRemote(user);
        }
      } else {
        print('❌ Login failed: Invalid credentials');
        print('🔍 Checking if email exists...');
        final emailExists = await userRepository.emailExists(email);
        print('📧 Email exists: $emailExists');
        if (emailExists) {
          // Email exists but password wrong
          final userByEmail = await userRepository.getUserByEmail(email);
          if (userByEmail != null) {
            print(
              '👤 User found with email, stored password: ${userByEmail.password}',
            );
            print('🔐 Provided password: $password');
            print('❓ Passwords match: ${userByEmail.password == password}');
          }
        }
        emit(const UserError('Invalid email or password'));
      }
    } catch (e) {
      print('❌ Login error: $e');
      emit(UserError('Login failed: $e'));
    }
  }

  // Get user by ID (Try remote first, fallback to local)
  Future<void> getUserById(int userId) async {
    try {
      emit(UserLoading());

      print('📂 Loading user $userId...');
      final hasInternet = await _hasConnection();

      if (hasInternet) {
        try {
          print('☁️ Fetching user from remote...');
          final response = await _apiService.getUser(userId);

          if (response['user_id'] != null) {
            print('✅ User fetched from remote');
            // Create User object from remote response
            final user = User(
              userId: response['user_id'],
              name: response['name'],
              email: response['email'],
              phone: response['phone'],
              password: response['password'] ?? '',
              gender: response['gender'],
              dob: response['dob'],
              latitude: response['latitude'],
              longitude: response['longitude'],
              locationName: response['location_name'],
              premium: response['premium'] ?? 'false',
            );

            // Sync to local database
            try {
              await userRepository.updateUser(user);
              print('💾 User synced to local DB');
            } catch (e) {
              print('⚠️ Failed to sync to local: $e');
            }

            emit(UserLoaded(user));
            return;
          }
        } catch (e) {
          print('❌ Remote fetch failed: $e');
          print('📍 Falling back to local database...');
        }
      }

      // Fallback to local
      print('💾 Loading from local database...');
      final user = await userRepository.getUserById(userId);
      if (user != null) {
        print('✅ User loaded from local DB');
        emit(UserLoaded(user));
      } else {
        print('❌ User not found');
        emit(const UserError('User not found'));
      }
    } catch (e) {
      print('❌ Load user error: $e');
      emit(UserError('Failed to load user: $e'));
    }
  }

  // Get user by email
  Future<void> getUserByEmail(String email) async {
    try {
      emit(UserLoading());

      final user = await userRepository.getUserByEmail(email);
      if (user != null) {
        emit(UserLoaded(user));
      } else {
        emit(const UserError('User not found'));
      }
    } catch (e) {
      emit(UserError('Failed to load user: $e'));
    }
  }

  // Get all users
  Future<void> getAllUsers() async {
    try {
      emit(UserLoading());

      final users = await userRepository.getAllUsers();
      emit(UserListLoaded(users));
    } catch (e) {
      emit(UserError('Failed to load users: $e'));
    }
  }

  // Update user (Remote first, then local)
  Future<void> updateUser(User user) async {
    try {
      emit(UserLoading());

      print('🔄 Updating user ${user.userId}...');
      final hasInternet = await _hasConnection();

      if (hasInternet) {
        try {
          print('☁️ Updating user on remote...');
          // Create update payload excluding user_id, password, and created_at
          final updateData = user.toMap();
          updateData.remove('user_id');
          updateData.remove('password');
          updateData.remove('created_at');

          final response = await _apiService.updateUser(
            user.userId!,
            updateData,
          );

          if (response['user_id'] != null) {
            print('✅ User updated on remote');
            // Update local database
            await userRepository.updateUser(user);
            print('💾 User updated in local DB');

            // Reload user
            final updatedUser = await userRepository.getUserById(user.userId!);
            if (updatedUser != null) {
              print('✅ User reloaded successfully');
              emit(UserLoaded(updatedUser));
            } else {
              emit(const UserError('Failed to reload user'));
            }
            return;
          }
        } catch (e) {
          print('❌ Remote update failed: $e');

          // Check if error is 404 (user doesn't exist in Supabase)
          if (e.toString().contains('404')) {
            print('🆕 User not found in Supabase, creating new user...');
            try {
              // Register user in Supabase
              final registerResponse = await _apiService.register(user.toMap());

              if (registerResponse['success'] == true) {
                final remoteUser = registerResponse['user'];
                print(
                  '✅ User created in Supabase with ID: ${remoteUser['user_id']}',
                );

                // Update local user with remote ID
                final updatedUser = user.copyWith(
                  userId: remoteUser['user_id'],
                );
                await userRepository.deleteUserById(
                  user.userId!,
                ); // Delete old local-only user
                await userRepository.insertUser(
                  updatedUser,
                ); // Insert with Supabase ID

                // Save new session with Supabase ID
                await _saveUserSession(remoteUser['user_id']);

                print('✅ User synced to Supabase and local DB updated');
                emit(UserLoaded(updatedUser));
                return;
              }
            } catch (createError) {
              print('❌ Failed to create user in Supabase: $createError');
            }
          }

          print('📍 Updating local database only...');
        }
      }

      // Fallback to local update
      print('💾 Updating local database...');
      final result = await userRepository.updateUser(user);
      if (result > 0) {
        print('✅ User updated locally');
        // Reload user
        final updatedUser = await userRepository.getUserById(user.userId!);
        if (updatedUser != null) {
          emit(UserLoaded(updatedUser));
        }
      } else {
        print('❌ Failed to update user');
        emit(const UserError('Failed to update user'));
      }
    } catch (e) {
      print('❌ Update error: $e');
      emit(UserError('Update failed: $e'));
    }
  }

  // Update user location
  Future<void> updateUserLocation(
    int userId,
    double latitude,
    double longitude, {
    String? locationName,
  }) async {
    try {
      emit(UserLoading());

      print(
        '🔄 Updating location for user $userId: ($latitude, $longitude) - $locationName',
      );
      final result = await userRepository.updateUserLocation(
        userId,
        latitude,
        longitude,
        locationName: locationName,
      );
      print('💾 Update result: $result rows affected');
      if (result > 0) {
        print('✅ Location updated successfully');
        emit(const UserOperationSuccess('Location updated successfully'));
        // Reload user
        final user = await userRepository.getUserById(userId);
        if (user != null) {
          print(
            '👤 User reloaded: Lat=${user.latitude}, Lon=${user.longitude}',
          );
          emit(UserLoaded(user));
        }
      } else {
        print('❌ Failed to update location');
        emit(const UserError('Failed to update location'));
      }
    } catch (e) {
      emit(UserError('Location update failed: $e'));
    }
  }

  // Update premium status
  Future<void> updateUserPremium(int userId, bool premium) async {
    try {
      emit(UserLoading());

      print('💎 Updating premium status for user $userId to $premium');

      // Update with remote-first logic (repository handles it)
      final result = await userRepository.updateUserPremium(userId, premium);
      if (result > 0) {
        // Reload user
        final user = await userRepository.getUserById(userId);
        if (user != null) {
          emit(
            UserAuthenticated(user),
          ); // Keep user authenticated after premium upgrade
          print('✅ Premium status updated successfully');
        } else {
          emit(const UserError('Failed to reload user after premium update'));
        }
      } else {
        emit(const UserError('Failed to update premium status'));
      }
    } catch (e) {
      emit(UserError('Premium status update failed: $e'));
    }
  }

  // Delete user
  Future<void> deleteUser(int userId) async {
    try {
      emit(UserLoading());

      final result = await userRepository.deleteUser(userId);
      if (result > 0) {
        emit(const UserOperationSuccess('User deleted successfully'));
      } else {
        emit(const UserError('Failed to delete user'));
      }
    } catch (e) {
      emit(UserError('Delete failed: $e'));
    }
  }

  // Logout user
  Future<void> logoutUser() async {
    await _clearUserSession();
    emit(UserUnauthenticated());
  }

  // Get premium users
  Future<void> getPremiumUsers() async {
    try {
      emit(UserLoading());

      final users = await userRepository.getPremiumUsers();
      emit(UserListLoaded(users));
    } catch (e) {
      emit(UserError('Failed to load premium users: $e'));
    }
  }

  // Check if email exists
  Future<bool> checkEmailExists(String email) async {
    try {
      return await userRepository.emailExists(email);
    } catch (e) {
      emit(UserError('Failed to check email: $e'));
      return false;
    }
  }

  // Check if phone exists
  Future<bool> checkPhoneExists(String phone) async {
    try {
      return await userRepository.phoneExists(phone);
    } catch (e) {
      emit(UserError('Failed to check phone: $e'));
      return false;
    }
  }

  // Get user count
  Future<int> getUserCount() async {
    try {
      return await userRepository.getUserCount();
    } catch (e) {
      emit(UserError('Failed to get user count: $e'));
      return 0;
    }
  }

  // SESSION MANAGEMENT

  // Save user session
  Future<void> _saveUserSession(int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final previousUserId = prefs.getInt('user_id');

      // If switching to a different user, clear the previous user's medicine data
      if (previousUserId != null && previousUserId != userId) {
        print('🔄 Switching users: $previousUserId -> $userId');
        print('🗑️ Clearing previous user medicine data...');
        await DBHelper.clearUserMedicineData(previousUserId);
      }

      await prefs.setInt('user_id', userId);
      await prefs.setBool('is_logged_in', true);
      print('💾 User session saved: userId=$userId');
    } catch (e) {
      print('❌ Failed to save user session: $e');
    }
  }

  // Clear user session
  Future<void> _clearUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_id');
      await prefs.setBool('is_logged_in', false);
      print('🗑️ User session cleared');
    } catch (e) {
      print('❌ Failed to clear user session: $e');
    }
  }

  // Restore user session on app start (Try remote first, fallback to local)
  Future<void> restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      final userId = prefs.getInt('user_id');

      print('🔄 Restoring session: isLoggedIn=$isLoggedIn, userId=$userId');

      if (isLoggedIn && userId != null) {
        // Try to fetch from remote first if online
        final hasInternet = await _hasConnection();

        if (hasInternet) {
          try {
            print('☁️ Fetching user from remote...');
            final response = await _apiService.getUser(userId);

            if (response['user_id'] != null) {
              print('✅ User fetched from remote');
              // Create User object from remote response
              final user = User(
                userId: response['user_id'],
                name: response['name'],
                email: response['email'],
                phone: response['phone'],
                password: response['password'] ?? '',
                gender: response['gender'],
                dob: response['dob'],
                latitude: response['latitude'],
                longitude: response['longitude'],
                locationName: response['location_name'],
                premium: response['premium'] ?? 'false',
              );

              // Sync to local database
              try {
                await userRepository.updateUser(user);
                print('💾 User synced to local DB');
              } catch (e) {
                print('⚠️ Failed to sync to local: $e');
              }

              print('✅ Session restored for: ${user.name}');
              emit(UserAuthenticated(user));
              return;
            }
          } catch (e) {
            print('❌ Remote fetch failed: $e');
            print('📍 Falling back to local database...');
          }
        }

        // Fallback to local database
        print('📂 Loading user from local database...');
        final user = await userRepository.getUserById(userId);
        if (user != null) {
          print('✅ Session restored for: ${user.name}');
          emit(UserAuthenticated(user));
        } else {
          print('⚠️ User not found in database, clearing session');
          await _clearUserSession();
          emit(UserUnauthenticated());
        }
      } else {
        print('ℹ️ No active session found');
        emit(UserUnauthenticated());
      }
    } catch (e) {
      print('❌ Failed to restore session: $e');
      emit(UserUnauthenticated());
    }
  }

  /// Sync local user to remote server (Supabase)
  Future<void> syncLocalUserToRemote(User user) async {
    try {
      print('🔄 Syncing local user to remote server...');

      // Check internet connection
      final hasInternet = await _hasConnection();
      if (!hasInternet) {
        print('⚠️ No internet connection, cannot sync');
        return;
      }

      // Try to register user remotely
      try {
        final response = await _apiService.register(user.toMap());

        if (response['success'] == true) {
          print('✅ User synced to remote successfully');
          final remoteUser = response['user'];

          // Update local user with remote ID
          final updatedUser = user.copyWith(userId: remoteUser['id']);

          await userRepository.updateUser(updatedUser);
          emit(UserAuthenticated(updatedUser));
          print('✅ Local user updated with remote ID: ${remoteUser['id']}');
        } else {
          print('⚠️ Remote sync failed: ${response['error']}');
        }
      } catch (e) {
        print('❌ Error syncing to remote: $e');
      }
    } catch (e) {
      print('❌ Sync error: $e');
    }
  }
}
