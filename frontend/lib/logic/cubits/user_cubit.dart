import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
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

  UserCubit(this.userRepository) : super(UserInitial());

  // Register new user
  Future<void> registerUser(User user) async {
    try {
      emit(UserLoading());

      // Check if email already exists
      final emailExists = await userRepository.emailExists(user.email);
      if (emailExists) {
        emit(const UserError('Email already registered'));
        return;
      }

      // Check if phone already exists
      final phoneExists = await userRepository.phoneExists(user.phone);
      if (phoneExists) {
        emit(const UserError('Phone number already registered'));
        return;
      }

      // Insert user
      await userRepository.insertUser(user);
      emit(const UserOperationSuccess('User registered successfully'));
    } catch (e) {
      emit(UserError('Failed to register user: $e'));
    }
  }

  // Login user
  Future<void> loginUser(String email, String password) async {
    try {
      emit(UserLoading());

      print('🔐 Attempting login for: $email');
      final user = await userRepository.authenticateUser(email, password);
      if (user != null) {
        print('✅ Login successful: ${user.name} (ID: ${user.userId})');
        print('📍 User location: Lat=${user.latitude}, Lon=${user.longitude}');
        emit(UserAuthenticated(user));
      } else {
        print('❌ Login failed: Invalid credentials');
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
  Future<void> updateUserLocation(int userId, double latitude, double longitude, {String? locationName}) async {
    try {
      emit(UserLoading());

      print('🔄 Updating location for user $userId: ($latitude, $longitude) - $locationName');
      final result = await userRepository.updateUserLocation(userId, latitude, longitude, locationName: locationName);
      print('💾 Update result: $result rows affected');
      if (result > 0) {
        print('✅ Location updated successfully');
        emit(const UserOperationSuccess('Location updated successfully'));
        // Reload user
        final user = await userRepository.getUserById(userId);
        if (user != null) {
          print('👤 User reloaded: Lat=${user.latitude}, Lon=${user.longitude}');
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
        emit(const UserOperationSuccess('Premium status updated successfully'));
        // Reload user
        final user = await userRepository.getUserById(userId);
        if (user != null) {
          emit(UserLoaded(user));
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
  void logoutUser() {
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
}
