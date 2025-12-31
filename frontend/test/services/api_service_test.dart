import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:frontend/data/services/api_service.dart';

@GenerateMocks([Dio])
import 'api_service_test.mocks.dart';

void main() {
  late ApiService apiService;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    apiService = ApiService();
  });

  group('ApiService', () {
    test('should initialize with correct base URL', () {
      apiService.initialize();
      // Add assertions
    });

    test('should handle successful GET request', () async {
      // Arrange
      // final response = Response(
      //   requestOptions: RequestOptions(path: '/test'),
      //   data: {'success': true},
      //   statusCode: 200,
      // );
      // when(mockDio.get(any)).thenAnswer((_) async => response);

      // Act
      // final result = await apiService.get('/test');

      // Assert
      // expect(result.data['success'], true);
    });

    test('should handle network error', () async {
      // Test error handling
    });
  });
}
