import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:frontend/logic/cubits/user_cubit.dart';
import 'package:frontend/data/repositories/user_repo.dart';
import 'package:frontend/data/models/user.dart';

@GenerateMocks([UserRepository])
import 'user_cubit_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late UserCubit userCubit;
  late MockUserRepository mockRepository;

  setUp(() {
    mockRepository = MockUserRepository();
    userCubit = UserCubit(mockRepository);
  });

  tearDown(() {
    userCubit.close();
  });

  group('UserCubit', () {
    final testUser = User(
      userId: 1,
      name: 'John Doe',
      email: 'john@example.com',
      phone: '1234567890',
      password: 'password123',
      gender: 'Male',
      dob: '1990-01-01',
      premium: false,
    );

    test('initial state is UserUnauthenticated', () {
      expect(userCubit.state, isA<UserUnauthenticated>());
    });

    group('registerUser', () {
      blocTest<UserCubit, UserState>(
        'emits [UserLoading, UserAuthenticated] when registration is successful',
        build: () {
          when(mockRepository.emailExists(any)).thenAnswer((_) async => false);
          when(mockRepository.phoneExists(any)).thenAnswer((_) async => false);
          when(mockRepository.insertUser(any)).thenAnswer((_) async => 1);
          when(
            mockRepository.getUserById(any),
          ).thenAnswer((_) async => testUser.copyWith(userId: 1));
          return userCubit;
        },
        act: (cubit) => cubit.registerUser(testUser),
        expect: () => [isA<UserLoading>(), isA<UserAuthenticated>()],
        verify: (_) {
          verify(mockRepository.insertUser(any)).called(greaterThan(0));
        },
      );

      blocTest<UserCubit, UserState>(
        'emits [UserLoading, UserError] when registration fails',
        build: () {
          when(mockRepository.emailExists(any)).thenAnswer((_) async => false);
          when(mockRepository.phoneExists(any)).thenAnswer((_) async => false);
          when(
            mockRepository.insertUser(any),
          ).thenThrow(Exception('Registration failed'));
          return userCubit;
        },
        act: (cubit) => cubit.registerUser(testUser),
        expect: () => [
          isA<UserLoading>(),
          isA<UserError>().having(
            (state) => state.error,
            'error message',
            contains('failed'),
          ),
        ],
      );
    });

    group('loginUser', () {
      blocTest<UserCubit, UserState>(
        'emits [UserLoading, UserAuthenticated] when login is successful',
        build: () {
          when(
            mockRepository.authenticateUser(any, any),
          ).thenAnswer((_) async => testUser);
          when(
            mockRepository.getUserByEmail(any),
          ).thenAnswer((_) async => testUser);
          return userCubit;
        },
        act: (cubit) => cubit.loginUser('john@example.com', 'password123'),
        expect: () => [isA<UserLoading>(), isA<UserAuthenticated>()],
      );

      blocTest<UserCubit, UserState>(
        'emits [UserLoading, UserError] when login fails with wrong credentials',
        build: () {
          when(
            mockRepository.authenticateUser(any, any),
          ).thenAnswer((_) async => null);
          return userCubit;
        },
        act: (cubit) => cubit.loginUser('john@example.com', 'wrongpassword'),
        expect: () => [
          isA<UserLoading>(),
          isA<UserError>().having(
            (state) => state.error,
            'error message',
            contains('Invalid'),
          ),
        ],
      );
    });

    group('getUserById', () {
      blocTest<UserCubit, UserState>(
        'emits [UserLoading, UserLoaded] when user is fetched successfully',
        build: () {
          when(
            mockRepository.getUserById(any),
          ).thenAnswer((_) async => testUser);
          return userCubit;
        },
        act: (cubit) => cubit.getUserById(1),
        expect: () => [
          isA<UserLoading>(),
          isA<UserLoaded>().having((state) => state.user.userId, 'user id', 1),
        ],
      );

      blocTest<UserCubit, UserState>(
        'emits [UserLoading, UserError] when user is not found',
        build: () {
          when(mockRepository.getUserById(any)).thenAnswer((_) async => null);
          return userCubit;
        },
        act: (cubit) => cubit.getUserById(999),
        expect: () => [
          isA<UserLoading>(),
          isA<UserError>().having(
            (state) => state.error,
            'error message',
            contains('not found'),
          ),
        ],
      );
    });

    group('updateUser', () {
      blocTest<UserCubit, UserState>(
        'emits [UserLoading, UserOperationSuccess] when update is successful',
        build: () {
          when(mockRepository.updateUser(any)).thenAnswer((_) async => 1);
          when(
            mockRepository.getUserById(any),
          ).thenAnswer((_) async => testUser);
          return userCubit;
        },
        act: (cubit) => cubit.updateUser(testUser),
        expect: () => [isA<UserLoading>(), isA<UserOperationSuccess>()],
      );

      blocTest<UserCubit, UserState>(
        'emits [UserLoading, UserError] when update fails',
        build: () {
          when(
            mockRepository.updateUser(any),
          ).thenThrow(Exception('Update failed'));
          return userCubit;
        },
        act: (cubit) => cubit.updateUser(testUser),
        expect: () => [
          isA<UserLoading>(),
          isA<UserError>().having(
            (state) => state.error,
            'error message',
            contains('Update failed'),
          ),
        ],
      );
    });

    group('logoutUser', () {
      blocTest<UserCubit, UserState>(
        'emits UserUnauthenticated when logout is called',
        build: () => userCubit,
        act: (cubit) => cubit.logoutUser(),
        expect: () => [isA<UserUnauthenticated>()],
      );
    });

    group('getAllUsers', () {
      blocTest<UserCubit, UserState>(
        'emits [UserLoading, UserListLoaded] when users are fetched',
        build: () {
          when(
            mockRepository.getAllUsers(),
          ).thenAnswer((_) async => [testUser]);
          return userCubit;
        },
        act: (cubit) => cubit.getAllUsers(),
        expect: () => [
          isA<UserLoading>(),
          isA<UserListLoaded>().having(
            (state) => state.users.length,
            'users count',
            1,
          ),
        ],
      );
    });
  });
}
