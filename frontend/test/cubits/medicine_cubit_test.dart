import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:frontend/logic/cubits/medicine_cubit.dart';
import 'package:frontend/data/repositories/medicine_repository.dart';

@GenerateMocks([MedicineRepository])
import 'medicine_cubit_test.mocks.dart';

void main() {
  late MedicineCubit medicineCubit;
  late MockMedicineRepository mockRepository;

  setUp(() {
    mockRepository = MockMedicineRepository();
    // medicineCubit = MedicineCubit(mockRepository);
  });

  tearDown(() {
    // medicineCubit.close();
  });

  group('MedicineCubit', () {
    test('initial state is MedicineInitial', () {
      // expect(medicineCubit.state, isA<MedicineInitial>());
    });

    blocTest<MedicineCubit, MedicineState>(
      'emits [MedicineLoading, MedicineLoaded] when loadMedicines is successful',
      build: () {
        // when(mockRepository.getMedicines(any))
        //     .thenAnswer((_) async => [/* mock medicines */]);
        // return medicineCubit;
        return MedicineCubit(mockRepository); // Placeholder
      },
      act: (cubit) {}, // cubit.loadMedicines(userId: 1),
      expect: () => [], // [isA<MedicineLoading>(), isA<MedicineLoaded>()],
    );
  });
}
