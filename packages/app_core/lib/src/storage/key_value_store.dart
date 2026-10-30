/// Key-value storage abstraction; v0 backed by shared_preferences.
abstract class KeyValueStore {
  Future<String?> read(String key);

  Future<void> write(String key, String value);

  Future<void> delete(String key);
}
