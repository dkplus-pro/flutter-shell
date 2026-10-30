import 'package:app_core/app_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'storage_providers.g.dart';

/// Placeholder key-value store; no business calls in v0. keepAlive: the
/// store caches a SharedPreferences instance for the app lifetime.
@Riverpod(keepAlive: true)
KeyValueStore keyValueStore(Ref ref) {
  return SharedPreferencesKeyValueStore();
}
