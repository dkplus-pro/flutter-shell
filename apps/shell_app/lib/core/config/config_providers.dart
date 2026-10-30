import 'package:app_core/app_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'config_providers.g.dart';

/// Application environment. Overridden once in `bootstrap.dart`; the default
/// throws so a missing override is caught immediately instead of silently
/// running with the wrong environment.
@Riverpod(keepAlive: true)
AppEnv appEnv(Ref ref) => throw StateError('Override in bootstrap');
