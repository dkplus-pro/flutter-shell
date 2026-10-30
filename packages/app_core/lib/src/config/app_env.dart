/// Application environment resolved from compile-time `--dart-define` values.
enum AppEnv {
  dev,
  prod;

  /// Parses a raw value; unknown values fail loudly instead of silently
  /// falling back to a wrong environment.
  static AppEnv parse(String raw) {
    return AppEnv.values.firstWhere(
      (env) => env.name == raw,
      orElse: () => throw ArgumentError.value(
        raw,
        'APP_ENV',
        'Expected dev|prod',
      ),
    );
  }

  static AppEnv fromDartDefine() =>
      parse(const String.fromEnvironment('APP_ENV', defaultValue: 'dev'));

  bool get isProd => this == AppEnv.prod;

  /// Placeholder base URL; real backends must be injected per environment and
  /// never committed as secrets.
  String get apiBaseUrl => const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'https://api.example.invalid',
      );
}
