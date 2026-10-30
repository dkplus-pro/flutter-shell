import 'package:native_bridge/native_bridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bridge_providers.g.dart';

/// Native bridge instance. Overridden once in `bootstrap.dart`; keepAlive
/// because the wrapper owns the process-wide FlutterApi registration and the
/// result stream for the whole engine lifetime.
@Riverpod(keepAlive: true)
NativeBridge nativeBridge(Ref ref) => throw StateError('Override in bootstrap');
