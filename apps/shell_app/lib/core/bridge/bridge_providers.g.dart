// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bridge_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Native bridge instance. Overridden once in `bootstrap.dart`; keepAlive
/// because the wrapper owns the process-wide FlutterApi registration and the
/// result stream for the whole engine lifetime.

@ProviderFor(nativeBridge)
final nativeBridgeProvider = NativeBridgeProvider._();

/// Native bridge instance. Overridden once in `bootstrap.dart`; keepAlive
/// because the wrapper owns the process-wide FlutterApi registration and the
/// result stream for the whole engine lifetime.

final class NativeBridgeProvider
    extends $FunctionalProvider<NativeBridge, NativeBridge, NativeBridge>
    with $Provider<NativeBridge> {
  /// Native bridge instance. Overridden once in `bootstrap.dart`; keepAlive
  /// because the wrapper owns the process-wide FlutterApi registration and the
  /// result stream for the whole engine lifetime.
  NativeBridgeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nativeBridgeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nativeBridgeHash();

  @$internal
  @override
  $ProviderElement<NativeBridge> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NativeBridge create(Ref ref) {
    return nativeBridge(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NativeBridge value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NativeBridge>(value),
    );
  }
}

String _$nativeBridgeHash() => r'1cf8c705d7128794c8cd5d89f4467ff301f3a098';
