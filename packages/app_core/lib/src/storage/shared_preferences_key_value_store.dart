import 'package:app_core/src/error/app_failure.dart';
import 'package:app_core/src/storage/key_value_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Implements the app-level [KeyValueStore] contract with an `app.` prefix
/// on all keys. with an `app.` prefix on all keys.
class SharedPreferencesKeyValueStore implements KeyValueStore {
  new({this._prefs});

  SharedPreferences? _prefs;

  static const String _prefix = 'app.';

  Future<SharedPreferences> _instance() async {
    try {
      return _prefs ??= await SharedPreferences.getInstance();
    } on Exception catch (error) {
      throw StorageFailure('Failed to open key-value store', cause: error);
    }
  }

  @override
  Future<String?> read(String key) async {
    try {
      final prefs = await _instance();
      return prefs.getString('$_prefix$key');
    } on StorageFailure {
      rethrow;
    } on Exception catch (error) {
      throw StorageFailure('Failed to read "$key"', cause: error);
    }
  }

  @override
  Future<void> write(String key, String value) async {
    try {
      final prefs = await _instance();
      await prefs.setString('$_prefix$key', value);
    } on StorageFailure {
      rethrow;
    } on Exception catch (error) {
      throw StorageFailure('Failed to write "$key"', cause: error);
    }
  }

  @override
  Future<void> delete(String key) async {
    try {
      final prefs = await _instance();
      await prefs.remove('$_prefix$key');
    } on StorageFailure {
      rethrow;
    } on Exception catch (error) {
      throw StorageFailure('Failed to delete "$key"', cause: error);
    }
  }
}
