/// Pigeon-based Flutter <-> native bridge.
///
/// Exports only the wrapper and data types; generated APIs stay internal.
library;

export 'src/bridge_exception.dart';
export 'src/generated/shell_api.g.dart' show NativeScreenResult, SystemInfo;
export 'src/shell_bridge.dart';
