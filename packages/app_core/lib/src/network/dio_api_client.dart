import 'package:app_core/src/error/app_failure.dart';
import 'package:app_core/src/network/api_client.dart';
import 'package:dio/dio.dart';

/// Dio-backed [ApiClient] with 10s timeouts and 2xx-only success.
class DioApiClient implements ApiClient {
  new({required String baseUrl, Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ),
          );

  final Dio _dio;

  @override
  Future<Map<String, Object?>> getJson(
    Uri uri, {
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.getUri<Object?>(
        uri,
        options: Options(headers: headers),
      );
      final data = response.data;
      if (data is Map) {
        return data.cast<String, Object?>();
      }
      throw NetworkFailure(
        'Unexpected response from ${uri.host}',
        cause: 'status=${response.statusCode} type=${data.runtimeType}',
      );
    } on DioException catch (error) {
      throw NetworkFailure('Request to ${uri.host} failed', cause: error);
    } on NetworkFailure {
      rethrow;
    } on Exception catch (error) {
      throw NetworkFailure('Request to ${uri.host} failed', cause: error);
    }
  }
}
