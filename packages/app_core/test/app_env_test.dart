import 'package:app_core/app_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses dev and prod', () {
    expect(AppEnv.parse('dev'), AppEnv.dev);
    expect(AppEnv.parse('prod'), AppEnv.prod);
    expect(AppEnv.dev.isProd, isFalse);
    expect(AppEnv.prod.isProd, isTrue);
  });

  test('rejects unknown values with ArgumentError', () {
    expect(() => AppEnv.parse('staging'), throwsArgumentError);
    expect(() => AppEnv.parse(''), throwsArgumentError);
  });

  test('apiBaseUrl falls back to placeholder', () {
    // Without --dart-define the placeholder host is used.
    expect(AppEnv.dev.apiBaseUrl, 'https://api.example.invalid');
  });
}
