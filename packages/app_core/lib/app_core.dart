/// Core infrastructure for the Flutter shell.
///
/// Exposes environment config, logging and the error model. Network/storage
/// abstractions land with their implementations and tests (P5).
library;

export 'src/config/app_env.dart';
export 'src/error/app_failure.dart';
export 'src/logging/app_logger.dart';
