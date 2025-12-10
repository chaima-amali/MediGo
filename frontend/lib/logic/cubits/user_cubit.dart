import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user.dart';
import '../../data/repositories/user_repo.dart';

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

  UserCubit(this.userRepository) : super(UserInitial()) {
    restoreSession();
  }

  // Register new user
  Future<void> registerUser(User user) async {
    try {
      emit(UserLoading());

      print('📝 Attempting to register user: ${user.email}');

      // Check if email already exists
      final emailExists = await userRepository.emailExists(user.email);
      print('📧 Email exists check for ${user.email}: $emailExists');
      if (emailExists) {
        print('❌ Registration failed: Email already registered');
        emit(const UserError('Email already registered'));
        return;
      }

      // Check if phone already exists
      final phoneExists = await userRepository.phoneExists(user.phone);
      print('📱 Phone exists check for ${user.phone}: $phoneExists');
      if (phoneExists) {
        print('❌ Registration failed: Phone already registered');
        emit(const UserError('Phone number already registered'));
        return;
      }

      // Insert user
      print('💾 Inserting user into database...');
      final userId = await userRepository.insertUser(user);
      print('✅ User inserted with ID: $userId');

      // After successful registration, load the user to set authenticated state
      final registeredUser = await userRepository.getUserByEmail(user.email);
      if (registeredUser != null) {
        await _saveUserSession(registeredUser.userId!);
        emit(UserAuthenticated(registeredUser));
      } else {
        emit(const UserOperationSuccess('User registered successfully'));
      }
    } catch (e) {
      emit(UserError('Failed to register user: $e'));
    }
  }

  // Login user
  Future<void> loginUser(String email, String password) async {
    try {
      emit(UserLoading());

      print('🔐 Attempting login for: $email');
      print('🔑 Password provided: ${password.length} characters');
      final user = await userRepository.authenticateUser(email, password);
      if (user != null) {
        print('✅ Login successful: ${user.name} (ID: ${user.userId})');
        print('📍 User location: Lat=${user.latitude}, Lon=${user.longitude}');
        await _saveUserSession(user.userId!);
        emit(UserAuthenticated(user));
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
      emit(UserError('Login failed: $e'));
    }
  }

  // Get user by ID
  Future<void> getUserById(int userId) async {
    try {
      emit(UserLoading());

      final user = await userRepository.getUserById(userId);
      if (user != null) {
        emit(UserLoaded(user));
      } else {
        emit(const UserError('User not found'));
      }
    } catch (e) {
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

  // Update user
  Future<void> updateUser(User user) async {
    try {
      emit(UserLoading());

      final result = await userRepository.updateUser(user);
      if (result > 0) {
        emit(const UserOperationSuccess('User updated successfully'));
        // Reload user
        final updatedUser = await userRepository.getUserById(user.userId!);
        if (updatedUser != null) {
          emit(UserLoaded(updatedUser));
        }
      } else {
        emit(const UserError('Failed to update user'));
      }
    } catch (e) {
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
  Future<void> updateUserPremium(int userId, String premium) async {
    try {
      emit(UserLoading());

      final result = await userRepository.updateUserPremium(userId, premium);
      if (result > 0) {
        // Reload user
        final user = await userRepository.getUserById(userId);
        if (user != null) {
          emit(
            UserAuthenticated(user),
          ); // Keep user authenticated after premium upgrade
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

  // Restore user session on app start
  Future<void> restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      final userId = prefs.getInt('user_id');

      print('🔄 Restoring session: isLoggedIn=$isLoggedIn, userId=$userId');

      if (isLoggedIn && userId != null) {
        print('📂 Loading user from database...');
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
}
