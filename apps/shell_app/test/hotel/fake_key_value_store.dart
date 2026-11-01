import 'package:app_core/app_core.dart';

/// In-memory [KeyValueStore] for unit tests: same async contract, no
/// shared_preferences plugin involved.
class FakeKeyValueStore implements KeyValueStore {
  final Map<String, String> _values = <String, String>{};

  /// Direct read for assertions on the persisted payloads.
  Map<String, String> get values => _values;

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async {
    _values[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _values.remove(key);
  }
}
