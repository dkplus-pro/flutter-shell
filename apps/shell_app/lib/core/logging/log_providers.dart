import 'package:app_core/app_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'log_providers.g.dart';

/// App-level logger. Overridden once in `bootstrap.dart`; keepAlive because
/// the logger lives as long as the process and its root sink is installed
/// exactly once by [AppLogger.create].
@Riverpod(keepAlive: true)
AppLogger appLogger(Ref ref) => throw StateError('Override in bootstrap');
