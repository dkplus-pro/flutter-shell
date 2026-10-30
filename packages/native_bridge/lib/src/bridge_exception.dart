/// Error thrown by the bridge wrapper.
///
/// `code`/`message`/`details` come from the platform error when one exists;
/// unexpected Dart-side failures are normalized to `BRIDGE_FAILURE`.
final class BridgeException implements Exception {
  const new(this.code, this.message, [this.details]);

  final String code;
  final String message;
  final Object? details;

  @override
  String toString() => 'BridgeException($code, $message)';
}
