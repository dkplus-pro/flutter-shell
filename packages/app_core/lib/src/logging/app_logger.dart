import 'dart:developer' as developer;

import 'package:logging/logging.dart';

/// Structured logger on top of `package:logging`.
///
/// Levels: dev = ALL, prod = INFO. Output goes through `dart:developer` log
/// so it surfaces in DevTools and `flutter run` consoles. Never log PII.
final class AppLogger {
  new _(this._tag, this._level);

  /// Creates the app-level logger. Must be called exactly once from the
  /// composition root before any child logger is created.
  factory create({required bool isProd}) {
    if (!_rootConfigured) {
      Logger.root.level = isProd ? Level.INFO : Level.ALL;
      Logger.root.onRecord.listen((record) {
        developer.log(
          record.message,
          name: record.loggerName,
          level: record.level.value,
          error: record.error,
          stackTrace: record.stackTrace,
        );
      });
      _rootConfigured = true;
    }
    return AppLogger._('app', Logger.root.level);
  }

  final String _tag;
  final Level _level;

  static bool _rootConfigured = false;

  /// Returns a namespaced logger, e.g. `logger.child('bridge')`.
  AppLogger child(String tag) => AppLogger._('${_tag}_$tag', _level);

  void info(String message) => _log(Level.INFO, message);

  void warning(String message, {Object? error, StackTrace? stackTrace}) {
    _log(Level.WARNING, message, error: error, stackTrace: stackTrace);
  }

  void error(String message, {Object? error, StackTrace? stackTrace}) {
    _log(Level.SEVERE, message, error: error, stackTrace: stackTrace);
  }

  void debug(String message) => _log(Level.FINE, message);

  void _log(
    Level level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (level < _level) {
      return;
    }
    developer.log(
      message,
      name: _tag,
      level: level.value,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
