import 'dart:async';

import 'package:flutter/services.dart';

import 'package:native_bridge/src/bridge_exception.dart';
import 'package:native_bridge/src/generated/shell_api.g.dart' as shell_api;

/// Factory producing the native ticker stream; injectable for tests.
typedef TickStreamFactory = Stream<int> Function();

/// Public facade over the Pigeon-generated APIs.
///
/// Callers depend only on this class (plus [BridgeException] and the two data
/// types); generated classes stay internal. `initialize()` must run once
/// before [ticks] so native screen results can be received.
final class NativeBridge {
  new({shell_api.ShellHostApi? hostApi, this._tickStreamFactory})
    : _hostApi = hostApi ?? shell_api.ShellHostApi();

  final shell_api.ShellHostApi _hostApi;
  final TickStreamFactory? _tickStreamFactory;
  final StreamController<shell_api.NativeScreenResult> _results =
      StreamController<shell_api.NativeScreenResult>.broadcast();
  bool _initialized = false;

  /// Idempotent; registers the FlutterApi handler. Must run before [ticks].
  void initialize() {
    if (_initialized) {
      return;
    }
    shell_api.ShellFlutterApi.setUp(_ResultHandler(this));
    _initialized = true;
  }

  bool get isInitialized => _initialized;

  Future<shell_api.SystemInfo> getSystemInfo() async {
    try {
      return await _hostApi.getSystemInfo();
    } on PlatformException catch (error) {
      throw BridgeException(error.code, error.message ?? '', error.details);
    } catch (error) {
      throw BridgeException(bridgeFailureCode, '$error', error);
    }
  }

  Stream<int> ticks() {
    if (!_initialized) {
      throw StateError(
        'NativeBridge.initialize() must be called before ticks()',
      );
    }
    final factory = _tickStreamFactory;
    if (factory != null) {
      return factory();
    }
    return shell_api.ticks();
  }

  /// Returns true when the native screen started; throws [BridgeException]
  /// otherwise.
  Future<bool> openNativeScreen({
    required String title,
    required String message,
  }) async {
    try {
      return await _hostApi.openNativeScreen(title, message);
    } on PlatformException catch (error) {
      throw BridgeException(error.code, error.message ?? '', error.details);
    } catch (error) {
      throw BridgeException(bridgeFailureCode, '$error', error);
    }
  }

  /// Native screen round-trip results; broadcast, may be subscribed many
  /// times. Events without subscribers are dropped silently.
  Stream<shell_api.NativeScreenResult> get nativeScreenResults =>
      _results.stream;

  /// Test/engine teardown only: closes the result stream and unregisters the
  /// FlutterApi handler. Late native callbacks are dropped by the host side.
  Future<void> dispose() async {
    shell_api.ShellFlutterApi.setUp(null);
    _initialized = false;
    await _results.close();
  }

  void _handleResult(shell_api.NativeScreenResult result) {
    if (_results.isClosed) {
      return;
    }
    _results.add(result);
  }

  static const String bridgeFailureCode = 'BRIDGE_FAILURE';
}

class _ResultHandler extends shell_api.ShellFlutterApi {
  new(this._bridge);

  final NativeBridge _bridge;

  @override
  void onNativeScreenResult(shell_api.NativeScreenResult result) {
    _bridge._handleResult(result);
  }
}
