// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bridge_demo_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// System info, autoDispose: refetches on every page visit; refresh via
/// `ref.invalidate(systemInfoProvider)`.

@ProviderFor(systemInfo)
final systemInfoProvider = SystemInfoProvider._();

/// System info, autoDispose: refetches on every page visit; refresh via
/// `ref.invalidate(systemInfoProvider)`.

final class SystemInfoProvider
    extends
        $FunctionalProvider<
          AsyncValue<SystemInfo>,
          SystemInfo,
          FutureOr<SystemInfo>
        >
    with $FutureModifier<SystemInfo>, $FutureProvider<SystemInfo> {
  /// System info, autoDispose: refetches on every page visit; refresh via
  /// `ref.invalidate(systemInfoProvider)`.
  SystemInfoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'systemInfoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$systemInfoHash();

  @$internal
  @override
  $FutureProviderElement<SystemInfo> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<SystemInfo> create(Ref ref) {
    return systemInfo(ref);
  }
}

String _$systemInfoHash() => r'3474c319b8209d31e3d4e23915d49ec7c0a62416';

/// Native 1Hz ticker, autoDispose: leaving the page cancels the subscription
/// which stops the native ticker (logcat TICK_STOPPED).

@ProviderFor(tickCount)
final tickCountProvider = TickCountProvider._();

/// Native 1Hz ticker, autoDispose: leaving the page cancels the subscription
/// which stops the native ticker (logcat TICK_STOPPED).

final class TickCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  /// Native 1Hz ticker, autoDispose: leaving the page cancels the subscription
  /// which stops the native ticker (logcat TICK_STOPPED).
  TickCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tickCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tickCountHash();

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    return tickCount(ref);
  }
}

String _$tickCountHash() => r'fb51fa95b8786b10057fecafe6a6c44f96df25bd';

/// Native screen round-trip results, autoDispose while the demo page listens.

@ProviderFor(nativeScreenResults)
final nativeScreenResultsProvider = NativeScreenResultsProvider._();

/// Native screen round-trip results, autoDispose while the demo page listens.

final class NativeScreenResultsProvider
    extends
        $FunctionalProvider<
          AsyncValue<NativeScreenResult>,
          NativeScreenResult,
          Stream<NativeScreenResult>
        >
    with
        $FutureModifier<NativeScreenResult>,
        $StreamProvider<NativeScreenResult> {
  /// Native screen round-trip results, autoDispose while the demo page listens.
  NativeScreenResultsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nativeScreenResultsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nativeScreenResultsHash();

  @$internal
  @override
  $StreamProviderElement<NativeScreenResult> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<NativeScreenResult> create(Ref ref) {
    return nativeScreenResults(ref);
  }
}

String _$nativeScreenResultsHash() =>
    r'4ab3fed4c42841ff4d9589daac05f3342d191664';

/// Opens the native demo screen; presentation calls this through the
/// provider so it never touches [NativeBridge] directly.

@ProviderFor(openNativeScreen)
final openNativeScreenProvider = OpenNativeScreenFamily._();

/// Opens the native demo screen; presentation calls this through the
/// provider so it never touches [NativeBridge] directly.

final class OpenNativeScreenProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Opens the native demo screen; presentation calls this through the
  /// provider so it never touches [NativeBridge] directly.
  OpenNativeScreenProvider._({
    required OpenNativeScreenFamily super.from,
    required ({String title, String message}) super.argument,
  }) : super(
         retry: null,
         name: r'openNativeScreenProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$openNativeScreenHash();

  @override
  String toString() {
    return r'openNativeScreenProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument = this.argument as ({String title, String message});
    return openNativeScreen(
      ref,
      title: argument.title,
      message: argument.message,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is OpenNativeScreenProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$openNativeScreenHash() => r'be3e8714e1e407ad3c452ad0944d21c8f0d06b82';

/// Opens the native demo screen; presentation calls this through the
/// provider so it never touches [NativeBridge] directly.

final class OpenNativeScreenFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<bool>,
          ({String title, String message})
        > {
  OpenNativeScreenFamily._()
    : super(
        retry: null,
        name: r'openNativeScreenProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Opens the native demo screen; presentation calls this through the
  /// provider so it never touches [NativeBridge] directly.

  OpenNativeScreenProvider call({
    required String title,
    required String message,
  }) => OpenNativeScreenProvider._(
    argument: (title: title, message: message),
    from: this,
  );

  @override
  String toString() => r'openNativeScreenProvider';
}
