/// Minimal JSON HTTP abstraction; v0 is a placeholder with no business
/// callers. Implementations must map failures to NetworkFailure.
abstract class ApiClient {
  Future<Map<String, Object?>> getJson(
    Uri uri, {
    Map<String, String>? headers,
  });
}
