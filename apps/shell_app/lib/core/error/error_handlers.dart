import 'dart:ui';

import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';

/// Installs process-wide error handlers.
///
/// - `FlutterError.onError`: log, then keep default behaviour (red screen in
///   debug).
/// - `PlatformDispatcher.onError`: log and swallow to avoid crashes.
/// - `ErrorWidget.builder`: in release show a plain placeholder without stack
///   traces. It does not depend on l10n because it can fire before delegates
///   are available.
void installGlobalErrorHandlers(AppLogger logger, {required bool isProd}) {
  final previousFlutterOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    logger.error(
      'FlutterError: ${details.exception}',
      error: details.exception,
      stackTrace: details.stack,
    );
    previousFlutterOnError?.call(details);
  };

  PlatformDispatcher.instance.onError = (error, stackTrace) {
    logger.error(
      'Uncaught platform error: $error',
      error: error,
      stackTrace: stackTrace,
    );
    return true;
  };

  if (isProd) {
    ErrorWidget.builder = (details) => const SizedBox.shrink();
  }
}
