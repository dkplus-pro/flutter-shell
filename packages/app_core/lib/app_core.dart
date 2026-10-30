/// Core infrastructure for the Flutter shell.
///
/// Exposes environment config, logging, the error model and the
/// network/storage abstractions. This package must stay free of Riverpod,
/// routing and UI concerns.
library;

export 'src/config/app_env.dart';
export 'src/error/app_failure.dart';
export 'src/logging/app_logger.dart';
export 'src/network/api_client.dart';
export 'src/network/dio_api_client.dart';
export 'src/storage/key_value_store.dart';
export 'src/storage/shared_preferences_key_value_store.dart';
