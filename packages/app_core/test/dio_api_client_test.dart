import 'dart:convert';
import 'dart:typed_data';

import 'package:app_core/app_core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fake adapter returning canned responses; no real network involved.
class _FakeAdapter implements HttpClientAdapter {
  new(this._statusCode, this._body);

  final int _statusCode;
  final Object? _body;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      jsonEncode(_body),
      _statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

Uri _uri(String path) => Uri.parse('https://api.example.invalid$path');

void main() {
  test('returns decoded JSON map on 200', () async {
    final dio = Dio(
      BaseOptions(baseUrl: 'https://api.example.invalid'),
    )..httpClientAdapter = _FakeAdapter(200, <String, Object?>{'ok': true});
    final client = DioApiClient(
      baseUrl: 'https://api.example.invalid',
      dio: dio,
    );

    final result = await client.getJson(_uri('/data'));

    expect(result, <String, Object?>{'ok': true});
  });

  test('maps non-JSON body to NetworkFailure', () async {
    final dio = Dio(
      BaseOptions(baseUrl: 'https://api.example.invalid'),
    )..httpClientAdapter = _FakeAdapter(200, <String>['not', 'a', 'map']);
    final client = DioApiClient(
      baseUrl: 'https://api.example.invalid',
      dio: dio,
    );

    await expectLater(
      client.getJson(_uri('/data')),
      throwsA(isA<NetworkFailure>()),
    );
  });

  test('maps HTTP 500 DioException to NetworkFailure', () async {
    final dio = Dio(
      BaseOptions(baseUrl: 'https://api.example.invalid'),
    )..httpClientAdapter = _FakeAdapter(500, <String, Object?>{'e': 1});
    final client = DioApiClient(
      baseUrl: 'https://api.example.invalid',
      dio: dio,
    );

    await expectLater(
      client.getJson(_uri('/data')),
      throwsA(
        isA<NetworkFailure>().having(
          (f) => f.cause,
          'cause',
          isA<DioException>(),
        ),
      ),
    );
  });

  test('maps connection error to NetworkFailure', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://127.0.0.1:1'));
    final client = DioApiClient(baseUrl: 'https://127.0.0.1:1', dio: dio);

    await expectLater(
      client.getJson(Uri.parse('https://127.0.0.1:1/x')),
      throwsA(isA<NetworkFailure>()),
    );
  });
}
